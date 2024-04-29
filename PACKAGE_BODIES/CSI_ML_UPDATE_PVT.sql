--------------------------------------------------------
--  DDL for Package Body CSI_ML_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_UPDATE_PVT" AS
-- $Header: csimupdb.pls 120.7 2007/11/27 02:30:22 anjgupta ship $

   g_action_replace       CONSTANT VARCHAR2 (30) := 'R';
   g_procstat_valid       CONSTANT VARCHAR2 (30) := 'R';
   g_procstat_processed   CONSTANT VARCHAR2 (30) := 'P';
   g_procstat_error       CONSTANT VARCHAR2 (30) := 'E';
   l_miss_char            CONSTANT VARCHAR2 (1)  := fnd_api.g_miss_char;
   l_miss_num             CONSTANT NUMBER        := fnd_api.g_miss_num;
   l_miss_date            CONSTANT DATE          := fnd_api.g_miss_date;

PROCEDURE populate_recs (
      p_txn_identifier         IN              VARCHAR2,
      p_source_system_name     IN              VARCHAR2,
      x_instance_tbl               OUT NOCOPY  csi_datastructures_pub.instance_tbl,
      x_party_tbl                  OUT NOCOPY  csi_datastructures_pub.party_tbl,
      x_account_tbl                OUT NOCOPY  csi_datastructures_pub.party_account_tbl,
      x_ext_attrib_value_tbl       OUT NOCOPY  csi_datastructures_pub.extend_attrib_values_tbl,
      x_price_tbl                  OUT NOCOPY  csi_datastructures_pub.pricing_attribs_tbl,
      x_org_assign_tbl             OUT NOCOPY  csi_datastructures_pub.organization_units_tbl,
      x_asset_assignment_tbl       OUT NOCOPY  csi_datastructures_pub.instance_asset_tbl,
      x_return_status              OUT NOCOPY  VARCHAR2,
      x_error_message              OUT NOCOPY  VARCHAR2
   )
   IS
      l_debug_level NUMBER := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));
      CURSOR inst_intf_cur (p_txn_id IN VARCHAR2,
                            p_source_name IN VARCHAR2)
      IS
         SELECT cii.*
           FROM csi_instance_interface cii
          WHERE cii.transaction_identifier = p_txn_id
          AND   cii.source_system_name = p_source_name
          AND   cii.instance_id IS NOT NULL --Added for open
          AND   cii.process_status='R';  -- added for bug 3260033


      CURSOR party_intf_cur (p_id IN NUMBER)
      IS
         SELECT cip.*
           FROM csi_i_party_interface cip
          WHERE cip.inst_interface_id = p_id;

      CURSOR item_obj_ver_cur (p_instance_id IN NUMBER)
      IS
         SELECT object_version_number,quantity,last_update_date
           FROM csi_item_instances
          WHERE instance_id = p_instance_id;

      CURSOR ou_obj_ver_cur (p_instance_id IN NUMBER)
      IS
         SELECT object_version_number,last_update_date
           FROM csi_i_org_assignments
          WHERE instance_id = p_instance_id;

      CURSOR price_obj_ver_cur (p_instance_id IN NUMBER)
      IS
         SELECT object_version_number,last_update_date
           FROM csi_i_pricing_attribs
          WHERE instance_id = p_instance_id;

      CURSOR ip_obj_ver_cur (p_ip_id IN NUMBER)
      IS
         SELECT object_version_number,last_update_date
           FROM csi_i_parties
          WHERE instance_party_id = p_ip_id;

      CURSOR ipa_obj_ver_cur (p_ip_account_id IN NUMBER)
      IS
         SELECT object_version_number,last_update_date
           FROM csi_ip_accounts
          WHERE ip_account_id = p_ip_account_id;

         --bnarayan added for R12
      CURSOR asset_attrib_intf_cur (p_id IN NUMBER, p_instance_id IN NUMBER)
      IS
         SELECT csiai.*,csia.instance_asset_id csia_instance_asset_id, nvl(csia.object_version_number,1) asset_object_ver_num
         FROM csi_i_asset_interface csiai, csi_i_assets csia
         WHERE csiai.inst_interface_id = p_id
         AND   csia.instance_id(+)     = p_instance_id
         AND   csia.fa_asset_id(+)     = csiai.fa_asset_id
         AND   csia.fa_location_id(+)  = csiai.fa_location_id ;


      CURSOR ext_attrib_intf_cur (p_id IN NUMBER)
      IS
         SELECT ceai.*, a.object_version_number ieav_object_ver_num
           FROM csi_iea_value_interface ceai, csi_iea_values a
          WHERE ceai.inst_interface_id= p_id
            AND ceai.attribute_value_id = a.attribute_value_id(+);

      l_old_quantity           NUMBER;
      l_item_object_version    NUMBER;
      l_ou_object_version      NUMBER;
      l_price_object_version   NUMBER;
      l_party_object_version   NUMBER;
      l_ipa1_object_version    NUMBER;
      l_ipa2_object_version    NUMBER;
      l_ipa3_object_version    NUMBER;
      l_last_update_date       DATE;
      l_error_message          VARCHAR2(250);
      inst_idx                 PLS_INTEGER := 0;
      prty_idx                 PLS_INTEGER := 0;
      ptyacc_idx               PLS_INTEGER := 0;
      extatt_idx               PLS_INTEGER := 0;
      org_idx                  PLS_INTEGER := 0;
      price_idx                PLS_INTEGER := 0;
      asset_idx                PLS_INTEGER := 0;  -- Asset index
      e_restriction            EXCEPTION;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_error_message := NULL;

      FOR inst_intf_rec IN inst_intf_cur (p_txn_identifier,
                                          p_source_system_name)
      LOOP
       -- Start code addition for bug 6368180, section 1 of 2
       IF inst_intf_rec.instance_id <> fnd_api.g_miss_num
       THEN
       -- We populate the record only if it is not for creating a new instance
       -- End code addition for bug 6368180, section 1 of 2
         inst_idx := inst_idx + 1;
         org_idx := org_idx + 1 ;
         price_idx := price_idx + 1;
	 asset_idx := asset_idx + 1; --bnarayan added for R12
         x_instance_tbl(inst_idx).instance_id := inst_intf_rec.instance_id;
         OPEN item_obj_ver_cur (inst_intf_rec.instance_id);
         FETCH item_obj_ver_cur INTO l_item_object_version,
                                     l_old_quantity,
                                     l_last_update_date;
         CLOSE item_obj_ver_cur;

         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
          IF(l_debug_level>1) THEN
           FND_File.Put_Line(Fnd_File.LOG,'Value of l_last_update_date='||to_char(l_last_update_date,'dd-mon-yy hh24:mi:ss'));
           FND_File.Put_Line(Fnd_File.LOG,'Value of inst_intf_rec.source_transaction_date='||to_char(inst_intf_rec.source_transaction_date,'dd-mon-yy hh24:mi:ss'));
           end if;
           fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
           fnd_message.set_token('INSTANCE_NUMBER',inst_intf_rec.instance_id);
           fnd_message.set_token('SOURCE_DATE',inst_intf_rec.source_transaction_date);
           l_error_message :=substr(fnd_message.get,1,208);
           RAISE e_restriction;
         END IF;

         OPEN ou_obj_ver_cur (inst_intf_rec.instance_id);
         FETCH ou_obj_ver_cur INTO l_ou_object_version,
                                   l_last_update_date;
         CLOSE ou_obj_ver_cur;
         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
 		fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
    		fnd_message.set_token('instance_id',inst_intf_rec.instance_id);
    		l_error_message :=substr(fnd_message.get,1,208);
                RAISE e_restriction;
         END IF;
         OPEN price_obj_ver_cur (inst_intf_rec.instance_id);
         FETCH price_obj_ver_cur INTO l_price_object_version,
                                      l_last_update_date;
         CLOSE price_obj_ver_cur;
         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
 		fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
    		fnd_message.set_token('instance_id',inst_intf_rec.instance_id);
    		l_error_message :=substr(fnd_message.get,1,208);
                RAISE e_restriction;
         END IF;

         SELECT l_miss_num /* DECODE (
                   inst_intf_rec.inv_vld_organization_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.inv_vld_organization_id
                ) */ -- Code commented for bug 3347509
                ,
                DECODE (
                   inst_intf_rec.inv_vld_organization_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.inv_vld_organization_id
                ),
                DECODE (
                   inst_intf_rec.inventory_item_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.inventory_item_id
                ),
                DECODE (
                   inst_intf_rec.location_type_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.location_type_code
                ),
                DECODE (
                   inst_intf_rec.location_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.location_id
                ),
                DECODE (
                   inst_intf_rec.inv_organization_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.inv_organization_id
                ),
                DECODE (
                   inst_intf_rec.inv_subinventory_name,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.inv_subinventory_name
                ),
                DECODE (
                   inst_intf_rec.inv_locator_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.inv_locator_id
                ),
                DECODE (
                   inst_intf_rec.lot_number,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.lot_number
                ),
                DECODE (
                   inst_intf_rec.project_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.project_id
                ),
                DECODE (
                   inst_intf_rec.task_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.task_id
                ),
                DECODE (
                   inst_intf_rec.in_transit_order_line_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.in_transit_order_line_id
                ),
                DECODE (
                   inst_intf_rec.wip_job_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.wip_job_id
                ),
                DECODE (
                   inst_intf_rec.po_order_line_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.po_order_line_id
                ),
                DECODE (
                   inst_intf_rec.inventory_revision,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.inventory_revision
                ),
                DECODE (
                   inst_intf_rec.serial_number,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.serial_number
                ),
                DECODE (
                   inst_intf_rec.mfg_serial_number_flag,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.mfg_serial_number_flag
                ),
                DECODE (
                   inst_intf_rec.quantity,
                   NULL, l_miss_num,
                   l_miss_num, NULL,inst_intf_rec.quantity
                  -- inst_intf_rec.quantity+l_old_quantity
                ),
                DECODE (
                   inst_intf_rec.unit_of_measure_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.unit_of_measure_code
                ),
                DECODE (
                   inst_intf_rec.accounting_class_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.accounting_class_code
                ),
                DECODE (
                   inst_intf_rec.instance_condition_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.instance_condition_id
                ),
                DECODE (
                   inst_intf_rec.instance_status_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.instance_status_id
                ),
                DECODE (
                   inst_intf_rec.customer_view_flag,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.customer_view_flag
                ),
                DECODE (
                   inst_intf_rec.merchant_view_flag,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.merchant_view_flag
                ),
                DECODE (
                   inst_intf_rec.sellable_flag,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.sellable_flag
                ),
                DECODE (
                   inst_intf_rec.system_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.system_id
                ),
                DECODE (
                   inst_intf_rec.instance_type_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_type_code
                ),
                DECODE (
                   inst_intf_rec.instance_end_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   inst_intf_rec.instance_end_date
                ),
                l_miss_num, -- LAST_OE_ORDER_LINE_ID
                l_miss_num, -- LAST_OE_RMA_LINE_ID
                l_miss_num, -- LAST_PO_PO_LINE_ID
                l_miss_char, -- LAST_OE_PO_NUMBER
                l_miss_num, -- LAST_WIP_JOB_ID
                l_miss_num, -- LAST_PA_PROJECT_ID
                l_miss_num, -- LAST_PA_TASK_ID
                l_miss_num, -- LAST_OE_AGREEMENT_ID
                DECODE (
                   inst_intf_rec.install_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   inst_intf_rec.install_date
                ),
                l_miss_char, -- MANUALLY_CREATED_FLAG
                DECODE (
                   inst_intf_rec.return_by_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   inst_intf_rec.return_by_date
                ),
                DECODE (
                   inst_intf_rec.actual_return_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   inst_intf_rec.actual_return_date
                ),
                l_miss_char, --CREATION_COMPLETE_FLAG
                l_miss_char, --COMPLETENESS_FLAG
                l_miss_char, --VERSION_LABEL
                l_miss_char, --VERSION_LABEL_DESCRIPTION
                DECODE (
                   inst_intf_rec.instance_context,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_context
                ),
                DECODE (
                   inst_intf_rec.instance_attribute1,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute1
                ),
                DECODE (
                   inst_intf_rec.instance_attribute2,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute2
                ),
                DECODE (
                   inst_intf_rec.instance_attribute3,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute3
                ),
                DECODE (
                   inst_intf_rec.instance_attribute4,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute4
                ),
                DECODE (
                   inst_intf_rec.instance_attribute5,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute5
                ),
                DECODE (
                   inst_intf_rec.instance_attribute6,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute6
                ),
                DECODE (
                   inst_intf_rec.instance_attribute7,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute7
                ),
                DECODE (
                   inst_intf_rec.instance_attribute8,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute8
                ),
                DECODE (
                   inst_intf_rec.instance_attribute9,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute9
                ),
                DECODE (
                   inst_intf_rec.instance_attribute10,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute10
                ),
                DECODE (
                   inst_intf_rec.instance_attribute11,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute11
                ),
                DECODE (
                   inst_intf_rec.instance_attribute12,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute12
                ),
                DECODE (
                   inst_intf_rec.instance_attribute13,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute13
                ),
                DECODE (
                   inst_intf_rec.instance_attribute14,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute14
                ),
                DECODE (
                   inst_intf_rec.instance_attribute15,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute15
                ),
		DECODE (
                   inst_intf_rec.instance_attribute16,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute16
                ),
		DECODE (
                   inst_intf_rec.instance_attribute17,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute17
                ),
		DECODE (
                   inst_intf_rec.instance_attribute18,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute18
                ),
		DECODE (
                   inst_intf_rec.instance_attribute19,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute19
                ),
		DECODE (
                   inst_intf_rec.instance_attribute20,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute20
                ),
		DECODE (
                   inst_intf_rec.instance_attribute21,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute21
                ),
		DECODE (
                   inst_intf_rec.instance_attribute22,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute22
                ),
		DECODE (
                   inst_intf_rec.instance_attribute23,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute23
                ),
		DECODE (
                   inst_intf_rec.instance_attribute24,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute24
                ),
		DECODE (
                   inst_intf_rec.instance_attribute25,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute25
                ),
		DECODE (
                   inst_intf_rec.instance_attribute26,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute26
                ),
		DECODE (
                   inst_intf_rec.instance_attribute27,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute27
                ),
		DECODE (
                   inst_intf_rec.instance_attribute28,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute28
                ),
		DECODE (
                   inst_intf_rec.instance_attribute29,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute29
                ),
		DECODE (
                   inst_intf_rec.instance_attribute30,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_attribute30
                ),
                l_item_object_version, -- OBJECT_VERSION_NUMBER
                l_miss_num, -- LAST_TXN_LINE_DETAIL_ID
		DECODE (
                   inst_intf_rec.install_location_type_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.install_location_type_code
                ),
                DECODE (
                   inst_intf_rec.install_location_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.install_location_id
                ),
                DECODE (
                   inst_intf_rec.network_asset_flag  ,
                   null, l_miss_char,
                   l_miss_char, null,
                   inst_intf_rec.network_asset_flag
                ),
                DECODE (
                   inst_intf_rec.maintainable_flag,
                   null, l_miss_char,
                   l_miss_char, null,
                   inst_intf_rec.maintainable_flag
                ),
                DECODE (
                   inst_intf_rec.equipment_gen_object_id,
                   null, l_miss_num,
                   l_miss_num, null,
                   inst_intf_rec.equipment_gen_object_id
                ),
                DECODE (
                   inst_intf_rec.asset_criticality_code,
                   null, l_miss_char,
                   l_miss_char, null,
                   inst_intf_rec.asset_criticality_code
                ),
                DECODE (
                   inst_intf_rec.operational_log_flag ,
                   null, l_miss_char,
                   l_miss_char, null,
                   inst_intf_rec.operational_log_flag
                ),
                DECODE (
                   inst_intf_rec.supplier_warranty_exp_date,
                   null, l_miss_date,
                   l_miss_date, null,
                   inst_intf_rec.supplier_warranty_exp_date
                ),
                DECODE (
                   inst_intf_rec.instantiation_flag,
                   null, l_miss_char,
                   l_miss_char, null,
                   inst_intf_rec.instantiation_flag
                ),

                DECODE (
                   inst_intf_rec.category_id,
                   null, l_miss_num,
                   l_miss_num, null,
                   inst_intf_rec.category_id
                ),
                l_miss_char, -- INSTANCE_USAGE_CODE
        -- Commenting the code as existence of instance_usage_code
        -- in csi_instance_interface is under discussion
        /*
                DECODE (
                   inst_intf_rec.instance_usage_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_usage_code
                ),
         */
               fnd_api.g_true, -- CHECK_FOR_INSTANCE_EXPIRY
                DECODE (
                   inst_intf_rec.instance_description,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.instance_description
                ),
                DECODE (
                   inst_intf_rec.operational_status_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   inst_intf_rec.operational_status_code
                )
           INTO x_instance_tbl(inst_idx).inv_master_organization_id,
                x_instance_tbl(inst_idx).vld_organization_id,
                x_instance_tbl(inst_idx).inventory_item_id,
                x_instance_tbl(inst_idx).location_type_code,
                x_instance_tbl(inst_idx).location_id,
                x_instance_tbl(inst_idx).inv_organization_id,
                x_instance_tbl(inst_idx).inv_subinventory_name,
                x_instance_tbl(inst_idx).inv_locator_id,
                x_instance_tbl(inst_idx).lot_number,
                x_instance_tbl(inst_idx).pa_project_id,
                x_instance_tbl(inst_idx).pa_project_task_id,
                x_instance_tbl(inst_idx).in_transit_order_line_id,
                x_instance_tbl(inst_idx).wip_job_id,
                x_instance_tbl(inst_idx).po_order_line_id,
                x_instance_tbl(inst_idx).inventory_revision,
                x_instance_tbl(inst_idx).serial_number,
                x_instance_tbl(inst_idx).mfg_serial_number_flag,
                x_instance_tbl(inst_idx).quantity,
                x_instance_tbl(inst_idx).unit_of_measure,
                x_instance_tbl(inst_idx).accounting_class_code,
                x_instance_tbl(inst_idx).instance_condition_id,
                x_instance_tbl(inst_idx).instance_status_id,
                x_instance_tbl(inst_idx).customer_view_flag,
                x_instance_tbl(inst_idx).merchant_view_flag,
                x_instance_tbl(inst_idx).sellable_flag,
                x_instance_tbl(inst_idx).system_id,
                x_instance_tbl(inst_idx).instance_type_code,
                x_instance_tbl(inst_idx).active_end_date,
                x_instance_tbl(inst_idx).last_oe_order_line_id,
                x_instance_tbl(inst_idx).last_oe_rma_line_id,
                x_instance_tbl(inst_idx).last_po_po_line_id,
                x_instance_tbl(inst_idx).last_oe_po_number,
                x_instance_tbl(inst_idx).last_wip_job_id,
                x_instance_tbl(inst_idx).last_pa_project_id,
                x_instance_tbl(inst_idx).last_pa_task_id,
                x_instance_tbl(inst_idx).last_oe_agreement_id,
                x_instance_tbl(inst_idx).install_date,
                x_instance_tbl(inst_idx).manually_created_flag,
                x_instance_tbl(inst_idx).return_by_date,
                x_instance_tbl(inst_idx).actual_return_date,
                x_instance_tbl(inst_idx).creation_complete_flag,
                x_instance_tbl(inst_idx).completeness_flag,
                x_instance_tbl(inst_idx).version_label,
                x_instance_tbl(inst_idx).version_label_description,
                x_instance_tbl(inst_idx).CONTEXT,
                x_instance_tbl(inst_idx).attribute1,
                x_instance_tbl(inst_idx).attribute2,
                x_instance_tbl(inst_idx).attribute3,
                x_instance_tbl(inst_idx).attribute4,
                x_instance_tbl(inst_idx).attribute5,
                x_instance_tbl(inst_idx).attribute6,
                x_instance_tbl(inst_idx).attribute7,
                x_instance_tbl(inst_idx).attribute8,
                x_instance_tbl(inst_idx).attribute9,
                x_instance_tbl(inst_idx).attribute10,
                x_instance_tbl(inst_idx).attribute11,
                x_instance_tbl(inst_idx).attribute12,
                x_instance_tbl(inst_idx).attribute13,
                x_instance_tbl(inst_idx).attribute14,
                x_instance_tbl(inst_idx).attribute15,
         	x_instance_tbl(inst_idx).attribute16,
		x_instance_tbl(inst_idx).attribute17,
		x_instance_tbl(inst_idx).attribute18,
		x_instance_tbl(inst_idx).attribute19,
		x_instance_tbl(inst_idx).attribute20,
		x_instance_tbl(inst_idx).attribute21,
		x_instance_tbl(inst_idx).attribute22,
		x_instance_tbl(inst_idx).attribute23,
		x_instance_tbl(inst_idx).attribute24,
		x_instance_tbl(inst_idx).attribute25,
		x_instance_tbl(inst_idx).attribute26,
		x_instance_tbl(inst_idx).attribute27,
		x_instance_tbl(inst_idx).attribute28,
		x_instance_tbl(inst_idx).attribute29,
		x_instance_tbl(inst_idx).attribute30,
                x_instance_tbl(inst_idx).object_version_number,
                x_instance_tbl(inst_idx).last_txn_line_detail_id,
                x_instance_tbl(inst_idx).install_location_type_code,
                x_instance_tbl(inst_idx).install_location_id,
		 x_instance_tbl(inst_idx).network_asset_flag,
                x_instance_tbl(inst_idx).maintainable_flag,
                x_instance_tbl(inst_idx).equipment_gen_object_id,
                x_instance_tbl(inst_idx).asset_criticality_code,
                x_instance_tbl(inst_idx).operational_log_flag,
                x_instance_tbl(inst_idx).supplier_warranty_exp_date,
                x_instance_tbl(inst_idx).instantiation_flag,
                x_instance_tbl(inst_idx).category_id,
                x_instance_tbl(inst_idx).instance_usage_code,
                x_instance_tbl(inst_idx).check_for_instance_expiry,
                x_instance_tbl(inst_idx).instance_description,
		x_instance_tbl(inst_idx).operational_status_code
           FROM DUAL;

          x_instance_tbl(inst_idx).INTERFACE_ID := inst_intf_rec.inst_interface_id;

  ---Populate Pricing attribites
         IF inst_intf_rec.pricing_attribute_id IS NOT NULL
         THEN
            x_price_tbl(price_idx).pricing_attribute_id :=
                                           inst_intf_rec.pricing_attribute_id;
         END IF;


         IF (   inst_intf_rec.pricing_attribute1 IS NOT NULL
             OR inst_intf_rec.pricing_attribute2 IS NOT NULL
             OR inst_intf_rec.pricing_attribute3 IS NOT NULL
             OR inst_intf_rec.pricing_attribute4 IS NOT NULL
             OR inst_intf_rec.pricing_attribute5 IS NOT NULL
             OR inst_intf_rec.pricing_attribute6 IS NOT NULL
             OR inst_intf_rec.pricing_attribute7 IS NOT NULL
             OR inst_intf_rec.pricing_attribute8 IS NOT NULL
             OR inst_intf_rec.pricing_attribute9 IS NOT NULL
             OR inst_intf_rec.pricing_attribute10 IS NOT NULL
             OR inst_intf_rec.pricing_attribute11 IS NOT NULL
             OR inst_intf_rec.pricing_attribute12 IS NOT NULL
             OR inst_intf_rec.pricing_attribute13 IS NOT NULL
             OR inst_intf_rec.pricing_attribute14 IS NOT NULL
             OR inst_intf_rec.pricing_attribute15 IS NOT NULL
             OR inst_intf_rec.pricing_attribute16 IS NOT NULL
             OR inst_intf_rec.pricing_attribute17 IS NOT NULL
             OR inst_intf_rec.pricing_attribute18 IS NOT NULL
             OR inst_intf_rec.pricing_attribute19 IS NOT NULL
             OR inst_intf_rec.pricing_attribute20 IS NOT NULL
             OR inst_intf_rec.pricing_attribute21 IS NOT NULL
             OR inst_intf_rec.pricing_attribute22 IS NOT NULL
             OR inst_intf_rec.pricing_attribute23 IS NOT NULL
             OR inst_intf_rec.pricing_attribute24 IS NOT NULL
             OR inst_intf_rec.pricing_attribute25 IS NOT NULL
             OR inst_intf_rec.pricing_attribute26 IS NOT NULL
             OR inst_intf_rec.pricing_attribute27 IS NOT NULL
             OR inst_intf_rec.pricing_attribute28 IS NOT NULL
             OR inst_intf_rec.pricing_attribute29 IS NOT NULL
             OR inst_intf_rec.pricing_attribute30 IS NOT NULL
             OR inst_intf_rec.pricing_attribute31 IS NOT NULL
             OR inst_intf_rec.pricing_attribute32 IS NOT NULL
             OR inst_intf_rec.pricing_attribute33 IS NOT NULL
             OR inst_intf_rec.pricing_attribute34 IS NOT NULL
             OR inst_intf_rec.pricing_attribute35 IS NOT NULL
             OR inst_intf_rec.pricing_attribute36 IS NOT NULL
             OR inst_intf_rec.pricing_attribute37 IS NOT NULL
             OR inst_intf_rec.pricing_attribute38 IS NOT NULL
             OR inst_intf_rec.pricing_attribute39 IS NOT NULL
             OR inst_intf_rec.pricing_attribute40 IS NOT NULL
             OR inst_intf_rec.pricing_attribute41 IS NOT NULL
             OR inst_intf_rec.pricing_attribute42 IS NOT NULL
             OR inst_intf_rec.pricing_attribute43 IS NOT NULL
             OR inst_intf_rec.pricing_attribute44 IS NOT NULL
             OR inst_intf_rec.pricing_attribute45 IS NOT NULL
             OR inst_intf_rec.pricing_attribute46 IS NOT NULL
             OR inst_intf_rec.pricing_attribute47 IS NOT NULL
             OR inst_intf_rec.pricing_attribute48 IS NOT NULL
             OR inst_intf_rec.pricing_attribute49 IS NOT NULL
             OR inst_intf_rec.pricing_attribute50 IS NOT NULL
             OR inst_intf_rec.pricing_attribute51 IS NOT NULL
             OR inst_intf_rec.pricing_attribute52 IS NOT NULL
             OR inst_intf_rec.pricing_attribute53 IS NOT NULL
             OR inst_intf_rec.pricing_attribute54 IS NOT NULL
             OR inst_intf_rec.pricing_attribute55 IS NOT NULL
             OR inst_intf_rec.pricing_attribute56 IS NOT NULL
             OR inst_intf_rec.pricing_attribute57 IS NOT NULL
             OR inst_intf_rec.pricing_attribute58 IS NOT NULL
             OR inst_intf_rec.pricing_attribute59 IS NOT NULL
             OR inst_intf_rec.pricing_attribute60 IS NOT NULL
             OR inst_intf_rec.pricing_attribute61 IS NOT NULL
             OR inst_intf_rec.pricing_attribute62 IS NOT NULL
             OR inst_intf_rec.pricing_attribute63 IS NOT NULL
             OR inst_intf_rec.pricing_attribute64 IS NOT NULL
             OR inst_intf_rec.pricing_attribute65 IS NOT NULL
             OR inst_intf_rec.pricing_attribute66 IS NOT NULL
             OR inst_intf_rec.pricing_attribute67 IS NOT NULL
             OR inst_intf_rec.pricing_attribute68 IS NOT NULL
             OR inst_intf_rec.pricing_attribute69 IS NOT NULL
             OR inst_intf_rec.pricing_attribute70 IS NOT NULL
             OR inst_intf_rec.pricing_attribute71 IS NOT NULL
             OR inst_intf_rec.pricing_attribute72 IS NOT NULL
             OR inst_intf_rec.pricing_attribute73 IS NOT NULL
             OR inst_intf_rec.pricing_attribute74 IS NOT NULL
             OR inst_intf_rec.pricing_attribute75 IS NOT NULL
             OR inst_intf_rec.pricing_attribute76 IS NOT NULL
             OR inst_intf_rec.pricing_attribute77 IS NOT NULL
             OR inst_intf_rec.pricing_attribute78 IS NOT NULL
             OR inst_intf_rec.pricing_attribute79 IS NOT NULL
             OR inst_intf_rec.pricing_attribute80 IS NOT NULL
             OR inst_intf_rec.pricing_attribute81 IS NOT NULL
             OR inst_intf_rec.pricing_attribute82 IS NOT NULL
             OR inst_intf_rec.pricing_attribute83 IS NOT NULL
             OR inst_intf_rec.pricing_attribute84 IS NOT NULL
             OR inst_intf_rec.pricing_attribute85 IS NOT NULL
             OR inst_intf_rec.pricing_attribute86 IS NOT NULL
             OR inst_intf_rec.pricing_attribute87 IS NOT NULL
             OR inst_intf_rec.pricing_attribute88 IS NOT NULL
             OR inst_intf_rec.pricing_attribute89 IS NOT NULL
             OR inst_intf_rec.pricing_attribute90 IS NOT NULL
             OR inst_intf_rec.pricing_attribute91 IS NOT NULL
             OR inst_intf_rec.pricing_attribute92 IS NOT NULL
             OR inst_intf_rec.pricing_attribute93 IS NOT NULL
             OR inst_intf_rec.pricing_attribute94 IS NOT NULL
             OR inst_intf_rec.pricing_attribute95 IS NOT NULL
             OR inst_intf_rec.pricing_attribute96 IS NOT NULL
             OR inst_intf_rec.pricing_attribute97 IS NOT NULL
             OR inst_intf_rec.pricing_attribute98 IS NOT NULL
             OR inst_intf_rec.pricing_attribute99 IS NOT NULL
             OR inst_intf_rec.pricing_attribute100 IS NOT NULL
            )
         THEN

            SELECT inst_intf_rec.instance_id,
                   l_miss_date, -- ACTIVE_START_DATE
                   DECODE (
                      inst_intf_rec.pricing_att_end_date,
                      NULL, l_miss_date,
                      l_miss_date, NULL,
                      inst_intf_rec.pricing_att_end_date
                   ),
                   DECODE (
                      inst_intf_rec.pricing_context,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_context
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute1,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute1
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute2,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute2
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute3,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute3
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute4,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute4
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute5,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute5
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute6,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute6
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute7,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute7
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute8,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute8
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute9,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute9
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute10,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute10
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute11,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute11
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute12,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute12
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute13,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute13
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute14,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute14
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute15,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute15
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute16,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute16
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute17,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute17
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute18,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute18
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute19,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute19
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute20,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute20
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute21,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute21
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute22,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute22
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute23,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute23
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute24,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute24
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute25,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute25
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute26,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute26
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute27,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute27
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute28,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute28
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute29,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute29
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute30,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute30
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute31,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute31
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute32,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute32
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute33,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute33
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute34,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute34
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute35,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute35
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute36,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute36
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute37,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute37
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute38,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute38
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute39,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute39
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute40,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute40
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute41,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute41
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute42,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute42
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute43,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute43
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute44,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute44
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute45,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute45
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute46,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute46
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute47,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute47
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute48,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute48
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute49,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute49
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute50,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute50
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute51,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute51
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute52,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute52
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute53,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute53
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute54,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute54
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute55,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute55
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute56,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute56
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute57,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute57
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute58,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute58
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute59,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute59
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute60,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute60
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute61,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute61
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute62,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute62
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute63,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute63
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute64,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute64
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute65,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute65
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute66,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute66
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute67,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute67
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute68,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute68
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute69,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute69
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute70,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute70
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute71,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute71
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute72,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute72
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute73,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute73
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute74,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute74
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute75,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute75
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute76,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute76
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute77,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute77
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute78,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute78
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute79,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute79
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute80,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute80
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute81,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute81
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute82,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute82
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute83,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute83
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute84,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute84
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute85,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute85
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute86,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute86
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute87,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute87
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute88,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute88
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute89,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute89
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute90,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute90
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute91,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute91
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute92,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute92
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute93,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute93
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute94,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute94
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute95,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute95
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute96,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute96
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute97,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute97
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute98,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute98
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute99,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute99
                   ),
                   DECODE (
                      inst_intf_rec.pricing_attribute100,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_attribute100
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_context,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_context
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute1,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute1
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute2,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute2
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute3,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute3
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute4,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute4
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute5,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute5
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute6,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute6
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute7,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute7
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute8,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute8
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute9,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute9
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute10,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute10
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute11,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute11
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute12,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute12
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute13,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute13
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute14,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute14
                   ),
                   DECODE (
                      inst_intf_rec.pricing_flex_attribute15,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.pricing_flex_attribute15
                   ),
                   l_price_object_version -- OBJECT_VERSION_NUMBER
              INTO x_price_tbl(price_idx).instance_id,
                   x_price_tbl(price_idx).active_start_date,
                   x_price_tbl(price_idx).active_end_date,
                   x_price_tbl(price_idx).pricing_context,
                   x_price_tbl(price_idx).pricing_attribute1,
                   x_price_tbl(price_idx).pricing_attribute2,
                   x_price_tbl(price_idx).pricing_attribute3,
                   x_price_tbl(price_idx).pricing_attribute4,
                   x_price_tbl(price_idx).pricing_attribute5,
                   x_price_tbl(price_idx).pricing_attribute6,
                   x_price_tbl(price_idx).pricing_attribute7,
                   x_price_tbl(price_idx).pricing_attribute8,
                   x_price_tbl(price_idx).pricing_attribute9,
                   x_price_tbl(price_idx).pricing_attribute10,
                   x_price_tbl(price_idx).pricing_attribute11,
                   x_price_tbl(price_idx).pricing_attribute12,
                   x_price_tbl(price_idx).pricing_attribute13,
                   x_price_tbl(price_idx).pricing_attribute14,
                   x_price_tbl(price_idx).pricing_attribute15,
                   x_price_tbl(price_idx).pricing_attribute16,
                   x_price_tbl(price_idx).pricing_attribute17,
                   x_price_tbl(price_idx).pricing_attribute18,
                   x_price_tbl(price_idx).pricing_attribute19,
                   x_price_tbl(price_idx).pricing_attribute20,
                   x_price_tbl(price_idx).pricing_attribute21,
                   x_price_tbl(price_idx).pricing_attribute22,
                   x_price_tbl(price_idx).pricing_attribute23,
                   x_price_tbl(price_idx).pricing_attribute24,
                   x_price_tbl(price_idx).pricing_attribute25,
                   x_price_tbl(price_idx).pricing_attribute26,
                   x_price_tbl(price_idx).pricing_attribute27,
                   x_price_tbl(price_idx).pricing_attribute28,
                   x_price_tbl(price_idx).pricing_attribute29,
                   x_price_tbl(price_idx).pricing_attribute30,
                   x_price_tbl(price_idx).pricing_attribute31,
                   x_price_tbl(price_idx).pricing_attribute32,
                   x_price_tbl(price_idx).pricing_attribute33,
                   x_price_tbl(price_idx).pricing_attribute34,
                   x_price_tbl(price_idx).pricing_attribute35,
                   x_price_tbl(price_idx).pricing_attribute36,
                   x_price_tbl(price_idx).pricing_attribute37,
                   x_price_tbl(price_idx).pricing_attribute38,
                   x_price_tbl(price_idx).pricing_attribute39,
                   x_price_tbl(price_idx).pricing_attribute40,
                   x_price_tbl(price_idx).pricing_attribute41,
                   x_price_tbl(price_idx).pricing_attribute42,
                   x_price_tbl(price_idx).pricing_attribute43,
                   x_price_tbl(price_idx).pricing_attribute44,
                   x_price_tbl(price_idx).pricing_attribute45,
                   x_price_tbl(price_idx).pricing_attribute46,
                   x_price_tbl(price_idx).pricing_attribute47,
                   x_price_tbl(price_idx).pricing_attribute48,
                   x_price_tbl(price_idx).pricing_attribute49,
                   x_price_tbl(price_idx).pricing_attribute50,
                   x_price_tbl(price_idx).pricing_attribute51,
                   x_price_tbl(price_idx).pricing_attribute52,
                   x_price_tbl(price_idx).pricing_attribute53,
                   x_price_tbl(price_idx).pricing_attribute54,
                   x_price_tbl(price_idx).pricing_attribute55,
                   x_price_tbl(price_idx).pricing_attribute56,
                   x_price_tbl(price_idx).pricing_attribute57,
                   x_price_tbl(price_idx).pricing_attribute58,
                   x_price_tbl(price_idx).pricing_attribute59,
                   x_price_tbl(price_idx).pricing_attribute60,
                   x_price_tbl(price_idx).pricing_attribute61,
                   x_price_tbl(price_idx).pricing_attribute62,
                   x_price_tbl(price_idx).pricing_attribute63,
                   x_price_tbl(price_idx).pricing_attribute64,
                   x_price_tbl(price_idx).pricing_attribute65,
                   x_price_tbl(price_idx).pricing_attribute66,
                   x_price_tbl(price_idx).pricing_attribute67,
                   x_price_tbl(price_idx).pricing_attribute68,
                   x_price_tbl(price_idx).pricing_attribute69,
                   x_price_tbl(price_idx).pricing_attribute70,
                   x_price_tbl(price_idx).pricing_attribute71,
                   x_price_tbl(price_idx).pricing_attribute72,
                   x_price_tbl(price_idx).pricing_attribute73,
                   x_price_tbl(price_idx).pricing_attribute74,
                   x_price_tbl(price_idx).pricing_attribute75,
                   x_price_tbl(price_idx).pricing_attribute76,
                   x_price_tbl(price_idx).pricing_attribute77,
                   x_price_tbl(price_idx).pricing_attribute78,
                   x_price_tbl(price_idx).pricing_attribute79,
                   x_price_tbl(price_idx).pricing_attribute80,
                   x_price_tbl(price_idx).pricing_attribute81,
                   x_price_tbl(price_idx).pricing_attribute82,
                   x_price_tbl(price_idx).pricing_attribute83,
                   x_price_tbl(price_idx).pricing_attribute84,
                   x_price_tbl(price_idx).pricing_attribute85,
                   x_price_tbl(price_idx).pricing_attribute86,
                   x_price_tbl(price_idx).pricing_attribute87,
                   x_price_tbl(price_idx).pricing_attribute88,
                   x_price_tbl(price_idx).pricing_attribute89,
                   x_price_tbl(price_idx).pricing_attribute90,
                   x_price_tbl(price_idx).pricing_attribute91,
                   x_price_tbl(price_idx).pricing_attribute92,
                   x_price_tbl(price_idx).pricing_attribute93,
                   x_price_tbl(price_idx).pricing_attribute94,
                   x_price_tbl(price_idx).pricing_attribute95,
                   x_price_tbl(price_idx).pricing_attribute96,
                   x_price_tbl(price_idx).pricing_attribute97,
                   x_price_tbl(price_idx).pricing_attribute98,
                   x_price_tbl(price_idx).pricing_attribute99,
                   x_price_tbl(price_idx).pricing_attribute100,
                   x_price_tbl(price_idx).CONTEXT,
                   x_price_tbl(price_idx).attribute1,
                   x_price_tbl(price_idx).attribute2,
                   x_price_tbl(price_idx).attribute3,
                   x_price_tbl(price_idx).attribute4,
                   x_price_tbl(price_idx).attribute5,
                   x_price_tbl(price_idx).attribute6,
                   x_price_tbl(price_idx).attribute7,
                   x_price_tbl(price_idx).attribute8,
                   x_price_tbl(price_idx).attribute9,
                   x_price_tbl(price_idx).attribute10,
                   x_price_tbl(price_idx).attribute11,
                   x_price_tbl(price_idx).attribute12,
                   x_price_tbl(price_idx).attribute13,
                   x_price_tbl(price_idx).attribute14,
                   x_price_tbl(price_idx).attribute15,
                   x_price_tbl(price_idx).object_version_number
              FROM DUAL;
         END IF;


      ---Populate Org Assignments
         IF inst_intf_rec.instance_ou_id IS NOT NULL
         THEN
            x_org_assign_tbl(org_idx).instance_ou_id :=
                                                 inst_intf_rec.instance_ou_id;
         END IF;

         IF (   inst_intf_rec.operating_unit IS NOT NULL
             OR inst_intf_rec.ou_relation_type IS NOT NULL
             OR inst_intf_rec.ou_end_date IS NOT NULL
            )
         THEN
            SELECT DECODE (
                      inst_intf_rec.instance_id,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      inst_intf_rec.instance_id
                   ),
                   DECODE (
                      inst_intf_rec.operating_unit,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      inst_intf_rec.operating_unit
                   ),
                   DECODE (
                      inst_intf_rec.ou_relation_type,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      inst_intf_rec.ou_relation_type
                   ),
                   l_miss_date, -- ACTIVE_START_DATE
                   DECODE (
                      inst_intf_rec.ou_end_date,
                      NULL, l_miss_date,
                      l_miss_date, NULL,
                      inst_intf_rec.ou_end_date
                   ),
                   l_miss_char, -- CONTEXT
                   l_miss_char, -- ATTRIBUTE1
                   l_miss_char, -- ATTRIBUTE2
                   l_miss_char, -- ATTRIBUTE3
                   l_miss_char, -- ATTRIBUTE4
                   l_miss_char, -- ATTRIBUTE5
                   l_miss_char, -- ATTRIBUTE6
                   l_miss_char, -- ATTRIBUTE7
                   l_miss_char, -- ATTRIBUTE8
                   l_miss_char, -- ATTRIBUTE9
                   l_miss_char, -- ATTRIBUTE10
                   l_miss_char, -- ATTRIBUTE11
                   l_miss_char, -- ATTRIBUTE12
                   l_miss_char, -- ATTRIBUTE13
                   l_miss_char, -- ATTRIBUTE14
                   l_miss_char, -- ATTRIBUTE15
                   l_ou_object_version -- OBJECT_VERSION_NUMBER
              INTO x_org_assign_tbl(org_idx).instance_id,
                   x_org_assign_tbl(org_idx).operating_unit_id,
                   x_org_assign_tbl(org_idx).relationship_type_code,
                   x_org_assign_tbl(org_idx).active_start_date,
                   x_org_assign_tbl(org_idx).active_end_date,
                   x_org_assign_tbl(org_idx).CONTEXT,
                   x_org_assign_tbl(org_idx).attribute1,
                   x_org_assign_tbl(org_idx).attribute2,
                   x_org_assign_tbl(org_idx).attribute3,
                   x_org_assign_tbl(org_idx).attribute4,
                   x_org_assign_tbl(org_idx).attribute5,
                   x_org_assign_tbl(org_idx).attribute6,
                   x_org_assign_tbl(org_idx).attribute7,
                   x_org_assign_tbl(org_idx).attribute8,
                   x_org_assign_tbl(org_idx).attribute9,
                   x_org_assign_tbl(org_idx).attribute10,
                   x_org_assign_tbl(org_idx).attribute11,
                   x_org_assign_tbl(org_idx).attribute12,
                   x_org_assign_tbl(org_idx).attribute13,
                   x_org_assign_tbl(org_idx).attribute14,
                   x_org_assign_tbl(org_idx).attribute15,
                   x_org_assign_tbl(org_idx).object_version_number
              FROM DUAL;
         END IF; --Org Assignments


