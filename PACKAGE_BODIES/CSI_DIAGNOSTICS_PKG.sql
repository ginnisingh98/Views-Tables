--------------------------------------------------------
--  DDL for Package Body CSI_DIAGNOSTICS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_DIAGNOSTICS_PKG" as
/* $Header: csidiagb.pls 120.18 2007/10/24 00:34:50 lakmohan ship $ */

  g_no_lot constant number := 1;
  g_lot    constant number := 2;

  CURSOR error_cur is
    SELECT /*+ parallel(cte) */
           cte.inv_material_transaction_id mtl_txn_id,
           cte.transaction_error_id        txn_error_id
    FROM   csi_txn_errors cte
    WHERE  cte.processed_flag in ('E', 'R')
    AND    cte.inv_material_transaction_id is not null;

  -- this CURSOR returns the serial numbers that are in the transaction
  CURSOR srl_cur(
    p_mtl_txn_id     in number)
  IS
    SELECT mut.serial_number           serial_number,
           mut.inventory_item_id       item_id,
           mut.organization_id         organization_id
    FROM   mtl_unit_transactions mut
    WHERE  mut.transaction_id    = p_mtl_txn_id
    UNION
    SELECT mut.serial_number           serial_number,
           mut.inventory_item_id       item_id,
           mut.organization_id         organization_id
    FROM   mtl_transaction_lot_numbers mtln,
           mtl_unit_transactions       mut
    WHERE  mtln.transaction_id   = p_mtl_txn_id
    AND    mut.transaction_id    = mtln.serial_transaction_id;

  CURSOR all_txn_cur(
    p_serial_number  in varchar2,
    p_item_id        in number)
  IS
    SELECT mmt.creation_date               mtl_creation_date,
           mmt.transaction_id              mtl_txn_id,
           mmt.transaction_date            mtl_txn_date,
           mmt.inventory_item_id           item_id,
           mmt.organization_id             organization_id,
           mmt.transaction_type_id         mtl_type_id,
           mtt.transaction_type_name       mtl_txn_name,
           mmt.transaction_action_id       mtl_action_id,
           mmt.transaction_source_type_id  mtl_source_type_id,
           mmt.transaction_source_id       mtl_source_id,
           mmt.trx_source_line_id          mtl_source_line_id,
           mmt.transaction_quantity        mtl_txn_qty,
           mtt.type_class                  mtl_type_class,
           mmt.transfer_transaction_id     mtl_xfer_txn_id,
           mmt.revision                    mtl_revision,
           to_char(null)                   lot_number,
           to_char(mmt.transaction_date,'dd-mm-yy hh24:mi:ss') mtl_txn_char_date
    FROM   mtl_unit_transactions     mut,
           mtl_material_transactions mmt,
           mtl_transaction_types     mtt
    WHERE  mut.serial_number       = p_serial_number
    AND    mut.inventory_item_id   = p_item_id
    AND    mmt.transaction_id      = mut.transaction_id
    AND    mtt.transaction_type_id = mmt.transaction_type_id
    UNION
    SELECT mmt.creation_date               mtl_creation_date,
           mmt.transaction_id              mtl_txn_id,
           mmt.transaction_date            mtl_txn_date,
           mmt.inventory_item_id           item_id,
           mmt.organization_id             organization_id,
           mmt.transaction_type_id         mtl_type_id,
           mtt.transaction_type_name       mtl_txn_name,
           mmt.transaction_action_id       mtl_action_id,
           mmt.transaction_source_type_id  mtl_source_type_id,
           mmt.transaction_source_id       mtl_source_id,
           mmt.trx_source_line_id          mtl_source_line_id,
           mmt.transaction_quantity        mtl_txn_qty,
           mtt.type_class                  mtl_type_class,
           mmt.transfer_transaction_id     mtl_xfer_txn_id,
           mmt.revision                    mtl_revision,
           mtln.lot_number                 lot_number,
           to_char(mmt.transaction_date,'dd-mm-yy hh24:mi:ss') mtl_txn_char_date
    FROM   mtl_unit_transactions       mut,
           mtl_transaction_lot_numbers mtln,
           mtl_material_transactions   mmt,
           mtl_transaction_types       mtt
    WHERE  mut.serial_number          = p_serial_number
    AND    mut.inventory_item_id      = p_item_id
    AND    mtln.organization_id       = mut.organization_id
    AND    mtln.transaction_date      = mut.transaction_date
    AND    mtln.serial_transaction_id = mut.transaction_id
    AND    mmt.transaction_id         = mtln.transaction_id
    AND    mtt.transaction_type_id    = mmt.transaction_type_id
    ORDER BY 1 desc, 2 desc;

  CURSOR inv_cur(p_mtl_txn_id in number) IS
    SELECT mmt.inventory_item_id        item_id,
           mmt.organization_id          organization_id,
           mmt.transfer_organization_id xfer_organization_id,
           mmt.subinventory_code        subinv_code,
           mmt.locator_id               locator_id,
           mmt.revision                 revision,
           abs(mmt.primary_quantity)    quantity,
           mmt.transaction_date         mtl_txn_date,
           mmt.transaction_id           mtl_txn_id,
           mmt.transaction_action_id    mtl_action_id,
           mmt.trx_source_line_id       trx_source_line_id,
           mmt.transaction_source_id    mtl_source_id,
           mmt.source_project_id        source_project_id,
           mmt.source_task_id           source_task_id
    FROM   mtl_material_transactions mmt
    WHERE  mmt.transaction_id = p_mtl_txn_id;

  CURSOR from_sixfer_cur(
    p_mtl_txn_id       in number,
    p_mtl_xfer_txn_id  in number)
  IS
    SELECT mmt.inventory_item_id      item_id,
           mmt.organization_id        organization_id,
           mmt.subinventory_code      subinv_code,
           mmt.locator_id             locator_id,
           mmt.revision               revision,
           to_char(null)              lot_number,
           abs(mmt.primary_quantity)  quantity,
           mmt.transaction_date       mtl_txn_date,
           mmt.transaction_id         mtl_txn_id,
           mmt.trx_source_line_id     trx_source_line_id
    FROM   mtl_material_transactions mmt
    WHERE  (mmt.transaction_id = p_mtl_txn_id
             OR
            mmt.transaction_id = p_mtl_xfer_txn_id)
    AND    mmt.transaction_quantity < 0
    UNION
    SELECT mmt.inventory_item_id      item_id,
           mmt.organization_id        organization_id,
           mmt.subinventory_code      subinv_code,
           mmt.locator_id             locator_id,
           mmt.revision               revision,
           mtln.lot_number            lot_number,
           abs(mtln.primary_quantity) quantity,
           mmt.transaction_date       mtl_txn_date,
           mmt.transaction_id         mtl_txn_id,
           mmt.trx_source_line_id     trx_source_line_id
    FROM   mtl_material_transactions   mmt,
           mtl_transaction_lot_numbers mtln
    WHERE  (mmt.transaction_id  = p_mtl_txn_id
            OR
            mmt.transaction_id  = p_mtl_xfer_txn_id)
    AND    mmt.transaction_quantity < 0
    AND    mtln.transaction_id  = mmt.transaction_id;

  --
  PROCEDURE log(
    p_message       in varchar2)
  IS
  BEGIN

    fnd_file.put_line(fnd_file.log, p_message);

    csi_t_gen_utility_pvt.g_debug_level := 10;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csisynclog',
      p_file_segment2 => to_char(sysdate, 'mmddyy'));

    csi_t_gen_utility_pvt.add(p_message);

    csi_t_gen_utility_pvt.g_debug_level := 0;

  END log;

  --
  PROCEDURE out(
    p_message       in varchar2)
  IS
  BEGIN

    fnd_file.put_line(fnd_file.output, p_message);

    csi_t_gen_utility_pvt.g_debug_level := 10;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csisyncout',
      p_file_segment2 => to_char(sysdate, 'mmddyy'));

    csi_t_gen_utility_pvt.add(p_message);

    csi_t_gen_utility_pvt.g_debug_level := 0;

  END out;

  --
  FUNCTION date_time_stamp RETURN varchar2
  IS
    l_date_time_stamp varchar2(30);
  BEGIN

    SELECT to_char(sysdate,'DD-MON-YYYY HH24:MI:SS : ')
    INTO   l_date_time_stamp
    FROM   sys.dual;

    RETURN l_date_time_stamp;
  END date_time_stamp;

  --
  PROCEDURE debug_off IS
  BEGIN
    fnd_profile.put('CSI_DEBUG_LEVEL',0);
    fnd_profile.put('CSE_DEBUG_OPTION','N');
    fnd_profile.put('OKS_DEBUG','N');
    csi_t_gen_utility_pvt.g_debug_level := 0;
  END debug_off;

  --
  PROCEDURE stack_message(
    p_message       in varchar2)
  IS
  BEGIN
    fnd_msg_pub.initialize;
    fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE',p_message);
    fnd_msg_pub.add;
  END stack_message;
  --
  PROCEDURE Update_Lookup(p_routine_name in varchar2) IS
     l_type        VARCHAR2(30) := 'CSI_CORRECTION_ROUTINES';
  BEGIN
     UPDATE FND_LOOKUP_VALUES
     SET enabled_flag = 'N',
         last_updated_by = -1,
         last_update_date = sysdate
     WHERE lookup_type = l_type
     AND   lookup_code = p_routine_name;
  END Update_Lookup;
  --
  FUNCTION correction_txn_type_id RETURN NUMBER
  IS
    l_txn_type_id  number;
  BEGIN

    BEGIN
      SELECT transaction_type_id
      INTO   l_txn_type_id
      FROM   csi_txn_types
      WHERE  source_transaction_type = 'DATA_CORRECTION';
    EXCEPTION
      WHEN no_data_found THEN
        l_txn_type_id := 2;
    END;

    RETURN l_txn_type_id;

  END correction_txn_type_id;

  PROCEDURE get_lot_number(
    p_lot_code        IN  number,
    p_mtl_txn_id      IN  number,
    p_serial_number   IN  varchar2,
    x_lot_number      OUT nocopy varchar2)
  IS
    CURSOR lot_cur(cp_mtl_txn_id IN number, cp_serial_number IN varchar2) IS
      SELECT mtln.lot_number
      FROM   mtl_transaction_lot_numbers mtln,
             mtl_unit_transactions       mut
      WHERE  mtln.transaction_id       = cp_mtl_txn_id
      AND    mut.transaction_id        = mtln.serial_transaction_id
      AND    mut.serial_number         = cp_serial_number;
  BEGIN

    IF p_lot_code = 1 THEN
     x_lot_number := fnd_api.g_miss_char;
    END IF;

    IF p_lot_code = 2 THEN
      x_lot_number := fnd_api.g_miss_char;
      FOR lot_rec IN lot_cur(p_mtl_txn_id, p_serial_number)
      LOOP
        x_lot_number := lot_rec.lot_number;
      END LOOP;
    END IF;

  END get_lot_number;

  --
  PROCEDURE Build_Inst_Rec_of_Table
     (
       p_inst_tbl           IN      csi_datastructures_pub.instance_tbl
      ,p_inst_rec_tab       IN OUT NOCOPY   csi_diagnostics_pkg.instance_rec_tab
      ,p_inst_hist_tbl      IN OUT NOCOPY csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_inst_tbl.FIRST .. p_inst_tbl.LAST LOOP
        select CSI_ITEM_INSTANCES_H_S.nextval
        into p_inst_hist_tbl(i) from dual;
        --
	p_inst_rec_tab.INSTANCE_ID(i)                := p_inst_tbl(i).INSTANCE_ID;
	p_inst_rec_tab.INSTANCE_NUMBER(i)            := p_inst_tbl(i).INSTANCE_NUMBER;
	p_inst_rec_tab.EXTERNAL_REFERENCE(i)         := p_inst_tbl(i).EXTERNAL_REFERENCE;
	p_inst_rec_tab.INVENTORY_ITEM_ID(i)          := p_inst_tbl(i).INVENTORY_ITEM_ID;
	p_inst_rec_tab.VLD_ORGANIZATION_ID(i)        := p_inst_tbl(i).VLD_ORGANIZATION_ID;
	p_inst_rec_tab.INVENTORY_REVISION(i)         := p_inst_tbl(i).INVENTORY_REVISION;
	p_inst_rec_tab.INV_MASTER_ORGANIZATION_ID(i) :=	p_inst_tbl(i).INV_MASTER_ORGANIZATION_ID;
	p_inst_rec_tab.SERIAL_NUMBER(i)              := p_inst_tbl(i).SERIAL_NUMBER;
	p_inst_rec_tab.MFG_SERIAL_NUMBER_FLAG(i)     :=	p_inst_tbl(i).MFG_SERIAL_NUMBER_FLAG;
	p_inst_rec_tab.LOT_NUMBER(i)                 := p_inst_tbl(i).LOT_NUMBER;
	p_inst_rec_tab.QUANTITY(i)                   := p_inst_tbl(i).QUANTITY;
	p_inst_rec_tab.UNIT_OF_MEASURE(i)       :=	p_inst_tbl(i).UNIT_OF_MEASURE;
	p_inst_rec_tab.ACCOUNTING_CLASS_CODE(i)       :=	p_inst_tbl(i).ACCOUNTING_CLASS_CODE;
	p_inst_rec_tab.INSTANCE_CONDITION_ID(i)       :=	p_inst_tbl(i).INSTANCE_CONDITION_ID;
	p_inst_rec_tab.INSTANCE_STATUS_ID(i)       :=	p_inst_tbl(i).INSTANCE_STATUS_ID;
	p_inst_rec_tab.CUSTOMER_VIEW_FLAG(i)       :=	p_inst_tbl(i).CUSTOMER_VIEW_FLAG;
	p_inst_rec_tab.MERCHANT_VIEW_FLAG(i)       :=	p_inst_tbl(i).MERCHANT_VIEW_FLAG;
	p_inst_rec_tab.SELLABLE_FLAG(i)       :=	p_inst_tbl(i).SELLABLE_FLAG;
	p_inst_rec_tab.SYSTEM_ID(i)       :=	p_inst_tbl(i).SYSTEM_ID;
	p_inst_rec_tab.INSTANCE_TYPE_CODE(i)       :=	p_inst_tbl(i).INSTANCE_TYPE_CODE;
	p_inst_rec_tab.ACTIVE_START_DATE(i)       :=	p_inst_tbl(i).ACTIVE_START_DATE;
	p_inst_rec_tab.ACTIVE_END_DATE(i)       :=	p_inst_tbl(i).ACTIVE_END_DATE;
	p_inst_rec_tab.LOCATION_TYPE_CODE(i)       :=	p_inst_tbl(i).LOCATION_TYPE_CODE;
	p_inst_rec_tab.LOCATION_ID(i)       :=	p_inst_tbl(i).LOCATION_ID;
	p_inst_rec_tab.INV_ORGANIZATION_ID(i)       :=	p_inst_tbl(i).INV_ORGANIZATION_ID;
	p_inst_rec_tab.INV_SUBINVENTORY_NAME(i)       :=	p_inst_tbl(i).INV_SUBINVENTORY_NAME;
	p_inst_rec_tab.INV_LOCATOR_ID(i)       :=	p_inst_tbl(i).INV_LOCATOR_ID;
	p_inst_rec_tab.PA_PROJECT_ID(i)       :=	p_inst_tbl(i).PA_PROJECT_ID;
	p_inst_rec_tab.PA_PROJECT_TASK_ID(i)       :=	p_inst_tbl(i).PA_PROJECT_TASK_ID;
	p_inst_rec_tab.IN_TRANSIT_ORDER_LINE_ID(i)       :=	p_inst_tbl(i).IN_TRANSIT_ORDER_LINE_ID;
	p_inst_rec_tab.WIP_JOB_ID(i)       :=	p_inst_tbl(i).WIP_JOB_ID;
	p_inst_rec_tab.PO_ORDER_LINE_ID(i)       :=	p_inst_tbl(i).PO_ORDER_LINE_ID;
	p_inst_rec_tab.LAST_OE_ORDER_LINE_ID(i)       :=	p_inst_tbl(i).LAST_OE_ORDER_LINE_ID;
	p_inst_rec_tab.LAST_OE_RMA_LINE_ID(i)       :=	p_inst_tbl(i).LAST_OE_RMA_LINE_ID;
	p_inst_rec_tab.LAST_PO_PO_LINE_ID(i)       :=	p_inst_tbl(i).LAST_PO_PO_LINE_ID;
	p_inst_rec_tab.LAST_OE_PO_NUMBER(i)       :=	p_inst_tbl(i).LAST_OE_PO_NUMBER;
	p_inst_rec_tab.LAST_WIP_JOB_ID(i)       :=	p_inst_tbl(i).LAST_WIP_JOB_ID;
	p_inst_rec_tab.LAST_PA_PROJECT_ID(i)       :=	p_inst_tbl(i).LAST_PA_PROJECT_ID;
	p_inst_rec_tab.LAST_PA_TASK_ID(i)       :=	p_inst_tbl(i).LAST_PA_TASK_ID;
	p_inst_rec_tab.LAST_OE_AGREEMENT_ID(i)       :=	p_inst_tbl(i).LAST_OE_AGREEMENT_ID;
	p_inst_rec_tab.INSTALL_DATE(i)       :=	p_inst_tbl(i).INSTALL_DATE;
	p_inst_rec_tab.MANUALLY_CREATED_FLAG(i)       :=	p_inst_tbl(i).MANUALLY_CREATED_FLAG;
	p_inst_rec_tab.RETURN_BY_DATE(i)       :=	p_inst_tbl(i).RETURN_BY_DATE;
	p_inst_rec_tab.ACTUAL_RETURN_DATE(i)       :=	p_inst_tbl(i).ACTUAL_RETURN_DATE;
	p_inst_rec_tab.CREATION_COMPLETE_FLAG(i)       :=	p_inst_tbl(i).CREATION_COMPLETE_FLAG;
	p_inst_rec_tab.COMPLETENESS_FLAG(i)       :=	p_inst_tbl(i).COMPLETENESS_FLAG;
	p_inst_rec_tab.VERSION_LABEL(i)       :=	p_inst_tbl(i).VERSION_LABEL;
	p_inst_rec_tab.VERSION_LABEL_DESCRIPTION(i)       :=	p_inst_tbl(i).VERSION_LABEL_DESCRIPTION;
	p_inst_rec_tab.CONTEXT(i)       :=	p_inst_tbl(i).CONTEXT;
	p_inst_rec_tab.ATTRIBUTE1(i)       :=	p_inst_tbl(i).ATTRIBUTE1;
	p_inst_rec_tab.ATTRIBUTE2(i)       :=	p_inst_tbl(i).ATTRIBUTE2;
	p_inst_rec_tab.ATTRIBUTE3(i)       :=	p_inst_tbl(i).ATTRIBUTE3;
	p_inst_rec_tab.ATTRIBUTE4(i)       :=	p_inst_tbl(i).ATTRIBUTE4;
	p_inst_rec_tab.ATTRIBUTE5(i)       :=	p_inst_tbl(i).ATTRIBUTE5;
	p_inst_rec_tab.ATTRIBUTE6(i)       :=	p_inst_tbl(i).ATTRIBUTE6;
	p_inst_rec_tab.ATTRIBUTE7(i)       :=	p_inst_tbl(i).ATTRIBUTE7;
	p_inst_rec_tab.ATTRIBUTE8(i)       :=	p_inst_tbl(i).ATTRIBUTE8;
	p_inst_rec_tab.ATTRIBUTE9(i)       :=	p_inst_tbl(i).ATTRIBUTE9;
	p_inst_rec_tab.ATTRIBUTE10(i)       :=	p_inst_tbl(i).ATTRIBUTE10;
	p_inst_rec_tab.ATTRIBUTE11(i)       :=	p_inst_tbl(i).ATTRIBUTE11;
	p_inst_rec_tab.ATTRIBUTE12(i)       :=	p_inst_tbl(i).ATTRIBUTE12;
	p_inst_rec_tab.ATTRIBUTE13(i)       :=	p_inst_tbl(i).ATTRIBUTE13;
	p_inst_rec_tab.ATTRIBUTE14(i)       :=	p_inst_tbl(i).ATTRIBUTE14;
	p_inst_rec_tab.ATTRIBUTE15(i)       :=	p_inst_tbl(i).ATTRIBUTE15;
	p_inst_rec_tab.OBJECT_VERSION_NUMBER(i)       :=	p_inst_tbl(i).OBJECT_VERSION_NUMBER;
	p_inst_rec_tab.LAST_TXN_LINE_DETAIL_ID(i)       :=	p_inst_tbl(i).LAST_TXN_LINE_DETAIL_ID;
	p_inst_rec_tab.INSTALL_LOCATION_TYPE_CODE(i)       :=	p_inst_tbl(i).INSTALL_LOCATION_TYPE_CODE;
	p_inst_rec_tab.INSTALL_LOCATION_ID(i)       :=	p_inst_tbl(i).INSTALL_LOCATION_ID;
	p_inst_rec_tab.INSTANCE_USAGE_CODE(i)       :=	p_inst_tbl(i).INSTANCE_USAGE_CODE;
	p_inst_rec_tab.CONFIG_INST_HDR_ID(i)       :=	p_inst_tbl(i).CONFIG_INST_HDR_ID;
	p_inst_rec_tab.CONFIG_INST_REV_NUM(i)       :=	p_inst_tbl(i).CONFIG_INST_REV_NUM;
	p_inst_rec_tab.CONFIG_INST_ITEM_ID(i)       :=	p_inst_tbl(i).CONFIG_INST_ITEM_ID;
	p_inst_rec_tab.CONFIG_VALID_STATUS(i)       :=	p_inst_tbl(i).CONFIG_VALID_STATUS;
	p_inst_rec_tab.INSTANCE_DESCRIPTION(i)       :=	p_inst_tbl(i).INSTANCE_DESCRIPTION;
     END LOOP;
  END Build_Inst_Rec_of_Table;
  --
  PROCEDURE Build_Rel_Rec_of_Table
     (
       p_ii_relationship_tbl     IN csi_datastructures_pub.ii_relationship_tbl
      ,p_ii_relationship_rec_tab IN OUT NOCOPY csi_diagnostics_pkg.ii_relationship_rec_tab
      ,p_rel_hist_tbl            IN OUT NOCOPY csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_ii_relationship_tbl.FIRST .. p_ii_relationship_tbl.LAST LOOP
        select CSI_II_RELATIONSHIPS_H_S.nextval
        into p_rel_hist_tbl(i) from dual;
        --
	p_ii_relationship_rec_tab.RELATIONSHIP_ID(i)	:= p_ii_relationship_tbl(i).RELATIONSHIP_ID;
	p_ii_relationship_rec_tab.RELATIONSHIP_TYPE_CODE(i)	:= p_ii_relationship_tbl(i).RELATIONSHIP_TYPE_CODE;
	p_ii_relationship_rec_tab.OBJECT_ID(i)	:= p_ii_relationship_tbl(i).OBJECT_ID;
	p_ii_relationship_rec_tab.SUBJECT_ID(i)	:= p_ii_relationship_tbl(i).SUBJECT_ID;
	p_ii_relationship_rec_tab.SUBJECT_HAS_CHILD(i)	:= p_ii_relationship_tbl(i).SUBJECT_HAS_CHILD;
	p_ii_relationship_rec_tab.POSITION_REFERENCE(i)	:= p_ii_relationship_tbl(i).POSITION_REFERENCE;
	p_ii_relationship_rec_tab.ACTIVE_START_DATE(i)	:= p_ii_relationship_tbl(i).ACTIVE_START_DATE;
	p_ii_relationship_rec_tab.ACTIVE_END_DATE(i)	:= p_ii_relationship_tbl(i).ACTIVE_END_DATE;
	p_ii_relationship_rec_tab.DISPLAY_ORDER(i)	:= p_ii_relationship_tbl(i).DISPLAY_ORDER;
	p_ii_relationship_rec_tab.MANDATORY_FLAG(i)	:= p_ii_relationship_tbl(i).MANDATORY_FLAG;
	p_ii_relationship_rec_tab.CONTEXT(i)	:= p_ii_relationship_tbl(i).CONTEXT;
	p_ii_relationship_rec_tab.ATTRIBUTE1(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE1;
	p_ii_relationship_rec_tab.ATTRIBUTE2(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE2;
	p_ii_relationship_rec_tab.ATTRIBUTE3(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE3;
	p_ii_relationship_rec_tab.ATTRIBUTE4(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE4;
	p_ii_relationship_rec_tab.ATTRIBUTE5(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE5;
	p_ii_relationship_rec_tab.ATTRIBUTE6(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE6;
	p_ii_relationship_rec_tab.ATTRIBUTE7(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE7;
	p_ii_relationship_rec_tab.ATTRIBUTE8(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE8;
	p_ii_relationship_rec_tab.ATTRIBUTE9(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE9;
	p_ii_relationship_rec_tab.ATTRIBUTE10(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE10;
	p_ii_relationship_rec_tab.ATTRIBUTE11(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE11;
	p_ii_relationship_rec_tab.ATTRIBUTE12(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE12;
	p_ii_relationship_rec_tab.ATTRIBUTE13(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE13;
	p_ii_relationship_rec_tab.ATTRIBUTE14(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE14;
	p_ii_relationship_rec_tab.ATTRIBUTE15(i)	:= p_ii_relationship_tbl(i).ATTRIBUTE15;
	p_ii_relationship_rec_tab.OBJECT_VERSION_NUMBER(i)	:= p_ii_relationship_tbl(i).OBJECT_VERSION_NUMBER;
     END LOOP;
  END Build_Rel_Rec_of_Table;
  --
  PROCEDURE Build_Ver_Label_Rec_of_Table
     (
       p_version_label_tbl     IN     csi_datastructures_pub.version_label_tbl
      ,p_version_label_rec_tab IN OUT NOCOPY  csi_diagnostics_pkg.version_label_rec_tab
      ,p_ver_label_hist_tbl    IN OUT NOCOPY csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_version_label_tbl.FIRST .. p_version_label_tbl.LAST LOOP
        select CSI_I_VERSION_LABELS_H_S.nextval
        into p_ver_label_hist_tbl(i) from dual;
        --
	p_version_label_rec_tab.version_label_id(i)	:= p_version_label_tbl(i).version_label_id;
	p_version_label_rec_tab.instance_id(i)	:= p_version_label_tbl(i).instance_id;
	p_version_label_rec_tab.version_label(i)	:= p_version_label_tbl(i).version_label;
	p_version_label_rec_tab.description(i)	:= p_version_label_tbl(i).description;
	p_version_label_rec_tab.date_time_stamp(i)	:= p_version_label_tbl(i).date_time_stamp;
	p_version_label_rec_tab.active_start_date(i)	:= p_version_label_tbl(i).active_start_date;
	p_version_label_rec_tab.active_end_date(i)	:= p_version_label_tbl(i).active_end_date;
	p_version_label_rec_tab.context(i)	:= p_version_label_tbl(i).context;
	p_version_label_rec_tab.attribute1(i)	:= p_version_label_tbl(i).attribute1;
	p_version_label_rec_tab.attribute2(i)	:= p_version_label_tbl(i).attribute2;
	p_version_label_rec_tab.attribute3(i)	:= p_version_label_tbl(i).attribute3;
	p_version_label_rec_tab.attribute4(i)	:= p_version_label_tbl(i).attribute4;
	p_version_label_rec_tab.attribute5(i)	:= p_version_label_tbl(i).attribute5;
	p_version_label_rec_tab.attribute6(i)	:= p_version_label_tbl(i).attribute6;
	p_version_label_rec_tab.attribute7(i)	:= p_version_label_tbl(i).attribute7;
	p_version_label_rec_tab.attribute8(i)	:= p_version_label_tbl(i).attribute8;
	p_version_label_rec_tab.attribute9(i)	:= p_version_label_tbl(i).attribute9;
	p_version_label_rec_tab.attribute10(i)	:= p_version_label_tbl(i).attribute10;
	p_version_label_rec_tab.attribute11(i)	:= p_version_label_tbl(i).attribute11;
	p_version_label_rec_tab.attribute12(i)	:= p_version_label_tbl(i).attribute12;
	p_version_label_rec_tab.attribute13(i)	:= p_version_label_tbl(i).attribute13;
	p_version_label_rec_tab.attribute14(i)	:= p_version_label_tbl(i).attribute14;
	p_version_label_rec_tab.attribute15(i)	:= p_version_label_tbl(i).attribute15;
	p_version_label_rec_tab.object_version_number(i)	:= p_version_label_tbl(i).object_version_number;
     END LOOP;
  END Build_Ver_Label_Rec_of_Table;
  --
  PROCEDURE Build_Party_Rec_of_Table
     ( p_party_tbl          IN   csi_datastructures_pub.party_tbl
      ,p_party_rec_tab      IN OUT NOCOPY  csi_diagnostics_pkg.party_rec_tab
      ,p_party_hist_tbl     IN OUT NOCOPY  csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
        select CSI_I_PARTIES_H_S.nextval
        into p_party_hist_tbl(i) from dual;
        --
	p_party_rec_tab.instance_party_id(i)	  := p_party_tbl(i).instance_party_id;
	p_party_rec_tab.instance_id(i)	  := p_party_tbl(i).instance_id;
	p_party_rec_tab.party_source_table(i)	  := p_party_tbl(i).party_source_table;
	p_party_rec_tab.party_id(i)	  := p_party_tbl(i).party_id;
	p_party_rec_tab.relationship_type_code(i)	  := p_party_tbl(i).relationship_type_code;
	p_party_rec_tab.contact_flag(i)	  := p_party_tbl(i).contact_flag;
	p_party_rec_tab.contact_ip_id(i)	  := p_party_tbl(i).contact_ip_id;
	p_party_rec_tab.active_start_date(i)	  := p_party_tbl(i).active_start_date;
	p_party_rec_tab.active_end_date(i)	  := p_party_tbl(i).active_end_date;
	p_party_rec_tab.context(i)	  := p_party_tbl(i).context;
	p_party_rec_tab.attribute1(i)	  := p_party_tbl(i).attribute1;
	p_party_rec_tab.attribute2(i)	  := p_party_tbl(i).attribute2;
	p_party_rec_tab.attribute3(i)	  := p_party_tbl(i).attribute3;
	p_party_rec_tab.attribute4(i)	  := p_party_tbl(i).attribute4;
	p_party_rec_tab.attribute5(i)	  := p_party_tbl(i).attribute5;
	p_party_rec_tab.attribute6(i)	  := p_party_tbl(i).attribute6;
	p_party_rec_tab.attribute7(i)	  := p_party_tbl(i).attribute7;
	p_party_rec_tab.attribute8(i)	  := p_party_tbl(i).attribute8;
	p_party_rec_tab.attribute9(i)	  := p_party_tbl(i).attribute9;
	p_party_rec_tab.attribute10(i)	  := p_party_tbl(i).attribute10;
	p_party_rec_tab.attribute11(i)	  := p_party_tbl(i).attribute11;
	p_party_rec_tab.attribute12(i)	  := p_party_tbl(i).attribute12;
	p_party_rec_tab.attribute13(i)	  := p_party_tbl(i).attribute13;
	p_party_rec_tab.attribute14(i)	  := p_party_tbl(i).attribute14;
	p_party_rec_tab.attribute15(i)	  := p_party_tbl(i).attribute15;
	p_party_rec_tab.object_version_number(i)	  := p_party_tbl(i).object_version_number;
	p_party_rec_tab.primary_flag(i)	  := p_party_tbl(i).primary_flag;
	p_party_rec_tab.preferred_flag(i)	  := p_party_tbl(i).preferred_flag;
     END LOOP;
  END Build_Party_Rec_of_Table;
  --
  PROCEDURE Build_Acct_Rec_of_Table
     (
       p_account_tbl        IN     csi_datastructures_pub.party_account_tbl
      ,p_account_rec_tab    IN OUT NOCOPY  csi_diagnostics_pkg.account_rec_tab
      ,p_account_hist_tbl   IN OUT NOCOPY  csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_account_tbl.FIRST .. p_account_tbl.LAST LOOP
        select CSI_IP_ACCOUNTS_H_S.nextval
        into p_account_hist_tbl(i) from dual;
        --
	p_account_rec_tab.ip_account_id(i)	 := p_account_tbl(i).ip_account_id;
	p_account_rec_tab.parent_tbl_index(i)	 := p_account_tbl(i).parent_tbl_index;
	p_account_rec_tab.instance_party_id(i)	 := p_account_tbl(i).instance_party_id;
	p_account_rec_tab.party_account_id(i)	 := p_account_tbl(i).party_account_id;
	p_account_rec_tab.relationship_type_code(i)	 := p_account_tbl(i).relationship_type_code;
	p_account_rec_tab.bill_to_address(i)	 := p_account_tbl(i).bill_to_address;
	p_account_rec_tab.ship_to_address(i)	 := p_account_tbl(i).ship_to_address;
	p_account_rec_tab.active_start_date(i)	 := p_account_tbl(i).active_start_date;
	p_account_rec_tab.active_end_date(i)	 := p_account_tbl(i).active_end_date;
	p_account_rec_tab.context(i)	 := p_account_tbl(i).context;
	p_account_rec_tab.attribute1(i)	 := p_account_tbl(i).attribute1;
	p_account_rec_tab.attribute2(i)	 := p_account_tbl(i).attribute2;
	p_account_rec_tab.attribute3(i)	 := p_account_tbl(i).attribute3;
	p_account_rec_tab.attribute4(i)	 := p_account_tbl(i).attribute4;
	p_account_rec_tab.attribute5(i)	 := p_account_tbl(i).attribute5;
	p_account_rec_tab.attribute6(i)	 := p_account_tbl(i).attribute6;
	p_account_rec_tab.attribute7(i)	 := p_account_tbl(i).attribute7;
	p_account_rec_tab.attribute8(i)	 := p_account_tbl(i).attribute8;
	p_account_rec_tab.attribute9(i)	 := p_account_tbl(i).attribute9;
	p_account_rec_tab.attribute10(i)	 := p_account_tbl(i).attribute10;
	p_account_rec_tab.attribute11(i)	 := p_account_tbl(i).attribute11;
	p_account_rec_tab.attribute12(i)	 := p_account_tbl(i).attribute12;
	p_account_rec_tab.attribute13(i)	 := p_account_tbl(i).attribute13;
	p_account_rec_tab.attribute14(i)	 := p_account_tbl(i).attribute14;
	p_account_rec_tab.attribute15(i)	 := p_account_tbl(i).attribute15;
	p_account_rec_tab.object_version_number(i)	 := p_account_tbl(i).object_version_number;
	p_account_rec_tab.call_contracts(i)	 := p_account_tbl(i).call_contracts;
	p_account_rec_tab.vld_organization_id(i)	 := p_account_tbl(i).vld_organization_id;
	p_account_rec_tab.expire_flag(i)	 := p_account_tbl(i).expire_flag;
     END LOOP;
  END Build_Acct_Rec_of_Table;
  --
  PROCEDURE Build_Org_Rec_of_Table
     (
       p_org_tbl                 IN      csi_datastructures_pub.organization_units_tbl
      ,p_org_units_rec_tab       IN OUT NOCOPY   csi_diagnostics_pkg.org_units_rec_tab
     ,p_org_hist_tbl             IN OUT NOCOPY   csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_org_tbl.FIRST .. p_org_tbl.LAST LOOP
       select CSI_I_ORG_ASSIGNMENTS_H_S.nextval
       into p_org_hist_tbl(i) from dual;
       --
       p_org_units_rec_tab.instance_ou_id(i)          := p_org_tbl(i).instance_ou_id;
       p_org_units_rec_tab.instance_id(i)	            := p_org_tbl(i).instance_id;
       p_org_units_rec_tab.operating_unit_id(i)       := p_org_tbl(i).operating_unit_id;
       p_org_units_rec_tab.relationship_type_code(i)  := p_org_tbl(i).relationship_type_code;
       p_org_units_rec_tab.active_start_date(i)       := p_org_tbl(i).active_start_date;
       p_org_units_rec_tab.active_end_date(i)         := p_org_tbl(i).active_end_date;
       p_org_units_rec_tab.context(i)	            := p_org_tbl(i).context;
       p_org_units_rec_tab.attribute1(i)	            := p_org_tbl(i).attribute1;
       p_org_units_rec_tab.attribute2(i)	            := p_org_tbl(i).attribute2;
       p_org_units_rec_tab.attribute3(i)	            := p_org_tbl(i).attribute3;
       p_org_units_rec_tab.attribute4(i)	            := p_org_tbl(i).attribute4;
       p_org_units_rec_tab.attribute5(i)	            := p_org_tbl(i).attribute5;
       p_org_units_rec_tab.attribute6(i)	            := p_org_tbl(i).attribute6;
       p_org_units_rec_tab.attribute7(i)	            := p_org_tbl(i).attribute7;
       p_org_units_rec_tab.attribute8(i)	            := p_org_tbl(i).attribute8;
       p_org_units_rec_tab.attribute9(i)	            := p_org_tbl(i).attribute9;
       p_org_units_rec_tab.attribute10(i)	            := p_org_tbl(i).attribute10;
       p_org_units_rec_tab.attribute11(i)	            := p_org_tbl(i).attribute11;
       p_org_units_rec_tab.attribute12(i)	            := p_org_tbl(i).attribute12;
       p_org_units_rec_tab.attribute13(i)	            := p_org_tbl(i).attribute13;
       p_org_units_rec_tab.attribute14(i)	            := p_org_tbl(i).attribute14;
       p_org_units_rec_tab.attribute15(i)	            := p_org_tbl(i).attribute15;
       p_org_units_rec_tab.object_version_number(i)   := p_org_tbl(i).object_version_number;
     END LOOP;
  END Build_Org_Rec_of_Table;
  --
  PROCEDURE Build_pricing_Rec_of_Table
     (
       p_pricing_tbl           IN      csi_datastructures_pub.pricing_attribs_tbl
      ,p_pricing_rec_tab       IN OUT NOCOPY   csi_diagnostics_pkg.pricing_attribs_rec_tab
      ,p_pricing_hist_tbl      IN OUT NOCOPY   csi_diagnostics_pkg.T_NUM
     ) IS
  BEGIN
     FOR i in p_pricing_tbl.FIRST .. p_pricing_tbl.LAST LOOP
        select CSI_I_PRICING_ATTRIBS_H_S.nextval
        into p_pricing_hist_tbl(i) from dual;
        --
	 p_pricing_rec_tab.pricing_attribute_id(i)    := p_pricing_tbl(i).pricing_attribute_id;
	 p_pricing_rec_tab.instance_id(i)	            := p_pricing_tbl(i).instance_id;
	 p_pricing_rec_tab.active_start_date(i)	    := p_pricing_tbl(i).active_start_date;
	 p_pricing_rec_tab.active_end_date(i)	        := p_pricing_tbl(i).active_end_date;
	 p_pricing_rec_tab.pricing_context(i)	        := p_pricing_tbl(i).pricing_context;
	 p_pricing_rec_tab.pricing_attribute1(i)	    := p_pricing_tbl(i).pricing_attribute1;
	 p_pricing_rec_tab.pricing_attribute2(i)	    := p_pricing_tbl(i).pricing_attribute2;
	 p_pricing_rec_tab.pricing_attribute3(i)	    := p_pricing_tbl(i).pricing_attribute3;
	 p_pricing_rec_tab.pricing_attribute4(i)	    := p_pricing_tbl(i).pricing_attribute4;
	 p_pricing_rec_tab.pricing_attribute5(i)	    := p_pricing_tbl(i).pricing_attribute5;
	 p_pricing_rec_tab.pricing_attribute6(i)	    := p_pricing_tbl(i).pricing_attribute6;
	 p_pricing_rec_tab.pricing_attribute7(i)	    := p_pricing_tbl(i).pricing_attribute7;
	 p_pricing_rec_tab.pricing_attribute8(i) 	    := p_pricing_tbl(i).pricing_attribute8;
	 p_pricing_rec_tab.pricing_attribute9(i)	    := p_pricing_tbl(i).pricing_attribute9;
	 p_pricing_rec_tab.pricing_attribute10(i)	    := p_pricing_tbl(i).pricing_attribute10;
	 p_pricing_rec_tab.pricing_attribute11(i)	    := p_pricing_tbl(i).pricing_attribute11;
	 p_pricing_rec_tab.pricing_attribute12(i)	    := p_pricing_tbl(i).pricing_attribute12;
	 p_pricing_rec_tab.pricing_attribute13(i)	    := p_pricing_tbl(i).pricing_attribute13;
	 p_pricing_rec_tab.pricing_attribute14(i)	    := p_pricing_tbl(i).pricing_attribute14;
	 p_pricing_rec_tab.pricing_attribute15(i)	    := p_pricing_tbl(i).pricing_attribute15;
	 p_pricing_rec_tab.pricing_attribute16(i)	    := p_pricing_tbl(i).pricing_attribute16;
	 p_pricing_rec_tab.pricing_attribute17(i)	    := p_pricing_tbl(i).pricing_attribute17;
	 p_pricing_rec_tab.pricing_attribute18(i)	    := p_pricing_tbl(i).pricing_attribute18;
	 p_pricing_rec_tab.pricing_attribute19(i)	    := p_pricing_tbl(i).pricing_attribute19;
	 p_pricing_rec_tab.pricing_attribute20(i)	    := p_pricing_tbl(i).pricing_attribute20;
	 p_pricing_rec_tab.pricing_attribute21(i)	    := p_pricing_tbl(i).pricing_attribute21;
	 p_pricing_rec_tab.pricing_attribute22(i)	    := p_pricing_tbl(i).pricing_attribute22;
	 p_pricing_rec_tab.pricing_attribute23(i)	    := p_pricing_tbl(i).pricing_attribute23;
	 p_pricing_rec_tab.pricing_attribute24(i)	    := p_pricing_tbl(i).pricing_attribute24;
	 p_pricing_rec_tab.pricing_attribute25(i)	    := p_pricing_tbl(i).pricing_attribute25;
	 p_pricing_rec_tab.pricing_attribute26(i)	    := p_pricing_tbl(i).pricing_attribute26;
	 p_pricing_rec_tab.pricing_attribute27(i)	    := p_pricing_tbl(i).pricing_attribute27;
	 p_pricing_rec_tab.pricing_attribute28(i)	    := p_pricing_tbl(i).pricing_attribute28;
	 p_pricing_rec_tab.pricing_attribute29(i)	    := p_pricing_tbl(i).pricing_attribute29;
	 p_pricing_rec_tab.pricing_attribute30(i)	    := p_pricing_tbl(i).pricing_attribute30;
	 p_pricing_rec_tab.pricing_attribute31(i)	    := p_pricing_tbl(i).pricing_attribute31;
	 p_pricing_rec_tab.pricing_attribute32(i)	    := p_pricing_tbl(i).pricing_attribute32;
	 p_pricing_rec_tab.pricing_attribute33(i)     := p_pricing_tbl(i).pricing_attribute33;
	 p_pricing_rec_tab.pricing_attribute34(i)	    := p_pricing_tbl(i).pricing_attribute34;
	 p_pricing_rec_tab.pricing_attribute35(i)	    := p_pricing_tbl(i).pricing_attribute35;
	 p_pricing_rec_tab.pricing_attribute36(i)	    := p_pricing_tbl(i).pricing_attribute36;
	 p_pricing_rec_tab.pricing_attribute37(i)	    := p_pricing_tbl(i).pricing_attribute37;
	 p_pricing_rec_tab.pricing_attribute38(i)	    := p_pricing_tbl(i).pricing_attribute38;
	 p_pricing_rec_tab.pricing_attribute39(i)	    := p_pricing_tbl(i).pricing_attribute39;
	 p_pricing_rec_tab.pricing_attribute40(i)	    := p_pricing_tbl(i).pricing_attribute40;
	 p_pricing_rec_tab.pricing_attribute41(i)	    := p_pricing_tbl(i).pricing_attribute41;
	 p_pricing_rec_tab.pricing_attribute42(i)	    := p_pricing_tbl(i).pricing_attribute42;
	 p_pricing_rec_tab.pricing_attribute43(i)     := p_pricing_tbl(i).pricing_attribute43;
	 p_pricing_rec_tab.pricing_attribute44(i)	    := p_pricing_tbl(i).pricing_attribute44;
	 p_pricing_rec_tab.pricing_attribute45(i)	    := p_pricing_tbl(i).pricing_attribute45;
	 p_pricing_rec_tab.pricing_attribute46(i)	    := p_pricing_tbl(i).pricing_attribute46;
	 p_pricing_rec_tab.pricing_attribute47(i)	    := p_pricing_tbl(i).pricing_attribute47;
	 p_pricing_rec_tab.pricing_attribute48(i)	    := p_pricing_tbl(i).pricing_attribute48;
	 p_pricing_rec_tab.pricing_attribute49(i)	    := p_pricing_tbl(i).pricing_attribute49;
	 p_pricing_rec_tab.pricing_attribute50(i)	    := p_pricing_tbl(i).pricing_attribute50;
	 p_pricing_rec_tab.pricing_attribute51(i)	    := p_pricing_tbl(i).pricing_attribute51;
	 p_pricing_rec_tab.pricing_attribute52(i)	    := p_pricing_tbl(i).pricing_attribute52;
	 p_pricing_rec_tab.pricing_attribute53(i)	    := p_pricing_tbl(i).pricing_attribute53;
	 p_pricing_rec_tab.pricing_attribute54(i)	    := p_pricing_tbl(i).pricing_attribute54;
	 p_pricing_rec_tab.pricing_attribute55(i)	    := p_pricing_tbl(i).pricing_attribute55;
	 p_pricing_rec_tab.pricing_attribute56(i)	    := p_pricing_tbl(i).pricing_attribute56;
	 p_pricing_rec_tab.pricing_attribute57(i)	    := p_pricing_tbl(i).pricing_attribute57;
	 p_pricing_rec_tab.pricing_attribute58(i)	    := p_pricing_tbl(i).pricing_attribute58;
	 p_pricing_rec_tab.pricing_attribute59(i)	    := p_pricing_tbl(i).pricing_attribute59;
	 p_pricing_rec_tab.pricing_attribute60(i)	    := p_pricing_tbl(i).pricing_attribute60;
	 p_pricing_rec_tab.pricing_attribute61(i)	    := p_pricing_tbl(i).pricing_attribute61;
	 p_pricing_rec_tab.pricing_attribute62(i)	    := p_pricing_tbl(i).pricing_attribute62;
	 p_pricing_rec_tab.pricing_attribute63(i)	    := p_pricing_tbl(i).pricing_attribute63;
	 p_pricing_rec_tab.pricing_attribute64(i)	    := p_pricing_tbl(i).pricing_attribute64;
	 p_pricing_rec_tab.pricing_attribute65(i)	    := p_pricing_tbl(i).pricing_attribute65;
	 p_pricing_rec_tab.pricing_attribute66(i)	    := p_pricing_tbl(i).pricing_attribute66;
	 p_pricing_rec_tab.pricing_attribute67(i)	    := p_pricing_tbl(i).pricing_attribute67;
	 p_pricing_rec_tab.pricing_attribute68(i)	    := p_pricing_tbl(i).pricing_attribute68;
	 p_pricing_rec_tab.pricing_attribute69(i)	    := p_pricing_tbl(i).pricing_attribute69;
	 p_pricing_rec_tab.pricing_attribute70(i)	    := p_pricing_tbl(i).pricing_attribute70;
	 p_pricing_rec_tab.pricing_attribute71(i)	    := p_pricing_tbl(i).pricing_attribute71;
	 p_pricing_rec_tab.pricing_attribute72(i)	    := p_pricing_tbl(i).pricing_attribute72;
	 p_pricing_rec_tab.pricing_attribute73(i)	    := p_pricing_tbl(i).pricing_attribute73;
	 p_pricing_rec_tab.pricing_attribute74(i)	    := p_pricing_tbl(i).pricing_attribute74;
	 p_pricing_rec_tab.pricing_attribute75(i)	    := p_pricing_tbl(i).pricing_attribute75;
	 p_pricing_rec_tab.pricing_attribute76(i)	    := p_pricing_tbl(i).pricing_attribute76;
	 p_pricing_rec_tab.pricing_attribute77(i)	    := p_pricing_tbl(i).pricing_attribute77;
	 p_pricing_rec_tab.pricing_attribute78(i)	    := p_pricing_tbl(i).pricing_attribute78;
	 p_pricing_rec_tab.pricing_attribute79(i)	    := p_pricing_tbl(i).pricing_attribute79;
	 p_pricing_rec_tab.pricing_attribute80(i)	    := p_pricing_tbl(i).pricing_attribute80;
	 p_pricing_rec_tab.pricing_attribute81(i)	    := p_pricing_tbl(i).pricing_attribute81;
	 p_pricing_rec_tab.pricing_attribute82(i)	    := p_pricing_tbl(i).pricing_attribute82;
	 p_pricing_rec_tab.pricing_attribute83(i)	    := p_pricing_tbl(i).pricing_attribute83;
	 p_pricing_rec_tab.pricing_attribute84(i)	    := p_pricing_tbl(i).pricing_attribute84;
	 p_pricing_rec_tab.pricing_attribute85(i)	    := p_pricing_tbl(i).pricing_attribute85;
	 p_pricing_rec_tab.pricing_attribute86(i)	    := p_pricing_tbl(i).pricing_attribute86;
	 p_pricing_rec_tab.pricing_attribute87(i)	    := p_pricing_tbl(i).pricing_attribute87;
	 p_pricing_rec_tab.pricing_attribute88(i)	    := p_pricing_tbl(i).pricing_attribute88;
	 p_pricing_rec_tab.pricing_attribute89(i)	    := p_pricing_tbl(i).pricing_attribute89;
	 p_pricing_rec_tab.pricing_attribute90(i)	    := p_pricing_tbl(i).pricing_attribute90;
	 p_pricing_rec_tab.pricing_attribute91(i)	    := p_pricing_tbl(i).pricing_attribute91;
	 p_pricing_rec_tab.pricing_attribute92(i)	    := p_pricing_tbl(i).pricing_attribute92;
	 p_pricing_rec_tab.pricing_attribute93(i)	    := p_pricing_tbl(i).pricing_attribute93;
	 p_pricing_rec_tab.pricing_attribute94(i)	    := p_pricing_tbl(i).pricing_attribute94;
	 p_pricing_rec_tab.pricing_attribute95(i)	    := p_pricing_tbl(i).pricing_attribute95;
	 p_pricing_rec_tab.pricing_attribute96(i)	    := p_pricing_tbl(i).pricing_attribute96;
	 p_pricing_rec_tab.pricing_attribute97(i)	    := p_pricing_tbl(i).pricing_attribute97;
	 p_pricing_rec_tab.pricing_attribute98(i)	    := p_pricing_tbl(i).pricing_attribute98;
	 p_pricing_rec_tab.pricing_attribute99(i)	    := p_pricing_tbl(i).pricing_attribute99;
	 p_pricing_rec_tab.pricing_attribute100(i)    := p_pricing_tbl(i).pricing_attribute100;
	 p_pricing_rec_tab.context(i)	                := p_pricing_tbl(i).context;
	 p_pricing_rec_tab.attribute1(i)	            := p_pricing_tbl(i).attribute1;
	 p_pricing_rec_tab.attribute2(i)	            := p_pricing_tbl(i).attribute2;
	 p_pricing_rec_tab.attribute3(i)	            := p_pricing_tbl(i).attribute3;
	 p_pricing_rec_tab.attribute4(i)	            := p_pricing_tbl(i).attribute4;
	 p_pricing_rec_tab.attribute5(i)	            := p_pricing_tbl(i).attribute5;
	 p_pricing_rec_tab.attribute6(i)	            := p_pricing_tbl(i).attribute6;
	 p_pricing_rec_tab.attribute7(i)	            := p_pricing_tbl(i).attribute7;
	 p_pricing_rec_tab.attribute8(i)	            := p_pricing_tbl(i).attribute8;
	 p_pricing_rec_tab.attribute9(i)	            := p_pricing_tbl(i).attribute9;
	 p_pricing_rec_tab.attribute10(i)	            := p_pricing_tbl(i).attribute10;
	 p_pricing_rec_tab.attribute11(i)	            := p_pricing_tbl(i).attribute11;
	 p_pricing_rec_tab.attribute12(i)	            := p_pricing_tbl(i).attribute12;
	 p_pricing_rec_tab.attribute13(i)	            := p_pricing_tbl(i).attribute13;
	 p_pricing_rec_tab.attribute14(i)	            := p_pricing_tbl(i).attribute14;
	 p_pricing_rec_tab.attribute15(i)	            := p_pricing_tbl(i).attribute15;
	 p_pricing_rec_tab.object_version_number(i)   := p_pricing_tbl(i).object_version_number;
     END LOOP;
  END Build_pricing_Rec_of_Table;
  --
  PROCEDURE Build_Ext_Attr_Rec_Table
     (
       p_ext_attr_tbl     IN     csi_datastructures_pub.extend_attrib_values_tbl
      ,p_ext_attr_rec_tab IN OUT NOCOPY  csi_diagnostics_pkg.extend_attrib_values_rec_tab
     ,p_ext_hist_tbl      IN OUT NOCOPY  csi_diagnostics_pkg.T_NUM
     ) IS

  BEGIN
     FOR i in p_ext_attr_tbl.FIRST .. p_ext_attr_tbl.LAST LOOP
       select CSI_IEA_VALUES_H_S.nextval
       into p_ext_hist_tbl(i) from dual;
       --
       p_ext_attr_rec_tab.attribute_value_id(i)      :=  p_ext_attr_tbl(i).attribute_value_id;
       p_ext_attr_rec_tab.instance_id(i)             :=  p_ext_attr_tbl(i).instance_id;
       p_ext_attr_rec_tab.attribute_id(i)            :=  p_ext_attr_tbl(i).attribute_id;
       p_ext_attr_rec_tab.attribute_code(i)          :=  p_ext_attr_tbl(i).attribute_code;
       p_ext_attr_rec_tab.attribute_value(i)         :=  p_ext_attr_tbl(i).attribute_value;
       p_ext_attr_rec_tab.active_start_date(i)       :=  p_ext_attr_tbl(i).active_start_date;
       p_ext_attr_rec_tab.active_end_date(i)         :=  p_ext_attr_tbl(i).active_end_date;
       p_ext_attr_rec_tab.context(i)                 :=  p_ext_attr_tbl(i).context;
       p_ext_attr_rec_tab.attribute1(i)              :=  p_ext_attr_tbl(i).attribute1;
       p_ext_attr_rec_tab.attribute2 (i)             :=  p_ext_attr_tbl(i).attribute2;
       p_ext_attr_rec_tab.attribute3(i)              :=  p_ext_attr_tbl(i).attribute3;
       p_ext_attr_rec_tab.attribute4(i)              :=  p_ext_attr_tbl(i).attribute4;
       p_ext_attr_rec_tab.attribute5(i)              :=  p_ext_attr_tbl(i).attribute5;
       p_ext_attr_rec_tab.attribute6(i)              :=  p_ext_attr_tbl(i).attribute6;
       p_ext_attr_rec_tab.attribute7(i)              :=  p_ext_attr_tbl(i).attribute7;
       p_ext_attr_rec_tab.attribute8(i)              :=  p_ext_attr_tbl(i).attribute8;
       p_ext_attr_rec_tab.attribute9(i)              :=  p_ext_attr_tbl(i).attribute9;
       p_ext_attr_rec_tab.attribute10(i)             :=  p_ext_attr_tbl(i).attribute10;
       p_ext_attr_rec_tab.attribute11(i)             :=  p_ext_attr_tbl(i).attribute11;
       p_ext_attr_rec_tab.attribute12(i)             :=  p_ext_attr_tbl(i).attribute12;
       p_ext_attr_rec_tab.attribute13(i)             :=  p_ext_attr_tbl(i).attribute13;
       p_ext_attr_rec_tab.attribute14(i)             :=  p_ext_attr_tbl(i).attribute14;
       p_ext_attr_rec_tab.attribute15(i)             :=  p_ext_attr_tbl(i).attribute15;
       p_ext_attr_rec_tab.object_version_number(i)   :=  p_ext_attr_tbl(i).object_version_number;
     END LOOP;
  END Build_Ext_Attr_Rec_Table;
  --
  PROCEDURE Build_Asset_Rec_Table
     (
       p_asset_tbl     IN     csi_datastructures_pub.instance_asset_tbl
      ,p_asset_rec_tab IN OUT NOCOPY  csi_diagnostics_pkg.instance_asset_rec_tab
      ,p_asset_hist_tbl IN OUT NOCOPY  csi_diagnostics_pkg.T_NUM
     ) IS

  BEGIN
     FOR i in p_asset_tbl.FIRST .. p_asset_tbl.LAST LOOP
       select CSI_I_ASSETS_H_S.nextval
       into p_asset_hist_tbl(i) from dual;
       --
       p_asset_rec_tab.instance_asset_id(i)          := p_asset_tbl(i).instance_asset_id;
       p_asset_rec_tab.instance_id(i)                := p_asset_tbl(i).instance_id;
       p_asset_rec_tab.fa_asset_id(i)                := p_asset_tbl(i).fa_asset_id;
       p_asset_rec_tab.fa_book_type_code(i)          := p_asset_tbl(i).fa_book_type_code;
       p_asset_rec_tab.fa_location_id(i)             := p_asset_tbl(i).fa_location_id;
       p_asset_rec_tab.asset_quantity(i)             := p_asset_tbl(i).asset_quantity;
       p_asset_rec_tab.update_status(i)              := p_asset_tbl(i).update_status;
       p_asset_rec_tab.active_start_date(i)          := p_asset_tbl(i).active_start_date;
       p_asset_rec_tab.active_end_date(i)            := p_asset_tbl(i).active_end_date;
       p_asset_rec_tab.object_version_number(i)      := p_asset_tbl(i).object_version_number;
       p_asset_rec_tab.check_for_instance_expiry(i)  := p_asset_tbl(i).check_for_instance_expiry;

     END LOOP;
     --
  END Build_Asset_Rec_Table;
  --

  PROCEDURE make_non_header(
    p_inst_h_rec       IN  csi_datastructures_pub.instance_header_rec,
    p_pty_h_tbl        IN  csi_datastructures_pub.party_header_tbl,
    p_pa_h_tbl         IN  csi_datastructures_pub.party_account_header_tbl,
    p_ou_h_tbl         IN  csi_datastructures_pub.org_units_header_tbl,
    p_asset_h_tbl      IN  csi_datastructures_pub.instance_asset_header_tbl,
    x_inst_rec         OUT nocopy csi_datastructures_pub.instance_rec,
    x_pty_tbl          OUT nocopy csi_datastructures_pub.party_tbl,
    x_pa_tbl           OUT nocopy csi_datastructures_pub.party_account_tbl,
    x_ou_tbl           OUT nocopy csi_datastructures_pub.organization_units_tbl,
    x_asset_tbl        OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status    OUT nocopy varchar2)
  IS
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    x_inst_rec.instance_id                := p_inst_h_rec.instance_id;
    x_inst_rec.instance_number            := p_inst_h_rec.instance_number;
    x_inst_rec.external_reference         := p_inst_h_rec.external_reference;
    x_inst_rec.inventory_item_id          := p_inst_h_rec.inventory_item_id;
    x_inst_rec.inventory_revision         := p_inst_h_rec.inventory_revision;
    x_inst_rec.inv_master_organization_id := p_inst_h_rec.inv_master_organization_id;
    x_inst_rec.serial_number              := p_inst_h_rec.serial_number;
    x_inst_rec.mfg_serial_number_flag     := p_inst_h_rec.mfg_serial_number_flag;
    x_inst_rec.lot_number                 := p_inst_h_rec.lot_number;
    x_inst_rec.quantity                   := p_inst_h_rec.quantity;
    x_inst_rec.unit_of_measure            := p_inst_h_rec.unit_of_measure;
    x_inst_rec.accounting_class_code      := p_inst_h_rec.accounting_class_code;
    x_inst_rec.instance_condition_id      := p_inst_h_rec.instance_condition_id;
    x_inst_rec.instance_usage_code        := p_inst_h_rec.instance_usage_code;
    x_inst_rec.instance_status_id         := p_inst_h_rec.instance_status_id;
    x_inst_rec.customer_view_flag         := p_inst_h_rec.customer_view_flag;
    x_inst_rec.merchant_view_flag         := p_inst_h_rec.merchant_view_flag;
    x_inst_rec.sellable_flag              := p_inst_h_rec.sellable_flag;
    x_inst_rec.system_id                  := p_inst_h_rec.system_id;
    x_inst_rec.instance_type_code         := p_inst_h_rec.instance_type_code;
    x_inst_rec.active_start_date          := p_inst_h_rec.active_start_date;
    x_inst_rec.active_end_date            := p_inst_h_rec.active_end_date;
    x_inst_rec.location_type_code         := p_inst_h_rec.location_type_code;
    x_inst_rec.location_id                := p_inst_h_rec.location_id;
    x_inst_rec.install_location_type_code := p_inst_h_rec.install_location_type_code;
    x_inst_rec.install_location_id        := p_inst_h_rec.install_location_id;
    x_inst_rec.inv_organization_id        := p_inst_h_rec.inv_organization_id;
    x_inst_rec.inv_subinventory_name      := p_inst_h_rec.inv_subinventory_name;
    x_inst_rec.inv_locator_id             := p_inst_h_rec.inv_locator_id;
    x_inst_rec.pa_project_id              := p_inst_h_rec.pa_project_id;
    x_inst_rec.pa_project_task_id         := p_inst_h_rec.pa_project_task_id;
    x_inst_rec.in_transit_order_line_id   := p_inst_h_rec.in_transit_order_line_id;
    x_inst_rec.wip_job_id                 := p_inst_h_rec.wip_job_id;
    x_inst_rec.po_order_line_id           := p_inst_h_rec.po_order_line_id;
    x_inst_rec.last_oe_order_line_id      := p_inst_h_rec.last_oe_order_line_id;
    x_inst_rec.last_oe_rma_line_id        := p_inst_h_rec.last_oe_rma_line_id;
    x_inst_rec.last_po_po_line_id         := p_inst_h_rec.last_po_po_line_id;
    x_inst_rec.last_oe_po_number          := p_inst_h_rec.last_oe_po_number;
    x_inst_rec.last_wip_job_id            := p_inst_h_rec.last_wip_job_id;
    x_inst_rec.last_pa_project_id         := p_inst_h_rec.last_pa_project_id;
    x_inst_rec.last_pa_task_id            := p_inst_h_rec.last_pa_task_id;
    x_inst_rec.last_oe_agreement_id       := p_inst_h_rec.last_oe_agreement_id;
    x_inst_rec.install_date               := p_inst_h_rec.install_date;
    x_inst_rec.manually_created_flag      := p_inst_h_rec.manually_created_flag;
    x_inst_rec.return_by_date             := p_inst_h_rec.return_by_date;
    x_inst_rec.actual_return_date         := p_inst_h_rec.actual_return_date;
    x_inst_rec.creation_complete_flag     := p_inst_h_rec.creation_complete_flag;
    x_inst_rec.completeness_flag          := p_inst_h_rec.completeness_flag;
    x_inst_rec.context                    := p_inst_h_rec.context;
    x_inst_rec.attribute1                 := p_inst_h_rec.attribute1;
    x_inst_rec.attribute2                 := p_inst_h_rec.attribute2;
    x_inst_rec.attribute3                 := p_inst_h_rec.attribute3;
    x_inst_rec.attribute4                 := p_inst_h_rec.attribute4;
    x_inst_rec.attribute5                 := p_inst_h_rec.attribute5;
    x_inst_rec.attribute6                 := p_inst_h_rec.attribute6;
    x_inst_rec.attribute7                 := p_inst_h_rec.attribute7;
    x_inst_rec.attribute8                 := p_inst_h_rec.attribute8;
    x_inst_rec.attribute9                 := p_inst_h_rec.attribute9;
    x_inst_rec.attribute10                := p_inst_h_rec.attribute10;
    x_inst_rec.attribute11                := p_inst_h_rec.attribute11;
    x_inst_rec.attribute12                := p_inst_h_rec.attribute12;
    x_inst_rec.attribute13                := p_inst_h_rec.attribute13;
    x_inst_rec.attribute14                := p_inst_h_rec.attribute14;
    x_inst_rec.attribute15                := p_inst_h_rec.attribute15;
    x_inst_rec.object_version_number      := p_inst_h_rec.object_version_number;
    x_inst_rec.config_inst_hdr_id         := p_inst_h_rec.config_inst_hdr_id;
    x_inst_rec.config_inst_rev_num        := p_inst_h_rec.config_inst_rev_num;
    x_inst_rec.config_inst_item_id        := p_inst_h_rec.config_inst_item_id;
    x_inst_rec.config_valid_status        := p_inst_h_rec.config_valid_status;
    x_inst_rec.instance_description       := p_inst_h_rec.instance_description;


    IF p_pty_h_tbl.COUNT > 0 THEN
      FOR l_ind IN p_pty_h_tbl.FIRST .. p_pty_h_tbl.LAST
      LOOP
        x_pty_tbl(l_ind).instance_party_id        := p_pty_h_tbl(l_ind).instance_party_id;
        x_pty_tbl(l_ind).instance_id              := p_pty_h_tbl(l_ind).instance_id;
        x_pty_tbl(l_ind).party_source_table       := p_pty_h_tbl(l_ind).party_source_table;
        x_pty_tbl(l_ind).party_id                 := p_pty_h_tbl(l_ind).party_id;
        x_pty_tbl(l_ind).relationship_type_code   := p_pty_h_tbl(l_ind).relationship_type_code;
        x_pty_tbl(l_ind).contact_flag             := p_pty_h_tbl(l_ind).contact_flag;
        x_pty_tbl(l_ind).contact_ip_id            := p_pty_h_tbl(l_ind).contact_ip_id;
        x_pty_tbl(l_ind).active_start_date        := p_pty_h_tbl(l_ind).active_start_date;
        x_pty_tbl(l_ind).active_end_date          := p_pty_h_tbl(l_ind).active_end_date;
        x_pty_tbl(l_ind).context                  := p_pty_h_tbl(l_ind).context;
        x_pty_tbl(l_ind).attribute1               := p_pty_h_tbl(l_ind).attribute1;
        x_pty_tbl(l_ind).attribute2               := p_pty_h_tbl(l_ind).attribute2;
        x_pty_tbl(l_ind).attribute3               := p_pty_h_tbl(l_ind).attribute3;
        x_pty_tbl(l_ind).attribute4               := p_pty_h_tbl(l_ind).attribute4;
        x_pty_tbl(l_ind).attribute5               := p_pty_h_tbl(l_ind).attribute5;
        x_pty_tbl(l_ind).attribute6               := p_pty_h_tbl(l_ind).attribute6;
        x_pty_tbl(l_ind).attribute7               := p_pty_h_tbl(l_ind).attribute7;
        x_pty_tbl(l_ind).attribute8               := p_pty_h_tbl(l_ind).attribute8;
        x_pty_tbl(l_ind).attribute9               := p_pty_h_tbl(l_ind).attribute9;
        x_pty_tbl(l_ind).attribute10              := p_pty_h_tbl(l_ind).attribute10;
        x_pty_tbl(l_ind).attribute11              := p_pty_h_tbl(l_ind).attribute11;
        x_pty_tbl(l_ind).attribute12              := p_pty_h_tbl(l_ind).attribute12;
        x_pty_tbl(l_ind).attribute13              := p_pty_h_tbl(l_ind).attribute13;
        x_pty_tbl(l_ind).attribute14              := p_pty_h_tbl(l_ind).attribute14;
        x_pty_tbl(l_ind).attribute15              := p_pty_h_tbl(l_ind).attribute15;
        x_pty_tbl(l_ind).primary_flag             := p_pty_h_tbl(l_ind).primary_flag;
        x_pty_tbl(l_ind).preferred_flag           := p_pty_h_tbl(l_ind).preferred_flag;
        SELECT object_version_number
        INTO   x_pty_tbl(l_ind).object_version_number
        FROM   csi_i_parties
        WHERE  instance_party_id = p_pty_h_tbl(l_ind).instance_party_id;
      END LOOP;
    END IF;

    IF p_pa_h_tbl.count > 0 THEN
      FOR l_ind IN p_pa_h_tbl.FIRST .. p_pa_h_tbl.LAST
      LOOP

        x_pa_tbl(l_ind).ip_account_id          := p_pa_h_tbl(l_ind).ip_account_id;
        x_pa_tbl(l_ind).instance_party_id      := p_pa_h_tbl(l_ind).instance_party_id;
        x_pa_tbl(l_ind).party_account_id       := p_pa_h_tbl(l_ind).party_account_id;
        x_pa_tbl(l_ind).relationship_type_code := p_pa_h_tbl(l_ind).relationship_type_code;
        x_pa_tbl(l_ind).bill_to_address        := p_pa_h_tbl(l_ind).bill_to_address;
        x_pa_tbl(l_ind).ship_to_address        := p_pa_h_tbl(l_ind).ship_to_address;
        x_pa_tbl(l_ind).active_start_date      := p_pa_h_tbl(l_ind).active_start_date;
        x_pa_tbl(l_ind).active_end_date        := p_pa_h_tbl(l_ind).active_end_date;
        x_pa_tbl(l_ind).context                := p_pa_h_tbl(l_ind).context;
        x_pa_tbl(l_ind).attribute1             := p_pa_h_tbl(l_ind).attribute1;
        x_pa_tbl(l_ind).attribute2             := p_pa_h_tbl(l_ind).attribute2;
        x_pa_tbl(l_ind).attribute3             := p_pa_h_tbl(l_ind).attribute3;
        x_pa_tbl(l_ind).attribute4             := p_pa_h_tbl(l_ind).attribute4;
        x_pa_tbl(l_ind).attribute5             := p_pa_h_tbl(l_ind).attribute5;
        x_pa_tbl(l_ind).attribute6             := p_pa_h_tbl(l_ind).attribute6;
        x_pa_tbl(l_ind).attribute7             := p_pa_h_tbl(l_ind).attribute7;
        x_pa_tbl(l_ind).attribute8             := p_pa_h_tbl(l_ind).attribute8;
        x_pa_tbl(l_ind).attribute9             := p_pa_h_tbl(l_ind).attribute9;
        x_pa_tbl(l_ind).attribute10            := p_pa_h_tbl(l_ind).attribute10;
        x_pa_tbl(l_ind).attribute11            := p_pa_h_tbl(l_ind).attribute11;
        x_pa_tbl(l_ind).attribute12            := p_pa_h_tbl(l_ind).attribute12;
        x_pa_tbl(l_ind).attribute13            := p_pa_h_tbl(l_ind).attribute13;
        x_pa_tbl(l_ind).attribute14            := p_pa_h_tbl(l_ind).attribute14;
        x_pa_tbl(l_ind).attribute15            := p_pa_h_tbl(l_ind).attribute15;
        SELECT object_version_number
        INTO   x_pa_tbl(l_ind).object_version_number
        FROM   csi_ip_accounts
        WHERE  ip_account_id = p_pa_h_tbl(l_ind).ip_account_id;

      END LOOP;
    END IF;

    IF p_ou_h_tbl.count > 0 THEN
      FOR l_ind IN p_ou_h_tbl.FIRST .. p_ou_h_tbl.LAST
      LOOP

        x_ou_tbl(l_ind).instance_ou_id         := p_ou_h_tbl(l_ind).instance_ou_id;
        x_ou_tbl(l_ind).instance_id            := p_ou_h_tbl(l_ind).instance_id;
        x_ou_tbl(l_ind).operating_unit_id      := p_ou_h_tbl(l_ind).operating_unit_id;
        x_ou_tbl(l_ind).relationship_type_code := p_ou_h_tbl(l_ind).relationship_type_code;
        x_ou_tbl(l_ind).active_start_date      := p_ou_h_tbl(l_ind).active_start_date;
        x_ou_tbl(l_ind).active_end_date        := p_ou_h_tbl(l_ind).active_end_date;
        x_ou_tbl(l_ind).context                := p_ou_h_tbl(l_ind).context;
        x_ou_tbl(l_ind).attribute1             := p_ou_h_tbl(l_ind).attribute1;
        x_ou_tbl(l_ind).attribute2             := p_ou_h_tbl(l_ind).attribute2;
        x_ou_tbl(l_ind).attribute3             := p_ou_h_tbl(l_ind).attribute3;
        x_ou_tbl(l_ind).attribute4             := p_ou_h_tbl(l_ind).attribute4;
        x_ou_tbl(l_ind).attribute5             := p_ou_h_tbl(l_ind).attribute5;
        x_ou_tbl(l_ind).attribute6             := p_ou_h_tbl(l_ind).attribute6;
        x_ou_tbl(l_ind).attribute7             := p_ou_h_tbl(l_ind).attribute7;
        x_ou_tbl(l_ind).attribute8             := p_ou_h_tbl(l_ind).attribute8;
        x_ou_tbl(l_ind).attribute9             := p_ou_h_tbl(l_ind).attribute9;
        x_ou_tbl(l_ind).attribute10            := p_ou_h_tbl(l_ind).attribute10;
        x_ou_tbl(l_ind).attribute11            := p_ou_h_tbl(l_ind).attribute11;
        x_ou_tbl(l_ind).attribute12            := p_ou_h_tbl(l_ind).attribute12;
        x_ou_tbl(l_ind).attribute13            := p_ou_h_tbl(l_ind).attribute13;
        x_ou_tbl(l_ind).attribute14            := p_ou_h_tbl(l_ind).attribute14;
        x_ou_tbl(l_ind).attribute15            := p_ou_h_tbl(l_ind).attribute15;
        SELECT object_version_number
        INTO   x_ou_tbl(l_ind).object_version_number
        FROM   csi_i_org_assignments
        WHERE  instance_ou_id = p_ou_h_tbl(l_ind).instance_ou_id;

      END LOOP;
    END IF;

    IF p_asset_h_tbl.count > 0 THEN
      FOR l_ind IN p_asset_h_tbl.FIRST .. p_asset_h_tbl.LAST
      LOOP

        x_asset_tbl(l_ind).instance_asset_id     := p_asset_h_tbl(l_ind).instance_asset_id;
        x_asset_tbl(l_ind).instance_id           := p_asset_h_tbl(l_ind).instance_id;
        x_asset_tbl(l_ind).fa_asset_id           := p_asset_h_tbl(l_ind).fa_asset_id;
        x_asset_tbl(l_ind).fa_book_type_code     := p_asset_h_tbl(l_ind).fa_book_type_code;
        x_asset_tbl(l_ind).fa_location_id        := p_asset_h_tbl(l_ind).fa_location_id;
        x_asset_tbl(l_ind).asset_quantity        := p_asset_h_tbl(l_ind).asset_quantity;
        x_asset_tbl(l_ind).update_status         := p_asset_h_tbl(l_ind).update_status;
        x_asset_tbl(l_ind).active_start_date     := p_asset_h_tbl(l_ind).active_start_date;
        x_asset_tbl(l_ind).active_end_date       := p_asset_h_tbl(l_ind).active_end_date;
        SELECT object_version_number
        INTO   x_asset_tbl(l_ind).object_version_number
        FROM   csi_i_assets
        WHERE  instance_asset_id = p_asset_h_tbl(l_ind).instance_asset_id;

      END LOOP;
    END IF;

  END make_non_header;
  --
  PROCEDURE forward_sync IS

    CURSOR fs_cur IS
      SELECT instance_id,
             date_time_stamp,
             inventory_item_id,
             serial_number,
             lot_control_code,
             mtl_txn_id,
             mtl_txn_creation_date
      FROM   csi_ii_forward_sync_temp
      WHERE  process_flag <> 'P';

    l_txn_type_id          number;
    l_error_exists         varchar2(1) := 'N';
    l_csi_txn_rec          csi_datastructures_pub.transaction_rec;

    -- get instance details variables
    g_inst_rec             csi_datastructures_pub.instance_header_rec;
    g_pty_tbl              csi_datastructures_pub.party_header_tbl;
    g_pa_tbl               csi_datastructures_pub.party_account_header_tbl;
    g_ou_tbl               csi_datastructures_pub.org_units_header_tbl;
    g_prc_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    g_eav_tbl              csi_datastructures_pub.extend_attrib_values_tbl;
    g_ea_tbl               csi_datastructures_pub.extend_attrib_tbl;
    g_asset_tbl            csi_datastructures_pub.instance_asset_header_tbl;


    -- get version label variables
    g_vl_qry_rec           csi_datastructures_pub.version_label_query_rec;
    g_vl_tbl               csi_datastructures_pub.version_label_tbl;

    -- get relationship variables
    l_iir_qry_rec          csi_datastructures_pub.relationship_query_rec;
    g_iir_qry_rec          csi_datastructures_pub.relationship_query_rec;
    l_iir_tbl              csi_datastructures_pub.ii_relationship_tbl;
    g_iir_tbl              csi_datastructures_pub.ii_relationship_tbl;
    iir_ind                binary_integer := 0;


    -- update item instance variables
    l_inst_rec             csi_datastructures_pub.instance_rec;
    l_pty_tbl              csi_datastructures_pub.party_tbl;
    l_pa_tbl               csi_datastructures_pub.party_account_tbl;
    l_ou_tbl               csi_datastructures_pub.organization_units_tbl;
    l_eav_tbl              csi_datastructures_pub.extend_attrib_values_tbl;
    l_prc_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_asset_tbl            csi_datastructures_pub.instance_asset_tbl;
    l_inst_ids_tbl         csi_datastructures_pub.id_tbl;
    l_txn_rec              csi_datastructures_pub.transaction_rec;
    l_vl_tbl               csi_datastructures_pub.version_label_tbl;

    l_return_status        varchar2(1);
    l_msg_data             varchar2(2000);
    l_msg_count            number;

    PROCEDURE init_struct(
      px_inst_rec     IN OUT nocopy csi_datastructures_pub.instance_header_rec,
      px_pty_tbl      IN OUT nocopy csi_datastructures_pub.party_header_tbl,
      px_pa_tbl       IN OUT nocopy csi_datastructures_pub.party_account_header_tbl,
      px_ou_tbl       IN OUT nocopy csi_datastructures_pub.org_units_header_tbl,
      px_prc_tbl      IN OUT nocopy csi_datastructures_pub.pricing_attribs_tbl,
      px_eav_tbl      IN OUT nocopy csi_datastructures_pub.extend_attrib_values_tbl,
      px_ea_tbl       IN OUT nocopy csi_datastructures_pub.extend_attrib_tbl,
      px_asset_tbl    IN OUT nocopy csi_datastructures_pub.instance_asset_header_tbl,
      px_vl_qry_rec   IN OUT nocopy csi_datastructures_pub.version_label_query_rec,
      px_vl_tbl       IN OUT nocopy csi_datastructures_pub.version_label_tbl,
      px_iir_qry_rec  IN OUT nocopy csi_datastructures_pub.relationship_query_rec,
      px_iir_tbl      IN OUT nocopy csi_datastructures_pub.ii_relationship_tbl)
    IS
      l_inst_rec      csi_datastructures_pub.instance_header_rec;
      l_vl_qry_rec    csi_datastructures_pub.version_label_query_rec;
      l_iir_qry_rec   csi_datastructures_pub.relationship_query_rec;
    BEGIN
      px_inst_rec     := l_inst_rec;
      px_vl_qry_rec   := l_vl_qry_rec;
      px_iir_qry_rec  := l_iir_qry_rec;
      px_pty_tbl.delete;
      px_pa_tbl.delete;
      px_ou_tbl.delete;
      px_prc_tbl.delete;
      px_eav_tbl.delete;
      px_ea_tbl.delete;
      px_asset_tbl.delete;
      px_vl_tbl.delete;
      px_iir_tbl.delete;
    END init_struct;
  BEGIN

    l_csi_txn_rec.transaction_type_id     := correction_txn_type_id;
    l_csi_txn_rec.transaction_date        := sysdate;
    l_csi_txn_rec.source_transaction_date := sysdate;
    l_csi_txn_rec.source_header_ref       := 'Forward Synch';

    SELECT csi_ii_forward_sync_temp_s.nextval
    INTO   l_csi_txn_rec.source_line_ref_id
    FROM   sys.dual;

    FOR fs_rec IN fs_cur
    LOOP

      iir_ind := 0;

      -- check for pending errors
      FOR all_txn in all_txn_cur(fs_rec.serial_number,fs_rec.inventory_item_id)
      LOOP

        IF all_txn.mtl_creation_date < fs_rec.mtl_txn_creation_date THEN
          BEGIN
            SELECT 'Y'
            INTO   l_error_exists
            FROM   csi_txn_errors
            WHERE  processed_flag in ('E','R')
            AND    inv_material_transaction_id = all_txn.mtl_txn_id
            AND    rownum < 2;
            EXIT;
          EXCEPTION
            WHEN no_data_found then
              l_error_exists := 'N';
          END;
        END IF;
      END LOOP;

      IF l_error_exists = 'N' THEN

        init_struct(
          px_inst_rec     => g_inst_rec,
          px_pty_tbl      => g_pty_tbl,
          px_pa_tbl       => g_pa_tbl,
          px_ou_tbl       => g_ou_tbl,
          px_prc_tbl      => g_prc_tbl,
          px_eav_tbl      => g_eav_tbl,
          px_ea_tbl       => g_ea_tbl,
          px_asset_tbl    => g_asset_tbl,
          px_vl_qry_rec   => g_vl_qry_rec,
          px_vl_tbl       => g_vl_tbl,
          px_iir_qry_rec  => g_iir_qry_rec,
          px_iir_tbl      => g_iir_tbl);

        BEGIN

          savepoint forward_sync;

          g_inst_rec.instance_id := fs_rec.instance_id;

          log('time stamp for old fetch : '||to_char(fs_rec.date_time_stamp, 'dd-mon-yyyy hh24:mi:ss'));

          csi_item_instance_pub.get_item_instance_details (
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => g_inst_rec,
            p_get_parties           => fnd_api.g_true,
            p_party_header_tbl      => g_pty_tbl,
            p_get_accounts          => fnd_api.g_true,
            p_account_header_tbl    => g_pa_tbl,
            p_get_org_assignments   => fnd_api.g_true,
            p_org_header_tbl        => g_ou_tbl,
            p_get_pricing_attribs   => fnd_api.g_true,
            p_pricing_attrib_tbl    => g_prc_tbl,
            p_get_ext_attribs       => fnd_api.g_true,
            p_ext_attrib_tbl        => g_eav_tbl,
            p_ext_attrib_def_tbl    => g_ea_tbl,
            p_get_asset_assignments => fnd_api.g_true,
            p_asset_header_tbl      => g_asset_tbl,
            p_resolve_id_columns    => fnd_api.g_false,
            p_time_stamp            => fs_rec.date_time_stamp,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- some missed out or wrong data columns - re-query and populate
          SELECT customer_view_flag,
                 merchant_view_flag,
                 quantity,
                 object_version_number
          INTO   g_inst_rec.customer_view_flag,
                 g_inst_rec.merchant_view_flag,
                 g_inst_rec.quantity,
                 g_inst_rec.object_version_number
          FROM   csi_item_instances
          WHERE  instance_id = g_inst_rec.instance_id;

          g_vl_qry_rec.instance_id := g_inst_rec.instance_id;

          -- get the version label on that day
          csi_item_instance_pub.get_version_labels(
            p_api_version             => 1.0,
            p_commit                  => fnd_api.g_false,
            p_init_msg_list           => fnd_api.g_true,
            p_validation_level        => fnd_api.g_valid_level_full,
            p_version_label_query_rec => g_vl_qry_rec,
            p_time_stamp              => fs_rec.date_time_stamp,
            x_version_label_tbl       => g_vl_tbl,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          make_non_header(
            p_inst_h_rec            => g_inst_rec,
            p_pty_h_tbl             => g_pty_tbl,
            p_pa_h_tbl              => g_pa_tbl,
            p_ou_h_tbl              => g_ou_tbl,
            p_asset_h_tbl           => g_asset_tbl,
            x_inst_rec              => l_inst_rec,
            x_pty_tbl               => l_pty_tbl,
            x_pa_tbl                => l_pa_tbl,
            x_ou_tbl                => l_ou_tbl,
            x_asset_tbl             => l_asset_tbl,
            x_return_status         => l_return_status);

          l_csi_txn_rec.inv_material_transaction_id := fs_rec.mtl_txn_id;

          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_inst_rec,
            p_party_tbl             => l_pty_tbl,
            p_account_tbl           => l_pa_tbl,
            p_org_assignments_tbl   => l_ou_tbl,
            p_ext_attrib_values_tbl => l_eav_tbl,
            p_pricing_attrib_tbl    => l_prc_tbl,
            p_asset_assignment_tbl  => l_asset_tbl,
            p_txn_rec               => l_csi_txn_rec,
            x_instance_id_lst       => l_inst_ids_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_vl_tbl := g_vl_tbl;

          IF l_vl_tbl.count > 0 THEN

            FOR l_ind IN l_vl_tbl.FIRST .. l_vl_tbl.LAST
            LOOP
              SELECT object_version_number
              INTO   l_vl_tbl(l_ind).object_version_number
              FROM   csi_i_version_labels
              WHERE  version_label_id = l_vl_tbl(l_ind).version_label_id;
            END LOOP;

            csi_item_instance_pub.update_version_label(
              p_api_version         => 1.0,
              p_commit              => fnd_api.g_false,
              p_init_msg_list       => fnd_api.g_true,
              p_validation_level    => fnd_api.g_valid_level_full,
              p_version_label_tbl   => l_vl_tbl,
              p_txn_rec             => l_csi_txn_rec,
              x_return_status       => l_return_status,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          g_iir_qry_rec.object_id              := g_inst_rec.instance_id;
          g_iir_qry_rec.relationship_type_code := 'COMPONENT-OF';

          csi_ii_relationships_pub.get_relationships(
            p_api_version                => 1.0,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_relationship_query_rec     => g_iir_qry_rec,
            p_depth                      => null,
            p_time_stamp                 => fs_rec.date_time_stamp,
            p_active_relationship_only   => fnd_api.g_false,
            x_relationship_tbl           => g_iir_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF g_iir_tbl.count > 0 THEN
            FOR l_ind IN g_iir_tbl.FIRST .. g_iir_tbl.LAST
            LOOP
              iir_ind := iir_ind + 1;
              l_iir_tbl(iir_ind) := g_iir_tbl(l_ind);

              SELECT object_version_number
              INTO   l_iir_tbl(iir_ind).object_version_number
              FROM   csi_ii_relationships
              WHERE  relationship_id = l_iir_tbl(iir_ind).relationship_id;
            END LOOP;
          END IF;

          g_iir_qry_rec                        := l_iir_qry_rec;
          g_iir_tbl.delete;

          g_iir_qry_rec.subject_id             := g_inst_rec.instance_id;
          g_iir_qry_rec.relationship_type_code := 'COMPONENT-OF';

          csi_ii_relationships_pub.get_relationships(
            p_api_version                => 1.0,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_relationship_query_rec     => g_iir_qry_rec,
            p_depth                      => NULL,
            p_time_stamp                 => fs_rec.date_time_stamp,
            p_active_relationship_only   => fnd_api.g_false,
            x_relationship_tbl           => g_iir_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF g_iir_tbl.count > 0 THEN
            FOR l_ind IN g_iir_tbl.FIRST .. g_iir_tbl.LAST
            LOOP
              iir_ind := iir_ind + 1;
              l_iir_tbl(iir_ind) := g_iir_tbl(l_ind);
              SELECT object_version_number
              INTO   l_iir_tbl(iir_ind).object_version_number
              FROM   csi_ii_relationships
              WHERE  relationship_id = l_iir_tbl(iir_ind).relationship_id;

            END LOOP;
          END IF;

          IF l_iir_tbl.COUNT > 0 THEN
            csi_ii_relationships_pub.update_relationship (
              p_api_version             => 1.0,
              p_commit                  => fnd_api.g_false,
              p_init_msg_list           => fnd_api.g_true,
              p_validation_level        => fnd_api.g_valid_level_full,
              p_relationship_tbl        => l_iir_tbl,
              p_txn_rec                 => l_csi_txn_rec,
              x_return_status           => l_return_status,
              x_msg_count               => l_msg_count,
              x_msg_data                => l_msg_data);

            IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          UPDATE csi_ii_forward_sync_temp
          SET    process_flag = 'P'
          WHERE  instance_id = fs_rec.instance_id;

        EXCEPTION
          WHEN fnd_api.g_exc_error THEN
            rollback to forward_sync;
            l_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
            log('Error in forward_sync : '||fs_rec.instance_id||' : '||l_msg_data);
        END;
      END IF;

    END LOOP;

  EXCEPTION
    when others then
      log('OTHERS exception from forward sync : '||sqlerrm);
  END forward_sync;
  --
  PROCEDURE insert_full_dump(p_instance_id    IN NUMBER) IS
    p_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_REC;
    p_temp_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_REC;
    p_party_header_tbl   CSI_DATASTRUCTURES_PUB.PARTY_HEADER_TBL;
    p_account_header_tbl CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_HEADER_TBL;
    p_org_header_tbl     CSI_DATASTRUCTURES_PUB.ORG_UNITS_HEADER_TBL;
    p_pricing_attrib_tbl CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
    p_ext_attrib_tbl     CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
    p_ext_attrib_def_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_TBL;
    p_asset_header_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_HEADER_TBL;
    p_ver_label_query_rec CSI_DATASTRUCTURES_PUB.VERSION_LABEL_QUERY_REC;
    p_rel_query_rec      CSI_DATASTRUCTURES_PUB.RELATIONSHIP_QUERY_REC;
    p_temp_rel_query_rec CSI_DATASTRUCTURES_PUB.RELATIONSHIP_QUERY_REC;
    x_version_label_tbl  csi_datastructures_pub.version_label_tbl;
    x_relationship_tbl   csi_datastructures_pub.ii_relationship_tbl;
    l_init_msg_list      VARCHAR2(2000);
    x_return_status      VARCHAR2(2000);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(2000);
    l_msg_index          NUMBER;
    l_msg_count          NUMBER;
     --
    l_instance_tbl          csi_datastructures_pub.instance_tbl;
    l_party_tbl             csi_datastructures_pub.party_tbl;
    l_party_account_tbl     csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;
    l_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    l_instance_asset_tbl    csi_datastructures_pub.instance_asset_tbl;
    l_version_label_tbl     csi_datastructures_pub.version_label_tbl;
    l_ii_relationship_tbl   csi_datastructures_pub.ii_relationship_tbl;
    --
    l_inst_rec_tab                csi_diagnostics_pkg.instance_rec_tab;
    l_version_label_rec_tab       csi_diagnostics_pkg.version_label_rec_tab;
    l_party_rec_tab               csi_diagnostics_pkg.party_rec_tab;
    l_account_rec_tab             csi_diagnostics_pkg.account_rec_tab;
    l_ext_attr_rec_tab            csi_diagnostics_pkg.extend_attrib_values_rec_tab;
    l_asset_rec_tab               csi_diagnostics_pkg.instance_asset_rec_tab;
    l_org_units_rec_tab           csi_diagnostics_pkg.org_units_rec_tab;
    l_pricing_rec_tab             csi_diagnostics_pkg.pricing_attribs_rec_tab;
    l_ii_relationship_rec_tab     csi_diagnostics_pkg.ii_relationship_rec_tab;
    --
    l_inst_hist_tbl               csi_diagnostics_pkg.T_NUM;
    l_party_hist_tbl              csi_diagnostics_pkg.T_NUM;
    l_account_hist_tbl            csi_diagnostics_pkg.T_NUM;
    l_org_hist_tbl                csi_diagnostics_pkg.T_NUM;
    l_ext_hist_tbl                csi_diagnostics_pkg.T_NUM;
    l_asset_hist_tbl              csi_diagnostics_pkg.T_NUM;
    l_pricing_hist_tbl            csi_diagnostics_pkg.T_NUM;
    l_rel_hist_tbl                csi_diagnostics_pkg.T_NUM;
    l_ver_label_hist_tbl          csi_diagnostics_pkg.T_NUM;
    --
    l_owner_src_table             VARCHAR2(30);
    l_owner_party                 NUMBER;
    l_owner_account               NUMBER;
    l_user_id                     NUMBER := fnd_global.user_id;
    l_txn_id                      NUMBER;
    v_txn_type_id                 NUMBER;
    l_char_ins_id                 VARCHAR2(50);
    --
    l_ctr                 NUMBER;
    l_exists              VARCHAR2(1);
    --
    Process_next          EXCEPTION;
    Comp_error            EXCEPTION;
    --
  BEGIN
    savepoint Insert_Full_Dump;
    IF p_instance_id IS NULL OR p_instance_id = FND_API.G_MISS_NUM THEN
      Raise comp_error;
    END IF;
    -- Get the Transaction Type ID for Txn Type MIGRATED
    v_txn_type_id := correction_txn_type_id;

    SELECT csi_transactions_s.nextval
    INTO   l_txn_id
    FROM   sys.dual;

    --
    BEGIN
      p_instance_rec := p_temp_instance_rec;
      p_party_header_tbl.DELETE;
      p_account_header_tbl.DELETE;
      p_org_header_tbl.DELETE;
      p_pricing_attrib_tbl.DELETE;
      p_ext_attrib_tbl.DELETE;
      p_ext_attrib_def_tbl.DELETE;
      p_asset_header_tbl.DELETE;
      x_version_label_tbl.DELETE;
      x_relationship_tbl.DELETE;
      --
      l_exists := 'N';
      p_instance_rec.instance_id := p_instance_id;
      l_char_ins_id := to_char(p_instance_id);

      -- Call Get API with the time stamp
      csi_item_instance_pub.get_item_instance_details (
        p_api_version           => 1.0,
        p_commit                => fnd_api.g_false,
        p_init_msg_list         => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_instance_rec          => p_instance_rec,
        p_get_parties           => fnd_api.g_true,
        p_party_header_tbl      => p_party_header_tbl,
        p_get_accounts          => fnd_api.g_true,
        p_account_header_tbl    => p_account_header_tbl,
        p_get_org_assignments   => fnd_api.g_true,
        p_org_header_tbl        => p_org_header_tbl,
        p_get_pricing_attribs   => fnd_api.g_true,
        p_pricing_attrib_tbl    => p_pricing_attrib_tbl,
        p_get_ext_attribs       => fnd_api.g_true,
        p_ext_attrib_tbl        => p_ext_attrib_tbl,
        p_ext_attrib_def_tbl    => p_ext_attrib_def_tbl,
        p_get_asset_assignments => fnd_api.g_true,
        p_asset_header_tbl      => p_asset_header_tbl,
        p_resolve_id_columns    => fnd_api.g_false,
        p_time_stamp            => sysdate,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);
      --
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_msg_index := 1;
        l_msg_count := x_msg_count;
        WHILE l_msg_count > 0 LOOP
          x_msg_data := FND_MSG_PUB.GET (  l_msg_index, FND_API.G_FALSE );
          l_msg_index := l_msg_index + 1;
          l_msg_count := l_msg_count - 1;
        END LOOP;
        log('Error in Get_Item_Instance Details for Instance : '||l_char_ins_id||'  '||x_msg_data);
        Raise Process_next;
      END IF;
      -- Build the Regular tables using the respective header tables
      -- Get the Customer and Merchant view flags

      SELECT customer_view_flag,
             merchant_view_flag,
             quantity
      INTO   p_instance_rec.customer_view_flag,
             p_instance_rec.merchant_view_flag,
             p_instance_rec.quantity
      FROM   csi_item_instances
      WHERE  instance_id = p_instance_rec.instance_id;
      --
      l_ctr := l_instance_tbl.count;
      l_ctr := l_ctr + 1;
      --
      l_instance_tbl(l_ctr).INSTANCE_ID  := p_instance_rec.INSTANCE_ID;
      l_instance_tbl(l_ctr).INSTANCE_NUMBER  := p_instance_rec.INSTANCE_NUMBER;
      l_instance_tbl(l_ctr).EXTERNAL_REFERENCE  := p_instance_rec.EXTERNAL_REFERENCE;
      l_instance_tbl(l_ctr).INVENTORY_ITEM_ID  := p_instance_rec.INVENTORY_ITEM_ID;
      l_instance_tbl(l_ctr).VLD_ORGANIZATION_ID  := p_instance_rec.VLD_ORGANIZATION_ID;
      l_instance_tbl(l_ctr).INVENTORY_REVISION  := p_instance_rec.INVENTORY_REVISION;
      l_instance_tbl(l_ctr).INV_MASTER_ORGANIZATION_ID  := p_instance_rec.INV_MASTER_ORGANIZATION_ID;
      l_instance_tbl(l_ctr).SERIAL_NUMBER  := p_instance_rec.SERIAL_NUMBER;
      l_instance_tbl(l_ctr).MFG_SERIAL_NUMBER_FLAG  := p_instance_rec.MFG_SERIAL_NUMBER_FLAG;
      l_instance_tbl(l_ctr).LOT_NUMBER  := p_instance_rec.LOT_NUMBER;
      l_instance_tbl(l_ctr).QUANTITY  := p_instance_rec.QUANTITY;
      l_instance_tbl(l_ctr).UNIT_OF_MEASURE  := p_instance_rec.UNIT_OF_MEASURE;
      l_instance_tbl(l_ctr).ACCOUNTING_CLASS_CODE  := p_instance_rec.ACCOUNTING_CLASS_CODE;
      l_instance_tbl(l_ctr).INSTANCE_CONDITION_ID  := p_instance_rec.INSTANCE_CONDITION_ID;
      l_instance_tbl(l_ctr).INSTANCE_STATUS_ID  := p_instance_rec.INSTANCE_STATUS_ID;
      l_instance_tbl(l_ctr).CUSTOMER_VIEW_FLAG  := p_instance_rec.CUSTOMER_VIEW_FLAG;
      l_instance_tbl(l_ctr).MERCHANT_VIEW_FLAG  := p_instance_rec.MERCHANT_VIEW_FLAG;
      l_instance_tbl(l_ctr).SELLABLE_FLAG  := p_instance_rec.SELLABLE_FLAG;
      l_instance_tbl(l_ctr).SYSTEM_ID  := p_instance_rec.SYSTEM_ID;
      l_instance_tbl(l_ctr).INSTANCE_TYPE_CODE  := p_instance_rec.INSTANCE_TYPE_CODE;
      l_instance_tbl(l_ctr).ACTIVE_START_DATE  := p_instance_rec.ACTIVE_START_DATE;
      l_instance_tbl(l_ctr).ACTIVE_END_DATE  := p_instance_rec.ACTIVE_END_DATE;
      l_instance_tbl(l_ctr).LOCATION_TYPE_CODE  := p_instance_rec.LOCATION_TYPE_CODE;
      l_instance_tbl(l_ctr).LOCATION_ID  := p_instance_rec.LOCATION_ID;
      l_instance_tbl(l_ctr).INV_ORGANIZATION_ID  := p_instance_rec.INV_ORGANIZATION_ID;
      l_instance_tbl(l_ctr).INV_SUBINVENTORY_NAME  := p_instance_rec.INV_SUBINVENTORY_NAME;
      l_instance_tbl(l_ctr).INV_LOCATOR_ID  := p_instance_rec.INV_LOCATOR_ID;
      l_instance_tbl(l_ctr).PA_PROJECT_ID  := p_instance_rec.PA_PROJECT_ID;
      l_instance_tbl(l_ctr).PA_PROJECT_TASK_ID  := p_instance_rec.PA_PROJECT_TASK_ID;
      l_instance_tbl(l_ctr).IN_TRANSIT_ORDER_LINE_ID  := p_instance_rec.IN_TRANSIT_ORDER_LINE_ID;
      l_instance_tbl(l_ctr).WIP_JOB_ID  := p_instance_rec.WIP_JOB_ID;
      l_instance_tbl(l_ctr).PO_ORDER_LINE_ID  := p_instance_rec.PO_ORDER_LINE_ID;
      l_instance_tbl(l_ctr).LAST_OE_ORDER_LINE_ID  := p_instance_rec.LAST_OE_ORDER_LINE_ID;
      l_instance_tbl(l_ctr).LAST_OE_RMA_LINE_ID  := p_instance_rec.LAST_OE_RMA_LINE_ID;
      l_instance_tbl(l_ctr).LAST_PO_PO_LINE_ID  := p_instance_rec.LAST_PO_PO_LINE_ID;
      l_instance_tbl(l_ctr).LAST_OE_PO_NUMBER  := p_instance_rec.LAST_OE_PO_NUMBER;
      l_instance_tbl(l_ctr).LAST_WIP_JOB_ID  := p_instance_rec.LAST_WIP_JOB_ID;
      l_instance_tbl(l_ctr).LAST_PA_PROJECT_ID  := p_instance_rec.LAST_PA_PROJECT_ID;
      l_instance_tbl(l_ctr).LAST_PA_TASK_ID  := p_instance_rec.LAST_PA_TASK_ID;
      l_instance_tbl(l_ctr).LAST_OE_AGREEMENT_ID  := p_instance_rec.LAST_OE_AGREEMENT_ID;
      l_instance_tbl(l_ctr).INSTALL_DATE  := p_instance_rec.INSTALL_DATE;
      l_instance_tbl(l_ctr).MANUALLY_CREATED_FLAG  := p_instance_rec.MANUALLY_CREATED_FLAG;
      l_instance_tbl(l_ctr).RETURN_BY_DATE  := p_instance_rec.RETURN_BY_DATE;
      l_instance_tbl(l_ctr).ACTUAL_RETURN_DATE  := p_instance_rec.ACTUAL_RETURN_DATE;
      l_instance_tbl(l_ctr).CREATION_COMPLETE_FLAG  := p_instance_rec.CREATION_COMPLETE_FLAG;
      l_instance_tbl(l_ctr).COMPLETENESS_FLAG  := p_instance_rec.COMPLETENESS_FLAG;
      l_instance_tbl(l_ctr).CONTEXT  := p_instance_rec.CONTEXT;
      l_instance_tbl(l_ctr).ATTRIBUTE1  := p_instance_rec.ATTRIBUTE1;
      l_instance_tbl(l_ctr).ATTRIBUTE2  := p_instance_rec.ATTRIBUTE2;
      l_instance_tbl(l_ctr).ATTRIBUTE3  := p_instance_rec.ATTRIBUTE3;
      l_instance_tbl(l_ctr).ATTRIBUTE4  := p_instance_rec.ATTRIBUTE4;
      l_instance_tbl(l_ctr).ATTRIBUTE5  := p_instance_rec.ATTRIBUTE5;
      l_instance_tbl(l_ctr).ATTRIBUTE6  := p_instance_rec.ATTRIBUTE6;
      l_instance_tbl(l_ctr).ATTRIBUTE7  := p_instance_rec.ATTRIBUTE7;
      l_instance_tbl(l_ctr).ATTRIBUTE8  := p_instance_rec.ATTRIBUTE8;
      l_instance_tbl(l_ctr).ATTRIBUTE9  := p_instance_rec.ATTRIBUTE9;
      l_instance_tbl(l_ctr).ATTRIBUTE10  := p_instance_rec.ATTRIBUTE10;
      l_instance_tbl(l_ctr).ATTRIBUTE11  := p_instance_rec.ATTRIBUTE11;
      l_instance_tbl(l_ctr).ATTRIBUTE12  := p_instance_rec.ATTRIBUTE12;
      l_instance_tbl(l_ctr).ATTRIBUTE13  := p_instance_rec.ATTRIBUTE13;
      l_instance_tbl(l_ctr).ATTRIBUTE14  := p_instance_rec.ATTRIBUTE14;
      l_instance_tbl(l_ctr).ATTRIBUTE15  := p_instance_rec.ATTRIBUTE15;
      l_instance_tbl(l_ctr).OBJECT_VERSION_NUMBER  := p_instance_rec.OBJECT_VERSION_NUMBER;
      l_instance_tbl(l_ctr).LAST_TXN_LINE_DETAIL_ID  := p_instance_rec.LAST_TXN_LINE_DETAIL_ID;
      l_instance_tbl(l_ctr).INSTALL_LOCATION_TYPE_CODE  := p_instance_rec.INSTALL_LOCATION_TYPE_CODE;
      l_instance_tbl(l_ctr).INSTALL_LOCATION_ID  := p_instance_rec.INSTALL_LOCATION_ID;
      l_instance_tbl(l_ctr).INSTANCE_USAGE_CODE  := p_instance_rec.INSTANCE_USAGE_CODE;
      l_instance_tbl(l_ctr).CONFIG_INST_HDR_ID  := p_instance_rec.CONFIG_INST_HDR_ID;
      l_instance_tbl(l_ctr).CONFIG_INST_REV_NUM  := p_instance_rec.CONFIG_INST_REV_NUM;
      l_instance_tbl(l_ctr).CONFIG_INST_ITEM_ID  := p_instance_rec.CONFIG_INST_ITEM_ID;
      l_instance_tbl(l_ctr).CONFIG_VALID_STATUS  := p_instance_rec.CONFIG_VALID_STATUS;
      l_instance_tbl(l_ctr).INSTANCE_DESCRIPTION  := p_instance_rec.INSTANCE_DESCRIPTION;
      -- Build Party Table
      IF p_party_header_tbl.count > 0 THEN
        l_ctr := l_party_tbl.count;
        FOR i in p_party_header_tbl.FIRST .. p_party_header_tbl.LAST LOOP
          l_ctr := l_ctr + 1;
          --
          l_party_tbl(l_ctr).instance_party_id   := p_party_header_tbl(i).instance_party_id;
          l_party_tbl(l_ctr).instance_id   := p_party_header_tbl(i).instance_id;
          l_party_tbl(l_ctr).party_source_table   := p_party_header_tbl(i).party_source_table;
          l_party_tbl(l_ctr).party_id   := p_party_header_tbl(i).party_id;
          l_party_tbl(l_ctr).relationship_type_code   := p_party_header_tbl(i).relationship_type_code;
          l_party_tbl(l_ctr).contact_flag   := p_party_header_tbl(i).contact_flag;
          l_party_tbl(l_ctr).contact_ip_id   := p_party_header_tbl(i).contact_ip_id;
          l_party_tbl(l_ctr).active_start_date   := p_party_header_tbl(i).active_start_date;
          l_party_tbl(l_ctr).active_end_date   := p_party_header_tbl(i).active_end_date;
          l_party_tbl(l_ctr).context   := p_party_header_tbl(i).context;
          l_party_tbl(l_ctr).attribute1   := p_party_header_tbl(i).attribute1;
          l_party_tbl(l_ctr).attribute2   := p_party_header_tbl(i).attribute2;
          l_party_tbl(l_ctr).attribute3   := p_party_header_tbl(i).attribute3;
          l_party_tbl(l_ctr).attribute4   := p_party_header_tbl(i).attribute4;
          l_party_tbl(l_ctr).attribute5   := p_party_header_tbl(i).attribute5;
          l_party_tbl(l_ctr).attribute6   := p_party_header_tbl(i).attribute6;
          l_party_tbl(l_ctr).attribute7   := p_party_header_tbl(i).attribute7;
          l_party_tbl(l_ctr).attribute8   := p_party_header_tbl(i).attribute8;
          l_party_tbl(l_ctr).attribute9   := p_party_header_tbl(i).attribute9;
          l_party_tbl(l_ctr).attribute10   := p_party_header_tbl(i).attribute10;
          l_party_tbl(l_ctr).attribute11   := p_party_header_tbl(i).attribute11;
          l_party_tbl(l_ctr).attribute12   := p_party_header_tbl(i).attribute12;
          l_party_tbl(l_ctr).attribute13   := p_party_header_tbl(i).attribute13;
          l_party_tbl(l_ctr).attribute14   := p_party_header_tbl(i).attribute14;
          l_party_tbl(l_ctr).attribute15   := p_party_header_tbl(i).attribute15;
          l_party_tbl(l_ctr).object_version_number   := p_party_header_tbl(i).object_version_number;
          l_party_tbl(l_ctr).primary_flag   := p_party_header_tbl(i).primary_flag;
          l_party_tbl(l_ctr).preferred_flag   := p_party_header_tbl(i).preferred_flag;
        END LOOP;
      END IF;
      --
      -- Build Account Table from Account Header Table
      IF p_account_header_tbl.count > 0 THEN
        l_ctr := l_party_account_tbl.count;
        FOR i in p_account_header_tbl.FIRST .. p_account_header_tbl.LAST LOOP
          l_ctr := l_ctr + 1;
          --
          l_party_account_tbl(l_ctr).ip_account_id := p_account_header_tbl(i).ip_account_id;
          l_party_account_tbl(l_ctr).instance_party_id := p_account_header_tbl(i).instance_party_id;
          l_party_account_tbl(l_ctr).party_account_id := p_account_header_tbl(i).party_account_id;
          l_party_account_tbl(l_ctr).relationship_type_code := p_account_header_tbl(i).relationship_type_code;
          l_party_account_tbl(l_ctr).bill_to_address := p_account_header_tbl(i).bill_to_address;
          l_party_account_tbl(l_ctr).ship_to_address := p_account_header_tbl(i).ship_to_address;
          l_party_account_tbl(l_ctr).active_start_date := p_account_header_tbl(i).active_start_date;
          l_party_account_tbl(l_ctr).active_end_date := p_account_header_tbl(i).active_end_date;
          l_party_account_tbl(l_ctr).context := p_account_header_tbl(i).context;
          l_party_account_tbl(l_ctr).attribute1 := p_account_header_tbl(i).attribute1;
          l_party_account_tbl(l_ctr).attribute2 := p_account_header_tbl(i).attribute2;
          l_party_account_tbl(l_ctr).attribute3 := p_account_header_tbl(i).attribute3;
          l_party_account_tbl(l_ctr).attribute4 := p_account_header_tbl(i).attribute4;
          l_party_account_tbl(l_ctr).attribute5 := p_account_header_tbl(i).attribute5;
          l_party_account_tbl(l_ctr).attribute6 := p_account_header_tbl(i).attribute6;
          l_party_account_tbl(l_ctr).attribute7 := p_account_header_tbl(i).attribute7;
          l_party_account_tbl(l_ctr).attribute8 := p_account_header_tbl(i).attribute8;
          l_party_account_tbl(l_ctr).attribute9 := p_account_header_tbl(i).attribute9;
          l_party_account_tbl(l_ctr).attribute10 := p_account_header_tbl(i).attribute10;
          l_party_account_tbl(l_ctr).attribute11 := p_account_header_tbl(i).attribute11;
          l_party_account_tbl(l_ctr).attribute12 := p_account_header_tbl(i).attribute12;
          l_party_account_tbl(l_ctr).attribute13 := p_account_header_tbl(i).attribute13;
          l_party_account_tbl(l_ctr).attribute14 := p_account_header_tbl(i).attribute14;
          l_party_account_tbl(l_ctr).attribute15 := p_account_header_tbl(i).attribute15;
          l_party_account_tbl(l_ctr).object_version_number := p_account_header_tbl(i).object_version_number;
        END LOOP;
      END IF;
      -- Build org Assignments table
      IF p_org_header_tbl.count > 0 THEN
        l_ctr := l_org_units_tbl.count;
        FOR i in p_org_header_tbl.FIRST .. p_org_header_tbl.LAST LOOP
          l_ctr := l_ctr + 1;
          --
          l_org_units_tbl(l_ctr).instance_ou_id := p_org_header_tbl(i).instance_ou_id;
          l_org_units_tbl(l_ctr).instance_id := p_org_header_tbl(i).instance_id;
          l_org_units_tbl(l_ctr).operating_unit_id := p_org_header_tbl(i).operating_unit_id;
          l_org_units_tbl(l_ctr).relationship_type_code := p_org_header_tbl(i).relationship_type_code;
          l_org_units_tbl(l_ctr).active_start_date := p_org_header_tbl(i).active_start_date;
          l_org_units_tbl(l_ctr).active_end_date := p_org_header_tbl(i).active_end_date;
          l_org_units_tbl(l_ctr).context := p_org_header_tbl(i).context;
          l_org_units_tbl(l_ctr).attribute1 := p_org_header_tbl(i).attribute1;
          l_org_units_tbl(l_ctr).attribute2 := p_org_header_tbl(i).attribute2;
          l_org_units_tbl(l_ctr).attribute3 := p_org_header_tbl(i).attribute3;
          l_org_units_tbl(l_ctr).attribute4 := p_org_header_tbl(i).attribute4;
          l_org_units_tbl(l_ctr).attribute5 := p_org_header_tbl(i).attribute5;
          l_org_units_tbl(l_ctr).attribute6 := p_org_header_tbl(i).attribute6;
          l_org_units_tbl(l_ctr).attribute7 := p_org_header_tbl(i).attribute7;
          l_org_units_tbl(l_ctr).attribute8 := p_org_header_tbl(i).attribute8;
          l_org_units_tbl(l_ctr).attribute9 := p_org_header_tbl(i).attribute9;
          l_org_units_tbl(l_ctr).attribute10 := p_org_header_tbl(i).attribute10;
          l_org_units_tbl(l_ctr).attribute11 := p_org_header_tbl(i).attribute11;
          l_org_units_tbl(l_ctr).attribute12 := p_org_header_tbl(i).attribute12;
          l_org_units_tbl(l_ctr).attribute13 := p_org_header_tbl(i).attribute13;
          l_org_units_tbl(l_ctr).attribute14 := p_org_header_tbl(i).attribute14;
          l_org_units_tbl(l_ctr).attribute15 := p_org_header_tbl(i).attribute15;
          l_org_units_tbl(l_ctr).object_version_number := p_org_header_tbl(i).object_version_number;
        END LOOP;
      END IF;
      -- Build Pricing Attrib Table
      IF p_pricing_attrib_tbl.count > 0 THEN
        l_ctr := l_pricing_attribs_tbl.count;
        FOR i in p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST LOOP
          l_ctr := l_ctr + 1;
          l_pricing_attribs_tbl(l_ctr) := p_pricing_attrib_tbl(i);
        END LOOP;
      END IF;

      -- Build Extended Attributes Table
      IF p_ext_attrib_tbl.count > 0 THEN
        l_ctr := l_ext_attrib_values_tbl.count;
        FOR i in p_ext_attrib_tbl.FIRST .. p_ext_attrib_tbl.LAST LOOP
          l_ctr := l_ctr + 1;
          l_ext_attrib_values_tbl(l_ctr) := p_ext_attrib_tbl(i);
        END LOOP;
      END IF;

      -- Build Instance Asset Table
      IF p_asset_header_tbl.count > 0 THEN
        l_ctr := l_instance_asset_tbl.count;
        FOR i in p_asset_header_tbl.FIRST .. p_asset_header_tbl.LAST LOOP
          l_ctr := l_ctr + 1;
          --
          l_instance_asset_tbl(l_ctr).instance_asset_id := p_asset_header_tbl(i).instance_asset_id;
          l_instance_asset_tbl(l_ctr).instance_id := p_asset_header_tbl(i).instance_id;
          l_instance_asset_tbl(l_ctr).fa_asset_id := p_asset_header_tbl(i).fa_asset_id;
          l_instance_asset_tbl(l_ctr).fa_book_type_code := p_asset_header_tbl(i).fa_book_type_code;
          l_instance_asset_tbl(l_ctr).fa_location_id := p_asset_header_tbl(i).fa_location_id;
          l_instance_asset_tbl(l_ctr).asset_quantity := p_asset_header_tbl(i).asset_quantity;
          l_instance_asset_tbl(l_ctr).update_status := p_asset_header_tbl(i).update_status;
          l_instance_asset_tbl(l_ctr).active_start_date := p_asset_header_tbl(i).active_start_date;
          l_instance_asset_tbl(l_ctr).active_end_date := p_asset_header_tbl(i).active_end_date;
          l_instance_asset_tbl(l_ctr).object_version_number := p_asset_header_tbl(i).object_version_number;
        END LOOP;
      END IF;

      --   Add version Label. Use Get_Version_Label API
      p_ver_label_query_rec.instance_id := p_instance_id;
      csi_item_instance_pub.get_version_labels (
        p_api_version             => 1.0,
        p_commit                  => fnd_api.g_false,
        p_init_msg_list           => l_init_msg_list,
        p_validation_level        => fnd_api.g_valid_level_full,
        p_version_label_query_rec => p_ver_label_query_rec,
        p_time_stamp              => fnd_api.g_miss_date,
        x_version_label_tbl       => x_version_label_tbl,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF x_version_label_tbl.count > 0 THEN
          l_ctr := l_version_label_tbl.count;
          FOR i in x_version_label_tbl.FIRST .. x_version_label_tbl.LAST LOOP
            l_ctr := l_ctr + 1;
            l_version_label_tbl(l_ctr) := x_version_label_tbl(i);
          END LOOP;
        END IF;
      END IF;

      --
      -- Add Get Relationships API
      p_rel_query_rec := p_temp_rel_query_rec;
      p_rel_query_rec.object_id := p_instance_id;
      p_rel_query_rec.relationship_type_code := 'COMPONENT-OF';
      csi_ii_relationships_pub.get_relationships(
        p_api_version                => 1.0,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => l_init_msg_list,
        p_validation_level           => fnd_api.g_valid_level_full,
        p_relationship_query_rec     => p_rel_query_rec,
        p_depth                      => NULL,
        p_time_stamp                 => fnd_api.g_miss_date,
        p_active_relationship_only   => fnd_api.g_true, -- BUG#5897084
        x_relationship_tbl           => x_relationship_tbl,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data);
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF x_relationship_tbl.count > 0 THEN
          FOR i in x_relationship_tbl.FIRST .. x_relationship_tbl.LAST LOOP
            l_exists := 'N';
            IF l_ii_relationship_tbl.count > 0 THEN
              FOR k in l_ii_relationship_tbl.FIRST .. l_ii_relationship_tbl.LAST LOOP
                IF l_ii_relationship_tbl(k).relationship_id = x_relationship_tbl(i).relationship_id THEN
                  l_exists := 'Y';
                  exit;
                END IF;
              END LOOP;
            END IF;
            IF l_exists <> 'Y' THEN
              l_ctr := l_ii_relationship_tbl.count;
              l_ctr := l_ctr + 1;
              l_ii_relationship_tbl(l_ctr) := x_relationship_tbl(i);
            END IF;
          END LOOP;
        END IF;
      END IF;
      --
      p_rel_query_rec := p_temp_rel_query_rec;
      p_rel_query_rec.subject_id := p_instance_id;
      p_rel_query_rec.relationship_type_code := 'COMPONENT-OF';
      csi_ii_relationships_pub.get_relationships(
        p_api_version                => 1.0,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => l_init_msg_list,
        p_validation_level           => fnd_api.g_valid_level_full,
        p_relationship_query_rec     => p_rel_query_rec,
        p_depth                      => NULL,
        p_time_stamp                 => fnd_api.g_miss_date,
        p_active_relationship_only   => fnd_api.g_true,  -- BUG#5897084
        x_relationship_tbl           => x_relationship_tbl,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data);
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF x_relationship_tbl.count > 0 THEN
          FOR i in x_relationship_tbl.FIRST .. x_relationship_tbl.LAST LOOP
            l_exists := 'N';
            IF l_ii_relationship_tbl.count > 0 THEN
              FOR k in l_ii_relationship_tbl.FIRST .. l_ii_relationship_tbl.LAST LOOP
                IF l_ii_relationship_tbl(k).relationship_id = x_relationship_tbl(i).relationship_id THEN
                  l_exists := 'Y';
                  exit;
                END IF;
              END LOOP;
            END IF;
            IF l_exists <> 'Y' THEN
              l_ctr := l_ii_relationship_tbl.count;
              l_ctr := l_ctr + 1;
              l_ii_relationship_tbl(l_ctr) := x_relationship_tbl(i);
            END IF;
          END LOOP;
        END IF;
      END IF;
      --
    EXCEPTION
       when Process_next then
         null;
    End;

    --
    IF l_instance_tbl.count > 0 THEN
      log('Before Build_Inst_Rec_of_Table');
      build_inst_rec_of_table (
        p_inst_tbl      => l_instance_tbl ,
        p_inst_rec_tab  => l_inst_rec_tab ,
        p_inst_hist_tbl => l_inst_hist_tbl);
      --
      l_ctr := l_inst_rec_tab.instance_id.count;
      -- Insert into History
      log('Before Inserting into Instances history..');
      FORALL i in 1 .. l_inst_rec_tab.instance_id.count
        INSERT INTO CSI_ITEM_INSTANCES_H(
          INSTANCE_HISTORY_ID,
          INSTANCE_ID,
          TRANSACTION_ID,
          NEW_INSTANCE_NUMBER,
          NEW_EXTERNAL_REFERENCE,
          NEW_INVENTORY_ITEM_ID,
          NEW_INVENTORY_REVISION,
          NEW_INV_MASTER_ORGANIZATION_ID,
          NEW_SERIAL_NUMBER ,
          NEW_MFG_SERIAL_NUMBER_FLAG,
          NEW_LOT_NUMBER,
          NEW_QUANTITY,
          NEW_UNIT_OF_MEASURE,
          NEW_ACCOUNTING_CLASS_CODE,
          NEW_INSTANCE_CONDITION_ID,
          NEW_INSTANCE_STATUS_ID,
          NEW_CUSTOMER_VIEW_FLAG,
          NEW_MERCHANT_VIEW_FLAG,
          NEW_SELLABLE_FLAG,
          NEW_SYSTEM_ID,
          NEW_INSTANCE_TYPE_CODE,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_LOCATION_TYPE_CODE,
          NEW_LOCATION_ID,
          NEW_INV_ORGANIZATION_ID,
          NEW_INV_SUBINVENTORY_NAME,
          NEW_INV_LOCATOR_ID,
          NEW_PA_PROJECT_ID,
          NEW_PA_PROJECT_TASK_ID,
          NEW_IN_TRANSIT_ORDER_LINE_ID,
          NEW_WIP_JOB_ID,
          NEW_PO_ORDER_LINE_ID,
          NEW_COMPLETENESS_FLAG,
          FULL_DUMP_FLAG,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER,
          NEW_INST_LOC_TYPE_CODE,
          NEW_INST_LOC_ID,
          NEW_INST_USAGE_CODE,
          NEW_last_vld_organization_id,
          NEW_CONFIG_INST_REV_NUM,
          NEW_CONFIG_VALID_STATUS,
          NEW_INSTANCE_DESCRIPTION)
        VALUES(
          l_inst_hist_tbl(i),
          l_inst_rec_tab.INSTANCE_ID(i),
          l_txn_id,
          l_inst_rec_tab.INSTANCE_NUMBER(i),
          l_inst_rec_tab.EXTERNAL_REFERENCE(i),
          l_inst_rec_tab.INVENTORY_ITEM_ID(i),
          l_inst_rec_tab.INVENTORY_REVISION(i),
          l_inst_rec_tab.INV_MASTER_ORGANIZATION_ID(i),
          l_inst_rec_tab.SERIAL_NUMBER (i),
          l_inst_rec_tab.MFG_SERIAL_NUMBER_FLAG(i),
          l_inst_rec_tab.LOT_NUMBER(i),
          l_inst_rec_tab.QUANTITY(i),
          l_inst_rec_tab.UNIT_OF_MEASURE(i),
          l_inst_rec_tab.ACCOUNTING_CLASS_CODE(i),
          l_inst_rec_tab.INSTANCE_CONDITION_ID(i),
          l_inst_rec_tab.INSTANCE_STATUS_ID(i),
          l_inst_rec_tab.CUSTOMER_VIEW_FLAG(i),
          l_inst_rec_tab.MERCHANT_VIEW_FLAG(i),
          l_inst_rec_tab.SELLABLE_FLAG(i),
          l_inst_rec_tab.SYSTEM_ID(i),
          l_inst_rec_tab.INSTANCE_TYPE_CODE(i),
          l_inst_rec_tab.ACTIVE_START_DATE(i),
          l_inst_rec_tab.ACTIVE_END_DATE(i),
          l_inst_rec_tab.LOCATION_TYPE_CODE(i),
          l_inst_rec_tab.LOCATION_ID(i),
          l_inst_rec_tab.INV_ORGANIZATION_ID(i),
          l_inst_rec_tab.INV_SUBINVENTORY_NAME(i),
          l_inst_rec_tab.INV_LOCATOR_ID(i),
          l_inst_rec_tab.PA_PROJECT_ID(i),
          l_inst_rec_tab.PA_PROJECT_TASK_ID(i),
          l_inst_rec_tab.IN_TRANSIT_ORDER_LINE_ID(i),
          l_inst_rec_tab.WIP_JOB_ID(i),
          l_inst_rec_tab.PO_ORDER_LINE_ID(i),
          l_inst_rec_tab.COMPLETENESS_FLAG(i),
          'Y',
          l_inst_rec_tab.CONTEXT(i),
          l_inst_rec_tab.ATTRIBUTE1(i),
          l_inst_rec_tab.ATTRIBUTE2(i),
          l_inst_rec_tab.ATTRIBUTE3(i),
          l_inst_rec_tab.ATTRIBUTE4(i),
          l_inst_rec_tab.ATTRIBUTE5(i),
          l_inst_rec_tab.ATTRIBUTE6(i),
          l_inst_rec_tab.ATTRIBUTE7(i),
          l_inst_rec_tab.ATTRIBUTE8(i),
          l_inst_rec_tab.ATTRIBUTE9(i),
          l_inst_rec_tab.ATTRIBUTE10(i),
          l_inst_rec_tab.ATTRIBUTE11(i),
          l_inst_rec_tab.ATTRIBUTE12(i),
          l_inst_rec_tab.ATTRIBUTE13(i),
          l_inst_rec_tab.ATTRIBUTE14(i),
          l_inst_rec_tab.ATTRIBUTE15(i),
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1,
          l_inst_rec_tab.INSTALL_LOCATION_TYPE_CODE(i), --fix for bug4881769
          l_inst_rec_tab.INSTALL_LOCATION_ID(i),
          l_inst_rec_tab.INSTANCE_USAGE_CODE(i),
          l_inst_rec_tab.vld_organization_id(i),
          l_inst_rec_tab.CONFIG_INST_REV_NUM(i),
          l_inst_rec_tab.CONFIG_VALID_STATUS(i),
          l_inst_rec_tab.INSTANCE_DESCRIPTION(i));
    END IF;
      --
    IF l_version_label_tbl.count > 0 THEN
      log('Before Build_Ver_Label_Rec_of_Table');
      Build_Ver_Label_Rec_of_Table (
        p_version_label_tbl     => l_version_label_tbl,
        p_version_label_rec_tab => l_version_label_rec_tab,
        p_ver_label_hist_tbl    => l_ver_label_hist_tbl);
      --
      l_ctr := l_version_label_rec_tab.version_label_id.count;
      -- Insert into History
      log('Before Inserting into Version Labels history ..');
      FORALL i in 1 .. l_version_label_rec_tab.version_label_id.count
        INSERT INTO CSI_I_VERSION_LABELS_H(
          VERSION_LABEL_HISTORY_ID,
          VERSION_LABEL_ID,
          TRANSACTION_ID,
          NEW_VERSION_LABEL,
          NEW_DESCRIPTION,
          NEW_DATE_TIME_STAMP,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
        VALUES(
          l_ver_label_hist_tbl(i),
          l_version_label_rec_tab.VERSION_LABEL_ID(i),
          l_txn_id,
          l_version_label_rec_tab.VERSION_LABEL(i),
          l_version_label_rec_tab.DESCRIPTION(i),
          l_version_label_rec_tab.DATE_TIME_STAMP(i),
          l_version_label_rec_tab.ACTIVE_START_DATE(i),
          l_version_label_rec_tab.ACTIVE_END_DATE(i),
          l_version_label_rec_tab.CONTEXT(i),
          l_version_label_rec_tab.ATTRIBUTE1(i),
          l_version_label_rec_tab.ATTRIBUTE2(i),
          l_version_label_rec_tab.ATTRIBUTE3(i),
          l_version_label_rec_tab.ATTRIBUTE4(i),
          l_version_label_rec_tab.ATTRIBUTE5(i),
          l_version_label_rec_tab.ATTRIBUTE6(i),
          l_version_label_rec_tab.ATTRIBUTE7(i),
          l_version_label_rec_tab.ATTRIBUTE8(i),
          l_version_label_rec_tab.ATTRIBUTE9(i),
          l_version_label_rec_tab.ATTRIBUTE10(i),
          l_version_label_rec_tab.ATTRIBUTE11(i),
          l_version_label_rec_tab.ATTRIBUTE12(i),
          l_version_label_rec_tab.ATTRIBUTE13(i),
          l_version_label_rec_tab.ATTRIBUTE14(i),
          l_version_label_rec_tab.ATTRIBUTE15(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
    IF l_party_tbl.count > 0 THEN
      log('Before Build_Party_Rec_of_Table');
      build_party_rec_of_table(
        p_party_tbl    => l_party_tbl,
        p_party_rec_tab => l_party_rec_tab,
        p_party_hist_tbl => l_party_hist_tbl);
      --
      l_ctr := l_party_rec_tab.instance_party_id.count;
      --
      -- Insert into History
      log('Before inserting into Parties history..');
      FORALL i in 1 .. l_party_rec_tab.instance_party_id.count
        INSERT INTO CSI_I_PARTIES_H(
          INSTANCE_PARTY_HISTORY_ID,
          INSTANCE_PARTY_ID,
          TRANSACTION_ID,
          NEW_PARTY_SOURCE_TABLE,
          NEW_PARTY_ID,
          NEW_RELATIONSHIP_TYPE_CODE,
          NEW_CONTACT_FLAG,
          NEW_CONTACT_IP_ID,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          NEW_PRIMARY_FLAG,
          NEW_PREFERRED_FLAG,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
        VALUES(
          l_party_hist_tbl(i),
          l_party_rec_tab.INSTANCE_PARTY_ID(i),
          l_txn_id,
          l_party_rec_tab.PARTY_SOURCE_TABLE(i),
          l_party_rec_tab.PARTY_ID(i),
          l_party_rec_tab.RELATIONSHIP_TYPE_CODE(i),
          l_party_rec_tab.CONTACT_FLAG(i),
          l_party_rec_tab.CONTACT_IP_ID(i),
          l_party_rec_tab.ACTIVE_START_DATE(i),
          l_party_rec_tab.ACTIVE_END_DATE(i),
          l_party_rec_tab.CONTEXT(i),
          l_party_rec_tab.ATTRIBUTE1(i),
          l_party_rec_tab.ATTRIBUTE2(i),
          l_party_rec_tab.ATTRIBUTE3(i),
          l_party_rec_tab.ATTRIBUTE4(i),
          l_party_rec_tab.ATTRIBUTE5(i),
          l_party_rec_tab.ATTRIBUTE6(i),
          l_party_rec_tab.ATTRIBUTE7(i),
          l_party_rec_tab.ATTRIBUTE8(i),
          l_party_rec_tab.ATTRIBUTE9(i),
          l_party_rec_tab.ATTRIBUTE10(i),
          l_party_rec_tab.ATTRIBUTE11(i),
          l_party_rec_tab.ATTRIBUTE12(i),
          l_party_rec_tab.ATTRIBUTE13(i),
          l_party_rec_tab.ATTRIBUTE14(i),
          l_party_rec_tab.ATTRIBUTE15(i),
          l_party_rec_tab.PRIMARY_FLAG(i),
          l_party_rec_tab.PREFERRED_FLAG(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
   IF l_party_account_tbl.count > 0 THEN
     log('Before Build_Acct_Rec_of_Table');
     Build_Acct_Rec_of_Table(
       p_account_tbl       => l_party_account_tbl,
       p_account_rec_tab   => l_account_rec_tab,
       p_account_hist_tbl  => l_account_hist_tbl);
     --
     l_ctr := l_account_rec_tab.ip_account_id.count;
     --
     -- Insert into History
     log('Before Inserting into Party Accounts history');
     FORALL i in 1 .. l_account_rec_tab.ip_account_id.count
       INSERT INTO CSI_IP_ACCOUNTS_H(
          IP_ACCOUNT_HISTORY_ID,
          IP_ACCOUNT_ID,
          TRANSACTION_ID,
          NEW_PARTY_ACCOUNT_ID,
          NEW_RELATIONSHIP_TYPE_CODE,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          NEW_BILL_TO_ADDRESS,
          NEW_SHIP_TO_ADDRESS,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
        VALUES(
          l_account_hist_tbl(i),
          l_account_rec_tab.IP_ACCOUNT_ID(i),
          l_txn_id,
          l_account_rec_tab.PARTY_ACCOUNT_ID(i),
          l_account_rec_tab.RELATIONSHIP_TYPE_CODE(i),
          l_account_rec_tab.ACTIVE_START_DATE(i),
          l_account_rec_tab.ACTIVE_END_DATE(i),
          l_account_rec_tab.CONTEXT(i),
          l_account_rec_tab.ATTRIBUTE1(i),
          l_account_rec_tab.ATTRIBUTE2(i),
          l_account_rec_tab.ATTRIBUTE3(i),
          l_account_rec_tab.ATTRIBUTE4(i),
          l_account_rec_tab.ATTRIBUTE5(i),
          l_account_rec_tab.ATTRIBUTE6(i),
          l_account_rec_tab.ATTRIBUTE7(i),
          l_account_rec_tab.ATTRIBUTE8(i),
          l_account_rec_tab.ATTRIBUTE9(i),
          l_account_rec_tab.ATTRIBUTE10(i),
          l_account_rec_tab.ATTRIBUTE11(i),
          l_account_rec_tab.ATTRIBUTE12(i),
          l_account_rec_tab.ATTRIBUTE13(i),
          l_account_rec_tab.ATTRIBUTE14(i),
          l_account_rec_tab.ATTRIBUTE15(i),
          l_account_rec_tab.BILL_TO_ADDRESS(i),
          l_account_rec_tab.SHIP_TO_ADDRESS(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
    IF l_org_units_tbl.count > 0 THEN
      log('Before Build_Org_Rec_of_Table');
      Build_Org_Rec_of_Table (
        p_org_tbl           => l_org_units_tbl,
        p_org_units_rec_tab => l_org_units_rec_tab,
        p_org_hist_tbl      => l_org_hist_tbl);
      --
      l_ctr := l_org_units_rec_tab.instance_ou_id.count;
      --
      -- Insert into History
      log('Before Inserting into Org Assignments history');
      FORALL i in 1 .. l_org_units_rec_tab.instance_ou_id.count
        INSERT INTO CSI_I_ORG_ASSIGNMENTS_H(
          INSTANCE_OU_HISTORY_ID,
          INSTANCE_OU_ID,
          TRANSACTION_ID,
          NEW_OPERATING_UNIT_ID,
          NEW_RELATIONSHIP_TYPE_CODE,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
       VALUES(
          l_org_hist_tbl(i),
          l_org_units_rec_tab.INSTANCE_OU_ID(i),
          l_txn_id,
          l_org_units_rec_tab.OPERATING_UNIT_ID(i),
          l_org_units_rec_tab.RELATIONSHIP_TYPE_CODE(i),
          l_org_units_rec_tab.ACTIVE_START_DATE(i),
          l_org_units_rec_tab.ACTIVE_END_DATE(i),
          l_org_units_rec_tab.CONTEXT(i),
          l_org_units_rec_tab.ATTRIBUTE1(i),
          l_org_units_rec_tab.ATTRIBUTE2(i),
          l_org_units_rec_tab.ATTRIBUTE3(i),
          l_org_units_rec_tab.ATTRIBUTE4(i),
          l_org_units_rec_tab.ATTRIBUTE5(i),
          l_org_units_rec_tab.ATTRIBUTE6(i),
          l_org_units_rec_tab.ATTRIBUTE7(i),
          l_org_units_rec_tab.ATTRIBUTE8(i),
          l_org_units_rec_tab.ATTRIBUTE9(i),
          l_org_units_rec_tab.ATTRIBUTE10(i),
          l_org_units_rec_tab.ATTRIBUTE11(i),
          l_org_units_rec_tab.ATTRIBUTE12(i),
          l_org_units_rec_tab.ATTRIBUTE13(i),
          l_org_units_rec_tab.ATTRIBUTE14(i),
          l_org_units_rec_tab.ATTRIBUTE15(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
    IF l_pricing_attribs_tbl.count > 0 THEN
      log('Before Build_pricing_Rec_of_Table');
      build_pricing_rec_of_table (
        p_pricing_tbl       => l_pricing_attribs_tbl,
        p_pricing_rec_tab   => l_pricing_rec_tab,
        p_pricing_hist_tbl  => l_pricing_hist_tbl);
      --
      l_ctr := l_pricing_rec_tab.pricing_attribute_id.count;
      --
      -- Insert into History
      log('Before Inserting into Pricing Attribs history');
      FORALL i in 1 .. l_pricing_rec_tab.pricing_attribute_id.count
        INSERT INTO CSI_I_PRICING_ATTRIBS_H(
          PRICE_ATTRIB_HISTORY_ID,
          PRICING_ATTRIBUTE_ID,
          TRANSACTION_ID,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          NEW_PRICING_CONTEXT,
          NEW_PRICING_ATTRIBUTE1,
          NEW_PRICING_ATTRIBUTE2,
          NEW_PRICING_ATTRIBUTE3,
          NEW_PRICING_ATTRIBUTE4,
          NEW_PRICING_ATTRIBUTE5,
          NEW_PRICING_ATTRIBUTE6,
          NEW_PRICING_ATTRIBUTE7,
          NEW_PRICING_ATTRIBUTE8,
          NEW_PRICING_ATTRIBUTE9,
          NEW_PRICING_ATTRIBUTE10,
          NEW_PRICING_ATTRIBUTE11,
          NEW_PRICING_ATTRIBUTE12,
          NEW_PRICING_ATTRIBUTE13,
          NEW_PRICING_ATTRIBUTE14,
          NEW_PRICING_ATTRIBUTE15,
          NEW_PRICING_ATTRIBUTE16,
          NEW_PRICING_ATTRIBUTE17,
          NEW_PRICING_ATTRIBUTE18,
          NEW_PRICING_ATTRIBUTE19,
          NEW_PRICING_ATTRIBUTE20,
          NEW_PRICING_ATTRIBUTE21,
          NEW_PRICING_ATTRIBUTE22,
          NEW_PRICING_ATTRIBUTE23,
          NEW_PRICING_ATTRIBUTE24,
          NEW_PRICING_ATTRIBUTE25,
          NEW_PRICING_ATTRIBUTE26,
          NEW_PRICING_ATTRIBUTE27,
          NEW_PRICING_ATTRIBUTE28,
          NEW_PRICING_ATTRIBUTE29,
          NEW_PRICING_ATTRIBUTE30,
          NEW_PRICING_ATTRIBUTE31,
          NEW_PRICING_ATTRIBUTE32,
          NEW_PRICING_ATTRIBUTE33,
          NEW_PRICING_ATTRIBUTE34,
          NEW_PRICING_ATTRIBUTE35,
          NEW_PRICING_ATTRIBUTE36,
          NEW_PRICING_ATTRIBUTE37,
          NEW_PRICING_ATTRIBUTE38,
          NEW_PRICING_ATTRIBUTE39,
          NEW_PRICING_ATTRIBUTE40,
          NEW_PRICING_ATTRIBUTE41,
          NEW_PRICING_ATTRIBUTE42,
          NEW_PRICING_ATTRIBUTE43,
          NEW_PRICING_ATTRIBUTE44,
          NEW_PRICING_ATTRIBUTE45,
          NEW_PRICING_ATTRIBUTE46,
          NEW_PRICING_ATTRIBUTE47,
          NEW_PRICING_ATTRIBUTE48,
          NEW_PRICING_ATTRIBUTE49,
          NEW_PRICING_ATTRIBUTE50,
          NEW_PRICING_ATTRIBUTE51,
          NEW_PRICING_ATTRIBUTE52,
          NEW_PRICING_ATTRIBUTE53,
          NEW_PRICING_ATTRIBUTE54,
          NEW_PRICING_ATTRIBUTE55,
          NEW_PRICING_ATTRIBUTE56,
          NEW_PRICING_ATTRIBUTE57,
          NEW_PRICING_ATTRIBUTE58,
          NEW_PRICING_ATTRIBUTE59,
          NEW_PRICING_ATTRIBUTE60,
          NEW_PRICING_ATTRIBUTE61,
          NEW_PRICING_ATTRIBUTE62,
          NEW_PRICING_ATTRIBUTE63,
          NEW_PRICING_ATTRIBUTE64,
          NEW_PRICING_ATTRIBUTE65,
          NEW_PRICING_ATTRIBUTE66,
          NEW_PRICING_ATTRIBUTE67,
          NEW_PRICING_ATTRIBUTE68,
          NEW_PRICING_ATTRIBUTE69,
          NEW_PRICING_ATTRIBUTE70,
          NEW_PRICING_ATTRIBUTE71,
          NEW_PRICING_ATTRIBUTE72,
          NEW_PRICING_ATTRIBUTE73,
          NEW_PRICING_ATTRIBUTE74,
          NEW_PRICING_ATTRIBUTE75,
          NEW_PRICING_ATTRIBUTE76,
          NEW_PRICING_ATTRIBUTE77,
          NEW_PRICING_ATTRIBUTE78,
          NEW_PRICING_ATTRIBUTE79,
          NEW_PRICING_ATTRIBUTE80,
          NEW_PRICING_ATTRIBUTE81,
          NEW_PRICING_ATTRIBUTE82,
          NEW_PRICING_ATTRIBUTE83,
          NEW_PRICING_ATTRIBUTE84,
          NEW_PRICING_ATTRIBUTE85,
          NEW_PRICING_ATTRIBUTE86,
          NEW_PRICING_ATTRIBUTE87,
          NEW_PRICING_ATTRIBUTE88,
          NEW_PRICING_ATTRIBUTE89,
          NEW_PRICING_ATTRIBUTE90,
          NEW_PRICING_ATTRIBUTE91,
          NEW_PRICING_ATTRIBUTE92,
          NEW_PRICING_ATTRIBUTE93,
          NEW_PRICING_ATTRIBUTE94,
          NEW_PRICING_ATTRIBUTE95,
          NEW_PRICING_ATTRIBUTE96,
          NEW_PRICING_ATTRIBUTE97,
          NEW_PRICING_ATTRIBUTE98,
          NEW_PRICING_ATTRIBUTE99,
          NEW_PRICING_ATTRIBUTE100,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
       VALUES(
          l_pricing_hist_tbl(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE_ID(i),
          l_txn_id,
          l_pricing_rec_tab.ACTIVE_START_DATE(i),
          l_pricing_rec_tab.ACTIVE_END_DATE(i),
          l_pricing_rec_tab.CONTEXT(i),
          l_pricing_rec_tab.ATTRIBUTE1(i),
          l_pricing_rec_tab.ATTRIBUTE2(i),
          l_pricing_rec_tab.ATTRIBUTE3(i),
          l_pricing_rec_tab.ATTRIBUTE4(i),
          l_pricing_rec_tab.ATTRIBUTE5(i),
          l_pricing_rec_tab.ATTRIBUTE6(i),
          l_pricing_rec_tab.ATTRIBUTE7(i),
          l_pricing_rec_tab.ATTRIBUTE8(i),
          l_pricing_rec_tab.ATTRIBUTE9(i),
          l_pricing_rec_tab.ATTRIBUTE10(i),
          l_pricing_rec_tab.ATTRIBUTE11(i),
          l_pricing_rec_tab.ATTRIBUTE12(i),
          l_pricing_rec_tab.ATTRIBUTE13(i),
          l_pricing_rec_tab.ATTRIBUTE14(i),
          l_pricing_rec_tab.ATTRIBUTE15(i),
          l_pricing_rec_tab.PRICING_CONTEXT(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE1(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE2(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE3(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE4(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE5(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE6(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE7(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE8(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE9(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE10(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE11(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE12(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE13(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE14(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE15(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE16(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE17(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE18(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE19(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE20(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE21(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE22(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE23(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE24(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE25(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE26(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE27(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE28(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE29(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE30(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE31(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE32(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE33(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE34(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE35(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE36(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE37(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE38(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE39(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE40(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE41(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE42(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE43(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE44(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE45(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE46(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE47(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE48(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE49(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE50(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE51(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE52(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE53(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE54(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE55(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE56(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE57(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE58(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE59(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE60(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE61(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE62(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE63(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE64(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE65(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE66(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE67(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE68(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE69(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE70(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE71(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE72(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE73(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE74(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE75(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE76(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE77(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE78(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE79(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE80(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE81(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE82(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE83(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE84(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE85(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE86(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE87(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE88(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE89(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE90(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE91(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE92(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE93(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE94(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE95(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE96(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE97(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE98(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE99(i),
          l_pricing_rec_tab.PRICING_ATTRIBUTE100(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
    IF l_ext_attrib_values_tbl.count > 0 THEN
      log('Before Build_Ext_Attr_Rec_Table');
      Build_Ext_Attr_Rec_Table (
       p_ext_attr_tbl     => l_ext_attrib_values_tbl,
       p_ext_attr_rec_tab => l_ext_attr_rec_tab,
       p_ext_hist_tbl     => l_ext_hist_tbl);
      --
      l_ctr := l_ext_attr_rec_tab.attribute_value_id.count;
      --
      -- Insert into History
      log('Before Inserting into Ext Attribs history');
      FORALL i in 1 .. l_ext_attr_rec_tab.attribute_value_id.count
        INSERT INTO CSI_IEA_VALUES_H(
          ATTRIBUTE_VALUE_HISTORY_ID,
          ATTRIBUTE_VALUE_ID,
          TRANSACTION_ID,
          NEW_ATTRIBUTE_VALUE,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          NEW_CONTEXT,
          NEW_ATTRIBUTE1,
          NEW_ATTRIBUTE2,
          NEW_ATTRIBUTE3,
          NEW_ATTRIBUTE4,
          NEW_ATTRIBUTE5,
          NEW_ATTRIBUTE6,
          NEW_ATTRIBUTE7,
          NEW_ATTRIBUTE8,
          NEW_ATTRIBUTE9,
          NEW_ATTRIBUTE10,
          NEW_ATTRIBUTE11,
          NEW_ATTRIBUTE12,
          NEW_ATTRIBUTE13,
          NEW_ATTRIBUTE14,
          NEW_ATTRIBUTE15,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
       VALUES(
          l_ext_hist_tbl(i),
          l_ext_attr_rec_tab.ATTRIBUTE_VALUE_ID(i),
          l_txn_id,
          l_ext_attr_rec_tab.ATTRIBUTE_VALUE(i),
          l_ext_attr_rec_tab.ACTIVE_START_DATE(i),
          l_ext_attr_rec_tab.ACTIVE_END_DATE(i),
          l_ext_attr_rec_tab.CONTEXT(i),
          l_ext_attr_rec_tab.ATTRIBUTE1(i),
          l_ext_attr_rec_tab.ATTRIBUTE2(i),
          l_ext_attr_rec_tab.ATTRIBUTE3(i),
          l_ext_attr_rec_tab.ATTRIBUTE4(i),
          l_ext_attr_rec_tab.ATTRIBUTE5(i),
          l_ext_attr_rec_tab.ATTRIBUTE6(i),
          l_ext_attr_rec_tab.ATTRIBUTE7(i),
          l_ext_attr_rec_tab.ATTRIBUTE8(i),
          l_ext_attr_rec_tab.ATTRIBUTE9(i),
          l_ext_attr_rec_tab.ATTRIBUTE10(i),
          l_ext_attr_rec_tab.ATTRIBUTE11(i),
          l_ext_attr_rec_tab.ATTRIBUTE12(i),
          l_ext_attr_rec_tab.ATTRIBUTE13(i),
          l_ext_attr_rec_tab.ATTRIBUTE14(i),
          l_ext_attr_rec_tab.ATTRIBUTE15(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
    IF l_instance_asset_tbl.count > 0 THEN
      log('Before Build_Asset_Rec_Table');
      Build_Asset_Rec_Table (
        p_asset_tbl     => l_instance_asset_tbl,
        p_asset_rec_tab => l_asset_rec_tab,
        p_asset_hist_tbl => l_asset_hist_tbl);
      --
      l_ctr := l_asset_rec_tab.instance_asset_id.count;
      --
      -- Insert into History
      log('Before Inserting into Assets history');
      FORALL i in 1 .. l_asset_rec_tab.instance_asset_id.count
        INSERT INTO CSI_I_ASSETS_H(
          INSTANCE_ASSET_HISTORY_ID,
          INSTANCE_ASSET_ID,
          TRANSACTION_ID,
          NEW_INSTANCE_ID,
          NEW_FA_ASSET_ID,
          NEW_ASSET_QUANTITY,
          NEW_FA_BOOK_TYPE_CODE,
          NEW_FA_LOCATION_ID,
          NEW_UPDATE_STATUS,
          NEW_ACTIVE_START_DATE,
          NEW_ACTIVE_END_DATE,
          FULL_DUMP_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
       VALUES(
          l_asset_hist_tbl(i),
          l_asset_rec_tab.INSTANCE_ASSET_ID(i),
          l_txn_id,
          l_asset_rec_tab.INSTANCE_ID(i),
          l_asset_rec_tab.FA_ASSET_ID(i),
          l_asset_rec_tab.ASSET_QUANTITY(i),
          l_asset_rec_tab.FA_BOOK_TYPE_CODE(i),
          l_asset_rec_tab.FA_LOCATION_ID(i),
          l_asset_rec_tab.UPDATE_STATUS(i),
          l_asset_rec_tab.ACTIVE_START_DATE(i),
          l_asset_rec_tab.ACTIVE_END_DATE(i),
          'Y',
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          -1,
          1);
    END IF;
    --
    IF l_ii_relationship_tbl.count > 0 THEN
      log('Before Build_Rel_Rec_of_Table');
      Build_Rel_Rec_of_Table (
        p_ii_relationship_tbl     => l_ii_relationship_tbl,
        p_ii_relationship_rec_tab => l_ii_relationship_rec_tab,
        p_rel_hist_tbl            => l_rel_hist_tbl);
      --
      l_ctr := l_ii_relationship_rec_tab.relationship_id.count;
      --
      -- Insert into History
      log('Before inserting into Relationships history');
      FORALL i in 1 .. l_ii_relationship_rec_tab.relationship_id.count
        INSERT INTO CSI_II_RELATIONSHIPS_H(
          RELATIONSHIP_HISTORY_ID
         ,RELATIONSHIP_ID
         ,TRANSACTION_ID
         ,NEW_SUBJECT_ID
         ,NEW_POSITION_REFERENCE
         ,NEW_ACTIVE_START_DATE
         ,NEW_ACTIVE_END_DATE
         ,NEW_MANDATORY_FLAG
         ,NEW_CONTEXT
         ,NEW_ATTRIBUTE1
         ,NEW_ATTRIBUTE2
         ,NEW_ATTRIBUTE3
         ,NEW_ATTRIBUTE4
         ,NEW_ATTRIBUTE5
         ,NEW_ATTRIBUTE6
         ,NEW_ATTRIBUTE7
         ,NEW_ATTRIBUTE8
         ,NEW_ATTRIBUTE9
         ,NEW_ATTRIBUTE10
         ,NEW_ATTRIBUTE11
         ,NEW_ATTRIBUTE12
         ,NEW_ATTRIBUTE13
         ,NEW_ATTRIBUTE14
         ,NEW_ATTRIBUTE15
         ,FULL_DUMP_FLAG
         ,CREATED_BY
         ,CREATION_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,OBJECT_VERSION_NUMBER)
       VALUES(
          l_rel_hist_tbl(i)
         ,l_ii_relationship_rec_tab.RELATIONSHIP_ID(i)
         ,l_txn_id
         ,l_ii_relationship_rec_tab.SUBJECT_ID(i)
         ,l_ii_relationship_rec_tab.POSITION_REFERENCE(i)
         ,l_ii_relationship_rec_tab.ACTIVE_START_DATE(i)
         ,l_ii_relationship_rec_tab.ACTIVE_END_DATE(i)
         ,l_ii_relationship_rec_tab.MANDATORY_FLAG(i)
         ,l_ii_relationship_rec_tab.CONTEXT(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE1(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE2(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE3(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE4(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE5(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE6(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE7(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE8(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE9(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE10(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE11(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE12(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE13(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE14(i)
         ,l_ii_relationship_rec_tab.ATTRIBUTE15(i)
         ,'Y'
         ,l_user_id
         ,sysdate
         ,l_user_id
         ,sysdate
         ,-1
         ,1);
    END IF;
    --
    IF l_instance_tbl.count > 0 THEN
      INSERT INTO CSI_TRANSACTIONS(
        TRANSACTION_ID
       ,TRANSACTION_DATE
       ,SOURCE_TRANSACTION_DATE
       ,SOURCE_HEADER_REF
       ,TRANSACTION_TYPE_ID
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
       ,OBJECT_VERSION_NUMBER)
      VALUES(
        l_txn_id             -- TRANSACTION_ID
       ,SYSDATE              -- TRANSACTION_DATE
       ,SYSDATE              -- SOURCE_TRANSACTION_DATE
       ,'Full Dump'          -- SOURCE_HEADER_REF
       ,v_txn_type_id        -- TRANSACTION_TYPE_ID
       ,l_user_id
       ,sysdate
       ,l_user_id
       ,sysdate
       ,-1
       ,1);
       --
    END IF;
    commit;
    log('Insert_Full_Dump Successfully completed...');
  EXCEPTION
    when comp_error then
      log('Comp error in Insert_Full_Dump..');
      ROLLBACK TO Insert_Full_Dump;
    when others then
      log(sqlerrm);
      ROLLBACK TO Insert_Full_Dump;
  END Insert_Full_Dump;

  FUNCTION is_sfm_active RETURN boolean
  IS

    l_applid      number;
    l_managerid   number;

    l_targetp     number;
    l_activep     number;
    l_pmon_method varchar2(30);
    l_callstat    number;

  BEGIN

    SELECT application_id, concurrent_queue_id
    INTO   l_applid, l_managerid
    FROM   fnd_concurrent_queues
    WHERE concurrent_queue_name = 'XDP_Q_EVENT_SVC';

    fnd_concurrent.get_manager_status(
      applid      => l_applid,
      managerid   => l_managerid,
      targetp     => l_targetp,
      activep     => l_activep,
      pmon_method => l_pmon_method,
      callstat    => l_callstat);

    IF (l_targetp > 0) or (l_activep > 0) THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;

  END is_sfm_active;

  PROCEDURE get_schema_name(
    p_product_short_name  IN  varchar2,
    x_schema_name         OUT nocopy varchar2,
    x_return_status       OUT nocopy varchar2)
  IS
    l_status        varchar2(1);
    l_industry      varchar2(1);
    l_oracle_schema varchar2(30);
    l_return        boolean;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_return := fnd_installation.get_app_info(
                  application_short_name => p_product_short_name,
                  status                 => l_status,
                  industry               => l_industry,
                  oracle_schema          => l_oracle_schema);

    IF NOT l_return THEN
      fnd_message.set_name('CSI', 'CSI_FND_INVALID_SCHEMA_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_schema_name := l_oracle_schema;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_schema_name;

  PROCEDURE truncate_table(
    p_table_name    in varchar2)
  IS
    l_num_of_rows      number;
    l_truncate_handle  pls_integer := dbms_sql.open_cursor;
    l_statement        varchar2(200);
  BEGIN
    l_statement := 'truncate table '||p_table_name;
    dbms_sql.parse(l_truncate_handle, l_statement, dbms_sql.native);
    l_num_of_rows := dbms_sql.execute(l_truncate_handle);
    dbms_sql.close_cursor(l_truncate_handle);
  EXCEPTION
    WHEN others THEN
      null;
  END truncate_table;

  PROCEDURE get_source_type(
    p_mtl_txn_id         IN number,
    p_mtl_type_id        IN number,
    p_mtl_action_id      IN number,
    p_mtl_source_type_id IN number,
    p_mtl_type_class     IN number,
    p_mtl_txn_qty        IN number,
    p_release            IN varchar2,
    x_source_type        OUT nocopy varchar2,
    x_csi_txn_type_id    OUT nocopy number)
  IS
  BEGIN

    -- Move order issue to project
    IF p_mtl_action_id = 1 AND p_mtl_source_type_id = 4 AND p_mtl_type_class = 1 THEN
      x_source_type := 'CSIISUPT';
      x_csi_txn_type_id := 113;
      return;
    END IF;

    -- Miscellaneous issue to project
    IF p_mtl_action_id = 1 AND p_mtl_source_type_id in (3,6,13) AND p_mtl_type_class = 1 THEN
      x_source_type := 'CSIMSIPT';
      x_csi_txn_type_id := 121;
      return;
    END IF;

    -- Miscellaneous Receipt from project
    IF p_mtl_action_id = 27 AND p_mtl_source_type_id in (3,6,13) AND p_mtl_type_class = 1 THEN
      x_source_type := 'CSIMSRPT';
      x_csi_txn_type_id := 120;
      return;
    END IF;

    -- project contract issue
    IF p_mtl_action_id = 1 AND p_mtl_source_type_id = 16 THEN
      x_source_type     := 'CSIOKSHP';
      x_csi_txn_type_id := 326;
      return;
    END IF;

    -- Sales Order Shipment
    IF p_mtl_action_id = 1 AND p_mtl_source_type_id = 2 THEN
      x_source_type     := 'CSISOSHP';
      x_csi_txn_type_id := 51;
      return;
    END IF;

    -- RMA receipt
    IF p_mtl_action_id = 27 AND p_mtl_source_type_id = 12 THEN
      x_source_type     := 'CSIRMARC';
      x_csi_txn_type_id := 53;
      return;
    END IF;

    -- Subinventory Transfers
    IF(p_mtl_txn_qty > 0 AND   p_mtl_action_id = 2)
        OR
       (p_mtl_action_id = 28 AND p_mtl_source_type_id = 2 AND p_mtl_txn_qty > 0)
        OR
       (p_mtl_action_id = 28 AND p_mtl_source_type_id = 8 AND p_mtl_txn_qty > 0)
    THEN
      x_source_type := 'CSISUBTR';
      x_csi_txn_type_id := 114;
      return;
    END IF;

    --Interorg transit receipt
    IF p_mtl_action_id = 12 AND p_mtl_source_type_id = 13 THEN
      x_source_type := 'CSIORGTR';
      x_csi_txn_type_id := 144;
      return;
    END IF;

    --Interorg transit shipment
    IF p_mtl_action_id = 21 AND p_mtl_source_type_id = 13 THEN
      x_source_type := 'CSIORGTS';
      x_csi_txn_type_id := 145;
      return;
    END IF;

    --Interorg Direct Shipment
    IF p_mtl_action_id = 3 AND  p_mtl_source_type_id = 13 AND p_mtl_txn_qty > 0 THEN
      x_source_type := 'CSIORGDS';
      x_csi_txn_type_id := 143;
      return;
    END IF;

    -- ISO requisition receipt
    IF p_mtl_action_id = 12 AND p_mtl_source_type_id = 7 THEN
      x_source_type := 'CSIINTSR';
      x_csi_txn_type_id := 131;
      return;
    END IF;

    -- ISO shipment
    IF p_mtl_action_id = 21 AND p_mtl_source_type_id = 8 THEN
      x_source_type := 'CSIINTSS';
      x_csi_txn_type_id := 130;
      return;
    END IF;

    -- ISO direct shipment
    IF p_mtl_action_id = 3 AND p_mtl_source_type_id = 7 AND p_mtl_txn_qty > 0 THEN
      x_source_type := 'CSIINTDS';
      x_csi_txn_type_id := 142;
      return;
    END IF;

    -- PO receipt
    IF p_mtl_action_id = 27 AND p_mtl_source_type_id = 1 THEN
      x_source_type := 'CSIPOINV';
      x_csi_txn_type_id := 112;
      return;
    END IF;

    -- cycle count
    IF p_mtl_action_id = 4 THEN
      x_source_type := 'CSICYCNT';
      x_csi_txn_type_id := 119;
      return;
    END IF;

    --physical inventory
    IF p_mtl_action_id = 8 THEN
      x_source_type := 'CSIPHYIN';
      x_csi_txn_type_id := 118;
      return;
    END IF;

    -- miscellaneous receipt
    --
    IF(p_mtl_action_id = 27 AND p_mtl_type_id NOT IN (15,123,43,94) AND
         (p_mtl_type_class is null OR p_mtl_type_class <> 1))
        OR
       (p_mtl_action_id = 29 AND p_mtl_txn_qty > 0 AND p_mtl_source_type_id = 1)
        OR
       (p_mtl_action_id = 29 AND p_mtl_txn_qty > 0 AND p_mtl_source_type_id = 13)
        OR
       (p_mtl_action_id = 29 AND p_mtl_txn_qty > 0 AND p_mtl_source_type_id = 7)
    THEN
      x_source_type := 'CSIMSRCV';
      x_csi_txn_type_id := 117;
      return;
    END IF;

    -- miscellaneous issue
    IF (p_mtl_action_id = 1 AND p_mtl_source_type_id in (4,13,6,3,8)
       AND
       p_mtl_type_id NOT IN (33,122,35,37,93)
       AND
       (p_mtl_type_class is null OR p_mtl_type_class <> 1))
      OR
      (p_mtl_action_id = 29 AND p_mtl_txn_qty < 0 AND p_mtl_source_type_id = 1)
      OR
      (p_mtl_action_id = 1 AND p_mtl_txn_qty < 0 AND p_mtl_source_type_id = 1)
        OR
       (p_mtl_action_id = 29 AND p_mtl_txn_qty < 0 AND p_mtl_source_type_id = 13)
        OR
       (p_mtl_action_id = 29 AND p_mtl_txn_qty < 0 AND p_mtl_source_type_id = 7)
    THEN
      x_source_type := 'CSIMSISU';
      x_csi_txn_type_id := 116;
      return;
    END IF;

    --wip assy return
    IF p_mtl_action_id = 32 AND p_mtl_source_type_id = 5 THEN
      x_source_type := 'CSIWIPAR';
      x_csi_txn_type_id := 71;
      return;
    END IF;

    -- wip component issue
    IF p_mtl_action_id = 1 AND p_mtl_source_type_id = 5 THEN
      x_source_type := 'CSIWIPCI';
      x_csi_txn_type_id := 71;
      return;
    END IF;

    -- wip negative comp issue
    IF p_mtl_action_id = 33 AND p_mtl_source_type_id = 5 THEN
      x_source_type := 'CSIWIPNI';
      x_csi_txn_type_id := 72;
      return;
    END IF;

    -- wip component return
    IF p_mtl_action_id = 27 AND p_mtl_source_type_id = 5 THEN
      x_source_type := 'CSIWIPCR';
      x_csi_txn_type_id := 72;
      return;
    END IF;

    -- wip assembly completion
    IF p_mtl_action_id = 31 AND p_mtl_source_type_id = 5 THEN
      x_source_type := 'CSIWIPAC';
      x_csi_txn_type_id := 73;
      return;
    END IF;

    -- wip negative comp return
    IF p_mtl_action_id = 34 AND p_mtl_source_type_id = 5 THEN
      x_source_type := 'CSIWIPNR';
      x_csi_txn_type_id := 71;
      return;
    END IF;

    x_source_type     := 'NONE';
    x_csi_txn_type_id := -1;

  END get_source_type;

  PROCEDURE pump_txn_error(
    p_mtl_txn_id         IN number,
    p_mtl_type_id        IN number,
    p_mtl_action_id      IN number,
    p_mtl_source_type_id IN number,
    p_mtl_type_class     IN number,
    p_mtl_txn_qty        IN number,
    p_dequeue_flag       IN varchar2 default 'N',
    p_release            IN varchar2)
  IS

    l_error_rec          csi_datastructures_pub.transaction_error_rec;
    l_error_id           number;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count          number;
    l_msg_data           varchar2(2000);
    l_source_type        varchar2(20);
    l_csi_txn_type_id    number;
    l_message_string     varchar2(2000);

    l_error_message      varchar2(2000);
  BEGIN

     savepoint pump_txn_error;

     IF p_dequeue_flag = 'Y' THEN
       l_error_rec.processed_flag            := 'R';
     ELSE
       l_error_rec.processed_flag            := 'E';
     END IF;

     l_error_rec.error_text                  := 'Missing transaction in Install Base.';
     l_error_rec.error_stage                 := 'IB_UPDATE';
     l_error_rec.inv_material_transaction_id := p_mtl_txn_id;
     l_error_rec.source_id                   := p_mtl_txn_id;
     cse_util_pkg.build_error_string(l_message_string,'MTL_TRANSACTION_ID',p_mtl_txn_id);
     l_error_rec.message_string              := l_message_string;

     get_source_type(
       p_mtl_txn_id         => p_mtl_txn_id,
       p_mtl_type_id        => p_mtl_type_id,
       p_mtl_action_id      => p_mtl_action_id,
       p_mtl_source_type_id => p_mtl_source_type_id,
       p_mtl_type_class     => p_mtl_type_class,
       p_mtl_txn_qty        => p_mtl_txn_qty,
       p_release            => p_release,
       x_source_type        => l_source_type,
       x_csi_txn_type_id    => l_csi_txn_type_id);

     l_error_rec.source_type                 := l_source_type;
     l_error_rec.transaction_type_id         := l_csi_txn_type_id;

     log('  '||l_error_rec.inv_material_transaction_id||' '||l_error_rec.source_type||' '||
           l_error_rec.transaction_type_id||' '||p_mtl_type_id||' '||p_mtl_action_id||' '||
           p_mtl_source_type_id);

     csi_transactions_pvt.create_txn_error (
       p_api_version          => 1.0,
       p_init_msg_list        => fnd_api.g_true,
       p_commit               => fnd_api.g_false,
       p_validation_level     => fnd_api.g_valid_level_full,
       p_txn_error_rec        => l_error_rec,
       x_transaction_error_id => l_error_id,
       x_return_status        => l_return_status,
       x_msg_count            => l_msg_count,
       x_msg_data             => l_msg_data);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
       RAISE fnd_api.g_exc_error;
     END IF;

     commit;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to pump_txn_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      log('  Error: '||l_error_message);
  END pump_txn_error;

  PROCEDURE decode_queue is
    CURSOR msg_cur(p_freeze_date IN date) IS
      SELECT msg_id,
             msg_code,
             msg_status,
             body_text,
             creation_date,
             description
      FROM   xnp_msgs
      WHERE  (msg_code like 'CSI%' OR msg_code like 'CSE%')
      AND    recipient_name is null
      AND    msg_status IN ('READY', 'FAILED', 'REJECTED')
      AND    msg_creation_date > p_freeze_date;

    l_amount        integer;
    l_msg_text      varchar2(32767);
    l_source_id     varchar2(200);
    l_source_type   varchar2(30);

    l_schema_name   varchar2(30);
    l_object_name   varchar2(80);
    l_freeze_date   date;
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    log(date_time_stamp||'  begin decode_queue');

    get_schema_name(
      p_product_short_name  => 'CSI',
      x_schema_name         => l_schema_name,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_object_name := l_schema_name||'.csi_xnp_msgs_temp';

    truncate_table(l_object_name);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;

    FOR msg_rec in msg_cur(l_freeze_date)
    LOOP

      l_amount := null;
      l_amount := dbms_lob.getlength(msg_rec.body_text);
      l_msg_text := null;

      dbms_lob.read(
        lob_loc => msg_rec.body_text,
        amount  => l_amount,
        offset  => 1,
        buffer  => l_msg_text );

      l_source_id := null;

      IF msg_rec.msg_code in ('CSISOFUL', 'CSIRMAFL') THEN
        xnp_xml_utils.decode(l_msg_text, 'ORDER_LINE_ID', l_source_id);
        l_source_type := 'ORDER_LINE_ID';
      ELSE
        xnp_xml_utils.decode(l_msg_text, 'MTL_TRANSACTION_ID', l_source_id);
        l_source_type := 'MTL_TRANSACTION_ID';
      END IF;

      INSERT INTO csi_xnp_msgs_temp(
        msg_id,
        msg_code,
        msg_text,
        msg_status,
        source_id,
        source_type,
        creation_date,
        description,
        process_flag)
      VALUES(
        msg_rec.msg_id,
        msg_rec.msg_code,
        l_msg_text,
        msg_rec.msg_status,
        l_source_id,
        l_source_type,
        msg_rec.creation_date,
        msg_rec.description,
        'Y');
      IF mod(msg_cur%rowcount, 100) = 0 THEN
        commit;
      END IF;
    END LOOP;

    log(date_time_stamp||'  end decode_queue');
  END decode_queue;

  PROCEDURE dequeue_messages_as_errors
  IS

    CURSOR q_cur IS
      SELECT msg_id,
             msg_code,
             msg_text,
             msg_status,
             source_id,
             source_type,
             creation_date,
             description,
             process_flag
      FROM   csi_xnp_msgs_temp
      WHERE  source_type = 'MTL_TRANSACTION_ID'
      AND    source_id   is not null;

      l_release             number;
      l_mtl_txn_id          number;
      l_mtl_type_id         number;
      l_mtl_action_id       number;
      l_mtl_source_type_id  number;
      l_mtl_type_class      number;
      l_mtl_txn_qty         number;

      skip_message          exception;

  BEGIN

    SELECT fnd_Profile.value('csi_upgrading_from_release')
    INTO   l_release
    FROM   sys.dual;

    decode_queue;

    FOR q_rec IN q_cur
    LOOP

      BEGIN

        BEGIN

          SELECT mmt.transaction_id,
                 mmt.transaction_type_id ,
                 mmt.transaction_action_id,
                 mmt.transaction_source_type_id,
                 mtt.type_class,
                 mmt.transaction_quantity
          INTO   l_mtl_txn_id,
                 l_mtl_type_id,
                 l_mtl_action_id,
                 l_mtl_source_type_id,
                 l_mtl_type_class,
                 l_mtl_txn_qty
          FROM   mtl_material_transactions mmt,
                 mtl_transaction_types     mtt
          WHERE  mmt.transaction_id      = q_rec.source_id
          AND    mtt.transaction_type_id = mmt.transaction_type_id;

        EXCEPTION
          WHEN no_data_found THEN
            RAISE skip_message;
          WHEN too_many_rows THEN
            RAISE skip_message;
        END;

        pump_txn_error(
          p_mtl_txn_id         => l_mtl_txn_id,
          p_mtl_type_id        => l_mtl_type_id,
          p_mtl_action_id      => l_mtl_action_id,
          p_mtl_source_type_id => l_mtl_source_type_id,
          p_mtl_type_class     => l_mtl_type_class,
          p_mtl_txn_qty        => l_mtl_txn_qty,
          p_dequeue_flag       => 'Y',
          p_release            => l_release);

        -- this code needs to be changed to appropriate call in xnp
        UPDATE xnp_msgs
        SET    msg_status = 'PROCESSED'
        WHERE  msg_id     = q_rec.msg_id;

      EXCEPTION
        WHEN skip_message THEN
          log('  bad mtl_txn_id for message in sfm queue message_id :'||q_rec.msg_id);
      END;
    END LOOP;

  END dequeue_messages_as_errors;

  PROCEDURE pump_prior_wip_missing_txns(
    p_mtl_creation_date IN date,
    p_mtl_txn_id        IN number,
    p_wip_job_id        IN number)
  IS
    CURSOR prior_cur(pc_mtl_creation_date IN date, pc_wip_job_id IN number, p_freeze_date in date) IS
      SELECT transaction_id                  mtl_txn_id,
             mmt.transaction_action_id       mtl_action_id,
             mmt.transaction_source_type_id  mtl_source_type_id,
             mmt.transaction_source_id       mtl_source_id,
             mmt.transaction_type_id         mtl_type_id,
             mtt.type_class                  mtl_type_class,
             mmt.transaction_quantity        mtl_txn_qty
      FROM   mtl_system_items          msi,
             mtl_transaction_types     mtt,
             mtl_material_transactions mmt
      WHERE  mmt.transaction_source_type_id = 5
      AND    mmt.transaction_action_id IN (1, 27, 31, 32, 33, 34)
      AND    mmt.transaction_date        > p_freeze_date
      AND    mmt.transaction_source_id   = pc_wip_job_id
      AND    mmt.creation_date           < pc_mtl_creation_date
      AND    mtt.transaction_type_id     = mmt.transaction_type_id
      AND    msi.organization_id         = mmt.organization_id
      AND    msi.inventory_item_id       = mmt.inventory_item_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y';

    l_release             varchar2(80);
    l_in_error            boolean;
    l_txn_error_flag      varchar2(1);

    l_in_queue            boolean;
    l_pending_msg_found   varchar2(1);

    l_processed           boolean;
    l_processed_flag      varchar2(1);

    TYPE missing_txn_rec is RECORD(
      mtl_txn_id          number,
      mtl_type_id         number,
      mtl_action_id       number,
      mtl_source_type_id  number,
      mtl_type_class      number,
      mtl_txn_qty         number);

    TYPE missing_txn_tbl is TABLE OF missing_txn_rec INDEX BY BINARY_INTEGER;

    l_missing_tbl         missing_txn_tbl;
    l_m_ind               binary_integer := 0;

    l_freeze_date         date;

  BEGIN

    l_missing_tbl.delete;

    SELECT fnd_Profile.value('CSI_UPGRADING_FROM_RELEASE')
    INTO   l_release
    FROM   sys.dual;
    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
     END IF;
     --
    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
    --
    FOR wip_txn_rec IN prior_cur(p_mtl_creation_date, p_wip_job_id, l_freeze_date)
    LOOP

      -- check if processed
      BEGIN
        SELECT 'Y' INTO l_processed_flag
        FROM   sys.dual
        WHERE  exists(
          SELECT '1' FROM  csi_transactions
          WHERE  inv_material_transaction_id = wip_txn_rec.mtl_txn_id);
        l_processed := true;
      EXCEPTION
        WHEN no_data_found THEN
          l_processed := false;
      END;

      IF NOT(l_processed) THEN
        -- check if errors
        l_in_error := false;
        BEGIN
          SELECT 'Y' INTO l_txn_error_flag
          FROM   sys.dual
          WHERE  EXISTS (
            SELECT '1' FROM csi_txn_errors
            WHERE  inv_material_transaction_id = wip_txn_rec.mtl_txn_id
            AND    processed_flag in ('E', 'R'));
          l_in_error := true;
        EXCEPTION
          WHEN no_data_found THEN
            l_in_error := false;
        END;

        -- check if pending in queue
        IF NOT(l_in_error) THEN
          BEGIN
            SELECT 'Y' INTO l_pending_msg_found
            FROM   sys.dual
            WHERE  exists (
              SELECT '1'
              FROM   csi_xnp_msgs_temp
              WHERE  source_type = 'MTL_TRANSACTION_ID'
              AND    source_id   = wip_txn_rec.mtl_txn_id
              AND    nvl(msg_status, 'READY') <> 'PROCESSED');
            l_in_queue := true;
          EXCEPTION
            WHEN no_data_found THEN
              l_in_queue := false;
          END;
        END IF;

        IF NOT(l_in_error) and NOT(l_in_queue) THEN

          l_m_ind := l_m_ind + 1;

          l_missing_tbl(l_m_ind).mtl_txn_id         := wip_txn_rec.mtl_txn_id;
          l_missing_tbl(l_m_ind).mtl_type_id        := wip_txn_rec.mtl_type_id;
          l_missing_tbl(l_m_ind).mtl_action_id      := wip_txn_rec.mtl_action_id;
          l_missing_tbl(l_m_ind).mtl_source_type_id := wip_txn_rec.mtl_source_type_id;
          l_missing_tbl(l_m_ind).mtl_type_class     := wip_txn_rec.mtl_type_class;
          l_missing_tbl(l_m_ind).mtl_txn_qty        := wip_txn_rec.mtl_txn_qty;

        END IF;

      END IF; -- not processed
    END LOOP;

    IF l_missing_tbl.COUNT > 0 THEN
      FOR l_ind IN l_missing_tbl.FIRST .. l_missing_tbl.LAST
      LOOP
        pump_txn_error(
          p_mtl_txn_id         => l_missing_tbl(l_ind).mtl_txn_id,
          p_mtl_type_id        => l_missing_tbl(l_ind).mtl_type_id,
          p_mtl_action_id      => l_missing_tbl(l_ind).mtl_action_id,
          p_mtl_source_type_id => l_missing_tbl(l_ind).mtl_source_type_id,
          p_mtl_type_class     => l_missing_tbl(l_ind).mtl_type_class,
          p_mtl_txn_qty        => l_missing_tbl(l_ind).mtl_txn_qty,
          p_dequeue_flag       => 'N',
          p_release            => l_release);
      END LOOP;
    END IF;

    commit;

  END pump_prior_wip_missing_txns;

  PROCEDURE pump_srl_missing_txns(
    p_serial_number       IN varchar2,
    p_item_id             IN number,
    p_serial_code         IN number,
    p_lot_code            IN number,
    p_freeze_date         IN date)
  IS

    l_release             varchar2(80);

    l_serial_code         number;
    l_lot_code            number;

    l_in_error            boolean;
    l_txn_error_flag      varchar2(1);

    l_in_queue            boolean;
    l_pending_msg_found   varchar2(1);

    l_processed           boolean;
    l_processed_flag      varchar2(1);

    TYPE missing_txn_rec is RECORD(
      mtl_txn_id          number,
      mtl_type_id         number,
      mtl_action_id       number,
      mtl_source_type_id  number,
      mtl_type_class      number,
      mtl_txn_qty         number);

    TYPE missing_txn_tbl is TABLE OF missing_txn_rec INDEX BY BINARY_INTEGER;

    l_missing_tbl         missing_txn_tbl;
    l_m_ind               binary_integer := 0;

  BEGIN


    l_missing_tbl.delete;

    SELECT fnd_Profile.value('csi_upgrading_from_release')
    INTO   l_release
    FROM   sys.dual;

    FOR all_txn_rec in all_txn_cur(
      p_serial_number => p_serial_number,
      p_item_id       => p_item_id)
    LOOP

      IF all_txn_rec.mtl_txn_date > p_freeze_date THEN

        IF  csi_inv_trxs_pkg.valid_ib_txn(all_txn_rec.mtl_txn_id) THEN

          -- check if processed
          BEGIN
            IF all_txn_rec.mtl_action_id in (2,3,28) THEN
              SELECT 'Y' INTO l_processed_flag
              FROM   sys.dual
              WHERE  exists(
                SELECT '1' FROM  csi_transactions
                WHERE  (inv_material_transaction_id = all_txn_rec.mtl_txn_id
                       OR
                       inv_material_transaction_id = all_txn_rec.mtl_xfer_txn_id));
            ELSE
              SELECT 'Y' INTO l_processed_flag
              FROM   sys.dual
              WHERE  exists(
                SELECT '1' FROM  csi_transactions
                WHERE  inv_material_transaction_id = all_txn_rec.mtl_txn_id);
            END IF;
            l_processed := true;
          EXCEPTION
            WHEN no_data_found THEN
              l_processed := false;
          END;

          IF l_processed THEN
            EXIT;
          END IF;

          -- check if errors
          l_in_error := false;
          BEGIN
            IF all_txn_rec.mtl_action_id in (2,3,28) THEN
              SELECT 'Y' INTO l_txn_error_flag
              FROM   sys.dual
              WHERE  EXISTS (
                SELECT '1' FROM csi_txn_errors
                WHERE  (inv_material_transaction_id = all_txn_rec.mtl_txn_id
                        OR
                        inv_material_transaction_id = all_txn_rec.mtl_xfer_txn_id)
                AND    processed_flag in ('E', 'R'));
            ELSE
              SELECT 'Y' INTO l_txn_error_flag
              FROM   sys.dual
              WHERE  EXISTS (
                SELECT '1' FROM csi_txn_errors
                WHERE  inv_material_transaction_id = all_txn_rec.mtl_txn_id
                AND    processed_flag in ('E', 'R'));
            END IF;
            l_in_error := true;
          EXCEPTION
            WHEN no_data_found THEN
              l_in_error := false;
          END;

          -- check if pending in queue
          IF NOT(l_in_error) THEN
            BEGIN
              SELECT 'Y' INTO l_pending_msg_found
              FROM   sys.dual
              WHERE  exists (
                SELECT '1'
                FROM   csi_xnp_msgs_temp
                WHERE  source_type = 'MTL_TRANSACTION_ID'
                AND    source_id   = all_txn_rec.mtl_txn_id
                AND    nvl(msg_status, 'READY') <> 'PROCESSED');
              l_in_queue := true;
            EXCEPTION
              WHEN no_data_found THEN
                l_in_queue := false;
            END;
          END IF;

          IF NOT(l_in_error) and NOT(l_in_queue) THEN

            l_m_ind := l_m_ind + 1;

            l_missing_tbl(l_m_ind).mtl_txn_id         := all_txn_rec.mtl_txn_id;
            l_missing_tbl(l_m_ind).mtl_type_id        := all_txn_rec.mtl_type_id;
            l_missing_tbl(l_m_ind).mtl_action_id      := all_txn_rec.mtl_action_id;
            l_missing_tbl(l_m_ind).mtl_source_type_id := all_txn_rec.mtl_source_type_id;
            l_missing_tbl(l_m_ind).mtl_type_class     := all_txn_rec.mtl_type_class;
            l_missing_tbl(l_m_ind).mtl_txn_qty        := all_txn_rec.mtl_txn_qty;

          END IF;

        END IF; -- valid ib transaction

      END IF;
    END LOOP;

    IF l_missing_tbl.COUNT > 0 THEN
      FOR l_ind IN l_missing_tbl.FIRST .. l_missing_tbl.LAST
      LOOP
        pump_txn_error(
          p_mtl_txn_id         => l_missing_tbl(l_ind).mtl_txn_id,
          p_mtl_type_id        => l_missing_tbl(l_ind).mtl_type_id,
          p_mtl_action_id      => l_missing_tbl(l_ind).mtl_action_id,
          p_mtl_source_type_id => l_missing_tbl(l_ind).mtl_source_type_id,
          p_mtl_type_class     => l_missing_tbl(l_ind).mtl_type_class,
          p_mtl_txn_qty        => l_missing_tbl(l_ind).mtl_txn_qty,
          p_dequeue_flag       => 'N',
          p_release            => l_release);
      END LOOP;
    END IF;

    commit;

  END pump_srl_missing_txns;

  PROCEDURE pump_all_missing_txns
  IS

    TYPE NumTabType is    varray(10000) of number;
    TYPE VarTabType is    varray(10000) of varchar2(80);

    l_serial_number_tab   VarTabType;
    l_item_id_tab         NumTabType;
    l_organization_id_tab NumTabType;

    MAX_BUFFER_SIZE       number := 1000;

    CURSOR all_srl_cur  IS
      SELECT msn.serial_number              serial_number,
             msn.inventory_item_id          item_id,
             msn.current_organization_id    organization_id
      FROM   mtl_serial_numbers msn
      WHERE  exists (
        SELECT '1'
        FROM   mtl_system_items msi,
               mtl_parameters   mp
        WHERE  mp.organization_id    = msn.current_organization_id
        AND    msi.organization_id   = mp.master_organization_id
        AND    msi.inventory_item_id = msn.inventory_item_id
        AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y');

    l_freeze_date         date;
    l_serial_code         number;
    l_lot_code            number;

  BEGIN

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
    --
    OPEN all_srl_cur;
    LOOP

      FETCH all_srl_cur BULK COLLECT
      INTO  l_serial_number_tab,
            l_item_id_tab,
            l_organization_id_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_serial_number_tab.COUNT
      LOOP

        log(' Serial Number : '||l_serial_number_tab(ind));

        SELECT serial_number_control_code,
               lot_control_code
        INTO   l_serial_code,
               l_lot_code
        FROM   mtl_system_items
        WHERE  inventory_item_id = l_item_id_tab(ind)
        AND    organization_id   = l_organization_id_tab(ind);

        pump_srl_missing_txns(
          p_serial_number       => l_serial_number_tab(ind),
          p_item_id             => l_item_id_tab(ind),
          p_serial_code         => l_serial_code,
          p_lot_code            => l_lot_code,
          p_freeze_date         => l_freeze_date);

      END LOOP;

      EXIT when all_srl_cur%NOTFOUND;

    END LOOP;

    IF all_srl_cur%ISOPEN THEN
      CLOSE all_srl_cur;
    END IF;

  END pump_all_missing_txns;

  PROCEDURE pump_err_missing_txns
  IS

    CURSOR tld_inst_cur(p_order_line_id in number) IS
      SELECT tld.instance_id,
             tld.serial_number,
             tld.inventory_item_id,
             tld.inv_organization_id
      FROM   csi_t_txn_line_details tld,
             csi_t_transaction_lines tl
      WHERE  tl.source_transaction_table = 'OE_ORDER_LINES_ALL'
      AND    tl.source_transaction_id    = p_order_line_id
      AND    tld.transaction_line_id     = tl.transaction_line_id
      AND    tld.instance_id is not null;

    l_mtl_source_type_id  number;
    l_mtl_action_id       number;
    l_wip_job_id          number;

    TYPE NumTabType is    varray(10000) of number;
    l_mtl_txn_id_tab      NumTabType;
    l_txn_error_id_tab    NumTabType;
    max_buffer_size       number := 1000;

    l_freeze_date         date;
    l_inv_item_id         number;
    l_inv_org_id          number;
    l_serial_code         number;
    l_lot_code            number;

    skip_error            exception;

    l_err_txn_date        date;
    l_order_line_id       number;
    l_inst_serial_number  varchar2(80);
    l_inst_item_id        number;
    l_inst_vld_org_id     number;
    l_mtl_creation_date   date;

  BEGIN

    log(date_time_stamp||'  begin pump_err_missing_txn');

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
    --
    OPEN error_cur;
    LOOP

      FETCH error_cur BULK COLLECT
      INTO  l_mtl_txn_id_tab,
            l_txn_error_id_tab
      LIMIT max_buffer_size;

      FOR ind IN 1 .. l_mtl_txn_id_tab.COUNT
      LOOP

        BEGIN
          BEGIN
            SELECT inventory_item_id,
                   organization_id,
                   transaction_source_type_id,
                   transaction_action_id,
                   transaction_source_id,
                   trx_source_line_id,
                   transaction_date,
                   creation_date
            INTO   l_inv_item_id,
                   l_inv_org_id,
                   l_mtl_source_type_id,
                   l_mtl_action_id,
                   l_wip_job_id,
                   l_order_line_id,
                   l_err_txn_date,
                   l_mtl_creation_date
            FROM   mtl_material_transactions
            WHERE  transaction_id = l_mtl_txn_id_tab(ind);
          EXCEPTION
            WHEN no_data_found THEN
              RAISE skip_error;
            WHEN too_many_rows THEN
              RAISE skip_error;
          END;

          IF l_err_txn_date < l_freeze_date THEN
            RAISE skip_error;
          END IF;

          SELECT serial_number_control_code,
                 lot_control_code
          INTO   l_serial_code,
                 l_lot_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = l_inv_item_id
          AND    organization_id   = l_inv_org_id;

          FOR srl_rec in srl_cur(l_mtl_txn_id_tab(ind))
          LOOP

            pump_srl_missing_txns(
              p_serial_number       => srl_rec.serial_number,
              p_item_id             => srl_rec.item_id,
              p_serial_code         => l_serial_code,
              p_lot_code            => l_lot_code,
              p_freeze_date         => l_freeze_date);

          END LOOP;

          IF l_mtl_action_id = 31 AND l_mtl_source_type_id = 5 THEN

            /* this routine pumps the prior wip transactions even if a txn is
               successfully processed later than the prior transaction
               forced pump for prior WIP transaction
            */
            pump_prior_wip_missing_txns(
              p_mtl_creation_date => l_mtl_creation_date,
              p_mtl_txn_id        => l_mtl_txn_id_tab(ind),
              p_wip_job_id        => l_wip_job_id);

          END IF;

          IF (l_mtl_action_id = 1 AND l_mtl_source_type_id = 2) OR -- sales order issue
             (l_mtl_action_id = 1 AND l_mtl_source_type_id = 8) OR -- int order issue
             (l_mtl_action_id = 27 AND l_mtl_source_type_id = 12)  -- rma receipt
          THEN

            FOR tld_inst_rec IN tld_inst_cur(l_order_line_id)
            LOOP

              l_inst_serial_number := tld_inst_rec.serial_number;
              l_inst_item_id       := tld_inst_rec.inventory_item_id;
              l_inst_vld_org_id    := tld_inst_rec.inv_organization_id;

              IF l_inst_serial_number is null THEN
                SELECT serial_number,
                       inventory_item_id,
                       last_vld_organization_id
                INTO   l_inst_serial_number,
                       l_inst_item_id,
                       l_inst_vld_org_id
                FROM   csi_item_instances
                WHERE  instance_id = tld_inst_rec.instance_id;
              END IF;

              IF l_inst_serial_number is not null THEN

                SELECT serial_number_control_code,
                       lot_control_code
                INTO   l_serial_code,
                       l_lot_code
                FROM   mtl_system_items
                WHERE  inventory_item_id = l_inst_item_id
                AND    organization_id   = l_inst_vld_org_id;

                pump_srl_missing_txns(
                  p_serial_number       => l_inst_serial_number,
                  p_item_id             => l_inst_item_id,
                  p_serial_code         => l_serial_code,
                  p_lot_code            => l_lot_code,
                  p_freeze_date         => l_freeze_date);

              END IF;

            END LOOP;
          END IF;


        EXCEPTION
          WHEN skip_error THEN
            log('  bad csi_txn_errors.mtl_txn_id : '||l_mtl_txn_id_tab(ind));
        END;
      END LOOP;

      EXIT when error_cur%NOTFOUND;

    END LOOP;

    IF error_cur%ISOPEN THEN
      CLOSE error_cur;
    END IF;

    log(date_time_stamp||'  end pump_err_missing_txn');

  END pump_err_missing_txns;

  /* main routine for populating the error stage of the serial transaction */
  PROCEDURE get_srldata(
    p_single_error_flag  IN  varchar2,
    p_mtl_txn_id         IN  number)
  IS

    CURSOR single_error_cur(pc_mtl_txn_id IN number) is
      SELECT cte.inv_material_transaction_id mtl_txn_id,
             cte.transaction_error_id        txn_error_id
      FROM   csi_txn_errors cte
      WHERE  cte.inv_material_transaction_id = pc_mtl_txn_id
      AND    cte.processed_flag in ('E', 'R');

    TYPE NumTabType is       varray(10000) of number;
    l_mtl_txn_id_tab         NumTabType;
    l_txn_error_id_tab       NumTabType;
    max_buffer_size          number := 1000;

    l_release                varchar2(80);

    l_diag_seq_id            number := 1000;
    l_freeze_date            date;
    l_inv_item_id            number;
    l_inv_org_id             number;

    l_unit_txn_found         boolean;
    l_knock_err_txn          boolean;
    l_err_txn_serial_code    number;
    l_err_txn_lot_code       number;
    l_err_txn_source_type_id number;
    l_err_txn_action_id      number;
    l_err_txn_date           date;

    l_serial_code            number;
    l_lot_code               number;
    l_revision_code          number;

    l_inst_id                number;
    l_inst_vld_org_id        number;
    l_inst_location          varchar2(80);
    l_inst_usage_code        varchar2(30);
    l_owner_ip_id            number;
    l_owner_ipa_id           number;
    l_inst_owner_pty_id      number;
    l_inst_owner_acct_id     number;
    l_inst_end_date          date;
    l_inst_org_id            number;
    l_inst_subinv_name       varchar2(30);
    l_inst_rev_num           varchar2(10);

    l_csi_txn_id             number;
    l_csi_txn_type_id        number;
    l_order_line_id          number;
    l_rma_line_id            number;
    l_wip_job_id             number;
    l_create_flag            varchar2(1) := 'N';
    l_error_flag             varchar2(1);
    l_last_txn               boolean;
    l_last_txn_flag          varchar2(1);

    l_error                  varchar2(2000);

    l_already_inserted       varchar2(1);
    l_inst_mig_flag          varchar2(1);
    l_internal_party_id      number;
    l_process_flag           varchar2(1);
    l_temp_message           varchar2(540);
    l_source_type            varchar2(30);

    l_txn_rec                csi_datastructures_pub.transaction_rec;
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);

    skip_insert              exception;
    skip_error               exception;

    l_schema_name            varchar2(30);
    l_object_name            varchar2(80);

  BEGIN

    -- dumps the xnp_msgs in to csi_xnp_msgs_tmp with the decoded value
    decode_queue;

    -- pump missing transaction for the serial numbers that are in error condition
    pump_err_missing_txns;

    get_schema_name(
      p_product_short_name  => 'CSI',
      x_schema_name         => l_schema_name,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_object_name := l_schema_name||'.csi_diagnostics_temp';

    -- cleans up the temporary process table
    truncate_table(l_object_name);

    log(date_time_stamp||'  begin get_srldata');

    SELECT fnd_Profile.value('csi_upgrading_from_release')
    INTO   l_release
    FROM   sys.dual;
    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_freeze_date       := csi_datastructures_pub.g_install_param_rec.freeze_date;
    --
    /* bulk fetch all the txn errors, 1000 records at a time */
    IF p_single_error_flag = 'Y' THEN
      OPEN single_error_cur(p_mtl_txn_id);
    ELSE
      /* bulk fetch all the txn errors, 1000 records at a time */
      OPEN error_cur;
    END IF;
    LOOP

      IF p_single_error_flag = 'Y' THEN
        FETCH single_error_cur BULK COLLECT
        INTO  l_mtl_txn_id_tab,
              l_txn_error_id_tab
        LIMIT max_buffer_size;
      ELSE
        FETCH error_cur BULK COLLECT
        INTO  l_mtl_txn_id_tab,
              l_txn_error_id_tab
        LIMIT max_buffer_size;
      END IF;

      FOR ind IN 1 .. l_mtl_txn_id_tab.COUNT
      LOOP

        BEGIN

          BEGIN
            SELECT inventory_item_id,
                   organization_id,
                   transaction_source_type_id,
                   transaction_action_id,
                   transaction_date
            INTO   l_inv_item_id,
                   l_inv_org_id,
                   l_err_txn_source_type_id,
                   l_err_txn_action_id,
                   l_err_txn_date
            FROM   mtl_material_transactions
            WHERE  transaction_id = l_mtl_txn_id_tab(ind);
          EXCEPTION
            WHEN no_data_found THEN
              RAISE skip_error;
            WHEN too_many_rows THEN
              RAISE skip_error;
          END;

          IF l_err_txn_date < l_freeze_date THEN

            UPDATE csi_txn_errors
            SET    processed_flag    = 'D',
                   error_text        = 'Transaction prior to freeze_date in install parameter',
                   last_update_login = fnd_global.login_id,
                   last_update_date  = sysdate,
                   last_updated_by   = fnd_global.user_id
            WHERE  transaction_error_id = l_txn_error_id_tab(ind);

            RAISE skip_error;
          END IF;

          SELECT serial_number_control_code,
                 lot_control_code
          INTO   l_err_txn_serial_code,
                 l_err_txn_lot_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = l_inv_item_id
          AND    organization_id   = l_inv_org_id;

          l_unit_txn_found := FALSE;

          FOR srl_rec in srl_cur(
            p_mtl_txn_id  => l_mtl_txn_id_tab(ind))
          LOOP

            l_unit_txn_found      := TRUE;

            l_inst_id             := null;
            l_inst_vld_org_id     := null;
            l_inst_location       := null;
            l_inst_usage_code     := null;
            l_owner_ip_id         := null;
            l_owner_ipa_id        := null;
            l_inst_owner_pty_id   := null;
            l_inst_owner_acct_id  := null;
            l_inst_end_date       := null;
            l_inst_org_id         := null;
            l_inst_subinv_name    := null;
            l_inst_mig_flag       := null;
            l_process_flag        := 'N';
            l_temp_message        := null;
            l_create_flag         := 'N';

            BEGIN
              SELECT instance_id ,
                     last_vld_organization_id,
                     owner_party_id,
                     owner_party_account_id,
                     location_type_code,
                     instance_usage_code,
                     active_end_date,
                     inv_organization_id,
                     inv_subinventory_name,
                     inventory_revision,
                     nvl(migrated_flag, 'N')
              INTO   l_inst_id,
                     l_inst_vld_org_id,
                     l_inst_owner_pty_id,
                     l_inst_owner_acct_id,
                     l_inst_location,
                     l_inst_usage_code,
                     l_inst_end_date,
                     l_inst_org_id,
                     l_inst_subinv_name,
                     l_inst_rev_num,
                     l_inst_mig_flag
              FROM   csi_item_instances
              WHERE  inventory_item_id = srl_rec.item_id
              AND    serial_number     = srl_rec.serial_number;

              l_create_flag := 'N';

              BEGIN
                SELECT instance_party_id
                INTO   l_owner_ip_id
                FROM   csi_i_parties
                WHERE  instance_id            = l_inst_id
                AND    relationship_type_code = 'OWNER'
                AND    rownum                 = 1;

                BEGIN
                  SELECT ip_account_id
                  INTO   l_owner_ipa_id
                  FROM   csi_ip_accounts
                  WHERE  instance_party_id      = l_owner_ip_id
                  AND    relationship_type_code = 'OWNER';
                EXCEPTION
                  WHEN no_data_found THEN
                    l_owner_ipa_id := null;
                END;

              EXCEPTION
                WHEN no_data_found THEN
                  l_owner_ip_id := null;
              END;

            EXCEPTION
              WHEN no_data_found THEN
                l_create_flag := 'Y';
                null;
              WHEN too_many_rows THEN
                l_create_flag  := 'N';
                l_process_flag := 'E';
                l_temp_message := 'Multiple serialized instances found';
            END;

            l_last_txn := TRUE;

            FOR txn_rec in all_txn_cur (
              p_serial_number => srl_rec.serial_number,
              p_item_id       => srl_rec.item_id)
            LOOP

              IF txn_rec.mtl_txn_date > l_freeze_date THEN

                BEGIN

                  IF not csi_inv_trxs_pkg.valid_ib_txn(txn_rec.mtl_txn_id) THEN
                    raise skip_insert;
                  END IF;

                  IF l_last_txn THEN
                    l_last_txn_flag := 'Y';
                  ELSE
                    l_last_txn_flag := 'N';
                  END IF;

                  l_last_txn := FALSE;

                  l_order_line_id := null;
                  l_rma_line_id   := null;
                  l_wip_job_id    := null;

                  -- sales order shipment -- pick release
                  IF txn_rec.mtl_type_id in (33,52)  THEN
                    l_order_line_id := txn_rec.mtl_source_line_id;
                  END IF;

                  -- rma receipt
                  IF txn_rec.mtl_type_id = 15 THEN
                    l_rma_line_id := txn_rec.mtl_source_line_id;
                  END IF;

                  -- wip transactions
                  IF txn_rec.mtl_source_type_id = 5 THEN
                    l_wip_job_id  := txn_rec.mtl_source_id;
                  END IF;

                  l_csi_txn_id      := null;
                  l_csi_txn_type_id := null;

                  BEGIN
                    IF txn_rec.mtl_action_id in (2,3,28) THEN
                      SELECT cte.transaction_type_id,
                             cte.error_text
                      INTO   l_csi_txn_type_id,
                             l_error
                      FROM   csi_txn_errors cte
                      WHERE  (cte.inv_material_transaction_id = txn_rec.mtl_txn_id
                              OR
                              cte.inv_material_transaction_id = txn_rec.mtl_xfer_txn_id)
                      AND    cte.processed_flag  in ('E', 'R')
                      AND    rownum = 1;
                    ELSE
                      SELECT cte.transaction_type_id,
                             cte.error_text
                      INTO   l_csi_txn_type_id,
                             l_error
                      FROM   csi_txn_errors cte
                      WHERE  cte.inv_material_transaction_id = txn_rec.mtl_txn_id
                      AND    cte.processed_flag  in ('E', 'R')
                      AND    rownum = 1;
                    END IF;

                    l_error_flag := 'E';
                  EXCEPTION
                    WHEN no_data_found THEN
                      l_error_flag := 'M';
                      l_error := null;
                  END;

                  BEGIN
                    IF txn_rec.mtl_action_id in (2,3,28) THEN
                      SELECT transaction_id,
                             transaction_type_id
                      INTO   l_csi_txn_id,
                             l_csi_txn_type_id
                      FROM   csi_transactions
                      WHERE (inv_material_transaction_id = txn_rec.mtl_txn_id
                             OR
                             inv_material_transaction_id = txn_rec.mtl_xfer_txn_id)
                      AND    rownum = 1;
                    ELSE
                      SELECT transaction_id,
                             transaction_type_id
                      INTO   l_csi_txn_id,
                             l_csi_txn_type_id
                      FROM   csi_transactions
                      WHERE  inv_material_transaction_id = txn_rec.mtl_txn_id
                      AND    rownum = 1;
                    END IF;
                  EXCEPTION
                    WHEN no_data_found THEN
                      l_csi_txn_id := null;
                  END;

                  IF nvl(l_error_flag,'P') = 'E' THEN
                    l_error_flag := 'E';
                  ELSE
                    IF l_csi_txn_id is not null THEN
                      l_error_flag := 'P';
                    END IF;
                  END IF;

                  BEGIN
                    SELECT 'Y' INTO l_already_inserted
                    FROM   csi_diagnostics_temp
                    WHERE  serial_number      = srl_rec.serial_number
                    AND    inventory_item_id  = srl_rec.item_id
                    AND    mtl_txn_id         = txn_rec.mtl_txn_id;
                  EXCEPTION
                    WHEN no_data_found THEN

                      SELECT serial_number_control_code,
                             lot_control_code ,
                             revision_qty_control_code
                      INTO   l_serial_code,
                             l_lot_code,
                             l_revision_code
                      FROM   mtl_system_items
                      WHERE  inventory_item_id = txn_rec.item_id
                      AND    organization_id   = txn_rec.organization_id;

                      get_source_type(
                        p_mtl_txn_id         => txn_rec.mtl_txn_id,
                        p_mtl_type_id        => txn_rec.mtl_type_id,
                        p_mtl_action_id      => txn_rec.mtl_action_id,
                        p_mtl_source_type_id => txn_rec.mtl_source_type_id,
                        p_mtl_type_class     => txn_rec.mtl_type_class,
                        p_mtl_txn_qty        => txn_rec.mtl_txn_qty,
                        p_release            => l_release,
                        x_source_type        => l_source_type,
                        x_csi_txn_type_id    => l_csi_txn_type_id);

                      l_diag_seq_id := l_diag_seq_id + 1;

                      INSERT INTO csi_diagnostics_temp(
                        diag_seq_id,
                        serial_number,
                        lot_number,
                        serial_control_code,
                        lot_control_code,
                        revision_control_code,
                        mtl_creation_date,
                        mtl_txn_date,
                        mtl_txn_id,
                        mtl_txn_name,
                        mtl_txn_qty,
                        mtl_xfer_txn_id,
                        mtl_item_revision,
                        inventory_item_id,
                        organization_id,
                        error_flag,
                        error_text,
                        mtl_type_id,
                        mtl_action_id,
                        mtl_src_type_id,
                        mtl_type_class,
                        source_type,
                        csi_txn_type_id,
                        csi_txn_id,
                        oe_order_line_id,
                        wip_job_id,
                        oe_rma_line_id,
                        instance_id,
                        instance_vld_organization_id,
                        instance_location,
                        instance_usage_code,
                        instance_organization_id,
                        instance_subinv_name,
                        instance_revision,
                        instance_end_date,
                        instance_owner_party_id,
                        instance_owner_account_id,
                        instance_mig_flag,
                        internal_party_id,
                        last_transaction_flag,
                        create_flag,
                        process_flag,
                        temporary_message)
                      VALUES(
                        l_diag_seq_id,
                        srl_rec.serial_number,
                        txn_rec.lot_number,
                        l_serial_code,
                        l_lot_code,
                        l_revision_code,
                        txn_rec.mtl_creation_date,
                        txn_rec.mtl_txn_date,
                        txn_rec.mtl_txn_id,
                        txn_rec.mtl_txn_name,
                        txn_rec.mtl_txn_qty,
                        txn_rec.mtl_xfer_txn_id,
                        txn_rec.mtl_revision,
                        srl_rec.item_id,
                        txn_rec.organization_id,
                        l_error_flag,
                        l_error,
                        txn_rec.mtl_type_id,
                        txn_rec.mtl_action_id,
                        txn_rec.mtl_source_type_id,
                        txn_rec.mtl_type_class,
                        l_source_type,
                        l_csi_txn_type_id,
                        l_csi_txn_id,
                        l_order_line_id,
                        l_wip_job_id,
                        l_rma_line_id,
                        l_inst_id,
                        l_inst_vld_org_id,
                        l_inst_location,
                        l_inst_usage_code,
                        l_inst_org_id,
                        l_inst_subinv_name,
                        l_inst_rev_num,
                        l_inst_end_date,
                        l_inst_owner_pty_id,
                        l_inst_owner_acct_id,
                        l_inst_mig_flag,
                        l_internal_party_id,
                        l_last_txn_flag,
                        l_create_flag,
                        l_process_flag,
                        l_temp_message);

                      commit;

                  END;

                EXCEPTION
                  WHEN skip_insert THEN
                    null;
                END;
              END IF;
            END LOOP;
          END LOOP;

          l_knock_err_txn  := FALSE;

          -- serialized and no unit txn
          IF l_err_txn_serial_code IN (2, 5) AND NOT(l_unit_txn_found) THEN
            l_knock_err_txn := TRUE;
          END IF;

          -- non serial and having unit txn
          IF l_err_txn_serial_code = 1 AND l_unit_txn_found THEN
            l_knock_err_txn := TRUE;
          END IF;

          IF l_err_txn_serial_code = 6 THEN
            -- exclude rma and shipments from knocking
            IF (l_err_txn_action_id = 27 AND l_err_txn_source_type_id = 12) -- RMA
                OR
               (l_err_txn_action_id = 1  AND l_err_txn_source_type_id = 2)  -- Ship
            THEN
              IF NOT(l_unit_txn_found)  THEN
                l_knock_err_txn := TRUE;
              ELSE
                l_knock_err_txn := FALSE;
              END IF;
            ELSE
              IF l_unit_txn_found  THEN
                IF (l_err_txn_action_id = 3  AND l_err_txn_source_type_id = 8) -- ISO Direct Ship
                    OR
                   (l_err_txn_action_id = 12 AND l_err_txn_source_type_id = 7) -- ISO Intr Receipt
                    OR
                   (l_err_txn_action_id = 21 AND l_err_txn_source_type_id = 8) -- ISO Intr Ship
                    OR
                   (l_err_txn_action_id = 1 AND l_err_txn_source_type_id = 8)  -- Internal Order Issue
                    OR
                   (l_err_txn_action_id = 1 AND l_err_txn_source_type_id = 16) -- Proj Contract Issue
                THEN
                  l_knock_err_txn := FALSE;
                ELSE
                  l_knock_err_txn := TRUE;
                END IF;
              ELSE
                l_knock_err_txn := FALSE;
              END IF;
            END IF;
          END IF;

          IF l_knock_err_txn THEN
            UPDATE csi_txn_errors
            SET    processed_flag = 'D',
                   error_text     = 'Serial control is now inappropriate for this txn. Knocking this',
                   last_update_date  = sysdate,
                   last_update_login = fnd_global.login_id,
                   last_updated_by   = fnd_global.user_id
            WHERE  inv_material_transaction_id = l_mtl_txn_id_tab(ind)
            AND    processed_flag in ('E', 'R');

            DELETE FROM csi_diagnostics_temp
            WHERE  mtl_txn_id = l_mtl_txn_id_tab(ind)
            AND    error_flag = 'E';

            -- for wip errors that are knocked we write a csi transaction '
            -- to make the completion goes thru
            IF l_err_txn_source_type_id = 5 OR l_unit_txn_found THEN

              l_txn_rec.transaction_id                := fnd_api.g_miss_num;
              l_txn_rec.transaction_type_id           := correction_txn_type_id;
              l_txn_rec.source_header_ref             := 'DATAFIX';
              l_txn_rec.source_line_ref               := 'SRLCONTROL TXN MISMATCH';
              l_txn_rec.source_transaction_date       := l_err_txn_date;
              l_txn_rec.transaction_date              := sysdate;
              l_txn_rec.inv_material_transaction_id   := l_mtl_txn_id_tab(ind);

              csi_transactions_pvt.create_transaction (
                p_api_version             => 1.0,
                p_commit                  => fnd_api.g_false,
                p_init_msg_list           => fnd_api.g_true,
                p_validation_level        => fnd_api.g_valid_level_full,
                p_success_if_exists_flag  => 'Y',
                p_transaction_rec         => l_txn_rec,
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data  );

            END IF;
          END IF;

        EXCEPTION
          WHEN skip_error THEN
            log('  bad csi_txn_errors.mtl_txn_id : '||l_mtl_txn_id_tab(ind));
        END;
      END LOOP; -- error txn loop

      IF p_single_error_flag = 'Y' THEN
        EXIT when single_error_cur%NOTFOUND;
      ELSE
        EXIT when error_cur%NOTFOUND;
      END IF;

    END LOOP;

    IF p_single_error_flag = 'Y' THEN
      IF single_error_cur%ISOPEN THEN
        CLOSE single_error_cur;
      END IF;
    ELSE
      IF error_cur%ISOPEN THEN
        CLOSE error_cur;
      END IF;
    END IF;

    log(date_time_stamp||'  end get_srldata');

  END get_srldata;

  PROCEDURE preprocess_shipment(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
    l_expire_flag       varchar2(1) := 'N';
    l_change_owner_flag varchar2(1) := 'Y';

    l_owner_party_id    number;
    l_owner_account_id  number;

  BEGIN

    IF  p_diag_txn_rec.serial_code = 6 THEN
      l_expire_flag := 'N';
      IF p_diag_txn_rec.create_flag = 'N' THEN

        get_rma_owner(
          p_serial_number     => p_diag_txn_rec.serial_number,
          p_inventory_item_id => p_diag_txn_rec.item_id,
          p_organization_id   => p_diag_txn_rec.organization_id,
          x_change_owner_flag => l_change_owner_flag,
          x_owner_party_id    => l_owner_party_id,
          x_owner_account_id  => l_owner_account_id);

        IF l_change_owner_flag = 'Y' THEN
          l_expire_flag := 'Y';
        ELSE
          l_expire_flag := 'N';
        END IF;

        UPDATE csi_diagnostics_temp
        SET    process_flag  = 'M',
               process_code  = 'SOISHIP',
               expire_flag   = l_expire_flag,
               temporary_message  = 'Updating the srlsoi instance with returned RMA info.'
        WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

      ELSE

        UPDATE csi_diagnostics_temp
        SET    process_flag  = 'M',
               process_code  = 'SOISHIP',
               temporary_message  = 'Creating/Updating a non serial instance with staging info'
        WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

      END IF;

    ELSE

      UPDATE csi_diagnostics_temp
      SET    process_flag  = 'M',
             process_code  = 'SHIP',
             temporary_message  = 'Creating/Updating the instance with staging info'
      WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

    END IF;

  END preprocess_shipment;

  PROCEDURE preprocess_rma(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN

    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'RMA',
           temporary_message  = 'Just mark error transaction to be re-processed'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

  END preprocess_rma;

  PROCEDURE preprocess_wipissue(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN
    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'WIPISSUE',
           temporary_message  = 'Stamp the inv location from serial and mark it FOR processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;
  END preprocess_wipissue;

  PROCEDURE preprocess_wipreturn(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN

    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'WIPRETURN',
           temporary_message  = 'Make it a WIP instance and allow re-processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

  END preprocess_wipreturn;

  PROCEDURE preprocess_wipcompletion(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN

    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'WIPCOMPL',
           temporary_message  = 'Mark the error FOR re-processing.'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

  END preprocess_wipcompletion;

  PROCEDURE preprocess_miscreceipt(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN

    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'MISCRCPT',
           temporary_message  = 'Stamp the INV location from serial'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

  END preprocess_miscreceipt;

  PROCEDURE preprocess_miscissue(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN

    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'MISCISSUE',
           temporary_message  = 'Stamp the INV location from serial'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

  END preprocess_miscissue;

  PROCEDURE preprocess_sixfer(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN

    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'SIXFER',
           temporary_message  = 'Stamp the inv location from serial and mark it FOR processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;

  END preprocess_sixfer;


  PROCEDURE preprocess_projreceipt(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN
    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'PROJRCPT',
           temporary_message  = 'Stamp the project location from serial and mark it for processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;
  END preprocess_projreceipt;

  PROCEDURE preprocess_interorgreceipt(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN
    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'IORGRCPT',
           temporary_message  = 'Stamp the intransit location from serial and mark it for processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;
  END preprocess_interorgreceipt;

  PROCEDURE preprocess_isoreceipt(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN
    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'ISORCPT',
           temporary_message  = 'Stamp the intransit location from serial and mark it for processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;
  END preprocess_isoreceipt;

  PROCEDURE preprocess_intransitship(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN
    UPDATE csi_diagnostics_temp
    SET    process_flag  = 'M',
           process_code  = 'INTRSHIP',
           temporary_message  = 'Stamp the inv location from serial and mark it for processing'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;
  END preprocess_intransitship;

  PROCEDURE preprocess_unidentified(
    p_diag_txn_rec      IN diag_txn_rec)
  IS
  BEGIN
    UPDATE csi_diagnostics_temp
    SET    process_flag   = 'R',
           temporary_message   = 'Marking this for re-process.'
    WHERE  diag_seq_id   = p_diag_txn_rec.diag_seq_id;
  END preprocess_unidentified;

  PROCEDURE preprocess_all(
    p_diag_txn_tbl        IN diag_txn_tbl)
  IS

    l_diag_txn_rec        diag_txn_rec;
    l_error_found         boolean := FALSE;
    l_error_ind           binary_integer := 0;
    l_diag_txn_r_tbl      diag_txn_tbl;
    l_preprocessed        boolean := false;

  BEGIN

    IF p_diag_txn_tbl.COUNT > 0 THEN

      l_preprocessed  := FALSE;
      l_error_found   := FALSE;

      FOR l_rev_ind IN reverse p_diag_txn_tbl.FIRST .. p_diag_txn_tbl.LAST
      LOOP

        l_diag_txn_rec := p_diag_txn_tbl(l_rev_ind);

        IF nvl(p_diag_txn_tbl(l_rev_ind).error_flag,'P') = 'E' THEN
          l_error_found := TRUE;
          l_error_ind   := l_rev_ind;
          exit;
        END IF;

      END LOOP;

      IF l_error_found THEN

        log('    '||l_diag_txn_rec.source_type||'  '||l_diag_txn_rec.mtl_txn_id||
            '  '||l_diag_txn_rec.process_code);

        IF l_diag_txn_rec.source_type = 'CSISOSHP' THEN -- shipping
          preprocess_shipment(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type = 'CSIOKSHP' THEN -- project contract shipment
          preprocess_shipment(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type = 'CSIRMARC' THEN -- rma
          preprocess_rma(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type IN (
                 'CSIWIPCI', -- wip component issue
                 'CSIWIPNR', -- wip negative component return
                 'CSIWIPAR') -- wip assembly return
        THEN
          preprocess_wipissue(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type IN (
                 'CSIWIPCR', -- wip component return
                 'CSIWIPNI') -- wip negative component issue
        THEN  -- wip returns
          preprocess_wipreturn(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type = 'CSIWIPAC' THEN -- wip completion
          preprocess_wipcompletion(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF (l_diag_txn_rec.source_type = 'CSIMSRCV') -- misc receipt
            OR
           (l_diag_txn_rec.source_type = 'CSICYCNT' AND l_diag_txn_rec.mtl_txn_qty > 0)
            OR
           (l_diag_txn_rec.source_type = 'CSIPHYIN' AND l_diag_txn_rec.mtl_txn_qty > 0)
            OR
           (l_diag_txn_rec.source_type = 'CSIPOINV')
        THEN
          preprocess_miscreceipt(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF (l_diag_txn_rec.source_type IN (
                 'CSIMSISU', -- misc issue
                 'CSIISUPT', -- move order issue to project
                 'CSIMSIPT') -- misc issue to project
            OR
           (l_diag_txn_rec.source_type = 'CSICYCNT' AND l_diag_txn_rec.mtl_txn_qty < 0)
            OR
           (l_diag_txn_rec.source_type = 'CSIPHYIN' AND l_diag_txn_rec.mtl_txn_qty < 0))
        THEN
          preprocess_miscissue(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type IN (
             'CSISUBTR', -- subinventory transfer
             'CSIORGDS', -- interorg direct shipment
             'CSIINTDS') -- iso direct shipment
        THEN
          preprocess_sixfer(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        -- receipt from project
        IF l_diag_txn_rec.source_type = 'CSIMSRPT' THEN
          preprocess_projreceipt(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        -- interorg intransit receipt
        IF l_diag_txn_rec.source_type = 'CSIORGTR' THEN
          preprocess_interorgreceipt(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        -- Internal sales order requisition receipt
        IF l_diag_txn_rec.source_type = 'CSIINTSR' THEN
          preprocess_isoreceipt(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type IN (
          'CSIORGTS', -- interorg intransit shipment
          'CSIINTSS') -- internal sales order intransit shipment
        THEN
          preprocess_intransitship(
            p_diag_txn_rec => l_diag_txn_rec);
          l_preprocessed := TRUE;
        END IF;

        IF l_diag_txn_rec.source_type = 'NONE' THEN
          l_preprocessed := FALSE;
        END IF;

        IF l_preprocessed THEN
          FOR l_ind IN 1 .. l_error_ind-1
          LOOP
            IF nvl(p_diag_txn_tbl(l_ind).error_flag,'P') = 'E' THEN
              UPDATE csi_diagnostics_temp
              SET    process_flag = 'R',
                     temporary_message = 'Marking it for re-process'
              WHERE  diag_seq_id = p_diag_txn_tbl(l_ind).diag_seq_id;
            END IF;
          END LOOP;
        END IF;

      END IF;
    END IF;

  END preprocess_all;

  PROCEDURE knock_all(
    p_diag_txn_tbl IN diag_txn_tbl)
  IS
  BEGIN
    IF p_diag_txn_tbl.COUNT > 0 THEN
      FOR l_ind IN  p_diag_txn_tbl.FIRST .. p_diag_txn_tbl.LAST
      LOOP

        IF nvl(p_diag_txn_tbl(l_ind).error_flag,'P') = 'E' THEN

          UPDATE csi_diagnostics_temp
          SET    process_flag = 'X',
                 temporary_message = 'Succeeding txn processed in IB for this serial'
          WHERE  diag_seq_id = p_diag_txn_tbl(l_ind).diag_seq_id;

        END IF;

      END LOOP;
    END IF;
  END knock_all;

  PROCEDURE init_diag_temp
  IS
    CURSOR diag_cur IS
      SELECT rowid row_id
      FROM   csi_diagnostics_temp;

  BEGIN

    FOR diag_rec IN diag_cur
    LOOP

      UPDATE csi_diagnostics_temp
      SET    process_flag   = 'N',
             process_code   = null,
             entangled_flag = null,
             expire_flag    = null,
             temporary_message   = null
      WHERE  rowid = diag_rec.row_id;

      IF mod(diag_cur%rowcount, 100) = 0 THEN
        commit;
      END IF;

    END LOOP;
    commit;

  END init_diag_temp;

  FUNCTION check_contracts(
    p_instance_id IN number)
  RETURN BOOLEAN
  IS
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count      number;
    l_msg_data       varchar2(2000);
    l_contracts_tbl  oks_entitlements_pub.output_tbl_ib;
    l_inp_rec        oks_entitlements_pub.input_rec_ib;
  BEGIN

    l_inp_rec.validate_flag      := 'Y'; -- show all contracts
    l_inp_rec.product_id         := p_instance_id;
    l_inp_rec.calc_resptime_flag := 'N';

    oks_entitlements_pub.get_contracts(
      p_api_version     => 1.0,
      p_init_msg_list   => 'T',
      p_inp_rec         => l_inp_rec,
      x_ent_contracts   => l_contracts_tbl,
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data);
    --
    IF l_contracts_tbl.count > 0 THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;

  END check_contracts;

  PROCEDURE identify_progressed(
    x_progressed OUT nocopy boolean)
  IS

    l_progressed          boolean := FALSE;
    l_process_code        varchar2(20);
    l_p_diag_seq_id       number;
    l_p_mtl_txn_id        number;
    l_p_mtl_creation_date date;
    l_p_csi_txn_id        number;
    l_contracts_flag      varchar2(1);
    l_earlier_txn_marked  boolean := FALSE;

    l_process_flag        varchar2(1);
    l_current_date        date;

    CURSOR m_cur IS
      SELECT distinct mtl_creation_date, mtl_txn_id
      FROM   csi_diagnostics_temp
      WHERE  nvl(process_flag, 'N') = 'M'
      ORDER BY mtl_creation_date asc, mtl_txn_id asc;

    CURSOR m_srl_cur(p_mtl_txn_id IN number) IS
      SELECT diag_seq_id,
             serial_number,
             inventory_item_id,
             instance_id,
             lot_control_code,
             process_flag
      FROM   csi_diagnostics_temp
      WHERE  mtl_txn_id = p_mtl_txn_id
      AND    nvl(process_flag, 'N') <> 'M';

    -- already marked earlier transactions
    CURSOR p_et_cur(
      p_serial_number     IN varchar2,
      p_item_id           IN number,
      p_mtl_creation_date IN date)
    IS
      SELECT diag_seq_id
      FROM   csi_diagnostics_temp
      WHERE  serial_number         = p_serial_number
      AND    inventory_item_id     = p_item_id
      AND    mtl_creation_date     < p_mtl_creation_date
      AND    nvl(process_flag,'N') = 'M';

    -- progressed marked transactions
    CURSOR p_lt_cur(
      p_serial_number     IN varchar2,
      p_item_id           IN number,
      p_mtl_creation_date IN date)
    IS
      SELECT diag_seq_id
      FROM   csi_diagnostics_temp
      WHERE  serial_number         = p_serial_number
      AND    inventory_item_id     = p_item_id
      AND    mtl_creation_date     > p_mtl_creation_date
      AND    nvl(process_flag,'N') = 'M'
      ORDER by mtl_creation_date asc, mtl_txn_id asc;

    CURSOR missing_csi_cur(
      p_serial_number     IN varchar2,
      p_item_id           IN number,
      p_mtl_creation_date IN date)
    IS
      SELECT diag_seq_id,
             mtl_txn_id,
             csi_txn_id,
             mtl_txn_date
      FROM   csi_diagnostics_temp
      WHERE  serial_number     = p_serial_number
      AND    inventory_item_id = p_item_id
      AND    mtl_creation_date < p_mtl_creation_date
      ORDER BY mtl_creation_date desc, mtl_txn_id desc;

    skip_txn           exception;
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data         varchar2(2000);
    l_msg_count        number;
    l_txn_rec          csi_datastructures_pub.transaction_rec;

  BEGIN

    FOR m_rec IN m_cur -- read all the distinct inv txn records that are marked for update
    LOOP

      BEGIN

        -- check if this txn is still there to be processed in the loop
        BEGIN
          SELECT process_code
          INTO   l_process_code
          FROM   csi_diagnostics_temp
          WHERE  mtl_txn_id            = m_rec.mtl_txn_id
          AND    nvl(process_flag,'N') = 'M' -- marked for update
          AND    rownum                = 1;
        EXCEPTION
          WHEN no_data_found THEN
            RAISE skip_txn;
        END;

        l_earlier_txn_marked := FALSE;

        -- get all the serials that are in the txn that are not marked as 'M'
        FOR m_srl_rec IN m_srl_cur(m_rec.mtl_txn_id)
        LOOP

          -- check if the earlier txn is marked for re-processing
          FOR p_et_rec in p_et_cur(
            p_serial_number     => m_srl_rec.serial_number,
            p_item_id           => m_srl_rec.inventory_item_id,
            p_mtl_creation_date => m_rec.mtl_creation_date)
          LOOP
            l_earlier_txn_marked := TRUE;
            exit;
          END LOOP;
        END LOOP;

        IF l_earlier_txn_marked THEN
          --skip it for marking this batch
          FOR m_srl_rec IN m_srl_cur(m_rec.mtl_txn_id)
          LOOP
            IF nvl(m_srl_rec.process_flag, 'N') = 'X' THEN
              UPDATE csi_diagnostics_temp
              SET    process_flag      = 'N',
                     temporary_message = 'updating for entanglement processing'
              WHERE  diag_seq_id       = m_srl_rec.diag_seq_id;
            END IF;
          END LOOP;
          RAISE skip_txn;
        END IF;

        -- get all the other serials in this transaction to be marked for processing
        -- the same way as the current serial
        FOR m_srl_rec IN m_srl_cur(m_rec.mtl_txn_id)
        LOOP

          UPDATE csi_diagnostics_temp
          SET    process_code = l_process_code,
                 process_flag = 'M',
                 temporary_message = 'updating for entanglement processing'
          WHERE  diag_seq_id  = m_srl_rec.diag_seq_id;

          -- for this serial check if there is any progressed transaction
          --

          IF m_srl_rec.instance_id is not null THEN

            -- get the max processed material transaction id
            SELECT nvl(min(diag_seq_id), -999999)
            INTO   l_p_diag_seq_id
            FROM   csi_diagnostics_temp
            WHERE  serial_number       = m_srl_rec.serial_number
            AND    inventory_item_id   = m_srl_rec.inventory_item_id
            AND    mtl_creation_date   > m_rec.mtl_creation_date
            AND    csi_txn_id          is not null;

            IF l_p_diag_seq_id <> -999999 THEN

              SELECT mtl_txn_id,
                     mtl_creation_date
              INTO   l_p_mtl_txn_id,
                     l_p_mtl_creation_date
              FROM   csi_diagnostics_temp
              WHERE  diag_seq_id = l_p_diag_seq_id;

              IF check_contracts(m_srl_rec.instance_id) THEN
                l_contracts_flag := 'Y';
              ELSE
                l_contracts_flag := 'N';
              END IF;

              SELECT csi_txn_id
              INTO   l_p_csi_txn_id
              FROM   csi_diagnostics_temp
              WHERE  serial_number     = m_srl_rec.serial_number
              AND    inventory_item_id = m_srl_rec.inventory_item_id
              AND    mtl_txn_id        = l_p_mtl_txn_id;

              l_progressed := TRUE;

              BEGIN

                SELECT process_flag,
                       date_time_stamp
                INTO   l_process_flag,
                       l_current_date
                FROM   csi_ii_forward_sync_temp
                WHERE  instance_id = m_srl_rec.instance_id;

                IF l_process_flag = 'P' THEN
                  Insert_Full_Dump(p_instance_id => m_srl_rec.instance_id);
                  l_current_date := sysdate;
                ELSE
                  l_current_date := l_current_date;
                END IF;

                UPDATE csi_ii_forward_sync_temp
                SET    date_time_stamp       = l_current_date,
                       mtl_txn_id            = l_p_mtl_txn_id,
                       mtl_txn_creation_date = l_p_mtl_creation_date,
                       contracts_flag        = l_contracts_flag,
                       process_flag          = 'N'
                WHERE  instance_id           =  m_srl_rec.instance_id;

              EXCEPTION
                WHEN no_data_found THEN
                  Insert_Full_Dump(p_instance_id => m_srl_rec.instance_id);
                  --
                  INSERT INTO csi_ii_forward_sync_temp(
                    instance_id,
                    serial_number,
                    inventory_item_id,
                    lot_control_code,
                    date_time_stamp,
                    mtl_txn_id,
                    mtl_txn_creation_date,
                    csi_txn_id,
                    contracts_flag,
                    process_flag,
                    error_message)
                  VALUES(
                    m_srl_rec.instance_id,
                    m_srl_rec.serial_number,
                    m_srl_rec.inventory_item_id,
                    m_srl_rec.lot_control_code,
                    sysdate,
                    l_p_mtl_txn_id,
                    l_p_mtl_creation_date,
                    l_p_csi_txn_id,
                    l_contracts_flag,
                    'N',
                    null);
              END;
            END IF;
          END IF;

          -- get the progressed marked serial and unmark them
          FOR p_lt_rec IN p_lt_cur(
            p_serial_number     => m_srl_rec.serial_number,
            p_item_id           => m_srl_rec.inventory_item_id,
            p_mtl_creation_date => m_rec.mtl_creation_date)
          LOOP

            UPDATE csi_diagnostics_temp
            SET    process_flag = 'R',
                   temporary_message = 'unmarking the serial to be processed after entanglement.'
            WHERE  diag_seq_id  = p_lt_rec.diag_seq_id;

          END LOOP;

          -- put the code here to create csi_transaction
          FOR missing_csi_rec IN missing_csi_cur(
            p_serial_number     => m_srl_rec.serial_number,
            p_item_id           => m_srl_rec.inventory_item_id,
            p_mtl_creation_date => m_rec.mtl_creation_date)
          LOOP

            IF missing_csi_rec.csi_txn_id is not null THEN
              exit;
            END IF;

            BEGIN
              SELECT transaction_id INTO l_txn_rec.transaction_id
              FROM   csi_transactions
              WHERE  inv_material_transaction_id = missing_csi_rec.mtl_txn_id;
            EXCEPTION
              WHEN no_data_found THEN

                l_txn_rec.transaction_id                := fnd_api.g_miss_num;
                l_txn_rec.transaction_type_id           := correction_txn_type_id;
                l_txn_rec.source_header_ref             := 'DATAFIX';
                l_txn_rec.source_line_ref               := 'TXNPUMP FOR PROGRESSED';
                l_txn_rec.source_transaction_date       := missing_csi_rec.mtl_txn_date;
                l_txn_rec.transaction_date              := sysdate;
                l_txn_rec.inv_material_transaction_id   := missing_csi_rec.mtl_txn_id;

                csi_transactions_pvt.create_transaction (
                  p_api_version             => 1.0,
                  p_commit                  => fnd_api.g_false,
                  p_init_msg_list           => fnd_api.g_true,
                  p_validation_level        => fnd_api.g_valid_level_full,
                  p_success_if_exists_flag  => 'Y',
                  p_transaction_rec         => l_txn_rec,
                  x_return_status           => l_return_status,
                  x_msg_count               => l_msg_count,
                  x_msg_data                => l_msg_data  );

                UPDATE csi_diagnostics_temp
                SET    csi_txn_id  = l_txn_rec.transaction_id,
                       error_flag  = 'P'
                WHERE  diag_seq_id = missing_csi_rec.diag_seq_id;

              WHEN too_many_rows THEN null;
            END;

          END LOOP;

        END LOOP;

      EXCEPTION
        WHEN skip_txn THEN
          null;
      END;
    END LOOP;
    x_progressed := l_progressed;
  END identify_progressed;

  PROCEDURE preprocess_srldata is

    TYPE NumTabType is    varray(10000) of number;
    TYPE VarTabType is    varray(10000) of varchar2(80);

    l_serial_number_tab   VarTabType;
    l_item_id_tab         NumTabType;

    MAX_BUFFER_SIZE       number := 1000;

    CURSOR diag_srl_cur IS
      SELECT serial_number,
             inventory_item_id
      FROM   csi_diagnostics_temp
      GROUP BY serial_number, inventory_item_id;

    CURSOR diag_txn_cur(p_serial_number IN varchar2, p_item_id IN number) IS
      SELECT diag_seq_id,
             serial_number,
             inventory_item_id,
             organization_id,
             mtl_txn_id,
             mtl_txn_qty,
             mtl_creation_date,
             serial_control_code,
             lot_control_code,
             revision_control_code,
             csi_txn_id,
             instance_id,
             create_flag,
             source_type,
             error_flag ,
             mtl_item_revision
      FROM   csi_diagnostics_temp
      WHERE  serial_number      = p_serial_number
      AND    inventory_item_id  = p_item_id
      ORDER by mtl_creation_date desc, mtl_txn_id desc;

    l_freeze_date         date;

    l_diag_txn_tbl        diag_txn_tbl;
    l_d_ind               binary_integer := 0;

    l_diag_txn_x_tbl      diag_txn_tbl;
    l_dx_ind              binary_integer := 0;

    l_txn_success         boolean;
    l_progressed          boolean := FALSE;
    l_seq_value           number;

  BEGIN

    init_diag_temp;

    log(date_time_stamp||'  begin preprocess_srldata');

    OPEN diag_srl_cur;
    LOOP

      FETCH diag_srl_cur BULK COLLECT
      INTO  l_serial_number_tab,
            l_item_id_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_serial_number_tab.COUNT
      LOOP

        l_diag_txn_tbl.delete;
        l_diag_txn_x_tbl.delete;

        l_d_ind  := 0;
        l_dx_ind := 0;

        l_txn_success := FALSE;

        FOR diag_txn_rec IN diag_txn_cur(
          p_serial_number => l_serial_number_tab(ind),
          p_item_id       => l_item_id_tab(ind))
        LOOP

          IF diag_txn_rec.csi_txn_id IS not null THEN
            l_txn_success := TRUE;
          END IF;

          IF NOT(l_txn_success) THEN

            l_d_ind := l_d_ind + 1;

            l_diag_txn_tbl(l_d_ind).diag_seq_id   := diag_txn_rec.diag_seq_id;
            l_diag_txn_tbl(l_d_ind).serial_number := diag_txn_rec.serial_number;
            l_diag_txn_tbl(l_d_ind).item_id       := diag_txn_rec.inventory_item_id;
            l_diag_txn_tbl(l_d_ind).organization_id := diag_txn_rec.organization_id;
            l_diag_txn_tbl(l_d_ind).mtl_txn_id    := diag_txn_rec.mtl_txn_id;
            l_diag_txn_tbl(l_d_ind).mtl_txn_qty   := diag_txn_rec.mtl_txn_qty;
            l_diag_txn_tbl(l_d_ind).mtl_creation_date := diag_txn_rec.mtl_creation_date;
            l_diag_txn_tbl(l_d_ind).serial_code   := diag_txn_rec.serial_control_code;
            l_diag_txn_tbl(l_d_ind).lot_code      := diag_txn_rec.lot_control_code;
            l_diag_txn_tbl(l_d_ind).revision_code := diag_txn_rec.revision_control_code;
            l_diag_txn_tbl(l_d_ind).inst_id       := diag_txn_rec.instance_id;
            l_diag_txn_tbl(l_d_ind).create_flag   := diag_txn_rec.create_flag;
            l_diag_txn_tbl(l_d_ind).source_type   := diag_txn_rec.source_type;
            l_diag_txn_tbl(l_d_ind).error_flag    := diag_txn_rec.error_flag;
            l_diag_txn_tbl(l_d_ind).marked_flag   := 'N';
            l_diag_txn_tbl(l_d_ind).process_flag  := 'N';
            l_diag_txn_tbl(l_d_ind).temp_message  := null;

          ELSE

            l_dx_ind := l_dx_ind + 1;

            l_diag_txn_x_tbl(l_dx_ind).diag_seq_id   := diag_txn_rec.diag_seq_id;
            l_diag_txn_x_tbl(l_dx_ind).serial_number := diag_txn_rec.serial_number;
            l_diag_txn_x_tbl(l_dx_ind).item_id       := diag_txn_rec.inventory_item_id;
            l_diag_txn_x_tbl(l_dx_ind).organization_id := diag_txn_rec.organization_id;
            l_diag_txn_x_tbl(l_dx_ind).mtl_txn_id    := diag_txn_rec.mtl_txn_id;
            l_diag_txn_x_tbl(l_dx_ind).mtl_txn_qty   := diag_txn_rec.mtl_txn_qty;
            l_diag_txn_x_tbl(l_dx_ind).mtl_creation_date := diag_txn_rec.mtl_creation_date;
            l_diag_txn_x_tbl(l_dx_ind).serial_code   := diag_txn_rec.serial_control_code;
            l_diag_txn_x_tbl(l_dx_ind).lot_code      := diag_txn_rec.lot_control_code;
            l_diag_txn_x_tbl(l_dx_ind).revision_code := diag_txn_rec.revision_control_code;
            l_diag_txn_x_tbl(l_dx_ind).inst_id       := diag_txn_rec.instance_id;
            l_diag_txn_x_tbl(l_dx_ind).create_flag   := diag_txn_rec.create_flag;
            l_diag_txn_x_tbl(l_dx_ind).source_type   := diag_txn_rec.source_type;
            l_diag_txn_x_tbl(l_dx_ind).error_flag    := diag_txn_rec.error_flag;
            l_diag_txn_x_tbl(l_dx_ind).marked_flag   := 'N';
            l_diag_txn_x_tbl(l_dx_ind).process_flag  := 'N';
            l_diag_txn_x_tbl(l_dx_ind).temp_message  := null;

          END IF;
        END LOOP;

        log('  '||l_serial_number_tab(ind)||
            ' P Count:'||l_diag_txn_tbl.COUNT||
            ' X Count:'||l_diag_txn_x_tbl.COUNT);

        IF l_diag_txn_tbl.COUNT > 0 THEN
          preprocess_all(
            p_diag_txn_tbl => l_diag_txn_tbl);
        END IF;

        IF l_diag_txn_x_tbl.COUNT > 0 THEN
          knock_all(
            p_diag_txn_tbl => l_diag_txn_x_tbl);
        END IF;

        IF mod(l_serial_number_tab.COUNT, 100) = 0 THEN
          commit;
        END IF;

      END LOOP;

      EXIT when diag_srl_cur%NOTFOUND;

    END LOOP;

    IF diag_srl_cur%ISOPEN THEN
      CLOSE diag_srl_cur;
    END IF;

    commit;

    identify_progressed(
      x_progressed => l_progressed);

    IF l_progressed THEN
      SELECT csi_ii_forward_sync_temp_s.nextval
      INTO   l_seq_value
      FROM   sys.dual;
    END IF;

    commit;

    log(date_time_stamp||'  end preprocess_srldata');
  END preprocess_srldata;

  FUNCTION fill(
    p_column in varchar2,
    p_width  in number,
    p_side   in varchar2 default 'R')
  RETURN varchar2 IS
    l_column varchar2(2000);
  BEGIN
    l_column := nvl(p_column, ' ');
    IF p_side = 'L' THEN
      return(lpad(l_column, p_width, ' '));
    ELSIF p_side = 'R' THEN
      return(rpad(l_column, p_width, ' '));
    END IF;
  END fill;

  --
  PROCEDURE report_header
  is
    l_header        varchar2(4000);
  BEGIN
    l_header := fill('SerialNumber', 15)||
                fill('Item/Org(M/I/V)', 20)||
                fill('InstID', 10)||
                fill('InstLoc', 15)||
                fill('Usage', 15)||
                fill('ISubinv', 14)||
                fill('Pty/Acct', 10)||
                fill('M', 1);

    out(l_header);

    l_header := fill('------------', 15)||
                fill('---------------', 20)||
                fill('------', 10)||
                fill('-------', 15)||
                fill('-----', 15)||
                fill('-------', 14)||
                fill('--------', 10)||
                fill('-', 1);

    out(l_header);

    l_header := fill(' ', 2)||
                fill('TxnName', 22)||
                fill('TxnID', 9)||
                fill('TxnDate', 11)||
                fill('CsiTxnID', 9)||
                fill('Code', 8)||
                fill('P', 2);

    out(l_header);

    l_header := fill(' ', 2)||
                fill('-------', 22)||
                fill('-----', 9)||
                fill('-------', 13)||
                fill('--------', 9)||
                fill('----', 8)||
                fill('-', 2);

    out(l_header);

  END report_header;

  PROCEDURE report_body(
    p_rec            in     csi_diagnostics_temp%rowtype,
    px_serial_number in out nocopy varchar2,
    px_item_id       in out nocopy number)
  is
    l_mtl_txn_date  date;
    l_srl_data      varchar2(4000);
    l_txn_data      varchar2(4000);
  BEGIN

    IF (p_rec.serial_number <> px_serial_number
        OR
        p_rec.inventory_item_id <> px_item_id)
    THEN

      out(' ');

      -- print header;
      l_srl_data := fill(p_rec.serial_number, 15)||
                    fill(to_char(p_rec.inventory_item_id)||'/'||
                         to_char(p_rec.organization_id)||'/'||
                         nvl(to_char(p_rec.instance_organization_id), ' ')||'/'||
                         nvl(to_char(p_rec.instance_vld_organization_id), ' '), 20)||
                    fill(p_rec.instance_id, 10)||
                    fill(p_rec.instance_location, 15)||
                    fill(p_rec.instance_usage_code, 15)||
                    fill(p_rec.instance_subinv_name, 14)||
                    fill(nvl(to_char(p_rec.instance_owner_party_id), ' ')||'/'||
                         nvl(to_char(p_rec.instance_owner_account_id), ' '), 10)||
                    fill(nvl(p_rec.instance_mig_flag,'N'), 1);

      out(l_srl_data);

    END IF;

    l_txn_data := fill(' ', 2)||
                  fill(p_rec.mtl_txn_name, 22)||
                  fill(p_rec.mtl_txn_id, 9)||
                  fill(to_char(p_rec.mtl_txn_date, 'ddmmyyhh24miss'), 13)||
                  fill(p_rec.csi_txn_id, 9)||
                  fill(p_rec.process_code, 8)||
                  fill(p_rec.process_flag, 2);

    out(l_txn_data);

    IF p_rec.error_flag = 'E' THEN
      out('    '||rtrim(fill(p_rec.error_text, 96)));
    END IF;

    IF p_rec.process_flag = 'E' THEN
      out('    '||rtrim(fill(p_rec.temporary_message, 96)));
    END IF;

    px_serial_number := p_rec.serial_number;
    px_item_id       := p_rec.inventory_item_id;

  END report_body;

  PROCEDURE spool_srldata(p_mode in varchar2 default 'ALL' ) is

    CURSOR dump_all_cur is
      SELECT *
      FROM csi_diagnostics_temp
      ORDER BY serial_number, inventory_item_id, mtl_creation_date desc, mtl_txn_id desc;

    CURSOR dump_fixable_cur is
      SELECT * FROM csi_diagnostics_temp A
      WHERE exists (
        SELECT 'X' FROM csi_diagnostics_temp B
        WHERE  B.serial_number = A.serial_number
        AND    B.inventory_item_id = A.inventory_item_id
        AND    B.process_flag in ('M', 'X', 'R'))
      ORDER BY A.serial_number, a.inventory_item_id, a.mtl_creation_date desc, a.mtl_txn_id desc;

    CURSOR dump_nonfixable_cur is
      SELECT * FROM csi_diagnostics_temp A
      WHERE not exists (
        SELECT 'X' FROM csi_diagnostics_temp B
        WHERE  B.serial_number = A.serial_number
        AND    B.inventory_item_id = A.inventory_item_id
        AND    B.process_flag in ('M', 'X', 'R'))
      ORDER BY A.serial_number, a.inventory_item_id, a.mtl_creation_date desc, a.mtl_txn_id desc;

    CURSOR dump_errors_cur is
      SELECT * FROM csi_diagnostics_temp A
      WHERE exists (
        SELECT 'X' FROM csi_diagnostics_temp B
        WHERE  B.serial_number = A.serial_number
        AND    B.inventory_item_id = A.inventory_item_id
        AND    B.process_flag = 'E')
      ORDER BY A.serial_number, a.inventory_item_id, a.mtl_creation_date desc, a.mtl_txn_id desc;

    l_old_serial    varchar2(80)  := '##**$$**##';
    l_old_item_id   number        := -.9999999999;

  BEGIN

    IF p_mode = 'ALL' THEN

      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csisrl',
        p_file_segment2 => to_char(sysdate, 'hh24miss'));

      out(' *****************************************************************************');
      out('                Serialized error correction -  breakup report                 ');
      out(' *****************************************************************************');

      report_header;

      FOR dump_rec in dump_all_cur
      LOOP
        report_body (
          p_rec            => dump_rec,
          px_serial_number => l_old_serial,
          px_item_id       => l_old_item_id);
      END LOOP;

    ELSIF p_mode = 'FIXABLE' THEN

      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csisrlfix',
        p_file_segment2 => to_char(sysdate, 'hh24miss'));

      report_header;

      FOR dump_rec in dump_fixable_cur
      LOOP
        report_body (
          p_rec            => dump_rec,
          px_serial_number => l_old_serial,
          px_item_id       => l_old_item_id);
      END LOOP;

    ELSIF p_mode = 'NONFIXABLE' THEN

      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csisrlnofix',
        p_file_segment2 => to_char(sysdate, 'hh24miss'));

      report_header;

      FOR dump_rec in dump_nonfixable_cur
      LOOP
        report_body (
          p_rec            => dump_rec,
          px_serial_number => l_old_serial,
          px_item_id       => l_old_item_id);
      END LOOP;

    ELSIF p_mode = 'ERRORS' THEN

      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csisrlerr',
        p_file_segment2 => to_char(sysdate, 'hh24miss'));

      out(' *****************************************************************************');
      out('               Errors reported in serialized error correction                 ');
      out(' *****************************************************************************');

      report_header;

      FOR dump_rec in dump_errors_cur
      LOOP
        report_body (
          p_rec            => dump_rec,
          px_serial_number => l_old_serial,
          px_item_id       => l_old_item_id);
      END LOOP;


    END IF;

  END spool_srldata;

  PROCEDURE dump_diff(
    p_instance_rec      in csi_datastructures_pub.instance_rec)
  IS

    l_vld_organization_id    number;
    l_inv_organization_id    number;
    l_inv_subinventory_name  varchar2(30);
    l_inventory_revision     varchar2(8);
    l_inv_locator_id         number;
    l_location_type_code     varchar(30);
    l_instance_usage_code    varchar(30);
    l_location_id            number;

  BEGIN
    SELECT last_vld_organization_id,
           inv_organization_id,
           inv_subinventory_name,
           inventory_revision,
           inv_locator_id,
           location_type_code,
           instance_usage_code,
           location_id
    INTO   l_vld_organization_id,
           l_inv_organization_id,
           l_inv_subinventory_name,
           l_inventory_revision,
           l_inv_locator_id,
           l_location_type_code,
           l_instance_usage_code,
           l_location_id
    FROM csi_item_instances
    WHERE instance_id = p_instance_rec.instance_id;

    out('  Instance: '||
        fill(l_location_type_code, 15)||
        fill(to_char(l_location_id), 6)||
        fill(l_instance_usage_code, 15)||
        fill(to_char(l_vld_organization_id),5)||
        fill(to_char(l_inv_organization_id),5)||
        fill(l_inv_subinventory_name,15)||
        fill(l_inventory_revision,5)||
        fill(to_char(l_inv_locator_id), 6));

    out('  Serial  : '||
        fill(p_instance_rec.location_type_code, 15)||
        fill(to_char(p_instance_rec.location_id), 6)||
        fill(p_instance_rec.instance_usage_code, 15)||
        fill(to_char(p_instance_rec.vld_organization_id),5)||
        fill(to_char(p_instance_rec.inv_organization_id),5)||
        fill(p_instance_rec.inv_subinventory_name,15)||
        fill(p_instance_rec.inventory_revision,5)||
        fill(to_char(p_instance_rec.inv_locator_id), 6));

  END dump_diff;

  FUNCTION not_the_same(
    p_instance_rec      in csi_datastructures_pub.instance_rec)
  RETURN boolean
  IS

    l_not_the_same    boolean := TRUE;

    l_vld_organization_id    number;
    l_inv_organization_id    number;
    l_inv_subinventory_name  varchar2(30);
    l_inventory_revision     varchar2(8);
    l_inv_locator_id         number;
    l_location_type_code     varchar(30);
    l_instance_usage_code    varchar(30);
    l_lot_number             varchar2(80);
    l_location_id            number;

    l_pa_project_id          number;
    l_pa_project_task_id     number;
    l_accounting_class_code  varchar2(30);

    l_wip_job_id             number;

    l_in_transit_order_line_id number;

  BEGIN

    SELECT last_vld_organization_id,
           inv_organization_id,
           inv_subinventory_name,
           inventory_revision,
           inv_locator_id,
           location_type_code,
           instance_usage_code,
           location_id,
           lot_number,
           pa_project_id,
           pa_project_task_id,
           accounting_class_code,
           wip_job_id,
           in_transit_order_line_id
    INTO   l_vld_organization_id,
           l_inv_organization_id,
           l_inv_subinventory_name,
           l_inventory_revision,
           l_inv_locator_id,
           l_location_type_code,
           l_instance_usage_code,
           l_location_id,
           l_lot_number,
           l_pa_project_id,
           l_pa_project_task_id,
           l_accounting_class_code,
           l_wip_job_id,
           l_in_transit_order_line_id
    FROM csi_item_instances
    WHERE instance_id = p_instance_rec.instance_id;

    IF p_instance_rec.location_type_code = 'INVENTORY' THEN

      IF (nvl(p_instance_rec.vld_organization_id, fnd_api.g_miss_num) =
          nvl(l_vld_organization_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.inv_organization_id,fnd_api.g_miss_num) =
          nvl(l_inv_organization_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.inv_subinventory_name, fnd_api.g_miss_char) =
          nvl(l_inv_subinventory_name, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inventory_revision, fnd_api.g_miss_char) =
          nvl(l_inventory_revision, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inv_locator_id, fnd_api.g_miss_num) =
          nvl(l_inv_locator_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.location_type_code, fnd_api.g_miss_char) =
          nvl(l_location_type_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.location_id, fnd_api.g_miss_num) =
          nvl(l_location_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.instance_usage_code, fnd_api.g_miss_char) =
          nvl(l_instance_usage_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.lot_number, fnd_api.g_miss_char) =
          nvl(l_lot_number, fnd_api.g_miss_char))
      THEN
        l_not_the_same := FALSE;
      END IF;

    ELSIF p_instance_rec.location_type_code = 'PROJECT' THEN

      IF (nvl(p_instance_rec.accounting_class_code, fnd_api.g_miss_char) =
          nvl(l_accounting_class_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.location_type_code, fnd_api.g_miss_char) =
          nvl(l_location_type_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.location_id, fnd_api.g_miss_num) =
          nvl(l_location_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.pa_project_id, fnd_api.g_miss_num) =
          nvl(l_pa_project_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.pa_project_task_id, fnd_api.g_miss_num) =
          nvl(l_pa_project_task_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.instance_usage_code, fnd_api.g_miss_char) =
          nvl(l_instance_usage_code, fnd_api.g_miss_char))
      THEN
        l_not_the_same := FALSE;
      END IF;

    ELSIF p_instance_rec.location_type_code = 'WIP' THEN

      IF (nvl(p_instance_rec.location_type_code, fnd_api.g_miss_char) =
          nvl(l_location_type_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.location_id, fnd_api.g_miss_num) =
          nvl(l_location_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.instance_usage_code, fnd_api.g_miss_char) =
          nvl(l_instance_usage_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.lot_number, fnd_api.g_miss_char) =
          nvl(l_lot_number, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inv_organization_id, fnd_api.g_miss_num) =
          nvl(l_inv_organization_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.inv_subinventory_name, fnd_api.g_miss_char) =
          nvl(l_inv_subinventory_name, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inventory_revision, fnd_api.g_miss_char) =
          nvl(l_inventory_revision, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inv_locator_id, fnd_api.g_miss_num) =
          nvl(l_inv_locator_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.wip_job_id, fnd_api.g_miss_num) =
          nvl(l_wip_job_id, fnd_api.g_miss_num))
      THEN
        l_not_the_same := FALSE;
      END IF;

    ELSIF p_instance_rec.location_type_code = 'IN_TRANSIT' THEN

      IF (nvl(p_instance_rec.location_type_code, fnd_api.g_miss_char) =
          nvl(l_location_type_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.location_id, fnd_api.g_miss_num) =
          nvl(l_location_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.instance_usage_code, fnd_api.g_miss_char) =
          nvl(l_instance_usage_code, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.lot_number, fnd_api.g_miss_char) =
          nvl(l_lot_number, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inv_organization_id, fnd_api.g_miss_num) =
          nvl(l_inv_organization_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.inv_subinventory_name, fnd_api.g_miss_char) =
          nvl(l_inv_subinventory_name, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inventory_revision, fnd_api.g_miss_char) =
          nvl(l_inventory_revision, fnd_api.g_miss_char))
          AND
         (nvl(p_instance_rec.inv_locator_id, fnd_api.g_miss_num) =
          nvl(l_inv_locator_id, fnd_api.g_miss_num))
          AND
         (nvl(p_instance_rec.in_transit_order_line_id, fnd_api.g_miss_num) =
          nvl(l_in_transit_order_line_id, fnd_api.g_miss_num))
      THEN
        l_not_the_same := FALSE;
      END IF;

    END IF;

    return l_not_the_same;

  END not_the_same;

  PROCEDURE init_plsql_tables(
    px_instance_rec  in out nocopy csi_datastructures_pub.instance_rec,
    px_parties_tbl   in out nocopy csi_datastructures_pub.party_tbl,
    px_pty_accts_tbl in out nocopy csi_datastructures_pub.party_account_tbl,
    px_org_units_tbl in out nocopy csi_datastructures_pub.organization_units_tbl,
    px_ea_values_tbl in out nocopy csi_datastructures_pub.extend_attrib_values_tbl,
    px_pricing_tbl   in out nocopy csi_datastructures_pub.pricing_attribs_tbl,
    px_assets_tbl    in out nocopy csi_datastructures_pub.instance_asset_tbl)
  is
    l_instance_rec   csi_datastructures_pub.instance_rec;

  BEGIN
    px_instance_rec  := l_instance_rec;
    px_parties_tbl.delete;
    px_pty_accts_tbl.delete;
    px_org_units_tbl.delete;
    px_ea_values_tbl.delete;
    px_pricing_tbl.delete;
    px_assets_tbl.delete;
  END init_plsql_tables;

  PROCEDURE knock_the_rest IS
    CURSOR knock_cur is
      SELECT mtl_txn_id,
             mtl_src_type_id,
             mtl_txn_date
      FROM   csi_diagnostics_temp
      WHERE  process_flag = 'X';

    l_txn_rec         csi_datastructures_pub.transaction_rec;
    l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  BEGIN
    FOR knock_rec in knock_cur
    LOOP
      UPDATE csi_txn_errors
      SET    processed_flag   = 'D',
             error_text       = 'A future transaction is processed. So not processing this.',
             last_update_date = sysdate,
             last_update_login = fnd_global.login_id,
             last_updated_by   = fnd_global.user_id
      WHERE  inv_material_transaction_id = knock_rec.mtl_txn_id
      AND    processed_flag in ('E', 'R');

      BEGIN
        SELECT transaction_id INTO l_txn_rec.transaction_id
        FROM   csi_transactions
        WHERE  inv_material_transaction_id = knock_rec.mtl_txn_id;
      EXCEPTION
        WHEN no_data_found THEN

          l_txn_rec.transaction_id              := fnd_api.g_miss_num;
          l_txn_rec.transaction_type_id         := correction_txn_type_id;
          l_txn_rec.source_header_ref           := 'DATAFIX';
          l_txn_rec.source_line_ref             := 'FUTURE TXN IS PROCESSED';
          l_txn_rec.source_transaction_date     := knock_rec.mtl_txn_date;
          l_txn_rec.transaction_date            := sysdate;
          l_txn_rec.inv_material_transaction_id := knock_rec.mtl_txn_id;

          csi_transactions_pvt.create_transaction (
            p_api_version             => 1.0,
            p_commit                  => fnd_api.g_false,
            p_init_msg_list           => fnd_api.g_true,
            p_validation_level        => fnd_api.g_valid_level_full,
            p_success_if_exists_flag  => 'Y',
            p_transaction_rec         => l_txn_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data);

      WHEN too_many_rows THEN
        null;
      END;

    END LOOP;
  END knock_the_rest;

  PROCEDURE create_instance(
    p_txn_rec        IN  csi_datastructures_pub.transaction_rec,
    p_instance_rec   IN  csi_datastructures_pub.instance_rec,
    p_parties_tbl    IN  csi_datastructures_pub.party_tbl,
    p_pty_accts_tbl  IN  csi_datastructures_pub.party_account_tbl,
    x_return_status  OUT nocopy varchar2,
    x_error_message  OUT nocopy varchar2)
  IS

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl          csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl           csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list    csi_datastructures_pub.id_tbl;
    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_error_message        varchar2(2000);
    l_msg_data             varchar2(2000);
    l_msg_count            number;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_txn_rec       := p_txn_rec;
    l_instance_rec  := p_instance_rec;
    l_parties_tbl   := p_parties_tbl;
    l_pty_accts_tbl := p_pty_accts_tbl;

    savepoint create_instance;

    csi_transactions_pvt.create_transaction (
      p_api_version             => 1.0,
      p_commit                  => fnd_api.g_false,
      p_init_msg_list           => fnd_api.g_true,
      p_validation_level        => fnd_api.g_valid_level_full,
      p_success_if_exists_flag  => 'Y',
      p_transaction_rec         => l_txn_rec,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data  );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    l_instance_rec.mfg_serial_number_flag := 'Y';

    IF l_instance_rec.location_type_code = 'INVENTORY'
       AND
       l_instance_rec.instance_usage_code = 'IN_INVENTORY'
    THEN
      SELECT nvl(mssi.location_id, haou.location_id)
      INTO   l_instance_rec.location_id
      FROM   mtl_secondary_inventories mssi,
             hr_all_organization_units haou
      WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
      AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
      AND    haou.organization_id          = mssi.organization_id;
    ELSIF l_instance_rec.location_type_code = 'WIP' THEN
      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
        csi_gen_utility_pvt.populate_install_param_rec;
      END IF;
      --
      l_instance_rec.location_id := csi_datastructures_pub.g_install_param_rec.wip_location_id;
    END IF;

    SELECT primary_uom_code
    INTO   l_instance_rec.unit_of_measure
    FROM   mtl_system_items
    WHERE  inventory_item_id = l_instance_rec.inventory_item_id
    AND    organization_id   = l_instance_rec.vld_organization_id;

    csi_item_instance_pub.create_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_instance_rec,
      p_party_tbl             => l_parties_tbl,
      p_account_tbl           => l_pty_accts_tbl,
      p_org_assignments_tbl   => l_org_units_tbl,
      p_ext_attrib_values_tbl => l_ea_values_tbl,
      p_pricing_attrib_tbl    => l_pricing_tbl,
      p_asset_assignment_tbl  => l_assets_tbl,
      p_txn_rec               => l_txn_rec,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data );

    l_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
    log('    create status :'||l_return_status||' '||l_msg_data);

    -- For Bug 4057183
    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      raise fnd_api.g_exc_error;
    END IF;

    IF nvl(l_txn_rec.transaction_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      UPDATE csi_transactions
      SET    inv_material_transaction_id = null
      WHERE  transaction_id              = l_txn_rec.transaction_id;
    END IF;

    commit;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to create_instance;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := csi_t_gen_utility_pvt.dump_error_stack;
  END create_instance;

  PROCEDURE update_instance(
    p_txn_rec        IN  csi_datastructures_pub.transaction_rec,
    p_instance_rec   IN  csi_datastructures_pub.instance_rec,
    p_parties_tbl    IN  csi_datastructures_pub.party_tbl,
    p_pty_accts_tbl  IN  csi_datastructures_pub.party_account_tbl,
    x_return_status  OUT nocopy varchar2,
    x_error_message  OUT nocopy varchar2)
  IS

    l_not_the_same         boolean := TRUE;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl          csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl           csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list    csi_datastructures_pub.id_tbl;
    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_error_message        varchar2(2000);
    l_msg_data             varchar2(2000);
    l_msg_count            number;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_txn_rec       := p_txn_rec;
    l_instance_rec  := p_instance_rec;
    l_parties_tbl   := p_parties_tbl;
    l_pty_accts_tbl := p_pty_accts_tbl;

    IF l_instance_rec.location_type_code = 'INVENTORY'
       AND
       l_instance_rec.instance_usage_code = 'IN_INVENTORY'
    THEN

      SELECT nvl(mssi.location_id, haou.location_id)
      INTO   l_instance_rec.location_id
      FROM   mtl_secondary_inventories mssi,
             hr_all_organization_units haou
      WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
      AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
      AND    haou.organization_id          = mssi.organization_id;

    END IF;

    IF l_instance_rec.location_type_code = 'WIP' THEN
      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
        csi_gen_utility_pvt.populate_install_param_rec;
      END IF;
      --
      l_instance_rec.location_id := csi_datastructures_pub.g_install_param_rec.wip_location_id;
    END IF;

    savepoint update_instance;

    l_not_the_same := not_the_same(l_instance_rec);

    IF l_not_the_same THEN

      log('    not the same');

      csi_transactions_pvt.create_transaction (
        p_api_version             => 1.0,
        p_commit                  => fnd_api.g_false,
        p_init_msg_list           => fnd_api.g_true,
        p_validation_level        => fnd_api.g_valid_level_full,
        p_success_if_exists_flag  => 'Y',
        p_transaction_rec         => l_txn_rec,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data  );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      UPDATE csi_item_instances
      SET    last_vld_organization_id = l_instance_rec.vld_organization_id,
             active_end_date          = null
      WHERE  instance_id = l_instance_rec.instance_id;

      csi_process_txn_pvt.check_and_break_relation(
        p_instance_id   => l_instance_rec.instance_id,
        p_csi_txn_rec   => l_txn_rec,
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      IF nvl(l_instance_rec.active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date THEN
        l_parties_tbl.delete;
        l_pty_accts_tbl.delete;
      END IF;

      IF l_parties_tbl.count > 0 THEN
        FOR lp_ind in l_parties_tbl.FIRST .. l_parties_tbl.LAST
        LOOP
          SELECT instance_party_id,
                 object_version_number
          INTO   l_parties_tbl(lp_ind).instance_party_id,
                 l_parties_tbl(lp_ind).object_version_number
          FROM   csi_i_parties
          WHERE  instance_id = l_instance_rec.instance_id
          AND    relationship_type_code = l_parties_tbl(lp_ind).relationship_type_code
          AND    rownum = 1;
        END LOOP;
      END IF;

      SELECT object_version_number
      INTO   l_instance_rec.object_version_number
      FROM   csi_item_instances
      WHERE  instance_id = l_instance_rec.instance_id;

      csi_item_instance_pub.update_item_instance(
        p_api_version           => 1.0,
        p_commit                => fnd_api.g_false,
        p_init_msg_list         => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_instance_rec          => l_instance_rec,
        p_party_tbl             => l_parties_tbl,
        p_account_tbl           => l_pty_accts_tbl,
        p_org_assignments_tbl   => l_org_units_tbl,
        p_ext_attrib_values_tbl => l_ea_values_tbl,
        p_pricing_attrib_tbl    => l_pricing_tbl,
        p_asset_assignment_tbl  => l_assets_tbl,
        p_txn_rec               => l_txn_rec,
        x_instance_id_lst       => l_instance_ids_list,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

      l_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
      log('    update status :'||l_return_status||' '||l_msg_data);

      -- For Bug 4057183
      -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
        raise fnd_api.g_exc_error;
      END IF;

      IF nvl(l_txn_rec.transaction_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        UPDATE csi_transactions
        SET    inv_material_transaction_id = null
        WHERE  transaction_id              = l_txn_rec.transaction_id;
      END IF;

    ELSE
      log('    the same');
      IF nvl(l_instance_rec.active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date THEN
        UPDATE csi_item_instances
        SET    active_end_date = l_instance_rec.active_end_date
        WHERE  instance_id     = l_instance_rec.instance_id;
      END IF;

      IF nvl(l_instance_rec.active_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
        UPDATE csi_item_instances
        SET    active_end_date = null
        WHERE  instance_id     = l_instance_rec.instance_id;
      END IF;
    END IF;

    commit;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to update_instance;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := csi_t_gen_utility_pvt.dump_error_stack;
  END update_instance;

  PROCEDURE fix_soiship(
    p_diag_txn_rec  IN diag_txn_rec,
    p_txn_rec       IN csi_datastructures_pub.transaction_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

    log('  '||p_diag_txn_rec.serial_number||
        '  '||p_diag_txn_rec.mtl_txn_id||
        '  '||p_diag_txn_rec.source_type||
        '  '||p_diag_txn_rec.process_code||
        '  '||p_diag_txn_rec.inst_id);

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec := p_txn_rec;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'INVENTORY';
      l_instance_rec.instance_usage_code      := 'RETURNED';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := inv_rec.organization_id;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
      l_instance_rec.inv_locator_id           := inv_rec.locator_id;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.object_version_number    := 1.0;

      SELECT nvl(mssi.location_id, haou.location_id)
      INTO   l_instance_rec.location_id
      FROM   mtl_secondary_inventories mssi,
             hr_all_organization_units haou
      WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
      AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
      AND    haou.organization_id          = mssi.organization_id;

      IF p_diag_txn_rec.expire_flag = 'Y' THEN
        l_instance_rec.active_end_date        := sysdate;
      END IF;

    END LOOP;

    IF p_diag_txn_rec.inst_id is not null THEN
      l_txn_rec.inv_material_transaction_id   := p_diag_txn_rec.mtl_txn_id;
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);

    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_soiship;

  PROCEDURE stage_soiship_instances
  IS

    CURSOR txn_cur is
      SELECT distinct mtl_txn_id ,
             inventory_item_id,
             organization_id
      FROM   csi_diagnostics_temp
      WHERE  process_flag = 'M'
      AND    process_code = 'SOISHIP';

    CURSOR returned_serial_cur(p_mtl_txn_id IN number) is
      SELECT cdt.diag_seq_id,
             cdt.process_code,
             cdt.mtl_txn_id,
             cdt.mtl_txn_date mtl_txn_date,
             cdt.serial_number,
             cdt.inventory_item_id,
             cdt.instance_id,
             cdt.csi_txn_id,
             cdt.csi_txn_type_id,
             cdt.wip_job_id,
             cdt.internal_party_id,
             nvl(cdt.create_flag, 'Y')  create_flag,
             nvl(cdt.expire_flag, 'N')  expire_flag,
             cdt.serial_control_code,
             cdt.lot_control_code
      FROM   csi_diagnostics_temp cdt
      WHERE  cdt.mtl_txn_id            = p_mtl_txn_id
      AND    cdt.process_flag          = 'M'
      AND    nvl(cdt.create_flag, 'Y') = 'N'; -- marked FOR processing

    CURSOR stage_cur(p_mtl_txn_id in number, p_lot_code in number) IS
      SELECT mmt.inventory_item_id      item_id,
             mmt.organization_id        organization_id,
             mmt.subinventory_code      subinv_code,
             mmt.locator_id             locator_id,
             mmt.revision               revision,
             to_char(null)              lot_number,
             abs(mmt.primary_quantity)  quantity,
             mmt.transaction_date       mtl_txn_date,
             mmt.transaction_id         mtl_txn_id,
             mmt.trx_source_line_id     trx_source_line_id
      FROM   mtl_material_transactions mmt
      WHERE  mmt.transaction_id = p_mtl_txn_id
      AND    p_lot_code = 1
      UNION
      SELECT mmt.inventory_item_id      item_id,
             mmt.organization_id        organization_id,
             mmt.subinventory_code      subinv_code,
             mmt.locator_id             locator_id,
             mmt.revision               revision,
             mtln.lot_number            lot_number,
             abs(mtln.primary_quantity) quantity,
             mmt.transaction_date       mtl_txn_date,
             mmt.transaction_id         mtl_txn_id,
             mmt.trx_source_line_id     trx_source_line_id
      FROM   mtl_material_transactions   mmt,
             mtl_transaction_lot_numbers mtln
      WHERE  mmt.transaction_id  = p_mtl_txn_id
      AND    mtln.transaction_id = mmt.transaction_id
      AND    p_lot_code <> 1;

    l_order_line_id         number;
    l_mtl_txn_date          date;

    l_serials_fixed         boolean;
    l_lot_code              number;
    l_uom_code              varchar2(10);

    l_instance_id           number;
    l_quantity              number;
    l_object_version_number number;

    l_internal_party_id    number;
    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl          csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl           csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list    csi_datastructures_pub.id_tbl;
    l_txn_rec              csi_datastructures_pub.transaction_rec;
    l_diag_txn_rec         diag_txn_rec;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

    l_error_message        varchar2(2000);
    srl_upd_error          exception;

  BEGIN

    log(date_time_stamp||'  begin stage_soiship_instances');

    FOR txn_rec IN txn_cur
    LOOP

      SELECT transaction_date,
             trx_source_line_id
      INTO   l_mtl_txn_date,
             l_order_line_id
      FROM   mtl_material_transactions
      WHERE  transaction_id = txn_rec.mtl_txn_id;

      l_txn_rec.transaction_id              := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id         := correction_txn_type_id;
      l_txn_rec.source_header_ref           := 'DATAFIX';
      l_txn_rec.source_line_ref             := 'SOISHIP';
      l_txn_rec.source_line_ref_id          := l_order_line_id;
      l_txn_rec.source_transaction_date     := l_mtl_txn_date;
      l_txn_rec.transaction_date            := l_mtl_txn_date;

      l_serials_fixed := TRUE;

      -- first fix all the serial numbers as returned
      FOR returned_serial_rec IN returned_serial_cur(txn_rec.mtl_txn_id)
      LOOP

        l_internal_party_id := returned_serial_rec.internal_party_id;

        l_diag_txn_rec.diag_seq_id     := returned_serial_rec.diag_seq_id;
        l_diag_txn_rec.process_code    := returned_serial_rec.process_code;
        l_diag_txn_rec.mtl_txn_id      := returned_serial_rec.mtl_txn_id;
        l_diag_txn_rec.mtl_txn_date    := returned_serial_rec.mtl_txn_date;
        l_diag_txn_rec.serial_number   := returned_serial_rec.serial_number;
        l_diag_txn_rec.item_id         := returned_serial_rec.inventory_item_id;
        l_diag_txn_rec.inst_id         := returned_serial_rec.instance_id;
        l_diag_txn_rec.csi_txn_id      := returned_serial_rec.csi_txn_id;
        l_diag_txn_rec.csi_txn_type_id := returned_serial_rec.csi_txn_type_id;
        l_diag_txn_rec.wip_job_id      := returned_serial_rec.wip_job_id;
        l_diag_txn_rec.create_flag     := returned_serial_rec.create_flag;
        l_diag_txn_rec.expire_flag     := returned_serial_rec.expire_flag;
        l_diag_txn_rec.serial_code     := returned_serial_rec.serial_control_code;
        l_diag_txn_rec.lot_code        := returned_serial_rec.lot_control_code;

        savepoint soiship_srl_upd;

        fix_soiship(
          p_diag_txn_rec  => l_diag_txn_rec,
          p_txn_rec       => l_txn_rec,
          x_return_status => l_return_status,
          x_error_message => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          l_serials_fixed := FALSE;
          rollback to soiship_srl_upd;

          UPDATE csi_diagnostics_temp
          SET    process_flag  = 'E',
                 temporary_message  = l_error_message
          WHERE  diag_seq_id   = returned_serial_rec.diag_seq_id;

        END IF;

        commit;

      END LOOP;

      IF l_serials_fixed THEN

        SELECT lot_control_code,
               primary_uom_code
        INTO   l_lot_code,
               l_uom_code
        FROM   mtl_system_items
        WHERE  inventory_item_id = txn_rec.inventory_item_id
        AND    organization_id   = txn_rec.organization_id;

        FOR stage_rec IN stage_cur (txn_rec.mtl_txn_id, l_lot_code)
        LOOP

          savepoint stage_soiship_instances;

          BEGIN

            init_plsql_tables(
              px_instance_rec  => l_instance_rec,
              px_parties_tbl   => l_parties_tbl,
              px_pty_accts_tbl => l_pty_accts_tbl,
              px_org_units_tbl => l_org_units_tbl,
              px_ea_values_tbl => l_ea_values_tbl,
              px_pricing_tbl   => l_pricing_tbl,
              px_assets_tbl    => l_assets_tbl);

            BEGIN

              SELECT instance_id,
                     quantity,
                     object_version_number
              INTO   l_instance_id,
                     l_quantity,
                     l_object_version_number
              FROM   csi_item_instances
              WHERE  location_type_code               = 'INVENTORY'
              AND    instance_usage_code              = 'IN_INVENTORY'
              AND    inventory_item_id                = stage_rec.item_id
              AND    inv_organization_id              = stage_rec.organization_id
              AND    inv_subinventory_name            = stage_rec.subinv_code
              AND    nvl(inv_locator_id,-9999)        = nvl(stage_rec.locator_id,-9999)
              AND    nvl(lot_number,'$$##$$')         = nvl(stage_rec.lot_number,'$$##$$')
              AND    nvl(inventory_revision,'$$##$$') = nvl(stage_rec.revision,'$$##$$')
              AND    serial_number is null;

            EXCEPTION
              WHEN no_data_found THEN
                l_instance_id := fnd_api.g_miss_num;
              WHEN too_many_rows THEN
                stack_message('Too many inventory instances for this non srl item.');
                raise fnd_api.g_exc_error;
            END;

            IF nvl(l_instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

              l_instance_rec.instance_id           := l_instance_id;
              l_instance_rec.quantity              := l_quantity + stage_rec.quantity;
              l_instance_rec.object_version_number := l_object_version_number;
              l_instance_rec.active_end_date       := null;
              l_instance_rec.instance_status_id    := 3;

              csi_item_instance_pub.update_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_instance_rec,
                p_party_tbl             => l_parties_tbl,
                p_account_tbl           => l_pty_accts_tbl,
                p_org_assignments_tbl   => l_org_units_tbl,
                p_ext_attrib_values_tbl => l_ea_values_tbl,
                p_pricing_attrib_tbl    => l_pricing_tbl,
                p_asset_assignment_tbl  => l_assets_tbl,
                p_txn_rec               => l_txn_rec,
                x_instance_id_lst       => l_instance_ids_list,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

              -- For Bug 4057183
              -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                raise fnd_api.g_exc_error;
              END IF;

            ELSE

              l_instance_rec.instance_id              := fnd_api.g_miss_num;
              l_instance_rec.location_type_code       := 'INVENTORY';
              l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
              l_instance_rec.inventory_item_id        := stage_rec.item_id;
              l_instance_rec.inv_organization_id      := stage_rec.organization_id;
              l_instance_rec.quantity                 := stage_rec.quantity;
              l_instance_rec.unit_of_measure          := l_uom_code;
              l_instance_rec.inv_subinventory_name    := stage_rec.subinv_code;
              l_instance_rec.inv_locator_id           := stage_rec.locator_id;
              l_instance_rec.lot_number               := stage_rec.lot_number;
              l_instance_rec.inventory_revision       := stage_rec.revision;
              l_instance_rec.vld_organization_id      := stage_rec.organization_id;
              l_instance_rec.object_version_number    := 1.0;

              SELECT nvl(mssi.location_id, haou.location_id)
              INTO   l_instance_rec.location_id
              FROM   mtl_secondary_inventories mssi,
                     hr_all_organization_units haou
              WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
              AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
              AND    haou.organization_id          = mssi.organization_id;

              l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
              l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
              l_parties_tbl(1).party_id               := l_internal_party_id;
              l_parties_tbl(1).relationship_type_code := 'OWNER';
              l_parties_tbl(1).contact_flag           := 'N';
              l_parties_tbl(1).object_version_number  := 1.0;

              csi_item_instance_pub.create_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_instance_rec,
                p_party_tbl             => l_parties_tbl,
                p_account_tbl           => l_pty_accts_tbl,
                p_org_assignments_tbl   => l_org_units_tbl,
                p_ext_attrib_values_tbl => l_ea_values_tbl,
                p_pricing_attrib_tbl    => l_pricing_tbl,
                p_asset_assignment_tbl  => l_assets_tbl,
                p_txn_rec               => l_txn_rec,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data );

              -- For Bug 4057183
              -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                raise fnd_api.g_exc_error;
              END IF;

            END IF;

            UPDATE csi_diagnostics_temp
            SET    process_flag = 'P',
                   temporary_message = 'Sales order issue instance staged.'
            WHERE  mtl_txn_id   = txn_rec.mtl_txn_id;

            UPDATE csi_txn_errors
            SET    processed_flag    = 'R',
                   last_update_date  = sysdate,
                   last_update_login = fnd_global.login_id,
                   last_updated_by   = fnd_global.user_id
            WHERE  inv_material_transaction_id = txn_rec.mtl_txn_id
            AND    processed_flag = 'E';

          EXCEPTION
            WHEN fnd_api.g_exc_error THEN
              rollback to stage_soiship_instances;
              l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
              UPDATE csi_diagnostics_temp
              SET    process_flag = 'E',
                     temporary_message = l_error_message
              WHERE  mtl_txn_id   = txn_rec.mtl_txn_id;
          END;
          commit;
        END LOOP;
      END IF;

    END LOOP;

    log(date_time_stamp||'  end stage_soiship_instances');

  END stage_soiship_instances;

  PROCEDURE fix_shipment(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'INVENTORY';
      l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := inv_rec.organization_id;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
      l_instance_rec.inv_locator_id           := inv_rec.locator_id;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    l_txn_rec.inv_material_transaction_id   := p_diag_txn_rec.mtl_txn_id;
    IF p_diag_txn_rec.inst_id is not null THEN
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    ELSE

      l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
      l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
      l_parties_tbl(1).party_id               := p_diag_txn_rec.internal_party_id;
      l_parties_tbl(1).relationship_type_code := 'OWNER';
      l_parties_tbl(1).contact_flag           := 'N';
      l_parties_tbl(1).object_version_number  := 1.0;

      create_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_shipment;

  PROCEDURE fix_rma(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_location_type_code     varchar2(30);
    l_intransit_location_id  number;

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    CURSOR prev_txn_cur(
      p_item_id       IN number,
      p_serial_number IN varchar2,
      p_diag_seq_id   IN number)
    IS
      SELECT mtl_txn_id,
             mtl_action_id,
             mtl_src_type_id,
             mtl_type_id
      FROM   csi_diagnostics_temp
      WHERE  inventory_item_id = p_item_id
      AND    serial_number     = p_serial_number
      AND    diag_seq_id       > p_diag_seq_id
      ORDER  by diag_seq_id asc;

    l_prev_txn_rec         prev_txn_cur%rowtype;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_diag_txn_rec.inst_id is not null THEN
       IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
          csi_gen_utility_pvt.populate_install_param_rec;
       END IF;
       --
       l_intransit_location_id := csi_datastructures_pub.g_install_param_rec.in_transit_location_id;
       --

      FOR prev_txn_rec IN prev_txn_cur(
        p_item_id       => p_diag_txn_rec.item_id,
        p_serial_number => p_diag_txn_rec.serial_number,
        p_diag_seq_id   => p_diag_txn_rec.diag_seq_id)
      LOOP
        l_prev_txn_rec := prev_txn_rec;
        exit;
      END LOOP;

      IF l_prev_txn_rec.mtl_action_id = 21 and l_prev_txn_rec.mtl_src_type_id = 8 THEN
        FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
        LOOP

          l_txn_rec.transaction_id                := fnd_api.g_miss_num;
          l_txn_rec.transaction_type_id           := correction_txn_type_id;
          l_txn_rec.source_header_ref             := 'DATAFIX';
          l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
          l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
          l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
          l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

          l_instance_rec.instance_id              := p_diag_txn_rec.inst_id;
          l_instance_rec.location_id              := l_intransit_location_id;
          l_instance_rec.location_type_code       := 'HZ_LOCATIONS';
          l_instance_rec.instance_usage_code      := 'OUT_OF_ENTERPRISE';
          l_instance_rec.inventory_item_id        := inv_rec.item_id;
          l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
          l_instance_rec.quantity                 := 1;
          l_instance_rec.inventory_revision       := inv_rec.revision;
          l_instance_rec.vld_organization_id      := inv_rec.organization_id;
          l_instance_rec.active_end_date          := sysdate;

        END LOOP;

        l_txn_rec.inv_material_transaction_id   := p_diag_txn_rec.mtl_txn_id;
        update_instance(
          p_txn_rec        => l_txn_rec,
          p_instance_rec   => l_instance_rec,
          p_parties_tbl    => l_parties_tbl,
          p_pty_accts_tbl  => l_pty_accts_tbl,
          x_return_status  => l_return_status,
          x_error_message  => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status  := l_return_status;
          x_error_message  := l_error_message;
        END IF;
      ELSE

        SELECT location_type_code
        INTO   l_location_type_code
        FROM   csi_item_instances
        WHERE  instance_id = p_diag_txn_rec.inst_id;

        IF l_location_type_code IN ('INVENTORY', 'WIP') THEN

          FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
          LOOP

            l_txn_rec.transaction_id                := fnd_api.g_miss_num;
            l_txn_rec.transaction_type_id           := correction_txn_type_id;
            l_txn_rec.source_header_ref             := 'DATAFIX';
            l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
            l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
            l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
            l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

            l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
            l_instance_rec.location_type_code       := 'INVENTORY';

            IF p_diag_txn_rec.serial_code = 6 THEN
              l_instance_rec.instance_usage_code    := 'RETURNED';
            ELSE
              l_instance_rec.instance_usage_code    := 'IN_INVENTORY';
            END IF;

            l_instance_rec.inventory_item_id        := inv_rec.item_id;
            l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
            l_instance_rec.inv_organization_id      := inv_rec.organization_id;
            l_instance_rec.quantity                 := 1;
            l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
            l_instance_rec.inv_locator_id           := inv_rec.locator_id;
            get_lot_number(
              p_lot_code        => p_diag_txn_rec.lot_code,
              p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
              p_serial_number   => p_diag_txn_rec.serial_number,
              x_lot_number      => l_instance_rec.lot_number);
            l_instance_rec.inventory_revision       := inv_rec.revision;
            l_instance_rec.vld_organization_id      := inv_rec.organization_id;
            l_instance_rec.active_end_date          := sysdate;
            l_instance_rec.object_version_number    := 1.0;

          END LOOP;

          l_txn_rec.inv_material_transaction_id   := p_diag_txn_rec.mtl_txn_id;

          update_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status  := l_return_status;
            x_error_message  := l_error_message;
          END IF;

        END IF;
      END IF;
    END IF;
  END fix_rma;

  PROCEDURE fix_wipissue(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'INVENTORY';
      l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := inv_rec.organization_id;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
      l_instance_rec.inv_locator_id           := inv_rec.locator_id;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    l_txn_rec.inv_material_transaction_id   := p_diag_txn_rec.mtl_txn_id;
    IF p_diag_txn_rec.inst_id is not null THEN
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    ELSE

      l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
      l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
      l_parties_tbl(1).party_id               := p_diag_txn_rec.internal_party_id;
      l_parties_tbl(1).relationship_type_code := 'OWNER';
      l_parties_tbl(1).contact_flag           := 'N';
      l_parties_tbl(1).object_version_number  := 1.0;

      create_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_wipissue;

  PROCEDURE fix_wipreturn(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.mtl_source_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'WIP';
      l_instance_rec.instance_usage_code      := 'IN_WIP';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := null;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := null;
      l_instance_rec.inv_locator_id           := null;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.wip_job_id               := inv_rec.mtl_source_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    IF p_diag_txn_rec.inst_id is not null THEN
      l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_wipreturn;

  PROCEDURE fix_wipcompletion(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.mtl_source_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'WIP';
      l_instance_rec.instance_usage_code      := 'IN_WIP';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := null;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := null;
      l_instance_rec.inv_locator_id           := null;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.wip_job_id               := inv_rec.mtl_source_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    IF p_diag_txn_rec.inst_id is not null THEN
      l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_wipcompletion;

  PROCEDURE fix_miscissue(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'INVENTORY';
      l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := inv_rec.organization_id;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
      l_instance_rec.inv_locator_id           := inv_rec.locator_id;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
    IF p_diag_txn_rec.inst_id is not null THEN
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    ELSE

      l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
      l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
      l_parties_tbl(1).party_id               := p_diag_txn_rec.internal_party_id;
      l_parties_tbl(1).relationship_type_code := 'OWNER';
      l_parties_tbl(1).contact_flag           := 'N';
      l_parties_tbl(1).object_version_number  := 1.0;

      create_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_miscissue;

  PROCEDURE fix_miscreceipt(
    p_diag_txn_rec  in  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_location_type_code   varchar2(30);

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_diag_txn_rec.inst_id is not null THEN

      SELECT location_type_code
      INTO   l_location_type_code
      FROM   csi_item_instances
      WHERE  instance_id = p_diag_txn_rec.inst_id;

      FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
      LOOP

        l_txn_rec.transaction_id                := fnd_api.g_miss_num;
        l_txn_rec.transaction_type_id           := correction_txn_type_id;
        l_txn_rec.source_header_ref             := 'DATAFIX';
        l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
        l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
        l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
        l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

        l_instance_rec.instance_id              := p_diag_txn_rec.inst_id;
        l_instance_rec.location_type_code       := 'INVENTORY';
        l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
        l_instance_rec.inventory_item_id        := inv_rec.item_id;
        l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
        l_instance_rec.inv_organization_id      := inv_rec.organization_id;
        l_instance_rec.quantity                 := 1;
        l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
        l_instance_rec.inv_locator_id           := inv_rec.locator_id;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
        l_instance_rec.inventory_revision       := inv_rec.revision;
        l_instance_rec.vld_organization_id      := inv_rec.organization_id;
        l_instance_rec.active_end_date          := sysdate;
        l_instance_rec.object_version_number    := 1.0;

      END LOOP;

      l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status  := l_return_status;
        x_error_message  := l_error_message;
      END IF;

    END IF;

  END fix_miscreceipt;

  PROCEDURE fix_sixfer(
    p_diag_txn_rec    IN  diag_txn_rec,
    x_return_status   OUT nocopy varchar2,
    x_error_message   OUT nocopy varchar2)
  IS

    l_mtl_xfer_txn_id      number;
    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT transfer_transaction_id
    INTO   l_mtl_xfer_txn_id
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_diag_txn_rec.mtl_txn_id;

    FOR inv_rec IN from_sixfer_cur(
      p_diag_txn_rec.mtl_txn_id,
      l_mtl_xfer_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.location_type_code       := 'INVENTORY';
      l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.inv_organization_id      := inv_rec.organization_id;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
      l_instance_rec.inv_locator_id           := inv_rec.locator_id;
      get_lot_number(
        p_lot_code        => p_diag_txn_rec.lot_code,
        p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
        p_serial_number   => p_diag_txn_rec.serial_number,
        x_lot_number      => l_instance_rec.lot_number);
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
    IF p_diag_txn_rec.inst_id is not null THEN
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    ELSE

      l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
      l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
      l_parties_tbl(1).party_id               := p_diag_txn_rec.internal_party_id;
      l_parties_tbl(1).relationship_type_code := 'OWNER';
      l_parties_tbl(1).contact_flag           := 'N';
      l_parties_tbl(1).object_version_number  := 1.0;

      create_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_sixfer;

  PROCEDURE fix_projreceipt(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;

    l_project_location_id  number;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_project_location_id := csi_datastructures_pub.g_install_param_rec.project_location_id;
    --

    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;


      l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
      l_instance_rec.accounting_class_code    := 'PROJECT';
      l_instance_rec.location_type_code       := 'PROJECT';
      l_instance_rec.location_id              := l_project_location_id;
      l_instance_rec.pa_project_id            := inv_rec.source_project_id;
      l_instance_rec.pa_project_task_id       := inv_rec.source_task_id;
      l_instance_rec.instance_usage_code      := 'IN_PROCESS';
      l_instance_rec.inventory_item_id        := inv_rec.item_id;
      l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
      l_instance_rec.quantity                 := 1;
      l_instance_rec.inv_organization_id      := null;
      l_instance_rec.inv_subinventory_name    := null;
      l_instance_rec.inv_locator_id           := null;
      l_instance_rec.lot_number               := null;
      l_instance_rec.inventory_revision       := inv_rec.revision;
      l_instance_rec.vld_organization_id      := inv_rec.organization_id;
      l_instance_rec.object_version_number    := 1.0;

    END LOOP;

    l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
    IF p_diag_txn_rec.inst_id is not null THEN
      update_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    ELSE

      l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
      l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
      l_parties_tbl(1).party_id               := p_diag_txn_rec.internal_party_id;
      l_parties_tbl(1).relationship_type_code := 'OWNER';
      l_parties_tbl(1).contact_flag           := 'N';
      l_parties_tbl(1).object_version_number  := 1.0;

      create_instance(
        p_txn_rec        => l_txn_rec,
        p_instance_rec   => l_instance_rec,
        p_parties_tbl    => l_parties_tbl,
        p_pty_accts_tbl  => l_pty_accts_tbl,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status  := l_return_status;
      x_error_message  := l_error_message;
    END IF;

  END fix_projreceipt;

  PROCEDURE fix_interorgreceipt(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec              csi_datastructures_pub.transaction_rec;

    l_internal_party_id    number;
    l_src_serial_code      number;
    l_lot_number           varchar2(80);
    l_inv_location_id      number;

    l_instance_quantity    number;
    l_instance_rec_tmp     csi_datastructures_pub.instance_rec;
    l_instance_rec         csi_datastructures_pub.instance_rec;
    l_parties_tbl          csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl           csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl            csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list     csi_datastructures_pub.id_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(2000);
    l_msg_count            number;
    l_error_message        varchar2(2000);

    user_error             exception;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    --
    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      SELECT serial_number_control_code
      INTO   l_src_serial_code
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = inv_rec.item_id
      AND    organization_id   = inv_rec.xfer_organization_id;

      SELECT nvl(mssi.location_id, haou.location_id)
      INTO   l_inv_location_id
      FROM   mtl_secondary_inventories mssi,
             hr_all_organization_units haou
      WHERE  mssi.organization_id          = inv_rec.organization_id
      AND    mssi.secondary_inventory_name = inv_rec.subinv_code
      AND    haou.organization_id          = mssi.organization_id;

      IF l_src_serial_code in (2, 5) THEN

        l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
        l_instance_rec.location_type_code       := 'INVENTORY';
        l_instance_rec.location_id              := l_inv_location_id;
        l_instance_rec.instance_usage_code      := 'IN_TRANSIT';
        l_instance_rec.inventory_item_id        := inv_rec.item_id;
        l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
        l_instance_rec.inv_organization_id      := inv_rec.xfer_organization_id;
        l_instance_rec.quantity                 := 1;
        l_instance_rec.inv_subinventory_name    := null;
        l_instance_rec.inv_locator_id           := null;
        l_instance_rec.lot_number               := null;
        l_instance_rec.inventory_revision       := inv_rec.revision;
        l_instance_rec.vld_organization_id      := inv_rec.xfer_organization_id;
        l_instance_rec.object_version_number    := 1.0;

        l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
        IF p_diag_txn_rec.inst_id is not null THEN
          update_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        ELSE

          l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
          l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
          l_parties_tbl(1).party_id               := l_internal_party_id;
          l_parties_tbl(1).relationship_type_code := 'OWNER';
          l_parties_tbl(1).contact_flag           := 'N';
          l_parties_tbl(1).object_version_number  := 1.0;

          create_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status  := l_return_status;
          x_error_message  := l_error_message;
        END IF;
      ELSIF l_src_serial_code in (1,6) THEN

        l_instance_rec := l_instance_rec_tmp;
        l_parties_tbl.delete;

        -- create/update a non serial intransit instance
        get_lot_number(
          p_lot_code        => p_diag_txn_rec.lot_code,
          p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
          p_serial_number   => p_diag_txn_rec.serial_number,
          x_lot_number      => l_lot_number);

        BEGIN
          SELECT instance_id,
                 object_version_number,
                 quantity
          INTO   l_instance_rec.instance_id,
                 l_instance_rec.object_version_number,
                 l_instance_quantity
          FROM   csi_item_instances
          WHERE  inventory_item_id                = inv_rec.item_id
          AND    nvl(inventory_revision,'$$##$$') = nvl(inv_rec.revision, '$$##$$')
          AND    nvl(lot_number,'$$##$$')         = nvl(l_lot_number, '$$##$$')
          AND    location_type_code               = 'INVENTORY'
          AND    instance_usage_code              = 'IN_TRANSIT'
          AND    serial_number                    is null;

          l_instance_rec.quantity := l_instance_quantity + 1;

        EXCEPTION
          WHEN no_data_found THEN
            l_instance_rec.instance_id := fnd_api.g_miss_num;
            l_instance_rec.quantity    := 1;
          WHEN too_many_rows THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_error_message := 'Multiple non serial in_transit instances found.';
            RAISE user_error;
        END;

        IF nvl(l_instance_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          l_instance_rec.active_end_date       := null;
          l_instance_rec.instance_status_id    := 3;

          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_party_tbl             => l_parties_tbl,
            p_account_tbl           => l_pty_accts_tbl,
            p_org_assignments_tbl   => l_org_units_tbl,
            p_ext_attrib_values_tbl => l_ea_values_tbl,
            p_pricing_attrib_tbl    => l_pricing_tbl,
            p_asset_assignment_tbl  => l_assets_tbl,
            p_txn_rec               => l_txn_rec,
            x_instance_id_lst       => l_instance_ids_list,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            x_return_status  := l_return_status;
            x_error_message  := csi_t_gen_utility_pvt.dump_error_stack;
            RAISE user_error;
          END IF;

        ELSE

          l_instance_rec.inventory_item_id        := inv_rec.item_id;
          l_instance_rec.inventory_revision       := inv_rec.revision;
          l_instance_rec.vld_organization_id      := inv_rec.xfer_organization_id;
          l_instance_rec.instance_usage_code      := 'IN_TRANSIT';
          l_instance_rec.location_type_code       := 'INVENTORY';
          l_instance_rec.location_id              := l_inv_location_id;
          l_instance_rec.active_end_date          := null;
          l_instance_rec.inv_organization_id      := null;
          l_instance_rec.inv_subinventory_name    := null;
          l_instance_rec.inv_locator_id           := null;
          l_instance_rec.lot_number               := l_lot_number;

          l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
          l_parties_tbl(1).instance_id            := fnd_api.g_miss_num;
          l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
          l_parties_tbl(1).party_id               := l_internal_party_id;
          l_parties_tbl(1).relationship_type_code := 'OWNER';
          l_parties_tbl(1).contact_flag           := 'N';
          l_parties_tbl(1).object_version_number  := 1.0;

          create_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status  := l_return_status;
            x_error_message  := l_error_message;
            RAISE user_error;
          END IF;
        END IF;

        -- update the destination in the returned status for 6
        IF l_src_serial_code = 6 and p_diag_txn_rec.inst_id is not null THEN

          l_instance_rec := l_instance_rec_tmp;
          l_parties_tbl.delete;

          l_instance_rec.instance_id          := p_diag_txn_rec.inst_id;
          l_instance_rec.location_type_code   := 'INVENTORY';
          l_instance_rec.inv_organization_id  := inv_rec.organization_id;
          l_instance_rec.inv_subinventory_name:= inv_rec.subinv_code;

          SELECT nvl(mssi.location_id, haou.location_id)
          INTO   l_instance_rec.location_id
          FROM   mtl_secondary_inventories mssi,
                 hr_all_organization_units haou
          WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
          AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
          AND    haou.organization_id          = mssi.organization_id;

          l_instance_rec.instance_usage_code    := 'RETURNED';
          l_instance_rec.inventory_item_id      := inv_rec.item_id;
          l_instance_rec.serial_number          := p_diag_txn_rec.serial_number;
          l_instance_rec.mfg_serial_number_flag := 'Y';
          l_instance_rec.quantity               := 1;
          l_instance_rec.inv_locator_id         := inv_rec.locator_id;
          l_instance_rec.creation_complete_flag := 'N';

          get_lot_number(
            p_lot_code        => p_diag_txn_rec.lot_code,
            p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
            p_serial_number   => p_diag_txn_rec.serial_number,
            x_lot_number      => l_instance_rec.lot_number);

          l_instance_rec.inventory_revision       := inv_rec.revision;
          l_instance_rec.vld_organization_id      := inv_rec.organization_id;

          l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;

          update_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
            x_error_message := l_error_message;
          END IF;
        END IF;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN user_error THEN
      -- just to bring the control to the end of the routine
      null;
  END fix_interorgreceipt;

  PROCEDURE fix_isoreceipt(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    l_txn_rec               csi_datastructures_pub.transaction_rec;

    l_instance_rec          csi_datastructures_pub.instance_rec;
    l_parties_tbl           csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl         csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl           csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl            csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list     csi_datastructures_pub.id_tbl;

    l_src_serial_code       number;
    l_dest_serial_code      number;

    l_instance_quantity     number;
    l_internal_party_id     number;
    l_intransit_location_id number;
    l_lot_number            varchar2(80);

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

    l_error_message         varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_intransit_location_id := csi_datastructures_pub.g_install_param_rec.in_transit_location_id;
    --
    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      SELECT serial_number_control_code
      INTO   l_src_serial_code
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = inv_rec.item_id
      AND    organization_id   = inv_rec.xfer_organization_id;

      SELECT serial_number_control_code
      INTO   l_dest_serial_code
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = inv_rec.item_id
      AND    organization_id   = inv_rec.organization_id;

      IF l_src_serial_code in (2, 5, 6) THEN
        l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);

        IF l_dest_serial_code = 1 THEN
          l_instance_rec.location_type_code     := 'HZ_LOCATIONS';
          l_instance_rec.location_type_code     := 'OUT_OF_ENTERPRISE';
        ELSE
          l_instance_rec.location_type_code     := 'IN_TRANSIT';
          l_instance_rec.instance_usage_code    := 'IN_TRANSIT';
        END IF;

        l_instance_rec.location_id              := l_intransit_location_id;
        l_instance_rec.inventory_item_id        := inv_rec.item_id;
        l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
        l_instance_rec.quantity                 := 1;
        l_instance_rec.inv_organization_id      := null;
        l_instance_rec.inv_subinventory_name    := null;
        l_instance_rec.inv_locator_id           := null;
        l_instance_rec.lot_number               := null;
        l_instance_rec.inventory_revision       := inv_rec.revision;

        -- read the order line id from the shipment transaction prior to the ISO receipt
        -- and stamp it in in_transit_order_line_id
        BEGIN
          SELECT trx_source_line_id
          INTO   l_instance_rec.in_transit_order_line_id
          FROM   mtl_material_transactions
          WHERE  transaction_action_id      = 21
          AND    transaction_source_type_id = 8
          AND   (shipment_number, inventory_item_id) IN (
                 SELECT shipment_number, inventory_item_id
                 FROM   mtl_material_transactions
                 WHERE  transaction_id = inv_rec.mtl_txn_id)
          AND rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            l_instance_rec.in_transit_order_line_id := inv_rec.trx_source_line_id;
        END;

        l_instance_rec.vld_organization_id      := inv_rec.organization_id;
        l_instance_rec.object_version_number    := 1.0;

        l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
        IF p_diag_txn_rec.inst_id is not null THEN
          update_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        ELSE

          l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
          l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
          l_parties_tbl(1).party_id               := l_internal_party_id;
          l_parties_tbl(1).relationship_type_code := 'OWNER';
          l_parties_tbl(1).contact_flag           := 'N';
          l_parties_tbl(1).object_version_number  := 1.0;

          create_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status  := l_return_status;
          x_error_message  := l_error_message;
        END IF;

      ELSIF l_src_serial_code = 1 THEN
        BEGIN

          get_lot_number(
            p_lot_code        => p_diag_txn_rec.lot_code,
            p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
            p_serial_number   => p_diag_txn_rec.serial_number,
            x_lot_number      => l_lot_number);

          SELECT instance_id,
                 object_version_number,
                 quantity
          INTO   l_instance_rec.instance_id,
                 l_instance_rec.object_version_number,
                 l_instance_quantity
          FROM   csi_item_instances
          WHERE  inventory_item_id                = inv_rec.item_id
          AND    nvl(inventory_revision,'$$##$$') = nvl(inv_rec.revision, '$$##$$')
          AND    nvl(lot_number,'$$##$$')         = nvl(l_lot_number, '$$##$$')
          AND    location_type_code               = 'IN_TRANSIT'
          AND    instance_usage_code              = 'IN_TRANSIT'
          AND    serial_number                    is null;

          l_instance_rec.quantity := l_instance_quantity + inv_rec.quantity;

        EXCEPTION
          WHEN no_data_found THEN
            l_instance_rec.instance_id           := fnd_api.g_miss_num;
            l_instance_rec.object_version_number := 1;
            l_instance_rec.quantity              := inv_rec.quantity;
        END;

        BEGIN
          SELECT trx_source_line_id
          INTO   l_instance_rec.in_transit_order_line_id
          FROM   mtl_material_transactions
          WHERE  transaction_action_id      = 21
          AND    transaction_source_type_id = 8
          AND   (shipment_number, inventory_item_id) IN (
                 SELECT shipment_number, inventory_item_id
                 FROM   mtl_material_transactions
                 WHERE  transaction_id = inv_rec.mtl_txn_id)
          AND rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            l_instance_rec.in_transit_order_line_id := inv_rec.trx_source_line_id;
        END;

        IF nvl(l_instance_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          l_instance_rec.active_end_date       := null;
          l_instance_rec.instance_status_id    := 3;

          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_party_tbl             => l_parties_tbl,
            p_account_tbl           => l_pty_accts_tbl,
            p_org_assignments_tbl   => l_org_units_tbl,
            p_ext_attrib_values_tbl => l_ea_values_tbl,
            p_pricing_attrib_tbl    => l_pricing_tbl,
            p_asset_assignment_tbl  => l_assets_tbl,
            p_txn_rec               => l_txn_rec,
            x_instance_id_lst       => l_instance_ids_list,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            x_return_status  := l_return_status;
            x_error_message  := csi_t_gen_utility_pvt.dump_error_stack;
          END IF;

        ELSE

          l_instance_rec.inventory_item_id        := inv_rec.item_id;
          l_instance_rec.inventory_revision       := inv_rec.revision;
          l_instance_rec.vld_organization_id      := inv_rec.xfer_organization_id;
          l_instance_rec.instance_usage_code      := 'IN_TRANSIT';
          l_instance_rec.location_type_code       := 'IN_TRANSIT';
          l_instance_rec.location_id              := l_intransit_location_id;
          l_instance_rec.active_end_date          := null;
          l_instance_rec.inv_organization_id      := null;
          l_instance_rec.inv_subinventory_name    := null;
          l_instance_rec.inv_locator_id           := null;
          l_instance_rec.lot_number               := null;

          l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
          l_parties_tbl(1).instance_id            := fnd_api.g_miss_num;
          l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
          l_parties_tbl(1).party_id               := l_internal_party_id;
          l_parties_tbl(1).relationship_type_code := 'OWNER';
          l_parties_tbl(1).contact_flag           := 'N';
          l_parties_tbl(1).object_version_number  := 1.0;

          create_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status  := l_return_status;
          x_error_message  := l_error_message;
        END IF;

      END IF;

    END LOOP;

  END fix_isoreceipt;

  PROCEDURE fix_intransitship(
    p_diag_txn_rec  IN  diag_txn_rec,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS

    CURSOR stage_cur(p_mtl_txn_id in number, p_lot_code in number) IS
      SELECT mmt.inventory_item_id      item_id,
             mmt.organization_id        organization_id,
             mmt.subinventory_code      subinv_code,
             mmt.locator_id             locator_id,
             mmt.revision               revision,
             to_char(null)              lot_number,
             abs(mmt.primary_quantity)  quantity,
             mmt.transaction_date       mtl_txn_date,
             mmt.transaction_id         mtl_txn_id,
             mmt.trx_source_line_id     trx_source_line_id
      FROM   mtl_material_transactions mmt
      WHERE  mmt.transaction_id = p_mtl_txn_id
      AND    p_lot_code = 1
      UNION
      SELECT mmt.inventory_item_id      item_id,
             mmt.organization_id        organization_id,
             mmt.subinventory_code      subinv_code,
             mmt.locator_id             locator_id,
             mmt.revision               revision,
             mtln.lot_number            lot_number,
             abs(mtln.primary_quantity) quantity,
             mmt.transaction_date       mtl_txn_date,
             mmt.transaction_id         mtl_txn_id,
             mmt.trx_source_line_id     trx_source_line_id
      FROM   mtl_material_transactions   mmt,
             mtl_transaction_lot_numbers mtln
      WHERE  mmt.transaction_id  = p_mtl_txn_id
      AND    mtln.transaction_id = mmt.transaction_id
      AND    p_lot_code <> 1;

    l_txn_rec                csi_datastructures_pub.transaction_rec;

    l_instance_rec           csi_datastructures_pub.instance_rec;
    l_parties_tbl            csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl          csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl          csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl            csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl             csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list      csi_datastructures_pub.id_tbl;

    l_internal_party_id      number;
    l_intransit_location_id  number;

    l_src_serial_code        number;
    l_src_lot_code           number;
    l_primary_uom_code       varchar2(8);

    l_dest_serial_code       number;
    l_dest_lot_code          number;

    l_instance_id            number;
    l_quantity               number;
    l_object_version_number  number;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);
    l_msg_data               varchar2(2000);
    l_msg_count              number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_intransit_location_id := csi_datastructures_pub.g_install_param_rec.in_transit_location_id;
    --
    FOR inv_rec IN inv_cur (p_diag_txn_rec.mtl_txn_id)
    LOOP

      SELECT serial_number_control_code,
             lot_control_code,
             primary_uom_code
      INTO   l_src_serial_code,
             l_src_lot_code,
             l_primary_uom_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = inv_rec.item_id
      AND    organization_id   = inv_rec.organization_id;

      SELECT serial_number_control_code,
             lot_control_code
      INTO   l_dest_serial_code,
             l_dest_lot_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = inv_rec.item_id
      AND    organization_id   = inv_rec.xfer_organization_id;

      l_txn_rec.transaction_id                := fnd_api.g_miss_num;
      l_txn_rec.transaction_type_id           := correction_txn_type_id;
      l_txn_rec.source_header_ref             := 'DATAFIX';
      l_txn_rec.source_line_ref               := p_diag_txn_rec.process_code;
      l_txn_rec.source_line_ref_id            := inv_rec.trx_source_line_id;
      l_txn_rec.source_transaction_date       := inv_rec.mtl_txn_date;
      l_txn_rec.transaction_date              := inv_rec.mtl_txn_date;

      IF l_src_serial_code in (2, 5) THEN

        l_instance_rec.instance_id              := nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num);
        l_instance_rec.location_type_code       := 'INVENTORY';
        l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
        l_instance_rec.inventory_item_id        := inv_rec.item_id;
        l_instance_rec.serial_number            := p_diag_txn_rec.serial_number;
        l_instance_rec.inv_organization_id      := inv_rec.organization_id;
        l_instance_rec.quantity                 := 1;
        l_instance_rec.inv_subinventory_name    := inv_rec.subinv_code;
        l_instance_rec.inv_locator_id           := inv_rec.locator_id;

        get_lot_number(
          p_lot_code        => p_diag_txn_rec.lot_code,
          p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
          p_serial_number   => p_diag_txn_rec.serial_number,
          x_lot_number      => l_instance_rec.lot_number);

        l_instance_rec.inventory_revision       := inv_rec.revision;
        l_instance_rec.vld_organization_id      := inv_rec.organization_id;
        l_instance_rec.object_version_number    := 1.0;

        l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;
        IF p_diag_txn_rec.inst_id is not null THEN
          update_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        ELSE

          l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
          l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
          l_parties_tbl(1).party_id               := l_internal_party_id;
          l_parties_tbl(1).relationship_type_code := 'OWNER';
          l_parties_tbl(1).contact_flag           := 'N';
          l_parties_tbl(1).object_version_number  := 1.0;

          create_instance(
            p_txn_rec        => l_txn_rec,
            p_instance_rec   => l_instance_rec,
            p_parties_tbl    => l_parties_tbl,
            p_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status  := l_return_status;
          x_error_message  := l_error_message;
        END IF;
      ELSE

        -- handle source
        FOR stage_rec IN stage_cur (inv_rec.mtl_txn_id, l_src_lot_code)
        LOOP

          BEGIN

            init_plsql_tables(
              px_instance_rec  => l_instance_rec,
              px_parties_tbl   => l_parties_tbl,
              px_pty_accts_tbl => l_pty_accts_tbl,
              px_org_units_tbl => l_org_units_tbl,
              px_ea_values_tbl => l_ea_values_tbl,
              px_pricing_tbl   => l_pricing_tbl,
              px_assets_tbl    => l_assets_tbl);

            BEGIN

              SELECT instance_id,
                     quantity,
                     object_version_number
              INTO   l_instance_id,
                     l_quantity,
                     l_object_version_number
              FROM   csi_item_instances
              WHERE  location_type_code               = 'INVENTORY'
              AND    instance_usage_code              = 'IN_INVENTORY'
              AND    inventory_item_id                = stage_rec.item_id
              AND    inv_organization_id              = stage_rec.organization_id
              AND    inv_subinventory_name            = stage_rec.subinv_code
              AND    nvl(inv_locator_id,-9999)        = nvl(stage_rec.locator_id,-9999)
              AND    nvl(lot_number,'$$##$$')         = nvl(stage_rec.lot_number,'$$##$$')
              AND    nvl(inventory_revision,'$$##$$') = nvl(stage_rec.revision,'$$##$$')
              AND    serial_number is null;

            EXCEPTION
              WHEN no_data_found THEN
                l_instance_id := fnd_api.g_miss_num;
              WHEN too_many_rows THEN
                stack_message('Too many inventory instances for this non srl item.');
                raise fnd_api.g_exc_error;
            END;

            IF nvl(l_instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

              l_instance_rec.instance_id           := l_instance_id;
              l_instance_rec.quantity              := l_quantity + stage_rec.quantity;
              l_instance_rec.object_version_number := l_object_version_number;
              l_instance_rec.active_end_date       := null;
              l_instance_rec.instance_status_id    := 3;

              csi_item_instance_pub.update_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_instance_rec,
                p_party_tbl             => l_parties_tbl,
                p_account_tbl           => l_pty_accts_tbl,
                p_org_assignments_tbl   => l_org_units_tbl,
                p_ext_attrib_values_tbl => l_ea_values_tbl,
                p_pricing_attrib_tbl    => l_pricing_tbl,
                p_asset_assignment_tbl  => l_assets_tbl,
                p_txn_rec               => l_txn_rec,
                x_instance_id_lst       => l_instance_ids_list,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

              log('  update_item_instance:nsrl: '||l_return_status);

              -- For Bug 4057183
              -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                raise fnd_api.g_exc_error;
              END IF;

            ELSE

              l_instance_rec.instance_id              := fnd_api.g_miss_num;
              l_instance_rec.location_type_code       := 'INVENTORY';
              l_instance_rec.instance_usage_code      := 'IN_INVENTORY';
              l_instance_rec.inventory_item_id        := stage_rec.item_id;
              l_instance_rec.inv_organization_id      := stage_rec.organization_id;
              l_instance_rec.quantity                 := stage_rec.quantity;
              l_instance_rec.unit_of_measure          := l_primary_uom_code;
              l_instance_rec.inv_subinventory_name    := stage_rec.subinv_code;
              l_instance_rec.inv_locator_id           := stage_rec.locator_id;
              l_instance_rec.lot_number               := stage_rec.lot_number;
              l_instance_rec.inventory_revision       := stage_rec.revision;
              l_instance_rec.vld_organization_id      := stage_rec.organization_id;
              l_instance_rec.object_version_number    := 1.0;

              SELECT nvl(mssi.location_id, haou.location_id)
              INTO   l_instance_rec.location_id
              FROM   mtl_secondary_inventories mssi,
                     hr_all_organization_units haou
              WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
              AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
              AND    haou.organization_id          = mssi.organization_id;

              l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
              l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
              l_parties_tbl(1).party_id               := l_internal_party_id;
              l_parties_tbl(1).relationship_type_code := 'OWNER';
              l_parties_tbl(1).contact_flag           := 'N';
              l_parties_tbl(1).object_version_number  := 1.0;

              csi_item_instance_pub.create_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_instance_rec,
                p_party_tbl             => l_parties_tbl,
                p_account_tbl           => l_pty_accts_tbl,
                p_org_assignments_tbl   => l_org_units_tbl,
                p_ext_attrib_values_tbl => l_ea_values_tbl,
                p_pricing_attrib_tbl    => l_pricing_tbl,
                p_asset_assignment_tbl  => l_assets_tbl,
                p_txn_rec               => l_txn_rec,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data );

              log('  create_item_instance:nsrl: '||l_return_status);

              -- For Bug 4057183
              -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                raise fnd_api.g_exc_error;
              END IF;

            END IF;
          EXCEPTION
            WHEN fnd_api.g_exc_error THEN
              x_return_status := fnd_api.g_ret_sts_error;
              x_error_message := csi_t_gen_utility_pvt.dump_error_stack;
              log('  error: '||x_error_message);
          END;
        END LOOP;

        -- handle soi destination instance
        IF nvl(p_diag_txn_rec.inst_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          IF l_src_serial_code = 6 THEN

            init_plsql_tables(
              px_instance_rec  => l_instance_rec,
              px_parties_tbl   => l_parties_tbl,
              px_pty_accts_tbl => l_pty_accts_tbl,
              px_org_units_tbl => l_org_units_tbl,
              px_ea_values_tbl => l_ea_values_tbl,
              px_pricing_tbl   => l_pricing_tbl,
              px_assets_tbl    => l_assets_tbl);

            l_instance_rec.instance_id          := p_diag_txn_rec.inst_id;
            l_instance_rec.location_type_code   := 'INVENTORY';
            l_instance_rec.inv_organization_id  := inv_rec.organization_id;
            l_instance_rec.inv_subinventory_name:= inv_rec.subinv_code;

            SELECT nvl(mssi.location_id, haou.location_id)
            INTO   l_instance_rec.location_id
            FROM   mtl_secondary_inventories mssi,
                   hr_all_organization_units haou
            WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
            AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
            AND    haou.organization_id          = mssi.organization_id;

            l_instance_rec.instance_usage_code  := 'RETURNED';
            l_instance_rec.inventory_item_id    := inv_rec.item_id;
            l_instance_rec.serial_number        := p_diag_txn_rec.serial_number;
            l_instance_rec.mfg_serial_number_flag := 'Y';
            l_instance_rec.quantity             := 1;
            l_instance_rec.inv_locator_id       := inv_rec.locator_id;
            l_instance_rec.creation_complete_flag := 'N';

            get_lot_number(
              p_lot_code        => p_diag_txn_rec.lot_code,
              p_mtl_txn_id      => p_diag_txn_rec.mtl_txn_id,
              p_serial_number   => p_diag_txn_rec.serial_number,
              x_lot_number      => l_instance_rec.lot_number);

            l_instance_rec.inventory_revision   := inv_rec.revision;
            l_instance_rec.vld_organization_id  := inv_rec.organization_id;

            l_txn_rec.inv_material_transaction_id  := p_diag_txn_rec.mtl_txn_id;

            update_instance(
              p_txn_rec        => l_txn_rec,
              p_instance_rec   => l_instance_rec,
              p_parties_tbl    => l_parties_tbl,
              p_pty_accts_tbl  => l_pty_accts_tbl,
              x_return_status  => l_return_status,
              x_error_message  => l_error_message);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              x_return_status := l_return_status;
              x_error_message := l_error_message;
            END IF;

          END IF;
        END IF;

      END IF;
    END LOOP;

  END fix_intransitship;

  PROCEDURE fix_all(
    p_diag_txn_rec IN diag_txn_rec)
  IS
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message    varchar2(2000);
    l_fixed            boolean := FALSE;
  BEGIN

    log('  '||p_diag_txn_rec.serial_number||
        '  '||p_diag_txn_rec.mtl_txn_id||
        '  '||p_diag_txn_rec.source_type||
        '  '||p_diag_txn_rec.process_code||
        '  '||p_diag_txn_rec.inst_id);

    IF p_diag_txn_rec.process_code = 'SHIP' THEN

      fix_shipment(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);

    END IF;

    IF p_diag_txn_rec.process_code = 'RMA' THEN
      fix_rma(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'WIPISSUE' THEN
      fix_wipissue(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'WIPRETURN' THEN
      fix_wipreturn(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'WIPCOMPL' THEN
      fix_wipcompletion(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'MISCISSUE' THEN
      fix_miscissue(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'MISCRCPT' THEN
      fix_miscreceipt(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'SIXFER' THEN
      fix_sixfer(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'PROJRCPT' THEN
      fix_projreceipt(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'IORGRCPT' THEN
      fix_interorgreceipt(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'ISORCPT' THEN
      fix_isoreceipt(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF p_diag_txn_rec.process_code = 'INTRSHIP' THEN
      fix_intransitship(
        p_diag_txn_rec  => p_diag_txn_rec,
        x_return_status => l_return_status,
        x_error_message => l_error_message);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_success THEN
      UPDATE csi_diagnostics_temp
      SET    process_flag = 'P'
      WHERE  diag_seq_id  = p_diag_txn_rec.diag_seq_id;

      UPDATE csi_txn_errors
      SET    processed_flag    = 'R',
             last_update_date  = sysdate,
             last_update_login = fnd_global.login_id,
             last_updated_by   = fnd_global.user_id
      WHERE  inv_material_transaction_id = p_diag_txn_rec.mtl_txn_id
      AND    processed_flag              = 'E';
    ELSE
      UPDATE csi_diagnostics_temp
      SET    process_flag = 'E',
             temporary_message = l_error_message
      WHERE  diag_seq_id  = p_diag_txn_rec.diag_seq_id;
    END IF;

  END fix_all;

  PROCEDURE fix_srldata is

    CURSOR process_cur is
      SELECT cdt.diag_seq_id,
             nvl(cdt.process_code,'NONE') process_code,
             cdt.mtl_txn_id,
             cdt.mtl_txn_date mtl_txn_date,
             cdt.serial_number,
             cdt.inventory_item_id,
             cdt.instance_id,
             cdt.csi_txn_id,
             cdt.csi_txn_type_id,
             cdt.wip_job_id,
             nvl(cdt.create_flag, 'N')  create_flag,
             nvl(cdt.expire_flag, 'N')  expire_flag,
             cdt.serial_control_code,
             cdt.lot_control_code,
             cdt.source_type,
             cdt.internal_party_id
      FROM   csi_diagnostics_temp cdt
      WHERE  nvl(cdt.process_flag ,'N') = 'M'; -- marked FOR processing

    CURSOR reprocess_cur IS
      SELECT distinct mtl_txn_id
      FROM   csi_diagnostics_temp
      WHERE  process_flag = 'R';

    l_diag_txn_rec         diag_txn_rec;

  BEGIN

    -- stage the non serial instance quantity and update the returned serial instance
    stage_soiship_instances;

    log(date_time_stamp||'  begin fix_srldata');

    FOR process_rec in process_cur
    LOOP

      IF process_rec.process_code <> 'SOISHIP' THEN

        l_diag_txn_rec.diag_seq_id       := process_rec.diag_seq_id;
        l_diag_txn_rec.process_code      := process_rec.process_code;
        l_diag_txn_rec.mtl_txn_id        := process_rec.mtl_txn_id;
        l_diag_txn_rec.mtl_txn_date      := process_rec.mtl_txn_date;
        l_diag_txn_rec.serial_number     := process_rec.serial_number;
        l_diag_txn_rec.item_id           := process_rec.inventory_item_id;
        l_diag_txn_rec.inst_id           := process_rec.instance_id;
        l_diag_txn_rec.csi_txn_id        := process_rec.csi_txn_id;
        l_diag_txn_rec.csi_txn_type_id   := process_rec.csi_txn_type_id;
        l_diag_txn_rec.wip_job_id        := process_rec.wip_job_id;
        l_diag_txn_rec.create_flag       := process_rec.create_flag;
        l_diag_txn_rec.expire_flag       := process_rec.expire_flag;
        l_diag_txn_rec.serial_code       := process_rec.serial_control_code;
        l_diag_txn_rec.lot_code          := process_rec.lot_control_code;
        l_diag_txn_rec.source_type       := process_rec.source_type;
        l_diag_txn_rec.internal_party_id := process_rec.internal_party_id;

        fix_all(
          p_diag_txn_rec => l_diag_txn_rec);

      END IF;

    END LOOP;

    FOR reprocess_rec in reprocess_cur
    LOOP
      update csi_txn_errors
      SET    processed_flag              = 'R',
             last_update_date            = sysdate,
             last_update_login           = fnd_global.login_id,
             last_updated_by             = fnd_global.user_id
      WHERE  inv_material_transaction_id = reprocess_rec.mtl_txn_id
      AND    processed_flag              = 'E';
    END LOOP;

    knock_the_rest;

    log(date_time_stamp||'  end fix_srldata');

  END fix_srldata;

  PROCEDURE get_rma_owner(
    p_serial_number     in  varchar2,
    p_inventory_item_id in  number,
    p_organization_id   in  number,
    x_change_owner_flag out nocopy varchar2,
    x_owner_party_id    out nocopy number,
    x_owner_account_id  out nocopy number)
  IS

    CURSOR rma_txn_cur(
      p_serial      in varchar2,
      p_item_id     in number,
      p_freeze_date in date)
    IS
      SELECT mmt.creation_date         mtl_creation_date,
             mut.transaction_id        mtl_txn_id,
             mut.transaction_date      mtl_txn_date,
             mmt.trx_source_line_id    rma_line_id
      FROM   mtl_unit_transactions     mut,
             mtl_material_transactions mmt
      WHERE  mut.serial_number         = p_serial
      AND    mut.inventory_item_id     = p_item_id
      AND    mut.transaction_date      > p_freeze_date
      AND    mmt.transaction_id        = mut.transaction_id
      AND    mmt.transaction_type_id   = 15
      UNION
      SELECT mmt.creation_date         mtl_creation_date,
             mtln.transaction_id       mtl_txn_id,
             mtln.transaction_date     mtl_txn_date,
             mmt.trx_source_line_id    rma_line_id
      FROM   mtl_unit_transactions       mut,
             mtl_transaction_lot_numbers mtln,
             mtl_material_transactions   mmt
      WHERE  mut.serial_number          = p_serial
      AND    mut.inventory_item_id      = p_item_id
      AND    mtln.serial_transaction_id = mut.transaction_id
      AND    mtln.transaction_date      > p_freeze_date
      AND    mmt.transaction_id         = mtln.transaction_id
      AND    mmt.transaction_type_id    = 15
      ORDER by 1 desc, 2 desc;

   CURSOR tld_cur(p_rma_line_id in number) is
     SELECT ctld.sub_type_id
     FROM   csi_t_transaction_lines ctl,
            csi_t_txn_line_details ctld
     WHERE  ctl.source_transaction_table = 'OE_ORDER_LINES_ALL'
     AND    ctl.source_transaction_type_id  = 53
     AND    ctl.source_transaction_id    = p_rma_line_id
     AND    ctld.transaction_line_id     = ctl.transaction_line_id
     AND    ctld.source_transaction_flag = 'Y';

    l_dflt_sub_type_id   number;
    l_rma_line_id        number;
    l_sub_type_id        number;
    l_owner_party_id     number;
    l_owner_account_id   number;
    l_change_owner_flag  varchar2(1) := 'Y';

    l_freeze_date        date;

  BEGIN

    SELECT sub_type_id
    INTO   l_dflt_sub_type_id
    FROM   csi_txn_sub_types
    WHERE  transaction_type_id = 53
    AND    default_flag = 'Y';
    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;

    l_change_owner_flag := 'Y';
    l_rma_line_id       := null;
    l_sub_type_id       := null;
    l_owner_party_id    := null;
    l_owner_account_id  := null;

    FOR rma_txn_rec in rma_txn_cur (
      p_serial      => p_serial_number,
      p_item_id     => p_inventory_item_id,
      p_freeze_date => l_freeze_date)
    LOOP
      l_rma_line_id  := rma_txn_rec.rma_line_id;
      exit;
    END LOOP;

    IF l_rma_line_id is not null THEN

      FOR tld_rec in tld_cur(l_rma_line_id)
      LOOP
        l_sub_type_id := tld_rec.sub_type_id;
        exit;
      END LOOP;

      IF l_sub_type_id is not null THEN
        null;
      ELSE
        l_sub_type_id := l_dflt_sub_type_id;
      END IF;

      SELECT nvl(src_change_owner, 'N')
      INTO   l_change_owner_flag
      FROM   csi_txn_sub_types
      WHERE  transaction_type_id = 53
      AND    sub_type_id         = l_sub_type_id;


      IF l_change_owner_flag = 'N' THEN

        SELECT nvl(oel.sold_to_org_id, oeh.sold_to_org_id)
        INTO   l_owner_account_id
        FROM   oe_order_lines_all oel,
               oe_order_headers_all oeh
        WHERE  oel.line_id = l_rma_line_id
        AND    oeh.header_id = oel.header_id;

        SELECT party_id
        INTO   l_owner_party_id
        FROM   hz_cust_accounts
        WHERE  cust_account_id = l_owner_account_id;

      END IF;

    END IF;

    x_change_owner_flag := l_change_owner_flag;
    x_owner_party_id    := l_owner_party_id;
    x_owner_account_id  := l_owner_account_id;

  END get_rma_owner;


  /* routine to sync inventory and instances */
  PROCEDURE sync_inv_serials IS

    CURSOR inv_srl_cur IS
      SELECT msn.serial_number              serial_number,
             msn.inventory_item_id          inventory_item_id,
             msn.current_organization_id    organization_id,
             msn.revision                   revision,
             msn.current_subinventory_code  subinventory_code,
             msn.current_locator_id         locator_id,
             msn.lot_number                 lot_number,
             msi.primary_uom_code           uom_code,
             msi.serial_number_control_code serial_code,
             msi.lot_control_code           lot_code
      FROM   mtl_system_items   msi,
             mtl_serial_numbers msn
      WHERE  msi.inventory_item_id = msn.inventory_item_id
      AND    msi.organization_id   = msn.current_organization_id
      AND    msi.serial_number_control_code in (2,5)
      AND    msn.current_status    = 3
      AND    EXISTS (
               SELECT '1'
               FROM  mtl_parameters   mp,
                     mtl_system_items msi_mast
               WHERE mp.organization_id         = msi.organization_id
               AND   msi_mast.inventory_item_id = msi.inventory_item_id
               AND   msi_mast.organization_id   = mp.master_organization_id
               AND   nvl(msi_mast.comms_nl_trackable_flag,'N') = 'Y')
      AND    EXISTS (
               SELECT '1'
               FROM  mtl_onhand_quantities moq
               WHERE moq.inventory_item_id     = msn.inventory_item_id
               AND   moq.organization_id       = msn.current_organization_id
               AND   moq.subinventory_code     = msn.current_subinventory_code
               AND   nvl(moq.locator_id,-999)  = nvl(msn.current_locator_id,-999)
               AND   nvl(moq.lot_number,'$#$') = nvl(msn.lot_number,'$#$')
               AND   nvl(moq.revision,'$#$')   = nvl(msn.revision,'$#$') );

    l_release            varchar2(80);

    l_internal_party_id  number;
    l_instance           varchar2(30);
    l_instance_found     boolean := TRUE;
    l_not_the_same       boolean := TRUE;

    l_instance_rec       csi_datastructures_pub.instance_rec;
    l_parties_tbl        csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl      csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl      csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl        csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list  csi_datastructures_pub.id_tbl;
    l_txn_rec            csi_datastructures_pub.transaction_rec;
    l_freeze_date        date;
    l_latest_txn         boolean := TRUE;
    l_pending_msg_found  varchar2(1);
    l_pending_err_found  varchar2(1);

    l_owner_party_id     number;
    l_owner_account_id   number;
    l_change_owner_flag  varchar2(1);
    l_txn_is_in_csi      varchar2(1);
    l_fs_found           varchar2(1);

    skip_serial          exception;

    l_error_message      varchar2(2000);
    l_msg_data           varchar2(2000);
    l_msg_count          number;
    l_return_status      varchar2(1);

    l_skip_error         varchar2(2000);

  BEGIN

    decode_queue;

    SELECT fnd_Profile.value('csi_upgrading_from_release')
    INTO   l_release
    FROM   sys.dual;
    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;

    FOR srl_rec IN inv_srl_cur
    LOOP

      BEGIN

        init_plsql_tables(
          px_instance_rec  => l_instance_rec,
          px_parties_tbl   => l_parties_tbl,
          px_pty_accts_tbl => l_pty_accts_tbl,
          px_org_units_tbl => l_org_units_tbl,
          px_ea_values_tbl => l_ea_values_tbl,
          px_pricing_tbl   => l_pricing_tbl,
          px_assets_tbl    => l_assets_tbl);

        BEGIN

          SELECT 'Y'
          INTO   l_fs_found
          FROM   csi_ii_forward_sync_temp
          WHERE  inventory_item_id = srl_rec.inventory_item_id
          AND    serial_number     = srl_rec.serial_number
          AND    process_flag     <> 'P';

          l_skip_error := 'serial awaiting to be forward synched';
          RAISE skip_serial;

        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;

        l_instance_rec.instance_id            := fnd_api.g_miss_num;
        l_instance_rec.inventory_item_id      := srl_rec.inventory_item_id;
        l_instance_rec.serial_number          := srl_rec.serial_number;
        l_instance_rec.lot_number             := srl_rec.lot_number;
        l_instance_rec.mfg_serial_number_flag := 'Y';
        l_instance_rec.quantity               := 1;
        l_instance_rec.unit_of_measure        := srl_rec.uom_code;

        l_instance_rec.vld_organization_id    := srl_rec.organization_id;
        l_instance_rec.inv_organization_id    := srl_rec.organization_id;
        l_instance_rec.inv_subinventory_name  := srl_rec.subinventory_code;
        l_instance_rec.inv_locator_id         := srl_rec.locator_id;
        l_instance_rec.inventory_revision     := srl_rec.revision;

        l_instance_rec.location_type_code     := 'INVENTORY';
        l_instance_rec.instance_usage_code    := 'IN_INVENTORY';

        -- get inv location id from the subinv/org definition
        BEGIN
          SELECT location_id
          INTO   l_instance_rec.location_id
          FROM   mtl_secondary_inventories
          WHERE  secondary_inventory_name = l_instance_rec.inv_subinventory_name
          AND    organization_id          = l_instance_rec.vld_organization_id;

          IF l_instance_rec.location_id is null THEN
            SELECT location_id
            INTO   l_instance_rec.location_id
            FROM   hr_all_organization_units
            WHERE  organization_id = l_instance_rec.vld_organization_id;
          END IF;
        END;

        BEGIN
          SELECT instance_id ,
                 object_version_number
          INTO   l_instance_rec.instance_id,
                 l_instance_rec.object_version_number
          FROM   csi_item_instances
          WHERE  inventory_item_id = srl_rec.inventory_item_id
          AND    serial_number     = srl_rec.serial_number;

          l_instance := to_char(l_instance_rec.instance_id);
          l_instance_found := TRUE;
        EXCEPTION
          WHEN no_data_found THEN
            l_instance := 'NONE';
            l_instance_found := FALSE;
          WHEN too_many_rows THEN
            l_instance_found := TRUE;
            l_skip_error := '  Too Many Instances for this serial number';
            raise skip_serial;
        END;

        IF l_instance_found THEN
          -- check if the instance inv location attributes are the same as the serial attribute
          l_not_the_same := not_the_same(l_instance_rec);
        END IF;

        -- fixable candidates  (no serial found or not the same)
        IF l_not_the_same OR NOT(l_instance_found) THEN

          log(fill(srl_rec.serial_number, 15)||
            fill(to_char(srl_rec.inventory_item_id), 9)||
            fill(to_char(srl_rec.organization_id), 9)||
            fill(to_char(srl_rec.serial_code), 2)||
            fill(to_char(srl_rec.lot_code), 2)||
            fill(l_instance,9));

          IF l_not_the_same AND l_instance_found THEN
            dump_diff(l_instance_rec);
          END IF;

          /* loop thru all the material transactions after freeze date and check if
             there is any pending in xnp_msgs.

             also check if there is any  errors in csi_txn_errors. if found then skip
             the serial.
          */

          l_latest_txn := TRUE;

          l_txn_rec.transaction_id              := fnd_api.g_miss_num;
          l_txn_rec.transaction_type_id         := correction_txn_type_id;
          l_txn_rec.source_header_ref           := 'DATAFIX';
          l_txn_rec.source_line_ref             := 'SRLSYNC';
          l_txn_rec.source_transaction_date     := sysdate;
          l_txn_rec.transaction_date            := sysdate;

          FOR all_txn_rec in all_txn_cur (
            p_serial_number => srl_rec.serial_number,
            p_item_id       => srl_rec.inventory_item_id)
          LOOP

            IF all_txn_rec.mtl_txn_date > l_freeze_date THEN

            IF csi_inv_trxs_pkg.valid_ib_txn(all_txn_rec.mtl_txn_id) THEN

              IF l_latest_txn THEN

                log('  latest mtl_txn_id : '||all_txn_rec.mtl_txn_id);

                l_txn_rec.source_transaction_date     := all_txn_rec.mtl_txn_date;
                l_txn_rec.transaction_date            := all_txn_rec.mtl_txn_date;

                BEGIN
                  SELECT 'X' INTO l_txn_is_in_csi
                  FROM   sys.dual
                  WHERE  exists (
                    SELECT 'Y' FROM csi_transactions
                    WHERE  inv_material_transaction_id = all_txn_rec.mtl_txn_id);
                  l_txn_rec.inv_material_transaction_id := null;
                EXCEPTION
                  WHEN no_data_found THEN
                    l_txn_rec.inv_material_transaction_id := all_txn_rec.mtl_txn_id;
                END;

                l_latest_txn := FALSE;

              END IF;

              BEGIN
                SELECT 'Y' INTO l_pending_msg_found
                FROM   sys.dual
                WHERE  exists (
                  SELECT '1'
                  FROM   csi_xnp_msgs_temp
                  WHERE  source_type = 'MTL_TRANSACTION_ID'
                  AND    source_id   = all_txn_rec.mtl_txn_id
                  AND    nvl(msg_status, 'READY') <> 'PROCESSED');

                l_skip_error := '  Unprocessed Message in XNP_MSGS for MTL_TXN_ID: '||
                                 all_txn_rec.mtl_txn_id;
                RAISE skip_serial;

              EXCEPTION
                WHEN no_data_found THEN
                  null;
              END;

              BEGIN
                IF all_txn_rec.mtl_action_id in (2,3,28) THEN

                  SELECT 'Y' INTO l_pending_err_found
                  FROM   sys.dual
                  WHERE  exists (
                    SELECT '1'
                    FROM   csi_txn_errors
                    WHERE  (inv_material_transaction_id = all_txn_rec.mtl_txn_id
                            OR
                            inv_material_transaction_id = all_txn_rec.mtl_txn_id)
                    AND    processed_flag in ('E', 'R'));

                ELSE

                  SELECT 'Y' INTO l_pending_err_found
                  FROM sys.dual
                  WHERE exists (
                    SELECT '1'
                    FROM   csi_txn_errors
                    WHERE  inv_material_transaction_id = all_txn_rec.mtl_txn_id
                    AND    processed_flag in ('E', 'R'));

                END IF;
                l_skip_error := '  Pending Error in CSI_TXN_ERRORS for MTL_TXN_ID: '||
                                 all_txn_rec.mtl_txn_id;
                RAISE skip_serial;

              EXCEPTION
                WHEN no_data_found THEN
                  null;
              END;

            END IF; -- valid ib txb
            END IF; -- > freeze_date

          END LOOP;

          l_change_owner_flag := 'Y';
          l_owner_party_id    := null;
          l_owner_account_id  := null;

          get_rma_owner(
            p_serial_number     => srl_rec.serial_number,
            p_inventory_item_id => srl_rec.inventory_item_id,
            p_organization_id   => srl_rec.organization_id,
            x_change_owner_flag => l_change_owner_flag,
            x_owner_party_id    => l_owner_party_id,
            x_owner_account_id  => l_owner_account_id);

          IF l_change_owner_flag = 'Y' THEN
            l_owner_party_id := l_internal_party_id;
          END IF;

          log('  Change Owner    : '||l_change_owner_flag);
          log('  Owner Party ID  : '||l_owner_party_id);
          log('  Owner Account ID: '||l_owner_account_id);

          IF l_change_owner_flag = 'Y' THEN
            l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
            l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
            l_parties_tbl(1).party_id               := l_internal_party_id;
            l_parties_tbl(1).relationship_type_code := 'OWNER';
            l_parties_tbl(1).contact_flag           := 'N';
            l_parties_tbl(1).object_version_number  := 1.0;
          ELSE
            l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
            l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
            l_parties_tbl(1).party_id               := l_owner_party_id;
            l_parties_tbl(1).relationship_type_code := 'OWNER';
            l_parties_tbl(1).contact_flag           := 'N';
            l_parties_tbl(1).object_version_number  := 1.0;

            l_pty_accts_tbl(1).ip_account_id          := fnd_api.g_miss_num;
            l_pty_accts_tbl(1).party_account_id       := l_owner_account_id;
            l_pty_accts_tbl(1).relationship_type_code := 'OWNER';
            l_pty_accts_tbl(1).bill_to_address        := fnd_api.g_miss_num;
            l_pty_accts_tbl(1).ship_to_address        := fnd_api.g_miss_num;
            l_pty_accts_tbl(1).instance_party_id      := fnd_api.g_miss_num;
            l_pty_accts_tbl(1).parent_tbl_index       := 1;

          END IF;

          IF l_instance_found THEN

            SELECT instance_party_id,
                   object_version_number
            INTO   l_parties_tbl(1).instance_party_id,
                   l_parties_tbl(1).object_version_number
            FROM   csi_i_parties
            WHERE  instance_id = l_instance_rec.instance_id
            AND    relationship_type_code = 'OWNER';

            log('  csi_process_txn_pvt.check_and_break_relation');

            -- qualifieis for update
            csi_process_txn_pvt.check_and_break_relation(
              p_instance_id   => l_instance_rec.instance_id,
              p_csi_txn_rec   => l_txn_rec,
              x_return_status => l_return_status);

            SELECT object_version_number
            INTO   l_instance_rec.object_version_number
            FROM   csi_item_instances
            WHERE  instance_id = l_instance_rec.instance_id;

            log('  csi_item_instance_pub.update_item_instance');

            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_instance_rec,
              p_party_tbl             => l_parties_tbl,
              p_account_tbl           => l_pty_accts_tbl,
              p_org_assignments_tbl   => l_org_units_tbl,
              p_ext_attrib_values_tbl => l_ea_values_tbl,
              p_pricing_attrib_tbl    => l_pricing_tbl,
              p_asset_assignment_tbl  => l_assets_tbl,
              p_txn_rec               => l_txn_rec,
              x_instance_id_lst       => l_instance_ids_list,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data);

            -- For Bug 4057183
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              raise fnd_api.g_exc_error;
            END IF;

          ELSE -- instance not found

            log('  csi_item_instance_pub.create_item_instance');

            csi_item_instance_pub.create_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_instance_rec,
              p_party_tbl             => l_parties_tbl,
              p_account_tbl           => l_pty_accts_tbl,
              p_org_assignments_tbl   => l_org_units_tbl,
              p_ext_attrib_values_tbl => l_ea_values_tbl,
              p_pricing_attrib_tbl    => l_pricing_tbl,
              p_asset_assignment_tbl  => l_assets_tbl,
              p_txn_rec               => l_txn_rec,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data );

            -- For Bug 4057183
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;

        END IF;
      EXCEPTION
        WHEN skip_serial THEN
          log(fill(srl_rec.serial_number, 15)||
              fill(to_char(srl_rec.inventory_item_id), 9)||
              fill(to_char(srl_rec.organization_id), 9)||
              fill(to_char(srl_rec.serial_code), 2)||
              fill(to_char(srl_rec.lot_code), 2));
          log(l_skip_error);
        WHEN fnd_api.g_exc_error THEN
          l_error_message :=  csi_t_gen_utility_pvt.dump_error_stack;
          log(fill(srl_rec.serial_number, 15)||
              fill(to_char(srl_rec.inventory_item_id), 9)||
              fill(to_char(srl_rec.organization_id), 9)||
              fill(to_char(srl_rec.serial_code), 2)||
              fill(to_char(srl_rec.lot_code), 2));
          log('  Error : '||l_error_message);
      END;

      IF mod(inv_srl_cur%rowcount,100) = 0 THEN
        commit;
      END IF;

    END LOOP;

  END sync_inv_serials;
  --
  PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    ) IS
    --
    l_rel_type_code          VARCHAR2(30) := 'COMPONENT-OF';
    --
     CURSOR REL_CUR IS
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.object_id = p_object_id
     and   cir.relationship_type_code = l_rel_type_code
     and   ((cir.active_end_date is null) or (cir.active_end_date > sysdate))
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES cii
                   where cii.instance_id = cir.subject_id
                   and  ((active_end_date is null) or (active_end_date > sysdate)));
     --
     l_ctr      NUMBER := 0;
  BEGIN
     FOR rel in REL_CUR LOOP
	l_ctr := l_ctr + 1;
	p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	p_rel_tbl(l_ctr).object_id := rel.object_id;
	p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	p_rel_tbl(l_ctr).display_order := rel.display_order;
	p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	p_rel_tbl(l_ctr).context := rel.context;
	p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
     END LOOP;
  END Get_Next_Level;
  --
  PROCEDURE missing_mtl_txn_id_in_csi IS

    TYPE NumTabType is  varray(10000) of number;

    l_csi_txn_id_tab     NumTabType;
    l_rma_line_id_tab    NumTabType;
    l_mtl_txn_id_tab     NumTabType;

    MAX_BUFFER_SIZE      number := 1000;

    CURSOR rma_txn_cur IS
      SELECT transaction_id,
             source_line_ref_id,
             inv_material_transaction_id
      FROM   csi_transactions
      WHERE  transaction_type_id = 53
      AND    inv_material_transaction_id is null;

    l_inventory_item_id  number;
    l_organization_id    number;
    l_mtl_txn_id         number;

    CURSOR mmt_cur(p_line_id in number, p_item_id in number, p_organization_id in number) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_type_id = 15 -- RMA Transaction
      AND    inventory_item_id   = p_item_id
      AND    organization_id     = p_organization_id
      AND    trx_source_line_id  = p_line_id
      order by creation_date desc, transaction_id desc;

  BEGIN

    OPEN rma_txn_cur;
    LOOP

      FETCH rma_txn_cur BULK COLLECT
      INTO  l_csi_txn_id_tab,
            l_rma_line_id_tab,
            l_mtl_txn_id_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_csi_txn_id_tab.COUNT
      LOOP

        IF l_rma_line_id_tab(ind) is not null THEN

          SELECT inventory_item_id,
                 ship_from_org_id
          INTO   l_inventory_item_id,
                 l_organization_id
          FROM   oe_order_lines_all
          WHERE  line_id = l_rma_line_id_tab(ind);

          l_mtl_txn_id  := null;

          FOR mmt_rec IN mmt_cur(l_rma_line_id_tab(ind), l_inventory_item_id, l_organization_id)
          LOOP
            l_mtl_txn_id := mmt_rec.transaction_id;
            exit;
          END LOOP;

          IF l_mtl_txn_id is not null THEN
            l_mtl_txn_id_tab(ind) := l_mtl_txn_id;
          END IF;

        END IF;
      END LOOP;

      FORALL u_ind in 1 .. l_csi_txn_id_tab.count
        UPDATE csi_transactions
        SET    inv_material_transaction_id = l_mtl_txn_id_tab(u_ind)
        WHERE  transaction_id              = l_csi_txn_id_tab(u_ind);

      commit;

      EXIT when rma_txn_cur%NOTFOUND;

    END LOOP;

    commit;

    IF rma_txn_cur%ISOPEN THEN
      CLOSE rma_txn_cur;
    END IF;

  END  missing_mtl_txn_id_in_csi;

  --
  --
  PROCEDURE Delete_Dup_Srl_Inv_Instance IS
     CURSOR CHECK_CUR IS
     select count(*)
     from CSI_ITEM_INSTANCES
     where location_type_code = 'INVENTORY'
     and   instance_usage_code = 'IN_INVENTORY'
     and   creation_date = last_update_date
     and   serial_number is not null
     and   lot_number is null
     group by inventory_item_id,serial_number
     having count(*) > 1 ;
     --
     CURSOR CSI_CUR(p_min IN NUMBER,p_max IN NUMBER) IS
     select instance_id,
	    inventory_item_id,
	    inv_organization_id,
	    inventory_revision,
	    inv_subinventory_name,
	    inv_locator_id,
	    serial_number,
	    last_update_date
     from csi_item_instances
     where instance_id between p_min and p_max
     and   serial_number is not null
     and   lot_number is null
     and   location_type_code = 'INVENTORY'
     and   instance_usage_code = 'IN_INVENTORY'
     and   migrated_flag = 'Y'
     and   mfg_serial_number_flag = 'Y'
     and   last_update_date = creation_date;
     --
     CURSOR MIN_CSI IS
     select min(instance_id)
     from csi_item_instances
     where serial_number is not null
     and   lot_number is null
     and   location_type_code = 'INVENTORY'
     and   instance_usage_code = 'IN_INVENTORY'
     and   migrated_flag = 'Y'
     and   mfg_serial_number_flag = 'Y'
     and   last_update_date = creation_date;
     --
     CURSOR MAX_CSI IS
     select max(instance_id)
     from csi_item_instances
     where serial_number is not null
     and   lot_number is null
     and   location_type_code = 'INVENTORY'
     and   instance_usage_code = 'IN_INVENTORY'
     and   migrated_flag = 'Y'
     and   mfg_serial_number_flag = 'Y'
     and   last_update_date = creation_date;
     --
     CURSOR TXN_CUR(p_instance_id IN NUMBER) IS
     SELECT transaction_id
     from CSI_INST_TRANSACTIONS_V
     where instance_id = p_instance_id;
     --
     TYPE NUMLIST is TABLE of NUMBER INDEX BY BINARY_INTEGER;
     l_instance_tbl         NUMLIST;
     l_txn_tbl              NUMLIST;
     --
     v_min                  NUMBER;
     v_max                  NUMBER;
     v_low                  NUMBER;
     v_high                 NUMBER;
     v_batch                NUMBER := nvl(FND_PROFILE.VALUE('CS_UPG_BATCHSIZE'),100);
     v_start                NUMBER;
     v_end                  NUMBER;
     v_diff                 NUMBER;
     v_batch_counter        NUMBER := 0;
     v_ins_count            NUMBER := 0;
     v_txn_count            NUMBER := 0;
     v_commit_counter       NUMBER := 0;
     v_subinv               VARCHAR2(10);
     v_locator_id           NUMBER;
     v_revision             VARCHAR2(3);
     v_org_id               NUMBER;
     v_recount              NUMBER;
     --
     Process_next           EXCEPTION;
     comp_error             EXCEPTION;
  BEGIN
     v_recount := 0;
     OPEN CHECK_CUR;
     FETCH CHECK_CUR INTO v_recount;
     CLOSE CHECK_CUR;
     --
     IF nvl(v_recount,0) = 0 THEN
	Raise comp_error;
     END IF;
     --
     OPEN MIN_CSI;
     FETCH MIN_CSI into v_low;
     CLOSE MIN_CSI;
     --
     OPEN MAX_CSI;
     FETCH MAX_CSI into v_high;
     CLOSE MAX_CSI;
     --
     v_diff  := ceil((v_high - v_low)/v_batch);
     v_start := v_low;
     v_end   := v_low + v_diff;
     v_batch_counter := 1;
     --
     l_instance_tbl.DELETE;
     l_txn_tbl.DELETE;
     LOOP
	For csi_rec in CSI_CUR(v_start,v_end)
	Loop
	   Begin
	      Begin
		 select mmt.subinventory_code,mmt.locator_id,mmt.organization_id,mmt.revision
		 into v_subinv,v_locator_id,v_org_id,v_revision
		 from MTL_MATERIAL_TRANSACTIONS mmt
		 where mmt.transaction_id = (select max(transaction_id)
					     from MTL_UNIT_TRANSACTIONS
					     where serial_number = csi_rec.serial_number
					     and   inventory_item_id = csi_rec.inventory_item_id
					     and   last_update_date <= csi_rec.last_update_date);
	      Exception
		 when others then
		    Raise Process_next;
	      End;
	      --
	      if ((v_subinv <> csi_rec.inv_subinventory_name) OR
		  (nvl(v_locator_id,-999) <> nvl(csi_rec.inv_locator_id,-999)) OR
		  (nvl(v_revision,'$#$') <> nvl(csi_rec.inventory_revision,'$#$')) OR
		  (v_org_id <> csi_rec.inv_organization_id)) then
		 v_ins_count := v_ins_count + 1;
		 l_instance_tbl(v_ins_count) := csi_rec.instance_id;
		 For txn in TXN_CUR(csi_rec.instance_id) Loop
		    v_txn_count := v_txn_count + 1;
		    l_txn_tbl(v_txn_count) := txn.transaction_id;
		 End Loop;
	      end if;
	      --
	   Exception
	      when Process_next then
		 null;
	   End;
	End Loop;
	--
	v_batch_counter := v_batch_counter + 1;
	EXIT WHEN v_min = v_max;
	EXIT WHEN v_end = v_max;
	EXIT WHEN v_batch_counter > v_batch;
	v_start := v_end + 1;
	--
	if v_batch_counter <> v_batch then
	   v_end := v_end + v_diff;
	else
	   v_end := v_high;
	end if;
	--
	if v_start > v_max then
	   v_start := v_max;
	end if;
	--
	if v_end > v_max then
	   v_end := v_max;
	end if;
	--
	commit;
     END LOOP;
     commit;
     --
     IF l_instance_tbl.count > 0 THEN
       BEGIN
	  FORALL j in l_instance_tbl.FIRST .. l_instance_tbl.LAST
	     DELETE FROM CSI_ITEM_INSTANCES WHERE instance_id = l_instance_tbl(j);
	  FORALL j in l_instance_tbl.FIRST .. l_instance_tbl.LAST
	     DELETE FROM CSI_I_PARTIES WHERE instance_id = l_instance_tbl(j);
	  FORALL j in l_instance_tbl.FIRST .. l_instance_tbl.LAST
	     DELETE FROM CSI_I_VERSION_LABELS WHERE instance_id = l_instance_tbl(j);
	  FORALL j in l_txn_tbl.FIRST .. l_txn_tbl.LAST
	     DELETE FROM CSI_ITEM_INSTANCES_H WHERE transaction_id = l_txn_tbl(j);
	  FORALL j in l_txn_tbl.FIRST .. l_txn_tbl.LAST
	     DELETE FROM CSI_I_PARTIES_H WHERE transaction_id = l_txn_tbl(j);
	  FORALL j in l_txn_tbl.FIRST .. l_txn_tbl.LAST
	     DELETE FROM CSI_I_VERSION_LABELS_H WHERE transaction_id = l_txn_tbl(j);
	  FORALL j in l_txn_tbl.FIRST .. l_txn_tbl.LAST
	     DELETE FROM CSI_TRANSACTIONS WHERE transaction_id = l_txn_tbl(j);
       END;
     END IF;
     commit;
     --
  EXCEPTION
     when comp_error then
	null;
  END Delete_Dup_Srl_Inv_Instance;
  --
  PROCEDURE Update_Instance_Usage IS
    CURSOR CSI_CUR IS
    Select instance_id,location_type_code
	  ,serial_number_control_code,serial_number,null usage_code
    from CSI_ITEM_INSTANCES cii
	,MTL_SYSTEM_ITEMS_B msi
    Where cii.instance_usage_code is NULL
    and   msi.inventory_item_id = cii.inventory_item_id
    and   msi.organization_id = cii.last_vld_organization_id;
    --
    l_exists                 VARCHAR2(1);
    l_rel_type_code          VARCHAR2(30) := 'COMPONENT-OF';
    --
    Type NumTabType is VARRAY(10000) of NUMBER;
    instance_id_mig          NumTabType;
    serial_code_mig          NumTabType;
    --
    Type V30TabType is VARRAY(10000) of VARCHAR2(30);
    location_type_mig        V30TabType;
    serial_number_mig        V30TabType;
    usage_code_mig           V30TabType;
    --
    MAX_BUFFER_SIZE          NUMBER := 1000;
 BEGIN
    OPEN CSI_CUR;
    LOOP
       FETCH CSI_CUR BULK COLLECT INTO
       instance_id_mig,
       location_type_mig,
       serial_code_mig,
       serial_number_mig,
       usage_code_mig
       LIMIT MAX_BUFFER_SIZE;
       --
       FOR i in 1 .. instance_id_mig.count LOOP
	  If serial_code_mig(i) = 6 and
	     serial_number_mig(i) is not NULL and
	     location_type_mig(i) = 'INVENTORY' Then
	     usage_code_mig(i) := 'RETURNED';
	  Else
	     if location_type_mig(i) = 'INVENTORY' then
		usage_code_mig(i) := 'IN_INVENTORY';
             elsif location_type_mig(i) = 'WIP' then
                usage_code_mig(i) := 'IN_WIP';
	     else
		usage_code_mig(i) := 'OUT_OF_ENTERPRISE';
	     end if;
	  End if;
	  Begin
	     select 'x'
	     into l_exists
	     from CSI_II_RELATIONSHIPS
	     where subject_id = instance_id_mig(i)
	     and   relationship_type_code = l_rel_type_code
             and   ((active_end_date is null) or (active_end_date > sysdate));
	     usage_code_mig(i) := 'IN_RELATIONSHIP';
	  Exception
	     when no_data_found then
		null;
	  End;
       --
       END LOOP;
       FORALL j in 1 .. instance_id_mig.count
	  UPDATE CSI_ITEM_INSTANCES
	  set instance_usage_code = usage_code_mig(j)
	     ,last_update_date = sysdate
	  where instance_id = instance_id_mig(j);
       commit;
       EXIT WHEN CSI_CUR%NOTFOUND;
    END LOOP;
    commit;
    CLOSE CSI_CUR;
  END Update_Instance_Usage;
  --
  PROCEDURE Update_Full_dump_flag IS
    CURSOR CSI_REL_CUR IS
    SELECT relationship_history_id
    FROM CSI_II_RELATIONSHIPS_H
    WHERE nvl(MIGRATED_FLAG,'N') = 'Y'
    AND   full_dump_flag <> 'Y';
    --
    CURSOR CSI_SYS_CUR IS
    SELECT system_id,min(system_history_id) system_history_id
    FROM CSI_SYSTEMS_H
    WHERE nvl(MIGRATED_FLAG,'N') = 'Y'
    AND   full_dump_flag <> 'Y'
    group by system_id;
    --
    Type NumTabType is VARRAY(10000) of NUMBER;
    rel_history_id_mig     NumTabType;
    system_id_mig          NumTabType;
    system_history_id_mig  NumTabType;
    --
    MAX_BUFFER_SIZE        NUMBER := 1000;
 BEGIN
    OPEN CSI_REL_CUR;
    LOOP
       FETCH CSI_REL_CUR BULK COLLECT INTO
       rel_history_id_mig
       LIMIT MAX_BUFFER_SIZE;
       FORALL j in 1 .. rel_history_id_mig.count
	  update CSI_II_RELATIONSHIPS_H
	  set full_dump_flag = 'Y'
	  where relationship_history_id = rel_history_id_mig(j);
       commit;
       --
       EXIT WHEN CSI_REL_CUR%NOTFOUND;
    END LOOP;
    commit;
    CLOSE CSI_REL_CUR;
    --
    OPEN CSI_SYS_CUR;
    LOOP
       FETCH CSI_SYS_CUR BULK COLLECT INTO
       system_id_mig,
       system_history_id_mig
       LIMIT MAX_BUFFER_SIZE;
       FORALL j in 1 .. system_id_mig.count
	  UPDATE CSI_SYSTEMS_H
	  set full_dump_flag = 'Y'
	  where system_history_id = system_history_id_mig(j);
       commit;
       --
       EXIT WHEN CSI_SYS_CUR%NOTFOUND;
    END LOOP;
    commit;
    CLOSE CSI_SYS_CUR;
 END Update_Full_dump_flag;
 --
 PROCEDURE Del_API_Dup_Srl_Instance IS
    cursor check_count is
    select count(*)
    from   csi_item_instances
    where  serial_number is not null
    group  by serial_number, inventory_item_id
    having count(*) > 1;
    --
    cursor c1 is
    select count(*), serial_number, inventory_item_id
    from   csi_item_instances
    where  serial_number is not null
    group  by serial_number, inventory_item_id
    having count(*) > 1;
    --
    cursor c4(p_serial_number varchar, p_inventory_item_id number) is
    select instance_id,instance_status_id
    from   csi_item_instances
    where  serial_number = p_serial_number
    and    inventory_item_id = p_inventory_item_id
    order  by instance_id desc;
    --
    v_commit_count       NUMBER := 0;
    v_recount            NUMBER;
    v_instance_status_id NUMBER;
    v_duplicate_count    NUMBER;
    v_instance_id        NUMBER;
    v_status_id          NUMBER;
    --
    comp_error           EXCEPTION;
 BEGIN
    v_recount := 0;
    OPEN check_count;
    FETCH check_count into v_recount;
    CLOSE check_count;
    --
    IF nvl(v_recount,0) = 0 THEN
       Raise comp_error;
    END IF;
    --
    begin
       select instance_status_id
       into   v_instance_status_id
       from   CSI_INSTANCE_STATUSES
       where  name = 'EXPIRED';
    exception
       when no_data_found then
	  raise_application_error(-20000,'You need to setup an Expired Instance Status');
	  return;
       when too_many_rows then
	  raise_application_error(-20000,'Too many definition for Expired Instance Status');
	  return;
    end;

    for i in c1
    loop
       v_instance_id := null;
       v_commit_count := v_commit_count + 1;
       --
       v_duplicate_count := 0;
       --
       Begin
	  select max(instance_id)
	  into v_instance_id
	  from csi_item_instances
	  where inventory_item_id = i.inventory_item_id
	  and   serial_number = i.serial_number;
       End;
       --
       for j in c4(i.serial_number, i.inventory_item_id)
       loop
	  if v_instance_id <> j.instance_id then
	     v_duplicate_count := v_duplicate_count + 1;

	     update csi_item_instances_h
	     set    old_serial_number = i.serial_number
		    ,new_serial_number = new_serial_number||'-DUP'||to_char(v_duplicate_count)
		    ,last_updated_by = fnd_global.user_id
		    ,last_update_date = sysdate
		    ,old_instance_status_id = j.instance_status_id
		    ,new_instance_status_id = v_instance_status_id
	     where  instance_history_id = (select max(instance_history_id)
					   from csi_item_instances_h
					   where instance_id = j.instance_id);
	     --
	     update csi_item_instances
	     set    serial_number = serial_number||'-DUP'||to_char(v_duplicate_count)
		    ,active_end_date = sysdate
		    ,instance_status_id = v_instance_status_id
		    ,last_updated_by = fnd_global.user_id
		    ,last_update_date = sysdate
	     where  instance_id = j.instance_id;
	  end if;
       end loop;
       --
       if v_commit_count >= 500 then
	  commit;
	  v_commit_count := 0;
       end if;
       --
    end loop;
    commit;
 EXCEPTION
    when comp_error then
       null;
 END Del_API_Dup_Srl_Instance;
 --
 PROCEDURE Update_Vld_Organization IS
   CURSOR CSI_INS_CUR IS
   SELECT instance_id,inventory_item_id,inv_organization_id,last_vld_organization_id
         ,serial_number,lot_number
         ,mfg_serial_number_flag,creation_complete_flag
         ,inventory_revision
         ,instance_usage_code
   FROM CSI_ITEM_INSTANCES
   WHERE location_type_code = 'INVENTORY'
   AND   inv_organization_id is not null
   AND   nvl(last_vld_organization_id,-999) <> inv_organization_id;
   --
   l_instance_rec      csi_datastructures_pub.instance_rec;
   l_temp_instance_rec csi_datastructures_pub.instance_rec;
   l_txn_rec           csi_datastructures_pub.transaction_rec;
   l_return_value      BOOLEAN;
   --
   Type NumTabType is VARRAY(10000) of NUMBER;
   instance_id_mig          NumTabType;
   item_id_mig              NumTabType;
   inv_org_id_mig           NumTabType;
   vld_org_id_mig           NumTabType;
   --
   Type V30Type is VARRAY(10000) of VARCHAR2(30);
   serial_number_mig        V30Type;
   usage_mig                V30Type;

   Type V80Type is VARRAY(10000) of VARCHAR2(80);
   lot_number_mig           V80Type;
   --
   Type V3Type is VARRAY(10000) of VARCHAR2(3);
   revision_mig             V3Type;
   --
   Type V1Type is VARRAY(10000) of VARCHAR2(1);
   mfg_srl_flag_mig         V1Type;
   complete_flag_mig        V1Type;
   --
   MAX_BUFFER_SIZE          NUMBER := 1000;
   --
   Process_Next             EXCEPTION;
BEGIN
   OPEN CSI_INS_CUR;
   LOOP
      FETCH CSI_INS_CUR BULK COLLECT INTO
      instance_id_mig,
      item_id_mig,
      inv_org_id_mig,
      vld_org_id_mig,
      serial_number_mig,
      lot_number_mig,
      mfg_srl_flag_mig,
      complete_flag_mig,
      revision_mig,
      usage_mig
      LIMIT MAX_BUFFER_SIZE;
      --
      FOR i in 1 .. instance_id_mig.count LOOP
         l_instance_rec := l_temp_instance_rec;
         --
         -- Need to validate against inv_organization_id since we update the instance with this org.
         --
         l_instance_rec.instance_id := instance_id_mig(i);
         l_instance_rec.inventory_item_id := item_id_mig(i);
         l_instance_rec.vld_organization_id := inv_org_id_mig(i);
         l_instance_rec.serial_number := serial_number_mig(i);
         l_instance_rec.lot_number := lot_number_mig(i);
         l_instance_rec.location_type_code := 'INVENTORY';
         l_instance_rec.mfg_serial_number_flag := mfg_srl_flag_mig(i);
         l_instance_rec.creation_complete_flag := complete_flag_mig(i);
         l_instance_rec.inventory_revision := revision_mig(i);
         l_instance_rec.instance_usage_code := usage_mig(i);
         --
         csi_Item_Instance_Vld_pvt.Validate_org_dependent_params
            ( p_instance_rec   => l_instance_rec
             ,p_txn_rec        => l_txn_rec
             ,l_return_value   => l_return_value
            );
         --
         IF l_return_value = TRUE THEN
            vld_org_id_mig(i) := inv_org_id_mig(i);
         END IF;
         --
      END LOOP;
      FORALL j in 1 .. instance_id_mig.count
         Update CSI_ITEM_INSTANCES
         set last_vld_organization_id = vld_org_id_mig(j)
         where instance_id = instance_id_mig(j);
      --
      commit;
      --
      FORALL j in 1 .. instance_id_mig.count
         Update CSI_ITEM_INSTANCES_H
         set new_last_vld_organization_id = vld_org_id_mig(j)
         where instance_history_id = (select max(instance_history_id) from CSI_ITEM_INSTANCES_H
                                      where instance_id = instance_id_mig(j));
      --
      commit;
      --
      EXIT WHEN CSI_INS_CUR%NOTFOUND;
   END LOOP;
   commit;
   CLOSE CSI_INS_CUR;
 END Update_Vld_Organization;
 --
 PROCEDURE Update_Revision IS
    CURSOR c1 IS
    SELECT a.instance_id
	  ,a.inventory_item_id
	  ,a.last_vld_organization_id
	  ,a.last_oe_order_line_id
	  ,a.serial_number
	  ,a.inventory_revision
    FROM  csi_item_instances a
	 ,mtl_system_items_b b
    WHERE a.inventory_item_id = b.inventory_item_id
    AND   a.last_vld_organization_id = b.organization_id
    AND   a.creation_complete_flag = 'Y'
    AND   a.inventory_revision IS NULL
    AND   a.migrated_flag = 'Y'
    AND   b.revision_qty_control_code = 2;

    Type NumTabType is VARRAY(10000) of NUMBER;
    instance_id_mig           NumTabType;
    item_id_mig               NumTabType;
    vld_org_id_mig            NumTabType;
    order_line_id_mig         NumTabType;
    l_schema_name             varchar2(30);
    l_object_name             varchar2(80);
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_sql_stmt                varchar2(2000);
    --
    Type V30Type is VARRAY(10000) of VARCHAR2(30);
    serial_number_mig        V30Type;
    --
    Type V3Type is VARRAY(10000) of VARCHAR2(3);
    revision_mig             V3Type;
    --
    MAX_BUFFER_SIZE          NUMBER := 1000;
 BEGIN
    get_schema_name(
      p_product_short_name  => 'CS',
      x_schema_name         => l_schema_name,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
       RETURN;
    END IF;
    --
    l_object_name := l_schema_name||'.CS_CUSTOMER_PRODUCTS_ALL_OLD cp';
    --
    l_sql_stmt := 'select cr.revision from CS_CP_REVISIONS cr, '||l_object_name || ' where cp.customer_product_id = :inst_id and cr.cp_revision_id = cp.current_cp_revision_id';
    --
    OPEN c1;
    LOOP
       FETCH c1 BULK COLLECT INTO
       instance_id_mig,
       item_id_mig,
       vld_org_id_mig,
       order_line_id_mig,
       serial_number_mig,
       revision_mig
       LIMIT MAX_BUFFER_SIZE;
       --
       FOR i in 1 .. instance_id_mig.count LOOP
	  Begin
             EXECUTE IMMEDIATE l_sql_stmt INTO revision_mig(i) USING instance_id_mig(i);
	  Exception
	     when others then
		revision_mig(i) := null;
	  End;
	  --
	  IF revision_mig(i) is null and order_line_id_mig(i) is not null THEN
	     Begin
		select revision
		into revision_mig(i)
		from MTL_MATERIAL_TRANSACTIONS
		where transaction_type_id = 33
		and   transaction_action_id = 1
		and   trx_source_line_id = order_line_id_mig(i)
		and   rownum < 2;
	     Exception
		when no_data_found then
		   Begin
		      select item_revision
		      into revision_mig(i)
		      from OE_ORDER_LINES_ALL
		      where line_id = order_line_id_mig(i);
		   Exception
		      when no_data_found then
			 revision_mig(i) := null;
		   End;
	     End;
	  END IF;
	  --
	  IF revision_mig(i) is null AND serial_number_mig(i) is not null THEN
	     Begin
		select revision
		into revision_mig(i)
		from MTL_SERIAL_NUMBERS
		where inventory_item_id = item_id_mig(i)
		and   serial_number = serial_number_mig(i);
	     Exception
		when no_data_found then
		   revision_mig(i) := null;
	     End;
	  END IF;
       END LOOP;
       --
       FORALL j in 1 .. instance_id_mig.count
	  UPDATE csi_item_instances
	  SET    inventory_revision = revision_mig(j)
	  WHERE  instance_id = instance_id_mig(j);
       commit;
       --
       FORALL j in 1 .. instance_id_mig.count
	  Update CSI_ITEM_INSTANCES_H
	  set new_inventory_revision = revision_mig(j)
	  where instance_history_id = (select max(instance_history_id) from CSI_ITEM_INSTANCES_H
				       where instance_id = instance_id_mig(j));
       --
       commit;
       --
       EXIT WHEN c1%NOTFOUND;
    END LOOP;
    commit;
    CLOSE c1;
 END Update_Revision;
 --
 PROCEDURE Update_Dup_Srl_Instance IS
    CURSOR CSI_CUR IS -- Cursor to delete the Inv instances emerged from wrong WHERE clause in Mig
    select cii.instance_id
    from CSI_ITEM_INSTANCES cii
    where cii.location_type_code = 'INVENTORY'
    and   cii.instance_usage_code = 'IN_INVENTORY'
    and   mfg_serial_number_flag = 'Y'
    and   cii.serial_number is not null
    and   cii.lot_number is not null
    and   cii.migrated_flag = 'Y'
    and   cii.creation_date = cii.last_update_date
    and   not exists (select 'X' from mtl_serial_numbers msn
		      where msn.inventory_item_id = cii.inventory_item_id
		      and   msn.serial_number = cii.serial_number
		      and   msn.lot_number = cii.lot_number);
    --
    CURSOR TXN_CUR(p_instance_id IN NUMBER) IS
    SELECT transaction_id
    from CSI_INST_TRANSACTIONS_V
    where instance_id = p_instance_id;
    --
    l_ins_count        NUMBER := 0;
    l_txn_count        NUMBER := 0;
    --
    Type NumTabType is VARRAY(10000) of NUMBER;
    instance_id_mig     NumTabType;
    --
    MAX_BUFFER_SIZE     NUMBER := 1000;
    TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_del_inst_tbl      NUMLIST;
    l_del_txn_tbl       NUMLIST;
    --
    cursor c1 is
    select count(*), serial_number, inventory_item_id
    from   csi_item_instances
    where  migrated_flag = 'Y'
    and    serial_number is not null
    group  by serial_number, inventory_item_id
    having count(*) > 1;

    cursor c2(p_serial_number varchar, p_inventory_item_id number) is
    select max(instance_id)
    from   csi_item_instances
    where  serial_number = p_serial_number
    and    inventory_item_id = p_inventory_item_id
    and    location_type_code = 'INVENTORY'
    and    instance_usage_code = 'IN_INVENTORY'
    and    inv_subinventory_name IS NOT NULL
    and    inv_organization_id IS NOT NULL;

    cursor c3(p_serial_number varchar, p_inventory_item_id number) is
    select max(instance_id)
    from   csi_item_instances
    where  serial_number = p_serial_number
    and    inventory_item_id = p_inventory_item_id;

    cursor c5(p_serial_number varchar, p_inventory_item_id number) is
    select max(instance_id)
    from   csi_item_instances
    where  serial_number = p_serial_number
    and    inventory_item_id = p_inventory_item_id
    and    last_oe_rma_line_id is not null
    and    migrated_flag = 'Y';

    cursor c4(p_serial_number varchar, p_inventory_item_id number) is
    select instance_id,instance_status_id
    from   csi_item_instances
    where  serial_number = p_serial_number
    and    inventory_item_id = p_inventory_item_id
    order  by instance_id desc;
    --
    cursor c6(p_inst_id1 number,p_inst_id2 number) is
    select transaction_id
    from csi_item_instances_h
    where instance_id = p_inst_id1
    intersect
    select transaction_id
    from csi_item_instances_h
    where instance_id = p_inst_id2;

    v_commit_count       NUMBER := 0;
    v_instance_status_id NUMBER;
    v_duplicate_count    NUMBER;
    v_instance_id        NUMBER;
    v_inv_instance_id    NUMBER;
    v_cp_instance_id     NUMBER;
    v_inv_exists         VARCHAR2(1) := 'N';
    v_terminated_flag    VARCHAR2(1);
    v_ret_instance_id    NUMBER;
    v_srl_control        NUMBER;
    v_inst_usage_code    VARCHAR2(30);
    v_org_id             NUMBER;
    v_subinv             VARCHAR2(10);
    v_locator            NUMBER;
    v_loc_id             NUMBER;
    v_status_id          NUMBER;
    v_status             VARCHAR2(50);
    v_txn_id             NUMBER;
    v_freeze_date        DATE;
    v_rev                VARCHAR2(3);
    l_schema_name        varchar2(30);
    l_object_name        varchar2(80);
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
    l_sql_stmt           varchar2(2000);
    --
 BEGIN
    get_schema_name(
      p_product_short_name  => 'CS',
      x_schema_name         => l_schema_name,
      x_return_status       => l_return_status);
    --
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
       RETURN;
    END IF;
    --
    l_object_name := l_schema_name||'.CS_CUSTOMER_PRODUCTS_ALL_OLD cp';
    --
    l_sql_stmt := 'select terminated_flag,cp.customer_product_status_id from CSI_INSTANCE_STATUSES cis, '||l_object_name||' where cp.customer_product_id = :inst_id and cis.instance_status_id = cp.customer_product_status_id';
    --
    BEGIN -- First
       OPEN CSI_CUR;
       LOOP
	  FETCH CSI_CUR BULK COLLECT INTO
	  instance_id_mig
	  LIMIT MAX_BUFFER_SIZE;
	  --
	  FOR i in 1 .. instance_id_mig.count LOOP
	     l_ins_count := l_ins_count + 1;
	     l_del_inst_tbl(l_ins_count) := instance_id_mig(i);
	     FOR txn_rec in TXN_CUR(instance_id_mig(i)) LOOP
		l_txn_count := l_txn_count + 1;
		l_del_txn_tbl(l_txn_count) := txn_rec.transaction_id;
	     END LOOP;
	  END LOOP;
	  EXIT WHEN CSI_CUR%NOTFOUND;
       END LOOP;
       CLOSE CSI_CUR;
       --
       IF l_del_inst_tbl.count > 0 THEN
	 BEGIN
	    FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
	       DELETE FROM CSI_ITEM_INSTANCES WHERE instance_id = l_del_inst_tbl(j);
	    FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
	       DELETE FROM CSI_I_PARTIES WHERE instance_id = l_del_inst_tbl(j);
	    FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
	       DELETE FROM CSI_I_VERSION_LABELS WHERE instance_id = l_del_inst_tbl(j);
	    FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
	       DELETE FROM CSI_ITEM_INSTANCES_H WHERE transaction_id = l_del_txn_tbl(j);
	    FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
	       DELETE FROM CSI_I_PARTIES_H WHERE transaction_id = l_del_txn_tbl(j);
	    FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
	       DELETE FROM CSI_I_VERSION_LABELS_H WHERE transaction_id = l_del_txn_tbl(j);
	    FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
	       DELETE FROM CSI_TRANSACTIONS WHERE transaction_id = l_del_txn_tbl(j);
	 END;
       END IF;
       commit;
    END; -- First
    commit;
    --
    BEGIN -- Second Update
       begin
	  select instance_status_id
	  into   v_instance_status_id
	  from   CSI_INSTANCE_STATUSES
	  where  name = 'EXPIRED';
       exception
	  when no_data_found then
	     raise_application_error(-20000,'You need to setup an Expired Instance Status');
	     return;
	  when too_many_rows then
	     raise_application_error(-20000,'Too many definition for Expired Instance Status');
	     return;
       end;
       --
       IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
       END IF;
       --
       v_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
       --
       for i in c1
       loop
	  v_inv_instance_id := null;
	  v_cp_instance_id := null;
	  v_instance_id := null;
	  v_ret_instance_id := null;
	  v_terminated_flag := 'X';
	  v_org_id := null;
	  v_subinv := null;
	  v_locator := null;
	  v_loc_id := null;
	  v_status_id := null;
          v_status := null;
	  v_commit_count := v_commit_count + 1;

	  open c2(i.serial_number, i.inventory_item_id);
	  fetch c2 into v_inv_instance_id;
	  close c2;
	  --
	  if v_inv_instance_id is null then
	     open c3(i.serial_number, i.inventory_item_id);
	     fetch c3 into v_cp_instance_id;
	     close c3;
	     --
	     v_instance_id := v_cp_instance_id;
	  else -- INV instance found
	     -- Try to get the last RMA instance
	     open c5(i.serial_number, i.inventory_item_id);
	     fetch c5 into v_ret_instance_id;
	     close c5;
	     --
	     if v_ret_instance_id is not null then -- RMA instance found
		Begin
                   EXECUTE IMMEDIATE l_sql_stmt INTO v_terminated_flag,v_status_id USING v_ret_instance_id;
		Exception
		   when others then
		      null;
		End;
		--
		if v_terminated_flag = 'Y' then -- Instance will be owned by Internal
		   v_instance_id := v_inv_instance_id;
		else
		   v_instance_id := v_ret_instance_id;
		   Begin
		      select location_id,inv_organization_id
			    ,inv_subinventory_name,inv_locator_id,inventory_revision
		      into v_loc_id,v_org_id,v_subinv,v_locator,v_rev
		      from CSI_ITEM_INSTANCES
		      where instance_id = v_inv_instance_id;
		      --
		   Exception
		      when no_data_found then
			 null;
		   End;
		   --
		   Begin
		      select serial_number_control_code
		      into v_srl_control
		      from MTL_SYSTEM_ITEMS_B
		      where inventory_item_id = i.inventory_item_id
		      and   organization_id = v_org_id;
		   Exception
		      when others then
			 null;
		   End;
		   --
		   if v_srl_control = 6 then
		      v_inst_usage_code := 'RETURNED';
		   else
		      v_inst_usage_code := 'IN_INVENTORY';
		   end if;
		   --
		  -- Added a check for the case of status id being null. shegde
		   if v_status_id is NULL then
		      v_status := nvl(FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS'), 'Latest');
                      select instance_status_id
                      into v_status_id
                      from CSI_INSTANCE_STATUSES
                      where name = v_status;
		   end if;

		   update CSI_ITEM_INSTANCES
		   set location_type_code = 'INVENTORY'
		      ,location_id = v_loc_id
		      ,accounting_class_code = 'CUST_PROD'
		      ,instance_usage_code = v_inst_usage_code
		      ,last_vld_organization_id = v_org_id
		      ,inv_organization_id = v_org_id
		      ,inv_subinventory_name = v_subinv
		      ,inv_locator_id = v_locator
		      ,instance_status_id = v_status_id
		      ,inventory_revision = v_rev
		   where instance_id = v_ret_instance_id;
		end if; -- Terminated_flag check
	     else
		-- There is no RMA instance
		v_instance_id := v_inv_instance_id;
	     end if;
	  end if; -- check for Inv Instance
	  --
	  v_duplicate_count := 0;

	  for j in c4(i.serial_number, i.inventory_item_id)
	  loop
	     if v_instance_id <> j.instance_id then
		v_duplicate_count := v_duplicate_count + 1;
		v_txn_id := null;
		open c6(v_instance_id,j.instance_id);
		fetch c6 into v_txn_id;
		close c6;
		--
                -- While suffixing with DUP, we use the instance_id in serial_number column to avoid serial #
                -- becoming more than 30 chars. The old serial_number is stored in the external_reference column.
		update csi_item_instances
		set     external_reference = serial_number
                       , serial_number = to_char(j.instance_id)||'-DUP'||to_char(v_duplicate_count)
		       ,active_end_date = sysdate
		       ,instance_status_id = v_instance_status_id
		       ,last_updated_by = fnd_global.user_id
		       ,last_update_date = sysdate
		where  instance_id = j.instance_id;
		--
		if v_txn_id is null then
		   update csi_item_instances_h
		   set    instance_id = v_instance_id
                          ,new_external_reference = i.serial_number
			  ,old_serial_number = nvl(new_serial_number,i.serial_number)
			  ,new_serial_number = to_char(j.instance_id)||'-DUP'||to_char(v_duplicate_count)
			  ,last_updated_by = fnd_global.user_id
			  ,last_update_date = sysdate
		   where  instance_id = j.instance_id;
		else -- common txn found
		   update csi_item_instances_h
		   set  new_external_reference = i.serial_number
		       ,old_serial_number = nvl(new_serial_number,i.serial_number)
		       ,new_serial_number = to_char(j.instance_id)||'-DUP'||to_char(v_duplicate_count)
		       ,last_updated_by = fnd_global.user_id
		       ,last_update_date = sysdate
		   where  instance_history_id = (select max(instance_history_id)
						 from csi_item_instances_h
						 where instance_id = j.instance_id
						 and   creation_date < v_freeze_date);
		end if;
	     end if;
	  end loop;

	  v_duplicate_count := 0;
	  v_instance_id := null;

	  if v_commit_count >= 500 then
	     commit;
	     v_commit_count := 0;
	  end if;

       end loop;
       commit;
    END; -- Second Update
    commit;
 END Update_Dup_Srl_Instance;
 --
  PROCEDURE Delete_Dup_Account IS
     CURSOR IP_CUR IS
     select cia.instance_party_id
     from csi_ip_accounts cia
     where cia.relationship_type_code = 'OWNER'
     group by cia.instance_party_id
     having count(*) > 1;
     --
     CURSOR ACCT_CUR(p_inst_party_id IN NUMBER,p_ip_acct_id IN NUMBER) IS
     select ip_account_id
     from csi_ip_accounts
     where instance_party_id = p_inst_party_id
     and   relationship_type_code = 'OWNER'
     and   ip_account_id <> p_ip_acct_id
     order by ip_account_id asc;
     --
     v_max_ip_acct_id      NUMBER;
     v_min_ret_id          NUMBER;
     v_old_account_id      NUMBER;
     v_commit_counter      NUMBER := 0;
     v_min_history_id      NUMBER;
     --
     Process_next          EXCEPTION;
  BEGIN
     FOR party in IP_CUR LOOP
	Begin
	   v_max_ip_acct_id := NULL;
	   v_min_ret_id := null;
	   --
	   select max(ip_account_id)
	   into v_max_ip_acct_id
	   from csi_ip_accounts
	   where instance_party_id = party.instance_party_id
	   and   relationship_type_code = 'OWNER'
	   and   ((active_end_date is null) or (active_end_date > sysdate));
	   --
	   IF v_max_ip_acct_id IS NULL THEN
	      Raise Process_next;
	   END IF;
	   --
	   select min(ip_account_history_id)
	   into v_min_ret_id
	   from CSI_IP_ACCOUNTS_H
	   where ip_account_id = v_max_ip_acct_id;
	   --
	   v_old_account_id := NULL;
	   --
	   FOR acct in ACCT_CUR(party.instance_party_id,v_max_ip_acct_id) LOOP
	      v_min_history_id := NULL;
	      select min(ip_account_history_id)
	      into v_min_history_id
	      from CSI_IP_ACCOUNTS_H
	      where ip_account_id = acct.ip_account_id;
	      --
	      IF v_min_history_id IS NULL THEN
		 Raise Process_next;
	      END IF;
	      --
	      IF ACCT_CUR%ROWCOUNT > 1 THEN
		 Update CSI_IP_ACCOUNTS_H
		 set old_party_account_id = v_old_account_id
		 where ip_account_history_id = v_min_history_id;
	      END IF;
	      --
	      DELETE from CSI_IP_ACCOUNTS_H
	      where ip_account_id = acct.ip_account_id
	      and   ip_account_history_id <> v_min_history_id;
	      --
	      v_old_account_id := NULL;
	      Begin
		 select new_party_account_id
		 into v_old_account_id
		 from CSI_IP_ACCOUNTS_H
		 where ip_account_history_id = v_min_history_id;
	      Exception
		 when no_data_found then
		    v_old_account_id := NULL;
	      End;
	      --
	      Update CSI_IP_ACCOUNTS_H
	      set ip_account_id = v_max_ip_acct_id
	      where ip_account_history_id = v_min_history_id;
	      --
	      Delete from CSI_IP_ACCOUNTS
	      where ip_account_id = acct.ip_account_id;
	      --
	      v_commit_counter := v_commit_counter + 1;
	      IF v_commit_counter = 100 THEN
		 v_commit_counter := 0;
		 commit;
	      END IF;
	   END LOOP;
	   Update CSI_IP_ACCOUNTS_H
	   set old_party_account_id = v_old_account_id
	   where ip_account_history_id = v_min_ret_id;
	Exception
	   when Process_next Then
	      null;
	End;
     END LOOP;
     commit;
  END Delete_Dup_Account;
  --
  PROCEDURE Update_Instance_Party_Source IS
     CURSOR CSI_INS_CUR IS
     SELECT instance_id,null
     FROM   csi_item_instances
     WHERE  (owner_party_source_table is null
     OR      owner_party_source_table  not in ('HZ_PARTIES','PO_VENDORS','EMPLOYEE','TEAM','GROUP'));
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     instance_id_mig         NumTabType;
     --
     Type V30TabType is VARRAY(10000) of VARCHAR2(30);
     party_src_table_mig     V30TabType;
     --
     MAX_BUFFER_SIZE         NUMBER := 1000;

  BEGIN
     OPEN CSI_INS_CUR;
     LOOP
	FETCH CSI_INS_CUR BULK COLLECT INTO
	instance_id_mig,
	party_src_table_mig
	LIMIT MAX_BUFFER_SIZE;
	--
	FOR i IN 1 .. instance_id_mig.count LOOP
	   BEGIN
	      SELECT party_source_table
	      INTO   party_src_table_mig(i)
	      FROM   csi_i_parties
	      WHERE  relationship_type_code = 'OWNER'
	      AND    instance_id = instance_id_mig(i);
	   EXCEPTION
	      WHEN no_data_found THEN
		 party_src_table_mig(i) := null;
	      WHEN OTHERS THEN
		 party_src_table_mig(i) := NULL;
	   END;
	   --
	END LOOP;
	--
	FORALL j in 1 .. instance_id_mig.count
	   UPDATE CSI_ITEM_INSTANCES
	   SET OWNER_PARTY_SOURCE_TABLE = party_src_table_mig(j)
	   WHERE instance_id = instance_id_mig(j);
	commit;
	EXIT WHEN CSI_INS_CUR%NOTFOUND;
     END LOOP;
     CLOSE CSI_INS_CUR;
     COMMIT;
  END Update_Instance_Party_Source;
  --
  PROCEDURE Update_Contact_Party_Record IS
     CURSOR CSI_PARTY_CUR IS
     select instance_id,instance_party_id,contact_ip_id,
     contact_flag,relationship_type_code
     from CSI_I_PARTIES
     where contact_ip_id IS NOT NULL;
     --
     l_ins_party_id       NUMBER;
     TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_upd_pty_tbl        NUMLIST;
     l_ctr                NUMBER := 0;
     l_exp_pty_tbl        NUMLIST;
     l_exp                NUMBER := 0;
     l_exists             VARCHAR2(1);
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     instance_id_mig         NumTabType;
     instance_party_id_mig   NumTabType;
     contact_ip_id_mig       NumTabType;
     --
     Type v1TabType is VARRAY(10000) of VARCHAR2(1);
     contact_flag_mig        v1TabType;
     --
     Type v30TabType is VARRAY(10000) of VARCHAR2(30);
     rel_type_code_mig       v30TabType;
     --
     MAX_BUFFER_SIZE         NUMBER := 1000;
  BEGIN
     OPEN CSI_PARTY_CUR;
     LOOP
	FETCH CSI_PARTY_CUR BULK COLLECT INTO
	instance_id_mig,
	instance_party_id_mig,
	contact_ip_id_mig,
	contact_flag_mig,
	rel_type_code_mig
	LIMIT MAX_BUFFER_SIZE;
	--
	l_ctr := 0;
	l_upd_pty_tbl.DELETE;
	l_exp := 0;
	l_exp_pty_tbl.DELETE;
	--
	FOR i in 1 .. instance_id_mig.count LOOP
	   IF ((nvl(contact_flag_mig(i),'N') <> 'Y') OR
	       (rel_type_code_mig(i) = 'OWNER')) THEN
	      l_ctr := l_ctr + 1;
	      l_upd_pty_tbl(l_ctr) := instance_party_id_mig(i);
	   ELSE
	      Begin
		 select 'x'
		 into l_exists
		 from CSI_I_PARTIES
		 where instance_party_id = contact_ip_id_mig(i)
		 and   instance_id = instance_id_mig(i);
	      Exception
		 when no_data_found then
		    l_exp := l_exp + 1;
		    l_exp_pty_tbl(l_exp) := instance_party_id_mig(i);
	      End;
	   END IF;
	END LOOP;
	IF l_upd_pty_tbl.count > 0 THEN
	   FORALL j in l_upd_pty_tbl.FIRST .. l_upd_pty_tbl.LAST
	      UPDATE CSI_I_PARTIES
	      set contact_ip_id = null
	      where instance_party_id = l_upd_pty_tbl(j);
	   --
	   commit;
	END IF;
	--
	IF l_exp_pty_tbl.count > 0 THEN
	   FORALL j in l_exp_pty_tbl.FIRST .. l_exp_pty_tbl.LAST
	      UPDATE CSI_I_PARTIES
	      set contact_ip_id = null,
		  active_end_date = sysdate
	      where instance_party_id = l_exp_pty_tbl(j);
	   --
	   commit;
	END IF;
	EXIT WHEN CSI_PARTY_CUR%NOTFOUND;
     END LOOP;
     CLOSE CSI_PARTY_CUR;
     commit;
  END Update_Contact_Party_Record;
  --
  PROCEDURE Revert_Party_Rel_Type_Update IS
     CURSOR INS_CUR IS
     select instance_id,relationship_type_code,count(*)
     from CSI_I_PARTIES
     where relationship_type_code = 'OWNER'
     group by instance_id,relationship_type_code
     having count(*) > 1;
     --
     CURSOR PARTY_HIST_CUR IS
     select a.instance_party_history_id instance_party_history_id,a.instance_party_id instance_party_id,
	    a.old_relationship_type_code old_rel_type,
	    a.old_party_id old_party_id,a.new_party_id new_party_id
     from CSI_I_PARTIES_H a
     where a.old_relationship_type_code is not null
     and   a.old_relationship_type_code <> 'OWNER'
     and   a.new_relationship_type_code is not null
     and   a.new_relationship_type_code = 'OWNER'
     and   a.new_party_id is not null
     and   a.old_party_id is not null
     and   exists (select 'x' from CSI_I_PARTIES b
		   where b.instance_id = (select c.instance_id from CSI_I_PARTIES c
					  where c.instance_party_id = a.instance_party_id)
		   and   b.relationship_type_code = 'OWNER')
     and   a.instance_party_history_id = (select max(instance_party_history_id)
					  from CSI_I_PARTIES_H d
					  where d.instance_party_id = a.instance_party_id);
     --
     TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_inst_tbl        NUMLIST;
     l_ctr             NUMBER := 0;
     l_internal_party_id NUMBER;
     l_party_id        NUMBER;
     l_ip_id           NUMBER;
     l_ip_account_id   NUMBER;
     l_vld_org_id      NUMBER;
     x_msg_data        VARCHAR2(2000);
     x_msg_count       NUMBER;
     x_return_status   VARCHAR2(1);
     l_txn_id          NUMBER;
     l_user_id         NUMBER := FND_GLOBAL.user_id;
     l_ins_flag        VARCHAR2(1) := 'N';
     v_txn_type_id     NUMBER;
     px_oks_txn_inst_tbl oks_ibint_pub.txn_instance_tbl;
     --
     Process_next      EXCEPTION;
     comp_error        EXCEPTION;
   BEGIN
      savepoint DATA_FIX;
      --
      Begin
	 select transaction_type_id
	 into v_txn_type_id
	 from CSI_TXN_TYPES
	 where SOURCE_TRANSACTION_TYPE = 'DATA_CORRECTION';
      Exception
	 when no_data_found then
	    Raise comp_error;
	 when others then
	    Raise comp_error;
      End;
      --
      FOR ins in INS_CUR LOOP
	 l_ctr := l_ctr + 1;
	 l_inst_tbl(l_ctr) := ins.instance_id;
      END LOOP;
      --
      IF l_inst_tbl.count = 0 THEN
	 RAISE Comp_error;
      END IF;
      --
      select CSI_TRANSACTIONS_S.nextval
      into l_txn_id from dual;
      --
      INSERT INTO CSI_TRANSACTIONS(
	       TRANSACTION_ID
	      ,TRANSACTION_DATE
	      ,SOURCE_TRANSACTION_DATE
	      ,SOURCE_HEADER_REF
	      ,TRANSACTION_TYPE_ID
	      ,CREATED_BY
	      ,CREATION_DATE
	      ,LAST_UPDATED_BY
	      ,LAST_UPDATE_DATE
	      ,LAST_UPDATE_LOGIN
	      ,OBJECT_VERSION_NUMBER
	      )
      VALUES(
	     l_txn_id                             -- TRANSACTION_ID
	    ,SYSDATE                              -- TRANSACTION_DATE
	    ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
	    ,'Update Dup Owner'                   -- SOURCE_HEADER_REF
	    ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
	    ,l_user_id
	    ,sysdate
	    ,l_user_id
	    ,sysdate
	    ,-1
	    ,1
	   );
      --
      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
      END IF;
      --
      l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
      --
      FOR party_rec in PARTY_HIST_CUR LOOP
	 Update CSI_I_PARTIES
	 set relationship_type_code = party_rec.old_rel_type,
	     party_id = party_rec.old_party_id
	 where instance_party_id = party_rec.instance_party_id;
	 --
	 Update CSI_I_PARTIES
	 set party_id = party_rec.new_party_id
	 where instance_id = (select instance_id from CSI_I_PARTIES
			      where instance_party_id = party_rec.instance_party_id)
	 and   relationship_type_code = 'OWNER';
	 --
	 Update CSI_I_PARTIES_H
	 set new_relationship_type_code = party_rec.old_rel_type,
	     new_party_id = party_rec.old_party_id
	 where instance_party_history_id = party_rec.instance_party_history_id;
	 --
      END LOOP;
      --
      IF l_inst_tbl.count > 0 THEN
	 FOR j in l_inst_tbl.FIRST .. l_inst_tbl.LAST LOOP
	    Begin
	       Begin
		  select instance_party_id
		  into l_ip_id
		  from CSI_I_PARTIES
		  where instance_id = l_inst_tbl(j)
		  and   relationship_type_code = 'OWNER'
		  and   party_id = l_internal_party_id;
	       Exception
		  when no_data_found then
		     Raise Process_next;
	       End;
	       --
	       Update CSI_IP_ACCOUNTS
	       set active_end_date = sysdate
	       where instance_party_id = l_ip_id
	       and   relationship_type_code = 'OWNER';
	       --
	       -- Insert into IP Accounts history
	       select ip_account_id
	       into l_ip_account_id
	       from CSI_IP_ACCOUNTS
	       where instance_party_id = l_ip_id
	       and   relationship_type_code = 'OWNER';
	       --
	       INSERT INTO CSI_IP_ACCOUNTS_H
		  ( IP_ACCOUNT_HISTORY_ID
		   ,IP_ACCOUNT_ID
		   ,TRANSACTION_ID
		   ,OLD_ACTIVE_END_DATE
		   ,NEW_ACTIVE_END_DATE
		   ,CREATED_BY
		   ,CREATION_DATE
		   ,LAST_UPDATED_BY
		   ,LAST_UPDATE_DATE
		   ,LAST_UPDATE_LOGIN
		   ,OBJECT_VERSION_NUMBER
		  )
	       VALUES
		  ( CSI_IP_ACCOUNTS_H_S.nextval
		   ,l_ip_account_id
		   ,l_txn_id
		   ,NULL
		   ,SYSDATE
		   ,l_user_id
		   ,sysdate
		   ,l_user_id
		   ,sysdate
		   ,-1
		   ,1
		  );
	       --
	       Update CSI_ITEM_INSTANCES
	       set owner_party_id = l_internal_party_id,
		   owner_party_account_id = null
	       where instance_id = l_inst_tbl(j);
	       --
	       select last_vld_organization_id
	       into l_vld_org_id
	       from CSI_ITEM_INSTANCES
	       where instance_id = l_inst_tbl(j);
	       --
	       CSI_Item_Instance_Pvt.Call_to_Contracts
		  ( p_transaction_type    => 'TRM'
		   ,p_instance_id         => l_inst_tbl(j)
		   ,p_new_instance_id     => NULL
		   ,p_vld_org_id          => l_vld_org_id
		   ,p_quantity            => NULL
		   ,p_party_account_id1   => NULL
		   ,p_party_account_id2   => NULL
                   ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
		   ,x_return_status       => x_return_status
		   ,x_msg_count           => x_msg_count
		   ,x_msg_data            => x_msg_data
		 );
	       --
	       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  Raise Comp_error;
	       END IF;
	    Exception
	       when Process_next then
		  null;
	    End;
	 END LOOP;
      END IF;
      --
      IF px_oks_txn_inst_tbl.count > 0 THEN
         UPDATE CSI_TRANSACTIONS
         set contracts_invoked = 'Y'
         where transaction_id = l_txn_id;
         --
	 OKS_IBINT_PUB.IB_interface
	    (
	      P_Api_Version           =>  1.0,
	      P_init_msg_list         =>  fnd_api.g_true,
	      P_single_txn_date_flag  =>  'Y',
	      P_Batch_type            =>  NULL,
	      P_Batch_ID              =>  NULL,
	      P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	      x_return_status         =>  x_return_status,
	      x_msg_count             =>  x_msg_count,
	      x_msg_data              =>  x_msg_data
	   );
	 --
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            Raise Comp_error;
	 END IF;
      END IF;
      commit;
  EXCEPTION
     when comp_error then
        Rollback to DATA_FIX;
     when others then
        Rollback to DATA_FIX;
  END Revert_Party_Rel_Type_Update;
  --
  PROCEDURE Update_Master_Organization_ID IS
     CURSOR CSI_CUR IS
     select cii.instance_id,cii.inv_master_organization_id,
            cii.last_vld_organization_id
     from CSI_ITEM_INSTANCES cii
     where not exists (select 'x'
                       from MTL_PARAMETERS msi
                       where organization_id = inv_master_organization_id
                       and   master_organization_id = inv_master_organization_id);
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     instance_id_mig       NumTabType;
     inv_master_org_id_mig NumTabType;
     last_vld_org_id_mig   NumTabType;
     --
     MAX_BUFFER_SIZE NUMBER := 1000;
  BEGIN
     OPEN CSI_CUR;
     LOOP
        FETCH CSI_CUR BULK COLLECT INTO
        instance_id_mig,
        inv_master_org_id_mig,
        last_vld_org_id_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR j in 1..instance_id_mig.count LOOP
           Begin
              select master_organization_id
              into inv_master_org_id_mig(j)
              from MTL_PARAMETERS
              where organization_id = last_vld_org_id_mig(j);
           Exception
              when no_data_found then
                 inv_master_org_id_mig(j) := inv_master_org_id_mig(j);
           End;
        END LOOP;
        --
        FORALL i in 1..instance_id_mig.count
           UPDATE CSI_ITEM_INSTANCES
           set inv_master_organization_id = inv_master_org_id_mig(i)
           where instance_id = instance_id_mig(i);
        commit;
        --
        FORALL i in 1..instance_id_mig.count
           UPDATE CSI_ITEM_INSTANCES_H
           set old_inv_master_organization_id = decode(old_inv_master_organization_id,null,null,inv_master_org_id_mig(i)),
               new_inv_master_organization_id = decode(new_inv_master_organization_id,null,null,inv_master_org_id_mig(i))
           where instance_id = instance_id_mig(i);
        commit;
        --
        EXIT WHEN CSI_CUR%NOTFOUND;
     END LOOP;
     commit;
     CLOSE CSI_CUR;
  END Update_Master_Organization_ID;
  --
  PROCEDURE Get_Children
    (p_object_id     IN  NUMBER,
     p_rel_tbl       OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    ) IS
    --
    l_rel_tbl                 csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_next_lvl        csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_temp            csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_final           csi_datastructures_pub.ii_relationship_tbl;
    l_next_ind                NUMBER := 0;
    l_final_ind               NUMBER := 0;
    l_ctr                     NUMBER := 0;
    l_found                   NUMBER;
  BEGIN
     Get_Next_Level
       ( p_object_id                 => p_object_id,
	 p_rel_tbl                   => l_rel_tbl
       );

     <<Next_Level>>

     l_rel_tbl_next_lvl.delete;
     l_next_ind := 0;
     --
     IF l_rel_tbl.count > 0 THEN
	FOR l_ind IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
	   l_final_ind := l_final_ind + 1;
	   l_rel_tbl_final(l_final_ind) := l_rel_tbl(l_ind);
	   /* get the next level using this Subject ID as the parent */
	   Get_Next_Level
	     ( p_object_id                 => l_rel_tbl(l_ind).subject_id,
	       p_rel_tbl                   => l_rel_tbl_temp
	     );
	   --
	   IF l_rel_tbl_temp.count > 0 THEN
	      FOR l_temp_ind IN l_rel_tbl_temp.FIRST .. l_rel_tbl_temp.LAST LOOP
                 IF l_rel_tbl_final.count > 0 THEN
                    l_found := 0;
                    FOR i IN l_rel_tbl_final.FIRST .. l_rel_tbl_final.LAST LOOP
                       IF l_rel_tbl_final(i).object_id = l_rel_tbl_temp(l_temp_ind).object_id THEN
                          l_found := 1;
                          exit;
                       END IF;
                    END LOOP;
                 END IF;
                 IF l_found = 0 THEN
		    l_next_ind := l_next_ind + 1;
		    l_rel_tbl_next_lvl(l_next_ind) := l_rel_tbl_temp(l_temp_ind);
                 END IF;
	      END LOOP;
	   END IF;
	END LOOP;
	--
	IF l_rel_tbl_next_lvl.count > 0 THEN
	   l_rel_tbl.DELETE;
	   l_rel_tbl := l_rel_tbl_next_lvl;
	   --
	   goto Next_Level;
	END IF;
     END IF;
     --
     p_rel_tbl := l_rel_tbl_final;
     --
     -- The output of l_rel_tbl_final will be Breadth first search Order.
  END Get_Children;
  --
  PROCEDURE Delete_Dup_Relationship IS
     CURSOR CSI_REL_CUR IS
     select object_id,subject_id,relationship_type_code,count(*)
     from CSI_II_RELATIONSHIPS
     where active_end_date is null
     and   nvl(migrated_flag,'N') = 'Y'
     group by object_id,subject_id,relationship_type_code
     having count(*) > 1;
     --
     -- Delete the ones that are not having any non-migrated txns
     CURSOR CSI_REL_DEL_CUR(p_rel_id IN NUMBER
			   ,p_object_id IN NUMBER
			   ,p_subject_id IN NUMBER
			   ,p_rel_type IN VARCHAR2) IS
     select cir.relationship_id
     from CSI_II_RELATIONSHIPS cir
     where cir.object_id = p_object_id
     and   cir.subject_id = p_subject_id
     and   cir.relationship_type_code = p_rel_type
     and   cir.active_end_date is null
     and   nvl(cir.migrated_flag,'N') = 'Y'
     and   cir.relationship_id <> p_rel_id
     and   not exists (select 'x' from CSI_II_RELATIONSHIPS_H cirh
                       where cirh.relationship_id = cir.relationship_id
                       and   nvl(cirh.migrated_flag,'N') = 'N');
     --
     l_ret_relationship_id      NUMBER;
     TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_rel_id_tbl     NUMLIST;
     l_ctr            NUMBER := 0;
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     Type V30TabType is VARRAY(10000) of VARCHAR2(30);
     l_object_id_mig            NumTabType;
     l_subject_id_mig           NumTabType;
     l_count_mig                NumTabType;
     l_rel_type_code_mig        V30TabType;
     --
     MAX_BUFFER_SIZE         NUMBER := 1000;
  BEGIN
     OPEN CSI_REL_CUR;
     LOOP
        FETCH CSI_REL_CUR BULK COLLECT INTO
           l_object_id_mig,
           l_subject_id_mig,
           l_rel_type_code_mig,
           l_count_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR k in 1..l_object_id_mig.count LOOP
           l_ret_relationship_id := -9999;
           -- Try to get the relationship which has non-migrated txns
   	   Begin
	      select max(cir.relationship_id)
	      into l_ret_relationship_id
	      from CSI_II_RELATIONSHIPS cir
	      where cir.object_id = l_object_id_mig(k)
	      and   cir.subject_id = l_subject_id_mig(k)
	      and   cir.relationship_type_code = l_rel_type_code_mig(k)
	      and   cir.active_end_date is null
	      and   nvl(cir.migrated_flag,'N') = 'Y'
              and   exists (select 'x' from CSI_II_RELATIONSHIPS_H cirh
                            where cirh.relationship_id = cir.relationship_id
                            and   nvl(cirh.migrated_flag,'N') = 'N');
	   End;
           --
           IF nvl(l_ret_relationship_id,-9999) = -9999 THEN
	      Begin
	         select max(relationship_id)
	         into l_ret_relationship_id
	         from CSI_II_RELATIONSHIPS
	         where object_id = l_object_id_mig(k)
	         and   subject_id = l_subject_id_mig(k)
	         and   relationship_type_code = l_rel_type_code_mig(k)
	         and   active_end_date is null
	         and   nvl(migrated_flag,'N') = 'Y';
	      End;
           END IF;
	   --
           -- The above l_ret_relationship_id will be retained
           --
	   FOR del_rec in CSI_REL_DEL_CUR(l_ret_relationship_id,
	   			          l_object_id_mig(k),
				          l_subject_id_mig(k),
                                          l_rel_type_code_mig(k)) LOOP
	      l_ctr := l_ctr + 1;
	      l_rel_id_tbl(l_ctr) := del_rec.relationship_id;
	   END LOOP;
        END LOOP;
        EXIT WHEN CSI_REL_CUR%NOTFOUND;
     END LOOP;
     --
     IF CSI_REL_CUR%ISOPEN THEN
        CLOSE CSI_REL_CUR;
     END IF;
     --
     IF l_rel_id_tbl.count > 0 THEN
	FORALL j in l_rel_id_tbl.FIRST .. l_rel_id_tbl.LAST
	   DELETE FROM CSI_II_RELATIONSHIPS_H
	   WHERE relationship_id = l_rel_id_tbl(j);
	commit;
	--
	FORALL j in l_rel_id_tbl.FIRST .. l_rel_id_tbl.LAST
	   DELETE FROM CSI_II_RELATIONSHIPS
	   WHERE relationship_id = l_rel_id_tbl(j);
	commit;
     END IF;
  END Delete_Dup_Relationship;
  --
  PROCEDURE Call_Parallel_Expire
      (errbuf          OUT NOCOPY VARCHAR2,
       retcode         OUT NOCOPY NUMBER,
       p_process_code  IN VARCHAR2
      ) IS
     --
     CURSOR EXP_CUR IS
     select instance_id,rowid
     from CSI_EXPIRE_INSTANCES_TEMP
     where process_code = p_process_code
     and   processed_flag in ('E','R');
     --
     l_vld_org          NUMBER;
     v_commit_count     NUMBER := 0;
     --
     x_return_status          VARCHAR2(1);
     x_msg_count              NUMBER;
     x_msg_data               VARCHAR2(2000);
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     px_oks_txn_inst_tbl      oks_ibint_pub.txn_instance_tbl;
     --
     Process_next       EXCEPTION;
  BEGIN
     FOR exp IN EXP_CUR LOOP
        BEGIN
           Begin
              select last_vld_organization_id
              into l_vld_org
              from CSI_ITEM_INSTANCES
              where instance_id = exp.instance_id;
           Exception
              when no_data_found then
                 Raise Process_next;
           End;
           --
	   CSI_Item_Instance_Pvt.Call_to_Contracts
	      ( p_transaction_type    => 'TRM'
	       ,p_instance_id         => exp.instance_id
	       ,p_new_instance_id     => NULL
	       ,p_vld_org_id          => l_vld_org
	       ,p_quantity            => NULL
	       ,p_party_account_id1   => NULL
	       ,p_party_account_id2   => NULL
               ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
	       ,x_return_status       => x_return_status
	       ,x_msg_count           => x_msg_count
	       ,x_msg_data            => x_msg_data
	      );
	      --
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              UPDATE CSI_EXPIRE_INSTANCES_TEMP
              set processed_flag = 'E',
                  error_message = x_msg_data
              where rowid = exp.rowid;
           ELSE
              UPDATE CSI_EXPIRE_INSTANCES_TEMP
              set processed_flag = 'P',
                  error_message = null
              where rowid = exp.rowid;
           END IF;
           --
           v_commit_count := v_commit_count + 1;
           IF v_commit_count = 500 THEN
              v_commit_count := 0;
              commit;
           END IF;
        EXCEPTION
           WHEN Process_next THEN
              NULL;
        END;
     END LOOP;
     commit;
     --
     IF px_oks_txn_inst_tbl.count > 0 THEN
	OKS_IBINT_PUB.IB_interface
	   (
	     P_Api_Version           =>  1.0,
	     P_init_msg_list         =>  fnd_api.g_true,
	     P_single_txn_date_flag  =>  'Y',
	     P_Batch_type            =>  NULL,
	     P_Batch_ID              =>  NULL,
	     P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	     x_return_status         =>  x_return_status,
	     x_msg_count             =>  x_msg_count,
	     x_msg_data              =>  x_msg_data
	  );
	--
     END IF;
  END Call_Parallel_Expire;
  --
  PROCEDURE Expire_Non_Trackable_Instance IS
     CURSOR CSI_CUR IS
     select cii.instance_id,cii.inventory_item_id,cii.inv_master_organization_id
     from CSI_ITEM_INSTANCES cii
     where nvl(cii.active_end_date,(sysdate+1)) > sysdate;
     --
     CURSOR REL_CUR IS
     select cii.instance_id,cii.inventory_item_id,cii.inv_master_organization_id,
            cir.relationship_id
     from   CSI_ITEM_INSTANCES cii,
            CSI_II_RELATIONSHIPS cir
     where  nvl(cii.active_end_date,(sysdate+1)) > sysdate
     and    cir.subject_id = cii.instance_id
     and   cir.relationship_type_code = 'COMPONENT-OF'
     and   nvl(cir.active_end_date,(sysdate+1)) > sysdate;
     --
     CURSOR CSI_MAT_ERROR IS
     select cii.transaction_error_id,
     mmt.inventory_item_id,mmt.organization_id
     from CSI_TXN_ERRORS cii,
          MTL_MATERIAL_TRANSACTIONS mmt
     where cii.processed_flag in ('E', 'R')
     and   cii.inv_material_transaction_id is not null
     and   mmt.transaction_id = cii.inv_material_transaction_id;
     --
     CURSOR CSI_NON_MAT_ERROR IS
     select transaction_error_id,source_id
     from CSI_TXN_ERRORS cii
     where cii.inv_material_transaction_id is null
     and   cii.source_id is not null
     and   cii.processed_flag in ('E', 'R');
     --
     v_commit_count           NUMBER := 0;
     v_err_msg                VARCHAR2(2000);
     v_txn_type_id            NUMBER;
     v_txn_id                 NUMBER;
     v_user_id                NUMBER := fnd_global.user_id;
     l_nl                     VARCHAR2(1);
     l_item_id                NUMBER;
     l_org_id                 NUMBER;
     l_organization_id        NUMBER;
     --
     TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_upd_txn_tbl           NUMLIST;
     l_upd_count             NUMBER := 0;
     l_rel_count             NUMBER := 0;
     l_rel_tbl               NUMLIST;
     l_rel_code              VARCHAR2(30) := 'COMPONENT-OF';
     l_ctr                   NUMBER := 0;
     l_inst_tbl              NUMLIST;
     l_inst_hist_tbl         NUMLIST;
     l_req_count             NUMBER := 0;
     l_req_tbl               NUMLIST;
     v_request_id            NUMBER;
     l_child_tbl             csi_datastructures_pub.ii_relationship_tbl;
     l_contracts_status      VARCHAR2(3);
     l_ins_flag              VARCHAR2(1) := 'N';
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     instance_id_mig         NumTabType;
     inventory_item_id_mig   NumTabType;
     mast_org_id_mig         NumTabType;
     relationship_id_mig     NumTabType;
     organization_id_mig     NumTabType;
     txn_error_id_mig        NumTabType;
     source_id_mig           NumTabType;
     --
     MAX_BUFFER_SIZE         NUMBER := 1000;
     INST_BUFFER_SIZE        NUMBER := 1000;
     --
     comp_error              EXCEPTION;
     Process_next            EXCEPTION;
  BEGIN
     DELETE FROM CSI_EXPIRE_INSTANCES_TEMP
     WHERE processed_flag = 'P'
     AND   process_code = 'EXPNL';
     commit;
     --
     -- Get the Transaction Type ID for Txn Type MIGRATED
     Begin
        select transaction_type_id
        into v_txn_type_id
        from CSI_TXN_TYPES
        where SOURCE_TRANSACTION_TYPE = 'DATA_CORRECTION';
     Exception
        when no_data_found then
           v_err_msg := 'Txn Type DATA_CORRECTION not defined in CSI_TXN_TYPES';
           Raise comp_error;
        when others then
           v_err_msg := 'Unable to get the ID for Txn Type DATA_CORRECTION from CSI_TXN_TYPES';
           Raise comp_error;
     End;
     -- End data the relationships
     OPEN REL_CUR;
     LOOP
        FETCH REL_CUR BULK COLLECT INTO
        instance_id_mig,
        inventory_item_id_mig,
        mast_org_id_mig,
        relationship_id_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR j in 1..instance_id_mig.count LOOP
           Begin
              Begin
                 select nvl(comms_nl_trackable_flag,'N')
                 into l_nl
                 from MTL_SYSTEM_ITEMS
                 where inventory_item_id = inventory_item_id_mig(j)
                 and   organization_id = mast_org_id_mig(j);
              Exception
                 when no_data_found then
                    Raise Process_next;
              End;
              IF l_nl <> 'Y' THEN
                 l_rel_count := l_rel_count + 1;
                 l_rel_tbl(l_rel_count) := relationship_id_mig(j);
              END IF;
           Exception
              when Process_next then
                 null;
           End;
        END LOOP;
        EXIT WHEN REL_CUR%NOTFOUND;
     END LOOP;
     CLOSE REL_CUR;
     --
     IF REL_CUR%ISOPEN THEN
        CLOSE REL_CUR;
     END IF;
     -- Update the Relationship end_date.
     IF l_rel_tbl.count > 0 THEN
        FORALL i in l_rel_tbl.FIRST .. l_rel_tbl.LAST
           UPDATE CSI_II_RELATIONSHIPS
           set active_end_date = sysdate
           where relationship_id = l_rel_tbl(i);
        --
        commit;
     END IF;
     --
     select CSI_TRANSACTIONS_S.nextval
     into v_txn_id from dual;
     --
     OPEN CSI_CUR;
     LOOP
        FETCH CSI_CUR BULK COLLECT INTO
        instance_id_mig,
        inventory_item_id_mig,
        mast_org_id_mig
        LIMIT INST_BUFFER_SIZE;
        --
        l_ctr := 0;
        l_inst_tbl.DELETE;
        l_inst_hist_tbl.DELETE;
        --
        FOR i in 1 .. instance_id_mig.count LOOP
           Begin
              Begin
                 select nvl(comms_nl_trackable_flag,'N')
                 into l_nl
                 from MTL_SYSTEM_ITEMS
                 where inventory_item_id = inventory_item_id_mig(i)
                 and   organization_id = mast_org_id_mig(i);
              Exception
                 when no_data_found then
                    Raise Process_next;
              End;
              IF l_nl = 'Y' THEN
                 Raise Process_next;
              END IF;
              --
              l_ctr := l_ctr + 1;
              l_inst_tbl(l_ctr) := instance_id_mig(i);
              --
              select CSI_ITEM_INSTANCES_H_S.nextval
              into l_inst_hist_tbl(l_ctr) from dual;
              --
              -- For this instance_id get the children
              l_child_tbl.DELETE;
              --
              Get_Children
                 ( p_object_id     => instance_id_mig(i),
                   p_rel_tbl       => l_child_tbl
                 );
              --
              IF l_child_tbl.count > 0 THEN
                 FOR rel_count in l_child_tbl.FIRST .. l_child_tbl.LAST LOOP
                    l_ctr := l_ctr + 1;
                    l_inst_tbl(l_ctr) := l_child_tbl(rel_count).subject_id;
                    --
                    select CSI_ITEM_INSTANCES_H_S.nextval
                    into l_inst_hist_tbl(l_ctr) from dual;
                 END LOOP;
              END IF;
           Exception
              when Process_next then
                 null;
           End;
        END LOOP;
           IF l_inst_tbl.count > 0 THEN
              l_ins_flag := 'Y';
              FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
                 INSERT INTO CSI_EXPIRE_INSTANCES_TEMP
                    ( INSTANCE_ID,
                      PROCESSED_FLAG,
                      PROCESS_CODE
                    )
                 VALUES
                   ( l_inst_tbl(j),
                     'R',
                     'EXPNL'
                   );
              -- Bulk Update Instances
              FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
                 UPDATE CSI_ITEM_INSTANCES
                 set active_end_date = sysdate,
                     instance_status_id = 1,
                     last_update_date = sysdate,
                     last_updated_by = v_user_id
                 where instance_id = l_inst_tbl(j);
              --
              -- Tie the Transaction to the history
              FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
		 INSERT INTO CSI_ITEM_INSTANCES_H
		     (
		      INSTANCE_HISTORY_ID
		     ,TRANSACTION_ID
		     ,INSTANCE_ID
		     ,CREATION_DATE
		     ,LAST_UPDATE_DATE
		     ,CREATED_BY
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		    )
		 VALUES
		    (
		      l_inst_hist_tbl(j)
		     ,v_txn_id
		     ,l_inst_tbl(j)
		     ,SYSDATE
		     ,SYSDATE
		     ,v_user_id
		     ,v_user_id
		     ,-1
		     ,1
		    );
           END IF;
           commit;
           EXIT WHEN CSI_CUR%NOTFOUND;
     END LOOP;
     CLOSE CSI_CUR;
     -- Insert one record into CSI_TRANSACTIONS
     IF l_ins_flag = 'Y' THEN
	   INSERT INTO CSI_TRANSACTIONS(
	    TRANSACTION_ID
	   ,TRANSACTION_DATE
	   ,SOURCE_TRANSACTION_DATE
	   ,SOURCE_HEADER_REF
	   ,SOURCE_LINE_REF
	   ,TRANSACTION_TYPE_ID
	   ,CREATED_BY
	   ,CREATION_DATE
	   ,LAST_UPDATED_BY
	   ,LAST_UPDATE_DATE
	   ,LAST_UPDATE_LOGIN
	   ,OBJECT_VERSION_NUMBER
	  )
	  VALUES(
	    v_txn_id                             -- TRANSACTION_ID
	   ,SYSDATE                              -- TRANSACTION_DATE
	   ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
	   ,'COMMS_NL_TRACKABLE_FLAG got switched off'   -- SOURCE_HEADER_REF
	   ,'DATAFIX By Expire Non_NL Trackable' -- SOURCE_LINE_REF
	   ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
	   ,v_user_id
	   ,sysdate
	   ,v_user_id
	   ,sysdate
	   ,-1
	   ,1
	  );
     END IF;
     commit;
     --
     IF CSI_CUR%ISOPEN THEN
        CLOSE CSI_CUR;
     END IF;
     -- Call Expire_Item_Instance wraper to Expire Contracts
     l_contracts_status := FND_PROFILE.VALUE('CSI_CONTRACTS_ENABLED');
     IF UPPER(l_contracts_status) = 'Y'  THEN
        UPDATE CSI_TRANSACTIONS
        set contracts_invoked = 'Y'
        where transaction_id = v_txn_id;
        --
        v_request_id := 0;
        v_request_id := fnd_request.submit_request
                           (
                              'CSI'
                             ,'CSIEXPIR'
                             ,NULL
                             ,SYSDATE
                             ,FALSE
                             ,'EXPNL'
                           );
        commit;
     END IF; -- Contracts enabled check
     commit;
     -- Update the Relationship end_date back to null.
     IF l_rel_tbl.count > 0 THEN
        FORALL i in l_rel_tbl.FIRST .. l_rel_tbl.LAST
           UPDATE CSI_II_RELATIONSHIPS
           set active_end_date = null
           where relationship_id = l_rel_tbl(i);
        --
        commit;
     END IF;
     commit;
     --
     OPEN CSI_MAT_ERROR;
     LOOP
        FETCH CSI_MAT_ERROR BULK COLLECT INTO
        txn_error_id_mig,
        inventory_item_id_mig,
        organization_id_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR i in 1 .. txn_error_id_mig.count LOOP
           select comms_nl_trackable_flag
           into l_nl
           from MTL_SYSTEM_ITEMS msi,
                MTL_PARAMETERS mp
           where mp.organization_id = organization_id_mig(i)
           and   msi.inventory_item_id = inventory_item_id_mig(i)
           and   msi.organization_id = mp.master_organization_id;
           --
           IF nvl(l_nl,'N') <> 'Y' THEN
              l_upd_count := l_upd_count + 1;
              l_upd_txn_tbl(l_upd_count) := txn_error_id_mig(i);
           END IF;
        END LOOP;
        EXIT WHEN CSI_MAT_ERROR%NOTFOUND;
     END LOOP;
     CLOSE CSI_MAT_ERROR;
     --
     -- Perform a Bulk Update
     IF l_upd_txn_tbl.count > 0 THEN
       FORALL i in l_upd_txn_tbl.FIRST .. l_upd_txn_tbl.LAST
         UPDATE csi_txn_errors
         SET    processed_flag   = 'D',
                error_text       = 'COMMS_NL_TRACKABLE_FLAG got switched off',
                last_update_date = sysdate
         WHERE transaction_error_id = l_upd_txn_tbl(i);
       commit;
     END IF;
     --
     --
     l_upd_txn_tbl.DELETE;
     l_upd_count := 0;
     --
     OPEN CSI_NON_MAT_ERROR;
     LOOP
        FETCH CSI_NON_MAT_ERROR BULK COLLECT INTO
        txn_error_id_mig,source_id_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR i in 1 .. txn_error_id_mig.count LOOP
           BEGIN
	      Begin
		 select oel.inventory_item_id,oel.org_id
		 into l_item_id, l_org_id
		 from OE_ORDER_LINES_ALL oel
		 where oel.line_id = source_id_mig(i);

                 l_organization_id := oe_sys_parameters.value(
                                        param_name => 'MASTER_ORGANIZATION_ID',
                                        p_org_id   => l_org_id);

	      Exception
		 when no_data_found then
		    Raise Process_next;
	      End;
	      --
	      Begin
		 select comms_nl_trackable_flag
		 into l_nl
		 from MTL_SYSTEM_ITEMS msi,
                      MTL_PARAMETERS mp
		 where mp.organization_id = l_organization_id
                 and   msi.inventory_item_id = l_item_id
		 and   msi.organization_id = mp.master_organization_id;
	      Exception
		 when no_data_found then
		    Raise Process_next;
	      End;
	      --
	      IF nvl(l_nl,'N') <> 'Y' THEN
	         l_upd_count := l_upd_count + 1;
		 l_upd_txn_tbl(l_upd_count) := txn_error_id_mig(i);
	      END IF;
           EXCEPTION
              WHEN Process_next then
                 NULL;
           END;
        END LOOP;
        EXIT WHEN CSI_NON_MAT_ERROR%NOTFOUND;
     END LOOP;
     CLOSE CSI_NON_MAT_ERROR;
     -- Perform a Bulk Update
     IF l_upd_txn_tbl.count > 0 THEN
        FORALL i in l_upd_txn_tbl.FIRST .. l_upd_txn_tbl.LAST
           UPDATE CSI_TXN_ERRORS
           set processed_flag = 'D',
           error_text = 'COMMS_NL_TRACKABLE_FLAG got switched off',
           last_update_date = sysdate
           where transaction_error_id = l_upd_txn_tbl(i);
        commit;
     END IF;
     --
     IF CSI_NON_MAT_ERROR%ISOPEN THEN
        CLOSE CSI_NON_MAT_ERROR;
     END IF;
     commit;
  EXCEPTION
     WHEN comp_error then
        NULL;
  END Expire_Non_Trackable_Instance;
  --
  -- The following procedure identifies the instances that got a srl/lot number without the
  -- respective control and nullify the srl/lot number.
  -- The history will be populated with the old srl/lot number and new value will be null.
  -- For Inventory instances, we just expire them
  --
  PROCEDURE Update_No_ctl_Srl_Lot_Inst IS
  /* commenting the following cursors for the bug 5989350 ,Since there is
     no need to nullify the serial and lot number for the instances
     which are already shipped to customers */
  /* CURSOR CSI_SRL_CUR IS
     select cii.instance_id,cii.serial_number,
            cii.last_vld_organization_id,cii.inventory_item_id
     from CSI_ITEM_INSTANCES cii
     where cii.serial_number is not null
     and   cii.last_vld_organization_id is not null
     and   cii.inv_organization_id is null
     and   cii.inv_subinventory_name is null; -- to filter Inventory instances
     --
     CURSOR CSI_LOT_CUR IS
     select cii.instance_id,cii.lot_number,
            cii.last_vld_organization_id,cii.inventory_item_id
     from CSI_ITEM_INSTANCES cii
     where cii.lot_number is not null
     and   cii.last_vld_organization_id is not null
     and   cii.inv_organization_id is null
     and   cii.inv_subinventory_name is null; -- to filter Inventory instances
     --
  */
     CURSOR INV_CSI_SRL_CUR IS
     select cii.instance_id,cii.serial_number,
            cii.last_vld_organization_id,cii.inventory_item_id
     from CSI_ITEM_INSTANCES cii
     where cii.serial_number is not null
     and   cii.last_vld_organization_id is not null
     and   cii.location_type_code = 'INVENTORY'
     and   cii.instance_usage_code = 'IN_INVENTORY'
     and   nvl(cii.active_end_date,(sysdate+1)) > sysdate
     and   cii.inv_organization_id is not null
     and   cii.inv_subinventory_name is not null; -- to handle Inventory instances
     --
     CURSOR INV_CSI_LOT_CUR IS
     select cii.instance_id,cii.lot_number,
            cii.last_vld_organization_id,cii.inventory_item_id
     from CSI_ITEM_INSTANCES cii
     where cii.lot_number is not null
     and   cii.last_vld_organization_id is not null
     and   cii.inv_organization_id is not null
     and   cii.location_type_code = 'INVENTORY'
     and   cii.instance_usage_code = 'IN_INVENTORY'
     and   nvl(cii.active_end_date,(sysdate+1)) > sysdate
     and   cii.inv_subinventory_name is not null; -- to handle Inventory instances
     --
     v_commit_count         NUMBER := 0;
     v_err_msg              VARCHAR2(2000);
     v_txn_type_id          NUMBER;
     v_srl_txn_id           NUMBER;
     v_lot_txn_id           NUMBER;
     v_user_id              NUMBER := fnd_global.user_id;
     v_srl_ctl              NUMBER;
     v_lot_ctl              NUMBER;
     --
     TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE T_V30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
     TYPE T_V80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
     --
     l_ctr                   NUMBER := 0;
     l_inst_tbl              NUMLIST;
     l_srl_tbl               T_V30;
     l_lot_tbl               T_V80;
     l_inst_hist_tbl         NUMLIST;
     l_srl_ins_flag          VARCHAR2(1) := 'N';
     l_lot_ins_flag          VARCHAR2(1) := 'N';
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     Type V30TabType is VARRAY(10000) of VARCHAR2(30);
     Type V80TabType is VARRAY(10000) of VARCHAR2(80); --bnarayan added for lot number change
     --
     instance_id_mig         NumTabType;
     vld_org_id_mig          NumTabType;
     inventory_item_id_mig   NumTabType;
     serial_number_mig       V30TabType;
     lot_number_mig          V80TabType;
     relationship_id_mig     NumTabType;
     organization_id_mig     NumTabType;
     --
     MAX_BUFFER_SIZE         NUMBER := 1000;
     INST_BUFFER_SIZE        NUMBER := 1000;
     --
     comp_error              EXCEPTION;
  BEGIN
     -- Get the Transaction Type ID for Txn Type DATA_CORRECTION
     Begin
	select transaction_type_id
	into v_txn_type_id
	from CSI_TXN_TYPES
	where SOURCE_TRANSACTION_TYPE = 'DATA_CORRECTION';
     Exception
	when no_data_found then
	   v_err_msg := 'Txn Type DATA_CORRECTION not defined in CSI_TXN_TYPES';
	   Raise comp_error;
	when others then
	   v_err_msg := 'Unable to get the ID for Txn Type DATA_CORRECTION from CSI_TXN_TYPES';
	   Raise comp_error;
     End;
     --
     select CSI_TRANSACTIONS_S.nextval
     into v_srl_txn_id from dual;
     --
     select CSI_TRANSACTIONS_S.nextval
     into v_lot_txn_id from dual;
     --
     /* commenting the following cursors for the bug 5989350 ,Since there is
     no need to nullify the serial and lot number for the instances
     which are already shipped to customers */
     /*OPEN CSI_SRL_CUR;
     LOOP
        FETCH CSI_SRL_CUR BULK COLLECT INTO
        instance_id_mig,
        serial_number_mig,
        vld_org_id_mig,
        inventory_item_id_mig
        LIMIT INST_BUFFER_SIZE;
        --
        l_ctr := 0;
        l_inst_tbl.DELETE;
        l_srl_tbl.DELETE;
        l_inst_hist_tbl.DELETE;
        --
        FOR i in 1 .. instance_id_mig.count LOOP
           v_srl_ctl := null;
           Begin
              select serial_number_control_code
              into v_srl_ctl
              from MTL_SYSTEM_ITEMS
              where inventory_item_id = inventory_item_id_mig(i)
              and   organization_id = vld_org_id_mig(i);
           Exception
              when others then
                 v_srl_ctl := null;
           End;
           IF nvl(v_srl_ctl,1) = 1 THEN
              l_ctr := l_ctr + 1;
              l_inst_tbl(l_ctr) := instance_id_mig(i);
              l_srl_tbl(l_ctr) := serial_number_mig(i);
              --
	         select CSI_ITEM_INSTANCES_H_S.nextval
	         into l_inst_hist_tbl(l_ctr) from dual;
           END IF;
	      --
        END LOOP;
        IF l_inst_tbl.count > 0 THEN
	   -- Bulk Update Instances
           l_srl_ins_flag := 'Y';
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      UPDATE CSI_ITEM_INSTANCES
	      set serial_number = null,
               mfg_serial_number_flag = 'N',
		     last_update_date = sysdate,
		     last_updated_by = v_user_id
	      where instance_id = l_inst_tbl(j);
	      --
	      -- Tie the Transaction to the history
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      INSERT INTO CSI_ITEM_INSTANCES_H
		  (
		   INSTANCE_HISTORY_ID
		  ,TRANSACTION_ID
		  ,INSTANCE_ID
            ,OLD_SERIAL_NUMBER
            ,NEW_SERIAL_NUMBER
		  ,CREATION_DATE
		  ,LAST_UPDATE_DATE
		  ,CREATED_BY
		  ,LAST_UPDATED_BY
		  ,LAST_UPDATE_LOGIN
		  ,OBJECT_VERSION_NUMBER
		 )
	      VALUES
		 (
		   l_inst_hist_tbl(j)
		  ,v_srl_txn_id
		  ,l_inst_tbl(j)
            ,l_srl_tbl(j)
            ,NULL
		  ,SYSDATE
		  ,SYSDATE
		  ,v_user_id
		  ,v_user_id
		  ,-1
		  ,1
		 );
        END IF;
        commit;
        EXIT WHEN CSI_SRL_CUR%NOTFOUND;
     END LOOP;
     commit;
     CLOSE CSI_SRL_CUR;
     --
     OPEN CSI_LOT_CUR;
     LOOP
        FETCH CSI_LOT_CUR BULK COLLECT INTO
        instance_id_mig,
        lot_number_mig,
        vld_org_id_mig,
        inventory_item_id_mig
        LIMIT INST_BUFFER_SIZE;
        --
        l_ctr := 0;
        l_inst_tbl.DELETE;
        l_lot_tbl.DELETE;
        l_inst_hist_tbl.DELETE;
        --
        FOR i in 1 .. instance_id_mig.count LOOP
           v_lot_ctl := null;
           Begin
              select lot_control_code
              into v_lot_ctl
              from MTL_SYSTEM_ITEMS
              where inventory_item_id = inventory_item_id_mig(i)
              and   organization_id = vld_org_id_mig(i);
           Exception
              when others then
                 v_lot_ctl := null;
           End;
           IF nvl(v_lot_ctl,1) = 1 THEN
              l_ctr := l_ctr + 1;
              l_inst_tbl(l_ctr) := instance_id_mig(i);
              l_lot_tbl(l_ctr) := lot_number_mig(i);
	         --
	         select CSI_ITEM_INSTANCES_H_S.nextval
	         into l_inst_hist_tbl(l_ctr) from dual;
           END IF;
        END LOOP;
        --
        IF l_inst_tbl.count > 0 THEN
           l_lot_ins_flag := 'Y';
	      -- Bulk Update Instances
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      UPDATE CSI_ITEM_INSTANCES
	      set lot_number = null,
		     last_update_date = sysdate,
		     last_updated_by = v_user_id
	      where instance_id = l_inst_tbl(j);
	      --
	      -- Tie the Transaction to the history
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      INSERT INTO CSI_ITEM_INSTANCES_H
		  (
		   INSTANCE_HISTORY_ID
		  ,TRANSACTION_ID
		  ,INSTANCE_ID
                  ,OLD_LOT_NUMBER
                  ,NEW_LOT_NUMBER
		  ,CREATION_DATE
		  ,LAST_UPDATE_DATE
		  ,CREATED_BY
		  ,LAST_UPDATED_BY
		  ,LAST_UPDATE_LOGIN
		  ,OBJECT_VERSION_NUMBER
		 )
	      VALUES
		 (
		   l_inst_hist_tbl(j)
		  ,v_lot_txn_id
		  ,l_inst_tbl(j)
                  ,l_lot_tbl(j)
                  ,NULL
		  ,SYSDATE
		  ,SYSDATE
		  ,v_user_id
		  ,v_user_id
		  ,-1
		  ,1
		 );
        END IF;
        commit;
        EXIT WHEN CSI_LOT_CUR%NOTFOUND;
     END LOOP;
     commit;
     CLOSE CSI_LOT_CUR;*/
     --
     OPEN INV_CSI_SRL_CUR;
     LOOP
        FETCH INV_CSI_SRL_CUR BULK COLLECT INTO
        instance_id_mig,
        serial_number_mig,
        vld_org_id_mig,
        inventory_item_id_mig
        LIMIT INST_BUFFER_SIZE;
        --
        l_ctr := 0;
        l_inst_tbl.DELETE;
        l_inst_hist_tbl.DELETE;
        --
        FOR i in 1 .. instance_id_mig.count LOOP
           v_srl_ctl := null;
           Begin
              select serial_number_control_code
              into v_srl_ctl
              from MTL_SYSTEM_ITEMS
              where inventory_item_id = inventory_item_id_mig(i)
              and   organization_id = vld_org_id_mig(i);
           Exception
              when others then
                 v_srl_ctl := null;
           End;
           IF nvl(v_srl_ctl,1) = 1 THEN
              l_ctr := l_ctr + 1;
              l_inst_tbl(l_ctr) := instance_id_mig(i);
	         --
	         select CSI_ITEM_INSTANCES_H_S.nextval
	         into l_inst_hist_tbl(l_ctr) from dual;
           END IF;
        END LOOP;
        IF l_inst_tbl.count > 0 THEN
	   -- Bulk Update Instances
           l_srl_ins_flag := 'Y';
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      UPDATE CSI_ITEM_INSTANCES
	      set active_end_date = sysdate,
               instance_status_id = 1,
		     last_update_date = sysdate,
		     last_updated_by = v_user_id
	      where instance_id = l_inst_tbl(j);
	      --
	      -- Tie the Transaction to the history
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      INSERT INTO CSI_ITEM_INSTANCES_H
		  (
		   INSTANCE_HISTORY_ID
		  ,TRANSACTION_ID
		  ,INSTANCE_ID
		  ,CREATION_DATE
		  ,LAST_UPDATE_DATE
		  ,CREATED_BY
		  ,LAST_UPDATED_BY
		  ,LAST_UPDATE_LOGIN
		  ,OBJECT_VERSION_NUMBER
		 )
	      VALUES
		 (
		   l_inst_hist_tbl(j)
		  ,v_srl_txn_id
		  ,l_inst_tbl(j)
		  ,SYSDATE
		  ,SYSDATE
		  ,v_user_id
		  ,v_user_id
		  ,-1
		  ,1
		 );
        END IF;
        commit;
        EXIT WHEN INV_CSI_SRL_CUR%NOTFOUND;
     END LOOP;
     commit;
     CLOSE INV_CSI_SRL_CUR;
     --
     OPEN INV_CSI_LOT_CUR;
     LOOP
        FETCH INV_CSI_LOT_CUR BULK COLLECT INTO
        instance_id_mig,
        lot_number_mig,
        vld_org_id_mig,
        inventory_item_id_mig
        LIMIT INST_BUFFER_SIZE;
        --
        l_ctr := 0;
        l_inst_tbl.DELETE;
        l_inst_hist_tbl.DELETE;
        --
        FOR i in 1 .. instance_id_mig.count LOOP
           v_lot_ctl := null;
           Begin
              select lot_control_code
              into v_lot_ctl
              from MTL_SYSTEM_ITEMS
              where inventory_item_id = inventory_item_id_mig(i)
              and   organization_id = vld_org_id_mig(i);
           Exception
              when others then
                 v_lot_ctl := null;
           End;
           IF nvl(v_lot_ctl,1) = 1 THEN
              l_ctr := l_ctr + 1;
              l_inst_tbl(l_ctr) := instance_id_mig(i);
	         --
	         select CSI_ITEM_INSTANCES_H_S.nextval
	         into l_inst_hist_tbl(l_ctr) from dual;
           END IF;
        END LOOP;
        --
        IF l_inst_tbl.count > 0 THEN
           l_lot_ins_flag := 'Y';
	      -- Bulk Update Instances
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      UPDATE CSI_ITEM_INSTANCES
	      set active_end_date = sysdate,
               instance_status_id = 1,
		     last_update_date = sysdate,
		     last_updated_by = v_user_id
	      where instance_id = l_inst_tbl(j);
	      --
	      -- Tie the Transaction to the history
	      FORALL j in l_inst_tbl.FIRST .. l_inst_tbl.LAST
	      INSERT INTO CSI_ITEM_INSTANCES_H
		  (
		   INSTANCE_HISTORY_ID
		  ,TRANSACTION_ID
		  ,INSTANCE_ID
		  ,CREATION_DATE
		  ,LAST_UPDATE_DATE
		  ,CREATED_BY
		  ,LAST_UPDATED_BY
		  ,LAST_UPDATE_LOGIN
		  ,OBJECT_VERSION_NUMBER
		 )
	      VALUES
		 (
		   l_inst_hist_tbl(j)
		  ,v_lot_txn_id
		  ,l_inst_tbl(j)
		  ,SYSDATE
		  ,SYSDATE
		  ,v_user_id
		  ,v_user_id
		  ,-1
		  ,1
		 );
        END IF;
        commit;
        EXIT WHEN INV_CSI_LOT_CUR%NOTFOUND;
     END LOOP;
     commit;
     CLOSE INV_CSI_LOT_CUR;
     --
     -- Insert one record into CSI_TRANSACTIONS
     IF l_srl_ins_flag = 'Y' THEN
	   INSERT INTO CSI_TRANSACTIONS(
	     TRANSACTION_ID
	    ,TRANSACTION_DATE
	    ,SOURCE_TRANSACTION_DATE
	    ,SOURCE_HEADER_REF
	    ,SOURCE_LINE_REF
	    ,TRANSACTION_TYPE_ID
	    ,CREATED_BY
	    ,CREATION_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATE_LOGIN
	    ,OBJECT_VERSION_NUMBER
	   )
	   VALUES(
	     v_srl_txn_id                             -- TRANSACTION_ID
	    ,SYSDATE                              -- TRANSACTION_DATE
	    ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
	    ,'Serial or Lot Control got switched off'   -- SOURCE_HEADER_REF
	    ,'DATAFIX By Update_No_ctl_Srl_Lot_Inst' -- SOURCE_LINE_REF
	    ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
	    ,v_user_id
	    ,sysdate
	    ,v_user_id
	    ,sysdate
	    ,-1
	    ,1
	   );
     END IF;
     --
     IF l_lot_ins_flag = 'Y' THEN
	   INSERT INTO CSI_TRANSACTIONS(
	     TRANSACTION_ID
	    ,TRANSACTION_DATE
	    ,SOURCE_TRANSACTION_DATE
	    ,SOURCE_HEADER_REF
	    ,SOURCE_LINE_REF
	    ,TRANSACTION_TYPE_ID
	    ,CREATED_BY
	    ,CREATION_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATE_LOGIN
	    ,OBJECT_VERSION_NUMBER
	   )
	   VALUES(
	     v_lot_txn_id                             -- TRANSACTION_ID
	    ,SYSDATE                              -- TRANSACTION_DATE
	    ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
	    ,'Serial or Lot Control got switched off'   -- SOURCE_HEADER_REF
	    ,'DATAFIX By Update_No_ctl_Srl_Lot_Inst' -- SOURCE_LINE_REF
	    ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
	    ,v_user_id
	    ,sysdate
	    ,v_user_id
	    ,sysdate
	    ,-1
	    ,1
	   );
     END IF;
     commit;
  EXCEPTION
     when comp_error then
        null;
  END Update_No_ctl_Srl_Lot_Inst;
  --
  -- This following Procedure identifies the failed shipping Txn and Bumpup or Create the
  -- necessary Shipping subinventory.
  -- We also consider WIP issues that need to be bumped up.
  PROCEDURE Create_or_Update_Shipping_Inst IS
     CURSOR CSI_CUR IS
     select cii.transaction_error_id,cii.inv_material_transaction_id,
            null,null,null,null,null,null
     from csi_txn_errors cii
     where cii.processed_flag in ('E', 'R')
     and   cii.inv_material_transaction_id is not null;
     --
     CURSOR LOT_CUR(p_txn_id in number) IS
     select lot_number,ABS(primary_quantity) transaction_quantity
     from mtl_transaction_lot_numbers
     where transaction_id = p_txn_id;
     --
     v_txn_id                           NUMBER;
     l_upg_profile                      VARCHAR2(30) := fnd_Profile.value('CSI_UPGRADING_FROM_RELEASE');
     v_freeze_date                      DATE;
     v_txn_type_id                      NUMBER;
     v_nl_trackable                     VARCHAR2(1);
     v_mast_org_id                      NUMBER;
     v_location_id                      NUMBER;
     v_ins_condition_id                 NUMBER;
     v_mfg_srl_flag                     VARCHAR2(1);
     v_ins_status_id                    NUMBER;
     v_instance_id                      NUMBER;
     v_ins_history_id                   NUMBER;
     v_created_by                       NUMBER := fnd_global.user_id;
     v_last_updated_by                  NUMBER := fnd_global.user_id;
     v_ins_ou_id                        NUMBER;
     v_ins_ou_history_id                NUMBER;
     v_ins_party_id                     NUMBER;
     v_ins_party_history_id             NUMBER;
     v_party_id                         NUMBER;
     v_source_reference_id              NUMBER;
     v_err_msg                          VARCHAR2(2000);
     v_exists                           VARCHAR2(1);
     v_ins_qty                          NUMBER;
     v_srl_ctl                          NUMBER;
     v_lot_ctl                          NUMBER;
     v_pri_uom                          VARCHAR2(3);
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     txn_error_id_mig         NumTabType;
     mat_txn_id_mig           NumTabType;
     organization_id_mig      NumTabType;
     inventory_item_id_mig    NumTabType;
     locator_id_mig           NumTabType;
     quantity_mig             NumTabType;
     --
     Type V3Type is VARRAY(10000) of VARCHAR2(3);
     revision_mig             V3Type;
     --
     Type V10Type is VARRAY(10000) of VARCHAR2(10);
     subinv_mig               V10Type;
     --
     MAX_BUFFER_SIZE          NUMBER := 1000;
     --
     Comp_error               EXCEPTION;
     Process_next             EXCEPTION;
  BEGIN
     IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
        csi_gen_utility_pvt.populate_install_param_rec;
     END IF;
     --
     v_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
     --
     -- Get the Transaction Type ID for Txn Type MIGRATED
     Begin
	   select transaction_type_id
	   into v_txn_type_id
	   from CSI_TXN_TYPES
	   where SOURCE_TRANSACTION_TYPE = 'DATA_CORRECTION';
     Exception
	   when no_data_found then
	      v_err_msg := 'Txn Type DATA_CORRECTION not defined in CSI_TXN_TYPES';
	      Raise comp_error;
	   when others then
	      v_err_msg := 'Unable to get the ID for Txn Type DATA_CORRECTION from CSI_TXN_TYPES';
	      Raise comp_error;
     End;
     --
     -- Get the LATEST Status ID. This will be used for all INV records.
     Begin
	   select instance_status_id
	   into v_ins_status_id
	   from CSI_INSTANCE_STATUSES
	   where name = 'Latest';
     Exception
	   when no_data_found then
	      v_err_msg := 'Status ID not found in CSI for Latest Status';
	      Raise comp_error;
	   when too_many_rows then
	      v_err_msg := 'Too many rows fouund in CSI for Latest Status';
	      Raise comp_error;
	   when others then
	      v_err_msg := 'Error in getting the Status ID in CSI for Latest Status';
	      Raise comp_error;
     End;
     -- Get the Internal Party ID
     IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
        csi_gen_utility_pvt.populate_install_param_rec;
     END IF;
     --
     v_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
     --
     if v_party_id is null then
	   v_err_msg := 'Internal Party ID not found in CSI_INSTALL_PARAMETERS';
	   Raise comp_error;
     end if;
     --
     OPEN CSI_CUR;
     LOOP
        FETCH CSI_CUR BULK COLLECT INTO
        txn_error_id_mig,
        mat_txn_id_mig,
        inventory_item_id_mig,
        revision_mig,
        organization_id_mig,
        subinv_mig,
        locator_id_mig,
        quantity_mig
        LIMIT MAX_BUFFER_SIZE;
        FOR i in 1..txn_error_id_mig.count LOOP
	   Begin
              Begin
                 select inventory_item_id,organization_id,revision,
	         subinventory_code,locator_id,abs(primary_quantity) transaction_quantity
                 into inventory_item_id_mig(i),organization_id_mig(i),revision_mig(i),
                 subinv_mig(i),locator_id_mig(i),quantity_mig(i)
                 from MTL_MATERIAL_TRANSACTIONS
                 where transaction_id = mat_txn_id_mig(i)
                 and   ( (transaction_type_id = 33) OR
                         (transaction_source_type_id = 5 AND transaction_quantity < 0) );
              Exception
                 when others then
                    Raise Process_next;
              End;
	      Begin
	         select primary_uom_code,serial_number_control_code,lot_control_code
	         into v_pri_uom,v_srl_ctl,v_lot_ctl
	         from MTL_SYSTEM_ITEMS
	         where inventory_item_id = inventory_item_id_mig(i)
	         and   organization_id = organization_id_mig(i);
	      Exception
	         when no_data_found then
	            Raise Process_next;
	      End;
	      --
	      IF v_srl_ctl <> 1 THEN
	         Raise Process_next;
	      END IF;
	      --
	      -- Get the Master Organization ID
	      Begin
	         select master_organization_id
	         into v_mast_org_id
	         from MTL_PARAMETERS
	         where organization_id = organization_id_mig(i);
	      Exception
	         when no_data_found then
	            Raise Process_next;
	      End;
	      --
	      v_nl_trackable := 'N';
	      Begin
	         select comms_nl_trackable_flag
	         into v_nl_trackable
	         from MTL_SYSTEM_ITEMS
	         where inventory_item_id = inventory_item_id_mig(i)
	         and   organization_id = v_mast_org_id;
	         Exception
	            when no_data_found then
		       Raise Process_next;
	         End;
	         --
	         IF NVL(v_nl_trackable,'N') <> 'Y' THEN
	            Update CSI_TXN_ERRORS
	            set processed_flag = 'D'
		          ,error_text = 'COMMS_NL_TRACKABLE_FLAG got switched off'
                    ,last_update_date = sysdate
	            where transaction_error_id = txn_error_id_mig(i);
	            --
	            Raise Process_next;
	         END IF;
	         --
	         IF v_lot_ctl = 1 THEN
	            v_exists := 'N';
	            Begin
		       select quantity,instance_id
		       into v_ins_qty,v_instance_id
		       from CSI_ITEM_INSTANCES
		       where inventory_item_id = inventory_item_id_mig(i)
		       and   inv_organization_id = organization_id_mig(i)
                       and   serial_number is null
                       and   lot_number is null
		       and   location_type_code = 'INVENTORY'
		       and   instance_usage_code = 'IN_INVENTORY'
		       and   inv_subinventory_name = subinv_mig(i)
		       and   nvl(inv_locator_id,-999) = nvl(locator_id_mig(i),-999)
		       and   nvl(inventory_revision,'$#$') = nvl(revision_mig(i),'$#$');
		       v_exists := 'Y';
	            Exception
		       when no_data_found then
		          v_exists := 'N';
		       when too_many_rows then
		          Raise Process_next;
	            End;
	            --
	      Begin
		 select CSI_TRANSACTIONS_S.nextval
		 into v_txn_id
		 from DUAL;
	      End;
	      --
	      Begin
		 INSERT INTO CSI_TRANSACTIONS(
		      TRANSACTION_ID
		     ,TRANSACTION_DATE
		     ,SOURCE_TRANSACTION_DATE
		     ,SOURCE_HEADER_REF
		     ,TRANSACTION_TYPE_ID
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		    )
		    VALUES(
		      v_txn_id                             -- TRANSACTION_ID
		     ,SYSDATE                              -- TRANSACTION_DATE
		     ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
		     ,'DATAFIX by STAGING Bump'            -- SOURCE_HEADER_REF
		     ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
		     ,v_created_by
		     ,sysdate
		     ,v_last_updated_by
		     ,sysdate
		     ,-1
		     ,1
		    );
	       Exception
		  when others then
		     v_err_msg := 'Error while Inserting into CSI_TRANSACTIONS '||substr(sqlerrm,1,1000);
		     raise_application_error(-20000, v_err_msg );
		     Raise;
	       End;
	      --
	      IF v_exists = 'Y' THEN
		 UPDATE CSI_ITEM_INSTANCES
		 set quantity = quantity + quantity_mig(i),
		     active_end_date = null,
		     instance_status_id = v_ins_status_id,
		     last_update_date = sysdate,
		     last_updated_by = v_last_updated_by,
                     last_vld_organization_id = organization_id_mig(i)
		 where instance_id = v_instance_id;
		 --
		 -- Tie the Transaction to the history
		 INSERT INTO CSI_ITEM_INSTANCES_H
		     (
		      INSTANCE_HISTORY_ID
		     ,TRANSACTION_ID
		     ,INSTANCE_ID
		     ,CREATION_DATE
		     ,LAST_UPDATE_DATE
		     ,CREATED_BY
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		    )
		 VALUES
		    (
		      CSI_ITEM_INSTANCES_H_S.nextval
		     ,v_txn_id
		     ,v_instance_id
		     ,SYSDATE
		     ,SYSDATE
		     ,v_created_by
		     ,v_last_updated_by
		     ,-1
		     ,1
		    );
		 --
		 Update CSI_TXN_ERRORS
		 set processed_flag = 'R',
                     last_update_date = sysdate
		 where transaction_error_id = txn_error_id_mig(i);
		 --
		 Raise Process_next;
	      END IF;
	      -- If instance is not found then Create the Instance
	      -- Get the Location ID from MTL_SECONDARY_INVENTORIES
	      v_location_id := NULL;
	      Begin
		 select location_id
		 into v_location_id
		 from MTL_SECONDARY_INVENTORIES
		 where organization_id = organization_id_mig(i)
		 and   secondary_inventory_name = subinv_mig(i);
	      Exception
		 when no_data_found then
		    Raise Process_next;
	      End;
	      -- Get the Location ID from HR_ORGANIZATION_UNITS
	      IF v_location_id IS NULL THEN
		 Begin
		    select location_id
		    into v_location_id
		    from HR_ORGANIZATION_UNITS
		    where organization_id = organization_id_mig(i);
		 Exception
		    when no_data_found then
		       Raise Process_next;
		 End;
	      END IF;
	      --
	      Begin
		 select csi_item_instances_s.nextval
		 into v_instance_id
		 from DUAL;
	      End;
	      --
	      -- Insert into CSI_ITEM_INSTANCES
	      Begin
		 INSERT INTO CSI_ITEM_INSTANCES(
		      INSTANCE_ID
		     ,INSTANCE_NUMBER
		     ,EXTERNAL_REFERENCE
		     ,INVENTORY_ITEM_ID
		     ,INVENTORY_REVISION
		     ,INV_MASTER_ORGANIZATION_ID
		     ,QUANTITY
		     ,UNIT_OF_MEASURE
		     ,ACCOUNTING_CLASS_CODE
		     ,INSTANCE_STATUS_ID
		     ,CUSTOMER_VIEW_FLAG
		     ,MERCHANT_VIEW_FLAG
		     ,SELLABLE_FLAG
		     ,SYSTEM_ID
		     ,INSTANCE_TYPE_CODE
		     ,ACTIVE_START_DATE
		     ,ACTIVE_END_DATE
		     ,LOCATION_TYPE_CODE
		     ,LOCATION_ID
		     ,INV_ORGANIZATION_ID
		     ,INV_SUBINVENTORY_NAME
		     ,INV_LOCATOR_ID
		     ,INSTALL_DATE
		     ,MANUALLY_CREATED_FLAG
		     ,CREATION_COMPLETE_FLAG
		     ,COMPLETENESS_FLAG
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		     ,INSTANCE_USAGE_CODE
		     ,OWNER_PARTY_SOURCE_TABLE
		     ,OWNER_PARTY_ID
		     ,LAST_VLD_ORGANIZATION_ID
		    )
		    VALUES(
		      v_instance_id                        -- INSTANCE_ID
		     ,v_instance_id                        -- INSTANCE_NUMBER
		     ,NULL                                 -- EXTERNAL_REFERENCE
		     ,inventory_item_id_mig(i)              -- INVENTORY_ITEM_ID
		     ,revision_mig(i)                       -- INVENTORY_REVISION
		     ,v_mast_org_id                        -- INV_MASTER_ORGANIZATION_ID
		     ,quantity_mig(i)           -- QUANTITY
		     ,v_pri_uom                            -- UNIT_OF_MEASURE (PRIMARY)
		     ,'INV'                                -- ACCOUNTING_CLASS_CODE
		     ,v_ins_status_id                      -- INSTANCE_STATUS_ID
		     ,'N'                                  -- CUSTOMER_VIEW_FLAG
		     ,'Y'                                  -- MERCHANT_VIEW_FLAG
		     ,'Y'                                  -- SELLABLE_FLAG
		     ,NULL                                 -- SYSTEM_ID
		     ,NULL                                 -- INSTANCE_TYPE_CODE
		     ,SYSDATE                              -- ACTIVE_START_DATE
		     ,NULL                                 -- ACTIVE_END_DATE
		     ,'INVENTORY'                          -- LOCATION_TYPE_CODE
		     ,v_location_id                        -- LOCATION_ID
		     ,organization_id_mig(i)                -- INV_ORGANIZATION_ID
		     ,subinv_mig(i)              -- INV_SUBINVENTORY_NAME
		     ,locator_id_mig(i)                     -- INV_LOCATOR_ID
		     ,NULL                                 -- INSTALL_DATE
		     ,'N'                                  -- MANUALLY_CREATED_FLAG
		     ,'Y'                                  -- CREATION_COMPLETE_FLAG
		     ,'Y'                                  -- COMPLETENESS_FLAG
		     ,v_created_by                         -- CREATED_BY
		     ,sysdate                              -- CREATION_DATE
		     ,v_last_updated_by                    -- LAST_UPDATED_BY
		     ,sysdate                              -- LAST_UPDATE_DATE
		     ,-1                                   -- LAST_UPDATE_LOGIN
		     ,1                                    -- OBJECT_VERSION_NUMBER
		     ,NULL                                 -- SECURITY_GROUP_ID
		     ,'IN_INVENTORY'                       -- INSTANCE_USAGE_CODE
		     ,'HZ_PARTIES'                         -- OWNER_PARTY_SOURCE_TABLE
		     ,v_party_id                           -- OWNER_PARTY_ID
		     ,organization_id_mig(i)                -- LAST_VLD_ORGANIZATION_ID
		    );
	      Exception
		 when others then
		    v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
					  ||' into CSI_ITEM_INSTANCES '||SUBSTR(sqlerrm,1,1000);
		    raise_application_error(-20000, v_err_msg );
		    Raise;
	      End;
	      -- Use the same instance record to create the history
	      Begin
		    select CSI_ITEM_INSTANCES_H_S.nextval
		    into v_ins_history_id
		    from DUAL;
	      End;
	      --
	      Begin
		    INSERT INTO CSI_ITEM_INSTANCES_H(
		      INSTANCE_HISTORY_ID
		     ,INSTANCE_ID
		     ,TRANSACTION_ID
		     ,OLD_INSTANCE_NUMBER
		     ,NEW_INSTANCE_NUMBER
		     ,OLD_EXTERNAL_REFERENCE
		     ,NEW_EXTERNAL_REFERENCE
		     ,OLD_INVENTORY_ITEM_ID
		     ,NEW_INVENTORY_ITEM_ID
		     ,OLD_INVENTORY_REVISION
		     ,NEW_INVENTORY_REVISION
		     ,OLD_INV_MASTER_ORGANIZATION_ID
		     ,NEW_INV_MASTER_ORGANIZATION_ID
		     ,OLD_QUANTITY
		     ,NEW_QUANTITY
		     ,OLD_UNIT_OF_MEASURE
		     ,NEW_UNIT_OF_MEASURE
		     ,OLD_ACCOUNTING_CLASS_CODE
		     ,NEW_ACCOUNTING_CLASS_CODE
		     ,OLD_INSTANCE_STATUS_ID
		     ,NEW_INSTANCE_STATUS_ID
		     ,OLD_CUSTOMER_VIEW_FLAG
		     ,NEW_CUSTOMER_VIEW_FLAG
		     ,OLD_MERCHANT_VIEW_FLAG
		     ,NEW_MERCHANT_VIEW_FLAG
		     ,OLD_SELLABLE_FLAG
		     ,NEW_SELLABLE_FLAG
		     ,OLD_SYSTEM_ID
		     ,NEW_SYSTEM_ID
		     ,OLD_INSTANCE_TYPE_CODE
		     ,NEW_INSTANCE_TYPE_CODE
		     ,OLD_ACTIVE_START_DATE
		     ,NEW_ACTIVE_START_DATE
		     ,OLD_ACTIVE_END_DATE
		     ,NEW_ACTIVE_END_DATE
		     ,OLD_LOCATION_TYPE_CODE
		     ,NEW_LOCATION_TYPE_CODE
		     ,OLD_LOCATION_ID
		     ,NEW_LOCATION_ID
		     ,OLD_INV_ORGANIZATION_ID
		     ,NEW_INV_ORGANIZATION_ID
		     ,OLD_INV_SUBINVENTORY_NAME
		     ,NEW_INV_SUBINVENTORY_NAME
		     ,OLD_INV_LOCATOR_ID
		     ,NEW_INV_LOCATOR_ID
		     ,OLD_COMPLETENESS_FLAG
		     ,NEW_COMPLETENESS_FLAG
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		     ,FULL_DUMP_FLAG
		     ,OLD_INST_USAGE_CODE
		     ,NEW_INST_USAGE_CODE
		     ,OLD_LAST_VLD_ORGANIZATION_ID
		     ,NEW_LAST_VLD_ORGANIZATION_ID
		    )
		    VALUES(
		      v_ins_history_id                                    -- INSTANCE_HISTORY_ID
		     ,v_instance_id                                       -- INSTANCE_ID
		     ,v_txn_id                                            -- TRANSACTION_ID
		     ,NULL                                                -- OLD_INSTANCE_NUMBER
		     ,v_instance_id                                       -- NEW_INSTANCE_NUMBER
		     ,NULL                                                -- OLD_EXTERNAL_REFERENCE
		     ,NULL                                                -- NEW_EXTERNAL_REFERENCE
		     ,NULL                                                -- OLD_INVENTORY_ITEM_ID
		     ,inventory_item_id_mig(i)                             -- NEW_INVENTORY_ITEM_ID
		     ,NULL                                                -- OLD_INVENTORY_REVISION
		     ,revision_mig(i)                                      -- NEW_INVENTORY_REVISION
		     ,NULL                                                -- OLD_INV_MASTER_ORGANIZATION_ID
		     ,v_mast_org_id                                       -- NEW_INV_MASTER_ORGANIZATION_ID
		     ,NULL                                                -- OLD_QUANTITY
		     ,quantity_mig(i)                          -- NEW_QUANTITY
		     ,NULL                                                -- OLD_UNIT_OF_MEASURE
		     ,v_pri_uom                                           -- NEW_UNIT_OF_MEASURE
		     ,NULL                                                -- OLD_ACCOUNTING_CLASS_CODE
		     ,'INV'                                               -- NEW_ACCOUNTING_CLASS_CODE
		     ,NULL                                                -- OLD_INSTANCE_STATUS_ID
		     ,v_ins_status_id                                     -- NEW_INSTANCE_STATUS_ID
		     ,NULL                                                -- OLD_CUSTOMER_VIEW_FLAG
		     ,'N'                                                 -- NEW_CUSTOMER_VIEW_FLAG
		     ,NULL                                                -- OLD_MERCHANT_VIEW_FLAG
		     ,'Y'                                                 -- NEW_MERCHANT_VIEW_FLAG
		     ,NULL                                                -- OLD_SELLABLE_FLAG
		     ,NULL                                                -- NEW_SELLABLE_FLAG
		     ,NULL                                                -- OLD_SYSTEM_ID
		     ,NULL                                                -- NEW_SYSTEM_ID
		     ,NULL                                                -- OLD_INSTANCE_TYPE_CODE
		     ,NULL                                                -- NEW_INSTANCE_TYPE_CODE
		     ,NULL                                                -- OLD_ACTIVE_START_DATE
		     ,SYSDATE                                             -- NEW_ACTIVE_START_DATE
		     ,NULL                                                -- OLD_ACTIVE_END_DATE
		     ,NULL                                                -- NEW_ACTIVE_END_DATE
		     ,NULL                                                -- OLD_LOCATION_TYPE_CODE
		     ,'INVENTORY'                                         -- NEW_LOCATION_TYPE_CODE
		     ,NULL                                                -- OLD_LOCATION_ID
		     ,v_location_id                                       -- NEW_LOCATION_ID
		     ,NULL                                                -- OLD_INV_ORGANIZATION_ID
		     ,organization_id_mig(i)                               -- NEW_INV_ORGANIZATION_ID
		     ,NULL                                                -- OLD_INV_SUBINVENTORY_NAME
		     ,subinv_mig(i)                             -- NEW_INV_SUBINVENTORY_NAME
		     ,NULL                                                -- OLD_INV_LOCATOR_ID
		     ,locator_id_mig(i)                                    -- NEW_INV_LOCATOR_ID
		     ,NULL                                                -- OLD_COMPLETENESS_FLAG
		     ,'Y'                                                 -- NEW_COMPLETENESS_FLAG
		     ,v_created_by                                        -- CREATED_BY
		     ,sysdate                                             -- CREATION_DATE
		     ,v_last_updated_by                                   -- LAST_UPDATED_BY
		     ,sysdate                                             -- LAST_UPDATE_DATE
		     ,-1                                                  -- LAST_UPDATE_LOGIN
		     ,1                                                   -- OBJECT_VERSION_NUMBER
		     ,NULL                                                -- SECURITY_GROUP_ID
		     ,'N'                                                 -- FULL_DUMP_FLAG
		     ,NULL                                                -- OLD_INST_USAGE_CODE
		     ,'IN_INVENTORY'                                      -- NEW_INST_USAGE_CODE
		     ,NULL                                                -- OLD_LAST_VLD_ORGANIZATION_ID
		     ,organization_id_mig(i)                               -- NEW_LAST_VLD_ORGANIZATION_ID
		    );
	      Exception
		    when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
				   ||' into CSI_ITEM_INSTANCES_H Using the Same Instance '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
	      End;
	      --
	      Begin
		 select CSI_I_PARTIES_S.nextval
		 into v_ins_party_id
		 from DUAL;
	      End;
	      Begin
		    INSERT INTO CSI_I_PARTIES(
		      INSTANCE_PARTY_ID
		     ,INSTANCE_ID
		     ,PARTY_SOURCE_TABLE
		     ,PARTY_ID
		     ,RELATIONSHIP_TYPE_CODE
		     ,CONTACT_FLAG
		     ,CONTACT_IP_ID
		     ,ACTIVE_START_DATE
		     ,ACTIVE_END_DATE
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		    )
		    VALUES(
		      v_ins_party_id                   -- INSTANCE_PARTY_ID
		     ,v_instance_id                    -- INSTANCE_ID
		     ,'HZ_PARTIES'                     -- PARTY_SOURCE_TABLE
		     ,v_party_id                       -- PARTY_ID
		     ,'OWNER'                          -- RELATIONSHIP_TYPE_CODE
		     ,'N'                              -- CONTACT_FLAG
		     ,NULL                             -- CONTACT_IP_ID
		     ,SYSDATE                          -- ACTIVE_START_DATE
		     ,NULL                             -- ACTIVE_END_DATE
		     ,v_created_by                     -- CREATED_BY
		     ,sysdate                          -- CREATION_DATE
		     ,v_last_updated_by                -- LAST_UPDATED_BY
		     ,sysdate                          -- LAST_UPDATE_DATE
		     ,-1                               -- LAST_UPDATE_LOGIN
		     ,1                                -- OBJECT_VERSION_NUMBER
		     ,NULL                             -- SECURITY_GROUP_ID
		    );
		    Exception
			  when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
						  ||' into CSI_I_PARTIES '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
		    End;
		    -- Insert into CSI_I_PARTIES_H
	      Begin
		 select CSI_I_PARTIES_H_S.nextval
		 into v_ins_party_history_id
		 from DUAL;
	      End;
	      -- Insert into CSI_I_PARTIES_H
	      Begin
		    INSERT INTO CSI_I_PARTIES_H(
		      INSTANCE_PARTY_HISTORY_ID
		     ,INSTANCE_PARTY_ID
		     ,TRANSACTION_ID
		     ,OLD_PARTY_SOURCE_TABLE
		     ,NEW_PARTY_SOURCE_TABLE
		     ,OLD_PARTY_ID
		     ,NEW_PARTY_ID
		     ,OLD_RELATIONSHIP_TYPE_CODE
		     ,NEW_RELATIONSHIP_TYPE_CODE
		     ,OLD_CONTACT_FLAG
		     ,NEW_CONTACT_FLAG
		     ,OLD_CONTACT_IP_ID
		     ,NEW_CONTACT_IP_ID
		     ,OLD_ACTIVE_START_DATE
		     ,NEW_ACTIVE_START_DATE
		     ,OLD_ACTIVE_END_DATE
		     ,NEW_ACTIVE_END_DATE
		     ,FULL_DUMP_FLAG
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		    )
		    VALUES(
		      v_ins_party_history_id               -- INSTANCE_PARTY_HISTORY_ID
		     ,v_ins_party_id                       -- INSTANCE_PARTY_ID
		     ,v_txn_id                             -- TRANSACTION_ID
		     ,NULL                                 -- OLD_PARTY_SOURCE_TABLE
		     ,'HZ_PARTIES'                         -- NEW_PARTY_SOURCE_TABLE
		     ,NULL                                 -- OLD_PARTY_ID
		     ,v_party_id                           -- NEW_PARTY_ID
		     ,NULL                                 -- OLD_RELATIONSHIP_TYPE_CODE
		     ,'OWNER'                              -- NEW_RELATIONSHIP_TYPE_CODE
		     ,NULL                                 -- OLD_CONTACT_FLAG
		     ,'N'                                  -- NEW_CONTACT_FLAG
		     ,NULL                                 -- OLD_CONTACT_IP_ID
		     ,NULL                                 -- NEW_CONTACT_IP_ID
		     ,NULL                                 -- OLD_ACTIVE_START_DATE
		     ,SYSDATE                              -- NEW_ACTIVE_START_DATE
		     ,NULL                                 -- OLD_ACTIVE_END_DATE
		     ,NULL                                 -- NEW_ACTIVE_END_DATE
		     ,'N'                                  -- FULL_DUMP_FLAG
		     ,v_created_by
		     ,sysdate
		     ,v_last_updated_by
		     ,sysdate
		     ,-1
		     ,1
		     ,NULL
		    );
	      Exception
		    when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
				   ||' into CSI_I_PARTIES_H using the same Instance '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
	      End;
	   ELSE -- Lot controlled item
	      FOR lot_rec in LOT_CUR(mat_txn_id_mig(i)) LOOP
	      v_exists := 'N';
		 Begin
		    select quantity,instance_id
		    into v_ins_qty,v_instance_id
		    from CSI_ITEM_INSTANCES
		    where inventory_item_id = inventory_item_id_mig(i)
		    and   inv_organization_id = organization_id_mig(i)
                    and   serial_number is null
		    and   location_type_code = 'INVENTORY'
		    and   instance_usage_code = 'IN_INVENTORY'
		    and   inv_subinventory_name = subinv_mig(i)
		    and   nvl(inv_locator_id,-999) = nvl(locator_id_mig(i),-999)
		    and   nvl(inventory_revision,'$#$') = nvl(revision_mig(i),'$#$')
		    and   lot_number = lot_rec.lot_number;
		    v_exists := 'Y';
		 Exception
		    when no_data_found then
		       v_exists := 'N';
		    when too_many_rows then
		       Raise Process_next;
		 End;
		 --
		 Begin
		    select CSI_TRANSACTIONS_S.nextval
		    into v_txn_id
		    from DUAL;
		 End;
		 --
		 Begin
		    INSERT INTO CSI_TRANSACTIONS(
			 TRANSACTION_ID
			,TRANSACTION_DATE
			,SOURCE_TRANSACTION_DATE
			,SOURCE_HEADER_REF
			,TRANSACTION_TYPE_ID
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
		       )
		       VALUES(
			 v_txn_id                             -- TRANSACTION_ID
			,SYSDATE                              -- TRANSACTION_DATE
			,SYSDATE                              -- SOURCE_TRANSACTION_DATE
			,'DATAFIX By STAGING Bump'            -- SOURCE_HEADER_REF
			,v_txn_type_id                        -- TRANSACTION_TYPE_ID
			,v_created_by
			,sysdate
			,v_last_updated_by
			,sysdate
			,-1
			,1
		       );
		  Exception
		     when others then
			v_err_msg := 'Error while Inserting into CSI_TRANSACTIONS '||substr(sqlerrm,1,1000);
			raise_application_error(-20000, v_err_msg );
			Raise;
		  End;
		 --
		 IF v_exists = 'Y' THEN
		    UPDATE CSI_ITEM_INSTANCES
		    set quantity = quantity + lot_rec.transaction_quantity,
			active_end_date = null,
			instance_status_id = v_ins_status_id,
			last_update_date = sysdate,
			last_updated_by = v_last_updated_by,
                        last_vld_organization_id = organization_id_mig(i)
		    where instance_id = v_instance_id;
		    --
		    -- Tie the Transaction to the history
		    INSERT INTO CSI_ITEM_INSTANCES_H
			(
			 INSTANCE_HISTORY_ID
			,TRANSACTION_ID
			,INSTANCE_ID
			,CREATION_DATE
			,LAST_UPDATE_DATE
			,CREATED_BY
			,LAST_UPDATED_BY
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
		       )
		    VALUES
		       (
			 CSI_ITEM_INSTANCES_H_S.nextval
			,v_txn_id
			,v_instance_id
			,SYSDATE
			,SYSDATE
			,v_created_by
			,v_last_updated_by
			,-1
			,1
		       );
		    --
		    Update CSI_TXN_ERRORS
		    set processed_flag = 'R',
                        last_update_date = sysdate
		    where transaction_error_id = txn_error_id_mig(i);
		    --
		    Raise Process_next;
		 END IF;
		 -- If instance not found then Create the Instance
		 -- Get the Location ID from MTL_SECONDARY_INVENTORIES
		 v_location_id := NULL;
		 Begin
		    select location_id
		    into v_location_id
		    from MTL_SECONDARY_INVENTORIES
		    where organization_id = organization_id_mig(i)
		    and   secondary_inventory_name = subinv_mig(i);
		 Exception
		    when no_data_found then
		       Raise Process_next;
		 End;
		 -- Get the Location ID from HR_ORGANIZATION_UNITS
		 IF v_location_id IS NULL THEN
		    Begin
		       select location_id
		       into v_location_id
		       from HR_ORGANIZATION_UNITS
		       where organization_id = organization_id_mig(i);
		    Exception
		       when no_data_found then
			  Raise Process_next;
		    End;
		 END IF;
		 --
		 Begin
		    select csi_item_instances_s.nextval
		    into v_instance_id
		    from DUAL;
		 End;
		 --
		 -- Insert into CSI_ITEM_INSTANCES
		 Begin
		    INSERT INTO CSI_ITEM_INSTANCES(
			 INSTANCE_ID
			,INSTANCE_NUMBER
			,EXTERNAL_REFERENCE
			,INVENTORY_ITEM_ID
			,INVENTORY_REVISION
			,INV_MASTER_ORGANIZATION_ID
			,MFG_SERIAL_NUMBER_FLAG
			,LOT_NUMBER
			,QUANTITY
			,UNIT_OF_MEASURE
			,ACCOUNTING_CLASS_CODE
			,INSTANCE_STATUS_ID
			,CUSTOMER_VIEW_FLAG
			,MERCHANT_VIEW_FLAG
			,SELLABLE_FLAG
			,SYSTEM_ID
			,INSTANCE_TYPE_CODE
			,ACTIVE_START_DATE
			,ACTIVE_END_DATE
			,LOCATION_TYPE_CODE
			,LOCATION_ID
			,INV_ORGANIZATION_ID
			,INV_SUBINVENTORY_NAME
			,INV_LOCATOR_ID
			,INSTALL_DATE
			,MANUALLY_CREATED_FLAG
			,CREATION_COMPLETE_FLAG
			,COMPLETENESS_FLAG
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
			,SECURITY_GROUP_ID
			,INSTANCE_USAGE_CODE
			,OWNER_PARTY_SOURCE_TABLE
			,OWNER_PARTY_ID
			,LAST_VLD_ORGANIZATION_ID
		       )
		       VALUES(
			 v_instance_id                        -- INSTANCE_ID
			,v_instance_id                        -- INSTANCE_NUMBER
			,NULL                                 -- EXTERNAL_REFERENCE
			,inventory_item_id_mig(i)              -- INVENTORY_ITEM_ID
			,revision_mig(i)                       -- INVENTORY_REVISION
			,v_mast_org_id                        -- INV_MASTER_ORGANIZATION_ID
			,'Y'                                  -- MFG_SERIAL_NUMBER_FLAG
			,lot_rec.lot_number                   -- LOT_NUMBER
			,lot_rec.transaction_quantity         -- QUANTITY
			,v_pri_uom                            -- UNIT_OF_MEASURE (PRIMARY)
			,'INV'                                -- ACCOUNTING_CLASS_CODE
			,v_ins_status_id                      -- INSTANCE_STATUS_ID
			,'N'                                  -- CUSTOMER_VIEW_FLAG
			,'Y'                                  -- MERCHANT_VIEW_FLAG
			,'Y'                                  -- SELLABLE_FLAG
			,NULL                                 -- SYSTEM_ID
			,NULL                                 -- INSTANCE_TYPE_CODE
			,SYSDATE                              -- ACTIVE_START_DATE
			,NULL                                 -- ACTIVE_END_DATE
			,'INVENTORY'                          -- LOCATION_TYPE_CODE
			,v_location_id                        -- LOCATION_ID
			,organization_id_mig(i)                -- INV_ORGANIZATION_ID
			,subinv_mig(i)              -- INV_SUBINVENTORY_NAME
			,locator_id_mig(i)                     -- INV_LOCATOR_ID
			,NULL                                 -- INSTALL_DATE
			,'N'                                  -- MANUALLY_CREATED_FLAG
			,'Y'                                  -- CREATION_COMPLETE_FLAG
			,'Y'                                  -- COMPLETENESS_FLAG
			,v_created_by                         -- CREATED_BY
			,sysdate                              -- CREATION_DATE
			,v_last_updated_by                    -- LAST_UPDATED_BY
			,sysdate                              -- LAST_UPDATE_DATE
			,-1                                   -- LAST_UPDATE_LOGIN
			,1                                    -- OBJECT_VERSION_NUMBER
			,NULL                                 -- SECURITY_GROUP_ID
			,'IN_INVENTORY'                       -- INSTANCE_USAGE_CODE
			,'HZ_PARTIES'                         -- OWNER_PARTY_SOURCE_TABLE
			,v_party_id                           -- OWNER_PARTY_ID
			,organization_id_mig(i)                -- LAST_VLD_ORGANIZATION_ID
		       );
		 Exception
		       when others then
			     v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
						     ||' into CSI_ITEM_INSTANCES '||SUBSTR(sqlerrm,1,1000);
				raise_application_error(-20000, v_err_msg );
			     Raise;
		 End;
		 -- Use the same instance record to create the history
		 Begin
		       select CSI_ITEM_INSTANCES_H_S.nextval
		       into v_ins_history_id
		       from DUAL;
		 End;
		 --
		 Begin
		       INSERT INTO CSI_ITEM_INSTANCES_H(
			 INSTANCE_HISTORY_ID
			,INSTANCE_ID
			,TRANSACTION_ID
			,OLD_INSTANCE_NUMBER
			,NEW_INSTANCE_NUMBER
			,OLD_EXTERNAL_REFERENCE
			,NEW_EXTERNAL_REFERENCE
			,OLD_INVENTORY_ITEM_ID
			,NEW_INVENTORY_ITEM_ID
			,OLD_INVENTORY_REVISION
			,NEW_INVENTORY_REVISION
			,OLD_INV_MASTER_ORGANIZATION_ID
			,NEW_INV_MASTER_ORGANIZATION_ID
			,OLD_MFG_SERIAL_NUMBER_FLAG
			,NEW_MFG_SERIAL_NUMBER_FLAG
			,OLD_LOT_NUMBER
			,NEW_LOT_NUMBER
			,OLD_QUANTITY
			,NEW_QUANTITY
			,OLD_UNIT_OF_MEASURE
			,NEW_UNIT_OF_MEASURE
			,OLD_ACCOUNTING_CLASS_CODE
			,NEW_ACCOUNTING_CLASS_CODE
			,OLD_INSTANCE_STATUS_ID
			,NEW_INSTANCE_STATUS_ID
			,OLD_CUSTOMER_VIEW_FLAG
			,NEW_CUSTOMER_VIEW_FLAG
			,OLD_MERCHANT_VIEW_FLAG
			,NEW_MERCHANT_VIEW_FLAG
			,OLD_SELLABLE_FLAG
			,NEW_SELLABLE_FLAG
			,OLD_SYSTEM_ID
			,NEW_SYSTEM_ID
			,OLD_INSTANCE_TYPE_CODE
			,NEW_INSTANCE_TYPE_CODE
			,OLD_ACTIVE_START_DATE
			,NEW_ACTIVE_START_DATE
			,OLD_ACTIVE_END_DATE
			,NEW_ACTIVE_END_DATE
			,OLD_LOCATION_TYPE_CODE
			,NEW_LOCATION_TYPE_CODE
			,OLD_LOCATION_ID
			,NEW_LOCATION_ID
			,OLD_INV_ORGANIZATION_ID
			,NEW_INV_ORGANIZATION_ID
			,OLD_INV_SUBINVENTORY_NAME
			,NEW_INV_SUBINVENTORY_NAME
			,OLD_INV_LOCATOR_ID
			,NEW_INV_LOCATOR_ID
			,OLD_COMPLETENESS_FLAG
			,NEW_COMPLETENESS_FLAG
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
			,SECURITY_GROUP_ID
			,FULL_DUMP_FLAG
			,OLD_INST_USAGE_CODE
			,NEW_INST_USAGE_CODE
			,OLD_LAST_VLD_ORGANIZATION_ID
			,NEW_LAST_VLD_ORGANIZATION_ID
		       )
		       VALUES(
			 v_ins_history_id                                    -- INSTANCE_HISTORY_ID
			,v_instance_id                                       -- INSTANCE_ID
			,v_txn_id                                            -- TRANSACTION_ID
			,NULL                                                -- OLD_INSTANCE_NUMBER
			,v_instance_id                                       -- NEW_INSTANCE_NUMBER
			,NULL                                                -- OLD_EXTERNAL_REFERENCE
			,NULL                                                -- NEW_EXTERNAL_REFERENCE
			,NULL                                                -- OLD_INVENTORY_ITEM_ID
			,inventory_item_id_mig(i)                             -- NEW_INVENTORY_ITEM_ID
			,NULL                                                -- OLD_INVENTORY_REVISION
			,revision_mig(i)                                      -- NEW_INVENTORY_REVISION
			,NULL                                                -- OLD_INV_MASTER_ORGANIZATION_ID
			,v_mast_org_id                                       -- NEW_INV_MASTER_ORGANIZATION_ID
			,NULL                                                -- OLD_MFG_SERIAL_NUMBER_FLAG
			,'Y'                                                 -- NEW_MFG_SERIAL_NUMBER_FLAG
			,NULL                                                -- OLD_LOT_NUMBER
			,lot_rec.lot_number                                  -- NEW_LOT_NUMBER
			,NULL                                                -- OLD_QUANTITY
			,lot_rec.transaction_quantity                        -- NEW_QUANTITY
			,NULL                                                -- OLD_UNIT_OF_MEASURE
			,v_pri_uom                                           -- NEW_UNIT_OF_MEASURE
			,NULL                                                -- OLD_ACCOUNTING_CLASS_CODE
			,'INV'                                               -- NEW_ACCOUNTING_CLASS_CODE
			,NULL                                                -- OLD_INSTANCE_STATUS_ID
			,v_ins_status_id                                     -- NEW_INSTANCE_STATUS_ID
			,NULL                                                -- OLD_CUSTOMER_VIEW_FLAG
			,'N'                                                 -- NEW_CUSTOMER_VIEW_FLAG
			,NULL                                                -- OLD_MERCHANT_VIEW_FLAG
			,'Y'                                                 -- NEW_MERCHANT_VIEW_FLAG
			,NULL                                                -- OLD_SELLABLE_FLAG
			,NULL                                                -- NEW_SELLABLE_FLAG
			,NULL                                                -- OLD_SYSTEM_ID
			,NULL                                                -- NEW_SYSTEM_ID
			,NULL                                                -- OLD_INSTANCE_TYPE_CODE
			,NULL                                                -- NEW_INSTANCE_TYPE_CODE
			,NULL                                                -- OLD_ACTIVE_START_DATE
			,SYSDATE                                             -- NEW_ACTIVE_START_DATE
			,NULL                                                -- OLD_ACTIVE_END_DATE
			,NULL                                                -- NEW_ACTIVE_END_DATE
			,NULL                                                -- OLD_LOCATION_TYPE_CODE
			,'INVENTORY'                                         -- NEW_LOCATION_TYPE_CODE
			,NULL                                                -- OLD_LOCATION_ID
			,v_location_id                                       -- NEW_LOCATION_ID
			,NULL                                                -- OLD_INV_ORGANIZATION_ID
			,organization_id_mig(i)                               -- NEW_INV_ORGANIZATION_ID
			,NULL                                                -- OLD_INV_SUBINVENTORY_NAME
			,subinv_mig(i)                             -- NEW_INV_SUBINVENTORY_NAME
			,NULL                                                -- OLD_INV_LOCATOR_ID
			,locator_id_mig(i)                                    -- NEW_INV_LOCATOR_ID
			,NULL                                                -- OLD_COMPLETENESS_FLAG
			,'Y'                                                 -- NEW_COMPLETENESS_FLAG
			,v_created_by                                        -- CREATED_BY
			,sysdate                                             -- CREATION_DATE
			,v_last_updated_by                                   -- LAST_UPDATED_BY
			,sysdate                                             -- LAST_UPDATE_DATE
			,-1                                                  -- LAST_UPDATE_LOGIN
			,1                                                   -- OBJECT_VERSION_NUMBER
			,NULL                                                -- SECURITY_GROUP_ID
			,'N'                                                 -- FULL_DUMP_FLAG
			,NULL                                                -- OLD_INST_USAGE_CODE
			,'IN_INVENTORY'                                      -- NEW_INST_USAGE_CODE
			,NULL                                                -- OLD_LAST_VLD_ORGANIZATION_ID
			,organization_id_mig(i)                               -- NEW_LAST_VLD_ORGANIZATION_ID
		       );
		 Exception
		       when others then
			     v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
				      ||' into CSI_ITEM_INSTANCES_H Using the Same Instance '||SUBSTR(sqlerrm,1,1000);
				raise_application_error(-20000, v_err_msg );
			     Raise;
		 End;
		 --
		 Begin
		    select CSI_I_PARTIES_S.nextval
		    into v_ins_party_id
		    from DUAL;
		 End;
		 Begin
		       INSERT INTO CSI_I_PARTIES(
			 INSTANCE_PARTY_ID
			,INSTANCE_ID
			,PARTY_SOURCE_TABLE
			,PARTY_ID
			,RELATIONSHIP_TYPE_CODE
			,CONTACT_FLAG
			,CONTACT_IP_ID
			,ACTIVE_START_DATE
			,ACTIVE_END_DATE
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
			,SECURITY_GROUP_ID
		       )
		       VALUES(
			 v_ins_party_id                   -- INSTANCE_PARTY_ID
			,v_instance_id                    -- INSTANCE_ID
			,'HZ_PARTIES'                     -- PARTY_SOURCE_TABLE
			,v_party_id                       -- PARTY_ID
			,'OWNER'                          -- RELATIONSHIP_TYPE_CODE
			,'N'                              -- CONTACT_FLAG
			,NULL                             -- CONTACT_IP_ID
			,SYSDATE                          -- ACTIVE_START_DATE
			,NULL                             -- ACTIVE_END_DATE
			,v_created_by                     -- CREATED_BY
			,sysdate                          -- CREATION_DATE
			,v_last_updated_by                -- LAST_UPDATED_BY
			,sysdate                          -- LAST_UPDATE_DATE
			,-1                               -- LAST_UPDATE_LOGIN
			,1                                -- OBJECT_VERSION_NUMBER
			,NULL                             -- SECURITY_GROUP_ID
		       );
		       Exception
			     when others then
			     v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
						     ||' into CSI_I_PARTIES '||SUBSTR(sqlerrm,1,1000);
				raise_application_error(-20000, v_err_msg );
			     Raise;
		       End;
		       -- Insert into CSI_I_PARTIES_H
		 Begin
		    select CSI_I_PARTIES_H_S.nextval
		    into v_ins_party_history_id
		    from DUAL;
		 End;
		 -- Insert into CSI_I_PARTIES_H
		 Begin
		       INSERT INTO CSI_I_PARTIES_H(
			 INSTANCE_PARTY_HISTORY_ID
			,INSTANCE_PARTY_ID
			,TRANSACTION_ID
			,OLD_PARTY_SOURCE_TABLE
			,NEW_PARTY_SOURCE_TABLE
			,OLD_PARTY_ID
			,NEW_PARTY_ID
			,OLD_RELATIONSHIP_TYPE_CODE
			,NEW_RELATIONSHIP_TYPE_CODE
			,OLD_CONTACT_FLAG
			,NEW_CONTACT_FLAG
			,OLD_CONTACT_IP_ID
			,NEW_CONTACT_IP_ID
			,OLD_ACTIVE_START_DATE
			,NEW_ACTIVE_START_DATE
			,OLD_ACTIVE_END_DATE
			,NEW_ACTIVE_END_DATE
			,FULL_DUMP_FLAG
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
			,SECURITY_GROUP_ID
		       )
		       VALUES(
			 v_ins_party_history_id               -- INSTANCE_PARTY_HISTORY_ID
			,v_ins_party_id                       -- INSTANCE_PARTY_ID
			,v_txn_id                             -- TRANSACTION_ID
			,NULL                                 -- OLD_PARTY_SOURCE_TABLE
			,'HZ_PARTIES'                         -- NEW_PARTY_SOURCE_TABLE
			,NULL                                 -- OLD_PARTY_ID
			,v_party_id                           -- NEW_PARTY_ID
			,NULL                                 -- OLD_RELATIONSHIP_TYPE_CODE
			,'OWNER'                              -- NEW_RELATIONSHIP_TYPE_CODE
			,NULL                                 -- OLD_CONTACT_FLAG
			,'N'                                  -- NEW_CONTACT_FLAG
			,NULL                                 -- OLD_CONTACT_IP_ID
			,NULL                                 -- NEW_CONTACT_IP_ID
			,NULL                                 -- OLD_ACTIVE_START_DATE
			,SYSDATE                              -- NEW_ACTIVE_START_DATE
			,NULL                                 -- OLD_ACTIVE_END_DATE
			,NULL                                 -- NEW_ACTIVE_END_DATE
			,'N'                                  -- FULL_DUMP_FLAG
			,v_created_by
			,sysdate
			,v_last_updated_by
			,sysdate
			,-1
			,1
			,NULL
		       );
		 Exception
		       when others then
			     v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
				      ||' into CSI_I_PARTIES_H using the same Instance '||SUBSTR(sqlerrm,1,1000);
				raise_application_error(-20000, v_err_msg );
			     Raise;
		 End;
	      END LOOP;
	   END IF; -- Lot control check
	   Update csi_txn_errors
	   set processed_flag = 'R',
               last_update_date = sysdate
	   where transaction_error_id = txn_error_id_mig(i);
	   --
	Exception
	   when process_next then
	      null;
	End;
      END LOOP;
      commit;
      EXIT WHEN CSI_CUR%NOTFOUND;
    END LOOP;
    commit;
    CLOSE CSI_CUR;
  EXCEPTION
     When comp_error then
	null;
  END Create_or_Update_Shipping_Inst;
  --
  PROCEDURE fix_srlsoi_returned_serials
  IS

    TYPE NumTabType is    varray(1000) of number;
    TYPE VarTabType is    varray(1000) of varchar2(80);

    l_serial_number_tab   VarTabType;
    l_item_id_tab         NumTabType;
    l_organization_id_tab NumTabType;
    l_lot_code_tab        NumTabType;

    MAX_BUFFER_SIZE       number := 1000;

    l_last_mtl_txn_id         number;
    l_last_mtl_action_id      number;
    l_last_mtl_source_type_id number;
    l_last_mtl_type_id        number;
    l_last_rma_processed      varchar2(1);

    l_change_owner_flag       varchar2(1);
    l_owner_party_id          number;
    l_owner_account_id        number;
    l_internal_party_id       number;

    l_txn_rec                 csi_datastructures_pub.transaction_rec;
    l_instance_rec            csi_datastructures_pub.instance_rec;
    l_parties_tbl             csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl           csi_datastructures_pub.party_account_tbl;

    l_error_message           varchar2(2000);

    l_msg_count               number;
    l_msg_data                varchar2(2000);
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR soisrl_cur IS
      SELECT msn.serial_number,
             msn.inventory_item_id,
             msn.current_organization_id,
             msi.lot_control_code
      FROM   mtl_serial_numbers msn,
             mtl_system_items   msi
      WHERE  msn.current_status             = 1   -- predefined state (for rma'ed serials)
      AND    msi.inventory_item_id          = msn.inventory_item_id
      AND    msi.organization_id            = msn.current_organization_id
      AND    msi.serial_number_control_code = 6   -- serialized at so issue
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y';

  BEGIN

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    --
    l_txn_rec.transaction_id                := fnd_api.g_miss_num;
    l_txn_rec.transaction_type_id           := correction_txn_type_id;
    l_txn_rec.source_header_ref             := 'DATAFIX';
    l_txn_rec.source_line_ref               := 'SRLSOI RETURNED FIX';
    l_txn_rec.source_transaction_date       := sysdate;
    l_txn_rec.transaction_date              := sysdate;

    OPEN soisrl_cur;
    LOOP

      FETCH soisrl_cur BULK COLLECT
      INTO  l_serial_number_tab,
            l_item_id_tab,
            l_organization_id_tab,
            l_lot_code_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR l_ind IN 1 .. l_serial_number_tab.COUNT
      LOOP

        l_last_mtl_txn_id := null;

        FOR all_txn_rec IN  all_txn_cur(
          p_serial_number  => l_serial_number_tab(l_ind),
          p_item_id        => l_item_id_tab(l_ind))
        LOOP
          l_last_mtl_txn_id         := all_txn_rec.mtl_txn_id;
          l_last_mtl_action_id      := all_txn_rec.mtl_action_id;
          l_last_mtl_source_type_id := all_txn_rec.mtl_source_type_id;
          l_last_mtl_type_id        := all_txn_rec.mtl_type_id;
          EXIT;
        END LOOP;

        IF l_last_mtl_txn_id is not null AND l_last_mtl_type_id = 15 THEN
          BEGIN
            SELECT 'Y'
            INTO   l_last_rma_processed
            FROM   sys.dual
            WHERE  exists
              (SELECT '1' FROM csi_transactions
               WHERE  inv_material_transaction_id = l_last_mtl_txn_id);
          EXCEPTION
            WHEN no_data_found THEN
              l_last_rma_processed := 'N';
          END;

          IF l_last_rma_processed = 'Y' THEN

            BEGIN

              SELECT instance_id,
                     object_version_number,
                     location_type_code,
                     instance_usage_code
              INTO   l_instance_rec.instance_id,
                     l_instance_rec.object_version_number,
                     l_instance_rec.location_type_code,
                     l_instance_rec.instance_usage_code
              FROM   csi_item_instances
              WHERE  inventory_item_id = l_item_id_tab(l_ind)
              AND    serial_number     = l_serial_number_tab(l_ind);

              IF l_instance_rec.instance_usage_code <> 'RETURNED' OR
                 l_instance_rec.location_type_code  <> 'INVENTORY'
              THEN

                csi_process_txn_pvt.check_and_break_relation(
                  p_instance_id   => l_instance_rec.instance_id,
                  p_csi_txn_rec   => l_txn_rec,
                  x_return_status => l_return_status);

                get_rma_owner(
                  p_serial_number        => l_serial_number_tab(l_ind),
                  p_inventory_item_id    => l_item_id_tab(l_ind),
                  p_organization_id      => l_organization_id_tab(l_ind),
                  x_change_owner_flag    => l_change_owner_flag,
                  x_owner_party_id       => l_owner_party_id,
                  x_owner_account_id     => l_owner_account_id);

                FOR inv_rec IN inv_cur (l_last_mtl_txn_id)
                LOOP

                  -- build instance rec
                  SELECT object_version_number
                  INTO   l_instance_rec.object_version_number
                  FROM   csi_item_instances
                  WHERE  instance_id = l_instance_rec.instance_id;

                  l_instance_rec.location_type_code    := 'INVENTORY';
                  l_instance_rec.instance_usage_code   := 'RETURNED';
                  l_instance_rec.inv_organization_id   := inv_rec.organization_id;
                  l_instance_rec.inv_subinventory_name := inv_rec.subinv_code;
                  l_instance_rec.inv_locator_id        := inv_rec.locator_id;
                  l_instance_rec.active_end_date       := null;

                  get_lot_number(
                    p_lot_code        => l_lot_code_tab(l_ind),
                    p_mtl_txn_id      => l_last_mtl_txn_id,
                    p_serial_number   => l_serial_number_tab(l_ind),
                    x_lot_number      => l_instance_rec.lot_number);

                  l_instance_rec.inventory_revision       := inv_rec.revision;
                  l_instance_rec.vld_organization_id      := inv_rec.organization_id;
                  l_instance_rec.object_version_number    := 1.0;

                  SELECT nvl(mssi.location_id, haou.location_id)
                  INTO   l_instance_rec.location_id
                  FROM   mtl_secondary_inventories mssi,
                         hr_all_organization_units haou
                  WHERE  mssi.organization_id          = l_instance_rec.inv_organization_id
                  AND    mssi.secondary_inventory_name = l_instance_rec.inv_subinventory_name
                  AND    haou.organization_id          = mssi.organization_id;

                END LOOP;

                IF l_change_owner_flag = 'Y' THEN
                  l_instance_rec.active_end_date := sysdate;

                  -- build internal party record
                  l_parties_tbl(1).instance_party_id      := fnd_api.g_miss_num;
                  l_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
                  l_parties_tbl(1).party_id               := l_internal_party_id;
                  l_parties_tbl(1).relationship_type_code := 'OWNER';
                  l_parties_tbl(1).contact_flag           := 'N';
                  l_parties_tbl(1).object_version_number  := 1.0;

                END IF;

                log('  serial :'||l_serial_number_tab(l_ind)||'  Change Owner :'||l_change_owner_flag);

                update_instance(
                  p_txn_rec        => l_txn_rec,
                  p_instance_rec   => l_instance_rec,
                  p_parties_tbl    => l_parties_tbl,
                  p_pty_accts_tbl  => l_pty_accts_tbl,
                  x_return_status  => l_return_status,
                  x_error_message  => l_error_message);

              END IF;

            EXCEPTION
              WHEN no_data_found THEN
                null;
              WHEN too_many_rows THEN
                log('too many instances for item '||l_item_id_tab(l_ind)||
                    ' serial '||l_serial_number_tab(l_ind));
            END;
          END IF;
        END IF;

        IF mod(l_ind, 100) = 0 THEN
          commit;
        END IF;

      END LOOP;

      EXIT when soisrl_cur%NOTFOUND;

    END LOOP;

    IF soisrl_cur%ISOPEN THEN
      CLOSE soisrl_cur;
    END IF;

  EXCEPTION
    WHEN others THEN
      log('Error(O): fix_srlsoi_returned_serials '||sqlerrm);
      close soisrl_cur;
  END fix_srlsoi_returned_serials;


  PROCEDURE IB_INV_Synch_Non_srl IS
     CURSOR INV_ONH_BAL_CUR IS
     select   moq.organization_id organization_id
     ,           moq.inventory_item_id inventory_item_id
     ,           moq.revision revision
     ,           moq.subinventory_code subinventory_code
     ,           moq.locator_id locator_id
     ,           moq.lot_number lot_number
     ,           msi.primary_uom_code primary_uom_code
     ,           sum(moq.transaction_quantity) onhand_qty
     from
		 mtl_system_items msi
     ,           mtl_onhand_quantities moq
     where       msi.inventory_item_id = moq.inventory_item_id
     and         msi.organization_id = moq.organization_id
     and         msi.serial_number_control_code in (1,6) -- No Serial control and at SO Issue Items
     group by
		 moq.organization_id
     ,           moq.inventory_item_id
     ,           moq.revision
     ,           moq.subinventory_code
     ,           moq.locator_id
     ,           moq.lot_number
     ,           msi.primary_uom_code;
     --
     v_txn_id                           NUMBER;
     v_freeze_date                      DATE;
     v_txn_type_id                      NUMBER;
     l_upg_profile                      VARCHAR2(30) := fnd_Profile.value('CSI_UPGRADING_FROM_RELEASE');
     v_mast_org_id                      NUMBER;
     v_nl_trackable                     VARCHAR2(1);
     v_location_id                      NUMBER;
     v_ins_condition_id                 NUMBER;
     v_mfg_srl_flag                     VARCHAR2(1);
     v_ins_status_id                    NUMBER;
     v_instance_id                      NUMBER;
     v_end_date                         DATE;
     v_ins_history_id                   NUMBER;
     v_created_by                       NUMBER := fnd_global.user_id;
     v_last_updated_by                  NUMBER := fnd_global.user_id;
     v_ins_ou_id                        NUMBER;
     v_ins_ou_history_id                NUMBER;
     v_ins_party_id                     NUMBER;
     v_ins_party_history_id             NUMBER;
     v_party_id                         NUMBER;
     v_source_reference_id              NUMBER;
     v_err_msg                          VARCHAR2(2000);
     v_exists                           VARCHAR2(1);
     v_ins_qty                          NUMBER;
     v_ins_obj_nbr                      NUMBER;
     l_error_count                      NUMBER := 0;
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     organization_id_mig      NumTabType;
     inventory_item_id_mig    NumTabType;
     locator_id_mig           NumTabType;
     quantity_mig             NumTabType;
     --
     Type V3Type is VARRAY(10000) of VARCHAR2(3);
     uom_code_mig             V3Type;
     revision_mig             V3Type;
     --
     Type V10Type is VARRAY(10000) of VARCHAR2(10);
     subinv_mig               V10Type;
     --
     Type V80Type is VARRAY(10000) of VARCHAR2(80);
     lot_mig                  V80Type;
     --
     MAX_BUFFER_SIZE        NUMBER := 1000;
     x_return_status          VARCHAR2(1);
  --
     process_next                       EXCEPTION;
     comp_error                         EXCEPTION;
  --
  BEGIN
     csi_t_gen_utility_pvt.build_file_name(
         p_file_segment1 => 'csinonsy',
         p_file_segment2 => to_char(sysdate, 'hh24miss'));
     --
     IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
        csi_gen_utility_pvt.populate_install_param_rec;
     END IF;
     --
     v_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
     --
     -- Get the Transaction Type ID for Txn Type MIGRATED
     Begin
	select transaction_type_id
	into v_txn_type_id
	from CSI_TXN_TYPES
	where SOURCE_TRANSACTION_TYPE = 'DATA_CORRECTION';
     Exception
	when no_data_found then
	   v_err_msg := 'Txn Type DATA_CORRECTION not defined in CSI_TXN_TYPES';
	   Raise comp_error;
	when others then
	   v_err_msg := 'Unable to get the ID for Txn Type DATA_CORRECTION from CSI_TXN_TYPES';
	   Raise comp_error;
     End;
     --
     -- Get the LATEST Status ID. This will be used for all INV records.
     Begin
	select instance_status_id
	into v_ins_status_id
	from CSI_INSTANCE_STATUSES
	where name = 'Latest';
     Exception
	when no_data_found then
	   v_err_msg := 'Status ID not found in CSI for Latest Status';
	   Raise comp_error;
	when too_many_rows then
	   v_err_msg := 'Too many rows fouund in CSI for Latest Status';
	   Raise comp_error;
	when others then
	   v_err_msg := 'Error in getting the Status ID in CSI for Latest Status';
	   Raise comp_error;
     End;
     -- Get the Internal Party ID
     IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
        csi_gen_utility_pvt.populate_install_param_rec;
     END IF;
     --
     v_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
     --
     if v_party_id is null then
	v_err_msg := 'Internal Party ID not found in CSI_INSTALL_PARAMETERS';
	Raise comp_error;
     end if;
     --
     --
     OPEN INV_ONH_BAL_CUR;
     LOOP
        FETCH INV_ONH_BAL_CUR BULK COLLECT INTO
        organization_id_mig,
        inventory_item_id_mig,
        revision_mig,
        subinv_mig,
        locator_id_mig,
        lot_mig,
        uom_code_mig,
        quantity_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR i in 1 .. organization_id_mig.count LOOP
           Begin
	       -- Assign NULL to all variables getting values from sequence. This is used at the later stage
	       -- to delete the records if the Insert fails. Assigning NULL will ensure that we do not delete
	       -- wrong set of previous records if the insert fails for the next.
	       v_txn_id := -99999;
	       v_instance_id := -99999;
	       v_ins_history_id := -99999;
	       v_ins_ou_id := -99999;
	       v_ins_ou_history_id := -99999;
	       v_ins_party_id := -99999;
	       v_ins_party_history_id := -99999;
	       --
	      -- Get the Master Organization ID
	      Begin
		 select master_organization_id
		 into v_mast_org_id
		 from MTL_PARAMETERS
		 where organization_id = organization_id_mig(i);
	      Exception
		 when no_data_found then
		    Raise Process_next;
	      End;
	      -- Check for IB trackable
	      v_nl_trackable := 'N';
	      Begin
		 select comms_nl_trackable_flag
		 into v_nl_trackable
		 from MTL_SYSTEM_ITEMS
		 where inventory_item_id = inventory_item_id_mig(i)
		 and   organization_id = v_mast_org_id;
	      Exception
		 when no_data_found then
		    Raise Process_next;
	      End;
	      -- Ignore if not Trackable
	      IF NVL(v_nl_trackable,'N') <> 'Y' THEN
		 Raise Process_next;
	      END IF; -- nl_trackable check
	      --
              -- Check if there are any errors in CSI_TXN_ERRORS
              l_error_count := 0;
              Begin
                 select count(*)
                 into l_error_count
                 from CSI_TXN_ERRORS cii,
                      MTL_MATERIAL_TRANSACTIONS mmt
                 where cii.inv_material_transaction_id is not null
                 and   cii.inv_material_transaction_id = mmt.transaction_id
                 and   cii.processed_flag in ('E','R')
                 and   mmt.inventory_item_id = inventory_item_id_mig(i)
                 and   mmt.organization_id = organization_id_mig(i);
              End;
              --
              IF nvl(l_error_count,0) > 0 THEN
                 v_err_msg := 'Unable to Synch Item ID '||to_char(inventory_item_id_mig(i))||
                              '  Under Organization '||to_char(organization_id_mig(i));
                 Out(v_err_msg);
                 Raise Process_next;
              END IF;
	      -- Get the Location ID from MTL_SECONDARY_INVENTORIES
	      Begin
		 select location_id
		 into v_location_id
		 from MTL_SECONDARY_INVENTORIES
		 where organization_id = organization_id_mig(i)
		 and   secondary_inventory_name = subinv_mig(i);
	      Exception
		 when no_data_found then
		    Raise Process_next;
	      End;
	      -- Get the Location ID from HR_ORGANIZATION_UNITS
	      IF v_location_id IS NULL THEN
		 Begin
		    select location_id
		    into v_location_id
		    from HR_ORGANIZATION_UNITS
		    where organization_id = organization_id_mig(i);
		 Exception
		    when no_data_found then
		       Raise Process_next;
		 End;
	      END IF;
	      --
	      if lot_mig(i) is not NULL then
		 v_mfg_srl_flag := 'Y';
	      else
		 v_mfg_srl_flag := NULL;
	      end if;
	      --
	      v_exists := 'N';
	      v_end_date := NULL;
	      Begin
		 select quantity,instance_id,active_end_date
		 into v_ins_qty,v_instance_id,v_end_date
		 from CSI_ITEM_INSTANCES
		 where inventory_item_id = inventory_item_id_mig(i)
		 and   inv_organization_id = organization_id_mig(i)
                 and   serial_number is null
		 and   location_type_code = 'INVENTORY'
		 and   instance_usage_code = 'IN_INVENTORY'
		 and   inv_subinventory_name = subinv_mig(i)
		 and   nvl(inv_locator_id,-999) = nvl(locator_id_mig(i),-999)
		 and   nvl(inventory_revision,'$#$') = nvl(revision_mig(i),'$#$')
		 and   nvl(lot_number,'$#$') = nvl(lot_mig(i),'$#$');
		 v_exists := 'Y';
	      Exception
		 when no_data_found then
		    v_exists := 'N';
		 when too_many_rows then
		    Raise Process_next;
	      End;
	      --
	      IF v_exists = 'Y' THEN
		 IF v_ins_qty <> quantity_mig(i) OR
		    NVL(v_end_date,(sysdate+1)) <= sysdate THEN
		    UPDATE CSI_ITEM_INSTANCES
		    set quantity = quantity_mig(i)
		       ,active_end_date = decode(quantity_mig(i),0,sysdate,null)
		       ,instance_status_id = decode(quantity_mig(i),0,1,v_ins_status_id)
		       ,last_update_date = sysdate
		       ,last_updated_by = v_last_updated_by
                       ,last_vld_organization_id = organization_id_mig(i)
		    where instance_id = v_instance_id;
		    --
		    Begin
		       select CSI_TRANSACTIONS_S.nextval
		       into v_txn_id
		       from DUAL;
		    End;
		    --
		    Begin
		       INSERT INTO CSI_TRANSACTIONS(
			    TRANSACTION_ID
			   ,TRANSACTION_DATE
			   ,SOURCE_TRANSACTION_DATE
			   ,SOURCE_HEADER_REF
			   ,TRANSACTION_TYPE_ID
			   ,CREATED_BY
			   ,CREATION_DATE
			   ,LAST_UPDATED_BY
			   ,LAST_UPDATE_DATE
			   ,LAST_UPDATE_LOGIN
			   ,OBJECT_VERSION_NUMBER
			  )
			  VALUES(
			    v_txn_id                             -- TRANSACTION_ID
			   ,SYSDATE                              -- TRANSACTION_DATE
			   ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
			   ,'DATAFIX By IB-INV Synch'            -- SOURCE_HEADER_REF
			   ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
			   ,v_created_by
			   ,sysdate
			   ,v_last_updated_by
			   ,sysdate
			   ,-1
			   ,1
			  );
		    Exception
		       when others then
			  v_err_msg := 'Error while Inserting into CSI_TRANSACTIONS '||substr(sqlerrm,1,1000);
			  raise_application_error(-20000, v_err_msg );
			  Raise;
		    End;
		    -- Tie the Transaction with the instance history
		    INSERT INTO CSI_ITEM_INSTANCES_H
			(
			 INSTANCE_HISTORY_ID
			,TRANSACTION_ID
			,INSTANCE_ID
			,OLD_QUANTITY
			,NEW_QUANTITY
			,CREATION_DATE
			,LAST_UPDATE_DATE
			,CREATED_BY
			,LAST_UPDATED_BY
			,LAST_UPDATE_LOGIN
			,OBJECT_VERSION_NUMBER
		       )
		    VALUES
		       (
			 CSI_ITEM_INSTANCES_H_S.nextval
			,v_txn_id
			,v_instance_id
			,v_ins_qty
			,quantity_mig(i)
			,SYSDATE
			,SYSDATE
			,v_created_by
			,v_last_updated_by
			,-1
			,1
		       );
		 END IF;
		 Raise Process_next;
	      END IF; -- Check for instance existance
	      --
	      -- If instance is not found then create the INV instance
	      -- For each record, we insert a record into CSI_TRANSACTIONS. This Transaction ID will be used
	      -- to populate the History Record.
	      Begin
		 select CSI_TRANSACTIONS_S.nextval
		 into v_txn_id
		 from DUAL;
	      End;
	      --
	      Begin
		 INSERT INTO CSI_TRANSACTIONS(
		      TRANSACTION_ID
		     ,TRANSACTION_DATE
		     ,SOURCE_TRANSACTION_DATE
		     ,SOURCE_HEADER_REF
		     ,TRANSACTION_TYPE_ID
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		    )
		    VALUES(
		      v_txn_id                             -- TRANSACTION_ID
		     ,SYSDATE                              -- TRANSACTION_DATE
		     ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
		     ,'DATAFIX By IB-INV Synch'            -- SOURCE_HEADER_REF
		     ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
		     ,v_created_by
		     ,sysdate
		     ,v_last_updated_by
		     ,sysdate
		     ,-1
		     ,1
		    );
	      Exception
		 when others then
		    v_err_msg := 'Error while Inserting into CSI_TRANSACTIONS '||substr(sqlerrm,1,1000);
		    raise_application_error(-20000, v_err_msg );
		    Raise;
	      End;
	      --
	      Begin
		 select csi_item_instances_s.nextval
		 into v_instance_id
		 from DUAL;
	      End;
	      --
	      -- Insert into CSI_ITEM_INSTANCES
	      Begin
		    INSERT INTO CSI_ITEM_INSTANCES(
		      INSTANCE_ID
		     ,INSTANCE_NUMBER
		     ,EXTERNAL_REFERENCE
		     ,INVENTORY_ITEM_ID
		     ,INVENTORY_REVISION
		     ,INV_MASTER_ORGANIZATION_ID
		     ,MFG_SERIAL_NUMBER_FLAG
		     ,LOT_NUMBER
		     ,QUANTITY
		     ,UNIT_OF_MEASURE
		     ,ACCOUNTING_CLASS_CODE
		     ,INSTANCE_CONDITION_ID
		     ,INSTANCE_STATUS_ID
		     ,CUSTOMER_VIEW_FLAG
		     ,MERCHANT_VIEW_FLAG
		     ,SELLABLE_FLAG
		     ,SYSTEM_ID
		     ,INSTANCE_TYPE_CODE
		     ,ACTIVE_START_DATE
		     ,ACTIVE_END_DATE
		     ,LOCATION_TYPE_CODE
		     ,LOCATION_ID
		     ,INV_ORGANIZATION_ID
		     ,INV_SUBINVENTORY_NAME
		     ,INV_LOCATOR_ID
		     ,PA_PROJECT_ID
		     ,PA_PROJECT_TASK_ID
		     ,IN_TRANSIT_ORDER_LINE_ID
		     ,WIP_JOB_ID
		     ,PO_ORDER_LINE_ID
		     ,LAST_OE_ORDER_LINE_ID
		     ,LAST_OE_RMA_LINE_ID
		     ,LAST_PO_PO_LINE_ID
		     ,LAST_OE_PO_NUMBER
		     ,LAST_WIP_JOB_ID
		     ,LAST_PA_PROJECT_ID
		     ,LAST_PA_TASK_ID
		     ,LAST_OE_AGREEMENT_ID
		     ,INSTALL_DATE
		     ,MANUALLY_CREATED_FLAG
		     ,RETURN_BY_DATE
		     ,ACTUAL_RETURN_DATE
		     ,CREATION_COMPLETE_FLAG
		     ,COMPLETENESS_FLAG
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		     ,INSTANCE_USAGE_CODE
		     ,OWNER_PARTY_SOURCE_TABLE
		     ,OWNER_PARTY_ID
		     ,LAST_VLD_ORGANIZATION_ID
		    )
		    VALUES(
		      v_instance_id                        -- INSTANCE_ID
		     ,v_instance_id                        -- INSTANCE_NUMBER
		     ,NULL                                 -- EXTERNAL_REFERENCE
		     ,INVENTORY_ITEM_ID_mig(i)             -- INVENTORY_ITEM_ID
		     ,revision_mig(i)                      -- INVENTORY_REVISION
		     ,v_mast_org_id                        -- INV_MASTER_ORGANIZATION_ID
		     ,v_mfg_srl_flag                       -- MFG_SERIAL_NUMBER_FLAG
		     ,LOT_mig(i)                           -- LOT_NUMBER
		     ,quantity_mig(i)                      -- QUANTITY
		     ,uom_code_mig(i)                      -- UNIT_OF_MEASURE (PRIMARY)
		     ,'INV'                                -- ACCOUNTING_CLASS_CODE
		     ,v_ins_condition_id                   -- INSTANCE_CONDITION_ID
		     ,v_ins_status_id                      -- INSTANCE_STATUS_ID
		     ,'N'                                  -- CUSTOMER_VIEW_FLAG
		     ,'Y'                                  -- MERCHANT_VIEW_FLAG
		     ,'Y'                                  -- SELLABLE_FLAG
		     ,NULL                                 -- SYSTEM_ID
		     ,NULL                                 -- INSTANCE_TYPE_CODE
		     ,SYSDATE                              -- ACTIVE_START_DATE
		     ,NULL                                 -- ACTIVE_END_DATE
		     ,'INVENTORY'                          -- LOCATION_TYPE_CODE
		     ,v_location_id                        -- LOCATION_ID
		     ,ORGANIZATION_ID_mig(i)               -- INV_ORGANIZATION_ID
		     ,subinv_mig(i)                        -- INV_SUBINVENTORY_NAME
		     ,LOCATOR_ID_mig(i)                    -- INV_LOCATOR_ID
		     ,NULL                                 -- PA_PROJECT_ID
		     ,NULL                                 -- PA_PROJECT_TASK_ID
		     ,NULL                                 -- IN_TRANSIT_ORDER_LINE_ID
		     ,NULL                                 -- WIP_JOB_ID
		     ,NULL                                 -- PO_ORDER_LINE_ID
		     ,NULL                                 -- LAST_OE_ORDER_LINE_ID
		     ,NULL                                 -- LAST_OE_RMA_LINE_ID
		     ,NULL                                 -- LAST_PO_PO_LINE_ID
		     ,NULL                                 -- LAST_OE_PO_NUMBER
		     ,NULL                                 -- LAST_WIP_JOB_ID
		     ,NULL                                 -- LAST_PA_PROJECT_ID
		     ,NULL                                 -- LAST_PA_TASK_ID
		     ,NULL                                 -- LAST_OE_AGREEMENT_ID
		     ,NULL                                 -- INSTALL_DATE
		     ,'N'                                  -- MANUALLY_CREATED_FLAG
		     ,NULL                                 -- RETURN_BY_DATE
		     ,NULL                                 -- ACTUAL_RETURN_DATE
		     ,'Y'                                  -- CREATION_COMPLETE_FLAG
		     ,'Y'                                  -- COMPLETENESS_FLAG
		     ,v_created_by                         -- CREATED_BY
		     ,sysdate                              -- CREATION_DATE
		     ,v_last_updated_by                    -- LAST_UPDATED_BY
		     ,sysdate                              -- LAST_UPDATE_DATE
		     ,-1                                   -- LAST_UPDATE_LOGIN
		     ,1                                    -- OBJECT_VERSION_NUMBER
		     ,NULL                                 -- SECURITY_GROUP_ID
		     ,'IN_INVENTORY'                       -- INSTANCE_USAGE_CODE
		     ,'HZ_PARTIES'                         -- OWNER_PARTY_SOURCE_TABLE
		     ,v_party_id                           -- OWNER_PARTY_ID
		     ,ORGANIZATION_ID_mig(i)               -- LAST_VLD_ORGANIZATION_ID
		    );
	      Exception
		    when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
						  ||' into CSI_ITEM_INSTANCES '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
	      End;
		    -- Use the same instance record to create the history
	      Begin
		    select CSI_ITEM_INSTANCES_H_S.nextval
		    into v_ins_history_id
		    from DUAL;
	      End;
	      --
	      Begin
		    INSERT INTO CSI_ITEM_INSTANCES_H(
		      INSTANCE_HISTORY_ID
		     ,INSTANCE_ID
		     ,TRANSACTION_ID
		     ,OLD_INSTANCE_NUMBER
		     ,NEW_INSTANCE_NUMBER
		     ,OLD_EXTERNAL_REFERENCE
		     ,NEW_EXTERNAL_REFERENCE
		     ,OLD_INVENTORY_ITEM_ID
		     ,NEW_INVENTORY_ITEM_ID
		     ,OLD_INVENTORY_REVISION
		     ,NEW_INVENTORY_REVISION
		     ,OLD_INV_MASTER_ORGANIZATION_ID
		     ,NEW_INV_MASTER_ORGANIZATION_ID
		     ,OLD_MFG_SERIAL_NUMBER_FLAG
		     ,NEW_MFG_SERIAL_NUMBER_FLAG
		     ,OLD_LOT_NUMBER
		     ,NEW_LOT_NUMBER
		     ,OLD_QUANTITY
		     ,NEW_QUANTITY
		     ,OLD_UNIT_OF_MEASURE
		     ,NEW_UNIT_OF_MEASURE
		     ,OLD_ACCOUNTING_CLASS_CODE
		     ,NEW_ACCOUNTING_CLASS_CODE
		     ,OLD_INSTANCE_CONDITION_ID
		     ,NEW_INSTANCE_CONDITION_ID
		     ,OLD_INSTANCE_STATUS_ID
		     ,NEW_INSTANCE_STATUS_ID
		     ,OLD_CUSTOMER_VIEW_FLAG
		     ,NEW_CUSTOMER_VIEW_FLAG
		     ,OLD_MERCHANT_VIEW_FLAG
		     ,NEW_MERCHANT_VIEW_FLAG
		     ,OLD_SELLABLE_FLAG
		     ,NEW_SELLABLE_FLAG
		     ,OLD_SYSTEM_ID
		     ,NEW_SYSTEM_ID
		     ,OLD_INSTANCE_TYPE_CODE
		     ,NEW_INSTANCE_TYPE_CODE
		     ,OLD_ACTIVE_START_DATE
		     ,NEW_ACTIVE_START_DATE
		     ,OLD_ACTIVE_END_DATE
		     ,NEW_ACTIVE_END_DATE
		     ,OLD_LOCATION_TYPE_CODE
		     ,NEW_LOCATION_TYPE_CODE
		     ,OLD_LOCATION_ID
		     ,NEW_LOCATION_ID
		     ,OLD_INV_ORGANIZATION_ID
		     ,NEW_INV_ORGANIZATION_ID
		     ,OLD_INV_SUBINVENTORY_NAME
		     ,NEW_INV_SUBINVENTORY_NAME
		     ,OLD_INV_LOCATOR_ID
		     ,NEW_INV_LOCATOR_ID
		     ,OLD_PA_PROJECT_ID
		     ,NEW_PA_PROJECT_ID
		     ,OLD_PA_PROJECT_TASK_ID
		     ,NEW_PA_PROJECT_TASK_ID
		     ,OLD_IN_TRANSIT_ORDER_LINE_ID
		     ,NEW_IN_TRANSIT_ORDER_LINE_ID
		     ,OLD_WIP_JOB_ID
		     ,NEW_WIP_JOB_ID
		     ,OLD_PO_ORDER_LINE_ID
		     ,NEW_PO_ORDER_LINE_ID
		     ,OLD_COMPLETENESS_FLAG
		     ,NEW_COMPLETENESS_FLAG
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		     ,FULL_DUMP_FLAG
		     ,OLD_INST_USAGE_CODE
		     ,NEW_INST_USAGE_CODE
		     ,OLD_LAST_VLD_ORGANIZATION_ID
		     ,NEW_LAST_VLD_ORGANIZATION_ID
		    )
		    VALUES(
		      v_ins_history_id                                    -- INSTANCE_HISTORY_ID
		     ,v_instance_id                                       -- INSTANCE_ID
		     ,v_txn_id                                            -- TRANSACTION_ID
		     ,NULL                                                -- OLD_INSTANCE_NUMBER
		     ,v_instance_id                                       -- NEW_INSTANCE_NUMBER
		     ,NULL                                                -- OLD_EXTERNAL_REFERENCE
		     ,NULL                                                -- NEW_EXTERNAL_REFERENCE
		     ,NULL                                                -- OLD_INVENTORY_ITEM_ID
		     ,INVENTORY_ITEM_ID_mig(i)                            -- NEW_INVENTORY_ITEM_ID
		     ,NULL                                                -- OLD_INVENTORY_REVISION
		     ,revision_mig(i)                                     -- NEW_INVENTORY_REVISION
		     ,NULL                                                -- OLD_INV_MASTER_ORGANIZATION_ID
		     ,v_mast_org_id                                       -- NEW_INV_MASTER_ORGANIZATION_ID
		     ,NULL                                                -- OLD_MFG_SERIAL_NUMBER_FLAG
		     ,v_mfg_srl_flag                                      -- NEW_MFG_SERIAL_NUMBER_FLAG
		     ,NULL                                                -- OLD LOT
		     ,LOT_mig(i)                                          -- NEW LOT
		     ,NULL                                                -- OLD_QUANTITY
		     ,quantity_mig(i)                                     -- NEW_QUANTITY
		     ,NULL                                                -- OLD_UNIT_OF_MEASURE
		     ,uom_code_mig(i)                                     -- NEW_UNIT_OF_MEASURE
		     ,NULL                                                -- OLD_ACCOUNTING_CLASS_CODE
		     ,'INV'                                               -- NEW_ACCOUNTING_CLASS_CODE
		     ,NULL                                                -- OLD_INSTANCE_CONDITION_ID
		     ,v_ins_condition_id                                  -- NEW_INSTANCE_CONDITION_ID
		     ,NULL                                                -- OLD_INSTANCE_STATUS_ID
		     ,v_ins_status_id                                     -- NEW_INSTANCE_STATUS_ID
		     ,NULL                                                -- OLD_CUSTOMER_VIEW_FLAG
		     ,'N'                                                 -- NEW_CUSTOMER_VIEW_FLAG
		     ,NULL                                                -- OLD_MERCHANT_VIEW_FLAG
		     ,'Y'                                                 -- NEW_MERCHANT_VIEW_FLAG
		     ,NULL                                                -- OLD_SELLABLE_FLAG
		     ,NULL                                                -- NEW_SELLABLE_FLAG
		     ,NULL                                                -- OLD_SYSTEM_ID
		     ,NULL                                                -- NEW_SYSTEM_ID
		     ,NULL                                                -- OLD_INSTANCE_TYPE_CODE
		     ,NULL                                                -- NEW_INSTANCE_TYPE_CODE
		     ,NULL                                                -- OLD_ACTIVE_START_DATE
		     ,SYSDATE                                             -- NEW_ACTIVE_START_DATE
		     ,NULL                                                -- OLD_ACTIVE_END_DATE
		     ,NULL                                                -- NEW_ACTIVE_END_DATE
		     ,NULL                                                -- OLD_LOCATION_TYPE_CODE
		     ,'INVENTORY'                                         -- NEW_LOCATION_TYPE_CODE
		     ,NULL                                                -- OLD_LOCATION_ID
		     ,v_location_id                                       -- NEW_LOCATION_ID
		     ,NULL                                                -- OLD_INV_ORGANIZATION_ID
		     ,ORGANIZATION_ID_mig(i)                              -- NEW_INV_ORGANIZATION_ID
		     ,NULL                                                -- OLD_INV_SUBINVENTORY_NAME
		     ,subinv_mig(i)                                       -- NEW_INV_SUBINVENTORY_NAME
		     ,NULL                                                -- OLD_INV_LOCATOR_ID
		     ,LOCATOR_ID_mig(i)                                   -- NEW_INV_LOCATOR_ID
		     ,NULL                                                -- OLD_PA_PROJECT_ID
		     ,NULL                                                -- NEW_PA_PROJECT_ID
		     ,NULL                                                -- OLD_PA_PROJECT_TASK_ID
		     ,NULL                                                -- NEW_PA_PROJECT_TASK_ID
		     ,NULL                                                -- OLD_IN_TRANSIT_ORDER_LINE_ID
		     ,NULL                                                -- NEW_IN_TRANSIT_ORDER_LINE_ID
		     ,NULL                                                -- OLD_WIP_JOB_ID
		     ,NULL                                                -- NEW_WIP_JOB_ID
		     ,NULL                                                -- OLD_PO_ORDER_LINE_ID
		     ,NULL                                                -- NEW_PO_ORDER_LINE_ID
		     ,NULL                                                -- OLD_COMPLETENESS_FLAG
		     ,'Y'                                                 -- NEW_COMPLETENESS_FLAG
		     ,v_created_by                                        -- CREATED_BY
		     ,sysdate                                             -- CREATION_DATE
		     ,v_last_updated_by                                   -- LAST_UPDATED_BY
		     ,sysdate                                             -- LAST_UPDATE_DATE
		     ,-1                                                  -- LAST_UPDATE_LOGIN
		     ,1                                                   -- OBJECT_VERSION_NUMBER
		     ,NULL                                                -- SECURITY_GROUP_ID
		     ,'N'                                                 -- FULL_DUMP_FLAG
		     ,NULL                                                -- OLD_INST_USAGE_CODE
		     ,'IN_INVENTORY'                                      -- NEW_INST_USAGE_CODE
		     ,NULL                                                -- OLD_LAST_VLD_ORGANIZATION_ID
		     ,ORGANIZATION_ID_mig(i)                              -- NEW_LAST_VLD_ORGANIZATION_ID
		    );
	      Exception
		    when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
				   ||' into CSI_ITEM_INSTANCES_H Using the Same Instance '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
	      End;
	      --
	      Begin
		 select CSI_I_PARTIES_S.nextval
		 into v_ins_party_id
		 from DUAL;
	      End;
	      Begin
		    INSERT INTO CSI_I_PARTIES(
		      INSTANCE_PARTY_ID
		     ,INSTANCE_ID
		     ,PARTY_SOURCE_TABLE
		     ,PARTY_ID
		     ,RELATIONSHIP_TYPE_CODE
		     ,CONTACT_FLAG
		     ,CONTACT_IP_ID
		     ,ACTIVE_START_DATE
		     ,ACTIVE_END_DATE
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		    )
		    VALUES(
		      v_ins_party_id                   -- INSTANCE_PARTY_ID
		     ,v_instance_id                    -- INSTANCE_ID
		     ,'HZ_PARTIES'                     -- PARTY_SOURCE_TABLE
		     ,v_party_id                       -- PARTY_ID
		     ,'OWNER'                          -- RELATIONSHIP_TYPE_CODE
		     ,'N'                              -- CONTACT_FLAG
		     ,NULL                             -- CONTACT_IP_ID
		     ,SYSDATE                          -- ACTIVE_START_DATE
		     ,NULL                             -- ACTIVE_END_DATE
		     ,v_created_by                     -- CREATED_BY
		     ,sysdate                          -- CREATION_DATE
		     ,v_last_updated_by                -- LAST_UPDATED_BY
		     ,sysdate                          -- LAST_UPDATE_DATE
		     ,-1                               -- LAST_UPDATE_LOGIN
		     ,1                                -- OBJECT_VERSION_NUMBER
		     ,NULL                             -- SECURITY_GROUP_ID
		    );
		    Exception
			  when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
						  ||' into CSI_I_PARTIES '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
		    End;
		    -- Insert into CSI_I_PARTIES_H
	      Begin
		 select CSI_I_PARTIES_H_S.nextval
		 into v_ins_party_history_id
		 from DUAL;
	      End;
	      -- Insert into CSI_I_PARTIES_H
	      Begin
		    INSERT INTO CSI_I_PARTIES_H(
		      INSTANCE_PARTY_HISTORY_ID
		     ,INSTANCE_PARTY_ID
		     ,TRANSACTION_ID
		     ,OLD_PARTY_SOURCE_TABLE
		     ,NEW_PARTY_SOURCE_TABLE
		     ,OLD_PARTY_ID
		     ,NEW_PARTY_ID
		     ,OLD_RELATIONSHIP_TYPE_CODE
		     ,NEW_RELATIONSHIP_TYPE_CODE
		     ,OLD_CONTACT_FLAG
		     ,NEW_CONTACT_FLAG
		     ,OLD_CONTACT_IP_ID
		     ,NEW_CONTACT_IP_ID
		     ,OLD_ACTIVE_START_DATE
		     ,NEW_ACTIVE_START_DATE
		     ,OLD_ACTIVE_END_DATE
		     ,NEW_ACTIVE_END_DATE
		     ,FULL_DUMP_FLAG
		     ,CREATED_BY
		     ,CREATION_DATE
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		     ,SECURITY_GROUP_ID
		    )
		    VALUES(
		      v_ins_party_history_id               -- INSTANCE_PARTY_HISTORY_ID
		     ,v_ins_party_id                       -- INSTANCE_PARTY_ID
		     ,v_txn_id                             -- TRANSACTION_ID
		     ,NULL                                 -- OLD_PARTY_SOURCE_TABLE
		     ,'HZ_PARTIES'                         -- NEW_PARTY_SOURCE_TABLE
		     ,NULL                                 -- OLD_PARTY_ID
		     ,v_party_id                           -- NEW_PARTY_ID
		     ,NULL                                 -- OLD_RELATIONSHIP_TYPE_CODE
		     ,'OWNER'                              -- NEW_RELATIONSHIP_TYPE_CODE
		     ,NULL                                 -- OLD_CONTACT_FLAG
		     ,'N'                                  -- NEW_CONTACT_FLAG
		     ,NULL                                 -- OLD_CONTACT_IP_ID
		     ,NULL                                 -- NEW_CONTACT_IP_ID
		     ,NULL                                 -- OLD_ACTIVE_START_DATE
		     ,SYSDATE                              -- NEW_ACTIVE_START_DATE
		     ,NULL                                 -- OLD_ACTIVE_END_DATE
		     ,NULL                                 -- NEW_ACTIVE_END_DATE
		     ,'N'                                  -- FULL_DUMP_FLAG
		     ,v_created_by
		     ,sysdate
		     ,v_last_updated_by
		     ,sysdate
		     ,-1
		     ,1
		     ,NULL
		    );
	      Exception
		    when others then
			  v_err_msg := 'Unable to Insert Item ID '||to_char(inventory_item_id_mig(i))
				   ||' into CSI_I_PARTIES_H using the same Instance '||SUBSTR(sqlerrm,1,1000);
			     raise_application_error(-20000, v_err_msg );
			  Raise;
	      End;
	   Exception
	      when process_next then
		 null;
	      when others then
		 v_err_msg := substr(sqlerrm,1,1000);
		 raise_application_error(-20000, v_err_msg );
		 Raise;
	   End;
        END LOOP; -- for loop
        commit;
        EXIT WHEN INV_ONH_BAL_CUR%NOTFOUND;
     END LOOP; -- Open loop
     commit;
     CLOSE INV_ONH_BAL_CUR;
  EXCEPTION
     when comp_error then
	null;
  END IB_INV_Synch_Non_srl;

  --
  PROCEDURE mark_error_transactions IS
    CURSOR CSI_CUR IS
      SELECT cii.transaction_error_id,
             mmt.inventory_item_id,
             mmt.organization_id,
             mmt.transaction_action_id,
             mmt.transaction_source_type_id,
             mmt.transaction_id
      FROM   csi_txn_errors cii,
             mtl_material_transactions mmt
      WHERE  cii.processed_flag in ('E', 'R')
      AND    cii.inv_material_transaction_id is not null
      AND    mmt.transaction_id =  cii.inv_material_transaction_id;

    TYPE NumTabType is varray(10000) of number;

    txn_error_id          NumTabType;
    item_id               NumTabType;
    inv_org_id            NumTabType;
    mmt_action_id         NumTabType;
    mmt_source_type_id    NumTabType;
    mat_txn_id            NumTabType;
    --
    max_buffer_size       number := 1000;
    --
    l_user_id             number := fnd_global.user_id;
    v_srl_ctl             number;
    v_txn_type_id         number;
    v_lot_ctl             number;
    l_ctr                 number := 0;
    --

    TYPE numlist is TABLE of number INDEX BY binary_integer;
    l_upd_txn_tbl         numlist;
    --
    process_next          exception;
    comp_error            exception;

  BEGIN

    -- Get the Transaction Type ID for Txn Type MIGRATED
    BEGIN
      SELECT transaction_type_id
      INTO   v_txn_type_id
      FROM   csi_txn_types
      WHERE  source_transaction_type = 'DATA_CORRECTION';
    EXCEPTION
      WHEN no_data_found THEN
        RAISE comp_error;
      WHEN others THEN
	RAISE comp_error;
    END;
    --

    OPEN CSI_CUR;
    LOOP
      FETCH CSI_CUR BULK COLLECT INTO
        txn_error_id,
        item_id,
        inv_org_id,
        mmt_action_id,
        mmt_source_type_id,
        mat_txn_id
      LIMIT MAX_BUFFER_SIZE;
      --
      FOR i in 1 .. txn_error_id.count
      LOOP
        BEGIN

          -- skip wip errors
          IF mmt_source_type_id(i) = 5 THEN
            RAISE process_next;
          END IF;

          -- skip shipment and RMA errors
          IF (mmt_action_id(i) = 1  AND mmt_source_type_id(i) = 2)  -- Sales Order Issue
              OR
             (mmt_action_id(i) = 27 AND mmt_source_type_id(i) = 12) -- RMA Receipt
          THEN
            RAISE process_next;
          END IF;

          --
          BEGIN
            SELECT serial_number_control_code,
                   lot_control_code
            INTO   v_srl_ctl,
                   v_lot_ctl
            FROM   mtl_system_items
            WHERE  inventory_item_id = item_id(i)
            AND    organization_id   = inv_org_id(i);
          EXCEPTION
            WHEN no_data_found THEN
              RAISE process_next;
          END;

          --
          IF v_srl_ctl not in (1, 6) THEN
            RAISE process_next;
          END IF;
          --

          IF v_srl_ctl = 6 THEN

            -- skip iso shipments for srlsoi items
            IF (mmt_action_id(i) = 21 AND mmt_source_type_id(i) = 8)  -- Int Order Intr Ship
                OR
               (mmt_action_id(i) = 12 AND mmt_source_type_id(i) = 7)  -- Int Req Intr Rcpt
                OR
               (mmt_action_id(i) = 3  AND mmt_source_type_id(i) = 8)  -- Int Order Direct Ship
                OR
               (mmt_action_id(i) = 1  AND mmt_source_type_id(i) = 8)  -- Internal order issue
            THEN
              RAISE process_next;
            END IF;
          END IF;

          l_ctr := l_ctr + 1;
          l_upd_txn_tbl(l_ctr) := txn_error_id(i);

        EXCEPTION
          WHEN process_next THEN
            null;
        END;
      END LOOP;

      EXIT WHEN csi_cur%notfound;

    END LOOP;

    CLOSE csi_cur;
    --
    IF l_upd_txn_tbl.count > 0 THEN
      FORALL i in l_upd_txn_tbl.FIRST .. l_upd_txn_tbl.LAST
        UPDATE csi_txn_errors
        SET    processed_flag = 'D',
               error_text = 'Data fix done - mark_error_transactions',
               last_update_date = sysdate
        WHERE  transaction_error_id = l_upd_txn_tbl(i);
        commit;
    END IF;
  EXCEPTION
    WHEN comp_error THEN
      null;
  END mark_error_transactions;

  --
  PROCEDURE Reverse_IB_INV_Synch IS
     CURSOR CSI_CUR IS
     select cii.instance_id,cii.inventory_item_id,cii.inv_organization_id,
     cii.inv_subinventory_name,cii.inv_locator_id,
     cii.inventory_revision,cii.lot_number,cii.quantity
     from CSI_ITEM_INSTANCES cii,
          MTL_SYSTEM_ITEMS msi
     where cii.location_type_code = 'INVENTORY'
     and   cii.instance_usage_code = 'IN_INVENTORY'
     and   cii.serial_number is NULL
     and   msi.inventory_item_id = cii.inventory_item_id
     and   msi.organization_id = cii.inv_master_organization_id
     and   nvl(msi.comms_nl_trackable_flag,'N') = 'Y';
     --
     v_qty                        NUMBER;
     l_txn_id                     NUMBER;
     l_user_id                    NUMBER := fnd_global.user_id;
     l_error_count                NUMBER;
     l_ins_flag                   VARCHAR2(1) := 'N';
     v_txn_type_id                NUMBER;
     v_err_msg                    VARCHAR2(2000);
     --
     Type NumTabType is VARRAY(10000) of NUMBER;
     instance_id_mig          NumTabType;
     organization_id_mig      NumTabType;
     inventory_item_id_mig    NumTabType;
     locator_id_mig           NumTabType;
     quantity_mig             NumTabType;
     --
     Type V3Type is VARRAY(10000) of VARCHAR2(3);
     revision_mig             V3Type;
     --
     Type V10Type is VARRAY(10000) of VARCHAR2(10);
     subinv_mig               V10Type;
     --
     Type V80Type is VARRAY(10000) of VARCHAR2(80);
     lot_mig                  V80Type;
     --
     MAX_BUFFER_SIZE        NUMBER := 1000;
     --
     process_next           EXCEPTION;
     comp_error             EXCEPTION;
  BEGIN
     csi_t_gen_utility_pvt.build_file_name(
         p_file_segment1 => 'csinonsy',
         p_file_segment2 => to_char(sysdate, 'hh24miss'));
     --
     -- Get the Transaction Type ID for Txn Type MIGRATED
     Begin
	select transaction_type_id
	into v_txn_type_id
	from CSI_TXN_TYPES
	where SOURCE_TRANSACTION_TYPE = 'DATA_CORRECTION';
     Exception
	when no_data_found then
	   Raise comp_error;
	when others then
	   Raise comp_error;
     End;
     select CSI_TRANSACTIONS_S.nextval
     into l_txn_id from dual;
     --
     OPEN CSI_CUR;
     LOOP
        FETCH CSI_CUR BULK COLLECT INTO
        instance_id_mig,
        inventory_item_id_mig,
        organization_id_mig,
        subinv_mig,
        locator_id_mig,
        revision_mig,
        lot_mig,
        quantity_mig
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR i in 1 .. instance_id_mig.count LOOP
	   Begin
              l_error_count := 0;
              Begin
                 select count(*)
                 into l_error_count
                 from CSI_TXN_ERRORS cii,
                      MTL_MATERIAL_TRANSACTIONS mmt
                 where cii.inv_material_transaction_id is not null
                 and   cii.inv_material_transaction_id = mmt.transaction_id
                 and   cii.processed_flag in ('E','R')
                 and   mmt.inventory_item_id = inventory_item_id_mig(i)
                 and   mmt.organization_id = organization_id_mig(i);
              End;
              --
              IF nvl(l_error_count,0) > 0 THEN
                 v_err_msg := 'Unable to Reverse Synch Item ID '||to_char(inventory_item_id_mig(i))||
                              '  Under Organization '||to_char(organization_id_mig(i));
                 Out(v_err_msg);
                 Raise Process_next;
              END IF;
              --
	      v_qty := 0;
	      Begin
	         select NVL(sum(transaction_quantity),0)
	         into v_qty
	         from MTL_ONHAND_QUANTITIES
	         where inventory_item_id = inventory_item_id_mig(i)
	         and   organization_id = organization_id_mig(i)
	         and   subinventory_code = subinv_mig(i)
	         and   nvl(locator_id,-999) = nvl(locator_id_mig(i),-999)
	         and   nvl(revision,'$#$') = nvl(revision_mig(i),'$#$')
	         and   nvl(lot_number,'$#$') = nvl(lot_mig(i),'$#$');
	      End;
	      --
	      IF v_qty <> quantity_mig(i) THEN
                 l_ins_flag := 'Y';
	         UPDATE CSI_ITEM_INSTANCES
	         set quantity = v_qty,
	   	     active_end_date = decode(v_qty,0,sysdate,active_end_date),
		     instance_status_id = decode(v_qty,0,1,instance_status_id),
                     last_update_date = sysdate,
                     last_updated_by = l_user_id
	         where instance_id = instance_id_mig(i);
                 --
                 -- Tie this instance with the transaction
		 INSERT INTO CSI_ITEM_INSTANCES_H
		     (
		      INSTANCE_HISTORY_ID
		     ,TRANSACTION_ID
		     ,INSTANCE_ID
		     ,CREATION_DATE
		     ,LAST_UPDATE_DATE
		     ,CREATED_BY
		     ,LAST_UPDATED_BY
		     ,LAST_UPDATE_LOGIN
		     ,OBJECT_VERSION_NUMBER
		    )
		 VALUES
		    (
                      CSI_ITEM_INSTANCES_H_S.nextval
		     ,l_txn_id
		     ,instance_id_mig(i)
		     ,SYSDATE
		     ,SYSDATE
		     ,l_user_id
		     ,l_user_id
		     ,-1
		     ,1
		    );
	      END IF;
           Exception
              when Process_next then
                 null;
	   End;
        END LOOP; -- for loop
        commit;
        EXIT WHEN CSI_CUR%NOTFOUND;
     END LOOP;
     CLOSE CSI_CUR;
     --
     IF l_ins_flag = 'Y' THEN
        INSERT INTO CSI_TRANSACTIONS(
	  TRANSACTION_ID
	 ,TRANSACTION_DATE
	 ,SOURCE_TRANSACTION_DATE
	 ,SOURCE_HEADER_REF
	 ,TRANSACTION_TYPE_ID
	 ,CREATED_BY
	 ,CREATION_DATE
	 ,LAST_UPDATED_BY
	 ,LAST_UPDATE_DATE
	 ,LAST_UPDATE_LOGIN
	 ,OBJECT_VERSION_NUMBER
	)
	VALUES(
	  l_txn_id                             -- TRANSACTION_ID
	 ,SYSDATE                              -- TRANSACTION_DATE
	 ,SYSDATE                              -- SOURCE_TRANSACTION_DATE
	 ,'Reverse Synch'                      -- SOURCE_HEADER_REF
	 ,v_txn_type_id                        -- TRANSACTION_TYPE_ID
	 ,l_user_id
	 ,sysdate
	 ,l_user_id
	 ,sysdate
	 ,-1
	 ,1
	);
     END IF;
     --
     commit;
  EXCEPTION
     when comp_error then
        null;
  END Reverse_IB_INV_Synch;
  --
  PROCEDURE get_nl_trackable_report
  IS
    CURSOR all_item_cur IS
      SELECT m_msi.concatenated_segments,
             m_msi.comms_nl_trackable_flag,
             c_msi.comms_nl_trackable_flag,
             m_mp.organization_code,
             c_mp.organization_code
      FROM   mtl_system_items_b   c_msi, -- Child Items
             mtl_parameters       c_mp,  -- Child Parameters
             mtl_system_items_kfv m_msi, -- Master Items
             mtl_parameters       m_mp   -- Master Parameters
      WHERE  m_mp.organization_id        = m_mp.master_organization_id
      AND    m_msi.organization_id       = m_mp.organization_id
      AND    m_msi.organization_id       = c_mp.master_organization_id
      AND    c_mp.master_organization_id = m_mp.organization_id
      AND    c_msi.organization_id       = c_mp.organization_id
      AND    m_msi.organization_id      <> c_mp.organization_id
      AND    c_msi.organization_id      <> m_msi.organization_id
      AND    c_msi.inventory_item_id     = m_msi.inventory_item_id
      AND    nvl(m_msi.comms_nl_trackable_flag,'N') <> nvl(c_msi.comms_nl_trackable_flag,'N')
      AND  EXISTS (SELECT 1 from  HR_ALL_ORGANIZATION_UNITS haou
      WHERE date_to IS NULL
      AND haou.organization_id =m_msi.organization_id)
      AND  EXISTS (SELECT 1 from  HR_ALL_ORGANIZATION_UNITS haou
      WHERE date_to IS NULL
      AND haou.organization_id =c_msi.organization_id)
      ORDER BY m_msi.inventory_item_id;
    --
    l_printheader  boolean := TRUE;
    l_printfooter  boolean := FALSE;

    v_msg          varchar2(4000);
    --
    Type V1TabType is VARRAY(10000) of VARCHAR2(1);
    l_master_flag_mig        V1TabType;
    l_child_flag_mig         V1TabType;
    Type V3TabType is VARRAY(10000) of VARCHAR2(3);
    l_master_org_mig         V3TabType;
    l_child_org_mig          V3TabType;
    Type V240TabType is VARRAY(10000) of MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
    l_item_segment_mig       V240TabType;
    --
    MAX_BUFFER_SIZE          NUMBER := 1000;
  BEGIN
    OPEN ALL_ITEM_CUR;
    LOOP
      FETCH ALL_ITEM_CUR BULK COLLECT INTO
        l_item_segment_mig,
        l_master_flag_mig,
        l_child_flag_mig,
        l_master_org_mig,
        l_child_org_mig
      LIMIT MAX_BUFFER_SIZE;
      --
      FOR i in 1..l_item_segment_mig.count LOOP
        IF l_printheader THEN
          l_printheader := FALSE;
	  l_printfooter := TRUE;
	  out('-----------------------------------------------------------------------');
	  out('Inconsistent IB trackable setting within master and child organizations');
	  out('-----------------------------------------------------------------------');
        END IF;
        l_global_warning_flag := 'Y';
        v_msg := 'Item : '||l_item_segment_mig(i)||
 	         '  is set as  '||l_master_flag_mig(i)||
	         '  in Master Org '||l_master_org_mig(i)||
	         '  and  '|| l_child_flag_mig(i)||
	         '  in Child Org '||l_child_org_mig(i);
        out(v_msg);
      END LOOP;
      EXIT WHEN ALL_ITEM_CUR%NOTFOUND;
    END LOOP;
     --
    IF ALL_ITEM_CUR%ISOPEN THEN
      CLOSE ALL_ITEM_CUR;
    END IF;
    --
    IF l_printfooter THEN
       out('***************************END OF REPORT**********************************');
    END IF;
  END get_nl_trackable_report;
  --
  PROCEDURE MERGE_NON_SRL_INV_INSTANCE IS
   CURSOR c1 IS
   SELECT /*+ parallel(a) parallel(c) */
         a.instance_id,
         a.inventory_item_id,
         a.location_type_code,
         a.location_id,
         a.inv_organization_id,
         a.inv_subinventory_name,
         a.instance_usage_code,
         a.quantity,
         a.active_end_date,
         a.inventory_revision,
         a.inv_locator_id,
         a.lot_number,
         a.owner_party_id
   FROM   csi_item_instances a,
         mtl_system_items_b c
   WHERE a.ROWID > (SELECT MIN(b.ROWID)
                   FROM csi_item_instances b
                   WHERE b.inventory_item_id = a.inventory_item_id
                   AND   b.location_type_code = a.location_type_code
                 --  AND   b.location_id = a.location_id
                   AND   b.serial_number is null
                   AND   b.inv_organization_id = a.inv_organization_id
                   AND   b.inv_subinventory_name = a.inv_subinventory_name
                   AND   b.instance_usage_code = a.instance_usage_code
                   AND   nvl(b.inventory_revision,'$#$') = nvl(a.inventory_revision,'$#$')
                   AND   nvl(b.inv_locator_id,-999) = nvl(a.inv_locator_id,-999)
                   AND   nvl(b.lot_number,'$#$')= nvl(a.lot_number,'$#$')
                   AND   b.owner_party_id = a.owner_party_id
                   AND   b.location_type_code = 'INVENTORY'
                   AND   b.instance_usage_code = 'IN_INVENTORY')
                 --  AND   b.active_end_date IS NULL)
 -- AND a.active_end_date IS NULL
  AND a.inventory_item_id = c.inventory_item_id
  AND a.inv_organization_id = c.organization_id
  AND a.serial_number is null
  AND c.serial_number_control_code IN (1,6);

  CURSOR c2  IS
  SELECT a.instance_id,
         a.inventory_item_id,
         a.location_type_code,
         a.location_id,
         a.inv_organization_id,
         a.inv_subinventory_name,
         a.instance_usage_code,
         a.quantity,
         a.active_end_date,
         a.inventory_revision,
         a.inv_locator_id,
         a.lot_number,
         a.owner_party_id
  FROM   csi_item_instances a,
         mtl_system_items_b c
  WHERE  a.ROWID = (SELECT MIN(b.ROWID)
                   FROM csi_item_instances b
                   WHERE b.inventory_item_id = a.inventory_item_id
                   AND   b.location_type_code = a.location_type_code
                 --  AND   b.location_id = a.location_id
                   AND   b.serial_number is null
                   AND   b.inv_organization_id = a.inv_organization_id
                   AND   b.inv_subinventory_name = a.inv_subinventory_name
                   AND   b.instance_usage_code = a.instance_usage_code
                   AND   nvl(b.inventory_revision,'$#$') = nvl(a.inventory_revision,'$#$')
                   AND   nvl(b.inv_locator_id,-999) = nvl(a.inv_locator_id,-999)
                   AND   nvl(b.lot_number,'$#$')= nvl(a.lot_number,'$#$')
                   AND   b.owner_party_id = a.owner_party_id
                   AND   b.location_type_code = 'INVENTORY'
                   AND   b.instance_usage_code = 'IN_INVENTORY')
                 --  AND   b.active_end_date IS NULL)
  AND a.inventory_item_id = c.inventory_item_id
  AND a.inv_organization_id = c.organization_id
  AND a.serial_number is null
  AND c.serial_number_control_code IN (1,6);

  p_instance_tbl     csi_datastructures_pub.instance_tbl;
  l_count            NUMBER;
  m                  NUMBER;
  temp_quantity      NUMBER;
  l_status_id        NUMBER;
  l_active_end_date  DATE;
 BEGIN
    m := 1;
    FOR i IN c1 LOOP
         p_instance_tbl(m).inventory_item_id :=i.inventory_item_id;
         p_instance_tbl(m).location_type_code :=i.location_type_code;
         p_instance_tbl(m).inv_organization_id :=i.inv_organization_id;
         p_instance_tbl(m).inv_subinventory_name :=i.inv_subinventory_name;
         p_instance_tbl(m).instance_usage_code :=i.instance_usage_code;
         p_instance_tbl(m).location_id :=i.location_id;
         p_instance_tbl(m).quantity:=i.quantity;
         p_instance_tbl(m).inventory_revision:=i.inventory_revision;
         p_instance_tbl(m).inv_locator_id:=i.inv_locator_id;
         p_instance_tbl(m).lot_number:=i.lot_number;
         p_instance_tbl(m).attribute1:=i.owner_party_id;

         DELETE FROM csi_item_instances_h
         WHERE  instance_id=i.instance_id;
         --
         DELETE FROM csi_i_parties_h
         WHERE instance_party_id in (select instance_party_id from csi_i_parties
                                     WHERE  instance_id=i.instance_id);
         --
         DELETE FROM csi_i_parties
         WHERE  instance_id=i.instance_id;
         --
         DELETE FROM csi_item_instances
         WHERE  instance_id=i.instance_id;

         m := m+1;

     END LOOP;
     l_count:=p_instance_tbl.COUNT;
     IF l_count > 0 THEN
        FOR j IN c2 LOOP
          temp_quantity:=0;
           FOR k in 1..l_count
           LOOP
              IF   p_instance_tbl(k).inventory_item_id =j.inventory_item_id
               AND p_instance_tbl(k).location_type_code =j.location_type_code
               AND p_instance_tbl(k).inv_organization_id =j.inv_organization_id
               AND p_instance_tbl(k).inv_subinventory_name =j.inv_subinventory_name
               AND p_instance_tbl(k).instance_usage_code =j.instance_usage_code
             --  AND p_instance_tbl(k).location_id =j.location_id
               AND nvl(p_instance_tbl(k).inventory_revision,'$#$')=nvl(j.inventory_revision,'$#$')
               AND nvl(p_instance_tbl(k).inv_locator_id,-999)=nvl(j.inv_locator_id,-999)
               AND nvl(p_instance_tbl(k).lot_number,'$#$')=nvl(j.lot_number,'$#$')
               AND p_instance_tbl(k).attribute1 = j.owner_party_id
             --  AND j.active_end_date IS NULL
              THEN
                temp_quantity:=temp_quantity+p_instance_tbl(k).quantity;
              END IF;
           END LOOP;

           IF j.quantity + temp_quantity = 0 THEN
              l_status_id := 1;
              l_active_end_date := sysdate;
           ELSE
              l_status_id := 510;
              l_active_end_date := null;
           END IF;
           --
           UPDATE csi_item_instances
           SET quantity=j.quantity+temp_quantity,
               instance_status_id = l_status_id,
               active_end_date = l_active_end_date
           WHERE instance_id=j.instance_id;

        END LOOP;
     END IF;
     commit;
  END MERGE_NON_SRL_INV_INSTANCE;

  PROCEDURE get_non_srl_rma_report(
    p_show_instances      IN varchar2)
  IS

    l_ownership_override  varchar2(1);

    CURSOR CSI_ERROR IS
      SELECT cii.transaction_error_id,
             cii.inv_material_transaction_id,
             cii.error_text,
             mmt.inventory_item_id,
             mmt.organization_id,
             mmt.transaction_quantity,
             mmt.trx_source_line_id,
             mmt.revision
      FROM   csi_txn_errors cii,
             mtl_material_transactions mmt
      WHERE  cii.processed_flag = 'E'
      AND    cii.inv_material_transaction_id is not null
      AND    mmt.transaction_id = cii.inv_material_transaction_id
      AND    mmt.transaction_type_id = 15; -- RMA

    --
    CURSOR tld_cur(p_rma_line_id in number) is
      SELECT ctld.sub_type_id, ctld.instance_id
      FROM   csi_t_transaction_lines ctl,
             csi_t_txn_line_details ctld
      WHERE  ctl.source_transaction_table = 'OE_ORDER_LINES_ALL'
      AND    ctl.source_transaction_id    = p_rma_line_id
      AND    ctld.transaction_line_id     = ctl.transaction_line_id
      AND    ctld.source_transaction_flag = 'Y';

    --
    CURSOR lot_cur(p_txn_id in number) IS
      SELECT lot_number,transaction_quantity
      FROM   mtl_transaction_lot_numbers
      WHERE  transaction_id = p_txn_id;

    --
    CURSOR csi_cur(
      p_item_id     in number,
      p_chg_owner   in varchar2,
      p_customer_id in number,
      p_revision    in varchar2,
      p_lot_number  in varchar2)
    IS
      SELECT instance_id,
		   instance_number,
             last_vld_organization_id,
             quantity,
             lot_number,
             inventory_revision ,
             owner_party_account_id account_id,
             owner_party_id         party_id
      FROM   csi_item_instances,
             hz_parties
      WHERE  inventory_item_id      = p_item_id
      AND    owner_party_account_id = decode(p_chg_owner,'Y',owner_party_account_id,p_customer_id)
      AND    instance_usage_code    = 'OUT_OF_ENTERPRISE'
      AND    nvl(lot_number,'$#$')  = nvl(p_lot_number,'$#$')
      AND    nvl(inventory_revision,'$#$') = nvl(p_revision,'$#$')
      AND    party_id = owner_party_id
      ORDER BY party_name asc, quantity desc;
    --
    l_ib_flag             varchar2(1) := 'N';
    l_customer_id         number;
    l_message             varchar2(32767);
    l_srl_ctl             number;
    l_lot_ctl             number;
    l_rma_num             varchar2(50) ;
    l_rma_line_num        varchar2(50) ;
    l_loop_count          number := 0;
    l_inst_ref            number;
    l_org_code            varchar2(30);

    --
    l_item                varchar2(240);
    l_customer_name       varchar2(240);
    l_instances_found     boolean := FALSE;
    Process_next          exception;

    FUNCTION get_customer(
      p_account_id IN number,
      p_party_id   IN number)
    RETURN varchar2 IS
      l_customer_name varchar2(240);
    BEGIN

      IF p_account_id is not null THEN
        SELECT hp.party_name
        INTO   l_customer_name
        FROM   hz_cust_accounts hca,
               hz_parties       hp
        WHERE  hca.cust_account_id = p_account_id
        AND    hp.party_id         = hca.party_id;
      ELSE
        IF p_party_id is not null THEN
          SELECT party_name
          INTO   l_customer_name
          FROM   hz_parties
          WHERE  party_id = p_party_id;
        END IF;
      END IF;

      return l_customer_name;

    EXCEPTION
      WHEN others THEN
        return l_customer_name;
    END get_customer;

    FUNCTION fill(
      p_column in varchar2,
      p_width  in number,
      p_side   in varchar2 default 'R')
    RETURN varchar2 is
      l_column varchar2(2000);
      l_width  number;
    BEGIN
      l_width  := p_width - 1;
      l_column := nvl(p_column, ' ');
      IF p_side = 'L' THEN
        return(lpad(l_column, l_width, ' ')||',');
      ELSIF p_side = 'R' THEN
        return(rpad(l_column, l_width, ' ')||',');
      END IF;
    END fill;

  BEGIN

    out('  ');
    out('********************************************************************************');
    out('               Non serialized RMAs without installation details                 ');
    out('********************************************************************************');

    l_message := fill('MTLTxnID', 10)||
                 fill('RMA#', 10)||
                 fill('Line', 6)||
                 fill('Instance', 10)||
                 fill('Owner', 35)||
                 fill('Quantity', 9);

    out(l_message);

    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_ownership_override := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;
    --
    FOR csi_rec IN csi_error
    LOOP

      BEGIN

        SELECT concatenated_segments,
               serial_number_control_code,
               lot_control_code
        INTO   l_item, l_srl_ctl,l_lot_ctl
        FROM   mtl_system_items_kfv mtl
        WHERE  mtl.inventory_item_id = csi_rec.inventory_item_id
        AND    mtl.organization_id = csi_rec.organization_id;

        SELECT comms_nl_trackable_flag,
               organization_code
        INTO   l_ib_flag,
               l_org_code
        FROM   mtl_system_items_b msi ,
               mtl_parameters     mp
        WHERE  msi.inventory_item_id = csi_rec.inventory_item_id
        AND    msi.organization_id   = mp.master_organization_id
        AND    mp.organization_id    = csi_rec.organization_id;
        --
        IF nvl(l_ib_flag, 'N') <> 'Y' THEN
          RAISE Process_next;
        END IF;
        --

        SELECT nvl(line.sold_to_org_id, hdr.sold_to_org_id),
               hdr.order_number,
               line.line_number||'.'||line.shipment_number
        INTO   l_customer_id,
               l_rma_num,
               l_rma_line_num
        FROM   oe_order_lines_all   line,
               oe_order_headers_all hdr
        WHERE  line.line_id = csi_rec.trx_source_line_id
        AND    hdr.header_id = line.header_id;

        l_customer_name := get_customer(l_customer_id, null);

        --
        IF l_srl_ctl = 1 THEN
          l_loop_count := 0;
          l_inst_ref := 0;
          FOR tld_rec in tld_cur(csi_rec.trx_source_line_id)
          LOOP
            IF nvl(tld_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_inst_ref := 1;
              --
            END IF;
            l_loop_count := l_loop_count + 1;
          END LOOP;

          IF ((l_loop_count = 0) OR (l_inst_ref = 1)) THEN

            l_customer_name := null;

            --
            IF l_lot_ctl = 1 THEN

              l_instances_found := FALSE;

              IF p_show_instances = 'Y' THEN
                FOR ins in csi_cur (csi_rec.inventory_item_id,l_ownership_override,
                  l_customer_id,csi_rec.revision,null)
                LOOP

                  l_instances_found := TRUE;

                  IF csi_cur%rowcount = 1 THEN
                    out('---------,---------,-----,---------,'||
                        '----------------------------------,--------,');
                  END IF;

                  l_customer_name := get_customer(ins.account_id, ins.party_id);

                  l_message := fill(csi_rec.inv_material_transaction_id, 10)||
                               fill(l_rma_num, 10)||
					      fill(l_rma_line_num, 6)||
                               fill(ins.instance_number, 10)||
                               fill(l_customer_name, 35)||
                               fill(ins.quantity, 9);
                  out(l_message);
                END LOOP;
              END IF;

              IF NOT(l_instances_found) THEN
                out('---------,---------,-----,---------,'||
                    '----------------------------------,--------,');
                l_message := fill(csi_rec.inv_material_transaction_id, 10)||
                             fill(l_rma_num, 10)||
                             fill(l_rma_line_num, 6);
                out(l_message);
              END IF;

            ELSE

              l_instances_found := FALSE;

              IF p_show_instances = 'Y' THEN

                FOR lot IN lot_cur(csi_rec.inv_material_transaction_id)
                LOOP

                  FOR ins in CSI_CUR (csi_rec.inventory_item_id, l_ownership_override,l_customer_id
                                     ,csi_rec.revision,lot.lot_number)
                  LOOP

                    l_instances_found := TRUE;

                    IF csi_cur%rowcount = 1 THEN
                      out('---------,---------,-----,---------,'||
                          '----------------------------------,--------,');
                    END IF;

                    l_customer_name := get_customer(ins.account_id, ins.party_id);

                    l_message := fill(csi_rec.inv_material_transaction_id, 10)||
                                 fill(l_rma_num, 10)||
                                 fill(l_rma_line_num, 6)||
                                 fill(ins.instance_number, 10)||
                                 fill(l_customer_name, 35)||
                                 fill(ins.quantity, 9);
                    out(l_message);
                  END LOOP;
                END LOOP;
              END IF;

              IF NOT(l_instances_found) THEN
                out('---------,---------,-----,---------,'||
                    '----------------------------------,--------,');
                l_message := fill(csi_rec.inv_material_transaction_id, 10)||
                             fill(l_rma_num, 10)||
                             fill(l_rma_line_num, 6);
                out(l_message);
              END IF;

            END IF;
          END IF;
        END IF;
      EXCEPTION
        WHEN Process_next then
          null;
      END;

    END LOOP;
    commit;
  EXCEPTION
    WHEN others THEN
     out('  Error in report:'||sqlerrm);
  END get_non_srl_rma_report;

  PROCEDURE check_org_uniqueness IS
    CURSOR uniq_cur IS
      SELECT a.instance_id,
             a.serial_number,
             a.inventory_item_id inst_item_id,
             d.inventory_item_id serial_item_id,
             d.current_status,
             d.current_organization_id,
             a.manually_created_flag,
             a.instance_usage_code,
             a.location_type_code,
             a.active_end_date
      FROM   csi_item_instances a,
             mtl_serial_numbers d,
             mtl_parameters    e
      WHERE  a.serial_number is not null
      AND    d.serial_number      = a.serial_number
      AND    d.inventory_item_id  <> a.inventory_item_id
      AND    e.organization_id    = nvl(a.last_vld_organization_id, a.inv_master_organization_id)
      AND    e.serial_number_type = 3;
  BEGIN
   csi_t_gen_utility_pvt.build_file_name(
       p_file_segment1 => 'csisrlun',
       p_file_segment2 => to_char(sysdate, 'hh24miss'));
   --
    FOR uniq_rec IN uniq_cur
    LOOP

      l_global_sync_flag := 'Y';

      IF uniq_cur%rowcount = 1 THEN
        out('Serial Uniqueness Report - Across Organization');
        out('------------------------------------------------------------------');
      END IF;

      out(to_char(uniq_rec.instance_id)||
                       '  '||uniq_rec.serial_number||
                       '  '||to_char(uniq_rec.inst_item_id)||
                       '  '||to_char(uniq_rec.serial_item_id)||
                       '  '||to_char(uniq_rec.current_status)||
                       '  '||to_char(uniq_rec.current_organization_id)||
                       '  '||uniq_rec.manually_created_flag||
                       '  '||uniq_rec.instance_usage_code||
                       '  '||uniq_rec.location_type_code);

    END LOOP;
  END check_org_uniqueness;


PROCEDURE CREATE_NSRL_RMA_TLD IS

  l_inventory_item_id    number;
  l_organization_id      number;
  l_serial_code          number;
  l_owner_pty_id         number;
  l_owner_acct_id        number;
  l_order_qty            number;
  l_order_uom            varchar2(9);
  l_txn_line_detail_id   number;
  l_transaction_line_id  number;
  l_instance_count       number;
  l_tld_count            number;
  l_sub_type_id          number;
  l_change_owner         varchar2(1);
  l_internal_party_id    number;

  l_instance_id          number;
  l_instance_qty         number;
  l_rma_line_id          number;
  l_primary_qty          number;
  l_processed_flag       varchar2(1) := 'N';

  l_line_rec       csi_t_datastructures_grp.txn_line_rec;
  l_line_dtl_tbl   csi_t_datastructures_grp.txn_line_detail_tbl;
  l_pty_dtl_tbl    csi_t_datastructures_grp.txn_party_detail_tbl;
  l_pty_acct_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
  l_ii_rltns_tbl   csi_t_datastructures_grp.txn_ii_rltns_tbl;
  l_oa_tbl         csi_t_datastructures_grp.txn_org_assgn_tbl;
  l_ea_tbl         csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
  l_sys_tbl        csi_t_datastructures_grp.txn_systems_tbl;

  l_return_status  varchar2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

  l_mtl_txn_date   date;
  l_mtl_cre_date   date;

  skip_error       exception;
  i                number;
  j                number;

   --added for bug 5248037--
  MAX_BUFFER_SIZE          number := 1000;
  l_rec_change             BOOLEAN;
  l_rma_txn_tbl           csi_diagnostics_pkg.rma_txn_tbl;
  l_instance_tbl          csi_diagnostics_pkg.instance_tbl;

  --Modified rma_cur and inst_cur for 5248037--
  CURSOR rma_cur
  IS
  SELECT cte.transaction_error_id transaction_error_id,
         cte.inv_material_transaction_id inv_material_transaction_id,
         mmt.inventory_item_id item_id,
         mmt.organization_id organization_id,
         mmt.trx_source_line_id mtl_src_line_id,
         mmt.creation_date mtl_creation_date,
         abs(mmt.primary_quantity) mtl_txn_qty,
         msi.serial_number_control_code serial_code,
         oel.sold_to_org_id owner_acct,
         oel.ordered_quantity ordered_qty,
         oel.order_quantity_uom ordered_uom,
         hca.party_id party_id
  FROM   csi_txn_errors cte,mtl_material_transactions mmt,mtl_system_items msi,oe_order_lines_all oel,hz_cust_accounts hca
  WHERE  cte.processed_flag in ('E', 'R')
  AND    cte.transaction_type_id = 53
  AND    cte.inv_material_transaction_id = mmt.transaction_id
  AND    msi.inventory_item_id = mmt.inventory_item_id
  AND    msi.organization_id = mmt.organization_id
  AND    msi.serial_number_control_code = 1
  AND    oel.line_id = mmt.trx_source_line_id
  AND    hca.cust_account_id = oel.sold_to_org_id
  ORDER BY item_id, party_id, owner_acct,mtl_txn_qty;

  CURSOR inst_cur (p_item_id NUMBER,
                   p_owner_party_id NUMBER,
                   p_owner_acct_id NUMBER)
  IS
  SELECT cii.instance_id instance_id,
         cii.quantity quantity,
         cii.active_start_date active_start_date
  FROM   csi_item_instances cii
  WHERE  cii.inventory_item_id      = p_item_id
  AND    cii.accounting_class_code  = 'CUST_PROD'
  AND    cii.instance_usage_code    = 'OUT_OF_ENTERPRISE'
  AND    cii.owner_party_id         = p_owner_party_id
  AND    cii.owner_party_account_id = p_owner_acct_id
  AND    sysdate between nvl(cii.active_start_date, sysdate-1) and nvl(cii.active_end_date, sysdate+1)
  ORDER BY quantity;

  CURSOR tld_cur(p_transaction_line_id IN number)
  IS
  SELECT txn_line_detail_id ,
         instance_id,
         quantity
  FROM   csi_t_txn_line_details
  WHERE  transaction_line_id = p_transaction_line_id
  AND    source_transaction_flag = 'Y';


  PROCEDURE debug(p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  BEGIN

    SELECT sub_type_id ,
           src_change_owner
    INTO   l_sub_type_id,
           l_change_owner
    FROM   csi_txn_sub_types
    WHERE  transaction_type_id = 53
    AND    default_flag        = 'Y';

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    --Changed to use the BULK COLLECT for cursor for bug5248037--
    OPEN rma_cur;
    LOOP
      FETCH rma_cur BULK COLLECT
         INTO l_rma_txn_tbl
            LIMIT MAX_BUFFER_SIZE;

      l_rec_change := TRUE;

      FOR i IN  1..l_rma_txn_tbl.COUNT
      LOOP
	l_processed_flag := 'N';

        IF l_rec_change THEN
          OPEN inst_cur(l_rma_txn_tbl(i).item_id,
                        l_rma_txn_tbl(i).party_id,
                        l_rma_txn_tbl(i).owner_acct);
          LOOP
            l_instance_tbl.delete;
            FETCH inst_cur BULK COLLECT
            INTO l_instance_tbl
            LIMIT MAX_BUFFER_SIZE;
            EXIT WHEN inst_cur%NOTFOUND;
         END LOOP;

	 IF inst_cur%ISOPEN THEN
            CLOSE inst_cur;
         END IF;
        END IF;

    IF l_instance_tbl.count > 0 THEN
     FOR j IN l_instance_tbl.FIRST..l_instance_tbl.LAST
     LOOP
      IF l_instance_tbl.EXISTS(j) THEN
       IF l_instance_tbl(j).quantity >= l_rma_txn_tbl(i).mtl_txn_qty
        AND l_instance_tbl(j).active_start_date <= l_rma_txn_tbl(i).mtl_creation_date THEN

          -- check for existance of txn details
          l_transaction_line_id := null;
          BEGIN
              SELECT transaction_line_id
              INTO   l_transaction_line_id
              FROM   csi_t_transaction_lines
              WHERE  source_transaction_table = 'OE_ORDER_LINES_ALL'
              AND    source_transaction_id    = l_rma_txn_tbl(i).mtl_src_line_id
              AND    source_transaction_type_id = 53;
          EXCEPTION
              WHEN no_data_found THEN
                l_transaction_line_id := null;
          END;

          -- if not found then

          IF l_transaction_line_id is null THEN
             -- create transaction details
	      l_line_rec.transaction_line_id            := fnd_api.g_miss_num;
              l_line_rec.source_transaction_type_id     := 53;
              l_line_rec.source_transaction_id          := l_rma_txn_tbl(i).mtl_src_line_id;
              l_line_rec.source_transaction_table       := 'OE_ORDER_LINES_ALL';
              l_line_rec.inv_material_txn_flag          := 'Y';
              l_line_rec.object_version_number          := 1.0;

              -- transaction line details table
              l_line_dtl_tbl(1).transaction_line_id     := fnd_api.g_miss_num;
              l_line_dtl_tbl(1).txn_line_detail_id      := fnd_api.g_miss_num;
              l_line_dtl_tbl(1).sub_type_id             := l_sub_type_id;
              l_line_dtl_tbl(1).instance_exists_flag    := 'Y';
              l_line_dtl_tbl(1).instance_id             := l_instance_tbl(j).instance_id;
              l_line_dtl_tbl(1).source_transaction_flag := 'Y';
              l_line_dtl_tbl(1).quantity                := l_rma_txn_tbl(i).ordered_qty;
              l_line_dtl_tbl(1).inventory_item_id       := l_rma_txn_tbl(i).item_id;
              l_line_dtl_tbl(1).inv_organization_id     := l_rma_txn_tbl(i).organization_id;
              l_line_dtl_tbl(1).unit_of_measure         := l_rma_txn_tbl(i).ordered_uom;
              l_line_dtl_tbl(1).mfg_serial_number_flag  := 'N';
              l_line_dtl_tbl(1).active_start_date       := sysdate;
              l_line_dtl_tbl(1).preserve_detail_flag    := 'Y';
              l_line_dtl_tbl(1).object_version_number   := 1.0;

               IF l_change_owner = 'Y' THEN
                  l_pty_dtl_tbl(1).txn_party_detail_id    := fnd_api.g_miss_num;
                  l_pty_dtl_tbl(1).txn_line_detail_id     := fnd_api.g_miss_num;
                  l_pty_dtl_tbl(1).party_source_table     := 'HZ_PARTIES';
                  l_pty_dtl_tbl(1).party_source_id        := l_internal_party_id;
                  l_pty_dtl_tbl(1).relationship_type_code := 'OWNER';
                  l_pty_dtl_tbl(1).contact_flag           := 'N';
                  l_pty_dtl_tbl(1).active_start_date      := sysdate;
                  l_pty_dtl_tbl(1).preserve_detail_flag   := 'Y';
                  l_pty_dtl_tbl(1).txn_line_details_index := 1;

		  BEGIN
                    SELECT instance_party_id
                    INTO   l_pty_dtl_tbl(1).instance_party_id
                    FROM   csi_i_parties
                    WHERE  instance_id            = l_instance_tbl(j).instance_id
                    AND    relationship_type_code = 'OWNER';
                  EXCEPTION
                    WHEN no_data_found THEN
                       l_pty_dtl_tbl(1).instance_party_id := fnd_api.g_miss_num;
                  END;
               END IF;

              -- api call
              csi_t_txn_details_grp.create_transaction_dtls(
                               p_api_version              => 1.0,
                               p_commit                   => fnd_api.g_false,
                               p_init_msg_list            => fnd_api.g_true,
                               p_validation_level         => fnd_api.g_valid_level_full,
                               px_txn_line_rec            => l_line_rec,
                               px_txn_line_detail_tbl     => l_line_dtl_tbl,
                               px_txn_party_detail_tbl    => l_pty_dtl_tbl,
                               px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
                               px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
                               px_txn_org_assgn_tbl       => l_oa_tbl,
                               px_txn_ext_attrib_vals_tbl => l_ea_tbl,
                               px_txn_systems_tbl         => l_sys_tbl,
                               x_return_status            => l_return_status,
                               x_msg_count                => l_msg_count,
                               x_msg_data                 => l_msg_data);

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;

             l_processed_flag := 'Y';
             -- else check if count of source line detail

        ELSE
           FOR tld_rec IN tld_cur(l_transaction_line_id)
           LOOP
             l_tld_count := tld_cur%rowcount;
             l_txn_line_detail_id := tld_rec.txn_line_detail_id;
             IF l_tld_count > 1 THEN
                 exit;
             END IF;
           END LOOP;

           -- if only one then
           IF l_tld_count = 1 THEN
                UPDATE csi_t_txn_line_details
                SET    instance_id = l_instance_tbl(j).instance_id,
                       instance_exists_flag = 'Y'
                WHERE  txn_line_detail_id = l_txn_line_detail_id;
                       l_processed_flag := 'Y';
           END IF;

        END IF;

        IF l_processed_flag = 'Y' THEN
           UPDATE csi_txn_errors
           SET    processed_flag       = 'R'
           WHERE  transaction_error_id = l_rma_txn_tbl(i).Txn_error_id;

          l_instance_tbl(j).quantity:=l_instance_tbl(j).quantity-l_rma_txn_tbl(i).ordered_qty;

          --If an instance is matched for the error'd record then that instance is removed from
	  --table
          IF l_instance_tbl(j).quantity = 0 THEN
            l_instance_tbl.DELETE(j);
          END IF;
          EXIT;
        END IF;
      END IF;
     END IF; --for record existing check
   END LOOP; -- instance for loop
  END IF; --instance tbl cnt greater than zero

   --This IF loop avoids the re-query if the next error record is for the same item,party and owner--
   IF i < l_rma_txn_tbl.count THEN
     IF (l_rma_Txn_tbl(i).item_id <> l_rma_txn_tbl(i+1).item_id)
     OR (l_rma_Txn_tbl(i).party_id <> l_rma_txn_tbl(i+1).party_id)
     OR (l_rma_Txn_tbl(i).owner_acct <> l_rma_txn_tbl(i+1).owner_acct) THEN
        l_rec_change := TRUE;
     ELSE
      l_rec_change := FALSE;
     END IF;
   END IF;

   END LOOP;

   COMMIT;

   EXIT WHEN rma_cur%NOTFOUND;

  END LOOP; --rma tbl

  IF rma_cur%ISOPEN THEN
   CLOSE rma_cur;
  END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      null;
    WHEN others THEN
      null;
      log('  Other Error:'||substr(sqlerrm, 1,250));
  END create_nsrl_rma_tld;

  PROCEDURE fix_txn_error_rec
  IS

    CURSOR err_cur IS
      SELECT transaction_error_id,
             inv_material_transaction_id
      FROM   csi_txn_errors
      WHERE  processed_flag in ('E', 'R')
      AND    inv_material_transaction_id is not null
      AND    (source_type is null OR transaction_type_id is null);

    l_release             varchar2(30);
    l_mtl_txn_id          number;
    l_mtl_type_id         number;
    l_mtl_action_id       number;
    l_mtl_source_type_id  number;
    l_mtl_type_class      number;
    l_mtl_txn_qty         number;

    l_source_type         varchar2(30);
    l_csi_txn_type_id     number;
    l_txn_processed       varchar2(1) := 'N';


  BEGIN

    SELECT fnd_Profile.value('csi_upgrading_from_release')
    INTO   l_release
    FROM   sys.dual;

    FOR err_rec IN err_cur
    LOOP

      BEGIN
        SELECT 'Y' INTO l_txn_processed
        FROM   sys.dual
        WHERE  exists (
          SELECT 'X' FROM csi_transactions
          WHERE  inv_material_transaction_id = err_rec.inv_material_transaction_id);

        UPDATE csi_txn_errors
        SET    processed_flag = 'D'
        WHERE  transaction_error_id = err_rec.transaction_error_id;

      EXCEPTION
        WHEN no_data_found THEN

          BEGIN
            SELECT mmt.transaction_id,
                   mmt.transaction_type_id,
                   mmt.transaction_action_id,
                   mmt.transaction_source_type_id,
                   mtt.type_class,
                   mmt.transaction_quantity
            INTO   l_mtl_txn_id,
                   l_mtl_type_id,
                   l_mtl_action_id,
                   l_mtl_source_type_id,
                   l_mtl_type_class,
                   l_mtl_txn_qty
            FROM   mtl_material_transactions mmt,
                   mtl_transaction_types     mtt
            WHERE  mmt.transaction_id      = err_rec.inv_material_transaction_id
            AND    mtt.transaction_type_id = mmt.transaction_type_id;

            get_source_type(
              p_mtl_txn_id         => l_mtl_txn_id,
              p_mtl_type_id        => l_mtl_type_id,
              p_mtl_action_id      => l_mtl_action_id,
              p_mtl_source_type_id => l_mtl_source_type_id,
              p_mtl_type_class     => l_mtl_type_class,
              p_mtl_txn_qty        => l_mtl_txn_qty,
              p_release            => l_release,
              x_source_type        => l_source_type,
              x_csi_txn_type_id    => l_csi_txn_type_id);

            UPDATE csi_txn_errors
            SET    source_type          = l_source_type,
                   transaction_type_id  = l_csi_txn_type_id
            WHERE  transaction_error_id = err_rec.transaction_error_id;

          EXCEPTION
            WHEN no_data_found THEN
              null;
          END;
      END ;
    END LOOP;
    commit;
  END fix_txn_error_rec;

  PROCEDURE fix_wip_usage IS

    TYPE NumTabType is       varray(10000) of number;
    l_instance_id_tab        NumTabType;
    MAX_BUFFER_SIZE          number := 1000;

    CURSOR wip_cur IS
      SELECT cii.instance_id
      FROM   csi_item_instances cii
      WHERE  cii.location_type_code = 'WIP'
      AND    cii.instance_usage_code <> 'IN_RELATIONSHIP'
      AND    exists (
        SELECT 'X' FROM mtl_system_items msi
        WHERE  msi.inventory_item_id = cii.inventory_item_id
        AND    msi.organization_id   = cii.last_vld_organization_id
        AND    msi.serial_number_control_code in (1, 6));

  BEGIN

    OPEN wip_cur;
    LOOP

      FETCH wip_cur BULK COLLECT
      INTO  l_instance_id_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_instance_id_tab.COUNT
      LOOP
        UPDATE csi_item_instances
        SET    instance_usage_code = 'IN_WIP'
        WHERE  instance_id         = l_instance_id_tab(ind);
      END LOOP;
      commit;

      EXIT when wip_cur%NOTFOUND;

    END LOOP;

    IF wip_cur%ISOPEN THEN
      CLOSE wip_cur;
    END IF;

  END fix_wip_usage;

  PROCEDURE delete_dup_nsrl_wip_instances IS

    l_keep_instance_id       number;
    TYPE NumTabType is       varray(10000) of number;
    TYPE VarTabType is       varray(10000) of varchar2(100);

    l_item_id_tab            NumTabType;
    l_revision_tab           VarTabType;
    l_lot_number_tab         VarTabType;
    l_wip_job_id_tab         NumTabType;

    MAX_BUFFER_SIZE          number := 1000;

    CURSOR dup_wip_cur IS
      SELECT cii.inventory_item_id,
             cii.inventory_revision,
             cii.lot_number,
             cii.wip_job_id
      FROM   csi_item_instances cii,
             mtl_system_items   msi
      WHERE  cii.location_type_code  = 'WIP'
      AND    cii.instance_usage_code = 'IN_WIP'
      AND    msi.inventory_item_id = cii.inventory_item_id
      AND    msi.organization_id   = cii.last_vld_organization_id
      AND    msi.serial_number_control_code in (1, 6)
      GROUP BY cii.inventory_item_id,
               cii.inventory_revision,
               cii.lot_number,
               cii.wip_job_id
      HAVING   count(*) > 1;

    CURSOR dup_inst_cur(
      p_item_id    IN number,
      p_revision   IN varchar,
      p_lot_number IN varchar2,
      p_wip_job_id IN number)
    IS
      SELECT cii.instance_id,
             cii.quantity
      FROM   csi_item_instances cii
      WHERE  cii.location_type_code  = 'WIP'
      AND    cii.instance_usage_code = 'IN_WIP'
      AND    cii.inventory_item_id                = p_item_id
      AND    nvl(cii.inventory_revision, '#*#*#') = nvl(p_revision, '#*#*#')
      AND    nvl(cii.lot_number,'#*#*#')          = nvl(p_lot_number, '#*#*#')
      AND    cii.wip_job_id                       = p_wip_job_id;

    CURSOR ip_cur(p_instance_id IN number) IS
      SELECT instance_party_id
      FROM   csi_i_parties
      WHERE  instance_id = p_instance_id;

  BEGIN

    OPEN dup_wip_cur;
    LOOP

      FETCH dup_wip_cur BULK COLLECT
      INTO  l_item_id_tab,
            l_revision_tab,
            l_lot_number_tab,
            l_wip_job_id_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_item_id_tab.COUNT
      LOOP

        l_keep_instance_id := null;

        FOR dup_inst_rec IN dup_inst_cur(
          p_item_id    => l_item_id_tab(ind),
          p_revision   => l_revision_tab(ind),
          p_lot_number => l_lot_number_tab(ind),
          p_wip_job_id => l_wip_job_id_tab(ind))
        LOOP

          IF dup_inst_cur%rowcount = 1 THEN
            l_keep_instance_id := dup_inst_rec.instance_id;
          ELSE

            -- preserve one instance for the wip job component and cumulate quantity
            UPDATE csi_item_instances
            SET    quantity    = quantity + dup_inst_rec.quantity
            WHERE  instance_id = l_keep_instance_id;

            -- delete the rest of the instances (party and accounts)
            FOR ip_rec IN ip_cur(dup_inst_rec.instance_id)
            LOOP

              -- there may not be an account, but just in case
              DELETE FROM csi_ip_accounts
              WHERE  instance_party_id = ip_rec.instance_party_id;

              DELETE FROM csi_i_parties_h
              WHERE  instance_party_id = ip_rec.instance_party_id;

            END LOOP;

            DELETE FROM csi_i_parties
            WHERE  instance_id = dup_inst_rec.instance_id;

            DELETE FROM csi_item_instances
            WHERE  instance_id = dup_inst_rec.instance_id;

            DELETE FROM csi_item_instances_h
            WHERE  instance_id = dup_inst_rec.instance_id;

          END IF;
        END LOOP;

      END LOOP;

      commit;

      EXIT when dup_wip_cur%NOTFOUND;

    END LOOP;

    IF dup_wip_cur%ISOPEN THEN
      CLOSE dup_wip_cur;
    END IF;

  END delete_dup_nsrl_wip_instances;
  --
  PROCEDURE Delete_Dup_Org_Assignments IS
     cursor csi_dup_cur is
     select instance_id,relationship_type_code
     from csi_i_org_assignments
     group by instance_id,relationship_type_code
     having count(*) > 1;
     --
     cursor csi_org_cur(p_instance_id in number,p_rel_type_code in varchar2) is
     select *
     from csi_i_org_assignments
     where instance_id = p_instance_id
     and   relationship_type_code = p_rel_type_code
     order by creation_date asc;
     --
     cursor csi_org_hist_cur(p_instance_id in number,p_rel_type_code in varchar2) is
     select coah.* from csi_i_org_assignments_h coah,
	    csi_i_org_assignments coa
     where coa.instance_id = p_instance_id
     and   coa.relationship_type_code = p_rel_type_code
     and   coah.instance_ou_id = coa.instance_ou_id
     order by coah.transaction_id,coah.last_update_date asc;
     --
     l_hist_rec             csi_org_hist_cur%ROWTYPE;
     v_min_ou_id            NUMBER;
     v_min_org_id           NUMBER;
     v_max_ou_id            NUMBER;
     v_max_org_id           NUMBER;
     l_row_count            NUMBER;
     l_del_count            NUMBER := 0;
     TYPE NumList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_del_tbl              NumList;
     TYPE ORG_HIST_TBL IS TABLE OF CSI_I_ORG_ASSIGNMENTS_H%ROWTYPE INDEX BY BINARY_INTEGER;
     l_org_hist_tbl         ORG_HIST_TBL;
     l_hist_count           NUMBER;
     v_ret_ou_id            NUMBER;
     l_prev_rec             csi_org_hist_cur%ROWTYPE;
     l_ou_hist_count        NUMBER;
     l_del_ou_hist_tbl      NumList;
     l_flag                 VARCHAR2(1);
     --
     Process_next           EXCEPTION;
  BEGIN
     FOR dup_rec in csi_dup_cur LOOP
	Begin
	   -- Get the latest org assignment. This org_id will be retained
	   v_max_ou_id := -9999;
	   Begin
	      select instance_ou_id
	      into v_max_ou_id
	      from csi_i_org_assignments
	      where instance_id = dup_rec.instance_id
	      and   relationship_type_code = dup_rec.relationship_type_code
	      and   creation_date = ( select max(creation_date)
				      from csi_i_org_assignments
				      where instance_id = dup_rec.instance_id
				      and   relationship_type_code = dup_rec.relationship_type_code
				      and   nvl(active_end_date,(sysdate+1)) > sysdate)
	      and   nvl(active_end_date,(sysdate+1)) > sysdate
	      and   rownum < 2;
	   Exception
	      when no_data_found then
		 select max(instance_ou_id)
		 into  v_max_ou_id
		 from csi_i_org_assignments
		 where instance_id = dup_rec.instance_id
		 and   relationship_type_code = dup_rec.relationship_type_code;
	   End;
	   --
	   l_row_count := 0;
	   l_del_count := 0;
	   l_del_tbl.DELETE;
	   l_hist_count := 0;
	   l_org_hist_tbl.DELETE;
	   v_ret_ou_id := -99999;
	   --
	   FOR org_rec in csi_org_cur(dup_rec.instance_id,dup_rec.relationship_type_code) LOOP
	      l_row_count := l_row_count + 1;
	      IF l_row_count = 1 THEN
		 v_ret_ou_id := org_rec.instance_ou_id;
		 UPDATE CSI_I_ORG_ASSIGNMENTS
		 set (operating_unit_id,active_end_date,context,attribute1,attribute2,attribute3,
		      attribute4,attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
		      attribute11,attribute12,attribute13,attribute14,attribute15,last_update_date) =
		    (select operating_unit_id,active_end_date,context,attribute1,attribute2,attribute3,
		     attribute4,attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
		     attribute11,attribute12,attribute13,attribute14,attribute15,sysdate
		     from csi_i_org_assignments
		     where instance_ou_id = v_max_ou_id)
		  where instance_ou_id = org_rec.instance_ou_id;
	      ELSE
		 l_del_count := l_del_count + 1;
		 l_del_tbl(l_del_count) := org_rec.instance_ou_id;
	      END IF;
	   END LOOP; -- end of instance_id, relationship type combination
	   --
	   -- For this Instance - Relationship type, get all the history records ordered by txn_id
	   open csi_org_hist_cur(dup_rec.instance_id,dup_rec.relationship_type_code);
	   LOOP
	      fetch csi_org_hist_cur into l_hist_rec;
	      IF csi_org_hist_cur%FOUND THEN
		 l_hist_count := l_hist_count + 1;
		 l_org_hist_tbl(l_hist_count) := l_hist_rec;
	      END IF;
	      EXIT WHEN csi_org_hist_cur%NOTFOUND;
	   END LOOP;
	   close csi_org_hist_cur;
	   --
	   -- Merge the history belonging to the same transaction
	   l_flag := 'N';
	   l_del_ou_hist_tbl.DELETE;
	   --
	   IF l_org_hist_tbl.count > 0 THEN
	      FOR j IN l_org_hist_tbl.FIRST .. l_org_hist_tbl.LAST LOOP
		 IF j = 1 THEN
		    l_prev_rec := l_org_hist_tbl(j);
		 ELSE
		    IF l_org_hist_tbl(j).transaction_id = l_prev_rec.transaction_id THEN
		       l_flag := 'Y';
		       l_ou_hist_count := l_del_ou_hist_tbl.count + 1;
		       l_del_ou_hist_tbl(l_ou_hist_count) := l_org_hist_tbl(j).instance_ou_history_id;
		       IF nvl(l_org_hist_tbl(j).old_operating_unit_id,-999) <>
			  nvl(l_org_hist_tbl(j).new_operating_unit_id,-999) THEN
			  l_prev_rec.old_operating_unit_id := l_org_hist_tbl(j).old_operating_unit_id;
			  l_prev_rec.new_operating_unit_id := l_org_hist_tbl(j).new_operating_unit_id;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_relationship_type_code,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_relationship_type_code,'$#$') THEN
			  l_prev_rec.old_relationship_type_code := l_org_hist_tbl(j).old_relationship_type_code;
			  l_prev_rec.new_relationship_type_code := l_org_hist_tbl(j).new_relationship_type_code;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_active_start_date,fnd_api.g_miss_date) <>
			  nvl(l_org_hist_tbl(j).new_active_start_date,fnd_api.g_miss_date) THEN
			  l_prev_rec.old_active_start_date := l_org_hist_tbl(j).old_active_start_date;
			  l_prev_rec.new_active_start_date := l_org_hist_tbl(j).new_active_start_date;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_active_end_date,fnd_api.g_miss_date) <>
			  nvl(l_org_hist_tbl(j).new_active_end_date,fnd_api.g_miss_date) THEN
			  l_prev_rec.old_active_end_date := l_org_hist_tbl(j).old_active_end_date;
			  l_prev_rec.new_active_end_date := l_org_hist_tbl(j).new_active_end_date;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_context,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_context,'$#$') THEN
			  l_prev_rec.old_context := l_org_hist_tbl(j).old_context;
			  l_prev_rec.new_context := l_org_hist_tbl(j).new_context;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute1,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute1,'$#$') THEN
			  l_prev_rec.old_attribute1 := l_org_hist_tbl(j).old_attribute1;
			  l_prev_rec.new_attribute1 := l_org_hist_tbl(j).new_attribute1;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute2,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute2,'$#$') THEN
			  l_prev_rec.old_attribute2 := l_org_hist_tbl(j).old_attribute2;
			  l_prev_rec.new_attribute2 := l_org_hist_tbl(j).new_attribute2;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute3,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute3,'$#$') THEN
			  l_prev_rec.old_attribute3 := l_org_hist_tbl(j).old_attribute3;
			  l_prev_rec.new_attribute3 := l_org_hist_tbl(j).new_attribute3;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute4,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute4,'$#$') THEN
			  l_prev_rec.old_attribute4 := l_org_hist_tbl(j).old_attribute4;
			  l_prev_rec.new_attribute4 := l_org_hist_tbl(j).new_attribute4;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute5,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute5,'$#$') THEN
			  l_prev_rec.old_attribute5 := l_org_hist_tbl(j).old_attribute5;
			  l_prev_rec.new_attribute5 := l_org_hist_tbl(j).new_attribute5;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute6,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute6,'$#$') THEN
			  l_prev_rec.old_attribute6 := l_org_hist_tbl(j).old_attribute6;
			  l_prev_rec.new_attribute6 := l_org_hist_tbl(j).new_attribute6;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute7,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute7,'$#$') THEN
			  l_prev_rec.old_attribute7 := l_org_hist_tbl(j).old_attribute7;
			  l_prev_rec.new_attribute7 := l_org_hist_tbl(j).new_attribute7;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute8,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute8,'$#$') THEN
			  l_prev_rec.old_attribute8 := l_org_hist_tbl(j).old_attribute8;
			  l_prev_rec.new_attribute8 := l_org_hist_tbl(j).new_attribute8;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute9,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute9,'$#$') THEN
			  l_prev_rec.old_attribute9 := l_org_hist_tbl(j).old_attribute9;
			  l_prev_rec.new_attribute9 := l_org_hist_tbl(j).new_attribute9;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute10,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute10,'$#$') THEN
			  l_prev_rec.old_attribute10 := l_org_hist_tbl(j).old_attribute10;
			  l_prev_rec.new_attribute10 := l_org_hist_tbl(j).new_attribute10;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute11,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute11,'$#$') THEN
			  l_prev_rec.old_attribute11 := l_org_hist_tbl(j).old_attribute11;
			  l_prev_rec.new_attribute11 := l_org_hist_tbl(j).new_attribute11;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute12,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute12,'$#$') THEN
			  l_prev_rec.old_attribute12 := l_org_hist_tbl(j).old_attribute12;
			  l_prev_rec.new_attribute12 := l_org_hist_tbl(j).new_attribute12;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute13,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute13,'$#$') THEN
			  l_prev_rec.old_attribute13 := l_org_hist_tbl(j).old_attribute13;
			  l_prev_rec.new_attribute13 := l_org_hist_tbl(j).new_attribute13;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute14,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute14,'$#$') THEN
			  l_prev_rec.old_attribute14 := l_org_hist_tbl(j).old_attribute14;
			  l_prev_rec.new_attribute14 := l_org_hist_tbl(j).new_attribute14;
		       END IF;
		       --
		       IF nvl(l_org_hist_tbl(j).old_attribute15,'$#$') <>
			  nvl(l_org_hist_tbl(j).new_attribute15,'$#$') THEN
			  l_prev_rec.old_attribute15 := l_org_hist_tbl(j).old_attribute15;
			  l_prev_rec.new_attribute15 := l_org_hist_tbl(j).new_attribute15;
		       END IF;
		       --
		    ELSE -- Txn id not same
		       IF l_flag = 'Y' THEN
			  update csi_i_org_assignments_h
			  set old_operating_unit_id = l_prev_rec.old_operating_unit_id,
			      new_operating_unit_id = l_prev_rec.new_operating_unit_id,
			      old_relationship_type_code = l_prev_rec.old_relationship_type_code,
			      new_relationship_type_code = l_prev_rec.new_relationship_type_code,
			      old_active_start_date = l_prev_rec.old_active_start_date,
			      new_active_start_date = l_prev_rec.new_active_start_date,
			      old_active_end_date = l_prev_rec.old_active_end_date,
			      new_active_end_date = l_prev_rec.new_active_end_date,
			      old_context = l_prev_rec.old_context,
			      new_context = l_prev_rec.new_context,
			      old_attribute1 = l_prev_rec.old_attribute1,
			      new_attribute1= l_prev_rec.new_attribute1,
			      old_attribute2 = l_prev_rec.old_attribute2,
			      new_attribute2= l_prev_rec.new_attribute2,
			      old_attribute3 = l_prev_rec.old_attribute3,
			      new_attribute3= l_prev_rec.new_attribute3,
			      old_attribute4 = l_prev_rec.old_attribute4,
			      new_attribute4= l_prev_rec.new_attribute4,
			      old_attribute5 = l_prev_rec.old_attribute5,
			      new_attribute5= l_prev_rec.new_attribute5,
			      old_attribute6 = l_prev_rec.old_attribute6,
			      new_attribute6= l_prev_rec.new_attribute6,
			      old_attribute7 = l_prev_rec.old_attribute7,
			      new_attribute7= l_prev_rec.new_attribute7,
			      old_attribute8 = l_prev_rec.old_attribute8,
			      new_attribute8= l_prev_rec.new_attribute8,
			      old_attribute9 = l_prev_rec.old_attribute9,
			      new_attribute9= l_prev_rec.new_attribute9,
			      old_attribute10 = l_prev_rec.old_attribute10,
			      new_attribute10= l_prev_rec.new_attribute10,
			      old_attribute11 = l_prev_rec.old_attribute11,
			      new_attribute11= l_prev_rec.new_attribute11,
			      old_attribute12 = l_prev_rec.old_attribute12,
			      new_attribute12= l_prev_rec.new_attribute12,
			      old_attribute13 = l_prev_rec.old_attribute13,
			      new_attribute13= l_prev_rec.new_attribute13,
			      old_attribute14 = l_prev_rec.old_attribute14,
			      new_attribute14= l_prev_rec.new_attribute14,
			      old_attribute15 = l_prev_rec.old_attribute15,
			      new_attribute15= l_prev_rec.new_attribute15,
			      last_update_date = sysdate
			  where instance_ou_history_id = l_prev_rec.instance_ou_history_id;
			  --
			  FORALL i in 1..l_del_ou_hist_tbl.count
			  delete from csi_i_org_assignments_h
			  where instance_ou_history_id = l_del_ou_hist_tbl(i);
			  --
			  l_flag := 'N';
			  l_del_ou_hist_tbl.DELETE;
		       END IF;
		       l_prev_rec := l_org_hist_tbl(j);
		    END IF;
		 END IF;
	      END LOOP;
	      -- Update the instance_ou_id with the one that is retained
	      IF l_flag = 'Y' THEN -- Just in case the last record in the loop matches with prev txn
		 update csi_i_org_assignments_h
		 set old_operating_unit_id = l_prev_rec.old_operating_unit_id,
		     new_operating_unit_id = l_prev_rec.new_operating_unit_id,
		     old_relationship_type_code = l_prev_rec.old_relationship_type_code,
		     new_relationship_type_code = l_prev_rec.new_relationship_type_code,
		     old_active_start_date = l_prev_rec.old_active_start_date,
		     new_active_start_date = l_prev_rec.new_active_start_date,
		     old_active_end_date = l_prev_rec.old_active_end_date,
		     new_active_end_date = l_prev_rec.new_active_end_date,
		     old_context = l_prev_rec.old_context,
		     new_context = l_prev_rec.new_context,
		     old_attribute1 = l_prev_rec.old_attribute1,
		     new_attribute1= l_prev_rec.new_attribute1,
		     old_attribute2 = l_prev_rec.old_attribute2,
		     new_attribute2= l_prev_rec.new_attribute2,
		     old_attribute3 = l_prev_rec.old_attribute3,
		     new_attribute3= l_prev_rec.new_attribute3,
		     old_attribute4 = l_prev_rec.old_attribute4,
		     new_attribute4= l_prev_rec.new_attribute4,
		     old_attribute5 = l_prev_rec.old_attribute5,
		     new_attribute5= l_prev_rec.new_attribute5,
		     old_attribute6 = l_prev_rec.old_attribute6,
		     new_attribute6= l_prev_rec.new_attribute6,
		     old_attribute7 = l_prev_rec.old_attribute7,
		     new_attribute7= l_prev_rec.new_attribute7,
		     old_attribute8 = l_prev_rec.old_attribute8,
		     new_attribute8= l_prev_rec.new_attribute8,
		     old_attribute9 = l_prev_rec.old_attribute9,
		     new_attribute9= l_prev_rec.new_attribute9,
		     old_attribute10 = l_prev_rec.old_attribute10,
		     new_attribute10= l_prev_rec.new_attribute10,
		     old_attribute11 = l_prev_rec.old_attribute11,
		     new_attribute11= l_prev_rec.new_attribute11,
		     old_attribute12 = l_prev_rec.old_attribute12,
		     new_attribute12= l_prev_rec.new_attribute12,
		     old_attribute13 = l_prev_rec.old_attribute13,
		     new_attribute13= l_prev_rec.new_attribute13,
		     old_attribute14 = l_prev_rec.old_attribute14,
		     new_attribute14= l_prev_rec.new_attribute14,
		     old_attribute15 = l_prev_rec.old_attribute15,
		     new_attribute15= l_prev_rec.new_attribute15,
		     last_update_date = sysdate
		 where instance_ou_history_id = l_prev_rec.instance_ou_history_id;
		 --
		 FORALL i in 1..l_del_ou_hist_tbl.count
		 delete from csi_i_org_assignments_h
		 where instance_ou_history_id = l_del_ou_hist_tbl(i);
		 --
		 l_flag := 'N';
		 l_del_ou_hist_tbl.DELETE;
	      END IF;
	      --
	      FOR x in l_org_hist_tbl.FIRST .. l_org_hist_tbl.LAST LOOP
		 update csi_i_org_assignments_h
		 set instance_ou_id = v_ret_ou_id,
		     last_update_date = sysdate
		 where instance_ou_history_id = l_org_hist_tbl(x).instance_ou_history_id;
	      END LOOP;
	   END IF;
	   --
	   -- Delete the Duplicate Org Assignments
	   FORALL x in l_del_tbl.FIRST .. l_del_tbl.LAST
	      DELETE FROM CSI_I_ORG_ASSIGNMENTS
	      where instance_ou_id = l_del_tbl(x);
	   commit;
	Exception
	   when Process_next then
	      null;
	End;
     END LOOP;
     commit;
  END Delete_Dup_Org_Assignments;
  --
  PROCEDURE dump_unprocessed_fs_serials IS

    CURSOR fs_cur IS
      SELECT inventory_item_id,
             serial_number,
             instance_id,
             date_time_stamp,
             mtl_txn_id,
             error_message
      FROM   csi_ii_forward_sync_temp
      WHERE  process_flag <> 'P';

    CURSOR err_txn_cur (p_item_id IN number, p_serial_number IN varchar2) IS
      SELECT cdt.mtl_txn_name,
             cdt.mtl_txn_id,
             cdt.mtl_txn_date,
             cte.error_text
      FROM   csi_diagnostics_temp cdt,
             csi_txn_errors       cte
      WHERE  cdt.inventory_item_id = p_item_id
      AND    cdt.serial_number = p_serial_number
      AND    cte.inv_material_transaction_id = cdt.mtl_txn_id
      AND    cte.processed_flag in ('E', 'R')
      ORDER BY diag_seq_id;

    l_out varchar2(2000);

  BEGIN
    FOR fs_rec IN fs_cur
    LOOP

      IF fs_cur%rowcount = 1 THEN
        l_out := fill('item_id', 10)||
                 fill('serial_number', 20)||
                 fill('inst_id',10)||
                 fill('time_stamp',12)||
                 fill('mtl_txn_id',10)||
                 fill('error_message', 18);
        log(l_out);
        l_out := fill('-------', 10)||
                 fill('-------------', 20)||
                 fill('-------',10)||
                 fill('----------',12)||
                 fill('----------',10)||
                 fill('-------------', 18);
        log(l_out);
      END IF;

      l_out := fill(fs_rec.inventory_item_id, 10)||
               fill(fs_rec.serial_number, 20)||
               fill(fs_rec.instance_id,10)||
               fill(fs_rec.date_time_stamp,12)||
               fill(fs_rec.mtl_txn_id,10)||
               fill(fs_rec.error_message, 18);

      FOR err_txn_rec IN err_txn_cur(fs_rec.inventory_item_id, fs_rec.serial_number)
      LOOP
        l_out := '  '||
                 fill(err_txn_rec.mtl_txn_name, 25)||
                 fill(err_txn_rec.mtl_txn_id, 10)||
                 fill(err_txn_rec.mtl_txn_date, 12)||
                 fill(err_txn_rec.error_text, 30);
        log(l_out);
      END LOOP;
    END LOOP;
  END dump_unprocessed_fs_serials;

  PROCEDURE populate_mtl_txn_creation_date
  IS
    l_creation_date date;

    CURSOR fs_cur IS
      SELECT mtl_txn_id
      FROM   csi_ii_forward_sync_temp
      WHERE  process_flag <> 'P'
      AND    mtl_txn_creation_date is null
      FOR UPDATE OF mtl_txn_creation_date;
  BEGIN
    FOR fs_rec IN fs_cur
    LOOP
      SELECT creation_date
      INTO   l_creation_date
      FROM   mtl_material_transactions
      WHERE  transaction_id = fs_rec.mtl_txn_id;

      UPDATE csi_ii_forward_sync_temp
      SET    mtl_txn_creation_date = l_creation_date
      WHERE  current of fs_cur;

    END LOOP;
    commit;
  END populate_mtl_txn_creation_date;

  --
  PROCEDURE create_mmt_trigger IS
  BEGIN

    log(date_time_stamp||'creating mmt trigger csi_block_mat_txn_trg');

    EXECUTE IMMEDIATE
     'CREATE OR REPLACE TRIGGER CSI_BLOCK_MAT_TXN_TRG
      BEFORE INSERT ON MTL_MATERIAL_TRANSACTIONS
      REFERENCING NEW AS NEW OLD AS OLD
      FOR EACH ROW
      DECLARE
        v_nl_trackable   VARCHAR2(1);
      BEGIN
        BEGIN
          SELECT comms_nl_trackable_flag
          INTO v_nl_trackable
          FROM MTL_SYSTEM_ITEMS msi,
               MTL_PARAMETERS mp
          where mp.organization_id = :new.organization_id
          and   msi.inventory_item_id = :new.inventory_item_id
          and   msi.organization_id = mp.master_organization_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
        IF nvl(v_nl_trackable,''N'') = ''Y'' THEN
          :new.last_updated_by := null;
        END IF;
      END;';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END create_mmt_trigger;

  PROCEDURE drop_mmt_trigger IS
  BEGIN
    log(date_time_stamp||'dropping the trigger csi_block_mat_txn_trg');
    EXECUTE IMMEDIATE 'DROP TRIGGER CSI_BLOCK_MAT_TXN_TRG';
  EXCEPTION
    WHEN others THEN
      null;
  END drop_mmt_trigger;

  PROCEDURE ib_sync(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY NUMBER,
    p_show_instances  IN         VARCHAR2,
    p_mode            IN         VARCHAR2,
    p_force_data_fix  IN         VARCHAR2)
  IS
    l_errbuf           varchar2(2000);
    l_retcode          number;
    l_recount          number;
    comp_error         exception;
    l_auto_populate_allowed varchar2(3); --bug 5248037--

    --
    TYPE LOOKUP_REC IS RECORD
       ( lookup_code       VARCHAR2(30),
         enabled_flag      VARCHAR2(1)
       );
    TYPE LOOKUP_TBL IS TABLE OF LOOKUP_REC INDEX BY BINARY_INTEGER;
    --
    l_lookup_tbl          LOOKUP_TBL;
    l_ctr                 NUMBER := 0;
    l_type                VARCHAR2(30) := 'CSI_CORRECTION_ROUTINES';
    --
    CURSOR CSI_LOOKUP_CUR IS
    select lookup_code,enabled_flag
    from CSI_LOOKUPS
    where lookup_type = l_type;
    --
    FUNCTION Is_Routine_Enabled(
      p_lookup_tbl       in lookup_tbl,
      p_routine_name     in varchar2)
    RETURN BOOLEAN
    IS
       l_ret_value   BOOLEAN := TRUE;
       l_flag        VARCHAR2(1);
    BEGIN
       l_flag := 'Y'; -- No data will qualify for Procedure execution
       --
       IF p_lookup_tbl.count > 0 THEN
	  FOR J IN p_lookup_tbl.FIRST .. p_lookup_tbl.LAST LOOP
	     IF p_lookup_tbl(J).lookup_code = p_routine_name THEN
		l_flag := p_lookup_tbl(J).enabled_flag;
		exit;
	     END IF;
	  END LOOP;
       END IF;
       --
       IF l_flag = 'Y' THEN
	  l_ret_value := TRUE;
       ELSE
	  l_ret_value := FALSE;
       END IF;
       --
       RETURN l_ret_value;
    END Is_Routine_Enabled;
    --
  BEGIN

    debug_off;

    log('------------------------------------------------------------------------');
    log(date_time_stamp||'start ib_sync ');
    log('  parameter - Show Instances    :'||p_show_instances);
    log('  parameter - Mode of execution :'||p_mode);
    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag = 'N' OR
       csi_datastructures_pub.g_install_param_rec.freeze_flag = 'N' THEN
       log('Install Parameters no set. Process terminating...');
       errbuf := 'CSI Install Parameters not set...';
       retcode := 1;
       RAISE comp_error;
    END IF;
    -- checks block -- show stoppers
    log(date_time_stamp||'get_nl_trackable_report');
    csi_diagnostics_pkg.get_nl_trackable_report;

    IF l_global_warning_flag = 'Y' THEN
      log('Inconsistent IB trackable flag setup in org items and master items detected.');
      log('Please fix the items in the report csinonl.<mmddyy>.dbg and then rerun the program.');
      log('Process terminating...');
      errbuf := 'Inconsistent IB trackability in org items and master items detected';
      retcode := 1;
      RAISE comp_error;
    END IF;

    -- reports block
    log(date_time_stamp||'check_org_uniqueness');
    csi_diagnostics_pkg.check_org_uniqueness;

    log(date_time_stamp||'get_non_srl_rma_report');
    csi_diagnostics_pkg.get_non_srl_rma_report(
      p_show_instances  => p_show_instances);
    --
    -- Enable the Lookup Values that contain the Data Fix routines so that they all get executed.
    --
    IF nvl(p_force_data_fix,'N') = 'Y' THEN
       UPDATE FND_LOOKUP_VALUES
       SET enabled_flag = 'Y',
	   last_updated_by = -1,
	   last_update_date = sysdate
       WHERE lookup_type = l_type;
       --
       commit;
    END IF;
    --
    IF p_mode IN ('C', 'S') THEN
      -- datafix block -
      FOR csi_rec IN CSI_LOOKUP_CUR LOOP
         l_ctr := l_ctr + 1;
         l_lookup_tbl(l_ctr).lookup_code := csi_rec.lookup_code;
         l_lookup_tbl(l_ctr).enabled_flag := csi_rec.enabled_flag;
      END LOOP;
      --
      IF Is_Routine_Enabled(l_lookup_tbl,'DELETE_DUP_RELATIONSHIP') THEN
         Update_Lookup('DELETE_DUP_RELATIONSHIP');
         log(date_time_stamp||'delete_dup_relationship');
         csi_diagnostics_pkg.Delete_Dup_Relationship;
         commit;
      ELSE
         log(date_time_stamp||'delete_dup_relationship already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_NO_CTL_SRL_LOT_INST') THEN
         Update_Lookup('UPDATE_NO_CTL_SRL_LOT_INST');
         log(date_time_stamp||'update_no_ctl_srl_lot_inst');
         csi_diagnostics_pkg.Update_No_Ctl_Srl_Lot_Inst;
         commit;
      ELSE
         log(date_time_stamp||'Update_No_Ctl_Srl_Lot_Inst already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'DELETE_DUP_SRL_INV_INSTANCE') THEN
         Update_Lookup('DELETE_DUP_SRL_INV_INSTANCE');
         log(date_time_stamp||'delete_dup_srl_inv_instance');
         csi_diagnostics_pkg.Delete_Dup_Srl_Inv_Instance;
      ELSE
         log(date_time_stamp||'Delete_Dup_Srl_Inv_Instance already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_DUP_SRL_INSTANCE') THEN
         Update_Lookup('UPDATE_DUP_SRL_INSTANCE');
         log(date_time_stamp||'update_dup_srl_instance');
         csi_diagnostics_pkg.Update_Dup_Srl_Instance;
         commit;
      ELSE
         log(date_time_stamp||'Update_Dup_Srl_Instance already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'DEL_API_DUP_SRL_INSTANCE') THEN
         Update_Lookup('DEL_API_DUP_SRL_INSTANCE');
         log(date_time_stamp||'del_api_dup_srl_instance');
         csi_diagnostics_pkg.Del_API_Dup_Srl_Instance;
         commit;
      ELSE
         log(date_time_stamp||'Del_API_Dup_Srl_Instance already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_INSTANCE_USAGE') THEN
         Update_Lookup('UPDATE_INSTANCE_USAGE');
         log(date_time_stamp||'update_instance_usage');
         csi_diagnostics_pkg.Update_Instance_Usage;
         commit;
      ELSE
         log(date_time_stamp||'Update_Instance_Usage already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_FULL_DUMP_FLAG') THEN
         Update_Lookup('UPDATE_FULL_DUMP_FLAG');
         log(date_time_stamp||'update_full_dump_flag');
         csi_diagnostics_pkg.Update_Full_dump_flag;
         commit;
      ELSE
         log(date_time_stamp||'Update_Full_dump_flag already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_VLD_ORGANIZATION') THEN
         Update_Lookup('UPDATE_VLD_ORGANIZATION');
         log(date_time_stamp||'update_vld_organization');
         csi_diagnostics_pkg.Update_Vld_Organization;
         commit;
      ELSE
         log(date_time_stamp||'Update_Vld_Organization already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_REVISION') THEN
         Update_Lookup('UPDATE_REVISION');
         log(date_time_stamp||'update_revision');
         csi_diagnostics_pkg.Update_Revision;
         commit;
      ELSE
         log(date_time_stamp||'Update_Revision already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'MERGE_NON_SRL_INV_INSTANCE') THEN
         Update_Lookup('MERGE_NON_SRL_INV_INSTANCE');
         log(date_time_stamp||'merge_non_srl_inv_instance');
         csi_diagnostics_pkg.merge_non_srl_inv_instance;
         commit;
      ELSE
         log(date_time_stamp||'merge_non_srl_inv_instance already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'DELETE_DUP_ACCOUNT') THEN
         Update_Lookup('DELETE_DUP_ACCOUNT');
         log(date_time_stamp||'delete_dup_account');
         csi_diagnostics_pkg.delete_dup_account;
         commit;
      ELSE
         log(date_time_stamp||'delete_dup_account already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_INSTANCE_PARTY_SOURCE') THEN
         Update_Lookup('UPDATE_INSTANCE_PARTY_SOURCE');
         log(date_time_stamp||'update_instance_party_source');
         csi_diagnostics_pkg.update_instance_party_source;
         commit;
      ELSE
         log(date_time_stamp||'update_instance_party_source already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_CONTACT_PARTY_RECORD') THEN
         Update_Lookup('UPDATE_CONTACT_PARTY_RECORD');
         log(date_time_stamp||'update_contact_party_record');
         csi_diagnostics_pkg.update_contact_party_record;
         commit;
      ELSE
         log(date_time_stamp||'update_contact_party_record already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'REVERT_PARTY_REL_TYPE_UPDATE') THEN
         Update_Lookup('REVERT_PARTY_REL_TYPE_UPDATE');
         log(date_time_stamp||'revert_party_rel_type_update');
         csi_diagnostics_pkg.revert_party_rel_type_update;
         commit;
      ELSE
         log(date_time_stamp||'revert_party_rel_type_update already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'UPDATE_MASTER_ORGANIZATION_ID') THEN
         Update_Lookup('UPDATE_MASTER_ORGANIZATION_ID');
         log(date_time_stamp||'update_master_organization_id');
         csi_diagnostics_pkg.update_master_organization_ID;
         commit;
      ELSE
         log(date_time_stamp||'update_master_organization_ID already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'MISSING_MTL_TXN_ID_IN_CSI') THEN
         Update_Lookup('MISSING_MTL_TXN_ID_IN_CSI');
         log(date_time_stamp||'missing_mtl_txn_id_in_csi');
         csi_diagnostics_pkg.missing_mtl_txn_id_in_csi;
         commit;
      ELSE
         log(date_time_stamp||'missing_mtl_txn_id_in_csi already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'FIX_WIP_USAGE') THEN
         Update_Lookup('FIX_WIP_USAGE');
         log(date_time_stamp||'fix_wip_usage');
         csi_diagnostics_pkg.fix_wip_usage;
         commit;
      ELSE
         log(date_time_stamp||'fix_wip_usage already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'DELETE_DUP_NSRL_WIP_INSTANCES') THEN
         Update_Lookup('DELETE_DUP_NSRL_WIP_INSTANCES');
         log(date_time_stamp||'delete_dup_nsrl_wip_instances');
         csi_diagnostics_pkg.delete_dup_nsrl_wip_instances;
         commit;
      ELSE
         log(date_time_stamp||'delete_dup_nsrl_wip_instances already executed...');
      END IF;

      IF Is_Routine_Enabled(l_lookup_tbl,'DELETE_DUP_ORG_ASSIGNMENTS') THEN
         Update_Lookup('DELETE_DUP_ORG_ASSIGNMENTS');
         log(date_time_stamp||'Delete_Dup_Org_Assignments');
         csi_diagnostics_pkg.Delete_Dup_Org_Assignments;
         commit;
      ELSE
         log(date_time_stamp||'Delete_Dup_Org_Assignments already executed...');
      END IF;
      --
      commit;

    END IF;

    IF p_mode = 'S' THEN -- Synchronize IB

      create_mmt_trigger;

      -- read pending messages in SFM queue and pump them as errors
      log(date_time_stamp||'deque_messages_as_errors');
      dequeue_messages_as_errors;

      -- spawn the requbmit interface for the pumped errors
      log(date_time_stamp||'Resubmit interface for pending messages');
      csi_resubmit_pub.resubmit_interface(
        errbuf        => l_errbuf,
        retcode       => l_retcode,
        p_option      => 'SELECTED');

      log(date_time_stamp||'Resubmit interface completed successfully.');

    END IF;

    IF p_mode in ('C', 'S') THEN

      IF Is_Routine_Enabled(l_lookup_tbl,'EXPIRE_NON_TRACKABLE_INSTANCE') THEN
         Update_Lookup('EXPIRE_NON_TRACKABLE_INSTANCE');
         log(date_time_stamp||'expire_non_trackable_instance');
         csi_diagnostics_pkg.expire_non_trackable_instance;
         commit;
      ELSE
         log(date_time_stamp||'expire_non_trackable_instance already executed...');
      END IF;

      log(date_time_stamp||'fix_srlsoi_returned_serials');
      csi_diagnostics_pkg.fix_srlsoi_returned_serials;

      log(date_time_stamp||'mark_error_transactions');
      csi_diagnostics_pkg.mark_error_transactions;

      log(date_time_stamp||'create_or_update_shipping_inst');
      csi_diagnostics_pkg.create_or_update_shipping_inst;

      l_auto_populate_allowed := FND_PROFILE.VALUE('CSI_AUTO_POPULATE_INSTANCE'); --bug 5248037--
      log('Auto population allowed '||l_auto_populate_allowed);

      --Added IF condition for bug 5248037--
      IF UPPER(l_auto_populate_allowed) = 'Y'  THEN
	log(date_time_stamp||'create_nsrl_rma_tld');
        csi_diagnostics_pkg.create_nsrl_rma_tld;
      END IF;

      -- serial data spool and preprocess
      log(date_time_stamp||'get_srldata');
      csi_diagnostics_pkg.get_srldata;

      log(date_time_stamp||'preprocess_srldata');
      csi_diagnostics_pkg.preprocess_srldata;

      -- fix srl errors
      log(date_time_stamp||'fix_srldata');
      csi_diagnostics_pkg.fix_srldata;

      -- serial correction reports
      log(date_time_stamp||'spool errors serial Info');
      csi_diagnostics_pkg.spool_srldata('ERRORS');

      -- serial correction reports
      log(date_time_stamp||'spool all serial info');
      csi_diagnostics_pkg.spool_srldata('ALL');

      -- spawn the resubmit interface for the marked errors
      log(date_time_stamp||'Resubmit errors for the corrected serial numbers');
      csi_resubmit_pub.Resubmit_Interface(
        errbuf        => l_errbuf,
        retcode       => l_retcode,
        p_option      => 'SELECTED');
      log(date_time_stamp||'Resubmit interface completed successfully.');

      -- for the newly created column populate the value reading mtl_txn_id
      populate_mtl_txn_creation_date;

      -- forward sync serial routine
      log(date_time_stamp||'forward_sync');
      csi_diagnostics_pkg.forward_sync;
      commit;

      -- Check whether all the instances are forward synched
      BEGIN
        SELECT count(*)
        INTO   l_recount
        FROM   csi_ii_forward_sync_temp
        WHERE  process_flag <> 'P';
      END;
      --
      IF nvl(l_recount,0) > 0 THEN
        log( 'Forward Synch did not complete successfully. unprocessed count : '||l_recount);
        errbuf  := 'Forward Sync did not complete successfully.';
        retcode := 1;
        log(date_time_stamp||'dump_unprocessed_fs_serials');
        dump_unprocessed_fs_serials;
      END IF;
      --
    END IF;

    IF p_mode = 'S' THEN -- synchronize IB

      IF l_global_sync_flag = 'Y' THEN
        log('Error condition detected for SRL uniqueness across org/Non serial RMA failures.');
        log('Please check the items reported in the concurrent request output.');
        log('Process terminating...');
        errbuf  := 'SRL uniqueness across org OR Non serial RMA failures';
        retcode := 1;
        Raise comp_error;
      END IF;

      IF is_sfm_active THEN
        log('Please shut down the SFM Event Manager queue and re-run the program.');
        log('Process terminating...');
        retcode := 1;
        errbuf  := 'Please shut down the SFM event manager queue and re-run the program.';
        Raise comp_error;
      END IF;
      --

      log(date_time_stamp||'sync_inv_serials');
      csi_diagnostics_pkg.sync_inv_serials;

      log(date_time_stamp||'ib_inv_synch_non_srl');
      csi_diagnostics_pkg.ib_inv_synch_non_srl;

      log(date_time_stamp||'reverse_ib_inv_synch');
      csi_diagnostics_pkg.reverse_ib_inv_synch;

    END IF;

    drop_mmt_trigger;

    commit;

    log(date_time_stamp||'end ib_sync');
    log('------------------------------------------------------------------------');

  EXCEPTION
    WHEN comp_error THEN
      drop_mmt_trigger;
    WHEN OTHERS THEN
      drop_mmt_trigger;
      log('others error in ib_sync : '||sqlerrm);
      retcode := 1;
      errbuf  := sqlerrm;
  END ib_sync;


PROCEDURE create_oper_upd_manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2
  )
 IS
 BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start create_oper_upd_manager');
  -- Parent Processing

  AD_CONC_UTILS_PKG.Submit_Subrequests
    (x_errbuf                    => x_errbuf,
     x_retcode                   => x_retcode,
     x_workerconc_app_shortname  => 'CSI',
     x_workerconc_progname       => 'CSIUPOPS',
     x_batch_size                => 1000,
     x_num_workers               => 5
    );

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_errbuf: ' || x_errbuf);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_retcode: ' || x_retcode);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End create_oper_upd_manager');

 END create_oper_upd_manager;

PROCEDURE create_oper_upd_worker
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   x_batch_size     IN   NUMBER,
   x_worker_id      IN   NUMBER,
   x_num_workers    IN   NUMBER
  )
 IS
   l_table_owner           VARCHAR2(30);
   l_product               VARCHAR2(30) := 'CSI';
   l_status                VARCHAR2(30);
   l_industry              VARCHAR2(30);
   l_retstatus             BOOLEAN;
   l_batch_size            NUMBER := 1000;
   l_worker_id             NUMBER:=5;
   l_num_workers           NUMBER := 5;
   l_any_rows_to_process   BOOLEAN;
   l_table_name            VARCHAR2(30) := 'CSI_ITEM_INSTANCES';
   l_update_name           VARCHAR2(30) := 'csiupops.sql';
   l_start_rowid           rowid;
   l_end_rowid             rowid;
   l_rows_processed        number;
 BEGIN

  l_retstatus := fnd_installation.get_app_info(
                     l_product, l_status, l_industry, l_table_owner);

  IF ((l_retstatus = FALSE) OR (l_table_owner IS NULL)) THEN
       RAISE_APPLICATION_ERROR(-20001,
          'Cannot get schema name for product : '||l_product);
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  x_worker_id : '||x_worker_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_num_workers : '||x_num_workers);
  ad_parallel_updates_pkg.initialize_rowid_range(
      ad_parallel_updates_pkg.ROWID_RANGE
      ,l_table_owner
      ,l_table_name
      ,l_update_name
      ,x_worker_id
      ,x_num_workers
      ,x_batch_size,0);

   ad_parallel_updates_pkg.get_rowid_range(
       l_start_rowid
      ,l_end_rowid
      ,l_any_rows_to_process
      ,x_batch_size
      ,TRUE);

   WHILE(l_any_rows_to_process = TRUE)
   LOOP

      UPDATE /*+ rowid(cii) */ csi_item_instances cii
      SET    operational_status_code =
             DECODE(instance_usage_code,'IN_SERVICE','IN_SERVICE','OUT_OF_SERVICE',
                 'OUT_OF_SERVICE', 'INSTALLED','INSTALLED','NOT_USED')
             ,LAST_UPDATE_DATE = sysdate
             ,LAST_UPDATED_BY = -1
      where  operational_status_code IS NULL
      AND    rowid between l_start_rowid and l_end_rowid;

      l_rows_processed := SQL%ROWCOUNT;

      ad_parallel_updates_pkg.processed_rowid_range(
           l_rows_processed,
           l_end_rowid);

      commit;

      ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           x_batch_size,
           FALSE);
   END LOOP;
   x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
        x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
        RAISE;
 END create_oper_upd_worker;

END csi_diagnostics_pkg;

/
