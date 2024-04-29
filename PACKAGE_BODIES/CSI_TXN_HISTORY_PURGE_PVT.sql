--------------------------------------------------------
--  DDL for Package Body CSI_TXN_HISTORY_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TXN_HISTORY_PURGE_PVT" AS
/* $Header: csivthpb.pls 120.2.12010000.2 2009/08/27 05:23:55 dsingire ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_TXN_HISTORY_PURGE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivthpb.pls';
--
--
-- Procedure to debug the discrepancies
--
Procedure Debug(
  p_message       IN VARCHAR2)
IS
Begin
   fnd_file.put_line(fnd_file.log, p_message);
End Debug;
--
--
-- Truncate the discrepancy table before each run
--
Procedure truncate_table(
  p_table_name    IN VARCHAR2)
IS
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
-- This is the main archive program which internally calls each of the entity
-- archive programs concurrently. It accepts a date timestamp as an parameter.
--
Procedure Archive ( errbuf           OUT NOCOPY  VARCHAR2,
                    retcode          OUT NOCOPY  NUMBER,
                    purge_to_date    IN          VARCHAR2)

  IS

    l_message         VARCHAR2(2000);
    from_trans        NUMBER;
    to_trans          NUMBER;
    l_request_id      NUMBER;
    l_errbuf          VARCHAR2(2000);
    l_recs_archived   NUMBER;
    l_date            DATE;
    t_date            DATE;
    l_exists          VARCHAR2(1);

Begin

  Debug('Start of the Install Base History Archive Process... ');

  -- Get the min and max transactions_ids for the date timestamp passed
     Begin
       Select Min(transaction_id),
              Max(transaction_id)
       Into   from_trans,
              to_trans
       From   CSI_TRANSACTIONS
       Where  creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS');
     Exception
       When Others Then
          Null;
     End;
            Debug('');
            Debug('Concurrent program parameters...');
            Debug('');
            Debug('+-----------------------------------------------------------------------------------------------+');
            Debug(substr('Transaction History Purge date in the format YYYY/MM/DD HH24:MI:SS ='||purge_to_date,1,255));
            Debug('+-----------------------------------------------------------------------------------------------+');
            Debug('');
            Debug('');
            Debug('Value of from_trans='||TO_CHAR(from_trans));
            Debug('Value of to_trans='||TO_CHAR(to_trans));

     --
     -- srramakr Fix for Bug # 3435413. No need to call Child processes if there are no
     -- Transactions to be Purged.
     IF from_trans IS NULL OR
        to_trans IS NULL THEN
        Debug('No History Transaction available for Purge for the Given Date...');
        Return;
     END IF;
     --
     -- Check if there are any instances residing in CSI_II_FORWARD_SYNC_TEMP table with a lesser time stamp.
     Begin
        select 'x'
        into l_exists
        from CSI_II_FORWARD_SYNC_TEMP
        where date_time_stamp <= to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
        and   process_flag <> 'P'
        and   rownum < 2;
        Debug('One or more instances reside in CSI_II_FORWARD_SYNC_TEMP table with a date_time_stamp lesser than the given Pruge Date. Cannot continue with the purge.');
        Return;
     Exception
        when no_data_found then
           null;
     End;
     --
   -- srramakr Bug 4366231. The following routine joins each entity history table with CSI_TRANSACTIONS
   -- to get the count of records purged and archieved. This causes lot of performance issue. Giving such
   -- count is unnecessary. The user can always check against the archive table. Hence commenting it.
  /*   csi_txn_history_purge_pvt.Record_count(From_trans   =>  From_trans,
                                            To_trans     =>  To_trans,
                                            Purge_to_date => purge_to_date,
                                            Recs_count   =>  l_recs_archived ); */
     --
     -- This following program is used to archive the Instance history. It accepts from  transactions
     -- as the input parameters.
     --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIINSARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );
            Debug('');
            Debug('Calling Install Base Instance History Archive and Purge Process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Instance History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Instance History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIPTYARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Party History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Party History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Instance Party History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIACTARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Account History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Account History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Account History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIOUARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Operating Units History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Operating Units History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Operating Units History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIPRIARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Pricing History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Pricing History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Pricing History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIEXTARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Extended Attribs History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Extended Attribs History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Extended Attribs History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIASTARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Assets History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Assets History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Assets History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIVERARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Version Label History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Version Label History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Version Label History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSIRELARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Instance Relationships History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Instance Relationships History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Instance Relationships History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
      --
      -- This following program is used to archive the Instance history. It accepts from  transactions
      -- as the input parameters.
      --
      l_request_id := fnd_request.submit_request (
                                           application    => 'CSI',
                                           program        => 'CSISYSARCH',
                                           start_time     =>  Null,
                                           sub_request    =>  False,
                                           argument1      =>  From_Trans,
                                           argument2      =>  To_Trans,
                                           argument3      =>  Purge_to_Date );

            Debug('');
            Debug('Calling Installed Base Systems History Archive and Purge process...');
            Debug('Request ID: '||l_request_id||' has been submitted');

              If l_request_id = 0
              Then
                 fnd_message.retrieve(l_errbuf);
                 Debug('Call to Installed Base Systems History Archive and Purge process has errored');
                 Debug('Error message   :'||substr(l_errbuf,1,75));
                 Debug(' :'||substr(l_errbuf,76,150));
                 Debug(' :'||substr(l_errbuf,151,225));
                 Debug(' :'||substr(l_errbuf,226,300));
              Else
                 Debug('Installed Base Systems History Archive and Purge process has completed successfully');
                 Debug('');
                 Commit;
              End If;
              -- convert the incoming date format.
              t_date := to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS');

              -- Update the csi object_dictionary table with the archived and purged date
              Begin
                 Update CSI_OBJECT_DICTIONARY
                 Set    last_archive_date = t_date;
              End;
              Commit;
              --
              Debug('');
           --   Debug('Total Number of Records Archived = '||l_recs_archived);
           --   Debug('');
           --   Debug('Total Number of Records Purged from history tables = '||l_recs_archived);
           --   Debug('');
              Debug('');

    Debug('End of Installed Base History Archive and purge process...');

Exception
  When Others Then
    Debug('Failed in the Installed Base History Archive Process');
End;
--
-- This program is used to archive the Instance history. It accepts from  transactions
-- as the input parameters.
--
Procedure Instance_Archive( errbuf       OUT NOCOPY VARCHAR2,
                            retcode      OUT NOCOPY NUMBER,
                            from_trans   IN  NUMBER,
                            to_trans     IN  NUMBER,
                            purge_to_date IN VARCHAR2 )
Is

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NumList IS Table Of Number Index By Binary_Integer;
    l_archive_id_tbl   NumList;

    Cursor inst_hist_csr (p_from_trans IN NUMBER,
                          p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_ITEM_INSTANCES_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_inst_hist_csr          inst_hist_csr%RowType;
    l_inst_hist_rec_tab      csi_txn_history_purge_pvt.instance_history_rec_tab;


 Begin
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_ITEM_INSTANCES_H';
    Exception
      When no_data_found Then
        l_table_id := 1;
      When others Then
        l_table_id := 1;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
    Begin
      SAVEPOINT Instance_Archive;
      l_ctr := 0;
      --
      l_inst_hist_rec_tab.instance_id.DELETE;
      l_inst_hist_rec_tab.old_instance_number.DELETE;
      l_inst_hist_rec_tab.new_instance_number.DELETE;
      l_inst_hist_rec_tab.old_external_reference.DELETE;
      l_inst_hist_rec_tab.new_external_reference.DELETE;
      l_inst_hist_rec_tab.old_inventory_item_id.DELETE;
      l_inst_hist_rec_tab.new_inventory_item_id.DELETE;
      l_inst_hist_rec_tab.old_inventory_revision.DELETE;
      l_inst_hist_rec_tab.new_inventory_revision.DELETE;
      l_inst_hist_rec_tab.old_inv_master_org_id.DELETE;
      l_inst_hist_rec_tab.new_inv_master_org_id.DELETE;
      l_inst_hist_rec_tab.old_serial_number.DELETE;
      l_inst_hist_rec_tab.new_serial_number.DELETE;
      l_inst_hist_rec_tab.old_mfg_serial_number_flag.DELETE;
      l_inst_hist_rec_tab.new_mfg_serial_number_flag.DELETE;
      l_inst_hist_rec_tab.old_lot_number.DELETE;
      l_inst_hist_rec_tab.new_lot_number.DELETE;
      l_inst_hist_rec_tab.old_quantity.DELETE;
      l_inst_hist_rec_tab.new_quantity.DELETE;
      l_inst_hist_rec_tab.old_unit_of_measure.DELETE;
      l_inst_hist_rec_tab.new_unit_of_measure.DELETE;
      l_inst_hist_rec_tab.old_accounting_class_code.DELETE;
      l_inst_hist_rec_tab.new_accounting_class_code.DELETE;
      l_inst_hist_rec_tab.old_instance_condition_id.DELETE;
      l_inst_hist_rec_tab.new_instance_condition_id.DELETE;
      l_inst_hist_rec_tab.old_instance_status_id.DELETE;
      l_inst_hist_rec_tab.new_instance_status_id.DELETE;
      l_inst_hist_rec_tab.old_customer_view_flag.DELETE;
      l_inst_hist_rec_tab.new_customer_view_flag.DELETE;
      l_inst_hist_rec_tab.old_merchant_view_flag.DELETE;
      l_inst_hist_rec_tab.new_merchant_view_flag.DELETE;
      l_inst_hist_rec_tab.old_sellable_flag.DELETE;
      l_inst_hist_rec_tab.new_sellable_flag.DELETE;
      l_inst_hist_rec_tab.old_system_id.DELETE;
      l_inst_hist_rec_tab.new_system_id.DELETE;
      l_inst_hist_rec_tab.old_instance_type_code.DELETE;
      l_inst_hist_rec_tab.new_instance_type_code.DELETE;
      l_inst_hist_rec_tab.old_active_start_date.DELETE;
      l_inst_hist_rec_tab.new_active_start_date.DELETE;
      l_inst_hist_rec_tab.old_active_end_date.DELETE;
      l_inst_hist_rec_tab.new_active_end_date.DELETE;
      l_inst_hist_rec_tab.old_location_type_code.DELETE;
      l_inst_hist_rec_tab.new_location_type_code.DELETE;
      l_inst_hist_rec_tab.old_location_id.DELETE;
      l_inst_hist_rec_tab.new_location_id.DELETE;
      l_inst_hist_rec_tab.old_inv_organization_id.DELETE;
      l_inst_hist_rec_tab.new_inv_organization_id.DELETE;
      l_inst_hist_rec_tab.old_inv_subinventory_name.DELETE;
      l_inst_hist_rec_tab.new_inv_subinventory_name.DELETE;
      l_inst_hist_rec_tab.old_inv_locator_id.DELETE;
      l_inst_hist_rec_tab.new_inv_locator_id.DELETE;
      l_inst_hist_rec_tab.old_pa_project_id.DELETE;
      l_inst_hist_rec_tab.new_pa_project_id.DELETE;
      l_inst_hist_rec_tab.old_pa_project_task_id.DELETE;
      l_inst_hist_rec_tab.new_pa_project_task_id.DELETE;
      l_inst_hist_rec_tab.old_in_transit_order_line_id.DELETE;
      l_inst_hist_rec_tab.new_in_transit_order_line_id.DELETE;
      l_inst_hist_rec_tab.old_wip_job_id.DELETE;
      l_inst_hist_rec_tab.new_wip_job_id.DELETE;
      l_inst_hist_rec_tab.old_po_order_line_id.DELETE;
      l_inst_hist_rec_tab.new_po_order_line_id.DELETE;
      l_inst_hist_rec_tab.old_install_date.DELETE;
      l_inst_hist_rec_tab.new_install_date.DELETE;
      l_inst_hist_rec_tab.old_return_by_date.DELETE;
      l_inst_hist_rec_tab.new_return_by_date.DELETE;
      l_inst_hist_rec_tab.old_actual_return_date.DELETE;
      l_inst_hist_rec_tab.new_actual_return_date.DELETE;
      l_inst_hist_rec_tab.old_completeness_flag.DELETE;
      l_inst_hist_rec_tab.new_completeness_flag.DELETE;
      l_inst_hist_rec_tab.old_inst_context.DELETE;
      l_inst_hist_rec_tab.new_inst_context.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute1.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute1.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute2.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute2.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute3.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute3.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute4.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute4.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute5.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute5.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute6.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute6.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute7.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute7.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute8.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute8.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute9.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute9.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute10.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute10.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute11.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute11.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute12.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute12.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute13.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute13.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute14.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute14.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute15.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute15.DELETE;
      l_inst_hist_rec_tab.old_install_location_type_code.DELETE;
      l_inst_hist_rec_tab.new_install_location_type_code.DELETE;
      l_inst_hist_rec_tab.old_install_location_id.DELETE;
      l_inst_hist_rec_tab.new_install_location_id.DELETE;
      l_inst_hist_rec_tab.old_instance_usage_code.DELETE;
      l_inst_hist_rec_tab.new_instance_usage_code.DELETE;
      l_inst_hist_rec_tab.old_config_inst_rev_num.DELETE;
      l_inst_hist_rec_tab.new_config_inst_rev_num.DELETE;
      l_inst_hist_rec_tab.old_config_valid_status.DELETE;
      l_inst_hist_rec_tab.new_config_valid_status.DELETE;
      l_inst_hist_rec_tab.old_instance_description.DELETE;
      l_inst_hist_rec_tab.new_instance_description.DELETE;
      l_inst_hist_rec_tab.instance_history_id.DELETE;
      l_inst_hist_rec_tab.transaction_id.DELETE;
      l_inst_hist_rec_tab.old_last_vld_organization_id.DELETE;
      l_inst_hist_rec_tab.new_last_vld_organization_id.DELETE;
      l_inst_hist_rec_tab.old_last_oe_agreement_id.DELETE;
      l_inst_hist_rec_tab.new_last_oe_agreement_id.DELETE;
      l_inst_hist_rec_tab.inst_full_dump_flag.DELETE;
      l_inst_hist_rec_tab.inst_created_by.DELETE;
      l_inst_hist_rec_tab.inst_creation_date.DELETE;
      l_inst_hist_rec_tab.inst_last_updated_by.DELETE;
      l_inst_hist_rec_tab.inst_last_update_date.DELETE;
      l_inst_hist_rec_tab.inst_last_update_login.DELETE;
      l_inst_hist_rec_tab.inst_object_version_number.DELETE;
      l_inst_hist_rec_tab.inst_security_group_id.DELETE;
      l_inst_hist_rec_tab.inst_migrated_flag.DELETE;
      -- Added for eam
      l_inst_hist_rec_tab.old_network_asset_flag.DELETE;
      l_inst_hist_rec_tab.new_network_asset_flag.DELETE;
      l_inst_hist_rec_tab.old_maintainable_flag.DELETE;
      l_inst_hist_rec_tab.new_maintainable_flag.DELETE;
      l_inst_hist_rec_tab.old_pn_location_id.DELETE;
      l_inst_hist_rec_tab.new_pn_location_id.DELETE;
      l_inst_hist_rec_tab.old_asset_criticality_code.DELETE;
      l_inst_hist_rec_tab.new_asset_criticality_code.DELETE;
      l_inst_hist_rec_tab.old_category_id.DELETE;
      l_inst_hist_rec_tab.new_category_id.DELETE;
      l_inst_hist_rec_tab.old_equipment_gen_object_id.DELETE;
      l_inst_hist_rec_tab.new_equipment_gen_object_id.DELETE;
      l_inst_hist_rec_tab.old_instantiation_flag.DELETE;
      l_inst_hist_rec_tab.new_instantiation_flag.DELETE;
      l_inst_hist_rec_tab.old_linear_location_id.DELETE;
      l_inst_hist_rec_tab.new_linear_location_id.DELETE;
      l_inst_hist_rec_tab.old_operational_log_flag.DELETE;
      l_inst_hist_rec_tab.new_operational_log_flag.DELETE;
      l_inst_hist_rec_tab.old_checkin_status.DELETE;
      l_inst_hist_rec_tab.new_checkin_status.DELETE;
      l_inst_hist_rec_tab.old_supplier_warranty_exp_date.DELETE;
      l_inst_hist_rec_tab.new_supplier_warranty_exp_date.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute16.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute16.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute17.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute17.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute18.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute18.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute19.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute19.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute20.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute20.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute21.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute21.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute22.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute22.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute23.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute23.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute24.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute24.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute25.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute25.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute26.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute26.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute27.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute27.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute28.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute28.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute29.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute29.DELETE;
      l_inst_hist_rec_tab.old_inst_attribute30.DELETE;
      l_inst_hist_rec_tab.new_inst_attribute30.DELETE;
      -- End addition for eam
      --
  For i in inst_hist_csr(v_start,v_end)
  Loop

      l_ctr := l_ctr + 1;

      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;

      l_inst_hist_rec_tab.instance_id(l_ctr)	                :=  i.instance_id;
      l_inst_hist_rec_tab.old_instance_number(l_ctr)	        :=  i.old_instance_number;
      l_inst_hist_rec_tab.new_instance_number(l_ctr)            :=  i.new_instance_number;
      l_inst_hist_rec_tab.old_external_reference(l_ctr)	        :=  i.old_external_reference;
      l_inst_hist_rec_tab.new_external_reference(l_ctr)	        :=  i.new_external_reference;
      l_inst_hist_rec_tab.old_inventory_item_id(l_ctr)	        :=  i.old_inventory_item_id;
      l_inst_hist_rec_tab.new_inventory_item_id(l_ctr)	        :=  i.new_inventory_item_id;
      l_inst_hist_rec_tab.old_inventory_revision(l_ctr)	        :=  i.old_inventory_revision;
      l_inst_hist_rec_tab.new_inventory_revision(l_ctr)	        :=  i.new_inventory_revision;
      l_inst_hist_rec_tab.old_inv_master_org_id(l_ctr)	        :=  i.old_inv_master_organization_id;
      l_inst_hist_rec_tab.new_inv_master_org_id(l_ctr)	        :=  i.new_inv_master_organization_id;
      l_inst_hist_rec_tab.old_serial_number(l_ctr)	            :=  i.old_serial_number;
      l_inst_hist_rec_tab.new_serial_number(l_ctr)	            :=  i.new_serial_number;
      l_inst_hist_rec_tab.old_mfg_serial_number_flag(l_ctr)     :=  i.old_mfg_serial_number_flag;
      l_inst_hist_rec_tab.new_mfg_serial_number_flag(l_ctr)     :=  i.new_mfg_serial_number_flag;
      l_inst_hist_rec_tab.old_lot_number(l_ctr)	                :=  i.old_lot_number;
      l_inst_hist_rec_tab.new_lot_number(l_ctr)	                :=  i.new_lot_number;
      l_inst_hist_rec_tab.old_quantity(l_ctr)	                :=  i.old_quantity;
      l_inst_hist_rec_tab.new_quantity(l_ctr)	                :=  i.new_quantity;
      l_inst_hist_rec_tab.old_unit_of_measure(l_ctr)	        :=  i.old_unit_of_measure;
      l_inst_hist_rec_tab.new_unit_of_measure(l_ctr)	        :=  i.new_unit_of_measure;
      l_inst_hist_rec_tab.old_accounting_class_code(l_ctr)      :=  i.old_accounting_class_code;
      l_inst_hist_rec_tab.new_accounting_class_code(l_ctr)      :=  i.new_accounting_class_code;
      l_inst_hist_rec_tab.old_instance_condition_id(l_ctr)      :=  i.old_instance_condition_id;
      l_inst_hist_rec_tab.new_instance_condition_id(l_ctr)      :=  i.new_instance_condition_id;
      l_inst_hist_rec_tab.old_instance_status_id(l_ctr)	        :=  i.old_instance_status_id;
      l_inst_hist_rec_tab.new_instance_status_id(l_ctr)	        :=  i.new_instance_status_id;
      l_inst_hist_rec_tab.old_customer_view_flag(l_ctr)	        :=  i.old_customer_view_flag;
      l_inst_hist_rec_tab.new_customer_view_flag(l_ctr)	        :=  i.new_customer_view_flag;
      l_inst_hist_rec_tab.old_merchant_view_flag(l_ctr)	        :=  i.old_merchant_view_flag;
      l_inst_hist_rec_tab.new_merchant_view_flag(l_ctr)	        :=  i.new_merchant_view_flag;
      l_inst_hist_rec_tab.old_sellable_flag(l_ctr)	            :=  i.old_sellable_flag;
      l_inst_hist_rec_tab.new_sellable_flag(l_ctr)	            :=  i.new_sellable_flag;
      l_inst_hist_rec_tab.old_system_id(l_ctr)	                :=  i.old_system_id;
      l_inst_hist_rec_tab.new_system_id(l_ctr)	                :=  i.new_system_id;
      l_inst_hist_rec_tab.old_instance_type_code(l_ctr)	        :=  i.old_instance_type_code;
      l_inst_hist_rec_tab.new_instance_type_code(l_ctr)	        :=  i.new_instance_type_code;
      l_inst_hist_rec_tab.old_active_start_date(l_ctr)	        :=  i.old_active_start_date;
      l_inst_hist_rec_tab.new_active_start_date(l_ctr)	        :=  i.new_active_start_date;
      l_inst_hist_rec_tab.old_active_end_date(l_ctr)	        :=  i.old_active_end_date;
      l_inst_hist_rec_tab.new_active_end_date(l_ctr)	        :=  i.new_active_end_date;
      l_inst_hist_rec_tab.old_location_type_code(l_ctr)	        :=  i.old_location_type_code;
      l_inst_hist_rec_tab.new_location_type_code(l_ctr)	        :=  i.new_location_type_code;
      l_inst_hist_rec_tab.old_location_id(l_ctr)	            :=  i.old_location_id;
      l_inst_hist_rec_tab.new_location_id(l_ctr)	            :=  i.new_location_id;
      l_inst_hist_rec_tab.old_inv_organization_id(l_ctr)        :=  i.old_inv_organization_id;
      l_inst_hist_rec_tab.new_inv_organization_id(l_ctr)        :=  i.new_inv_organization_id;
      l_inst_hist_rec_tab.old_inv_subinventory_name(l_ctr)      :=  i.old_inv_subinventory_name;
      l_inst_hist_rec_tab.new_inv_subinventory_name(l_ctr)      :=  i.new_inv_subinventory_name;
      l_inst_hist_rec_tab.old_inv_locator_id(l_ctr)	            :=  i.old_inv_locator_id;
      l_inst_hist_rec_tab.new_inv_locator_id(l_ctr)	            :=  i.new_inv_locator_id;
      l_inst_hist_rec_tab.old_pa_project_id(l_ctr)	            :=  i.old_pa_project_id;
      l_inst_hist_rec_tab.new_pa_project_id(l_ctr)	            :=  i.new_pa_project_id;
      l_inst_hist_rec_tab.old_pa_project_task_id(l_ctr)	        :=  i.old_pa_project_task_id;
      l_inst_hist_rec_tab.new_pa_project_task_id(l_ctr)	        :=  i.new_pa_project_task_id;
      l_inst_hist_rec_tab.old_in_transit_order_line_id(l_ctr)   :=  i.old_in_transit_order_line_id;
      l_inst_hist_rec_tab.new_in_transit_order_line_id(l_ctr)   :=  i.new_in_transit_order_line_id;
      l_inst_hist_rec_tab.old_wip_job_id(l_ctr)	                :=  i.old_wip_job_id;
      l_inst_hist_rec_tab.new_wip_job_id(l_ctr)	                :=  i.new_wip_job_id;
      l_inst_hist_rec_tab.old_po_order_line_id(l_ctr)           :=  i.old_po_order_line_id;
      l_inst_hist_rec_tab.new_po_order_line_id(l_ctr)           :=  i.new_po_order_line_id;
      l_inst_hist_rec_tab.old_install_date(l_ctr)	            :=  i.old_install_date;
      l_inst_hist_rec_tab.new_install_date(l_ctr)	            :=  i.new_install_date;
      l_inst_hist_rec_tab.old_return_by_date(l_ctr)	            :=  i.old_return_by_date;
      l_inst_hist_rec_tab.new_return_by_date(l_ctr)	            :=  i.new_return_by_date;
      l_inst_hist_rec_tab.old_actual_return_date(l_ctr)	        :=  i.old_actual_return_date;
      l_inst_hist_rec_tab.new_actual_return_date(l_ctr)	        :=  i.new_actual_return_date;
      l_inst_hist_rec_tab.old_completeness_flag(l_ctr)	        :=  i.old_completeness_flag;
      l_inst_hist_rec_tab.new_completeness_flag(l_ctr)	        :=  i.new_completeness_flag;
      l_inst_hist_rec_tab.old_inst_context(l_ctr)	            :=  i.old_context;
      l_inst_hist_rec_tab.new_inst_context(l_ctr)	            :=  i.new_context;
      l_inst_hist_rec_tab.old_inst_attribute1(l_ctr)	        :=  i.old_attribute1;
      l_inst_hist_rec_tab.new_inst_attribute1(l_ctr)	        :=  i.new_attribute1;
      l_inst_hist_rec_tab.old_inst_attribute2(l_ctr)	        :=  i.old_attribute2;
      l_inst_hist_rec_tab.new_inst_attribute2(l_ctr)	        :=  i.new_attribute2;
      l_inst_hist_rec_tab.old_inst_attribute3(l_ctr)	        :=  i.old_attribute3;
      l_inst_hist_rec_tab.new_inst_attribute3(l_ctr)	        :=  i.new_attribute3;
      l_inst_hist_rec_tab.old_inst_attribute4(l_ctr)	        :=  i.old_attribute4;
      l_inst_hist_rec_tab.new_inst_attribute4(l_ctr)	        :=  i.new_attribute4;
      l_inst_hist_rec_tab.old_inst_attribute5(l_ctr)	        :=  i.old_attribute5;
      l_inst_hist_rec_tab.new_inst_attribute5(l_ctr)	        :=  i.new_attribute5;
      l_inst_hist_rec_tab.old_inst_attribute6(l_ctr)	        :=  i.old_attribute6;
      l_inst_hist_rec_tab.new_inst_attribute6(l_ctr)	        :=  i.new_attribute6;
      l_inst_hist_rec_tab.old_inst_attribute7(l_ctr)	        :=  i.old_attribute7;
      l_inst_hist_rec_tab.new_inst_attribute7(l_ctr)	        :=  i.new_attribute7;
      l_inst_hist_rec_tab.old_inst_attribute8(l_ctr)	        :=  i.old_attribute8;
      l_inst_hist_rec_tab.new_inst_attribute8(l_ctr)	        :=  i.new_attribute8;
      l_inst_hist_rec_tab.old_inst_attribute9(l_ctr)	        :=  i.old_attribute9;
      l_inst_hist_rec_tab.new_inst_attribute9(l_ctr)	        :=  i.new_attribute9;
      l_inst_hist_rec_tab.old_inst_attribute10(l_ctr)	        :=  i.old_attribute10;
      l_inst_hist_rec_tab.new_inst_attribute10(l_ctr)	        :=  i.new_attribute10;
      l_inst_hist_rec_tab.old_inst_attribute11(l_ctr)      	    :=  i.old_attribute11;
      l_inst_hist_rec_tab.new_inst_attribute11(l_ctr)	        :=  i.new_attribute11;
      l_inst_hist_rec_tab.old_inst_attribute12(l_ctr)	        :=  i.old_attribute12;
      l_inst_hist_rec_tab.new_inst_attribute12(l_ctr)	        :=  i.new_attribute12;
      l_inst_hist_rec_tab.old_inst_attribute13(l_ctr)	        :=  i.old_attribute13;
      l_inst_hist_rec_tab.new_inst_attribute13(l_ctr)	        :=  i.new_attribute13;
      l_inst_hist_rec_tab.old_inst_attribute14(l_ctr)	        :=  i.old_attribute14;
      l_inst_hist_rec_tab.new_inst_attribute14(l_ctr)	        :=  i.new_attribute14;
      l_inst_hist_rec_tab.old_inst_attribute15(l_ctr)	        :=  i.old_attribute15;
      l_inst_hist_rec_tab.new_inst_attribute15(l_ctr)	        :=  i.new_attribute15;
      l_inst_hist_rec_tab.old_install_location_type_code(l_ctr) :=  i.old_inst_loc_type_code;
      l_inst_hist_rec_tab.new_install_location_type_code(l_ctr) :=  i.new_inst_loc_type_code;
      l_inst_hist_rec_tab.old_install_location_id(l_ctr)        :=  i.old_inst_loc_id;
      l_inst_hist_rec_tab.new_install_location_id(l_ctr)        :=  i.new_inst_loc_id;
      l_inst_hist_rec_tab.old_instance_usage_code(l_ctr)        :=  i.old_inst_usage_code;
      l_inst_hist_rec_tab.new_instance_usage_code(l_ctr)        :=  i.new_inst_usage_code;
      l_inst_hist_rec_tab.old_config_inst_rev_num(l_ctr)        :=  i.old_config_inst_rev_num;
      l_inst_hist_rec_tab.new_config_inst_rev_num(l_ctr)        :=  i.new_config_inst_rev_num;
      l_inst_hist_rec_tab.old_config_valid_status(l_ctr)        :=  i.old_config_valid_status;
      l_inst_hist_rec_tab.new_config_valid_status(l_ctr)        :=  i.new_config_valid_status;
      l_inst_hist_rec_tab.old_instance_description(l_ctr)       :=  i.old_instance_description;
      l_inst_hist_rec_tab.new_instance_description(l_ctr)       :=  i.new_instance_description;
      l_inst_hist_rec_tab.instance_history_id(l_ctr)	        :=  i.instance_history_id;
      l_inst_hist_rec_tab.transaction_id(l_ctr)	                :=  i.transaction_id;
      l_inst_hist_rec_tab.old_last_vld_organization_id(l_ctr)   :=  i.old_last_vld_organization_id;
      l_inst_hist_rec_tab.new_last_vld_organization_id(l_ctr)   :=  i.new_last_vld_organization_id;
      l_inst_hist_rec_tab.old_last_oe_agreement_id(l_ctr)       :=  i.old_oe_agreement_id;
      l_inst_hist_rec_tab.new_last_oe_agreement_id(l_ctr)       :=  i.new_oe_agreement_id;
      l_inst_hist_rec_tab.inst_full_dump_flag(l_ctr)            :=  i.full_dump_flag;
      l_inst_hist_rec_tab.inst_created_by(l_ctr)                :=  i.created_by;
      l_inst_hist_rec_tab.inst_creation_date(l_ctr)             :=  i.creation_date;
      l_inst_hist_rec_tab.inst_last_updated_by(l_ctr)           :=  i.last_updated_by;
      l_inst_hist_rec_tab.inst_last_update_date(l_ctr)          :=  i.last_update_date;
      l_inst_hist_rec_tab.inst_last_update_login(l_ctr)         :=  i.last_update_login;
      l_inst_hist_rec_tab.inst_object_version_number(l_ctr)     :=  i.object_version_number;
      l_inst_hist_rec_tab.inst_security_group_id(l_ctr)         :=  i.security_group_id;
      l_inst_hist_rec_tab.inst_migrated_flag(l_ctr)             :=  i.migrated_flag;
      -- Added for eam
      l_inst_hist_rec_tab.old_network_asset_flag(l_ctr)         :=  i.old_network_asset_flag ;
      l_inst_hist_rec_tab.new_network_asset_flag(l_ctr)         :=  i.new_network_asset_flag ;
      l_inst_hist_rec_tab.old_maintainable_flag(l_ctr)          :=  i.old_maintainable_flag ;
      l_inst_hist_rec_tab.new_maintainable_flag(l_ctr)          :=  i.new_maintainable_flag ;
      l_inst_hist_rec_tab.old_pn_location_id(l_ctr)             :=  i.old_pn_location_id ;
      l_inst_hist_rec_tab.new_pn_location_id(l_ctr)             :=  i.new_pn_location_id ;
      l_inst_hist_rec_tab.old_asset_criticality_code(l_ctr)     :=  i.old_asset_criticality_code ;
      l_inst_hist_rec_tab.new_asset_criticality_code(l_ctr)     :=  i.new_asset_criticality_code ;
      l_inst_hist_rec_tab.old_category_id(l_ctr)                :=  i.old_category_id ;
      l_inst_hist_rec_tab.new_category_id(l_ctr)                :=  i.new_category_id ;
      l_inst_hist_rec_tab.old_equipment_gen_object_id(l_ctr)    :=  i.old_equipment_gen_object_id ;
      l_inst_hist_rec_tab.new_equipment_gen_object_id(l_ctr)    :=  i.new_equipment_gen_object_id ;
      l_inst_hist_rec_tab.old_instantiation_flag(l_ctr)         :=  i.old_instantiation_flag ;
      l_inst_hist_rec_tab.new_instantiation_flag(l_ctr)         :=  i.new_instantiation_flag ;
      l_inst_hist_rec_tab.old_linear_location_id(l_ctr)         :=  i.old_linear_location_id ;
      l_inst_hist_rec_tab.new_linear_location_id(l_ctr)         :=  i.new_linear_location_id ;
      l_inst_hist_rec_tab.old_operational_log_flag(l_ctr)       :=  i.old_operational_log_flag ;
      l_inst_hist_rec_tab.new_operational_log_flag(l_ctr)       :=  i.new_operational_log_flag ;
      l_inst_hist_rec_tab.old_checkin_status(l_ctr)             :=  i.old_checkin_status ;
      l_inst_hist_rec_tab.new_checkin_status(l_ctr)             :=  i.new_checkin_status ;
      l_inst_hist_rec_tab.old_supplier_warranty_exp_date(l_ctr) :=  i.old_supplier_warranty_exp_date ;
      l_inst_hist_rec_tab.new_supplier_warranty_exp_date(l_ctr) :=  i.new_supplier_warranty_exp_date ;
      l_inst_hist_rec_tab.old_inst_attribute16(l_ctr)           :=  i.old_attribute16;
      l_inst_hist_rec_tab.new_inst_attribute16(l_ctr)           :=  i.new_attribute16;
      l_inst_hist_rec_tab.old_inst_attribute17(l_ctr)           :=  i.old_attribute17;
      l_inst_hist_rec_tab.new_inst_attribute17(l_ctr)           :=  i.new_attribute17;
      l_inst_hist_rec_tab.old_inst_attribute18(l_ctr)           :=  i.old_attribute18;
      l_inst_hist_rec_tab.new_inst_attribute18(l_ctr)           :=  i.new_attribute18;
      l_inst_hist_rec_tab.old_inst_attribute19(l_ctr)           :=  i.old_attribute19;
      l_inst_hist_rec_tab.new_inst_attribute19(l_ctr)           :=  i.new_attribute19;
      l_inst_hist_rec_tab.old_inst_attribute20(l_ctr)           :=  i.old_attribute20;
      l_inst_hist_rec_tab.new_inst_attribute20(l_ctr)           :=  i.new_attribute20;
      l_inst_hist_rec_tab.old_inst_attribute21(l_ctr)           :=  i.old_attribute21;
      l_inst_hist_rec_tab.new_inst_attribute21(l_ctr)           :=  i.new_attribute21;
      l_inst_hist_rec_tab.old_inst_attribute22(l_ctr)           :=  i.old_attribute22;
      l_inst_hist_rec_tab.new_inst_attribute22(l_ctr)           :=  i.new_attribute22;
      l_inst_hist_rec_tab.old_inst_attribute23(l_ctr)           :=  i.old_attribute23;
      l_inst_hist_rec_tab.new_inst_attribute23(l_ctr)           :=  i.new_attribute23;
      l_inst_hist_rec_tab.old_inst_attribute24(l_ctr)           :=  i.old_attribute24;
      l_inst_hist_rec_tab.new_inst_attribute24(l_ctr)           :=  i.new_attribute24;
      l_inst_hist_rec_tab.old_inst_attribute25(l_ctr)           :=  i.old_attribute25;
      l_inst_hist_rec_tab.new_inst_attribute25(l_ctr)           :=  i.new_attribute25;
      l_inst_hist_rec_tab.old_inst_attribute26(l_ctr)           :=  i.old_attribute26;
      l_inst_hist_rec_tab.new_inst_attribute26(l_ctr)           :=  i.new_attribute26;
      l_inst_hist_rec_tab.old_inst_attribute27(l_ctr)           :=  i.old_attribute27;
      l_inst_hist_rec_tab.new_inst_attribute27(l_ctr)           :=  i.new_attribute27;
      l_inst_hist_rec_tab.old_inst_attribute28(l_ctr)           :=  i.old_attribute28;
      l_inst_hist_rec_tab.new_inst_attribute28(l_ctr)           :=  i.new_attribute28;
      l_inst_hist_rec_tab.old_inst_attribute29(l_ctr)           :=  i.old_attribute29;
      l_inst_hist_rec_tab.new_inst_attribute29(l_ctr)           :=  i.new_attribute29;
      l_inst_hist_rec_tab.old_inst_attribute30(l_ctr)           :=  i.old_attribute30;
      l_inst_hist_rec_tab.new_inst_attribute30(l_ctr)           :=  i.new_attribute30;
      -- End addition for eam

   End Loop;

      l_cnt := l_inst_hist_rec_tab.instance_history_id.count;
      Debug('');
      Debug('');
      Debug('Number of Instance history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
--      Debug('Seq val is '||to_char(l_archive_id_tbl(l_cnt)));
--      Debug('Srl count is '||to_char(l_inst_hist_rec_tab.new_serial_number.count));
--      Debug('Install Date count is '||to_char(l_inst_hist_rec_tab.new_install_date.count));
   --
   If l_cnt > 0 Then

   -- Archive the Instance History Data for the Transaction range
      FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
           HISTORY_ARCHIVE_ID
          ,OBJECT_ID
          ,ENTITY_HISTORY_ID
          ,TRANSACTION_ID
          ,ENTITY_ID
          ,COL_NUM_01
          ,COL_NUM_02
          ,COL_NUM_03
          ,COL_NUM_04
          ,COL_NUM_05
          ,COL_NUM_06
          ,COL_NUM_07
          ,COL_NUM_08
          ,COL_NUM_09
          ,COL_NUM_10
          ,COL_NUM_11
          ,COL_NUM_12
          ,COL_NUM_13
          ,COL_NUM_14
          ,COL_NUM_15
          ,COL_NUM_16
          ,COL_NUM_17
          ,COL_NUM_18
          ,COL_NUM_19
          ,COL_NUM_20
          ,COL_NUM_21
          ,COL_NUM_22
          ,COL_NUM_23
          ,COL_NUM_24
          ,COL_NUM_25
          ,COL_NUM_26
          ,COL_NUM_27
          ,COL_NUM_28
          ,COL_NUM_29
          ,COL_NUM_30
          ,COL_NUM_31
          ,COL_NUM_32
          ,COL_NUM_33
          ,COL_NUM_34
          ,COL_NUM_35
          ,COL_NUM_36
          ,COL_NUM_37 -- entity creation_by
          ,COL_NUM_38 -- entity last_updated_by
          ,COL_NUM_39 -- entity last_update_login
          ,COL_NUM_40 -- entity object_version_number
          ,COL_NUM_41 -- entity security_group_id

          ,COL_NUM_42 -- entity old_pn_location_id
          ,COL_NUM_43 -- entity new_pn_location_id
          ,COL_NUM_44 -- entity old_category_id
          ,COL_NUM_45 -- entity new_category_id
          ,COL_NUM_46 -- entity old_equipment_gen_object_id
          ,COL_NUM_47 -- entity new_equipment_gen_object_id
          ,COL_NUM_48 -- entity old_linear_location_id
          ,COL_NUM_49 -- entity new_linear_location_id
          ,COL_NUM_50 -- entity old_checkin_status
          ,COL_NUM_51 -- entity new_checkin_status

          ,COL_CHAR_01
          ,COL_CHAR_02
          ,COL_CHAR_03
          ,COL_CHAR_04
          ,COL_CHAR_05
          ,COL_CHAR_06
          ,COL_CHAR_07
          ,COL_CHAR_08
          ,COL_CHAR_09
          ,COL_CHAR_10
          ,COL_CHAR_11
          ,COL_CHAR_12
          ,COL_CHAR_13
          ,COL_CHAR_14
          ,COL_CHAR_15
          ,COL_CHAR_16
          ,COL_CHAR_17
          ,COL_CHAR_18
          ,COL_CHAR_19
          ,COL_CHAR_20
          ,COL_CHAR_21
          ,COL_CHAR_22
          ,COL_CHAR_23
          ,COL_CHAR_24
          ,COL_CHAR_25
          ,COL_CHAR_26
          ,COL_CHAR_27
          ,COL_CHAR_28
          ,COL_CHAR_29
          ,COL_CHAR_30
          ,COL_CHAR_31 -- entity old_context
          ,COL_CHAR_32 -- entity new_context
          ,COL_CHAR_33 -- entity old_attribute1
          ,COL_CHAR_34 -- entity new_attribute1
          ,COL_CHAR_35 -- entity old_attribute2
          ,COL_CHAR_36 -- entity new_attribute2
          ,COL_CHAR_37 -- entity old_attribute3
          ,COL_CHAR_38 -- entity new_attribute3
          ,COL_CHAR_39 -- entity old_attribute4
          ,COL_CHAR_40 -- entity new_attribute4
          ,COL_CHAR_41 -- entity old_attribute5
          ,COL_CHAR_42 -- entity new_attribute5
          ,COL_CHAR_43 -- entity old_attribute6
          ,COL_CHAR_44 -- entity new_attribute6
          ,COL_CHAR_45 -- entity old_attribute7
          ,COL_CHAR_46 -- entity new_attribute7
          ,COL_CHAR_47 -- entity old_attribute8
          ,COL_CHAR_48 -- entity new_attribute8
          ,COL_CHAR_49 -- entity old_attribute9
          ,COL_CHAR_50 -- entity new_attribute9
          ,COL_CHAR_51 -- entity old_attribute10
          ,COL_CHAR_52 -- entity new_attribute10
          ,COL_CHAR_53 -- entity old_attribute11
          ,COL_CHAR_54 -- entity new_attribute11
          ,COL_CHAR_55 -- entity old_attribute12
          ,COL_CHAR_56 -- entity new_attribute12
          ,COL_CHAR_57 -- entity old_attribute13
          ,COL_CHAR_58 -- entity new_attribute13
          ,COL_CHAR_59 -- entity old_attribute14
          ,COL_CHAR_60 -- entity new_attribute14
          ,COL_CHAR_61 -- entity old_attribute15
          ,COL_CHAR_62 -- entity new_attribute15
          ,COL_CHAR_63
          ,COL_CHAR_64
          ,COL_CHAR_65
          ,COL_CHAR_66
          ,COL_CHAR_67
          ,COL_CHAR_68
          ,COL_CHAR_69
          ,COL_CHAR_70
          ,COL_CHAR_71 -- entity full_dump_flag
          ,COL_CHAR_72 -- entity migrated_flag

          ,COL_CHAR_73 -- entity old_attribute16
          ,COL_CHAR_74 -- entity new_attribute16
          ,COL_CHAR_75 -- entity old_attribute17
          ,COL_CHAR_76 -- entity new_attribute17
          ,COL_CHAR_77 -- entity old_attribute18
          ,COL_CHAR_78 -- entity new_attribute18
          ,COL_CHAR_79 -- entity old_attribute19
          ,COL_CHAR_80 -- entity new_attribute19
          ,COL_CHAR_81 -- entity old_attribute20
          ,COL_CHAR_82 -- entity new_attribute20
          ,COL_CHAR_83 -- entity old_attribute21
          ,COL_CHAR_84 -- entity new_attribute21
          ,COL_CHAR_85 -- entity old_attribute22
          ,COL_CHAR_86 -- entity new_attribute22
          ,COL_CHAR_87 -- entity old_attribute23
          ,COL_CHAR_88 -- entity new_attribute23
          ,COL_CHAR_89 -- entity old_attribute24
          ,COL_CHAR_90 -- entity new_attribute24
          ,COL_CHAR_91 -- entity old_attribute25
          ,COL_CHAR_92 -- entity new_attribute25
          ,COL_CHAR_93 -- entity old_attribute26
          ,COL_CHAR_94 -- entity new_attribute26
          ,COL_CHAR_95 -- entity old_attribute27
          ,COL_CHAR_96 -- entity new_attribute27
          ,COL_CHAR_97 -- entity old_attribute28
          ,COL_CHAR_98 -- entity new_attribute28
          ,COL_CHAR_99 -- entity old_attribute29
          ,COL_CHAR_100 -- entity new_attribute29
          ,COL_CHAR_101 -- entity old_attribute30
          ,COL_CHAR_102 -- entity new_attribute30

          ,COL_CHAR_103 -- entity old_network_asset_flag
          ,COL_CHAR_104 -- entity new_network_asset_flag
          ,COL_CHAR_105 -- entity old_maintainable_flag
          ,COL_CHAR_106 -- entity new_maintainable_flag
          ,COL_CHAR_107 -- entity old_asset_criticality_code
          ,COL_CHAR_108 -- entity new_asset_criticality_code
          ,COL_CHAR_109 -- entity old_instantiation_flag
          ,COL_CHAR_110 -- entity new_instantiation_flag
          ,COL_CHAR_111 -- entity old_operational_log_flag
          ,COL_CHAR_112 -- entity new_operational_log_flag

          ,COL_DATE_01  -- entity old_active_start_date
          ,COL_DATE_02  -- entity new_active_start_date
          ,COL_DATE_03  -- entity old_active_end_date
          ,COL_DATE_04  -- entity new_active_end_date
          ,COL_DATE_05
          ,COL_DATE_06
          ,COL_DATE_07
          ,COL_DATE_08
          ,COL_DATE_09
          ,COL_DATE_10
          ,COL_DATE_11 -- entity creation_date
          ,COL_DATE_12 -- entity last_update_date

          ,COL_DATE_13 -- entity old_supplier_warranty_exp_date
          ,COL_DATE_14 -- entity new_supplier_warranty_exp_date

          ,CONTEXT
          ,ATTRIBUTE1
          ,ATTRIBUTE2
          ,ATTRIBUTE3
          ,ATTRIBUTE4
          ,ATTRIBUTE5
          ,ATTRIBUTE6
          ,ATTRIBUTE7
          ,ATTRIBUTE8
          ,ATTRIBUTE9
          ,ATTRIBUTE10
          ,ATTRIBUTE11
          ,ATTRIBUTE12
          ,ATTRIBUTE13
          ,ATTRIBUTE14
          ,ATTRIBUTE15
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER
          ,SECURITY_GROUP_ID
          )
		  Values
          (
          l_archive_id_tbl(i),
          l_table_id,
	 	  l_inst_hist_rec_tab.instance_history_id(i),
		  l_inst_hist_rec_tab.transaction_id(i),
		  l_inst_hist_rec_tab.instance_id(i),
		  l_inst_hist_rec_tab.old_inventory_item_id(i),
		  l_inst_hist_rec_tab.new_inventory_item_id(i),
		  l_inst_hist_rec_tab.old_inv_master_org_id(i),
		  l_inst_hist_rec_tab.new_inv_master_org_id(i),
		  l_inst_hist_rec_tab.old_quantity(i),
		  l_inst_hist_rec_tab.new_quantity(i),
		  l_inst_hist_rec_tab.old_instance_condition_id(i),
		  l_inst_hist_rec_tab.new_instance_condition_id(i),
		  l_inst_hist_rec_tab.old_instance_status_id(i),
		  l_inst_hist_rec_tab.new_instance_status_id(i),
		  l_inst_hist_rec_tab.old_system_id(i),
		  l_inst_hist_rec_tab.new_system_id(i),
		  l_inst_hist_rec_tab.old_location_id(i),
		  l_inst_hist_rec_tab.new_location_id(i),
		  l_inst_hist_rec_tab.old_inv_organization_id(i),
		  l_inst_hist_rec_tab.new_inv_organization_id(i),
		  l_inst_hist_rec_tab.old_inv_locator_id(i),
		  l_inst_hist_rec_tab.new_inv_locator_id(i),
		  l_inst_hist_rec_tab.old_pa_project_id(i),
		  l_inst_hist_rec_tab.new_pa_project_id(i),
		  l_inst_hist_rec_tab.old_pa_project_task_id(i),
		  l_inst_hist_rec_tab.new_pa_project_task_id(i),
		  l_inst_hist_rec_tab.old_in_transit_order_line_id(i),
		  l_inst_hist_rec_tab.new_in_transit_order_line_id(i),
		  l_inst_hist_rec_tab.old_wip_job_id(i),
		  l_inst_hist_rec_tab.new_wip_job_id(i),
		  l_inst_hist_rec_tab.old_po_order_line_id(i),
		  l_inst_hist_rec_tab.new_po_order_line_id(i),
		  l_inst_hist_rec_tab.old_install_location_id(i),
		  l_inst_hist_rec_tab.new_install_location_id(i),
		  l_inst_hist_rec_tab.old_last_vld_organization_id(i),
		  l_inst_hist_rec_tab.new_last_vld_organization_id(i),
          l_inst_hist_rec_tab.old_last_oe_agreement_id(i),
          l_inst_hist_rec_tab.new_last_oe_agreement_id(i),
		  l_inst_hist_rec_tab.old_config_inst_rev_num(i),
		  l_inst_hist_rec_tab.new_config_inst_rev_num(i),
   		  l_inst_hist_rec_tab.inst_created_by(i),
   		  l_inst_hist_rec_tab.inst_last_updated_by(i),
   		  l_inst_hist_rec_tab.inst_last_update_login(i),
   		  l_inst_hist_rec_tab.inst_object_version_number(i),
   		  l_inst_hist_rec_tab.inst_security_group_id(i),
          -- Added for eam
          l_inst_hist_rec_tab.old_pn_location_id(i),
          l_inst_hist_rec_tab.new_pn_location_id(i),
          l_inst_hist_rec_tab.old_category_id(i),
          l_inst_hist_rec_tab.new_category_id(i),
          l_inst_hist_rec_tab.old_equipment_gen_object_id(i),
          l_inst_hist_rec_tab.new_equipment_gen_object_id(i),
          l_inst_hist_rec_tab.old_linear_location_id(i),
          l_inst_hist_rec_tab.new_linear_location_id(i),
          l_inst_hist_rec_tab.old_checkin_status(i),
          l_inst_hist_rec_tab.new_checkin_status(i),
          -- End addition for eam
		  l_inst_hist_rec_tab.old_instance_number(i),
		  l_inst_hist_rec_tab.new_instance_number(i),
		  l_inst_hist_rec_tab.old_external_reference(i),
		  l_inst_hist_rec_tab.new_external_reference(i),
		  l_inst_hist_rec_tab.old_inventory_revision(i),
		  l_inst_hist_rec_tab.new_inventory_revision(i),
		  l_inst_hist_rec_tab.old_serial_number(i),
		  l_inst_hist_rec_tab.new_serial_number(i),
		  l_inst_hist_rec_tab.old_mfg_serial_number_flag(i),
		  l_inst_hist_rec_tab.new_mfg_serial_number_flag(i),
		  l_inst_hist_rec_tab.old_lot_number(i),
		  l_inst_hist_rec_tab.new_lot_number(i),
		  l_inst_hist_rec_tab.old_unit_of_measure(i),
		  l_inst_hist_rec_tab.new_unit_of_measure(i),
		  l_inst_hist_rec_tab.old_accounting_class_code(i),
		  l_inst_hist_rec_tab.new_accounting_class_code(i),
		  l_inst_hist_rec_tab.old_customer_view_flag(i),
		  l_inst_hist_rec_tab.new_customer_view_flag(i),
		  l_inst_hist_rec_tab.old_merchant_view_flag(i),
		  l_inst_hist_rec_tab.new_merchant_view_flag(i),
		  l_inst_hist_rec_tab.old_sellable_flag(i),
		  l_inst_hist_rec_tab.new_sellable_flag(i),
		  l_inst_hist_rec_tab.old_instance_type_code(i),
		  l_inst_hist_rec_tab.new_instance_type_code(i),
		  l_inst_hist_rec_tab.old_location_type_code(i),
		  l_inst_hist_rec_tab.new_location_type_code(i),
		  l_inst_hist_rec_tab.old_inv_subinventory_name(i),
		  l_inst_hist_rec_tab.new_inv_subinventory_name(i),
		  l_inst_hist_rec_tab.old_completeness_flag(i),
		  l_inst_hist_rec_tab.new_completeness_flag(i),
		  l_inst_hist_rec_tab.old_inst_context(i),
		  l_inst_hist_rec_tab.new_inst_context(i),
		  l_inst_hist_rec_tab.old_inst_attribute1(i),
		  l_inst_hist_rec_tab.new_inst_attribute1(i),
		  l_inst_hist_rec_tab.old_inst_attribute2(i),
		  l_inst_hist_rec_tab.new_inst_attribute2(i),
		  l_inst_hist_rec_tab.old_inst_attribute3(i),
		  l_inst_hist_rec_tab.new_inst_attribute3(i),
		  l_inst_hist_rec_tab.old_inst_attribute4(i),
		  l_inst_hist_rec_tab.new_inst_attribute4(i),
		  l_inst_hist_rec_tab.old_inst_attribute5(i),
		  l_inst_hist_rec_tab.new_inst_attribute5(i),
		  l_inst_hist_rec_tab.old_inst_attribute6(i),
		  l_inst_hist_rec_tab.new_inst_attribute6(i),
		  l_inst_hist_rec_tab.old_inst_attribute7(i),
		  l_inst_hist_rec_tab.new_inst_attribute7(i),
		  l_inst_hist_rec_tab.old_inst_attribute8(i),
		  l_inst_hist_rec_tab.new_inst_attribute8(i),
		  l_inst_hist_rec_tab.old_inst_attribute9(i),
		  l_inst_hist_rec_tab.new_inst_attribute9(i),
		  l_inst_hist_rec_tab.old_inst_attribute10(i),
		  l_inst_hist_rec_tab.new_inst_attribute10(i),
		  l_inst_hist_rec_tab.old_inst_attribute11(i),
		  l_inst_hist_rec_tab.new_inst_attribute11(i),
		  l_inst_hist_rec_tab.old_inst_attribute12(i),
		  l_inst_hist_rec_tab.new_inst_attribute12(i),
		  l_inst_hist_rec_tab.old_inst_attribute13(i),
		  l_inst_hist_rec_tab.new_inst_attribute13(i),
		  l_inst_hist_rec_tab.old_inst_attribute14(i),
		  l_inst_hist_rec_tab.new_inst_attribute14(i),
		  l_inst_hist_rec_tab.old_inst_attribute15(i),
		  l_inst_hist_rec_tab.new_inst_attribute15(i),
		  l_inst_hist_rec_tab.old_install_location_type_code(i),
		  l_inst_hist_rec_tab.new_install_location_type_code(i),
		  l_inst_hist_rec_tab.old_instance_usage_code(i),
		  l_inst_hist_rec_tab.new_instance_usage_code(i),
		  l_inst_hist_rec_tab.old_config_valid_status(i),
		  l_inst_hist_rec_tab.new_config_valid_status(i),
		  l_inst_hist_rec_tab.old_instance_description(i),
		  l_inst_hist_rec_tab.new_instance_description(i),
		  l_inst_hist_rec_tab.inst_full_dump_flag(i),
   		  l_inst_hist_rec_tab.inst_migrated_flag(i),
       -- Added for eam
          l_inst_hist_rec_tab.old_inst_attribute16(i),
          l_inst_hist_rec_tab.new_inst_attribute16(i),
          l_inst_hist_rec_tab.old_inst_attribute17(i),
          l_inst_hist_rec_tab.new_inst_attribute17(i),
          l_inst_hist_rec_tab.old_inst_attribute18(i),
          l_inst_hist_rec_tab.new_inst_attribute18(i),
          l_inst_hist_rec_tab.old_inst_attribute19(i),
          l_inst_hist_rec_tab.new_inst_attribute19(i),
          l_inst_hist_rec_tab.old_inst_attribute20(i),
          l_inst_hist_rec_tab.new_inst_attribute20(i),
          l_inst_hist_rec_tab.old_inst_attribute21(i),
          l_inst_hist_rec_tab.new_inst_attribute21(i),
          l_inst_hist_rec_tab.old_inst_attribute22(i),
          l_inst_hist_rec_tab.new_inst_attribute22(i),
          l_inst_hist_rec_tab.old_inst_attribute23(i),
          l_inst_hist_rec_tab.new_inst_attribute23(i),
          l_inst_hist_rec_tab.old_inst_attribute24(i),
          l_inst_hist_rec_tab.new_inst_attribute24(i),
          l_inst_hist_rec_tab.old_inst_attribute25(i),
          l_inst_hist_rec_tab.new_inst_attribute25(i),
          l_inst_hist_rec_tab.old_inst_attribute26(i),
          l_inst_hist_rec_tab.new_inst_attribute26(i),
          l_inst_hist_rec_tab.old_inst_attribute27(i),
          l_inst_hist_rec_tab.new_inst_attribute27(i),
          l_inst_hist_rec_tab.old_inst_attribute28(i),
          l_inst_hist_rec_tab.new_inst_attribute28(i),
          l_inst_hist_rec_tab.old_inst_attribute29(i),
          l_inst_hist_rec_tab.new_inst_attribute29(i),
          l_inst_hist_rec_tab.old_inst_attribute30(i),
          l_inst_hist_rec_tab.new_inst_attribute30(i),

          l_inst_hist_rec_tab.old_network_asset_flag(i),
          l_inst_hist_rec_tab.new_network_asset_flag(i),
          l_inst_hist_rec_tab.old_maintainable_flag(i),
          l_inst_hist_rec_tab.new_maintainable_flag(i),
          l_inst_hist_rec_tab.old_asset_criticality_code(i),
          l_inst_hist_rec_tab.new_asset_criticality_code(i),
          l_inst_hist_rec_tab.old_instantiation_flag(i),
          l_inst_hist_rec_tab.new_instantiation_flag(i),
          l_inst_hist_rec_tab.old_operational_log_flag(i),
          l_inst_hist_rec_tab.new_operational_log_flag(i),

       -- End addition for eam
		  l_inst_hist_rec_tab.old_active_start_date(i),
		  l_inst_hist_rec_tab.new_active_start_date(i),
		  l_inst_hist_rec_tab.old_active_end_date(i),
		  l_inst_hist_rec_tab.new_active_end_date(i),
          l_inst_hist_rec_tab.old_install_date(i),
          l_inst_hist_rec_tab.new_install_date(i),
          l_inst_hist_rec_tab.old_return_by_date(i),
          l_inst_hist_rec_tab.new_return_by_date(i),
          l_inst_hist_rec_tab.old_actual_return_date(i),
          l_inst_hist_rec_tab.new_actual_return_date(i),
   		  l_inst_hist_rec_tab.inst_creation_date(i),
   		  l_inst_hist_rec_tab.inst_last_update_date(i),
          -- Added for eam
          l_inst_hist_rec_tab.old_supplier_warranty_exp_date(i),
          l_inst_hist_rec_tab.new_supplier_warranty_exp_date(i),
          -- End addition for eam
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          l_user_id,
          sysdate,
          l_user_id,
          sysdate,
          l_login_id,
          1,
          null
         );

      -- Purge the corresonding Archive data from the Instance history tables

      FORALL i IN 1 .. l_cnt

         Delete From CSI_ITEM_INSTANCES_H
         Where instance_history_id = l_inst_hist_rec_tab.instance_history_id(i);

      -- Update csi_item instances table with the last transaction history purged date

      FORALL i IN 1 .. l_cnt

         Update CSI_ITEM_INSTANCES
         Set last_purge_date = to_date(purge_to_date,'YYYY/MM/DD HH24:MI:SS')
         Where instance_id = l_inst_hist_rec_tab.instance_id(i);

   End If; -- if l_cnt > 0
   --
   Exit When from_trans = to_trans;
   Exit When v_end = to_trans;
   --
  v_start := v_end + 1;
  v_end   := v_start + v_batch;
  --
 If v_start > to_trans Then
    v_start := to_trans;
 End If;
 --
 If v_end > to_trans then
    v_end := to_trans;
 End If;
 --
 Commit;
 --
 Exception
  When Others Then
   Debug(substr(sqlerrm,1,255));
   Rollback to Instance_Archive;
 End;
End Loop; -- Local Batch Loop
Commit;
--
END; -- End of Procedure Instance_Archive
--
--
--
--
-- This program is used to archive the Instance Party history. It accepts from  transactions
-- as the input parameters.
--

PROCEDURE party_archive( errbuf       OUT NOCOPY VARCHAR2,
                         retcode      OUT NOCOPY NUMBER,
                         from_trans   IN  NUMBER,
                         to_trans     IN  NUMBER,
                         purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NumList IS Table Of Number Index By Binary_Integer;
    l_archive_id_tbl   NUMLIST;

    Cursor pty_hist_csr (p_from_trans IN NUMBER,
                         p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_I_PARTIES_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_pty_hist_csr          pty_hist_csr%RowType;
    l_pty_hist_rec_tab      csi_txn_history_purge_pvt.party_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_I_PARTIES_H';
    Exception
      When no_data_found Then
        l_table_id := 2;
      When others Then
        l_table_id := 2;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Party_Archive;
      l_ctr := 0;
      --
      l_pty_hist_rec_tab.instance_party_history_id.DELETE;
      l_pty_hist_rec_tab.instance_party_id.DELETE;
      l_pty_hist_rec_tab.transaction_id.DELETE;
      l_pty_hist_rec_tab.old_party_source_table.DELETE;
      l_pty_hist_rec_tab.new_party_source_table.DELETE;
      l_pty_hist_rec_tab.old_party_id.DELETE;
      l_pty_hist_rec_tab.new_party_id.DELETE;
      l_pty_hist_rec_tab.old_relationship_type_code.DELETE;
      l_pty_hist_rec_tab.new_relationship_type_code.DELETE;
      l_pty_hist_rec_tab.old_contact_flag.DELETE;
      l_pty_hist_rec_tab.new_contact_flag.DELETE;
      l_pty_hist_rec_tab.old_contact_ip_id.DELETE;
      l_pty_hist_rec_tab.new_contact_ip_id.DELETE;
      l_pty_hist_rec_tab.old_active_start_date.DELETE;
      l_pty_hist_rec_tab.new_active_start_date.DELETE;
      l_pty_hist_rec_tab.old_active_end_date.DELETE;
      l_pty_hist_rec_tab.new_active_end_date.DELETE;
      l_pty_hist_rec_tab.old_context.DELETE;
      l_pty_hist_rec_tab.new_context.DELETE;
      l_pty_hist_rec_tab.old_attribute1.DELETE;
      l_pty_hist_rec_tab.new_attribute1.DELETE;
      l_pty_hist_rec_tab.old_attribute2.DELETE;
      l_pty_hist_rec_tab.new_attribute2.DELETE;
      l_pty_hist_rec_tab.old_attribute3.DELETE;
      l_pty_hist_rec_tab.new_attribute3.DELETE;
      l_pty_hist_rec_tab.old_attribute4.DELETE;
      l_pty_hist_rec_tab.new_attribute4.DELETE;
      l_pty_hist_rec_tab.old_attribute5.DELETE;
      l_pty_hist_rec_tab.new_attribute5.DELETE;
      l_pty_hist_rec_tab.old_attribute6.DELETE;
      l_pty_hist_rec_tab.new_attribute6.DELETE;
      l_pty_hist_rec_tab.old_attribute7.DELETE;
      l_pty_hist_rec_tab.new_attribute7.DELETE;
      l_pty_hist_rec_tab.old_attribute8.DELETE;
      l_pty_hist_rec_tab.new_attribute8.DELETE;
      l_pty_hist_rec_tab.old_attribute9.DELETE;
      l_pty_hist_rec_tab.new_attribute9.DELETE;
      l_pty_hist_rec_tab.old_attribute10.DELETE;
      l_pty_hist_rec_tab.new_attribute10.DELETE;
      l_pty_hist_rec_tab.old_attribute11.DELETE;
      l_pty_hist_rec_tab.new_attribute11.DELETE;
      l_pty_hist_rec_tab.old_attribute12.DELETE;
      l_pty_hist_rec_tab.new_attribute12.DELETE;
      l_pty_hist_rec_tab.old_attribute13.DELETE;
      l_pty_hist_rec_tab.new_attribute13.DELETE;
      l_pty_hist_rec_tab.old_attribute14.DELETE;
      l_pty_hist_rec_tab.new_attribute14.DELETE;
      l_pty_hist_rec_tab.old_attribute15.DELETE;
      l_pty_hist_rec_tab.new_attribute15.DELETE;
      l_pty_hist_rec_tab.old_preferred_flag.DELETE;
      l_pty_hist_rec_tab.new_preferred_flag.DELETE;
      l_pty_hist_rec_tab.old_primary_flag.DELETE;
      l_pty_hist_rec_tab.new_primary_flag.DELETE;
      l_pty_hist_rec_tab.pty_full_dump_flag.DELETE;
      l_pty_hist_rec_tab.pty_created_by.DELETE;
      l_pty_hist_rec_tab.pty_creation_date.DELETE;
      l_pty_hist_rec_tab.pty_last_updated_by.DELETE;
      l_pty_hist_rec_tab.pty_last_update_date.DELETE;
      l_pty_hist_rec_tab.pty_last_update_login.DELETE;
      l_pty_hist_rec_tab.pty_object_version_number.DELETE;
      l_pty_hist_rec_tab.pty_security_group_id.DELETE;
      l_pty_hist_rec_tab.pty_migrated_flag.DELETE;
      --

  For i in pty_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_pty_hist_rec_tab.instance_party_history_id(l_ctr)  :=  i.instance_party_history_id;
      l_pty_hist_rec_tab.transaction_id(l_ctr)             :=  i.transaction_id;
      l_pty_hist_rec_tab.instance_party_id(l_ctr)          :=  i.instance_party_id;
      l_pty_hist_rec_tab.old_party_source_table(l_ctr)     :=  i.old_party_source_table;
      l_pty_hist_rec_tab.new_party_source_table(l_ctr)     :=  i.new_party_source_table;
      l_pty_hist_rec_tab.old_party_id(l_ctr)               :=  i.old_party_id;
      l_pty_hist_rec_tab.new_party_id(l_ctr)               :=  i.new_party_id;
      l_pty_hist_rec_tab.old_relationship_type_code(l_ctr) :=  i.old_relationship_type_code;
      l_pty_hist_rec_tab.new_relationship_type_code(l_ctr) :=  i.new_relationship_type_code;
      l_pty_hist_rec_tab.old_contact_flag(l_ctr)           :=  i.old_contact_flag;
      l_pty_hist_rec_tab.new_contact_flag(l_ctr)           :=  i.new_contact_flag;
      l_pty_hist_rec_tab.old_contact_ip_id(l_ctr)          :=  i.old_contact_ip_id;
      l_pty_hist_rec_tab.new_contact_ip_id(l_ctr)          :=  i.new_contact_ip_id;
      l_pty_hist_rec_tab.old_active_start_date(l_ctr)      :=  i.old_active_start_date;
      l_pty_hist_rec_tab.new_active_start_date(l_ctr)      :=  i.new_active_start_date;
      l_pty_hist_rec_tab.old_active_end_date(l_ctr)        :=  i.old_active_end_date;
      l_pty_hist_rec_tab.new_active_end_date(l_ctr)        :=  i.new_active_end_date;
      l_pty_hist_rec_tab.old_context(l_ctr)	               :=  i.old_context;
      l_pty_hist_rec_tab.new_context(l_ctr)	               :=  i.new_context;
      l_pty_hist_rec_tab.old_attribute1(l_ctr)	           :=  i.old_attribute1;
      l_pty_hist_rec_tab.new_attribute1(l_ctr)	           :=  i.new_attribute1;
      l_pty_hist_rec_tab.old_attribute2(l_ctr)	           :=  i.old_attribute2;
      l_pty_hist_rec_tab.new_attribute2(l_ctr)	           :=  i.new_attribute2;
      l_pty_hist_rec_tab.old_attribute3(l_ctr)	           :=  i.old_attribute3;
      l_pty_hist_rec_tab.new_attribute3(l_ctr)	           :=  i.new_attribute3;
      l_pty_hist_rec_tab.old_attribute4(l_ctr)	           :=  i.old_attribute4;
      l_pty_hist_rec_tab.new_attribute4(l_ctr)	           :=  i.new_attribute4;
      l_pty_hist_rec_tab.old_attribute5(l_ctr)	           :=  i.old_attribute5;
      l_pty_hist_rec_tab.new_attribute5(l_ctr)	           :=  i.new_attribute5;
      l_pty_hist_rec_tab.old_attribute6(l_ctr)	           :=  i.old_attribute6;
      l_pty_hist_rec_tab.new_attribute6(l_ctr)	           :=  i.new_attribute6;
      l_pty_hist_rec_tab.old_attribute7(l_ctr)	           :=  i.old_attribute7;
      l_pty_hist_rec_tab.new_attribute7(l_ctr)	           :=  i.new_attribute7;
      l_pty_hist_rec_tab.old_attribute8(l_ctr)	           :=  i.old_attribute8;
      l_pty_hist_rec_tab.new_attribute8(l_ctr)	           :=  i.new_attribute8;
      l_pty_hist_rec_tab.old_attribute9(l_ctr)	           :=  i.old_attribute9;
      l_pty_hist_rec_tab.new_attribute9(l_ctr)	           :=  i.new_attribute9;
      l_pty_hist_rec_tab.old_attribute10(l_ctr)	           :=  i.old_attribute10;
      l_pty_hist_rec_tab.new_attribute10(l_ctr)	           :=  i.new_attribute10;
      l_pty_hist_rec_tab.old_attribute11(l_ctr)      	   :=  i.old_attribute11;
      l_pty_hist_rec_tab.new_attribute11(l_ctr)	           :=  i.new_attribute11;
      l_pty_hist_rec_tab.old_attribute12(l_ctr)	           :=  i.old_attribute12;
      l_pty_hist_rec_tab.new_attribute12(l_ctr)	           :=  i.new_attribute12;
      l_pty_hist_rec_tab.old_attribute13(l_ctr)	           :=  i.old_attribute13;
      l_pty_hist_rec_tab.new_attribute13(l_ctr)	           :=  i.new_attribute13;
      l_pty_hist_rec_tab.old_attribute14(l_ctr)	           :=  i.old_attribute14;
      l_pty_hist_rec_tab.new_attribute14(l_ctr)	           :=  i.new_attribute14;
      l_pty_hist_rec_tab.old_attribute15(l_ctr)	           :=  i.old_attribute15;
      l_pty_hist_rec_tab.new_attribute15(l_ctr)	           :=  i.new_attribute15;
      l_pty_hist_rec_tab.old_preferred_flag(l_ctr)	       :=  i.old_preferred_flag;
      l_pty_hist_rec_tab.new_preferred_flag(l_ctr)	       :=  i.new_preferred_flag;
      l_pty_hist_rec_tab.old_primary_flag(l_ctr)	       :=  i.old_primary_flag;
      l_pty_hist_rec_tab.new_primary_flag(l_ctr)	       :=  i.new_primary_flag;
      l_pty_hist_rec_tab.pty_full_dump_flag(l_ctr)         :=  i.full_dump_flag;
      l_pty_hist_rec_tab.pty_created_by(l_ctr)             :=  i.created_by;
      l_pty_hist_rec_tab.pty_creation_date(l_ctr)          :=  i.creation_date;
      l_pty_hist_rec_tab.pty_last_updated_by(l_ctr)        :=  i.last_updated_by;
      l_pty_hist_rec_tab.pty_last_update_date(l_ctr)       :=  i.last_update_date;
      l_pty_hist_rec_tab.pty_last_update_login(l_ctr)      :=  i.last_update_login;
      l_pty_hist_rec_tab.pty_object_version_number(l_ctr)  :=  i.object_version_number;
      l_pty_hist_rec_tab.pty_security_group_id(l_ctr)      :=  i.security_group_id;
      l_pty_hist_rec_tab.pty_migrated_flag(l_ctr)          :=  i.migrated_flag;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_pty_hist_rec_tab.instance_party_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Instance Party history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_01
           ,COL_NUM_02
           ,COL_NUM_03
           ,COL_NUM_04
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_03
           ,COL_CHAR_04
           ,COL_CHAR_05
           ,COL_CHAR_06
           ,COL_CHAR_07
           ,COL_CHAR_08
           ,COL_CHAR_09
           ,COL_CHAR_10
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_pty_hist_rec_tab.instance_party_history_id(i),
           l_pty_hist_rec_tab.transaction_id(i),
           l_pty_hist_rec_tab.instance_party_id(i),
           l_pty_hist_rec_tab.old_party_id(i),
           l_pty_hist_rec_tab.new_party_id(i),
           l_pty_hist_rec_tab.old_contact_ip_id(i),
           l_pty_hist_rec_tab.new_contact_ip_id(i),
           l_pty_hist_rec_tab.pty_created_by(i),
           l_pty_hist_rec_tab.pty_last_updated_by(i),
           l_pty_hist_rec_tab.pty_last_update_login(i),
           l_pty_hist_rec_tab.pty_object_version_number(i),
           l_pty_hist_rec_tab.pty_security_group_id(i),
           l_pty_hist_rec_tab.old_party_source_table(i),
           l_pty_hist_rec_tab.new_party_source_table(i),
           l_pty_hist_rec_tab.old_relationship_type_code(i),
           l_pty_hist_rec_tab.new_relationship_type_code(i),
           l_pty_hist_rec_tab.old_contact_flag(i),
           l_pty_hist_rec_tab.new_contact_flag(i),
           l_pty_hist_rec_tab.old_preferred_flag(i),
           l_pty_hist_rec_tab.new_preferred_flag(i),
           l_pty_hist_rec_tab.old_primary_flag(i),
           l_pty_hist_rec_tab.new_primary_flag(i),
           l_pty_hist_rec_tab.old_context(i),
           l_pty_hist_rec_tab.new_context(i),
           l_pty_hist_rec_tab.old_attribute1(i),
           l_pty_hist_rec_tab.new_attribute1(i),
           l_pty_hist_rec_tab.old_attribute2(i),
           l_pty_hist_rec_tab.new_attribute2(i),
           l_pty_hist_rec_tab.old_attribute3(i),
           l_pty_hist_rec_tab.new_attribute3(i),
           l_pty_hist_rec_tab.old_attribute4(i),
           l_pty_hist_rec_tab.new_attribute4(i),
           l_pty_hist_rec_tab.old_attribute5(i),
           l_pty_hist_rec_tab.new_attribute5(i),
           l_pty_hist_rec_tab.old_attribute6(i),
           l_pty_hist_rec_tab.new_attribute6(i),
           l_pty_hist_rec_tab.old_attribute7(i),
           l_pty_hist_rec_tab.new_attribute7(i),
           l_pty_hist_rec_tab.old_attribute8(i),
           l_pty_hist_rec_tab.new_attribute8(i),
           l_pty_hist_rec_tab.old_attribute9(i),
           l_pty_hist_rec_tab.new_attribute9(i),
           l_pty_hist_rec_tab.old_attribute10(i),
           l_pty_hist_rec_tab.new_attribute10(i),
           l_pty_hist_rec_tab.old_attribute11(i),
           l_pty_hist_rec_tab.new_attribute11(i),
           l_pty_hist_rec_tab.old_attribute12(i),
           l_pty_hist_rec_tab.new_attribute12(i),
           l_pty_hist_rec_tab.old_attribute13(i),
           l_pty_hist_rec_tab.new_attribute13(i),
           l_pty_hist_rec_tab.old_attribute14(i),
           l_pty_hist_rec_tab.new_attribute14(i),
           l_pty_hist_rec_tab.old_attribute15(i),
           l_pty_hist_rec_tab.new_attribute15(i),
           l_pty_hist_rec_tab.pty_full_dump_flag(i),
           l_pty_hist_rec_tab.pty_migrated_flag(i),
           l_pty_hist_rec_tab.old_active_start_date(i),
           l_pty_hist_rec_tab.new_active_start_date(i),
           l_pty_hist_rec_tab.old_active_end_date(i),
           l_pty_hist_rec_tab.new_active_end_date(i),
           l_pty_hist_rec_tab.pty_creation_date(i),
           l_pty_hist_rec_tab.pty_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

      -- Purge the corresonding Archive data from the Instance history tables

         FORALL i IN 1 .. l_cnt

          Delete From CSI_I_PARTIES_H
          Where instance_party_history_id = l_pty_hist_rec_tab.instance_party_history_id(i);

      End If; -- if l_cnt > 0
      --
      Exit When from_trans = to_trans;
      Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         DEBUG(substr(sqlerrm,1,255));
         ROLLBACK to Party_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure Instance_Party_Archive


--
-- This program is used to archive the Instance Party history. It accepts from  transactions
-- as the input parameters.
--

PROCEDURE Account_archive( errbuf       OUT NOCOPY VARCHAR2,
                           retcode      OUT NOCOPY NUMBER,
                           from_trans   IN  NUMBER,
                           to_trans     IN  NUMBER,
                           purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor acct_hist_csr (p_from_trans IN NUMBER,
                          p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_IP_ACCOUNTS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_acct_hist_csr         acct_hist_csr%RowType;
    l_acct_hist_rec_tab     csi_txn_history_purge_pvt.account_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_IP_ACCOUNTS_H';
    Exception
      When no_data_found Then
        l_table_id := 3;
      When others Then
        l_table_id := 3;
    End;
    --
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
    Begin
      SAVEPOINT Account_Archive;
      l_ctr := 0;
      --
      l_acct_hist_rec_tab.ip_account_history_id.DELETE;
      l_acct_hist_rec_tab.ip_account_id.DELETE;
      l_acct_hist_rec_tab.transaction_id.DELETE;
      l_acct_hist_rec_tab.old_party_account_id.DELETE;
      l_acct_hist_rec_tab.new_party_account_id.DELETE;
      l_acct_hist_rec_tab.old_relationship_type_code.DELETE;
      l_acct_hist_rec_tab.new_relationship_type_code.DELETE;
      l_acct_hist_rec_tab.old_bill_to_address.DELETE;
      l_acct_hist_rec_tab.new_bill_to_address.DELETE;
      l_acct_hist_rec_tab.old_ship_to_address.DELETE;
      l_acct_hist_rec_tab.new_ship_to_address.DELETE;
      l_acct_hist_rec_tab.old_active_start_date.DELETE;
      l_acct_hist_rec_tab.new_active_start_date.DELETE;
      l_acct_hist_rec_tab.old_active_end_date.DELETE;
      l_acct_hist_rec_tab.new_active_end_date.DELETE;
      l_acct_hist_rec_tab.old_context.DELETE;
      l_acct_hist_rec_tab.new_context.DELETE;
      l_acct_hist_rec_tab.old_attribute1.DELETE;
      l_acct_hist_rec_tab.new_attribute1.DELETE;
      l_acct_hist_rec_tab.old_attribute2.DELETE;
      l_acct_hist_rec_tab.new_attribute2.DELETE;
      l_acct_hist_rec_tab.old_attribute3.DELETE;
      l_acct_hist_rec_tab.new_attribute3.DELETE;
      l_acct_hist_rec_tab.old_attribute4.DELETE;
      l_acct_hist_rec_tab.new_attribute4.DELETE;
      l_acct_hist_rec_tab.old_attribute5.DELETE;
      l_acct_hist_rec_tab.new_attribute5.DELETE;
      l_acct_hist_rec_tab.old_attribute6.DELETE;
      l_acct_hist_rec_tab.new_attribute6.DELETE;
      l_acct_hist_rec_tab.old_attribute7.DELETE;
      l_acct_hist_rec_tab.new_attribute7.DELETE;
      l_acct_hist_rec_tab.old_attribute8.DELETE;
      l_acct_hist_rec_tab.new_attribute8.DELETE;
      l_acct_hist_rec_tab.old_attribute9.DELETE;
      l_acct_hist_rec_tab.new_attribute9.DELETE;
      l_acct_hist_rec_tab.old_attribute10.DELETE;
      l_acct_hist_rec_tab.new_attribute10.DELETE;
      l_acct_hist_rec_tab.old_attribute11.DELETE;
      l_acct_hist_rec_tab.new_attribute11.DELETE;
      l_acct_hist_rec_tab.old_attribute12.DELETE;
      l_acct_hist_rec_tab.new_attribute12.DELETE;
      l_acct_hist_rec_tab.old_attribute13.DELETE;
      l_acct_hist_rec_tab.new_attribute13.DELETE;
      l_acct_hist_rec_tab.old_attribute14.DELETE;
      l_acct_hist_rec_tab.new_attribute14.DELETE;
      l_acct_hist_rec_tab.old_attribute15.DELETE;
      l_acct_hist_rec_tab.new_attribute15.DELETE;
      l_acct_hist_rec_tab.acct_full_dump_flag.DELETE;
      l_acct_hist_rec_tab.acct_created_by.DELETE;
      l_acct_hist_rec_tab.acct_creation_date.DELETE;
      l_acct_hist_rec_tab.acct_last_updated_by.DELETE;
      l_acct_hist_rec_tab.acct_last_update_date.DELETE;
      l_acct_hist_rec_tab.acct_last_update_login.DELETE;
      l_acct_hist_rec_tab.acct_object_version_number.DELETE;
      l_acct_hist_rec_tab.acct_security_group_id.DELETE;
      l_acct_hist_rec_tab.acct_migrated_flag.DELETE;
      l_acct_hist_rec_tab.old_instance_party_id.DELETE;
      l_acct_hist_rec_tab.new_instance_party_id.DELETE;
      --

  For i in acct_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_acct_hist_rec_tab.ip_account_history_id(l_ctr)      :=  i.ip_account_history_id;
      l_acct_hist_rec_tab.ip_account_id(l_ctr)              :=  i.ip_account_id;
      l_acct_hist_rec_tab.transaction_id(l_ctr)             :=  i.transaction_id;
      l_acct_hist_rec_tab.old_party_account_id(l_ctr)       :=  i.old_party_account_id;
      l_acct_hist_rec_tab.new_party_account_id(l_ctr)       :=  i.new_party_account_id;
      l_acct_hist_rec_tab.old_relationship_type_code(l_ctr) :=  i.old_relationship_type_code;
      l_acct_hist_rec_tab.new_relationship_type_code(l_ctr) :=  i.new_relationship_type_code;
      l_acct_hist_rec_tab.old_bill_to_address(l_ctr)        :=  i.old_bill_to_address;
      l_acct_hist_rec_tab.new_bill_to_address(l_ctr)        :=  i.new_bill_to_address;
      l_acct_hist_rec_tab.old_ship_to_address(l_ctr)        :=  i.old_ship_to_address;
      l_acct_hist_rec_tab.new_ship_to_address(l_ctr)        :=  i.new_ship_to_address;
      l_acct_hist_rec_tab.old_active_start_date(l_ctr)      :=  i.old_active_start_date;
      l_acct_hist_rec_tab.new_active_start_date(l_ctr)      :=  i.new_active_start_date;
      l_acct_hist_rec_tab.old_active_end_date(l_ctr)        :=  i.old_active_end_date;
      l_acct_hist_rec_tab.new_active_end_date(l_ctr)        :=  i.new_active_end_date;
      l_acct_hist_rec_tab.old_context(l_ctr)	            :=  i.old_context;
      l_acct_hist_rec_tab.new_context(l_ctr)	            :=  i.new_context;
      l_acct_hist_rec_tab.old_attribute1(l_ctr)	            :=  i.old_attribute1;
      l_acct_hist_rec_tab.new_attribute1(l_ctr)	            :=  i.new_attribute1;
      l_acct_hist_rec_tab.old_attribute2(l_ctr)	            :=  i.old_attribute2;
      l_acct_hist_rec_tab.new_attribute2(l_ctr)	            :=  i.new_attribute2;
      l_acct_hist_rec_tab.old_attribute3(l_ctr)	            :=  i.old_attribute3;
      l_acct_hist_rec_tab.new_attribute3(l_ctr)	            :=  i.new_attribute3;
      l_acct_hist_rec_tab.old_attribute4(l_ctr)	            :=  i.old_attribute4;
      l_acct_hist_rec_tab.new_attribute4(l_ctr)	            :=  i.new_attribute4;
      l_acct_hist_rec_tab.old_attribute5(l_ctr)	            :=  i.old_attribute5;
      l_acct_hist_rec_tab.new_attribute5(l_ctr)	            :=  i.new_attribute5;
      l_acct_hist_rec_tab.old_attribute6(l_ctr)	            :=  i.old_attribute6;
      l_acct_hist_rec_tab.new_attribute6(l_ctr)	            :=  i.new_attribute6;
      l_acct_hist_rec_tab.old_attribute7(l_ctr)	            :=  i.old_attribute7;
      l_acct_hist_rec_tab.new_attribute7(l_ctr)	            :=  i.new_attribute7;
      l_acct_hist_rec_tab.old_attribute8(l_ctr)	            :=  i.old_attribute8;
      l_acct_hist_rec_tab.new_attribute8(l_ctr)	            :=  i.new_attribute8;
      l_acct_hist_rec_tab.old_attribute9(l_ctr)	            :=  i.old_attribute9;
      l_acct_hist_rec_tab.new_attribute9(l_ctr)	            :=  i.new_attribute9;
      l_acct_hist_rec_tab.old_attribute10(l_ctr)	        :=  i.old_attribute10;
      l_acct_hist_rec_tab.new_attribute10(l_ctr)	        :=  i.new_attribute10;
      l_acct_hist_rec_tab.old_attribute11(l_ctr)      	    :=  i.old_attribute11;
      l_acct_hist_rec_tab.new_attribute11(l_ctr)	        :=  i.new_attribute11;
      l_acct_hist_rec_tab.old_attribute12(l_ctr)	        :=  i.old_attribute12;
      l_acct_hist_rec_tab.new_attribute12(l_ctr)	        :=  i.new_attribute12;
      l_acct_hist_rec_tab.old_attribute13(l_ctr)	        :=  i.old_attribute13;
      l_acct_hist_rec_tab.new_attribute13(l_ctr)	        :=  i.new_attribute13;
      l_acct_hist_rec_tab.old_attribute14(l_ctr)	        :=  i.old_attribute14;
      l_acct_hist_rec_tab.new_attribute14(l_ctr)	        :=  i.new_attribute14;
      l_acct_hist_rec_tab.old_attribute15(l_ctr)	        :=  i.old_attribute15;
      l_acct_hist_rec_tab.new_attribute15(l_ctr)	        :=  i.new_attribute15;
      l_acct_hist_rec_tab.acct_full_dump_flag(l_ctr)	    :=  i.full_dump_flag;
      l_acct_hist_rec_tab.acct_created_by(l_ctr)            :=  i.created_by;
      l_acct_hist_rec_tab.acct_creation_date(l_ctr)         :=  i.creation_date;
      l_acct_hist_rec_tab.acct_last_updated_by(l_ctr)       :=  i.last_updated_by;
      l_acct_hist_rec_tab.acct_last_update_date(l_ctr)      :=  i.last_update_date;
      l_acct_hist_rec_tab.acct_last_update_login(l_ctr)     :=  i.last_update_login;
      l_acct_hist_rec_tab.acct_object_version_number(l_ctr)	:=  i.object_version_number;
      l_acct_hist_rec_tab.acct_security_group_id(l_ctr)	    :=  i.security_group_id;
      l_acct_hist_rec_tab.acct_migrated_flag(l_ctr)	        :=  i.migrated_flag;
      l_acct_hist_rec_tab.old_instance_party_id(l_ctr)      :=  i.old_instance_party_id;
      l_acct_hist_rec_tab.new_instance_party_id(l_ctr)      :=  i.new_instance_party_id;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_acct_hist_rec_tab.ip_account_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Party Account history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_01
           ,COL_NUM_02
           ,COL_NUM_03
           ,COL_NUM_04
           ,COL_NUM_05
           ,COL_NUM_06
           ,COL_NUM_07
           ,COL_NUM_08
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_acct_hist_rec_tab.ip_account_history_id(i),
           l_acct_hist_rec_tab.transaction_id(i),
           l_acct_hist_rec_tab.ip_account_id(i),
           l_acct_hist_rec_tab.old_party_account_id(i),
           l_acct_hist_rec_tab.new_party_account_id(i),
           l_acct_hist_rec_tab.old_bill_to_address(i),
           l_acct_hist_rec_tab.new_bill_to_address(i),
           l_acct_hist_rec_tab.old_ship_to_address(i),
           l_acct_hist_rec_tab.new_ship_to_address(i),
           l_acct_hist_rec_tab.old_instance_party_id(i),
           l_acct_hist_rec_tab.new_instance_party_id(i),
           l_acct_hist_rec_tab.acct_created_by(i),
           l_acct_hist_rec_tab.acct_last_updated_by(i),
           l_acct_hist_rec_tab.acct_last_update_login(i),
		   l_acct_hist_rec_tab.acct_object_version_number(i), -- obj_ver_num
           l_acct_hist_rec_tab.acct_security_group_id(i), -- sec_grp_id
           l_acct_hist_rec_tab.old_relationship_type_code(i),
           l_acct_hist_rec_tab.new_relationship_type_code(i),
           l_acct_hist_rec_tab.old_context(i),
           l_acct_hist_rec_tab.new_context(i),
           l_acct_hist_rec_tab.old_attribute1(i),
           l_acct_hist_rec_tab.new_attribute1(i),
           l_acct_hist_rec_tab.old_attribute2(i),
           l_acct_hist_rec_tab.new_attribute2(i),
           l_acct_hist_rec_tab.old_attribute3(i),
           l_acct_hist_rec_tab.new_attribute3(i),
           l_acct_hist_rec_tab.old_attribute4(i),
           l_acct_hist_rec_tab.new_attribute4(i),
           l_acct_hist_rec_tab.old_attribute5(i),
           l_acct_hist_rec_tab.new_attribute5(i),
           l_acct_hist_rec_tab.old_attribute6(i),
           l_acct_hist_rec_tab.new_attribute6(i),
           l_acct_hist_rec_tab.old_attribute7(i),
           l_acct_hist_rec_tab.new_attribute7(i),
           l_acct_hist_rec_tab.old_attribute8(i),
           l_acct_hist_rec_tab.new_attribute8(i),
           l_acct_hist_rec_tab.old_attribute9(i),
           l_acct_hist_rec_tab.new_attribute9(i),
           l_acct_hist_rec_tab.old_attribute10(i),
           l_acct_hist_rec_tab.new_attribute10(i),
           l_acct_hist_rec_tab.old_attribute11(i),
           l_acct_hist_rec_tab.new_attribute11(i),
           l_acct_hist_rec_tab.old_attribute12(i),
           l_acct_hist_rec_tab.new_attribute12(i),
           l_acct_hist_rec_tab.old_attribute13(i),
           l_acct_hist_rec_tab.new_attribute13(i),
           l_acct_hist_rec_tab.old_attribute14(i),
           l_acct_hist_rec_tab.new_attribute14(i),
           l_acct_hist_rec_tab.old_attribute15(i),
           l_acct_hist_rec_tab.new_attribute15(i),
           l_acct_hist_rec_tab.acct_full_dump_flag(i), --'N', dump_flag
           l_acct_hist_rec_tab.acct_migrated_flag(i), -- mig_flag
           l_acct_hist_rec_tab.old_active_start_date(i),
           l_acct_hist_rec_tab.new_active_start_date(i),
           l_acct_hist_rec_tab.old_active_end_date(i),
           l_acct_hist_rec_tab.new_active_end_date(i),
           l_acct_hist_rec_tab.acct_creation_date(i),
           l_acct_hist_rec_tab.acct_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

         -- Purge the corresonding Archive data from the Instance history tables

            FORALL i IN 1 .. l_cnt

               Delete From CSI_IP_ACCOUNTS_H
               Where ip_account_history_id = l_acct_hist_rec_tab.ip_account_history_id(i);

       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Account_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- End of Procedure Inst Party Account Archive

--
-- This program is used to archive the Operating units history. It accepts from and to transactions
-- as the input parameters.
--

PROCEDURE Org_Units_archive( errbuf       OUT NOCOPY VARCHAR2,
                             retcode      OUT NOCOPY NUMBER,
                             from_trans   IN  NUMBER,
                             to_trans     IN  NUMBER,
                             purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor org_units_hist_csr (p_from_trans IN NUMBER,
                               p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_I_ORG_ASSIGNMENTS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_org_units_hist_csr         org_units_hist_csr%ROWTYPE;
    l_org_units_hist_rec_tab     csi_txn_history_purge_pvt.org_units_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_I_ORG_ASSIGNMENTS_H';
    Exception
      When no_data_found Then
        l_table_id := 4;
      When others Then
        l_table_id := 4;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Org_Archive;
      l_ctr := 0;
      --
      l_org_units_hist_rec_tab.instance_ou_history_id.DELETE;
      l_org_units_hist_rec_tab.instance_ou_id.DELETE;
      l_org_units_hist_rec_tab.transaction_id.DELETE;
      l_org_units_hist_rec_tab.old_operating_unit_id.DELETE;
      l_org_units_hist_rec_tab.new_operating_unit_id.DELETE;
      l_org_units_hist_rec_tab.old_ou_relnship_type_code.DELETE;
      l_org_units_hist_rec_tab.new_ou_relnship_type_code.DELETE;
      l_org_units_hist_rec_tab.old_ou_active_start_date.DELETE;
      l_org_units_hist_rec_tab.new_ou_active_start_date.DELETE;
      l_org_units_hist_rec_tab.old_ou_active_end_date.DELETE;
      l_org_units_hist_rec_tab.new_ou_active_end_date.DELETE;
      l_org_units_hist_rec_tab.old_ou_context.DELETE;
      l_org_units_hist_rec_tab.new_ou_context.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute1.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute1.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute2.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute2.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute3.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute3.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute4.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute4.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute5.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute5.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute6.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute6.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute7.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute7.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute8.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute8.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute9.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute9.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute10.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute10.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute11.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute11.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute12.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute12.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute13.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute13.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute14.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute14.DELETE;
      l_org_units_hist_rec_tab.old_ou_attribute15.DELETE;
      l_org_units_hist_rec_tab.new_ou_attribute15.DELETE;
      l_org_units_hist_rec_tab.ou_full_dump_flag.DELETE;
      l_org_units_hist_rec_tab.ou_created_by.DELETE;
      l_org_units_hist_rec_tab.ou_creation_date.DELETE;
      l_org_units_hist_rec_tab.ou_last_updated_by.DELETE;
      l_org_units_hist_rec_tab.ou_last_update_date.DELETE;
      l_org_units_hist_rec_tab.ou_last_update_login.DELETE;
      l_org_units_hist_rec_tab.ou_object_version_number.DELETE;
      l_org_units_hist_rec_tab.ou_security_group_id.DELETE;
      l_org_units_hist_rec_tab.ou_migrated_flag.DELETE;
      --

  For i in org_units_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_org_units_hist_rec_tab.instance_ou_history_id(l_ctr)        :=  i.instance_ou_history_id;
      l_org_units_hist_rec_tab.instance_ou_id(l_ctr)                :=  i.instance_ou_id;
      l_org_units_hist_rec_tab.transaction_id(l_ctr)                :=  i.transaction_id;
      l_org_units_hist_rec_tab.old_operating_unit_id(l_ctr)         :=  i.old_operating_unit_id;
      l_org_units_hist_rec_tab.new_operating_unit_id(l_ctr)         :=  i.new_operating_unit_id;
      l_org_units_hist_rec_tab.old_ou_relnship_type_code(l_ctr)     :=  i.old_relationship_type_code;
      l_org_units_hist_rec_tab.new_ou_relnship_type_code(l_ctr)     :=  i.new_relationship_type_code;
      l_org_units_hist_rec_tab.old_ou_active_start_date(l_ctr)      :=  i.old_active_start_date;
      l_org_units_hist_rec_tab.new_ou_active_start_date(l_ctr)      :=  i.new_active_start_date;
      l_org_units_hist_rec_tab.old_ou_active_end_date(l_ctr)        :=  i.old_active_end_date;
      l_org_units_hist_rec_tab.new_ou_active_end_date(l_ctr)        :=  i.new_active_end_date;
      l_org_units_hist_rec_tab.old_ou_context(l_ctr)	            :=  i.old_context;
      l_org_units_hist_rec_tab.new_ou_context(l_ctr)	            :=  i.new_context;
      l_org_units_hist_rec_tab.old_ou_attribute1(l_ctr)	            :=  i.old_attribute1;
      l_org_units_hist_rec_tab.new_ou_attribute1(l_ctr)	            :=  i.new_attribute1;
      l_org_units_hist_rec_tab.old_ou_attribute2(l_ctr)	            :=  i.old_attribute2;
      l_org_units_hist_rec_tab.new_ou_attribute2(l_ctr)	            :=  i.new_attribute2;
      l_org_units_hist_rec_tab.old_ou_attribute3(l_ctr)	            :=  i.old_attribute3;
      l_org_units_hist_rec_tab.new_ou_attribute3(l_ctr)	            :=  i.new_attribute3;
      l_org_units_hist_rec_tab.old_ou_attribute4(l_ctr)	            :=  i.old_attribute4;
      l_org_units_hist_rec_tab.new_ou_attribute4(l_ctr)	            :=  i.new_attribute4;
      l_org_units_hist_rec_tab.old_ou_attribute5(l_ctr)	            :=  i.old_attribute5;
      l_org_units_hist_rec_tab.new_ou_attribute5(l_ctr)	            :=  i.new_attribute5;
      l_org_units_hist_rec_tab.old_ou_attribute6(l_ctr)	            :=  i.old_attribute6;
      l_org_units_hist_rec_tab.new_ou_attribute6(l_ctr)	            :=  i.new_attribute6;
      l_org_units_hist_rec_tab.old_ou_attribute7(l_ctr)	            :=  i.old_attribute7;
      l_org_units_hist_rec_tab.new_ou_attribute7(l_ctr)	            :=  i.new_attribute7;
      l_org_units_hist_rec_tab.old_ou_attribute8(l_ctr)	            :=  i.old_attribute8;
      l_org_units_hist_rec_tab.new_ou_attribute8(l_ctr)	            :=  i.new_attribute8;
      l_org_units_hist_rec_tab.old_ou_attribute9(l_ctr)	            :=  i.old_attribute9;
      l_org_units_hist_rec_tab.new_ou_attribute9(l_ctr)	            :=  i.new_attribute9;
      l_org_units_hist_rec_tab.old_ou_attribute10(l_ctr)	        :=  i.old_attribute10;
      l_org_units_hist_rec_tab.new_ou_attribute10(l_ctr)	        :=  i.new_attribute10;
      l_org_units_hist_rec_tab.old_ou_attribute11(l_ctr)      	    :=  i.old_attribute11;
      l_org_units_hist_rec_tab.new_ou_attribute11(l_ctr)	        :=  i.new_attribute11;
      l_org_units_hist_rec_tab.old_ou_attribute12(l_ctr)	        :=  i.old_attribute12;
      l_org_units_hist_rec_tab.new_ou_attribute12(l_ctr)	        :=  i.new_attribute12;
      l_org_units_hist_rec_tab.old_ou_attribute13(l_ctr)	        :=  i.old_attribute13;
      l_org_units_hist_rec_tab.new_ou_attribute13(l_ctr)	        :=  i.new_attribute13;
      l_org_units_hist_rec_tab.old_ou_attribute14(l_ctr)	        :=  i.old_attribute14;
      l_org_units_hist_rec_tab.new_ou_attribute14(l_ctr)	        :=  i.new_attribute14;
      l_org_units_hist_rec_tab.old_ou_attribute15(l_ctr)	        :=  i.old_attribute15;
      l_org_units_hist_rec_tab.new_ou_attribute15(l_ctr)	        :=  i.new_attribute15;
      l_org_units_hist_rec_tab.ou_full_dump_flag(l_ctr)	            :=  i.full_dump_flag;
      l_org_units_hist_rec_tab.ou_created_by(l_ctr)                 :=  i.created_by;
      l_org_units_hist_rec_tab.ou_creation_date(l_ctr)              :=  i.creation_date;
      l_org_units_hist_rec_tab.ou_last_updated_by(l_ctr)            :=  i.last_updated_by;
      l_org_units_hist_rec_tab.ou_last_update_date(l_ctr)           :=  i.last_update_date;
      l_org_units_hist_rec_tab.ou_last_update_login(l_ctr)          :=  i.last_update_login;
      l_org_units_hist_rec_tab.ou_object_version_number(l_ctr)	    :=  i.object_version_number;
      l_org_units_hist_rec_tab.ou_security_group_id(l_ctr)	        :=  i.security_group_id;
      l_org_units_hist_rec_tab.ou_migrated_flag(l_ctr)	            :=  i.migrated_flag;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_org_units_hist_rec_tab.instance_ou_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Org Assignments history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_01
           ,COL_NUM_02
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_org_units_hist_rec_tab.instance_ou_history_id(i),
           l_org_units_hist_rec_tab.transaction_id(i),
           l_org_units_hist_rec_tab.instance_ou_id(i),
           l_org_units_hist_rec_tab.old_operating_unit_id(i),
           l_org_units_hist_rec_tab.new_operating_unit_id(i),
           l_org_units_hist_rec_tab.ou_created_by(i),
           l_org_units_hist_rec_tab.ou_last_updated_by(i),
           l_org_units_hist_rec_tab.ou_last_update_login(i),
		   l_org_units_hist_rec_tab.ou_object_version_number(i), -- obj_ver_num
           l_org_units_hist_rec_tab.ou_security_group_id(i), -- sec_grp_id
           l_org_units_hist_rec_tab.old_ou_relnship_type_code(i),
           l_org_units_hist_rec_tab.new_ou_relnship_type_code(i),
           l_org_units_hist_rec_tab.old_ou_context(i),
           l_org_units_hist_rec_tab.new_ou_context(i),
           l_org_units_hist_rec_tab.old_ou_attribute1(i),
           l_org_units_hist_rec_tab.new_ou_attribute1(i),
           l_org_units_hist_rec_tab.old_ou_attribute2(i),
           l_org_units_hist_rec_tab.new_ou_attribute2(i),
           l_org_units_hist_rec_tab.old_ou_attribute3(i),
           l_org_units_hist_rec_tab.new_ou_attribute3(i),
           l_org_units_hist_rec_tab.old_ou_attribute4(i),
           l_org_units_hist_rec_tab.new_ou_attribute4(i),
           l_org_units_hist_rec_tab.old_ou_attribute5(i),
           l_org_units_hist_rec_tab.new_ou_attribute5(i),
           l_org_units_hist_rec_tab.old_ou_attribute6(i),
           l_org_units_hist_rec_tab.new_ou_attribute6(i),
           l_org_units_hist_rec_tab.old_ou_attribute7(i),
           l_org_units_hist_rec_tab.new_ou_attribute7(i),
           l_org_units_hist_rec_tab.old_ou_attribute8(i),
           l_org_units_hist_rec_tab.new_ou_attribute8(i),
           l_org_units_hist_rec_tab.old_ou_attribute9(i),
           l_org_units_hist_rec_tab.new_ou_attribute9(i),
           l_org_units_hist_rec_tab.old_ou_attribute10(i),
           l_org_units_hist_rec_tab.new_ou_attribute10(i),
           l_org_units_hist_rec_tab.old_ou_attribute11(i),
           l_org_units_hist_rec_tab.new_ou_attribute11(i),
           l_org_units_hist_rec_tab.old_ou_attribute12(i),
           l_org_units_hist_rec_tab.new_ou_attribute12(i),
           l_org_units_hist_rec_tab.old_ou_attribute13(i),
           l_org_units_hist_rec_tab.new_ou_attribute13(i),
           l_org_units_hist_rec_tab.old_ou_attribute14(i),
           l_org_units_hist_rec_tab.new_ou_attribute14(i),
           l_org_units_hist_rec_tab.old_ou_attribute15(i),
           l_org_units_hist_rec_tab.new_ou_attribute15(i),
           l_org_units_hist_rec_tab.ou_full_dump_flag(i), --'N', dump_flag
           l_org_units_hist_rec_tab.ou_migrated_flag(i), -- mig_flag
           l_org_units_hist_rec_tab.old_ou_active_start_date(i),
           l_org_units_hist_rec_tab.new_ou_active_start_date(i),
           l_org_units_hist_rec_tab.old_ou_active_end_date(i),
           l_org_units_hist_rec_tab.new_ou_active_end_date(i),
           l_org_units_hist_rec_tab.ou_creation_date(i),
           l_org_units_hist_rec_tab.ou_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

        -- Purge the corresonding Archive data from the Instance history tables

           FORALL i IN 1 .. l_cnt

               Delete From CSI_I_ORG_ASSIGNMENTS_H
               Where instance_ou_history_id = l_org_units_hist_rec_tab.instance_ou_history_id(i);


       End If; -- if l_cnt > 0

       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Org_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure OrgUnits_Archive

--
-- This program is used to archive the Extended Attribs history. It accepts from and to transactions
-- as the input parameters.
--

PROCEDURE Ext_Attribs_archive( errbuf       OUT NOCOPY VARCHAR2,
                               retcode      OUT NOCOPY NUMBER,
                               from_trans   IN  NUMBER,
                               to_trans     IN  NUMBER,
                               purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor ext_attrib_hist_csr (p_from_trans IN NUMBER,
                                p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_IEA_VALUES_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_ext_attrib_hist_csr         ext_attrib_hist_csr%ROWTYPE;
    l_ext_attrib_hist_rec_tab     csi_txn_history_purge_pvt.ext_attrib_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_IEA_VALUES_H';
    Exception
      When no_data_found Then
        l_table_id := 5;
      When others Then
        l_table_id := 5;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Ext_Archive;
      l_ctr := 0;
      --
      l_ext_attrib_hist_rec_tab.attribute_value_history_id.DELETE;
      l_ext_attrib_hist_rec_tab.attribute_value_id.DELETE;
      l_ext_attrib_hist_rec_tab.transaction_id.DELETE;
      l_ext_attrib_hist_rec_tab.old_attribute_value.DELETE;
      l_ext_attrib_hist_rec_tab.new_attribute_value.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_active_start_date.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_active_start_date.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_active_end_date.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_active_end_date.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_context.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_context.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute1.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute1.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute2.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute2.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute3.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute3.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute4.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute4.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute5.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute5.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute6.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute6.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute7.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute7.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute8.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute8.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute9.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute9.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute10.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute10.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute11.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute11.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute12.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute12.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute13.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute13.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute14.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute14.DELETE;
      l_ext_attrib_hist_rec_tab.old_ext_attribute15.DELETE;
      l_ext_attrib_hist_rec_tab.new_ext_attribute15.DELETE;
      l_ext_attrib_hist_rec_tab.ext_full_dump_flag.DELETE;
      l_ext_attrib_hist_rec_tab.ext_created_by.DELETE;
      l_ext_attrib_hist_rec_tab.ext_creation_date.DELETE;
      l_ext_attrib_hist_rec_tab.ext_last_updated_by.DELETE;
      l_ext_attrib_hist_rec_tab.ext_last_update_date.DELETE;
      l_ext_attrib_hist_rec_tab.ext_last_update_login.DELETE;
      l_ext_attrib_hist_rec_tab.ext_object_version_number.DELETE;
      l_ext_attrib_hist_rec_tab.ext_security_group_id.DELETE;
      l_ext_attrib_hist_rec_tab.ext_migrated_flag.DELETE;
      --

  For i in ext_attrib_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_ext_attrib_hist_rec_tab.attribute_value_history_id(l_ctr)   :=  i.attribute_value_history_id;
      l_ext_attrib_hist_rec_tab.attribute_value_id(l_ctr)           :=  i.attribute_value_id;
      l_ext_attrib_hist_rec_tab.transaction_id(l_ctr)               :=  i.transaction_id;
      l_ext_attrib_hist_rec_tab.old_attribute_value(l_ctr)          :=  i.old_attribute_value;
      l_ext_attrib_hist_rec_tab.new_attribute_value(l_ctr)          :=  i.new_attribute_value;
      l_ext_attrib_hist_rec_tab.old_ext_active_start_date(l_ctr)    :=  i.old_active_start_date;
      l_ext_attrib_hist_rec_tab.new_ext_active_start_date(l_ctr)    :=  i.new_active_start_date;
      l_ext_attrib_hist_rec_tab.old_ext_active_end_date(l_ctr)      :=  i.old_active_end_date;
      l_ext_attrib_hist_rec_tab.new_ext_active_end_date(l_ctr)      :=  i.new_active_end_date;
      l_ext_attrib_hist_rec_tab.old_ext_context(l_ctr)	            :=  i.old_context;
      l_ext_attrib_hist_rec_tab.new_ext_context(l_ctr)	            :=  i.new_context;
      l_ext_attrib_hist_rec_tab.old_ext_attribute1(l_ctr)	        :=  i.old_attribute1;
      l_ext_attrib_hist_rec_tab.new_ext_attribute1(l_ctr)	        :=  i.new_attribute1;
      l_ext_attrib_hist_rec_tab.old_ext_attribute2(l_ctr)	        :=  i.old_attribute2;
      l_ext_attrib_hist_rec_tab.new_ext_attribute2(l_ctr)	        :=  i.new_attribute2;
      l_ext_attrib_hist_rec_tab.old_ext_attribute3(l_ctr)	        :=  i.old_attribute3;
      l_ext_attrib_hist_rec_tab.new_ext_attribute3(l_ctr)	        :=  i.new_attribute3;
      l_ext_attrib_hist_rec_tab.old_ext_attribute4(l_ctr)	        :=  i.old_attribute4;
      l_ext_attrib_hist_rec_tab.new_ext_attribute4(l_ctr)	        :=  i.new_attribute4;
      l_ext_attrib_hist_rec_tab.old_ext_attribute5(l_ctr)	        :=  i.old_attribute5;
      l_ext_attrib_hist_rec_tab.new_ext_attribute5(l_ctr)	        :=  i.new_attribute5;
      l_ext_attrib_hist_rec_tab.old_ext_attribute6(l_ctr)	        :=  i.old_attribute6;
      l_ext_attrib_hist_rec_tab.new_ext_attribute6(l_ctr)	        :=  i.new_attribute6;
      l_ext_attrib_hist_rec_tab.old_ext_attribute7(l_ctr)	        :=  i.old_attribute7;
      l_ext_attrib_hist_rec_tab.new_ext_attribute7(l_ctr)	        :=  i.new_attribute7;
      l_ext_attrib_hist_rec_tab.old_ext_attribute8(l_ctr)	        :=  i.old_attribute8;
      l_ext_attrib_hist_rec_tab.new_ext_attribute8(l_ctr)	        :=  i.new_attribute8;
      l_ext_attrib_hist_rec_tab.old_ext_attribute9(l_ctr)	        :=  i.old_attribute9;
      l_ext_attrib_hist_rec_tab.new_ext_attribute9(l_ctr)	        :=  i.new_attribute9;
      l_ext_attrib_hist_rec_tab.old_ext_attribute10(l_ctr)	        :=  i.old_attribute10;
      l_ext_attrib_hist_rec_tab.new_ext_attribute10(l_ctr)	        :=  i.new_attribute10;
      l_ext_attrib_hist_rec_tab.old_ext_attribute11(l_ctr)    	    :=  i.old_attribute11;
      l_ext_attrib_hist_rec_tab.new_ext_attribute11(l_ctr)	        :=  i.new_attribute11;
      l_ext_attrib_hist_rec_tab.old_ext_attribute12(l_ctr)	        :=  i.old_attribute12;
      l_ext_attrib_hist_rec_tab.new_ext_attribute12(l_ctr)	        :=  i.new_attribute12;
      l_ext_attrib_hist_rec_tab.old_ext_attribute13(l_ctr)	        :=  i.old_attribute13;
      l_ext_attrib_hist_rec_tab.new_ext_attribute13(l_ctr)	        :=  i.new_attribute13;
      l_ext_attrib_hist_rec_tab.old_ext_attribute14(l_ctr)	        :=  i.old_attribute14;
      l_ext_attrib_hist_rec_tab.new_ext_attribute14(l_ctr)	        :=  i.new_attribute14;
      l_ext_attrib_hist_rec_tab.old_ext_attribute15(l_ctr)	        :=  i.old_attribute15;
      l_ext_attrib_hist_rec_tab.new_ext_attribute15(l_ctr)	        :=  i.new_attribute15;
      l_ext_attrib_hist_rec_tab.ext_full_dump_flag(l_ctr)	        :=  i.full_dump_flag;
      l_ext_attrib_hist_rec_tab.ext_created_by(l_ctr)               :=  i.created_by;
      l_ext_attrib_hist_rec_tab.ext_creation_date(l_ctr)            :=  i.creation_date;
      l_ext_attrib_hist_rec_tab.ext_last_updated_by(l_ctr)          :=  i.last_updated_by;
      l_ext_attrib_hist_rec_tab.ext_last_update_date(l_ctr)         :=  i.last_update_date;
      l_ext_attrib_hist_rec_tab.ext_last_update_login(l_ctr)        :=  i.last_update_login;
      l_ext_attrib_hist_rec_tab.ext_object_version_number(l_ctr)    :=  i.object_version_number;
      l_ext_attrib_hist_rec_tab.ext_security_group_id(l_ctr)	    :=  i.security_group_id;
      l_ext_attrib_hist_rec_tab.ext_migrated_flag(l_ctr)	        :=  i.migrated_flag;


   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_ext_attrib_hist_rec_tab.attribute_value_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Extended Attributes history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_ext_attrib_hist_rec_tab.attribute_value_history_id(i),
           l_ext_attrib_hist_rec_tab.transaction_id(i),
           l_ext_attrib_hist_rec_tab.attribute_value_id(i),
           l_ext_attrib_hist_rec_tab.ext_created_by(i),
           l_ext_attrib_hist_rec_tab.ext_last_updated_by(i),
           l_ext_attrib_hist_rec_tab.ext_last_update_login(i),
           l_ext_attrib_hist_rec_tab.ext_object_version_number(i), -- obj_ver_num
           l_ext_attrib_hist_rec_tab.ext_security_group_id(i),
           l_ext_attrib_hist_rec_tab.old_attribute_value(i),
           l_ext_attrib_hist_rec_tab.new_attribute_value(i),
           l_ext_attrib_hist_rec_tab.old_ext_context(i),
           l_ext_attrib_hist_rec_tab.new_ext_context(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute1(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute1(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute2(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute2(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute3(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute3(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute4(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute4(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute5(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute5(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute6(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute6(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute7(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute7(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute8(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute8(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute9(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute9(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute10(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute10(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute11(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute11(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute12(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute12(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute13(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute13(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute14(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute14(i),
           l_ext_attrib_hist_rec_tab.old_ext_attribute15(i),
           l_ext_attrib_hist_rec_tab.new_ext_attribute15(i),
           l_ext_attrib_hist_rec_tab.ext_full_dump_flag(i), --'N', dump_flag
           l_ext_attrib_hist_rec_tab.ext_migrated_flag(i), -- mig_flag
           l_ext_attrib_hist_rec_tab.old_ext_active_start_date(i),
           l_ext_attrib_hist_rec_tab.new_ext_active_start_date(i),
           l_ext_attrib_hist_rec_tab.old_ext_active_end_date(i),
           l_ext_attrib_hist_rec_tab.new_ext_active_end_date(i),
           l_ext_attrib_hist_rec_tab.ext_creation_date(i),
           l_ext_attrib_hist_rec_tab.ext_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

         -- Purge the corresonding Archive data from the Instance history tables

            FORALL i IN 1 .. l_cnt

               Delete From CSI_IEA_VALUES_H
               Where attribute_value_history_id = l_ext_attrib_hist_rec_tab.attribute_value_history_id(i);

       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Ext_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure ExtAttribs_Archive


--
-- This program is used to archive the Pricing Attribs history. It accepts from and to transactions
-- as the input parameters.
--

PROCEDURE Pricing_archive( errbuf       OUT NOCOPY VARCHAR2,
                           retcode      OUT NOCOPY NUMBER,
                           from_trans   IN  NUMBER,
                           to_trans     IN  NUMBER,
                           purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor pri_attribs_hist_csr (p_from_trans IN NUMBER,
                                 p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_I_PRICING_ATTRIBS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_pri_attribs_hist_csr         pri_attribs_hist_csr%ROWTYPE;
    l_pri_attribs_hist_rec_tab     csi_txn_history_purge_pvt.pricing_attribs_hist_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_I_PRICING_ATTRIBS_H';
    Exception
      When no_data_found Then
        l_table_id := 6;
      When others Then
        l_table_id := 6;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Pricing_Archive;
      l_ctr := 0;
      --
      l_pri_attribs_hist_rec_tab.price_attrib_history_id.DELETE;
      l_pri_attribs_hist_rec_tab.pricing_attribute_id.DELETE;
      l_pri_attribs_hist_rec_tab.transaction_id.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_context.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_context.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute1.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute1.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute2.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute2.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute3.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute3.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute4.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute4.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute5.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute5.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute6.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute6.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute7.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute7.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute8.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute8.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute9.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute9.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute10.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute10.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute11.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute11.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute12.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute12.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute13.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute13.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute14.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute14.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute15.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute15.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute16.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute16.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute17.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute17.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute18.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute18.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute19.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute19.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute20.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute20.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute21.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute21.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute22.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute22.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute23.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute23.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute24.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute24.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute25.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute25.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute26.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute26.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute27.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute27.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute28.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute28.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute29.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute29.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute30.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute30.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute31.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute31.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute32.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute32.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute33.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute33.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute34.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute34.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute35.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute35.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute36.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute36.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute37.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute37.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute38.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute38.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute39.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute39.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute40.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute40.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute41.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute41.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute42.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute42.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute43.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute43.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute44.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute44.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute45.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute45.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute46.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute46.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute47.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute47.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute48.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute48.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute49.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute49.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute50.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute50.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute51.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute51.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute52.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute52.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute53.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute53.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute54.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute54.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute55.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute55.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute56.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute56.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute57.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute57.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute58.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute58.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute59.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute59.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute60.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute60.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute61.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute61.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute62.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute62.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute63.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute63.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute64.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute64.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute65.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute65.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute66.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute66.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute67.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute67.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute68.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute68.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute69.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute69.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute70.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute70.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute71.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute71.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute72.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute72.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute73.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute73.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute74.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute74.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute75.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute75.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute76.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute76.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute77.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute77.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute78.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute78.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute79.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute79.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute80.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute80.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute81.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute81.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute82.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute82.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute83.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute83.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute84.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute84.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute85.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute85.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute86.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute86.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute87.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute87.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute88.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute88.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute89.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute89.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute90.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute90.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute91.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute91.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute92.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute92.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute93.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute93.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute94.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute94.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute95.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute95.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute96.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute96.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute97.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute97.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute98.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute98.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute99.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute99.DELETE;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute100.DELETE;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute100.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_active_start_date.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_active_start_date.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_active_end_date.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_active_end_date.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_context.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_context.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute1.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute1.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute2.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute2.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute3.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute3.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute4.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute4.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute5.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute5.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute6.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute6.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute7.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute7.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute8.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute8.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute9.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute9.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute10.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute10.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute11.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute11.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute12.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute12.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute13.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute13.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute14.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute14.DELETE;
      l_pri_attribs_hist_rec_tab.old_pri_attribute15.DELETE;
      l_pri_attribs_hist_rec_tab.new_pri_attribute15.DELETE;
      l_pri_attribs_hist_rec_tab.pri_full_dump_flag.DELETE;
      l_pri_attribs_hist_rec_tab.pri_created_by.DELETE;
      l_pri_attribs_hist_rec_tab.pri_creation_date.DELETE;
      l_pri_attribs_hist_rec_tab.pri_last_updated_by.DELETE;
      l_pri_attribs_hist_rec_tab.pri_last_update_date.DELETE;
      l_pri_attribs_hist_rec_tab.pri_last_update_login.DELETE;
      l_pri_attribs_hist_rec_tab.pri_object_version_number.DELETE;
      l_pri_attribs_hist_rec_tab.pri_security_group_id.DELETE;
      l_pri_attribs_hist_rec_tab.pri_migrated_flag.DELETE;
      --

  For i in pri_attribs_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_pri_attribs_hist_rec_tab.price_attrib_history_id(l_ctr)           :=  i.price_attrib_history_id;
      l_pri_attribs_hist_rec_tab.pricing_attribute_id(l_ctr)              :=  i.pricing_attribute_id;
      l_pri_attribs_hist_rec_tab.transaction_id(l_ctr)                    :=  i.transaction_id;
      l_pri_attribs_hist_rec_tab.old_pricing_context(l_ctr)               :=  i.old_pricing_context;
      l_pri_attribs_hist_rec_tab.new_pricing_context(l_ctr)               :=  i.new_pricing_context;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute1(l_ctr)            :=  i.old_pricing_attribute1;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute1(l_ctr)            :=  i.new_pricing_attribute1;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute2(l_ctr)            :=  i.old_pricing_attribute2;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute2(l_ctr)            :=  i.new_pricing_attribute2;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute3(l_ctr)            :=  i.old_pricing_attribute3;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute3(l_ctr)            :=  i.new_pricing_attribute3;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute4(l_ctr)            :=  i.old_pricing_attribute4;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute4(l_ctr)            :=  i.new_pricing_attribute4;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute5(l_ctr)            :=  i.old_pricing_attribute5;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute5(l_ctr)            :=  i.new_pricing_attribute5;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute6(l_ctr)            :=  i.old_pricing_attribute6;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute6(l_ctr)            :=  i.new_pricing_attribute6;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute7(l_ctr)            :=  i.old_pricing_attribute7;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute7(l_ctr)            :=  i.new_pricing_attribute7;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute8(l_ctr)            :=  i.old_pricing_attribute8;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute8(l_ctr)            :=  i.new_pricing_attribute8;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute9(l_ctr)            :=  i.old_pricing_attribute9;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute9(l_ctr)            :=  i.new_pricing_attribute9;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute10(l_ctr)           :=  i.old_pricing_attribute10;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute10(l_ctr)           :=  i.new_pricing_attribute10;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute11(l_ctr)           :=  i.old_pricing_attribute11;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute11(l_ctr)           :=  i.new_pricing_attribute11;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute12(l_ctr)           :=  i.old_pricing_attribute12;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute12(l_ctr)           :=  i.new_pricing_attribute12;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute13(l_ctr)           :=  i.old_pricing_attribute13;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute13(l_ctr)           :=  i.new_pricing_attribute13;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute14(l_ctr)           :=  i.old_pricing_attribute14;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute14(l_ctr)           :=  i.new_pricing_attribute14;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute15(l_ctr)           :=  i.old_pricing_attribute15;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute15(l_ctr)           :=  i.new_pricing_attribute15;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute16(l_ctr)           :=  i.old_pricing_attribute16;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute16(l_ctr)           :=  i.new_pricing_attribute16;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute17(l_ctr)           :=  i.old_pricing_attribute17;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute17(l_ctr)           :=  i.new_pricing_attribute17;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute18(l_ctr)           :=  i.old_pricing_attribute18;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute18(l_ctr)           :=  i.new_pricing_attribute18;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute19(l_ctr)           :=  i.old_pricing_attribute19;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute19(l_ctr)           :=  i.new_pricing_attribute19;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute20(l_ctr)           :=  i.old_pricing_attribute20;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute20(l_ctr)           :=  i.new_pricing_attribute20;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute21(l_ctr)           :=  i.old_pricing_attribute21;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute21(l_ctr)           :=  i.new_pricing_attribute21;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute22(l_ctr)           :=  i.old_pricing_attribute22;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute22(l_ctr)           :=  i.new_pricing_attribute22;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute23(l_ctr)           :=  i.old_pricing_attribute23;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute23(l_ctr)           :=  i.new_pricing_attribute23;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute24(l_ctr)           :=  i.old_pricing_attribute24;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute24(l_ctr)           :=  i.new_pricing_attribute24;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute25(l_ctr)           :=  i.old_pricing_attribute25;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute25(l_ctr)           :=  i.new_pricing_attribute25;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute26(l_ctr)           :=  i.old_pricing_attribute26;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute26(l_ctr)           :=  i.new_pricing_attribute26;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute27(l_ctr)           :=  i.old_pricing_attribute27;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute27(l_ctr)           :=  i.new_pricing_attribute27;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute28(l_ctr)           :=  i.old_pricing_attribute28;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute28(l_ctr)           :=  i.new_pricing_attribute28;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute29(l_ctr)           :=  i.old_pricing_attribute29;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute29(l_ctr)           :=  i.new_pricing_attribute29;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute30(l_ctr)           :=  i.old_pricing_attribute30;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute30(l_ctr)           :=  i.new_pricing_attribute30;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute31(l_ctr)           :=  i.old_pricing_attribute31;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute31(l_ctr)           :=  i.new_pricing_attribute31;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute32(l_ctr)           :=  i.old_pricing_attribute32;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute32(l_ctr)           :=  i.new_pricing_attribute32;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute33(l_ctr)           :=  i.old_pricing_attribute33;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute33(l_ctr)           :=  i.new_pricing_attribute33;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute34(l_ctr)           :=  i.old_pricing_attribute34;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute34(l_ctr)           :=  i.new_pricing_attribute34;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute35(l_ctr)           :=  i.old_pricing_attribute35;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute35(l_ctr)           :=  i.new_pricing_attribute35;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute36(l_ctr)           :=  i.old_pricing_attribute36;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute36(l_ctr)           :=  i.new_pricing_attribute36;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute37(l_ctr)           :=  i.old_pricing_attribute37;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute37(l_ctr)           :=  i.new_pricing_attribute37;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute38(l_ctr)           :=  i.old_pricing_attribute38;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute38(l_ctr)           :=  i.new_pricing_attribute38;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute39(l_ctr)           :=  i.old_pricing_attribute39;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute39(l_ctr)           :=  i.new_pricing_attribute39;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute40(l_ctr)           :=  i.old_pricing_attribute40;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute40(l_ctr)           :=  i.new_pricing_attribute40;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute41(l_ctr)           :=  i.old_pricing_attribute41;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute41(l_ctr)           :=  i.new_pricing_attribute41;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute42(l_ctr)           :=  i.old_pricing_attribute42;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute42(l_ctr)           :=  i.new_pricing_attribute42;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute43(l_ctr)           :=  i.old_pricing_attribute43;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute43(l_ctr)           :=  i.new_pricing_attribute43;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute44(l_ctr)           :=  i.old_pricing_attribute44;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute44(l_ctr)           :=  i.new_pricing_attribute44;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute45(l_ctr)           :=  i.old_pricing_attribute45;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute45(l_ctr)           :=  i.new_pricing_attribute45;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute46(l_ctr)           :=  i.old_pricing_attribute46;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute46(l_ctr)           :=  i.new_pricing_attribute46;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute47(l_ctr)           :=  i.old_pricing_attribute47;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute47(l_ctr)           :=  i.new_pricing_attribute47;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute48(l_ctr)           :=  i.old_pricing_attribute48;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute48(l_ctr)           :=  i.new_pricing_attribute48;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute49(l_ctr)           :=  i.old_pricing_attribute49;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute49(l_ctr)           :=  i.new_pricing_attribute49;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute50(l_ctr)           :=  i.old_pricing_attribute50;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute50(l_ctr)           :=  i.new_pricing_attribute50;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute51(l_ctr)           :=  i.old_pricing_attribute51;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute51(l_ctr)           :=  i.new_pricing_attribute51;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute52(l_ctr)           :=  i.old_pricing_attribute52;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute52(l_ctr)           :=  i.new_pricing_attribute52;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute53(l_ctr)           :=  i.old_pricing_attribute53;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute53(l_ctr)           :=  i.new_pricing_attribute53;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute54(l_ctr)           :=  i.old_pricing_attribute54;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute54(l_ctr)           :=  i.new_pricing_attribute54;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute55(l_ctr)           :=  i.old_pricing_attribute55;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute55(l_ctr)           :=  i.new_pricing_attribute55;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute56(l_ctr)           :=  i.old_pricing_attribute56;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute56(l_ctr)           :=  i.new_pricing_attribute56;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute57(l_ctr)           :=  i.old_pricing_attribute57;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute57(l_ctr)           :=  i.new_pricing_attribute57;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute58(l_ctr)           :=  i.old_pricing_attribute58;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute58(l_ctr)           :=  i.new_pricing_attribute58;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute59(l_ctr)           :=  i.old_pricing_attribute59;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute59(l_ctr)           :=  i.new_pricing_attribute59;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute60(l_ctr)           :=  i.old_pricing_attribute60;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute60(l_ctr)           :=  i.new_pricing_attribute60;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute61(l_ctr)           :=  i.old_pricing_attribute61;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute61(l_ctr)           :=  i.new_pricing_attribute61;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute62(l_ctr)           :=  i.old_pricing_attribute62;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute62(l_ctr)           :=  i.new_pricing_attribute62;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute63(l_ctr)           :=  i.old_pricing_attribute63;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute63(l_ctr)           :=  i.new_pricing_attribute63;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute64(l_ctr)           :=  i.old_pricing_attribute64;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute64(l_ctr)           :=  i.new_pricing_attribute64;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute65(l_ctr)           :=  i.old_pricing_attribute65;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute65(l_ctr)           :=  i.new_pricing_attribute65;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute66(l_ctr)           :=  i.old_pricing_attribute66;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute66(l_ctr)           :=  i.new_pricing_attribute66;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute67(l_ctr)           :=  i.old_pricing_attribute67;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute67(l_ctr)           :=  i.new_pricing_attribute67;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute68(l_ctr)           :=  i.old_pricing_attribute68;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute68(l_ctr)           :=  i.new_pricing_attribute68;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute69(l_ctr)           :=  i.old_pricing_attribute69;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute69(l_ctr)           :=  i.new_pricing_attribute69;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute70(l_ctr)           :=  i.old_pricing_attribute70;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute70(l_ctr)           :=  i.new_pricing_attribute70;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute71(l_ctr)           :=  i.old_pricing_attribute71;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute71(l_ctr)           :=  i.new_pricing_attribute71;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute72(l_ctr)           :=  i.old_pricing_attribute72;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute72(l_ctr)           :=  i.new_pricing_attribute72;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute73(l_ctr)           :=  i.old_pricing_attribute73;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute73(l_ctr)           :=  i.new_pricing_attribute73;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute74(l_ctr)           :=  i.old_pricing_attribute74;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute74(l_ctr)           :=  i.new_pricing_attribute74;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute75(l_ctr)           :=  i.old_pricing_attribute75;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute75(l_ctr)           :=  i.new_pricing_attribute75;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute76(l_ctr)           :=  i.old_pricing_attribute76;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute76(l_ctr)           :=  i.new_pricing_attribute76;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute77(l_ctr)           :=  i.old_pricing_attribute77;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute77(l_ctr)           :=  i.new_pricing_attribute77;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute78(l_ctr)           :=  i.old_pricing_attribute78;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute78(l_ctr)           :=  i.new_pricing_attribute78;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute79(l_ctr)           :=  i.old_pricing_attribute79;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute79(l_ctr)           :=  i.new_pricing_attribute79;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute80(l_ctr)           :=  i.old_pricing_attribute80;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute80(l_ctr)           :=  i.new_pricing_attribute80;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute81(l_ctr)           :=  i.old_pricing_attribute81;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute81(l_ctr)           :=  i.new_pricing_attribute81;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute82(l_ctr)           :=  i.old_pricing_attribute82;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute82(l_ctr)           :=  i.new_pricing_attribute82;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute83(l_ctr)           :=  i.old_pricing_attribute83;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute83(l_ctr)           :=  i.new_pricing_attribute83;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute84(l_ctr)           :=  i.old_pricing_attribute84;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute84(l_ctr)           :=  i.new_pricing_attribute84;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute85(l_ctr)           :=  i.old_pricing_attribute85;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute85(l_ctr)           :=  i.new_pricing_attribute85;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute86(l_ctr)           :=  i.old_pricing_attribute86;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute86(l_ctr)           :=  i.new_pricing_attribute86;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute87(l_ctr)           :=  i.old_pricing_attribute87;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute87(l_ctr)           :=  i.new_pricing_attribute87;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute88(l_ctr)           :=  i.old_pricing_attribute88;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute88(l_ctr)           :=  i.new_pricing_attribute88;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute89(l_ctr)           :=  i.old_pricing_attribute89;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute89(l_ctr)           :=  i.new_pricing_attribute89;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute90(l_ctr)           :=  i.old_pricing_attribute90;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute90(l_ctr)           :=  i.new_pricing_attribute90;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute91(l_ctr)           :=  i.old_pricing_attribute91;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute91(l_ctr)           :=  i.new_pricing_attribute91;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute92(l_ctr)           :=  i.old_pricing_attribute92;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute92(l_ctr)           :=  i.new_pricing_attribute92;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute93(l_ctr)           :=  i.old_pricing_attribute93;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute93(l_ctr)           :=  i.new_pricing_attribute93;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute94(l_ctr)           :=  i.old_pricing_attribute94;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute94(l_ctr)           :=  i.new_pricing_attribute94;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute95(l_ctr)           :=  i.old_pricing_attribute95;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute95(l_ctr)           :=  i.new_pricing_attribute95;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute96(l_ctr)           :=  i.old_pricing_attribute96;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute96(l_ctr)           :=  i.new_pricing_attribute96;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute97(l_ctr)           :=  i.old_pricing_attribute97;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute97(l_ctr)           :=  i.new_pricing_attribute97;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute98(l_ctr)           :=  i.old_pricing_attribute98;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute98(l_ctr)           :=  i.new_pricing_attribute98;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute99(l_ctr)           :=  i.old_pricing_attribute99;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute99(l_ctr)           :=  i.new_pricing_attribute99;
      l_pri_attribs_hist_rec_tab.old_pricing_attribute100(l_ctr)          :=  i.old_pricing_attribute100;
      l_pri_attribs_hist_rec_tab.new_pricing_attribute100(l_ctr)          :=  i.new_pricing_attribute100;
      l_pri_attribs_hist_rec_tab.old_pri_active_start_date(l_ctr)         :=  i.old_active_start_date;
      l_pri_attribs_hist_rec_tab.new_pri_active_start_date(l_ctr)         :=  i.new_active_start_date;
      l_pri_attribs_hist_rec_tab.old_pri_active_end_date(l_ctr)           :=  i.old_active_end_date;
      l_pri_attribs_hist_rec_tab.new_pri_active_end_date(l_ctr)           :=  i.new_active_end_date;
      l_pri_attribs_hist_rec_tab.old_pri_context(l_ctr)                   :=  i.old_context;
      l_pri_attribs_hist_rec_tab.new_pri_context(l_ctr)                   :=  i.new_context;
      l_pri_attribs_hist_rec_tab.old_pri_attribute1(l_ctr)                :=  i.old_attribute1;
      l_pri_attribs_hist_rec_tab.new_pri_attribute1(l_ctr)                :=  i.new_attribute1;
      l_pri_attribs_hist_rec_tab.old_pri_attribute2(l_ctr)                :=  i.old_attribute2;
      l_pri_attribs_hist_rec_tab.new_pri_attribute2(l_ctr)                :=  i.old_attribute2;
      l_pri_attribs_hist_rec_tab.old_pri_attribute3(l_ctr)                :=  i.old_attribute3;
      l_pri_attribs_hist_rec_tab.new_pri_attribute3(l_ctr)                :=  i.old_attribute3;
      l_pri_attribs_hist_rec_tab.old_pri_attribute4(l_ctr)                :=  i.old_attribute4;
      l_pri_attribs_hist_rec_tab.new_pri_attribute4(l_ctr)                :=  i.old_attribute4;
      l_pri_attribs_hist_rec_tab.old_pri_attribute5(l_ctr)                :=  i.old_attribute5;
      l_pri_attribs_hist_rec_tab.new_pri_attribute5(l_ctr)                :=  i.old_attribute5;
      l_pri_attribs_hist_rec_tab.old_pri_attribute6(l_ctr)                :=  i.old_attribute6;
      l_pri_attribs_hist_rec_tab.new_pri_attribute6(l_ctr)                :=  i.old_attribute6;
      l_pri_attribs_hist_rec_tab.old_pri_attribute7(l_ctr)                :=  i.old_attribute7;
      l_pri_attribs_hist_rec_tab.new_pri_attribute7(l_ctr)                :=  i.old_attribute7;
      l_pri_attribs_hist_rec_tab.old_pri_attribute8(l_ctr)                :=  i.old_attribute8;
      l_pri_attribs_hist_rec_tab.new_pri_attribute8(l_ctr)                :=  i.old_attribute8;
      l_pri_attribs_hist_rec_tab.old_pri_attribute9(l_ctr)                :=  i.old_attribute9;
      l_pri_attribs_hist_rec_tab.new_pri_attribute9(l_ctr)                :=  i.old_attribute9;
      l_pri_attribs_hist_rec_tab.old_pri_attribute10(l_ctr)               :=  i.old_attribute10;
      l_pri_attribs_hist_rec_tab.new_pri_attribute10(l_ctr)               :=  i.old_attribute10;
      l_pri_attribs_hist_rec_tab.old_pri_attribute11(l_ctr)               :=  i.old_attribute11;
      l_pri_attribs_hist_rec_tab.new_pri_attribute11(l_ctr)               :=  i.old_attribute11;
      l_pri_attribs_hist_rec_tab.old_pri_attribute12(l_ctr)               :=  i.old_attribute12;
      l_pri_attribs_hist_rec_tab.new_pri_attribute12(l_ctr)               :=  i.old_attribute12;
      l_pri_attribs_hist_rec_tab.old_pri_attribute13(l_ctr)               :=  i.old_attribute13;
      l_pri_attribs_hist_rec_tab.new_pri_attribute13(l_ctr)               :=  i.old_attribute13;
      l_pri_attribs_hist_rec_tab.old_pri_attribute14(l_ctr)               :=  i.old_attribute14;
      l_pri_attribs_hist_rec_tab.new_pri_attribute14(l_ctr)               :=  i.old_attribute14;
      l_pri_attribs_hist_rec_tab.old_pri_attribute15(l_ctr)               :=  i.old_attribute15;
      l_pri_attribs_hist_rec_tab.new_pri_attribute15(l_ctr)               :=  i.old_attribute15;
      l_pri_attribs_hist_rec_tab.pri_full_dump_flag(l_ctr)                :=  i.full_dump_flag;
      l_pri_attribs_hist_rec_tab.pri_created_by(l_ctr)                    :=  i.created_by;
      l_pri_attribs_hist_rec_tab.pri_creation_date(l_ctr)                 :=  i.creation_date;
      l_pri_attribs_hist_rec_tab.pri_last_updated_by(l_ctr)               :=  i.last_updated_by;
      l_pri_attribs_hist_rec_tab.pri_last_update_date(l_ctr)              :=  i.last_update_date;
      l_pri_attribs_hist_rec_tab.pri_last_update_login(l_ctr)             :=  i.last_update_login;
      l_pri_attribs_hist_rec_tab.pri_object_version_number(l_ctr)         :=  i.object_version_number;
      l_pri_attribs_hist_rec_tab.pri_security_group_id(l_ctr)             :=  i.security_group_id;
      l_pri_attribs_hist_rec_tab.pri_migrated_flag(l_ctr)                 :=  i.migrated_flag;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_pri_attribs_hist_rec_tab.price_attrib_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Pricing Attributes history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
          ,COL_CHAR_01
          ,COL_CHAR_02
          ,COL_CHAR_03
          ,COL_CHAR_04
          ,COL_CHAR_05
          ,COL_CHAR_06
          ,COL_CHAR_07
          ,COL_CHAR_08
          ,COL_CHAR_09
          ,COL_CHAR_10
          ,COL_CHAR_11
          ,COL_CHAR_12
          ,COL_CHAR_13
          ,COL_CHAR_14
          ,COL_CHAR_15
          ,COL_CHAR_16
          ,COL_CHAR_17
          ,COL_CHAR_18
          ,COL_CHAR_19
          ,COL_CHAR_20
          ,COL_CHAR_21
          ,COL_CHAR_22
          ,COL_CHAR_23
          ,COL_CHAR_24
          ,COL_CHAR_25
          ,COL_CHAR_26
          ,COL_CHAR_27
          ,COL_CHAR_28
          ,COL_CHAR_29
          ,COL_CHAR_30
          ,COL_CHAR_31
          ,COL_CHAR_32
          ,COL_CHAR_33
          ,COL_CHAR_34
          ,COL_CHAR_35
          ,COL_CHAR_36
          ,COL_CHAR_37
          ,COL_CHAR_38
          ,COL_CHAR_39
          ,COL_CHAR_40
          ,COL_CHAR_41
          ,COL_CHAR_42
          ,COL_CHAR_43
          ,COL_CHAR_44
          ,COL_CHAR_45
          ,COL_CHAR_46
          ,COL_CHAR_47
          ,COL_CHAR_48
          ,COL_CHAR_49
          ,COL_CHAR_50
          ,COL_CHAR_51
          ,COL_CHAR_52
          ,COL_CHAR_53
          ,COL_CHAR_54
          ,COL_CHAR_55
          ,COL_CHAR_56
          ,COL_CHAR_57
          ,COL_CHAR_58
          ,COL_CHAR_59
          ,COL_CHAR_60
          ,COL_CHAR_61
          ,COL_CHAR_62
          ,COL_CHAR_63
          ,COL_CHAR_64
          ,COL_CHAR_65
          ,COL_CHAR_66
          ,COL_CHAR_67
          ,COL_CHAR_68
          ,COL_CHAR_69
          ,COL_CHAR_70
          ,COL_CHAR_71
          ,COL_CHAR_72
          ,COL_CHAR_73
          ,COL_CHAR_74
          ,COL_CHAR_75
          ,COL_CHAR_76
          ,COL_CHAR_77
          ,COL_CHAR_78
          ,COL_CHAR_79
          ,COL_CHAR_80
          ,COL_CHAR_81
          ,COL_CHAR_82
          ,COL_CHAR_83
          ,COL_CHAR_84
          ,COL_CHAR_85
          ,COL_CHAR_86
          ,COL_CHAR_87
          ,COL_CHAR_88
          ,COL_CHAR_89
          ,COL_CHAR_90
          ,COL_CHAR_91
          ,COL_CHAR_92
          ,COL_CHAR_93
          ,COL_CHAR_94
          ,COL_CHAR_95
          ,COL_CHAR_96
          ,COL_CHAR_97
          ,COL_CHAR_98
          ,COL_CHAR_99
          ,COL_CHAR_100
          ,COL_CHAR_101
          ,COL_CHAR_102
          ,COL_CHAR_103
          ,COL_CHAR_104
          ,COL_CHAR_105
          ,COL_CHAR_106
          ,COL_CHAR_107
          ,COL_CHAR_108
          ,COL_CHAR_109
          ,COL_CHAR_110
          ,COL_CHAR_111
          ,COL_CHAR_112
          ,COL_CHAR_113
          ,COL_CHAR_114
          ,COL_CHAR_115
          ,COL_CHAR_116
          ,COL_CHAR_117
          ,COL_CHAR_118
          ,COL_CHAR_119
          ,COL_CHAR_120
          ,COL_CHAR_121
          ,COL_CHAR_122
          ,COL_CHAR_123
          ,COL_CHAR_124
          ,COL_CHAR_125
          ,COL_CHAR_126
          ,COL_CHAR_127
          ,COL_CHAR_128
          ,COL_CHAR_129
          ,COL_CHAR_130
          ,COL_CHAR_131
          ,COL_CHAR_132
          ,COL_CHAR_133
          ,COL_CHAR_134
          ,COL_CHAR_135
          ,COL_CHAR_136
          ,COL_CHAR_137
          ,COL_CHAR_138
          ,COL_CHAR_139
          ,COL_CHAR_140
          ,COL_CHAR_141
          ,COL_CHAR_142
          ,COL_CHAR_143
          ,COL_CHAR_144
          ,COL_CHAR_145
          ,COL_CHAR_146
          ,COL_CHAR_147
          ,COL_CHAR_148
          ,COL_CHAR_149
          ,COL_CHAR_150
          ,COL_CHAR_151
          ,COL_CHAR_152
          ,COL_CHAR_153
          ,COL_CHAR_154
          ,COL_CHAR_155
          ,COL_CHAR_156
          ,COL_CHAR_157
          ,COL_CHAR_158
          ,COL_CHAR_159
          ,COL_CHAR_160
          ,COL_CHAR_161
          ,COL_CHAR_162
          ,COL_CHAR_163
          ,COL_CHAR_164
          ,COL_CHAR_165
          ,COL_CHAR_166
          ,COL_CHAR_167
          ,COL_CHAR_168
          ,COL_CHAR_169
          ,COL_CHAR_170
          ,COL_CHAR_171
          ,COL_CHAR_172
          ,COL_CHAR_173
          ,COL_CHAR_174
          ,COL_CHAR_175
          ,COL_CHAR_176
          ,COL_CHAR_177
          ,COL_CHAR_178
          ,COL_CHAR_179
          ,COL_CHAR_180
          ,COL_CHAR_181
          ,COL_CHAR_182
          ,COL_CHAR_183
          ,COL_CHAR_184
          ,COL_CHAR_185
          ,COL_CHAR_186
          ,COL_CHAR_187
          ,COL_CHAR_188
          ,COL_CHAR_189
          ,COL_CHAR_190
          ,COL_CHAR_191
          ,COL_CHAR_192
          ,COL_CHAR_193
          ,COL_CHAR_194
          ,COL_CHAR_195
          ,COL_CHAR_196
          ,COL_CHAR_197
          ,COL_CHAR_198
          ,COL_CHAR_199
          ,COL_CHAR_200
          ,COL_CHAR_201
          ,COL_CHAR_202
          ,COL_CHAR_203
          ,COL_CHAR_204
          ,COL_CHAR_205
          ,COL_CHAR_206
          ,COL_CHAR_207
          ,COL_CHAR_208
          ,COL_CHAR_209
          ,COL_CHAR_210
          ,COL_CHAR_211
          ,COL_CHAR_212
          ,COL_CHAR_213
          ,COL_CHAR_214
          ,COL_CHAR_215
          ,COL_CHAR_216
          ,COL_CHAR_217
          ,COL_CHAR_218
          ,COL_CHAR_219
          ,COL_CHAR_220
          ,COL_CHAR_221
          ,COL_CHAR_222
          ,COL_CHAR_223
          ,COL_CHAR_224
          ,COL_CHAR_225
          ,COL_CHAR_226
          ,COL_CHAR_227
          ,COL_CHAR_228
          ,COL_CHAR_229
          ,COL_CHAR_230
          ,COL_CHAR_231
          ,COL_CHAR_232
          ,COL_CHAR_233
          ,COL_CHAR_234
          ,COL_CHAR_235
          ,COL_CHAR_236
          ,COL_DATE_01
          ,COL_DATE_02
          ,COL_DATE_03
          ,COL_DATE_04
          ,COL_DATE_11
          ,COL_DATE_12
          ,CONTEXT
          ,ATTRIBUTE1
          ,ATTRIBUTE2
          ,ATTRIBUTE3
          ,ATTRIBUTE4
          ,ATTRIBUTE5
          ,ATTRIBUTE6
          ,ATTRIBUTE7
          ,ATTRIBUTE8
          ,ATTRIBUTE9
          ,ATTRIBUTE10
          ,ATTRIBUTE11
          ,ATTRIBUTE12
          ,ATTRIBUTE13
          ,ATTRIBUTE14
          ,ATTRIBUTE15
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER
          ,SECURITY_GROUP_ID
           )
           Values
           (
               l_archive_id_tbl(i),
               l_table_id,
               l_pri_attribs_hist_rec_tab.price_attrib_history_id(i),
               l_pri_attribs_hist_rec_tab.transaction_id(i),
               l_pri_attribs_hist_rec_tab.pricing_attribute_id(i),
               l_pri_attribs_hist_rec_tab.pri_created_by(i),
               l_pri_attribs_hist_rec_tab.pri_last_updated_by(i),
               l_pri_attribs_hist_rec_tab.pri_last_update_login(i),
               l_pri_attribs_hist_rec_tab.pri_object_version_number(i),
               l_pri_attribs_hist_rec_tab.pri_security_group_id(i),
               l_pri_attribs_hist_rec_tab.old_pricing_context(i),
               l_pri_attribs_hist_rec_tab.new_pricing_context(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute1(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute1(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute2(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute2(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute3(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute3(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute4(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute4(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute5(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute5(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute6(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute6(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute7(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute7(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute8(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute8(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute9(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute9(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute10(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute10(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute11(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute11(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute12(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute12(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute13(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute13(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute14(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute14(i),
               l_pri_attribs_hist_rec_tab.old_pri_context(i),
               l_pri_attribs_hist_rec_tab.new_pri_context(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute1(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute1(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute2(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute2(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute3(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute3(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute4(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute4(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute5(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute5(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute6(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute6(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute7(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute7(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute8(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute8(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute9(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute9(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute10(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute10(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute11(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute11(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute12(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute12(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute13(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute13(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute14(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute14(i),
               l_pri_attribs_hist_rec_tab.old_pri_attribute15(i),
               l_pri_attribs_hist_rec_tab.new_pri_attribute15(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute15(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute15(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute16(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute16(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute17(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute17(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute18(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute18(i),
               l_pri_attribs_hist_rec_tab.pri_full_dump_flag(i),
               l_pri_attribs_hist_rec_tab.pri_migrated_flag(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute19(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute19(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute20(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute20(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute21(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute21(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute22(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute22(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute23(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute23(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute24(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute24(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute25(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute25(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute26(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute26(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute27(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute27(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute28(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute28(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute29(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute29(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute30(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute30(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute31(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute31(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute32(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute32(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute33(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute33(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute34(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute34(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute35(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute35(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute36(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute36(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute37(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute37(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute38(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute38(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute39(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute39(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute40(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute40(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute41(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute41(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute42(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute42(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute43(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute43(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute44(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute44(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute45(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute45(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute46(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute46(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute47(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute47(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute48(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute48(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute49(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute49(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute50(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute50(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute51(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute51(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute52(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute52(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute53(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute53(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute54(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute54(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute55(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute55(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute56(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute56(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute57(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute57(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute58(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute58(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute59(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute59(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute60(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute60(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute61(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute61(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute62(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute62(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute63(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute63(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute64(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute64(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute65(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute65(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute66(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute66(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute67(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute67(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute68(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute68(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute69(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute69(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute70(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute70(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute71(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute71(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute72(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute72(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute73(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute73(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute74(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute74(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute75(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute75(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute76(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute76(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute77(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute77(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute78(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute78(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute79(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute79(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute80(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute80(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute81(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute81(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute82(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute82(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute83(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute83(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute84(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute84(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute85(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute85(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute86(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute86(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute87(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute87(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute88(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute88(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute89(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute89(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute90(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute90(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute91(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute91(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute92(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute92(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute93(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute93(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute94(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute94(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute95(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute95(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute96(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute96(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute97(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute97(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute98(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute98(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute99(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute99(i),
               l_pri_attribs_hist_rec_tab.old_pricing_attribute100(i),
               l_pri_attribs_hist_rec_tab.new_pricing_attribute100(i),
               l_pri_attribs_hist_rec_tab.old_pri_active_start_date(i),
               l_pri_attribs_hist_rec_tab.new_pri_active_start_date(i),
               l_pri_attribs_hist_rec_tab.old_pri_active_end_date(i),
               l_pri_attribs_hist_rec_tab.new_pri_active_end_date(i),
               l_pri_attribs_hist_rec_tab.pri_creation_date(i),
               l_pri_attribs_hist_rec_tab.pri_last_update_date(i),
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               l_user_id,
               sysdate,
               l_user_id,
               sysdate,
               l_login_id,
               1,
               null
               );

         -- Purge the corresonding Archive data from the Instance history tables

            FORALL i IN 1 .. l_cnt

               Delete From CSI_I_PRICING_ATTRIBS_H
               Where price_attrib_history_id = l_pri_attribs_hist_rec_tab.price_attrib_history_id(i);


       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Pricing_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure PriAttribs_Archive

--
-- This program is used to archive the Operating units history. It accepts from and to transactions
-- as the input parameters.
--

PROCEDURE Assets_archive( errbuf       OUT NOCOPY VARCHAR2,
                          retcode      OUT NOCOPY NUMBER,
                          from_trans   IN  NUMBER,
                          to_trans     IN  NUMBER,
                          purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor ins_asset_hist_csr (p_from_trans IN NUMBER,
                               p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_I_ASSETS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_ins_asset_hist_csr         ins_asset_hist_csr%ROWTYPE;
    l_ins_asset_hist_rec_tab     csi_txn_history_purge_pvt.ins_asset_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_I_ASSETS_H';
    Exception
      When no_data_found Then
        l_table_id := 7;
      When others Then
        l_table_id := 7;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Asset_Archive;
      l_ctr := 0;
      --
      l_ins_asset_hist_rec_tab.instance_asset_history_id.DELETE;
      l_ins_asset_hist_rec_tab.instance_asset_id.DELETE;
      l_ins_asset_hist_rec_tab.transaction_id.DELETE;
      l_ins_asset_hist_rec_tab.old_instance_id.DELETE;
      l_ins_asset_hist_rec_tab.new_instance_id.DELETE;
      l_ins_asset_hist_rec_tab.old_fa_asset_id.DELETE;
      l_ins_asset_hist_rec_tab.new_fa_asset_id.DELETE;
      l_ins_asset_hist_rec_tab.old_asset_quantity.DELETE;
      l_ins_asset_hist_rec_tab.new_asset_quantity.DELETE;
      l_ins_asset_hist_rec_tab.old_fa_book_type_code.DELETE;
      l_ins_asset_hist_rec_tab.new_fa_book_type_code.DELETE;
      l_ins_asset_hist_rec_tab.old_fa_location_id.DELETE;
      l_ins_asset_hist_rec_tab.new_fa_location_id.DELETE;
      l_ins_asset_hist_rec_tab.old_update_status.DELETE;
      l_ins_asset_hist_rec_tab.new_update_status.DELETE;
      l_ins_asset_hist_rec_tab.old_ast_active_start_date.DELETE;
      l_ins_asset_hist_rec_tab.new_ast_active_start_date.DELETE;
      l_ins_asset_hist_rec_tab.old_ast_active_end_date.DELETE;
      l_ins_asset_hist_rec_tab.new_ast_active_end_date.DELETE;
      l_ins_asset_hist_rec_tab.ast_full_dump_flag.DELETE;
      l_ins_asset_hist_rec_tab.ast_created_by.DELETE;
      l_ins_asset_hist_rec_tab.ast_creation_date.DELETE;
      l_ins_asset_hist_rec_tab.ast_last_updated_by.DELETE;
      l_ins_asset_hist_rec_tab.ast_last_update_date.DELETE;
      l_ins_asset_hist_rec_tab.ast_last_update_login.DELETE;
      l_ins_asset_hist_rec_tab.ast_object_version_number.DELETE;
      l_ins_asset_hist_rec_tab.ast_security_group_id.DELETE;
      l_ins_asset_hist_rec_tab.ast_migrated_flag.DELETE;
      --

  For i in ins_asset_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_ins_asset_hist_rec_tab.instance_asset_history_id(l_ctr)        :=  i.instance_asset_history_id;
      l_ins_asset_hist_rec_tab.instance_asset_id(l_ctr)                :=  i.instance_asset_id;
      l_ins_asset_hist_rec_tab.transaction_id(l_ctr)                   :=  i.transaction_id;
      l_ins_asset_hist_rec_tab.old_instance_id(l_ctr)                  :=  i.old_instance_id;
      l_ins_asset_hist_rec_tab.new_instance_id(l_ctr)                  :=  i.new_instance_id;
      l_ins_asset_hist_rec_tab.old_fa_asset_id(l_ctr)                  :=  i.old_fa_asset_id;
      l_ins_asset_hist_rec_tab.new_fa_asset_id(l_ctr)                  :=  i.new_fa_asset_id;
      l_ins_asset_hist_rec_tab.old_asset_quantity(l_ctr)               :=  i.old_asset_quantity;
      l_ins_asset_hist_rec_tab.new_asset_quantity(l_ctr)               :=  i.new_asset_quantity;
      l_ins_asset_hist_rec_tab.old_fa_book_type_code(l_ctr)            :=  i.old_fa_book_type_code;
      l_ins_asset_hist_rec_tab.new_fa_book_type_code(l_ctr)            :=  i.new_fa_book_type_code;
      l_ins_asset_hist_rec_tab.old_fa_location_id(l_ctr)               :=  i.old_fa_location_id;
      l_ins_asset_hist_rec_tab.new_fa_location_id(l_ctr)               :=  i.new_fa_location_id;
      l_ins_asset_hist_rec_tab.old_update_status(l_ctr)                :=  i.old_update_status;
      l_ins_asset_hist_rec_tab.new_update_status(l_ctr)                :=  i.new_update_status;
      l_ins_asset_hist_rec_tab.old_ast_active_start_date(l_ctr)        :=  i.old_active_start_date;
      l_ins_asset_hist_rec_tab.new_ast_active_start_date(l_ctr)        :=  i.new_active_start_date;
      l_ins_asset_hist_rec_tab.old_ast_active_end_date(l_ctr)          :=  i.old_active_end_date;
      l_ins_asset_hist_rec_tab.new_ast_active_end_date(l_ctr)          :=  i.new_active_end_date;
      l_ins_asset_hist_rec_tab.ast_full_dump_flag(l_ctr)	           :=  i.full_dump_flag;
      l_ins_asset_hist_rec_tab.ast_created_by(l_ctr)                   :=  i.created_by;
      l_ins_asset_hist_rec_tab.ast_creation_date(l_ctr)                :=  i.creation_date;
      l_ins_asset_hist_rec_tab.ast_last_updated_by(l_ctr)              :=  i.last_updated_by;
      l_ins_asset_hist_rec_tab.ast_last_update_date(l_ctr)             :=  i.last_update_date;
      l_ins_asset_hist_rec_tab.ast_last_update_login(l_ctr)            :=  i.last_update_login;
      l_ins_asset_hist_rec_tab.ast_object_version_number(l_ctr)	       :=  i.object_version_number;
      l_ins_asset_hist_rec_tab.ast_security_group_id(l_ctr)	           :=  i.security_group_id;
      l_ins_asset_hist_rec_tab.ast_migrated_flag(l_ctr)	               :=  i.migrated_flag;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_ins_asset_hist_rec_tab.instance_asset_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Instance Asset history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (

            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_01
           ,COL_NUM_02
           ,COL_NUM_03
           ,COL_NUM_04
           ,COL_NUM_05
           ,COL_NUM_06
           ,COL_NUM_07
           ,COL_NUM_08
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_03
           ,COL_CHAR_04
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_ins_asset_hist_rec_tab.instance_asset_history_id(i),
           l_ins_asset_hist_rec_tab.transaction_id(i),
           l_ins_asset_hist_rec_tab.instance_asset_id(i),
           l_ins_asset_hist_rec_tab.old_instance_id(i),
           l_ins_asset_hist_rec_tab.new_instance_id(i),
           l_ins_asset_hist_rec_tab.old_fa_asset_id(i),
           l_ins_asset_hist_rec_tab.new_fa_asset_id(i),
           l_ins_asset_hist_rec_tab.old_asset_quantity(i),
           l_ins_asset_hist_rec_tab.new_asset_quantity(i),
           l_ins_asset_hist_rec_tab.old_fa_location_id(i),
           l_ins_asset_hist_rec_tab.new_fa_location_id(i),
           l_ins_asset_hist_rec_tab.ast_created_by(i),
           l_ins_asset_hist_rec_tab.ast_last_updated_by(i),
           l_ins_asset_hist_rec_tab.ast_last_update_login(i),
	   l_ins_asset_hist_rec_tab.ast_object_version_number(i), -- obj_ver_num
           l_ins_asset_hist_rec_tab.ast_security_group_id(i), -- sec_grp_id
           l_ins_asset_hist_rec_tab.old_fa_book_type_code(i),
           l_ins_asset_hist_rec_tab.new_fa_book_type_code(i),
           l_ins_asset_hist_rec_tab.old_update_status(i),
           l_ins_asset_hist_rec_tab.new_update_status(i),
           l_ins_asset_hist_rec_tab.ast_full_dump_flag(i), --'N', dump_flag
           l_ins_asset_hist_rec_tab.ast_migrated_flag(i), -- mig_flag
           l_ins_asset_hist_rec_tab.old_ast_active_start_date(i),
           l_ins_asset_hist_rec_tab.new_ast_active_start_date(i),
           l_ins_asset_hist_rec_tab.old_ast_active_end_date(i),
           l_ins_asset_hist_rec_tab.new_ast_active_end_date(i),
           l_ins_asset_hist_rec_tab.ast_creation_date(i),
           l_ins_asset_hist_rec_tab.ast_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

         -- Purge the corresonding Archive data from the Instance Asset history tables

            FORALL i IN 1 .. l_cnt

               Delete From CSI_I_ASSETS_H
               Where instance_asset_history_id = l_ins_asset_hist_rec_tab.instance_asset_history_id(i);

       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Asset_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure InstAssets_Archive


PROCEDURE Ver_Labels_archive( errbuf       OUT NOCOPY VARCHAR2,
                              retcode      OUT NOCOPY NUMBER,
                              from_trans   IN  NUMBER,
                              to_trans     IN  NUMBER,
                              purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor ver_label_hist_csr (p_from_trans IN NUMBER,
                               p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_I_VERSION_LABELS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_ver_label_hist_csr         ver_label_hist_csr%ROWTYPE;
    l_ver_label_hist_rec_tab     csi_txn_history_purge_pvt.ver_label_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_I_VERSION_LABELS_H';
    Exception
      When no_data_found Then
        l_table_id := 8;
      When others Then
        l_table_id := 8;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Version_Archive;
      l_ctr := 0;
      --
      l_ver_label_hist_rec_tab.version_label_history_id.DELETE;
      l_ver_label_hist_rec_tab.version_label_id.DELETE;
      l_ver_label_hist_rec_tab.transaction_id.DELETE;
      l_ver_label_hist_rec_tab.old_version_label.DELETE;
      l_ver_label_hist_rec_tab.new_version_label.DELETE;
      l_ver_label_hist_rec_tab.old_ver_description.DELETE;
      l_ver_label_hist_rec_tab.new_ver_description.DELETE;
      l_ver_label_hist_rec_tab.old_date_time_stamp.DELETE;
      l_ver_label_hist_rec_tab.new_date_time_stamp.DELETE;
      l_ver_label_hist_rec_tab.old_ver_active_start_date.DELETE;
      l_ver_label_hist_rec_tab.new_ver_active_start_date.DELETE;
      l_ver_label_hist_rec_tab.old_ver_active_end_date.DELETE;
      l_ver_label_hist_rec_tab.new_ver_active_end_date.DELETE;
      l_ver_label_hist_rec_tab.old_ver_context.DELETE;
      l_ver_label_hist_rec_tab.new_ver_context.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute1.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute1.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute2.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute2.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute3.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute3.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute4.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute4.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute5.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute5.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute6.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute6.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute7.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute7.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute8.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute8.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute9.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute9.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute10.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute10.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute11.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute11.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute12.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute12.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute13.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute13.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute14.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute14.DELETE;
      l_ver_label_hist_rec_tab.old_ver_attribute15.DELETE;
      l_ver_label_hist_rec_tab.new_ver_attribute15.DELETE;
      l_ver_label_hist_rec_tab.ver_full_dump_flag.DELETE;
      l_ver_label_hist_rec_tab.ver_created_by.DELETE;
      l_ver_label_hist_rec_tab.ver_creation_date.DELETE;
      l_ver_label_hist_rec_tab.ver_last_updated_by.DELETE;
      l_ver_label_hist_rec_tab.ver_last_update_date.DELETE;
      l_ver_label_hist_rec_tab.ver_last_update_login.DELETE;
      l_ver_label_hist_rec_tab.ver_object_version_number.DELETE;
      l_ver_label_hist_rec_tab.ver_security_group_id.DELETE;
      l_ver_label_hist_rec_tab.ver_migrated_flag.DELETE;
      --

  For i in ver_label_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_ver_label_hist_rec_tab.version_label_history_id(l_ctr)         :=  i.version_label_history_id;
      l_ver_label_hist_rec_tab.version_label_id(l_ctr)                 :=  i.version_label_id;
      l_ver_label_hist_rec_tab.transaction_id(l_ctr)                   :=  i.transaction_id;
      l_ver_label_hist_rec_tab.old_version_label(l_ctr)                :=  i.old_version_label;
      l_ver_label_hist_rec_tab.new_version_label(l_ctr)                :=  i.new_version_label;
      l_ver_label_hist_rec_tab.old_ver_description(l_ctr)              :=  i.old_description;
      l_ver_label_hist_rec_tab.new_ver_description(l_ctr)              :=  i.new_description;
      l_ver_label_hist_rec_tab.old_date_time_stamp(l_ctr)              :=  i.old_date_time_stamp;
      l_ver_label_hist_rec_tab.new_date_time_stamp(l_ctr)              :=  i.new_date_time_stamp;
      l_ver_label_hist_rec_tab.old_ver_active_start_date(l_ctr)        :=  i.old_active_start_date;
      l_ver_label_hist_rec_tab.new_ver_active_start_date(l_ctr)        :=  i.new_active_start_date;
      l_ver_label_hist_rec_tab.old_ver_active_end_date(l_ctr)          :=  i.old_active_end_date;
      l_ver_label_hist_rec_tab.new_ver_active_end_date(l_ctr)          :=  i.new_active_end_date;
      l_ver_label_hist_rec_tab.old_ver_context(l_ctr)	               :=  i.old_context;
      l_ver_label_hist_rec_tab.new_ver_context(l_ctr)	               :=  i.new_context;
      l_ver_label_hist_rec_tab.old_ver_attribute1(l_ctr)	           :=  i.old_attribute1;
      l_ver_label_hist_rec_tab.new_ver_attribute1(l_ctr)	           :=  i.new_attribute1;
      l_ver_label_hist_rec_tab.old_ver_attribute2(l_ctr)	           :=  i.old_attribute2;
      l_ver_label_hist_rec_tab.new_ver_attribute2(l_ctr)	           :=  i.new_attribute2;
      l_ver_label_hist_rec_tab.old_ver_attribute3(l_ctr)	           :=  i.old_attribute3;
      l_ver_label_hist_rec_tab.new_ver_attribute3(l_ctr)	           :=  i.new_attribute3;
      l_ver_label_hist_rec_tab.old_ver_attribute4(l_ctr)	           :=  i.old_attribute4;
      l_ver_label_hist_rec_tab.new_ver_attribute4(l_ctr)	           :=  i.new_attribute4;
      l_ver_label_hist_rec_tab.old_ver_attribute5(l_ctr)	           :=  i.old_attribute5;
      l_ver_label_hist_rec_tab.new_ver_attribute5(l_ctr)	           :=  i.new_attribute5;
      l_ver_label_hist_rec_tab.old_ver_attribute6(l_ctr)	           :=  i.old_attribute6;
      l_ver_label_hist_rec_tab.new_ver_attribute6(l_ctr)	           :=  i.new_attribute6;
      l_ver_label_hist_rec_tab.old_ver_attribute7(l_ctr)	           :=  i.old_attribute7;
      l_ver_label_hist_rec_tab.new_ver_attribute7(l_ctr)	           :=  i.new_attribute7;
      l_ver_label_hist_rec_tab.old_ver_attribute8(l_ctr)	           :=  i.old_attribute8;
      l_ver_label_hist_rec_tab.new_ver_attribute8(l_ctr)	           :=  i.new_attribute8;
      l_ver_label_hist_rec_tab.old_ver_attribute9(l_ctr)	           :=  i.old_attribute9;
      l_ver_label_hist_rec_tab.new_ver_attribute9(l_ctr)	           :=  i.new_attribute9;
      l_ver_label_hist_rec_tab.old_ver_attribute10(l_ctr)	           :=  i.old_attribute10;
      l_ver_label_hist_rec_tab.new_ver_attribute10(l_ctr)	           :=  i.new_attribute10;
      l_ver_label_hist_rec_tab.old_ver_attribute11(l_ctr)      	       :=  i.old_attribute11;
      l_ver_label_hist_rec_tab.new_ver_attribute11(l_ctr)	           :=  i.new_attribute11;
      l_ver_label_hist_rec_tab.old_ver_attribute12(l_ctr)	           :=  i.old_attribute12;
      l_ver_label_hist_rec_tab.new_ver_attribute12(l_ctr)	           :=  i.new_attribute12;
      l_ver_label_hist_rec_tab.old_ver_attribute13(l_ctr)	           :=  i.old_attribute13;
      l_ver_label_hist_rec_tab.new_ver_attribute13(l_ctr)	           :=  i.new_attribute13;
      l_ver_label_hist_rec_tab.old_ver_attribute14(l_ctr)	           :=  i.old_attribute14;
      l_ver_label_hist_rec_tab.new_ver_attribute14(l_ctr)	           :=  i.new_attribute14;
      l_ver_label_hist_rec_tab.old_ver_attribute15(l_ctr)	           :=  i.old_attribute15;
      l_ver_label_hist_rec_tab.new_ver_attribute15(l_ctr)	           :=  i.new_attribute15;
      l_ver_label_hist_rec_tab.ver_full_dump_flag(l_ctr)	           :=  i.full_dump_flag;
      l_ver_label_hist_rec_tab.ver_created_by(l_ctr)                   :=  i.created_by;
      l_ver_label_hist_rec_tab.ver_creation_date(l_ctr)                :=  i.creation_date;
      l_ver_label_hist_rec_tab.ver_last_updated_by(l_ctr)              :=  i.last_updated_by;
      l_ver_label_hist_rec_tab.ver_last_update_date(l_ctr)             :=  i.last_update_date;
      l_ver_label_hist_rec_tab.ver_last_update_login(l_ctr)            :=  i.last_update_login;
      l_ver_label_hist_rec_tab.ver_object_version_number(l_ctr)	       :=  i.object_version_number;
      l_ver_label_hist_rec_tab.ver_security_group_id(l_ctr)	           :=  i.security_group_id;
      l_ver_label_hist_rec_tab.ver_migrated_flag(l_ctr)	               :=  i.migrated_flag;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_ver_label_hist_rec_tab.version_label_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Instance Version labels history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_03
           ,COL_CHAR_04
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_05
           ,COL_DATE_06
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_ver_label_hist_rec_tab.version_label_history_id(i),
           l_ver_label_hist_rec_tab.transaction_id(i),
           l_ver_label_hist_rec_tab.version_label_id(i),
           l_ver_label_hist_rec_tab.ver_created_by(i),
           l_ver_label_hist_rec_tab.ver_last_updated_by(i),
           l_ver_label_hist_rec_tab.ver_last_update_login(i),
           l_ver_label_hist_rec_tab.ver_object_version_number(i), -- obj_ver_num
           l_ver_label_hist_rec_tab.ver_security_group_id(i), -- sec_grp_id
           l_ver_label_hist_rec_tab.old_version_label(i),
           l_ver_label_hist_rec_tab.new_version_label(i),
           l_ver_label_hist_rec_tab.old_ver_description(i),
           l_ver_label_hist_rec_tab.new_ver_description(i),
           l_ver_label_hist_rec_tab.old_ver_context(i),
           l_ver_label_hist_rec_tab.new_ver_context(i),
           l_ver_label_hist_rec_tab.old_ver_attribute1(i),
           l_ver_label_hist_rec_tab.new_ver_attribute1(i),
           l_ver_label_hist_rec_tab.old_ver_attribute2(i),
           l_ver_label_hist_rec_tab.new_ver_attribute2(i),
           l_ver_label_hist_rec_tab.old_ver_attribute3(i),
           l_ver_label_hist_rec_tab.new_ver_attribute3(i),
           l_ver_label_hist_rec_tab.old_ver_attribute4(i),
           l_ver_label_hist_rec_tab.new_ver_attribute4(i),
           l_ver_label_hist_rec_tab.old_ver_attribute5(i),
           l_ver_label_hist_rec_tab.new_ver_attribute5(i),
           l_ver_label_hist_rec_tab.old_ver_attribute6(i),
           l_ver_label_hist_rec_tab.new_ver_attribute6(i),
           l_ver_label_hist_rec_tab.old_ver_attribute7(i),
           l_ver_label_hist_rec_tab.new_ver_attribute7(i),
           l_ver_label_hist_rec_tab.old_ver_attribute8(i),
           l_ver_label_hist_rec_tab.new_ver_attribute8(i),
           l_ver_label_hist_rec_tab.old_ver_attribute9(i),
           l_ver_label_hist_rec_tab.new_ver_attribute9(i),
           l_ver_label_hist_rec_tab.old_ver_attribute10(i),
           l_ver_label_hist_rec_tab.new_ver_attribute10(i),
           l_ver_label_hist_rec_tab.old_ver_attribute11(i),
           l_ver_label_hist_rec_tab.new_ver_attribute11(i),
           l_ver_label_hist_rec_tab.old_ver_attribute12(i),
           l_ver_label_hist_rec_tab.new_ver_attribute12(i),
           l_ver_label_hist_rec_tab.old_ver_attribute13(i),
           l_ver_label_hist_rec_tab.new_ver_attribute13(i),
           l_ver_label_hist_rec_tab.old_ver_attribute14(i),
           l_ver_label_hist_rec_tab.new_ver_attribute14(i),
           l_ver_label_hist_rec_tab.old_ver_attribute15(i),
           l_ver_label_hist_rec_tab.new_ver_attribute15(i),
           l_ver_label_hist_rec_tab.ver_full_dump_flag(i), --'N', dump_flag
           l_ver_label_hist_rec_tab.ver_migrated_flag(i), -- mig_flag
           l_ver_label_hist_rec_tab.old_ver_active_start_date(i),
           l_ver_label_hist_rec_tab.new_ver_active_start_date(i),
           l_ver_label_hist_rec_tab.old_ver_active_end_date(i),
           l_ver_label_hist_rec_tab.new_ver_active_end_date(i),
           l_ver_label_hist_rec_tab.old_date_time_stamp(i),
           l_ver_label_hist_rec_tab.new_date_time_stamp(i),
           l_ver_label_hist_rec_tab.ver_creation_date(i),
           l_ver_label_hist_rec_tab.ver_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

         -- Purge the corresonding Archive data from the Instance Ver. Labels history tables

            FORALL i IN 1 .. l_cnt

              Delete From CSI_I_VERSION_LABELS_H
              Where version_label_history_id = l_ver_label_hist_rec_tab.version_label_history_id(i);


       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Version_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure VersionLabels_Archive


--
-- This program is used to archive the Operating units history. It accepts from and to transactions
-- as the input parameters.
--

PROCEDURE Inst_Relnships_archive( errbuf       OUT NOCOPY VARCHAR2,
                                  retcode      OUT NOCOPY NUMBER,
                                  from_trans   IN  NUMBER,
                                  to_trans     IN  NUMBER,
                                  purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor rel_hist_csr (p_from_trans IN NUMBER,
                         p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_II_RELATIONSHIPS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_rel_hist_csr         rel_hist_csr%ROWTYPE;
    l_rel_hist_rec_tab     csi_txn_history_purge_pvt.relationship_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_II_RELATIONSHIPS_H';
    Exception
      When no_data_found Then
        l_table_id := 9;
      When others Then
        l_table_id := 9;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT Rel_Archive;
      l_ctr := 0;
      --
      l_rel_hist_rec_tab.relationship_history_id.DELETE;
      l_rel_hist_rec_tab.relationship_id.DELETE;
      l_rel_hist_rec_tab.transaction_id.DELETE;
      l_rel_hist_rec_tab.old_subject_id.DELETE;
      l_rel_hist_rec_tab.new_subject_id.DELETE;
      l_rel_hist_rec_tab.old_position_reference.DELETE;
      l_rel_hist_rec_tab.new_position_reference.DELETE;
      l_rel_hist_rec_tab.old_rel_active_start_date.DELETE;
      l_rel_hist_rec_tab.new_rel_active_start_date.DELETE;
      l_rel_hist_rec_tab.old_rel_active_end_date.DELETE;
      l_rel_hist_rec_tab.new_rel_active_end_date.DELETE;
      l_rel_hist_rec_tab.old_mandatory_flag.DELETE;
      l_rel_hist_rec_tab.new_mandatory_flag.DELETE;
      l_rel_hist_rec_tab.old_rel_context.DELETE;
      l_rel_hist_rec_tab.new_rel_context.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute1.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute1.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute2.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute2.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute3.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute3.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute4.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute4.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute5.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute5.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute6.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute6.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute7.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute7.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute8.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute8.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute9.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute9.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute10.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute10.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute11.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute11.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute12.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute12.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute13.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute13.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute14.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute14.DELETE;
      l_rel_hist_rec_tab.old_rel_attribute15.DELETE;
      l_rel_hist_rec_tab.new_rel_attribute15.DELETE;
      l_rel_hist_rec_tab.rel_full_dump_flag.DELETE;
      l_rel_hist_rec_tab.rel_created_by.DELETE;
      l_rel_hist_rec_tab.rel_creation_date.DELETE;
      l_rel_hist_rec_tab.rel_last_updated_by.DELETE;
      l_rel_hist_rec_tab.rel_last_update_date.DELETE;
      l_rel_hist_rec_tab.rel_last_update_login.DELETE;
      l_rel_hist_rec_tab.rel_object_version_number.DELETE;
      l_rel_hist_rec_tab.rel_security_group_id.DELETE;
      l_rel_hist_rec_tab.rel_migrated_flag.DELETE;
      --

  For i in rel_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_rel_hist_rec_tab.relationship_history_id(l_ctr)        :=  i.relationship_history_id;
      l_rel_hist_rec_tab.relationship_id(l_ctr)                :=  i.relationship_id;
      l_rel_hist_rec_tab.transaction_id(l_ctr)                 :=  i.transaction_id;
      l_rel_hist_rec_tab.old_subject_id(l_ctr)                 :=  i.old_subject_id;
      l_rel_hist_rec_tab.new_subject_id(l_ctr)                 :=  i.new_subject_id;
      l_rel_hist_rec_tab.old_position_reference(l_ctr)         :=  i.old_position_reference;
      l_rel_hist_rec_tab.new_position_reference(l_ctr)         :=  i.new_position_reference;
      l_rel_hist_rec_tab.old_rel_active_start_date(l_ctr)      :=  i.old_active_start_date;
      l_rel_hist_rec_tab.new_rel_active_start_date(l_ctr)      :=  i.new_active_start_date;
      l_rel_hist_rec_tab.old_rel_active_end_date(l_ctr)        :=  i.old_active_end_date;
      l_rel_hist_rec_tab.new_rel_active_end_date(l_ctr)        :=  i.new_active_end_date;
      l_rel_hist_rec_tab.old_mandatory_flag(l_ctr)             :=  i.old_mandatory_flag;
      l_rel_hist_rec_tab.new_mandatory_flag(l_ctr)             :=  i.new_mandatory_flag;
      l_rel_hist_rec_tab.old_rel_context(l_ctr)	               :=  i.old_context;
      l_rel_hist_rec_tab.new_rel_context(l_ctr)	               :=  i.new_context;
      l_rel_hist_rec_tab.old_rel_attribute1(l_ctr)	           :=  i.old_attribute1;
      l_rel_hist_rec_tab.new_rel_attribute1(l_ctr)	           :=  i.new_attribute1;
      l_rel_hist_rec_tab.old_rel_attribute2(l_ctr)	           :=  i.old_attribute2;
      l_rel_hist_rec_tab.new_rel_attribute2(l_ctr)	           :=  i.new_attribute2;
      l_rel_hist_rec_tab.old_rel_attribute3(l_ctr)	           :=  i.old_attribute3;
      l_rel_hist_rec_tab.new_rel_attribute3(l_ctr)	           :=  i.new_attribute3;
      l_rel_hist_rec_tab.old_rel_attribute4(l_ctr)	           :=  i.old_attribute4;
      l_rel_hist_rec_tab.new_rel_attribute4(l_ctr)	           :=  i.new_attribute4;
      l_rel_hist_rec_tab.old_rel_attribute5(l_ctr)	           :=  i.old_attribute5;
      l_rel_hist_rec_tab.new_rel_attribute5(l_ctr)	           :=  i.new_attribute5;
      l_rel_hist_rec_tab.old_rel_attribute6(l_ctr)	           :=  i.old_attribute6;
      l_rel_hist_rec_tab.new_rel_attribute6(l_ctr)	           :=  i.new_attribute6;
      l_rel_hist_rec_tab.old_rel_attribute7(l_ctr)	           :=  i.old_attribute7;
      l_rel_hist_rec_tab.new_rel_attribute7(l_ctr)	           :=  i.new_attribute7;
      l_rel_hist_rec_tab.old_rel_attribute8(l_ctr)	           :=  i.old_attribute8;
      l_rel_hist_rec_tab.new_rel_attribute8(l_ctr)	           :=  i.new_attribute8;
      l_rel_hist_rec_tab.old_rel_attribute9(l_ctr)	           :=  i.old_attribute9;
      l_rel_hist_rec_tab.new_rel_attribute9(l_ctr)	           :=  i.new_attribute9;
      l_rel_hist_rec_tab.old_rel_attribute10(l_ctr)	           :=  i.old_attribute10;
      l_rel_hist_rec_tab.new_rel_attribute10(l_ctr)	           :=  i.new_attribute10;
      l_rel_hist_rec_tab.old_rel_attribute11(l_ctr)      	   :=  i.old_attribute11;
      l_rel_hist_rec_tab.new_rel_attribute11(l_ctr)	           :=  i.new_attribute11;
      l_rel_hist_rec_tab.old_rel_attribute12(l_ctr)	           :=  i.old_attribute12;
      l_rel_hist_rec_tab.new_rel_attribute12(l_ctr)	           :=  i.new_attribute12;
      l_rel_hist_rec_tab.old_rel_attribute13(l_ctr)	           :=  i.old_attribute13;
      l_rel_hist_rec_tab.new_rel_attribute13(l_ctr)	           :=  i.new_attribute13;
      l_rel_hist_rec_tab.old_rel_attribute14(l_ctr)	           :=  i.old_attribute14;
      l_rel_hist_rec_tab.new_rel_attribute14(l_ctr)	           :=  i.new_attribute14;
      l_rel_hist_rec_tab.old_rel_attribute15(l_ctr)	           :=  i.old_attribute15;
      l_rel_hist_rec_tab.new_rel_attribute15(l_ctr)	           :=  i.new_attribute15;
      l_rel_hist_rec_tab.rel_full_dump_flag(l_ctr)	           :=  i.full_dump_flag;
      l_rel_hist_rec_tab.rel_created_by(l_ctr)                 :=  i.created_by;
      l_rel_hist_rec_tab.rel_creation_date(l_ctr)              :=  i.creation_date;
      l_rel_hist_rec_tab.rel_last_updated_by(l_ctr)            :=  i.last_updated_by;
      l_rel_hist_rec_tab.rel_last_update_date(l_ctr)           :=  i.last_update_date;
      l_rel_hist_rec_tab.rel_last_update_login(l_ctr)          :=  i.last_update_login;
      l_rel_hist_rec_tab.rel_object_version_number(l_ctr)	   :=  i.object_version_number;
      l_rel_hist_rec_tab.rel_security_group_id(l_ctr)	       :=  i.security_group_id;
      l_rel_hist_rec_tab.rel_migrated_flag(l_ctr)	           :=  i.migrated_flag;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_rel_hist_rec_tab.relationship_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of Instance Relationships history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_01
           ,COL_NUM_02
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_03
           ,COL_CHAR_04
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_rel_hist_rec_tab.relationship_history_id(i),
           l_rel_hist_rec_tab.transaction_id(i),
           l_rel_hist_rec_tab.relationship_id(i),
           l_rel_hist_rec_tab.old_subject_id(i),
           l_rel_hist_rec_tab.new_subject_id(i),
           l_rel_hist_rec_tab.rel_created_by(i),
           l_rel_hist_rec_tab.rel_last_updated_by(i),
           l_rel_hist_rec_tab.rel_last_update_login(i),
           l_rel_hist_rec_tab.rel_object_version_number(i), -- obj_ver_num
           l_rel_hist_rec_tab.rel_security_group_id(i), -- sec_grp_id
           l_rel_hist_rec_tab.old_position_reference(i),
           l_rel_hist_rec_tab.new_position_reference(i),
           l_rel_hist_rec_tab.old_mandatory_flag(i),
           l_rel_hist_rec_tab.new_mandatory_flag(i),
           l_rel_hist_rec_tab.old_rel_context(i),
           l_rel_hist_rec_tab.new_rel_context(i),
           l_rel_hist_rec_tab.old_rel_attribute1(i),
           l_rel_hist_rec_tab.new_rel_attribute1(i),
           l_rel_hist_rec_tab.old_rel_attribute2(i),
           l_rel_hist_rec_tab.new_rel_attribute2(i),
           l_rel_hist_rec_tab.old_rel_attribute3(i),
           l_rel_hist_rec_tab.new_rel_attribute3(i),
           l_rel_hist_rec_tab.old_rel_attribute4(i),
           l_rel_hist_rec_tab.new_rel_attribute4(i),
           l_rel_hist_rec_tab.old_rel_attribute5(i),
           l_rel_hist_rec_tab.new_rel_attribute5(i),
           l_rel_hist_rec_tab.old_rel_attribute6(i),
           l_rel_hist_rec_tab.new_rel_attribute6(i),
           l_rel_hist_rec_tab.old_rel_attribute7(i),
           l_rel_hist_rec_tab.new_rel_attribute7(i),
           l_rel_hist_rec_tab.old_rel_attribute8(i),
           l_rel_hist_rec_tab.new_rel_attribute8(i),
           l_rel_hist_rec_tab.old_rel_attribute9(i),
           l_rel_hist_rec_tab.new_rel_attribute9(i),
           l_rel_hist_rec_tab.old_rel_attribute10(i),
           l_rel_hist_rec_tab.new_rel_attribute10(i),
           l_rel_hist_rec_tab.old_rel_attribute11(i),
           l_rel_hist_rec_tab.new_rel_attribute11(i),
           l_rel_hist_rec_tab.old_rel_attribute12(i),
           l_rel_hist_rec_tab.new_rel_attribute12(i),
           l_rel_hist_rec_tab.old_rel_attribute13(i),
           l_rel_hist_rec_tab.new_rel_attribute13(i),
           l_rel_hist_rec_tab.old_rel_attribute14(i),
           l_rel_hist_rec_tab.new_rel_attribute14(i),
           l_rel_hist_rec_tab.old_rel_attribute15(i),
           l_rel_hist_rec_tab.new_rel_attribute15(i),
           l_rel_hist_rec_tab.rel_full_dump_flag(i), --'N', dump_flag
           l_rel_hist_rec_tab.rel_migrated_flag(i), -- mig_flag
           l_rel_hist_rec_tab.old_rel_active_start_date(i),
           l_rel_hist_rec_tab.new_rel_active_start_date(i),
           l_rel_hist_rec_tab.old_rel_active_end_date(i),
           l_rel_hist_rec_tab.new_rel_active_end_date(i),
           l_rel_hist_rec_tab.rel_creation_date(i),
           l_rel_hist_rec_tab.rel_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

         -- Purge the corresonding Archive data from the Instance Rel. history tables

            FORALL i IN 1 .. l_cnt

               Delete From CSI_II_RELATIONSHIPS_H
               Where relationship_history_id = l_rel_hist_rec_tab.relationship_history_id(i);

       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to Rel_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure InstRels_Archive


--
-- This program is used to archive the Operating units history. It accepts from and to transactions
-- as the input parameters.
--

PROCEDURE Systems_archive( errbuf       OUT NOCOPY VARCHAR2,
                           retcode      OUT NOCOPY NUMBER,
                           from_trans   IN  NUMBER,
                           to_trans     IN  NUMBER,
                           purge_to_date IN VARCHAR2 )
IS

    l_archive_id      NUMBER;
    l_ctr             NUMBER := 0;
    l_cnt             NUMBER;
    l_table_id        NUMBER;
    l_user_id         NUMBER := FND_GLOBAL.USER_ID;
    l_login_id        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    v_batch           NUMBER := 15000;
    v_start           NUMBER;
    v_end             NUMBER;

    Type NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_archive_id_tbl   NUMLIST;

    Cursor sys_hist_csr (p_from_trans IN NUMBER,
                         p_to_trans   IN NUMBER) IS
    Select csh.*
    From   CSI_SYSTEMS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between p_from_trans and p_to_trans   --Bug 8836533
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;

    l_sys_hist_csr         sys_hist_csr%ROWTYPE;
    l_sys_hist_rec_tab     csi_txn_history_purge_pvt.system_history_rec_tab;


Begin
    --
    --
    Begin
      Select object_id
      Into   l_table_id
      From   csi_object_dictionary
      Where  object_name = 'CSI_SYSTEMS_H';
    Exception
      When no_data_found Then
        l_table_id := 10;
      When others Then
        l_table_id := 10;
    End;
    --
    Begin
      Select fnd_profile.value('CSI_TXN_HISTORY_PURGE_BATCH_SIZE')
      Into   v_batch
      From   dual;
    Exception
      When no_data_found Then
        v_batch := 15000;
    End;
    --
    v_start := from_trans;
    v_end   := from_trans + v_batch;
    --
    If v_end > to_trans Then
       v_end := to_trans;
    End If;
    --
 Loop
   Begin
      SAVEPOINT System_Archive;
      l_ctr := 0;
      --
      l_sys_hist_rec_tab.system_history_id.DELETE;
      l_sys_hist_rec_tab.system_id.DELETE;
      l_sys_hist_rec_tab.transaction_id.DELETE;
      l_sys_hist_rec_tab.old_customer_id.DELETE;
      l_sys_hist_rec_tab.new_customer_id.DELETE;
      l_sys_hist_rec_tab.old_system_type_code.DELETE;
      l_sys_hist_rec_tab.new_system_type_code.DELETE;
      l_sys_hist_rec_tab.old_system_number.DELETE;
      l_sys_hist_rec_tab.new_system_number.DELETE;
      l_sys_hist_rec_tab.old_parent_system_id.DELETE;
      l_sys_hist_rec_tab.new_parent_system_id.DELETE;
      l_sys_hist_rec_tab.old_ship_to_contact_id.DELETE;
      l_sys_hist_rec_tab.new_ship_to_contact_id.DELETE;
      l_sys_hist_rec_tab.old_bill_to_contact_id.DELETE;
      l_sys_hist_rec_tab.new_bill_to_contact_id.DELETE;
      l_sys_hist_rec_tab.old_technical_contact_id.DELETE;
      l_sys_hist_rec_tab.new_technical_contact_id.DELETE;
      l_sys_hist_rec_tab.old_service_admin_contact_id.DELETE;
      l_sys_hist_rec_tab.new_service_admin_contact_id.DELETE;
      l_sys_hist_rec_tab.old_ship_to_site_use_id.DELETE;
      l_sys_hist_rec_tab.new_ship_to_site_use_id.DELETE;
      l_sys_hist_rec_tab.old_install_site_use_id.DELETE;
      l_sys_hist_rec_tab.new_install_site_use_id.DELETE;
      l_sys_hist_rec_tab.old_bill_to_site_use_id.DELETE;
      l_sys_hist_rec_tab.new_bill_to_site_use_id.DELETE;
      l_sys_hist_rec_tab.old_coterminate_day_month.DELETE;
      l_sys_hist_rec_tab.new_coterminate_day_month.DELETE;
      l_sys_hist_rec_tab.old_sys_active_start_date.DELETE;
      l_sys_hist_rec_tab.new_sys_active_start_date.DELETE;
      l_sys_hist_rec_tab.old_sys_active_end_date.DELETE;
      l_sys_hist_rec_tab.new_sys_active_end_date.DELETE;
      l_sys_hist_rec_tab.old_autocreated_from_system.DELETE;
      l_sys_hist_rec_tab.new_autocreated_from_system.DELETE;
      l_sys_hist_rec_tab.old_config_system_type.DELETE;
      l_sys_hist_rec_tab.new_config_system_type.DELETE;
      l_sys_hist_rec_tab.old_name.DELETE;
      l_sys_hist_rec_tab.new_name.DELETE;
      l_sys_hist_rec_tab.old_sys_description.DELETE;
      l_sys_hist_rec_tab.new_sys_description.DELETE;
      l_sys_hist_rec_tab.old_sys_context.DELETE;
      l_sys_hist_rec_tab.new_sys_context.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute1.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute1.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute2.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute2.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute3.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute3.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute4.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute4.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute5.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute5.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute6.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute6.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute7.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute7.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute8.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute8.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute9.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute9.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute10.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute10.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute11.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute11.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute12.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute12.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute13.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute13.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute14.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute14.DELETE;
      l_sys_hist_rec_tab.old_sys_attribute15.DELETE;
      l_sys_hist_rec_tab.new_sys_attribute15.DELETE;
      l_sys_hist_rec_tab.sys_full_dump_flag.DELETE;
      l_sys_hist_rec_tab.sys_created_by.DELETE;
      l_sys_hist_rec_tab.sys_creation_date.DELETE;
      l_sys_hist_rec_tab.sys_last_updated_by.DELETE;
      l_sys_hist_rec_tab.sys_last_update_date.DELETE;
      l_sys_hist_rec_tab.sys_last_update_login.DELETE;
      l_sys_hist_rec_tab.sys_object_version_number.DELETE;
      l_sys_hist_rec_tab.sys_security_group_id.DELETE;
      l_sys_hist_rec_tab.sys_migrated_flag.DELETE;
      l_sys_hist_rec_tab.old_sys_operating_unit_id.DELETE;
      l_sys_hist_rec_tab.new_sys_operating_unit_id.DELETE;
      --

  For i in sys_hist_csr(v_start,v_end)
  Loop
      --
      l_ctr := l_ctr + 1;
      --
      Select csi_history_archive_s.Nextval
      Into l_archive_id_tbl(l_ctr)
      From dual;
      --
      l_sys_hist_rec_tab.system_history_id(l_ctr)              :=  i.system_history_id;
      l_sys_hist_rec_tab.system_id(l_ctr)                      :=  i.system_id;
      l_sys_hist_rec_tab.transaction_id(l_ctr)                 :=  i.transaction_id;
      l_sys_hist_rec_tab.old_customer_id(l_ctr)                :=  i.old_customer_id;
      l_sys_hist_rec_tab.new_customer_id(l_ctr)                :=  i.new_customer_id;
      l_sys_hist_rec_tab.old_system_type_code(l_ctr)           :=  i.old_system_type_code;
      l_sys_hist_rec_tab.new_system_type_code(l_ctr)           :=  i.new_system_type_code;
      l_sys_hist_rec_tab.old_system_number(l_ctr)              :=  i.old_system_number;
      l_sys_hist_rec_tab.new_system_number(l_ctr)              :=  i.new_system_number;
      l_sys_hist_rec_tab.old_parent_system_id(l_ctr)           :=  i.old_parent_system_id;
      l_sys_hist_rec_tab.new_parent_system_id(l_ctr)           :=  i.new_parent_system_id;
      l_sys_hist_rec_tab.old_ship_to_contact_id(l_ctr)         :=  i.old_ship_to_contact_id;
      l_sys_hist_rec_tab.new_ship_to_contact_id(l_ctr)         :=  i.new_ship_to_contact_id;
      l_sys_hist_rec_tab.old_bill_to_contact_id(l_ctr)         :=  i.old_bill_to_contact_id;
      l_sys_hist_rec_tab.new_bill_to_contact_id(l_ctr)         :=  i.new_bill_to_contact_id;
      l_sys_hist_rec_tab.old_technical_contact_id(l_ctr)       :=  i.old_technical_contact_id;
      l_sys_hist_rec_tab.new_technical_contact_id(l_ctr)       :=  i.new_technical_contact_id;
      l_sys_hist_rec_tab.old_service_admin_contact_id(l_ctr)   :=  i.old_service_admin_contact_id;
      l_sys_hist_rec_tab.new_service_admin_contact_id(l_ctr)   :=  i.new_service_admin_contact_id;
      l_sys_hist_rec_tab.old_ship_to_site_use_id(l_ctr)        :=  i.old_ship_to_site_use_id;
      l_sys_hist_rec_tab.new_ship_to_site_use_id(l_ctr)        :=  i.new_ship_to_site_use_id;
      l_sys_hist_rec_tab.old_install_site_use_id(l_ctr)        :=  i.old_install_site_use_id;
      l_sys_hist_rec_tab.new_install_site_use_id(l_ctr)        :=  i.new_install_site_use_id;
      l_sys_hist_rec_tab.old_bill_to_site_use_id(l_ctr)        :=  i.old_bill_to_site_use_id;
      l_sys_hist_rec_tab.new_bill_to_site_use_id(l_ctr)        :=  i.new_bill_to_site_use_id;
      l_sys_hist_rec_tab.old_coterminate_day_month(l_ctr)      :=  i.old_coterminate_day_month;
      l_sys_hist_rec_tab.new_coterminate_day_month(l_ctr)      :=  i.new_coterminate_day_month;
      l_sys_hist_rec_tab.old_sys_active_start_date(l_ctr)      :=  i.old_start_date_active;
      l_sys_hist_rec_tab.new_sys_active_start_date(l_ctr)      :=  i.new_start_date_active;
      l_sys_hist_rec_tab.old_sys_active_end_date(l_ctr)        :=  i.old_end_date_active;
      l_sys_hist_rec_tab.new_sys_active_end_date(l_ctr)        :=  i.new_end_date_active;
      l_sys_hist_rec_tab.old_autocreated_from_system(l_ctr)    :=  i.old_autocreated_from_system;
      l_sys_hist_rec_tab.new_autocreated_from_system(l_ctr)    :=  i.new_autocreated_from_system;
      l_sys_hist_rec_tab.old_config_system_type(l_ctr)         :=  i.old_config_system_type;
      l_sys_hist_rec_tab.new_config_system_type(l_ctr)         :=  i.new_config_system_type;
      l_sys_hist_rec_tab.old_name(l_ctr)                       :=  i.old_name;
      l_sys_hist_rec_tab.new_name(l_ctr)                       :=  i.new_name;
      l_sys_hist_rec_tab.old_sys_description(l_ctr)            :=  i.old_description;
      l_sys_hist_rec_tab.new_sys_description(l_ctr)            :=  i.new_description;
      l_sys_hist_rec_tab.old_sys_context(l_ctr)	               :=  i.old_context;
      l_sys_hist_rec_tab.new_sys_context(l_ctr)	               :=  i.new_context;
      l_sys_hist_rec_tab.old_sys_attribute1(l_ctr)	           :=  i.old_attribute1;
      l_sys_hist_rec_tab.new_sys_attribute1(l_ctr)	           :=  i.new_attribute1;
      l_sys_hist_rec_tab.old_sys_attribute2(l_ctr)	           :=  i.old_attribute2;
      l_sys_hist_rec_tab.new_sys_attribute2(l_ctr)	           :=  i.new_attribute2;
      l_sys_hist_rec_tab.old_sys_attribute3(l_ctr)	           :=  i.old_attribute3;
      l_sys_hist_rec_tab.new_sys_attribute3(l_ctr)	           :=  i.new_attribute3;
      l_sys_hist_rec_tab.old_sys_attribute4(l_ctr)	           :=  i.old_attribute4;
      l_sys_hist_rec_tab.new_sys_attribute4(l_ctr)	           :=  i.new_attribute4;
      l_sys_hist_rec_tab.old_sys_attribute5(l_ctr)	           :=  i.old_attribute5;
      l_sys_hist_rec_tab.new_sys_attribute5(l_ctr)	           :=  i.new_attribute5;
      l_sys_hist_rec_tab.old_sys_attribute6(l_ctr)	           :=  i.old_attribute6;
      l_sys_hist_rec_tab.new_sys_attribute6(l_ctr)	           :=  i.new_attribute6;
      l_sys_hist_rec_tab.old_sys_attribute7(l_ctr)	           :=  i.old_attribute7;
      l_sys_hist_rec_tab.new_sys_attribute7(l_ctr)	           :=  i.new_attribute7;
      l_sys_hist_rec_tab.old_sys_attribute8(l_ctr)	           :=  i.old_attribute8;
      l_sys_hist_rec_tab.new_sys_attribute8(l_ctr)	           :=  i.new_attribute8;
      l_sys_hist_rec_tab.old_sys_attribute9(l_ctr)	           :=  i.old_attribute9;
      l_sys_hist_rec_tab.new_sys_attribute9(l_ctr)	           :=  i.new_attribute9;
      l_sys_hist_rec_tab.old_sys_attribute10(l_ctr)	           :=  i.old_attribute10;
      l_sys_hist_rec_tab.new_sys_attribute10(l_ctr)	           :=  i.new_attribute10;
      l_sys_hist_rec_tab.old_sys_attribute11(l_ctr)   	       :=  i.old_attribute11;
      l_sys_hist_rec_tab.new_sys_attribute11(l_ctr)	           :=  i.new_attribute11;
      l_sys_hist_rec_tab.old_sys_attribute12(l_ctr)	           :=  i.old_attribute12;
      l_sys_hist_rec_tab.new_sys_attribute12(l_ctr)	           :=  i.new_attribute12;
      l_sys_hist_rec_tab.old_sys_attribute13(l_ctr)	           :=  i.old_attribute13;
      l_sys_hist_rec_tab.new_sys_attribute13(l_ctr)	           :=  i.new_attribute13;
      l_sys_hist_rec_tab.old_sys_attribute14(l_ctr)	           :=  i.old_attribute14;
      l_sys_hist_rec_tab.new_sys_attribute14(l_ctr)	           :=  i.new_attribute14;
      l_sys_hist_rec_tab.old_sys_attribute15(l_ctr)	           :=  i.old_attribute15;
      l_sys_hist_rec_tab.new_sys_attribute15(l_ctr)	           :=  i.new_attribute15;
      l_sys_hist_rec_tab.sys_full_dump_flag(l_ctr)	           :=  i.full_dump_flag;
      l_sys_hist_rec_tab.sys_created_by(l_ctr)                 :=  i.created_by;
      l_sys_hist_rec_tab.sys_creation_date(l_ctr)              :=  i.creation_date;
      l_sys_hist_rec_tab.sys_last_updated_by(l_ctr)            :=  i.last_updated_by;
      l_sys_hist_rec_tab.sys_last_update_date(l_ctr)           :=  i.last_update_date;
      l_sys_hist_rec_tab.sys_last_update_login(l_ctr)          :=  i.last_update_login;
      l_sys_hist_rec_tab.sys_object_version_number(l_ctr)      :=  i.object_version_number;
      l_sys_hist_rec_tab.sys_security_group_id(l_ctr)	       :=  i.security_group_id;
      l_sys_hist_rec_tab.sys_migrated_flag(l_ctr)	           :=  i.migrated_flag;
      l_sys_hist_rec_tab.old_sys_operating_unit_id(l_ctr)      :=  i.old_operating_unit_id;
      l_sys_hist_rec_tab.new_sys_operating_unit_id(l_ctr)      :=  i.new_operating_unit_id;

   End Loop;

      -- get the party history count for the transaction range
      l_cnt := l_sys_hist_rec_tab.system_history_id.count;
      --
      Debug('');
      Debug('');
      Debug('Number of System history records archived:'||to_char(l_cnt));
      Debug('');
      Debug('');
      --
      If l_cnt > 0 Then

        FORALL i IN 1 .. l_cnt

         Insert Into CSI_HISTORY_ARCHIVE
         (
            HISTORY_ARCHIVE_ID
           ,OBJECT_ID
           ,ENTITY_HISTORY_ID
           ,TRANSACTION_ID
           ,ENTITY_ID
           ,COL_NUM_01
           ,COL_NUM_02
           ,COL_NUM_03
           ,COL_NUM_04
           ,COL_NUM_05
           ,COL_NUM_06
           ,COL_NUM_07
           ,COL_NUM_08
           ,COL_NUM_09
           ,COL_NUM_10
           ,COL_NUM_11
           ,COL_NUM_12
           ,COL_NUM_13
           ,COL_NUM_14
           ,COL_NUM_15
           ,COL_NUM_16
           ,COL_NUM_17
           ,COL_NUM_18
           ,COL_NUM_19
           ,COL_NUM_20
           ,COL_NUM_21
           ,COL_NUM_22
           ,COL_NUM_37
           ,COL_NUM_38
           ,COL_NUM_39
           ,COL_NUM_40
           ,COL_NUM_41
           ,COL_CHAR_01
           ,COL_CHAR_02
           ,COL_CHAR_03
           ,COL_CHAR_04
           ,COL_CHAR_05
           ,COL_CHAR_06
           ,COL_CHAR_07
           ,COL_CHAR_08
           ,COL_CHAR_09
           ,COL_CHAR_10
           ,COL_CHAR_11
           ,COL_CHAR_12
           ,COL_CHAR_31
           ,COL_CHAR_32
           ,COL_CHAR_33
           ,COL_CHAR_34
           ,COL_CHAR_35
           ,COL_CHAR_36
           ,COL_CHAR_37
           ,COL_CHAR_38
           ,COL_CHAR_39
           ,COL_CHAR_40
           ,COL_CHAR_41
           ,COL_CHAR_42
           ,COL_CHAR_43
           ,COL_CHAR_44
           ,COL_CHAR_45
           ,COL_CHAR_46
           ,COL_CHAR_47
           ,COL_CHAR_48
           ,COL_CHAR_49
           ,COL_CHAR_50
           ,COL_CHAR_51
           ,COL_CHAR_52
           ,COL_CHAR_53
           ,COL_CHAR_54
           ,COL_CHAR_55
           ,COL_CHAR_56
           ,COL_CHAR_57
           ,COL_CHAR_58
           ,COL_CHAR_59
           ,COL_CHAR_60
           ,COL_CHAR_61
           ,COL_CHAR_62
           ,COL_CHAR_71
           ,COL_CHAR_72
           ,COL_DATE_01
           ,COL_DATE_02
           ,COL_DATE_03
           ,COL_DATE_04
           ,COL_DATE_11
           ,COL_DATE_12
           ,CONTEXT
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,OBJECT_VERSION_NUMBER
           ,SECURITY_GROUP_ID
           )
           Values
           (
           l_archive_id_tbl(i),
           l_table_id,
           l_sys_hist_rec_tab.system_history_id(i),
           l_sys_hist_rec_tab.transaction_id(i),
           l_sys_hist_rec_tab.system_id(i),
           l_sys_hist_rec_tab.old_customer_id(i),
           l_sys_hist_rec_tab.new_customer_id(i),
           l_sys_hist_rec_tab.old_parent_system_id(i),
           l_sys_hist_rec_tab.new_parent_system_id(i),
           l_sys_hist_rec_tab.old_bill_to_contact_id(i),
           l_sys_hist_rec_tab.new_bill_to_contact_id(i),
           l_sys_hist_rec_tab.old_ship_to_contact_id(i),
           l_sys_hist_rec_tab.new_ship_to_contact_id(i),
           l_sys_hist_rec_tab.old_technical_contact_id(i),
           l_sys_hist_rec_tab.new_technical_contact_id(i),
           l_sys_hist_rec_tab.old_service_admin_contact_id(i),
           l_sys_hist_rec_tab.new_service_admin_contact_id(i),
           l_sys_hist_rec_tab.old_ship_to_site_use_id(i),
           l_sys_hist_rec_tab.new_ship_to_site_use_id(i),
           l_sys_hist_rec_tab.old_install_site_use_id(i),
           l_sys_hist_rec_tab.new_install_site_use_id(i),
           l_sys_hist_rec_tab.old_bill_to_site_use_id(i),
           l_sys_hist_rec_tab.new_bill_to_site_use_id(i),
           l_sys_hist_rec_tab.old_autocreated_from_system(i),
           l_sys_hist_rec_tab.new_autocreated_from_system(i),
           l_sys_hist_rec_tab.old_sys_operating_unit_id(i),
           l_sys_hist_rec_tab.new_sys_operating_unit_id(i),
           l_sys_hist_rec_tab.sys_created_by(i),
           l_sys_hist_rec_tab.sys_last_updated_by(i),
           l_sys_hist_rec_tab.sys_last_update_login(i),
	   l_sys_hist_rec_tab.sys_object_version_number(i), -- obj_ver_num
           l_sys_hist_rec_tab.sys_security_group_id(i), -- sec_grp_id
           l_sys_hist_rec_tab.old_system_type_code(i),
           l_sys_hist_rec_tab.new_system_type_code(i),
           l_sys_hist_rec_tab.old_system_number(i),
           l_sys_hist_rec_tab.new_system_number(i),
           l_sys_hist_rec_tab.old_coterminate_day_month(i),
           l_sys_hist_rec_tab.new_coterminate_day_month(i),
           l_sys_hist_rec_tab.old_config_system_type(i),
           l_sys_hist_rec_tab.new_config_system_type(i),
           l_sys_hist_rec_tab.old_name(i),
           l_sys_hist_rec_tab.new_name(i),
           l_sys_hist_rec_tab.old_sys_description(i),
           l_sys_hist_rec_tab.new_sys_description(i),
           l_sys_hist_rec_tab.old_sys_context(i),
           l_sys_hist_rec_tab.new_sys_context(i),
           l_sys_hist_rec_tab.old_sys_attribute1(i),
           l_sys_hist_rec_tab.new_sys_attribute1(i),
           l_sys_hist_rec_tab.old_sys_attribute2(i),
           l_sys_hist_rec_tab.new_sys_attribute2(i),
           l_sys_hist_rec_tab.old_sys_attribute3(i),
           l_sys_hist_rec_tab.new_sys_attribute3(i),
           l_sys_hist_rec_tab.old_sys_attribute4(i),
           l_sys_hist_rec_tab.new_sys_attribute4(i),
           l_sys_hist_rec_tab.old_sys_attribute5(i),
           l_sys_hist_rec_tab.new_sys_attribute5(i),
           l_sys_hist_rec_tab.old_sys_attribute6(i),
           l_sys_hist_rec_tab.new_sys_attribute6(i),
           l_sys_hist_rec_tab.old_sys_attribute7(i),
           l_sys_hist_rec_tab.new_sys_attribute7(i),
           l_sys_hist_rec_tab.old_sys_attribute8(i),
           l_sys_hist_rec_tab.new_sys_attribute8(i),
           l_sys_hist_rec_tab.old_sys_attribute9(i),
           l_sys_hist_rec_tab.new_sys_attribute9(i),
           l_sys_hist_rec_tab.old_sys_attribute10(i),
           l_sys_hist_rec_tab.new_sys_attribute10(i),
           l_sys_hist_rec_tab.old_sys_attribute11(i),
           l_sys_hist_rec_tab.new_sys_attribute11(i),
           l_sys_hist_rec_tab.old_sys_attribute12(i),
           l_sys_hist_rec_tab.new_sys_attribute12(i),
           l_sys_hist_rec_tab.old_sys_attribute13(i),
           l_sys_hist_rec_tab.new_sys_attribute13(i),
           l_sys_hist_rec_tab.old_sys_attribute14(i),
           l_sys_hist_rec_tab.new_sys_attribute14(i),
           l_sys_hist_rec_tab.old_sys_attribute15(i),
           l_sys_hist_rec_tab.new_sys_attribute15(i),
           l_sys_hist_rec_tab.sys_full_dump_flag(i), --'N', dump_flag
           l_sys_hist_rec_tab.sys_migrated_flag(i), -- mig_flag
           l_sys_hist_rec_tab.old_sys_active_start_date(i),
           l_sys_hist_rec_tab.new_sys_active_start_date(i),
           l_sys_hist_rec_tab.old_sys_active_end_date(i),
           l_sys_hist_rec_tab.new_sys_active_end_date(i),
           l_sys_hist_rec_tab.sys_creation_date(i),
           l_sys_hist_rec_tab.sys_last_update_date(i),
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           null,
           l_user_id,
           sysdate,
           l_user_id,
           sysdate,
           l_login_id,
           1,
           null
           );

         -- Purge the corresonding Archive data from the Systems history tables

            FORALL i IN 1 .. l_cnt

               Delete From CSI_SYSTEMS_H
               Where system_history_id = l_sys_hist_rec_tab.system_history_id(i);


       End If; -- if l_cnt > 0
       --
       Exit When from_trans = to_trans;
       Exit When v_end = to_trans;

     v_start := v_end + 1;
     v_end   := v_start + v_batch;
     --
     --
	 If v_start > to_trans Then
	    v_start := to_trans;
	 End If;
	 --
	 If v_end > to_trans then
	    v_end := to_trans;
	 End If;
     --
     Commit;
     --
   Exception
      when others then
         Debug(substr(sqlerrm,1,255));
         ROLLBACK to System_Archive;
   End;
 End Loop; -- Local Batch Loop
 Commit;
   --
END; -- Procedure Systems_Archive


Procedure Record_count( From_trans IN  NUMBER,
                        To_trans   IN  NUMBER,
                        Purge_to_date IN VARCHAR2,
                        Recs_count OUT NOCOPY NUMBER )
IS

  l_temp   NUMBER;
  l_temp1  NUMBER;
  l_temp2  NUMBER;
  l_temp3  NUMBER;
  l_temp4  NUMBER;
  l_temp5  NUMBER;
  l_temp6  NUMBER;
  l_temp7  NUMBER;
  l_temp8  NUMBER;
  l_temp9  NUMBER;

Begin
  --
  Begin
    Select COUNT(*)
    Into   l_temp
    From   CSI_ITEM_INSTANCES_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp1
    From   CSI_I_PARTIES_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp2
    From   CSI_IP_ACCOUNTS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp3
    From   CSI_I_ORG_ASSIGNMENTS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp4
    From   CSI_IEA_VALUES_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp5
    From   CSI_I_PRICING_ATTRIBS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp6
    From   CSI_I_ASSETS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp7
    From   CSI_I_VERSION_LABELS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp8
    From   CSI_II_RELATIONSHIPS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  --
  Begin
    Select COUNT(*)
    Into   l_temp9
    From   CSI_SYSTEMS_H csh,
           CSI_TRANSACTIONS csit
    Where  csit.transaction_id between From_trans and To_trans
    And    csit.creation_date < to_date(purge_to_date, 'YYYY/MM/DD HH24:MI:SS')
    And    csh.transaction_id = csit.transaction_id;
  Exception
    When Others Then
    Null;
  End;
  --
  Recs_Count := l_temp+l_temp1+l_temp2+l_temp3+l_temp4+l_temp5+l_temp6+l_temp7+l_temp8+l_temp9;

End;

END CSI_TXN_HISTORY_PURGE_PVT;

/
