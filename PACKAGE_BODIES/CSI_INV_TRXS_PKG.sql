--------------------------------------------------------
--  DDL for Package Body CSI_INV_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_TRXS_PKG" as
-- $Header: csiivtxb.pls 120.14.12010000.5 2010/01/11 11:26:30 aradhakr ship $

l_Sysdate   DATE    := SYSDATE;

   PROCEDURE debug(p_message IN varchar2) IS
   BEGIN
      csi_t_gen_utility_pvt.add(p_message);
   EXCEPTION
     WHEN others THEN
       null;
   END debug;

   PROCEDURE misc_receipt(p_transaction_id     IN  NUMBER,
                          p_message_id         IN  NUMBER,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl            CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.MISC_RECEIPT';
   l_api_version             NUMBER          := 1.0;
   l_commit                  VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list           VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level        NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only    VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only  VARCHAR2(10)    := FND_API.G_FALSE;
   l_resolve_id_columns      VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id          NUMBER          := NULL;
   l_object_version_number   NUMBER          := 1;
   l_sysdate                 DATE            := SYSDATE;
   l_master_organization_id  NUMBER;
   l_depreciable             VARCHAR2(1);
   l_instance_query_rec      CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec     CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_api_src_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                 CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status           VARCHAR2(1);
   l_error_code              VARCHAR2(50);
   l_error_message           VARCHAR2(4000);
   l_instance_id_lst         CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec         CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec       CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_src_instance_header_tbl CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_ext_attrib_values_tbl   CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   l_party_tbl               CSI_DATASTRUCTURES_PUB.PARTY_TBL;
   l_account_tbl             CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
   l_pricing_attrib_tbl      CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   l_org_assignments_tbl     CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
   l_asset_assignment_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
   l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning             VARCHAR2(1) := 'W';
   l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected          VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_in_inventory       VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_INVENTORY;
   l_in_process         VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_PROCESS;
   l_out_of_service     VARCHAR2(25) := CSI_INV_TRXS_PKG.G_OUT_OF_SERVICE;
   l_out_of_enterprise  VARCHAR2(25) := 'OUT_OF_ENTERPRISE';
   l_in_relationship    VARCHAR2(25) := 'IN_RELATIONSHIP';
   l_in_service         VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit         VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed          VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_in_wip             VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_WIP;
   l_transaction_error_id    NUMBER;
   l_quantity                NUMBER;
   l_mfg_serial_flag         VARCHAR2(1);
   l_trans_status_code       VARCHAR2(15);
   l_ins_number              VARCHAR2(100);
   l_ins_id                  NUMBER;
   l_file                    VARCHAR2(500);
   l_status                  VARCHAR2(1000);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_sql_error               VARCHAR2(2000);
   l_msg_index               NUMBER;
   l_employee_id             NUMBER;
   j                         PLS_INTEGER;
   i                         PLS_INTEGER := 1;
   p                         PLS_INTEGER := 1;
   l_tbl_count               NUMBER := 0;
   b                         NUMBER;
   l_trans_type_code         VARCHAR2(25);
   l_trans_app_code          VARCHAR2(5);
   l_ownership_party         VARCHAR2(1);
   l_internal_party_id       NUMBER;                --added code for bug #5868111
   l_owner_party_id          NUMBER;                --added code for bug #5868111
   l_redeploy_flag           VARCHAR2(1);
   l_upd_error_instance_id   NUMBER := NULL;

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

   CURSOR c_obj_version (pc_instance_id IN NUMBER) is
     SELECT object_version_number
     FROM   csi_item_instances
     WHERE  instance_id = pc_instance_id;

   CURSOR c_phys_inv_info (pc_physical_adjustment_id IN NUMBER) is
     SELECT mpi.physical_inventory_id    physical_inventory_id,
            mpi.physical_inventory_name  physical_inventory_name,
            mpit.tag_number              tag_number
     FROM mtl_physical_adjustments mpa,
          mtl_physical_inventories mpi,
          mtl_physical_inventory_tags mpit
     WHERE mpa.physical_inventory_id = mpi.physical_inventory_id
     AND   mpa.physical_inventory_id = mpit.physical_inventory_id
     AND   mpa.adjustment_id = mpit.adjustment_id
     AND   mpa.adjustment_id = pc_physical_adjustment_id;

   r_phys_inv_info     c_phys_inv_info%rowtype;

   CURSOR c_cycle_count_info (pc_cycle_count_entry_id IN NUMBER) is
     SELECT mcch.cycle_count_header_id   cycle_count_header_id,
            mcch.cycle_count_header_name cycle_count_header_name
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.cycle_count_header_id = mcch.cycle_count_header_id
     AND mcce.cycle_count_entry_id = pc_cycle_count_entry_id;

   r_cycle_count_info     c_cycle_count_info%rowtype;

   BEGIN
     x_return_status := l_fnd_success;

     debug('*****Start of csi_inv_trxs_pkg.misc_receipt Transaction procedure*****');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiivtxb.pls 115.25');
     debug('Transaction You are Processing is: '||p_transaction_id);

     -- This procedure queries all of the Inventory Transaction Records and returns them
     -- as a table.

     debug('Executing csi_inv_trxs_pkg.get_transaction_recs');

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

     -- Determine Trasaction Type
     IF l_mtl_item_tbl(i).transaction_type_id = 8 THEN
       l_trans_type_code := 'PHYSICAL_INVENTORY';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 4 THEN
       l_trans_type_code := 'CYCLE_COUNT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 40 THEN
       l_trans_type_code := 'ACCT_RECEIPT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 41 THEN
       l_trans_type_code := 'ACCT_ALIAS_RECEIPT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 71 THEN
       l_trans_type_code := 'PO_RCPT_ADJUSTMENT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 72 THEN
       l_trans_type_code := 'INT_REQ_RCPT_ADJUSTMENT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 70 THEN
       l_trans_type_code := 'SHIPMENT_RCPT_ADJUSTMENT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 42 THEN
       l_trans_type_code := 'MISC_RECEIPT';
       l_trans_app_code  := 'INV';
     ELSE
       l_trans_type_code := 'MISC_RECEIPT';
       l_trans_app_code  := 'INV';
     END IF;

     debug('Trans Type Code: '||l_trans_type_code);
     debug('Trans App Code: '||l_trans_app_code);


     -- Get the Master Organization ID

     debug('Executing csi_inv_trxs_pkg.get_master_organization');

     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                             l_master_organization_id,
                                             l_return_status,
                                             l_error_message);

     debug('Master Organization is: '||l_master_organization_id);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id

     debug('Executing csi_inv_trxs_pkg.get_fnd_employee_id');

     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       debug('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
     END IF;

     debug('The Employee that is processing this Transaction is: '||l_employee_id);

     -- See if this is a depreciable Item to set the status of the transaction record

     debug('Executing csi_inv_trxs_pkg.check_depreciable');

     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                            l_depreciable);

     debug('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);

     -- Set the mfg_serial_number_flag and quantity
     IF l_mtl_item_tbl(i).serial_number IS NULL THEN
       l_mfg_serial_flag := 'N';
       l_quantity        := l_mtl_item_tbl(i).transaction_quantity;
     ELSE
       l_mfg_serial_flag := 'Y';
       l_quantity        := 1;
     END IF;

     debug('The mfg_serial_flag is: '||l_mfg_serial_flag);
     debug('The Quantity is: '||l_quantity);
     debug('The Transaction Status will be - Complete or Pending: '||l_trans_status_code);

     -- Get Party ownership Flag
     l_ownership_party := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;
     l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;             --added code for bug #5868111

     debug('Ownership Party FLag is: '||l_ownership_party);
     debug('Internal Party Id is   : '||l_internal_party_id);                                         --added code for bug #5868111

     -- Get Default CSI Status from Profile
     OPEN c_id;
     FETCH c_id into r_id;
     CLOSE c_id;

     debug('Instance Status from Profile: '||r_id.instance_status_id);

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
     l_txn_rec.object_version_number        :=  l_object_version_number;


     IF l_mtl_item_tbl(i).transaction_type_id = 8 THEN
       OPEN c_phys_inv_info (l_mtl_item_tbl(i).physical_adjustment_id);
       FETCH c_phys_inv_info into r_phys_inv_info;
       CLOSE c_phys_inv_info;

       l_txn_rec.source_header_ref_id := r_phys_inv_info.physical_inventory_id;
       l_txn_rec.source_header_ref := r_phys_inv_info.physical_inventory_name;
       l_txn_rec.source_line_ref := r_phys_inv_info.tag_number;

       debug('MMT Phys Adj ID: '||l_mtl_item_tbl(i).physical_adjustment_id);
       debug('Physical Inventory ID: '||l_txn_rec.source_header_ref_id);
       debug('Physical Inventory Name: '||l_txn_rec.source_header_ref);

     ELSIF l_mtl_item_tbl(i).transaction_type_id = 4 THEN

       OPEN c_cycle_count_info (l_mtl_item_tbl(i).cycle_count_id);
       FETCH c_cycle_count_info into r_cycle_count_info;
       CLOSE c_cycle_count_info;

       l_txn_rec.source_header_ref_id := r_cycle_count_info.cycle_count_header_id;
       l_txn_rec.source_header_ref := r_cycle_count_info.cycle_count_header_name;

       debug('MMT Cycle Count ID: '||l_mtl_item_tbl(i).cycle_count_id);
       debug('Cycle Count ID: '||l_txn_rec.source_header_ref_id);
       debug('Cycle Count Name: '||l_txn_rec.source_header_ref);

     END IF;

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

       IF l_mtl_item_tbl(j).serial_number IS NOT NULL THEN -- Serialized

         csi_inv_trxs_pkg.set_item_attr_query_values(l_mtl_item_tbl,
                                                     j,
                                                     NULL,
                                                     l_instance_query_rec,
                                                     x_return_status);

         csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec => l_instance_query_rec);

         debug('Calling get_item_instance');

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
                                                  l_src_instance_header_tbl,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

         debug('After get_item_instance');

         l_tbl_count := 0;
         l_tbl_count := l_src_instance_header_tbl.count;

         debug('Source Records Found: '||l_tbl_count);

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
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

       IF l_src_instance_header_tbl.count = 0 THEN -- No Records found so Create Serialized record
         debug('No Records found so Create a Serialized Record');

         l_new_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_instance_rec.serial_number                :=  l_mtl_item_tbl(j).serial_number;
         l_new_instance_rec.mfg_serial_number_flag       :=  'Y';
         l_new_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_instance_rec.quantity                     :=  1;
         l_new_instance_rec.active_start_date            :=  l_sysdate;
         l_new_instance_rec.active_end_date              :=  NULL;
         l_new_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).primary_uom_code;
         l_new_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_instance_rec.customer_view_flag           :=  'N';
         l_new_instance_rec.merchant_view_flag           :=  'Y';
         l_new_instance_rec.object_version_number        :=  l_object_version_number;
         l_new_instance_rec.operational_status_code      :=  'NOT_USED';
         l_ext_attrib_values_tbl                         :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl                                     :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl                                   :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl                            :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl                           :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl                          :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         l_new_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('Instance_status_id Value: '||nvl(l_new_instance_rec.instance_status_id,-1));
         debug('You will now Create a new Item Instance Record');
         debug('Serial Number: '||l_new_instance_rec.serial_number);

         csi_item_instance_pub.create_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_new_instance_rec,
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

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
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

         debug('Item Instance Created: '||l_new_instance_rec.instance_id);

       ELSIF l_src_instance_header_tbl.count = 1 THEN

           debug('Records were found');

           IF l_src_instance_header_tbl(i).instance_usage_code in (l_out_of_service,
                                                                   l_in_inventory,
                                                                   l_installed,
                                                                   l_in_service,
                                                                   l_in_process) THEN

           debug('Update Serialized Item which is OUT NOCOPY Of Service');
           debug('Serial Number is: '||l_src_instance_header_tbl(i).serial_number);

           l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.quantity                     :=  1;
           l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
	   -- Added for bug 5975739
	   l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           --l_update_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
           l_update_instance_rec.active_end_date              :=  NULL;
           l_update_instance_rec.pa_project_id                :=  NULL;
           l_update_instance_rec.pa_project_task_id           :=  NULL;
           l_update_instance_rec.install_location_type_code   :=  NULL;
           l_update_instance_rec.install_location_id          :=  NULL;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
           l_update_instance_rec.instance_status_id           := l_src_instance_header_tbl(i).instance_status_id;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           -- Bug 9091915
           -- When instance status id is available for a source instance
           -- the status id should not be updated
           IF NVL(l_update_instance_rec.instance_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
           l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);
           END IF;

           debug('Before Update Item Instance');

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

           debug('Update of Item instance that is '||l_src_instance_header_tbl(i).instance_usage_code);
           debug('Update Item Instance is: '||l_update_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
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

         ELSIF l_src_instance_header_tbl(i).instance_usage_code in (l_out_of_enterprise,l_in_relationship,l_in_wip) THEN

            IF l_ownership_party = 'Y' THEN

            IF l_src_instance_header_tbl(i).instance_usage_code = l_in_relationship THEN
              debug('Check and Break Relationship for Instance :'||l_src_instance_header_tbl(i).instance_id);

              csi_process_txn_pvt.check_and_break_relation(l_src_instance_header_tbl(i).instance_id,
                                                           l_txn_rec,
                                                           l_return_status);

             IF NOT l_return_status = l_fnd_success then
               debug('You encountered an error in the se_inv_trxs_pkg.check_and_break_relation');
               l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
               RAISE fnd_api.g_exc_error;
             END IF;

            debug('Object Version originally from instance: '||l_src_instance_header_tbl(i).object_version_number);

            OPEN c_obj_version (l_src_instance_header_tbl(i).instance_id);
            FETCH c_obj_version into l_src_instance_header_tbl(i).object_version_number;
            CLOSE c_obj_version;

            debug('Current Object Version after check and break :'||l_src_instance_header_tbl(i).object_version_number);

            END IF; -- Check and Break

	        debug('Update Serialized Item which is :'||l_src_instance_header_tbl(i).instance_usage_code);
	        debug('Serial Number is: '||l_src_instance_header_tbl(i).serial_number);

           l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.quantity                     :=  1;
           l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
           l_update_instance_rec.mfg_serial_number_flag       :=  'Y';
	   -- Added for Bug 5975739
	   l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           --l_update_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
           l_update_instance_rec.active_end_date              :=  NULL;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
	     --bnarayan for the bug4540920
           l_update_instance_rec.install_location_type_code   :=  NULL;
           l_update_instance_rec.install_location_id          :=  NULL;
           l_update_instance_rec.instance_status_id           := l_src_instance_header_tbl(i).instance_status_id;


  -- code added for bug #5868111....start here

  IF l_ownership_party = 'Y' THEN

            -- Get Owner Party ID of the Instance.

             BEGIN
               SELECT owner_party_id
               INTO l_owner_party_id
               FROM csi_item_instances
               WHERE instance_id = l_src_instance_header_tbl(i).instance_id;

             EXCEPTION
               WHEN no_data_found THEN
                 l_owner_party_id := -99999;
             END;

  -- code added for bug #5868111....end here


          -- We want to change the party of this back
          -- to the Internal Party

            debug('Usage is '||l_src_instance_header_tbl(i).instance_usage_code);
            debug('We need to bring this back into Inventory and change the Owner Party back to the Internal Party if the Instance is not already at the Internal Party');      --added code for bug #5868111
            debug('Current Owner Party; '||l_owner_party_id);                 --added code for bug #5868111
            debug('Owner Party   : '||l_owner_party_id);                      --added code for bug #5868111
            debug('Internal Party: '||l_internal_party_id);                   --added code for bug #5868111


        IF l_owner_party_id  <> l_internal_party_id THEN                             --added code for bug #5868111

  	   -- Set Instance ID so it will query the child recs for this
	   -- Instance.

	   l_instance_header_rec.instance_id := l_src_instance_header_tbl(i).instance_id;
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
                   l_party_tbl(i).instance_id    :=  l_src_instance_header_tbl(i).instance_id;
                   l_party_tbl(i).instance_party_id :=  l_party_header_tbl(p).instance_party_id;
                   l_party_tbl(i).object_version_number := l_party_header_tbl(p).object_version_number;
                   debug('After finding the OWNER party and updating this back to the Internal Party ID');
	         END IF;-- Owner Party
               END LOOP;

                 debug('Inst Party ID :'||l_party_tbl(i).instance_party_id);
                 debug('Party Inst ID :'||l_party_tbl(i).instance_id);
                 debug('Party Source Table :'||l_party_tbl(i).party_source_table);
                 debug('Party ID :'||l_party_tbl(i).party_id);
                 debug('Rel Type Code :'||l_party_tbl(i).relationship_type_code);
                 debug('Contact Flag :'||l_party_tbl(i).contact_flag);
                 debug('Object Version Number:' ||l_party_tbl(i).object_version_number);

		 --code added for bug #5868111....start here

        ELSE  --Instance is already at Internal Party
                 l_party_tbl.delete;

        END IF; -- Party Header vs Int Party Id

  ELSE -- Ownership "N"

      debug('Ownership Override is "N" so get the Owner Party ID and compare to the Internal Party ID');


             BEGIN
               SELECT owner_party_id
               INTO l_owner_party_id
               FROM csi_item_instances
               WHERE instance_id = l_src_instance_header_tbl(i).instance_id;

             EXCEPTION
               WHEN no_data_found THEN
                 l_owner_party_id := -99999;
             END;

             debug('Owner Party   : '||l_owner_party_id);
             debug('Internal Party: '||l_internal_party_id);

             IF l_owner_party_id <> l_internal_party_id THEN

               l_status := 'In Inventory, Out of Service, Installed, In Process or In Service ';
             debug('Serialized Item with In Inventory, Out of Service, Installed, In Process or In Service exists however the ownership_override_at_txn flag is set to N');
             debug('The current owner party is not the Internal Party so we will NOT bring this back into inventory');
             debug('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);

             fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
             fnd_message.set_token('STATUS',l_status);
               l_error_message := fnd_message.get;
               l_return_status := l_fnd_error;
               RAISE fnd_api.g_exc_error;
             ELSE
               l_party_tbl.delete;
             END IF;
           END IF;


--code added for bug #5868111....end here

           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           -- Bug 9091915
           -- When instance status id is available for a source instance
           -- the status id should not be updated
           IF NVL(l_update_instance_rec.instance_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
           l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);
           END IF;

           debug('Before Update Item Instance');

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

           debug('Update of Item instance that is '||l_src_instance_header_tbl(i).instance_usage_code); --code added for bug #5868111
           debug('Update Item Instance is: '||l_update_instance_rec.instance_id);
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
          ELSE
             l_status := 'In Inventory, Out of Service, Out of Enterprise, In Relationship, Installed, In Service or In Process';
             debug('Serialized Item with Out of Enterprise or In Relationship exists however the ownership_override_at_txn flag is set to N so we will NOT bring this back into inventory');
             debug('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);
             fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
             fnd_message.set_token('STATUS',l_status);
             l_error_message := fnd_message.get;
             l_return_status := l_fnd_error;
             RAISE fnd_api.g_exc_error;
           END IF;
        ELSE
          l_status := 'In Inventory, Out of Service, Installed, In Service or In Process';
          debug('Serialized Item with Status other then Out Of Service, In Inventory, Installed, or In Process already exists in Install Base');
          debug('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);
          fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
          fnd_message.set_token('STATUS',l_status);
          l_error_message := fnd_message.get;
          l_return_status := l_fnd_error;
          RAISE fnd_api.g_exc_error;
          END IF;
       ELSE --   No API Records so create a new serialized record
         l_new_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_instance_rec.serial_number                :=  l_mtl_item_tbl(j).serial_number;
         l_new_instance_rec.mfg_serial_number_flag       :=  'Y';
         l_new_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_instance_rec.quantity                     :=  1;
         l_new_instance_rec.active_start_date            :=  l_sysdate;
         l_new_instance_rec.active_end_date              :=  NULL;
         l_new_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_new_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_instance_rec.customer_view_flag           :=  'N';
         l_new_instance_rec.merchant_view_flag           :=  'Y';
         l_new_instance_rec.object_version_number        :=  l_object_version_number;
         l_new_instance_rec.operational_status_code      :=  'NOT_USED';
         l_ext_attrib_values_tbl                         :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl                                     :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl                                   :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl                            :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl                           :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl                          :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         l_new_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('You will now Create a new Item Instance Record');

         csi_item_instance_pub.create_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_new_instance_rec,
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

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
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

        debug('Item Instance Created: '||l_new_instance_rec.instance_id);

      END IF;     -- End of Serialized Source Block

      ELSIF l_mtl_item_tbl(j).serial_number IS NULL THEN -- Non Serialized

         csi_inv_trxs_pkg.set_item_attr_query_values(l_mtl_item_tbl,
                                                     j,
                                                     NULL,
                                                     l_instance_query_rec,
                                                     x_return_status);

         l_instance_query_rec.inv_organization_id    :=  l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.inv_subinventory_name  :=  l_mtl_item_tbl(j).subinventory_code;
         l_instance_query_rec.instance_usage_code    :=  l_in_inventory;

         csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec => l_instance_query_rec);


         debug('Calling get_item_instance');

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
                                                  l_src_instance_header_tbl,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

          debug('After get_item_instance');

          l_tbl_count := 0;
          l_tbl_count := l_src_instance_header_tbl.count;

          debug('Source Records Found: '||l_tbl_count);

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
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

       IF l_src_instance_header_tbl.count = 0 THEN -- No Records found so Create either Serialized or Non Serialized
            debug('No Records found so Create a Record for Non-Serialized');

         l_new_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_instance_rec.mfg_serial_number_flag       :=  'N';
         l_new_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
         l_new_instance_rec.active_start_date            :=  l_sysdate;
         l_new_instance_rec.active_end_date              :=  NULL;
         l_new_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_new_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_instance_rec.customer_view_flag           :=  'N';
         l_new_instance_rec.merchant_view_flag           :=  'Y';
         l_new_instance_rec.object_version_number        :=  l_object_version_number;
         l_new_instance_rec.operational_status_code      :=  'NOT_USED';
         l_ext_attrib_values_tbl                         :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl                                     :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl                                   :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl                            :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl                           :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl                          :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         l_new_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('You will now Create a new Item Instance Record');

         csi_item_instance_pub.create_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_new_instance_rec,
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

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
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
            debug('Item Instance Created: '||l_new_instance_rec.instance_id);

       ELSIF l_src_instance_header_tbl.count = 1 THEN
         -- Update Non Serialized Item
            debug('1 Instance Record was found');

              debug('Update the Non-Serialized, In-Inventory Item Instance record');

           l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
           l_update_instance_rec.active_end_date              :=  NULL;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
           l_update_instance_rec.instance_status_id           := l_src_instance_header_tbl(i).instance_status_id;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           -- Bug 9091915
           -- When instance status id is available for a source instance
           -- the status id should not be updated
           IF NVL(l_update_instance_rec.instance_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
           l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);
           END IF;

           debug('Before Update Item Instance');

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

           debug('Item Instance Updated: '||l_update_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
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
         debug('Multiple Instances were Found in Install Base Base-20');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

      END IF;     -- End of Source Record If
      END IF;     -- End of Serialized Item If
     END LOOP;    -- End of For Loop

     debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('*****End of csi_inv_trxs_pkg.misc_receipt Transaction*****');

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       debug('You have encountered a "fnd_api.g_exc_error" exception');
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
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIMSRCV';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  :=  csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
       l_sql_error := SQLERRM;
       debug('You have encountered a "others" exception');
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
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := fnd_message.get;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIMSRCV';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  :=  csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END misc_receipt;

   PROCEDURE receipt_inventory(p_transaction_id     IN  NUMBER,
                               p_message_id         IN  NUMBER,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl                CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                    VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.RECEIPT_INVENTORY';
   l_api_version                 NUMBER          := 1.0;
   l_commit                      VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list               VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level            NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only        VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only      VARCHAR2(10)    := FND_API.G_FALSE;
   l_resolve_id_columns          VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id              NUMBER          := NULL;
   l_object_version_number       NUMBER          := 1;
   l_sysdate                     DATE            := SYSDATE;
   l_master_organization_id      NUMBER;
   l_depreciable                 VARCHAR2(1);
   l_instance_query_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec            CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                     CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_dest_instance_rec           CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_api_src_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_return_status               VARCHAR2(1);
   l_error_code                  VARCHAR2(50);
   l_error_message               VARCHAR2(4000);
   l_instance_id_lst             CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec             CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec           CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_src_instance_header_tbl     CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_ext_attrib_values_tbl       CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   l_party_tbl                   CSI_DATASTRUCTURES_PUB.PARTY_TBL;
   l_account_tbl                 CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
   l_pricing_attrib_tbl          CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   l_org_assignments_tbl         CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
   l_asset_assignment_tbl        CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
   l_fnd_success                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning                 VARCHAR2(1) := 'W';
   l_fnd_error                   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_in_inventory                VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_INVENTORY;
   l_in_process                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_PROCESS;
   l_out_of_service              VARCHAR2(25) := CSI_INV_TRXS_PKG.G_OUT_OF_SERVICE;
   l_out_of_enterprise           VARCHAR2(25) := 'OUT_OF_ENTERPRISE';
   l_in_relationship             VARCHAR2(25) := 'IN_RELATIONSHIP';
   l_in_service                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed                   VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_in_wip                      VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_WIP;
   l_transaction_error_id        NUMBER;
   l_quantity                    NUMBER;
   l_mfg_serial_flag             VARCHAR2(1);
   l_trans_status_code           VARCHAR2(15);
   l_ins_number                  VARCHAR2(100);
   l_ins_id                      NUMBER;
   l_file                        VARCHAR2(500);
   l_status                      VARCHAR2(1000);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_sql_error                   VARCHAR2(2000);
   l_msg_index                   NUMBER;
   l_employee_id                 NUMBER;
   j                             PLS_INTEGER;
   i                             PLS_INTEGER := 1;
   p                             PLS_INTEGER := 1;
   l_tbl_count                   NUMBER :=0;
   l_sql                         VARCHAR2(2000);
   l_ownership_party             VARCHAR2(1);
   l_internal_party_id           NUMBER;       --added code for bug #5868111
   l_owner_party_id              NUMBER;       --added code for bug #5868111
   l_redeploy_flag               VARCHAR2(1);
   l_upd_error_instance_id       NUMBER := NULL;

   l_instance_header_rec     csi_datastructures_pub.instance_header_rec;
   l_party_header_tbl        csi_datastructures_pub.party_header_tbl;
   l_account_header_tbl      csi_datastructures_pub.party_account_header_tbl;
   l_org_header_tbl          csi_datastructures_pub.org_units_header_tbl;
   l_pricing_header_tbl      csi_datastructures_pub.pricing_attribs_tbl;
   l_ext_attrib_header_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
   l_ext_attrib_def_tbl      csi_datastructures_pub.extend_attrib_tbl;
   l_asset_header_tbl        csi_datastructures_pub.instance_asset_header_tbl;

   CURSOR c_po_info (pc_po_distribution_id in number) is
     SELECT pod.po_header_id  po_header_id,
            pod.po_line_id    po_line_id,
            pol.line_num      po_line_number,
            poh.segment1      po_number,
            pol.unit_price    unit_price,
            poh.currency_code currency_code
     FROM po_distributions_all pod,
          po_headers_all       poh,
          po_lines_all         pol
     WHERE pod.po_distribution_id = pc_po_distribution_id
     AND   pod.po_header_id       = poh.po_header_id
     AND   pod.po_line_id         = pol.po_line_id
     AND   poh.po_header_id       = pol.po_header_id;

   r_po_info     c_po_info%rowtype;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   CURSOR c_obj_version (pc_instance_id IN NUMBER) is
     SELECT object_version_number
     FROM   csi_item_instances
     WHERE  instance_id = pc_instance_id;

   BEGIN
     x_return_status := l_fnd_success;

     debug('*****Start of csi_inv_trxs_pkg.receipt_inventory Transaction procedure*****');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('Transaction You are Processing is: '||p_transaction_id);

     -- This procedure queries all of the Inventory Transaction Records and
     -- returns them as a table.

     debug('Executing csi_inv_trxs_pkg.get_transaction_recs');

     csi_inv_trxs_pkg.get_transaction_recs(p_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;

     debug('Source Records Found: '||l_tbl_count);

     IF NOT l_return_status = l_fnd_success THEN
          debug('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||p_transaction_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Get the Master Organization ID

     debug('Executing csi_inv_trxs_pkg.get_master_organization');

     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id

     debug('Executing csi_inv_trxs_pkg.get_fnd_employee_id');

     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       debug('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
     END IF;

     debug('The Employee that is processing this Transaction is: '||l_employee_id);

     -- See if this is a depreciable Item to set the status of the transaction record

     debug('Executing csi_inv_trxs_pkg.check_depreciable');

     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                            l_depreciable);

     debug('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);

     -- Set the mfg_serial_number_flag and quantity
     IF l_mtl_item_tbl(i).serial_number is NULL THEN
       l_mfg_serial_flag := 'N';
       l_quantity        := l_mtl_item_tbl(i).transaction_quantity;
     ELSE
       l_mfg_serial_flag := 'Y';
       l_quantity        := 1;
     END IF;

     -- Get Party ownership Flag
     l_ownership_party := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;
     l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;        --added code for bug #5868111

     debug('Ownership Flag is: '||l_ownership_party);
     debug('Internal Party Id is   : '||l_internal_party_id);                                    --added code for bug #5868111

     -- Get Default CSI Status from Profile
     OPEN c_id;
     FETCH c_id into r_id;
     CLOSE c_id;

     debug('Instance Status from Profile: '||r_id.instance_status_id);

     -- Added so that the PO_HEADER_ID and PO_LINE_ID can be added to
     -- the transaction record.

     OPEN c_po_info (l_mtl_item_tbl(i).po_distribution_id);
     FETCH c_po_info into r_po_info;
     CLOSE c_po_info;

     debug('PO Number: '||r_po_info.po_number);
     debug('PO Line Number: '||r_po_info.po_line_number);
     debug('PO Header ID: '||r_po_info.po_header_id);
     debug('PO Line ID: '||r_po_info.po_line_id);
     debug('PO Unit Price: '||r_po_info.unit_price);
     debug('PO Currency Code: '||r_po_info.currency_code);

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
     l_txn_rec.transaction_type_id      :=  csi_inv_trxs_pkg.get_txn_type_id('PO_RECEIPT_INTO_INVENTORY','INV');
     l_txn_rec.transaction_quantity     := l_mtl_item_tbl(i).transaction_quantity;
     l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
     l_txn_rec.transacted_by            :=  l_employee_id;
     l_txn_rec.transaction_action_code  :=  NULL;
     l_txn_rec.message_id               :=  p_message_id;
     l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
     l_txn_rec.object_version_number    :=  l_object_version_number;
     l_txn_rec.source_dist_ref_id1      :=  l_mtl_item_tbl(i).po_distribution_id;
     l_txn_rec.source_dist_ref_id2      :=  l_mtl_item_tbl(i).rcv_transaction_id;
     l_txn_rec.source_header_ref_id     :=  r_po_info.po_header_id;
     l_txn_rec.source_line_ref_id       :=  r_po_info.po_line_id;
     l_txn_rec.source_header_ref        :=  r_po_info.po_number;
     l_txn_rec.source_line_ref          :=  to_char(r_po_info.po_line_number);

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
        debug('PO_HEADER_ID is: '||r_po_info.po_header_id);
        debug('PO_LINE_ID is: '||r_po_info.po_line_id);

     IF l_mtl_item_tbl(j).serial_number IS NOT NULL THEN -- Serialized

       csi_inv_trxs_pkg.set_item_attr_query_values(l_mtl_item_tbl,
                                                   j,
                                                   NULL,
                                                   l_instance_query_rec,
                                                   x_return_status);

       csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec => l_instance_query_rec);

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
                                                l_inactive_instance_only,
                                                l_src_instance_header_tbl,
                                                l_return_status,
                                                l_msg_count,
                                                l_msg_data);

       debug('After Get Item Instance');

       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;

       debug('Source Records Found: '||l_tbl_count);

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
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

       IF l_src_instance_header_tbl.count < 1 THEN -- No Records found so Create either Serialized Item

         debug('No source records were found so create a new one');
         l_new_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_instance_rec.serial_number                :=  l_mtl_item_tbl(j).serial_number;
         l_new_instance_rec.mfg_serial_number_flag       :=  l_mfg_serial_flag;
         l_new_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_instance_rec.quantity                     :=  abs(l_quantity);
         l_new_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).primary_uom_code;
         l_new_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_instance_rec.last_po_po_line_id           :=  r_po_info.po_line_id; --5184815
         l_new_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_instance_rec.customer_view_flag           :=  'N';
         l_new_instance_rec.merchant_view_flag           :=  'Y';
         l_new_instance_rec.object_version_number        :=  l_object_version_number;
         l_new_instance_rec.operational_status_code      :=  'NOT_USED';
         l_new_instance_rec.active_start_date            :=  l_sysdate;
         l_new_instance_rec.active_end_date              :=  NULL;
         l_new_instance_rec.purchase_unit_price          :=  r_po_info.unit_price;
         l_new_instance_rec.purchase_currency_code       :=  r_po_info.currency_code;

         l_ext_attrib_values_tbl                         :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl                                     :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl                                   :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl                            :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl                           :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl                          :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         l_new_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('Before Create of new source Item Instance');

         csi_item_instance_pub.create_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_new_instance_rec,
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


         debug('After Create Item Instance');
         debug('Item Instance Created: '||l_new_instance_rec.instance_id);

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
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

       --ELSIF l_src_instance_header_tbl.count > 0 THEN -- Records Found
       ELSIF l_src_instance_header_tbl.count = 1 THEN -- Records Found

         IF l_src_instance_header_tbl(i).instance_usage_code in (l_out_of_service,
                                                                 l_in_inventory,
                                                                 l_installed,
                                                                 l_in_service,
                                                                 l_in_process) THEN
         -- Update Serialized Item

         debug('Serialized Source records found');
         debug('Update Serialized Item which is :'||l_src_instance_header_tbl(i).instance_usage_code);
         debug('Serial Number is: '||l_src_instance_header_tbl(i).serial_number);
         debug('Updating Item Instance: '||l_src_instance_header_tbl(i).instance_id);

         l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
         l_update_instance_rec.quantity                     :=  1;
         l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
	 --Added For Bug 5975739
	 l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_update_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         --l_update_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
    	 l_update_instance_rec.last_po_po_line_id           :=  r_po_info.po_line_id; --5184815
         l_update_instance_rec.active_end_date              :=  NULL;
         l_update_instance_rec.pa_project_id                :=  NULL;
         l_update_instance_rec.pa_project_task_id           :=  NULL;
         l_update_instance_rec.install_location_type_code   :=  NULL;
         l_update_instance_rec.install_location_id          :=  NULL;
         l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

         l_party_tbl.delete;
         l_account_tbl.delete;
         l_pricing_attrib_tbl.delete;
         l_org_assignments_tbl.delete;
         l_asset_assignment_tbl.delete;

         l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('Right after setting instance status');
         debug('Before Update item instance');

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

         debug('After get item instance');
         debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
         IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
           debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
           debug('Message Count: '||l_msg_count);
           debug('Return Status: '||l_return_status);
           l_msg_index := 1;
           WHILE l_msg_count > 0 loop
             l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
 	   END LOOP;
	   RAISE fnd_api.g_exc_error;
         END IF;

          ELSIF l_src_instance_header_tbl(i).instance_usage_code in (l_out_of_enterprise,l_in_relationship,l_in_wip) THEN

         IF l_ownership_party = 'Y' THEN


            IF l_src_instance_header_tbl(i).instance_usage_code = l_in_relationship THEN
              debug('Check and Break Relationship for Instance :'||l_src_instance_header_tbl(i).instance_id);

              csi_process_txn_pvt.check_and_break_relation(l_src_instance_header_tbl(i).instance_id,
                                                           l_txn_rec,
                                                           l_return_status);

             IF NOT l_return_status = l_fnd_success then
               debug('You encountered an error in the se_inv_trxs_pkg.check_and_break_relation');
               l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
               RAISE fnd_api.g_exc_error;
             END IF;

            debug('Object Version originally from instance: '||l_src_instance_header_tbl(i).object_version_number);

            OPEN c_obj_version (l_src_instance_header_tbl(i).instance_id);
            FETCH c_obj_version into l_src_instance_header_tbl(i).object_version_number;
            CLOSE c_obj_version;

            debug('Current Object Version after check and break :'||l_src_instance_header_tbl(i).object_version_number);

            END IF; -- Check and Break

           debug('Update Serialized Item which is :'||l_src_instance_header_tbl(i).instance_usage_code);
           debug('Serial Number is: '||l_src_instance_header_tbl(i).serial_number);

         l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
         l_update_instance_rec.quantity                     :=  1;
         l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
	 -- Added for Bug 5975739
	 l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_update_instance_rec.mfg_serial_number_flag       :=  'Y';
	 l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
	 l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_update_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
        -- l_update_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
	 l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
	 l_update_instance_rec.last_po_po_line_id           :=  r_po_info.po_line_id; --5184815
         l_update_instance_rec.active_end_date              :=  NULL;
         l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
	   --bnarayan for the bug4549020
         l_update_instance_rec.install_location_type_code   :=  NULL;
         l_update_instance_rec.install_location_id          :=  NULL;


IF l_ownership_party = 'Y' THEN  --added code for bug #5868111

	  -- We want to change the party of this back
	  -- to the Internal Party

           debug('Usage is '||l_src_instance_header_tbl(i).instance_usage_code||' So we need to bring this back into Inventory and change the Owner Party back to the Internal Party');

  	   -- Set Instance ID so it will query the child recs for this
	   -- Instance.

	   l_instance_header_rec.instance_id := l_src_instance_header_tbl(i).instance_id;
/*Code changes for bug 8842177**/
         -- Get Owner Party ID of the Instance.

             BEGIN
               SELECT owner_party_id
               INTO l_owner_party_id
               FROM csi_item_instances
               WHERE instance_id = l_src_instance_header_tbl(i).instance_id;

             EXCEPTION
               WHEN no_data_found THEN
                 l_owner_party_id := -99999;
             END;

        IF l_owner_party_id  <> l_internal_party_id THEN                             --added code for bug #5868111

  	   -- Set Instance ID so it will query the child recs for this
	   -- Instance.

	   l_instance_header_rec.instance_id := l_src_instance_header_tbl(i).instance_id;
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
                   l_party_tbl(i).instance_id    :=  l_src_instance_header_tbl(i).instance_id;
                   l_party_tbl(i).instance_party_id :=  l_party_header_tbl(p).instance_party_id;
                   l_party_tbl(i).object_version_number := l_party_header_tbl(p).object_version_number;
                   debug('After finding the OWNER party and updating this back to the Internal Party ID');
	         END IF;-- Owner Party
               END LOOP;

                 debug('Inst Party ID :'||l_party_tbl(i).instance_party_id);
                 debug('Party Inst ID :'||l_party_tbl(i).instance_id);
                 debug('Party Source Table :'||l_party_tbl(i).party_source_table);
                 debug('Party ID :'||l_party_tbl(i).party_id);
                 debug('Rel Type Code :'||l_party_tbl(i).relationship_type_code);
                 debug('Contact Flag :'||l_party_tbl(i).contact_flag);
                 debug('Object Version Number:' ||l_party_tbl(i).object_version_number);

		 --code added for bug #5868111....start here

        ELSE  --Instance is already at Internal Party
                 l_party_tbl.delete;

        END IF; -- Party Header vs Int Party Id

/*Code changes for bug 8842177**/

-- code added for bug #5868111...starts below

ELSE -- Ownership "N"

          debug('Ownership Override is "N" so get the Owner Party ID and compare to the Internal Party ID');

                BEGIN
                  SELECT owner_party_id
                  INTO l_owner_party_id
                  FROM csi_item_instances
                  WHERE instance_id = l_src_instance_header_tbl(i).instance_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    l_owner_party_id := -99999;
                END;

                IF l_owner_party_id <> l_internal_party_id THEN

                  l_status := 'In Inventory, Out of Service, Installed, In Process or In Service ';
                  debug('Serialized Item with In Inventory, Out of Service, Installed, In Process or In Service exists however the ownership_override_at_txn flag is set to N');
                  debug('The current owner party is not the Internal Party so we will NOT bring this back into inventory');
                  debug('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);
                  fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
                  fnd_message.set_token('STATUS',l_status);
                  l_error_message := fnd_message.get;
                  l_return_status := l_fnd_error;
                  RAISE fnd_api.g_exc_error;
                ELSE
                  l_party_tbl.delete;
                END IF;
              END IF;

--code added for bug #5868111.....ends here


           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

         l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           debug('Right after setting instance status');
           debug('Before Update item instance');

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

           debug('After get item instance');
	   debug('After update of Out of Enterprise Item Instance');
	   debug('Update Item Instance is: '||l_update_instance_rec.instance_id);
	   debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
           debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
           debug('Message Count: '||l_msg_count);
           debug('Return Status: '||l_return_status);
           l_msg_index := 1;
           WHILE l_msg_count > 0 loop
             l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
 	   END LOOP;
	   RAISE fnd_api.g_exc_error;
       END IF;

        ELSE
           l_status := 'In Inventory, Out of Service, Out of Enterprise, In Relationship, Installed, In Service or In Process';
             debug('Serialized Item with Out of Enterprise or In Relationship exists however the ownership_override_at_txn flag is set to N so we will NOT bring this back into inventory');
             debug('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);
           fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
           fnd_message.set_token('STATUS',l_status);
           l_error_message := fnd_message.get;
           l_return_status := l_fnd_error;
           RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
        l_status := 'In Inventory, Out of Service, Installed, In Service or In Process';
          debug('Serialized Item with Status other then Out Of Service, In Inventory, Installed, or In Process already exists in Install Base');
          debug('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);
        fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
        fnd_message.set_token('STATUS',l_status);
        l_error_message := fnd_message.get;
        l_return_status := l_fnd_error;
        RAISE fnd_api.g_exc_error;
      END IF; -- Usage IF

     END IF;    -- Serialized Source Records

     ELSIF l_mtl_item_tbl(j).serial_number IS NULL THEN -- Non Serialized

       csi_inv_trxs_pkg.set_item_attr_query_values(l_mtl_item_tbl,
                                                   j,
                                                   NULL,
                                                   l_instance_query_rec,
                                                   x_return_status);

       l_instance_query_rec.inv_organization_id    :=  l_mtl_item_tbl(j).organization_id;
       l_instance_query_rec.inv_subinventory_name  :=  l_mtl_item_tbl(j).subinventory_code;
       l_instance_query_rec.instance_usage_code    :=  l_in_inventory;

       csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec => l_instance_query_rec);


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
                                                l_inactive_instance_only,
                                                l_src_instance_header_tbl,
                                                l_return_status,
                                                l_msg_count,
                                                l_msg_data);

       debug('After Get Item Instance');

       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;

       debug('Source Records Found: '||l_tbl_count);

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
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

       IF l_src_instance_header_tbl.count = 0 THEN -- No Records found so Create Non Serialized Item

          debug('No source records were found so create a new one');
         l_new_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_instance_rec.mfg_serial_number_flag       :=  l_mfg_serial_flag;
         l_new_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
         l_new_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_new_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_instance_rec.instance_usage_code          :=  l_in_inventory;
     	 l_new_instance_rec.last_po_po_line_id           :=  r_po_info.po_line_id; --5184815
         l_new_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_instance_rec.customer_view_flag           :=  'N';
         l_new_instance_rec.merchant_view_flag           :=  'Y';
         l_new_instance_rec.object_version_number        :=  l_object_version_number;
         l_new_instance_rec.operational_status_code      :=  'NOT_USED';
         l_new_instance_rec.active_start_date            :=  l_sysdate;
         l_new_instance_rec.active_end_date              :=  NULL;

         l_ext_attrib_values_tbl                         :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl                                     :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl                                   :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl                            :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl                           :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl                          :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         l_new_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('Before Create of new source Item Instance');

         csi_item_instance_pub.create_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_new_instance_rec,
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


         debug('After Create Item Instance');
         debug('Item Instance Created: '||l_new_instance_rec.instance_id);

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
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

       ELSIF l_src_instance_header_tbl.count = 1 THEN -- Records Found

         -- Update Non Serialized Item

           debug('Non Serialized Source records found');
           debug('Updating Item Instance: '||l_src_instance_header_tbl(i).instance_id);

           l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
           l_update_instance_rec.active_end_date              :=  NULL;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
    	   l_update_instance_rec.last_po_po_line_id           :=  r_po_info.po_line_id; --5184815

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           debug('Right after setting instance status');
           debug('Before Update item instance');

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

              debug('After Update item instance');
              debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
                debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
                debug('Message Count: '||l_msg_count);
                debug('Return Status: '||l_return_status);
             l_msg_index := 1;
             WHILE l_msg_count > 0 loop
               l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
 	     END LOOP;
	     RAISE fnd_api.g_exc_error;
           END IF;

       ELSIF l_src_instance_header_tbl.count > 1 THEN -- Records Found
       -- Multiple Instances were found so throw error
           debug('Multiple Instances were Found in Install Base
Base-21');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;
       END IF;      -- End of Source Record If
     END IF;        -- End of Serial Number if
     END LOOP;      -- End of For Loop

        debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        debug('*****End of csi_inv_trxs_pkg.receipt_inventory Transaction*****');

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
          debug('You have encountered a "fnd_api.g_exc_error" exception');
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
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIPOINV';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  :=  csi_inv_trxs_pkg.get_txn_type_id('PO_RECEIPT_INTO_INVENTORY','INV');
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
       l_sql_error := SQLERRM;
       debug('You have encountered a "others" exception');
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
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := fnd_message.get;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIPOINV';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  :=  csi_inv_trxs_pkg.get_txn_type_id('PO_RECEIPT_INTO_INVENTORY','INV');
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END receipt_inventory;

   PROCEDURE misc_issue(p_transaction_id     IN  NUMBER,
                        p_message_id         IN  NUMBER,
                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl            CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.MISC_ISSUE';
   l_api_version             NUMBER          := 1.0;
   l_commit                  VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list           VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level        NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only    VARCHAR2(10)    := FND_API.G_TRUE;
   l_resolve_id_columns      VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id          NUMBER          := NULL;
   l_object_version_number   NUMBER          := 1;
   l_sysdate                 DATE            := SYSDATE;
   l_master_organization_id  NUMBER;
   l_depreciable             VARCHAR2(1);
   l_instance_query_rec      CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec     CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_api_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_api_src_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                 CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status           VARCHAR2(1);
   l_error_code              VARCHAR2(50);
   l_error_message           VARCHAR2(4000);
   l_instance_id_lst         CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec         CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec       CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_src_instance_header_tbl CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_ext_attrib_values_tbl   CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   l_party_tbl               CSI_DATASTRUCTURES_PUB.PARTY_TBL;
   l_account_tbl             CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
   l_pricing_attrib_tbl      CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   l_org_assignments_tbl     CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
   l_asset_assignment_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
   l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning             VARCHAR2(1) := 'W';
   l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected          VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_in_inventory            VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_INVENTORY;
   l_in_process              VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_PROCESS;
   l_out_of_service          VARCHAR2(25) := CSI_INV_TRXS_PKG.G_OUT_OF_SERVICE;
   l_in_service              VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit              VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed               VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_transaction_error_id    NUMBER;
   l_quantity                NUMBER;
   l_mfg_serial_flag         VARCHAR2(1);
   l_trans_status_code       VARCHAR2(15);
   l_ins_number              VARCHAR2(100);
   l_ins_id                  NUMBER;
   l_file                    VARCHAR2(500);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_sql_error               VARCHAR2(2000);
   l_msg_index               NUMBER;
   l_employee_id             NUMBER;
   l_end_date                DATE;
   j                         PLS_INTEGER;
   i                         PLS_INTEGER := 1;
   l_tbl_count               NUMBER := 0;
   l_neg_code                NUMBER := 0;
   l_instance_status         VARCHAR2(1);
   l_trans_type_code         VARCHAR2(25);
   l_trans_app_code          VARCHAR2(5);
   l_redeploy_flag           VARCHAR2(1);
   l_upd_error_instance_id   NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   CURSOR c_phys_inv_info (pc_physical_adjustment_id IN NUMBER) is
     SELECT mpi.physical_inventory_id    physical_inventory_id,
            mpi.physical_inventory_name  physical_inventory_name,
            mpit.tag_number              tag_number
     FROM mtl_physical_adjustments mpa,
          mtl_physical_inventories mpi,
          mtl_physical_inventory_tags mpit
     WHERE mpa.physical_inventory_id = mpi.physical_inventory_id
     AND   mpa.physical_inventory_id = mpit.physical_inventory_id
     AND   mpa.adjustment_id = mpit.adjustment_id
     AND   mpa.adjustment_id = pc_physical_adjustment_id;

   r_phys_inv_info     c_phys_inv_info%rowtype;

   CURSOR c_cycle_count_info (pc_cycle_count_entry_id IN NUMBER) is
     SELECT mcch.cycle_count_header_id   cycle_count_header_id,
            mcch.cycle_count_header_name cycle_count_header_name
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.cycle_count_header_id = mcch.cycle_count_header_id
     AND mcce.cycle_count_entry_id = pc_cycle_count_entry_id;

   r_cycle_count_info     c_cycle_count_info%rowtype;

   BEGIN
     x_return_status := l_fnd_success;

     debug('*****Start of csi_inv_trxs_pkg.misc_issue Transaction procedure*****');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiivtxb.pls 115.25');
     debug('Transaction You are Processing is: '||p_transaction_id);

     -- This procedure queries all of the Inventory Transaction Records and returns them
     -- as a table.
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

     -- Determine Trasaction Type
     IF l_mtl_item_tbl(i).transaction_type_id = 8 THEN
       l_trans_type_code := 'PHYSICAL_INVENTORY';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 4 THEN
       l_trans_type_code := 'CYCLE_COUNT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 31 THEN
       l_trans_type_code := 'ACCT_ALIAS_ISSUE';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 34 THEN
       l_trans_type_code := 'ISO_ISSUE';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 36 THEN
       l_trans_type_code := 'RETURN_TO_VENDOR';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 1 THEN
       l_trans_type_code := 'ACCT_ISSUE';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 32 THEN
       l_trans_type_code := 'MISC_ISSUE';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 63 THEN
       l_trans_type_code := 'MOVE_ORDER_ISSUE';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 71 THEN
       l_trans_type_code := 'PO_RCPT_ADJUSTMENT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 72 THEN
       l_trans_type_code := 'INT_REQ_RCPT_ADJUSTMENT';
       l_trans_app_code  := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 70 THEN
       l_trans_type_code := 'SHIPMENT_RCPT_ADJUSTMENT';
       l_trans_app_code  := 'INV';
     ELSE
       l_trans_type_code := 'MISC_ISSUE';
       l_trans_app_code  := 'INV';
     END IF;

     debug('Trans Type Code: '||l_trans_type_code);
     debug('Trans App Code: '||l_trans_app_code);

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     debug('Master Organization is: '||l_master_organization_id);

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

     -- Set the mfg_serial_number_flag
     IF l_mtl_item_tbl(i).serial_number is NULL THEN
       l_mfg_serial_flag := 'N';
     ELSE
       l_mfg_serial_flag := 'Y';
       l_quantity := -1;
     END IF;

     -- Get the Negative Receipt Code to see if this org allows Negative
     -- Quantity Records 1 = Yes, 2 = No

     l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(
                                l_mtl_item_tbl(i).organization_id);

     IF l_neg_code = 1 AND l_mtl_item_tbl(i).serial_number is NULL THEN
       l_instance_status := FND_API.G_FALSE;
     ELSE
       l_instance_status := FND_API.G_TRUE;
     END IF;

     debug('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);

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

     -- Get Default Status ID
     OPEN c_id;
     FETCH c_id into r_id;
     CLOSE c_id;

     -- Create CSI Transaction to be used
     l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
     l_txn_rec.transaction_date         := l_sysdate;
     l_txn_rec.transaction_type_id      := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
     l_txn_rec.transaction_quantity     := l_mtl_item_tbl(i).transaction_quantity;
     l_txn_rec.transaction_uom_code     := l_mtl_item_tbl(i).transaction_uom;
     l_txn_rec.transacted_by            := l_employee_id;
     l_txn_rec.transaction_action_code  := NULL;
     l_txn_rec.message_id               := p_message_id;
     l_txn_rec.inv_material_transaction_id :=  p_transaction_id;
     l_txn_rec.object_version_number    := l_object_version_number;
     l_txn_rec.source_header_ref_id     := l_mtl_item_tbl(i).transaction_source_id;
     l_txn_rec.source_line_ref_id       := l_mtl_item_tbl(i).move_order_line_id;

     IF l_mtl_item_tbl(i).transaction_type_id = 8 THEN
       OPEN c_phys_inv_info (l_mtl_item_tbl(i).physical_adjustment_id);
       FETCH c_phys_inv_info into r_phys_inv_info;
       CLOSE c_phys_inv_info;

       l_txn_rec.source_header_ref_id := r_phys_inv_info.physical_inventory_id;
       l_txn_rec.source_header_ref := r_phys_inv_info.physical_inventory_name;
       l_txn_rec.source_line_ref := r_phys_inv_info.tag_number;

       debug('MMT Phys Adj ID: '||l_mtl_item_tbl(i).physical_adjustment_id);
       debug('Physical Inventory ID: '||l_txn_rec.source_header_ref_id);
       debug('Physical Inventory Name: '||l_txn_rec.source_header_ref);

     ELSIF l_mtl_item_tbl(i).transaction_type_id = 4 THEN

       OPEN c_cycle_count_info (l_mtl_item_tbl(i).cycle_count_id);
       FETCH c_cycle_count_info into r_cycle_count_info;
       CLOSE c_cycle_count_info;

       l_txn_rec.source_header_ref_id := r_cycle_count_info.cycle_count_header_id;
       l_txn_rec.source_header_ref := r_cycle_count_info.cycle_count_header_name;

       debug('MMT Cycle Count ID: '||l_mtl_item_tbl(i).cycle_count_id);
       debug('Cycle Count ID: '||l_txn_rec.source_header_ref_id);
       debug('Cycle Count Name: '||l_txn_rec.source_header_ref);

     END IF;

   -- Move Order Transfer Info on Txn Record
     IF l_mtl_item_tbl(i).transaction_type_id = 63 THEN
       l_txn_rec.source_header_ref_id     :=  l_mtl_item_tbl(i).transaction_source_id;
       l_txn_rec.source_line_ref_id       :=  l_mtl_item_tbl(i).move_order_line_id;
     END IF;

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

       csi_inv_trxs_pkg.set_item_attr_query_values(l_mtl_item_tbl,
                                                   j,
                                                   NULL,
                                                   l_instance_query_rec,
                                                   x_return_status);


       IF l_mtl_item_tbl(j).serial_number IS NULL THEN -- Non Serial

         l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
         l_instance_query_rec.instance_usage_code             :=  l_in_inventory;

       END IF;

       csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec => l_instance_query_rec);

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
         l_msg_index := 1;
	    WHILE l_msg_count > 0 loop
	      l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	      l_msg_index := l_msg_index + 1;
           l_msg_count := l_msg_count - 1;
  	    END LOOP;
         RAISE fnd_api.g_exc_error;
       END IF;

       IF l_mtl_item_tbl(j).serial_number is NULL THEN
         IF l_src_instance_header_tbl.count = 0 THEN
           IF l_neg_code = 1 THEN -- Allow Neg Qtys on NON Serial Items ONLY
         -- No Instances so check to see if Neg Qtys Allowed to create source

         debug('No records were found and Neg Qtys allowed so create a new Source Instance Record');

         l_new_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_src_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_src_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_src_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_src_instance_rec.mfg_serial_number_flag       :=  'N';
         l_new_src_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_src_instance_rec.quantity                     :=  l_mtl_item_tbl(j).transaction_quantity;
         l_new_src_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_new_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_src_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_src_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_src_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_src_instance_rec.customer_view_flag           :=  'N';
         l_new_src_instance_rec.merchant_view_flag           :=  'Y';
         l_new_src_instance_rec.object_version_number        :=  l_object_version_number;
         l_new_src_instance_rec.operational_status_code      :=  'NOT_USED';
         l_new_src_instance_rec.active_start_date            :=  l_sysdate;
         l_new_src_instance_rec.active_end_date               :=  NULL;

         l_ext_attrib_values_tbl   :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl               :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl             :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl      :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl     :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl    :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         debug('Before Create of source Instance - Neg Qty');

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

         debug('After Create of Source Item Instance');
         debug('New instance created is: '||l_new_src_instance_rec.instance_id);

         -- Check for any errors and add them to the message stack to pass out to be put into the
         -- error log table.
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

       ELSE  -- No Records were found and Neg Qtys Not Allowed
         debug('No Records were found in Install Base and Neg Qtys not allowed to error');
         fnd_message.set_name('CSI','CSI_NO_NEG_BAL_ALLOWED');
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

      END IF; -- Neg Qty IF

    ELSE -- Non Serialized Instances Found so Update

         debug('Update source record for non seralized item');
         debug('Update Source Non Serialized item: '||l_src_instance_header_tbl(i).instance_id);

         l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
         l_update_instance_rec.active_end_date              :=  NULL;
         l_update_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(i).primary_quantity);
         l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

         l_party_tbl.delete;
         l_account_tbl.delete;
         l_pricing_attrib_tbl.delete;
         l_org_assignments_tbl.delete;
         l_asset_assignment_tbl.delete;

         debug('Before Update Non Serialized Item Instance');

         l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         debug('Instance Status Id: '||l_update_instance_rec.instance_status_id);

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

         debug('After Update Non Serialzied Item Instance');
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
       END IF;      -- IF Src Non Serial Recs found

     ELSIF l_mtl_item_tbl(j).serial_number is NOT NULL THEN
       IF l_src_instance_header_tbl.count = 1 THEN -- Serialized Records found so update

           debug('Updating Serialized Item Instance');
--R12 changes,Misc issue on serialized rebuildables/asset numbers leaves the instance in active state and
--all inventory attributes made as null.
	   debug('l_mtl_item_tbl(j).eam_item_type--'||l_mtl_item_tbl(j).eam_item_type);
	   l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
	   l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
           l_update_instance_rec.quantity                     :=  1;
	   IF l_mtl_item_tbl(j).eam_item_type in(1,3) THEN
		l_update_instance_rec.active_end_date              :=  NULL;
		l_update_instance_rec.inv_subinventory_name	   :=  NULL;
		l_update_instance_rec.inv_locator_id		   :=  NULL;
		l_update_instance_rec.location_type_code	   := 'INTERNAL_SITE';
		l_update_instance_rec.instance_usage_code	   := 'OUT_OF_SERVICE';
		Begin
			SELECT nvl(location_id,NULL)
			INTO l_update_instance_rec.location_id
			FROM hr_all_organization_units
			WHERE organization_id = l_src_instance_header_tbl(i).vld_organization_id;
		Exception
		WHEN no_data_found THEN
			null;
		End;
		l_update_instance_rec.inv_organization_id	   :=  NULL;
--end of R12 changes
	   ELSE
           l_update_instance_rec.active_end_date              :=  l_sysdate;
           END IF;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update of Serialized Item Instance');

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

           debug('After Update of Serialized Item Instance');
           debug('Updated Item Instance: '||l_update_instance_rec.instance_id);
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

       ELSIF l_src_instance_header_tbl.count = 0 THEN
         debug('No Records were found in Install Base');
         fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
         fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;
       END IF;      -- End of Source Record IF
     END IF;        -- End of Serial IF
     END LOOP;      -- End of For Loop

     debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('*****End of csi_inv_trxs_pkg.misc_issue Transaction*****');

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       debug('You have encountered a "fnd_api.g_exc_error" exception');
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
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIMSISU';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  :=  csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
       l_sql_error := SQLERRM;
       debug('You have encountered a "others" exception');
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
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := fnd_message.get;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIMSISU';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  :=  csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END misc_issue;

   PROCEDURE cycle_count(p_transaction_id     IN  NUMBER,
                         p_message_id         IN  NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_api_name                    VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.CYCLE_COUNT';
   l_return_status               VARCHAR2(1);
   l_error_code                  VARCHAR2(50);
   l_error_message               VARCHAR2(4000);
   l_fnd_success                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning                 VARCHAR2(1) := 'W';
   l_fnd_error                   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_sql_error                   VARCHAR2(2000);
   r_quantity                    NUMBER := 0;
   l_trx_error_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;

   cursor C_QUANTITY is
     select transaction_quantity
     from   mtl_material_transactions
     where  transaction_id = p_transaction_id;

   BEGIN

     x_return_status := l_fnd_success;

     debug('*****Start of csi_inv_trxs_pkg.cycle_count Transaction*****');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiivtxb.pls 115.25');
     debug('Transaction You are Processing is: '||p_transaction_id);

   open C_QUANTITY;
   fetch C_QUANTITY into R_QUANTITY;
   close C_QUANTITY;

   if r_quantity > 0 then
     csi_inv_trxs_pkg.misc_receipt(p_transaction_id,
                                   p_message_id,
                                   l_return_status,
                                   l_trx_error_rec);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.cycle_count');
       RAISE fnd_api.g_exc_error;
     END IF;
   ELSIF r_quantity < 0 then
     csi_inv_trxs_pkg.misc_issue(p_transaction_id,
                                 p_message_id,
                                 l_return_status,
                                 l_trx_error_rec);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.cycle_count');
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   debug('*****End of csi_inv_trxs_pkg.cycle_count Transaction*****');

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       debug('You have encountered a "fnd_api.g_exc_error" exception');
       x_return_status := l_fnd_error;
       l_trx_error_rec.source_type := 'CSICYCNT';
       x_trx_error_rec := l_trx_error_rec;

     WHEN others THEN
       l_sql_error := SQLERRM;
       debug('You have encountered a "others" exception');
       debug('SQL Error: '||l_sql_error);
       fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_return_status := l_fnd_unexpected;
       l_trx_error_rec.error_text := fnd_message.get;
       l_trx_error_rec.transaction_id       := NULL;
       l_trx_error_rec.source_type          := 'CSICYCNT';
       l_trx_error_rec.source_id            := p_transaction_id;
       l_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       l_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('CYCLE_COUNT','INV');
       l_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       l_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;
       x_trx_error_rec := l_trx_error_rec;

   END cycle_count;

   PROCEDURE physical_inventory(p_transaction_id     IN  NUMBER,
                                p_message_id         IN  NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_api_name                    VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.PHYSICAL_INVENTORY';
   l_return_status               VARCHAR2(1);
   l_error_code                  VARCHAR2(50);
   l_error_message               VARCHAR2(4000);
   l_fnd_success                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning                 VARCHAR2(1) := 'W';
   l_fnd_error                   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_sql_error                   VARCHAR2(2000);
   r_quantity                    NUMBER := 0;
   l_trx_error_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;

   cursor C_QUANTITY is
     select transaction_quantity
     from   mtl_material_transactions
     where  transaction_id = p_transaction_id;

   BEGIN
     x_return_status := l_fnd_success;

   debug('*****Start of csi_inv_trxs_pkg.physical_inventory Transaction*****');
   debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   debug('csiorgtb.pls 115.25');
   debug('Transaction You are Processing is: '||p_transaction_id);

   open C_QUANTITY;
   fetch C_QUANTITY into R_QUANTITY;
   close C_QUANTITY;

   if r_quantity > 0 then
     csi_inv_trxs_pkg.misc_receipt(p_transaction_id,
                                   p_message_id,
                                   l_return_status,
                                   l_trx_error_rec);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.physical_inventory');
       RAISE fnd_api.g_exc_error;
     END IF;
   ELSIF r_quantity < 0 then
     csi_inv_trxs_pkg.misc_issue(p_transaction_id,
                                 p_message_id,
                                 l_return_status,
                                 l_trx_error_rec);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.physical_inventory');
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   debug('*****End of csi_inv_trxs_pkg.physical_inventory Transaction*****');

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      debug('You have encountered a "fnd_api.g_exc_error" exception');
      x_return_status := l_fnd_error;
      l_trx_error_rec.source_type := 'CSIPHYIN';
      x_trx_error_rec := l_trx_error_rec;

    WHEN others THEN
      l_sql_error := SQLERRM;
      debug('You have encountered a "others" exception');
      debug('SQL Error: '||l_sql_error);
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_return_status := l_fnd_unexpected;
      l_trx_error_rec.error_text := fnd_message.get;
      l_trx_error_rec.transaction_id       := NULL;
      l_trx_error_rec.source_type          := 'CSIPHYIN';
      l_trx_error_rec.source_id            := p_transaction_id;
      l_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
      l_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('PHYSICAL_INVENTORY','INV');
      l_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
      l_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;
      x_trx_error_rec := l_trx_error_rec;

  END physical_inventory;

   PROCEDURE get_transaction_recs(p_transaction_id     IN  NUMBER,
                                  x_mtl_item_tbl       OUT NOCOPY CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_error_message      OUT NOCOPY VARCHAR2)
   IS

   l_api_name                VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.GET_TRANSACTION_RECS';
   l_fnd_success             VARCHAR2(1)     := FND_API.G_RET_STS_SUCCESS;
   l_fnd_error               VARCHAR2(1)     := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected          VARCHAR2(1)     := FND_API.G_RET_STS_UNEXP_ERROR;
   l_sql_error               VARCHAR2(2000);
   i                         PLS_INTEGER;

   CURSOR c_items IS
     SELECT
            mmt.inventory_item_id           inventory_item_id,
            mmt.organization_id             organization_id,
            mmt.subinventory_code           subinventory_code,
            mmt.transfer_organization_id    transfer_organization_id,
            mmt.transfer_subinventory       transfer_subinventory,
            mmt.revision                    revision,
            mmt.transaction_quantity        transaction_quantity,
 	    mmt.primary_quantity            primary_quantity,
            mmt.transaction_uom             transaction_uom,
	    msib.primary_uom_code           primary_uom_code,
            mmt.transaction_type_id         transaction_type_id,
            mmt.transaction_action_id       transaction_action_id,
            mmt.transaction_source_id       transaction_source_id,
            mmt.transaction_source_type_id  transaction_source_type_id,
            mmt.transfer_locator_id         transfer_locator_id,
            mmt.locator_id                  locator_id,
            mmt.source_project_id           source_project_id,
            mmt.source_task_id              source_task_id,
            mmt.project_id                  from_project_id,
            mmt.task_id                     from_task_id,
            mmt.to_project_id               to_project_id,
            mmt.to_task_id                  to_task_id,
            mmt.transaction_date            transaction_date,
            mmt.last_updated_by             last_updated_by,
            msn.serial_number               serial_number,
            NULL                            lot_number,
            msi.location_id                 subinv_location_id,
            rt.po_distribution_id           po_distribution_id,
            haou.location_id                hr_location_id,
            mmt.shipment_number             shipment_number,
            mmt.trx_source_line_id          trx_source_line_id,
            mmt.move_order_line_id          move_order_line_id,
	    msib.serial_number_control_code serial_number_control_code,
	    msib.lot_control_code           lot_control_code,
            msib.revision_qty_control_code  revision_qty_control_code,
            msib.comms_nl_trackable_flag    comms_nl_trackable_flag,
            msib.location_control_code      location_control_code,
            mmt.ship_to_location_id         ship_to_location_id,
            mmt.physical_adjustment_id      physical_adjustment_id,
            mmt.cycle_count_id              cycle_count_id,
	    nvl(msib.eam_item_type,0)	    eam_item_type,  --included for R12,eAM integration
            mmt.rcv_transaction_id          rcv_transaction_id,
            mmt.transfer_transaction_id     transfer_transaction_id
     FROM
            mtl_system_items_b           msib,
            mtl_serial_numbers           msn,
            mtl_unit_transactions        mut,
            mtl_secondary_inventories    msi,
            hr_all_organization_units    haou,
            rcv_transactions             rt,
            mtl_material_transactions    mmt
     WHERE
            mmt.transaction_id         = p_transaction_id                AND
            mmt.inventory_item_id      = msib.inventory_item_id          AND
            mmt.organization_id        = msib.organization_id            AND
            msib.lot_control_code      <> 2                              AND
            mmt.rcv_transaction_id     = rt.transaction_id(+)            AND
            mmt.organization_id        = haou.organization_id(+)         AND
            mmt.subinventory_code      = msi.secondary_inventory_name(+) AND
            mmt.organization_id        = msi.organization_id(+)          AND
            mmt.transaction_id         = mut.transaction_id(+)           AND
            mut.inventory_item_id      = msn.inventory_item_id(+)        AND
            mut.serial_number          = msn.serial_number(+)
UNION ALL
     SELECT
            mmt.inventory_item_id           inventory_item_id,
            mmt.organization_id             organization_id,
            mmt.subinventory_code           subinventory_code,
            mmt.transfer_organization_id    transfer_organization_id,
            mmt.transfer_subinventory       transfer_subinventory,
            mmt.revision                    revision,
            mtln.transaction_quantity       transaction_quantity,
	    mtln.primary_quantity           primary_quantity,
            mmt.transaction_uom             transaction_uom,
 	    msib.primary_uom_code           primary_uom_code,
            mmt.transaction_type_id         transaction_type_id,
            mmt.transaction_action_id       transaction_action_id,
            mmt.transaction_source_id       transaction_source_id,
            mmt.transaction_source_type_id  transaction_source_type_id,
            mmt.transfer_locator_id         transfer_locator_id,
            mmt.locator_id                  locator_id,
            mmt.source_project_id           source_project_id,
            mmt.source_task_id              source_task_id,
            mmt.project_id                  from_project_id,
            mmt.task_id                     from_task_id,
            mmt.to_project_id               to_project_id,
            mmt.to_task_id                  to_task_id,
            mmt.transaction_date            transaction_date,
            mmt.last_updated_by             last_updated_by,
            msn.serial_number               serial_number,
            mtln.lot_number                 lot_number,
            msi.location_id                 subinv_location_id,
            rt.po_distribution_id           po_distribution_id,
            haou.location_id                hr_location_id,
            mmt.shipment_number             shipment_number,
            mmt.trx_source_line_id          trx_source_line_id,
            mmt.move_order_line_id          move_order_line_id,
	    msib.serial_number_control_code serial_number_control_code,
	    msib.lot_control_code           lot_control_code,
            msib.revision_qty_control_code  revision_qty_control_code,
            msib.comms_nl_trackable_flag    comms_nl_trackable_flag,
            msib.location_control_code      location_control_code,
            mmt.ship_to_location_id         ship_to_location_id,
            mmt.physical_adjustment_id      physical_adjustment_id,
            mmt.cycle_count_id              cycle_count_id,
	    nvl(msib.eam_item_type,0)	    eam_item_type,   --included for R12,eAM integration
            mmt.rcv_transaction_id          rcv_transaction_id,
            mmt.transfer_transaction_id     transfer_transaction_id
     FROM
            mtl_system_items_b           msib,
            mtl_serial_numbers           msn,
            mtl_unit_transactions        mut,
            mtl_transaction_lot_numbers  mtln,
            mtl_secondary_inventories    msi,
            hr_all_organization_units    haou,
            rcv_transactions             rt,
            mtl_material_transactions    mmt
     WHERE
            mmt.transaction_id         = p_transaction_id                AND
            mmt.inventory_item_id      = msib.inventory_item_id          AND
            mmt.organization_id        = msib.organization_id            AND
            msib.lot_control_code      = 2                               AND
            mmt.rcv_transaction_id     = rt.transaction_id(+)            AND
            mmt.organization_id        = haou.organization_id(+)         AND
            mmt.subinventory_code      = msi.secondary_inventory_name(+) AND
            mmt.organization_id        = msi.organization_id(+)          AND
            mmt.transaction_id         = mtln.transaction_id(+)          AND
            mtln.serial_transaction_id = mut.transaction_id(+)           AND
            mut.inventory_item_id      = msn.inventory_item_id(+)        AND
            mut.serial_number          = msn.serial_number(+);

   BEGIN
     i := 1;
     FOR r_items IN c_items LOOP
       x_mtl_item_tbl(i).inventory_item_id     := r_items.inventory_item_id;
       x_mtl_item_tbl(i).organization_id       := r_items.organization_id;
       x_mtl_item_tbl(i).subinventory_code     := r_items.subinventory_code;
       x_mtl_item_tbl(i).revision              := r_items.revision;
       x_mtl_item_tbl(i).transaction_quantity  := r_items.transaction_quantity;
       x_mtl_item_tbl(i).primary_quantity      := r_items.primary_quantity;
       x_mtl_item_tbl(i).transaction_uom       := r_items.transaction_uom;
       x_mtl_item_tbl(i).primary_uom_code      := r_items.primary_uom_code;
       x_mtl_item_tbl(i).transaction_type_id   := r_items.transaction_type_id;
       x_mtl_item_tbl(i).transaction_action_id := r_items.transaction_action_id;
       x_mtl_item_tbl(i).transaction_source_id := r_items.transaction_source_id;
       x_mtl_item_tbl(i).transaction_source_type_id := r_items.transaction_source_type_id;
       x_mtl_item_tbl(i).transfer_locator_id    := r_items.transfer_locator_id;
       x_mtl_item_tbl(i).transfer_organization_id := r_items.transfer_organization_id;
       x_mtl_item_tbl(i).transfer_subinventory := r_items.transfer_subinventory;
       x_mtl_item_tbl(i).locator_id            := r_items.locator_id;
       x_mtl_item_tbl(i).source_project_id     := r_items.source_project_id;
       x_mtl_item_tbl(i).source_task_id        := r_items.source_task_id;
       x_mtl_item_tbl(i).from_project_id       := r_items.from_project_id;
       x_mtl_item_tbl(i).from_task_id          := r_items.from_task_id;
       x_mtl_item_tbl(i).to_project_id         := r_items.to_project_id;
       x_mtl_item_tbl(i).to_task_id            := r_items.to_task_id;
       x_mtl_item_tbl(i).transaction_date      := r_items.transaction_date;
       x_mtl_item_tbl(i).last_updated_by       := r_items.last_updated_by;
       x_mtl_item_tbl(i).serial_number         := r_items.serial_number;
       x_mtl_item_tbl(i).lot_number            := r_items.lot_number;
       x_mtl_item_tbl(i).subinv_location_id    := r_items.subinv_location_id;
       x_mtl_item_tbl(i).po_distribution_id    := r_items.po_distribution_id;
       x_mtl_item_tbl(i).hr_location_id        := r_items.hr_location_id;
       x_mtl_item_tbl(i).shipment_number       := r_items.shipment_number;
       x_mtl_item_tbl(i).trx_source_line_id    := r_items.trx_source_line_id;
       x_mtl_item_tbl(i).move_order_line_id    := r_items.move_order_line_id;
       x_mtl_item_tbl(i).serial_number_control_code := r_items.serial_number_control_code;
       x_mtl_item_tbl(i).lot_control_code := r_items.lot_control_code;
       x_mtl_item_tbl(i).revision_qty_control_code := r_items.revision_qty_control_code;
       x_mtl_item_tbl(i).comms_nl_trackable_flag := r_items.comms_nl_trackable_flag;
       x_mtl_item_tbl(i).location_control_code   := r_items.location_control_code;
       x_mtl_item_tbl(i).ship_to_location_id := r_items.ship_to_location_id;
       x_mtl_item_tbl(i).physical_adjustment_id := r_items.physical_adjustment_id;
       x_mtl_item_tbl(i).cycle_count_id      := r_items.cycle_count_id;
       x_mtl_item_tbl(i).eam_item_type	     := r_items.eam_item_type; --for R12,eAM integration
       x_mtl_item_tbl(i).rcv_transaction_id  := r_items.rcv_transaction_id;
       x_mtl_item_tbl(i).transfer_transaction_id  := r_items.transfer_transaction_id;

     i := i + 1;
     END LOOP;

     IF i = 1 then
       RAISE no_data_found;
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('CSI','CSI_NO_INVENTORY_RECORDS');
        fnd_message.set_token('MTL_TRANSACTION_ID',p_transaction_id);
        x_error_message := fnd_message.get;
        x_return_status := l_fnd_error;

       WHEN others THEN
        l_sql_error := SQLERRM;
        debug('You have encountered a "others" exception');
        debug('SQL Error: '||l_sql_error);
        fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
        fnd_message.set_token('API_NAME',l_api_name);
	fnd_message.set_token('SQL_ERROR',SQLERRM);
        x_error_message := fnd_message.get;
        x_return_status := l_fnd_unexpected;
   END get_transaction_recs;

   PROCEDURE decode_message (p_msg_header	     IN     XNP_MESSAGE.MSG_HEADER_REC_TYPE,
	                     p_msg_text	             IN	    VARCHAR2,
	                     x_return_status	     OUT NOCOPY    VARCHAR2,
	                     x_error_message	     OUT NOCOPY    VARCHAR2,
                             x_mtl_trx_rec           OUT NOCOPY    CSI_INV_TRXS_PKG.MTL_TRX_TYPE) IS

   l_api_name             VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.DECODE_MESSAGE';
   l_fnd_unexpected       VARCHAR2(1)     := FND_API.G_RET_STS_UNEXP_ERROR;
   l_sql_error            VARCHAR2(2000);

   BEGIN
     xnp_xml_utils.decode(P_Msg_Text, 'MTL_TRANSACTION_ID', X_MTL_TRX_REC.MTL_TRANSACTION_ID);

     IF (X_MTL_TRX_REC.MTL_TRANSACTION_ID is NULL) or
        (X_MTL_TRX_REC.MTL_TRANSACTION_ID = FND_API.G_MISS_NUM) THEN
       RAISE fnd_api.g_exc_error;
     END IF;

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       fnd_message.set_name('CSI','CSI_DECODE_MGS_ERROR');
       fnd_message.set_token('MESSAGE_ID',p_msg_header.message_id);
       fnd_message.set_token('MESSAGE_CODE',p_msg_header.message_code);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;

     WHEN others THEN
       l_sql_error := SQLERRM;
       debug('You have encountered a "others" exception');
       debug('SQL Error: '||l_sql_error);
       fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;
   END decode_message;

PROCEDURE get_asset_creation_code(
     p_inventory_item_id IN NUMBER,
     p_asset_creation_code OUT NOCOPY VARCHAR2
   )
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     l_err_text          VARCHAR2(2000);
     l_api_name          VARCHAR2(200)   := 'CSI_INV_TRXS_PKG.GET_ASSET_CREATION_CODE';
CURSOR Asset_CC_Cur (P_Item_Id IN NUMBER) IS
       SELECT   DISTINCT asset_creation_code
         FROM   mtl_system_items
        WHERE   inventory_item_id = p_inventory_item_id
          AND   organization_id =
                (select organization_id
                from   mtl_system_items
                where  inventory_item_id=p_inventory_item_id
                and rownum=1)
          AND   enabled_flag = 'Y'
          AND   nvl (start_date_active, l_sysdate) <= l_sysdate
          AND   nvl (end_date_active, l_sysdate+1) > l_sysdate;
BEGIN
 P_Asset_Creation_Code := NULL;
 OPEN Asset_CC_Cur(P_inventory_item_id);
 FETCH Asset_CC_Cur INTO P_Asset_Creation_Code;
  IF NOT Asset_CC_Cur%FOUND THEN
      P_Asset_Creation_Code := NULL;
  END IF;
 CLOSE Asset_CC_Cur;
EXCEPTION
        WHEN OTHERS THEN
                fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
                fnd_message.set_token('API_NAME', l_api_name);
                fnd_message.set_token('SQL_ERROR', sqlerrm);
                l_err_text := fnd_message.get;
                raise;
END get_asset_creation_code;

PROCEDURE Check_item_Trackable(
     p_inventory_item_id IN NUMBER,
     p_nl_trackable_flag OUT NOCOPY VARCHAR2)
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     yes_or_no VARCHAR2(2) := 'N';
     l_err_text          VARCHAR2(2000);
     l_api_name          VARCHAR2(200)   := 'CSI_INV_TRXS_PKG.CHECK_ITEM_TRACKABLE';
CURSOR NL_TRACK_CUR(P_Item_Id IN NUMBER) IS
       SELECT   DISTINCT 'Y'
       FROM     mtl_system_items
       WHERE    inventory_item_id = p_item_id
       AND      organization_id =
                (select organization_id
                 from   mtl_system_items
                 where inventory_item_id=P_inventory_item_id
                 and  rownum =1)
       AND      enabled_flag = 'Y'
       AND      nvl (start_date_active, l_sysdate) <= l_sysdate
       AND      nvl (end_date_active, l_sysdate+1) > l_sysdate
       AND      comms_nl_trackable_flag = 'Y';
BEGIN
        OPEN NL_Track_Cur(P_Inventory_Item_Id);
        FETCH  NL_Track_Cur INTO Yes_Or_No;
        CLOSE NL_Track_Cur;
        IF (yes_or_no = 'Y') THEN
                p_nl_trackable_flag := 'TRUE';
        ELSE
                p_nl_trackable_flag := 'FALSE';
        END IF;
EXCEPTION
  	WHEN OTHERS THEN
                fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
                fnd_message.set_token('API_NAME', l_api_name);
                fnd_message.set_token('SQL_ERROR', sqlerrm);
    		l_err_text := fnd_message.get;
END check_item_trackable;

PROCEDURE check_depreciable(
     p_inventory_item_id IN NUMBER,
     p_depreciable OUT NOCOPY VARCHAR2
   )
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     l_asset_creation_code VARCHAR2(1);
     l_err_text          VARCHAR2(2000);
     l_api_name          VARCHAR2(200)   := 'CSI_INV_TRXS_PKG.CHECK_DEPRECIABLE';
BEGIN
	csi_inv_trxs_pkg.Get_Asset_Creation_Code(
		p_inventory_item_id,
		l_asset_creation_code);
	IF l_asset_creation_code NOT IN ('1','Y') OR
		l_asset_creation_code IS NULL
 	THEN
		p_depreciable := 'N';
	ELSE
		p_depreciable := 'Y';
	END IF;
EXCEPTION
  	WHEN OTHERS THEN
                fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
                fnd_message.set_token('API_NAME', l_api_name);
                fnd_message.set_token('SQL_ERROR', sqlerrm);
    		l_err_text := fnd_message.get;
    		raise;
END check_depreciable;

FUNCTION is_csi_installed RETURN VARCHAR2
IS
l_csi_installed    VARCHAR2(1) := 'N' ;
dummy  VARCHAR2(40);
ret    BOOLEAN;
BEGIN
        IF (csi_inv_trxs_pkg.x_csi_install is NULL)
        THEN
         ret := fnd_installation.get_app_info('CSI',
                  csi_inv_trxs_pkg.x_csi_install, dummy, dummy);
        END IF;

        IF (csi_inv_trxs_pkg.x_csi_install = 'I')
        THEN
         l_csi_installed := 'Y';
        ELSE
         l_csi_installed := 'N';
        END IF;
  RETURN l_csi_installed ;
END is_csi_installed ;

FUNCTION get_neg_inv_code (p_org_id in NUMBER) RETURN NUMBER IS

l_neg_code    NUMBER := 0;

cursor c_code (pc_org_id in NUMBER) is
  SELECT negative_inv_receipt_Code
  FROM   mtl_parameters
  WHERE  organization_id = pc_org_id;

r_code     c_code%rowtype;

BEGIN
  OPEN c_code (p_org_id);
  FETCH c_code into r_code;
  IF c_code%found THEN
    l_neg_code := r_code.negative_inv_receipt_code;
  END IF;
  CLOSE c_code;
  RETURN l_neg_code ;
END get_neg_inv_code;

PROCEDURE get_master_organization(p_organization_id          IN  NUMBER,
                                  p_master_organization_id   OUT NOCOPY NUMBER,
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  x_error_message            OUT NOCOPY VARCHAR2)
IS

l_sql_error         VARCHAR2(500);
l_org_code          VARCHAR2(3);
l_fnd_success       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnd_error         VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected    VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
l_error_message     VARCHAR2(2000);
e_procedure_error   EXCEPTION;

CURSOR c_name is
  SELECT organization_code
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

r_name   c_name%rowtype;

CURSOR c_id IS
  SELECT master_organization_id
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

r_id     c_id%rowtype;

BEGIN

  l_error_message := NULL;
  x_return_status := l_fnd_success;

  OPEN c_id;
  FETCH c_id into r_id;
  IF c_id%found then
    p_master_organization_id := r_id.master_organization_id;
  ELSE
    OPEN c_name;
    FETCH c_name into r_name;
    if c_name%found then
      l_org_code := r_name.organization_code;
    end if;
    RAISE e_procedure_error;
  END IF;

EXCEPTION
  WHEN e_procedure_error THEN
     fnd_message.set_name('CSI','CSI_MSTR_ORG_NOTFOUND');
     fnd_message.set_token('ORGANIZATION_ID',p_organization_id);
     fnd_message.set_token('ORGANIZATION_CODE',l_org_code);
     x_error_message := fnd_message.get;
     x_return_status := l_fnd_error;

  WHEN others THEN
     fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
     fnd_message.set_token('SQL_ERROR',SQLERRM);
     x_error_message := fnd_message.get;
     x_return_status := l_fnd_unexpected;
END get_master_organization;

PROCEDURE build_error_string (
        p_string            IN OUT NOCOPY  VARCHAR2,
        p_attribute         IN      VARCHAR2,
        p_value             IN      VARCHAR2) IS

BEGIN
	p_string := p_string || '<' || p_attribute || '>' ;
	p_string := p_string || p_value ;
	p_string := p_string || '</' || p_attribute || '>' ;

END build_error_string;

PROCEDURE get_string_value (
        p_string            IN      VARCHAR2,
        p_attribute         IN      VARCHAR2,
        x_value             OUT NOCOPY     VARCHAR2) IS

  tag_pos           INTEGER := 0 ;
  token             VARCHAR2(1024) := '' ;
  token_delimeter   VARCHAR2(1024) := '' ;
  tag_delimeter_pos INTEGER := 0 ;

BEGIN

  token := '<' || p_attribute || '>' ;
  token_delimeter := '</' || p_attribute || '>' ;
  tag_pos := INSTR( p_string, token, 1 ) ;

  IF (tag_pos = 0)
  THEN
    x_value := NULL ;
    RETURN ;
  END IF ;

  tag_delimeter_pos := INSTR( p_string, token_delimeter, 1 ) ;

  IF (tag_delimeter_pos = 0)
  THEN
    x_value := NULL ;
    RETURN ;
  END IF ;

  x_value := SUBSTR(p_string, tag_pos + LENGTH(token),
            tag_delimeter_pos - (tag_pos + LENGTH(token))) ;

END get_string_value;

FUNCTION Init_Instance_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Query_Rec IS
 l_Instance_Query_Rec CSI_DataStructures_Pub.Instance_Query_Rec;
BEGIN
RETURN l_Instance_Query_Rec;
END Init_Instance_Query_Rec;

FUNCTION Init_Instance_Create_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec IS
l_Instance_Rec  CSI_DATASTRUCTURES_PUB.Instance_Rec;
BEGIN
  l_instance_rec.version_label          := 'AS-CREATED';
  l_instance_rec.creation_complete_flag := NULL;
RETURN l_Instance_Rec;
END Init_Instance_Create_Rec;

FUNCTION Init_Instance_Update_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec IS
l_Instance_Rec  CSI_DATASTRUCTURES_PUB.Instance_Rec;
BEGIN
RETURN l_Instance_Rec;
END Init_Instance_Update_Rec;

FUNCTION Init_Party_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Tbl IS
 l_Party_Tbl  CSI_DATASTRUCTURES_PUB.Party_Tbl;
 l_source_table VARCHAR2(30);
 l_Party_Id  NUMBER;
 l_relation_code VARCHAR2(30);

 CURSOR Source_Table_Cur IS
   SELECT lookup_code
   FROM   CSI_Lookups
   WHERE lookup_Type = 'CSI_PARTY_SOURCE_TABLE'
   AND   lookup_code = 'HZ_PARTIES';

 CURSOR Relationship_Cur IS
   SELECT IPA_Relation_Type_Code
   FROM   CSI_IPA_Relation_Types
   WHERE  Upper(IPA_Relation_Type_Code) = 'OWNER';

BEGIN
  OPEN Source_Table_Cur;
  FETCH Source_Table_Cur INTO l_source_table;
  CLOSE Source_Table_Cur;

  l_Party_ID := csi_datastructures_pub.g_install_param_rec.internal_party_id;

  OPEN Relationship_Cur;
  FETCH Relationship_Cur INTO l_relation_code;
  CLOSE Relationship_Cur;

   l_Party_Tbl(1).party_source_table      := l_Source_Table;
   l_Party_Tbl(1).party_id                := l_Party_Id;
   l_Party_Tbl(1).relationship_type_code  := l_relation_Code;
   l_Party_Tbl(1).contact_flag            := 'N';
  RETURN l_Party_Tbl;
END Init_Party_Tbl;

FUNCTION Init_Account_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Account_Tbl IS
l_Account_Tbl CSI_DATASTRUCTURES_PUB.Party_Account_Tbl;
BEGIN
RETURN l_Account_Tbl;
END Init_Account_Tbl;

FUNCTION Init_ext_attrib_values_tbl RETURN CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl IS
l_extend_attrib_values_tbl  CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
BEGIN
RETURN l_extend_attrib_values_tbl;
END Init_ext_attrib_values_tbl;

FUNCTION Init_Pricing_Attribs_Tbl RETURN CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl IS
l_Pricing_Attribs_Tbl  CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
BEGIN
RETURN l_Pricing_Attribs_Tbl;
END Init_Pricing_Attribs_Tbl;

FUNCTION Init_Org_Assignments_Tbl RETURN CSI_DATASTRUCTURES_PUB.organization_units_tbl IS
l_Org_Assignments_Tbl  CSI_DATASTRUCTURES_PUB.organization_units_tbl;
BEGIN
RETURN l_Org_Assignments_Tbl;
END Init_Org_Assignments_Tbl;

FUNCTION Init_Asset_Assignment_Tbl RETURN CSI_DATASTRUCTURES_PUB.instance_asset_tbl IS
l_Asset_Assignment_Tbl CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
BEGIN
RETURN l_Asset_Assignment_Tbl;
END Init_Asset_Assignment_Tbl;

FUNCTION Init_Instance_Asset_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Query_Rec IS
l_instance_asset_Query_Rec CSI_DATASTRUCTURES_PUB.instance_asset_Query_Rec;
BEGIN
RETURN l_instance_asset_Query_Rec;
END Init_Instance_Asset_Query_Rec;

FUNCTION Init_Instance_Asset_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Rec IS
l_instance_asset_Rec CSI_DATASTRUCTURES_PUB.instance_asset_Rec;
BEGIN
RETURN l_instance_asset_Rec;
END Init_Instance_Asset_Rec;

FUNCTION Get_Txn_Type_Id(P_Txn_Type IN VARCHAR2,
                         P_App_Short_Name IN VARCHAR2) RETURN NUMBER IS
l_Txn_Type_Id NUMBER;
CURSOR Txn_Type_Cur IS
    SELECT ctt.Transaction_Type_Id Transaction_Type_Id
    FROM   CSI_Txn_Types ctt,
           FND_Application fa
    WHERE  ctt.Source_Transaction_Type = P_Txn_Type
    AND    fa.application_id   = ctt.Source_Application_ID
    AND    fa.Application_Short_Name = P_App_Short_Name;
BEGIN
OPEN Txn_Type_Cur;
FETCH Txn_Type_Cur INTO l_Txn_Type_Id;
CLOSE Txn_Type_Cur;
RETURN l_Txn_Type_Id;
END Get_Txn_Type_Id;

FUNCTION Get_Txn_Type_Code(P_Txn_Id IN NUMBER) RETURN VARCHAR2 IS
l_Txn_Type_Code VARCHAR2(100);
CURSOR Txn_Type_Id_Cur IS
    SELECT Source_Transaction_Type
    FROM   CSI_Txn_Types
    WHERE  Transaction_Type_Id = P_Txn_Id;
BEGIN
OPEN Txn_Type_Id_Cur;
FETCH Txn_Type_Id_Cur INTO l_Txn_Type_Code;
CLOSE Txn_Type_Id_Cur;
RETURN l_Txn_Type_Code;
END Get_Txn_Type_Code;

FUNCTION Get_Txn_Status_Code(P_Txn_Status IN VARCHAR2) RETURN VARCHAR2 IS
l_Txn_Status_Code VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR;
BEGIN
RETURN l_Txn_Status_Code;
END Get_Txn_Status_Code;

FUNCTION Get_Location_Type_Code(P_Location_Meaning in VARCHAR2) RETURN VARCHAR2 IS

l_location_type_code     VARCHAR2(50);

CURSOR c_code IS
  SELECT lookup_code
  FROM   csi_lookups
  WHERE  lookup_type = 'CSI_INST_LOCATION_SOURCE_CODE'
  AND    lookup_code = upper(P_Location_Meaning);

r_code     c_code%rowtype;

BEGIN
  OPEN c_code;
  FETCH c_code into r_code;
  IF c_code%found THEN
    l_location_type_code := r_code.lookup_code;
  ELSE
    l_location_type_code := NULL;
  END IF;
  CLOSE c_code;
  RETURN l_location_type_code;
END Get_Location_Type_Code;

FUNCTION Get_Dflt_Project_Location_Id RETURN NUMBER IS

l_project_location_id     NUMBER := NULL;

BEGIN

  l_project_location_id := csi_datastructures_pub.g_install_param_rec.project_location_id;

  RETURN l_project_location_id;
END Get_Dflt_Project_Location_Id;

FUNCTION Get_Default_Status_Id (p_transaction_id in number) RETURN NUMBER IS

l_transaction_id     NUMBER;

CURSOR c_id IS
  SELECT   src_status_id
  FROM     csi_txn_sub_types
  WHERE    transaction_type_id = p_transaction_id
  AND      default_flag = 'Y';

r_id     c_id%rowtype;

BEGIN
  OPEN c_id;
  FETCH c_id into r_id;
  IF c_id%found THEN
    l_transaction_id := r_id.src_status_id;
  ELSE
    l_transaction_id := NULL;
  END IF;
  CLOSE c_id;
  RETURN l_transaction_id;
END Get_Default_Status_id;

FUNCTION Get_Txn_Action_Code(P_Txn_Action IN VARCHAR2) RETURN VARCHAR2 IS
l_Txn_Action_Code VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR;

BEGIN
  RETURN l_Txn_Action_Code;
END Get_Txn_Action_Code;

FUNCTION Get_Fnd_Employee_Id(P_Last_Updated IN NUMBER) RETURN NUMBER IS

l_employee_id     NUMBER;

CURSOR c_id IS
  SELECT employee_id
  FROM   fnd_user
  WHERE  user_id = p_last_updated;

r_id     c_id%rowtype;

BEGIN
  OPEN c_id;
  FETCH c_id into r_id;
  IF c_id%found THEN
    l_employee_id := r_id.employee_id;
  ELSE
    l_employee_id := -1;
  END IF;
  CLOSE c_id;
  RETURN l_employee_id;
END Get_Fnd_Employee_Id;

FUNCTION Init_Txn_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Rec IS
l_Txn_Rec CSI_DATASTRUCTURES_PUB.TRANSACTION_Rec;
BEGIN
  RETURN l_Txn_Rec;
END Init_Txn_Rec;

FUNCTION Init_Txn_Error_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec IS
l_Txn_Error_Rec CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec;
BEGIN
  l_Txn_Error_Rec.processed_flag      := CSI_INV_TRXS_PKG.G_TXN_ERROR;
  RETURN l_Txn_Error_Rec;
END Init_Txn_Error_Rec;

FUNCTION Init_Party_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Party_Query_Rec IS
l_Party_Query_Rec CSI_DATASTRUCTURES_PUB.Party_Query_Rec;
 l_Party_Id  NUMBER;
 l_relation_code VARCHAR2(30);

CURSOR Relationship_Cur IS
 SELECT IPA_Relation_Type_Code
 FROM   CSI_IPA_Relation_Types
 WHERE  Upper(IPA_Relation_Type_Code) = 'OWNER';

BEGIN


  l_Party_ID := csi_datastructures_pub.g_install_param_rec.internal_party_id;

  OPEN Relationship_Cur;
  FETCH Relationship_Cur INTO l_relation_code;
  CLOSE Relationship_Cur;

  l_Party_Query_Rec.party_id                := l_Party_Id;
  l_Party_Query_Rec.relationship_type_code  := l_relation_Code;

RETURN  l_Party_Query_Rec;
END Init_Party_Query_Rec;

 FUNCTION get_inv_name (p_transaction_id IN NUMBER) RETURN VARCHAR2 IS

 l_transaction_type_id     NUMBER;
 l_inv_name                VARCHAR2(30);

  CURSOR x is
    SELECT transaction_type_id
    FROM mtl_material_transactions
    WHERE transaction_id = p_transaction_id;

 BEGIN

   OPEN x;
   FETCH x into l_transaction_type_id;
   CLOSE x;

   IF l_transaction_type_id = 1 THEN --	Account issue
     l_inv_name := 'ACCT_ISSUE';
   ELSIF l_transaction_type_id = 2 THEN --	Subinventory Transfer
     l_inv_name := 'SUBINVENTORY_TRANSFER';
   ELSIF l_transaction_type_id = 3 THEN --	Direct Org Transfer
     l_inv_name := 'INTERORG_DIRECT_SHIP';
   ELSIF l_transaction_type_id = 4 THEN --	Cycle Count Adjust
     l_inv_name := 'CYCLE_COUNT';
   ELSIF l_transaction_type_id = 5 THEN --	Cycle Count Transfer
     l_inv_name := 'CYCLE_COUNT_TRANSFER';
   ELSIF l_transaction_type_id = 8 THEN --	Physical Inv Adjust
     l_inv_name := 'PHYSICAL_INVENTORY';
   ELSIF l_transaction_type_id = 9 THEN --	Physical Inv Transfer
     l_inv_name := 'PHYSICAL_INV_TRANSFER';
   ELSIF l_transaction_type_id = 12 THEN --	Intransit Receipt
     l_inv_name := 'INTERORG_TRANS_RECEIPT';
   ELSIF l_transaction_type_id = 15 THEN --	RMA Receipt
     l_inv_name := 'RMA_RECEIPT';
   ELSIF l_transaction_type_id = 17 THEN --	WIP Assembly Return
     l_inv_name := 'WIP_ISSUE';
   ELSIF l_transaction_type_id = 18 THEN --	PO Receipt
     l_inv_name := 'PO_RECEIPT_INTO_INVENTORY';
   ELSIF l_transaction_type_id = 21 THEN --	Intransit Shipment
     l_inv_name := 'INTERORG_TRANS_SHIPMENT';
   --ELSIF l_transaction_type_id = 25 THEN --	WIP cost update
   --ELSIF l_transaction_type_id = 26 THEN --	Periodic Cost Update
   --ELSIF l_transaction_type_id = 28 THEN --	Layer Cost Update
   ELSIF l_transaction_type_id = 31 THEN --	Account alias issue
     l_inv_name := 'ACCT_ALIAS_ISSUE';
   ELSIF l_transaction_type_id = 32 THEN --	Miscellaneous issue
     l_inv_name := 'MISC_ISSUE';
   ELSIF l_transaction_type_id = 33 THEN --	Sales order issue
     l_inv_name := 'OM_SHIPMENT';
   ELSIF l_transaction_type_id = 34 THEN --	Internal order issue
     l_inv_name := 'ISO_ISSUE';
   ELSIF l_transaction_type_id = 35 THEN --	WIP component issue
     l_inv_name := 'WIP_ISSUE';
   ELSIF l_transaction_type_id = 36 THEN --	Return to Vendor
     l_inv_name := 'RETURN_TO_VENDOR';
   --ELSIF l_transaction_type_id = 37 THEN --	RMA Return
   ELSIF l_transaction_type_id = 38 THEN --	WIP Neg Comp Issue
     l_inv_name := 'WIP_RECEIPT';
   ELSIF l_transaction_type_id = 40 THEN --	Account receipt
     l_inv_name := 'ACCT_RECEIPT';
   ELSIF l_transaction_type_id = 41 THEN --	Account alias receipt
     l_inv_name := 'ACCT_ALIAS_RECEIPT';
   ELSIF l_transaction_type_id = 42 THEN --	Miscellaneous receipt
     l_inv_name := 'MISC_RECEIPT';
   ELSIF l_transaction_type_id = 43 THEN --	WIP Component Return
     l_inv_name := 'WIP_RECEIPT';
   ELSIF l_transaction_type_id = 44 THEN --	WIP Assy Completion
     l_inv_name := 'WIP_ASSEMBLY_COMPLETION';
   ELSIF l_transaction_type_id = 48 THEN --	WIP Neg Comp Return
     l_inv_name := 'WIP_ISSUE';
   ELSIF l_transaction_type_id = 50 THEN --	Internal Order Xfer
     l_inv_name := 'ISO_TRANSFER';
   ELSIF l_transaction_type_id = 51 THEN --	Backflush Transfer
     l_inv_name := 'BACKFLUSH_TRANSFER';
   ELSIF l_transaction_type_id = 52 THEN --	Sales Order Pick
     l_inv_name := 'SALES_ORDER_PICK';
   ELSIF l_transaction_type_id = 53 THEN --	Internal Order Pick
     l_inv_name := 'ISO_PICK';
   ELSIF l_transaction_type_id = 54 THEN --	Int Order Direct Ship
     l_inv_name := 'ISO_DIRECT_SHIP';
   --ELSIF l_transaction_type_id = 55 THEN --	WIP Lot Split
   --ELSIF l_transaction_type_id = 56 THEN --	WIP Lot Merge
   --ELSIF l_transaction_type_id = 57 THEN --	Lot Bonus
   --ELSIF l_transaction_type_id = 58 THEN --	Lot Update Quantity
   ELSIF l_transaction_type_id = 61 THEN --	Int Req Intr Rcpt
     l_inv_name := 'ISO_REQUISITION_RECEIPT';
   ELSIF l_transaction_type_id = 62 THEN --	Int Order Intr Ship
     l_inv_name := 'ISO_SHIPMENT';
   ELSIF l_transaction_type_id = 63 THEN --	Move Order Issue
     l_inv_name := 'MOVE_ORDER_ISSUE';
   ELSIF l_transaction_type_id = 64 THEN --	Move Order Transfer
     l_inv_name := 'MOVE_ORDER_TRANSFER';
   ELSIF l_transaction_type_id = 66 THEN --	Project Borrow
     l_inv_name := 'PROJECT_BORROW';
   ELSIF l_transaction_type_id = 67 THEN --	Project Transfer
     l_inv_name := 'PROJECT_TRANSFER';
   ELSIF l_transaction_type_id = 68 THEN --	Project Payback
     l_inv_name := 'PROJECT_PAYBACK';
   ELSIF l_transaction_type_id = 70 THEN --	Shipment Rcpt Adjust
     l_inv_name := 'SHIPMENT_RCPT_ADJUSTMENT';
   ELSIF l_transaction_type_id = 71 THEN --	PO Rcpt Adjust
     l_inv_name := 'PO_RCPT_ADJUSTMENT';
   ELSIF l_transaction_type_id = 72 THEN --	Int Req Rcpt Adjust
     l_inv_name := 'INT_REQ_RCPT_ADJUSTMENT';
   --ELSIF l_transaction_type_id = 73 THEN --	Planning Transfer
   ELSIF l_transaction_type_id = 77 THEN --	ProjectContract Issue
     l_inv_name := 'PROJECT_CONTRACT_SHIPMENT';
   --ELSIF l_transaction_type_id = 80 THEN --	Average cost update
   --ELSIF l_transaction_type_id = 82 THEN --	Inventory Lot Split
   --ELSIF l_transaction_type_id = 83 THEN --	Inventory Lot Merge
   --ELSIF l_transaction_type_id = 84 THEN --	Inventory Lot Translate
   --ELSIF l_transaction_type_id = 86 THEN --	Cost Group Transfer
   --ELSIF l_transaction_type_id = 87 THEN --	Container Pack
   --ELSIF l_transaction_type_id = 88 THEN --	Container Unpack
   --ELSIF l_transaction_type_id = 89 THEN --	Container Split
   --ELSIF l_transaction_type_id = 90 THEN --	WIP assembly scrap
   --ELSIF l_transaction_type_id = 91 THEN --	WIP return from scrap
   --ELSIF l_transaction_type_id = 92 THEN --	WIP estimated scrap
   ELSE
     l_inv_name := NULL;
   END IF;

   RETURN l_inv_name;
 END get_inv_name;

 PROCEDURE log_csi_error(p_trx_error_rec IN CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC) IS

 l_api_version       NUMBER := 1.0;
 l_commit            VARCHAR2(1) := FND_API.G_FALSE;
 l_init_msg_list     VARCHAR2(1) := FND_API.G_TRUE;
 l_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL;
 l_msg_count         NUMBER;
 l_msg_data          VARCHAR2(2000);
 l_txn_error_id      NUMBER;
 l_return_status     VARCHAR2(1);
 l_trx_error_rec     CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
 no_error_logged         EXCEPTION;
 x_transaction_error_id  NUMBER;

 BEGIN

   l_trx_error_rec := p_trx_error_rec;

   l_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;
   l_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;

   csi_transactions_pvt.create_txn_error
       (l_api_version, l_init_msg_list, l_commit, l_validation_level,
        l_trx_error_rec, l_return_status, l_msg_count,l_msg_data,
        l_txn_error_id);

   IF NOT l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
     raise no_error_logged;
   END IF;

 EXCEPTION
   WHEN no_error_logged THEN
     BEGIN
      csi_txn_errors_pkg.insert_row(
          px_transaction_error_id       => x_transaction_error_id,
          p_transaction_id              => fnd_api.g_miss_num,
          p_message_id                  => l_trx_error_rec.message_id,
          p_error_text                  => l_trx_error_rec.error_text,
          p_source_type                 => l_trx_error_rec.source_type,
          p_source_id                   => l_trx_error_rec.source_id,
          p_processed_flag              => l_trx_error_rec.processed_flag,
          p_created_by                  => fnd_global.user_id,
          p_creation_date               => SYSDATE,
          p_last_updated_by             => fnd_global.user_id,
          p_last_update_date            => SYSDATE,
          p_last_update_login           => fnd_global.conc_login_id,
          p_object_version_number       => 1,
          p_transaction_type_id         => l_trx_error_rec.transaction_type_id ,
          p_source_group_ref            => l_trx_error_rec.source_group_ref,
          p_source_group_ref_id         => l_trx_error_rec.source_group_ref_id ,
          p_source_header_ref           => l_trx_error_rec.source_header_ref ,
          p_source_header_ref_id        => l_trx_error_rec.source_header_ref_id ,
          p_source_line_ref             => l_trx_error_rec.source_line_ref ,
          p_source_line_ref_id          => l_trx_error_rec.source_line_ref_id ,
          p_source_dist_ref_id1         => l_trx_error_rec.source_dist_ref_id1 ,
          p_source_dist_ref_id2         => l_trx_error_rec.source_dist_ref_id2 ,
          p_inv_material_transaction_id => l_trx_error_rec.inv_material_transaction_id,
          p_error_stage                 => l_trx_error_rec.error_stage,
          p_message_string              => l_trx_error_rec.message_string,
          p_instance_id                 => l_trx_error_rec.instance_id,
          p_inventory_item_id           => l_trx_error_rec.inventory_item_id,
          p_serial_number               => l_trx_error_rec.serial_number,
          p_lot_number                  => l_trx_error_rec.lot_number,
          p_transaction_error_date      => l_trx_error_rec.transaction_error_date,
          p_src_serial_num_ctrl_code    => l_trx_error_rec.src_serial_num_ctrl_code,
          p_src_location_ctrl_code      => l_trx_error_rec.src_location_ctrl_code,
          p_src_lot_ctrl_code           => l_trx_error_rec.src_lot_ctrl_code,
          p_src_rev_qty_ctrl_code       => l_trx_error_rec.src_rev_qty_ctrl_code,
          p_dst_serial_num_ctrl_code    => l_trx_error_rec.dst_serial_num_ctrl_code,
          p_dst_location_ctrl_code      => l_trx_error_rec.dst_location_ctrl_code,
          p_dst_lot_ctrl_code           => l_trx_error_rec.dst_lot_ctrl_code,
          p_dst_rev_qty_ctrl_code       => l_trx_error_rec.dst_rev_qty_ctrl_code,
          p_comms_nl_trackable_flag     => l_trx_error_rec.comms_nl_trackable_flag
          );
     EXCEPTION
       WHEN OTHERS THEN
         raise;
     END;
  WHEN OTHERS THEN
      BEGIN
      csi_txn_errors_pkg.insert_row(
          px_transaction_error_id       => x_transaction_error_id,
          p_transaction_id              => fnd_api.g_miss_num,
          p_message_id                  => l_trx_error_rec.message_id,
          p_error_text                  => SQLERRM,
          p_source_type                 => l_trx_error_rec.source_type,
          p_source_id                   => l_trx_error_rec.source_id,
          p_processed_flag              => l_trx_error_rec.processed_flag,
          p_created_by                  => fnd_global.user_id,
          p_creation_date               => SYSDATE,
          p_last_updated_by             => fnd_global.user_id,
          p_last_update_date            => SYSDATE,
          p_last_update_login           => fnd_global.conc_login_id,
          p_object_version_number       => 1,
          p_transaction_type_id         => l_trx_error_rec.transaction_type_id ,
          p_source_group_ref            => l_trx_error_rec.source_group_ref,
          p_source_group_ref_id         => l_trx_error_rec.source_group_ref_id ,
          p_source_header_ref           => l_trx_error_rec.source_header_ref ,
          p_source_header_ref_id        => l_trx_error_rec.source_header_ref_id ,
          p_source_line_ref             => l_trx_error_rec.source_line_ref ,
          p_source_line_ref_id          => l_trx_error_rec.source_line_ref_id ,
          p_source_dist_ref_id1         => l_trx_error_rec.source_dist_ref_id1 ,
          p_source_dist_ref_id2         => l_trx_error_rec.source_dist_ref_id2 ,
          p_inv_material_transaction_id => l_trx_error_rec.inv_material_transaction_id,
          p_error_stage                 => l_trx_error_rec.error_stage,
          p_message_string              => l_trx_error_rec.message_string,
          p_instance_id                 => l_trx_error_rec.instance_id,
          p_inventory_item_id           => l_trx_error_rec.inventory_item_id,
          p_serial_number               => l_trx_error_rec.serial_number,
          p_lot_number                  => l_trx_error_rec.lot_number,
          p_transaction_error_date      => l_trx_error_rec.transaction_error_date,
          p_src_serial_num_ctrl_code    => l_trx_error_rec.src_serial_num_ctrl_code,
          p_src_location_ctrl_code      => l_trx_error_rec.src_location_ctrl_code,
          p_src_lot_ctrl_code           => l_trx_error_rec.src_lot_ctrl_code,
          p_src_rev_qty_ctrl_code       => l_trx_error_rec.src_rev_qty_ctrl_code,
          p_dst_serial_num_ctrl_code    => l_trx_error_rec.dst_serial_num_ctrl_code,
          p_dst_location_ctrl_code      => l_trx_error_rec.dst_location_ctrl_code,
          p_dst_lot_ctrl_code           => l_trx_error_rec.dst_lot_ctrl_code,
          p_dst_rev_qty_ctrl_code       => l_trx_error_rec.dst_rev_qty_ctrl_code,
          p_comms_nl_trackable_flag     => l_trx_error_rec.comms_nl_trackable_flag
          );
      EXCEPTION
        WHEN OTHERS THEN
          raise;
      END;
 END log_csi_error;

 PROCEDURE create_csi_txn(px_txn_rec   IN OUT NOCOPY
                          CSI_DATASTRUCTURES_PUB.TRANSACTION_REC,
                          x_error_message OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)  IS


  l_api_version             NUMBER          := 1.0;
  l_msg_count               NUMBER;
  l_msg_index               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_error_message           VARCHAR2(4000);
  l_return_status           VARCHAR2(1);
  l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  BEGIN
  px_txn_rec.transaction_date       :=  sysdate;
  px_txn_rec.object_version_number  :=  1;

  csi_transactions_pvt.create_transaction(l_api_version,
	                                  fnd_api.g_false,
	                                  fnd_api.g_false,
	                                  fnd_api.g_valid_level_full,
	                                  'N',
	                                  px_txn_rec,
	                                  l_return_status,
	                                  l_msg_count,
	                                  l_msg_data
	                                  );

  IF NOT l_return_status = l_fnd_success then
    debug('You encountered an error in the csi_transactions_pvt.create_transaction API '||l_msg_data);
    l_msg_index := 1;
    WHILE l_msg_count > 0 loop
      l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
      l_msg_index := l_msg_index + 1;
      l_msg_count := l_msg_count - 1;
    END LOOP;
    RAISE fnd_api.g_exc_error;
  END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      debug('You have encountered a "fnd_api.g_exc_error" exception');
      x_return_status := l_fnd_error;
      x_error_message := l_error_message;

 END create_csi_txn;

PROCEDURE get_redeploy_flag(
              p_inventory_item_id IN NUMBER
             ,p_serial_number     IN VARCHAR2
             ,p_transaction_date  IN DATE
             ,x_redeploy_flag     OUT NOCOPY VARCHAR2
             ,x_return_status     OUT NOCOPY VARCHAR2
             ,x_error_message     OUT NOCOPY VARCHAR2)
IS
l_out_of_sev  NUMBER;
l_proj_insev  NUMBER;
l_issue_hz  NUMBER;
l_misc_issue_hz NUMBER;

-- Reordered cursor query for bug --bug 9205166

/*CURSOR get_redeploy_flag_cur
IS
SELECT 'Y' redeploy_flag
FROM   csi_transactions ct
      ,csi_item_instances_h ciih
      ,csi_item_instances cii
WHERE  ct.transaction_id = ciih.transaction_id
AND    ciih.instance_id = cii.instance_id
AND    cii.inventory_item_id = p_inventory_item_id
AND    cii.serial_number = p_serial_number
AND    ct.transaction_date < NVL(p_transaction_date, SYSDATE)
AND    ct.transaction_type_id IN (l_out_of_sev, l_proj_insev,
l_issue_hz, l_misc_issue_hz) ;*/

CURSOR get_redeploy_flag_cur
IS
SELECT /*+ ordered */
  'Y' redeploy_flag
FROM  csi_item_instances cii
      ,csi_item_instances_h ciih
      ,csi_transactions ct
WHERE  ct.transaction_id = ciih.transaction_id
AND    ciih.instance_id = cii.instance_id
AND    cii.inventory_item_id = p_inventory_item_id
AND    cii.serial_number = p_serial_number
AND    ct.transaction_date < NVL(p_transaction_date, SYSDATE)
AND    ct.transaction_type_id IN (l_out_of_sev, l_proj_insev,
l_issue_hz, l_misc_issue_hz) ;


BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   x_redeploy_flag := 'N' ;

   l_out_of_sev := get_txn_type_id('OUT_OF_SERVICE','CSE');
   l_proj_insev := get_txn_type_id('PROJECT_ITEM_IN_SERVICE','CSE');
   l_issue_hz := get_txn_type_id('ISSUE_TO_HZ_LOC','INV');
   l_misc_issue_hz := get_txn_type_id('MISC_ISSUE_HZ_LOC','INV');

   OPEN get_redeploy_flag_cur ;
   FETCH get_redeploy_flag_cur INTO x_redeploy_flag ;
   CLOSE get_redeploy_flag_cur ;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := fnd_api.G_RET_STS_ERROR ;
    x_error_message := SQLERRM ;
END get_redeploy_flag ;

FUNCTION valid_ib_txn (p_transaction_id IN NUMBER) RETURN BOOLEAN IS

l_api_version               NUMBER := 1.0;
l_init_msg_list             VARCHAR2(1) := FND_API.G_FALSE;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_logical_trx_attr_values   INV_DROPSHIP_GLOBALS.logical_trx_attr_tbl;
l_fnd_success               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_ds_return_status          VARCHAR2(30);
l_source_type               VARCHAR2(50) := NULL;
l_type_id                   NUMBER       := NULL;
l_csi_txn_name              VARCHAR2(50) := NULL;
l_log_trx_action_id         NUMBER := NULL;
l_log_trx_source_type_id    NUMBER := NULL;
l_log_trx_type_code         NUMBER := NULL;
l_log_trx_id                NUMBER := NULL;
j                           PLS_INTEGER := 0;
l_log_rec_count             NUMBER := 0;
l_mo_issue_hz               NUMBER;
l_misc_issue_hz             NUMBER;
l_misc_receipt_hz           NUMBER;

CURSOR c_mtl_data is
  SELECT transaction_id,
         inventory_item_id,
         transaction_quantity,
         source_code,
         transaction_action_id,
         transaction_type_id,
         transaction_source_type_id,
         ship_to_location_id
  FROM mtl_material_transactions
  WHERE transaction_id = p_transaction_id;

r_mtl_data     c_mtl_data%rowtype;

CURSOR c_type_class (pc_transaction_type_id NUMBER) is
  SELECT type_class,
         transaction_source_type_id,
         nvl(location_required_flag,'N') location_required_flag
  FROM mtl_trx_types_view
  WHERE transaction_type_id = pc_transaction_type_id;

r_type_class      c_type_class%rowtype;

BEGIN

  -- Get all Inventory Data.

  FOR r_mtl_data in c_mtl_data LOOP

  l_source_type := NULL;
  l_type_id     := NULL;

  -- Get CSI Txn Name for Error
  l_csi_txn_name := csi_inv_trxs_pkg.get_inv_name(r_mtl_data.transaction_id);

  -- Get Type Class Code
  OPEN c_type_class(r_mtl_data.transaction_type_id);
  FETCH c_type_class into r_type_class;
  CLOSE c_type_class;

  -- Get Drop Shipment Info from Inventory API

  inv_ds_logical_trx_info_pub.get_logical_attr_values(l_ds_return_status,
                                                      l_msg_count,
                                                      l_msg_data,
                                                      l_logical_trx_attr_values,
                                                      l_api_version,
                                                      l_init_msg_list,
                                                      r_mtl_data.transaction_id);

  IF l_ds_return_status = l_fnd_success AND
     l_logical_trx_attr_values.count > 0 THEN

    FOR j in l_logical_trx_attr_values.first .. l_logical_trx_attr_values.last LOOP

      IF (l_logical_trx_attr_values(j).transaction_action_id = 7 AND
          l_logical_trx_attr_values(j).transaction_source_type_id = 2 AND
          l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

          l_log_trx_action_id       := l_logical_trx_attr_values(j).transaction_action_id;
          l_log_trx_source_type_id  := l_logical_trx_attr_values(j).transaction_source_type_id;
          l_log_trx_type_code       := l_logical_trx_attr_values(j).logical_trx_type_code;

          FOR j in l_logical_trx_attr_values.first .. l_logical_trx_attr_values.last LOOP

            IF (l_logical_trx_attr_values(j).transaction_action_id = 9 AND
                l_logical_trx_attr_values(j).transaction_source_type_id = 13 AND
                l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

                l_log_trx_id              := l_logical_trx_attr_values(j).transaction_id;
            END IF;
          END LOOP;

     ELSIF (l_logical_trx_attr_values(j).transaction_action_id = 11 AND
            l_logical_trx_attr_values(j).transaction_source_type_id = 1 AND
            l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

          l_log_trx_action_id       := l_logical_trx_attr_values(j).transaction_action_id;
          l_log_trx_source_type_id  := l_logical_trx_attr_values(j).transaction_source_type_id;
          l_log_trx_type_code       := l_logical_trx_attr_values(j).logical_trx_type_code;
          l_log_trx_id              := l_logical_trx_attr_values(j).transaction_id;

      END IF;
    END LOOP;
  END IF;

  -- Start of code to see what kind of source type this is

  IF (r_mtl_data.transaction_action_id = 1 AND
      r_mtl_data.transaction_source_type_id = 4 AND
      r_mtl_data.transaction_type_id NOT IN (33,122,35,37,93)  AND
      r_type_class.location_required_flag = 'Y' AND
     (r_type_class.type_class is null OR r_type_class.type_class <> 1))
  THEN
    RETURN(TRUE);

  ELSIF (r_mtl_data.transaction_action_id = 27 AND
         r_mtl_data.transaction_source_type_id in (13,6,3) AND
         r_mtl_data.transaction_type_id NOT IN (15,123,43,94) AND
         r_type_class.location_required_flag = 'Y' AND
        (r_type_class.type_class is null OR r_type_class.type_class <> 1))
  THEN
    RETURN(TRUE);

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
	 r_mtl_data.transaction_source_type_id in (13,6,3) AND
	 r_mtl_data.transaction_type_id NOT IN (33,122,35,37,93)  AND
	 r_type_class.location_required_flag = 'Y' AND
	(r_type_class.type_class is null OR r_type_class.type_class <> 1))
  THEN

     RETURN(TRUE);

  ELSIF (l_log_trx_action_id  = 7 AND
         l_log_trx_source_type_id = 2 AND
         l_log_trx_id IS NOT NULL)
  THEN
	---Transactions fall in this category are :
	---  Type                          Action ID     Txn Type ID
	-----------------------          -------------   ------------
	--1. Logical Sales Order Issue        7              30

     IF l_log_trx_id <> p_transaction_id THEN
       RETURN(FALSE);
     ELSE
       RETURN(TRUE);
     END IF;

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 4 AND
         r_type_class.type_class = 1) -- Issue to Project
  THEN
     RETURN(TRUE);

  ELSIF (r_mtl_data.transaction_action_id = 1 AND  -- Misc. Issue to Project
   						   -- Acct/Acct Alias, Inv
         r_mtl_data.transaction_source_type_id in (3,6,13) AND
         r_type_class.type_class = 1)
  THEN
     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 27 AND
          r_mtl_data.transaction_source_type_id in (3,6,13) AND
          r_type_class.type_class = 1)  -- Misc Receipt from Project
							     -- Acct/Acct Alias, Inv
   THEN
     RETURN(TRUE);

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 16)

  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Project Contract Issue   	  1              77
     RETURN(TRUE);

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 2) OR
	    -- Changed to 2 from Txn Type ID 33
        (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 8)
  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Sales Order Issue        	  1              33
	--2. Intrnl Ord Issue(Ship Conf)  1              34

     RETURN(TRUE);

  ELSIF (r_mtl_data.transaction_action_id = 27 AND
         r_mtl_data.transaction_source_type_id = 12)
	     -- Changed to 12 from Txn Type ID 15
  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. RMA Receipt              	  27             15

     RETURN(TRUE);

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

     RETURN(TRUE);

    ELSIF (r_mtl_data.transaction_action_id = 12 AND  -- Interorg Receipt
            r_mtl_data.transaction_source_type_id = 13)
		  -- Changed to 13 from Txn ID 12

   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. InTransit Receipt            12             12

     RETURN(TRUE);

    ELSIF (r_mtl_data.transaction_action_id = 21 AND
            r_mtl_data.transaction_source_type_id = 13)  -- Interorg Shipment
		  -- Changed to 13 from Txn ID 21

   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. InTransit Shipment           21             21

     RETURN(TRUE);

   ELSIF  (r_mtl_data.transaction_action_id = 3 AND  -- Direct Org Transfer
            r_mtl_data.transaction_source_type_id = 13 AND
            r_mtl_data.transaction_quantity > 0)
            -- Changed to 13 from Txn ID 3
   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Direct Org Transfer          3              3

     RETURN(TRUE);

   ELSIF  (r_mtl_data.transaction_action_id = 12 AND  -- Int So In Trans Receipt
           r_mtl_data.transaction_source_type_id = 7)
   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Int Req Intr Rcpt            12             61

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 21 AND  -- Int So In Trans Ship
          r_mtl_data.transaction_source_type_id = 8)

   THEN
    ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Int Order Intr Ship          21             62

     RETURN(TRUE);

   ELSIF  (r_mtl_data.transaction_action_id = 3 AND -- ISO Direct Shipment
	   r_mtl_data.transaction_source_type_id in (7,8) AND
	   r_mtl_data.transaction_quantity > 0)

   THEN
        ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Int Order Direct Ship        3              54

     RETURN(TRUE);

  ELSIF  r_mtl_data.transaction_action_id = 27 AND
         r_mtl_data.transaction_source_type_id = 1
	     -- Changed to 1 from Txn Type ID 18

        ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. PO Receipt                   27             18

  THEN
     RETURN(TRUE);

   ELSIF r_mtl_data.transaction_action_id = 4

    ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Cycle Count Adjust (-/+)      4             4

   THEN
     RETURN(TRUE);

   ELSIF r_mtl_data.transaction_action_id = 8

    ---Transactions fall in this category are :
	---  Type                     Action ID     Txn Type ID
	-----------------------     -------------   ------------
	--1. Physical Inv Adjust(-/+)      8              8

   THEN
     RETURN(TRUE);

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

     RETURN(TRUE);

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

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 32 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 17
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Assembly Return          32             17

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 1 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 35
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Component Issue          1              35

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 33 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 38
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Neg Comp Issue           33             38

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 27 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 43
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Component Return         27             43

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 31 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 44
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Assy Completion          31             44

     RETURN(TRUE);

   ELSIF (r_mtl_data.transaction_action_id = 34 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 48
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Neg Comp Return          34             48

     RETURN(TRUE);

   ELSE
     -- Source Type not Recognized
     RETURN(FALSE);
 END IF;
 END LOOP;  -- End of c_mtl_data Cursor Loop

 RETURN(FALSE);

END; -- valid_ib_txn

  PROCEDURE set_item_attr_query_values(
    l_mtl_item_tbl          IN  CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE,
    table_index             IN  NUMBER,
    p_source                IN  VARCHAR2,
    x_instance_query_rec    OUT NOCOPY csi_datastructures_pub.instance_query_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_instance_query_rec    csi_datastructures_pub.instance_query_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('Setting Item Control Attributes on Query Record');

    l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
    l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(table_index).inventory_item_id;

    -- Serial Control and if Non Serial all other controls are checked. If this is serial we just set that
    -- and exit since the query is just by item/serial

    IF l_mtl_item_tbl(table_index).serial_number_control_code IN (1,6) THEN
      l_instance_query_rec.serial_number                   := NULL;

      -- Lot Control
      IF  l_mtl_item_tbl(table_index).lot_control_code = 1 THEN
        l_instance_query_rec.lot_number                      :=  NULL;
      ELSE
        l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(table_index).lot_number;
      END IF;

      -- Revision Control
      IF l_mtl_item_tbl(table_index).revision_qty_control_code = 1 THEN
        l_instance_query_rec.inventory_revision              :=  NULL;
      ELSE
        l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(table_index).revision;
      END IF;

      -- Locator Control
      -- Since Locator control can be set at Item, Org or Subinv Level just take what is there
      -- and do not look at the control code
      --IF l_mtl_item_tbl(table_index).location_control_code = 1 THEN
      --  l_instance_query_rec.inv_locator_id                  :=  NULL;
      --ELSE
        IF p_source = 'TRANSFER' THEN
          l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(table_index).transfer_locator_id;
        ELSE
          l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(table_index).locator_id;
        END IF;
      --END IF;

    ELSE
      l_instance_query_rec.serial_number                   := l_mtl_item_tbl(table_index).serial_number;

    END IF; -- End of Serial IF

    x_instance_query_rec := l_instance_query_rec;

    debug('Done setting attributes in query passing out to set the rest of the values ');

  EXCEPTION
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END set_item_attr_query_values;

END csi_inv_trxs_pkg;

/
