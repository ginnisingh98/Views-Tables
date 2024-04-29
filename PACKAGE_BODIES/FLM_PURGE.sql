--------------------------------------------------------
--  DDL for Package Body FLM_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_PURGE" AS
/* $Header: FLMCPPGB.pls 120.3 2006/09/20 21:21:45 ksuleman noship $ */


PROCEDURE VERIFY_FOREIGN_KEYS(
                    arg_wip_entity_id    in      number,
                    arg_org_id           in      number,
                    arg_item_id          in      number,
                    arg_table_name       out     NOCOPY varchar2,
                    arg_return_value     out     NOCOPY number ,
                            errbuf       out     NOCOPY varchar2
)
IS
l_records_found NUMBER := G_ZERO;
l_stmt_num      NUMBER := G_ZERO;
l_flag          BOOLEAN := TRUE;
Begin
        l_stmt_num := 310;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM  MTL_MATERIAL_TRANSACTIONS
               WHERE ORGANIZATION_ID = arg_org_id
                 AND INVENTORY_ITEM_ID = arg_item_id
                 AND TRANSACTION_SOURCE_TYPE_ID + 0 = 5
                 AND TRANSACTION_SOURCE_ID = arg_wip_entity_id);


        if (l_records_found <> 0) then
            arg_table_name := arg_table_name || ' MTL_MATERIAL_TRANSACTIONS *';
            l_flag := FALSE;
        end if;

        l_stmt_num := 320;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
            (SELECT 1
             FROM MTL_TRANSACTION_ACCOUNTS MTA , MTL_MATERIAL_TRANSACTIONS MMT
             WHERE MMT.ORGANIZATION_ID = arg_org_id
             AND MMT.TRANSACTION_SOURCE_ID = arg_wip_entity_id
             AND MMT.TRANSACTION_ID = MTA.TRANSACTION_ID
             AND MMT.TRANSACTION_SOURCE_TYPE_ID +0 = 5 );

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_TRANSACTIONS_ACCOUNTS *';
            l_flag := FALSE ;
        end if;

        l_stmt_num := 330;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM  MTL_TRANSACTION_LOT_NUMBERS
                WHERE TRANSACTION_SOURCE_TYPE_ID = 5
                AND TRANSACTION_SOURCE_ID = arg_wip_entity_id );

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_TRANSACTION_LOT_NUMBERS *';
            l_flag := FALSE;
        end if;

        l_stmt_num := 340;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM MTL_UNIT_TRANSACTIONS
                WHERE TRANSACTION_SOURCE_TYPE_ID = 5
                AND TRANSACTION_SOURCE_ID = arg_wip_entity_id );

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_UNIT_TRANSACTIONS *';
            l_flag := FALSE;
        end if;

        l_stmt_num := 350;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM  MTL_DEMAND MD, WIP_ENTITIES WE
               WHERE WE.WIP_ENTITY_ID = arg_wip_entity_id
               AND MD.SUPPLY_SOURCE_TYPE = 5
               AND MD.SUPPLY_SOURCE_HEADER_ID = WE.WIP_ENTITY_ID
               AND MD.INVENTORY_ITEM_ID = WE.PRIMARY_ITEM_ID
               AND MD.ORGANIZATION_ID = arg_org_id);

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_DEMAND *';
            l_flag := FALSE;
        end if;

        l_stmt_num := 360;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM   MTL_USER_SUPPLY
               WHERE SOURCE_TYPE_ID = 4
               AND SOURCE_ID = arg_wip_entity_id
               AND ORGANIZATION_ID = arg_org_id);

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_USER_SUPPLY *';
            l_flag := FALSE;
        end if;

        l_stmt_num := 370;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM   MTL_USER_DEMAND
               WHERE SOURCE_TYPE_ID = 4
               AND SOURCE_ID = arg_wip_entity_id
               AND ORGANIZATION_ID = arg_org_id);

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_USER_DEMAND *';
            l_flag := FALSE;
        end if;

        l_stmt_num := 380;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM   MTL_SERIAL_NUMBERS
                 WHERE INVENTORY_ITEM_ID = arg_item_id
                   AND ORIGINAL_WIP_ENTITY_ID = arg_wip_entity_id);

        if (l_records_found <> 0) then
            arg_table_name := arg_table_name||' MTL_SERIAL_NUMBERS *';
            l_flag := FALSE;
        end if;


    if (l_flag) then
        arg_return_value := G_SUCCESS;
    else
        arg_return_value := G_WARNING;
    end if;

   EXCEPTION WHEN OTHERS THEN
         arg_return_value := G_ERROR;
                   errbuf := substr(SQLERRM,1,500);
         MRP_UTIL.MRP_LOG('Error at '||l_stmt_num|| ' in Verify_Foreign_Key');
