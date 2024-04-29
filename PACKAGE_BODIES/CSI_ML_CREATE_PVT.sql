--------------------------------------------------------
--  DDL for Package Body CSI_ML_CREATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_CREATE_PVT" AS
-- $Header: csimcrtb.pls 120.13 2007/11/27 02:33:12 anjgupta ship $

PROCEDURE get_iface_create_recs
 (
   p_txn_from_date         IN  VARCHAR2,
   p_txn_to_date           IN  VARCHAR2,
   p_source_system_name    IN  VARCHAR2,
   p_worker_id             IN  NUMBER,
   p_commit_recs           IN  NUMBER,
   p_instance_tbl          OUT NOCOPY CSI_DATASTRUCTURES_PUB.INSTANCE_TBL,
   p_party_tbl             OUT NOCOPY CSI_DATASTRUCTURES_PUB.PARTY_TBL,
   p_account_tbl           OUT NOCOPY CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL,
   p_ext_attrib_tbl        OUT NOCOPY CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL,
   p_price_tbl             OUT NOCOPY CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL,
   p_org_assign_tbl        OUT NOCOPY CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL,
   p_txn_tbl               OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL,
   p_party_contact_tbl     OUT NOCOPY CSI_ML_UTIL_PVT.PARTY_CONTACT_TBL_TYPE,
   x_asset_assignment_tbl  OUT NOCOPY csi_datastructures_pub.instance_asset_tbl,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_error_message         OUT NOCOPY VARCHAR2) IS

   inst_idx                PLS_INTEGER;
   prty_idx                PLS_INTEGER;
   ptyacc_idx              PLS_INTEGER;
   extatt_idx              PLS_INTEGER;
   orgass_idx              PLS_INTEGER;
   price_idx               PLS_INTEGER;
   txn_idx                 PLS_INTEGER;
   prty_contact_idx        PLS_INTEGER;
   asset_idx               PLS_INTEGER; --bnarayan added for open interface
   l_fnd_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_error             VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_fnd_g_num             NUMBER      := FND_API.G_MISS_NUM;
   l_fnd_g_char            VARCHAR2(1) := FND_API.G_MISS_CHAR;
   l_fnd_g_date            DATE        := FND_API.G_MISS_DATE;
   l_fnd_g_true            VARCHAR2(1) := FND_API.G_TRUE;
   l_api_name              VARCHAR2(255) :=
                               'CSI_ML_CREATE_PVT.GET_IFACE_CREATE_RECS';

   l_sql_error             VARCHAR2(2000);
   l_commit_recs           NUMBER := 0;
   l_txn_type_id           NUMBER;
   l_error_message         VARCHAR2(2000);

   a     NUMBER := 0;
   b     NUMBER := 0;
   c     NUMBER := 0;
   d     NUMBER := 0;
   e     NUMBER := 0;
   f     NUMBER := 0;
   g     NUMBER := 0;
   h     NUMBER := 0;
   l_debug_level  NUMBER := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

   CURSOR c_inst (pc_txn_from_date      IN DATE,
	          pc_txn_to_date        IN DATE,
                  pc_source_system_name IN VARCHAR2,
                  pc_worker_id          IN NUMBER DEFAULT NULL,
                  pc_commit_recs        IN NUMBER) IS
     SELECT cii.*
     FROM   csi_instance_interface       cii
     WHERE  trunc(cii.source_transaction_date) between
                          nvl(pc_txn_from_date,trunc(cii.source_transaction_date)) and
                          nvl(pc_txn_to_date,trunc(cii.source_transaction_date))
     AND cii.process_status = 'X'
     AND source_system_name = nvl(pc_source_system_name,source_system_name)
     AND nvl(parallel_worker_id,-1) = nvl(pc_worker_id,nvl(parallel_worker_id,-1))
     AND rownum <= pc_commit_recs;

     r_inst      c_inst%rowtype;

   CURSOR c_prty (pc_interface_id in NUMBER) IS
     SELECT cpi.*
     FROM   csi_i_party_interface          cpi
     WHERE  cpi.inst_interface_id = pc_interface_id;

     r_prty      c_prty%rowtype;

   CURSOR c_attr (pc_interface_id in NUMBER) IS
     SELECT ceai.*
     FROM   csi_iea_value_interface     ceai
     WHERE  ceai.inst_interface_id = pc_interface_id;

	--bnarayan added for open interface
    CURSOR c_assets(pc_interface_id in NUMBER) IS
     SELECT csia.*
     FROM   csi_i_asset_interface     csia
     WHERE  csia.inst_interface_id = pc_interface_id;

     r_attr      c_attr%rowtype;
     l_int_party        NUMBER;
     l_txn_from_date date := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
     l_txn_to_date   date := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
   BEGIN

     inst_idx              := 1;
     prty_idx              := 1;
     ptyacc_idx            := 1;
     extatt_idx            := 1;
     price_idx             := 1;
     orgass_idx            := 1;
     prty_contact_idx      := 1;
     asset_idx             := 1;
     x_return_status       := l_fnd_success;

     -- Since all Transations are Open Interface get the ID 1 time.
     l_txn_type_id := csi_ml_util_pvt.get_txn_type_id('OPEN_INTERFACE','CSI');

     BEGIN
        SELECT internal_party_id
        INTO   l_int_party
        FROM  csi_install_parameters;
     EXCEPTION
       WHEN OTHERS THEN
         null;
     END;

     BEGIN
      fnd_message.set_name('CSI','CSI_INTERFACE_LOC_TYPE_CODE');
      l_error_message := fnd_message.get;

      UPDATE CSI_INSTANCE_INTERFACE cii
      SET    error_text =l_error_message
            ,process_status ='E'
      WHERE nvl(parallel_worker_id,-1) = nvl(p_worker_id,nvl(parallel_worker_id,-1))
      AND   cii.process_status = 'X'
      AND   cii.source_system_name = p_source_system_name
      AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
      AND   cii.location_type_code in ('INVENTORY','PO','IN_TRANSIT','WIP','PROJECT');

      IF SQL%FOUND THEN
        l_error_message := l_error_message||' Total Rows in this error : '||SQL%ROWCOUNT ;
        FND_File.Put_Line(Fnd_File.LOG, l_error_message );
      END IF;

      fnd_message.set_name('CSI','CSI_ML_NO_ASSET_FOR_CT');
      l_error_message := fnd_message.get;

      UPDATE CSI_INSTANCE_INTERFACE cii
      SET    error_text =l_error_message
            ,process_status ='E'
      WHERE nvl(parallel_worker_id,-1) = nvl(p_worker_id,nvl(parallel_worker_id,-1))
      AND   cii.process_status = 'X'
      AND   cii.source_system_name = p_source_system_name
      AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
      AND   exists ( SELECT 1
                     FROM   csi_i_party_interface cipi
                           ,csi_i_asset_interface ciai
                     WHERE  cipi.inst_interface_id = ciai.inst_interface_id
                     AND    cipi.inst_interface_id = cii.inst_interface_id
                     AND    nvl(cipi.party_id,0) <> l_int_party
                     AND    cipi.party_relationship_type_code = 'OWNER'
                   );

      IF SQL%FOUND THEN
        l_error_message := l_error_message||' Total Rows in this error : '||SQL%ROWCOUNT ;
        FND_File.Put_Line(Fnd_File.LOG, l_error_message );
      END IF;

        fnd_message.set_name('CSI','CSI_NO_ASSET_ASSN_FOUND');
        l_error_message  := fnd_message.get;

      UPDATE CSI_INSTANCE_INTERFACE cii
      SET    error_text =l_error_message
            ,process_status ='E'
      WHERE nvl(parallel_worker_id,-1) = nvl(p_worker_id,nvl(parallel_worker_id,-1))
      AND   cii.process_status = 'X'
      AND   cii.source_system_name = p_source_system_name
      AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
      AND   exists (SELECT 1
                         FROM csi_i_asset_interface ciai
                        WHERE cii.inst_interface_id = ciai.inst_interface_id
                          AND ciai.fa_asset_id IS NULL
                          AND ciai.fa_asset_number IS NULL
                         );

        IF SQL%FOUND THEN
           FND_File.Put_Line(Fnd_File.LOG, l_error_message ||' Total Rows in this error : '||SQL%ROWCOUNT);
        END IF;



      fnd_message.set_name('CSI','CSI_API_ASSET_REQUIRED');
      l_error_message := fnd_message.get;

      UPDATE CSI_INSTANCE_INTERFACE cii
      SET    error_text =l_error_message
            ,process_status ='E'
      WHERE nvl(parallel_worker_id,-1) = nvl(p_worker_id,nvl(parallel_worker_id,-1))
      AND   cii.process_status = 'X'
      AND   cii.source_system_name = p_source_system_name
      AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
      AND   cii.location_type_code  IN ('HZ_PARTY_SITES','HZ_LOCATIONS')
      AND   (exists (SELECT 1
                    FROM   csi_i_party_interface cipi
                    WHERE  cipi.inst_interface_id = cii.inst_interface_id
                    AND    nvl(cipi.party_id,0) = l_int_party
                    AND    cipi.party_relationship_type_code = 'OWNER'
                   )
              AND   not exists (SELECT 1
                                FROM csi_i_asset_interface ciai
                                WHERE  cii.inst_interface_id = ciai.inst_interface_id
                         ));

      IF SQL%FOUND THEN
        l_error_message := l_error_message||' Total Rows in this error : '||SQL%ROWCOUNT ;
        FND_File.Put_Line(Fnd_File.LOG, l_error_message );
      END IF;

     END;

     FOR r_inst IN c_inst (l_txn_from_date,
                           l_txn_to_date,
                           p_source_system_name,
                           p_worker_id,
                           p_commit_recs) LOOP

       -- Set each column of the PL/SQL Record

       IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

         p_instance_tbl(inst_idx).instance_id       := null;
         p_instance_tbl(inst_idx).instance_number   := null;
         p_instance_tbl(inst_idx).inventory_item_id := r_inst.inventory_item_id;
         --p_instance_tbl(inst_idx).external_reference :=  l_fnd_g_char;
         -- added for bug 3453916
         p_instance_tbl(inst_idx).external_reference := r_inst.external_reference;


         IF r_inst.inst_interface_id IS NULL THEN
          p_instance_tbl(inst_idx).interface_id := l_fnd_g_num;
         ELSE
          p_instance_tbl(inst_idx).interface_id := r_inst.inst_interface_id;
         END IF;
