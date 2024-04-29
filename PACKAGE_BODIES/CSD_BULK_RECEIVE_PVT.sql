--------------------------------------------------------
--  DDL for Package Body CSD_BULK_RECEIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_BULK_RECEIVE_PVT" AS
/* $Header: csdvbrvb.pls 120.17.12010000.6 2009/10/14 04:44:02 subhat ship $ */

/*-----------------------------------------------------------------*/
/* procedure name: process_bulk_receive_items                      */
/* description   : Concurrent program to Bulk Receive Items        */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE process_bulk_receive_items
(
  errbuf                OUT    NOCOPY    VARCHAR2,
  retcode               OUT    NOCOPY    VARCHAR2,
  p_transaction_number  IN     NUMBER
)

IS

  -- Cursor to validate IB Owner and the Bulk Receive Party
  Cursor c_set_party(p_transaction_number in number) is
  Select *
  from csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and incident_id is null
  and repair_line_id is null
  and internal_sr_flag = 'N'
  and change_owner_flag = 'N'
  and status  = 'NEW';

  -- Cursor to Change owner
  Cursor c_change_owner(p_transaction_number in number) is
  select *
  from csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and  status in ('NEW','ERRORED')
  and  change_owner_flag = 'Y'
  and  party_id is null
  and  internal_sr_flag = 'N';

  -- Cursor to Create Internal SR's
  Cursor c_create_intr_sr(p_transaction_number in number) is
  select *
  from csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and  status in ('NEW','ERRORED')
  and  incident_id is null
  and  internal_sr_flag = 'Y';

  -- Cursor to get internal party
  Cursor c_get_intr_party is
  select csi.internal_party_id,
         hca.cust_account_id
  from csi_install_parameters csi,
       hz_cust_accounts hca
  where csi.internal_party_id = hca.party_id(+)
  and   hca.status(+) = 'A';

  -- Cursor to Create SR
  Cursor c_create_sr (p_transaction_number in number) is
  select distinct party_id,cust_account_id
  from csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and   status in ('NEW','ERRORED')
  and  incident_id is null
  and  party_id is not null
  and  internal_sr_flag = 'N';

  -- Cursor to Create New RO only
  Cursor c_create_ro (p_transaction_number in number,p_incident_id in number) is
  select *
  from  csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and   incident_id = p_incident_id
  and   repair_line_id is null
  and   internal_sr_flag = 'N';

  -- Cursor to reprocess the errored RO's
  Cursor c_reprocess_ro (p_transaction_number in number) is
  select *
  from  csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and   status = 'ERRORED'
  and   incident_id is not null
  and   repair_line_id is null
  and   internal_sr_flag = 'N';

  -- Cursor to Auto Receive
  Cursor c_auto_receive (p_transaction in number) is
  select *
  from csd_bulk_receive_items_b
  where transaction_number = p_transaction_number
  and status in ('NEW','ERRORED')
  and repair_line_id is not null
  and internal_sr_flag = 'N';

  -- Cursor to check the order status
  Cursor c_check_prdtxn_status(p_repair_line_id in number) is
  select  dpt.prod_txn_status,
          edt.order_line_id,
	     edt.order_header_id,
	     dpt.source_serial_number
  from    csd_product_transactions dpt,
 		cs_estimate_details edt
  where   dpt.repair_line_id = p_repair_line_id
  and     dpt.action_type = 'RMA'
  and     dpt.prod_txn_status = 'BOOKED'
  and     dpt.estimate_detail_id = edt.estimate_detail_id
  and     edt.source_code = 'DR';
  -- commented out old query due to performance bug 4997501
  -- select prod_txn_status,
  --       order_line_id,
  --       order_header_id,
  --       source_serial_number
  -- from csd_product_txns_v
  -- where repair_line_id = p_repair_line_id
  -- and action_type = 'RMA'
  -- and prod_txn_status = 'BOOKED';

  -- Cursor to get item attributes
  Cursor c_get_item_attributes (p_inventory_item_id in number) is
  Select comms_nl_trackable_flag,
         concatenated_segments,
         serial_number_control_code
  from mtl_system_items_kfv
  where inventory_item_id = p_inventory_item_id
  and organization_id = cs_std.get_item_valdn_orgzn_id;

  -- Cursor to get owner
  Cursor c_get_ib_owner ( p_inventory_item_id in number,p_serial_number in varchar2) is
  Select owner_party_id,
         owner_party_account_id
  from csi_item_instances
  where inventory_item_id = p_inventory_item_id
  and serial_number = p_serial_number;

  -- Cursor to get Warning Reason Desc
  Cursor c_get_warning_desc( p_warning_code in varchar2) is
  Select description
  from fnd_lookup_values_vl
  where lookup_type = 'CSD_BULK_RECEIVE_WARNINGS'
  and lookup_code = p_warning_code
  and enabled_flag = 'Y'
  and trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
      and trunc(nvl(end_date_active,sysdate));

  -- Used for standard concurrent program parameter 'retcode' value
  c_success         CONSTANT NUMBER := 0;
  c_warning         CONSTANT NUMBER := 1;
  c_error           CONSTANT NUMBER := 2;


  -- Local variables
  l_incident_id          Number;
  l_incident_number      Varchar2(64);
  l_repair_line_id       Number;
  l_repair_number        Varchar2(30);
  l_return_status        Varchar2(1);
  l_ro_error_count       Number;
  l_msg_count            Number;
  l_msg_data             Varchar2(2000);
  l_sr_bulk_receive_rec  csd_bulk_receive_util.bulk_receive_rec;
  l_ro_status            Varchar2(30);
  l_c_create_ro_rowcount Number;
  l_order_status         Varchar2(30);
  l_intr_party_id        Number;
  i                      Number;
  l_ib_owner_id          Number;
  l_ib_owner_acct_id     Number;
  l_ib_flag              Varchar2(1);
  l_intr_sr_notes_table  cs_servicerequest_pub.notes_table;
  l_sr_notes_table       cs_servicerequest_pub.notes_table;
  l_bulk_autorcv_tbl     csd_bulk_receive_util.bulk_autorcv_tbl;
  l_procedure_name       Varchar2(30) := 'csd_bulk_receive_items_pvt';
  l_create_intr_sr       Boolean;
  l_intr_cust_acct_id    Number;
  l_warning_desc         Varchar2(240);
  l_order_line_id        Number;
  l_order_header_id      Number;
  l_serial_label         Varchar2(30);
  l_item_label           Varchar2(30);
  l_qty_label            Varchar2(30);
  l_note_details         Varchar2(2000);
  l_item_name            Varchar2(40);
  l_source_serial_number Varchar2(30);
  c_non_serialized       CONSTANT Number := 1;
  l_serial_number_control_code Number;
  -- swai: 12.1.1 bug 7176940 service bulletin check
  l_ro_sc_ids_tbl CSD_RO_BULLETINS_PVT.CSD_RO_SC_IDS_TBL_TYPE;

  -- subhat: 12.1.2 BR ER FP changes
  x_sr_ro_rma_tbl CSD_BULK_RECEIVE_UTIL.sr_ro_rma_tbl;
  l_create_sr_flag VARCHAR2(3) := 'Y';
  l_counter    number := 0;
  g_ret_sts_success varchar2(3) := FND_API.G_RET_STS_SUCCESS;
  l_prod_txn_rec csd_process_pvt.product_txn_rec;
  l_msg_index_out NUMBER;
  l_req_data varchar2(30);
  x number;
  l_continue_further boolean := true;

