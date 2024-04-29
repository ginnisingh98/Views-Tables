--------------------------------------------------------
--  DDL for Package Body WIP_DIAG_JOB_SCH_HC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DIAG_JOB_SCH_HC" as
/* $Header: WIPDDEFB.pls 120.0.12000000.1 2007/07/10 09:45:59 mraman noship $ */
PROCEDURE invalid_job_def_job(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_job_id    NUMBER;
 l_org_id    NUMBER;
 l_cutoff_date  VARCHAR2(50);
 we_dyn_where_clause VARCHAR2(1000):= null;
 wdj_dyn_where_clause VARCHAR2(1000) := null;
 wo_dyn_where_clause VARCHAR2(1000) := null;
 wdj_atc_where_clause VARCHAR2(1000):= null;
 CURSOR l_trail_space(l_table_owner varchar2) IS SELECT column_name
                         FROM all_tab_columns
                         WHERE table_name = 'WIP_DISCRETE_JOBS'
                         AND data_type = 'VARCHAR2'
                         AND owner     = l_table_owner;

       a NUMBER:=0;
       sqltext  VARCHAR2(9999) :=NULL;
       sqltext1 VARCHAR2(9999):=NULL;
       sqltext2 VARCHAR2(9999):= NULL;
       l_return_status boolean;
       p_status varchar2(3);
       p_industry varchar2(30);
       p_table_owner varchar2(30);
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
row_limit := 1000;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs);
l_job_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Job Id',inputs);
--l_cutoff_date := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('CutoffDate',inputs);

   if l_org_id is not null then
      we_dyn_where_clause := ' we.organization_id = '|| l_org_id  || ' AND ';
      wdj_dyn_where_clause := ' wdj.organization_id = '|| l_org_id  || ' AND ';
      wo_dyn_where_clause := ' wo.organization_id = '|| l_org_id  || ' AND ';
   end if;
   if l_job_id is not null then
      we_dyn_where_clause := we_dyn_where_clause ||  ' we.wip_entity_id = '|| l_job_id  || ' AND ';
      wdj_dyn_where_clause := wdj_dyn_where_clause || ' wdj.wip_entity_id = '|| l_job_id  || ' AND ';
      wo_dyn_where_clause := wo_dyn_where_clause || ' wo.wip_entity_id = '|| l_job_id  || ' AND ';
   end if;
   if l_cutoff_date is not null then
      wo_dyn_where_clause := wo_dyn_where_clause || ' creation_date > Trunc(To_Date(' || l_cutoff_date || ',''dd-mon-yyyy'')) AND ';
   end if;


-- 1	This script will identify all released jobs that do not have Released Date populated.
sqltxt :=
'select we.wip_entity_name Job , we.wip_entity_id JobId, we.organization_id OrganizationID, '||
'   decode(wdj.status_type,      '||
'   1,''Unreleased'', '||
'   3, ''Released'', '||
'   4, ''Complete'', '||
'   5, ''Complete NoCharge'', '||
'   6, ''On Hold'', '||
'   7, ''Cancelled'', '||
'   8, ''Pend Bill Load'', '||
'   9, ''Failed Bill Load'', '||
'   10, ''Pend Rtg Load'', '||
'   11, ''Failed Rtg Load'', '||
'   12, ''Closed'', '||
'   13, ''Pending- Mass Loaded'', '||
'   14, ''Pending Close'', '||
'   15, ''Failed Close'', '||
'   wdj.status_type) Status, wdj.DATE_RELEASED, wdj.DATE_CLOSED  '||
'from   wip_entities we, '||
'       wip_discrete_jobs wdj '||
'where  ' || we_dyn_where_clause  || ' wdj.wip_entity_id = we.wip_entity_id '||
'and    wdj.date_released is null '||
'and    WDJ.STATUS_TYPE IN (3, 4, 5, 6, 14, 15)  ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Release Date.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are released jobs with null date released.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;


-- 2	This script will identify all jobs where quantity completed on job is not in sync with Inventory
sqltxt :=
'select substr(we.wip_entity_name, 1,15) Job, wdj.wip_entity_id JobId,  we.organization_id OrganizationID, wdj.primary_item_id ItemId, wdj.start_quantity,  '||
' wdj.quantity_completed, wdj.quantity_scrapped, wdj.net_quantity, wdj.creation_date '||
'from   wip_discrete_jobs wdj, wip_entities we '||
'where ' || we_dyn_where_clause  || ' wdj.wip_entity_id = we.wip_entity_id '||
'and exists (select 1  '||
'  from mtl_material_transactions mmt '||
'  where mmt.transaction_source_type_id = 5 '||
'  and   mmt.transaction_source_id = wdj.wip_entity_id '||
'  and   mmt.organization_id = wdj.organization_id '||
'  and   mmt.inventory_item_id = wdj.primary_item_id '||
'  and   mmt.transaction_action_id in (31,32)) '||
'and    quantity_completed <> (select sum(mmt.primary_quantity) '||    /*Bug 6049344: Replaced trx qty with primary qty*/
'         from mtl_material_transactions mmt '||
'      where mmt.transaction_source_type_id = 5 '||
'    and   mmt.transaction_source_id = wdj.wip_entity_id '||
'    and   mmt.organization_id = wdj.organization_id '||
'    and   mmt.inventory_item_id = wdj.primary_item_id '||
'    and   mmt.transaction_action_id in (31,32)) order by we.wip_entity_id ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Job Quantity Completed',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs where quantity completed on job is not in sync with Inventory.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test. <BR> <BR>');
END IF;


-- 3	This script will identify all jobs where Resource Start and End Dates falls outside of Operation Start and End Dates
sqltxt :=
' select  substr(we.wip_entity_name, 1, 30) Job,'||
'           wop.wip_entity_id JobId, '||
'           wop.organization_id OrganizationID, wop.repetitive_schedule_id ScheduleId,  '||
'           wop.operation_seq_num, '||
'           wor.resource_id, '||
'           wor.resource_seq_num, '||
'           wop.first_unit_start_date Operation_Start, '||
'           wop.last_unit_completion_date Operation_Completion, '||
'           wor.start_date Resource_Start, '||
'           wor.completion_date Resource_Completion'||
'    from   wip_operation_resources wor, '||
'           wip_operations wop, '||
'           wip_entities we '||
'    where ' || we_dyn_where_clause  || ' wop.wip_entity_id = wor.wip_entity_id '||
'    and    wop.organization_id = wor.organization_id '||
'    and    wop.operation_seq_num = wor.operation_seq_num '||
'    and    nvl(wor.REPETITIVE_SCHEDULE_ID, -1) = nvl(wop.REPETITIVE_SCHEDULE_ID, -1) '||
'    and    we.wip_entity_id = wop.wip_entity_id '||
'    and   ( (wop.first_unit_start_date > wor.start_date) '||
'             or '||
'           (wop.last_unit_completion_date < wor.completion_date)) order by wop.organization_id, wop.wip_entity_id ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Job Resource Start and End Date. ',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are resources on Jobs/Schedules where Start and End Dates falls outside of Operation Start and End Dates.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