/*
         IF r_inst.inv_vld_organization_id IS NULL THEN
           p_instance_tbl(inst_idx).inv_master_organization_id := l_fnd_g_num;
         ELSE
          p_instance_tbl(inst_idx).inv_master_organization_id :=
               r_inst.inv_vld_organization_id;
         END IF;
*/  -- Code commented for bug 3347509
         IF r_inst.inv_vld_organization_id IS NULL THEN
           p_instance_tbl(inst_idx).vld_organization_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).vld_organization_id := r_inst.inv_vld_organization_id;
         END IF;

         IF r_inst.location_type_code IS NULL THEN
           p_instance_tbl(inst_idx).location_type_code := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).location_type_code := r_inst.location_type_code;
         END IF;

         IF r_inst.location_id IS NULL THEN
           p_instance_tbl(inst_idx).location_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).location_id :=  r_inst.location_id;
         END IF;

         IF r_inst.inv_organization_id IS NULL THEN
           p_instance_tbl(inst_idx).inv_organization_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).inv_organization_id := r_inst.inv_organization_id;
         END IF;

         IF r_inst.inv_subinventory_name IS NULL THEN
           p_instance_tbl(inst_idx).inv_subinventory_name := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).inv_subinventory_name :=  r_inst.inv_subinventory_name;
         END IF;

         IF r_inst.inv_locator_id IS NULL THEN
           p_instance_tbl(inst_idx).inv_locator_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).inv_locator_id := r_inst.inv_locator_id;
         END IF;

         IF r_inst.lot_number IS NULL THEN
           p_instance_tbl(inst_idx).lot_number := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).lot_number := r_inst.lot_number;
         END IF;

         IF r_inst.project_id IS NULL THEN
           p_instance_tbl(inst_idx).pa_project_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).pa_project_id := r_inst.project_id;
         END IF;

         IF r_inst.task_id IS NULL THEN
           p_instance_tbl(inst_idx).pa_project_task_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).pa_project_task_id := r_inst.task_id;
         END IF;

         IF r_inst.in_transit_order_line_id IS NULL THEN
           p_instance_tbl(inst_idx).in_transit_order_line_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).in_transit_order_line_id := r_inst.in_transit_order_line_id;
         END IF;

         IF r_inst.wip_job_id IS NULL THEN
           p_instance_tbl(inst_idx).wip_job_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).wip_job_id := r_inst.wip_job_id;
         END IF;

         IF r_inst.po_order_line_id IS NULL THEN
           p_instance_tbl(inst_idx).po_order_line_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).po_order_line_id := r_inst.po_order_line_id;
         END IF;

         IF r_inst.inventory_revision IS NULL THEN
           p_instance_tbl(inst_idx).inventory_revision := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).inventory_revision := r_inst.inventory_revision;
         END IF;

         IF r_inst.serial_number IS NULL THEN
           p_instance_tbl(inst_idx).serial_number  := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).serial_number := r_inst.serial_number;
         END IF;

         IF r_inst.mfg_serial_number_flag IS NULL THEN
           p_instance_tbl(inst_idx).mfg_serial_number_flag := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).mfg_serial_number_flag := r_inst.mfg_serial_number_flag;
         END IF;

         IF r_inst.quantity IS NULL THEN
           p_instance_tbl(inst_idx).quantity := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).quantity := r_inst.quantity;
         END IF;

         IF r_inst.unit_of_measure_code IS NULL THEN
           p_instance_tbl(inst_idx).unit_of_measure := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).unit_of_measure := r_inst.unit_of_measure_code;
         END IF;

         IF r_inst.accounting_class_code IS NULL THEN
           p_instance_tbl(inst_idx).accounting_class_code  := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).accounting_class_code := r_inst.accounting_class_code;
         END IF;

         IF r_inst.instance_condition_id IS NULL THEN
           p_instance_tbl(inst_idx).instance_condition_id  := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).instance_condition_id := r_inst.instance_condition_id;
         END IF;

         IF r_inst.instance_status_id IS NULL THEN
           p_instance_tbl(inst_idx).instance_status_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).instance_status_id := r_inst.instance_status_id;
         END IF;

         IF r_inst.customer_view_flag IS NULL THEN
           p_instance_tbl(inst_idx).customer_view_flag  := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).customer_view_flag := r_inst.customer_view_flag;
         END IF;

         IF r_inst.merchant_view_flag IS NULL THEN
           p_instance_tbl(inst_idx).merchant_view_flag  := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).merchant_view_flag := r_inst.merchant_view_flag;
         END IF;

         IF r_inst.sellable_flag IS NULL THEN
           p_instance_tbl(inst_idx).sellable_flag := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).sellable_flag := r_inst.sellable_flag;
         END IF;

         IF r_inst.system_id IS NULL THEN
           p_instance_tbl(inst_idx).system_id  := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).system_id := r_inst.system_id ;
         END IF;

         IF r_inst.instance_type_code IS NULL THEN
           p_instance_tbl(inst_idx).instance_type_code := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).instance_type_code := r_inst.instance_type_code;
         END IF;

         IF r_inst.instance_end_date IS NULL THEN
           p_instance_tbl(inst_idx).active_end_date  := l_fnd_g_date;
         ELSE
           p_instance_tbl(inst_idx).active_end_date := r_inst.instance_end_date;
         END IF;

         IF r_inst.instance_start_date IS NULL THEN
           p_instance_tbl(inst_idx).active_start_date  := l_fnd_g_date;
         ELSE
           p_instance_tbl(inst_idx).active_start_date := r_inst.instance_start_date;
         END IF;
   -- Added

         IF r_inst.oe_order_line_id IS NULL THEN
           p_instance_tbl(inst_idx).last_oe_order_line_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).last_oe_order_line_id := r_inst.oe_order_line_id;
         END IF;

         IF r_inst.oe_rma_line_id IS NULL THEN
           p_instance_tbl(inst_idx).last_oe_rma_line_id := l_fnd_g_num;
         ELSE
           p_instance_tbl(inst_idx).last_oe_rma_line_id := r_inst.oe_rma_line_id;
         END IF;
   -- End addition

       --  p_instance_tbl(inst_idx).LAST_OE_ORDER_LINE_ID := l_fnd_g_num;   -- LAST_OE_ORDER_LINE_ID

        -- p_instance_tbl(inst_idx).last_oe_rma_line_id   :=l_fnd_g_num;  -- last_oe_rma_line_id
         p_instance_tbl(inst_idx).last_po_po_line_id    :=l_fnd_g_num;   -- last_po_po_line_id
         p_instance_tbl(inst_idx).last_oe_po_number     :=l_fnd_g_char;  -- last_oe_po_number
         p_instance_tbl(inst_idx).last_wip_job_id       :=l_fnd_g_num;   -- last_wip_job_id
         p_instance_tbl(inst_idx).last_pa_project_id    := l_fnd_g_num;   -- last_pa_project_id
         p_instance_tbl(inst_idx).last_pa_task_id       :=l_fnd_g_num;   -- last_pa_task_id
         p_instance_tbl(inst_idx).last_oe_agreement_id  :=l_fnd_g_num;   -- last_oe_agreement_id

         IF r_inst.install_date IS NULL THEN
           p_instance_tbl(inst_idx).install_date := l_fnd_g_date;
         ELSE
           p_instance_tbl(inst_idx).install_date := r_inst.install_date;
         END IF;

         p_instance_tbl(inst_idx).manually_created_flag := l_fnd_g_char;  -- manually_created_flag

         IF r_inst.return_by_date IS NULL THEN
           p_instance_tbl(inst_idx).return_by_date := l_fnd_g_date;
         ELSE
           p_instance_tbl(inst_idx).return_by_date := r_inst.return_by_date;
         END IF;

         IF r_inst.actual_return_date IS NULL THEN
           p_instance_tbl(inst_idx).actual_return_date := l_fnd_g_date;
         ELSE
           p_instance_tbl(inst_idx).actual_return_date := r_inst.actual_return_date;
         END IF;

         p_instance_tbl(inst_idx).creation_complete_flag := l_fnd_g_char;  --creation_complete_flag
         p_instance_tbl(inst_idx).completeness_flag := l_fnd_g_char;  --completeness_flag
         p_instance_tbl(inst_idx).version_label := l_fnd_g_char;  --version_label
         p_instance_tbl(inst_idx).version_label_description := l_fnd_g_char;  --version_label_description

         IF r_inst.instance_context IS NULL THEN
           p_instance_tbl(inst_idx).context := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).context := r_inst.instance_context;
         END IF;

         IF r_inst.instance_attribute1 IS NULL THEN
           p_instance_tbl(inst_idx).attribute1 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute1 := r_inst.instance_attribute1;
         END IF;

         IF r_inst.instance_attribute2 IS NULL THEN
           p_instance_tbl(inst_idx).attribute2 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute2 := r_inst.instance_attribute2;
         END IF;

         IF r_inst.instance_attribute3 IS NULL THEN
           p_instance_tbl(inst_idx).attribute3 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute3 := r_inst.instance_attribute3;
         END IF;

         IF r_inst.instance_attribute4 IS NULL THEN
           p_instance_tbl(inst_idx).attribute4 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute4 := r_inst.instance_attribute4;
         END IF;

         IF r_inst.instance_attribute5 IS NULL THEN
           p_instance_tbl(inst_idx).attribute5 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute5 := r_inst.instance_attribute5;
         END IF;

         IF r_inst.instance_attribute6 IS NULL THEN
           p_instance_tbl(inst_idx).attribute6 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute6 := r_inst.instance_attribute6;
         END IF;

         IF r_inst.instance_attribute7 IS NULL THEN
           p_instance_tbl(inst_idx).attribute7 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute7 := r_inst.instance_attribute7;
         END IF;

         IF r_inst.instance_attribute8 IS NULL THEN
           p_instance_tbl(inst_idx).attribute8 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute8 := r_inst.instance_attribute8;
         END IF;

         IF r_inst.instance_attribute9 IS NULL THEN
           p_instance_tbl(inst_idx).attribute9 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute9 := r_inst.instance_attribute9;
         END IF;

         IF r_inst.instance_attribute10 IS NULL THEN
           p_instance_tbl(inst_idx).attribute10 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute10 := r_inst.instance_attribute10;
         END IF;

         IF r_inst.instance_attribute11 IS NULL THEN
           p_instance_tbl(inst_idx).attribute11 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute11 := r_inst.instance_attribute11;
         END IF;

         IF r_inst.instance_attribute12 IS NULL THEN
           p_instance_tbl(inst_idx).attribute12 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute12:= r_inst.instance_attribute12;
         END IF;

         IF r_inst.instance_attribute13 IS NULL THEN
           p_instance_tbl(inst_idx).attribute13 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute13:= r_inst.instance_attribute13;
         END IF;

         IF r_inst.instance_attribute14 IS NULL THEN
           p_instance_tbl(inst_idx).attribute14 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute14:= r_inst.instance_attribute14;
         END IF;

         IF r_inst.instance_attribute15 IS NULL THEN
           p_instance_tbl(inst_idx).attribute15 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute15 := r_inst.instance_attribute15;
         END IF;

	 IF r_inst.instance_attribute16 IS NULL THEN
           p_instance_tbl(inst_idx).attribute16 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute16 := r_inst.instance_attribute16;
         END IF;

	 IF r_inst.instance_attribute17 IS NULL THEN
           p_instance_tbl(inst_idx).attribute17 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute17 := r_inst.instance_attribute17;
         END IF;

	IF r_inst.instance_attribute18 IS NULL THEN
           p_instance_tbl(inst_idx).attribute18 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute18 := r_inst.instance_attribute18;
         END IF;

	IF r_inst.instance_attribute19 IS NULL THEN
           p_instance_tbl(inst_idx).attribute19 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute19 := r_inst.instance_attribute19;
         END IF;

	IF r_inst.instance_attribute20 IS NULL THEN
           p_instance_tbl(inst_idx).attribute20 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute20 := r_inst.instance_attribute20;
         END IF;

	IF r_inst.instance_attribute21 IS NULL THEN
           p_instance_tbl(inst_idx).attribute21 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute21 := r_inst.instance_attribute21;
         END IF;

	IF r_inst.instance_attribute22 IS NULL THEN
           p_instance_tbl(inst_idx).attribute22 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute22 := r_inst.instance_attribute22;
         END IF;

	IF r_inst.instance_attribute23 IS NULL THEN
           p_instance_tbl(inst_idx).attribute23 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute23 := r_inst.instance_attribute23;
         END IF;

	IF r_inst.instance_attribute24 IS NULL THEN
           p_instance_tbl(inst_idx).attribute24 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute24 := r_inst.instance_attribute24;
         END IF;

	IF r_inst.instance_attribute25 IS NULL THEN
           p_instance_tbl(inst_idx).attribute25 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute25 := r_inst.instance_attribute25;
         END IF;

	IF r_inst.instance_attribute26 IS NULL THEN
           p_instance_tbl(inst_idx).attribute26 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute26 := r_inst.instance_attribute26;
         END IF;

	IF r_inst.instance_attribute27 IS NULL THEN
           p_instance_tbl(inst_idx).attribute27 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute27 := r_inst.instance_attribute27;
         END IF;

	IF r_inst.instance_attribute28 IS NULL THEN
           p_instance_tbl(inst_idx).attribute28 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute28 := r_inst.instance_attribute28;
         END IF;

	IF r_inst.instance_attribute29 IS NULL THEN
           p_instance_tbl(inst_idx).attribute29 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute29 := r_inst.instance_attribute29;
         END IF;

	IF r_inst.instance_attribute30 IS NULL THEN
           p_instance_tbl(inst_idx).attribute30 := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).attribute30 := r_inst.instance_attribute30;
         END IF;

         IF r_inst.network_asset_flag IS NULL THEN
           p_instance_tbl(inst_idx).network_asset_flag:= l_fnd_g_char;
	 ELSE
           p_instance_tbl(inst_idx).network_asset_flag:= r_inst.network_asset_flag;
	 END IF;

	IF r_inst.maintainable_flag IS NULL THEN
           p_instance_tbl(inst_idx).maintainable_flag := l_fnd_g_char;
        ELSE
           p_instance_tbl(inst_idx).maintainable_flag := r_inst.maintainable_flag;
        END IF;

	IF r_inst.ASSET_CRITICALITY_CODE IS NULL THEN
           p_instance_tbl(inst_idx).asset_criticality_code := l_fnd_g_char;
	ELSE
           p_instance_tbl(inst_idx).asset_criticality_code := r_inst.asset_criticality_code;
	END IF;

	 IF r_inst.category_id IS NULL THEN
           p_instance_tbl(inst_idx).category_id :=l_fnd_g_num;
	 ELSE
           p_instance_tbl(inst_idx).category_id :=r_inst.category_id;
	 END IF;

	IF r_inst.equipment_gen_object_id IS NULL THEN
           p_instance_tbl(inst_idx).equipment_gen_object_id :=l_fnd_g_num;
	ELSE
           p_instance_tbl(inst_idx).equipment_gen_object_id :=r_inst.equipment_gen_object_id;
	END IF;

	IF r_inst.instantiation_flag IS NULL THEN
           p_instance_tbl(inst_idx).instantiation_flag :=l_fnd_g_char;
	ELSE
           p_instance_tbl(inst_idx).instantiation_flag :=r_inst.instantiation_flag;
       	END IF;

	IF r_inst.operational_log_flag IS NULL THEN
           p_instance_tbl(inst_idx).operational_log_flag :=l_fnd_g_char;
	ELSE
           p_instance_tbl(inst_idx).operational_log_flag :=r_inst.operational_log_flag;
	END IF;

        IF r_inst.supplier_warranty_exp_date IS NULL THEN
           p_instance_tbl(inst_idx).supplier_warranty_exp_date := l_fnd_g_date;
	ELSE
           p_instance_tbl(inst_idx).supplier_warranty_exp_date :=r_inst.supplier_warranty_exp_date;
	END IF;

        p_instance_tbl(inst_idx).object_version_number := 1;
        p_instance_tbl(inst_idx).last_txn_line_detail_id := l_fnd_g_num;

        IF r_inst.install_location_type_code IS NULL THEN
           p_instance_tbl(inst_idx).install_location_type_code := l_fnd_g_char;
        ELSE
           p_instance_tbl(inst_idx).install_location_type_code := r_inst.install_location_type_code;
        END IF;

        IF r_inst.install_location_id IS NULL THEN
           p_instance_tbl(inst_idx).install_location_id := l_fnd_g_num;
        ELSE
           p_instance_tbl(inst_idx).install_location_id := r_inst.install_location_id;
        END IF;

        --p_instance_tbl(inst_idx).instance_usage_code := l_fnd_g_char;
        p_instance_tbl(inst_idx).check_for_instance_expiry := l_fnd_g_true;
   -- Added the following for bug 3234776
        IF r_inst.instance_description IS NULL THEN
           p_instance_tbl(inst_idx).instance_description := l_fnd_g_char;
        ELSE
           p_instance_tbl(inst_idx).instance_description := r_inst.instance_description;
        END IF;
   -- End addition for bug 3234776
   -- Added the following for bug 3234780
        IF r_inst.config_inst_hdr_id IS NULL THEN
           p_instance_tbl(inst_idx).config_inst_hdr_id := l_fnd_g_num;
        ELSE
           p_instance_tbl(inst_idx).config_inst_hdr_id := r_inst.config_inst_hdr_id;
        END IF;

        IF r_inst.config_inst_rev_num IS NULL THEN
           p_instance_tbl(inst_idx).config_inst_rev_num := l_fnd_g_num;
        ELSE
           p_instance_tbl(inst_idx).config_inst_rev_num := r_inst.config_inst_rev_num;
        END IF;

        IF r_inst.config_inst_item_id IS NULL THEN
           p_instance_tbl(inst_idx).config_inst_item_id := l_fnd_g_num;
        ELSE
           p_instance_tbl(inst_idx).config_inst_item_id := r_inst.config_inst_item_id;
        END IF;

        IF r_inst.config_valid_status IS NULL THEN
           p_instance_tbl(inst_idx).config_valid_status := l_fnd_g_char;
        ELSE
           p_instance_tbl(inst_idx).config_valid_status := r_inst.config_valid_status;
        END IF;

        -- Commenting the code as existence of instance_usage_code
        -- in csi_instance_interface is under discussion
        /*
	  IF r_inst.instance_usage_code IS NULL THEN
           p_instance_tbl(inst_idx).INSTANCE_usage_code := l_fnd_g_char;
         ELSE
           p_instance_tbl(inst_idx).INSTANCE_usage_code := r_inst.instance_usage_code;
         END IF;
        */
   -- End addition for bug 3234780

        IF r_inst.operational_status_code IS NULL THEN
           p_instance_tbl(inst_idx).operational_status_code := l_fnd_g_char;
        ELSE
           p_instance_tbl(inst_idx).operational_status_code := r_inst.operational_status_code;
        END IF;
       -- If operational_status_code has a value, then copy it to instance_usage_code
       -- else default it to out_of_enterprise
        IF p_instance_tbl(inst_idx).operational_status_code IS NOT NULL AND
           p_instance_tbl(inst_idx).operational_status_code <> l_fnd_g_char
        THEN
           p_instance_tbl(inst_idx).instance_usage_code := p_instance_tbl(inst_idx).operational_status_code;
        ELSE
           p_instance_tbl(inst_idx).instance_usage_code := 'OUT_OF_ENTERPRISE';
        END IF;

       FOR r_prty in c_prty (r_inst.inst_interface_id) LOOP
         -- Loop and create Party Table

         IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

           p_party_tbl(prty_idx).instance_party_id := NULL;
           p_party_tbl(prty_idx).instance_id       := NULL;
           p_party_tbl(prty_idx).parent_tbl_index   := inst_idx;

           IF r_prty.inst_interface_id IS NULL THEN
  	         p_party_tbl(prty_idx).interface_id := l_fnd_g_num;
           ELSE
	         p_party_tbl(prty_idx).interface_id := r_prty.inst_interface_id;
           END IF;

           IF r_prty.party_source_table IS NULL THEN
	         p_party_tbl(prty_idx).party_source_table := l_fnd_g_char;
           ELSE
	         p_party_tbl(prty_idx).party_source_table := r_prty.party_source_table;
           END IF;

           IF r_prty.party_id IS NULL THEN
             p_party_tbl(prty_idx).party_id := l_fnd_g_num;
           ELSE
             p_party_tbl(prty_idx).party_id := r_prty.party_id;
           END IF;

           IF r_prty.party_relationship_type_code IS NULL THEN
             p_party_tbl(prty_idx).relationship_type_code := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).relationship_type_code := r_prty.party_relationship_type_code;
           /* Added for bug 3511629. */
           /* Commented, as we don't need the following code
             IF p_party_tbl(prty_idx).relationship_type_code='OWNER'
             THEN
               IF p_party_tbl(prty_idx).party_id = l_int_party
               THEN
                  p_instance_tbl(inst_idx).instance_usage_code:= 'IN_INVENTORY';
               ELSE
                  p_instance_tbl(inst_idx).instance_usage_code:= 'OUT_OF_ENTERPRISE';
               END IF;
             END IF;
            */
            /* End addition for bug 3511629. */
           END IF;

           p_party_tbl(prty_idx).contact_flag := r_prty.contact_flag;