BEGIN

  -- check if the program run is the first one or not. If the program run is not first run
  -- then exit immediately - Child Request submission changes, subhat.
  -- before exiting, we also need to make sure that the child request is offcourse completed,
  -- and then need to run the post receive steps.

  l_req_data := fnd_conc_global.request_data;

  if l_req_data is not null then
  	x := to_number(l_req_data);
  	if x > 0 then
  		errbuf := 'Done';
  		retcode := 0;
  		-- carry out post receipt processing.
  	   csd_bulk_receive_util.after_receipt(p_request_group_id => x,
  	   									   p_transaction_number => p_transaction_number);
  		-- lets write the output and then return.
  		csd_bulk_receive_util.write_to_conc_output
		( p_transaction_number => p_transaction_number);
  		return;
  	end if;
  else
  	x := 1;
  end if;

  --
  -- Logic  Summary
  -- All the following steps are executed for a
  -- particular Transaction Number.
  --
  -- A.If Profile 'CSD_BLKRCV_CHG_IB_OWNER' is 'NO'
  --   then set the Party id of the Bulk Receive Rec
  --   to the IB Owner Party
  -- B.Update IB Owner.
  -- C.Create Internal SR for warning records.
  -- D.Reprocess errored Repair Orders and create Logistic
  --   lines.
  -- E.Create Service Request,Repair Order, Logistic lines
  --   for new records.
  -- F.Auto Receive all the eligible records.
  --

  savepoint process_bulk_receive_items;

  --
  -- MOAC initialization
  --
  MO_GLOBAL.init('CS_CHARGES');

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS.BEGIN',
                    'Entered Process Bulk Receive Items');
  End if;

  -- Verify the required parameter - Transaction Number
  If ( p_transaction_number is null ) then

    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_event,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                      'Validate Transaction Number');
    End if;

    Fnd_file.put_line(fnd_file.log,'Error: Transaction Number is null');
    retcode :=  c_error;

  End if;

  --
  -- Step - A
  -- If Profile 'CSD_BLKRCV_CHG_IB_OWNER' is 'NO'
  -- then set the Party id of the Bulk Receive Rec
  -- to the IB Owner Party
  If (fnd_profile.value('CSD_BLK_RCV_CHG_IB_OWNER') = 'N') then

    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_event,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                      'Change IB Owner Profile is No, verify Instance party and Entered Party');
    End if;

    For c_set_party_rec in c_set_party ( p_transaction_number)
    Loop

      If ( c_set_party_rec.inventory_item_id is not null ) then

        l_ib_flag   := null;
        l_item_name := null;
        l_serial_number_control_code := null;

        Open c_get_item_attributes(c_set_party_rec.inventory_item_id);
        Fetch c_get_item_attributes into l_ib_flag,l_item_name,l_serial_number_control_code;
        Close c_get_item_attributes;

        -- If Install base item then verify the IB Owner
        If ( l_ib_flag = 'Y' ) then

          l_ib_owner_id      := null;
          l_ib_owner_acct_id := null;

          Open c_get_ib_owner (c_set_party_rec.inventory_item_id,
                               c_set_party_rec.serial_number);
          Fetch c_get_ib_owner into l_ib_owner_id,l_ib_owner_acct_id;
          Close c_get_ib_owner;

          -- If the IB Owner is <> Entered Party then update the
          -- Bulk Receive Party = IB Owner
          If ( l_ib_owner_id <> c_set_party_rec.party_id) then

            If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_statement,
	                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
	                    'Update: bulk_receive_id[' || c_set_party_rec.bulk_receive_id ||
	                    '] with IB owner party id - '||l_ib_owner_id);
            End if;

            Update csd_bulk_receive_items_b
            set party_id = l_ib_owner_id,
                cust_account_id = l_ib_owner_acct_id
            where bulk_receive_id = c_set_party_rec.bulk_receive_id;
          End if;

        End if;

      End if; -- End if of the inventory item id null check

    End Loop;

  End if;

  --
  -- Step - B
  -- Change IB owner for records which have IB owner different
  -- from the entered Party/Account
  --
  If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_event,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Change IB Owner');
  End if;

  For c_change_owner_rec in c_change_owner (p_transaction_number)
  Loop

    Savepoint change_ib_owner;

    csd_bulk_receive_util.change_blkrcv_ib_owner
    (
     p_bulk_receive_id => c_change_owner_rec.bulk_receive_id,
     x_return_status   => l_return_status,
     x_msg_count       => l_msg_count,
     x_msg_data        => l_msg_data
    );

    If (l_return_status = FND_API.G_RET_STS_SUCCESS) then

      If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.STRING (fnd_log.level_statement,
	              'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
	              'Change IB owner,Update : bulk_receive_id['
	               || c_change_owner_rec.bulk_receive_id ||
	              '] party id with orig party id');
      End if;

      Update csd_bulk_receive_items_b
      set party_id = orig_party_id
         ,cust_account_id = orig_cust_account_id
         ,status = 'NEW'
      where bulk_receive_id = c_change_owner_rec.bulk_receive_id;

    Else

      Rollback to change_ib_owner;

      -- Write to conc log
      Fnd_file.put_line(fnd_file.log,'Error: IB Change Owner failed');
      Fnd_file.put(fnd_file.log,'Serial Number :'||c_change_owner_rec.serial_number||',');
      Fnd_file.put(fnd_file.log,'Inventory Item id :'||c_change_owner_rec.inventory_item_id||',');
      Fnd_file.put(fnd_file.log,'Qty :'||c_change_owner_rec.quantity||',');
      Fnd_file.put_line(fnd_file.log,'New Party Id :'||c_change_owner_rec.orig_party_id);

      csd_bulk_receive_util.write_to_conc_log
        ( p_msg_count  => l_msg_count,
          p_msg_data   => l_msg_data);

    End If;

  End Loop;  -- End of c_change_owner_rec loop


  --
  -- Step - C
  -- Create Internal SR for Warning / Invalid records.
  -- Note is created for every Warning and is associated with
  -- the Internal SR.
  --
  i := 0;
  l_create_intr_sr := FALSE;

  fnd_message.set_name('CSD','CSD_BULK_RCV_SERIAL_CONC_LABEL');
  l_serial_label := fnd_message.get;

  fnd_message.set_name('CSD','CSD_BULK_RCV_ITEM_CONC_LABEL');
  l_item_label   := fnd_message.get;

  fnd_message.set_name('CSD','CSD_BULK_RCV_QTY_CONC_LABEL');
  l_qty_label    := fnd_message.get;

  For c_create_intr_sr_rec in c_create_intr_sr (p_transaction_number)
  Loop

    i:= i + 1;
    l_create_intr_sr := TRUE;
    l_warning_desc := null;
    l_ib_flag      := null;
    l_item_name    := null;
    l_serial_number_control_code := null;

    Open c_get_warning_desc (c_create_intr_sr_rec.warning_reason_code);
    Fetch c_get_warning_desc into l_warning_desc;
    Close c_get_warning_desc;

    Open c_get_item_attributes(c_create_intr_sr_rec.inventory_item_id);
    Fetch c_get_item_attributes into l_ib_flag,l_item_name,l_serial_number_control_code;
    Close c_get_item_attributes;

    l_note_details := ' - '||l_serial_label||' : '||c_create_intr_sr_rec.serial_number||','||
                      l_item_label||' : '||l_item_name||','||
                      l_qty_label||' : '||c_create_intr_sr_rec.quantity;

    l_intr_sr_notes_table(i).note                 := l_warning_desc;
    l_intr_sr_notes_table(i).note_detail          := l_note_details;
    l_intr_sr_notes_table(i).note_type            := 'CS_PROBLEM';
    l_intr_sr_notes_table(i).note_context_type_01 := 'CS';

  End Loop;


  If ( l_create_intr_sr ) then
    -- Call the Create Service Request API
    Savepoint create_intr_sr_savepoint;

    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
        fnd_log.STRING (fnd_log.level_event,
                        'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                        'Create Internal SR');
    End if;

    l_intr_party_id     := null;
    l_intr_cust_acct_id := null;

    Open c_get_intr_party;
    Fetch c_get_intr_party into l_intr_party_id,l_intr_cust_acct_id;
    Close c_get_intr_party;

    l_sr_bulk_receive_rec.party_id        := l_intr_party_id;
    l_sr_bulk_receive_rec.cust_account_id := l_intr_cust_acct_id;

    csd_bulk_receive_util.create_blkrcv_sr
      (
        p_bulk_receive_rec  => l_sr_bulk_receive_rec,
        p_sr_notes_tbl      => l_intr_sr_notes_table,
        x_incident_id       => l_incident_id,
        x_incident_number   => l_incident_number,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data
      );

    If (l_return_status = FND_API.G_RET_STS_SUCCESS) then

      If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.STRING (fnd_log.level_statement,
     	              'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
     	              'Created Internal SR : Incident id = '
     	               ||l_incident_id );
      End if;

      Update csd_bulk_receive_items_b
      set incident_id = l_incident_id,
          status = 'PROCESSED',
          party_id = l_intr_party_id,
          cust_account_id = l_intr_cust_acct_id
      where transaction_number = p_transaction_number
      and incident_id is null
      and internal_sr_flag = 'Y';

    Else

      Rollback To create_intr_sr_savepoint;

      Update csd_bulk_receive_items_b
      set status = 'ERRORED'
      where transaction_number = p_transaction_number
      and incident_id is null
      and internal_sr_flag = 'Y';

      -- Write to Conc Log
      Fnd_file.put_line(fnd_file.log,'Error: Creation of Internal Service Request failed');
      Fnd_file.put_line(fnd_file.log,'Internal party id :'||l_intr_party_id);

      csd_bulk_receive_util.write_to_conc_log
        ( p_msg_count  => l_msg_count,
          p_msg_data   => l_msg_data);

    End if;
  End if;


  --
  -- Step - D
  -- To Reprocess Errored RO's
  --
  If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_event,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                   'Check and reprocess Errored Repair Orders');
  End if;

  For c_reprocess_ro_rec in c_reprocess_ro(p_transaction_number)
  Loop

    Savepoint reprocess_ro_savepoint;

    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
        fnd_log.STRING (fnd_log.level_event,
                       'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                       'Reprocess RO - Call Create Repair Orders');
    End if;

    -- Call Create RO Helper procedure
    csd_bulk_receive_util.create_blkrcv_ro
    (
      p_bulk_receive_id  => c_reprocess_ro_rec.bulk_receive_id,
      x_repair_line_id   => l_repair_line_id,
      x_repair_number    => l_repair_number,
      x_return_status    => l_return_status,
      x_ro_status        => l_ro_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data
    );

    If (l_return_status = FND_API.G_RET_STS_SUCCESS) then

      -- If RO is created in Draft status then
      -- no Logistic lines are created

      If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.STRING (fnd_log.level_statement,
                     'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                     'Reprocess RO - Created Repair Order ['||l_repair_line_id||'] in '
     	              ||l_ro_status||' status' );
      End if;

      If ( l_ro_status = 'DRAFT' ) then

        Update csd_bulk_receive_items_b
        set repair_line_id = l_repair_line_id,
            status = 'PROCESSED'
        where bulk_receive_id = c_reprocess_ro_rec.bulk_receive_id;

      Else

        -- Update the Bulk Receive Record
        Update csd_bulk_receive_items_b
        set repair_line_id = l_repair_line_id,
            status = 'NEW'
        where bulk_receive_id = c_reprocess_ro_rec.bulk_receive_id;

        -- Call the create default product transaction

	If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
	  fnd_log.STRING (fnd_log.level_event,
	                  'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
	                  'Reprocess RO - Call Create Product Transactions');
        End if;

        csd_bulk_receive_util.create_blkrcv_default_prod_txn
	(
	  p_bulk_receive_id => c_reprocess_ro_rec.bulk_receive_id,
	  x_return_status   => l_return_status,
	  x_msg_count       => l_msg_count,
	  x_msg_data        => l_msg_data
        );

        If NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) then

          -- If Logistic line creation fails then rollback RO
    	  Rollback To reprocess_ro_savepoint;

	  Update csd_bulk_receive_items_b
	  set status = 'ERRORED'
	  where bulk_receive_id = c_reprocess_ro_rec.bulk_receive_id;

          -- Write to conc log
          Fnd_file.put_line(fnd_file.log,'Error : Creation of Default Logistic lines failed');
          Fnd_file.put(fnd_file.log,'Serial Number :'||c_reprocess_ro_rec.serial_number||',');
          Fnd_file.put(fnd_file.log,'Inventory Item Id :'||c_reprocess_ro_rec.inventory_item_id||',');
          Fnd_file.put_line(fnd_file.log,'Qty :'||c_reprocess_ro_rec.quantity);

          csd_bulk_receive_util.write_to_conc_log
          ( p_msg_count  => l_msg_count,
            p_msg_data   => l_msg_data);

        End if;

        -- swai: 12.1.1 bug 7176940 - check service bulletins after RO creation
        IF (nvl(fnd_profile.value('CSD_AUTO_CHECK_BULLETINS'),'N') = 'Y') THEN
            CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO(
               p_api_version_number         => 1.0,
               p_init_msg_list              => Fnd_Api.G_FALSE,
               p_commit                     => Fnd_Api.G_FALSE,
               p_validation_level           => Fnd_Api.G_VALID_LEVEL_FULL,
               p_repair_line_id             => l_repair_line_id,
               px_ro_sc_ids_tbl             => l_ro_sc_ids_tbl,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data
            );
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.STRING (fnd_log.level_statement,
                                     'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                                       'Reprocess RO - After CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO['
                                     || l_repair_line_id || ']');
            END IF;
            -- ignore return status for now.
        END IF;

      End if;  -- End if of status = 'DRAFT' if condition

    Else

      Rollback To reprocess_ro_savepoint;

      Update csd_bulk_receive_items_b
      set status = 'ERRORED'
      where bulk_receive_id = c_reprocess_ro_rec.bulk_receive_id;

      -- Write to conc log
      Fnd_file.put_line(fnd_file.log,'Error : Creation of Repair Order failed');
      Fnd_file.put(fnd_file.log,'Serial Number :'||c_reprocess_ro_rec.serial_number||',');
      Fnd_file.put(fnd_file.log,'Inventory Item Id :'||c_reprocess_ro_rec.inventory_item_id||',');
      Fnd_file.put_line(fnd_file.log,'Qty :'||c_reprocess_ro_rec.quantity);

      csd_bulk_receive_util.write_to_conc_log
        ( p_msg_count  => l_msg_count,
          p_msg_data   => l_msg_data);

    End if;

  End Loop; -- End of c_reprocess_ro_rec loop

  -- 12.2 subhat
  if NVL(FND_PROFILE.value('CSD_EXP_RCPT_FOR_BLKRCV'),'N') = 'Y' THEN
	 --
	 If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    		fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Entered program unit to receive the matched lines');
  	End if;
      l_create_sr_flag := 'N';
       -- loop through the records and populate the record for the receiving.

      for bk_rcv_rec in (select * from csd_bulk_receive_items_b
                where transaction_number = p_transaction_number)
      loop
        -- find out if the line is ready to be received.
        l_continue_further := true;
        l_counter := l_counter + 1;
        if bk_rcv_rec.order_header_id is not null and bk_rcv_rec.order_line_id is not null then
            -- external ref# handling.
            if bk_rcv_rec.instance_id is not null and bk_rcv_rec.external_reference is not null
             	then
  					  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
						 fnd_log.STRING (fnd_log.level_procedure,
										'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
										'Calling csd_bulk_receive_util.update_external_reference');
                      End if;
             		  csd_repair_manager_util.update_external_reference(p_external_reference => bk_rcv_rec.external_reference,
					  	                        p_instance_id        => bk_rcv_rec.instance_id,
					  	                        x_return_status      => l_return_status,
					  							x_msg_count          => l_msg_count,
  							  					x_msg_data           => l_msg_data);
             elsif bk_rcv_rec.instance_id is null and bk_rcv_rec.external_reference is not null
             	then
             		-- try to get the instance from the repair order.
             		begin
						select instance_id
						into bk_rcv_rec.instance_id
						from csd_repairs
						where repair_line_id = bk_rcv_rec.repair_line_id;
					exception
						when no_data_found then
							null;
					end;

					if bk_rcv_rec.instance_id is null then
						declare
							l_instance_rec                csd_mass_rcv_pvt.instance_rec_type;
							l_instance_id   number;
						begin
							Select ship_to_site_use_id
							into   l_instance_rec.party_site_use_id
							from  cs_incidents_all_b
							where incident_id = bk_rcv_rec.incident_id;

							l_instance_rec.inventory_item_id       := bk_rcv_rec.inventory_item_id;
							l_instance_rec.instance_id             := null;
							l_instance_rec.instance_number         := null;
							l_instance_rec.serial_number           := bk_rcv_rec.serial_number;
							l_instance_rec.lot_number              := null;
							l_instance_rec.quantity                := 1;
							l_instance_rec.uom                     := bk_rcv_rec.uom_code;
							l_instance_rec.party_id                := bk_rcv_rec.party_id;
							l_instance_rec.account_id              := bk_rcv_rec.cust_account_id;
							l_instance_rec.mfg_serial_number_flag  := 'N';
							l_instance_rec.external_reference      := bk_rcv_rec.external_reference;

							If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
						        fnd_log.STRING (fnd_log.level_procedure,
											   'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
											   'Calling csd_mass_rcv_pvt.create_item_instance');
                      		End if;
							-- call the API to create the instance
							    csd_mass_rcv_pvt.create_item_instance (
							      p_api_version        => 1.0,
							      p_init_msg_list      => fnd_api.g_false,
							      p_commit             => fnd_api.g_false,
							      p_validation_level   => fnd_api.g_valid_level_full,
							      x_return_status      => l_return_status,
							      x_msg_count          => l_msg_count,
							      x_msg_data           => l_msg_data,
							      px_instance_rec      => l_instance_rec,
      						 	  x_instance_id        => l_instance_id );
      						if not (l_return_status = fnd_api.g_ret_sts_success) then
      							raise fnd_api.g_exc_error;
      					    end if;
      					  exception
      					  	when FND_API.G_EXC_ERROR then
      					  		null;
      					  end;
      				 else
						If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
						    fnd_log.STRING (fnd_log.level_procedure,
							    		   'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
							    		   'Calling csd_mass_rcv_pvt.update_external_reference');
                      	End if;
      				 	csd_repair_manager_util.update_external_reference(p_external_reference => bk_rcv_rec.external_reference,
											  	  p_instance_id        => bk_rcv_rec.instance_id,
											  	  x_return_status      => l_return_status,
												  x_msg_count          => l_msg_count,
  							  					  x_msg_data           => l_msg_data);
  					end if;

             end if;
          -- we need to make sure that the RMA is booked.
          -- RMA can be in submitted status too.
          csd_bulk_receive_util.pre_process_rma
          ( p_repair_line_id   => bk_rcv_rec.repair_line_id,
            px_order_header_id => bk_rcv_rec.order_header_id,
            px_order_line_id   => bk_rcv_rec.order_line_id,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            x_return_status    => l_return_status
          );
          if l_return_status <> fnd_api.g_ret_sts_success then
          	-- the order is not booked and an attempt to book it has failed.
          	-- log it to concurrent log.
		    csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);
		    -- update the bulk receive record as errored.
		    update csd_bulk_receive_items_b
		    set    status = 'ERRORED'
		    where bulk_receive_id = bk_rcv_rec.bulk_receive_id;

		    -- proceed for the next record.
		    -- bug#8805130, continue is 11G keyword. Use if construct to achieve the same
		    -- functionality.
		    --continue;
		    l_continue_further := false;
		  end if;
		  if l_continue_further then
          if nvl(bk_rcv_rec.under_receipt_flag,'N') = 'Y' then
            -- split the existing line.
            If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				fnd_log.STRING(fnd_log.level_procedure,
				  'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
				  'Under-receipt: Under receipt for repair_line_id '||bk_rcv_rec.repair_line_id);
            End if;
            l_bulk_autorcv_tbl(l_counter).bulk_receive_id := bk_rcv_rec.bulk_receive_id;
            l_bulk_autorcv_tbl(l_counter).repair_line_id  := bk_rcv_rec.repair_line_id;
            l_bulk_autorcv_tbl(l_counter).order_header_id := bk_rcv_rec.order_header_id;
            l_bulk_autorcv_tbl(l_counter).order_line_id   := bk_rcv_rec.order_line_id;
            l_bulk_autorcv_tbl(l_counter).under_receipt_flag := 'Y';
            l_bulk_autorcv_tbl(l_counter).receipt_qty  := bk_rcv_rec.quantity;
            l_bulk_autorcv_tbl(l_counter).locator_id   := bk_rcv_rec.locator_id;
            l_bulk_autorcv_tbl(l_counter).subinventory := bk_rcv_rec.subinventory;
            l_bulk_autorcv_tbl(l_counter).item_revision := bk_rcv_rec.item_revision;
            l_bulk_autorcv_tbl(l_counter).lot_number    := bk_rcv_rec.lot_number;
            l_bulk_autorcv_tbl(l_counter).serial_number := bk_rcv_rec.serial_number;



          elsif nvl(bk_rcv_rec.over_receipt_flag,'N') = 'Y' then
            -- create a new RMA for the over receipt quantity
            -- call the util procedure to create the new RMA line.
            If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Over-receipt: Before calling csd_bulk_receive_util.create_new_rma');
            End if;
            csd_bulk_receive_util.create_new_rma(
                    p_api_version => 1,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit        => FND_API.G_FALSE,
                    p_order_header_id => bk_rcv_rec.order_header_id,
                    p_new_rma_qty     => bk_rcv_rec.over_receipt_qty,
                    p_repair_line_id  => bk_rcv_rec.repair_line_id,
                    p_incident_id     => bk_rcv_rec.incident_id,
                    p_rma_quantity    => (bk_rcv_rec.quantity - bk_rcv_rec.over_receipt_qty),
                    x_return_status   => l_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data,
                    x_order_line_id   => l_order_line_id,
                    x_order_header_id => l_order_header_id
            );
            if l_return_status <> g_ret_sts_success then
              -- error during rma creation.
              If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Error during new RMA creation '||l_msg_data);
             End if;
             csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);

             update csd_bulk_receive_items_b
             set    status = 'ERRORED'
             where  bulk_receive_id = bk_rcv_rec.bulk_receive_id;

            else
            If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Populate the bulk receive table '||bk_rcv_rec.order_header_id||'['||bk_rcv_rec.order_line_id||']');
             End if;
             -- auto create the ship lines for the over-receipt quantity.
             csd_bulk_receive_util.create_new_ship_line(
             		 p_api_version => 1,
             		 p_init_msg_list => FND_API.G_FALSE,
             		 p_commit      => FND_API.G_FALSE,
             		 p_order_header_id => bk_rcv_rec.order_header_id,
             		 p_new_ship_qty    => bk_rcv_rec.over_receipt_qty,
             		 p_repair_line_id  => bk_rcv_rec.repair_line_id,
             		 p_incident_id     => bk_rcv_rec.incident_id,
             		 x_return_status   => l_return_status,
					 x_msg_count       => l_msg_count,
                     x_msg_data        => l_msg_data);
              -- if there is any error during creation new ship line, we wont stall the rest
              -- of the processing.csd_bulk_receive_util.create_new_ship_line does rollback
              -- to savepoint when it hits an error.

             l_bulk_autorcv_tbl(l_counter).bulk_receive_id := bk_rcv_rec.bulk_receive_id;
             l_bulk_autorcv_tbl(l_counter).repair_line_id  := bk_rcv_rec.repair_line_id;
             l_bulk_autorcv_tbl(l_counter).order_header_id := bk_rcv_rec.order_header_id;
             l_bulk_autorcv_tbl(l_counter).order_line_id   := bk_rcv_rec.order_line_id;
			 l_bulk_autorcv_tbl(l_counter).locator_id   := bk_rcv_rec.locator_id;
 			 l_bulk_autorcv_tbl(l_counter).subinventory := bk_rcv_rec.subinventory;
			 l_bulk_autorcv_tbl(l_counter).item_revision := bk_rcv_rec.item_revision;
			 l_bulk_autorcv_tbl(l_counter).lot_number    := bk_rcv_rec.lot_number;
			 l_bulk_autorcv_tbl(l_counter).serial_number := bk_rcv_rec.serial_number;

             l_counter := l_counter + 1;
             l_bulk_autorcv_tbl(l_counter).bulk_receive_id := bk_rcv_rec.bulk_receive_id;
             l_bulk_autorcv_tbl(l_counter).repair_line_id  := bk_rcv_rec.repair_line_id;
             l_bulk_autorcv_tbl(l_counter).order_header_id := l_order_header_id;--bk_rcv_rec.order_header_id;
             l_bulk_autorcv_tbl(l_counter).order_line_id   := l_order_line_id; --bk_rcv_rec.order_line_id;
			 l_bulk_autorcv_tbl(l_counter).locator_id   := bk_rcv_rec.locator_id;
 			 l_bulk_autorcv_tbl(l_counter).subinventory := bk_rcv_rec.subinventory;
			 l_bulk_autorcv_tbl(l_counter).item_revision := bk_rcv_rec.item_revision;
			 l_bulk_autorcv_tbl(l_counter).lot_number    := bk_rcv_rec.lot_number;
			 l_bulk_autorcv_tbl(l_counter).serial_number := bk_rcv_rec.serial_number;
             If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Populated bulk receive rec for over receipt '||l_order_header_id||'['||l_order_line_id||']');
             End if;
            end if;

          else -- regular expected receipt
             If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Populating the bulk receive table for receipt against existing RMAs');
             End if;

             l_bulk_autorcv_tbl(l_counter).bulk_receive_id := bk_rcv_rec.bulk_receive_id;
             l_bulk_autorcv_tbl(l_counter).repair_line_id  := bk_rcv_rec.repair_line_id;
             l_bulk_autorcv_tbl(l_counter).order_header_id := bk_rcv_rec.order_header_id;
             l_bulk_autorcv_tbl(l_counter).order_line_id   := bk_rcv_rec.order_line_id;
			 l_bulk_autorcv_tbl(l_counter).locator_id   := bk_rcv_rec.locator_id;
 			 l_bulk_autorcv_tbl(l_counter).subinventory := bk_rcv_rec.subinventory;
			 l_bulk_autorcv_tbl(l_counter).item_revision := bk_rcv_rec.item_revision;
			 l_bulk_autorcv_tbl(l_counter).lot_number    := bk_rcv_rec.lot_number;
			 l_bulk_autorcv_tbl(l_counter).serial_number := bk_rcv_rec.serial_number;
          end if;

          end if; -- end of l_continue_further check.
        -- process unplanned receipts

        -- Unplanned Receipt = 'N' but no order header or line id.
		-- The RMA line is not yet interfaced to OM. Book the order and process it.
		elsif bk_rcv_rec.order_line_id is null and bk_rcv_rec.unplanned_receipt_flag = 'N'
        then
			csd_bulk_receive_util.pre_process_rma
			  ( p_repair_line_id => bk_rcv_rec.repair_line_id,
				px_order_header_id => bk_rcv_rec.order_header_id,
				px_order_line_id   => bk_rcv_rec.order_line_id,
				x_msg_count       => l_msg_count,
				x_msg_data        => l_msg_data,
				x_return_status   => l_return_status
			  );

          	if l_return_status <> fnd_api.g_ret_sts_success then
			          	-- the order is not booked and an attempt to book it has failed.
			          	-- log it to concurrent log.
					    csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);
					    -- update the bulk receive record as errored.
					    update csd_bulk_receive_items_b
					    set    status = 'ERRORED'
					    where bulk_receive_id = bk_rcv_rec.bulk_receive_id;
					    -- proceed for the next record.
					    -- bug#8805130, continue is 11G keyword. Use if construct to achieve the same
		   				-- functionality.
					    -- continue;
					    l_continue_further := false;
		    end if;
		if l_continue_further then
		    l_bulk_autorcv_tbl(l_counter).bulk_receive_id := bk_rcv_rec.bulk_receive_id;
			l_bulk_autorcv_tbl(l_counter).repair_line_id  := bk_rcv_rec.repair_line_id;
			l_bulk_autorcv_tbl(l_counter).order_header_id := bk_rcv_rec.order_header_id;
			l_bulk_autorcv_tbl(l_counter).order_line_id   := bk_rcv_rec.order_line_id;
			l_bulk_autorcv_tbl(l_counter).locator_id   := bk_rcv_rec.locator_id;
			l_bulk_autorcv_tbl(l_counter).subinventory := bk_rcv_rec.subinventory;
			l_bulk_autorcv_tbl(l_counter).item_revision := bk_rcv_rec.item_revision;
			l_bulk_autorcv_tbl(l_counter).lot_number    := bk_rcv_rec.lot_number;
			l_bulk_autorcv_tbl(l_counter).serial_number := bk_rcv_rec.serial_number;
		end if; -- end of l_continue_further check.

        elsif bk_rcv_rec.unplanned_receipt_flag = 'Y' then
          -- entire unplanned receipt scenario should be treated as a transaction.
          -- an error in any step should result in processing to stop for this record.
          begin
          -- case1.
          -- SR, RO exists but no RMA. Create the RMA, book it and receive the item against it.
          if bk_rcv_rec.incident_id is not null and bk_rcv_rec.repair_line_id is not null then
            -- no RMA is created. Try to create a new rma line and book it.
            -- call the create default product txn helper.
             -- external ref# handling.
             if bk_rcv_rec.instance_id is not null and bk_rcv_rec.external_reference is not null
             	then
             		  csd_repair_manager_util.update_external_reference(p_external_reference => bk_rcv_rec.external_reference,
					  	                        p_instance_id        => bk_rcv_rec.instance_id,
					  	                        x_return_status      => l_return_status,
					  							x_msg_count          => l_msg_count,
  							  					x_msg_data           => l_msg_data);
             elsif bk_rcv_rec.instance_id is null and bk_rcv_rec.external_reference is not null
             	then
             		-- try to get the instance from the repair order.
             		begin
						select instance_id
						into bk_rcv_rec.instance_id
						from csd_repairs
						where repair_line_id = bk_rcv_rec.repair_line_id;
					exception
						when no_data_found then
							null;
					end;

					if bk_rcv_rec.instance_id is null then
						declare
							l_instance_rec                csd_mass_rcv_pvt.instance_rec_type;
							l_instance_id   number;
						begin
							Select ship_to_site_use_id
							into   l_instance_rec.party_site_use_id
							from  cs_incidents_all_b
							where incident_id = bk_rcv_rec.incident_id;

							l_instance_rec.inventory_item_id       := bk_rcv_rec.inventory_item_id;
							l_instance_rec.instance_id             := null;
							l_instance_rec.instance_number         := null;
							l_instance_rec.serial_number           := bk_rcv_rec.serial_number;
							l_instance_rec.lot_number              := null;
							l_instance_rec.quantity                := 1;
							l_instance_rec.uom                     := bk_rcv_rec.uom_code;
							--l_instance_rec.party_site_use_id       := l_party_site_use_id;
							l_instance_rec.party_id                := bk_rcv_rec.party_id;
							l_instance_rec.account_id              := bk_rcv_rec.cust_account_id;
							l_instance_rec.mfg_serial_number_flag  := 'N';
							l_instance_rec.external_reference      := bk_rcv_rec.external_reference;

							-- call the API to create the instance
							    csd_mass_rcv_pvt.create_item_instance (
							      p_api_version        => 1.0,
							      p_init_msg_list      => fnd_api.g_false,
							      p_commit             => fnd_api.g_false,
							      p_validation_level   => fnd_api.g_valid_level_full,
							      x_return_status      => l_return_status,
							      x_msg_count          => l_msg_count,
							      x_msg_data           => l_msg_data,
							      px_instance_rec      => l_instance_rec,
      						 	  x_instance_id        => l_instance_id );
      						if not (l_return_status = fnd_api.g_ret_sts_success) then
      							raise fnd_api.g_exc_error;
      					    end if;
      					  exception
      					  	when FND_API.G_EXC_ERROR then
      					  		null;
      					  end;
      				 else
      				 	csd_repair_manager_util.update_external_reference(p_external_reference => bk_rcv_rec.external_reference,
											  	  p_instance_id        => bk_rcv_rec.instance_id,
											  	  x_return_status      => l_return_status,
												  x_msg_count          => l_msg_count,
  							  					  x_msg_data           => l_msg_data);
  					end if;

             end if;
            If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			                fnd_log.STRING (fnd_log.level_procedure,
			                'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
			                'calling create default product transaction with bulk_receive_id '
			                ||bk_rcv_rec.bulk_receive_id);
            End if;
            csd_bulk_receive_util.create_blkrcv_default_prod_txn
      	     (
      	      p_bulk_receive_id => bk_rcv_rec.bulk_receive_id,
      	      x_return_status   => l_return_status,
      	      x_msg_count       => l_msg_count,
      	      x_msg_data        => l_msg_data
             );

            if l_return_status <> g_ret_sts_success then

               If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
                fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Error while creating default product txn lines '||l_msg_data);
               End if;
               csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);

               update csd_bulk_receive_items_b
               set    status = 'ERRORED'
               where  bulk_receive_id = bk_rcv_rec.bulk_receive_id;

               raise fnd_api.g_exc_error;
            end if;

	       -- update the csd_product_transactions table to mark it as unplanned.

            update csd_product_transactions
            set unplanned_receipt_flag = 'Y'
            where repair_line_id    = bk_rcv_rec.repair_line_id
            and   action_type = 'RMA';
          -- no matching RO's found, create new RO and product lines.
          elsif bk_rcv_rec.incident_id is not null then
            -- call the create ro util api to create a new repair order.

            If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
              fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Unplanned receipt: Before calling csd_bulk_receive_util.create_blkrcv_ro');
            End if;

            csd_bulk_receive_util.create_blkrcv_ro(
                                  p_bulk_receive_id => bk_rcv_rec.bulk_receive_id,
                                  x_repair_line_id => l_repair_line_id,
                                  x_repair_number  => l_repair_number,
                                  x_ro_status      => l_ro_status,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data
                                  );
             if l_return_status <> g_ret_sts_success then
                If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
                    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Error occured while creating RO '||l_msg_data);
                End if;

            	fnd_file.put_line(fnd_file.log,'Error occured in repair order creation '||l_msg_data);

               	update csd_bulk_receive_items_b
               	set    status = 'ERRORED'
               	where  bulk_receive_id = bk_rcv_rec.bulk_receive_id;

                csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);

                raise fnd_api.g_exc_error;
             end if;

             update csd_bulk_receive_items_b
             set repair_line_id = l_repair_line_id
             where bulk_receive_id = bk_rcv_rec.bulk_receive_id;

             if l_ro_status = 'DRAFT' then
             	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				  fnd_log.STRING (fnd_log.level_procedure,
						'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
						'Draft RO: The repair order is created in draft status. Set bulk receive status to processed');
				End if;

				update csd_bulk_receive_items_b
				set  status = 'PROCESSED'
				where bulk_receive_id = bk_rcv_rec.bulk_receive_id;

			 else
				 -- call the create default product txn helper to create the RMA's.
				 If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				  fnd_log.STRING (fnd_log.level_procedure,
						'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
						'Unplanned Receipt: Before calling csd_bulk_receive_util.create_blkrcv_default_prod_txn');
				 End if;
				 csd_bulk_receive_util.create_blkrcv_default_prod_txn
				 (
				  p_bulk_receive_id => bk_rcv_rec.bulk_receive_id,
				  x_return_status   => l_return_status,
				  x_msg_count       => l_msg_count,
				  x_msg_data        => l_msg_data
				 );

				 if l_return_status <> g_ret_sts_success then
				   If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
						fnd_log.STRING (fnd_log.level_procedure,
						'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
						'Error occured while creating default product lines '||l_msg_data);
				   End if;
				   fnd_file.put_line(fnd_file.log,'Error occured during creation of default logistics lines '||l_msg_data);
				   csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);

				   update csd_bulk_receive_items_b
				   set    status = 'ERRORED'
				   where  bulk_receive_id = bk_rcv_rec.bulk_receive_id;

				   raise fnd_api.g_exc_error;
				 end if;
				-- get the order header and line id for the RMA just created.
				 begin
					select ced.order_header_id,ced.order_line_id
					into bk_rcv_rec.order_header_id,bk_rcv_rec.order_line_id
					from csd_product_transactions cpt,
						 cs_estimate_details ced
					where cpt.repair_line_id = l_repair_line_id
					and   ced.estimate_detail_id = cpt.estimate_detail_id
					and   cpt.action_type = 'RMA';
				 exception
					when no_data_found then
					  null;
				 end;
				 l_bulk_autorcv_tbl(l_counter).bulk_receive_id := bk_rcv_rec.bulk_receive_id;
				 l_bulk_autorcv_tbl(l_counter).repair_line_id  := l_repair_line_id;
				 l_bulk_autorcv_tbl(l_counter).order_header_id := bk_rcv_rec.order_header_id;
				 l_bulk_autorcv_tbl(l_counter).order_line_id   := bk_rcv_rec.order_line_id;
				 l_bulk_autorcv_tbl(l_counter).locator_id   := bk_rcv_rec.locator_id;
				 l_bulk_autorcv_tbl(l_counter).subinventory := bk_rcv_rec.subinventory;
				 l_bulk_autorcv_tbl(l_counter).item_revision := bk_rcv_rec.item_revision;
				 l_bulk_autorcv_tbl(l_counter).lot_number    := bk_rcv_rec.lot_number;

				 -- update product transactions and mark it as unplanned.
				 update csd_product_transactions
				 set unplanned_receipt_flag = 'Y'
				 where repair_line_id    = l_repair_line_id
				 and   action_type = 'RMA';

		  	 end if; -- Else part of draft status check.
          -- create new SR, RO and RMA (use the old code)
          else
            l_create_sr_flag := 'Y';

          end if;
          exception
          	when FND_API.G_EXC_ERROR then
          		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
                    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                    'Error occured during unplanned receipt processing '||l_msg_data);
                End if;
             when others then
             	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				    fnd_log.STRING (fnd_log.level_procedure,
				    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
				    'In when others: '||SQLERRM);
                End if;
                raise;
          end;
         end if;

       end loop;
      commit;

      if l_bulk_autorcv_tbl.COUNT >= 1 THEN
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
		                    fnd_log.STRING (fnd_log.level_procedure,
		                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
		                    'Calling csd_bulk_receive_util.bulk_auto_receive');
        End if;

	    csd_bulk_receive_util.bulk_auto_receive
            ( p_bulk_autorcv_tbl => l_bulk_autorcv_tbl,
              x_return_status    => l_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => l_msg_data
            );
      end if;
      if l_return_status <> g_ret_sts_success then
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
		                    fnd_log.STRING (fnd_log.level_procedure,
		                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
		                    'Error in csd_bulk_receive_util.bulk_auto_receive '||l_msg_data);
        End if;
        csd_bulk_receive_util.write_to_conc_log(l_msg_count,l_msg_data);
      end if;