--4	This script will identify all jobs where the quantity issued of material requirements is not in sync with Inventory
sqltxt :=
'select substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId,  we.organization_id OrganizationID,  wro.inventory_item_id,  '||
'       wro.operation_seq_num, wro.quantity_per_assembly, wro.required_quantity,  '||
'       wro.quantity_issued, Sum(mmt.primary_quantity)*(-1) Inventory_Quantity '||
'from   wip_discrete_jobs wdj, wip_entities we, '||
'       wip_requirement_operations wro, mtl_material_transactions mmt '||
'where  ' || we_dyn_where_clause  || ' wdj.wip_entity_id = we.wip_entity_id    '||
'AND    wdj.organization_id = we.organization_id '||
'AND    wdj.wip_entity_id = wro.wip_entity_id '||
'AND    wdj.organization_id = wro.organization_id '||
'AND    wdj.wip_entity_id = mmt.transaction_source_id '||
'AND    wdj.organization_id = mmt.organization_id '||
'AND    mmt.transaction_source_type_id = 5 '||
'AND    mmt.operation_seq_num = wro.operation_seq_num '||
'AND    mmt.inventory_item_id = wro.inventory_item_id '||
'AND    mmt.transaction_action_id IN (1, 27, 33, 34) ' ||
' HAVING Sum(mmt.primary_quantity) <> wro.quantity_issued*(-1) '||
'GROUP BY wdj.wip_entity_id, substr(we.wip_entity_name,1,15), we.organization_id, wro.inventory_item_id, wro.operation_seq_num, '||
'         wro.quantity_per_assembly, wro.required_quantity, wro.quantity_issued ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs with Quantity_Issued in material requirements not in sync with Inventory.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs where issued quantity of material requirements is not in sync with Inventory.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

--5	This script will identify unreleased jobs that have quantities on operation.
sqltxt :=
'SELECT distinct substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId,   '||
'        wdj.organization_id OrganizationID, '||
'   decode(wdj.status_type,      '||
'   1,''Unreleased'', '||
'   3, ''Released'', '||
'   4, ''Complete'', '||
'   5, ''Complete NoCharge'', '||
'   6, ''On Hold'', '||
'   7, ''Cancelled'', '||
'   8, ''Pend Bill Load'', '||
'   9, ''Failed Bill Load'', '||
'   10, ''Pend Rtg Load'', '||
'   11, ''Failed Rtg Load'', '||
'   12, ''Closed'', '||
'   13, ''Pending- Mass Loaded'', '||
'   14, ''Pending Close'', '||
'   15, ''Failed Close'', '||
'   wdj.status_type) Status  '||
'FROM   wip_discrete_jobs wdj, wip_entities we, '||
'       wip_operations wo '||
'WHERE  ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type = 1 '||
'AND    wdj.wip_entity_id = wo.wip_entity_id '||
'AND    wdj.organization_id = wo.organization_id '||
'AND    (wo.quantity_in_queue <> 0 '||
'        OR wo.quantity_running <> 0 '||
'        OR wo.quantity_waiting_to_move <> 0 '||
'        OR wo.quantity_scrapped <> 0 '||
'        OR wo.quantity_rejected <> 0 '||
'        OR wo.quantity_completed <> 0) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Unreleased jobs that have quantities on operation.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are unreleased jobs that have quantities on operation.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

--6	This script will identify all released jobs that do not have any quantites on any operation.
sqltxt :=
'SELECT distinct substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId,  '||
'       wdj.organization_id OrganizationID,  ' ||
'   decode(wdj.status_type,      '||
'   1,''Unreleased'', '||
'   3, ''Released'', '||
'   4, ''Complete'', '||
'   5, ''Complete NoCharge'', '||
'   6, ''On Hold'', '||
'   7, ''Cancelled'', '||
'   8, ''Pend Bill Load'', '||
'   9, ''Failed Bill Load'', '||
'   10, ''Pend Rtg Load'', '||
'   11, ''Failed Rtg Load'', '||
'   12, ''Closed'', '||
'   13, ''Pending- Mass Loaded'', '||
'   14, ''Pending Close'', '||
'   15, ''Failed Close'', '||
'   wdj.status_type) Status  '||
'FROM   wip_discrete_jobs wdj, wip_entities we, '||
'       wip_operations wo '||
'WHERE  ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (3,4) '||
'AND    wdj.wip_entity_id = wo.wip_entity_id '||
'AND    wdj.organization_id = wo.organization_id '||
'AND    wo.quantity_in_queue = 0 '||
'AND    wo.quantity_running = 0 '||
'AND    wo.quantity_waiting_to_move = 0 '||
'AND    wo.quantity_scrapped = 0 '||
'AND    wo.quantity_rejected = 0 '||
'AND    wo.quantity_completed = 0 ' ||
' AND ( wo.PREVIOUS_OPERATION_SEQ_NUM is null /*for first operation*/' ||
' OR 0  >= ' ||
' (Select sum(wo1.quantity_in_queue) + sum(wo1.quantity_running) + ' ||
' sum(quantity_waiting_to_move) + sum(quantity_scrapped) + sum(quantity_rejected) + '||
' sum(quantity_completed) from wip_operations wo1 ' ||
' WHERE  ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    wo1.organization_id = wo.organization_id '||
'AND    wo1.wip_entity_id = wo.wip_entity_id '||
'AND  wo1.OPERATION_SEQ_NUM <= wo.PREVIOUS_OPERATION_SEQ_NUM ))';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Released jobs that do not have any quantites on any operation.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are released jobs that do not have any quantites on any operation.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;