-- commented the following unnecessary code
/*
           -- Create table with contact Parties
           IF p_party_tbl(prty_idx).contact_flag = 'Y' THEN
             p_party_contact_tbl(prty_contact_idx).ip_interface_id := r_prty.ip_interface_id;
             p_party_contact_tbl(prty_contact_idx).inst_interface_id := r_prty.inst_interface_id;
             p_party_contact_tbl(prty_contact_idx).contact_party_id := r_prty.contact_party_id;
             p_party_contact_tbl(prty_contact_idx).contact_party_number := r_prty.contact_party_number;
             p_party_contact_tbl(prty_contact_idx).contact_party_name   := r_prty.contact_party_name;
             p_party_contact_tbl(prty_contact_idx).contact_party_rel_type := r_prty.contact_party_rel_type;
             p_party_contact_tbl(prty_contact_idx).parent_tbl_idx := prty_idx;
             prty_contact_idx := prty_contact_idx + 1;
           END IF;
*/
           p_party_tbl(prty_idx).contact_ip_id := l_fnd_g_num;
           --p_party_tbl(prty_idx).active_start_date := l_fnd_g_date;
   -- Added
           IF r_prty.party_start_date IS NULL THEN
             p_party_tbl(prty_idx).active_start_date := l_fnd_g_date;
           ELSE
             p_party_tbl(prty_idx).active_start_date := r_prty.party_start_date;
           END IF;
   -- End addition
           IF r_prty.party_end_date IS NULL THEN
             p_party_tbl(prty_idx).active_end_date := l_fnd_g_date;
           ELSE
             p_party_tbl(prty_idx).active_end_date := r_prty.party_end_date;
           END IF;



           IF r_prty.party_context IS NULL THEN
             p_party_tbl(prty_idx).context := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).context := r_prty.party_context;
           END IF;

           IF r_prty.party_attribute1 IS NULL THEN
             p_party_tbl(prty_idx).attribute1 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute1 := r_prty.party_attribute1;
           END IF;

           IF r_prty.party_attribute2 IS NULL THEN
             p_party_tbl(prty_idx).attribute2 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute2 := r_prty.party_attribute2;
           END IF;

           IF r_prty.party_attribute3 IS NULL THEN
             p_party_tbl(prty_idx).attribute3 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute3 := r_prty.party_attribute3;
           END IF;

           IF r_prty.party_attribute4 IS NULL THEN
             p_party_tbl(prty_idx).attribute4 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute4 := r_prty.party_attribute4;
           END IF;

           IF r_prty.party_attribute5 IS NULL THEN
             p_party_tbl(prty_idx).attribute5 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute5 := r_prty.party_attribute5;
           END IF;

           IF r_prty.party_attribute6 IS NULL THEN
             p_party_tbl(prty_idx).attribute6 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute6 := r_prty.party_attribute6;
           END IF;

           IF r_prty.party_attribute7 IS NULL THEN
             p_party_tbl(prty_idx).attribute7 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute7 := r_prty.party_attribute7;
           END IF;

           IF r_prty.party_attribute8 IS NULL THEN
             p_party_tbl(prty_idx).attribute8 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute8 := r_prty.party_attribute8;
           END IF;

           IF r_prty.party_attribute8 IS NULL THEN
             p_party_tbl(prty_idx).attribute9 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute9 := r_prty.party_attribute9;
           END IF;

           IF r_prty.party_attribute10 IS NULL THEN
             p_party_tbl(prty_idx).attribute10 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute10 := r_prty.party_attribute10;
           END IF;

           IF r_prty.party_attribute11 IS NULL THEN
             p_party_tbl(prty_idx).attribute11 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute11 := r_prty.party_attribute11;
           END IF;

           IF r_prty.party_attribute12 IS NULL THEN
             p_party_tbl(prty_idx).attribute12 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute12 := r_prty.party_attribute12;
           END IF;

           IF r_prty.party_attribute13 IS NULL THEN
             p_party_tbl(prty_idx).attribute13 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute13 := r_prty.party_attribute13;
           END IF;

           IF r_prty.party_attribute14 IS NULL THEN
             p_party_tbl(prty_idx).attribute14 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute14 := r_prty.party_attribute14;
           END IF;

           IF r_prty.party_attribute15 IS NULL THEN
             p_party_tbl(prty_idx).attribute15 := l_fnd_g_char;
           ELSE
             p_party_tbl(prty_idx).attribute15 := r_prty.party_attribute15;
           END IF;

           p_party_tbl(prty_idx).object_version_number  := 1;     -- object_version_number
           p_party_tbl(prty_idx).primary_flag := l_fnd_g_char;    -- primary_flag
           p_party_tbl(prty_idx).preferred_flag := l_fnd_g_char;     -- preferred_flag

         IF r_prty.party_account1_id IS NOT NULL OR r_prty.party_account1_number IS NOT NULL THEN -- Put record in Table

           IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

            p_account_tbl(ptyacc_idx).ip_account_id     := l_fnd_g_num;
            p_account_tbl(ptyacc_idx).instance_party_id := l_fnd_g_num;
            p_account_tbl(ptyacc_idx).parent_tbl_index  := prty_idx;

            IF r_prty.party_account1_id IS NULL THEN
              p_account_tbl(ptyacc_idx).party_account_id := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).party_account_id := r_prty.party_account1_id;
            END IF;

            IF r_prty.acct1_relationship_type_code IS NULL THEN
              p_account_tbl(ptyacc_idx).relationship_type_code := l_fnd_g_char;
            ELSE
              p_account_tbl(ptyacc_idx).relationship_type_code := r_prty.acct1_relationship_type_code;
            END IF;

            IF r_prty.bill_to_address1 IS NULL THEN
              p_account_tbl(ptyacc_idx).bill_to_address := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).bill_to_address := r_prty.bill_to_address1;
            END IF;

            IF r_prty.ship_to_address1 IS NULL THEN
              p_account_tbl(ptyacc_idx).ship_to_address := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).ship_to_address := r_prty.ship_to_address1;
            END IF;

            -- p_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date; -- active_start_date
        -- Added
             IF r_prty.party_acct1_start_date IS NULL THEN
               p_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date;
             ELSE
               p_account_tbl(ptyacc_idx).active_start_date := r_prty.party_acct1_start_date;
             END IF;
         -- End addition
             IF r_prty.party_acct1_end_date IS NULL THEN
               p_account_tbl(ptyacc_idx).active_end_date := l_fnd_g_date;
             ELSE
               p_account_tbl(ptyacc_idx).active_end_date := r_prty.party_acct1_end_date;
             END IF;

             IF r_prty.account1_context IS NULL THEN
               p_account_tbl(ptyacc_idx).context := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).context := r_prty.account1_context;
             END IF;

             IF r_prty.account1_attribute1 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute1 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute1 := r_prty.account1_attribute1;
             END IF;

             IF r_prty.account1_attribute2 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute2 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute2 := r_prty.account1_attribute2;
             END IF;

             IF r_prty.account1_attribute3 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute3 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute3 := r_prty.account1_attribute3;
             END IF;

             IF r_prty.account1_attribute4 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute4 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute4 := r_prty.account1_attribute4;
             END IF;

             IF r_prty.account1_attribute5 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute5 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute5 := r_prty.account1_attribute5;
             END IF;

             IF r_prty.account1_attribute6 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute6 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute6 := r_prty.account1_attribute6;
             END IF;

             IF r_prty.account1_attribute7 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute7 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute7 := r_prty.account1_attribute7;
             END IF;

             IF r_prty.account1_attribute8 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute8 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute8 := r_prty.account1_attribute8;
             END IF;

             IF r_prty.account1_attribute9 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute9 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute9 := r_prty.account1_attribute9;
             END IF;

             IF r_prty.account1_attribute10 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute10 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute10 := r_prty.account1_attribute10;
             END IF;

             IF r_prty.account1_attribute11 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute11 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute11 := r_prty.account1_attribute11;
             END IF;

             IF r_prty.account1_attribute12 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute12 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute12 := r_prty.account1_attribute12;
             END IF;

             IF r_prty.account1_attribute13 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute13 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute13 := r_prty.account1_attribute13;
             END IF;

             IF r_prty.account1_attribute14 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute14 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute14 := r_prty.account1_attribute14;
             END IF;

             IF r_prty.account1_attribute15 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute15 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute15 := r_prty.account1_attribute15;
             END IF;

             p_account_tbl(ptyacc_idx).object_version_number := 1;
             p_account_tbl(ptyacc_idx).call_contracts  := l_fnd_g_true;
             p_account_tbl(ptyacc_idx).vld_organization_id :=  l_fnd_g_num;

           END IF;
           ptyacc_idx := ptyacc_idx + 1;
         END IF; -- Party Account 1

         IF r_prty.party_account2_id IS NOT NULL OR r_prty.party_account2_number IS NOT NULL THEN -- Put record in Table

           IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

            p_account_tbl(ptyacc_idx).ip_account_id    := l_fnd_g_num;
            p_account_tbl(ptyacc_idx).instance_party_id := l_fnd_g_num;
            p_account_tbl(ptyacc_idx).parent_tbl_index  := prty_idx;

            IF r_prty.party_account2_id IS NULL THEN
              p_account_tbl(ptyacc_idx).party_account_id := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).party_account_id := r_prty.party_account2_id;
            END IF;

            IF r_prty.acct2_relationship_type_code IS NULL THEN
              p_account_tbl(ptyacc_idx).relationship_type_code := l_fnd_g_char;
            ELSE
              p_account_tbl(ptyacc_idx).relationship_type_code := r_prty.acct2_relationship_type_code;
            END IF;

            IF r_prty.bill_to_address2 IS NULL THEN
              p_account_tbl(ptyacc_idx).bill_to_address := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).bill_to_address := r_prty.bill_to_address2;
            END IF;

            IF r_prty.ship_to_address2 IS NULL THEN
              p_account_tbl(ptyacc_idx).ship_to_address := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).ship_to_address := r_prty.ship_to_address2;
            END IF;

            -- p_account_tbl(ptyacc_idx).ACTIVE_START_DATE := l_fnd_g_date; -- ACTIVE_START_DATE
        -- Added
             IF r_prty.party_acct2_start_date IS NULL THEN
               p_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date;
             ELSE
               p_account_tbl(ptyacc_idx).active_start_date := r_prty.party_acct2_start_date;
             END IF;
         -- End addition

             IF r_prty.party_acct2_end_date IS NULL THEN
               p_account_tbl(ptyacc_idx).active_end_date := l_fnd_g_date;
             ELSE
               p_account_tbl(ptyacc_idx).active_end_date := r_prty.party_acct2_end_date;
             END IF;

             IF r_prty.account2_context IS NULL THEN
               p_account_tbl(ptyacc_idx).context := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).context := r_prty.account2_context;
             END IF;

             IF r_prty.account2_attribute1 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute1 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute1 := r_prty.account2_attribute1;
             END IF;

             IF r_prty.account2_attribute2 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute2 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute2 := r_prty.account2_attribute2;
             END IF;

             IF r_prty.account2_attribute3 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute3 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute3 := r_prty.account2_attribute3;
             END IF;

             IF r_prty.account2_attribute4 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute4 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute4 := r_prty.account2_attribute4;
             END IF;

             IF r_prty.account2_attribute5 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute5 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute5 := r_prty.account2_attribute5;
             END IF;

             IF r_prty.account2_attribute6 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute6 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute6 := r_prty.account2_attribute6;
             END IF;

             IF r_prty.account2_attribute7 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute7 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute7 := r_prty.account2_attribute7;
             END IF;

             IF r_prty.account2_attribute8 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute8 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute8 := r_prty.account2_attribute8;
             END IF;

             IF r_prty.account2_attribute9 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute9 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute9 := r_prty.account2_attribute9;
             END IF;

             IF r_prty.account2_attribute10 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute10 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute10 := r_prty.account2_attribute10;
             END IF;

             IF r_prty.account2_attribute11 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute11 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute11 := r_prty.account2_attribute11;
             END IF;

             IF r_prty.account2_attribute12 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute12 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute12 := r_prty.account2_attribute12;
             END IF;

             IF r_prty.account2_attribute13 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute13 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute13 := r_prty.account2_attribute13;
             END IF;

             IF r_prty.account2_attribute14 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute14 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute14 := r_prty.account2_attribute14;
             END IF;

             IF r_prty.account2_attribute15 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute15 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute15 := r_prty.account2_attribute15;
             END IF;

             p_account_tbl(ptyacc_idx).object_version_number := 1;
             p_account_tbl(ptyacc_idx).call_contracts  := l_fnd_g_true;
             p_account_tbl(ptyacc_idx).vld_organization_id :=  l_fnd_g_num;

           END IF;
           ptyacc_idx := ptyacc_idx + 1;
         END IF;  -- Party Account 2

         IF r_prty.party_account3_id IS NOT NULL OR r_prty.party_account3_number IS NOT NULL THEN -- Put record in Table

           IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

            p_account_tbl(ptyacc_idx).ip_account_id    := l_fnd_g_num;
            p_account_tbl(ptyacc_idx).instance_party_id := l_fnd_g_num;
            p_account_tbl(ptyacc_idx).parent_tbl_index  := prty_idx;

            IF r_prty.party_account3_id IS NULL THEN
              p_account_tbl(ptyacc_idx).party_account_id := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).party_account_id := r_prty.party_account3_id;
            END IF;

            IF r_prty.acct3_relationship_type_code IS NULL THEN
              p_account_tbl(ptyacc_idx).relationship_type_code := l_fnd_g_char;
            ELSE
              p_account_tbl(ptyacc_idx).relationship_type_code := r_prty.acct3_relationship_type_code;
            END IF;

            IF r_prty.bill_to_address3 IS NULL THEN
              p_account_tbl(ptyacc_idx).bill_to_address := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).bill_to_address := r_prty.bill_to_address3;
            END IF;

            IF r_prty.ship_to_address3 IS NULL THEN
              p_account_tbl(ptyacc_idx).ship_to_address := l_fnd_g_num;
            ELSE
              p_account_tbl(ptyacc_idx).ship_to_address := r_prty.ship_to_address3;
            END IF;

            -- p_account_tbl(ptyacc_idx).ACTIVE_START_DATE := l_fnd_g_date; -- ACTIVE_START_DATE
        -- Added
             IF r_prty.party_acct3_start_date IS NULL THEN
               p_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date;
             ELSE
               p_account_tbl(ptyacc_idx).active_start_date := r_prty.party_acct3_start_date;
             END IF;
         -- End addition

             IF r_prty.party_acct3_end_date IS NULL THEN
               p_account_tbl(ptyacc_idx).active_end_date := l_fnd_g_date;
             ELSE
               p_account_tbl(ptyacc_idx).active_end_date := r_prty.party_acct3_end_date;
             END IF;

             IF r_prty.account3_context IS NULL THEN
               p_account_tbl(ptyacc_idx).context := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).context := r_prty.account3_context;
             END IF;

             IF r_prty.account3_attribute1 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute1 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute1 := r_prty.account3_attribute1;
             END IF;

             IF r_prty.account3_attribute2 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute2 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute2 := r_prty.account3_attribute2;
             END IF;

             IF r_prty.account3_attribute3 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute3 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute3 := r_prty.account3_attribute3;
             END IF;

             IF r_prty.account3_attribute4 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute4 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute4 := r_prty.account3_attribute4;
             END IF;

             IF r_prty.account3_attribute5 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute5 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute5 := r_prty.account3_attribute5;
             END IF;

             IF r_prty.account3_attribute6 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute6 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute6 := r_prty.account3_attribute6;
             END IF;

             IF r_prty.account3_attribute7 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute7 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute7 := r_prty.account3_attribute7;
             END IF;

             IF r_prty.account3_attribute8 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute8 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute8 := r_prty.account3_attribute8;
             END IF;

             IF r_prty.account3_attribute9 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute9 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute9 := r_prty.account3_attribute9;
             END IF;

             IF r_prty.account3_attribute10 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute10 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute10 := r_prty.account3_attribute10;
             END IF;

             IF r_prty.account3_attribute11 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute11 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute11 := r_prty.account3_attribute11;
             END IF;

             IF r_prty.account3_attribute12 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute12 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute12 := r_prty.account3_attribute12;
             END IF;

             IF r_prty.account3_attribute13 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute13 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute13 := r_prty.account3_attribute13;
             END IF;

             IF r_prty.account3_attribute14 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute14 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute14 := r_prty.account3_attribute14;
             END IF;

             IF r_prty.account3_attribute15 IS NULL THEN
               p_account_tbl(ptyacc_idx).attribute15 := l_fnd_g_char;
             ELSE
               p_account_tbl(ptyacc_idx).attribute15 := r_prty.account3_attribute15;
             END IF;

             p_account_tbl(ptyacc_idx).object_version_number := 1;
             p_account_tbl(ptyacc_idx).call_contracts  := l_fnd_g_true;
             p_account_tbl(ptyacc_idx).vld_organization_id :=  l_fnd_g_num;

           END IF;
           ptyacc_idx := ptyacc_idx + 1;
         END IF;  -- Party Account 3

        -- Added the following code to handle contacts.
        -- If contact_party_id is passed then I assume
        -- a contact should be created for the party.
           IF r_prty.contact_party_id IS NOT NULL AND
              r_prty.contact_party_id <> fnd_api.g_miss_num
           THEN
             prty_idx:=prty_idx + 1;
             p_party_tbl(prty_idx).instance_party_id:=fnd_api.g_miss_num;
             p_party_tbl(prty_idx).instance_id:=fnd_api.g_miss_num;
             p_party_tbl(prty_idx).party_source_table:=r_prty.party_source_table;
             p_party_tbl(prty_idx).party_id:=r_prty.contact_party_id;
             p_party_tbl(prty_idx).relationship_type_code:=r_prty.contact_party_rel_type;
             p_party_tbl(prty_idx).contact_flag:='Y';
             p_party_tbl(prty_idx).contact_parent_tbl_index:=prty_idx-1;
             p_party_tbl(prty_idx).parent_tbl_index:=inst_idx;
           END IF;
        -- End addition for contacts.

         prty_idx := prty_idx + 1;
         END IF;   -- End Create Update Party
       END LOOP;   -- End of Party and Party Account LOOP

       FOR r_attr in c_attr (r_inst.inst_interface_id) LOOP
         -- Extended Attribute Values

         IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

           p_ext_attrib_tbl(extatt_idx).attribute_value_id :=  NULL;
           p_ext_attrib_tbl(extatt_idx).instance_id        :=  NULL;
           p_ext_attrib_tbl(extatt_idx).parent_tbl_index   :=  inst_idx;

           IF r_attr.attribute_id IS NULL THEN
             p_ext_attrib_tbl(extatt_idx).attribute_id := l_fnd_g_num;
           ELSE
             p_ext_attrib_tbl(extatt_idx).attribute_id := r_attr.attribute_id;
           END IF;

           IF r_attr.attribute_code IS NULL THEN
             p_ext_attrib_tbl(extatt_idx).attribute_code := l_fnd_g_char;
           ELSE
             p_ext_attrib_tbl(extatt_idx).attribute_code := r_attr.attribute_code;
           END IF;

           IF r_attr.attribute_value IS NULL THEN
             p_ext_attrib_tbl(extatt_idx).attribute_value := l_fnd_g_char;
           ELSE
             p_ext_attrib_tbl(extatt_idx).attribute_value := r_attr.attribute_value;
           END IF;

           p_ext_attrib_tbl(extatt_idx).ACTIVE_START_DATE := l_fnd_g_date;

           IF r_attr.ieav_end_date IS NULL THEN
             p_ext_attrib_tbl(extatt_idx).active_end_date := l_fnd_g_date;
           ELSE
             p_ext_attrib_tbl(extatt_idx).active_end_date := r_attr.ieav_end_date;
           END IF;

           p_ext_attrib_tbl(extatt_idx).context := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute1 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute2 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute3 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute4 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute5 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute6 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute7 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute8 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute9 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute10 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute11 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute12 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute13 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute14 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).attribute15 := l_fnd_g_char;
           p_ext_attrib_tbl(extatt_idx).object_version_number := 1;

         extatt_idx := extatt_idx + 1;
         END IF;
       END LOOP;  -- End of Extended Attributes

       -- Start of Instance Pricing Attributes

       IF (r_inst.pricing_att_start_date  IS NOT NULL OR
           r_inst.pricing_att_end_date    IS NOT NULL OR
           r_inst.pricing_context         IS NOT NULL OR
           r_inst.pricing_attribute1      IS NOT NULL OR
           r_inst.pricing_attribute2      IS NOT NULL OR
           r_inst.pricing_attribute3      IS NOT NULL OR
           r_inst.pricing_attribute4      IS NOT NULL OR
           r_inst.pricing_attribute5      IS NOT NULL OR
           r_inst.pricing_attribute6      IS NOT NULL OR
           r_inst.pricing_attribute7      IS NOT NULL OR
           r_inst.pricing_attribute8      IS NOT NULL OR
           r_inst.pricing_attribute9      IS NOT NULL OR
           r_inst.pricing_attribute10     IS NOT NULL OR
           r_inst.pricing_attribute11     IS NOT NULL OR
           r_inst.pricing_attribute12     IS NOT NULL OR
           r_inst.pricing_attribute13     IS NOT NULL OR
           r_inst.pricing_attribute14     IS NOT NULL OR
           r_inst.pricing_attribute15     IS NOT NULL OR
           r_inst.pricing_attribute16     IS NOT NULL OR
           r_inst.pricing_attribute17     IS NOT NULL OR
           r_inst.pricing_attribute18     IS NOT NULL OR
           r_inst.pricing_attribute19     IS NOT NULL OR
           r_inst.pricing_attribute20     IS NOT NULL OR
           r_inst.pricing_attribute21     IS NOT NULL OR
           r_inst.pricing_attribute22     IS NOT NULL OR
           r_inst.pricing_attribute23     IS NOT NULL OR
           r_inst.pricing_attribute24     IS NOT NULL OR
           r_inst.pricing_attribute25     IS NOT NULL OR
           r_inst.pricing_attribute26     IS NOT NULL OR
           r_inst.pricing_attribute27     IS NOT NULL OR
           r_inst.pricing_attribute28     IS NOT NULL OR
           r_inst.pricing_attribute29     IS NOT NULL OR
           r_inst.pricing_attribute30     IS NOT NULL OR
           r_inst.pricing_attribute31     IS NOT NULL OR
           r_inst.pricing_attribute32     IS NOT NULL OR
           r_inst.pricing_attribute33     IS NOT NULL OR
           r_inst.pricing_attribute34     IS NOT NULL OR
           r_inst.pricing_attribute35     IS NOT NULL OR
           r_inst.pricing_attribute36     IS NOT NULL OR
           r_inst.pricing_attribute37     IS NOT NULL OR
           r_inst.pricing_attribute38     IS NOT NULL OR
           r_inst.pricing_attribute39     IS NOT NULL OR
           r_inst.pricing_attribute40     IS NOT NULL OR
           r_inst.pricing_attribute41     IS NOT NULL OR
           r_inst.pricing_attribute42     IS NOT NULL OR
           r_inst.pricing_attribute43     IS NOT NULL OR
           r_inst.pricing_attribute44     IS NOT NULL OR
           r_inst.pricing_attribute45     IS NOT NULL OR
           r_inst.pricing_attribute46     IS NOT NULL OR
           r_inst.pricing_attribute47     IS NOT NULL OR
           r_inst.pricing_attribute48     IS NOT NULL OR
           r_inst.pricing_attribute49     IS NOT NULL OR
           r_inst.pricing_attribute50     IS NOT NULL OR
           r_inst.pricing_attribute51     IS NOT NULL OR
           r_inst.pricing_attribute52     IS NOT NULL OR
           r_inst.pricing_attribute53     IS NOT NULL OR
           r_inst.pricing_attribute54     IS NOT NULL OR
           r_inst.pricing_attribute55     IS NOT NULL OR
           r_inst.pricing_attribute56     IS NOT NULL OR
           r_inst.pricing_attribute57     IS NOT NULL OR
           r_inst.pricing_attribute58     IS NOT NULL OR
           r_inst.pricing_attribute59     IS NOT NULL OR
           r_inst.pricing_attribute60     IS NOT NULL OR
           r_inst.pricing_attribute61     IS NOT NULL OR
           r_inst.pricing_attribute62     IS NOT NULL OR
           r_inst.pricing_attribute63     IS NOT NULL OR
           r_inst.pricing_attribute64     IS NOT NULL OR
           r_inst.pricing_attribute65     IS NOT NULL OR
           r_inst.pricing_attribute66     IS NOT NULL OR
           r_inst.pricing_attribute67     IS NOT NULL OR
           r_inst.pricing_attribute68     IS NOT NULL OR
           r_inst.pricing_attribute69     IS NOT NULL OR
           r_inst.pricing_attribute70     IS NOT NULL OR
           r_inst.pricing_attribute71     IS NOT NULL OR
           r_inst.pricing_attribute72     IS NOT NULL OR
           r_inst.pricing_attribute73     IS NOT NULL OR
           r_inst.pricing_attribute74     IS NOT NULL OR
           r_inst.pricing_attribute75     IS NOT NULL OR
           r_inst.pricing_attribute76     IS NOT NULL OR
           r_inst.pricing_attribute77     IS NOT NULL OR
           r_inst.pricing_attribute78     IS NOT NULL OR
           r_inst.pricing_attribute79     IS NOT NULL OR
           r_inst.pricing_attribute80     IS NOT NULL OR
           r_inst.pricing_attribute81     IS NOT NULL OR
           r_inst.pricing_attribute82     IS NOT NULL OR
           r_inst.pricing_attribute83     IS NOT NULL OR
           r_inst.pricing_attribute84     IS NOT NULL OR
           r_inst.pricing_attribute85     IS NOT NULL OR
           r_inst.pricing_attribute86     IS NOT NULL OR
           r_inst.pricing_attribute87     IS NOT NULL OR
           r_inst.pricing_attribute88     IS NOT NULL OR
           r_inst.pricing_attribute89     IS NOT NULL OR
           r_inst.pricing_attribute90     IS NOT NULL OR
           r_inst.pricing_attribute91     IS NOT NULL OR
           r_inst.pricing_attribute92     IS NOT NULL OR
           r_inst.pricing_attribute93     IS NOT NULL OR
           r_inst.pricing_attribute94     IS NOT NULL OR
           r_inst.pricing_attribute95     IS NOT NULL OR
           r_inst.pricing_attribute96     IS NOT NULL OR
           r_inst.pricing_attribute97     IS NOT NULL OR
           r_inst.pricing_attribute98     IS NOT NULL OR
           r_inst.pricing_attribute99     IS NOT NULL OR
           r_inst.pricing_attribute100    IS NOT NULL) THEN

      IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

         p_price_tbl(price_idx).pricing_attribute_id  :=  NULL;
         p_price_tbl(price_idx).instance_id           :=  NULL;
         p_price_tbl(price_idx).parent_tbl_index      :=  inst_idx;

         p_price_tbl(price_idx).active_start_date := l_fnd_g_date;

         IF r_inst.pricing_att_end_date IS NULL THEN
           p_price_tbl(price_idx).active_end_date := l_fnd_g_date;
         ELSE
           p_price_tbl(price_idx).active_end_date := r_inst.pricing_att_end_date;
         END IF;

         IF r_inst.pricing_context IS NULL THEN
           p_price_tbl(price_idx).pricing_context := l_fnd_g_char;
           -- changed from context tar 4102867.999
         ELSE
           p_price_tbl(price_idx).pricing_context := r_inst.pricing_context;
           -- changed from context tar 4102867.999
         END IF;

         IF r_inst.pricing_attribute1 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute1 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute1 := r_inst.pricing_attribute1;
         END IF;

         IF r_inst.pricing_attribute2 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute2 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute2 := r_inst.pricing_attribute2;
         END IF;

         IF r_inst.pricing_attribute3 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute3 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute3 := r_inst.pricing_attribute3;
         END IF;

         IF r_inst.pricing_attribute4 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute4 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute4 := r_inst.pricing_attribute4;
         END IF;

         IF r_inst.pricing_attribute5 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute5 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute5 := r_inst.pricing_attribute5;
         END IF;

         IF r_inst.pricing_attribute6 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute6 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute6 := r_inst.pricing_attribute6;
         END IF;

         IF r_inst.pricing_attribute7 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute7 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute7 := r_inst.pricing_attribute7;
         END IF;

         IF r_inst.pricing_attribute8 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute8 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute8 := r_inst.pricing_attribute8;
         END IF;

         IF r_inst.pricing_attribute9 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute9 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute9 := r_inst.pricing_attribute9;
         END IF;

         IF r_inst.pricing_attribute10 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute10 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute10 := r_inst.pricing_attribute10;
         END IF;

         IF r_inst.pricing_attribute11 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute11 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute11 := r_inst.pricing_attribute11;
         END IF;

         IF r_inst.pricing_attribute12 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute12 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute12 := r_inst.pricing_attribute12;
         END IF;

         IF r_inst.pricing_attribute13 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute13 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute13 := r_inst.pricing_attribute13;
         END IF;

         IF r_inst.pricing_attribute14 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute14 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute14 := r_inst.pricing_attribute14;
         END IF;

         IF r_inst.pricing_attribute15 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute15 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute15 := r_inst.pricing_attribute15;
         END IF;

         IF r_inst.pricing_attribute16 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute16 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute16 := r_inst.pricing_attribute16;
         END IF;

         IF r_inst.pricing_attribute17 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute17 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute17 := r_inst.pricing_attribute17;
         END IF;

         IF r_inst.pricing_attribute18 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute18 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute18 := r_inst.pricing_attribute18;
         END IF;

         IF r_inst.pricing_attribute19 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute19 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute19 := r_inst.pricing_attribute19;
         END IF;

         IF r_inst.pricing_attribute20 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute20 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute20 := r_inst.pricing_attribute20;
         END IF;

         IF r_inst.pricing_attribute21 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute21 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute21 := r_inst.pricing_attribute21;
         END IF;

         IF r_inst.pricing_attribute22 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute22 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute22 := r_inst.pricing_attribute22;
         END IF;

         IF r_inst.pricing_attribute23 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute23 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute23 := r_inst.pricing_attribute23;
         END IF;

         IF r_inst.pricing_attribute24 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute24 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute24 := r_inst.pricing_attribute24;
         END IF;

         IF r_inst.pricing_attribute25 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute25 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute25 := r_inst.pricing_attribute25;
         END IF;

         IF r_inst.pricing_attribute26 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute26 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute26 := r_inst.pricing_attribute26;
         END IF;

         IF r_inst.pricing_attribute27 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute27 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute27 := r_inst.pricing_attribute27;
         END IF;

         IF r_inst.pricing_attribute28 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute28 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute28 := r_inst.pricing_attribute28;
         END IF;

         IF r_inst.pricing_attribute29 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute29 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute29 := r_inst.pricing_attribute29;
         END IF;

         IF r_inst.pricing_attribute30 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute30 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute30 := r_inst.pricing_attribute30;
         END IF;

         IF r_inst.pricing_attribute31 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute31 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute31 := r_inst.pricing_attribute31;
         END IF;

         IF r_inst.pricing_attribute32 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute32 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute32 := r_inst.pricing_attribute32;
         END IF;

         IF r_inst.pricing_attribute33 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute33 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute33 := r_inst.pricing_attribute33;
         END IF;

         IF r_inst.pricing_attribute34 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute34 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute34 := r_inst.pricing_attribute34;
         END IF;

         IF r_inst.pricing_attribute35 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute35 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute35 := r_inst.pricing_attribute35;
         END IF;

         IF r_inst.pricing_attribute36 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute36 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute36 := r_inst.pricing_attribute36;
         END IF;

         IF r_inst.pricing_attribute37 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute37 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute37 := r_inst.pricing_attribute37;
         END IF;

         IF r_inst.pricing_attribute38 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute38 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute38 := r_inst.pricing_attribute38;
         END IF;

         IF r_inst.pricing_attribute39 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute39 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute39 := r_inst.pricing_attribute39;
         END IF;

         IF r_inst.pricing_attribute40 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute40 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute40 := r_inst.pricing_attribute40;
         END IF;

         IF r_inst.pricing_attribute41 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute41 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute41 := r_inst.pricing_attribute41;
         END IF;

         IF r_inst.pricing_attribute42 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute42 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute42 := r_inst.pricing_attribute42;
         END IF;

         IF r_inst.pricing_attribute43 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute43 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute43 := r_inst.pricing_attribute43;
         END IF;

         IF r_inst.pricing_attribute44 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute44 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute44 := r_inst.pricing_attribute44;
         END IF;

         IF r_inst.pricing_attribute45 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute45 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute45 := r_inst.pricing_attribute45;
         END IF;

         IF r_inst.pricing_attribute46 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute46 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute46 := r_inst.pricing_attribute46;
         END IF;

         IF r_inst.pricing_attribute47 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute47 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute47 := r_inst.pricing_attribute47;
         END IF;

         IF r_inst.pricing_attribute48 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute48 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute48 := r_inst.pricing_attribute48;
         END IF;

         IF r_inst.pricing_attribute49 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute49 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute49 := r_inst.pricing_attribute49;
         END IF;

         IF r_inst.pricing_attribute50 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute50 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute50 := r_inst.pricing_attribute50;
         END IF;

         IF r_inst.pricing_attribute51 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute51 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute51 := r_inst.pricing_attribute51;
         END IF;

         IF r_inst.pricing_attribute52 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute52 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute52 := r_inst.pricing_attribute52;
         END IF;

         IF r_inst.pricing_attribute53 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute53 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute53 := r_inst.pricing_attribute53;
         END IF;

         IF r_inst.pricing_attribute54 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute54 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute54 := r_inst.pricing_attribute54;
         END IF;

         IF r_inst.pricing_attribute55 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute55 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute55 := r_inst.pricing_attribute55;
         END IF;

         IF r_inst.pricing_attribute56 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute56 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute56 := r_inst.pricing_attribute56;
         END IF;

         IF r_inst.pricing_attribute57 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute57 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute57 := r_inst.pricing_attribute57;
         END IF;

         IF r_inst.pricing_attribute58 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute58 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute58 := r_inst.pricing_attribute58;
         END IF;

         IF r_inst.pricing_attribute59 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute59 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute59 := r_inst.pricing_attribute59;
         END IF;

         IF r_inst.pricing_attribute60 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute60 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute60 := r_inst.pricing_attribute60;
         END IF;

         IF r_inst.pricing_attribute61 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute61 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute61 := r_inst.pricing_attribute61;
         END IF;

         IF r_inst.pricing_attribute62 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute62 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute62 := r_inst.pricing_attribute62;
         END IF;

         IF r_inst.pricing_attribute63 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute63 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute63 := r_inst.pricing_attribute63;
         END IF;

         IF r_inst.pricing_attribute64 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute64 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute64 := r_inst.pricing_attribute64;
         END IF;

         IF r_inst.pricing_attribute5 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute65 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute65 := r_inst.pricing_attribute65;
         END IF;

         IF r_inst.pricing_attribute66 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute66 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute66 := r_inst.pricing_attribute66;
         END IF;

         IF r_inst.pricing_attribute67 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute67 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute67 := r_inst.pricing_attribute67;
         END IF;

         IF r_inst.pricing_attribute68 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute68 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute68 := r_inst.pricing_attribute68;
         END IF;

         IF r_inst.pricing_attribute69 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute69 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute69 := r_inst.pricing_attribute69;
         END IF;

         IF r_inst.pricing_attribute70 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute70 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute70 := r_inst.pricing_attribute70;
         END IF;

         IF r_inst.pricing_attribute71 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute71 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute71 := r_inst.pricing_attribute71;
         END IF;

         IF r_inst.pricing_attribute72 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute72 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute72 := r_inst.pricing_attribute72;
         END IF;

         IF r_inst.pricing_attribute73 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute73 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute73 := r_inst.pricing_attribute73;
         END IF;

         IF r_inst.pricing_attribute74 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute74 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute74 := r_inst.pricing_attribute74;
         END IF;

         IF r_inst.pricing_attribute75 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute75 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute75 := r_inst.pricing_attribute75;
         END IF;

         IF r_inst.pricing_attribute76 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute76 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute76 := r_inst.pricing_attribute76;
         END IF;

         IF r_inst.pricing_attribute77 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute77 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute77 := r_inst.pricing_attribute77;
         END IF;

         IF r_inst.pricing_attribute78 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute78 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute78 := r_inst.pricing_attribute78;
         END IF;

         IF r_inst.pricing_attribute79 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute79 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute79 := r_inst.pricing_attribute79;
         END IF;

         IF r_inst.pricing_attribute80 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute80 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute80 := r_inst.pricing_attribute80;
         END IF;

         IF r_inst.pricing_attribute81 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute81 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute81 := r_inst.pricing_attribute81;
         END IF;

         IF r_inst.pricing_attribute82 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute82 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute82 := r_inst.pricing_attribute82;
         END IF;

         IF r_inst.pricing_attribute83 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute83 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute83 := r_inst.pricing_attribute83;
         END IF;

         IF r_inst.pricing_attribute84 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute84 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute84 := r_inst.pricing_attribute84;
         END IF;

         IF r_inst.pricing_attribute85 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute85 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute85 := r_inst.pricing_attribute85;
         END IF;

         IF r_inst.pricing_attribute86 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute86 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute86 := r_inst.pricing_attribute86;
         END IF;

         IF r_inst.pricing_attribute87 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute87 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute87 := r_inst.pricing_attribute87;
         END IF;

         IF r_inst.pricing_attribute88 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute88 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute88 := r_inst.pricing_attribute88;
         END IF;

         IF r_inst.pricing_attribute89 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute89 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute89 := r_inst.pricing_attribute89;
         END IF;

         IF r_inst.pricing_attribute90 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute90 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute90 := r_inst.pricing_attribute90;
         END IF;

         IF r_inst.pricing_attribute91 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute91 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute91 := r_inst.pricing_attribute91;
         END IF;

         IF r_inst.pricing_attribute92 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute92 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute92 := r_inst.pricing_attribute92;
         END IF;

         IF r_inst.pricing_attribute93 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute93 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute93 := r_inst.pricing_attribute93;
         END IF;

         IF r_inst.pricing_attribute94 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute94 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute94 := r_inst.pricing_attribute94;
         END IF;

         IF r_inst.pricing_attribute95 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute95 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute95 := r_inst.pricing_attribute95;
         END IF;

         IF r_inst.pricing_attribute96 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute96 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute96 := r_inst.pricing_attribute96;
         END IF;

         IF r_inst.pricing_attribute97 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute97 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute97 := r_inst.pricing_attribute97;
         END IF;

         IF r_inst.pricing_attribute98 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute98 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute98 := r_inst.pricing_attribute98;
         END IF;

         IF r_inst.pricing_attribute99 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute99 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute99 := r_inst.pricing_attribute99;
         END IF;

         IF r_inst.pricing_attribute100 IS NULL THEN
          p_price_tbl(price_idx).pricing_attribute100 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).pricing_attribute100 := r_inst.pricing_attribute100;
         END IF;

         IF r_inst.pricing_flex_context IS NULL THEN
          p_price_tbl(price_idx).context := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).context := r_inst.pricing_flex_context;
         END IF;

         IF r_inst.pricing_flex_attribute1 IS NULL THEN
          p_price_tbl(price_idx).attribute1 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute1 := r_inst.pricing_flex_attribute1;
         END IF;

         IF r_inst.pricing_flex_attribute2 IS NULL THEN
          p_price_tbl(price_idx).attribute2 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute2 := r_inst.pricing_flex_attribute2;
         END IF;

         IF r_inst.pricing_flex_attribute3 IS NULL THEN
          p_price_tbl(price_idx).attribute3 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute3 := r_inst.pricing_flex_attribute3;
         END IF;

         IF r_inst.pricing_flex_attribute4 IS NULL THEN
          p_price_tbl(price_idx).attribute4 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute4 := r_inst.pricing_flex_attribute4;
         END IF;

         IF r_inst.pricing_flex_attribute5 IS NULL THEN
          p_price_tbl(price_idx).attribute5 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute5 := r_inst.pricing_flex_attribute5;
         END IF;

         IF r_inst.pricing_flex_attribute6 IS NULL THEN
          p_price_tbl(price_idx).attribute6 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute6 := r_inst.pricing_flex_attribute6;
         END IF;

         IF r_inst.pricing_flex_attribute7 IS NULL THEN
          p_price_tbl(price_idx).attribute7 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute7 := r_inst.pricing_flex_attribute7;
         END IF;

         IF r_inst.pricing_flex_attribute8 IS NULL THEN
          p_price_tbl(price_idx).attribute8 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute8 := r_inst.pricing_flex_attribute8;
         END IF;

         IF r_inst.pricing_flex_attribute9 IS NULL THEN
          p_price_tbl(price_idx).attribute9 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute9 := r_inst.pricing_flex_attribute9;
         END IF;

         IF r_inst.pricing_flex_attribute10 IS NULL THEN
          p_price_tbl(price_idx).attribute10 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute10 := r_inst.pricing_flex_attribute10;
         END IF;

         IF r_inst.pricing_flex_attribute11 IS NULL THEN
          p_price_tbl(price_idx).attribute11 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute11 := r_inst.pricing_flex_attribute11;
         END IF;

         IF r_inst.pricing_flex_attribute12 IS NULL THEN
          p_price_tbl(price_idx).attribute12 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute12 := r_inst.pricing_flex_attribute12;
         END IF;

         IF r_inst.pricing_flex_attribute13 IS NULL THEN
          p_price_tbl(price_idx).attribute13 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute13 := r_inst.pricing_flex_attribute13;
         END IF;

         IF r_inst.pricing_flex_attribute14 IS NULL THEN
          p_price_tbl(price_idx).attribute14 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute14 := r_inst.pricing_flex_attribute14;
         END IF;

         IF r_inst.pricing_flex_attribute15 IS NULL THEN
          p_price_tbl(price_idx).attribute15 := l_fnd_g_char;
         ELSE
          p_price_tbl(price_idx).attribute15 := r_inst.pricing_flex_attribute15;
         END IF;

         p_price_tbl(price_idx).object_version_number := 1;

       END IF;

       price_idx := price_idx + 1;
     END IF;    -- End of Pricing Attributes

     -- Org Assignments
     IF (r_inst.operating_unit            IS NOT NULL OR
         r_inst.ou_relation_type          IS NOT NULL OR
         r_inst.ou_start_date             IS NOT NULL OR
         r_inst.ou_end_date               IS NOT NULL) THEN

     IF nvl(r_inst.transaction_identifier,'-1') = '-1' THEN

       p_org_assign_tbl(orgass_idx).instance_ou_id    :=  NULL;
       p_org_assign_tbl(orgass_idx).instance_id       :=  NULL;
       p_org_assign_tbl(orgass_idx).parent_tbl_index  :=  inst_idx;

       IF r_inst.operating_unit IS NULL THEN
         p_org_assign_tbl(orgass_idx).operating_unit_id := l_fnd_g_num;
       ELSE
         p_org_assign_tbl(orgass_idx).operating_unit_id := r_inst.operating_unit;
       END IF;

       IF r_inst.ou_relation_type IS NULL THEN
         p_org_assign_tbl(orgass_idx).relationship_type_code := l_fnd_g_char;
       ELSE
         p_org_assign_tbl(orgass_idx).relationship_type_code := r_inst.ou_relation_type;
       END IF;

       p_org_assign_tbl(orgass_idx).active_start_date := l_fnd_g_date;

       IF r_inst.ou_end_date IS NULL THEN
         p_org_assign_tbl(orgass_idx).active_end_date := l_fnd_g_date;
       ELSE
         p_org_assign_tbl(orgass_idx).active_end_date := r_inst.ou_end_date;
       END IF;

       p_org_assign_tbl(orgass_idx).context := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute1 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute2 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute3 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute4 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute5 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute6 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute7 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute8 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute9 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute10 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute11 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute12 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute13 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute14 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).attribute15 := l_fnd_g_char;
       p_org_assign_tbl(orgass_idx).object_version_number := 1;

     END IF;

     orgass_idx := orgass_idx + 1;
     END IF;  -- End of Org Assignments

 --bnarayan added for open interface
   FOR c_assets_rec IN c_assets(r_inst.inst_interface_id)
     LOOP
        IF c_assets_rec.instance_asset_id IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).instance_asset_id :=l_fnd_g_num;
        ELSE
           x_asset_assignment_tbl( asset_idx ).instance_asset_id :=
                                                c_assets_rec.instance_asset_id;
        END IF;
        IF c_assets_rec.instance_id IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).instance_id :=l_fnd_g_num;
        ELSE
           x_asset_assignment_tbl( asset_idx ).instance_id :=
                                                c_assets_rec.instance_id;
        END IF;
        IF c_assets_rec.fa_asset_id IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).fa_asset_id :=l_fnd_g_num;
        ELSE
           x_asset_assignment_tbl( asset_idx ).fa_asset_id :=
                                                c_assets_rec.fa_asset_id;
        END IF;
        IF c_assets_rec.fa_book_type_code IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).fa_book_type_code:= l_fnd_g_char;
        ELSE
           x_asset_assignment_tbl( asset_idx ).fa_book_type_code :=
                                                c_assets_rec.fa_book_type_code;
        END IF;
        IF c_assets_rec.fa_location_id IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).fa_location_id :=l_fnd_g_num;
        ELSE
           x_asset_assignment_tbl( asset_idx ).fa_location_id :=
                                                c_assets_rec.fa_location_id;
        END IF;
        IF c_assets_rec.asset_quantity IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).asset_quantity :=l_fnd_g_num;
        ELSE
           x_asset_assignment_tbl( asset_idx ).asset_quantity :=
                                                c_assets_rec.asset_quantity;
        END IF;
        IF c_assets_rec.update_status IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).update_status :=l_fnd_g_char;
        ELSE
           x_asset_assignment_tbl( asset_idx ).update_status :=
                                                c_assets_rec.update_status;
        END IF;
        IF c_assets_rec.active_start_date IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).active_start_date :=l_fnd_g_date;
        ELSE
           x_asset_assignment_tbl( asset_idx ).active_start_date :=
                                                c_assets_rec.active_start_date;
        END IF;
        IF c_assets_rec.active_end_date IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).active_end_date :=l_fnd_g_date;
        ELSE
           x_asset_assignment_tbl( asset_idx ).active_end_date :=
                                                c_assets_rec.active_end_date;
        END IF;

         IF c_assets_rec.fa_sync_flag IS NULL THEN
           x_asset_assignment_tbl( asset_idx ).fa_sync_flag :=l_fnd_g_char;
        ELSE
           x_asset_assignment_tbl( asset_idx ).fa_sync_flag :=
                                                c_assets_rec.fa_sync_flag;
        END IF;

	 x_asset_assignment_tbl( asset_idx ).parent_tbl_index := inst_idx ;
        x_asset_assignment_tbl( asset_idx ).object_version_number := 1 ;
        asset_idx := asset_idx + 1 ;
     END LOOP;

     -- Transaction Table

     p_txn_tbl(inst_idx).transaction_date        := r_inst.source_transaction_date;
     p_txn_tbl(inst_idx).source_transaction_date := r_inst.source_transaction_date;
     p_txn_tbl(inst_idx).transaction_type_id     := l_txn_type_id;
     p_txn_tbl(inst_idx).transaction_quantity    := r_inst.quantity;
     p_txn_tbl(inst_idx).transaction_uom_code    := r_inst.unit_of_measure_code;
     p_txn_tbl(inst_idx).transacted_by           := r_inst.created_by;
     p_txn_tbl(inst_idx).transaction_status_code := 'COMPLETE';
     p_txn_tbl(inst_idx).transaction_action_code := NULL;
     p_txn_tbl(inst_idx).object_version_number   := 1;

     inst_idx := inst_idx + 1;
     END IF; -- End of Update or Create If
     END LOOP;

     a := 0;
     b := 0;
     c := 0;
     d := 0;
     e := 0;
     f := 0;
     g := 0;

     a := p_instance_tbl.count;
     b := p_party_tbl.count;
     c := p_account_tbl.count;
     d := p_ext_attrib_tbl.count;
     e := p_price_tbl.count;
     f := p_org_assign_tbl.count;
     g := p_txn_tbl.count;

  IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'Inst Records: '||a);
     FND_File.Put_Line(Fnd_File.LOG,'Party Records: '||b);
     FND_File.Put_Line(Fnd_File.LOG,'Acct Records: '||c);
     FND_File.Put_Line(Fnd_File.LOG,'Price Records: '||e);
     FND_File.Put_Line(Fnd_File.LOG,'Ext Attr Records: '||d);
     FND_File.Put_Line(Fnd_File.LOG,'Org Assign Records: '||f);
     FND_File.Put_Line(Fnd_File.LOG,'Txn Records: '||g);
  END IF;

     IF inst_idx = 1 then
       RAISE no_data_found;
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fnd_message.set_name('CSI','CSI_ML_NO_DATA_FOUND');
         fnd_message.set_token('API_NAME',l_api_name);
         fnd_message.set_token('FROM_DATE',l_txn_from_date);
         fnd_message.set_token('TO_DATE',l_txn_to_date);
         x_error_message := fnd_message.get;
         x_return_status := l_fnd_error;

       WHEN others THEN
         l_sql_error := SQLERRM;
         fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
         fnd_message.set_token('API_NAME',l_api_name);
         fnd_message.set_token('SQL_ERROR',SQLERRM);
         x_error_message := fnd_message.get;
         x_return_status := l_fnd_unexpected;

   END get_iface_create_recs;