end if;

if l_create_sr_flag = 'Y' then
  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
       fnd_log.STRING (fnd_log.level_procedure,
        			   'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                       'Into create new SR, RO and RMA');
  End if;



  --
  -- Step - E
  -- Create SR for every distinct party and then create
  -- RO and Logistic lines for all the records (in csd_bulk_receive_items_b table)
  -- having same party.If SR creation fails then RO's are not created.
  --
  For c_create_sr_rec in c_create_sr (p_transaction_number)
  Loop
    -- SR Savepoint
    Savepoint create_new_sr_savepoint;

    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
        fnd_log.STRING (fnd_log.level_event,
                        'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                        'Create SR');
    End if;

    -- Create SR
    l_sr_bulk_receive_rec.party_id        := c_create_sr_rec.party_id;
    l_sr_bulk_receive_rec.cust_account_id := c_create_sr_rec.cust_account_id;

    If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_statement,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
	            'Create SR for Party id - '||c_create_sr_rec.party_id
	            ||',Account Id - '||c_create_sr_rec.cust_account_id);
    End if;

    csd_bulk_receive_util.create_blkrcv_sr
    (
      p_bulk_receive_rec  => l_sr_bulk_receive_rec,
      p_sr_notes_tbl      => l_sr_notes_table,
      x_incident_id       => l_incident_id,
      x_incident_number   => l_incident_number,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    If (l_return_status = FND_API.G_RET_STS_SUCCESS) then

      -- Update the record status

      Update csd_bulk_receive_items_b
      set incident_id = l_incident_id,
          status = 'NEW'
      where transaction_number = p_transaction_number
      and party_id = c_create_sr_rec.party_id
      and cust_account_id = c_create_sr_rec.cust_account_id
      and incident_id is null
      and internal_sr_flag = 'N';

    Else

      Rollback To create_new_sr_savepoint;

      -- Update the record status

      Update csd_bulk_receive_items_b
      set status = 'ERRORED'
      where party_id = c_create_sr_rec.party_id
      and cust_account_id = c_create_sr_rec.cust_account_id
      and incident_id is null
      and internal_sr_flag = 'N';

      -- Write to conc log
      Fnd_file.put_line(fnd_file.log,'Error: Service Request Creation failed');
      Fnd_file.put_line(fnd_file.log,'Party id :'||c_create_sr_rec.party_id);

      csd_bulk_receive_util.write_to_conc_log
        ( p_msg_count  => l_msg_count,
          p_msg_data   => l_msg_data);

    End if;

    If (l_return_status = FND_API.G_RET_STS_SUCCESS) then

      -- Initialize the error count
      l_ro_error_count := 0;

      -- Create RO's
      For c_create_ro_rec in c_create_ro (p_transaction_number,l_incident_id)
      Loop

        l_c_create_ro_rowcount := c_create_ro%rowcount;

        Savepoint create_ro_savepoint;

        If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
          fnd_log.STRING (fnd_log.level_event,
                       'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                       'New SR - Call Create Repair Order');
        End if;

        -- Call Create RO Helper procedure
        csd_bulk_receive_util.create_blkrcv_ro
        (
          p_bulk_receive_id  => c_create_ro_rec.bulk_receive_id,
          x_repair_line_id   => l_repair_line_id,
          x_repair_number    => l_repair_number,
          x_return_status    => l_return_status,
          x_ro_status        => l_ro_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );

        If (l_return_status = FND_API.G_RET_STS_SUCCESS) then

	  -- If the RO is created in Draft status then
	  -- no Logistic lines are created.

          If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
	    fnd_log.STRING (fnd_log.level_statement,
	                 'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
	                 'New SR - Created Repair Order ['||l_repair_line_id||'] in '
     	                 ||l_ro_status||' status' );
	  End if;

          If ( l_ro_status = 'DRAFT' ) then

            Update csd_bulk_receive_items_b
	    	  set repair_line_id = l_repair_line_id,
	    	  status = 'PROCESSED'
	    where bulk_receive_id = c_create_ro_rec.bulk_receive_id;

          Else

            -- Update the Bulk Receive Record
            Update csd_bulk_receive_items_b
            set repair_line_id = l_repair_line_id,
                status = 'NEW'
            where bulk_receive_id = c_create_ro_rec.bulk_receive_id;

            -- Call to create default product transaction
	    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
	      fnd_log.STRING (fnd_log.level_event,
	                      'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
	                      'New SR - Call Create Product Transactions');
            End if;

	    csd_bulk_receive_util.create_blkrcv_default_prod_txn
	    (
	      p_bulk_receive_id => c_create_ro_rec.bulk_receive_id,
	      x_return_status   => l_return_status,
	      x_msg_count       => l_msg_count,
	      x_msg_data        => l_msg_data
            );

	    If NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) then

  	      -- If Logistic line creation fails then rollback RO

    	      Rollback To create_ro_savepoint;

	      l_ro_error_count := l_ro_error_count + 1;

	      Update csd_bulk_receive_items_b
	      set status = 'ERRORED'
	      where bulk_receive_id = c_create_ro_rec.bulk_receive_id;

              -- Write to conc log
              Fnd_file.put_line(fnd_file.log,'Error : Creation of Default Logistic lines failed');
	      Fnd_file.put(fnd_file.log,'Serial Number :'||c_create_ro_rec.serial_number||',');
	      Fnd_file.put(fnd_file.log,'Inventory Item Id :'||c_create_ro_rec.inventory_item_id||',');
              Fnd_file.put_line(fnd_file.log,'Qty :'||c_create_ro_rec.quantity);

              csd_bulk_receive_util.write_to_conc_log
              ( p_msg_count  => l_msg_count,
                p_msg_data   => l_msg_data);

            End if;

            -- swai: 12.1.1 bug 7176940 - check service bulletins after RO creation
            IF (nvl(fnd_profile.value('CSD_AUTO_CHECK_BULLETINS'),'N') = 'Y') THEN
                CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO(
                   p_api_version_number         => 1.0,
                   p_init_msg_list              => Fnd_Api.G_FALSE,
                   p_commit                     => Fnd_Api.G_FALSE,
                   p_validation_level           => Fnd_Api.G_VALID_LEVEL_FULL,
                   p_repair_line_id             => l_repair_line_id,
                   px_ro_sc_ids_tbl             => l_ro_sc_ids_tbl,
                   x_return_status              => l_return_status,
                   x_msg_count                  => l_msg_count,
                   x_msg_data                   => l_msg_data
                );
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                         'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                                           'New SR - After CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO['
                                         || l_repair_line_id || ']');
                END IF;
                -- ignore return status for now.
            END IF;

          End if;

         Else

          Rollback To create_ro_savepoint;

	  l_ro_error_count := l_ro_error_count + 1;

	  Update csd_bulk_receive_items_b
          set status = 'ERRORED'
	  where bulk_receive_id = c_create_ro_rec.bulk_receive_id;

          -- Write to conc log
          Fnd_file.put_line(fnd_file.log,'Error : Creation of Repair Order failed');
          Fnd_file.put(fnd_file.log,'Serial Number :'||c_create_ro_rec.serial_number||',');
          Fnd_file.put(fnd_file.log,'Inventory Item Id :'||c_create_ro_rec.inventory_item_id||',');
          Fnd_file.put_line(fnd_file.log,'Qty :'||c_create_ro_rec.quantity);

          csd_bulk_receive_util.write_to_conc_log
          ( p_msg_count  => l_msg_count,
            p_msg_data   => l_msg_data);

       -- 12.1.2 BR ER FP changes subhat
       if NVL(FND_PROFILE.value('CSD_MATCH_SR_RO_RMA_FOR_BLKRCV'),'Y') = 'Y' then
		    update csd_product_transactions
		    set unplanned_receipt_flag = 'Y'
		    where repair_line_id    = l_repair_line_id
		    and   action_type = 'RMA';
	   end if;

        End if;

      End Loop;  --- End of c_create_ro_rec Loop

      -- Verify if any RO is created for the
      -- SR, if not then rollback the created SR
      If ( l_ro_error_count = l_c_create_ro_rowcount ) then
        Rollback To create_new_sr_savepoint;
      End if;

    End if; -- End if of l_return_status of Service Request

  End Loop;  --- End of c_create_sr_rec Loop


  -- Commit before Auto Receiving. This is required since Auto Receiving
  -- is executed as a Autonomous transaction.If explicit commit is not executed
  -- then new entities (Order etc..) will not be visible.
  -- Fix for bug#5438074
  commit;

  --
  -- Step - F
  -- Auto Receive
  --
  i := 0;

  For c_auto_receive_rec in c_auto_receive(p_transaction_number)
  Loop

    -- Verify if the Sub Inv is set
    If ( fnd_profile.value('CSD_BLK_RCV_DEFAULT_SUB_INV') is null) then

      Fnd_file.put_line(fnd_file.log,'Error : Bulk Receive Sub Inventory Profile is Null');
      Fnd_file.put_line(fnd_file.log,'Error : Unable to Auto Receive');

      -- Exit the loop
      exit;

    End if;

    l_order_status         := null;
    l_order_line_id        := null;
    l_order_header_id      := null;
    l_source_serial_number := null;

    -- Get Product Txn Details
    Open c_check_prdtxn_status ( c_auto_receive_rec.repair_line_id);
    Fetch c_check_prdtxn_status into l_order_status,l_order_line_id,
          l_order_header_id,l_source_serial_number;
    Close c_check_prdtxn_status;

    -- Verify if the order line is BOOKED
    If ( l_order_status = 'BOOKED' ) then

      l_ib_flag   := null;
      l_item_name := null;
      l_serial_number_control_code := null;

      -- Get Item Attributes
      Open c_get_item_attributes(c_auto_receive_rec.inventory_item_id);
      Fetch c_get_item_attributes into l_ib_flag,l_item_name,l_serial_number_control_code;
      Close c_get_item_attributes;

      -- Verify if Serial number is entered for a Serialized item. This is possible since
      -- Draft RO is created for a  Serialized Item with qty > 1
      If (l_source_serial_number is null and l_serial_number_control_code <> c_non_serialized ) then

        -- Display the log message;Verify if Serial number is entered
        Fnd_file.put_line(fnd_file.log,'Warning : Serial Number is not entered for a Serialized Item,unable to Auto receive');
        Fnd_file.put(fnd_file.log,'Serial Number :'||c_auto_receive_rec.serial_number);
        Fnd_file.put_line(fnd_file.log,'Item :'||l_item_name);

      Else

        -- Fix for bug#5415850
        i := i + 1;

        l_bulk_autorcv_tbl(i).bulk_receive_id := c_auto_receive_rec.bulk_receive_id;
        l_bulk_autorcv_tbl(i).repair_line_id  := c_auto_receive_rec.repair_line_id;
        l_bulk_autorcv_tbl(i).order_header_id := l_order_header_id;
        l_bulk_autorcv_tbl(i).order_line_id   := l_order_line_id;
        -- 12.1.2 BR ER FP changes, subhat.
	    l_bulk_autorcv_tbl(i).subinventory    := c_auto_receive_rec.subinventory;
	    l_bulk_autorcv_tbl(i).item_revision   := c_auto_receive_rec.item_revision;
	    l_bulk_autorcv_tbl(i).locator_id      := c_auto_receive_rec.locator_id;
	    l_bulk_autorcv_tbl(i).lot_number      := c_auto_receive_rec.lot_number;

      End if;

    Else
      -- Display the log message RO RMA Order is not BOOKED
      Fnd_file.put_line(fnd_file.log,'Warning : Order is not Booked,unable to Auto receive');
      Fnd_file.put(fnd_file.log,'Serial Number :'||c_auto_receive_rec.serial_number);
      Fnd_file.put_line(fnd_file.log,'Inventory Item :'||l_item_name);
    End if;

  End Loop; -- End of c_auto_receive_rec Loop

  --
  -- Call the Auto Receive Procedure
  --

  If ( l_bulk_autorcv_tbl.count > 0 ) then


    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_event,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS',
                   'Calling Auto Receive API');
    End if;

    csd_bulk_receive_util.bulk_auto_receive
      ( p_bulk_autorcv_tbl => l_bulk_autorcv_tbl,
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data
      );

  End if;
  end if; -- 12.1.2 BR ER FP Changes subhat. End of else part (original blkrcv code)

  --
  -- Display the Output
  --
  -- we need to write the output here only if conc req was not submitted. Which is not the case
  -- post 12.1.2. Thus commenting.
  -- bug#8968918, subhat.
  -- when this is commented out, if the repair order was created in draft status, the output
  -- is not written. Uncommenting the earlier commented code.
  if  fnd_conc_global.request_data is null then
  	csd_bulk_receive_util.write_to_conc_output
    	( p_transaction_number => p_transaction_number);
  end if;
  retcode := c_success;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_PVT.PROCESS_BULK_RECEIVE_ITEMS.END',
                      'Exit - Process Bulk Receive Items');
  End if;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    -- write message to log file indicating the failure of the concurrent program,
    -- return error retcode
    errbuf  := FND_MESSAGE.GET_STRING('CSD','CSD_BULK_RECEIVE_FAILURE');
    retcode := c_error;

  WHEN FND_API.G_EXC_ERROR THEN
    -- write message to log file indicating the failure of the concurrent program,
    -- return error retcode
    errbuf  := FND_MESSAGE.GET_STRING('CSD','CSD_BULK_RECEIVE_FAILURE');
    retcode := c_error;

  WHEN OTHERS THEN
    -- Add Unexpected Error to Message List, here SQLERRM is used for
    -- getting the error

    FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME ,
                            p_procedure_name => l_procedure_name );

    -- Get the count of the Messages from the message list, if the count is 1
    -- get the message as well

    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                              p_count => l_msg_count,
                              p_data  => l_msg_data);

    IF l_msg_count = 1 THEN

      fnd_file.put_line( fnd_file.log, l_msg_data);

    ELSIF l_msg_count > 1 THEN

      -- If the message count is greater than 1, loop through the
      -- message list, retrieve the messages and write it to the log file

      FOR l_msg_ctr IN 1..l_msg_count
      LOOP
        l_msg_data := fnd_msg_pub.get(l_msg_ctr, FND_API.G_FALSE );
        fnd_file.put_line( fnd_file.log, l_msg_data);
      END LOOP;

    END IF;

    -- write message to log file indicating the failure of the concurrent program,
    -- return error retcode

    errbuf  := FND_MESSAGE.GET_STRING('CSD','CSD_BULK_RECEIVE_FAILURE');
    retcode := c_error ;

END process_bulk_receive_items;

END CSD_BULK_RECEIVE_PVT;

/