--6.5 This script identifies all jobs that have operation quantities not in sync with move transaction quantities
sqltxt := ' SELECT  substr(we.wip_entity_name, 1,20) Job, wop.wip_entity_id JobId , wop.organization_id, wop.operation_seq_num ' ||
 ' FROM  WIP_OPERATIONS wop , wip_entities we, wip_discrete_jobs wdj ' ||
 ' WHERE ' || wdj_dyn_where_clause ||
 ' we.wip_entity_id = wdj.wip_entity_id ' ||
 ' and wdj.wip_entity_id = wop.wip_entity_id ' ||
 ' and ( ' ||
 '  ( wop.quantity_in_queue  ' ||
 '     - Decode(Nvl(wop.PREVIOUS_OPERATION_SEQ_NUM, 0), 0, wdj.start_quantity,0)  ' ||
 '     - ( SELECT Decode(Nvl(wop.PREVIOUS_OPERATION_SEQ_NUM, 0), 0,Sum(Nvl(OVERCOMPLETION_PRIMARY_QTY,0)),0) ' ||
 '         FROM  wip_move_transactions wmt2 ' ||
 '         WHERE  wmt2.wip_entity_id = wop.wip_entity_id ) ' ||
 '        <> ((SELECT SUM( DECODE(wop.operation_seq_num, ' ||
 '                       wmt_rec.fm_operation_seq_num, ' ||
 '                      -1*DECODE(wmt_rec.fm_intraoperation_step_type, ' ||
 '                       1,ROUND(wmt_rec.primary_quantity,6), ' ||
 '                       2,0,3,0,4,0,5,0 ' ||
 '                       ),0) + ' ||
 '                       DECODE(wop.operation_seq_num, ' ||
 '                       wmt_rec.to_operation_seq_num, ' ||
 '                       DECODE(wmt_rec.to_intraoperation_step_type, ' ||
 '                       1,ROUND(wmt_rec.primary_quantity,6), ' ||
 '                       2,0,3,0,4,0,5,0),0) ' ||
 '                       ) ' ||
 '            FROM WIP_OPERATIONS wop1 , wip_move_transactions wmt_rec ' ||
 '            WHERE wop1.rowid = wop.ROWID ' ||
 '            AND  wop.wip_entity_id = wmt_rec.wip_entity_id ' ||
 '            AND (wop1.operation_seq_num = wmt_rec.fm_operation_seq_num ' ||
 '            OR wop1.operation_seq_num = wmt_rec.to_operation_seq_num) ) ' ||
 '           ) ' ||
 '   ) ' ||
 '   OR ' ||
 '   ( ' ||
 '     wop.quantity_running <>  ' ||
 '         (SELECT  SUM(DECODE(wop.operation_seq_num, ' ||
 ' 			          wmt_rec.fm_operation_seq_num, -1*DECODE(wmt_rec.fm_intraoperation_step_type, ' ||
 ' 			          1,0, ' ||
 ' 			          2,ROUND(wmt_rec.primary_quantity,6), ' ||
 ' 			          3,0,4,0,5,0),0) + ' ||
 ' 			          DECODE(wop.operation_seq_num, ' ||
 ' 			          wmt_rec.to_operation_seq_num, DECODE(wmt_rec.to_intraoperation_step_type, ' ||
 ' 			          1,0, ' ||
 ' 			          2,ROUND(wmt_rec.primary_quantity,6), ' ||
 ' 			          3,0,4,0,5,0),0) ) ' ||
 '           FROM WIP_OPERATIONS wop1 , wip_move_transactions wmt_rec ' ||
 '           WHERE wop1.rowid = wop.ROWID ' ||
 '           AND  wop.wip_entity_id = wmt_rec.wip_entity_id ' ||
 '           AND (wop1.operation_seq_num = wmt_rec.fm_operation_seq_num ' ||
 '           OR wop1.operation_seq_num = wmt_rec.to_operation_seq_num)) ' ||
 '   ) ' ||
 '   OR ' ||
 '   ( ' ||
 '     wop.quantity_waiting_to_move  ' ||
 '     + Decode(Nvl(wop.next_operation_seq_num, 0), 0, wdj.quantity_completed , 0)  ' ||
 '      <> (SELECT  SUM(DECODE(wop.operation_seq_num, ' ||
 ' 			   wmt_rec.fm_operation_seq_num, -1*DECODE(wmt_rec.fm_intraoperation_step_type, ' ||
 ' 			   1,0,2,0, ' ||
 ' 			   3,ROUND(wmt_rec.primary_quantity,6), ' ||
 ' 			   4,0,5,0),0) + ' ||
 ' 			   DECODE(wop.operation_seq_num, ' ||
 ' 			   wmt_rec.to_operation_seq_num, DECODE(wmt_rec.to_intraoperation_step_type, ' ||
 ' 			  1,0,2,0, ' ||
 ' 			  3,ROUND(wmt_rec.primary_quantity,6), ' ||
 ' 			    4,0,5,0),0) ) ' ||
 '           FROM WIP_OPERATIONS wop1 , wip_move_transactions wmt_rec ' ||
 '           WHERE wop1.rowid = wop.ROWID ' ||
 '           AND  wop.wip_entity_id = wmt_rec.wip_entity_id ' ||
 '           AND (wop1.operation_seq_num = wmt_rec.fm_operation_seq_num ' ||
 '           OR wop1.operation_seq_num = wmt_rec.to_operation_seq_num)) ' ||
 '   ) ' ||
 '   OR ' ||
 '    ( ' ||
 '     wop.quantity_rejected <>  ' ||
 '           (SELECT SUM(DECODE(wop.operation_seq_num, ' ||
 '                       wmt_rec.fm_operation_seq_num, -1*DECODE(wmt_rec.fm_intraoperation_step_type, ' ||
 ' 	                1,0,2,0,3,0, ' ||
 ' 	                4,ROUND(wmt_rec.primary_quantity,6), ' ||
 ' 	                5,0),0) + ' ||
 ' 	                DECODE(wop.operation_seq_num, ' ||
 ' 	                wmt_rec.to_operation_seq_num, DECODE(wmt_rec.to_intraoperation_step_type, ' ||
 ' 	                1,0,2,0,3,0, ' ||
 ' 	                4,ROUND(wmt_rec.primary_quantity,6), ' ||
 ' 	                5,0),0) ) ' ||
 '             FROM WIP_OPERATIONS wop1 , wip_move_transactions wmt_rec ' ||
 '             WHERE wop1.rowid = wop.ROWID ' ||
 '             AND  wop.wip_entity_id = wmt_rec.wip_entity_id ' ||
 '             AND (wop1.operation_seq_num = wmt_rec.fm_operation_seq_num ' ||
 '             OR wop1.operation_seq_num = wmt_rec.to_operation_seq_num) ) ' ||
 '  ) ' ||
 '   OR ' ||
 '   ( ' ||
 '     wop.quantity_scrapped <>  ' ||
 '         (SELECT 	 SUM(DECODE(wop.operation_seq_num, ' ||
 '                         wmt_rec.fm_operation_seq_num, -1*DECODE(wmt_rec.fm_intraoperation_step_type, ' ||
 ' 	                  1,0,2,0,3,0,4,0, ' ||
 ' 	                  5,ROUND(wmt_rec.primary_quantity,6)),0) + ' ||
 ' 	                  DECODE(wop.operation_seq_num, ' ||
 ' 	                  wmt_rec.to_operation_seq_num, DECODE(wmt_rec.to_intraoperation_step_type, ' ||
 ' 	                     1,0,2,0,3,0,4,0, ' ||
 ' 	                       5,ROUND(wmt_rec.primary_quantity,6)),0) ) ' ||
 ' 	    FROM WIP_OPERATIONS wop1 , wip_move_transactions wmt_rec ' ||
 ' 	    WHERE wop1.rowid = wop.ROWID ' ||
 '           AND  wop.wip_entity_id = wmt_rec.wip_entity_id ' ||
 '           AND (wop1.operation_seq_num = wmt_rec.fm_operation_seq_num ' ||
 '           OR wop1.operation_seq_num = wmt_rec.to_operation_seq_num)) ' ||
 '   ) ' ||
 '   OR ' ||
 '   ( wop.quantity_completed  ' ||
 '           <> (SELECT NVL(SUM(wti.primary_quantity * ' ||
 '                      DECODE(sign(wti.to_operation_seq_num-wti.fm_operation_seq_num), ' ||
 '                      0,DECODE(sign(wti.fm_intraoperation_step_type-2), ' ||
 '                        0,DECODE(sign(wti.to_intraoperation_step_type-2), ' ||
 '                      0,-1, ' ||
 '                       -1,-1, ' ||
 '                         1,1), ' ||
 '                        -1,DECODE(sign(wti.to_intraoperation_step_type-2), ' ||
 '                           0,-1,-1,-1,1,1), ' ||
 '                          1,-1), ' ||
 '                        1, 1, ' ||
 '                       -1,-1)),0) ' ||
 '                FROM WIP_OPERATIONS wop1, WIP_MOVE_TRANSACTIONS wti ' ||
 '                WHERE wop1.rowid = wop.rowid ' ||
 '                AND wop1.organization_id = wti.organization_id ' ||
 '                AND wop1.wip_entity_id = wti.wip_entity_id ' ||
 '                AND ( ' ||
 '                    (wop1.operation_seq_num >= wti.fm_operation_seq_num ' ||
 '                      + DECODE(sign(wti.fm_intraoperation_step_type-2), 0,0,-1,0,1,1) ' ||
 '                     AND wop1.operation_seq_num < wti.to_operation_seq_num ' ||
 '                    + DECODE(sign(wti.to_intraoperation_step_type-2), 0,0,-1,0,1,1) ' ||
 '                     AND (wti.to_operation_seq_num > wti.fm_operation_seq_num ' ||
 '                     OR (wti.to_operation_seq_num = wti.fm_operation_seq_num ' ||
 '                     AND wti.fm_intraoperation_step_type<=2 ' ||
 '                     AND wti.to_intraoperation_step_type>2)) ' ||
 '                    AND (wop1.count_point_type < 3 ' ||
 '                    OR wop1.operation_seq_num = wti.fm_operation_seq_num ' ||
 '                                       OR (wop1.operation_seq_num = wti.to_operation_seq_num ' ||
 '                                           AND wti.to_intraoperation_step_type > 2))) ' ||
 '                                 OR ' ||
 '                                 (wop1.operation_seq_num < wti.fm_operation_seq_num ' ||
 '                                     + DECODE(sign(wti.fm_intraoperation_step_type-2), 0,0,-1,0,1,1) ' ||
 '                                   AND wop1.operation_seq_num >= wti.to_operation_seq_num ' ||
 '                                     + DECODE(sign(wti.to_intraoperation_step_type-2), 0,0,-1,0,1,1) ' ||
 '                                   AND (wti.fm_operation_seq_num > wti.to_operation_seq_num ' ||
 '                                       OR (wti.fm_operation_seq_num = wti.to_operation_seq_num ' ||
 '                                           AND wti.to_intraoperation_step_type<=2 ' ||
 '                                           AND wti.fm_intraoperation_step_type>2)) ' ||
 '                                AND (wop1.count_point_type < 3 ' ||
 '                                OR (wop1.operation_seq_num = wti.to_operation_seq_num and wop1.count_point_type < 3 ) ' ||
 '                                OR (wop1.operation_seq_num = wti.fm_operation_seq_num ' ||
 '                                AND wti.fm_intraoperation_step_type > 2))) ' ||
 '                                   )) ' ||
 '     ) ' ||
 ' ) ' ;

dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
    'Jobs that have operation quantities not in sync with move transaction quantities.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

if dummy_num > 0 then
        reportStr := 'The rows returned above signify that Operation quantites are not in sync with Move Transactions. ';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
end if;

--7	This script identifies all  records that are Orphan in the WIP tables.
sqltxt :=
'SELECT wo.wip_entity_id JobId, wo.organization_id OrganizationID,  ''Orphan wip_operations data exists'' Message   '||
' FROM wip_operations wo  ' ||
'WHERE  ' || wo_dyn_where_clause ||
' NOT EXISTS (SELECT 1 FROM wip_entities we '||
'                WHERE ' || we_dyn_where_clause  || ' wo.wip_entity_id = we.wip_entity_id '||
'                AND wo.organization_id = we.organization_id) '||
'UNION '||
'SELECT wo.wip_entity_id JobId, wo.organization_id OrganizationID,  ''Orphan wip_requirement_operations data exists'' Message  FROM wip_requirement_operations wo '||
'WHERE  ' || wo_dyn_where_clause ||
' NOT EXISTS (SELECT 1 FROM wip_entities we '||
'                WHERE ' || we_dyn_where_clause  || ' wo.wip_entity_id = we.wip_entity_id '||
'                AND wo.organization_id = we.organization_id) '||
'UNION '||
'SELECT  wo.wip_entity_id JobId, wo.organization_id OrganizationID,  ''Orphan wip_operation_resources data exists'' Message   FROM wip_operation_resources wo   '||
'WHERE  ' || wo_dyn_where_clause ||
' NOT EXISTS (SELECT 1 FROM wip_entities we '||
'                WHERE ' || we_dyn_where_clause  || ' wo.wip_entity_id = we.wip_entity_id '||
'                AND wo.organization_id = we.organization_id)'||
'UNION               '||
'SELECT  wo.wip_entity_id JobId, wo.organization_id OrganizationID,  ''Orphan wip_period_balances data exists'' Message  FROM wip_period_balances wo   '||
'WHERE  ' || wo_dyn_where_clause ||
'   NOT EXISTS (SELECT 1 FROM wip_entities we '||
'                   WHERE ' || we_dyn_where_clause  || ' wo.wip_entity_id = we.wip_entity_id '||
'                   AND wo.organization_id = we.organization_id) '||
'UNION               '||
'SELECT  wo.wip_entity_id JobId, wo.organization_id OrganizationID, ''Orphan wip_discrete_jobs data exists''  Message  FROM wip_discrete_jobs wo   '||
'WHERE  ' || wo_dyn_where_clause ||
'    NOT EXISTS (SELECT 1 FROM wip_entities we '||
'                   WHERE ' || we_dyn_where_clause  || ' wo.wip_entity_id = we.wip_entity_id '||
'                   AND wo.organization_id = we.organization_id) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Records Orphan in the WIP tables.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are orphan records exist in WIP table(s). ';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;


