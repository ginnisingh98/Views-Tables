--------------------------------------------------------
--  DDL for Package Body CSI_INV_DISCREPANCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_DISCREPANCY_PKG" AS
/* $Header: csiinvdb.pls 120.1 2005/06/04 02:06:57 appldev  $ */

-- ------------------------------------------------------------
-- Define global variables
-- ------------------------------------------------------------
  g_no_lot constant number := 1;
  g_lot    constant number := 2;
  --
  -- Procedure to debug the discrepancies
  --
  Procedure Debug(
    p_message       IN VARCHAR2)
  Is
  Begin
    fnd_file.put_line(fnd_file.log, p_message);
  End Debug;
  --
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
  --
  -- Truncate the discrepancy table before each run
  --
  Procedure Truncate_table(
    p_table_name    IN VARCHAR2)
  Is
    l_num_of_rows      NUMBER;
    l_truncate_handle  PLS_INTEGER := dbms_sql.open_cursor;
    l_statement        VARCHAR2(200);
  Begin
    l_statement := 'truncate table '||p_table_name;
    dbms_sql.parse(l_truncate_handle, l_statement, dbms_sql.native);
    l_num_of_rows := dbms_sql.execute(l_truncate_handle);
    dbms_sql.close_cursor(l_truncate_handle);
  Exception
    When Others Then
      Null;
  End truncate_table;
  --
  --
  -- Procedure that gets all the messages that are stuck in the
  -- SFM queue
  --
  Procedure decode_queue
  Is

    Cursor msg_cur IS
      Select msg_id,
             msg_code,
             msg_status,
             body_text,
             creation_date,
             description
      From   xnp_msgs
      Where  (msg_code Like 'CSI%' OR msg_code Like 'CSE%')
      And    nvl(msg_status, 'READY') <> 'PROCESSED'
      And    recipient_name Is Null;

    l_amount        INTEGER;
    l_msg_text      VARCHAR2(32767);
    l_source_id     VARCHAR2(200);
    l_source_type   VARCHAR2(30);

    l_schema_name   varchar2(30);
    l_object_name   varchar2(80);
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;

  Begin

    get_schema_name(
      p_product_short_name  => 'CSI',
      x_schema_name         => l_schema_name,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_object_name := l_schema_name||'.csi_xnp_msgs_temp';

  -- truncate the temporary table before each run
    truncate_table(l_object_name);

     For msg_rec in msg_cur
     Loop

       l_amount := Null;
       l_amount := dbms_lob.getlength(msg_rec.body_text);
       l_msg_text := Null;

       dbms_lob.read(
         lob_loc => msg_rec.body_text,
         amount  => l_amount,
         offset  => 1,
         buffer  => l_msg_text );

       l_source_id := Null;

       If msg_rec.msg_code in ('CSISOFUL', 'CSIRMAFL') Then
         xnp_xml_utils.decode(l_msg_text, 'ORDER_LINE_ID', l_source_id);
         l_source_type := 'ORDER_LINE_ID';
       Else
         xnp_xml_utils.decode(l_msg_text, 'MTL_TRANSACTION_ID', l_source_id);
         l_source_type := 'MTL_TRANSACTION_ID';
       End If;

       Insert Into csi_xnp_msgs_temp(
         msg_id,
         msg_code,
         msg_text,
         msg_status,
         source_id,
         source_type,
         creation_date,
         description,
         process_flag
         )
         Values
         (
         msg_rec.msg_id,
         msg_rec.msg_code,
         l_msg_text,
         msg_rec.msg_status,
         l_source_id,
         l_source_type,
         msg_rec.creation_date,
         msg_rec.description,
         'Y'
         );

       If mod(msg_cur%rowcount, 100) = 0 THEN
         commit;
       End If;
     End Loop; -- msg_rec in msg_cur
  End decode_queue;
  --
  --
  --  This procedure gets all the discrepancies in the data between the IB and INV
  --  for Non-Serialized items
  --
  Procedure IB_INV_Disc_Non_srl
  IS
     Cursor INV_ONH_BAL_CUR IS
     Select      moq.organization_id organization_id
     ,           moq.inventory_item_id inventory_item_id
     ,           moq.revision revision
     ,           moq.subinventory_code subinventory_code
     ,           moq.locator_id locator_id
     ,           moq.lot_number lot_number
     ,           msi.primary_uom_code primary_uom_code
     ,           SUM(moq.transaction_quantity) onhand_qty
     From
                 mtl_system_items      msi
     ,           mtl_onhand_quantities moq
     Where       msi.inventory_item_id = moq.inventory_item_id
     And         msi.organization_id   = moq.organization_id
     And         msi.serial_number_control_code in (1,6) -- No Serial control and at SO Issue Items
     Group By
		         moq.organization_id
     ,           moq.inventory_item_id
     ,           moq.revision
     ,           moq.subinventory_code
     ,           moq.locator_id
     ,           moq.lot_number
     ,           msi.primary_uom_code;


     v_inst_id                         NUMBER;
     v_inv_item_id                     NUMBER;
     v_inv_rev                         VARCHAR2(30);
     v_inv_srl_num                     VARCHAR2(30);
     v_inv_lot_num                     VARCHAR2(80);
     v_inst_qty                        NUMBER;
     v_inv_org_id                      NUMBER;
     v_inv_subinv_name                 VARCHAR2(30);
     v_inv_locator_id                  NUMBER;
     v_loc_type                        VARCHAR2(30);
     v_inst_usage                      VARCHAR2(30);
     v_freeze_date                     DATE;
     v_mast_org_id                     NUMBER;
     v_nl_trackable                    VARCHAR2(1);
     v_ins_status_id                   NUMBER;
     v_instance_id                     NUMBER;
     v_end_date                        DATE;
     v_party_id                        NUMBER;
     v_err_msg                         VARCHAR2(2000);
     v_exists                          VARCHAR2(1);
     v_ins_obj_nbr                     NUMBER;
     v_commit_count                    NUMBER := 0;
     l_error_count                     NUMBER := 0;
     l_count                           NUMBER := 0;
     inst_exists                       VARCHAR2(1);
     Error_text                        VARCHAR2(200);
     l_inst_count                      NUMBER := 0;
     --
     x_return_status                   VARCHAR2(1);
     --
     process_next                      Exception;
     comp_error                        Exception;


     Type NumTabType is VARRAY(10000) of NUMBER;
     organization_id_mig               NumTabType;
     inventory_item_id_mig             NumTabType;
     locator_id_mig                    NumTabType;
     quantity_mig                      NumTabType;
     --
     Type V3Type is VARRAY(10000) of VARCHAR2(3);
     uom_code_mig                      V3Type;
     revision_mig                      V3Type;
     --
     Type V10Type is VARRAY(10000) of VARCHAR2(10);
     subinv_mig                        V10Type;
     --
     Type V80Type is VARRAY(10000) of VARCHAR2(80); --bnarayan for inventory convergence
     lot_mig                           V80Type;
     --
     MAX_BUFFER_SIZE          NUMBER := 1000;

  Begin

  debug('start of the IB_INV_Disc program for Non-serialized items..');

  -- Load the csi_xnp_msgs_temp table with the records pending in the SFM queue
     decode_queue;
  --
  --
  Open INV_ONH_BAL_CUR;
  Loop
        Fetch INV_ONH_BAL_CUR BULK COLLECT INTO
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
        For i in 1 .. organization_id_mig.count
        Loop
         Begin

         -- Get the Master Organization ID
           Begin
              Select master_organization_id
              Into   v_mast_org_id
              From   MTL_PARAMETERS
              Where  organization_id = organization_id_mig(i);
           Exception
              When no_data_found Then
                Raise Process_next;
           End;
           --
           -- Check for IB trackable
           --
           v_nl_trackable := 'N';
            Begin
              Select comms_nl_trackable_flag
              Into   v_nl_trackable
              From   MTL_SYSTEM_ITEMS
              Where  inventory_item_id = inventory_item_id_mig(i)
              And    organization_id   = v_mast_org_id; -- check should it be org. id
           Exception
	          When No_Data_Found Then
                Raise Process_next;
           End;
	       --
           -- Check if there are any errors in CSI_TXN_ERRORS
           --
           l_error_count := 0;
           Begin
              Select Count(*)
              Into   l_error_count
              From   CSI_TXN_ERRORS csi,
                     MTL_MATERIAL_TRANSACTIONS mmt
              Where  csi.inv_material_transaction_id Is Not Null
              And    csi.inv_material_transaction_id = mmt.transaction_id
              And    csi.processed_flag IN ('E','R')
              And    mmt.inventory_item_id = inventory_item_id_mig(i)
              And    mmt.organization_id = organization_id_mig(i);
           End;
           --
           IF nvl(l_error_count,0) > 0 THEN
              v_err_msg := 'Unable to Synch Item ID '||to_char(inventory_item_id_mig(i))||
                            '  Under Organization '||to_char(organization_id_mig(i))||'pending in CSI_TXN_ERRORS';
               --debug(v_err_msg);
              Raise Process_next;
           End If;
           --
           -- Check whether there are any pending transactions in SFM Queue
           --
           If l_error_count = 0 Then

              Begin
                 Select Count(*)
                 Into   l_error_count
                 From   CSI_XNP_MSGS_TEMP xnp,
                        MTL_MATERIAL_TRANSACTIONS mmt
                 Where  xnp.source_id = mmt.transaction_id
                 And    xnp.source_type = 'MTL_TRANSACTION_ID'
                 And    mmt.inventory_item_id = inventory_item_id_mig(i)
                 And    mmt.organization_id   = organization_id_mig(i)
                 And    nvl(xnp.msg_status, 'READY') <> 'PROCESSED';
              End;
           End If;
           --
           If nvl(l_error_count, 0) > 0 Then
              v_err_msg := 'Unable to Synch Item ID '||to_char(inventory_item_id_mig(i))||
                            '  Under Organization '||to_char(organization_id_mig(i))||'pending in SFM queue';
              --debug(v_err_msg);
             Raise Process_next;
           End If;
           --
           -- Select the IB data
           --
           v_exists := Null;
           Begin
              Select   instance_id
              ,        inventory_item_id
              ,        inventory_revision
              ,        lot_number
              ,        quantity
              ,        active_end_date
              ,        location_type_code
              ,        inv_organization_id
              ,        inv_subinventory_name
              ,        inv_locator_id
              ,        instance_usage_code
              Into     v_inst_id
              ,        v_inv_item_id
              ,        v_inv_rev
              ,        v_inv_lot_num
              ,        v_inst_qty
              ,        v_end_date
              ,        v_loc_type
              ,        v_inv_org_id
              ,        v_inv_subinv_name
              ,        v_inv_locator_id
              ,        v_inst_usage
              From     csi_item_instances
              Where    inventory_item_id             = inventory_item_id_mig(i)
              And      last_vld_organization_id      = organization_id_mig(i)
              And      location_type_code            = 'INVENTORY'
              And      instance_usage_code           = 'IN_INVENTORY'
              And      inv_subinventory_name         = subinv_mig(i)
              And      nvl(inv_locator_id,-999)      = nvl(locator_id_mig(i),-999)
              And      nvl(inventory_revision,'$#$') = nvl(revision_mig(i),'$#$')
              And      nvl(lot_number,'$#$')         = nvl(lot_mig(i),'$#$')
              And      ((active_end_date IS NULL) OR (active_end_date > SYSDATE));
              v_exists := 'Y';
           Exception
              When No_Data_Found Then
                v_exists := 'N';
              When Too_Many_Rows Then
                Raise Process_next;
           END;
           --
           -- if the on-hand quantity in the INV doesn't match with the quantity in IB or if
           -- there are any active item instances for which comms_nl_trackable_flag is 'NULL' OR 'N'
           -- the then dump the difference into a temp table
           --
           If v_exists = 'Y'
           Then
              If v_inst_qty <> quantity_mig(i)
              OR NVL(v_nl_trackable, 'N') <> 'Y'
              Then

                Begin
                  Insert Into CSI_INV_DISCREPANCY_TEMP
                          (
                           discrepancy_id
                          ,inventory_item_id
                          ,serial_number
                          ,inv_revision
                          ,inv_lot_number
                          ,inv_quantity
                          ,inv_organization_id
                          ,inv_subinventory_name
                          ,inv_locator_id
                          ,instance_id
                          ,ii_revision
                          ,ii_lot_number
                          ,ii_quantity
                          ,ii_organization_id
                          ,ii_subinventory_name
                          ,ii_locator_id
                          ,ii_location_type_code
                          ,instance_usage_code
                          ,master_org_trackable_flag
                          ,child_org_trackable_flag
                          )
                          Values
                          (
                           csi_inv_discrepency_temp_s.Nextval
                          ,inventory_item_id_mig(i)
                          ,Null
                          ,revision_mig(i)
                          ,lot_mig(i)
                          ,quantity_mig(i)
                          ,organization_id_mig(i)
                          ,subinv_mig(i)
                          ,locator_id_mig(i)
                          ,v_inst_id
                          ,v_inv_rev
                          ,v_inv_lot_num
                          ,v_inst_qty
                          ,v_inv_org_id
                          ,v_inv_subinv_name
                          ,v_inv_locator_id
                          ,v_loc_type
                          ,v_inst_usage
                          ,v_nl_trackable
                          ,v_nl_trackable
                          );

                Exception
                   When Others Then
                     Null;
                       v_err_msg := 'Unable to Insert a record into the IB_INV_SYNC table'||SUBSTR(sqlerrm,1,1000);
                       debug(v_err_msg);

                End; -- end of insert into ib_inv_sync table

            End If; -- v_onhand_qty <> v_inst_qty
         End If; -- v_exists = 'Y'
         --
        Exception
         When process_next Then
           Null;
         When Others Then
           Null;
         End;
      --
      End Loop; -- for loop
      Commit;
     Exit When INV_ONH_BAL_CUR%NOTFOUND;
    End Loop; -- Open loop
    Commit;
    Close INV_ONH_BAL_CUR;
    --
 Exception
   When COMP_ERROR Then
     Null;
   When Others Then
     Null;

 End IB_INV_Disc_Non_srl;
 --

  --
  -- This function checks whether there are any differences between the INV and IB, if so then returns FALSE
  --
  FUNCTION not_the_same(
    p_instance_rec      in csi_datastructures_pub.instance_rec)
  RETURN boolean
  IS

    l_not_the_same    BOOLEAN := TRUE;

    l_vld_organization_id    number;
    l_inv_organization_id    number;
    l_inv_subinventory_name  varchar2(30);
    l_inventory_revision     varchar2(8);
    l_inv_locator_id         number;
    l_location_type_code     varchar(30);
    l_instance_usage_code    varchar(30);
    l_lot_number             varchar2(80);
    l_location_id            number;

  BEGIN
  debug('p_instance_rec.instance_id:'||p_instance_rec.instance_id);
    SELECT last_vld_organization_id,
           inv_organization_id,
           inv_subinventory_name,
           inventory_revision,
           inv_locator_id,
           location_type_code,
           instance_usage_code,
           location_id,
           lot_number
    INTO   l_vld_organization_id,
           l_inv_organization_id,
           l_inv_subinventory_name,
           l_inventory_revision,
           l_inv_locator_id,
           l_location_type_code,
           l_instance_usage_code,
           l_location_id,
           l_lot_number
    FROM csi_item_instances
    WHERE instance_id = p_instance_rec.instance_id;

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
       (nvl(p_instance_rec.instance_usage_code, fnd_api.g_miss_char) =
        nvl(l_instance_usage_code, fnd_api.g_miss_char))
        AND
       (nvl(p_instance_rec.lot_number, fnd_api.g_miss_char) =
        nvl(l_lot_number, fnd_api.g_miss_char))
    THEN
      l_not_the_same := FALSE;

      --debug('IB and INV attributes for ser. item are not same');
    END IF;

    RETURN l_not_the_same;

  END not_the_same;
  --
  --
  --  This procedure gets all the discrepancies between the IB and INV for Serialized items
  --
  PROCEDURE IB_INV_Disc_serials  IS

     CURSOR srl_cur
     IS
      SELECT msn.serial_number              serial_number,
             msn.inventory_item_id          inventory_item_id,
             msk.concatenated_segments      item_name,
             msn.current_organization_id    organization_id,
             msn.revision                   revision,
             msn.current_subinventory_code  subinventory_code,
             msn.current_locator_id         locator_id,
             msn.lot_number                 lot_number,
             msi.primary_uom_code           uom_code,
             msi.serial_number_control_code serial_code,
             msi.lot_control_code           lot_code
      FROM   mtl_system_items   msi,
             mtl_serial_numbers msn,
             mtl_system_items_kfv msk
      WHERE  msi.inventory_item_id = msn.inventory_item_id
      AND    msi.organization_id   = msn.current_organization_id
      AND    msi.inventory_item_id = msk.inventory_item_id
      AND    msi.organization_id   = msk.organization_id
      AND    msi.serial_number_control_code IN (2,5)
      AND    msn.current_status    = 3
      AND    EXISTS (
               SELECT '1'
               FROM   mtl_parameters   mp,
                      mtl_system_items msi_mast
               WHERE  mp.organization_id         = msi.organization_id
               AND    msi_mast.inventory_item_id = msi.inventory_item_id
               AND    msi_mast.organization_id   = mp.master_organization_id)
      --         AND    nvl(msi_mast.comms_nl_trackable_flag,'N') = 'Y') --commented to query all the non-trackable items
               AND    EXISTS (
                        SELECT '1'
                        FROM  mtl_onhand_quantities moq
                        WHERE moq.inventory_item_id     = msn.inventory_item_id
                        AND   moq.organization_id       = msn.current_organization_id
                        AND   moq.subinventory_code     = msn.current_subinventory_code
                        AND   nvl(moq.locator_id,-999)  = nvl(msn.current_locator_id,-999)
                        AND   nvl(moq.lot_number,'$#$') = nvl(msn.lot_number,'$#$')
                        AND   nvl(moq.revision,'$#$')   = nvl(msn.revision,'$#$') );

    CURSOR all_txn_cur(
      p_serial_number  in varchar2,
      p_item_id        in number,
      p_lot_code       in number  )
    IS
    SELECT /*+ parallel(mut) parallel(mmt) parallel(mtt) */
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
           to_char(null)                   lot_number,
           to_char(mmt.transaction_date,'dd-mm-yy hh24:mi:ss') mtl_txn_char_date
    FROM   mtl_unit_transactions     mut,
           mtl_material_transactions mmt,
           mtl_transaction_types     mtt
    WHERE  p_lot_code              = g_no_lot
    AND    mut.serial_number       = p_serial_number
    AND    mut.inventory_item_id   = p_item_id
    AND    mmt.transaction_id      = mut.transaction_id
    AND    mtt.transaction_type_id = mmt.transaction_type_id
    UNION
    SELECT /*+ parallel(mut) parallel(mtln) parallel(mmt) parallel(mtt) */
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
           mtln.lot_number                 lot_number,
           to_char(mmt.transaction_date,'dd-mm-yy hh24:mi:ss') mtl_txn_char_date
    FROM   mtl_unit_transactions       mut,
           mtl_transaction_lot_numbers mtln,
           mtl_material_transactions   mmt,
           mtl_transaction_types       mtt
    WHERE  p_lot_code                 = g_lot
    AND    mut.serial_number          = p_serial_number
    AND    mut.inventory_item_id      = p_item_id
    AND    mtln.serial_transaction_id = mut.transaction_id
    AND    mmt.transaction_id         = mtln.transaction_id
    AND    mtt.transaction_type_id    = mmt.transaction_type_id
    ORDER BY 1 desc;

    l_vld_organization_id    NUMBER;
    l_inventory_item_id      NUMBER;
    v_item_name              VARCHAR2(240);
    l_inv_organization_id    NUMBER;
    l_inv_subinventory_name  VARCHAR2(30);
    l_inventory_revision     VARCHAR2(8);
    l_inv_locator_id         NUMBER;
    l_location_type_code     VARCHAR(30);
    l_instance_usage_code    VARCHAR(30);
    l_lot_number             VARCHAR2(80);
    l_serial_number          VARCHAR2(30);
    l_quantity               NUMBER;
    l_location_id            NUMBER;
    l_instance               VARCHAR2(30);
    v_err_msg                VARCHAR2(2000);
    l_instance_found         BOOLEAN := TRUE;
    l_not_the_same           BOOLEAN := TRUE;
    --
    skip_serial              EXCEPTION;
    skip_txn                 EXCEPTION;
    comp_error               EXCEPTION;
    process_next             EXCEPTION;
    --
    l_error_message          VARCHAR2(2000);
    l_msg_data               VARCHAR2(2000);
    l_msg_count              NUMBER;
    l_return_status          VARCHAR2(1);
    --
    l_skip_error             VARCHAR2(2000);
    l_instance_rec           csi_datastructures_pub.instance_rec;
    l_exists                 VARCHAR2(1);
    serial_exists            VARCHAR2(1);
    l_error_count            NUMBER := 0;
    l_count                  NUMBER := 0;
    inst_exists              VARCHAR2(1);
    v_mast_org_id            NUMBER;
    v_nl_trackable           VARCHAR2(1);
    Error_text               VARCHAR2(200);
    l_inst_count             NUMBER := 0;
    --

  BEGIN

  debug('start of the IB_INV_Disc program for Serialized items..');

    --
    FOR srl_rec IN srl_cur
    LOOP

      BEGIN

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

      -- Get the Master Organization ID
         BEGIN
            SELECT master_organization_id
            INTO   v_mast_org_id
            FROM   MTL_PARAMETERS
            WHERE  organization_id = srl_rec.organization_id;
         EXCEPTION
            WHEN no_data_found THEN
		    RAISE Skip_serial;
	     END;

      -- Check for IB trackable
	     v_nl_trackable := 'N';
	     BEGIN
            SELECT comms_nl_trackable_flag
            INTO   v_nl_trackable
            FROM   MTL_SYSTEM_ITEMS
            WHERE  inventory_item_id = srl_rec.inventory_item_id
            AND    organization_id   = v_mast_org_id;
         EXCEPTION
	        WHEN no_data_found THEN
             RAISE Skip_serial;
         END;