PROCEDURE get_iface_rel_recs
 (
   p_txn_from_date         IN  VARCHAR2,
   p_txn_to_date           IN  VARCHAR2,
   p_source_system_name    IN  VARCHAR2,
   p_relationship_tbl      OUT NOCOPY CSI_DATASTRUCTURES_PUB.II_RELATIONSHIP_TBL,
   p_txn_tbl               OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_error_message         OUT NOCOPY VARCHAR2) IS

   rel_idx                 PLS_INTEGER;
   txn_idx                 PLS_INTEGER;
   l_fnd_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_error             VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_fnd_g_num             NUMBER      := FND_API.G_MISS_NUM;
   l_fnd_g_char            VARCHAR2(1) := FND_API.G_MISS_CHAR;
   l_fnd_g_date            DATE        := FND_API.G_MISS_DATE;
   l_fnd_g_true            VARCHAR2(1) := FND_API.G_TRUE;
   l_api_name              VARCHAR2(255) :=
                               'CSI_ML_CREATE_PVT.GET_IFACE_REL_RECS';

   l_sql_error     VARCHAR2(2000);
   l_debug_level  NUMBER := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

   a     NUMBER := 0;

   CURSOR c_rel (pc_txn_from_date      IN DATE,
	         pc_txn_to_date        IN DATE,
                 pc_source_system_name IN VARCHAR2) IS

     SELECT ciri.REL_INTERFACE_ID
           ,ciri.PARALLEL_WORKER_ID
           ,ciri.SUBJECT_INTERFACE_ID
           ,ciri.OBJECT_INTERFACE_ID
           ,ciri.RELATIONSHIP_TYPE_CODE
           ,ciri.RELATIONSHIP_START_DATE
           ,ciri.RELATIONSHIP_END_DATE
           ,ciri.POSITION_REFERENCE
           ,ciri.DISPLAY_ORDER
           ,ciri.MANDATORY_FLAG
           ,ciri.RELATIONSHIP_DIRECTION
           ,ciri.ERROR_TEXT
           ,ciri.CONTEXT
           ,ciri.ATTRIBUTE1
           ,ciri.ATTRIBUTE2
           ,ciri.ATTRIBUTE3
           ,ciri.ATTRIBUTE4
           ,ciri.ATTRIBUTE5
           ,ciri.ATTRIBUTE6
           ,ciri.ATTRIBUTE7
           ,ciri.ATTRIBUTE8
           ,ciri.ATTRIBUTE9
           ,ciri.ATTRIBUTE10
           ,ciri.ATTRIBUTE11
           ,ciri.ATTRIBUTE12
           ,ciri.ATTRIBUTE13
           ,ciri.ATTRIBUTE14
           ,ciri.ATTRIBUTE15
           ,cii1.transaction_identifier transaction_identifier
           ,cii1.instance_id subject_instance_id
           ,cii2.instance_id object_instance_id
     FROM   csi_ii_relation_interface   ciri,
            csi_instance_interface   cii1,
            csi_instance_interface   cii2
     WHERE  trunc(cii1.source_transaction_date) between
                          nvl(pc_txn_from_date,trunc(cii1.source_transaction_date)) and
                          nvl(pc_txn_to_date,trunc(cii1.source_transaction_date))
     AND cii1.process_status in ('X','E')
     AND cii1.source_system_name = nvl(pc_source_system_name,cii1.source_system_name)
     AND ciri.subject_interface_id = cii1.inst_interface_id

     AND trunc(cii2.source_transaction_date) between
                          nvl(pc_txn_from_date,trunc(cii2.source_transaction_date)) and
                          nvl(pc_txn_to_date,trunc(cii2.source_transaction_date))
     AND cii2.process_status in ('X','E')
     AND cii2.source_system_name = nvl(pc_source_system_name,cii2.source_system_name)
     AND ciri.object_interface_id = cii2.inst_interface_id;

     r_rel       c_rel%rowtype;
     l_txn_from_date date := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
     l_txn_to_date   date := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
   BEGIN

     rel_idx         := 1;
     txn_idx         := 1;
     x_return_status := l_fnd_success;

     FOR r_rel IN c_rel  (l_txn_from_date,
		          l_txn_to_date,
                          p_source_system_name) LOOP

       -- Set each column of the PL/SQL Record

     IF nvl(r_rel.transaction_identifier,'-1') = '-1' THEN

       p_relationship_tbl(rel_idx).relationship_id  := l_fnd_g_num;
       p_relationship_tbl(rel_idx).object_id        := r_rel.object_instance_id;
       p_relationship_tbl(rel_idx).subject_id      := r_rel.subject_instance_id;

       IF r_rel.relationship_type_code IS NULL THEN
         p_relationship_tbl(rel_idx).relationship_type_code := l_fnd_g_char;
       ELSE
         p_relationship_tbl(rel_idx).relationship_type_code := r_rel.relationship_type_code;
       END IF;

       p_relationship_tbl(rel_idx).subject_has_child := l_fnd_g_char;

       IF r_rel.position_reference IS NULL THEN
         p_relationship_tbl(rel_idx).position_reference := l_fnd_g_char;
       ELSE
         p_relationship_tbl(rel_idx).position_reference := r_rel.position_reference;
       END IF;

       p_relationship_tbl(rel_idx).active_start_date := l_fnd_g_date;

       IF r_rel.relationship_end_date IS NULL THEN
         p_relationship_tbl(rel_idx).active_end_date := l_fnd_g_date;
       ELSE
         p_relationship_tbl(rel_idx).active_end_date := r_rel.relationship_end_date;
       END IF;

       IF r_rel.display_order IS NULL THEN
         p_relationship_tbl(rel_idx).display_order := l_fnd_g_num;
       ELSE
         p_relationship_tbl(rel_idx).display_order := r_rel.display_order;
       END IF;

       p_relationship_tbl(rel_idx).mandatory_flag := l_fnd_g_char;

       p_relationship_tbl(rel_idx).context := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute1 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute2 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute3 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute4 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute5 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute6 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute7 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute8 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute9 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute10 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute11 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute12 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute13 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute14 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).attribute15 := l_fnd_g_char;
       p_relationship_tbl(rel_idx).object_version_number := 1;
       p_relationship_tbl(rel_idx).parent_tbl_index := l_fnd_g_num;
       p_relationship_tbl(rel_idx).processed_flag := l_fnd_g_char;

       rel_idx := rel_idx + 1;
       END IF; -- End of Create If
     END LOOP;

     a := p_relationship_tbl.count;

 IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'Relationship Records: '||a);
END IF;

     IF rel_idx = 1 then
       RAISE no_data_found;
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fnd_message.set_name('CSI','CSI_ML_NO_DATA_FOUND');
         fnd_message.set_token('API_NAME',l_api_name);
         fnd_message.set_token('FROM_DATE',l_txn_from_date);
         fnd_message.set_token('TO_DATE',l_txn_to_date);
         x_error_message := fnd_message.get;
         x_return_status := l_fnd_error;

       WHEN others THEN
         l_sql_error := SQLERRM;
         fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
         fnd_message.set_token('API_NAME',l_api_name);
         fnd_message.set_token('SQL_ERROR',SQLERRM);
         x_error_message := fnd_message.get;
         x_return_status := l_fnd_unexpected;

   END get_iface_rel_recs;

END CSI_ML_CREATE_PVT;

/
