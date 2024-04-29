--------------------------------------------------------
--  DDL for Package Body CSI_INV_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_TRANSFER_PKG" as
-- $Header: csiivttb.pls 120.4 2006/06/06 19:26:34 jpwilson noship $

   PROCEDURE debug(p_message IN varchar2) IS

   BEGIN
      csi_t_gen_utility_pvt.add(p_message);
   EXCEPTION
     WHEN others THEN
       null;
   END debug;

   PROCEDURE subinv_transfer(p_transaction_id     IN  NUMBER,
                             p_message_id         IN  NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl                CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                    VARCHAR2(100)   := 'CSI_INV_TRANSFER_PKG.SUBINV_TRANSFER';
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
   l_instance_query_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_dest_instance_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_src_instance_rec     CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_instance_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_upd_src_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_dest_instance_query_rec     CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_new_instance_rec            CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_api_dest_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_api_src_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
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
   l_transaction_error_id        NUMBER;
   l_quantity                    NUMBER;
   l_mfg_serial_number_flag      VARCHAR2(1);
   l_trans_status_code           VARCHAR2(15);
   l_ins_number                  VARCHAR2(100);
   l_employee_id                 NUMBER;
   l_ins_id                      NUMBER;
   l_file                        VARCHAR2(500);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_sql_error                   VARCHAR2(2000);
   l_msg_index                   NUMBER;
   j                             PLS_INTEGER := 1;
   i                             PLS_INTEGER := 1;
   l_tbl_count                   NUMBER := 0;
   l_neg_code                    NUMBER := 0;
   l_instance_status             VARCHAR2(1);
   l_trans_type_code             VARCHAR2(25);
   l_trans_app_code              VARCHAR2(5);
   l_redeploy_flag               VARCHAR2(1);
   l_upd_error_instance_id       NUMBER := NULL;

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
	 SELECT transfer_transaction_id
	 FROM mtl_material_transactions
	 WHERE transaction_id = p_transaction_id;

   r_mtl     c_mtl%rowtype;

   CURSOR c_so_info (pc_line_id in NUMBER) is
     SELECT oeh.header_id,
            oel.line_id,
            oeh.order_number,
            oel.line_number
     FROM   oe_order_headers_all oeh,
            oe_order_lines_all oel
     WHERE oeh.header_id = oel.header_id
     AND   oel.line_id = pc_line_id;

   r_so_info     c_so_info%rowtype;

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
     x_trx_error_rec.error_text := NULL;

     debug('*****Start of csi_inv_transfer_pkg.subinv_transfer Transaction *****');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiivttb.pls 115.15');
     debug('Transaction ID with is: '||p_transaction_id);

     -- This procedure queries all of the Inventory Transaction Records
     -- and returns them as a table.

	-- This will open the cursor and fetch the (-) transaction ID
     OPEN c_mtl;
     FETCH c_mtl into r_mtl;
     CLOSE c_mtl;

     debug('Transaction ID with (+) is: '||p_transaction_id);
     debug('Transaction ID with (-) is: '||r_mtl.transfer_transaction_id);

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

     debug('Master Org is: '||l_master_organization_id);

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

     -- Determine the Transaction Type
     IF l_mtl_item_tbl(i).transaction_type_id = 2 THEN
        l_trans_type_code := 'SUBINVENTORY_TRANSFER';
        l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 5  THEN
       l_trans_type_code := 'CYCLE_COUNT_TRANSFER' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 9  THEN
       l_trans_type_code := 'PHYSICAL_INV_TRANSFER' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 50  THEN
       l_trans_type_code := 'ISO_TRANSFER' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 51  THEN
       l_trans_type_code := 'BACKFLUSH_TRANSFER' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 53  THEN
       l_trans_type_code := 'ISO_PICK' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 52  THEN
       l_trans_type_code := 'SALES_ORDER_PICK' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 64  THEN
       l_trans_type_code := 'MOVE_ORDER_TRANSFER' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 66  THEN
       l_trans_type_code := 'PROJECT_BORROW' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 67  THEN
       l_trans_type_code := 'PROJECT_TRANSFER' ;
       l_trans_app_code := 'INV';
     ELSIF l_mtl_item_tbl(i).transaction_type_id = 68  THEN
       l_trans_type_code := 'PROJECT_PAYBACK' ;
       l_trans_app_code := 'INV';
     ELSE
       l_trans_type_code := 'SUBINVENTORY_TRANSFER';
       l_trans_app_code := 'INV';
     END IF;

        debug('Trans Type Code: '||l_trans_type_code);
        debug('Trans App Code: '||l_trans_app_code);

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

     -- Added so that the SO_HEADER_ID and SO_LINE_ID can be added to
     -- the transaction record.

     OPEN c_so_info (l_mtl_item_tbl(i).trx_source_line_id);
     FETCH c_so_info into r_so_info;
     CLOSE c_so_info;

     debug('Sales Order Header: '||r_so_info.header_id);
     debug('Sales Order Line: '||r_so_info.line_id);
     debug('Order Number: '||r_so_info.order_number);
     debug('Line Number: '||r_so_info.line_number);

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

     IF l_mtl_item_tbl(i).transaction_type_id in (50,52,53)  THEN
       l_txn_rec.source_header_ref_id     :=  r_so_info.header_id;
       l_txn_rec.source_line_ref_id       :=  r_so_info.line_id;
       l_txn_rec.source_header_ref        :=  to_char(r_so_info.order_number);
       l_txn_rec.source_line_ref          :=  to_char(r_so_info.line_number);
     END IF;

     -- Move Order Transfer Info on Txn Record
     IF l_mtl_item_tbl(i).transaction_type_id = 64 THEN
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

     FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

       debug('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
       debug('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
       debug('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
       debug('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
       debug('Serial Number : '||l_mtl_item_tbl(j).serial_number);
       debug('Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
       debug('Organization ID: '||l_mtl_item_tbl(j).organization_id);
       debug('SO_HEADER_ID is: '||r_so_info.header_id);
       debug('SO_LINE_ID is: '||r_so_info.line_id);

       -- Get the Location Ids for Receiving Org
       OPEN c_loc_ids (l_mtl_item_tbl(j).transfer_organization_id,
                       l_mtl_item_tbl(j).transfer_subinventory);
       FETCH c_loc_ids into r_loc_ids;
       CLOSE c_loc_ids;

       debug('Transfer Subinv Location: '||r_loc_ids.subinv_location_id);
       debug('Transfer HR Location    : '||r_loc_ids.hr_location_id);

       IF l_mtl_item_tbl(j).transaction_type_id <> 50 THEN
         debug('This is not an ISO Transfer so process as normal - Source');
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

       ELSE
         debug('This is an ISO Transfer - Source');
         IF l_mtl_item_tbl(j).serial_number_control_code IN (1,6) THEN

           debug('This is an ISO Transfer - Serial Control 1 or 6');

           l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.serial_number                   :=  NULL;
           l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
           l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
           l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
           l_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
           l_instance_query_rec.instance_usage_code             :=  l_in_inventory;
         ELSE
           debug('This is an ISO Transfer - Serial Control 2 or 5');
           l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
         END IF;

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

       --IF l_mtl_item_tbl(j).serial_number is NULL THEN
       IF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN
         IF l_src_instance_header_tbl.count = 0 THEN
           IF l_neg_code = 1 THEN -- Allow Neg Qtys on NON Serial Items ONLY

             debug('No records were found so create a new Source Non Serialized Instance Record');

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
                 l_new_src_instance_rec.active_end_date              :=  NULL;
                 --l_new_src_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;

                 l_ext_attrib_values_tbl                             :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
                 l_party_tbl                                         :=  csi_inv_trxs_pkg.init_party_tbl;
                 l_account_tbl                                       :=  csi_inv_trxs_pkg.init_account_tbl;
                 l_pricing_attrib_tbl                                :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
                 l_org_assignments_tbl                               :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
                 l_asset_assignment_tbl                              :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

                 debug('Before Create of source Instance');

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

       END IF;  -- Neg Qty If

       ELSIF l_src_instance_header_tbl.count = 1 THEN
         -- Records found so make sure that is is updated to be unexp
         -- and subtract the quantity from source record

           debug('You will update instance: '||l_src_instance_header_tbl(i).instance_id);
           debug('End Date is: '||l_src_instance_header_tbl(i).active_end_date);

           l_update_src_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_src_instance_rec.instance_id             :=  l_src_instance_header_tbl(i).instance_id;
           l_update_src_instance_rec.quantity                :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_update_src_instance_rec.active_end_date         :=  NULL;
           --l_update_src_instance_rec.last_oe_order_line_id   :=  r_so_info.line_id;
           l_update_src_instance_rec.object_version_number   :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Source Item Instance - Neg Qty');

           l_update_src_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           debug('Instance Status Id: '||l_update_src_instance_rec.instance_status_id);

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_src_instance_rec,
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
           l_upd_error_instance_id := l_update_src_instance_rec.instance_id;

           debug('After Update Source Item Instance - Neg Qty');
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
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

         END IF;      -- End of Source Record If

           -- Now query for the destination records
         IF l_mtl_item_tbl(j).transaction_type_id <> 50 THEN
           debug('This is not an ISO Transfer so process as normal - Dest');
           csi_inv_trxs_pkg.set_item_attr_query_values(l_mtl_item_tbl,
                                                       j,
                                                       'TRANSFER',
                                                       l_dest_instance_query_rec,
                                                       x_return_status);


           IF l_mtl_item_tbl(j).serial_number IS NULL THEN -- Non Serial

             l_dest_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
             l_dest_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).transfer_subinventory;
             l_dest_instance_query_rec.instance_usage_code             :=  l_in_inventory;

           END IF;

           l_mfg_serial_number_flag := 'N';
           l_quantity := abs(l_mtl_item_tbl(j).transaction_quantity);

         ELSE
           debug('This is an ISO Transfer - Dest');
           IF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN

             debug('This is an ISO Transfer - Dest - Serial Control is: '||l_mtl_item_tbl(j).serial_number_control_code);

             l_dest_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_dest_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
             l_dest_instance_query_rec.serial_number                   :=  NULL;
             l_dest_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
             l_dest_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
             l_dest_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).transfer_locator_id;
             l_dest_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
             l_dest_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).transfer_subinventory;
             l_dest_instance_query_rec.instance_usage_code             :=  l_in_inventory;

             l_mfg_serial_number_flag := 'N';
             l_quantity := abs(l_mtl_item_tbl(j).transaction_quantity);

           --ELSE
           --  debug('This is an ISO Transfer - Dest - Serial Control 6');
           --  l_dest_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
           --  l_dest_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
           --  l_dest_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;

           --  l_mfg_serial_number_flag := 'Y';
           --  l_quantity := 1;
           END IF;
        END IF;

         csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec => l_dest_instance_query_rec);

           debug('Before Dest Get Item Instance - 31');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_dest_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance for destination records');

           l_tbl_count := 0;
           l_tbl_count := l_dest_instance_header_tbl.count;

           debug('Destination Records Found: '||l_tbl_count);

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

           IF l_dest_instance_header_tbl.count = 0 THEN -- Installed Base Destination Records are not found

             debug('No Destination Records were found so create a new one - Neg Qty If Statement');

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  l_mfg_serial_number_flag;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  l_quantity;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             --l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_dest_instance_rec.location_id                  :=  nvl(r_loc_ids.subinv_location_id,r_loc_ids.hr_location_id);
             l_new_dest_instance_rec.instance_usage_code          :=  l_in_inventory;
             l_new_dest_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).transfer_subinventory;
             l_new_dest_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).transfer_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;
             --l_new_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             debug('Before Create of Non Serialized Destination Item Instance');
             debug('Location ID value: '||l_new_instance_rec.location_id);
             debug('Subinv Location: '||l_mtl_item_tbl(j).subinv_location_id);
             debug('HR Location: '||l_mtl_item_tbl(j).hr_location_id);
             debug('Serial Number: '||l_mtl_item_tbl(j).serial_number);
             debug('Mfg Flag: '||l_mfg_serial_number_flag);

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

             debug('After Create of Non Serialized Destination Item Instance');

             -- Check for any errors and add them to the message stack to pass out to be put into the
             -- error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
	           WHILE l_msg_count > 0 loop
	             l_error_message := fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	             l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
  	           END LOOP;
	           RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN

            IF l_mtl_item_tbl(j).transaction_type_id <> 50 THEN

               -- Installed Base Destination Records Found

                 debug('You will update instance: '||l_dest_instance_header_tbl(i).instance_id);

                 l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
                 l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
                 l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
                 l_update_dest_instance_rec.active_end_date         :=  NULL;
                 --l_update_dest_instance_rec.last_oe_order_line_id   :=  r_so_info.line_id;
                 l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

             ELSE -- ISO Transfer Transaction

               --IF l_mtl_item_tbl(j).serial_number_control_code = 6 THEN
               --  debug('Serialized Source records were foundo - ISO Transfer');
               --  debug('Update the serialized item with Serial Number - ISO Transfer: '||l_src_instance_header_tbl(i).serial_number);

               --  l_update_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
               --  l_update_src_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
               --  l_update_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).transfer_subinventory;
               --  l_update_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).transfer_locator_id;
               --  l_update_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
               --  l_update_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);

               IF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN

                 debug('You will update instance - ISO Transfer: '||l_dest_instance_header_tbl(i).instance_id);
                 debug('This is an ISO Transfer - Dest - Serial Control is: '||l_mtl_item_tbl(j).serial_number_control_code);

                 l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
                 l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
                 l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
                 l_update_dest_instance_rec.active_end_date         :=  NULL;
                 --l_update_dest_instance_rec.last_oe_order_line_id   :=  r_so_info.line_id;
                 l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               END IF;

               END IF; -- Check of Transaction Type

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Before Update Item Instance - 34');
               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);

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

             debug('After Update Item Instance - Neg Qty');
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

           ELSIF l_dest_instance_header_tbl.count > 1 THEN
             -- Multiple Instances were found so throw error
             debug('Multiple Instances were Found in Install Base-80');
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If

       --ELSIF l_mtl_item_tbl(j).serial_number is NOT NULL THEN
       ELSIF l_mtl_item_tbl(j).serial_number_control_code in (2,5) THEN
         -- Serialized Item
         IF l_src_instance_header_tbl.count = 1 THEN
         -- Update Source Record then Continue

           debug('Serialized Source records were found');
           debug('Update the serialized item with Serial Number: '||l_src_instance_header_tbl(i).serial_number);

           l_update_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_update_src_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).transfer_subinventory;
           l_update_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).transfer_locator_id;
           l_update_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           --l_update_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_update_src_instance_rec.location_id                  :=  nvl(r_loc_ids.subinv_location_id,r_loc_ids.hr_location_id);
           --l_update_src_instance_rec.last_oe_order_line_id       :=  r_so_info.line_id;
           l_update_src_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

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
                                                      l_update_src_instance_rec,
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
           l_upd_error_instance_id := l_update_src_instance_rec.instance_id;

           debug('After Update of Serialized Item Instance');
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

         ELSIF l_src_instance_header_tbl.count = 0 THEN
           debug('No Records were found in Install Base');
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

         ELSIF l_src_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
           debug('Multiple Instances were Found in Install Base-40');
           fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
           fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;
       END IF;        -- End of Source Record IF for Serialized

       END IF;        -- End of Serial Number If
     END LOOP;        -- End of For Loop

     debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('*****End of csi_inv_transfer_pkg.subinv_transfer Transaction*****');

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

       x_trx_error_rec.error_text           := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSISUBTR';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
       l_sql_error := SQLERRM;
       debug('SQL Error: '||l_sql_error);
       debug('You have encountered a "others" exception');
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
       x_trx_error_rec.source_type          := 'CSISUBTR';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END subinv_transfer;

END csi_inv_transfer_pkg;

/