/*
      -- If trackable_flag is 'N' in INV, check whether you have any corresponding
      -- instance in IB
         IF v_nl_trackable = 'N' THEN

            BEGIN
             SELECT count(1)
             INTO   l_inst_count
             FROM   CSI_ITEM_INSTANCES
             WHERE  inventory_item_id = srl_rec.inventory_item_id
             AND    ((active_end_date IS NULL) OR (active_end_date > 'SYSDATE'))
             AND    ROWNUM < 2;
            EXCEPTION
             WHEN no_data_found THEN
                v_nl_trackable := 'N';
            END;
         END IF;
         --
          --
          IF nvl(l_inst_count,0) > 0
          THEN
            Error_text := 'IB has instances having comms_nl_trackable_flag set to N in item definition';
          ELSE
            Error_text := '';
          END IF;
*/          --

        -- Ignore if not Trackable
--        IF NVL(v_nl_trackable,'N') <> 'Y' THEN
--            Raise Skip_serial;
-- 	    END IF; -- nl_trackable check
        --
        -- Check if there are any instances for item-serial combination
        --
        BEGIN
          SELECT instance_id ,
                 object_version_number
          INTO   l_instance_rec.instance_id,
                 l_instance_rec.object_version_number
          FROM   CSI_ITEM_INSTANCES
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
            Raise skip_serial;
        END;
        --
        -- get the item name
        --
        BEGIN
          SELECT concatenated_segments
          INTO   v_item_name
          FROM   MTL_SYSTEM_ITEMS_KFV
          WHERE  inventory_item_id = srl_rec.inventory_item_id
          AND    organization_id   = srl_rec.organization_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
          WHEN Others THEN
            Raise skip_serial;
        END;
        --
        --
        -- Initialize the IB variables
        --
        l_vld_organization_id    := NULL;
        l_inventory_item_id      := NULL;
        l_inv_organization_id    := NULL;
        l_inv_subinventory_name  := NULL;
        l_inventory_revision     := NULL;
        l_inv_locator_id         := NULL;
        l_location_type_code     := NULL;
        l_instance_usage_code    := NULL;
        l_location_id            := NULL;
        l_lot_number             := NULL;
        l_serial_number          := NULL;
        l_quantity               := NULL;
        --
        --
        IF l_instance_found THEN
        -- check if the instance inv location attributes are the same as the serial attribute
          l_not_the_same := not_the_same(l_instance_rec);
        END IF;

        -- fixable candidates  (no serial found or not the same)
        IF l_not_the_same  --OR NOT(l_instance_found)
        THEN

           IF l_instance_rec.instance_id IS NOT NULL
           THEN
            --dbms_output.put_line('instance_id'||l_instance_rec.instance_id);
            SELECT last_vld_organization_id,
                   inventory_item_id,
                   inv_organization_id,
                   inv_subinventory_name,
                   inventory_revision,
                   inv_locator_id,
                   location_type_code,
                   instance_usage_code,
                   location_id,
                   lot_number,
                   serial_number,
                   quantity
            INTO   l_vld_organization_id,
                   l_inventory_item_id,
                   l_inv_organization_id,
                   l_inv_subinventory_name,
                   l_inventory_revision,
                   l_inv_locator_id,
                   l_location_type_code,
                   l_instance_usage_code,
                   l_location_id,
                   l_lot_number,
                   l_serial_number,
                   l_quantity
            FROM   CSI_ITEM_INSTANCES
            WHERE  instance_id = l_instance_rec.instance_id;
           END IF;

           -- Check for any inv material transactions in csi_txn_errors with status of ('E','R')
           FOR all_txn IN ALL_TXN_CUR(srl_rec.serial_number,
                                      srl_rec.inventory_item_id,
                                      srl_rec.lot_code)
           LOOP
                --dbms_output.put_line(substr('Value of all_txn.mtl_txn_id='||all_txn.mtl_txn_id,1,255));
                l_error_count := 0;
                -- Check if there are any errors in CSI_TXN_ERRORS
                BEGIN
                     SELECT COUNT(*)
                     INTO   l_error_count
                     FROM   CSI_TXN_ERRORS csi
                     WHERE  csi.inv_material_transaction_id IS NOT NULL
                     AND    csi.inv_material_transaction_id = all_txn.mtl_txn_id
                     AND    csi.processed_flag IN ('E','R');
                END;
                --
                IF nvl(l_error_count,0) > 0 THEN
                  Exit;
                END IF;

                -- Check whether there are any pending transactions in SFM Queue
                IF l_error_count = 0 THEN
                   debug('there are no error txns in csi_txn_errors');
                   l_count := 0;
                   BEGIN
                     SELECT COUNT(*)
                     INTO   l_error_count
                     FROM   CSI_XNP_MSGS_TEMP xnp
                     WHERE  xnp.source_id IS NOT NULL
                     AND    xnp.source_id = all_txn.mtl_txn_id
                     AND    xnp.source_type = 'MTL_TRANSACTION_ID'
                     AND    nvl(xnp.msg_status, 'READY') <> 'PROCESSED';
                   END;
                END IF;
                --
                IF nvl(l_error_count, 0) > 0 THEN
                   Exit;
                END IF;
                --
            END LOOP; -- end loop for FOR all_txn IN ALL_TXN_CUR
            --

            -- Dump the discrepancies into a temporary table
            IF l_error_count = 0
            THEN
              IF NVL(v_nl_trackable, 'N') <> 'Y'
              THEN

               BEGIN

                    INSERT INTO CSI_INV_DISCREPANCY_TEMP
                          (
                           discrepancy_id
                          ,inventory_item_id
                          ,serial_number
                          ,inv_revision
                          ,inv_lot_number
                          ,inv_quantity
                          ,inv_organization_id
                          ,inv_subinventory_name
                          ,inv_locator_id
                          ,instance_id
                          ,ii_revision
                          ,ii_lot_number
                          ,ii_quantity
                          ,ii_organization_id
                          ,ii_subinventory_name
                          ,ii_locator_id
                          ,ii_location_type_code
                          ,instance_usage_code
                          ,master_org_trackable_flag
                          ,child_org_trackable_flag
                          )
                          VALUES
                          (
                           csi_inv_discrepency_temp_s.Nextval
                          ,l_instance_rec.inventory_item_id
                          ,l_instance_rec.serial_number
                          ,l_instance_rec.inventory_revision
                          ,l_instance_rec.lot_number
                          ,l_instance_rec.quantity
                          ,l_instance_rec.inv_organization_id
                          ,l_instance_rec.inv_subinventory_name
                          ,l_instance_rec.inv_locator_id
                          ,l_instance_rec.instance_id
                          ,l_inventory_revision
                          ,l_lot_number
                          ,l_quantity
                          ,l_inv_organization_id
                          ,l_inv_subinventory_name
                          ,l_inv_locator_id
                          ,l_location_type_code
                          ,l_instance_usage_code
                          ,v_nl_trackable
                          ,v_nl_trackable
                          );

                 EXCEPTION
                  WHEN OTHERS THEN
                    v_err_msg := 'Unable to Insert a record into the CSI_INV_DISCREPENCY_TEMP table'||SUBSTR(sqlerrm,1,1000);
                    NULL;
                 END; -- end of insert into ib_inv_sync table
                 --
               END IF;
               --
             END IF; -- end if for l_error_count = 0
             --

        END IF; -- end if for l_not_the_same
        --
      EXCEPTION
        WHEN skip_serial THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END;
      --
      IF mod(srl_cur%rowcount,100) = 0 THEN
        COMMIT;
      END IF;
      --
    END LOOP; -- end loop for FOR srl_rec IN srl_cur
  EXCEPTION
      WHEN comp_error THEN
       NULL;
  END IB_INV_Disc_serials;
  --
  --
  --
  --
  -- PROCEDURE GET_REPORT_CLOB
  --   This procedure will retrieve the Report output file from the OS and
  --   embed it into the body of an email.
  --   This requires creating a DOCUMENT Message Attribute with the default value:
  --
  --      plsqlclob:RM_SEND_REPORT.GET_REPORT_CLOB/REQ_ID
  --
  --   where REQ_ID is the internal name of the Message Attribute which points
  --   to the item attribute containing the Request Id.
  --
  --   This function would be used in conjunction with the
  --   FND_WF_STANDARD.EXECUTECONCPROG which will execute a concurrent request
  --   and return the Result of 'Normal', 'Cancelled', 'Warning', 'Terminated',
  --   or 'Error'
  --
  --   We will query the request and embed the OUTPUT if it is 'Normal', otherwise
  --   we output the request LOG.
  --
  --   To get the access of the file you must create a db directory for this with the
  --   following commands where the REPORT_OUT directory is $APPLCSF/$APPLOUT and
  --   REPORT_LOG directory = $APPLCSF/$APPLLOG or applicable directories:
  --
  --      create directory REPORT_OUT as '/vis11i/common/admin/out';
  --      create directory REPORT_LOG as '/vis11i/common/admin/log';
  --      connect sys/<syspwd>@<SID>
  --      grant read on directory REPORT_OUT to APPS;
  --      grant read on directory REPORT_LOG to APPS;

  --
  -- Procedure that gets the report output file located on the middle tier/or from the server
  --
  PROCEDURE GET_REPORT_CLOB ( document_id	  in	  varchar2,
                              display_type    in	  varchar2,
                              document	      in out nocopy  clob,
                              document_type   in out nocopy  varchar2)
  IS

  l_item_type      wf_items.item_type%TYPE;
  l_item_key       wf_items.item_key%TYPE;

  l_document_type  VARCHAR2(25);
  l_document       VARCHAR2(32000) := '';

  NL               VARCHAR2(1) := fnd_global.newline;
  l_header_id      number;
  l_file           varchar2(100);
  l_amt            number;
  l_pos            number;

  p_filedir        varchar2(100);
  p_filename       varchar2(100);
  l_theBFILE       BFILE;
  l_theCLOB        CLOB;
  l_total_bytes    number;
  l_exists         INTEGER;
  l_open           INTEGER;
  l_req_id         varchar2(100);
  l_comp_stat      varchar2(1);

  v_Buffer VARCHAR2(80);
  v_Offset INTEGER := 1;
  v_Amount INTEGER := 80;



  BEGIN