-- 8	This script identifies all the jobs that have multiple PO Move resources in an operation.
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId,  '||
'       wdj.organization_id OrganizationID,  wo.operation_seq_num, Count(*) '||
'FROM   wip_discrete_jobs wdj, wip_entities we, '||
'       wip_operations wo, wip_operation_resources wor '||
'WHERE   ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3) '||
'AND    wdj.wip_entity_id = wo.wip_entity_id '||
'AND    wdj.organization_id = wo.organization_id '||
'AND    wo.wip_entity_id = wor.wip_entity_id '||
'AND    wo.organization_id = wor.organization_id '||
'AND    wo.operation_seq_num = wor.operation_seq_num '||
'AND    wor.autocharge_type = 4 '||
'HAVING Count(*) > 1 '||
'GROUP BY wdj.wip_entity_id, substr(we.wip_entity_name,1,15),  '||
'       wdj.organization_id, wo.operation_seq_num ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs that have multiple PO Move resources in an operation.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are multiple PO move resources in an operation.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;


--9	This script check if there are any trailing spaces in the text fields on Discrete Job for a particular Job.
IF ( l_job_Id IS NOT NULL ) THEN

  BEGIN
l_return_status := FND_INSTALLATION.GET_APP_INFO( application_short_name => 'WIP', status => p_status, industry=> p_industry, oracle_schema => p_table_owner);

 sqltxt:='SELECT 1 from dual where 1=2';

         FOR i IN l_trail_space(p_table_owner) loop
               sqltext1:= 'SELECT nvl(Min('||
                                         1 ||
 ' ),0) FROM wip_discrete_jobs wdj WHERE ' ||
                                  'Length('||
                              i.column_name||
                         ')<>Length(RTrim('||
                              i.column_name||
                                   '))AND '||
                       wdj_dyn_where_clause||
                                      '1=1';

             EXECUTE IMMEDIATE sqltext1 INTO a ;

                IF a=1 THEN

                       sqltext:=    sqltext||
              'column_name "Column Name" ,'||
                              i.column_name||
                             ' "Value"'||
                                ', length('||
                              i.column_name||
                   ') "Length in Database"'||
                           ',length(Rtrim('||
                              i.column_name||
                       ')) "Actual Length",';

