--------------------------------------------------------
--  DDL for Package Body CSI_INV_ISO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_ISO_PKG" as
-- $Header: csiintsb.pls 120.6.12000000.4 2007/07/06 15:33:23 ngoutam ship $

l_debug NUMBER := csi_t_gen_utility_pvt.g_debug_level;

   PROCEDURE iso_shipment(p_transaction_id     IN  NUMBER,
                          p_message_id         IN  NUMBER,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl               CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                   VARCHAR2(100)   := 'CSI_INV_TRXS_PKG.ISO_SHIPMENT';
   l_api_version                NUMBER          := 1.0;
   l_commit                     VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list              VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only       VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only     VARCHAR2(10)    := FND_API.G_FALSE;
   l_expire_children            VARCHAR2(1)     := FND_API.G_FALSE;
   l_transaction_id             NUMBER          := NULL;
   l_resolve_id_columns         VARCHAR2(10)    := FND_API.G_FALSE;
   l_object_version_number      NUMBER          := 1;
   l_sysdate                    DATE            := SYSDATE;
   l_master_organization_id     NUMBER;
   l_depreciable                VARCHAR2(1);
   l_instance_query_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_dest_instance_query_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_upd_src_dest_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec           CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec      CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_expire_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                    CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_exp_txn_rec                CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
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
   l_trans_type_code            VARCHAR2(25);
   l_trans_app_code             VARCHAR2(5);
   l_employee_id                NUMBER;
   l_file                       VARCHAR2(500);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_sql_error                  VARCHAR2(2000);
   l_msg_index                  NUMBER;
   j                            PLS_INTEGER := 1;
   i                            PLS_INTEGER := 1;
   l_tbl_count                  NUMBER := 0;
   l_neg_code                   NUMBER := 0;
   l_instance_status            VARCHAR2(1);
   l_sr_control                 NUMBER;
   l_mfg_flag                   VARCHAR2(1)  := NULL;
   l_serial_number              VARCHAR2(30) := NULL;
   l_trans_quantity             NUMBER := 0;
   l_quantity                   NUMBER := 0;
   l_redeploy_flag              VARCHAR2(1);
   l_upd_error_instance_id      NUMBER := NULL;
   l_receipt_action_flag        VARCHAR2(1) := NULL;
   l_curr_object_vers_61_id     NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   cursor c_inst (pc_instance_id in NUMBER) is
     SELECT instance_usage_code
     FROM   csi_item_instances
     WHERE  instance_id = pc_instance_id;

   r_inst   c_inst%rowtype;

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

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('******Start of csi_inv_iso_pkg.iso_shipment Transaction procedure******');
           csi_t_gen_utility_pvt.add('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           csi_t_gen_utility_pvt.add('csiintsb.pls 115.27');
     END IF;

     IF (l_debug > 0) THEN
       csi_t_gen_utility_pvt.add('Transaction ID with is: '||p_transaction_id);
       csi_t_gen_utility_pvt.add('l_sysdate set to: '||to_char(l_sysdate,'DD-MON-YYYY HH24:MI:SS'));
     END IF;

     -- This procedure queries all of the Inventory Transaction Records and
     -- returns them as a table.

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

     IF (l_debug > 0) THEN
      	  csi_t_gen_utility_pvt.add('Transaction Action ID: '||l_mtl_item_tbl(i).transaction_action_id);
      	  csi_t_gen_utility_pvt.add('Transaction Source Type ID: '||l_mtl_item_tbl(i).transaction_source_type_id);
      	  csi_t_gen_utility_pvt.add('Transaction Quantity: '||l_mtl_item_tbl(i).transaction_quantity);
     END IF;

     -- Get the Master Organization ID
     CSI_INV_TRXS_PKG.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                              l_master_organization_id,
                                              l_return_status,
                                              l_error_message);

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Master Org ID: '||l_master_organization_id);
     END IF;

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

	-- Get the Negative Receipt Code to see if this org allows Negative
	-- Quantity Records 1 = Yes, 2 = No

	l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(
                                        l_mtl_item_tbl(i).organization_id);

     IF l_neg_code = 1 AND l_mtl_item_tbl(i).serial_number_control_code in (1,6) THEN
	 l_instance_status := FND_API.G_FALSE;
     ELSE
	 l_instance_status := FND_API.G_TRUE;
     END IF;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);
     END IF;

     -- Determine Transaction Type for this

     l_trans_type_code := 'ISO_SHIPMENT';
     l_trans_app_code := 'INV';

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Trans Type Code: '||l_trans_type_code);
           csi_t_gen_utility_pvt.add('Trans App Code: '||l_trans_app_code);
     END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

     -- Added so that the SO_HEADER_ID and SO_LINE_ID can be added to
     -- the transaction record.

     OPEN c_so_info (l_mtl_item_tbl(j).trx_source_line_id);
     FETCH c_so_info into r_so_info;
     CLOSE c_so_info;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Sales Order Header: '||r_so_info.header_id);
           csi_t_gen_utility_pvt.add('Sales Order Line: '||r_so_info.line_id);
           csi_t_gen_utility_pvt.add('Order Number: '||r_so_info.order_number);
           csi_t_gen_utility_pvt.add('Line Number: '||r_so_info.line_number);
     END IF;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Starting to loop through Material Transaction Records');
     END IF;

    -- Get Default Profile Instance Status

    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

    IF (l_debug > 0) THEN
      csi_t_gen_utility_pvt.add('Default Profile Status: '||r_id.instance_status_id);
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
     l_txn_rec.source_header_ref_id     :=  r_so_info.header_id;
     l_txn_rec.source_line_ref_id       :=  r_so_info.line_id;
     l_txn_rec.source_header_ref        :=  to_char(r_so_info.order_number);
     l_txn_rec.source_line_ref          :=  substr(to_char(r_so_info.line_number)||'.'||l_mtl_item_tbl(i).shipment_number,1,50);

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

     -- Get Receiving Organization Item Master Control Codes
     OPEN c_item_control (l_mtl_item_tbl(j).inventory_item_id,
                          l_mtl_item_tbl(j).transfer_organization_id);
     FETCH c_item_control into r_item_control;
     CLOSE c_item_control;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Serial Number : '||l_mtl_item_tbl(j).serial_number);
        csi_t_gen_utility_pvt.add('Shipping Org Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Serial Number Control Code: '||r_item_control.serial_number_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Lot Control Code: '||l_mtl_item_tbl(j).lot_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Lot Control Code: '||r_item_control.lot_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Loction Control Code: '||l_mtl_item_tbl(j).location_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Location Control Code: '||r_item_control.location_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Revision Control Code: '||l_mtl_item_tbl(j).revision_qty_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Revision Control Code: '||r_item_control.revision_qty_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Trackable Flag: '||r_item_control.comms_nl_trackable_flag);
       csi_t_gen_utility_pvt.add('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
       csi_t_gen_utility_pvt.add('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
       csi_t_gen_utility_pvt.add('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
       csi_t_gen_utility_pvt.add('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
       csi_t_gen_utility_pvt.add('Organization ID: '||l_mtl_item_tbl(j).organization_id);
       csi_t_gen_utility_pvt.add('Transfer Org ID: '||l_mtl_item_tbl(j).transfer_organization_id);
     END IF;

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

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Set Serial Number to NULL since the shipping org is 1 or 6 and we are looking for a NON serial In Inventory Instance');
         END IF;

       ELSIF l_mtl_item_tbl(j).serial_number_control_code in (2,5) THEN
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
       l_sub_inventory   :=  NULL;
       l_trx_action_type := 'IN_TRANSIT_SHIPMENT';
       l_instance_usage_code := l_instance_query_rec.instance_usage_code;

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Set Serial Number to what is passed in since the shipping org is 2,5 and we are looking for a serialized instance In Inventory Instance');
         END IF;

       END IF;

       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Transaction Action Type:'|| l_trx_action_type);
             csi_t_gen_utility_pvt.add('Before Get Item Instance-1 ');
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
             csi_t_gen_utility_pvt.add('After Get Item Instance-2');
       END IF;

       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Before checking to see if Source records Exist');
       END IF;

       IF l_mtl_item_tbl(j).serial_number_control_code in (2,5) THEN
          IF l_src_instance_header_tbl.count > 0 THEN
            IF r_item_control.serial_number_control_code <> 1 THEN -- Do Regular Processing move to In Transit

          IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Updating Serial Number: '||l_mtl_item_tbl(j).serial_number);
          END IF;

          l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
          l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
          l_update_instance_rec.inv_subinventory_name        :=  NULL;
          l_update_instance_rec.inv_locator_id               :=  NULL;
	  -- Added for Bug 5975739
	  l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
          l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
          l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
          l_update_instance_rec.in_transit_order_line_id    :=  r_so_info.line_id;
          l_update_instance_rec.instance_usage_code          :=  l_in_transit;
          l_update_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
          l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('After you initialize the Transaction Record Values');
           END IF;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Update Item Instance-3');
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
             csi_t_gen_utility_pvt.add('After Update Item Instance-4');
             csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
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

           ELSE -- Serial Control is 1 ( No Control ) so set to Out Of Enterprise

            IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Updating Serial Number: '||l_mtl_item_tbl(j).serial_number);
                 csi_t_gen_utility_pvt.add('Setting to OUT OF ENTERPRISE');
            END IF;

            l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
            l_update_instance_rec.inv_subinventory_name        :=  NULL;
            l_update_instance_rec.inv_locator_id               :=  NULL;
            -- Added for Bug 5975739
	    l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
	    l_update_instance_rec.inv_organization_id          :=  NULL;
            l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
            -- Bug 5253131
            l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('INTERNAL_SITE');
            l_update_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
            l_update_instance_rec.active_end_date              :=  l_sysdate;
            l_update_instance_rec.instance_usage_code          :=  l_out_of_enterprise;
            l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('After you initialize the Transaction Record Values');
                   csi_t_gen_utility_pvt.add(l_update_instance_rec.location_id);
                   csi_t_gen_utility_pvt.add(l_update_instance_rec.location_type_code);
             END IF;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Before Update Item Instance-3');
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
               csi_t_gen_utility_pvt.add('After Update Item Instance-4');
               csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
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

         IF j = 1 THEN -- Look for IN Transit Non Serial If not there create or Update only 1 time
           l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.serial_number                 :=  NULL;
           l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
           l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.in_transit_order_line_id      :=  r_so_info.line_id;
           l_instance_query_rec.instance_usage_code           :=  l_in_transit;

           l_instance_usage_code                              :=  l_in_transit;
           l_subinventory_name                                :=  NULL;
           l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
           l_locator_id                                       :=  NULL;

           l_mfg_flag := NULL;
           l_serial_number := NULL;
           l_quantity := abs(l_mtl_item_tbl(j).transaction_quantity);

            IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Since the Shipping Code is 2 or 5 and the Receiving is 1 Look for Non Serial In Transit');
                 csi_t_gen_utility_pvt.dump_instance_query_rec(l_instance_query_rec);
           END IF;

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Before Get Item Instance for Dest Non Serialized Instance-5');
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
                 csi_t_gen_utility_pvt.add('After Get Item Instance-6');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count < 1 THEN  -- Installed Base Destination Records are not found so create a new record

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Creating New Dest dest Instance-7');
             END IF;

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  l_mfg_flag;
             l_new_dest_instance_rec.serial_number                :=  l_serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  l_quantity;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
             l_new_dest_instance_rec.in_transit_order_line_id     :=  r_so_info.line_id;
             l_new_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             --l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
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

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Before Create Item Instance-8');
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-9');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Usage Code: '||l_dest_instance_header_tbl(i).instance_usage_code);
               csi_t_gen_utility_pvt.add('Item ID: '||l_dest_instance_header_tbl(i).inventory_item_id);
               csi_t_gen_utility_pvt.add('Instance ID: '||l_dest_instance_header_tbl(i).instance_id);
             END IF;

            l_update_dest_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_dest_instance_rec.instance_id              :=  l_dest_instance_header_tbl(i).instance_id;
            l_update_dest_instance_rec.quantity                 :=  l_dest_instance_header_tbl(i).quantity + l_quantity;
            l_update_dest_instance_rec.location_type_code       :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
            l_update_dest_instance_rec.in_transit_order_line_id :=  r_so_info.line_id;
	    -- Added for Bug 5975739
	    l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
            l_update_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
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

               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('Before Update Item Instance-10');
                     csi_t_gen_utility_pvt.add('Instance Status-11: '||l_update_dest_instance_rec.instance_status_id);

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
               csi_t_gen_utility_pvt.add('After Update Item Instance-12');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSE -- Error No dest non serial recs round
            IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('No Records were found in Install Base but the usage is not correct-14, The Usage is: '||l_dest_instance_header_tbl(i).instance_usage_code);
            END IF;
            fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
            fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;
          END IF;    -- End of Destination Record If

         END IF; -- End of j=1 for Control Code 1
       END IF; -- serial control <> 1

       ELSE -- No Serialized Instances found so Error.
         IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('No Records were found in Install Base-13');
         END IF;

         fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
         fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

       END IF; -- SRC Table Count

       ELSIF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN

         IF l_mtl_item_tbl(j).serial_number_control_code = 6 AND
            r_item_control.serial_number_control_code = 1 THEN -- Set Flag serial Numbers need to be Out of Enterprise
           l_receipt_action_flag := 'Y';
         ELSE
           l_receipt_action_flag := 'N';
         END IF;

	 IF j = 1 THEN

         IF l_src_instance_header_tbl.count = 0 THEN
         IF l_neg_code = 1 THEN -- Negative Records Allowed so Create/Update

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('No Source records were found and Neg Code is 1 so create a new Source Instance Record');
           END IF;

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
           l_new_src_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;

           l_ext_attrib_values_tbl                             :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl                                         :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl                                       :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl                                :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl                               :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl                              :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Create Source Item Instance-14');
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
                   csi_t_gen_utility_pvt.add('After Create Source Item Instance-15');
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

         ELSE -- Inv Does not allowe neg qty and source is not found
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('No Records were found in Install Base-16');
           END IF;
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

       END IF; -- End of Neg Qty IF
    ELSIF l_src_instance_header_tbl.count = 1 THEN -- Source Records are found

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('1 Source Record Found so we will update it.');
           csi_t_gen_utility_pvt.add('You will update instance: '||l_src_instance_header_tbl(i).instance_id);
                 csi_t_gen_utility_pvt.add('End Date is: '||l_src_instance_header_tbl(i).active_end_date);
         END IF;

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.active_end_date        :=  NULL;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Update Source Item Instance-17');
           END IF;

           l_upd_src_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Instance Status Id: '||l_upd_src_dest_instance_rec.instance_status_id);
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
             csi_t_gen_utility_pvt.add('After Update Item Instance-18');
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
        csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install BaseBase-19');
      END IF;
      fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
      fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
      fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
      fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
      fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
      l_error_message := fnd_message.get;
      RAISE fnd_api.g_exc_error;
    END IF;  -- End of If for Main Source
  END IF;  -- End of J If

	   -- Get Destination Records
	   -- We will query for serialized In Transit Instances
-- JUNE22
-- Changed query fields for serial control = 1

         IF l_mtl_item_tbl(j).serial_number_control_code = 1 THEN
           l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.serial_number                 :=  NULL;
           l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
           l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
           l_instance_query_rec.location_type_code            :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
           l_instance_query_rec.instance_usage_code           :=  l_in_transit;
           l_instance_query_rec.in_transit_order_line_id      :=  r_so_info.line_id;

           l_instance_usage_code                              :=  l_in_transit;
           l_subinventory_name                                :=  NULL;
           l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
           l_locator_id                                       :=  NULL;

            l_mfg_flag := NULL;
            l_serial_number := NULL;
            l_quantity := abs(l_mtl_item_tbl(j).transaction_quantity);

            IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Ship Serial Code is 1 so we want to query for Non Serialized, Setting Serial Number to NULL for Dest Query for In Transit');
                 csi_t_gen_utility_pvt.add('Serial Number: '||l_mtl_item_tbl(j).serial_number);
           END IF;

         ELSIF l_mtl_item_tbl(j).serial_number_control_code = 6 THEN

           l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.serial_number                 :=  l_mtl_item_tbl(j).serial_number;
           l_instance_usage_code                              :=  l_in_transit;
           l_subinventory_name                                :=  NULL;
           l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
           l_locator_id                                       :=  NULL;

           l_mfg_flag := 'Y';
           l_serial_number := l_mtl_item_tbl(j).serial_number;
           l_quantity := 1;
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Ship Serial Code is 6 so we want to query for Serialized, Setting Serial Number to Trans Serial Number for Dest Query');
             csi_t_gen_utility_pvt.add('Setting l_mfg_flag to Y and l_serial_number to serial_number since we will create non serialized records');
             csi_t_gen_utility_pvt.add('Serial Number: '||l_mtl_item_tbl(j).serial_number);
           END IF;

         END IF;

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Before Get Item Instance for Dest Serialized Instance-20');
           csi_t_gen_utility_pvt.add('Serial Number: '||l_mtl_item_tbl(j).serial_number);
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
                 csi_t_gen_utility_pvt.add('After Get Item Instance-21');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_receipt_action_flag = 'N' THEN -- Do regular processing to In Transit
             IF l_dest_instance_header_tbl.count < 1 THEN  -- Installed Base Destination Records are not found so create a new record


             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Creating New Dest dest Instance-22');
             END IF;

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  l_mfg_flag;
             l_new_dest_instance_rec.serial_number                :=  l_serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  l_quantity;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_type_code           := csi_inv_trxs_pkg.get_location_type_code('In_Transit');
             l_new_dest_instance_rec.in_transit_order_line_id     := r_so_info.line_id;
             l_new_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;
             --Added the below code for bug 5897127 Base Bug 5758860--
	     l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Before Create Item Instance-23');
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-24');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Usage Code: '||l_dest_instance_header_tbl(i).instance_usage_code);
               csi_t_gen_utility_pvt.add('Item ID: '||l_dest_instance_header_tbl(i).inventory_item_id);
               csi_t_gen_utility_pvt.add('Instance ID: '||l_dest_instance_header_tbl(i).instance_id);
             END IF;

             IF l_dest_instance_header_tbl(i).instance_usage_code IN (l_in_transit,l_returned) THEN
                -- Update Non Serialized / Serialized Item


         l_trans_quantity := 0;

         IF l_mtl_item_tbl(j).serial_number_control_code = 1 THEN

            l_trans_quantity := l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);

            IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Setting Trans Qty: '||l_trans_quantity);
           END IF;
         ELSIF l_mtl_item_tbl(j).serial_number_control_code = 6 THEN
            l_trans_quantity := 1;
            IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Setting Trans Qty: '||l_trans_quantity);
           END IF;
         END IF;

            l_update_dest_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_dest_instance_rec.instance_id              :=  l_dest_instance_header_tbl(i).instance_id;
            l_update_dest_instance_rec.quantity                 :=  l_trans_quantity;
            l_update_dest_instance_rec.location_type_code       :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
            l_update_dest_instance_rec.in_transit_order_line_id :=  r_so_info.line_id;
            -- Added for Bug 5975739
	    l_update_dest_instance_rec.inv_master_organization_id :=  l_master_organization_id;
	    l_update_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
            l_update_dest_instance_rec.inv_organization_id          :=  NULL;
            l_update_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
            l_update_dest_instance_rec.inv_locator_id               :=  l_locator_id;
            l_update_dest_instance_rec.instance_usage_code          :=  l_in_transit;
            l_update_dest_instance_rec.active_end_date            := NULL;
            l_update_dest_instance_rec.active_end_date          :=  NULL;
            l_update_dest_instance_rec.object_version_number    :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('Before Update Item Instance-25');
                     csi_t_gen_utility_pvt.add('Instance Status-26: '||l_update_dest_instance_rec.instance_status_id);

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
               csi_t_gen_utility_pvt.add('After Update Item Instance-27');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSE -- Error No Src Recs with usage of In Transit or Returned
            IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('No Records were found in Install Base but the usage is not correct-20, The Usage is: '||l_dest_instance_header_tbl(i).instance_usage_code);
            END IF;
            fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
            fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;
            END IF;  -- In Transit and Returned Usage Code Check
          END IF;    -- End of Destination Record If

          ELSIF l_receipt_action_flag = 'Y' THEN -- Set Serial Numbers to be Out Of Enterprise

          IF l_mtl_item_tbl(j).serial_number_control_code = 1 THEN

          IF l_dest_instance_header_tbl.count < 1 THEN -- Installed Base Destination Records Not Found

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Creating New Dest dest Instance-28');
             END IF;

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  NULL;
             l_new_dest_instance_rec.serial_number                :=  NULL;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
             l_new_dest_instance_rec.in_transit_order_line_id     :=  r_so_info.line_id;
             l_new_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
             l_new_dest_instance_rec.instance_usage_code          :=  l_in_transit;
             l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  NULL;
             l_new_dest_instance_rec.inv_locator_id               :=  NULL;
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

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Before Create Item Instance-29');
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-30');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Usage Code: '||l_dest_instance_header_tbl(i).instance_usage_code);
               csi_t_gen_utility_pvt.add('Item ID: '||l_dest_instance_header_tbl(i).inventory_item_id);
               csi_t_gen_utility_pvt.add('Instance ID: '||l_dest_instance_header_tbl(i).instance_id);
             END IF;

            l_update_dest_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_dest_instance_rec.instance_id              :=  l_dest_instance_header_tbl(i).instance_id;
            l_update_dest_instance_rec.quantity                 :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
            l_update_dest_instance_rec.location_type_code       :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
            l_update_dest_instance_rec.in_transit_order_line_id :=  r_so_info.line_id;
	    -- Added for Bug 5975739
	    l_update_dest_instance_rec.inv_master_organization_id :=  l_master_organization_id;
            l_update_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
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

               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('Before Update Item Instance-31');
                     csi_t_gen_utility_pvt.add('Instance Status-32: '||l_update_dest_instance_rec.instance_status_id);

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
               csi_t_gen_utility_pvt.add('After Update Item Instance-33');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;
          END IF;    -- End of Destination Record If

          ELSIF l_mtl_item_tbl(j).serial_number_control_code = 6 THEN

           IF l_dest_instance_header_tbl.count < 1 THEN -- Installed Base Destination Records Not Found

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Creating New Dest dest Instance-34');
             END IF;

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'Y';
             l_new_dest_instance_rec.serial_number                :=  l_mtl_item_tbl(j).serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  1;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             -- Bug 5253131
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('INTERNAL_SITE');
             l_new_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
             l_new_dest_instance_rec.instance_usage_code          :=  l_out_of_enterprise;
             l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  NULL;
             l_new_dest_instance_rec.inv_locator_id               :=  NULL;
             l_new_dest_instance_rec.inv_organization_id          :=  NULL;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Before Create Item Instance-35');
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-36');
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

             l_expire_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_expire_instance_rec.instance_id              :=  l_new_dest_instance_rec.instance_id;
             l_expire_instance_rec.active_end_date          :=  sysdate;

             l_exp_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
             l_exp_txn_rec.transaction_date         :=  l_sysdate;
             l_exp_txn_rec.transaction_type_id      :=  csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
             l_exp_txn_rec.transaction_quantity     :=  l_mtl_item_tbl(i).transaction_quantity;
             l_exp_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
             l_exp_txn_rec.transacted_by            :=  l_employee_id;
             l_exp_txn_rec.transaction_action_code  :=  NULL;
             l_exp_txn_rec.message_id               :=  p_message_id;
             l_exp_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
             l_exp_txn_rec.object_version_number    :=  l_object_version_number;
             l_exp_txn_rec.source_header_ref_id     :=  r_so_info.header_id;
             l_exp_txn_rec.source_line_ref_id       :=  r_so_info.line_id;
             l_exp_txn_rec.source_header_ref        :=  to_char(r_so_info.order_number);
             l_exp_txn_rec.source_line_ref          :=  substr(to_char(r_so_info.line_number)||'.'||l_mtl_item_tbl(i).shipment_number,1,50);

             -- Current Object Version ID since the instance was Just Created
             SELECT object_version_number
             INTO l_curr_object_vers_61_id
             FROM csi_item_instances
             WHERE instance_id = l_expire_instance_rec.instance_id;

             l_expire_instance_rec.object_version_number   :=  l_curr_object_vers_61_id;

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Expiring Item Instance-36.1: '||l_new_dest_instance_rec.instance_id);
                 csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
                 csi_t_gen_utility_pvt.add('l_curr_object_vers_61_id is: '||l_curr_object_vers_61_id);
               END IF;

               csi_item_instance_pub.expire_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_expire_instance_rec,
                                                          l_expire_children,
                                                          l_exp_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('After Expire Item Instance-36.2');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status = l_fnd_success then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Usage Code: '||l_dest_instance_header_tbl(i).instance_usage_code);
               csi_t_gen_utility_pvt.add('Item ID: '||l_dest_instance_header_tbl(i).inventory_item_id);
               csi_t_gen_utility_pvt.add('Instance ID: '||l_dest_instance_header_tbl(i).instance_id);
             END IF;

            l_update_dest_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_dest_instance_rec.instance_id              :=  l_dest_instance_header_tbl(i).instance_id;
            l_update_dest_instance_rec.quantity                 :=  1;
            -- Bug 5253131
            l_update_dest_instance_rec.location_type_code       :=  csi_inv_trxs_pkg.get_location_type_code('INTERNAL_SITE');
            l_update_dest_instance_rec.last_oe_order_line_id    :=  r_so_info.line_id;
	    -- Added for Bug 5975739
	    l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
            l_update_dest_instance_rec.inv_organization_id      :=  NULL;
            l_update_dest_instance_rec.vld_organization_id      :=  l_mtl_item_tbl(j).organization_id;
            l_update_dest_instance_rec.inv_subinventory_name    :=  NULL;
            l_update_dest_instance_rec.inv_locator_id           :=  NULL;
            l_update_dest_instance_rec.instance_usage_code      :=  l_out_of_enterprise;
            l_update_dest_instance_rec.active_end_date          :=  l_sysdate;
            l_update_dest_instance_rec.object_version_number    :=  l_dest_instance_header_tbl(i).object_version_number;

            l_party_tbl.delete;
            l_account_tbl.delete;
            l_pricing_attrib_tbl.delete;
            l_org_assignments_tbl.delete;
            l_asset_assignment_tbl.delete;

            l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);


               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('Before Update Item Instance-37');
                     csi_t_gen_utility_pvt.add('Instance Status-38: '||l_update_dest_instance_rec.instance_status_id);

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
               csi_t_gen_utility_pvt.add('After Update Item Instance-39');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

          END IF; -- Destination IF

         IF j = 1 THEN -- Look for IN Transit Non Serial If not there create or Update only 1 time
           l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.serial_number                 :=  NULL;
           l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
           l_instance_query_rec.instance_usage_code           :=  l_in_transit;
           l_instance_query_rec.in_transit_order_line_id      :=  r_so_info.line_id;

           l_instance_usage_code                              :=  l_in_transit;
           l_subinventory_name                                :=  NULL;
           l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
           l_locator_id                                       :=  NULL;

           l_mfg_flag := NULL;
           l_serial_number := NULL;
           l_quantity := abs(l_mtl_item_tbl(j).transaction_quantity);

            IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Since the Shipping Code is 6 and the Receiving is 1 Look for Non Serial In Transit');
           END IF;

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Before Get Item Instance for Dest Serialized Instance-40');
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
                 csi_t_gen_utility_pvt.add('After Get Item Instance-41');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count < 1 THEN  -- Installed Base Destination Records are not found so create a new record

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Creating New Dest dest Instance-42');
             END IF;

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  l_mfg_flag;
             l_new_dest_instance_rec.serial_number                :=  l_serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  l_quantity;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
             l_new_dest_instance_rec.in_transit_order_line_id     :=  r_so_info.line_id;
             l_new_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
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

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Before Create Item Instance-43');
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-44');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Usage Code: '||l_dest_instance_header_tbl(i).instance_usage_code);
               csi_t_gen_utility_pvt.add('Item ID: '||l_dest_instance_header_tbl(i).inventory_item_id);
               csi_t_gen_utility_pvt.add('Instance ID: '||l_dest_instance_header_tbl(i).instance_id);
             END IF;

            l_update_dest_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_dest_instance_rec.instance_id              :=  l_dest_instance_header_tbl(i).instance_id;
            l_update_dest_instance_rec.quantity                 :=  l_dest_instance_header_tbl(i).quantity + l_quantity;
            l_update_dest_instance_rec.location_type_code       :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
            l_update_dest_instance_rec.in_transit_order_line_id :=  r_so_info.line_id;
	    -- Added for Bug 5975739
	    l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
            l_update_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
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

               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('Before Update Item Instance-45');
                     csi_t_gen_utility_pvt.add('Instance Status-46: '||l_update_dest_instance_rec.instance_status_id);

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
               csi_t_gen_utility_pvt.add('After Update Item Instance-47');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSE -- Error No dest non serial recs round
            IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('No Records were found in Install Base but the usage is not correct-20, The Usage is: '||l_dest_instance_header_tbl(i).instance_usage_code);
            END IF;
            fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
            fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;

            end if; --End of Destination Record If

          END IF;    -- End of j=1 for Control Code 1
         END IF;     -- serial Control 1 or 6 IF
        END IF;      -- l_receipt_action_flag
       END IF;       -- Serial If Statement
     END LOOP;       -- End of For Loop

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           csi_t_gen_utility_pvt.add('******End of csi_inv_iso_pkg.iso_shipment Transaction******');
     END IF;

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('You have encountered a "fnd_api.g_exc_error" exception in the Internal Sales Order Transaction - In Transit Shipment');
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
         x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
         x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
         x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
         x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIINTSS';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
        l_sql_error := SQLERRM;
        IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('You have encountered a "when others" exception in the Internal Sales Order Transaction - In Transit Shipment');
              csi_t_gen_utility_pvt.add('SQL Error: '||l_sql_error);
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
          x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
          x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
          x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
          x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
          x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
          x_trx_error_rec.transaction_error_date := l_sysdate ;
        END IF;

        x_trx_error_rec.error_text := fnd_message.get;
        x_trx_error_rec.transaction_id       := NULL;
        x_trx_error_rec.source_type          := 'CSIINTSS';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END iso_shipment;

   PROCEDURE iso_receipt(p_transaction_id     IN  NUMBER,
                         p_message_id         IN  NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl               CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                   VARCHAR2(100)   := 'CSI_INV_ISO_PKG.ISO_RECEIPT';
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
   l_in_relationship            VARCHAR2(25) := 'IN_RELATIONSHIP';
   l_out_of_enterprise          VARCHAR2(25) := 'OUT_OF_ENTERPRISE';
   l_returned                   VARCHAR2(25) := 'RETURNED';
   l_instance_usage_code        VARCHAR2(25);
   l_organization_id            NUMBER;
   l_subinventory_name          VARCHAR2(10);
   l_locator_id                 NUMBER;
   l_transaction_error_id       NUMBER;
   l_trx_type_id                NUMBER;
   l_trans_type_code            VARCHAR2(25);
   l_trans_app_code             VARCHAR2(5);
   l_employee_id                NUMBER;
   l_file                       VARCHAR2(500);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_sql_error                  VARCHAR2(2000);
   l_msg_index                  NUMBER;
   j                            PLS_INTEGER :=1;
   i                            PLS_INTEGER :=1;
   k                            PLS_INTEGER :=1;
   m                            PLS_INTEGER :=1;
   l_tbl_count                  NUMBER := 0;
   l_neg_code                   NUMBER := 0;
   l_instance_status            VARCHAR2(1);
   l_inv_org_iso                NUMBER;
   l_sr_control                 NUMBER := 0;
   l_12_loop                    NUMBER := 0;
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

     --Cursor modified for bug 5023673--
   CURSOR c_intransit_line_id (pc_transaction_id IN NUMBER) IS
     SELECT m2.trx_source_line_id
     FROM mtl_material_transactions m1, mtl_material_transactions m2
     WHERE m1.transaction_id = pc_transaction_id
     AND m1.transfer_transaction_id = m2.transaction_id;

   r_intransit_line_id     c_intransit_line_id%rowtype;

   CURSOR c_obj_version (pc_instance_id IN NUMBER) is
     SELECT object_version_number
     FROM   csi_item_instances
     WHERE  instance_id = pc_instance_id;

   CURSOR c_so_info (pc_line_id in NUMBER) is
     SELECT oeh.header_id,
            oel.line_id,
            oeh.order_number,
            oel.line_number
     FROM   oe_order_headers_all oeh,
            oe_order_lines_all oel
     WHERE oeh.header_id = oel.header_id
     AND   oel.line_id = pc_line_id;

--   CURSOR c_so_info (pc_line_id in NUMBER) is
--     SELECT oeh.header_id,
--            oel.line_id,
--            oeh.order_number,
--            oel.line_number
--     FROM   oe_order_headers_all oeh,
--            oe_order_lines_all oel
--     WHERE oeh.header_id = oel.header_id
--     AND   oel.source_document_id = pc_line_id;

   r_so_info     c_so_info%rowtype;

   CURSOR c_xfer_trans_id (pc_xfer_id IN NUMBER) IS
     SELECT trx_source_line_id
     from mtl_material_transactions
     WHERE transaction_id = pc_xfer_id;

   r_xfer_trans_id     c_xfer_trans_id%rowtype;

   BEGIN

     x_return_status := l_fnd_success;
     l_error_message := NULL;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('******Start of csi_inv_iso_pkg.iso_receipt Transaction procedure******');
           csi_t_gen_utility_pvt.add('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           csi_t_gen_utility_pvt.add('csiintsb.pls 115.27');
     END IF;

     IF (l_debug > 0) THEN
       csi_t_gen_utility_pvt.add('Transaction ID with is: '||p_transaction_id);
       csi_t_gen_utility_pvt.add('l_sysdate set to: '||to_char(l_sysdate,'DD-MON-YYYY HH24:MI:SS'));
     END IF;

     -- This procedure queries all of the Inventory Transaction Records and
     -- returns them as a table.

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

     IF (l_debug > 0) THEN
      	  csi_t_gen_utility_pvt.add('Transaction Action ID: '||l_mtl_item_tbl(i).transaction_action_id);
      	  csi_t_gen_utility_pvt.add('Transaction Source Type ID: '||l_mtl_item_tbl(i).transaction_source_type_id);
      	  csi_t_gen_utility_pvt.add('Transaction Quantity: '||l_mtl_item_tbl(i).transaction_quantity);
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

     -- Set so we only Query Valid Records.
     l_instance_status := FND_API.G_TRUE;

	-- Determine Transaction Type for this

       l_trans_type_code := 'ISO_REQUISITION_RECEIPT';
       l_trans_app_code := 'INV';

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Trans Type Code: '||l_trans_type_code);
           csi_t_gen_utility_pvt.add('Trans App Code: '||l_trans_app_code);
     END IF;

    -- Get Default Profile Instance Status

    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

    IF (l_debug > 0) THEN
      csi_t_gen_utility_pvt.add('Default Profile Status: '||r_id.instance_status_id);
    END IF;

     -- Added so that the SO_HEADER_ID and SO_LINE_ID can be added to
     -- the transaction record.

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Transfer Transaction ID: '||l_mtl_item_tbl(j).transfer_transaction_id);
     END IF;

     OPEN c_xfer_trans_id (l_mtl_item_tbl(j).transfer_transaction_id);
     FETCH c_xfer_trans_id into r_xfer_trans_id;
     CLOSE c_xfer_trans_id;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Trx Source Line ID: '||r_xfer_trans_id.trx_source_line_id);
     END IF;

     OPEN c_so_info (r_xfer_trans_id.trx_source_line_id);
     --OPEN c_so_info (l_mtl_item_tbl(j).transaction_source_id);
     FETCH c_so_info into r_so_info;
     CLOSE c_so_info;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Sales Order Header: '||r_so_info.header_id);
           csi_t_gen_utility_pvt.add('Sales Order Line: '||r_so_info.line_id);
           csi_t_gen_utility_pvt.add('Order Number: '||r_so_info.order_number);
           csi_t_gen_utility_pvt.add('Line Number: '||r_so_info.line_number);
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
     l_txn_rec.source_header_ref_id     :=  r_so_info.header_id;
     l_txn_rec.source_line_ref_id       :=  r_so_info.line_id;
     l_txn_rec.source_header_ref        :=  to_char(r_so_info.order_number);
     l_txn_rec.source_line_ref          :=  substr(to_char(r_so_info.line_number)||'.'||l_mtl_item_tbl(i).shipment_number,1,50);

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

    -- Get Line ID from Shipment Number

    OPEN c_intransit_line_id(p_transaction_id); --Modified for bug 5023673--
    FETCH c_intransit_line_id into r_intransit_line_id;
    CLOSE c_intransit_line_id;

    IF (l_debug > 0) THEN
      csi_t_gen_utility_pvt.add('Shipment Number: '||l_mtl_item_tbl(j).shipment_number);
      csi_t_gen_utility_pvt.add('Previous Line ID for Shipment: '||r_intransit_line_id.trx_source_line_id);
    END IF;

     IF (l_debug > 0) THEN
       csi_t_gen_utility_pvt.add('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
       csi_t_gen_utility_pvt.add('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
       csi_t_gen_utility_pvt.add('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
       csi_t_gen_utility_pvt.add('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
       csi_t_gen_utility_pvt.add('Organization ID: '||l_mtl_item_tbl(j).organization_id);
       csi_t_gen_utility_pvt.add('Transfer Org ID: '||l_mtl_item_tbl(j).transfer_organization_id);
     END IF;

     -- Get Shipping Organization Serial Control Code
     OPEN c_item_control (l_mtl_item_tbl(j).inventory_item_id,
                          l_mtl_item_tbl(j).transfer_organization_id);
     FETCH c_item_control into r_item_control;
     CLOSE c_item_control;

     l_sr_control := r_item_control.serial_number_control_code;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Serial Number : '||l_mtl_item_tbl(j).serial_number);
        csi_t_gen_utility_pvt.add('l_sr_control is: '||l_sr_control);
        csi_t_gen_utility_pvt.add('Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Serial Number Control Code: '||r_item_control.serial_number_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Lot Control Code: '||l_mtl_item_tbl(j).lot_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Lot Control Code: '||r_item_control.lot_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Loction Control Code: '||l_mtl_item_tbl(j).location_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Location Control Code: '||r_item_control.location_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Revision Control Code: '||l_mtl_item_tbl(j).revision_qty_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Revision Control Code: '||r_item_control.revision_qty_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Trackable Flag: '||r_item_control.comms_nl_trackable_flag);
     END IF;

         l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
         l_instance_usage_code                                :=  l_fnd_g_char;

       --In Transit Receipt
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
          --Added this IF construct for bug 6137231
         IF r_item_control.lot_control_code = 2 AND l_mtl_item_tbl(j).lot_control_code = 2 THEN
            l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
	 END IF;
         l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.instance_usage_code             :=  l_in_transit;
         l_instance_query_rec.location_type_code              :=  csi_inv_trxs_pkg.get_location_type_code('In_Transit');
         l_trx_action_type := 'IN_TRANSIT_RECEIPT';
         l_instance_usage_code := l_instance_query_rec.instance_usage_code;

      IF (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
          l_sr_control = 6) OR
         (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
          l_sr_control in (2,5)) OR
         (l_mtl_item_tbl(j).serial_number_control_code = 6 AND
          l_sr_control in (2,5)) OR
         (l_mtl_item_tbl(j).serial_number_control_code = 6 AND
          l_sr_control = 6) THEN

         --l_instance_query_rec.inv_organization_id := l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.serial_number := l_mtl_item_tbl(j).serial_number;
         IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Set Serial Number to Trans Record');
         END IF;
       ELSIF (l_mtl_item_tbl(j).serial_number_control_code in (6,1) AND
              l_sr_control = 1) OR
             (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
              l_sr_control = 1) THEN
         l_instance_query_rec.serial_number := NULL;
	 l_instance_query_rec.in_transit_order_line_id := r_intransit_line_id.trx_source_line_id;
         --l_instance_query_rec.inv_organization_id := l_mtl_item_tbl(j).transfer_organization_id;
         IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Set Serial Number to NULL');
         END IF;
       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 1 AND
              l_sr_control = 6) OR
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND
              l_sr_control in (2,5)) THEN
            l_instance_query_rec.serial_number := NULL;
	    l_instance_query_rec.in_transit_order_line_id := r_intransit_line_id.trx_source_line_id;
         IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Set Serial Number to NULL');
               csi_t_gen_utility_pvt.add('Pass into get item instance the Previous In Transit id ('||l_instance_query_rec.in_transit_order_line_id||')');
         END IF;
       END IF;

       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('l_12_loop is:'|| l_12_loop);
             csi_t_gen_utility_pvt.add('If Count is 1 then bypass Get Item Instance');
       END IF;

	  IF l_12_loop = 0 THEN

       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Transaction Action Type:'|| l_trx_action_type);
             csi_t_gen_utility_pvt.add('Before Get Item Instance-1');
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
       END IF;

       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('After Get Item Instance-2');
       END IF;
       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

     IF l_src_instance_header_tbl.count > 0 OR
	   l_12_loop = 1 THEN -- Installed Base Records Found
       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Records exists so now check both Shipping and Rec Serial Control');
       END IF;


      IF (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
          l_sr_control in (2,5)) OR
         (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
          l_sr_control = 6) THEN

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Serial Control at Shipping is 2,5 or 6 and Receiving are 2,5');
                   csi_t_gen_utility_pvt.add('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
             END IF;

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
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
	     --start of code for bug 6137231--
             IF r_item_control.lot_control_code = 2 AND l_mtl_item_tbl(j).lot_control_code = 1 THEN
               l_update_instance_rec.lot_number                   :=  NULL;
               csi_t_gen_utility_pvt.add('Lot control 2 and 1');
             ELSIF r_item_control.lot_control_code = 2 AND l_mtl_item_tbl(j).lot_control_code = 2 THEN
               l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
               csi_t_gen_utility_pvt.add('Lot control 2 and 2');
             ELSIF r_item_control.lot_control_code = 1 AND l_mtl_item_tbl(j).lot_control_code = 2 THEN
               l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
               csi_t_gen_utility_pvt.add('Lot control 1 and 2');
             END IF;---lot check
	     --End of code for bug 6137231--

           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('After you initialize the Update Record Values');
           END IF;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Update Item Instance-3');
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
                 csi_t_gen_utility_pvt.add('After Update Item Instance-4');
                 csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
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

	 -- Added case 2,4,6 for serial in transit being RETURNED - JPW

      ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 1 AND
             l_sr_control = 6) OR
            (l_mtl_item_tbl(j).serial_number_control_code = 1 AND
             l_sr_control in (2,5)) THEN

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Serial Control at Shipping is 6,5 or 2 and Receiving is 1');
                csi_t_gen_utility_pvt.add('Subtract Trans Qty from In Transit Non Serial Instance');
                csi_t_gen_utility_pvt.add('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
             END IF;

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
             l_update_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After you initialize the Update Record Values');
              csi_t_gen_utility_pvt.add('Instance Updated: '||l_update_instance_rec.instance_id);
              csi_t_gen_utility_pvt.add('Object Version: '||l_update_instance_rec.object_version_number);
              csi_t_gen_utility_pvt.add('New Quantity: '||l_update_instance_rec.quantity);
           END IF;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After you initialize the Transaction Record Values');
           END IF;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Update Item Instance-5');
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
              csi_t_gen_utility_pvt.add('After Update Item Instance-10.9');
              csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
              csi_t_gen_utility_pvt.add('You are updating Serial Number: '||l_update_instance_rec.serial_number);
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

         --  IF j = 1 THEN
           -- Now Query for Non Serialized In Inventory Record 1 Time Only
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

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Get Dest Item Instance-7');
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
              csi_t_gen_utility_pvt.add('After Get Item Instance-8');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             END IF;

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Create Item Instance-9');
                csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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
                csi_t_gen_utility_pvt.add('After Create Item Instance-10');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
             END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance-12');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
                  csi_t_gen_utility_pvt.add('Transaction Type ID: '||l_txn_rec.transaction_type_id);
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
                csi_t_gen_utility_pvt.add('After Update Item Instance-13');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
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
               csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-14');
             END IF;
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If
         --END IF;      -- End of J Index Loop

	 -- Added case 1,3,5 for serial in transit being RETURNED - JPW

      ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 6 AND
             l_sr_control in (2,5)) OR
            (l_mtl_item_tbl(j).serial_number_control_code = 6 AND
             l_sr_control = 6) THEN

            IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Serial Control at Shipping is 2,5 or 6 and Receiving is 6');
                   csi_t_gen_utility_pvt.add('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
            END IF;

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
             l_update_instance_rec.active_end_date              :=  l_sysdate;

             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After you initialize the Update Record Values');
              csi_t_gen_utility_pvt.add('Instance Updated: '||l_update_instance_rec.instance_id);
              csi_t_gen_utility_pvt.add('End Date Passed in: '||to_char(l_update_instance_rec.active_end_date,'DD-MON-YYYY HH24:MI:SS'));
              csi_t_gen_utility_pvt.add('Object Version: '||l_update_instance_rec.object_version_number);
           END IF;

---- BEGIN New Added
	     --Added for Bug 5975739
	     l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;

	     l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
             l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_update_instance_rec.instance_usage_code          :=  l_returned;

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Setting In Transit Serialized Instance to be RETURNED usage');
                csi_t_gen_utility_pvt.add('Usage: '||l_update_instance_rec.instance_usage_code);
                csi_t_gen_utility_pvt.add('VLD Org: '||l_update_instance_rec.vld_organization_id);
                csi_t_gen_utility_pvt.add('INV Org: '||l_update_instance_rec.inv_organization_id);
                csi_t_gen_utility_pvt.add('Subinv Code: '||l_update_instance_rec.inv_subinventory_name);
             END IF;

---- END NEW ADDED

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Update Item Instance-18');
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
                 csi_t_gen_utility_pvt.add('After Update Item Instance-19');
                 csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
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

          IF j = 1 THEN -- Update Source Since its Non Serialized 1 Time

            IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Update/Create Non Serial Dest 1 time with Transaction Quantity');
            END IF;

         -- Now Query for Dest Non Serialized Instances and Update (Unexpire)/ Create Instances
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

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Get Dest Item Instance-20');
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
                 csi_t_gen_utility_pvt.add('After Get Item Instance-21');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.serial_number                :=  NULL;
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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             END IF;

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Before Create Item Instance-22');
               csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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
               csi_t_gen_utility_pvt.add('After Create Item Instance-23');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance-25');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
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
                 csi_t_gen_utility_pvt.add('After Update Item Instance-26');
                 csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
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
               csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-28');
             END IF;
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If
         END IF;    -- End J Loop IF

      ELSIF (l_mtl_item_tbl(j).serial_number_control_code in (6,1) AND
             l_sr_control = 1) THEN

            IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Serial Control at Shipping is 1 and Receiving is 6 or 1');
                   csi_t_gen_utility_pvt.add('Source Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
            END IF;

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Update Item Instance-31');
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
                 csi_t_gen_utility_pvt.add('After Update Item Instance-32');
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

         -- Now Query for Dest Non Serialized Instances and Update (Unexpire)/ Create Instances
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

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Get Dest Item Instance-33');
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
                 csi_t_gen_utility_pvt.add('After Get Item Instance-34');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  l_mtl_item_tbl(j).transaction_quantity;
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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             END IF;

             IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Create Item Instance-35');
                 csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-36');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance-37');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
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
                 csi_t_gen_utility_pvt.add('After Update Item Instance-38');
                 csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
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
               csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-43');
             END IF;
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;
           END IF;    -- End of Destination Record If


      ELSIF (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
             l_sr_control = 1) THEN


            l_12_loop := 1;

            IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Setting l_12_loop: '||l_12_loop);
              csi_t_gen_utility_pvt.add('Serial Control at Shipping is 1 and Receiving is 2,5');
            END IF;

          IF j = 1 THEN -- Update Source Since its Non Serialized 1 Time

            IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Source Instance being updated 1 time: '||l_src_instance_header_tbl(i).instance_id);

            END IF;

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Before Update Item Instance-43');
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
             csi_t_gen_utility_pvt.add('After Update Item Instance-44');
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
         END IF; -- End of J = 1 If to update Source 1 time

         -- Now Query for Dest Serialized Instances and Update (Unexpire)/ Create Instances
             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
             --l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
             --l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.serial_number                 :=  l_mtl_item_tbl(j).serial_number;
             --l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             --l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).subinventory_code;
             --l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).organization_id;
             --l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
             --l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;
             l_instance_usage_code                              :=  l_in_inventory;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).subinventory_code;
             l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).locator_id;

           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Get Dest Item Instance-45');
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
                 csi_t_gen_utility_pvt.add('After Get Item Instance-46');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             END IF;

             IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Before Create Item Instance-47');
                 csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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
                   csi_t_gen_utility_pvt.add('After Create Item Instance-48');
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Serialized Instance found-48.1');
             END IF;

             IF l_dest_instance_header_tbl(i).instance_usage_code IN (l_in_transit,l_in_inventory,l_in_relationship,l_out_of_enterprise) THEN

             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Usage Code is: '||l_dest_instance_header_tbl(i).instance_usage_code);
             END IF;

             IF l_dest_instance_header_tbl(i).instance_usage_code = l_in_relationship THEN
               csi_t_gen_utility_pvt.add('Check and Break Relationship for Instance :'||l_dest_instance_header_tbl(i).instance_id);

               csi_process_txn_pvt.check_and_break_relation(l_dest_instance_header_tbl(i).instance_id,
                                                            l_txn_rec,
                                                            l_return_status);

              IF NOT l_return_status = l_fnd_success then
                csi_t_gen_utility_pvt.add('You encountered an error in the se_inv_trxs_pkg.check_and_break_relation');
                l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
                RAISE fnd_api.g_exc_error;
              END IF;

              csi_t_gen_utility_pvt.add('Object Version originally from instance: '||l_dest_instance_header_tbl(i).object_version_number);

              OPEN c_obj_version (l_dest_instance_header_tbl(i).instance_id);
              FETCH c_obj_version into l_dest_instance_header_tbl(i).object_version_number;
              CLOSE c_obj_version;

              csi_t_gen_utility_pvt.add('Current Object Version after check and break :'||l_dest_instance_header_tbl(i).object_version_number);

              END IF; -- Check and Break


               l_update_dest_instance_rec                             :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id                 :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
               l_update_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
               l_update_dest_instance_rec.quantity                     :=  1;
               l_update_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
               l_update_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
               l_update_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
	       -- Added for Bug 5975739
               l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
               l_update_dest_instance_rec.inv_organization_id          :=  l_organization_id;
               l_update_dest_instance_rec.vld_organization_id          :=  l_organization_id;
               l_update_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
               l_update_dest_instance_rec.inv_locator_id               :=  l_locator_id;
               l_update_dest_instance_rec.quantity                :=  1;
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  l_src_instance_header_tbl(i).in_transit_order_line_id;

             IF l_dest_instance_header_tbl(i).instance_usage_code IN (l_in_relationship,l_out_of_enterprise) THEN

	       -- We want to change the party of this back
     	       -- to the Internal Party

                IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Usage is '||l_dest_instance_header_tbl(i).instance_usage_code||' So we need to bring this back into Inventory and change the Owner Party back to the Internal Party');
                END IF;

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
                    IF (l_debug > 0) THEN
                      csi_t_gen_utility_pvt.add('Found the OWNER party so updating this back to the Internal Party ID');
                    END IF;

                  l_party_tbl                   :=  csi_inv_trxs_pkg.init_party_tbl;
                  l_party_tbl(i).instance_id    :=  l_dest_instance_header_tbl(i).instance_id;
                  l_party_tbl(i).instance_party_id :=  l_party_header_tbl(p).instance_party_id;
                  l_party_tbl(i).object_version_number := l_party_header_tbl(p).object_version_number;
                  IF (l_debug > 0) THEN
                    csi_t_gen_utility_pvt.add('After finding the OWNER party and updating this back to the Internal Party ID');
                  END IF;
 	         END IF;
                END LOOP;

                IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Inst Party ID :'||l_party_tbl(i).instance_party_id);
                  csi_t_gen_utility_pvt.add('Party Inst ID :'||l_party_tbl(i).instance_id);
                  csi_t_gen_utility_pvt.add('Party Source Table :'||l_party_tbl(i).party_source_table);
                  csi_t_gen_utility_pvt.add('Party ID :'||l_party_tbl(i).party_id);
                  csi_t_gen_utility_pvt.add('Rel Type Code :'||l_party_tbl(i).relationship_type_code);
                  csi_t_gen_utility_pvt.add('Contact Flag :'||l_party_tbl(i).contact_flag);
                  csi_t_gen_utility_pvt.add('Object Version Number:' ||l_party_tbl(i).object_version_number);
                END IF;

                ELSE

                  l_party_tbl.delete;

                END IF;

               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance-49');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
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
               csi_t_gen_utility_pvt.add('After Update Item Instance-50');
               csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                     csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

             ELSE -- No Records Found So throw Error
             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('No Records were found in Install Base-55');
             END IF;

             fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;
           END IF; -- Usage Code If

         ELSIF l_dest_instance_header_tbl.count > 1 THEN

         -- Multiple Instances were found so throw error
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-54');
           END IF;
           fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
           fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

         END IF;    -- End of Destination Record If

      END IF; -- Serial Control IF

     ELSE -- No IB Records Found So throw Error
           IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('No Records were found in Install Base to receive-55');
           END IF;
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;
     END IF; -- End of Main Source Header Tbl IF
     END LOOP;        -- End of For Loop

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           csi_t_gen_utility_pvt.add('******End of csi_inv_iso_pkg.iso_receipt Transaction******');
     END IF;

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('You have encountered a "fnd_api.g_exc_error" exception in the Internal Order In Transit Receipt');
       END IF;
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
       x_trx_error_rec.source_type          := 'CSIINTSR';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
        l_sql_error := SQLERRM;
        IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('You have encountered a "when others" exception in the Internal Order In Transit Receipt');
              csi_t_gen_utility_pvt.add('SQL Error: '||l_sql_error);
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
        x_trx_error_rec.source_type          := 'CSIINTSR';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        csi_t_gen_utility_pvt.add('ID_ISO1: '||csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code));
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
        csi_t_gen_utility_pvt.add('ID_ISO2: '||csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code));
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END iso_receipt;

   PROCEDURE iso_direct(p_transaction_id     IN  NUMBER,
                        p_message_id         IN  NUMBER,
                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl               CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                   VARCHAR2(100)   := 'CSI_INV_ISO_PKG.ISO_DIRECT';
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
   l_in_transit                 VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_in_relationship            VARCHAR2(25) := 'IN_RELATIONSHIP';
   l_fnd_g_num                  NUMBER      := FND_API.G_MISS_NUM;
   l_fnd_g_char                 VARCHAR2(1) := FND_API.G_MISS_CHAR;
   l_fnd_g_date                 DATE        := FND_API.G_MISS_DATE;
   l_instance_usage_code        VARCHAR2(25);
   l_organization_id            NUMBER;
   l_subinventory_name          VARCHAR2(10);
   l_locator_id                 NUMBER;
   l_transaction_error_id       NUMBER;
   l_trx_type_id                NUMBER;
   l_trans_type_code            VARCHAR2(25);
   l_trans_app_code             VARCHAR2(5);
   l_employee_id                NUMBER;
   l_file                       VARCHAR2(500);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_sql_error                  VARCHAR2(2000);
   l_msg_index                  NUMBER;
   j                            PLS_INTEGER := 1;
   k                            PLS_INTEGER := 1;
   i                            PLS_INTEGER := 1;
   l_tbl_count                  NUMBER := 0;
   l_neg_code                   NUMBER := 0;
   l_instance_status            VARCHAR2(1);
   l_sr_control                 NUMBER := 0;
   l_12_loop                    NUMBER := 0;
   l_66_flag                    NUMBER := 0;
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

   CURSOR c_obj_version (pc_instance_id IN NUMBER) is
     SELECT object_version_number
     FROM   csi_item_instances
     WHERE  instance_id = pc_instance_id;

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

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('******Start of csi_inv_iso_pkg.iso_direct Transaction procedure******');
        csi_t_gen_utility_pvt.add('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        csi_t_gen_utility_pvt.add('csiintsb.pls 115.27');
     END IF;

	-- This will open the cursor and fetch the (-) transaction ID
     OPEN c_mtl;
     FETCH c_mtl into r_mtl;
     CLOSE c_mtl;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Direct ISO using Trasfer Trans ID');
        csi_t_gen_utility_pvt.add('Transaction ID with (+) is: '||p_transaction_id);
        csi_t_gen_utility_pvt.add('Transaction ID with (-) is: '||r_mtl.transfer_transaction_id);
        csi_t_gen_utility_pvt.add('l_sysdate set to: '||to_char(l_sysdate,'DD-MON-YYYY HH24:MI:SS'));
     END IF;

     -- This procedure queries all of the Inventory Transaction Records and
	-- returns them as a table.

     csi_inv_trxs_pkg.get_transaction_recs(r_mtl.transfer_transaction_id,
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
          csi_t_gen_utility_pvt.add('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||r_mtl.transfer_transaction_id);
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

	-- Get the Negative Receipt Code to see if this org allows Negative
	-- Quantity Records 1 = Yes, 2 = No

	l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(
						  l_mtl_item_tbl(i).organization_id);


     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);
     END IF;

     -- Determine Transaction Type for this

     l_trans_type_code := 'ISO_DIRECT_SHIP';
     l_trans_app_code := 'INV';

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Trans Type Code: '||l_trans_type_code);
           csi_t_gen_utility_pvt.add('Trans App Code: '||l_trans_app_code);
     END IF;

    -- Get Default Profile Instance Status

    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

    IF (l_debug > 0) THEN
      csi_t_gen_utility_pvt.add('Default Profile Status: '||r_id.instance_status_id);
    END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

     -- Added so that the SO_HEADER_ID and SO_LINE_ID can be added to
     -- the transaction record.

     OPEN c_so_info (l_mtl_item_tbl(j).trx_source_line_id);
     FETCH c_so_info into r_so_info;
     CLOSE c_so_info;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Sales Order Header: '||r_so_info.header_id);
           csi_t_gen_utility_pvt.add('Sales Order Line: '||r_so_info.line_id);
           csi_t_gen_utility_pvt.add('Order Number: '||r_so_info.order_number);
           csi_t_gen_utility_pvt.add('Line Number: '||r_so_info.line_number);
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
     l_txn_rec.source_header_ref_id     :=  r_so_info.header_id;
     l_txn_rec.source_line_ref_id       :=  r_so_info.line_id;
     l_txn_rec.source_header_ref        :=  to_char(r_so_info.order_number);
     l_txn_rec.source_line_ref          :=  substr(to_char(r_so_info.line_number)||'.'||l_mtl_item_tbl(i).shipment_number,1,50);

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
       csi_t_gen_utility_pvt.add('Organization ID: '||l_mtl_item_tbl(j).organization_id);
       csi_t_gen_utility_pvt.add('Transfer Org ID: '||l_mtl_item_tbl(j).transfer_organization_id);
       csi_t_gen_utility_pvt.add('Transfer Subinv: '||l_mtl_item_tbl(j).transfer_subinventory);
     END IF;

     -- Get Receiving Organization Serial Control Code
     OPEN c_item_control (l_mtl_item_tbl(j).inventory_item_id,
                        l_mtl_item_tbl(j).transfer_organization_id);
     FETCH c_item_control into r_item_control;
     CLOSE c_item_control;

     l_sr_control := r_item_control.serial_number_control_code;

     IF (l_debug > 0) THEN
        csi_t_gen_utility_pvt.add('Serial Number : '||l_mtl_item_tbl(j).serial_number);
        csi_t_gen_utility_pvt.add('l_sr_control is: '||l_sr_control);
        csi_t_gen_utility_pvt.add('Shipping Org Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Serial Number Control Code: '||r_item_control.serial_number_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Lot Control Code: '||l_mtl_item_tbl(j).lot_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Lot Control Code: '||r_item_control.lot_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Loction Control Code: '||l_mtl_item_tbl(j).location_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Location Control Code: '||r_item_control.location_control_code);
        csi_t_gen_utility_pvt.add('Shipping Org Revision Control Code: '||l_mtl_item_tbl(j).revision_qty_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Revision Control Code: '||r_item_control.revision_qty_control_code);
        csi_t_gen_utility_pvt.add('Receiving Org Trackable Flag: '||r_item_control.comms_nl_trackable_flag);
     END IF;

	-- Set Query Instance Status
	IF l_neg_code = 1 AND l_mtl_item_tbl(j).serial_number_control_code = 1  THEN
	 l_instance_status := FND_API.G_FALSE;
     ELSE
	 l_instance_status := FND_API.G_TRUE;
	END IF;

     IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Query Inst Status : '||l_instance_status);
     END IF;

     -- Get the Location Ids for Receiving Org
     OPEN c_loc_ids (l_mtl_item_tbl(j).transfer_organization_id,
                     l_mtl_item_tbl(j).transfer_subinventory);
     FETCH c_loc_ids into r_loc_ids;
     CLOSE c_loc_ids;

     csi_t_gen_utility_pvt.add('Transfer Subinv Location: '||r_loc_ids.subinv_location_id);
     csi_t_gen_utility_pvt.add('Transfer HR Location    : '||r_loc_ids.hr_location_id);

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

       IF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN
         l_instance_query_rec.serial_number := NULL;
         IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Shipping org is 1,6 so set to NULL');
         END IF;
       END IF;

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Transaction Action Type:'|| l_trx_action_type);
          csi_t_gen_utility_pvt.add('Before Get Item Instance');
       END IF;

       IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('l_12_loop is:'|| l_12_loop);
             csi_t_gen_utility_pvt.add('If Count is 1 then bypass Get Item Instance');
       END IF;

       IF l_12_loop = 0 THEN

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
       END IF; -- End of l_12_loop

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('After Get Item Instance');
       END IF;
       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);

         IF l_tbl_count > 0 THEN
           csi_t_gen_utility_pvt.add('In Transit Order Line ID: '||l_src_instance_header_tbl(i).in_transit_order_line_id);
         END IF;

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

       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('Before checking to see if Source records Exist');         END IF;

       IF (l_mtl_item_tbl(j).serial_number_control_code = 5 AND -- Ship
	   l_sr_control = 5) OR -- Rec
          (l_mtl_item_tbl(j).serial_number_control_code = 5 AND -- Ship
	   l_sr_control = 2) OR -- Rec
          (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
	   l_sr_control = 5) OR -- Rec
          (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
	   l_sr_control = 2) OR -- Rec
          (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
	   l_sr_control = 2) OR -- Rec
          (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
	   l_sr_control = 5) THEN -- Rec
      --    (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
--	   l_sr_control = 6) THEN -- Rec
          IF l_src_instance_header_tbl.count > 0 THEN

          IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Shipping and Rec Serial Control are both 2,5');
               csi_t_gen_utility_pvt.add('Updating Serialized Instance: '||l_mtl_item_tbl(j).serial_number);
               csi_t_gen_utility_pvt.add('After you determine this is a Direct Shipment');
               csi_t_gen_utility_pvt.add('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
               csi_t_gen_utility_pvt.add('In Transit Order line ID: '||l_src_instance_header_tbl(i).in_transit_order_line_id);
          END IF;

          l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
          l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
          l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
          l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
          l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).transfer_subinventory;
          l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).transfer_locator_id;
          l_update_instance_rec.location_id                  :=  nvl(r_loc_ids.subinv_location_id,r_loc_ids.hr_location_id);
          l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
          l_update_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
          l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
          l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

          IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('After you initialize the Transaction Record Values');
             csi_t_gen_utility_pvt.add('After the update for Direct Shipment is set.');
             csi_t_gen_utility_pvt.add('Transfer Org: '||l_update_instance_rec.inv_organization_id);
             csi_t_gen_utility_pvt.add('Source Org: '||l_mtl_item_tbl(j).organization_id);
          END IF;

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
              csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
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

	    ELSE -- No Src Records found so error
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('No Records were found in Install Base');
           END IF;

           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;
	    END IF;  -- End of 2,5 and 2,5 IF

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
              l_sr_control = 1) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
              l_sr_control = 6) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
              l_sr_control = 1) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
              l_sr_control = 6) THEN -- Rec

            IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Shipping and Rec Serial Control are both 1,6');
          END IF;

         IF (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
             l_sr_control = 6) OR   -- Rec
            (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
             l_sr_control = 1) THEN -- Rec
           l_66_flag := 1;
           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('l_66_flag is :'||l_66_flag);
           END IF;
         END IF;


         IF l_src_instance_header_tbl.count = 0 THEN
           IF l_neg_code = 1 THEN  -- Allow Neg Qtys on NON Serial Items ONLY


         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('No Source Recs found so create Serial Instance ');
         END IF;


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

           ELSE -- Neg Code is <> 1 so Neg Qtys are not allowed so error
             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('No Records were found in Install Base - 11');
             END IF;

             fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;  -- End of Neg Qty If

         ELSIF l_src_instance_header_tbl.count = 1 THEN

         IF (l_debug > 0) THEN
            csi_t_gen_utility_pvt.add('You will update instance: '||l_src_instance_header_tbl(i).instance_id);
            csi_t_gen_utility_pvt.add('End Date is: '||l_src_instance_header_tbl(i).active_end_date);
         END IF;


           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.active_end_date        :=  NULL;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Update Source Item Instance - Neg Qty');
           END IF;

           l_upd_src_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           IF (l_debug > 0) THEN
             csi_t_gen_utility_pvt.add('Instance Status Id: '||l_upd_src_dest_instance_rec.instance_status_id);
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

           ELSIF l_src_instance_header_tbl.count > 1 THEN
           -- Multiple Instances were found so throw error
             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install BaseBase-11');
             END IF;
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

         END IF;  -- End of If for Source Count

	    -- Get Destination Records

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
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Get Item Instance');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Creating New Dest dest Instance - Neg Qty');
             END IF;

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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Before Create Item Instance - Neg Qty');
               csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  r_so_info.line_id;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
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
                csi_t_gen_utility_pvt.add('After Update Item Instance');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
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
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 5 AND -- Ship
	      l_sr_control = 1) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 5 AND -- Ship
	      l_sr_control = 6) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
	      l_sr_control = 1) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
	      l_sr_control = 6) THEN -- Rec

          IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Shipping is 2,5,6 and Rec Serial Control is 1,6');
          END IF;