--  l_file := oe_debug_pub.set_debug_mode('FILE');
  --dbms_output.put_line('inside get_report_clob');

  dbms_lob.createtemporary(l_theCLOB, TRUE, DBMS_LOB.session);

  debug('Inside CSI_SEND_REPORT.GET_REPORT_CLOB');
  debug('document_id = ' || document_id);

  -- Get the current status of the Report concurrent request
  select STATUS_CODE
  into l_comp_stat
  from fnd_concurrent_requests
  where request_id = to_number(document_id);

  debug('l_comp_stat = ' || l_comp_stat);
  --dbms_output.put_line('Value of l_comp_stat='||l_comp_stat);
  -- If completion status = C then attempt to get the OUTPUT of report
  if l_comp_stat = 'C' then
     p_filedir := 'REPORT_OUT';
     p_filename := 'o'||document_id|| '.out';
     --dbms_output.put_line('Value of p_filename='||TO_CHAR(p_filename));
     --debug('p_filedir = ' || p_filedir);
     debug('p_filename = ' || p_filename);

     -- Set the BFILE Directory and FileName
     l_theBFILE := BFileName(p_filedir,p_filename);

     -- First make certain the requested file exists
     l_exists := dbms_lob.fileexists(l_theBFILE);

     -- If the OUTPUT file does not exist then Try the Log File
     if l_exists = 0 then

        -- reset the l_comp_stat to 'F' so we will look for the log file in the next if statement
        l_comp_stat := 'F';
        l_document := 'OUTPUT file does not exists for request id, '|| document_id ||'.  Attempting to retrieve log file.';
        l_pos := dbms_lob.getlength(document) + 1;
        l_amt := length(l_document);
        dbms_lob.write(document,l_amt,l_pos,l_document);

     end if; --l_exists = 0 then (OUTPUT FILE)
  end if; -- l_comp_stat = 'C'

  -- If completion status <> C then attempt to get the LOG of report
  if l_comp_stat <> 'C' then
     p_filedir := 'REPORT_LOG';
     p_filename := 'l'||document_id|| '.req';

     --debug('p_filedir = ' || p_filedir);
     debug('p_filename = ' || p_filename);

     -- Set the BFILE Directory and FileName
     l_theBFILE := BFileName(p_filedir,p_filename);

     -- First make certain the requested file exists
     l_exists := dbms_lob.fileexists(l_theBFILE);

     -- If the OUTPUT file does not exist then Try the Log File
     if l_exists = 0 then

        l_document := 'Neither an OUTPUT or LOG file exists for request id, '|| document_id;
        l_pos := dbms_lob.getlength(document) + 1;
        l_amt := length(l_document);
        dbms_lob.write(document,l_amt,l_pos,l_document);

     end if; --l_exists = 0 then (LOG FILE)
  end if; -- l_comp_stat <>  'C'

  -- Send the OUTPUT or LOG to the notification body if the file exists
  if l_exists = 1 then

     -- to see if the file was opened using the input BFILE locators
     l_open := dbms_lob.FILEISOPEN(l_theBFILE);

     if l_open = 1 then
       -- File is already open so ignore
       null;
       debug('File already opened');
     else
       -- Open the file
       dbms_lob.fileOpen(l_theBFILE);
           debug('Opened LOG File');
     end if; -- l_open = 1
     -- Read the LOG file into the CLOB;
     dbms_lob.loadFromFile(dest_lob => l_theCLOB,
                           src_lob  => l_theBFILE,
                           amount   => dbms_lob.getLength(l_theBFILE));

     l_total_bytes:=dbms_lob.getLength(l_theCLOB);

     if (display_type = 'text/html') then
        debug('Inside the text/html');

        l_document := '<br>' || '<br> <pre>' ;
        l_document := l_document || '<font face="courier new" size=2>';

        l_pos := dbms_lob.getlength(document) + 1;
        l_amt := length(l_document);
        dbms_lob.write(document,l_amt,l_pos,l_document);

        -- Now append l_theCLOB (report) to the document;
        dbms_lob.append(document, l_theCLOB);

        -- Append a few breaks on the end;
        l_document :=  '<br>' || '<br> </pre>';

        l_pos := dbms_lob.getlength(document) + 1;
        l_amt := length(l_document);
        dbms_lob.write(document,l_amt,l_pos,l_document);

        --Close the file handle
        dbms_lob.fileClose(l_theBFILE);

      elsif (display_type = 'text/plain') then

        debug('Inside the text/plain');
        -- Append l_theCLOB (report) to the document;
        dbms_lob.APPEND(document, l_theCLOB);

       --Close the file handle
        dbms_lob.fileClose(l_theBFILE);

      end if; --(display_type = 'text/html')

   end if; -- File exists(l_exists = 1)

  END GET_REPORT_CLOB;
  --
  --
  --This procedure is to launch a workflow process
  --
  PROCEDURE Launch_Workflow (p_msg    IN VARCHAR2,
                             p_req_id IN NUMBER)
  IS

  --Workflow attributes
        l_itemtype                  Varchar2(40)  := 'CSIINVWF';
        l_itemkey                   Varchar2(240) := 'CSI-'||to_char(sysdate,'MMDDYYYYHH24MISS');
        l_process                   Varchar2(40)  := 'CSIIBINVWF';
        l_notify                    Varchar2(10)  := 'Y';
        l_receiver                  Varchar2(100);
        l_itemkey_seq               Integer ;

  BEGIN
       -- Recipient is derived from profile option
       -- l_receiver := Fnd_Profile.Value ('CSI_INTEGRATION_NOTIFY_TO');

       -- IF l_receiver IS NULL THEN
       --   l_receiver := 'Oracle Installed Base Admin';
       -- END IF;

        -- Sequence generation which will be used for item uniqueness
        Select CSI_WF_ITEM_KEY_NUMBER_S.Nextval
        Into   l_itemkey_seq
        From   dual;

        l_itemkey := 'CSI-'||l_itemkey_seq;

           WF_ENGINE.CreateProcess
           (
                itemtype        => l_itemtype,
                itemkey         => l_itemkey,
                process         => l_process
           );

           WF_ENGINE.SetItemAttrText
           (
                itemtype        => l_itemtype,
                itemkey         => l_itemkey,
                aname           => '#FROM_ROLE',
                avalue          => 'Oracle Installed Base Admin'
           );

           WF_ENGINE.SetItemAttrText
           (
                itemtype        => l_itemtype,
                itemkey         => l_itemkey,
                aname           => 'CSI_TEXT',
                avalue          => p_msg
           );

           WF_ENGINE.SetItemAttrText
           (
                itemtype        => l_itemtype,
                itemkey         => l_itemkey,
                aname           => 'REQ_ID',
                avalue          => p_req_id
           );

           WF_ENGINE.SetItemAttrText
           (
                itemtype        => l_itemtype,
                itemkey         => l_itemkey,
                aname           => 'CSI_RECV',
                avalue          => 'Oracle Installed Base Admin'
           );

           WF_ENGINE.StartProcess
           (
                itemtype        => l_itemtype,
                itemkey         => l_itemkey
           );


  END;

  --
  -- This procedure is called from the concurrent prog.
  --
  PROCEDURE IB_INV_DISCREPANCY( errbuf  OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER ) IS

     l_count        NUMBER;
     l_disc_count   NUMBER;
     l_exists       VARCHAR2(1);
     l_errbuf       VARCHAR2(2000);
     NL             VARCHAR2(1) := fnd_global.newline;
     l_request_id   NUMBER;

     l_schema_name   varchar2(30);
     l_object_name   varchar2(80);
     l_return_status varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
     --
     -- Empty the discrepancy table before each run
     --
     get_schema_name(
       p_product_short_name  => 'CSI',
       x_schema_name         => l_schema_name,
       x_return_status       => l_return_status);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
       RAISE fnd_api.g_exc_error;
     END IF;

     l_object_name := l_schema_name||'.csi_inv_discrepancy_temp';

     -- Empty the discrepancy table before each run
     truncate_table(l_object_name);
     --
     -- Call the Non-Serialized discrepancy procedure
     --
     debug( 'Calling IB_INV_Disc_Non_srl : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     CSI_INV_DISCREPANCY_PKG.IB_Inv_Disc_Non_srl;
     --
     -- Call the Serialized discrepancy procedure
     --
     debug( 'Calling IB_INV_Disc_serials : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     CSI_INV_DISCREPANCY_PKG.IB_Inv_Disc_serials;
     --
     --Check if there are any discrepancies recorded in the discrepancy table
     --
     BEGIN
       SELECT count(*)
       INTO   l_disc_count
       FROM   CSI_INV_DISCREPANCY_TEMP;
     END;
     --
     -- If there are any data discrepancies between IB and INV then display the report
     --

     IF l_disc_count > 0
     THEN
            l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIINVDR',
                                           start_time     =>  NULL,
                                           sub_request    =>  FALSE);

            debug('Calling Install Base and Inventory Discrepancy Report...');
            debug('Request ID: '||l_request_id||' has been submitted');
            debug('');
            COMMIT; -- this commit is the concurrent request in the fnd_concurrent_requests for parallel

              IF l_request_id = 0
              THEN
                 FND_MESSAGE.RETRIEVE(l_errbuf);
                 debug('IB - INV Discrepancy Report has errored');
                 debug('Error message   :'||substr(l_errbuf,1,75));
                 debug(' :'||substr(l_errbuf,76,150));
                 debug(' :'||substr(l_errbuf,151,225));
                 debug(' :'||substr(l_errbuf,226,300));
              ELSE
                 debug('IB - INV Discrepancy Report completed successfully');
              END IF;

       --If there are any data discrepancies between IB and INV then send a
       --notification to the concerned personnel
       --
       --Launch the workflow to send a notification to the end user in case of discrepancies
       --between IB and INV

       Launch_Workflow( ''|| fnd_global.local_chr(10) ||
                   'Hello Install Base User, '|| fnd_global.local_chr(10)||
                   ''||fnd_global.local_chr(10)||
                   'Installed Base has detected that there are some discrepancies in the data between ' || --fnd_global.local_chr(10) ||
                   'Installed Base and Inventory. For more information on these discrepancies please '|| --fnd_global.local_chr(10) ||
                   'see the IB - INV Discrepancy Report.'||fnd_global.local_chr(10)||
                   ''||fnd_global.local_chr(10)||
                   'The details of the report output can be viewed in the concurrent request output' ||
                   'under the Oracle Installed Base Admin responsibility. Query  for the following' ||
                   'Concurrent Request Id:    '||l_request_id ||
                   ''||fnd_global.local_chr(10)||
                   ''||fnd_global.local_chr(10)||
                   ''||fnd_global.local_chr(10)||
                   'Thank You'|| fnd_global.local_chr(10) ||
                   ''||fnd_global.local_chr(10)||
                   'Oracle Install Base', l_request_id);

     END IF;

     --
  END IB_INV_DISCREPANCY;
  --




END CSI_INV_DISCREPANCY_PKG;
--

/