END VERIFY_FOREIGN_KEYS;


PROCEDURE DELETE_EXE_TABLES(arg_wip_entity_id  in      number,
                            arg_org_id         in      number) IS
BEGIN

  delete from flm_exe_serial_numbers
    where wip_entity_id = arg_wip_entity_id;

  delete from flm_exe_lot_numbers
    where wip_entity_id = arg_wip_entity_id;

  delete from flm_exe_req_operations
    where wip_entity_id = arg_wip_entity_id;

END DELETE_EXE_TABLES;


Procedure DELETE_TABLES(
                    arg_wip_entity_id  in      number,
                    arg_org_id         in      number,
		    arg_auto_replenish in      varchar2, /* Added for Enhancement #2829204 */
                    arg_return_value   out     NOCOPY number,
                          errbuf       out     NOCOPY varchar2
)
IS
l_stmt_num  NUMBER := G_ZERO;

CURSOR card_activity_csr IS
  SELECT kanban_activity_id
    FROM mtl_kanban_card_activity
   WHERE source_wip_entity_id = arg_wip_entity_id;

Begin
         l_stmt_num := 410;

         DELETE FROM MTL_MATERIAL_TRANSACTIONS_TEMP
         WHERE  TRANSACTION_SOURCE_TYPE_ID +0 = 5
         AND TRANSACTION_SOURCE_ID = arg_wip_entity_id
         AND ORGANIZATION_ID = arg_org_id;

         l_stmt_num := 420;

         DELETE FROM MTL_TRANSACTIONS_INTERFACE
         WHERE TRANSACTION_SOURCE_ID = arg_wip_entity_id
         AND ORGANIZATION_ID = arg_org_id;

         l_stmt_num := 430;

         DELETE FROM MRP_RELIEF_INTERFACE
         WHERE  DISPOSITION_TYPE = 1
         AND DISPOSITION_ID = arg_wip_entity_id;

         l_stmt_num := 440;

         DELETE FROM WIP_REQ_OPERATION_COST_DETAILS
         WHERE  WIP_ENTITY_ID = arg_wip_entity_id ;

         l_stmt_num := 450;

         DELETE FROM WIP_OPERATION_OVERHEADS
         WHERE WIP_ENTITY_ID = arg_wip_entity_id ;

         l_stmt_num := 460;

         DELETE FROM WIP_TRANSACTIONS
         WHERE WIP_ENTITY_ID = arg_wip_entity_id;

         l_stmt_num := 470;

         DELETE FROM WIP_TRANSACTION_ACCOUNTS
         WHERE WIP_ENTITY_ID = arg_wip_entity_id;

         l_stmt_num := 475;
         DELETE FROM WIP_PERIOD_BALANCES
         WHERE WIP_ENTITY_ID = arg_wip_entity_id
           AND ORGANIZATION_ID = arg_org_id;

         l_stmt_num := 480;

         /* Added for Enhancement # 3321626
          * To Delete data from flm_exe_operations table also.
	  */

         DELETE FROM FLM_EXE_OPERATIONS
	 WHERE WIP_ENTITY_ID = arg_wip_entity_id;

         l_stmt_num := 481 ;
         delete_exe_tables (arg_wip_entity_id, arg_org_id);

	 l_stmt_num := 485;

         DELETE FROM WIP_FLOW_SCHEDULES
         WHERE WIP_ENTITY_ID = arg_wip_entity_id;

         l_stmt_num := 490;

         /*
	    Added for Enhancement #2829204
	    If for the flow schedule, auto_replenish flag was set to 'Y', this
	    indicates, this flow schedule is being referenced by a Kanban Card.
	    So, we need to delink that Kanban Card Activity which was linked to
	    this flow schedule.
	 */

	 IF (nvl(arg_auto_replenish, 'N') = 'Y') THEN

	   FOR l_card_activity_csr IN card_activity_csr
	   LOOP
             UPDATE mtl_kanban_card_activity
	        SET source_wip_entity_id = NULL
	      WHERE kanban_activity_id = l_card_activity_csr.kanban_activity_id;
           END LOOP;

	 END IF;

	 l_stmt_num := 495;

         DELETE FROM WIP_ENTITIES
         WHERE WIP_ENTITY_ID = arg_wip_entity_id;

    arg_return_value := G_SUCCESS;

   EXCEPTION WHEN OTHERS THEN
           arg_return_value := G_ERROR;
                    errbuf := substr(SQLERRM,1,500);
           MRP_UTIL.MRP_LOG('Error at '||l_stmt_num|| ' in Delete_Tables');