-- Bug 3880731 - Take out the loop

        --FOR k in l_src_instance_header_tbl.FIRST .. abs(l_mtl_item_tbl(j).primary_quantity) LOOP
             IF (l_debug > 0) THEN
                   csi_t_gen_utility_pvt.add('Serial Control at Shipping is 2,5,6 and Receiving is 1,6');
                   csi_t_gen_utility_pvt.add('Expire The Serialized Instance First');
                   csi_t_gen_utility_pvt.add('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
             END IF;

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
             l_update_instance_rec.active_end_date              :=  l_sysdate;
             l_update_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After you initialize the Update Record Values');
              csi_t_gen_utility_pvt.add('Instance Updated: '||l_update_instance_rec.instance_id);
              csi_t_gen_utility_pvt.add('End Date Passed in: '||to_char(l_update_instance_rec.active_end_date,'DD-MON-YYYY HH24:MI:SS'));
              csi_t_gen_utility_pvt.add('Object Version: '||l_update_instance_rec.object_version_number);
           END IF;

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
                 csi_t_gen_utility_pvt.add('You are updating Instance: '||l_update_instance_rec.instance_id);
                 csi_t_gen_utility_pvt.add('You are updating Serial Number: '||l_update_instance_rec.serial_number);
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

-- Bug 3880731 Take out the loop
       -- END LOOP; -- End For Loop for Update of Sr Instances

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
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('After Get Item Instance');
           END IF;
           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Creating New Dest dest Instance - Neg Qty');
             END IF;

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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Create Item Instance - Neg Qty');
                csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  r_so_info.line_id;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
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
                csi_t_gen_utility_pvt.add('After Update Item Instance');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
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
              csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-61');
            END IF;
            fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
            fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
            fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
            fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
            fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If
         END IF;      -- End of J Index Loop

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
	      l_sr_control = 5) OR -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
	      l_sr_control = 2) THEN -- Rec

          IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Shipping is 1 and and Rec Serial Control is 2,5,6');
           END IF;

         l_12_loop := 1;

         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Setting l_12_loop: '||l_12_loop);
           csi_t_gen_utility_pvt.add('Serial Control at Shipping is 1,6 and Receiving is 2,5');
         END IF;

          IF j = 1 THEN -- Update Source Since its Non Serialized 1 Time
            IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Serial Control at Shipping is 1,6 and Receiving is 2,5');
               csi_t_gen_utility_pvt.add('Update Source 1 time with Transaction Quantity');
               csi_t_gen_utility_pvt.add('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);
            END IF;

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.last_oe_order_line_id  :=  r_so_info.line_id;
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Update Item Instance - 6');
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
              csi_t_gen_utility_pvt.add('After Update Item Instance - 7');
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
         END IF; -- End of J = 1 If to update Source 1 time

         -- Now Query for Dest Serialized Instances and Update (Unexpire)/ Create Instances
             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
             --l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
             --l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.serial_number                 :=  l_mtl_item_tbl(j).serial_number;
             --l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             --l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).transfer_subinventory;
             --l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).transfer_organization_id;
             --l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).transfer_locator_id;
             l_instance_usage_code                              :=  l_in_inventory; --l_instance_query_rec.instance_usage_code;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).transfer_subinventory;
             l_organization_id                                  :=  l_mtl_item_tbl(j).transfer_organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).transfer_locator_id;

           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Before Get Dest Item Instance - 8');
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
              csi_t_gen_utility_pvt.add('After Get Item Instance - 9');
           END IF;

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;
           IF (l_debug > 0) THEN
              csi_t_gen_utility_pvt.add('Source Records Found: '||l_tbl_count);
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

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'Y';
             l_new_dest_instance_rec.serial_number                :=  l_mtl_item_tbl(j).serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  1;
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
             l_new_dest_instance_rec.last_oe_order_line_id        :=  r_so_info.line_id;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             END IF;

             IF (l_debug > 0) THEN
                csi_t_gen_utility_pvt.add('Before Create Item Instance - 10');
                csi_t_gen_utility_pvt.add('In Transit Order Line ID on Dest Rec: '||l_new_dest_instance_rec.last_oe_order_line_id);
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
                csi_t_gen_utility_pvt.add('After Create Item Instance - 11');
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

           ELSIF l_dest_instance_header_tbl.count > 0 THEN -- Installed Base Destination Records Found


            IF l_dest_instance_header_tbl(i).instance_usage_code in (l_in_inventory,l_in_relationship) THEN

              IF l_dest_instance_header_tbl(i).instance_usage_code = l_in_relationship THEN
                csi_t_gen_utility_pvt.add('Check and Break Relationship for Instance :'||l_dest_instance_header_tbl(i).instance_id);

                csi_process_txn_pvt.check_and_break_relation(l_dest_instance_header_tbl(i).instance_id,
                                                             l_txn_rec,
                                                             l_return_status);

                IF NOT l_return_status = l_fnd_success then
                  csi_t_gen_utility_pvt.add('You encountered an error in the se_inv_trxs_pkg.check_and_break_relation');
                  l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
                  RAISE fnd_api.g_exc_error;
                END IF;

                csi_t_gen_utility_pvt.add('Object Version originally from instance: '||l_dest_instance_header_tbl(i).object_version_number);

                OPEN c_obj_version (l_dest_instance_header_tbl(i).instance_id);
                FETCH c_obj_version into l_dest_instance_header_tbl(i).object_version_number;
                CLOSE c_obj_version;

                csi_t_gen_utility_pvt.add('Current Object Version after check and break :'||l_dest_instance_header_tbl(i).object_version_number);

              END IF; -- Check and Break


               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  1;
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;
               l_update_dest_instance_rec.last_oe_order_line_id   :=  r_so_info.line_id;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               END IF;

               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('Before Update Item Instance - 13');
                  csi_t_gen_utility_pvt.add('In Transit Order Line ID in Updated Instance: '||l_update_dest_instance_rec.last_oe_order_line_id);
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
                csi_t_gen_utility_pvt.add('After Update Item Instance - 14');
                csi_t_gen_utility_pvt.add('l_upd_error_instance_id is: '||l_upd_error_instance_id);
             END IF;

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               IF (l_debug > 0) THEN
                  csi_t_gen_utility_pvt.add('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               END IF;
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSE -- No Serialized Instances with In Inventory or In Relationship Exist

             IF (l_debug > 0) THEN
                 csi_t_gen_utility_pvt.add('No Records were found in Install Base-5');
             END IF;

             fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF; -- End of inv or in rel IF

           ELSIF l_dest_instance_header_tbl.count > 1 THEN
             -- Multiple Instances were found so throw error
             IF (l_debug > 0) THEN
               csi_t_gen_utility_pvt.add('Multiple Instances were Found in Install Base-62');
             END IF;
             fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
             fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If

	  END IF;  -- End of Serial Control IF

       IF l_66_flag = 1 THEN
         IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('Exiting Loop :'||l_66_flag);
           csi_t_gen_utility_pvt.add('Ship Control :'||l_mtl_item_tbl(j).serial_number_control_code);
           csi_t_gen_utility_pvt.add('Rec Control :'||l_sr_control);
         END IF;
         EXIT;
       END IF;

    END LOOP;   -- End of main For Inv Loop

    IF (l_debug > 0) THEN
       csi_t_gen_utility_pvt.add('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
       csi_t_gen_utility_pvt.add('******End of csi_inv_iso_pkg.iso_direct Transaction******');
    END IF;

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF (l_debug > 0) THEN
          csi_t_gen_utility_pvt.add('You have encountered a "fnd_api.g_exc_error" exception in the Direct ISO Transaction');
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
         x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
         x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
         x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
         x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIINTDS';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
        l_sql_error := SQLERRM;
        IF (l_debug > 0) THEN
           csi_t_gen_utility_pvt.add('You have encountered a "when others" exception in the Direct ISO Transaction');
           csi_t_gen_utility_pvt.add('SQL Error: '||l_sql_error);
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
          x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
          x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
          x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
          x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
          x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
          x_trx_error_rec.transaction_error_date := l_sysdate ;
        END IF;

        x_trx_error_rec.error_text := fnd_message.get;
        x_trx_error_rec.transaction_id       := NULL;
        x_trx_error_rec.source_type          := 'CSIINTDS';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

  END iso_direct;
END csi_inv_iso_pkg;

/
