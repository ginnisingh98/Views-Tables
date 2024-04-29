--------------------------------------------------------
--  DDL for Package Body CSI_INV_PROJECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_PROJECT_PKG" as
-- $Header: csiivtpb.pls 120.2.12000000.2 2007/07/06 12:19:05 syenaman ship $

l_debug NUMBER := csi_t_gen_utility_pvt.g_debug_level;

   PROCEDURE issue_to_project(p_transaction_id     IN  NUMBER,
                              p_message_id         IN  NUMBER,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl                CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                    VARCHAR2(100)   := 'CSI_INV_PROJECT_PKG.ISSUE_TO_PROJECT';
   l_api_version                 NUMBER          := 1.0;
   l_commit                      VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list               VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level            NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only        VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only      VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id              NUMBER          := NULL;
   l_resolve_id_columns          VARCHAR2(10)    := FND_API.G_FALSE;
   l_object_version_number       NUMBER          := 1;
   l_sysdate                     DATE            := SYSDATE;
   l_master_organization_id      NUMBER;
   l_depreciable                 VARCHAR2(1);
   l_instance_query_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_dest_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_source_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec            CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                     CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status               VARCHAR2(1);
   l_error_code                  VARCHAR2(50);
   l_error_message               VARCHAR2(4000);
   l_instance_id_lst             CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec             CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec           CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_src_instance_header_tbl     CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_dest_instance_header_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
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
   l_in_service                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed                   VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_transaction_error_id        NUMBER;
   l_quantity                    NUMBER;
   l_mfg_serial_flag             VARCHAR2(1);
   l_trans_status_code           VARCHAR2(15);
   l_ins_number                  VARCHAR2(100);
   l_ins_id                      NUMBER;
   l_file                        VARCHAR2(500);
   l_trx_type_id                 NUMBER;
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_msg_index                   NUMBER;
   l_employee_id                 NUMBER;
   j                             PLS_INTEGER;
   i                             PLS_INTEGER := 1;
   l_tbl_count                   NUMBER := 0;
   l_neg_code                    NUMBER := 0;
   l_instance_status             VARCHAR2(1);
   l_redeploy_flag               VARCHAR2(1);
   l_upd_error_instance_id       NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   BEGIN

     x_return_status := l_fnd_success;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('*****Start of csi_inv_trxs_pkg.issue_to_project Transaction procedure*****');
        csi_t_gen_utility_pvt.add('Transaction You are Processing is: '||p_transaction_id);
     END IF;

     -- This procedure queries all of the Inventory Transaction Records and returns them
     -- as a table.
     csi_inv_trxs_pkg.get_transaction_recs(p_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;
     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Inventory Records Found: '||l_tbl_count);
     END IF;

IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||p_transaction_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id
     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
       END IF;
     END IF;
     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('The Employee that is processing this Transaction is: '||l_employee_id);
     END IF;

     -- See if this is a depreciable Item to set the status of the transaction record
     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                            l_depreciable);

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);
     END IF;

     -- Set the mfg_serial_number_flag and quantity
     IF l_mtl_item_tbl(i).serial_number is NULL THEN
       l_mfg_serial_flag := 'N';
       l_quantity        := l_mtl_item_tbl(i).transaction_quantity;
     ELSE
       l_mfg_serial_flag := 'Y';
       l_quantity        := 1;
     END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

     -- Get the Negative Receipt Code to see if this org allows Negative
     -- Quantity Records 1 = Yes, 2 = No

	l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(
						  l_mtl_item_tbl(i).organization_id);

     IF l_neg_code = 1 AND l_mtl_item_tbl(i).serial_number is NULL THEN
       l_instance_status := FND_API.G_FALSE;
     ELSE
       l_instance_status := FND_API.G_TRUE;
     END IF;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);
     END IF;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Starting to loop through Material Transaction Records');
     END IF;

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
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Redeploy Flag: '||l_redeploy_flag);
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.get_redeploy_flag: '||l_error_message);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Redeploy Flag: '||l_redeploy_flag);
        csi_t_gen_utility_pvt.add('Trans Status Code: '||l_txn_rec.transaction_status_code);
     END IF;

     -- Get Default Status ID
     OPEN c_id;
     FETCH c_id into r_id;
     CLOSE c_id;

     -- Create CSI Transaction to be used
     l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
     l_txn_rec.transaction_date         := l_sysdate;
     l_txn_rec.transaction_type_id      :=  csi_inv_trxs_pkg.get_txn_type_id('MOVE_ORDER_ISSUE_TO_PROJECT','INV');
     l_txn_rec.transaction_quantity     := l_mtl_item_tbl(i).transaction_quantity;
     l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
     l_txn_rec.transacted_by            :=  l_employee_id;
     l_txn_rec.transaction_action_code  :=  NULL;
     l_txn_rec.message_id               :=  p_message_id;
     l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
     l_txn_rec.object_version_number    :=  l_object_version_number;
     l_txn_rec.source_header_ref_id     :=  l_mtl_item_tbl(i).transaction_source_id;
     l_txn_rec.source_line_ref_id       :=  l_mtl_item_tbl(i).move_order_line_id;

     csi_inv_trxs_pkg.create_csi_txn(l_txn_rec,
                                     l_error_message,
                                     l_return_status);

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('CSI Transaction Created: '||l_txn_rec.transaction_id);
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.create_csi_txn: '||p_transaction_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
          csi_t_gen_utility_pvt.add('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
          csi_t_gen_utility_pvt.add('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
          csi_t_gen_utility_pvt.add('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
       END IF;

       l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
       l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
       l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
       l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
       l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
       l_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
       l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
       l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
       l_instance_query_rec.instance_usage_code             :=  l_in_inventory;

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Before Get Item Instance');
       END IF;

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

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('After Get Item Instance');
       END IF;
       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
       END IF;
       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
       IF NOT l_return_status = l_fnd_success then
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
         END IF;
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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('No records were found so create a new Source Instance Record');
         END IF;

         l_new_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_src_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_src_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_src_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_src_instance_rec.mfg_serial_number_flag       :=  'N';
         l_new_src_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_src_instance_rec.quantity                     :=  l_mtl_item_tbl(j).transaction_quantity;
         l_new_src_instance_rec.active_start_date            :=  l_sysdate;
         l_new_src_instance_rec.active_end_date              :=  NULL;
         l_new_src_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_new_src_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
         l_new_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_src_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_src_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_src_instance_rec.customer_view_flag           :=  'N';
         l_new_src_instance_rec.merchant_view_flag           :=  'Y';
         l_new_src_instance_rec.operational_status_code      :=  'NOT_USED';
         l_new_src_instance_rec.object_version_number        :=  l_object_version_number;

         l_ext_attrib_values_tbl  :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
         l_party_tbl              :=  csi_inv_trxs_pkg.init_party_tbl;
         l_account_tbl            :=  csi_inv_trxs_pkg.init_account_tbl;
         l_pricing_attrib_tbl     :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
         l_org_assignments_tbl    :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
         l_asset_assignment_tbl   :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Create Source Item Instance');
         END IF;

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

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('After Create Source Item Instance');
                csi_t_gen_utility_pvt.add('After Create of Source Item Instance');
   		csi_t_gen_utility_pvt.add('New instance created is: '||l_new_src_instance_rec.instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the
             -- error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               END IF;
               l_msg_index := 1;
	           WHILE l_msg_count > 0 loop
	               l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	               l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                  END LOOP;
	           RAISE fnd_api.g_exc_error;
             END IF;

       ELSE  -- No Records were found and Neg Qtys Not Allowed
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('No Records were found in Install Base andNeg Qtys not allowed to error');
         END IF;
         fnd_message.set_name('CSI','CSI_NO_NEG_BAL_ALLOWED');
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

     END IF;  -- Neg Qty If

     ELSIF l_src_instance_header_tbl.count = 1 THEN
        -- Records found so make sure that is is updated to be unexp
       -- and subtract the quantity from source record

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You will update instance: '||l_src_instance_header_tbl(i).instance_id);
            csi_t_gen_utility_pvt.add('End Date is: '||l_src_instance_header_tbl(i).active_end_date);
         END IF;
         l_update_source_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_update_source_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
         l_update_source_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
         l_update_source_instance_rec.active_end_date              :=  NULL;
         l_update_source_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

         l_party_tbl.delete;
         l_account_tbl.delete;
         l_pricing_attrib_tbl.delete;
         l_org_assignments_tbl.delete;
         l_asset_assignment_tbl.delete;

         l_update_source_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Update Item Instance');
         END IF;

         csi_item_instance_pub.update_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_update_source_instance_rec,
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
         l_upd_error_instance_id := l_update_source_instance_rec.instance_id;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Update Item Instance');
            csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
         END IF;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_source_instance_rec.instance_status_id);
         END IF;

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             END IF;
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
         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-30');
         END IF;
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         RAISE fnd_api.g_exc_error;

         END IF;   -- End of Source Record IF

         -- Now query and get the destination record.
         l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_query_rec.pa_project_id                   :=  l_mtl_item_tbl(j).source_project_id;
         l_instance_query_rec.pa_project_task_id              :=  l_mtl_item_tbl(j).source_task_id;
         l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_query_rec.instance_usage_code             :=  l_in_process;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Destination Get Item Instance - Neg Qty');
         END IF;

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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Destination Get Item Instance');
         END IF;
         l_tbl_count := 0;
         l_tbl_count := l_dest_instance_header_tbl.count;
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Destination Records Found: '||l_tbl_count);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status = l_fnd_success then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
           END IF;
           l_msg_index := 1;
           WHILE l_msg_count > 0 loop
	        l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	        l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
  	      END LOOP;
	      RAISE fnd_api.g_exc_error;
         END IF;

         IF l_dest_instance_header_tbl.count = 0 THEN -- Installed Base Destination Records are not found
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('No Destination Records were found so we will create a new destination Record using the source data');
           END IF;

           l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
           l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
           l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
           l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
           l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
           l_new_dest_instance_rec.active_end_date              :=  NULL;
           l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_new_dest_instance_rec.instance_usage_code          :=  l_in_process;
           l_new_dest_instance_rec.inv_locator_id               :=  NULL;
           l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Project');
           l_new_dest_instance_rec.location_id                  :=  csi_inv_trxs_pkg.get_dflt_project_location_id;
           l_new_dest_instance_rec.inv_organization_id          :=  NULL;
           l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_dest_instance_rec.pa_project_id                :=  l_mtl_item_tbl(j).source_project_id;
           l_new_dest_instance_rec.pa_project_task_id           :=  l_mtl_item_tbl(j).source_task_id;
           l_new_dest_instance_rec.customer_view_flag           :=  'N';
           l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
           l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
           l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;

           l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Create Item Instance - Neg Qty');
           END IF;

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

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Create Item Instance');
              csi_t_gen_utility_pvt.add('Item Instance Created: '||l_new_dest_instance_rec.instance_id);
           END IF;

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
             END IF;
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
             END LOOP;
	        RAISE fnd_api.g_exc_error;
           END IF;

         ELSIF l_dest_instance_header_tbl.count = 1 THEN-- Installed Base Destination Records Found

	   IF (l_debug > 0) THEN
   	     csi_t_gen_utility_pvt.add('You will update instance: '||l_dest_instance_header_tbl(i).instance_id);
	   END IF;

             l_update_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_dest_instance_rec.instance_id                  :=  l_dest_instance_header_tbl(i).instance_id;
             l_update_dest_instance_rec.quantity                     :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
             l_update_dest_instance_rec.active_end_date              :=  NULL;
             l_update_dest_instance_rec.object_version_number        :=  l_dest_instance_header_tbl(i).object_version_number;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Update Item Instance - Neg Qty');
             END IF;

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

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('After Update Item Instance - Neg Qty');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
               END IF;
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
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-30');
           END IF;
           fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
           fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
           RAISE fnd_api.g_exc_error;

         END IF;    -- End of Destination Non Serial IF

       ELSIF l_mtl_item_tbl(j).serial_number is NOT NULL THEN
         IF l_src_instance_header_tbl.count = 1 THEN  -- Installed Base Records Found
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You are updating an Item Instance Record');
            csi_t_gen_utility_pvt.add('You are updating a Serialized Item: '||l_src_instance_header_tbl(i).instance_id);
            csi_t_gen_utility_pvt.add('The Transaction Status Code will be - Complete (C) or Incomplete (I): '||l_trans_status_code);
           END IF;

           l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           l_update_instance_rec.inv_subinventory_name        :=  NULL;
	   -- Added for Bug 5975739
	   l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_update_instance_rec.inv_organization_id          :=  NULL;
           l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.inv_locator_id               :=  NULL;
           l_update_instance_rec.location_id                  :=  csi_inv_trxs_pkg.get_dflt_project_location_id;
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Project');
           l_update_instance_rec.pa_project_id                :=  l_mtl_item_tbl(j).source_project_id;
           l_update_instance_rec.pa_project_task_id           :=  l_mtl_item_tbl(j).source_task_id;
           l_update_instance_rec.instance_usage_code          :=  l_in_process;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Update Item Instance');
           END IF;

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

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Update Item Instance');
              csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
           END IF;

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             END IF;
             l_msg_index := 1;
	       WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
             END LOOP;
	     RAISE fnd_api.g_exc_error;
           END IF;
         ELSIF l_src_instance_header_tbl.count = 0 THEN
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('No Records were found in Install Base');
           END IF;
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

         ELSIF l_src_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Multiple Instances were Found in InstallBase-40');
           END IF;
           fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
           fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
           RAISE fnd_api.g_exc_error;
       END IF;        -- End of Source Record IF for Serialized

       END IF;      -- End of Serial Number If
     END LOOP;        -- End of For Loop

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('*****End of csi_inv_trxs_pkg.issue_to_project Transaction procedure*****');
     END IF;

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered a "fnd_api.g_exc_error" exception');
       END IF;
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
       x_trx_error_rec.source_type          := 'CSIISUPT';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('MOVE_ORDER_ISSUE_TO_PROJECT','INV');
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered a "others" exception');
       END IF;
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
       x_trx_error_rec.source_type          := 'CSIISUPT';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('MOVE_ORDER_ISSUE_TO_PROJECT','INV');
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;
   END issue_to_project;

   PROCEDURE misc_receipt_projtask(p_transaction_id     IN  NUMBER,
                                   p_message_id         IN  NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl                CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                    VARCHAR2(100)   := 'CSI_INV_PROJECT_PKG.MISC_RECEIPT_PROJTASK';
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
   l_instance_id_lst             CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_txn_error_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
   l_instance_query_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_instance_dest_query_rec     CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_dest_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_upd_src_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_dest_instance_query_rec     CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_new_instance_rec            CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_instance_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                     CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status               VARCHAR2(1);
   l_error_code                  VARCHAR2(50);
   l_error_message               VARCHAR2(4000);
   l_party_query_rec             CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec           CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_src_instance_header_tbl     CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_dest_instance_header_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
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
   l_in_service                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed                   VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_in_wip                      VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_WIP;
   l_transaction_error_id        NUMBER;
   l_quantity                    NUMBER;
   l_mfg_serial_flag             VARCHAR2(1);
   l_trans_status_code           VARCHAR2(15);
   l_ins_number                  VARCHAR2(100);
   l_employee_id                 NUMBER;
   l_ins_id                      NUMBER;
   l_file                        VARCHAR2(500);
   l_status                      VARCHAR2(100);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_msg_index                   NUMBER;
   j                             PLS_INTEGER;
   i                             PLS_INTEGER := 1;
   l_tbl_count                   NUMBER := 0;
   l_redeploy_flag               VARCHAR2(1);
   l_upd_error_instance_id       NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   BEGIN

     x_return_status := l_fnd_success;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('*****Start of csi_inv_trxs_pkg.misc_receipt_projtask Transaction procedure*****');
        csi_t_gen_utility_pvt.add('Transaction You are Processing is: '||p_transaction_id);
     END IF;

     -- This procedure queries all of the Inventory Transaction Records and returns them
     -- as a table.
     csi_inv_trxs_pkg.get_transaction_recs(p_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;
     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Inventory Records Found: '||l_tbl_count);
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||p_transaction_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id
     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
       END IF;
     END IF;
     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('The Employee that is processing this Transaction is: '||l_employee_id);
     END IF;

     -- See if this is a depreciable Item to set the status of the transaction record
     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                            l_depreciable);

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);
     END IF;

     -- Set the quantity
     IF l_mtl_item_tbl(i).serial_number IS NULL THEN
       l_quantity        := l_mtl_item_tbl(i).transaction_quantity;
     ELSE
       l_quantity        := 1;
     END IF;

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
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Redeploy Flag: '||l_redeploy_flag);
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.get_redeploy_flag: '||l_error_message);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Redeploy Flag: '||l_redeploy_flag);
        csi_t_gen_utility_pvt.add('Trans Status Code: '||l_txn_rec.transaction_status_code);
     END IF;

     -- Get Default Status ID
     OPEN c_id;
     FETCH c_id into r_id;
     CLOSE c_id;

     -- Create CSI Transaction to be used
     l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
     l_txn_rec.transaction_date         := l_sysdate;
     l_txn_rec.transaction_type_id      :=  csi_inv_trxs_pkg.get_txn_type_id('MISC_RECEIPT_FROM_PROJECT','INV');
     l_txn_rec.transaction_quantity     := l_mtl_item_tbl(i).transaction_quantity;
     l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
     l_txn_rec.transacted_by            :=  l_employee_id;
     l_txn_rec.transaction_action_code  :=  NULL;
     l_txn_rec.message_id               :=  p_message_id;
     l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
     l_txn_rec.object_version_number    :=  l_object_version_number;

     csi_inv_trxs_pkg.create_csi_txn(l_txn_rec,
                                     l_error_message,
                                     l_return_status);

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('CSI Transaction Created: '||l_txn_rec.transaction_id);
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.create_csi_txn: '||p_transaction_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Starting to loop through Material Transaction Records');
     END IF;

     FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
        csi_t_gen_utility_pvt.add('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
        csi_t_gen_utility_pvt.add('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
        csi_t_gen_utility_pvt.add('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
     END IF;

     IF l_mtl_item_tbl(j).serial_number IS NOT NULL THEN -- Serialized

       l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
       l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
       --l_instance_query_rec.pa_project_id                   :=  l_mtl_item_tbl(j).source_project_id;
       --l_instance_query_rec.pa_project_task_id              :=  l_mtl_item_tbl(j).source_task_id;
       l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
       --l_instance_query_rec.instance_usage_code             :=  l_in_process;

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Before Get Item Instance');
       END IF;

       csi_item_instance_pub.get_item_instances(l_api_version,
                                                l_commit,
                                                l_init_msg_list,
                                                l_validation_level,
                                                l_instance_query_rec,
                                                l_party_query_rec,
                                                l_account_query_rec,
                                                l_transaction_id,
                                                l_resolve_id_columns,
                                                l_active_instance_only,
                                                l_src_instance_header_tbl,
                                                l_return_status,
                                                l_msg_count,
                                                l_msg_data);

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('After Update Item Instance');
       END IF;
       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
       END IF;

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
       IF NOT l_return_status = l_fnd_success then
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
         END IF;
         l_msg_index := 1;
           WHILE l_msg_count > 0 loop
	     l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	     l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
  	   END LOOP;
	   RAISE fnd_api.g_exc_error;
       END IF;

       IF l_src_instance_header_tbl.count = 1 THEN -- Records found so update either Serialized or Non Serialized
          IF l_src_instance_header_tbl(i).instance_usage_code in (l_out_of_service,
                                                                  l_in_inventory,
                                                                  l_in_wip,
                                                                  l_installed,
                                                                  l_in_service,
                                                                  l_in_process) THEN

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Source records found so decide which one to update');
           END IF;

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
             l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
             l_update_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_update_instance_rec.quantity                     :=  1;
	     -- Added for Bug 5975739
	     l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
             l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_update_instance_rec.pa_project_id                :=  NULL;
             l_update_instance_rec.pa_project_task_id           :=  NULL;
             l_update_instance_rec.install_location_type_code   :=  NULL;
             l_update_instance_rec.install_location_id          :=  NULL;
             l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
             l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Update Item Instance');
             END IF;

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

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('After Update Item Instance');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the
             -- error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;
          ELSE
            l_status := 'In Inventory, Out of Service, Installed, In Service or In Process';
            IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Serialized Item with Status other then Out Of Service, In Inventory, Installed, or In Process already exists in Install Base');
              csi_t_gen_utility_pvt.add('Instance Usage Code is: '||l_src_instance_header_tbl(i).instance_usage_code);
            END IF;
            fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
            fnd_message.set_token('STATUS',l_status);
            l_error_message := fnd_message.get;
            l_return_status := l_fnd_error;
            RAISE fnd_api.g_exc_error;
        END IF;

         ELSIF l_src_instance_header_tbl.count = 0 THEN

           csi_t_gen_utility_pvt.add('No Serialized Instances are found so we need to create one that we would have received from the project and task');

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
           l_new_instance_rec.operational_status_code      :=  'NOT_USED';
           l_new_instance_rec.object_version_number        :=  l_object_version_number;
           l_ext_attrib_values_tbl                         :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl                                     :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl                                   :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl                            :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl                           :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl                          :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           l_new_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           csi_t_gen_utility_pvt.add('Instance_status_id Value: '||nvl(l_new_instance_rec.instance_status_id,-1));
           csi_t_gen_utility_pvt.add('You will now Create a new Item Instance Record');
           csi_t_gen_utility_pvt.add('Serial Number: '||l_new_instance_rec.serial_number);

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
             csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
             l_msg_index := 1;
  	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	  	   l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           csi_t_gen_utility_pvt.add('Item Instance Created: '||l_new_instance_rec.instance_id);

-- Bug 4378656 - If the instance is not there then we still need to create one that is In Inventory.
--           IF (l_debug > 0) THEN
--             csi_t_gen_utility_pvt.add('No Records were found in Install Base');
--           END IF;
--           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
--           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
--           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
--           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
--           l_error_message := fnd_message.get;
--           RAISE fnd_api.g_exc_error;

         ELSIF l_src_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Multiple Instances were Found in InstallBase-55');
           END IF;
           fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
           fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
           RAISE fnd_api.g_exc_error;
       END IF;    -- No Records Found

     ELSIF l_mtl_item_tbl(j).serial_number IS NULL THEN -- Non Serialized

       l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
       l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
       l_instance_query_rec.pa_project_id                   :=  l_mtl_item_tbl(j).source_project_id;
       l_instance_query_rec.pa_project_task_id              :=  l_mtl_item_tbl(j).source_task_id;
       l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
       l_instance_query_rec.serial_number                   :=  NULL;
       l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
       l_instance_query_rec.instance_usage_code             :=  l_in_process;

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Before Get Item Instance');
       END IF;

       csi_item_instance_pub.get_item_instances(l_api_version,
                                                l_commit,
                                                l_init_msg_list,
                                                l_validation_level,
                                                l_instance_query_rec,
                                                l_party_query_rec,
                                                l_account_query_rec,
                                                l_transaction_id,
                                                l_resolve_id_columns,
                                                l_active_instance_only,
                                                l_src_instance_header_tbl,
                                                l_return_status,
                                                l_msg_count,
                                                l_msg_data);

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('After Get Item Instance');
       END IF;
       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
       END IF;

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
       IF NOT l_return_status = l_fnd_success then
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
         END IF;
         l_msg_index := 1;
           WHILE l_msg_count > 0 loop
	     l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	     l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
  	   END LOOP;
	   RAISE fnd_api.g_exc_error;
       END IF;

       IF l_src_instance_header_tbl.count = 1 THEN -- Records found so update either Serialized or Non Serialized

         l_upd_src_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_upd_src_dest_instance_rec.instance_id             :=  l_src_instance_header_tbl(i).instance_id;
         l_upd_src_dest_instance_rec.quantity                :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
         l_upd_src_dest_instance_rec.active_end_date         :=  NULL;
         l_upd_src_dest_instance_rec.object_version_number   :=  l_src_instance_header_tbl(i).object_version_number;

         l_party_tbl.delete;
         l_account_tbl.delete;
         l_pricing_attrib_tbl.delete;
         l_org_assignments_tbl.delete;
         l_asset_assignment_tbl.delete;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Update Item Instance');
         END IF;

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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Update Item Instance');
            csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
           END IF;
           l_msg_index := 1;
            WHILE l_msg_count > 0 loop
              l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	      l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
  	     END LOOP;
	     RAISE fnd_api.g_exc_error;
         END IF;

         -- Now query and get the destination record.
         l_instance_dest_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
         l_instance_dest_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_dest_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
         l_instance_dest_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         l_instance_dest_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_dest_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_dest_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
         l_instance_dest_query_rec.serial_number                   :=  NULL;
         l_instance_dest_query_rec.instance_usage_code             :=  l_in_inventory;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Get Item Instance');
         END IF;

         csi_item_instance_pub.get_item_instances(l_api_version,
                                                  l_commit,
                                                  l_init_msg_list,
                                                  l_validation_level,
                                                  l_instance_dest_query_rec,
                                                  l_party_query_rec,
                                                  l_account_query_rec,
                                                  l_transaction_id,
                                                  l_resolve_id_columns,
                                                  l_inactive_instance_only,
                                                  l_dest_instance_header_tbl,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Get Item Instance');
         END IF;
         l_tbl_count := 0;
         l_tbl_count := l_dest_instance_header_tbl.count;
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Destination Records Found: '||l_tbl_count);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status = l_fnd_success then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
           END IF;
           l_msg_index := 1;
             WHILE l_msg_count > 0 loop
	       l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	       l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	     END LOOP;
	     RAISE fnd_api.g_exc_error;
         END IF;

         IF l_dest_instance_header_tbl.count = 0 THEN

           l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
           l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
           l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
           l_new_dest_instance_rec.serial_number                :=  NULL;
           l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
           l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_new_dest_instance_rec.instance_usage_code          :=  l_in_inventory;
           l_new_dest_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_dest_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
           l_new_dest_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
           l_new_dest_instance_rec.customer_view_flag           :=  'N';
           l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
           l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
           l_new_dest_instance_rec.active_end_date              :=  NULL;
           l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
           l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;

           l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Create Item Instance');
           END IF;

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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Update Item Instance');
            csi_t_gen_utility_pvt.add('Item Instance Created: '||l_new_dest_instance_rec.instance_id);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
           END IF;
           l_msg_index := 1;
             WHILE l_msg_count > 0 loop
               l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	       l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
             END LOOP;
	     RAISE fnd_api.g_exc_error;
         END IF;

         ELSIF l_dest_instance_header_tbl.count = 1 THEN

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_dest_instance_header_tbl(i).instance_id;
             l_update_instance_rec.quantity                     :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
             l_update_instance_rec.active_end_date              :=  NULL;
             l_update_instance_rec.object_version_number        :=  l_dest_instance_header_tbl(i).object_version_number;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Update Item Instance');
             END IF;

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

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('After Update Item Instance');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the
             -- error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
               END IF;
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
         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-50');
         END IF;
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         RAISE fnd_api.g_exc_error;

         END IF;    -- End of Destination Record If

       ELSIF l_src_instance_header_tbl.count = 0 THEN

         csi_t_gen_utility_pvt.add('No Source Records in a Project and Task Exist. Query for the inventory record in the Org to see if it exists. If it does then add to that instance otherwise create a new instance that is located in Inventory');

         -- No Project and Task Records exist so check if there are any in Inventory. If not we will create otherwise update
         l_instance_dest_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
         l_instance_dest_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_dest_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
         l_instance_dest_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         l_instance_dest_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_dest_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_dest_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
         l_instance_dest_query_rec.serial_number                   :=  NULL;
         l_instance_dest_query_rec.instance_usage_code             :=  l_in_inventory;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Get Item Instance');
         END IF;

         csi_item_instance_pub.get_item_instances(l_api_version,
                                                  l_commit,
                                                  l_init_msg_list,
                                                  l_validation_level,
                                                  l_instance_dest_query_rec,
                                                  l_party_query_rec,
                                                  l_account_query_rec,
                                                  l_transaction_id,
                                                  l_resolve_id_columns,
                                                  l_inactive_instance_only,
                                                  l_dest_instance_header_tbl,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Get Item Instance');
         END IF;
         l_tbl_count := 0;
         l_tbl_count := l_dest_instance_header_tbl.count;
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Destination Records Found: '||l_tbl_count);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status = l_fnd_success then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
           END IF;
           l_msg_index := 1;
             WHILE l_msg_count > 0 loop
	       l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	       l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	     END LOOP;
	     RAISE fnd_api.g_exc_error;
         END IF;

         IF l_dest_instance_header_tbl.count = 0 THEN

           csi_t_gen_utility_pvt.add('No Records existed so we will create a new one in Inventory that is Non Serialized');

           l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
           l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
           l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
           l_new_dest_instance_rec.serial_number                :=  NULL;
           l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
           l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_new_dest_instance_rec.instance_usage_code          :=  l_in_inventory;
           l_new_dest_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_dest_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
           l_new_dest_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
           l_new_dest_instance_rec.customer_view_flag           :=  'N';
           l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
           l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
           l_new_dest_instance_rec.active_end_date              :=  NULL;
           l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
           l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;

           l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Create Item Instance');
           END IF;

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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Update Item Instance');
            csi_t_gen_utility_pvt.add('Item Instance Created: '||l_new_dest_instance_rec.instance_id);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
           END IF;
           l_msg_index := 1;
             WHILE l_msg_count > 0 loop
               l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	       l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
             END LOOP;
	     RAISE fnd_api.g_exc_error;
         END IF;

         ELSIF l_dest_instance_header_tbl.count = 1 THEN

             csi_t_gen_utility_pvt.add('Records existed so we will update the existing Instance: '||l_dest_instance_header_tbl(i).instance_id);

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_dest_instance_header_tbl(i).instance_id;
             l_update_instance_rec.quantity                     :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
             l_update_instance_rec.active_end_date              :=  NULL;
             l_update_instance_rec.object_version_number        :=  l_dest_instance_header_tbl(i).object_version_number;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Update Item Instance');
             END IF;

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

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('After Update Item Instance');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the
             -- error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
               END IF;
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
         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base so error-90');
         END IF;
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         RAISE fnd_api.g_exc_error;

         END IF;    -- End of Destination Record If for checking for In Inventory Records because the Project/Source Instance was not there.

-- Bug 4378656 - If the instance is not there then we still need to create one that is In Inventory.
--         IF (l_debug > 0) THEN
--           csi_t_gen_utility_pvt.add('No Records were found in Install Base');
--         END IF;
--         fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
--         fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
--         fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
--         fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
--         l_error_message := fnd_message.get;
--         RAISE fnd_api.g_exc_error;

       ELSIF l_src_instance_header_tbl.count > 1 THEN
       -- Multiple Instances were found so throw error
         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Multiple Instances were Found in InstallBase-75');
         END IF;
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         RAISE fnd_api.g_exc_error;

       END IF;        -- End of No Records Found If
       END IF;        -- End of Serial Number If
     END LOOP;        -- End of For Loop

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('*****End of csi_inv_trxs_pkg.misc_receipt_projtask Transaction procedure*****');
     END IF;

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered a "fnd_api.g_exc_error" exception');
       END IF;
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
       x_trx_error_rec.source_type          := 'CSIMSRPT';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('MISC_RECEIPT_FROM_PROJECT','INV');
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered a "others" exception');
       END IF;
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
       x_trx_error_rec.source_type          := 'CSIMSRPT';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('MISC_RECEIPT_FROM_PROJECT','INV');
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END misc_receipt_projtask;

   PROCEDURE misc_issue_projtask(p_transaction_id     IN  NUMBER,
                                 p_message_id         IN  NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl                CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                    VARCHAR2(100)   := 'CSI_INV_PROJECT_PKG.MISC_ISSUE_PROJTASK';
   l_api_version                 NUMBER          := 1.0;
   l_commit                      VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list               VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level            NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only        VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only      VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id              NUMBER          := NULL;
   l_resolve_id_columns          VARCHAR2(10)    := FND_API.G_FALSE;
   l_object_version_number       NUMBER          := 1;
   l_sysdate                     DATE            := SYSDATE;
   l_master_organization_id      NUMBER;
   l_depreciable                 VARCHAR2(1);
   l_instance_query_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_dest_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_source_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec            CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                     CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status               VARCHAR2(1);
   l_error_code                  VARCHAR2(50);
   l_error_message               VARCHAR2(4000);
   l_instance_id_lst             CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec             CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec           CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_src_instance_header_tbl     CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_dest_instance_header_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
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
   l_in_service                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed                   VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_transaction_error_id        NUMBER;
   l_quantity                    NUMBER;
   l_mfg_serial_flag             VARCHAR2(1);
   l_trans_status_code           VARCHAR2(15);
   l_ins_number                  VARCHAR2(100);
   l_ins_id                      NUMBER;
   l_file                        VARCHAR2(500);
   l_trx_type_id                 NUMBER;
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_msg_index                   NUMBER;
   l_employee_id                 NUMBER;
   j                             PLS_INTEGER;
   i                             PLS_INTEGER := 1;
   l_tbl_count                   NUMBER := 0;
   l_neg_code                    NUMBER := 0;
   l_instance_status             VARCHAR2(1);
   l_redeploy_flag               VARCHAR2(1);
   l_upd_error_instance_id       NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   BEGIN

     x_return_status := l_fnd_success;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('*****Start of csi_inv_trxs_pkg.misc_issue_projtask Transaction procedure*****');
        csi_t_gen_utility_pvt.add('Transaction You are Processing is: '||p_transaction_id);
     END IF;

     -- This procedure queries all of the Inventory Transaction Records and returns them
     -- as a table.
     csi_inv_trxs_pkg.get_transaction_recs(p_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;
     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Inventory Records Found: '||l_tbl_count);
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||p_transaction_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id
     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
       END IF;
     END IF;
     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('The Employee that is processing this Transaction is: '||l_employee_id);
     END IF;

     -- See if this is a depreciable Item to set the status of the transaction record
     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                            l_depreciable);

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);
     END IF;


     -- Set the mfg_serial_number_flag and quantity
     IF l_mtl_item_tbl(i).serial_number is NULL THEN
       l_mfg_serial_flag := 'N';
       l_quantity        := l_mtl_item_tbl(i).transaction_quantity;
     ELSE
       l_mfg_serial_flag := 'Y';
       l_quantity        := 1;
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

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);
     END IF;

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
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Redeploy Flag: '||l_redeploy_flag);
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.get_redeploy_flag: '||l_error_message);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Redeploy Flag: '||l_redeploy_flag);
        csi_t_gen_utility_pvt.add('Trans Status Code: '||l_txn_rec.transaction_status_code);
     END IF;

    -- Get Default Status ID
    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

     -- Create CSI Transaction to be used
     l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
     l_txn_rec.transaction_date         := l_sysdate;
     l_txn_rec.transaction_type_id      :=  csi_inv_trxs_pkg.get_txn_type_id('MISC_ISSUE_TO_PROJECT','INV');
     l_txn_rec.transaction_quantity     := l_mtl_item_tbl(i).transaction_quantity;
     l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
     l_txn_rec.transacted_by            :=  l_employee_id;
     l_txn_rec.transaction_action_code  :=  NULL;
     l_txn_rec.message_id               :=  p_message_id;
     l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
     l_txn_rec.object_version_number    :=  l_object_version_number;

     csi_inv_trxs_pkg.create_csi_txn(l_txn_rec,
                                     l_error_message,
                                     l_return_status);

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('CSI Transaction Created: '||l_txn_rec.transaction_id);
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered an error in csi_inv_trxs_pkg.create_csi_txn: '||p_transaction_id);
       END IF;
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Starting to loop through Material Transaction Records');
     END IF;

     FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
          csi_t_gen_utility_pvt.add('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
          csi_t_gen_utility_pvt.add('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
          csi_t_gen_utility_pvt.add('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
       END IF;

       l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
       l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
       l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
       l_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
       l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
       l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
       l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
       l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
       l_instance_query_rec.instance_usage_code             :=  l_in_inventory;

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Before Get Item Instance');
       END IF;

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

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('After Get Item Instance');
       END IF;
       l_tbl_count := 0;
       l_tbl_count :=  l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
       END IF;

       -- Check for any errors and add them to the message stack to pass out to be put into the
       -- error log table.
       IF NOT l_return_status = l_fnd_success then
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
         END IF;
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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('No records were found so create a new Source Instance Record');
         END IF;

         l_new_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
         l_new_src_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
         l_new_src_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
         l_new_src_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
         l_new_src_instance_rec.mfg_serial_number_flag       :=  'N';
         l_new_src_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
         l_new_src_instance_rec.quantity                     :=  l_mtl_item_tbl(j).transaction_quantity;
         l_new_src_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
         l_new_src_instance_rec.instance_usage_code          :=  l_in_inventory;
         l_new_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_new_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
         l_new_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
         l_new_src_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_src_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
         l_new_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
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

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Create Transaction - Neg Qty');
         END IF;

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

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Create Transaction');
              csi_t_gen_utility_pvt.add('New instance created is: '||l_new_src_instance_rec.instance_id);
           END IF;

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
             END IF;
             l_msg_index := 1;
	          WHILE l_msg_count > 0 loop
	            l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	            l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	          END LOOP;
	        RAISE fnd_api.g_exc_error;
           END IF;

       ELSE  -- No Records were found and Neg Qtys Not Allowed
         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('No Records were found in Install Base andNeg Qtys not allowed to error');
         END IF;
         fnd_message.set_name('CSI','CSI_NO_NEG_BAL_ALLOWED');
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

       END IF;  -- Neg Qty If

       ELSIF l_src_instance_header_tbl.count = 1 THEN
        -- Records found so make sure that is is updated to be unexp
        -- and subtract the quantity from source record

	    IF (l_debug > 0) THEN
   	      csi_t_gen_utility_pvt.add('You will update instance: '||l_src_instance_header_tbl(i).instance_id);
   	      csi_t_gen_utility_pvt.add('End Date is: '||l_src_instance_header_tbl(i).active_end_date);
	    END IF;

         l_update_source_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_update_source_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
         l_update_source_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
         l_update_source_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

         l_party_tbl.delete;
         l_account_tbl.delete;
         l_pricing_attrib_tbl.delete;
         l_org_assignments_tbl.delete;
         l_asset_assignment_tbl.delete;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Before Update Item Instance - Neg Qty');
         END IF;

         l_update_source_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_source_instance_rec.instance_status_id);
         END IF;

         csi_item_instance_pub.update_item_instance(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_update_source_instance_rec,
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
         l_upd_error_instance_id := l_update_source_instance_rec.instance_id;

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('After Update Item Instance - Neg Qty');
            csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
         END IF;

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
           END IF;
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
         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-30');
         END IF;
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         RAISE fnd_api.g_exc_error;

       END IF; -- End of Source Record If

           -- Now query and get the destination record.
           l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.pa_project_id                   :=  l_mtl_item_tbl(j).source_project_id;
           l_instance_query_rec.pa_project_task_id              :=  l_mtl_item_tbl(j).source_task_id;
           l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
           l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.serial_number                   :=  NULL;
           l_instance_query_rec.instance_usage_code             :=  l_in_process;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Get Item Instance Dest - 100');
           END IF;

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

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Get Item Instance Dest - Neg Qty');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Destination Records Found: '||l_tbl_count);
           END IF;

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
           IF NOT l_return_status = l_fnd_success then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             END IF;
             l_msg_index := 1;
              WHILE l_msg_count > 0 loop
	        l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	        l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
  	      END LOOP;
	      RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count = 0 THEN -- Installed Base Destination Records are not found
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('No Destination Records were found so we will create a new destination Record using the source data');
             END IF;

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.instance_usage_code          :=  l_in_process;
             l_new_dest_instance_rec.inv_locator_id               :=  NULL;
             l_new_dest_instance_rec.location_id                  :=  csi_inv_trxs_pkg.get_dflt_project_location_id;
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Project');
             l_new_dest_instance_rec.inv_organization_id          :=  NULL;
             l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_new_dest_instance_rec.pa_project_id                :=  l_mtl_item_tbl(j).source_project_id;
             l_new_dest_instance_rec.pa_project_task_id           :=  l_mtl_item_tbl(j).source_task_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Create Item Instance - Neg Qty');
             END IF;

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

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('After Create Item Instance - Neg Qty');
                csi_t_gen_utility_pvt.add('Item Instance Created: '||l_new_dest_instance_rec.instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the
             -- error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               END IF;
               l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
                   l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN
               -- Installed Base Destination Records Found

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You will update instance: '||l_dest_instance_header_tbl(i).instance_id);
               END IF;

               l_update_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id                  :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                     :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date              :=  NULL;
               l_update_dest_instance_rec.object_version_number        :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Transaction - 101');
               END IF;

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

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('After Update Transaction - 102');
                 csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
               END IF;

               -- Check for any errors and add them to the message stack to pass out to be put into the
               -- error log table.
               IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
                 IF (l_debug > 0) THEN
                    csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
                 END IF;
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
             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-60');
             END IF;
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             RAISE fnd_api.g_exc_error;

    END IF;    -- End of Destination Record If

       ELSIF l_mtl_item_tbl(j).serial_number is NOT NULL THEN
       IF l_src_instance_header_tbl.count = 1 THEN  -- Installed Base Records Found
           l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.lot_number                   :=  l_src_instance_header_tbl(i).lot_number;
           l_update_instance_rec.inv_subinventory_name        :=  NULL;
	   -- Added fro bug 5975739
	   l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_update_instance_rec.inv_organization_id          :=  NULL;
           l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.inv_locator_id               :=  NULL;
           l_update_instance_rec.location_id                  :=  csi_inv_trxs_pkg.get_dflt_project_location_id;
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Project');
           l_update_instance_rec.pa_project_id                :=  l_mtl_item_tbl(j).source_project_id;
           l_update_instance_rec.pa_project_task_id           :=  l_mtl_item_tbl(j).source_task_id;
           l_update_instance_rec.instance_usage_code          :=  l_in_process;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Update Item Instance - 103');
           END IF;

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

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Update Item Instance - 104');
              csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
           END IF;

           -- Check for any errors and add them to the message stack to pass out to be put into the
           -- error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             END IF;
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
             END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

         ELSIF l_src_instance_header_tbl.count = 0 THEN
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('No Records were found in Install Base');
           END IF;
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

         ELSIF l_src_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Multiple Instances were Found in InstallBase-65');
           END IF;
           fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
           fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
           RAISE fnd_api.g_exc_error;
       END IF;        -- End of Source Record IF for Serialized
       END IF;        -- End of Serial Number If
     END LOOP;        -- End of For Loop

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('*****End of csi_inv_trxs_pkg.misc_issue_projtask Transaction procedure*****');
     END IF;

    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('You have encountered a "fnd_api.g_exc_error" exception');
        END IF;
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
        x_trx_error_rec.source_type          := 'CSIMSIPT';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('MISC_ISSUE_TO_PROJECT','INV');
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

      WHEN others THEN
        IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('You have encountered a "others" exception');
        END IF;
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
        x_trx_error_rec.source_type          := 'CSIMSIPT';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id('MISC_ISSUE_TO_PROJECT','INV');
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END misc_issue_projtask;
END csi_inv_project_pkg;

/