END DELETE_TABLES;

PROCEDURE PURGE_SCHEDULES(
                    errbuf               out     NOCOPY varchar2,
                    retcode              out     NOCOPY number,
                    arg_org_id           in      number,
                    arg_cutoff_date      in      varchar2,
                    arg_line             in      VARCHAR2,
                    arg_assembly         in      VARCHAR2,
                    arg_purge_option     in      number)
IS
  CURSOR Purge(p_cutoff_date DATE) IS  --fix bug#3170105
    SELECT  wfs.wip_entity_id ,
            wfs.schedule_number,
            wfs.status,
            wfs.primary_item_id ,
            wfs.line_id line_id,
            wfs.scheduled_completion_date ,
            wfs.date_closed,
            wfs.organization_id,
	    wfs.auto_replenish  /* Added for Enhancement #2829204 */
    FROM    wip_flow_schedules wfs
    WHERE   wfs.organization_id = arg_org_id
    AND     wfs.scheduled_completion_date <= p_cutoff_date
    AND     (arg_line is null or wfs.line_id = to_number(arg_line) )
    AND     wfs.primary_item_id = nvl(arg_assembly,wfs.primary_item_id);

    l_wip_entity_id            WIP_FLOW_SCHEDULES.WIP_ENTITY_ID%TYPE;
    l_schedule_number          WIP_FLOW_SCHEDULES.SCHEDULE_NUMBER%TYPE;
    l_status                   WIP_FLOW_SCHEDULES.STATUS%TYPE;
    l_primary_item_id          WIP_FLOW_SCHEDULES.PRIMARY_ITEM_ID%TYPE;
    l_close_date               WIP_FLOW_SCHEDULES.DATE_CLOSED%TYPE;
    l_completion_date          WIP_FLOW_SCHEDULES.SCHEDULED_COMPLETION_DATE%TYPE;
    l_account_close_date       DATE;
    l_organization_id          WIP_FLOW_SCHEDULES.ORGANIZATION_ID%TYPE;
    l_table_name               VARCHAR2(500);
    l_tot_rec_purge            NUMBER := G_ZERO;
    l_records_deleted          NUMBER := G_ZERO;
    l_flag                     BOOLEAN ;
    l_return_value             NUMBER := G_ZERO;
    l_stmt_num                 NUMBER := G_ZERO;
    l_auto_replenish           WIP_FLOW_SCHEDULES.AUTO_REPLENISH%TYPE;
    l_cutoff_date              DATE;
    l_line_code                VARCHAR2(10);