----Populate Party
      FOR party_intf_rec IN party_intf_cur (inst_intf_rec.inst_interface_id)
      LOOP
         prty_idx :=   prty_idx
                     + 1;

         x_party_tbl (prty_idx).instance_party_id :=
                                              party_intf_rec.instance_party_id;
         x_party_tbl (prty_idx).instance_id := inst_intf_rec.instance_id;

         OPEN ip_obj_ver_cur (party_intf_rec.instance_party_id);
         FETCH ip_obj_ver_cur INTO l_party_object_version,
                                   l_last_update_date ;
         CLOSE ip_obj_ver_cur;
         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
 		fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
    		fnd_message.set_token('instance_id',inst_intf_rec.instance_id);
    		l_error_message := fnd_message.get;
                RAISE e_restriction;
         END IF;
         SELECT DECODE (
                   party_intf_rec.party_source_table,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_source_table
                ),
                DECODE (
                   party_intf_rec.party_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   party_intf_rec.party_id
                ),
                DECODE (
                   party_intf_rec.party_relationship_type_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_relationship_type_code
                ),
                DECODE (
                   party_intf_rec.contact_flag,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.contact_flag
                ),
                DECODE (
                   party_intf_rec.contact_ip_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   party_intf_rec.contact_ip_id
                ),
                DECODE (
                   party_intf_rec.party_start_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   party_intf_rec.party_start_date
                ),
                DECODE (
                   party_intf_rec.party_end_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   party_intf_rec.party_end_date
                ),
                DECODE (
                   party_intf_rec.party_context,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_context
                ),
                DECODE (
                   party_intf_rec.party_attribute1,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute1
                ),
                DECODE (
                   party_intf_rec.party_attribute2,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute2
                ),
                DECODE (
                   party_intf_rec.party_attribute3,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute3
                ),
                DECODE (
                   party_intf_rec.party_attribute4,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute4
                ),
                DECODE (
                   party_intf_rec.party_attribute5,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute5
                ),
                DECODE (
                   party_intf_rec.party_attribute6,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute6
                ),
                DECODE (
                   party_intf_rec.party_attribute7,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute7
                ),
                DECODE (
                   party_intf_rec.party_attribute8,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute8
                ),
                DECODE (
                   party_intf_rec.party_attribute9,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute9
                ),
                DECODE (
                   party_intf_rec.party_attribute10,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute10
                ),
                DECODE (
                   party_intf_rec.party_attribute11,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute11
                ),
                DECODE (
                   party_intf_rec.party_attribute12,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute12
                ),
                DECODE (
                   party_intf_rec.party_attribute13,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute13
                ),
                DECODE (
                   party_intf_rec.party_attribute14,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute14
                ),
                DECODE (
                   party_intf_rec.party_attribute15,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   party_intf_rec.party_attribute15
                ),
                l_party_object_version -- OBJECT_VERSION_NUMBER
           INTO x_party_tbl (prty_idx).party_source_table,
                x_party_tbl (prty_idx).party_id,
                x_party_tbl (prty_idx).relationship_type_code,
                x_party_tbl (prty_idx).contact_flag,
                x_party_tbl (prty_idx).contact_ip_id,
                x_party_tbl (prty_idx).active_start_date,
                x_party_tbl (prty_idx).active_end_date,
                x_party_tbl (prty_idx).CONTEXT,
                x_party_tbl (prty_idx).attribute1,
                x_party_tbl (prty_idx).attribute2,
                x_party_tbl (prty_idx).attribute3,
                x_party_tbl (prty_idx).attribute4,
                x_party_tbl (prty_idx).attribute5,
                x_party_tbl (prty_idx).attribute6,
                x_party_tbl (prty_idx).attribute7,
                x_party_tbl (prty_idx).attribute8,
                x_party_tbl (prty_idx).attribute9,
                x_party_tbl (prty_idx).attribute10,
                x_party_tbl (prty_idx).attribute11,
                x_party_tbl (prty_idx).attribute12,
                x_party_tbl (prty_idx).attribute13,
                x_party_tbl (prty_idx).attribute14,
                x_party_tbl (prty_idx).attribute15,
                x_party_tbl (prty_idx).object_version_number
           FROM DUAL;

              x_party_tbl (prty_idx).parent_tbl_index:=inst_idx;
           IF (x_party_tbl(prty_idx).contact_flag = 'Y'
               AND x_party_tbl(prty_idx).contact_ip_id IS NULL)
           THEN
                FOR i IN 1 .. prty_idx LOOP
                   IF (x_party_tbl(i).party_id = party_intf_rec.contact_party_id AND x_party_tbl(i).relationship_type_code = party_intf_rec.contact_party_rel_type)
                   THEN x_party_tbl(prty_idx).contact_parent_tbl_index := i;
                   END IF;
                   EXIT;
                END LOOP;
           END IF;

   ---Populate Party Account1
         IF party_intf_rec.party_account1_id IS NOT NULL
         THEN -- Put record in Table
            ptyacc_idx :=   ptyacc_idx
                          + 1;
            x_account_tbl (ptyacc_idx).ip_account_id :=
                                                party_intf_rec.ip_account1_id;
            x_account_tbl (ptyacc_idx).instance_party_id :=
                                             party_intf_rec.instance_party_id;
            x_account_tbl (ptyacc_idx).parent_tbl_index := prty_idx;
            OPEN ipa_obj_ver_cur (party_intf_rec.ip_account1_id);
            FETCH ipa_obj_ver_cur INTO l_ipa1_object_version,
                                       l_last_update_date;
            CLOSE ipa_obj_ver_cur;
         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
 		fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
    		fnd_message.set_token('instance_id',inst_intf_rec.instance_id);
    		l_error_message := fnd_message.get;
                RAISE e_restriction;
         END IF;
            x_account_tbl (ptyacc_idx).object_version_number :=
                                                        l_ipa1_object_version;

            SELECT DECODE (
                      party_intf_rec.party_account1_id,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.party_account1_id
                   ),
                   DECODE (
                      party_intf_rec.acct1_relationship_type_code,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.acct1_relationship_type_code
                   ),
                   DECODE (
                      party_intf_rec.bill_to_address1,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.bill_to_address1
                   ),
                   DECODE (
                      party_intf_rec.ship_to_address1,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.ship_to_address1
                   ),
                   l_miss_date, -- ACTIVE_START_DATE
                   DECODE (
                      party_intf_rec.party_acct1_end_date,
                      NULL, l_miss_date,
                      l_miss_date, NULL,
                      party_intf_rec.party_acct1_end_date
                   ),
                   DECODE (
                      party_intf_rec.account1_context,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_context
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute1,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute1
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute2,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute2
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute3,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute3
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute4,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute4
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute5,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute5
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute6,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute6
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute7,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute7
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute8,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute8
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute9,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute9
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute10,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute10
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute11,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute11
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute12,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute12
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute13,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute13
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute14,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute14
                   ),
                   DECODE (
                      party_intf_rec.account1_attribute15,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account1_attribute15
                   ),
                   fnd_api.g_false, --CALL_CONTRACTS
                   l_miss_num --VLD_ORGANIZATION_ID
              INTO x_account_tbl (ptyacc_idx).party_account_id,
                   x_account_tbl (ptyacc_idx).relationship_type_code,
                   x_account_tbl (ptyacc_idx).bill_to_address,
                   x_account_tbl (ptyacc_idx).ship_to_address,
                   x_account_tbl (ptyacc_idx).active_start_date,
                   x_account_tbl (ptyacc_idx).active_end_date,
                   x_account_tbl (ptyacc_idx).CONTEXT,
                   x_account_tbl (ptyacc_idx).attribute1,
                   x_account_tbl (ptyacc_idx).attribute2,
                   x_account_tbl (ptyacc_idx).attribute3,
                   x_account_tbl (ptyacc_idx).attribute4,
                   x_account_tbl (ptyacc_idx).attribute5,
                   x_account_tbl (ptyacc_idx).attribute6,
                   x_account_tbl (ptyacc_idx).attribute7,
                   x_account_tbl (ptyacc_idx).attribute8,
                   x_account_tbl (ptyacc_idx).attribute9,
                   x_account_tbl (ptyacc_idx).attribute10,
                   x_account_tbl (ptyacc_idx).attribute11,
                   x_account_tbl (ptyacc_idx).attribute12,
                   x_account_tbl (ptyacc_idx).attribute13,
                   x_account_tbl (ptyacc_idx).attribute14,
                   x_account_tbl (ptyacc_idx).attribute15,
                   x_account_tbl (ptyacc_idx).call_contracts,
                   x_account_tbl (ptyacc_idx).vld_organization_id
              FROM DUAL;
         END IF; ---party_account1

         ---Populate Party Account2
         IF party_intf_rec.party_account2_id IS NOT NULL
         THEN -- Put record in Table
            ptyacc_idx :=   ptyacc_idx
                          + 1;
            x_account_tbl (ptyacc_idx).ip_account_id :=
                                                party_intf_rec.ip_account2_id;
            x_account_tbl (ptyacc_idx).instance_party_id :=
                                             party_intf_rec.instance_party_id;
            x_account_tbl (ptyacc_idx).parent_tbl_index := prty_idx;
            OPEN ipa_obj_ver_cur (party_intf_rec.ip_account2_id);
            FETCH ipa_obj_ver_cur INTO l_ipa2_object_version,
                                       l_last_update_date;
            CLOSE ipa_obj_ver_cur;
         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
 		fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
    		fnd_message.set_token('instance_id',inst_intf_rec.instance_id);
    		l_error_message := fnd_message.get;
                RAISE e_restriction;
         END IF;
            x_account_tbl (ptyacc_idx).object_version_number :=
                                                        l_ipa2_object_version;

            SELECT DECODE (
                      party_intf_rec.party_account2_id,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.party_account2_id
                   ),
                   DECODE (
                      party_intf_rec.acct2_relationship_type_code,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.acct2_relationship_type_code
                   ),
                   DECODE (
                      party_intf_rec.bill_to_address2,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.bill_to_address2
                   ),
                   DECODE (
                      party_intf_rec.ship_to_address2,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.ship_to_address2
                   ),
                   l_miss_date, -- ACTIVE_START_DATE
                   DECODE (
                      party_intf_rec.party_acct2_end_date,
                      NULL, l_miss_date,
                      l_miss_date, NULL,
                      party_intf_rec.party_acct2_end_date
                   ),
                   DECODE (
                      party_intf_rec.account2_context,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_context
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute1,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute1
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute2,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute2
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute3,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute3
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute4,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute4
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute5,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute5
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute6,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute6
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute7,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute7
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute8,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute8
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute9,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute9
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute10,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute10
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute11,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute11
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute12,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute12
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute13,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute13
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute14,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute14
                   ),
                   DECODE (
                      party_intf_rec.account2_attribute15,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account2_attribute15
                   ),
                   fnd_api.g_false, --CALL_CONTRACTS
                   l_miss_num --VLD_ORGANIZATION_ID
              INTO x_account_tbl (ptyacc_idx).party_account_id,
                   x_account_tbl (ptyacc_idx).relationship_type_code,
                   x_account_tbl (ptyacc_idx).bill_to_address,
                   x_account_tbl (ptyacc_idx).ship_to_address,
                   x_account_tbl (ptyacc_idx).active_start_date,
                   x_account_tbl (ptyacc_idx).active_end_date,
                   x_account_tbl (ptyacc_idx).CONTEXT,
                   x_account_tbl (ptyacc_idx).attribute1,
                   x_account_tbl (ptyacc_idx).attribute2,
                   x_account_tbl (ptyacc_idx).attribute3,
                   x_account_tbl (ptyacc_idx).attribute4,
                   x_account_tbl (ptyacc_idx).attribute5,
                   x_account_tbl (ptyacc_idx).attribute6,
                   x_account_tbl (ptyacc_idx).attribute7,
                   x_account_tbl (ptyacc_idx).attribute8,
                   x_account_tbl (ptyacc_idx).attribute9,
                   x_account_tbl (ptyacc_idx).attribute10,
                   x_account_tbl (ptyacc_idx).attribute11,
                   x_account_tbl (ptyacc_idx).attribute12,
                   x_account_tbl (ptyacc_idx).attribute13,
                   x_account_tbl (ptyacc_idx).attribute14,
                   x_account_tbl (ptyacc_idx).attribute15,
                   x_account_tbl (ptyacc_idx).call_contracts,
                   x_account_tbl (ptyacc_idx).vld_organization_id
              FROM DUAL;
         END IF; ---party_account2

         ---Populate Party Account3
         IF party_intf_rec.party_account3_id IS NOT NULL
         THEN -- Put record in Table
            ptyacc_idx :=   ptyacc_idx
                          + 1;
            x_account_tbl (ptyacc_idx).ip_account_id :=
                                                party_intf_rec.ip_account3_id;
            x_account_tbl (ptyacc_idx).instance_party_id :=
                                             party_intf_rec.instance_party_id;
            x_account_tbl (ptyacc_idx).parent_tbl_index := prty_idx;
            OPEN ipa_obj_ver_cur (party_intf_rec.ip_account3_id);
            FETCH ipa_obj_ver_cur INTO l_ipa3_object_version,
                                       l_last_update_date;
            CLOSE ipa_obj_ver_cur;
         IF l_last_update_date > inst_intf_rec.source_transaction_date
         THEN
 		fnd_message.set_name('CSI','CSI_INTERFACE_RESTRICTION');
    		fnd_message.set_token('instance_id',inst_intf_rec.instance_id);
    		l_error_message := fnd_message.get;
                RAISE e_restriction;
         END IF;
            x_account_tbl (ptyacc_idx).object_version_number :=
                                                        l_ipa3_object_version;

            SELECT DECODE (
                      party_intf_rec.party_account3_id,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.party_account3_id
                   ),
                   DECODE (
                      party_intf_rec.acct3_relationship_type_code,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.acct3_relationship_type_code
                   ),
                   DECODE (
                      party_intf_rec.bill_to_address3,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.bill_to_address3
                   ),
                   DECODE (
                      party_intf_rec.ship_to_address3,
                      NULL, l_miss_num,
                      l_miss_num, NULL,
                      party_intf_rec.ship_to_address3
                   ),
                   l_miss_date, -- ACTIVE_START_DATE
                   DECODE (
                      party_intf_rec.party_acct3_end_date,
                      NULL, l_miss_date,
                      l_miss_date, NULL,
                      party_intf_rec.party_acct3_end_date
                   ),
                   DECODE (
                      party_intf_rec.account3_context,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_context
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute1,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute1
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute2,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute2
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute3,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute3
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute4,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute4
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute5,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute5
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute6,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute6
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute7,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute7
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute8,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute8
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute9,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute9
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute10,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute10
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute11,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute11
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute12,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute12
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute13,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute13
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute14,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute14
                   ),
                   DECODE (
                      party_intf_rec.account3_attribute15,
                      NULL, l_miss_char,
                      l_miss_char, NULL,
                      party_intf_rec.account3_attribute15
                   ),
                   fnd_api.g_false, --CALL_CONTRACTS
                   l_miss_num --VLD_ORGANIZATION_ID
              INTO x_account_tbl (ptyacc_idx).party_account_id,
                   x_account_tbl (ptyacc_idx).relationship_type_code,
                   x_account_tbl (ptyacc_idx).bill_to_address,
                   x_account_tbl (ptyacc_idx).ship_to_address,
                   x_account_tbl (ptyacc_idx).active_start_date,
                   x_account_tbl (ptyacc_idx).active_end_date,
                   x_account_tbl (ptyacc_idx).CONTEXT,
                   x_account_tbl (ptyacc_idx).attribute1,
                   x_account_tbl (ptyacc_idx).attribute2,
                   x_account_tbl (ptyacc_idx).attribute3,
                   x_account_tbl (ptyacc_idx).attribute4,
                   x_account_tbl (ptyacc_idx).attribute5,
                   x_account_tbl (ptyacc_idx).attribute6,
                   x_account_tbl (ptyacc_idx).attribute7,
                   x_account_tbl (ptyacc_idx).attribute8,
                   x_account_tbl (ptyacc_idx).attribute9,
                   x_account_tbl (ptyacc_idx).attribute10,
                   x_account_tbl (ptyacc_idx).attribute11,
                   x_account_tbl (ptyacc_idx).attribute12,
                   x_account_tbl (ptyacc_idx).attribute13,
                   x_account_tbl (ptyacc_idx).attribute14,
                   x_account_tbl (ptyacc_idx).attribute15,
                   x_account_tbl (ptyacc_idx).call_contracts,
                   x_account_tbl (ptyacc_idx).vld_organization_id
              FROM DUAL;
         END IF; ---party_account3

           IF party_intf_rec.contact_party_id IS NOT NULL AND
              party_intf_rec.contact_party_id <> fnd_api.g_miss_num
           THEN
             prty_idx:=prty_idx + 1;
             x_party_tbl(prty_idx).instance_party_id:=fnd_api.g_miss_num;
             x_party_tbl(prty_idx).instance_id:=inst_intf_rec.instance_id;
             x_party_tbl(prty_idx).party_source_table:=party_intf_rec.party_source_table;
             x_party_tbl(prty_idx).party_id:=party_intf_rec.contact_party_id;
             x_party_tbl(prty_idx).relationship_type_code:=party_intf_rec.contact_party_rel_type;
             x_party_tbl(prty_idx).contact_flag:='Y';
             x_party_tbl(prty_idx).contact_parent_tbl_index:=prty_idx-1;
             x_party_tbl(prty_idx).parent_tbl_index:=inst_idx;
             x_party_tbl(prty_idx).contact_ip_id:=party_intf_rec.instance_party_id ;
           END IF;

      END LOOP; ---party_intf_cur


    ---Populate Extended Attributes

      FOR ext_attrib_intf_rec IN ext_attrib_intf_cur (inst_intf_rec.inst_interface_id)
      LOOP
         extatt_idx :=   extatt_idx
                       + 1;

         SELECT DECODE (
                   inst_intf_rec.instance_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   inst_intf_rec.instance_id
                ),
                DECODE (
                   ext_attrib_intf_rec.attribute_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   ext_attrib_intf_rec.attribute_id
                ),
                DECODE (
                   ext_attrib_intf_rec.attribute_value_id,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   ext_attrib_intf_rec.attribute_value_id
                ),
                DECODE (
                   ext_attrib_intf_rec.attribute_code,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   ext_attrib_intf_rec.attribute_code
                ),
                DECODE (
                   ext_attrib_intf_rec.attribute_value,
                   NULL, l_miss_char,
                   l_miss_char, NULL,
                   ext_attrib_intf_rec.attribute_value
                ),
                l_miss_date, -- ACTIVE_START_DATE
                DECODE (
                   ext_attrib_intf_rec.ieav_end_date,
                   NULL, l_miss_date,
                   l_miss_date, NULL,
                   ext_attrib_intf_rec.ieav_end_date
                ),
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                l_miss_char,
                DECODE (
                   ext_attrib_intf_rec.ieav_object_ver_num,
                   NULL, l_miss_num,
                   l_miss_num, NULL,
                   ext_attrib_intf_rec.ieav_object_ver_num
                )
           -- OBJECT_VERSION_NUMBER
           INTO x_ext_attrib_value_tbl (extatt_idx).instance_id,
                x_ext_attrib_value_tbl (extatt_idx).attribute_id,
                x_ext_attrib_value_tbl (extatt_idx).attribute_value_id,
                x_ext_attrib_value_tbl (extatt_idx).attribute_code,
                x_ext_attrib_value_tbl (extatt_idx).attribute_value,
                x_ext_attrib_value_tbl (extatt_idx).active_start_date,
                x_ext_attrib_value_tbl (extatt_idx).active_end_date,
                x_ext_attrib_value_tbl (extatt_idx).CONTEXT,
                x_ext_attrib_value_tbl (extatt_idx).attribute1,
                x_ext_attrib_value_tbl (extatt_idx).attribute2,
                x_ext_attrib_value_tbl (extatt_idx).attribute3,
                x_ext_attrib_value_tbl (extatt_idx).attribute4,
                x_ext_attrib_value_tbl (extatt_idx).attribute5,
                x_ext_attrib_value_tbl (extatt_idx).attribute6,
                x_ext_attrib_value_tbl (extatt_idx).attribute7,
                x_ext_attrib_value_tbl (extatt_idx).attribute8,
                x_ext_attrib_value_tbl (extatt_idx).attribute9,
                x_ext_attrib_value_tbl (extatt_idx).attribute10,
                x_ext_attrib_value_tbl (extatt_idx).attribute11,
                x_ext_attrib_value_tbl (extatt_idx).attribute12,
                x_ext_attrib_value_tbl (extatt_idx).attribute13,
                x_ext_attrib_value_tbl (extatt_idx).attribute14,
                x_ext_attrib_value_tbl (extatt_idx).attribute15,
                x_ext_attrib_value_tbl (extatt_idx).object_version_number
           FROM DUAL;
      END LOOP; ---ext_attrib_intf_cur

      --bnarayan added for R12
	 -- Populate asset records

		FOR asset_attrib_intf_rec IN asset_attrib_intf_cur (inst_intf_rec.inst_interface_id, inst_intf_rec.instance_id)
		LOOP

		 IF asset_attrib_intf_rec.csia_instance_asset_id IS NULL THEN
                     x_asset_assignment_tbl( asset_idx ).instance_asset_id := l_miss_num;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).instance_asset_id := asset_attrib_intf_rec.csia_instance_asset_id ;
	         END IF;

		 IF inst_intf_rec.instance_id IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).instance_id := l_miss_num;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).instance_id := inst_intf_rec.instance_id ;
	         END IF;

		 IF asset_attrib_intf_rec.fa_asset_id IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).fa_asset_id := l_miss_num;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).fa_asset_id := asset_attrib_intf_rec.fa_asset_id ;
	         END IF;

		 IF asset_attrib_intf_rec.fa_book_type_code IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).fa_book_type_code := l_miss_char;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).fa_book_type_code := asset_attrib_intf_rec.fa_book_type_code;
	         END IF;

		 IF asset_attrib_intf_rec.fa_location_id IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).fa_location_id :=l_miss_num;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).fa_location_id := asset_attrib_intf_rec.fa_location_id ;
	         END IF;

		 IF asset_attrib_intf_rec.asset_quantity IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).asset_quantity := l_miss_num;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).asset_quantity := asset_attrib_intf_rec.asset_quantity ;
	         END IF;

		 IF asset_attrib_intf_rec.update_status IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).update_status :=l_miss_char;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).update_status := asset_attrib_intf_rec.update_status ;
	         END IF;

		 IF asset_attrib_intf_rec.active_start_date IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).active_start_date := l_miss_date;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).active_start_date := asset_attrib_intf_rec.active_start_date ;
	         END IF;

		 IF asset_attrib_intf_rec.active_end_date  IS NULL THEN
	                x_asset_assignment_tbl( asset_idx ).active_end_date  := l_miss_date;
	         ELSE
	                x_asset_assignment_tbl( asset_idx ).active_end_date  := asset_attrib_intf_rec.active_end_date;
	         END IF;

		   x_asset_assignment_tbl( asset_idx ).fa_sync_flag :=asset_attrib_intf_rec.fa_sync_flag;
                   x_asset_assignment_tbl( asset_idx ).object_version_number:=asset_attrib_intf_rec.asset_object_ver_num;
		   x_asset_assignment_tbl( asset_idx ).parent_tbl_index     :=inst_idx;
		   asset_idx             := asset_idx    + 1; -- Increment asset index

		 END LOOP; --end of asset loop
        -- Start code addition for bug 6368180, section 2 of 2
        END IF; ---IF inst_intf_rec.instance_id <> fnd_api.g_miss_num
        -- End code addition for bug 6368180, section 2 of 2
      END LOOP; ---inst_intf_cur
   EXCEPTION
      WHEN e_restriction
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         x_error_message := l_error_message;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_error_message := SQLERRM;

   END populate_recs;

END csi_ml_update_pvt;


/