wdj_atc_where_clause:=' atc.column_name='''||
                             i.column_name ||
                      ''' and table_name= '||
                    '''WIP_DISCRETE_JOBS'''||
                           ' and owner= '''||
                              p_table_owner||
                                        '''';

                                        a:=0;

                         IF Length(sqltext)>0 THEN

                                    sqltext:=RTrim(sqltext,',');
                                             sqltext:='select '||
                                                        sqltext||
       ' from wip_discrete_jobs wdj,all_tab_columns atc where '||
                                           wdj_dyn_where_clause||
                                           wdj_atc_where_clause||
                                               ' and owner= '''||
                                                  p_table_owner||
                                                            '''';


                                    IF(Length(sqltext2) > 0) THEN
                                           sqltext2 := sqltext2||
                                                    '  union ' ||
                                                        sqltext;
                                    ELSE
                                     sqltext2 := sqltext;
                                    END IF;

                                    sqltext:=NULL;

                           END IF;

           END IF;
          END LOOP;
       END;
          if sqltext2 is not null then
          sqltxt := sqltext2;
          end if;

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Trailing spaces in the text fields for a Discrete Job',true,null,'Y',row_limit);

        IF (dummy_num > 0) THEN
                reportStr := 'The rows returned above signify that there are trailing spaces in the text fields for Discrete Job.';
                JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
                JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
        END IF;
END IF;

--COMPLETION SUBINVENTORY / LOCATOR
-----------------------------------

-- 10. invalid completion subinventory
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'      wdj.organization_id OrganizationID,  wdj.completion_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_secondary_inventories mi '||
'                  WHERE wdj.completion_subinventory = mi.secondary_inventory_name '||
'                  AND   wdj.organization_id = mi.organization_id '||
'                  AND   mi.secondary_inventory_name <> ''AX_INTRANS''                    AND   Nvl(mi.disable_date,Trunc(SYSDATE+1)) > Trunc(SYSDATE)) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Completion Subinventory',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having invalid completion subinventory.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;


--11. completion subinventory not valid for the assembly. assembly has "restrict subinventories" enabled and
-- this subinventory is not part of it.
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, wdj.organization_id OrganizationID, msik.concatenated_segments, '||
'      wdj.completion_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_entities we, mtl_system_items_kfv msik '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    msik.inventory_item_id = wdj.primary_item_id '||
'AND    msik.organization_id = wdj.organization_id '||
'AND    msik.restrict_subinventories_code = 1 '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_item_sub_inventories mi '||
'                  WHERE wdj.completion_subinventory = mi.secondary_inventory '||
'                  AND   wdj.organization_id = mi.organization_id '||
'                  AND   wdj.primary_item_id = mi.inventory_item_id) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Completion Subinventory - Not part of "Restricted Subinventories"',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having completion subinventory that is not part of "Restricted Subinventories". ';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

-- 12. completion subinventory has invalid material status
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'      wdj.organization_id OrganizationID,  wdj.completion_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    inv_material_status_grp.is_status_applicable( '||
'                                NULL, NULL, 44, NULL, NULL, '||
'                                wdj.organization_id, wdj.primary_item_id, '||
'                                wdj.completion_subinventory, '||
'                                NULL, NULL, NULL, ''Z'') <> ''Y'' ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Completion Subinventory - Invalid Material Status',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having completion subinventory with invalid material status.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

-- 13. completion locator missing
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'        wdj.organization_id OrganizationID,  wdj.completion_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    wma_special_lovs.locatorControl(wdj.organization_id, '||
'                                      wdj.completion_subinventory, '||
'                                      wdj.primary_item_id) <> 1 '||
'AND    completion_locator_id IS NULL ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with missing Completion Locator',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs with null completion locator.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

-- 14. completion locator was supposed to be null but populated
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'        wdj.organization_id OrganizationID,  wdj.completion_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE  ' || we_dyn_where_clause  || 'we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    wma_special_lovs.locatorControl(wdj.organization_id, '||
'                                      wdj.completion_subinventory, '||
'                                      wdj.primary_item_id) = 1 '||
'AND    completion_locator_id IS NOT NULL ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with non locator controlled Completion Subinventory but Completion Locator populated.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs with non locator controlled Completion Subinventory but Completion Locator populated.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--15. completion subinventory NULL but completion locator populated
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'       wdj.organization_id OrganizationID,  wdj.completion_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE  ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NULL '||
'AND    wdj.completion_locator_id IS NOT NULL ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with a completion locator but no Completion Subinventory.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs with a completion locator but no Completion Subinventory.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

-- 16. completion locator not valid
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'        wdj.organization_id OrganizationID,  wdj.completion_subinventory, '||
'      inv_project.get_locator(wdj.completion_locator_id, '||
'                              wdj.organization_id) Locator '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    wdj.completion_locator_id IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_item_locations mil '||
'                  WHERE  wdj.completion_locator_id = mil.inventory_location_id '||
'                  AND    wdj.organization_id = mil.organization_id '||
'                  AND    wdj.completion_subinventory = mil.subinventory_code '||
'                  AND    Nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate)) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Completion Locator ',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having invalid completion locator.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

-- 17. completion locator not valid for the assembly. assembly has "restrict locators" enabled and
-- this locator is not part of it.
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'        wdj.organization_id OrganizationID,  wdj.completion_subinventory, msik.concatenated_segments, '||
'      inv_project.get_locator(wdj.completion_locator_id, wdj.organization_id) Locator '||
'FROM   wip_discrete_jobs wdj, wip_entities we, mtl_system_items_kfv msik '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    msik.inventory_item_id = wdj.primary_item_id '||
'AND    msik.organization_id = wdj.organization_id '||
'AND    msik.restrict_locators_code = 1 '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    wdj.completion_locator_id IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_secondary_locators msl '||
'                  WHERE  wdj.completion_locator_id = msl.secondary_locator '||
'                  AND    wdj.organization_id = msl.organization_id '||
'                  AND    wdj.primary_item_id = msl.inventory_item_id) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Completion Locator - Not part of "Restricted Locators"',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having  completion locator that is not part of "Restricted Locators".';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

-- 18.completion locator has invalid material status
sqltxt :=
'SELECT substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, '||
'       wdj.organization_id OrganizationID,  wdj.completion_subinventory, '||
'      inv_project.get_locator(wdj.completion_locator_id, wdj.organization_id) Locator '||
'FROM   wip_discrete_jobs wdj, wip_entities we '||
'WHERE ' || we_dyn_where_clause  || ' we.wip_entity_id = wdj.wip_entity_id '||
'AND    we.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wdj.completion_subinventory IS NOT NULL '||
'AND    wdj.completion_locator_id IS NOT NULL '||
'AND    inv_material_status_grp.is_status_applicable( '||
'                                NULL, NULL, 44, NULL, NULL, '||
'                                wdj.organization_id, wdj.primary_item_id, '||
'                                wdj.completion_subinventory, wdj.completion_locator_id, '||
'                                NULL, NULL, ''Z'') <> ''Y''  ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Completion Locator - Invalid Material Status',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having  completion locator with invalid material status.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the discrete job form, and update the completion subinventory/locator of the problematic job to a valid value.<BR> <BR> ';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--SUPPLY SUBINVENTORY / LOCATOR
-----------------------------

 --19. invalid supply subinventory
sqltxt :=
'SELECT wro.wip_entity_id JobId,   wro.organization_id OrganizationID,  '||
'       wro.operation_seq_num,wro.inventory_item_id,wro.supply_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_secondary_inventories mi '||
'                  WHERE wro.supply_subinventory = mi.secondary_inventory_name '||
'                  AND   wro.organization_id = mi.organization_id '||
'                  AND   mi.secondary_inventory_name <> ''AX_INTRANS'' '||
'                  AND   Nvl(mi.disable_date,Trunc(SYSDATE+1)) > Trunc(SYSDATE)) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Supply Subinventory',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having invalid supply subinventory.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--20. supply subinventory not valid for the component. component has "restrict subinventories" enabled and
-- this subinventory is not part of it.
sqltxt :=
'SELECT wro.wip_entity_id JobId,wro.organization_id OrganizationID,  msik.concatenated_segments, '||
'       wro.operation_seq_num,wro.inventory_item_id,wro.supply_subinventory '||
'FROM   wip_discrete_jobs wdj,wip_requirement_operations wro, mtl_system_items_kfv msik '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    msik.inventory_item_id = wro.inventory_item_id '||
'AND    msik.organization_id = wro.organization_id '||
'AND    msik.restrict_subinventories_code = 1 '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_item_sub_inventories mi '||
'                  WHERE wro.supply_subinventory = mi.secondary_inventory '||
'                  AND   wro.organization_id = mi.organization_id '||
'                  AND   wro.inventory_item_id = mi.inventory_item_id) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Supply Subinventory - Not part of '||
                ' "Restricted Subinventories".',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having supply subinventory that is not part of "Restricted Subinventories".';

        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--21. supply subinventory has invalid material status
sqltxt :=
'SELECT wro.wip_entity_id JobId, wro.organization_id OrganizationID,   '||
'       wro.operation_seq_num,wro.inventory_item_id,wro.supply_subinventory '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    inv_material_status_grp.is_status_applicable( '||
'                                NULL, NULL, 44, NULL, NULL, '||
'                                wro.organization_id, wro.inventory_item_id, '||
'                                wro.supply_subinventory, '||
'                                NULL, NULL, NULL, ''Z'') <> ''Y'' ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Supply Subinventory - Invalid Material Status',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having supply subinventory with invalid material status.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--22. supply locator locator missing
sqltxt :=
'SELECT wro.wip_entity_id JobId, wro.organization_id OrganizationID,  wro.operation_seq_num, '||
'       wro.inventory_item_id,wro.supply_subinventory,wro.supply_locator_id '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    wma_special_lovs.locatorControl(wro.organization_id, '||
'                                      wro.supply_subinventory, '||
'                                      wro.inventory_item_id) <> 1 '||
'AND    wro.supply_locator_id IS NULL ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with Supply Locator Missing',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs where supply locator is missing.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--23. supply locator was supposed to be null but populated
sqltxt :=
'SELECT wro.wip_entity_id JobId, wro.organization_id OrganizationID,  wro.operation_seq_num, '||
'       wro.inventory_item_id,wro.supply_subinventory,wro.supply_locator_id '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    wma_special_lovs.locatorControl(wro.organization_id, '||
'                                      wro.supply_subinventory, '||
'                                      wro.inventory_item_id) = 1 '||
'AND    wro.supply_locator_id IS NOT NULL ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with non locator controlled Supply Subinventory but Supply Locator populated.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs with non locator controlled Supply Subinventory but Supply Locator populated.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--24. supply subinventory NULL but supply locator populated
sqltxt :=
'SELECT wro.wip_entity_id JobId, wro.organization_id OrganizationID,  wro.operation_seq_num, '||
'       wro.inventory_item_id,wro.supply_subinventory,wro.supply_locator_id '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NULL '||
'AND    wro.supply_locator_id IS NOT NULL ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with a Supply Locator but no Supply Subinventory',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs where supply locator is populated but supply subinventory is null.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--25. supply locator not valid
sqltxt :=
'SELECT wro.wip_entity_id JobId, wro.organization_id OrganizationID,  wro.operation_seq_num, '||
'       wro.inventory_item_id,wro.supply_subinventory, '||
'      inv_project.get_locator(wro.supply_locator_id, '||
'                              wro.organization_id) Locator '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    wro.supply_locator_id IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_item_locations mil '||
'                  WHERE  wro.supply_locator_id = mil.inventory_location_id '||
'                  AND    wro.organization_id = mil.organization_id '||
'                  AND    wro.supply_subinventory = mil.subinventory_code '||
'                  AND    Nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate)) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Supply Locator ',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs where supply locator is not valid.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--26. Supply locator not valid for the component. component has "restrict locators" enabled and
-- this locator is not part of it.
sqltxt :=
'SELECT wro.wip_entity_id JobId, wro.organization_id OrganizationID,  wro.operation_seq_num, '||
'       wro.inventory_item_id,wro.supply_subinventory, msik.concatenated_segments, '||
'      inv_project.get_locator(wro.supply_locator_id, wro.organization_id) Locator '||
'FROM   wip_discrete_jobs wdj,wip_requirement_operations wro, mtl_system_items_kfv msik '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    msik.inventory_item_id = wro.inventory_item_id '||
'AND    msik.organization_id = wro.organization_id '||
'AND    msik.restrict_locators_code = 1 '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    wro.supply_locator_id IS NOT NULL '||
'AND    NOT EXISTS (SELECT 1 FROM mtl_secondary_locators msl '||
'                  WHERE  wro.supply_locator_id = msl.secondary_locator '||
'                  AND    wro.organization_id = msl.organization_id '||
'                  AND    wro.inventory_item_id = msl.inventory_item_id) ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules with invalid Supply Locator - Not part of "Restricted Locators"',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs where supply locator is populated but it is not part of "Restricted Locators".';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--27. supply locator has invalid material status
sqltxt :=
'SELECT  wro.wip_entity_id JobId, wro.organization_id OrganizationID,  wro.operation_seq_num, '||
'        wro.inventory_item_id,wro.supply_subinventory, '||
'        inv_project.get_locator(wro.supply_locator_id, wro.organization_id) Locator '||
'FROM   wip_discrete_jobs wdj, wip_requirement_operations wro '||
'WHERE ' || wdj_dyn_where_clause  || ' wro.wip_entity_id = wdj.wip_entity_id '||
'AND    wro.organization_id = wdj.organization_id '||
'AND    wdj.status_type IN (1,3,4) '||
'AND    wro.supply_subinventory IS NOT NULL '||
'AND    wro.supply_locator_id IS NOT NULL '||
'AND    inv_material_status_grp.is_status_applicable( '||
'                                NULL, NULL, 44, NULL, NULL, '||
'                                wro.organization_id, wro.inventory_item_id, '||
'                                wro.supply_subinventory, wro.supply_locator_id, '||
'                                NULL, NULL, ''Z'') <> ''Y'' ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs/Schedules invalid Supply Locator - Invalid Material Status',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs having supply locator with invalid material status.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Please query up each job in the material requirements form, and update the supply subinventory/locator of the problematic component to a valid value.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END invalid_job_def_job;

PROCEDURE failed_job_close_job(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_job_id    NUMBER;
 l_org_id    NUMBER;
 we_dyn_where_clause VARCHAR2(1000):= null;
 wdj_dyn_where_clause VARCHAR2(1000) := null;
 wg_dyn_where_clause VARCHAR2(1000) := null;  -- where caluse for generic source
 wti_dyn_where_clause VARCHAR2(1000) := null;  -- where caluse for imventory tables
 l_check_failed_close_jobs varchar2(2000);
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
row_limit := 1000;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs);
l_job_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Job Id',inputs);
--l_cutoff_date := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('CutoffDate',inputs);

   if l_org_id is not null then
      we_dyn_where_clause := ' we.organization_id = '|| l_org_id  || ' AND ';
      wdj_dyn_where_clause := ' wdj.organization_id = '|| l_org_id  || ' AND ';
      wti_dyn_where_clause := ' organization_id = '|| l_org_id  || ' AND ';
      wg_dyn_where_clause := ' organization_id = '|| l_org_id  || ' AND ';
   end if;
   if l_job_id is not null then
      we_dyn_where_clause := we_dyn_where_clause ||  ' we.wip_entity_id = '|| l_job_id  || ' AND ';
      wdj_dyn_where_clause := wdj_dyn_where_clause || ' wdj.wip_entity_id = '|| l_job_id  || ' AND ';
      wti_dyn_where_clause := wti_dyn_where_clause || ' transaction_source_id = '|| l_job_id  || ' AND ';
      wg_dyn_where_clause := wg_dyn_where_clause || ' wip_entity_id = '|| l_job_id  || ' AND ';
   end if;


l_check_failed_close_jobs :=
        ' (select wdj.wip_entity_id from wip_discrete_jobs wdj' ||
        ' where ' || wdj_dyn_where_clause || ' wdj.status_type = 15) ';

--1. This script will check for jobs that have failed in job close process due to pending transactions
sqltxt :=
' select wip_entity_id JobID, organization_id OrganizationID, ''Pending MOVE Transactions Exists''   "Pending Txns.." '||
' from    wip_move_txn_interface '||
' where ' || wg_dyn_where_clause  || ' wip_entity_id in ' || l_check_failed_close_jobs ||
' UNION ALL '||
' select wip_entity_id JobID, organization_id OrganizationID,  ''Pending RESOURCE Transactions Exists''    "Pending Txns.." '||
' from    wip_cost_txn_interface '||
' where ' || wg_dyn_where_clause  || ' wip_entity_id in ' || l_check_failed_close_jobs ||
' UNION ALL '||
' select transaction_source_id JobID, organization_id OrganizationID,  ''Pending UNCOSTED Material Transactions Exists''    "Pending Txns.." '||
' from    mtl_material_transactions '||
' where  ' || wti_dyn_where_clause  || ' transaction_source_type_id = 5 '||
' and     costed_flag in (''N'',''E'') '||
' and    transaction_source_id in ' || l_check_failed_close_jobs ||
' UNION ALL '||
' select transaction_source_id JobID, organization_id OrganizationID,  ''Pending Material Transactions Exists''    "Pending Txns.." '||
' from    mtl_material_transactions_temp mmtt '||
' where  ' || wti_dyn_where_clause  || ' transaction_source_type_id = 5 '||
' and     transaction_source_id not in ( '||
'   select txn_source_id '||
'   from   mtl_txn_request_lines '||
'   where  txn_source_id = mmtt.transaction_source_id '||
'   and    organization_id = mmtt.organization_id '||
'   and    line_status = 9) '||
' and   transaction_source_id in ' || l_check_failed_close_jobs ||
' UNION ALL '||
' select wip_entity_id JobID, organization_id OrganizationID,  ''Pending Operation Yields Exists''    "Pending Txns.." '||
' from    wip_operation_yields '||
' where  ' || wg_dyn_where_clause  || ' status IN (1, 3)  '||
' and    wip_entity_id in ' || l_check_failed_close_jobs ||
' UNION ALL '||
' select we.wip_entity_id JobID, we.organization_id OrganizationID, ''Pending PUT-AWAY Transactions Exists''    "Pending Txns.." '||
' from    wip_lpn_completions  we, '||
'  wms_license_plate_numbers lpn '||
' where  ' || we_dyn_where_clause  || ' we.lpn_id = lpn.lpn_id '||
' and     lpn.lpn_context = 2 '||
' and     wip_entity_id in ' || l_check_failed_close_jobs ;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs failed in job close process due to pending transactions',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that jobs are failed to close due to pending transactions.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        reportStr := 'Check the output and process the pending transactions against the job so that job can be closed.<BR><BR>';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(reportStr);
END IF;

--2 Jobs that are not closed but entity_type updated
sqltxt :=
' Select substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, wdj.organization_id OrganizationID, '||
'         decode(wdj.status_type, '||
'      1,''Unreleased'', '||
'                           3, ''Released'', '||
'                           4, ''Complete'', '||
'                           5, ''Complete NoCharge'', '||
'                           6, ''On Hold'', '||
'                           7, ''Cancelled'', '||
'                           8, ''Pend Bill Load'', '||
'                           9, ''Failed Bill Load'', '||
'                           10, ''Pend Rtg Load'', '||
'                           11, ''Failed Rtg Load'', '||
'                           12, ''Closed'', '||
'                           13, ''Pending- Mass Loaded'', '||
'                           14, ''Pending Close'', '||
'                           15, ''Failed Close'', '||
'                           wdj.status_type) status_type, '||
'         decode(entity_type,1, ''1=Discrete Job'', '||
'                            2, ''2=Repetitive Assly'', '||
'                            3, ''3=Closed Discr Job'', '||
'                            4, ''4=Flow Schedule'', '||
'                            5, ''5=Lot Based Job'', '||
'                            entity_type) entity_type, '||
'        wdj.creation_date, '||
'        wdj.date_released,  '||
'        wdj.date_completed '||
' from   wip_discrete_jobs wdj, '||
'        wip_entities we '||
' where ' || we_dyn_where_clause  || '  wdj.wip_entity_id = we.wip_entity_id '||
' and    wdj.organization_id = we.organization_id '||
' and    wdj.status_type <> 12 '||
' and    we.entity_type in (3,7,8)  -- closed DJ, closed EAM, closed LBJ '||
' order by 1,2 ' ;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs that are not closed but its entity_type updated to closed',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs that are not closed but its entity_type updated to closed.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test .<BR> <BR>');
END IF;

--3 Jobs that are closed but entity_type not updated
sqltxt :=
' select substr(we.wip_entity_name,1,15) Job, wdj.wip_entity_id JobId, wdj.organization_id OrganizationID, '||
'         decode(wdj.status_type, '||
'      1,''Unreleased'', '||
'                           3, ''Released'', '||
'                           4, ''Complete'', '||
'                           5, ''Complete NoCharge'', '||
'                           6, ''On Hold'', '||
'                           7, ''Cancelled'', '||
'                           8, ''Pend Bill Load'', '||
'                           9, ''Failed Bill Load'', '||
'                           10, ''Pend Rtg Load'', '||
'                           11, ''Failed Rtg Load'', '||
'                           12, ''Closed'', '||
'                           13, ''Pending- Mass Loaded'', '||
'                           14, ''Pending Close'', '||
'                           15, ''Failed Close'', '||
'                           wdj.status_type) status_type, '||
'         decode(entity_type,1, ''1=Discrete Job'', '||
'                            2, ''2=Repetitive Assly'', '||
'                            3, ''3=Closed Discr Job'', '||
'                            4, ''4=Flow Schedule'', '||
'                            5, ''5=Lot Based Job'', '||
'                            entity_type) entity_type, '||
'        wdj.creation_date, '||
'        wdj.date_released,  '||
'        wdj.date_completed '||
' from   wip_discrete_jobs wdj,  '||
'        wip_entities we '||
' where ' || we_dyn_where_clause  || '  wdj.wip_entity_id = we.wip_entity_id '||
' and    wdj.organization_id = we.organization_id '||
' and    wdj.status_type = 12 '||
' and    we.entity_type not in (3,7,8) '||
' order by 1,2';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Jobs that are closed but its entity_type not updated to closed',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
        reportStr := 'The rows returned above signify that there are jobs that are closed but its entity_type not updated to closed.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test.<BR> <BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END failed_job_close_job;

END;

/