Begin


    l_stmt_num := 100;

      MRP_UTIL.MRP_LOG('  The Value of Parameters are : ');
      MRP_UTIL.MRP_LOG('  Organization    ---> '||to_char(arg_org_id));

      --fix bug#3170105
      l_cutoff_date := flm_timezone.client_to_server(
        fnd_date.canonical_to_date(arg_cutoff_date))+1-1/(24*60*60);
      MRP_UTIL.MRP_LOG('  Cut-Off Date    ---> '||to_char(l_cutoff_date));
      --end of fix bug#3170105

      -- Bug 5353590
      -- find the line_code name with the (line id, org id) unique key
      select line_code into l_line_code
      from wip_lines
      where line_id = arg_line and organization_id = arg_org_id;

      MRP_UTIL.MRP_LOG('  Line            ---> '||arg_line||' (line name: '||l_line_code||')');
      MRP_UTIL.MRP_LOG('  Assembly        ---> '||arg_assembly);

      /*
         When the "Purge Option" is given as "All",
         arg_purge_option will have a value of 1
         When the "Purge Option" is given as "Resource Transactions Only",
         arg_purge_option will have a value of 2
      */

      if ( arg_purge_option = 1 ) then
         MRP_UTIL.MRP_LOG('  Purge Option    ---> '||'All');
      elsif ( arg_purge_option = 2 ) then
         MRP_UTIL.MRP_LOG('  Purge Option    ---> '||'Resource Transactions Only');
      elsif ( arg_purge_option = 3 ) then /* Added for deleting execution history data */
         MRP_UTIL.MRP_LOG('  Purge Option    ---> '||'Execution History Only');
      end if;

       select max(period_close_date)  --fix bug#3170105
         into l_account_close_date
         from org_acct_periods
        where organization_id = arg_org_id
          and schedule_close_date
              <= l_cutoff_date
          and open_flag = 'N'
          and period_close_date IS NOT NULL;

   if (l_account_close_date is null) then
          fnd_message.set_name('FLM','FLM_SCHED_NO_ACCT_CLOSE_PERIOD');
          MRP_UTIL.MRP_LOG(fnd_message.get);
          return;
   end if;

    FOR Purge_Rec IN Purge(l_cutoff_date) LOOP  --fix bug#3170105

           l_flag := TRUE;
           l_table_name  := NULL;
           l_wip_entity_id := Purge_Rec.Wip_entity_id;
           l_schedule_number := Purge_rec.Schedule_Number;
           l_status := Purge_rec.Status;
           l_primary_item_id := Purge_rec.Primary_item_id;
           l_completion_date := Purge_rec.Scheduled_completion_date;
           l_close_date := Purge_rec.Date_closed;
           l_organization_id := Purge_rec.Organization_id;
	   l_auto_replenish := Purge_rec.Auto_Replenish;

           if (l_completion_date > l_account_close_date) then
              fnd_message.set_name('FLM','FLM_SCHED_CLOSED_PERIOD');
              fnd_message.set_token('SCHEDULE',l_schedule_number);
              MRP_UTIL.MRP_LOG(fnd_message.get);
              l_flag := FALSE;
           end if;

           l_stmt_num := 200;

           if (l_flag) then
              if ((l_status <> G_CLOSED_STATUS)
                        or (l_close_date IS NULL)) then
                 fnd_message.set_name('FLM','FLM_SCHED_NOT_CLOSED');
                 fnd_message.set_token('SCHEDULE',l_schedule_number);
                 MRP_UTIL.MRP_LOG(fnd_message.get);
                 l_flag := FALSE;
              end if;
           end if;

           l_stmt_num := 300;

           /* start of arg_purge_option if condition */
           if (arg_purge_option = 2)  and (l_flag) then

              DELETE FROM WIP_TRANSACTIONS
              WHERE WIP_ENTITY_ID = l_wip_entity_id;

              l_stmt_num := 310;

              DELETE FROM WIP_TRANSACTION_ACCOUNTS
              WHERE WIP_ENTITY_ID = l_wip_entity_id;

              l_stmt_num := 320;

              l_records_deleted := l_records_deleted + 1;
              l_tot_rec_purge := l_tot_rec_purge + 1;

              if (l_records_deleted >= G_BATCH ) then
                  COMMIT;
                  l_records_deleted := G_ZERO;
              end if;

           /* Added for Enhancement # 3321626
	    * To Delete data from flm_exe_operations table if purge_option = 3
	    */
	   elsif (arg_purge_option = 3) and (l_flag) then

	      DELETE FROM FLM_EXE_OPERATIONS
	      WHERE WIP_ENTITY_ID = l_wip_entity_id;

	      l_stmt_num := 325;

              delete_exe_tables (l_wip_entity_id, l_organization_id);

              l_stmt_num := 326;

              l_records_deleted := l_records_deleted + 1;
              l_tot_rec_purge := l_tot_rec_purge + 1;

              if (l_records_deleted >= G_BATCH ) then
                  COMMIT;
                  l_records_deleted := G_ZERO;
              end if;

	   else
            if (l_flag) then
               Verify_Foreign_Keys(l_wip_entity_id,
                                  l_organization_id,
                                  l_primary_item_id,
                                  l_table_name,
                                  l_return_value,
                                  errbuf
                                  );
            end if;


           if (l_return_value = G_WARNING) and (l_flag) then
              fnd_message.set_name('FLM','FLM_SCHEDULE_FKEY_REFERENCE');
              fnd_message.set_token('SCHEDULE',l_schedule_number);
              fnd_message.set_token('TABLES',l_table_name);
              MRP_UTIL.MRP_LOG(fnd_message.get);
              l_flag := FALSE;
           elsif (l_return_value = G_ERROR) then
              APP_EXCEPTION.RAISE_EXCEPTION;
           end if;


           l_stmt_num := 400;

           if (l_flag) then
                Delete_Tables(l_wip_entity_id,
                              l_organization_id,
			      l_auto_replenish, /* Added for Enhancement #2829204 */
                              l_return_value,
                              errbuf
                              );
           end if;

           l_stmt_num := 500;

           if ((l_flag) and (l_return_value = G_SUCCESS)) then
               l_records_deleted := l_records_deleted + 1;
               l_tot_rec_purge := l_tot_rec_purge + 1;
               if (l_records_deleted >= G_BATCH ) then
                   COMMIT;
                  l_records_deleted := G_ZERO;
               end if;
           elsif (l_return_value = G_ERROR) then
              retcode := l_return_value;
              APP_EXCEPTION.RAISE_EXCEPTION;
           end if;

        end if;  /* end of arg_purge_option if condition */

    END LOOP;

    if (l_records_deleted > 0) then
      COMMIT;
    end if;

    if (l_tot_rec_purge = G_ZERO) then
       fnd_message.set_name('FLM','FLM_SCHEDULE_NOT_FOUND');
       MRP_UTIL.MRP_LOG(fnd_message.get);
    else
       /* Added for Enhancement # 3321626
        * Modified the message to be shown in the log file, depending upon the Purge Option
	*/
       if (arg_purge_option = 2) then
         fnd_message.set_name('FLM','FLM_PURGE_RESOURCE_TXNS');
         fnd_message.set_token('NUMBER',l_tot_rec_purge);
         MRP_UTIL.MRP_LOG(fnd_message.get);

       elsif (arg_purge_option = 3) then
         fnd_message.set_name('FLM','FLM_PURGE_EXECUTION_HISTORY');
         fnd_message.set_token('NUMBER',l_tot_rec_purge);
         MRP_UTIL.MRP_LOG(fnd_message.get);

       else
         fnd_message.set_name('FLM','FLM_SCHEDULES_PURGED');
         fnd_message.set_token('NUMBER',l_tot_rec_purge);
         MRP_UTIL.MRP_LOG(fnd_message.get);
       end if;
    end if;

   EXCEPTION WHEN OTHERS THEN
      retcode := G_ERROR;
      if (errbuf is NULL) then
        errbuf := SUBSTR(SQLERRM, 1, 500);
      end if;
      ROLLBACK;
      MRP_UTIL.MRP_LOG('Error at '||l_stmt_num|| ' Purge_Schedules');
      MRP_UTIL.MRP_LOG('Error due to '|| errbuf );
END PURGE_SCHEDULES;


END FLM_PURGE;

/
