--------------------------------------------------------
--  DDL for Package Body WIP_DIAG_DATA_COLL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DIAG_DATA_COLL" as
/* $Header: WIPDCOLB.pls 120.1.12010000.2 2008/10/02 22:19:47 ntangjee ship $ */

procedure disc_lot_job (p_wip_entity_id IN NUMBER) is
  l_dummy number ;
  row_limit   NUMBER;
BEGIN
row_limit := 1000;
sqltxt :=
'    select  a.wip_entity_id , ' ||
'        b.wip_entity_name, ' ||
'        decode(b.entity_type,1, ''1=Discrete Job'', ' ||
'                             2, ''2=Repetitive Assly'', ' ||
'                             3, ''3=Closed Discr Job'', ' ||
'                             4, ''4=Flow Schedule'', ' ||
'                             5, ''5=Lot Based Job'', ' ||
'                             b.entity_type) entity_type, ' ||
'        a.organization_id, ' ||
'        p.organization_code, ' ||
'        a.primary_item_id, ' ||
'        substrb(m.concatenated_segments, 1, 30) item_name, ' ||
'        decode(a.status_type, ' ||
'			  1,''Unreleased'', ' ||
'                          3, ''Released'', ' ||
'                          4, ''Complete'', ' ||
'                          5, ''Complete NoCharge'', ' ||
'                          6, ''On Hold'', ' ||
'                          7, ''Cancelled'', ' ||
'                          8, ''Pend Bill Load'', ' ||
'                          9, ''Failed Bill Load'', ' ||
'                          10, ''Pend Rtg Load'', ' ||
'                          11, ''Failed Rtg Load'', ' ||
'                          12, ''Closed'', ' ||
'                          13, ''Pending- Mass Loaded'', ' ||
'                          14, ''Pending Close'', ' ||
'                          15, ''Failed Close'', ' ||
'                          a.status_type) status_type, ' ||
'        decode(a.job_type, 1, ''Standard'', ' ||
'                        3, ''Non-Standard'', ' ||
'			a.job_type) job_type, ' ||
'	a.lot_number, ' ||
'	a.completion_subinventory, ' ||
'	a.completion_locator_id, ' ||
'        a.start_quantity, ' ||
'	m.primary_uom_code uom_code, ' ||
'	a.quantity_completed, ' ||
'	a.quantity_scrapped, ' ||
'	a.net_quantity, ' ||
'        decode(a.wip_supply_type,  1, ''Push'', ' ||
'                        	2, ''Assembly Pull'', ' ||
'                        	3, ''Operation Pull'', ' ||
'                        	4, ''Bulk'', ' ||
'                        	5, ''Supplier'', ' ||
'                        	6, ''Phantom'', ' ||
'                        	7, ''Based on Bill'', ' ||
'				a.wip_supply_type) wip_supply_type, ' ||
'	a.class_code, ' ||
'	a.scheduled_start_date, ' ||
'	a.scheduled_completion_date, ' ||
'	a.date_released, ' ||
'	a.date_completed, ' ||
'	a.date_closed, ' ||
'	a.creation_date, ' ||
'	a.common_bom_sequence_id,  ' ||
'	a.common_routing_sequence_id, ' ||
'	a.bom_revision, ' ||
'	a.routing_revision, ' ||
'	nvl(a.alternate_bom_designator, ''PRIMARY'') alternate_bom_designator, ' ||
'	nvl(a.alternate_routing_designator, ''PRIMARY'') alternate_routing_designator, ' ||
'	decode(a.overcompletion_tolerance_type, ' ||
'		1, ''Percent'', ' ||
'		2, ''Amount'') Tol_Type, ' ||
'	a.overcompletion_tolerance_value Tol_Value ' ||
'    from  wip_discrete_jobs a , wip_entities b, mtl_system_items_kfv m, mtl_parameters p ' ||
'    where b.wip_entity_id = a.wip_entity_id ' ||
'    and   b.organization_id = a.organization_id ' ||
'    and   m.inventory_item_id = a.primary_item_id ' ||
'    and   m.organization_id = a.organization_id ' ||
'    and   a.organization_id = p.organization_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and b.wip_entity_id = '|| p_wip_entity_id;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'JOB HEADER ( WIP DISCRETE JOBS , WIP ENTITIES )',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.operation_seq_num, ' ||
'	a.operation_sequence_id, ' ||
'	a.standard_operation_id, ' ||
'        bso.operation_code , ' ||
'	a.department_id, ' ||
'        c.department_code, ' ||
'	a.description, ' ||
'        a.first_unit_start_date, ' ||
'        a.first_unit_completion_date, ' ||
'        a.last_unit_start_date, ' ||
'        a.last_unit_completion_date, ' ||
'       a.scheduled_quantity, ' ||
'	a.quantity_in_queue , ' ||
'	a.quantity_running  , ' ||
'	a.quantity_waiting_to_move , ' ||
'	a.quantity_rejected , ' ||
'	a.quantity_scrapped , ' ||
'	a.quantity_completed , ' ||
'        a.previous_operation_seq_num, ' ||
'	a.next_operation_seq_num, ' ||
'	a.count_point_type, ' ||
'  	decode( a.backflush_flag, 1, ''Yes'', ' ||
'				  2, ''No'') backflush_flag, ' ||
'	a.minimum_transfer_quantity, ' ||
'	a.date_last_moved, ' ||
'	a.creation_date ' ||
'from    wip_operations a, wip_entities b, bom_departments c, bom_standard_operations bso ' ||
'where   a.wip_entity_id = b.wip_entity_id ' ||
'and     a.organization_id = b.organization_id ' ||
'and     a.department_id = c.department_id ' ||
'and     a.organization_id = c.organization_id ' ||
'and     a.standard_operation_id = bso.standard_operation_id(+) ' ||
'and     a.organization_id = bso.organization_id(+) ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and b.wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by 1 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP OPERATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.wip_entity_id, '||
'	a.inventory_item_id, '||
'        substrb(m.concatenated_segments, 1, 30) item_name, '||
'	a.organization_id, '||
'	a.operation_seq_num, '||
'	a.component_sequence_id, '||
'	a.department_id, '||
'        decode(a.wip_supply_type,  1, ''Push'', '||
'                        	2, ''Assembly Pull'', '||
'                        	3, ''Operation Pull'', '||
'                        	4, ''Bulk'', '||
'                        	5, ''Supplier'', '||
'                        	6, ''Phantom'', '||
'                        	7, ''Based on Bill'', '||
'				a.wip_supply_type) wip_supply_type, '||
'	a.required_quantity, '||
'	a.quantity_issued, '||
'	a.quantity_per_assembly, '||
'	a.supply_subinventory, '||
'	a.supply_locator_id, '||
'	a.quantity_allocated, '||
'	a.quantity_backordered, '||
'	a.quantity_relieved, '||
'	a.creation_date '||
'from    wip_requirement_operations a, wip_entities b, mtl_system_items_kfv m '||
'where   b.wip_entity_id = a.wip_entity_id '||
'and     b.organization_id = a.organization_id '||
'and     a.inventory_item_id = m.inventory_item_id '||
'and     a.organization_id = m.organization_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and b.wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by operation_seq_num,inventory_item_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP REQUIREMENT OPERATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.operation_seq_num, '||
'        a.resource_seq_num, '||
' 	a.resource_id, '||
'        a.autocharge_type, '||
'        c.resource_code, '||
'	a.uom_code, '||
'	decode (a.basis_type, 1, ''Item'', '||
'			      2, ''Lot'', '||
'			      3, ''Res Units'', '||
'			      4, ''Res Value'', '||
'			      5, ''Tot Value'', '||
'			      6, ''Activity'', '||
'			      a.BASIS_TYPE)  basis_type, '||
'        decode(a.scheduled_flag, 1, ''Yes'', '||
'                                 2, ''No'', '||
'                                 3, ''Prior'', '||
'                                 4, ''Next'', '||
'                                 a.scheduled_flag) scheduled_flag, '||
'	a.usage_rate_or_amount , '||
'        a.start_date, '||
'        a.completion_date, '||
'        a.applied_resource_units, '||
'        a.applied_resource_value, '||
'	a.creation_date '||
'from    wip_operation_resources a,  bom_resources c '||
'where   a.resource_id = c.resource_id '||
'and     a.organization_id = c.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and a.wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by 1,2';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP OPERATION RESOURCES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.operation_seq_num, '||
'        a.resource_seq_num, '||
'        c.resource_code, '||
'	a.organization_id, '||
' 	a.repetitive_schedule_id, '||
'	a.start_date, '||
'	a.completion_date, '||
'	a.assigned_units, '||
'	a.creation_date '||
'from    wip_operation_resource_usage a, wip_operation_resources b, bom_resources c '||
'where   a.wip_entity_id = b.wip_entity_id '||
'and     a.operation_seq_num = b.operation_seq_num '||
'and     nvl(a.repetitive_schedule_id,0) = nvl(b.repetitive_schedule_id,0) '||
'and     a.resource_seq_num = b.resource_seq_num '||
'and     b.resource_id = c.resource_id '||
'and     b.organization_id = c.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and a.wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by 1,2 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP OPERATION RESOURCE USAGES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select acct_period_id, '||
'       decode(class_type,1,''Standard Discrete'', '||
'                         2,''Repetitive Assembly'', '||
'                         3,''Asset non-standard'', '||
'                         4,''Expense non-standard'', '||
'                         5,''Standard Lot Based'', '||
'                         6,''EAM'', '||
'                         7,''Expense non-standard Lot Based'', '||
'			 class_type) class_type, '||
'       tl_resource_in, '||
'       tl_overhead_in, '||
'       tl_outside_processing_in, '||
'       pl_material_in, '||
'       pl_material_overhead_in, '||
'       pl_resource_in, '||
'       pl_overhead_in, '||
'       pl_outside_processing_in, '||
'       tl_material_out, '||
'       tl_material_overhead_out, '||
'       tl_resource_out, '||
'       tl_overhead_out, '||
'       tl_outside_processing_out, '||
'       pl_material_out, '||
'       pl_material_overhead_out, '||
'       pl_resource_out, '||
'       pl_overhead_out, '||
'       pl_outside_processing_out, '||
'       tl_scrap_in, '||
'       tl_scrap_out, '||
'       tl_scrap_var, '||
'       creation_date, '||
'       last_update_date '||
'from   wip_period_balances ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by creation_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP PERIOD BALANCES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wmt.transaction_id, '||
'       wmt.group_id, '||
'       wmt.fm_operation_code, '||
'       wmt.fm_operation_seq_num, '||
'       decode (wmt.fm_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			wmt.fm_intraoperation_step_type) fm_intraoperation_step_type, '||
'       wmt.to_operation_code, '||
'       wmt.to_operation_seq_num, '||
'       decode (wmt.to_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			wmt.to_intraoperation_step_type) to_intraoperation_step_type, '||
'       wmt.transaction_quantity, '||
'       wmt.transaction_uom, '||
'       wmt.primary_quantity, '||
'       wmt.primary_uom, '||
'       wmt.source_code, '||
'       wmt.source_line_id,  '||
'       wmt.organization_id, '||
'       wmt.primary_item_id, '||
'       wmt.transaction_date, '||
'	wmt.creation_date, '||
'       wmt.acct_period_id, '||
'       wmt.wsm_undo_txn_id, ' ||
'       wmt.job_quantity_snapshot, '||
'       wmt.batch_id, ' ||
'       wmt.scrap_account_id '||
'from   wip_move_transactions wmt '||
'where    exists (select 1 '||
'               from   wip_entities we '||
'               where  we.wip_entity_id = wmt.wip_entity_id '||
'               and    we.entity_type <> 2  '|| 	/*  Other than repetitive Schedule */
'              ) ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wmt.wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by 1 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP MOVE TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wmti.transaction_id, '||
'       group_id, '||
'       source_code,  '||
'       source_line_id, '||
'       decode(process_phase, '||
'			1, ''Move Valdn'', '||
'			2, ''Move Proc'', '||
'			3, ''BF Setup'', '||
'			process_phase) process_phase_meaning, '||
'       decode(process_status, '||
'			1, ''Pending'', '||
'			2, ''Running'', '||
'			3, ''Error'', '||
'			4, ''Completed'', '||
'			5, ''Warning'', '||
'			process_status) process_status_meaning, '||
'       decode(transaction_type, '||
'			1, ''Move'', '||
'			2, ''Complete'', '||
'			3, ''Return'', '||
'			transaction_type) transaction_type_meaning, '||
'       repetitive_schedule_id, '||
'       fm_operation_seq_num, '||
'       fm_operation_code, '||
'       decode (fm_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			fm_intraoperation_step_type) fm_intraoperation_step_type, '||
'       to_operation_seq_num, '||
'       to_operation_code, '||
'       decode (to_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			to_intraoperation_step_type) to_intraoperation_step_type, '||
'       transaction_quantity, '||
'       transaction_uom, '||
'       primary_quantity, '||
'       primary_uom, '||
'       organization_id, '||
'       primary_item_id, '||
'       transaction_date, '||
'	wmti.creation_date, '||
'       acct_period_id, '||
'       scrap_account_id, '||
'       overcompletion_transaction_qty, '||
'       overcompletion_primary_qty, '||
'       overcompletion_transaction_id, '||
'       error_column, '||
'       error_message '||
'from   wip_move_txn_interface wmti, '||
'       wip_txn_interface_errors wtie  '||
'where  wmti.transaction_id = wtie.transaction_id (+) ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by 1 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP MOVE TXN INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

/*
sqltxt :=
'select allocation_id, '||
'       organization_id, '||
'       demand_source_header_id, '||
'       demand_source_line, 	'||
'       user_line_num, '||
'       demand_source_delivery, '||
'       user_delivery, 	'||
'       quantity_allocated, '||
'       quantity_completed, '||
'       demand_class, 	'||
'       creation_date '||
'from   wip_so_allocations ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by allocation_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP SO ALLOCATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;
*/

sqltxt :=
'select wcti.transaction_id,  '||
'       wcti.creation_date, '||
'       wcti.last_update_date, '||
'       wcti.request_id, '||
'       source_code, '||
'       source_line_id, '||
'       decode(process_phase, '||
'		1, ''Res Valdn'', '||
'		2, ''Res Processing'', '||
'		3, ''Job Close'', '||
'		4, ''Prd Close'', '||
'		process_phase) process_phase_meaning, '||
'       decode(process_status, '||
'			1, ''Pending'', '||
'			2, ''Running'', '||
'			3, ''Error'', '||
'			4, ''Completed'', '||
'			5, ''Warning'', '||
'			process_status) process_status_meaning, '||
'       decode(transaction_type, '||
'		1, ''Resource'', '||
'		2, ''Overhead'', '||
'		3, ''OSP'', '||
'		4, ''Cost Update'', '||
'		5, ''PrdClose Var'', '||
'		6, ''JobClose Var'', '||
'		transaction_type) transaction_type_meaning, '||
'       organization_id, '||
'       organization_code, '||
'       primary_item_id, '||
'       transaction_date, '||
'       operation_seq_num, '||
'       resource_seq_num, '||
'       acct_period_id, '||
'       resource_id, '||
'       decode(resource_type, '||
'		1, ''Machine'', '||
'		2, ''Person'', '||
'		3, ''Space'', '||
'		4, ''Misc'', '||
'		5, ''Amount'', '||
'		resource_type) resource_type, '||
'       transaction_quantity, '||
'       actual_resource_rate, '||
'       transaction_uom, '||
'       decode(basis_type, '||
'		1, ''Item'', '||
'		2, ''Lot'', '||
'		3, ''Res Units'', '||
'		4, ''Res Value'', '||
'		5, ''Tot Value'', '||
'		6, ''Activity'') basis_type,  '||
'       move_transaction_id, '||
'       completion_transaction_id, '||
'       error_column, '||
'       error_message '||
'from   wip_cost_txn_interface wcti, '||
'       wip_txn_interface_errors wtie '||
'where  wcti.transaction_id = wtie.transaction_id (+) ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_id';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP COST TXN INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wt.transaction_id,  '||
'       wt.creation_date, '||
'       wt.last_update_date, '||
'       wt.request_id, '||
'       wt.source_code, '||
'       wt.source_line_id, '||
'       wt.group_id, '||
'       decode(wt.transaction_type, '||
'		1, ''Resource'', '||
'		2, ''Overhead'', '||
'		3, ''OSP'', '||
'		4, ''Cost Update'', '||
'		5, ''PrdClose Var'', '||
'		6, ''JobClose Var'', '||
'		wt.transaction_type) transaction_type_meaning, '||
'       wt.organization_id, '||
'       wt.primary_item_id, '||
'       wt.transaction_date, '||
'       wt.operation_seq_num, '||
'       wt.resource_seq_num, '||
'       wt.acct_period_id, '||
'       wt.resource_id, '||
'       wt.transaction_quantity, '||
'       wt.actual_resource_rate, '||
'       wt.standard_resource_rate, '||
'       wt.transaction_uom, '||
'       wt.move_transaction_id, '||
'       wt.completion_transaction_id '||
'from   wip_transactions wt '||
'where  exists (select 1 '||
'               from   wip_entities we '||
'               where  we.wip_entity_id = wt.wip_entity_id '||
'               and    we.entity_type <> 2) '; /*  Other than Repetitive */

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_id';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_interface_id, '||
'        transaction_header_id, '||
'	source_code, '||
'	source_line_id, '||
'        source_header_id, '||
'	process_flag, '||
'	transaction_mode, '||
'	lock_flag, '||
'	request_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	transaction_uom, '||
'	transaction_date, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_source_id, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Plan Xfr'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	transaction_type_id, '||
'	operation_seq_num, '||
'	repetitive_line_id, '||
'	transfer_organization, '||
'	transfer_subinventory, '||
'	transfer_locator, '||
'        overcompletion_transaction_qty, '||
'        overcompletion_primary_qty, '||
'        overcompletion_transaction_id, '||
'	error_code, '||
'	substr(error_explanation,1,100) error_explanation '||
'from    mtl_transactions_Interface mti '||
'where   mti.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by transaction_interface_id, transaction_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_interface_id, '||
'	source_code, '||
'	source_line_id, '||
'	request_id, '||
'	lot_number, '||
'	lot_expiration_date, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	serial_transaction_temp_id, '||
'	process_flag,  '||
'	error_code '||
'from    mtl_transaction_lots_interface mtli '||
'where   mtli.transaction_interface_id in '||
'		(select transaction_interface_id '||
'		 from mtl_transactions_Interface mti '||
'	 	 where   mti.transaction_source_type_id = 5 ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by lot_expiration_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select '||
'	transaction_interface_id, '||
'	source_code, '||
'	source_line_id, '||
'	request_id, '||
'	vendor_serial_number, '||
'	vendor_lot_number, '||
'	fm_serial_number, '||
'	to_serial_number, '||
'	error_code, '||
'	process_flag, '||
'	parent_serial_number '||
'from    mtl_serial_numbers_interface msni '||
'where   msni.transaction_interface_id in '||
'		(select transaction_interface_id '||
'		 from mtl_transactions_Interface mti '||
'	 	 where   mti.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by fm_serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSNI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_temp_id, '||
'        transaction_header_id, '||
'	source_code, '||
'	source_line_id, '||
'	transaction_mode, '||
'	lock_flag, '||
'	transaction_date, '||
'	transaction_type_id, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Issue'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_source_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	primary_quantity, '||
'	trx_source_line_id, '||
'	trx_source_delivery_id, '||
'        overcompletion_transaction_qty, '||
'        overcompletion_primary_qty, '||
'        overcompletion_transaction_id, '||
'	move_transaction_id, '||
'	completion_transaction_id, '||
'	source_code, '||
'	source_line_id, '||
'	transfer_organization, '||
'	transfer_subinventory, '||
'	transfer_to_location, '||
'	move_order_line_id, '||
'	reservation_id, '||
'	creation_date, '||
'	last_update_date, '||
'	error_code '||
'from    mtl_material_transactions_temp '||
'where   transaction_source_type_id = 5 ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and transaction_source_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_temp_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MMTT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_temp_id, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	lot_number, '||
'	lot_expiration_date, '||
'	serial_transaction_temp_id, '||
'	group_header_id, '||
'	put_away_rule_id, '||
'	pick_rule_id, '||
'	request_id, '||
'	creation_date, '||
'	error_code '||
'from    mtl_transaction_lots_temp mtlt '||
'where   mtlt.transaction_temp_id in '||
'		(select mmtt.transaction_temp_id '||
'		 from mtl_material_transactions_temp mmtt '||
'	 	 where   mmtt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmtt.transaction_source_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by transaction_temp_id, lot_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_temp_id, '||
'	vendor_serial_number, '||
'	vendor_lot_number, '||
'	fm_serial_number, '||
'	to_serial_number, '||
'	serial_prefix, '||
'	group_header_id, '||
'	parent_serial_number, '||
'	end_item_unit_number, '||
'	request_id, '||
'	creation_date, '||
'	error_code '||
'from    mtl_serial_numbers_temp msnt '||
'where   msnt.transaction_temp_id  in '||
'		(select  mmtt.transaction_temp_id '||
'		 from    mtl_material_transactions_temp mmtt '||
'	 	 where   mmtt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmtt.transaction_source_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by transaction_temp_id, fm_serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSNT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select DISTINCT '||
' TRL.LINE_ID                         MOVE_LINE_ID, '||
' TRL.REQUEST_NUMBER                  MOVE_NUMBER, '||
' TRL.HEADER_ID                       MV_HDR_ID, '||
' TRL.LINE_NUMBER                     MV_LINE_NUM, '||
' decode(TRL.LINE_STATUS, '||
'                    1, ''Incomplete'', '||
'                    2, ''Pend Aprvl'', '||
'                    3, ''Approved'', '||
'                    4, ''Not Apprvd'', '||
'                    5, ''Closed'', '||
'                    6, ''Canceled'', '||
'                    7, ''Pre Apprvd'', '||
'                    8, ''Part Aprvd'') MV_LINE_STAT, '||
' TRL.INVENTORY_ITEM_ID, '||
' TRL.ORGANIZATION_ID, '||
' TRL.REVISION, '||
' TRL.QUANTITY                        QTY, '||
' TRL.PRIMARY_QUANTITY                PRM_QTY,            '||
' TRL.QUANTITY_DELIVERED              DLVD_QTY, '||
' TRL.QUANTITY_DETAILED               DTLD_QTY, '||
' TRL.MOVE_ORDER_TYPE_NAME            MOVE_TYPE_NAME, '||
' decode(TRL.TRANSACTION_SOURCE_TYPE_ID,2,''Sales Order'', '||
'                                       5,''Job or Schedule'', '||
'                                       13,''Inventory'', '||
'					TRL.TRANSACTION_SOURCE_TYPE_ID) txn_source_meaning,   '||
' TRL.TRANSACTION_TYPE_NAME           transaction_type_meaning,        '||
' decode(TRL.TRANSACTION_ACTION_ID, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Plan Xfr'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		trl.transaction_action_id) txn_action_meaning, '||
' TRL.FROM_SUBINVENTORY_CODE          FROM_SUB, '||
' TRL.FROM_LOCATOR_ID                 FROM_LOC_ID,  '||
' TRL.TO_SUBINVENTORY_CODE            TO_SUB, '||
' TRL.TO_LOCATOR_ID                   TO_LOC_ID,           '||
' TRL.LOT_NUMBER                      LOT_NUM, '||
' TRL.TRANSACTION_HEADER_ID           TRNS_HEAD_ID, '||
' TRL.CREATION_DATE '||
'from MTL_TXN_REQUEST_LINES_V   TRL '||
'WHERE trl.move_order_type <> 6 '||
'AND   (trl.txn_source_id, trl.txn_source_line_id) in  '||
'	(select  wdj.wip_entity_id, wro.operation_seq_num  '||
'	 from wip_discrete_jobs wdj,  '||
'	      wip_entities we,  '||
'		wip_lines wl,  '||
'		wip_requirement_operations wro  '||
'	 where wdj.wip_entity_id = we.wip_entity_id  '||
'	 and  wdj.organization_id = we.organization_id  '||
'	 and wdj.wip_entity_id = wro.wip_entity_id  '||
'         and wdj.organization_id = wro.organization_id  '||
'	 and wdj.line_id = wl.line_id(+)  '||
'         and wdj.organization_id = wl.organization_id(+)  ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and we.wip_entity_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by request_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTL_TXN_REQUEST_LINES_V TRANSACTIONS  - MOVE ORDERS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_id, '||
'	transaction_date, '||
'	transaction_type_id, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Issue'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_source_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	primary_quantity, '||
'	trx_source_line_id, '||
'	trx_source_delivery_id, '||
'	move_transaction_id, '||
'	completion_transaction_id, '||
'	source_code, '||
'	source_line_id, '||
'	transfer_organization_id, '||
'	transfer_subinventory, '||
'	transfer_locator_id, '||
'	move_order_line_id, '||
'	reservation_id, '||
'	creation_date, '||
'	last_update_date, '||
'	error_code '||
'from    mtl_material_transactions '||
'where   transaction_source_type_id = 5 '||
'and     exists (select 1  '||
'                from   wip_entities '||
'                where  wip_entity_id = transaction_source_id '||
'                and    entity_type <>  2 ) '; /*  Other than repetitive schedule */

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and transaction_source_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MMT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	inventory_item_id, '||
'	lot_number, '||
'	organization_id, '||
'	transaction_id, '||
'	transaction_date, '||
'	creation_date, '||
'	transaction_source_id, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	serial_transaction_id '||
'from    mtl_transaction_lot_numbers mtln '||
'where   mtln.transaction_id in '||
'		(select mmt.transaction_id '||
'		 from mtl_material_transactions mmt '||
'	 	 where   mmt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by inventory_item_id, lot_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	inventory_item_id, '||
'	serial_number, '||
'	decode(current_status, '||
'		1, ''Defined but not used'', '||
'		3, ''Resides in stores'', '||
'		4, ''Issued out of stores'', '||
'		5, ''Resides in intrasit'', '||
'		current_status) current_status_meaning, '||
'	revision, '||
'	lot_number, '||
'	parent_item_id, '||
'	last_transaction_id, '||
'	parent_serial_number, '||
'	end_item_unit_number, '||
'	group_mark_id, '||
'	line_mark_id, '||
'	lot_line_mark_id, '||
'	gen_object_id, '||
'	creation_date '||
'from    mtl_serial_numbers msn ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where msn.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by inventory_item_id, serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSN TRANSACTIONS for WIP Serial Tracking',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
' select mmt.inventory_item_id, ' ||
'        mmt.transaction_id,' ||
'        mmt.transaction_date,' ||
'        mmt.transaction_source_id,' ||
'        mut.serial_number,' ||
'        mmt.subinventory_code,' ||
'        mmt.locator_id , ' ||
'        mmt.creation_date' ||
' from   mtl_material_transactions mmt,' ||
'        mtl_unit_transactions mut' ||
' where  mmt.transaction_action_id in (1, 27, 33, 34, 30, 31, 32)' ||
' and    mmt.transaction_source_type_id = 5' ||
' and    mut.transaction_id = mmt.transaction_id' ;

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id  = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by mmt.inventory_item_id, mut.serial_number ';
   end if ;


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	header_id, '||
'	source_id, '||
'	source_code, '||
'	completion_status, '||
'	creation_date, '||
'	last_update_date, '||
'	inventory_item_id, '||
'	organization_id, '||
'	primary_quantity, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	transaction_date, '||
'	transaction_action_id, '||
'	transaction_source_id, '||
'	transaction_source_type_id, '||
'	transaction_type_id, '||
'	transaction_mode, '||
'	acct_period_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	schedule_id, '||
'	repetitive_line_id, '||
'	operation_seq_num, '||
'	cost_group_id, '||
'	lock_flag, '||
'	error_code, '||
'	final_completion_flag, '||
'	completion_transaction_id '||
'from    wip_lpn_completions ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by header_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP LPN COMPLETIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'     RES.RESERVATION_ID            RESERV_ID, '||
'     decode(RES.SHIP_READY_FLAG,1,''1=Released'',2,''2=Submitted'',to_char(RES.SHIP_READY_FLAG)) '||
'                                   SHIP_READY,  '||
'     RES.DEMAND_SOURCE_HEADER_ID   DS_HEADER_ID, '||
'     RES.DEMAND_SOURCE_LINE_ID     DS_LINE_ID, '||
'     RES.DEMAND_SOURCE_DELIVERY    DS_DELIVERY, '||
'     RES.INVENTORY_ITEM_ID         ITEM_ID, '||
'     RES.RESERVATION_QUANTITY      RES_QTY, '||
'     RES.RESERVATION_UOM_CODE      RUOM, '||
'     RES.PRIMARY_RESERVATION_QUANTITY PRES_QTY, '||
'     RES.PRIMARY_UOM_CODE          PUOM, '||
'     RES.DETAILED_QUANTITY         DET_QTY, '||
'     RES.REQUIREMENT_DATE          REQUIRD_DATE, '||
'     RES.DEMAND_SOURCE_TYPE_ID     DS_TYPE, '||
'     RES.ORGANIZATION_ID           ORG_ID, '||
'     RES.SUBINVENTORY_CODE         SUBINV, '||
'     RES.LOT_NUMBER                LOT, '||
'     RES.REVISION                  REV, '||
'     RES.LOCATOR_ID                LOC_ID, '||
'     RES.SERIAL_NUMBER             SERIAL_NUM, '||
'     decode(RES.SUPPLY_SOURCE_TYPE_ID,1,''1=PO'', '||
'                                      2,''2=OE'', '||
'                                      5,''5=WIP DJ'', '||
'                                      7,''7=INT_REQ'', '||
'                                      8,''8=INT_OE'', '||
'                                      13,''13=INV'', '||
'                                      17,''17=REQ'', '||
'					RES.SUPPLY_SOURCE_TYPE_ID) '||
'                                   SS_TYPE_ID, '||
'     We.WIP_ENTITY_ID             WIP_ID, '||
'     decode(JOB.STATUS_TYPE, 1, ''Unreleased'',            '||
'                             2, ''Simulated'',            '||
'                             3, ''Released'',            '||
'                             4, ''Complete'',            '||
'                             5, ''Complete-NoCharges'',            '||
'                             6, ''OnHold'',            '||
'                             7, ''Canceled'',            '||
'                             8, ''Pending Bill Load'',            '||
'                             9, ''Failed Bill Load'',            '||
'                            10, ''Pending Routing Load'',            '||
'                            11, ''Failed Routing Load'',            '||
'                            12, ''Closed'',            '||
'                            13, ''Pending-Mass Load'',            '||
'                            14, ''Pending Close'',            '||
'                            15, ''Failed Close'',  '||
'                            16, ''Pending Scheduling'',  '||
'                            17, ''Draft'',  '||
'                            JOB.STATUS_TYPE ) JOB_STATUS, '||
'     RES.SUPPLY_SOURCE_HEADER_ID   SS_HEADER_ID,       '||
'     RES.SUPPLY_SOURCE_LINE_DETAIL SS_SOURCE_LINE_DET, '||
'     RES.SUPPLY_SOURCE_LINE_ID     SS_SOURCE_LINE,       '||
'     RES.PARTIAL_QUANTITIES_ALLOWED ALLOW_PART, '||
'     to_char(RES.CREATION_DATE, ''DD-MON HH24:MI:SS'') CREATE_DATE, '||
'     to_char(RES.LAST_UPDATE_DATE, ''DD-MON HH24:MI:SS'') UPD_DATE '||
'from '||
'     MTL_RESERVATIONS              RES, '||
'     WIP_ENTITIES                  WE, '||
'     WIP_DISCRETE_JOBS             JOB '||
'where RES.SUPPLY_SOURCE_HEADER_ID   = WE.WIP_ENTITY_ID '||
'and  WE.WIP_ENTITY_ID             = JOB.WIP_ENTITY_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and we.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by reservation_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTL RESERVATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'Select '||
'RQI.INTERFACE_SOURCE_LINE_ID           wip_entity_id, '||
'RQI.INTERFACE_SOURCE_CODE              SRC_CODE, '||
'RQI.AUTHORIZATION_STATUS               AUTH_STATUS,    '||
'RQI.DELIVER_TO_LOCATION_ID             DELIV_LOC, '||
'RQI.PREPARER_ID                        PREPARER, '||
'RQI.DESTINATION_ORGANIZATION_ID        DEST_ORG_ID, '||
'RQI.DESTINATION_TYPE_CODE              DEST_TYPE, '||
'RQI.SOURCE_TYPE_CODE                   SRC_TYPE_CODE, '||
'RQI.ITEM_ID                            ITEM_ID, '||
'RQI.NEED_BY_DATE                       NEED_BY,                                '||
'RQI.QUANTITY                           QTY,                   '||
'RQI.UNIT_PRICE                         PRICE '||
'from  '||
' PO_REQUISITIONS_INTERFACE_ALL   RQI '||
'where RQI.INTERFACE_SOURCE_CODE =''WIP'' ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rqi.interface_source_line_id = '|| p_wip_entity_id ;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO REQUISITION INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select '||
'  POE.INTERFACE_TRANSACTION_ID     INTF_TRANS_ID,    '||
'  POE.COLUMN_NAME                  COLUMN_NAME,                   '||
'  POE.ERROR_MESSAGE                ERROR,   '||
'  POE.INTERFACE_TYPE               INTF_TYPE,          '||
'  POE.REQUEST_ID                   REQUEST_ID, '||
'  POE.TABLE_NAME                   TABLE_NAME '||
'from   '||
'  PO_INTERFACE_ERRORS         POE, '||
'  PO_REQUISITIONS_INTERFACE_ALL   RQI '||
'where RQI.TRANSACTION_ID           = POE.INTERFACE_TRANSACTION_ID ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rqi.interface_source_line_id = '|| p_wip_entity_id ;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO INTERFACE ERRORS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select   '||
'  RQH.REQUISITION_HEADER_ID               REQ_HEADER_ID , '||
'  RQH.SEGMENT1                            REQ_NUMBER, '||
'  RQL.REQUISITION_LINE_ID          	  REQ_LINE_ID,               '||
'  RQL.LINE_NUM                            REQ_LINE, '||
'  RQH.INTERFACE_SOURCE_LINE_ID            INT_SRC_LINE_ID, '||
'  RQL.WIP_ENTITY_ID		          WIP_ENTITY_ID, '||
'  RQH.AUTHORIZATION_STATUS                AUTH_STATUS,                '||
'  RQH.ENABLED_FLAG                        ENABLED,   '||
'  RQH.INTERFACE_SOURCE_CODE               SRC_CODE, '||
'  RQH.SUMMARY_FLAG                        SUMMARY, '||
'  RQH.TRANSFERRED_TO_OE_FLAG              XFR_OE_FLAG, '||
'  RQH.TYPE_LOOKUP_CODE                    REQ_TYPE, '||
'  RQH.WF_ITEM_TYPE                        ITEM_TYPE, '||
'  RQH.WF_ITEM_KEY                         ITEM_KEY, '||
'  RQL.ITEM_ID                      ITEM_ID,     '||
'  RQL.UNIT_MEAS_LOOKUP_CODE        UOM,  '||
'  RQL.UNIT_PRICE                   PRICE, '||
'  RQL.QUANTITY                     QTY,            '||
'  RQL.QUANTITY_CANCELLED           QTY_CNC,           '||
'  RQL.QUANTITY_DELIVERED           QTY_DLV,                   '||
'  RQL.CANCEL_FLAG                  CANC,         '||
'  RQL.DESTINATION_CONTEXT          DEST_TYPE,      '||
'  RQL.DESTINATION_ORGANIZATION_ID  DEST_ORG, '||
'  RQL.ENCUMBERED_FLAG              ENC_FLAG ,                  '||
'  RQL.LINE_TYPE_ID                 LINE_TYPE_ID, '||
'  RQL.NEED_BY_DATE                 NEED_BY, '||
'  RQL.ON_RFQ_FLAG                  RFQ ,                                           '||
'  RQL.SOURCE_TYPE_CODE             SRC_TYPE_CODE, '||
'  RQL.SUGGESTED_BUYER_ID           BUYER_ID              '||
'from  '||
' PO_REQUISITION_HEADERS_ALL      RQH, '||
' PO_REQUISITION_LINES_ALL        RQL '||
'where  '||
' RQH.REQUISITION_HEADER_ID = RQL.REQUISITION_HEADER_ID ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rql.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by RQH.REQUISITION_HEADER_ID, RQL.REQUISITION_LINE_ID, RQL.ITEM_ID';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO REQUISITION DETAILS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFS.item_key               REQ_NUM_IK, '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.NOTIFICATION_ID        NOTIF_ID, '||
'       WFS.BEGIN_DATE, '||
'       WFS.END_DATE, '||
'       WFS.ERROR_NAME             ERROR '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''REQAPPRV'' '||
'and  WFS.item_key       in (select wf_item_key '||
'                           from  '||
'                           PO_REQUISITION_HEADERS_ALL  RQH, '||
'			   PO_REQUISITION_LINES_ALL    RQL '||
'                           where  '||
' 				RQH.REQUISITION_HEADER_ID = RQL.REQUISITION_HEADER_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rql.wip_entity_id = '|| p_wip_entity_id ||') ';
   end if;

   sqltxt :=sqltxt||
'	and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'	and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'	and  WFP.PROCESS_NAME       = WFA.NAME '||
'	and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'	and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'	and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'	and  WFA1.VERSION =  '||
'    	(select max(VERSION) '||
'     	from WF_ACTIVITIES WF2 '||
'     	where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     	and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'	and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'	and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS ';

   sqltxt :=sqltxt||' order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW REQUISITION APPROVAL STATUS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.ERROR_NAME             ERROR_NAME, '||
'       WFS.ERROR_MESSAGE          ERROR_MESSAGE, '||
'       WFS.ERROR_STACK            ERROR_STACK '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''REQAPPRV'' '||
'and  WFS.item_key       in (select wf_item_key '||
'                           from  '||
'                           PO_REQUISITION_HEADERS_ALL  RQH, '||
'			   PO_REQUISITION_LINES_ALL    RQL '||
'                           where  '||
' 				RQH.REQUISITION_HEADER_ID = RQL.REQUISITION_HEADER_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rql.wip_entity_id = '|| p_wip_entity_id ||') ';
   end if;

   sqltxt := sqltxt ||
'	and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'	and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'	and  WFP.PROCESS_NAME       = WFA.NAME '||
'	and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'	and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'	and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'	and  WFA1.VERSION =  '||
'    	(select max(VERSION) '||
'     	from WF_ACTIVITIES WF2 '||
'     	where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     	and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'	and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'	and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS '||
'	and  WFS.ERROR_NAME is not NULL '||
'	order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW REQUISITION APPROVAL ERRORS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'  POH.PO_HEADER_ID                PO_HEADER_ID,          '||
'  POH.SEGMENT1                    PO_NUM, '||
'  POL.PO_LINE_ID                  PO_LINE_ID, '||
'  POL.LINE_NUM                    PO_LINE, '||
'  POL.LINE_TYPE_ID                LINE_TYPE_ID, '||
'  POL.ITEM_ID                     ITEM_ID,                   '||
'  POL.QUANTITY                    QTY, '||
'  POL.UNIT_PRICE                  PRICE, '||
'  POH.ACCEPTANCE_REQUIRED_FLAG    ACCEPT_REQD, '||
'  POH.BILL_TO_LOCATION_ID         BILL_TO, '||
'  POH.SHIP_TO_LOCATION_ID         SHIP_TO, '||
'  POH.CLOSED_CODE                 CLS_STAT, '||
'  POH.CONFIRMING_ORDER_FLAG       CONF_ORD, '||
'  POH.CURRENCY_CODE               CURR, '||
'  POH.ENABLED_FLAG                ENABLED, '||
'  POH.FROZEN_FLAG                 FROZEN,                    '||
'  POH.SUMMARY_FLAG                SUMM,                '||
'  POH.TYPE_LOOKUP_CODE            TYPE, '||
'  POH.VENDOR_CONTACT_ID           VEND_CNCACT,      '||
'  POH.VENDOR_ID                   VEND_ID,     '||
'  POH.VENDOR_SITE_ID              VEND_SITE,    '||
'  POH.WF_ITEM_TYPE                ITEM_TYPE, '||
'  POH.WF_ITEM_KEY                 ITEM_KEY ,  '||
'  POL.CATEGORY_ID                 CATEGORY_ID, '||
'  POL.CLOSED_CODE                 CLS_STAT, '||
'  POL.FIRM_STATUS_LOOKUP_CODE     FIRM '||
'from  '||
'    PO_HEADERS_ALL             POH, '||
'    PO_LINES_ALL               POL, '||
'    PO_LINE_LOCATIONS_ALL      LL, '||
'    PO_REQUISITION_LINES_ALL   PRL, '||
'    PO_REQUISITION_HEADERS_ALL PRH '||
'where  PRH.requisition_header_id = PRL.requisition_header_id '||
'and    PRL.line_location_id = LL.line_location_id '||
'and    LL.PO_HEADER_ID = POH.PO_HEADER_ID '||
'and    POL.PO_HEADER_ID = POH.PO_HEADER_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and prl.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by poh.po_header_id, pol.po_line_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO DETAILS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFS.item_key               PO_NUM_IK, '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.NOTIFICATION_ID        NOTIF_ID, '||
'       WFS.BEGIN_DATE, '||
'       WFS.END_DATE, '||
'       WFS.ERROR_NAME             ERROR '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''POAPPRV'' '||
'and  WFS.item_key           in (select poh.wf_item_key '||
'				from  '||
'    				PO_HEADERS_ALL             POH, '||
'				PO_LINES_ALL               POL, '||
'    				PO_LINE_LOCATIONS_ALL      LL, '||
'    				PO_REQUISITION_LINES_ALL   PRL, '||
'    				PO_REQUISITION_HEADERS_ALL PRH '||
'				where  PRH.requisition_header_id = PRL.requisition_header_id ';
   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and prl.wip_entity_id = '|| p_wip_entity_id ;
   end if;

   sqltxt := sqltxt ||
'				and    PRL.line_location_id = LL.line_location_id '||
'				and    LL.PO_HEADER_ID = POH.PO_HEADER_ID '||
'				and    POL.PO_HEADER_ID = POH.PO_HEADER_ID) '||
'and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'and  WFP.PROCESS_NAME       = WFA.NAME '||
'and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'and  WFA1.VERSION =  '||
'    (select max(VERSION) '||
'     from WF_ACTIVITIES WF2 '||
'     where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS '||
'order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME  ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW PURCHASE ORDER APPROVAL STATUS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.ERROR_NAME             ERROR_NAME, '||
'       WFS.ERROR_MESSAGE          ERROR_MESSAGE, '||
'       WFS.ERROR_STACK            ERROR_STACK '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''POAPPRV'' '||
'and  WFS.item_key           in (select poh.wf_item_key '||
'				from  '||
'    				PO_HEADERS_ALL             POH, '||
'				PO_LINES_ALL               POL, '||
'    				PO_LINE_LOCATIONS_ALL      LL, '||
'    				PO_REQUISITION_LINES_ALL   PRL, '||
'    				PO_REQUISITION_HEADERS_ALL PRH '||
'				where  PRH.requisition_header_id = PRL.requisition_header_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and prl.wip_entity_id = '|| p_wip_entity_id ;
   end if;

   sqltxt := sqltxt ||
'				and    PRL.line_location_id = LL.line_location_id '||
'				and    LL.PO_HEADER_ID = POH.PO_HEADER_ID '||
'				and    POL.PO_HEADER_ID = POH.PO_HEADER_ID) '||
'and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'and  WFP.PROCESS_NAME       = WFA.NAME '||
'and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'and  WFA1.VERSION =  '||
'    (select max(VERSION) '||
'     from WF_ACTIVITIES WF2 '||
'     where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS '||
'and  WFS.ERROR_NAME is not NULL '||
'order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME ';


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW PURCHASE APPROVAL ERRORS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	default_discrete_class, '||
'	decode(lot_number_default_type,1,''Job Name'', '||
'					2,''Based On Inventory Rules'', '||
'					3,''No Default'', '||
'					lot_number_default_type) lot_number_default_type, '||
'	decode(so_change_response_type,1,''Never'', '||
'					2,''Always'', '||
'					3,''When linked 1-1Default'') so_change_response_type, '||
'	decode(mandatory_scrap_flag,1,''Yes'',2,''No'') Mandatory_Scrap_Flag, '||
'	decode(dynamic_operation_insert_flag,1,''Yes'',2,''No'') Dynamic_Oprn_Insert_Flag, '||
'	decode(moves_over_no_move_statuses,1,''Yes'',2,''No'') Moves_Over_No_Move_Status, '||
'       default_pull_supply_subinv, '||
'	default_pull_supply_locator_id, '||
'	decode(backflush_lot_entry_type,1, ''Manual, verify all'', '||
'	                            2, ''Receipt Date, Verify all'', '||
'	                            3, ''Receipt Date, Verify excepns'', '||
'	                            4, ''Expiration Date, verify all'', '||
'	                            5, ''Expiration Date, verify excepns'', '||
'	                            6, ''Transaction History'', '||
'	                            backflush_lot_entry_type) Lot_Selection_Method , ' ;

if (release_level = '11.5.10.2' ) then
   sqltxt := sqltxt ||
'	decode(alternate_lot_selection_method,1, ''Manual'', '||
'	                            2, ''Receipt Date'', '||
'	                            4, ''Expiration Date'' , '||
'	                         alternate_lot_selection_method) Alternate_Lot_Selection_Method, ' ;
end if ;
    sqltxt := sqltxt ||

'	decode(allocate_backflush_components,''1'',''Yes'',''2'',''No'') Allocate_Backflush_Comps, '||
'	decode(allow_backflush_qty_change,1,''Yes'',2,''No'') Allow_Backflush_Qty_Change, '||
'	autorelease_days, '||
'	osp_shop_floor_status, '||
'	decode(po_creation_time, 1, ''At Job/Schedule Release'', '||
'	                         2, ''At Operation'', '||
'	                         3, ''Manual'', '||
'	                         po_creation_time) PO_Creation_Time, '||
'	default_overcompl_tolerance, '||
'	production_scheduler_id, '||
'	decode(material_constrained,1,''Yes'',2,''No'') Material_Constrained, '||
'	decode(use_finite_scheduler,1,''Yes'',2,''No'') Use_Finite_Scheduler,'||
'	repetitive_variance_type '||
'from	wip_parameters '||
'where   organization_id = (select organization_id  '||
'			from wip_entities ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ||')';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP PARAMETERS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.assembly_item_id, '||
'       substrb(msi.concatenated_segments, 1,30) item_name,  '||
-- '    a.organization_id, '||
'       nvl(a.alternate_bom_designator, ''PRIMARY'') alternate_bom_designator, '||
'       a.common_assembly_item_id, '||
'       decode( a.assembly_type,1,''Manufacturing'', '||
'                               2,''Engineering'', '||
'                               a.assembly_type) assembly_type, '||
'       a.bill_sequence_id, '||
'       a.common_bill_sequence_id, '||
'       b.operation_seq_num, '||
'       b.component_item_id, '||
'       substrb(msi_comp.concatenated_segments, 1,30) comp_item_name,  '||
'       b.component_quantity, '||
'       b.component_yield_factor, '||
'       b.effectivity_date, '||
'       b.implementation_date, '||
'       b.disable_date, '||
'       decode(b.wip_supply_type,1,''Push'', '||
'                                2,''Assembly Pull'', '||
'                                3,''Operation Pull'', '||
'                                4,''Bulk'', '||
'                                5,''Supplier'', '||
'                                6,''Phantom'', '||
'                                7,''Based on Bill'', '||
'                                b.wip_supply_type) wip_supply_type, '||
'       b.supply_subinventory, '||
'       b.supply_locator_id, '||
'       b.component_sequence_id '||
'from    bom_bill_of_materials a, bom_inventory_components b,  '||
'        wip_discrete_jobs wj, mtl_system_items_kfv msi, mtl_system_items_kfv msi_comp '||
'where   a.common_bill_sequence_id = b.bill_sequence_id '||
'and     a.organization_id = wj.organization_id '||
'and     a.assembly_item_id = wj.primary_item_id '||
'and     wj.common_bom_sequence_id = a.bill_sequence_id  '||
'and     msi.inventory_item_id = a.assembly_item_id '||
'and     msi.organization_id = a.organization_id ' ||
'and     msi_comp.organization_id = a.organization_id ' ||
'and     msi_comp.inventory_item_id = b.component_item_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wj.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by a.bill_sequence_id, a.assembly_item_id, a.alternate_bom_designator, b.component_sequence_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'BILL OF MATERIAL',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  bor.assembly_item_id, '||
'       substrb(msi.concatenated_segments, 1,30) item_name,  '||
'       bor.organization_id, '||
'       nvl(bor.alternate_routing_designator, ''PRIMARY'') alternate_routing_designator, '||
'       bor.routing_sequence_id, '||
'       bor.common_routing_sequence_id, '||
'       bor.common_assembly_item_id, '||
'       bor.completion_subinventory, '||
'       bor.completion_locator_id, '||
'       decode(nvl(bor.cfm_routing_flag,2), '||
'               1, ''Flow'', '||
'               2, ''Discrete'', '||
'               3, ''Network'', '||
'               bor.cfm_routing_flag) cfm_routing_flag, '||
'       decode (bor.routing_type, '||
'               1, ''Mfg Rtg'', '||
'               2, ''Engg Rtg'', '||
'               bor.routing_type) routing_type, '||
'       a.operation_sequence_id, '||
'       a.operation_seq_num, '||
'       a.routing_sequence_id, '||
'       a.standard_operation_id, '||
'       b.operation_code, '||
'       a.department_id, '||
'       a.count_point_type, '||
'       a.effectivity_date, '||
'       a.disable_date, '||
'       decode( a.backflush_flag, 1, ''Yes'', '||
'                                 2, ''No'') backflush_flag, '||
'       decode( a.option_dependent_flag, 1, ''Yes'', '||
'                                       2, ''No'') option_dependent_flag, '||
'       a.yield, '||
'       decode(a.operation_yield_enabled, 1, ''Yes'', '||
'                                         2, ''No'', '||
'                                         a.operation_yield_enabled) operation_yield_enabled '||
'from    bom_operation_sequences a, bom_operational_routings bor, wip_discrete_jobs wj, '||
'        bom_standard_operations b , mtl_system_items_kfv msi '||
'where   a.routing_sequence_id = bor.common_routing_sequence_id '||
'and     wj.organization_id = bor.organization_id '||
'and     wj.common_routing_sequence_id = bor.routing_sequence_id '||
'and     a.standard_operation_id = b.standard_operation_id(+) ' ||
'and     bor.assembly_item_id = msi.inventory_item_id '||
'and     bor.organization_id = msi.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wj.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by bor.routing_sequence_id, bor.alternate_routing_designator, a.operation_seq_num';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'ROUTING',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'SELECT msik.inventory_item_id, '||
'                  substr(msik.concatenated_segments, 1, 30) Item, '||
'                  msik.outside_operation_flag, '||
'                  msik.outside_operation_uom_type, '||
'                  wor.operation_seq_num, '||
'                  wor.resource_seq_num, '||
'                  wor.resource_id, '||
'                  br.resource_code, '||
'                  decode(wor.autocharge_type , 3, ''PO Move'', 4, ''PO Receipt'') AutoCharge_Type '||
'           FROM   mtl_system_items_kfv msik, '||
'                  bom_resources br, '||
'                  wip_operation_resources wor '||
'           WHERE  msik.inventory_item_id = br.purchase_item_id '||
'           AND    msik.organization_id = br.organization_id '||
'           AND    wor.resource_id = br.resource_id '||
'           AND    wor.autocharge_type IN (3,4) '||
'           AND    wor.organization_id = br.organization_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wor.wip_entity_id = '|| p_wip_entity_id ;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'OSP ITEM DETAILS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	secondary_inventory_name, '||
'	organization_id, '||
'	decode(reservable_type, '||
'		1, ''Yes'', '||
'		2, ''No'', '||
'		reservable_type) reserv_type_mng, '||
'	disable_date, '||
'	decode(inventory_atp_code, '||
'		1, ''Incl in ATP calc'', '||
'		2, ''Not Incl in ATP calc'', '||
'		inventory_atp_code)	inv_atp_code_mng, '||
'	decode(locator_type, '||
'		1, ''No loc control'', '||
'		2, ''Prespecified'', '||
'		3, ''Dynamic'', '||
'		4, ''Determined at subinv'', '||
'		5, ''Determined at item'', '||
'		locator_type) locator_type_mng, '||
'	picking_order, '||
'	source_subinventory '||
'from    mtl_secondary_inventories '||
'where   organization_id = (select organization_id  '||
'			from wip_entities ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by 1';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'SUBINVENTORY SETUP',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

 -- Run following diagnostics only for Lot Based jobs
 begin
   select 1
   into   l_dummy
   from   wip_entities
   where  wip_entity_id = p_wip_entity_id
   and    entity_type = 5 ; -- LotBased

   sqltxt := ' select ' ||
   '   new_lot_separator          ' ||
   ' ,  job_completion_separator   ' ||
   ' ,  allow_backward_move_flag   ' ||
   ' ,  delete_backward_from_flag  ' ||
   ' ,  transaction_account_id     ' ||
   ' ,  plan_code                  ' ||
   ' ,  op_seq_num_increment       ' ||
   ' ,  coproducts_supply_default  ' ||
   ' ,  default_acct_class_code    ' ||
   ' ,  estimated_scrap_accounting ' ||
   ' ,  inv_lot_txn_enabled        ' ||
   ' ,  honor_kanban_size          ' ||
   ' ,  charge_jump_from_queue     ' ||
   ' from wsm_parameters wp, wip_entities we ' ||
   ' where wp.organization_id = we.organization_id' ||
   ' and   we.wip_entity_id = ' || p_wip_entity_id  ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'OSFM PARAMETER SETUP',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

   sqltxt :=
   ' select  a.from_seq_num,' ||
   '         a.from_operation_code,' ||
   '         a.from_op_seq_id,' ||
   ' 	a.to_seq_num,' ||
   '         a.to_operation_code,' ||
   ' 	a.to_op_seq_id,' ||
   ' 	decode(a.transition_type,1, ''PRIMARY'',' ||
   ' 				    ''ALTERNATE'') transition_type' ||
   ' from    bom_operation_networks_v a, wip_discrete_jobs wj' ||
   ' where   wj.wip_entity_id = ' ||  p_wip_entity_id  ||
   ' and     wj.common_routing_sequence_id = a.routing_sequence_id' ||
   ' order by a.transition_type, a.row_id' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'ROUTING NETWORK',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

   sqltxt :=
   ' select	tm.transaction_id,' ||
   ' 	decode (tm.transaction_type_id, 1, ''Split'',' ||
   ' 	                          2, ''Merge'',' ||
   ' 	                          3, ''Update Assly'',' ||
   ' 	                          4, ''Bonus'',' ||
   ' 	                          5, ''Update Routing'',' ||
   ' 	                          6, ''Update Qty'',' ||
   ' 	                          7, ''Update Lotname'',' ||
   ' 				  tm.transaction_type_id ) transaction_type,' ||
   ' 	tm.transaction_date,' ||
   '    	tm.organization_id,' ||
   ' 	decode (tm.status, 1, ''Pending'',' ||
   ' 	                2, ''Running'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Completed'',' ||
   ' 	                5, ''Warning'',' ||
   ' 			status) status,' ||
'    	decode (tm.costed, 1, ''Pending'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Costed'',' ||
   ' 			tm.costed) costed, ' ||
   ' 	sj.wip_entity_name, ' ||
   ' 	sj.representative_flag,' ||
   ' 	sj.job_start_quantity,' ||
   ' 	sj.operation_seq_num,' ||
   '         decode (sj.intraoperation_step, ' ||
   ' 			1, ''Queue'',' ||
   ' 	                2, ''Run'',' ||
   ' 	                3, ''ToMove'',' ||
   ' 	                5, ''Scrap'',' ||
   ' 			intraoperation_step) intraoperation_step,' ||
   ' 	sj.available_quantity,' ||
   ' 	sj.routing_seq_id,' ||
   '    	sj.primary_item_id,' ||
   ' 	tm.error_message' ||
   '    from	wsm_split_merge_transactions tm,' ||
   ' 	wsm_sm_starting_jobs sj,' ||
   ' 	wip_entities w' ||
   ' where   sj.transaction_id = tm.transaction_id' ||
   ' and     sj.wip_entity_id = w.wip_entity_id' ||
   ' and     w.wip_entity_id = ' || p_wip_entity_id ||
   '    order by 1' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'WIP Lot Transaction : Starting Lots',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
   ' select	tm.transaction_id,' ||
   ' 	decode (tm.transaction_type_id, 1, ''Split'',' ||
   ' 	                          2, ''Merge'',' ||
   ' 	                          3, ''Update Assly'',' ||
   ' 	                          4, ''Bonus'',' ||
   ' 	                          5, ''Update Routing'',' ||
   ' 	                          6, ''Update Qty'',' ||
   ' 	                          7, ''Update Lotname'',' ||
   ' 				  tm.transaction_type_id ) transaction_type,' ||
   ' 	tm.transaction_date,' ||
   ' 	tm.organization_id,' ||
   ' 	decode (tm.status, 1, ''Pending'',' ||
   ' 	                2, ''Running'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Completed'',' ||
   ' 	                5, ''Warning'',' ||
   ' 			tm.status) status,' ||
   ' 	decode (tm.costed, 1, ''Pending'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Costed'',' ||
   ' 			tm.costed) costed, ' ||
   ' 	rj.wip_entity_name,' ||
   ' 	rj.primary_item_id,' ||
   ' 	rj.start_quantity,' ||
   ' 	rj.common_bom_sequence_id,' ||
   ' 	rj.common_routing_sequence_id,' ||
   ' 	rj.alternate_bom_designator,' ||
   ' 	rj.alternate_routing_designator,' ||
   ' 	rj.completion_subinventory,' ||
   ' 	rj.completion_locator_id,' ||
   ' 	rj.starting_operation_seq_num,' ||
   '         decode (rj.starting_intraoperation_step, ' ||
   ' 			1, ''Queue'',' ||
   ' 	                2, ''Run'',' ||
   ' 	                3, ''ToMove'',' ||
   ' 	                5, ''Scrap'',' ||
   ' 			rj.starting_intraoperation_step) starting_intraoperation_step,' ||
   '    	rj.starting_operation_code,' ||
   ' 	rj.starting_std_op_id,' ||
   ' 	tm.error_message' ||
   ' from	wsm_split_merge_transactions tm,' ||
   ' 	wsm_sm_resulting_jobs rj,' ||
   ' 	wip_entities w' ||
   '    where   rj.transaction_id = tm.transaction_id' ||
   ' and     rj.wip_entity_id = w.wip_entity_id' ||
   ' and     rj.transaction_id in (select wssj.transaction_id' ||
   '                               from wsm_sm_starting_jobs wssj' ||
   '                            where wssj.wip_entity_id = ' || p_wip_entity_id  ||
   ' ) order by transaction_id' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'Resulting  Lots',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

   sqltxt :=
   ' select	tm.transaction_id,' ||
   ' 	decode (tm.transaction_type_id, 1, ''Split'',' ||
   ' 	                          2, ''Merge'',' ||
   ' 	                          3, ''Update Assly'',' ||
   ' 	                          4, ''Bonus'',' ||
   ' 	                          5, ''Update Routing'',' ||
   ' 	                          6, ''Update Qty'',' ||
   ' 	                          7, ''Update Lotname'',' ||
   ' 				  tm.transaction_type_id ) transaction_type,' ||
   ' 	tm.transaction_date,' ||
   ' 	tm.organization_id,' ||
   ' 	decode (tm.status, 1, ''Pending'',' ||
   ' 	                2, ''Running'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Completed'',' ||
   ' 	                5, ''Warning'',' ||
   ' 			tm.status) status,' ||
   ' 	decode (tm.costed, 1, ''Pending'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Costed'',' ||
   ' 			tm.costed) costed, ' ||
   ' 	rj.wip_entity_name,' ||
   ' 	rj.primary_item_id,' ||
   ' 	rj.start_quantity,' ||
   ' 	rj.common_bom_sequence_id,' ||
   ' 	rj.common_routing_sequence_id,' ||
   ' 	rj.alternate_bom_designator,' ||
   ' 	rj.alternate_routing_designator,' ||
   ' 	rj.completion_subinventory,' ||
   ' 	rj.completion_locator_id,' ||
   ' 	rj.starting_operation_seq_num,' ||
   '         decode (rj.starting_intraoperation_step, ' ||
   ' 			1, ''Queue'',' ||
   ' 	                2, ''Run'',' ||
   ' 	                3, ''ToMove'',' ||
   ' 	                5, ''Scrap'',' ||
   ' 			rj.starting_intraoperation_step) starting_intraoperation_step,' ||
   ' 	rj.starting_operation_code,' ||
   ' 	rj.starting_std_op_id,' ||
   ' 	tm.error_message' ||
   ' from	wsm_split_merge_transactions tm,' ||
   ' 	wsm_sm_resulting_jobs rj,' ||
   ' 	wip_entities w' ||
   ' where   rj.transaction_id = tm.transaction_id' ||
   ' and     rj.wip_entity_id = w.wip_entity_id' ||
   ' and     w.wip_entity_id = ' || p_wip_entity_id ||
   ' order by transaction_id' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'WIP Lot Transactions : Resulting Lots',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

   sqltxt :=
   ' select	tm.transaction_id,' ||
   ' 	decode (tm.transaction_type_id, 1, ''Split'',' ||
   ' 	                          2, ''Merge'',' ||
   ' 	                          3, ''Update Assly'',' ||
   ' 	                          4, ''Bonus'',' ||
   ' 	                          5, ''Update Routing'',' ||
   ' 	                          6, ''Update Qty'',' ||
   ' 	                          7, ''Update Lotname'',' ||
   ' 				  tm.transaction_type_id ) transaction_type,' ||
   ' 	tm.transaction_date,' ||
   ' 	tm.organization_id,' ||
   ' 	decode (tm.status, 1, ''Pending'',' ||
   ' 	                2, ''Running'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Completed'',' ||
   ' 	                5, ''Warning'',' ||
   ' 			status) status,' ||
   ' 	decode (tm.costed, 1, ''Pending'',' ||
   ' 	                3, ''Error'',' ||
   ' 	                4, ''Costed'',' ||
   ' 			tm.costed) costed, ' ||
   ' 	sj.wip_entity_name, ' ||
   ' 	sj.representative_flag,' ||
   ' 	sj.job_start_quantity,' ||
   ' 	sj.operation_seq_num,' ||
   '         decode (sj.intraoperation_step, ' ||
   ' 			1, ''Queue'',' ||
   ' 	                2, ''Run'',' ||
   ' 	                3, ''ToMove'',' ||
   ' 	                5, ''Scrap'',' ||
   ' 			intraoperation_step) intraoperation_step,' ||
   '    	sj.available_quantity,' ||
   ' 	sj.routing_seq_id,' ||
   ' 	sj.primary_item_id,' ||
   ' 	tm.error_message' ||
   ' from	wsm_split_merge_transactions tm,' ||
   ' 	wsm_sm_starting_jobs sj,' ||
   '    	wip_entities w' ||
   ' where   sj.transaction_id = tm.transaction_id' ||
   ' and     sj.wip_entity_id = w.wip_entity_id' ||
   ' and     sj.transaction_id in (select wsrj.transaction_id' ||
   '                               from wsm_sm_resulting_jobs wsrj' ||
   '                            where wsrj.wip_entity_id = ' || p_wip_entity_id ||
   ' ) order by transaction_id' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'Starting  Lots',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

  exception
    when no_data_found then null ;
 end ;
END disc_lot_job ;

procedure repetitive (p_wip_entity_id IN NUMBER,
                      p_line_id IN NUMBER,
                      p_rep_schedule_id IN NUMBER ) is
row_limit NUMBER;
BEGIN
row_limit := 1000;

sqltxt :=
'select  a.wip_entity_id , '||
'        b.wip_entity_name, '||
'	a.repetitive_schedule_id, '||
'	a.line_id, '||
'        decode(b.entity_type,1, ''1=Discrete Job'', '||
'                             2, ''2=Repetitive Assly'', '||
'                             3, ''3=Closed Discr Job'', '||
'                             4, ''4=Flow Schedule'', '||
'                             5, ''5=Lot Based Job'', '||
'                             b.entity_type) entity_type, '||
'        a.organization_id, '||
'        p.organization_code, '||
'        wri.primary_item_id, '||
'        decode(a.status_type, '||
'			  1,''Unreleased'', '||
'                          3, ''Released'', '||
'                          4, ''Complete'', '||
'                          5, ''Complete NoCharge'', '||
'                          6, ''On Hold'', '||
'                          7, ''Cancelled'', '||
'                          8, ''Pend Bill Load'', '||
'                          9, ''Failed Bill Load'', '||
'                          10, ''Pend Rtg Load'', '||
'                          11, ''Failed Rtg Load'', '||
'                          12, ''Closed'', '||
'                          13, ''Pending- Mass Loaded'', '||
'                          14, ''Pending Close'', '||
'                          15, ''Failed Close'', '||
'                          a.status_type) status_type, '||
'	wri.completion_subinventory, '||
'	wri.completion_locator_id, '||
'	m.primary_uom_code uom_code, '||
'        a.processing_work_days, '||
'        a.daily_production_rate, '||
'	a.quantity_completed, '||
'        decode(wri.wip_supply_type,  1, ''Push'', '||
'                        	2, ''Assembly Pull'', '||
'                        	3, ''Operation Pull'', '||
'                        	4, ''Bulk'', '||
'                        	5, ''Supplier'', '||
'                        	6, ''Phantom'', '||
'                        	7, ''Based on Bill'', '||
'				wri.wip_supply_type) wip_supply_type, '||
'	wri.class_code, '||
'	decode(wri.overcompletion_tolerance_type, '||
'		1, ''Percent'', '||
'		2, ''Amount'') Tol_Type, '||
'	wri.overcompletion_tolerance_value Tol_Value, '||
'	a.date_released, '||
'	a.creation_date, '||
'	a.common_bom_sequence_id,  '||
'	a.common_routing_sequence_id, '||
'	a.first_unit_start_date, '||
'        a.first_unit_completion_date, '||
'        a.last_unit_start_date, '||
'        a.last_unit_completion_date, '||
'	a.bom_revision, '||
'	a.routing_revision, '||
'	nvl(a.alternate_bom_designator, ''PRIMARY'') alternate_bom_designator, '||
'	nvl(a.alternate_routing_designator, ''PRIMARY'') alternate_routing_designator '||
'from  wip_repetitive_schedules a , wip_repetitive_items wri, wip_entities b, mtl_system_items m , mtl_parameters p '||
'where b.wip_entity_id = a.wip_entity_id '||
'and   wri.wip_entity_id  = a.wip_entity_id  '||
'and   b.organization_id = a.organization_id '||
'and   m.inventory_item_id = b.primary_item_id '||
'and   m.organization_id = a.organization_id   '||
'and   a.organization_id = p.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt := sqltxt ||' and b.wip_entity_id = '|| p_wip_entity_id;
   end if;

   if p_line_id is not null then
      sqltxt := sqltxt ||' and wri.line_id = '|| p_line_id ;
   end if;

   if p_rep_schedule_id is not null then
      sqltxt := sqltxt ||' and a.repetitive_schedule_id = '|| p_rep_schedule_id;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP HEADER ( WIP REPETITIVE SCHEDULES, WIP REPETITIVE ITEMS, WIP ENTITIES )',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;


sqltxt :=
'select  a.operation_seq_num, ' ||
'	a.operation_sequence_id, ' ||
'	a.standard_operation_id, ' ||
'        bso.operation_code , ' ||
'	a.department_id, ' ||
'        c.department_code, ' ||
'	a.description, ' ||
'        a.first_unit_start_date, ' ||
'        a.first_unit_completion_date, ' ||
'        a.last_unit_start_date, ' ||
'        a.last_unit_completion_date, ' ||
'	a.quantity_in_queue , ' ||
'	a.quantity_running  , ' ||
'	a.quantity_waiting_to_move , ' ||
'	a.quantity_rejected , ' ||
'	a.quantity_scrapped , ' ||
'	a.quantity_completed , ' ||
'        a.previous_operation_seq_num, ' ||
'	a.next_operation_seq_num, ' ||
'	a.count_point_type, ' ||
'  	decode( a.backflush_flag, 1, ''Yes'', ' ||
'				  2, ''No'') backflush_flag, ' ||
'	a.minimum_transfer_quantity, ' ||
'	a.date_last_moved, ' ||
'	a.creation_date ' ||
'from    wip_operations a, wip_entities b, bom_departments c, bom_standard_operations bso ' ||
'where   a.wip_entity_id = b.wip_entity_id ' ||
'and     a.organization_id = b.organization_id ' ||
'and     a.department_id = c.department_id ' ||
'and     a.organization_id = c.organization_id ' ||
'and     a.standard_operation_id = bso.standard_operation_id(+) ' ||
'and     a.organization_id = bso.organization_id(+) ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and a.wip_entity_id = '|| p_wip_entity_id;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and a.repetitive_schedule_id = '|| p_rep_schedule_id;
      sqltxt :=sqltxt||' order by 1 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP OPERATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.wip_entity_id, '||
'	a.inventory_item_id, '||
'        substrb(m.concatenated_segments, 1, 30) item_name, '||
'	a.organization_id, '||
'	a.operation_seq_num, '||
'	a.component_sequence_id, '||
'	a.department_id, '||
'        decode(a.wip_supply_type,  1, ''Push'', '||
'                        	2, ''Assembly Pull'', '||
'                        	3, ''Operation Pull'', '||
'                        	4, ''Bulk'', '||
'                        	5, ''Supplier'', '||
'                        	6, ''Phantom'', '||
'                        	7, ''Based on Bill'', '||
'				a.wip_supply_type) wip_supply_type, '||
'	a.required_quantity, '||
'	a.quantity_issued, '||
'	a.quantity_per_assembly, '||
'	a.supply_subinventory, '||
'	a.supply_locator_id, '||
'	a.quantity_allocated, '||
'	a.quantity_backordered, '||
'	a.quantity_relieved, '||
'	a.creation_date '||
'from    wip_requirement_operations a, wip_entities b, mtl_system_items_kfv m '||
'where   b.wip_entity_id = a.wip_entity_id '||
'and     b.organization_id = a.organization_id '||
'and     a.inventory_item_id = m.inventory_item_id '||
'and     a.organization_id = m.organization_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and a.wip_entity_id = '|| p_wip_entity_id;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and a.repetitive_schedule_id = '|| p_rep_schedule_id;
      sqltxt :=sqltxt||' order by operation_seq_num,inventory_item_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP REQUIREMENT OPERATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.operation_seq_num, '||
'        a.resource_seq_num, '||
' 	a.resource_id, '||
'        a.autocharge_type, '||
'        c.resource_code, '||
'	a.uom_code, '||
'	decode (a.basis_type, 1, ''Item'', '||
'			      2, ''Lot'', '||
'			      3, ''Res Units'', '||
'			      4, ''Res Value'', '||
'			      5, ''Tot Value'', '||
'			      6, ''Activity'', '||
'			      a.BASIS_TYPE)  basis_type, '||
'        decode(a.scheduled_flag, 1, ''Yes'', '||
'                                 2, ''No'', '||
'                                 3, ''Prior'', '||
'                                 4, ''Next'', '||
'                                 a.scheduled_flag) scheduled_flag, '||
'	a.usage_rate_or_amount , '||
'        a.start_date, '||
'        a.completion_date, '||
'        a.applied_resource_units, '||
'        a.applied_resource_value, '||
'	a.creation_date '||
'from    wip_operation_resources a,  bom_resources c '||
'where   a.resource_id = c.resource_id '||
'and     a.organization_id = c.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and a.wip_entity_id = '|| p_wip_entity_id;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and a.repetitive_schedule_id = '|| p_rep_schedule_id;
      sqltxt :=sqltxt||' order by 1,2';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP OPERATION RESOURCES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.operation_seq_num, '||
'        a.resource_seq_num, '||
'        c.resource_code, '||
'	a.organization_id, '||
' 	a.repetitive_schedule_id, '||
'	a.start_date, '||
'	a.completion_date, '||
'	a.assigned_units, '||
'	a.creation_date '||
'from    wip_operation_resource_usage a, wip_operation_resources b, bom_resources c '||
'where   a.wip_entity_id = b.wip_entity_id '||
'and     a.operation_seq_num = b.operation_seq_num '||
'and     nvl(a.repetitive_schedule_id,0) = nvl(b.repetitive_schedule_id,0) '||
'and     a.resource_seq_num = b.resource_seq_num '||
'and     b.resource_id = c.resource_id '||
'and     b.organization_id = c.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and a.wip_entity_id = '|| p_wip_entity_id;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and a.repetitive_schedule_id = '|| p_rep_schedule_id;
      sqltxt :=sqltxt||' order by 1,2 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP OPERATION RESOURCE USAGES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select acct_period_id, '||
'       decode(class_type,1,''Standard Discrete'', '||
'                         2,''Repetitive Assembly'', '||
'                         3,''Asset non-standard'', '||
'                         4,''Expense non-standard'', '||
'                         5,''Standard Lot Based'', '||
'                         6,''EAM'', '||
'                         7,''Expense non-standard Lot Based'', '||
'			 class_type) class_type, '||
'       tl_resource_in, '||
'       tl_overhead_in, '||
'       tl_outside_processing_in, '||
'       pl_material_in, '||
'       pl_material_overhead_in, '||
'       pl_resource_in, '||
'       pl_overhead_in, '||
'       pl_outside_processing_in, '||
'       tl_material_out, '||
'       tl_material_overhead_out, '||
'       tl_resource_out, '||
'       tl_overhead_out, '||
'       tl_outside_processing_out, '||
'       pl_material_out, '||
'       pl_material_overhead_out, '||
'       pl_resource_out, '||
'       pl_overhead_out, '||
'       pl_outside_processing_out, '||
'       tl_scrap_in, '||
'       tl_scrap_out, '||
'       tl_scrap_var, '||
'       creation_date, '||
'       last_update_date '||
'from   wip_period_balances ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and repetitive_schedule_id = '|| p_rep_schedule_id;
      sqltxt :=sqltxt||' order by creation_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP PERIOD BALANCES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wmt.transaction_id, '||
'       wmt.group_id, '||
'       wmt.fm_operation_code, '||
'       wmt.fm_operation_seq_num, '||
'       decode (wmt.fm_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			wmt.fm_intraoperation_step_type) fm_intraoperation_step_type, '||
'       wmt.to_operation_code, '||
'       wmt.to_operation_seq_num, '||
'       decode (wmt.to_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			wmt.to_intraoperation_step_type) to_intraoperation_step_type, '||
'       wmt.transaction_quantity, '||
'       wmta.transaction_quantity Allocation_Txn_Qty, ' ||
'       wmt.transaction_uom, '||
'       wmt.primary_quantity, '||
'       wmta.primary_quantity Allocation_Primary_Qty, ' ||
'       wmt.primary_uom, '||
'       wmt.source_code, '||
'       wmt.source_line_id,  '||
'       wmt.organization_id, '||
'       wmt.primary_item_id, '||
'       wmt.transaction_date, '||
'	wmt.creation_date, '||
'       wmt.acct_period_id, '||
'       wmt.scrap_account_id '||
' from  wip_move_transactions wmt , '||
'       wip_move_txn_allocations wmta '||
'where  wmt.transaction_id = wmta.transaction_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wmt.wip_entity_id = '|| p_wip_entity_id;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and wmta.repetitive_schedule_id = '|| p_rep_schedule_id;
      sqltxt :=sqltxt||' order by 1 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP MOVE TRANSACTIONS AND ALLOCATION',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wmti.transaction_id, '||
'       group_id, '||
'       source_code,  '||
'       source_line_id, '||
'       decode(process_phase, '||
'			1, ''Move Valdn'', '||
'			2, ''Move Proc'', '||
'			3, ''BF Setup'', '||
'			process_phase) process_phase_meaning, '||
'       decode(process_status, '||
'			1, ''Pending'', '||
'			2, ''Running'', '||
'			3, ''Error'', '||
'			4, ''Completed'', '||
'			5, ''Warning'', '||
'			process_status) process_status_meaning, '||
'       decode(transaction_type, '||
'			1, ''Move'', '||
'			2, ''Complete'', '||
'			3, ''Return'', '||
'			transaction_type) transaction_type_meaning, '||
'       repetitive_schedule_id, '||
'       fm_operation_seq_num, '||
'       fm_operation_code, '||
'       decode (fm_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			fm_intraoperation_step_type) fm_intraoperation_step_type, '||
'       to_operation_seq_num, '||
'       to_operation_code, '||
'       decode (to_intraoperation_step_type,  '||
'			1, ''Queue'', '||
'	                2, ''Run'', '||
'	                3, ''ToMove'', '||
'	                5, ''Scrap'', '||
'			to_intraoperation_step_type) to_intraoperation_step_type, '||
'       transaction_quantity, '||
'       transaction_uom, '||
'       primary_quantity, '||
'       primary_uom, '||
'       organization_id, '||
'       primary_item_id, '||
'       transaction_date, '||
'	wmti.creation_date, '||
'       acct_period_id, '||
'       scrap_account_id, '||
'       overcompletion_transaction_qty, '||
'       overcompletion_primary_qty, '||
'       overcompletion_transaction_id, '||
'       error_column, '||
'       error_message '||
'from   wip_move_txn_interface wmti, '||
'       wip_txn_interface_errors wtie  '||
'where  wmti.transaction_id = wtie.transaction_id (+) ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by 1 ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP MOVE TXN INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

/*
sqltxt :=
'select allocation_id, '||
'       organization_id, '||
'       demand_source_header_id, '||
'       demand_source_line, 	'||
'       user_line_num, '||
'       demand_source_delivery, '||
'       user_delivery, 	'||
'       quantity_allocated, '||
'       quantity_completed, '||
'       demand_class, 	'||
'       creation_date '||
'from   wip_so_allocations ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by allocation_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP SO ALLOCATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

*/

sqltxt :=
'select wcti.transaction_id,  '||
'       wcti.creation_date, '||
'       wcti.last_update_date, '||
'       wcti.request_id, '||
'       source_code, '||
'       source_line_id, '||
'       decode(process_phase, '||
'		1, ''Res Valdn'', '||
'		2, ''Res Processing'', '||
'		3, ''Job Close'', '||
'		4, ''Prd Close'', '||
'		process_phase) process_phase_meaning, '||
'       decode(process_status, '||
'			1, ''Pending'', '||
'			2, ''Running'', '||
'			3, ''Error'', '||
'			4, ''Completed'', '||
'			5, ''Warning'', '||
'			process_status) process_status_meaning, '||
'       decode(transaction_type, '||
'		1, ''Resource'', '||
'		2, ''Overhead'', '||
'		3, ''OSP'', '||
'		4, ''Cost Update'', '||
'		5, ''PrdClose Var'', '||
'		6, ''JobClose Var'', '||
'		transaction_type) transaction_type_meaning, '||
'       organization_id, '||
'       organization_code, '||
'       primary_item_id, '||
'       transaction_date, '||
'       operation_seq_num, '||
'       resource_seq_num, '||
'       acct_period_id, '||
'       resource_id, '||
'       decode(resource_type, '||
'		1, ''Machine'', '||
'		2, ''Person'', '||
'		3, ''Space'', '||
'		4, ''Misc'', '||
'		5, ''Amount'', '||
'		resource_type) resource_type, '||
'       transaction_quantity, '||
'       actual_resource_rate, '||
'       transaction_uom, '||
'       decode(basis_type, '||
'		1, ''Item'', '||
'		2, ''Lot'', '||
'		3, ''Res Units'', '||
'		4, ''Res Value'', '||
'		5, ''Tot Value'', '||
'		6, ''Activity'') basis_type,  '||
'       move_transaction_id, '||
'       completion_transaction_id, '||
'       error_column, '||
'       error_message '||
'from   wip_cost_txn_interface wcti, '||
'       wip_txn_interface_errors wtie '||
'where  wcti.transaction_id = wtie.transaction_id (+) ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id ;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and repetitive_schedule_id = '|| p_rep_schedule_id ;
      sqltxt :=sqltxt||' order by transaction_id';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP COST TXN INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wt.transaction_id,  '||
'       wt.creation_date, '||
'       wt.last_update_date, '||
'       wt.request_id, '||
'       wt.source_code, '||
'       wt.source_line_id, '||
'       wt.group_id, '||
'       decode(wt.transaction_type, '||
'		1, ''Resource'', '||
'		2, ''Overhead'', '||
'		3, ''OSP'', '||
'		4, ''Cost Update'', '||
'		5, ''PrdClose Var'', '||
'		6, ''JobClose Var'', '||
'		wt.transaction_type) transaction_type_meaning, '||
'       wt.organization_id, '||
'       wt.primary_item_id, '||
'       wt.transaction_date, '||
'       wt.operation_seq_num, '||
'       wt.resource_seq_num, '||
'       wt.acct_period_id, '||
'       wt.resource_id, '||
'       wt.transaction_quantity, '||
'       wta.transaction_quantity Allocation_Txn_Qty, ' ||
'       wt.actual_resource_rate, '||
'       wt.standard_resource_rate, '||
'       wt.transaction_uom, '||
'       wt.move_transaction_id, '||
'       wt.completion_transaction_id '||
'from   wip_transactions wt, '||
'       wip_txn_allocations wta '||
'where  wt.transaction_id = wta.transaction_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wt.wip_entity_id = '|| p_wip_entity_id ;
   end if;
   if p_rep_schedule_id is not null then
      sqltxt :=sqltxt||' and wta.repetitive_schedule_id = '|| p_rep_schedule_id ;
      sqltxt :=sqltxt||' order by transaction_id';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP TRANSACTIONS AND ALLOCATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_interface_id, '||
'        transaction_header_id, '||
'	source_code, '||
'	source_line_id, '||
'        source_header_id, '||
'	process_flag, '||
'	transaction_mode, '||
'	lock_flag, '||
'	request_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	transaction_uom, '||
'	transaction_date, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_source_id, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Plan Xfr'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	transaction_type_id, '||
'	operation_seq_num, '||
'	repetitive_line_id, '||
'	transfer_organization, '||
'	transfer_subinventory, '||
'	transfer_locator, '||
'        overcompletion_transaction_qty, '||
'        overcompletion_primary_qty, '||
'        overcompletion_transaction_id, '||
'	error_code, '||
'	substr(error_explanation,1,100) error_explanation '||
'from    mtl_transactions_Interface mti '||
'where   mti.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by transaction_interface_id, transaction_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_interface_id, '||
'	source_code, '||
'	source_line_id, '||
'	request_id, '||
'	lot_number, '||
'	lot_expiration_date, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	serial_transaction_temp_id, '||
'	process_flag,  '||
'	error_code '||
'from    mtl_transaction_lots_interface mtli '||
'where   mtli.transaction_interface_id in '||
'		(select transaction_interface_id '||
'		 from mtl_transactions_Interface mti '||
'	 	 where   mti.transaction_source_type_id = 5 ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by lot_expiration_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select '||
'	transaction_interface_id, '||
'	source_code, '||
'	source_line_id, '||
'	request_id, '||
'	vendor_serial_number, '||
'	vendor_lot_number, '||
'	fm_serial_number, '||
'	to_serial_number, '||
'	error_code, '||
'	process_flag, '||
'	parent_serial_number '||
'from    mtl_serial_numbers_interface msni '||
'where   msni.transaction_interface_id in '||
'		(select transaction_interface_id '||
'		 from mtl_transactions_Interface mti '||
'	 	 where   mti.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by fm_serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSNI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_temp_id, '||
'        transaction_header_id, '||
'	source_code, '||
'	source_line_id, '||
'	transaction_mode, '||
'	lock_flag, '||
'	transaction_date, '||
'	transaction_type_id, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Issue'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_source_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	primary_quantity, '||
'	trx_source_line_id, '||
'	trx_source_delivery_id, '||
'        overcompletion_transaction_qty, '||
'        overcompletion_primary_qty, '||
'        overcompletion_transaction_id, '||
'	move_transaction_id, '||
'	completion_transaction_id, '||
'	source_code, '||
'	source_line_id, '||
'	transfer_organization, '||
'	transfer_subinventory, '||
'	transfer_to_location, '||
'	move_order_line_id, '||
'	reservation_id, '||
'	creation_date, '||
'	last_update_date, '||
'	error_code '||
'from    mtl_material_transactions_temp '||
'where   transaction_source_type_id = 5 ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and transaction_source_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_temp_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MMTT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_temp_id, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	lot_number, '||
'	lot_expiration_date, '||
'	serial_transaction_temp_id, '||
'	group_header_id, '||
'	put_away_rule_id, '||
'	pick_rule_id, '||
'	request_id, '||
'	creation_date, '||
'	error_code '||
'from    mtl_transaction_lots_temp mtlt '||
'where   mtlt.transaction_temp_id in '||
'		(select mmtt.transaction_temp_id '||
'		 from mtl_material_transactions_temp mmtt '||
'	 	 where   mmtt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmtt.transaction_source_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by transaction_temp_id, lot_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_temp_id, '||
'	vendor_serial_number, '||
'	vendor_lot_number, '||
'	fm_serial_number, '||
'	to_serial_number, '||
'	serial_prefix, '||
'	group_header_id, '||
'	parent_serial_number, '||
'	end_item_unit_number, '||
'	request_id, '||
'	creation_date, '||
'	error_code '||
'from    mtl_serial_numbers_temp msnt '||
'where   msnt.transaction_temp_id  in '||
'		(select  mmtt.transaction_temp_id '||
'		 from    mtl_material_transactions_temp mmtt '||
'	 	 where   mmtt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmtt.transaction_source_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by transaction_temp_id, fm_serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSNT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select DISTINCT '||
' TRL.LINE_ID                         MOVE_LINE_ID, '||
' TRL.REQUEST_NUMBER                  MOVE_NUMBER, '||
' TRL.HEADER_ID                       MV_HDR_ID, '||
' TRL.LINE_NUMBER                     MV_LINE_NUM, '||
' decode(TRL.LINE_STATUS, '||
'                    1, ''Incomplete'', '||
'                    2, ''Pend Aprvl'', '||
'                    3, ''Approved'', '||
'                    4, ''Not Apprvd'', '||
'                    5, ''Closed'', '||
'                    6, ''Canceled'', '||
'                    7, ''Pre Apprvd'', '||
'                    8, ''Part Aprvd'') MV_LINE_STAT, '||
' TRL.INVENTORY_ITEM_ID, '||
' TRL.ORGANIZATION_ID, '||
' TRL.REVISION, '||
' TRL.QUANTITY                        QTY, '||
' TRL.PRIMARY_QUANTITY                PRM_QTY,            '||
' TRL.QUANTITY_DELIVERED              DLVD_QTY, '||
' TRL.QUANTITY_DETAILED               DTLD_QTY, '||
' TRL.MOVE_ORDER_TYPE_NAME            MOVE_TYPE_NAME, '||
' decode(TRL.TRANSACTION_SOURCE_TYPE_ID,2,''Sales Order'', '||
'                                       5,''Job or Schedule'', '||
'                                       13,''Inventory'', '||
'					TRL.TRANSACTION_SOURCE_TYPE_ID) txn_source_meaning,   '||
' TRL.TRANSACTION_TYPE_NAME           transaction_type_meaning,        '||
' decode(TRL.TRANSACTION_ACTION_ID, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Plan Xfr'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		trl.transaction_action_id) txn_action_meaning, '||
' TRL.FROM_SUBINVENTORY_CODE          FROM_SUB, '||
' TRL.FROM_LOCATOR_ID                 FROM_LOC_ID,  '||
' TRL.TO_SUBINVENTORY_CODE            TO_SUB, '||
' TRL.TO_LOCATOR_ID                   TO_LOC_ID,           '||
' TRL.LOT_NUMBER                      LOT_NUM, '||
' TRL.TRANSACTION_HEADER_ID           TRNS_HEAD_ID, '||
' TRL.CREATION_DATE '||
'from MTL_TXN_REQUEST_LINES_V   TRL '||
'WHERE trl.move_order_type <> 6 '||
'AND   (trl.txn_source_id, trl.txn_source_line_id) in  '||
'	(select  wdj.wip_entity_id, wro.operation_seq_num  '||
'	 from wip_discrete_jobs wdj,  '||
'	      wip_entities we,  '||
'		wip_lines wl,  '||
'		wip_requirement_operations wro  '||
'	 where wdj.wip_entity_id = we.wip_entity_id  '||
'	 and  wdj.organization_id = we.organization_id  '||
'	 and wdj.wip_entity_id = wro.wip_entity_id  '||
'         and wdj.organization_id = wro.organization_id  '||
'	 and wdj.line_id = wl.line_id(+)  '||
'         and wdj.organization_id = wl.organization_id(+)  ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and we.wip_entity_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by request_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTL_TXN_REQUEST_LINES_V TRANSACTIONS  - MOVE ORDERS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  mmt.transaction_id, '||
'	mmt.transaction_date, '||
'	mmt.transaction_type_id, '||
'	decode(mmt.transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Issue'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		mmt.transaction_action_id) txn_action_meaning, '||
'	decode(mmt.transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		mmt.transaction_source_type_id) txn_source_meaning, '||
'	mmt.transaction_source_id, '||
'	mmt.inventory_item_id, '||
'	mmt.organization_id, '||
'	mmt.subinventory_code, '||
'	mmt.locator_id, '||
'	mmt.revision, '||
'	mmt.transaction_quantity, '||
'       mmta.transaction_quantity  Allocation_Txn_Qty, ' ||
'	mmt.transaction_uom, '||
'	mmt.primary_quantity, '||
'       mmta.primary_quantity  Allocation_Primary_Qty, ' ||
'	mmt.trx_source_line_id, '||
'	mmt.trx_source_delivery_id, '||
'	mmt.move_transaction_id, '||
'	mmt.completion_transaction_id, '||
'	mmt.source_code, '||
'	mmt.source_line_id, '||
'	mmt.transfer_organization_id, '||
'	mmt.transfer_subinventory, '||
'	mmt.transfer_locator_id, '||
'	mmt.move_order_line_id, '||
'	mmt.reservation_id, '||
'	mmt.creation_date, '||
'	mmt.last_update_date, '||
'	mmt.error_code '||
' from  mtl_material_transactions mmt, '||
'       mtl_material_txn_allocations mmta ' ||
' where mmt.transaction_id = mmta.transaction_id ' ||
' and   mmt.transaction_source_type_id = 5 ' ;

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id = '|| p_wip_entity_id  ||
                       ' and mmta.repetitive_schedule_id = ' || p_rep_schedule_id ;
      sqltxt :=sqltxt||' order by transaction_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MMT TRANSACTIONS AND ALLOCATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	inventory_item_id, '||
'	lot_number, '||
'	organization_id, '||
'	transaction_id, '||
'	transaction_date, '||
'	creation_date, '||
'	transaction_source_id, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	serial_transaction_id '||
'from    mtl_transaction_lot_numbers mtln '||
'where   mtln.transaction_id in '||
'		(select mmt.transaction_id '||
'		 from mtl_material_transactions mmt '||
'	 	 where   mmt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by inventory_item_id, lot_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

/*
sqltxt :=
'select	 '||
'	inventory_item_id, '||
'	serial_number, '||
'	decode(current_status, '||
'		1, ''Defined but not used'', '||
'		3, ''Resides in stores'', '||
'		4, ''Issued out of stores'', '||
'		5, ''Resides in intrasit'', '||
'		current_status) current_status_meaning, '||
'	revision, '||
'	lot_number, '||
'	parent_item_id, '||
'	last_transaction_id, '||
'	parent_serial_number, '||
'	end_item_unit_number, '||
'	group_mark_id, '||
'	line_mark_id, '||
'	lot_line_mark_id, '||
'	gen_object_id, '||
'	creation_date '||
'from    mtl_serial_numbers msn ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where msn.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by inventory_item_id, serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

*/

sqltxt :=
' select mmt.inventory_item_id, ' ||
'        mmt.transaction_id,' ||
'        mmt.transaction_date,' ||
'        mmt.transaction_source_id,' ||
'        mut.serial_number,' ||
'        mmt.subinventory_code,' ||
'        mmt.locator_id , ' ||
'        mmt.creation_date' ||
' from   mtl_material_transactions mmt,' ||
'        mtl_material_txn_allocations mmta, ' ||
'        mtl_unit_transactions mut' ||
' where  mmt.transaction_id = mmta.transaction_id ' ||
' and    mmt.transaction_action_id in (1, 27, 33, 34, 30, 31, 32)' ||
' and    mmt.transaction_source_type_id = 5' ||
' and    mut.transaction_id = mmt.transaction_id' ;

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id  = '|| p_wip_entity_id  ||
               ' and     mmta.repetitive_schedule_id = ' || p_rep_schedule_id ;
      sqltxt :=sqltxt||' order by mmt.inventory_item_id, mut.serial_number ';
   end if ;


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

/*
sqltxt :=
'select	header_id, '||
'	source_id, '||
'	source_code, '||
'	completion_status, '||
'	creation_date, '||
'	last_update_date, '||
'	inventory_item_id, '||
'	organization_id, '||
'	primary_quantity, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	transaction_date, '||
'	transaction_action_id, '||
'	transaction_source_id, '||
'	transaction_source_type_id, '||
'	transaction_type_id, '||
'	transaction_mode, '||
'	acct_period_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	schedule_id, '||
'	repetitive_line_id, '||
'	operation_seq_num, '||
'	cost_group_id, '||
'	lock_flag, '||
'	error_code, '||
'	final_completion_flag, '||
'	completion_transaction_id '||
'from    wip_lpn_completions ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by header_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP LPN COMPLETIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

*/


sqltxt :=
'select  '||
'     RES.RESERVATION_ID            RESERV_ID, '||
'     decode(RES.SHIP_READY_FLAG,1,''1=Released'',2,''2=Submitted'',to_char(RES.SHIP_READY_FLAG)) '||
'                                   SHIP_READY,  '||
'     RES.DEMAND_SOURCE_HEADER_ID   DS_HEADER_ID, '||
'     RES.DEMAND_SOURCE_LINE_ID     DS_LINE_ID, '||
'     RES.DEMAND_SOURCE_DELIVERY    DS_DELIVERY, '||
'     RES.INVENTORY_ITEM_ID         ITEM_ID, '||
'     RES.RESERVATION_QUANTITY      RES_QTY, '||
'     RES.RESERVATION_UOM_CODE      RUOM, '||
'     RES.PRIMARY_RESERVATION_QUANTITY PRES_QTY, '||
'     RES.PRIMARY_UOM_CODE          PUOM, '||
'     RES.DETAILED_QUANTITY         DET_QTY, '||
'     RES.REQUIREMENT_DATE          REQUIRD_DATE, '||
'     RES.DEMAND_SOURCE_TYPE_ID     DS_TYPE, '||
'     RES.ORGANIZATION_ID           ORG_ID, '||
'     RES.SUBINVENTORY_CODE         SUBINV, '||
'     RES.LOT_NUMBER                LOT, '||
'     RES.REVISION                  REV, '||
'     RES.LOCATOR_ID                LOC_ID, '||
'     RES.SERIAL_NUMBER             SERIAL_NUM, '||
'     decode(RES.SUPPLY_SOURCE_TYPE_ID,1,''1=PO'', '||
'                                      2,''2=OE'', '||
'                                      5,''5=WIP DJ'', '||
'                                      7,''7=INT_REQ'', '||
'                                      8,''8=INT_OE'', '||
'                                      13,''13=INV'', '||
'                                      17,''17=REQ'', '||
'					RES.SUPPLY_SOURCE_TYPE_ID) '||
'                                   SS_TYPE_ID, '||
'     We.WIP_ENTITY_ID             WIP_ID, '||
'     decode(JOB.STATUS_TYPE, 1, ''Unreleased'',            '||
'                             2, ''Simulated'',            '||
'                             3, ''Released'',            '||
'                             4, ''Complete'',            '||
'                             5, ''Complete-NoCharges'',            '||
'                             6, ''OnHold'',            '||
'                             7, ''Canceled'',            '||
'                             8, ''Pending Bill Load'',            '||
'                             9, ''Failed Bill Load'',            '||
'                            10, ''Pending Routing Load'',            '||
'                            11, ''Failed Routing Load'',            '||
'                            12, ''Closed'',            '||
'                            13, ''Pending-Mass Load'',            '||
'                            14, ''Pending Close'',            '||
'                            15, ''Failed Close'',  '||
'                            16, ''Pending Scheduling'',  '||
'                            17, ''Draft'',  '||
'                            JOB.STATUS_TYPE ) JOB_STATUS, '||
'     JOB.SOURCE_CODE		   SOURCE_CODE, '||
'     RES.SUPPLY_SOURCE_HEADER_ID   SS_HEADER_ID,       '||
'     RES.SUPPLY_SOURCE_LINE_DETAIL SS_SOURCE_LINE_DET, '||
'     RES.SUPPLY_SOURCE_LINE_ID     SS_SOURCE_LINE,       '||
'     RES.PARTIAL_QUANTITIES_ALLOWED ALLOW_PART, '||
'     to_char(RES.CREATION_DATE, ''DD-MON HH24:MI:SS'') CREATE_DATE, '||
'     to_char(RES.LAST_UPDATE_DATE, ''DD-MON HH24:MI:SS'') UPD_DATE '||
'from '||
'     MTL_RESERVATIONS              RES, '||
'     WIP_ENTITIES                  WE, '||
'     WIP_DISCRETE_JOBS             JOB '||
'where RES.SUPPLY_SOURCE_HEADER_ID   = We.WIP_ENTITY_ID '||
'and  We.WIP_ENTITY_ID             = JOB.WIP_ENTITY_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and we.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by reservation_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTL RESERVATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'Select '||
'RQI.INTERFACE_SOURCE_LINE_ID           wip_entity_id, '||
'RQI.INTERFACE_SOURCE_CODE              SRC_CODE, '||
'RQI.AUTHORIZATION_STATUS               AUTH_STATUS,    '||
'RQI.DELIVER_TO_LOCATION_ID             DELIV_LOC, '||
'RQI.PREPARER_ID                        PREPARER, '||
'RQI.DESTINATION_ORGANIZATION_ID        DEST_ORG_ID, '||
'RQI.DESTINATION_TYPE_CODE              DEST_TYPE, '||
'RQI.SOURCE_TYPE_CODE                   SRC_TYPE_CODE, '||
'RQI.ITEM_ID                            ITEM_ID, '||
'RQI.NEED_BY_DATE                       NEED_BY,                                '||
'RQI.QUANTITY                           QTY,                   '||
'RQI.UNIT_PRICE                         PRICE '||
'from  '||
' PO_REQUISITIONS_INTERFACE_ALL   RQI '||
'where RQI.INTERFACE_SOURCE_CODE =''WIP'' ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rqi.interface_source_line_id = '|| p_wip_entity_id ;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO REQUISITION INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select '||
'  POE.INTERFACE_TRANSACTION_ID     INTF_TRANS_ID,    '||
'  POE.COLUMN_NAME                  COLUMN_NAME,                   '||
'  POE.ERROR_MESSAGE                ERROR,   '||
'  POE.INTERFACE_TYPE               INTF_TYPE,          '||
'  POE.REQUEST_ID                   REQUEST_ID, '||
'  POE.TABLE_NAME                   TABLE_NAME '||
'from   '||
'  PO_INTERFACE_ERRORS         POE, '||
'  PO_REQUISITIONS_INTERFACE_ALL   RQI '||
'where RQI.TRANSACTION_ID           = POE.INTERFACE_TRANSACTION_ID ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rqi.interface_source_line_id = '|| p_wip_entity_id ;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO INTERFACE ERRORS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select   '||
'  RQH.REQUISITION_HEADER_ID               REQ_HEADER_ID , '||
'  RQH.SEGMENT1                            REQ_NUMBER, '||
'  RQL.REQUISITION_LINE_ID          	  REQ_LINE_ID,               '||
'  RQL.LINE_NUM                            REQ_LINE, '||
'  RQH.INTERFACE_SOURCE_LINE_ID            INT_SRC_LINE_ID, '||
'  RQL.WIP_ENTITY_ID		          WIP_ENTITY_ID, '||
'  RQH.AUTHORIZATION_STATUS                AUTH_STATUS,                '||
'  RQH.ENABLED_FLAG                        ENABLED,   '||
'  RQH.INTERFACE_SOURCE_CODE               SRC_CODE, '||
'  RQH.SUMMARY_FLAG                        SUMMARY, '||
'  RQH.TRANSFERRED_TO_OE_FLAG              XFR_OE_FLAG, '||
'  RQH.TYPE_LOOKUP_CODE                    REQ_TYPE, '||
'  RQH.WF_ITEM_TYPE                        ITEM_TYPE, '||
'  RQH.WF_ITEM_KEY                         ITEM_KEY, '||
'  RQL.ITEM_ID                      ITEM_ID,     '||
'  RQL.UNIT_MEAS_LOOKUP_CODE        UOM,  '||
'  RQL.UNIT_PRICE                   PRICE, '||
'  RQL.QUANTITY                     QTY,            '||
'  RQL.QUANTITY_CANCELLED           QTY_CNC,           '||
'  RQL.QUANTITY_DELIVERED           QTY_DLV,                   '||
'  RQL.CANCEL_FLAG                  CANC,         '||
'  RQL.DESTINATION_CONTEXT          DEST_TYPE,      '||
'  RQL.DESTINATION_ORGANIZATION_ID  DEST_ORG, '||
'  RQL.ENCUMBERED_FLAG              ENC_FLAG ,                  '||
'  RQL.LINE_TYPE_ID                 LINE_TYPE_ID, '||
'  RQL.NEED_BY_DATE                 NEED_BY, '||
'  RQL.ON_RFQ_FLAG                  RFQ ,                                           '||
'  RQL.SOURCE_TYPE_CODE             SRC_TYPE_CODE, '||
'  RQL.SUGGESTED_BUYER_ID           BUYER_ID              '||
'from  '||
' PO_REQUISITION_HEADERS_ALL      RQH, '||
' PO_REQUISITION_LINES_ALL        RQL '||
'where  '||
' RQH.REQUISITION_HEADER_ID = RQL.REQUISITION_HEADER_ID ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rql.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by RQH.REQUISITION_HEADER_ID, RQL.REQUISITION_LINE_ID, RQL.ITEM_ID';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO REQUISITION DETAILS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFS.item_key               REQ_NUM_IK, '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.NOTIFICATION_ID        NOTIF_ID, '||
'       WFS.BEGIN_DATE, '||
'       WFS.END_DATE, '||
'       WFS.ERROR_NAME             ERROR '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''REQAPPRV'' '||
'and  WFS.item_key       in (select wf_item_key '||
'                           from  '||
'                           PO_REQUISITION_HEADERS_ALL  RQH, '||
'			   PO_REQUISITION_LINES_ALL    RQL '||
'                           where  '||
' 				RQH.REQUISITION_HEADER_ID = RQL.REQUISITION_HEADER_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rql.wip_entity_id = '|| p_wip_entity_id ||') ';
   end if;

   sqltxt :=sqltxt||
'	and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'	and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'	and  WFP.PROCESS_NAME       = WFA.NAME '||
'	and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'	and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'	and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'	and  WFA1.VERSION =  '||
'    	(select max(VERSION) '||
'     	from WF_ACTIVITIES WF2 '||
'     	where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     	and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'	and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'	and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS ';

   sqltxt :=sqltxt||' order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW REQUISITION APPROVAL STATUS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.ERROR_NAME             ERROR_NAME, '||
'       WFS.ERROR_MESSAGE          ERROR_MESSAGE, '||
'       WFS.ERROR_STACK            ERROR_STACK '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''REQAPPRV'' '||
'and  WFS.item_key       in (select wf_item_key '||
'                           from  '||
'                           PO_REQUISITION_HEADERS_ALL  RQH, '||
'			   PO_REQUISITION_LINES_ALL    RQL '||
'                           where  '||
' 				RQH.REQUISITION_HEADER_ID = RQL.REQUISITION_HEADER_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and rql.wip_entity_id = '|| p_wip_entity_id ||') ';
   end if;

   sqltxt := sqltxt ||
'	and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'	and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'	and  WFP.PROCESS_NAME       = WFA.NAME '||
'	and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'	and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'	and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'	and  WFA1.VERSION =  '||
'    	(select max(VERSION) '||
'     	from WF_ACTIVITIES WF2 '||
'     	where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     	and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'	and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'	and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS '||
'	and  WFS.ERROR_NAME is not NULL '||
'	order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW REQUISITION APPROVAL ERRORS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'  POH.PO_HEADER_ID                PO_HEADER_ID,          '||
'  POH.SEGMENT1                    PO_NUM, '||
'  POL.PO_LINE_ID                  PO_LINE_ID, '||
'  POL.LINE_NUM                    PO_LINE, '||
'  POL.LINE_TYPE_ID                LINE_TYPE_ID, '||
'  POL.ITEM_ID                     ITEM_ID,                   '||
'  POL.QUANTITY                    QTY, '||
'  POL.UNIT_PRICE                  PRICE, '||
'  POH.ACCEPTANCE_REQUIRED_FLAG    ACCEPT_REQD, '||
'  POH.BILL_TO_LOCATION_ID         BILL_TO, '||
'  POH.SHIP_TO_LOCATION_ID         SHIP_TO, '||
'  POH.CLOSED_CODE                 CLS_STAT, '||
'  POH.CONFIRMING_ORDER_FLAG       CONF_ORD, '||
'  POH.CURRENCY_CODE               CURR, '||
'  POH.ENABLED_FLAG                ENABLED, '||
'  POH.FROZEN_FLAG                 FROZEN,                    '||
'  POH.SUMMARY_FLAG                SUMM,                '||
'  POH.TYPE_LOOKUP_CODE            TYPE, '||
'  POH.VENDOR_CONTACT_ID           VEND_CNCACT,      '||
'  POH.VENDOR_ID                   VEND_ID,     '||
'  POH.VENDOR_SITE_ID              VEND_SITE,    '||
'  POH.WF_ITEM_TYPE                ITEM_TYPE, '||
'  POH.WF_ITEM_KEY                 ITEM_KEY ,  '||
'  POL.CATEGORY_ID                 CATEGORY_ID, '||
'  POL.CLOSED_CODE                 CLS_STAT, '||
'  POL.FIRM_STATUS_LOOKUP_CODE     FIRM '||
'from  '||
'    PO_HEADERS_ALL             POH, '||
'    PO_LINES_ALL               POL, '||
'    PO_LINE_LOCATIONS_ALL      LL, '||
'    PO_REQUISITION_LINES_ALL   PRL, '||
'    PO_REQUISITION_HEADERS_ALL PRH '||
'where  PRH.requisition_header_id = PRL.requisition_header_id '||
'and    PRL.line_location_id = LL.line_location_id '||
'and    LL.PO_HEADER_ID = POH.PO_HEADER_ID '||
'and    POL.PO_HEADER_ID = POH.PO_HEADER_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and prl.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by poh.po_header_id, pol.po_line_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'PO DETAILS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFS.item_key               PO_NUM_IK, '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.NOTIFICATION_ID        NOTIF_ID, '||
'       WFS.BEGIN_DATE, '||
'       WFS.END_DATE, '||
'       WFS.ERROR_NAME             ERROR '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''POAPPRV'' '||
'and  WFS.item_key           in (select poh.wf_item_key '||
'				from  '||
'    				PO_HEADERS_ALL             POH, '||
'				PO_LINES_ALL               POL, '||
'    				PO_LINE_LOCATIONS_ALL      LL, '||
'    				PO_REQUISITION_LINES_ALL   PRL, '||
'    				PO_REQUISITION_HEADERS_ALL PRH '||
'				where  PRH.requisition_header_id = PRL.requisition_header_id ';
   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and prl.wip_entity_id = '|| p_wip_entity_id ;
   end if;

   sqltxt := sqltxt ||
'				and    PRL.line_location_id = LL.line_location_id '||
'				and    LL.PO_HEADER_ID = POH.PO_HEADER_ID '||
'				and    POL.PO_HEADER_ID = POH.PO_HEADER_ID) '||
'and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'and  WFP.PROCESS_NAME       = WFA.NAME '||
'and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'and  WFA1.VERSION =  '||
'    (select max(VERSION) '||
'     from WF_ACTIVITIES WF2 '||
'     where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS '||
'order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME  ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW PURCHASE ORDER APPROVAL STATUS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'       WFA.DISPLAY_NAME           PROCESS_NAME, '||
'       WFA1.DISPLAY_NAME          ACTIVITY_NAME, '||
'       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT, '||
'       LKP.MEANING                  ACT_STATUS, '||
'       WFS.ERROR_NAME             ERROR_NAME, '||
'       WFS.ERROR_MESSAGE          ERROR_MESSAGE, '||
'       WFS.ERROR_STACK            ERROR_STACK '||
'from WF_ITEM_ACTIVITY_STATUSES WFS, '||
'     WF_PROCESS_ACTIVITIES     WFP, '||
'     WF_ACTIVITIES_VL          WFA, '||
'     WF_ACTIVITIES_VL          WFA1, '||
'     WF_LOOKUPS                LKP '||
'where  '||
'     WFS.ITEM_TYPE          = ''POAPPRV'' '||
'and  WFS.item_key           in (select poh.wf_item_key '||
'				from  '||
'    				PO_HEADERS_ALL             POH, '||
'				PO_LINES_ALL               POL, '||
'    				PO_LINE_LOCATIONS_ALL      LL, '||
'    				PO_REQUISITION_LINES_ALL   PRL, '||
'    				PO_REQUISITION_HEADERS_ALL PRH '||
'				where  PRH.requisition_header_id = PRL.requisition_header_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and prl.wip_entity_id = '|| p_wip_entity_id ;
   end if;

   sqltxt := sqltxt ||
'				and    PRL.line_location_id = LL.line_location_id '||
'				and    LL.PO_HEADER_ID = POH.PO_HEADER_ID '||
'				and    POL.PO_HEADER_ID = POH.PO_HEADER_ID) '||
'and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID '||
'and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE '||
'and  WFP.PROCESS_NAME       = WFA.NAME '||
'and  WFP.PROCESS_VERSION    = WFA.VERSION '||
'and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE '||
'and  WFP.ACTIVITY_NAME      = WFA1.NAME '||
'and  WFA1.VERSION =  '||
'    (select max(VERSION) '||
'     from WF_ACTIVITIES WF2 '||
'     where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE '||
'     and   WF2.NAME      = WFP.ACTIVITY_NAME) '||
'and  LKP.LOOKUP_TYPE = ''WFENG_STATUS'' '||
'and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS '||
'and  WFS.ERROR_NAME is not NULL '||
'order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME ';


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WORKFLOW PURCHASE APPROVAL ERRORS ',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	default_discrete_class, '||
'	decode(lot_number_default_type,1,''Job Name'', '||
'					2,''Based On Inventory Rules'', '||
'					3,''No Default'', '||
'					lot_number_default_type) lot_number_default_type, '||
'	decode(so_change_response_type,1,''Never'', '||
'					2,''Always'', '||
'					3,''When linked 1-1Default'') so_change_response_type, '||
'	decode(mandatory_scrap_flag,1,''Yes'',2,''No'') Mandatory_Scrap_Flag, '||
'	decode(dynamic_operation_insert_flag,1,''Yes'',2,''No'') Dynamic_Oprn_Insert_Flag, '||
'	decode(moves_over_no_move_statuses,1,''Yes'',2,''No'') Moves_Over_No_Move_Status, '||
'       default_pull_supply_subinv, '||
'	default_pull_supply_locator_id, '||
'	decode(backflush_lot_entry_type,1, ''Manual, verify all'', '||
'	                            2, ''Receipt Date, Verify all'', '||
'	                            3, ''Receipt Date, Verify excepns'', '||
'	                            4, ''Expiration Date, verify all'', '||
'	                            5, ''Expiration Date, verify excepns'', '||
'	                            6, ''Transaction History'', '||
'	                            backflush_lot_entry_type) Lot_Selection_Method , ' ;
if (release_level = '11.5.10.2' ) then
   sqltxt := sqltxt ||
'	decode(alternate_lot_selection_method,1, ''Manual'', '||
'	                            2, ''Receipt Date'', '||
'	                            4, ''Expiration Date'' , '||
'	                         alternate_lot_selection_method) Alternate_Lot_Selection_Method, ' ;
end if ;
    sqltxt := sqltxt ||
'	decode(allocate_backflush_components,''1'',''Yes'',''2'',''No'') Allocate_Backflush_Comps, '||
'	decode(allow_backflush_qty_change,1,''Yes'',2,''No'') Allow_Backflush_Qty_Change, '||
'	autorelease_days, '||
'	osp_shop_floor_status, '||
'	decode(po_creation_time, 1, ''At Job/Schedule Release'', '||
'	                         2, ''At Operation'', '||
'	                         3, ''Manual'', '||
'	                         po_creation_time) PO_Creation_Time, '||
'	default_overcompl_tolerance, '||
'	production_scheduler_id, '||
'	decode(material_constrained,1,''Yes'',2,''No'') Material_Constrained, '||
'	decode(use_finite_scheduler,1,''Yes'',2,''No'') Use_Finite_Scheduler,'||
'	repetitive_variance_type '||
'from	wip_parameters '||
'where   organization_id = (select organization_id  '||
'			from wip_entities ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ||')';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP PARAMETERS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  a.assembly_item_id, '||
'	substrb(msi.concatenated_segments, 1,30) item_name,  '||
-- '	a.organization_id, '||
'	nvl(a.alternate_bom_designator, ''PRIMARY'') alternate_bom_designator, '||
'	a.common_assembly_item_id, '||
'	decode( a.assembly_type,1,''Manufacturing'', '||
'				2,''Engineering'', '||
'				a.assembly_type) assembly_type, '||
'	a.bill_sequence_id, '||
'	a.common_bill_sequence_id, '||
'	b.operation_seq_num, '||
'	b.component_item_id, '||
'	substrb(msi_comp.concatenated_segments, 1,30) comp_item_name,  '||
'	b.component_quantity, '||
'	b.component_yield_factor, '||
'	b.effectivity_date, '||
'	b.implementation_date, '||
'	b.disable_date, '||
'	decode(b.wip_supply_type,1,''Push'', '||
'				 2,''Assembly Pull'', '||
'				 3,''Operation Pull'', '||
'				 4,''Bulk'', '||
'				 5,''Supplier'', '||
'				 6,''Phantom'', '||
'				 7,''Based on Bill'', '||
'				 b.wip_supply_type) wip_supply_type, '||
'	b.supply_subinventory, '||
'	b.supply_locator_id, '||
'	b.component_sequence_id '||
'from    bom_bill_of_materials a, bom_inventory_components b,  '||
'        wip_discrete_jobs wj, mtl_system_items_kfv msi, mtl_system_items_kfv msi_comp '||
'where   a.common_bill_sequence_id = b.bill_sequence_id '||
'and     a.organization_id = wj.organization_id '||
'and     a.assembly_item_id = wj.primary_item_id '||
'and     wj.common_bom_sequence_id = a.bill_sequence_id	 '||
'and     msi.inventory_item_id = a.assembly_item_id '||
'and     msi.organization_id = a.organization_id ' ||
'and     msi_comp.organization_id = a.organization_id ' ||
'and     msi_comp.inventory_item_id = b.component_item_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wj.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by a.bill_sequence_id, a.assembly_item_id, a.alternate_bom_designator, b.component_sequence_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'BILL OF MATERIAL',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  bor.assembly_item_id, '||
'	substrb(msi.concatenated_segments, 1,30) item_name,  '||
'	bor.organization_id, '||
'	nvl(bor.alternate_routing_designator, ''PRIMARY'') alternate_routing_designator, '||
'	bor.routing_sequence_id, '||
'	bor.common_routing_sequence_id, '||
'	bor.common_assembly_item_id, '||
'	bor.completion_subinventory, '||
'	bor.completion_locator_id, '||
'	decode(nvl(bor.cfm_routing_flag,2), '||
'		1, ''Flow'', '||
'		2, ''Discrete'', '||
'		3, ''Network'', '||
'		bor.cfm_routing_flag) cfm_routing_flag, '||
'	decode (bor.routing_type, '||
'		1, ''Mfg Rtg'', '||
'		2, ''Engg Rtg'', '||
'		bor.routing_type) routing_type, '||
'       a.operation_sequence_id, '||
'	a.operation_seq_num, '||
'	a.routing_sequence_id, '||
'	a.standard_operation_id, '||
'	b.operation_code, '||
'	a.department_id, '||
'	a.count_point_type, '||
'	a.effectivity_date, '||
'	a.disable_date, '||
'  	decode( a.backflush_flag, 1, ''Yes'', '||
'				  2, ''No'') backflush_flag, '||
'  	decode( a.option_dependent_flag, 1, ''Yes'', '||
'				  	2, ''No'') option_dependent_flag, '||
'	a.yield, '||
'	decode(a.operation_yield_enabled, 1, ''Yes'', '||
'	                                  2, ''No'', '||
'					  a.operation_yield_enabled) operation_yield_enabled '||
'from    bom_operation_sequences a, bom_operational_routings bor, wip_discrete_jobs wj, '||
'        bom_standard_operations b , mtl_system_items_kfv msi '||
'where   a.routing_sequence_id = bor.common_routing_sequence_id '||
'and     wj.organization_id = bor.organization_id '||
'and     wj.common_routing_sequence_id = bor.routing_sequence_id '||
'and     a.standard_operation_id = b.standard_operation_id(+) ' ||
'and     bor.assembly_item_id = msi.inventory_item_id '||
'and     bor.organization_id = msi.organization_id ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wj.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by bor.routing_sequence_id, bor.alternate_routing_designator, a.operation_seq_num';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'ROUTING',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'SELECT msik.inventory_item_id, '||
'                  substr(msik.concatenated_segments, 1, 30)  Item, '||
'                  msik.outside_operation_flag, '||
'                  msik.outside_operation_uom_type, '||
'                  wor.operation_seq_num, '||
'                  wor.resource_seq_num, '||
'                  wor.resource_id, '||
'                  br.resource_code, '||
'                  decode(wor.autocharge_type , 3, ''Po Move'', 4, ''PO Receipt'') AutoCharge_Type' ||
'           FROM   mtl_system_items_kfv msik, '||
'                  bom_resources br, '||
'                  wip_operation_resources wor '||
'           WHERE  msik.inventory_item_id = br.purchase_item_id '||
'           AND    msik.organization_id = br.organization_id '||
'           AND    wor.resource_id = br.resource_id '||
'           AND    wor.autocharge_type IN (3,4) '||
'           AND    wor.organization_id = br.organization_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wor.wip_entity_id = '|| p_wip_entity_id ;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'OSP ITEM DETAILS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	secondary_inventory_name, '||
'	organization_id, '||
'	decode(reservable_type, '||
'		1, ''Yes'', '||
'		2, ''No'', '||
'		reservable_type) reserv_type_mng, '||
'	disable_date, '||
'	decode(inventory_atp_code, '||
'		1, ''Incl in ATP calc'', '||
'		2, ''Not Incl in ATP calc'', '||
'		inventory_atp_code)	inv_atp_code_mng, '||
'	decode(locator_type, '||
'		1, ''No loc control'', '||
'		2, ''Prespecified'', '||
'		3, ''Dynamic'', '||
'		4, ''Determined at subinv'', '||
'		5, ''Determined at item'', '||
'		locator_type) locator_type_mng, '||
'	picking_order, '||
'	source_subinventory '||
'from    mtl_secondary_inventories '||
'where   organization_id = (select organization_id  '||
'			from wip_entities ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by 1';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'SUBINVENTORY SETUP',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

END repetitive ;

PROCEDURE flow (p_wip_entity_id IN NUMBER) IS
row_limit NUMBER;
BEGIN

row_limit := 1000;

sqltxt :=
'    select  a.wip_entity_id , ' ||
'        a.schedule_number, ' ||
'        decode(b.entity_type,1, ''1=Discrete Job'', ' ||
'                             2, ''2=Repetitive Assly'', ' ||
'                             3, ''3=Closed Discr Job'', ' ||
'                             4, ''4=Flow Schedule'', ' ||
'                             5, ''5=Lot Based Job'', ' ||
'                             b.entity_type) entity_type, ' ||
'        decode(a.scheduled_flag, 1, ''Flow Schedule'', 2, ''Work Order-less'', a.scheduled_flag) SchFlag , ' ||
'        a.organization_id, ' ||
'        p.organization_code, ' ||
'        a.primary_item_id, ' ||
'        substrb(m.concatenated_segments, 1, 30) item_name, ' ||
'        decode(a.status, ' ||
'			  1,''Open'', ' ||
'                          2, ''Closed'', ' ||
'                          a.status) status , ' ||
'	a.completion_subinventory, ' ||
'	a.completion_locator_id, ' ||
'        a.planned_quantity, ' ||
'	m.primary_uom_code uom_code, ' ||
'	a.quantity_completed, ' ||
'	a.quantity_scrapped, ' ||
'	a.class_code, ' ||
'	a.date_closed, ' ||
'	a.creation_date, ' ||
'	a.bom_revision, ' ||
'	a.routing_revision, ' ||
'	nvl(a.alternate_bom_designator, ''PRIMARY'') alternate_bom_designator, ' ||
'	nvl(a.alternate_routing_designator, ''PRIMARY'') alternate_routing_designator ' ||
'    from  wip_flow_schedules a , wip_entities b, mtl_system_items_kfv m, mtl_parameters p ' ||
'    where b.wip_entity_id = a.wip_entity_id ' ||
'    and   b.organization_id = a.organization_id ' ||
'    and   m.inventory_item_id = a.primary_item_id ' ||
'    and   m.organization_id = a.organization_id ' ||
'    and   a.organization_id = p.organization_id ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and b.wip_entity_id = '|| p_wip_entity_id;
   end if;


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'JOB HEADER ( WIP FLOW SCHEDULES , WIP ENTITIES )',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select acct_period_id, '||
'       decode(class_type,1,''Standard Discrete'', '||
'                         2,''Repetitive Assembly'', '||
'                         3,''Asset non-standard'', '||
'                         4,''Expense non-standard'', '||
'                         5,''Standard Lot Based'', '||
'                         6,''EAM'', '||
'                         7,''Expense non-standard Lot Based'', '||
'			 class_type) class_type, '||
'       tl_resource_in, '||
'       tl_overhead_in, '||
'       tl_outside_processing_in, '||
'       pl_material_in, '||
'       pl_material_overhead_in, '||
'       pl_resource_in, '||
'       pl_overhead_in, '||
'       pl_outside_processing_in, '||
'       tl_material_out, '||
'       tl_material_overhead_out, '||
'       tl_resource_out, '||
'       tl_overhead_out, '||
'       tl_outside_processing_out, '||
'       pl_material_out, '||
'       pl_material_overhead_out, '||
'       pl_resource_out, '||
'       pl_overhead_out, '||
'       pl_outside_processing_out, '||
'       tl_scrap_in, '||
'       tl_scrap_out, '||
'       tl_scrap_var, '||
'       creation_date, '||
'       last_update_date '||
'from   wip_period_balances ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by creation_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP PERIOD BALANCES',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wcti.transaction_id,  '||
'       wcti.creation_date, '||
'       wcti.last_update_date, '||
'       wcti.request_id, '||
'       source_code, '||
'       source_line_id, '||
'       decode(process_phase, '||
'		1, ''Res Valdn'', '||
'		2, ''Res Processing'', '||
'		3, ''Job Close'', '||
'		4, ''Prd Close'', '||
'		process_phase) process_phase_meaning, '||
'       decode(process_status, '||
'			1, ''Pending'', '||
'			2, ''Running'', '||
'			3, ''Error'', '||
'			4, ''Completed'', '||
'			5, ''Warning'', '||
'			process_status) process_status_meaning, '||
'       decode(transaction_type, '||
'		1, ''Resource'', '||
'		2, ''Overhead'', '||
'		3, ''OSP'', '||
'		4, ''Cost Update'', '||
'		5, ''PrdClose Var'', '||
'		6, ''JobClose Var'', '||
'		transaction_type) transaction_type_meaning, '||
'       organization_id, '||
'       organization_code, '||
'       primary_item_id, '||
'       transaction_date, '||
'       operation_seq_num, '||
'       resource_seq_num, '||
'       acct_period_id, '||
'       resource_id, '||
'       decode(resource_type, '||
'		1, ''Machine'', '||
'		2, ''Person'', '||
'		3, ''Space'', '||
'		4, ''Misc'', '||
'		5, ''Amount'', '||
'		resource_type) resource_type, '||
'       transaction_quantity, '||
'       actual_resource_rate, '||
'       transaction_uom, '||
'       decode(basis_type, '||
'		1, ''Item'', '||
'		2, ''Lot'', '||
'		3, ''Res Units'', '||
'		4, ''Res Value'', '||
'		5, ''Tot Value'', '||
'		6, ''Activity'') basis_type,  '||
'       move_transaction_id, '||
'       completion_transaction_id, '||
'       error_column, '||
'       error_message '||
'from   wip_cost_txn_interface wcti, '||
'       wip_txn_interface_errors wtie '||
'where  wcti.transaction_id = wtie.transaction_id (+) ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_id';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP COST TXN INTERFACE',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select wt.transaction_id,  '||
'       wt.creation_date, '||
'       wt.last_update_date, '||
'       wt.request_id, '||
'       wt.source_code, '||
'       wt.source_line_id, '||
'       wt.group_id, '||
'       decode(wt.transaction_type, '||
'		1, ''Resource'', '||
'		2, ''Overhead'', '||
'		3, ''OSP'', '||
'		4, ''Cost Update'', '||
'		5, ''PrdClose Var'', '||
'		6, ''JobClose Var'', '||
'		wt.transaction_type) transaction_type_meaning, '||
'       wt.organization_id, '||
'       wt.primary_item_id, '||
'       wt.transaction_date, '||
'       wt.operation_seq_num, '||
'       wt.resource_seq_num, '||
'       wt.acct_period_id, '||
'       wt.resource_id, '||
'       wt.transaction_quantity, '||
'       wt.actual_resource_rate, '||
'       wt.standard_resource_rate, '||
'       wt.transaction_uom, '||
'       wt.move_transaction_id, '||
'       wt.completion_transaction_id '||
'from   wip_transactions wt '||
'where  exists (select 1 '||
'               from   wip_entities we '||
'               where  we.wip_entity_id = wt.wip_entity_id '||
'               and    we.entity_type <> 2) '; /*  Other than Repetitive */

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_id';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_interface_id, '||
'        transaction_header_id, '||
'	source_code, '||
'	source_line_id, '||
'        source_header_id, '||
'	process_flag, '||
'	transaction_mode, '||
'	lock_flag, '||
'	request_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	transaction_uom, '||
'	transaction_date, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_source_id, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Plan Xfr'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	transaction_type_id, '||
'	operation_seq_num, '||
'	repetitive_line_id, '||
'	transfer_organization, '||
'	transfer_subinventory, '||
'	transfer_locator, '||
'        overcompletion_transaction_qty, '||
'        overcompletion_primary_qty, '||
'        overcompletion_transaction_id, '||
'	error_code, '||
'	substr(error_explanation,1,100) error_explanation '||
'from    mtl_transactions_Interface mti '||
'where   mti.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id;
      sqltxt :=sqltxt||' order by transaction_interface_id, transaction_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_interface_id, '||
'	source_code, '||
'	source_line_id, '||
'	request_id, '||
'	lot_number, '||
'	lot_expiration_date, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	serial_transaction_temp_id, '||
'	process_flag,  '||
'	error_code '||
'from    mtl_transaction_lots_interface mtli '||
'where   mtli.transaction_interface_id in '||
'		(select transaction_interface_id '||
'		 from mtl_transactions_Interface mti '||
'	 	 where   mti.transaction_source_type_id = 5 ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by lot_expiration_date ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select '||
'	transaction_interface_id, '||
'	source_code, '||
'	source_line_id, '||
'	request_id, '||
'	vendor_serial_number, '||
'	vendor_lot_number, '||
'	fm_serial_number, '||
'	to_serial_number, '||
'	error_code, '||
'	process_flag, '||
'	parent_serial_number '||
'from    mtl_serial_numbers_interface msni '||
'where   msni.transaction_interface_id in '||
'		(select transaction_interface_id '||
'		 from mtl_transactions_Interface mti '||
'	 	 where   mti.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mti.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by fm_serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSNI TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_temp_id, '||
'        transaction_header_id, '||
'	source_code, '||
'	source_line_id, '||
'	transaction_mode, '||
'	lock_flag, '||
'	transaction_date, '||
'	transaction_type_id, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Issue'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_source_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	primary_quantity, '||
'	trx_source_line_id, '||
'	trx_source_delivery_id, '||
'        overcompletion_transaction_qty, '||
'        overcompletion_primary_qty, '||
'        overcompletion_transaction_id, '||
'	move_transaction_id, '||
'	completion_transaction_id, '||
'	source_code, '||
'	source_line_id, '||
'	transfer_organization, '||
'	transfer_subinventory, '||
'	transfer_to_location, '||
'	move_order_line_id, '||
'	reservation_id, '||
'	creation_date, '||
'	last_update_date, '||
'	error_code '||
'from    mtl_material_transactions_temp '||
'where   transaction_source_type_id = 5 ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and transaction_source_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_temp_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MMTT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_temp_id, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	lot_number, '||
'	lot_expiration_date, '||
'	serial_transaction_temp_id, '||
'	group_header_id, '||
'	put_away_rule_id, '||
'	pick_rule_id, '||
'	request_id, '||
'	creation_date, '||
'	error_code '||
'from    mtl_transaction_lots_temp mtlt '||
'where   mtlt.transaction_temp_id in '||
'		(select mmtt.transaction_temp_id '||
'		 from mtl_material_transactions_temp mmtt '||
'	 	 where   mmtt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmtt.transaction_source_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by transaction_temp_id, lot_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	transaction_temp_id, '||
'	vendor_serial_number, '||
'	vendor_lot_number, '||
'	fm_serial_number, '||
'	to_serial_number, '||
'	serial_prefix, '||
'	group_header_id, '||
'	parent_serial_number, '||
'	end_item_unit_number, '||
'	request_id, '||
'	creation_date, '||
'	error_code '||
'from    mtl_serial_numbers_temp msnt '||
'where   msnt.transaction_temp_id  in '||
'		(select  mmtt.transaction_temp_id '||
'		 from    mtl_material_transactions_temp mmtt '||
'	 	 where   mmtt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmtt.transaction_source_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by transaction_temp_id, fm_serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSNT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select DISTINCT '||
' TRL.LINE_ID                         MOVE_LINE_ID, '||
' TRL.REQUEST_NUMBER                  MOVE_NUMBER, '||
' TRL.HEADER_ID                       MV_HDR_ID, '||
' TRL.LINE_NUMBER                     MV_LINE_NUM, '||
' decode(TRL.LINE_STATUS, '||
'                    1, ''Incomplete'', '||
'                    2, ''Pend Aprvl'', '||
'                    3, ''Approved'', '||
'                    4, ''Not Apprvd'', '||
'                    5, ''Closed'', '||
'                    6, ''Canceled'', '||
'                    7, ''Pre Apprvd'', '||
'                    8, ''Part Aprvd'') MV_LINE_STAT, '||
' TRL.INVENTORY_ITEM_ID, '||
' TRL.ORGANIZATION_ID, '||
' TRL.REVISION, '||
' TRL.QUANTITY                        QTY, '||
' TRL.PRIMARY_QUANTITY                PRM_QTY,            '||
' TRL.QUANTITY_DELIVERED              DLVD_QTY, '||
' TRL.QUANTITY_DETAILED               DTLD_QTY, '||
' TRL.MOVE_ORDER_TYPE_NAME            MOVE_TYPE_NAME, '||
' decode(TRL.TRANSACTION_SOURCE_TYPE_ID,2,''Sales Order'', '||
'                                       5,''Job or Schedule'', '||
'                                       13,''Inventory'', '||
'					TRL.TRANSACTION_SOURCE_TYPE_ID) txn_source_meaning,   '||
' TRL.TRANSACTION_TYPE_NAME           transaction_type_meaning,        '||
' decode(TRL.TRANSACTION_ACTION_ID, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Plan Xfr'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		trl.transaction_action_id) txn_action_meaning, '||
' TRL.FROM_SUBINVENTORY_CODE          FROM_SUB, '||
' TRL.FROM_LOCATOR_ID                 FROM_LOC_ID,  '||
' TRL.TO_SUBINVENTORY_CODE            TO_SUB, '||
' TRL.TO_LOCATOR_ID                   TO_LOC_ID,           '||
' TRL.LOT_NUMBER                      LOT_NUM, '||
' TRL.TRANSACTION_HEADER_ID           TRNS_HEAD_ID, '||
' TRL.CREATION_DATE '||
'from MTL_TXN_REQUEST_LINES_V   TRL '||
'WHERE trl.move_order_type <> 6 '||
'AND   (trl.txn_source_id, trl.txn_source_line_id) in  '||
'	(select  wdj.wip_entity_id, wro.operation_seq_num  '||
'	 from wip_flow_schedules wdj,  '||
'	      wip_entities we,  '||
'		wip_lines wl,  '||
'		wip_requirement_operations wro  '||
'	 where wdj.wip_entity_id = we.wip_entity_id  '||
'	 and  wdj.organization_id = we.organization_id  '||
'	 and wdj.wip_entity_id = wro.wip_entity_id  '||
'         and wdj.organization_id = wro.organization_id  '||
'	 and wdj.line_id = wl.line_id(+)  '||
'         and wdj.organization_id = wl.organization_id(+)  ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and we.wip_entity_id = '|| p_wip_entity_id ||')' ;
      sqltxt :=sqltxt||' order by request_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTL_TXN_REQUEST_LINES_V TRANSACTIONS  - MOVE ORDERS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  transaction_id, '||
'	transaction_date, '||
'	transaction_type_id, '||
'	decode(transaction_action_id, '||
'		1, ''Issue'', '||
'		2, ''Subinv Xfr'', '||
'		3, ''Org Xfr'', '||
'		4, ''Cycle Count Adj'', '||
'		5, ''Issue'', '||
'		21, ''Intransit Shpmt'', '||
'		24, ''Cost Update'', '||
'		27, ''Receipt'', '||
'		28, ''Stg Xfr'', '||
'		30, ''Wip scrap'', '||
'		31, ''Assy Complete'', '||
'		32, ''Assy return'', '||
'		33, ''-ve CompIssue'', '||
'		34, ''-ve CompReturn'', '||
'		40, ''Inv Lot Split'', '||
'		41, ''Inv Lot Merge'', '||
'		42, ''Inv Lot Translate'', '||
'		42, ''Inv Lot Translate'', '||
'		transaction_action_id) txn_action_meaning, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_source_id, '||
'	inventory_item_id, '||
'	organization_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	revision, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	primary_quantity, '||
'	trx_source_line_id, '||
'	trx_source_delivery_id, '||
'	move_transaction_id, '||
'	completion_transaction_id, '||
'	source_code, '||
'	source_line_id, '||
'	transfer_organization_id, '||
'	transfer_subinventory, '||
'	transfer_locator_id, '||
'	move_order_line_id, '||
'	reservation_id, '||
'	creation_date, '||
'	last_update_date, '||
'	error_code '||
'from    mtl_material_transactions '||
'where   transaction_source_type_id = 5 '||
'and     exists (select 1  '||
'                from   wip_entities '||
'                where  wip_entity_id = transaction_source_id '||
'                and    entity_type <>  2 ) '; /*  Other than repetitive schedule */

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and transaction_source_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by transaction_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MMT TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	 '||
'	inventory_item_id, '||
'	lot_number, '||
'	organization_id, '||
'	transaction_id, '||
'	transaction_date, '||
'	creation_date, '||
'	transaction_source_id, '||
'	decode(transaction_source_type_id, '||
'		1, ''PO'', '||
'		2, ''SO'', '||
'		4, ''MoveOrder'', '||
'		5, ''WIP'', '||
'		6, ''AcctAlias'', '||
'		7, ''Int REQ'', '||
'		8, ''Int Order'', '||
'		9, ''CycleCount'', '||
'		10,''PhyCount'', '||
'		11,''StdCostUpd'', '||
'		12, ''RMA'', '||
'		13, ''INV'', '||
'		17, ''Ext REQ'', '||
'		transaction_source_type_id) txn_source_meaning, '||
'	transaction_quantity, '||
'	primary_quantity, '||
'	serial_transaction_id '||
'from    mtl_transaction_lot_numbers mtln '||
'where   mtln.transaction_id in '||
'		(select mmt.transaction_id '||
'		 from mtl_material_transactions mmt '||
'	 	 where   mmt.transaction_source_type_id = 5 ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by inventory_item_id, lot_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTLN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

/*
sqltxt :=
'select	 '||
'	inventory_item_id, '||
'	serial_number, '||
'	decode(current_status, '||
'		1, ''Defined but not used'', '||
'		3, ''Resides in stores'', '||
'		4, ''Issued out of stores'', '||
'		5, ''Resides in intrasit'', '||
'		current_status) current_status_meaning, '||
'	revision, '||
'	lot_number, '||
'	parent_item_id, '||
'	last_transaction_id, '||
'	parent_serial_number, '||
'	end_item_unit_number, '||
'	group_mark_id, '||
'	line_mark_id, '||
'	lot_line_mark_id, '||
'	gen_object_id, '||
'	creation_date '||
'from    mtl_serial_numbers msn ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where msn.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by inventory_item_id, serial_number ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

*/

sqltxt :=
' select mmt.inventory_item_id, ' ||
'        mmt.transaction_id,' ||
'        mmt.transaction_date,' ||
'        mmt.transaction_source_id,' ||
'        mut.serial_number,' ||
'        mmt.subinventory_code,' ||
'        mmt.locator_id , ' ||
'        mmt.creation_date' ||
' from   mtl_material_transactions mmt,' ||
'        mtl_unit_transactions mut' ||
' where  mmt.transaction_action_id in (1, 27, 33, 34, 30, 31, 32)' ||
' and    mmt.transaction_source_type_id = 5' ||
' and    mut.transaction_id = mmt.transaction_id' ;

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and mmt.transaction_source_id  = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by mmt.inventory_item_id, mut.serial_number ';
   end if ;


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MSN TRANSACTIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	header_id, '||
'	source_id, '||
'	source_code, '||
'	completion_status, '||
'	creation_date, '||
'	last_update_date, '||
'	inventory_item_id, '||
'	organization_id, '||
'	primary_quantity, '||
'	transaction_quantity, '||
'	transaction_uom, '||
'	transaction_date, '||
'	transaction_action_id, '||
'	transaction_source_id, '||
'	transaction_source_type_id, '||
'	transaction_type_id, '||
'	transaction_mode, '||
'	acct_period_id, '||
'	subinventory_code, '||
'	locator_id, '||
'	schedule_id, '||
'	repetitive_line_id, '||
'	operation_seq_num, '||
'	cost_group_id, '||
'	lock_flag, '||
'	error_code, '||
'	final_completion_flag, '||
'	completion_transaction_id '||
'from    wip_lpn_completions ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by header_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP LPN COMPLETIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select  '||
'     RES.RESERVATION_ID            RESERV_ID, '||
'     decode(RES.SHIP_READY_FLAG,1,''1=Released'',2,''2=Submitted'',to_char(RES.SHIP_READY_FLAG)) '||
'                                   SHIP_READY,  '||
'     RES.DEMAND_SOURCE_HEADER_ID   DS_HEADER_ID, '||
'     RES.DEMAND_SOURCE_LINE_ID     DS_LINE_ID, '||
'     RES.DEMAND_SOURCE_DELIVERY    DS_DELIVERY, '||
'     RES.INVENTORY_ITEM_ID         ITEM_ID, '||
'     RES.RESERVATION_QUANTITY      RES_QTY, '||
'     RES.RESERVATION_UOM_CODE      RUOM, '||
'     RES.PRIMARY_RESERVATION_QUANTITY PRES_QTY, '||
'     RES.PRIMARY_UOM_CODE          PUOM, '||
'     RES.DETAILED_QUANTITY         DET_QTY, '||
'     RES.REQUIREMENT_DATE          REQUIRD_DATE, '||
'     RES.DEMAND_SOURCE_TYPE_ID     DS_TYPE, '||
'     RES.ORGANIZATION_ID           ORG_ID, '||
'     RES.SUBINVENTORY_CODE         SUBINV, '||
'     RES.LOT_NUMBER                LOT, '||
'     RES.REVISION                  REV, '||
'     RES.LOCATOR_ID                LOC_ID, '||
'     RES.SERIAL_NUMBER             SERIAL_NUM, '||
'     decode(RES.SUPPLY_SOURCE_TYPE_ID,1,''1=PO'', '||
'                                      2,''2=OE'', '||
'                                      5,''5=WIP DJ'', '||
'                                      7,''7=INT_REQ'', '||
'                                      8,''8=INT_OE'', '||
'                                      13,''13=INV'', '||
'                                      17,''17=REQ'', '||
'					RES.SUPPLY_SOURCE_TYPE_ID) '||
'                                   SS_TYPE_ID, '||
'     We.WIP_ENTITY_ID             WIP_ID, '||
'     decode(JOB.STATUS, 1, ''Open'',            '||
'                             2, ''Closed'',            '||
'                            JOB.STATUS ) STATUS, '||
'     RES.SUPPLY_SOURCE_HEADER_ID   SS_HEADER_ID,       '||
'     RES.SUPPLY_SOURCE_LINE_DETAIL SS_SOURCE_LINE_DET, '||
'     RES.SUPPLY_SOURCE_LINE_ID     SS_SOURCE_LINE,       '||
'     RES.PARTIAL_QUANTITIES_ALLOWED ALLOW_PART, '||
'     to_char(RES.CREATION_DATE, ''DD-MON HH24:MI:SS'') CREATE_DATE, '||
'     to_char(RES.LAST_UPDATE_DATE, ''DD-MON HH24:MI:SS'') UPD_DATE '||
'from '||
'     MTL_RESERVATIONS              RES, '||
'     WIP_ENTITIES                  WE, '||
'     WIP_FLOW_SCHEDULES            JOB '||
'where RES.SUPPLY_SOURCE_HEADER_ID   = We.WIP_ENTITY_ID '||
'and  We.WIP_ENTITY_ID             = JOB.WIP_ENTITY_ID ';

   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' and we.wip_entity_id = '|| p_wip_entity_id ;
      sqltxt :=sqltxt||' order by reservation_id ';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'MTL RESERVATIONS',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

sqltxt :=
'select	secondary_inventory_name, '||
'	organization_id, '||
'	decode(reservable_type, '||
'		1, ''Yes'', '||
'		2, ''No'', '||
'		reservable_type) reserv_type_mng, '||
'	disable_date, '||
'	decode(inventory_atp_code, '||
'		1, ''Incl in ATP calc'', '||
'		2, ''Not Incl in ATP calc'', '||
'		inventory_atp_code)	inv_atp_code_mng, '||
'	decode(locator_type, '||
'		1, ''No loc control'', '||
'		2, ''Prespecified'', '||
'		3, ''Dynamic'', '||
'		4, ''Determined at subinv'', '||
'		5, ''Determined at item'', '||
'		locator_type) locator_type_mng, '||
'	picking_order, '||
'	source_subinventory '||
'from    mtl_secondary_inventories '||
'where   organization_id = (select organization_id  '||
'			from wip_entities ';


   if p_wip_entity_id is not null then
      sqltxt :=sqltxt||' where wip_entity_id = '|| p_wip_entity_id ||')';
      sqltxt :=sqltxt||' order by 1';
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'SUBINVENTORY SETUP',null,'Y',row_limit);
END flow ;

procedure setup (p_org_id IN NUMBER,
                 report OUT NOCOPY JTF_DIAG_REPORT,
                 reportClob OUT NOCOPY CLOB) IS

  l_user_id                         varchar2(255);
  l_user_name                       varchar2(255);
  l_resp_id                         varchar2(255);
  l_resp_name                       varchar2(255);
  l_appl_id                         number := 506 ;
  l_pov                             varchar2(60);
  l_lvl                             varchar2(10);
  l_po_id_string                    varchar2(2000) ;
  l_user_id_string                  varchar2(100) ;
  l_resp_id_string                  varchar2(100) ;

  l_release_name                    varchar2(20) ;
  l_other_info                      varchar2(20) ;
  l_result                          boolean ;

  reportStr varchar2(2000) ;
  l_count   number ;

  l_url  varchar2(255) ;
  l_desc varchar2(255) ;


  row_limit number;

  cursor wip_param_csr is
  select *
  from   wip_parameters
  where  organization_id = p_org_id ;

  wip_param_rec wip_param_csr%ROWTYPE ;

  cursor wip_param_v_csr is
  select *
  from   wip_parameters_v
  where  organization_id = p_org_id ;

  wip_param_v_rec wip_param_v_csr%ROWTYPE ;

  cursor inv_param_csr is
  select *
  from   mtl_parameters
  where  organization_id = p_org_id ;

  inv_param_rec inv_param_csr%ROWTYPE ;
  apps_ver varchar2(20) ;




  procedure checkWipProfiles is

    profile_val fnd_profile_option_values.profile_option_value%type ;

  begin

  row_limit := 1000;

  l_result := fnd_release.get_release(l_release_name, l_other_info) ;

  l_url  := 'http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT' || '&' || 'p_id=67009.1' ;
  l_desc := 'Oracle Work in Process Documentation - Release 11i' ;

  fnd_profile.get('USER_ID', l_user_id);
  fnd_profile.get('USER_NAME', l_user_name);
  fnd_profile.get('RESP_ID', l_resp_id);
  fnd_profile.get('RESP_NAME', l_resp_name);

  if l_user_id is null then
     l_user_id_string := '0' ;
  else
     l_user_id_string := to_char(l_user_id) ;
  end if ;

  if l_resp_id is null then
     l_resp_id_string := '0' ;
  else
     l_resp_id_string := to_char(l_resp_id) ;
  end if ;

/*
sqltxt := 'select substr(fpo.user_profile_option_name, 1, 60) Profile ,decode(substr(fpov.profile_option_value, 1, 52), ''1'', ''Yes'', ''2'', ''No'', substr(fpov.profile_option_value,1, 52)) Value,  '||

'         decode(fpov.level_id, 10001, ''Site'', 10002, ''Appl'', 10003, ''Resp'', 10004, ''User'', ''None'') lvl  '||
'  from   fnd_profile_option_values fpov  , '||
'         fnd_profile_options_vl fpo ' ||
'  where  fpo.application_id = fpov.application_id ' ||
'  and    fpo.profile_option_id = fpov.profile_option_id ' ||
'  and    (fpov.application_id    = 706 '||
'  and    fpov.profile_option_id  in ( ' ||
'                      select fpovl.profile_option_id  ' ||
'                       from   fnd_profile_options_vl fpovl ' ||
'                       where  fpovl.application_id = 706 ' ||
'                       and    fpovl.start_date_active <= sysdate ' ||
'                       and    nvl(fpovl.end_date_active,sysdate) >= sysdate) ' ||
'   or   (fpov.application_id = 704 and fpov.profile_option_id = 1260)) ' ||
'  and    ((fpov.level_id = 10001 and fpov.level_value = 0)  '||
'   or    (fpov.level_id = 10002 and fpov.level_value = 706)  '||
'   or    (fpov.level_id = 10003 and fpov.level_value_application_id = 706  '||
'  and    fpov.level_value = to_number( ' || l_resp_id_string || '))  '||
'   or    (fpov.level_id = 10004 and fpov.level_value = to_number( ' || l_user_id_string || ')))  ' ||
'   order by fpo.user_profile_option_name, fpov.level_id desc ' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP Profiles',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

*/

  reportStr := 'WIP Profiles' ;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
  JTF_DIAGNOSTIC_COREAPI.Display_Profiles(706) ;

  reportStr := 'MRP Debug Profile' ;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
  JTF_DIAGNOSTIC_COREAPI.Display_Profiles(704, 'MRP_DEBUG');



   apps_ver := JTF_DIAGNOSTIC_COREAPI.Get_DB_Apps_Version ;

  /* Fix for #5757345. in following if */

  if (release_level in ('11.5.10' , '11.5.10.1', '11.5.10.2')) then

    reportStr := 'FND Profiles' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;

    -- Check FND Profile for WIP Debugging
    reportStr := 'FND Profiles - FND: Debug Log Enabled' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
    JTF_DIAGNOSTIC_COREAPI.Display_Profiles(0, 'AFLOG_ENABLED');

    reportStr := 'FND Profiles - FND: Debug Log FileName' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
    JTF_DIAGNOSTIC_COREAPI.Display_Profiles(0, 'AFLOG_FILENAME');

    reportStr := 'FND Profiles - FND: Debug Log Level' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
    JTF_DIAGNOSTIC_COREAPI.Display_Profiles(0, 'AFLOG_LEVEL');

    reportStr := 'FND Profiles - FND: Debug Log Module' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
    JTF_DIAGNOSTIC_COREAPI.Display_Profiles(0, 'AFLOG_MODULE');

    reportStr := 'Following profiles are not used from 11.5.10 onwards' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;
    JTF_DIAGNOSTIC_COREAPI.Tab1Print('TP:WIP Background Shop Floor Material Processing')  ;
    JTF_DIAGNOSTIC_COREAPI.Tab1Print('TP:WIP Operation Backflush Setup')  ;
    JTF_DIAGNOSTIC_COREAPI.Tab1Print('TP:WIP Debug File')  ;
    JTF_DIAGNOSTIC_COREAPI.Tab1Print('TP:WIP Debug Directory')  ;
    JTF_DIAGNOSTIC_COREAPI.Tab1Print('WIP:Job Name Updatable')  ;

    JTF_DIAGNOSTIC_COREAPI.BRPrint ;

    reportStr := 'Following profiles are introduced in 11.5.10' ;
    JTF_DIAGNOSTIC_COREAPI.SectionPrint(reportStr)  ;

    JTF_DIAGNOSTIC_COREAPI.Tab1Print('TP:WIP Work Order-less Completion Transaction Form')  ;
    JTF_DIAGNOSTIC_COREAPI.Tab1Print('TP:WIP Work Order-less Default Completion Type')  ;

 end if ;


   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   profile_val := JTF_DIAGNOSTIC_COREAPI.CheckProfile('WIP_CONC_MESSAGE_LEVEL', l_user_id, l_resp_id, l_appl_id );

   if (profile_val <> 0 ) then
       -- Check for MRP Debug value. It must be set to yes so that debug messages can be printed.
       profile_val := JTF_DIAGNOSTIC_COREAPI.CheckProfile('MRP_DEBUG', l_user_id, l_resp_id, 704);

      reportStr := ' MRP: Debug profile must be set to ''Yes'' so that Debug messages in concurrent definition of Job , WIP Mass Load, Autocreate FAS, Leadtime request will be printed' ;
      JTF_DIAGNOSTIC_COREAPI.WarningPrint(reportStr);

   else
       reportStr := 'Debug messages in concurrent definition of Job , WIP Mass Load, Autocreate FAS, Leadtime request will not be printed' ;
       JTF_DIAGNOSTIC_COREAPI.WarningPrint(reportStr);
   end if ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;



   -- Check if Oracle Flow Manufacturing is installed as check profiles as appropriate
   -- if (FNDUtility.getInstallStatus(report, 714) = 2) then
       profile_val := JTF_DIAGNOSTIC_COREAPI.CheckProfile('WIP_WORKORDERLESS_COMP_FORM_DEFAULT', l_user_id, l_resp_id, l_appl_id );

       if (profile_val = 4 ) then
          reportStr := ' The profile option ''TP:WIP Work Order-less Default Completion Type'' has not been set.';
          JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
      JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('If discrete manufacturing or project manufacturing or flow manufacturing '||
                                             'is planned to be used this profile must be set. Please see the'  || l_url , l_desc, 'for more information on how to setup WIP Profile') ;
       end if ;

   -- end if ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;


   profile_val := JTF_DIAGNOSTIC_COREAPI.CheckProfile('WIP_JOB_PREFIX', l_user_id, l_resp_id, l_appl_id , 'No Prefix');
   if (profile_val = 4 )then
      reportStr := ' The profile option ''WIP:Discrete Job Prefix'' has not been set.';
      JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
      JTF_DIAGNOSTIC_COREAPI.ActionWarningLink('If discrete manufacturing or project manufacturing or flow manufacturing'||
                                               ' is planned to be used this profile must be set. Please see the' , l_url , l_desc ,'for more information on how to setup WIP Profile') ;
   end if ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   profile_val := JTF_DIAGNOSTIC_COREAPI.CheckProfile('WIP_OSP_WF', l_user_id, l_resp_id, l_appl_id );
   if (profile_val = 4) then
      reportStr := ' The profile option ''WIP:Job Name Updatable'' has not been set.';
      JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
      JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('If discrete manufacturing or project manufacturing or flow '||
                                             'manufacturing is planned to be used this profile must be set. Please see the', l_url ,
                                             l_desc,'for more information on how to setup WIP Profile') ;
   end if ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

/*
   if (apps_ver = '11.5.9') then
       profile_val := JTF_DIAGNOSTIC_COREAPI.CheckProfile('WIP_DEBUG_FILE', l_user_id, l_resp_id, l_appl_id, 'wip.log' );
   end if ;
*/


   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

  end checkWipProfiles ;

  procedure checkWipDetails is
   row_limit NUMBER;
  begin
   row_limit := 1000;

   sqltxt :=   'SELECT ' ||
            'mlu1.meaning                    cost_method, ' ||
            'mlu2.meaning                    def_lot_numb_typ, ' ||
            'mlu3.meaning                    resp_so_chgs, ' ||
            'mlu4.meaning                    per_variances, ' ||
            'mlu5.meaning                    lot_selection_mth, ' ||
            'wip1.default_discrete_class      def_disc_cls, ' ||
            'wip1.autorelease_days            auto_rel_days, ' ||
            'wip1.default_pull_supply_subinv  supply_subinv, ' ||
            'wip1.component_atp_rule_name     atp_rule, ' ||
            'wip1.cost_type                   cost_type, ' ||
            'wip1.system_option               syst_opt, ' ||
            'wip1.completion_cost_source_meaning  compl_cst_src, ' ||
            'decode(wip1.auto_compute_final_completion, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')  auto_comp, ' ||
            'decode(wip1.dynamic_operation_insert_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')  dynamic_ops_ins, ' ||
            'decode(wip1.moves_over_no_move_statuses, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')    moves_over_no_move, ' ||
            'decode(wip1.queue_enabled_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')   intra_queue_flg, ' ||
            'decode(wip1.run_enabled_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')     intra_run_flg, ' ||
            'decode(wip1.to_move_enabled_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')  intra_tomove_flg, ' ||
            'decode(wip1.reject_enabled_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')   intra_reject_flg, ' ||
            'decode(wip1.scrap_enabled_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')    intra_scrap_flg, ' ||
            'decode(wip1.mandatory_scrap_flag, ' ||
            '1, ' ||
            '''Y'', ' ||
            '''N'')  req_scrap_acct, ' ||
            'mtp.organization_code            org_code, ' ||
            'mpm.organization_code            mast_org_code, ' ||
            'mpc.organization_code            cost_org_code, ' ||
            'wip1.default_overcompl_tolerance, ' ||
            'wip1.production_scheduler, ' ||
            'wip1.shipping_manager, ' ||
            'mlu6.meaning use_finite_scheduler, ' ||
            'wip1.use_finite_scheduler use_finite_scheduler_code, ' ||
            'wip1.horizon_length, ' ||
            'wip1.default_scrap_account_id, ' ||
            'wip1.simulation_set, ' ||
            'wip1.component_atp_rule_name, ' ||
            'wip1.osp_shop_floor_status, ' ||
            'wip1.po_creation_time, '  ||
            'decode(wip1.material_constrained, ' ||
            '1, ' ||
            '''Resource and Material'', ' ||
            '2, ' ||
            '''Resource Only'', ' ||
            'wip1.material_constrained ) material_constrained, ' ||
            'milk.concatenated_segments locator, ' ||
            'decode(wip1.lot_verification, '  ||
            '0, ' ||
            '''All'', ' ||
            '1, ' ||
            '''Exceptions Only'', ' ||
            'wip1.lot_verification ) lot_verification, ' ||
            'gcck.concatenated_segments default_scrap_account, ' ||
            'mtp.primary_cost_method primary_cost_method_code, ' ||
            'wip2.system_option_id ' ||
            'FROM ' ||
            'mfg_lookups               mlu1, ' ||
            'mfg_lookups               mlu2, ' ||
            'mfg_lookups               mlu3, ' ||
            'mfg_lookups               mlu4, ' ||
            'mfg_lookups               mlu5, ' ||
            'mfg_lookups               mlu6, ' ||
            'mtl_parameters            mtp, ' ||
            'mtl_parameters            mpm, ' ||
            'mtl_parameters            mpc, ' ||
            'wip_parameters_v          wip1, ' ||
            'wip_parameters            wip2, ' ||
            'mtl_item_locations_kfv milk, ' ||
            'gl_code_combinations_kfv gcck ' ||
            'WHERE ' ||
            'gcck.code_combination_id(+) = wip1.default_scrap_account_id AND ' ||
            'milk.inventory_location_id(+) = wip1.default_pull_supply_locator_id AND ' ||
            'mlu1.lookup_type             = ''MTL_PRIMARY_COST'' AND ' ||
            'mlu1.lookup_code             = nvl(mtp.primary_cost_method,-1) AND ' ||
            'mlu2.lookup_type             = ''WIP_LOT_NUMBER_DEFAULT'' AND ' ||
            'mlu2.lookup_code             = nvl(wip1.lot_number_default_type,-1) AND ' ||
            'mlu3.lookup_type             = ''WIP_SO_CHANGE_TYPE'' AND ' ||
            'mlu3.lookup_code             = nvl(wip1.so_change_response_type,-1) AND ' ||
            'mlu4.lookup_type             = ''WIP_REPETITIVE_VARIANCE_TYPE'' AND ' ||
            'mlu4.lookup_code             = nvl(wip1.repetitive_variance_type,-1) AND ' ||
            'mlu5.lookup_type             = ''WIP_BACKFLUSH_LOT_ENTRY'' AND ' ||
            'mlu5.lookup_code             = nvl(wip1.backflush_lot_entry_type,-1) AND ' ||
            'mlu6.lookup_code = wip1.use_finite_scheduler AND ' ||
            'mlu6.lookup_type = ''SYS_YES_NO'' AND ' ||
            'mtp.cost_organization_id     = mpc.organization_id AND ' ||
            'mtp.master_organization_id   = mpm.organization_id AND ' ||
            'mtp.organization_id          = wip1.organization_id AND ' ||
            'wip2.rowid = wip1.row_id AND ' ||
            'wip1.organization_id          = ' || p_org_id ;





    dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'WIP Parameters SETUP',null,'Y',row_limit);

    IF (dummy_num = row_limit) THEN
      JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
    END IF;

   if dummy_num = 0 then
     reportStr := 'There are no work in process parameters defined for this organization';

     JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr) ;
     JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please see the' , l_url, l_desc, ' for more information on how to setup these parameter values') ;
   else
     open wip_param_v_csr ;
     fetch wip_param_v_csr into wip_param_v_rec ;
     close wip_param_v_csr ;

     open wip_param_csr ;
     fetch wip_param_csr into wip_param_rec ;
     close wip_param_csr ;

     open inv_param_csr ;
     fetch inv_param_csr into inv_param_rec ;
     close inv_param_csr ;

     if (inv_param_rec.primary_cost_method = 2 ) then -- Average Costing

        JTF_DIAGNOSTIC_COREAPI.SectionPrint('Cost Method Average Parameters' ) ;
        JTF_DIAGNOSTIC_COREAPI.Line_Out('Default Completion Cost Source = ' || wip_param_v_rec.completion_cost_source_meaning || '<BR>' );
        JTF_DIAGNOSTIC_COREAPI.Line_Out('System Option = ' ||  wip_param_v_rec.system_option || '<BR>');
        JTF_DIAGNOSTIC_COREAPI.Line_Out('Cost Type = ' ||  wip_param_v_rec.cost_type || '<BR>');


        if (wip_param_rec.system_option_id = 2 ) then
           JTF_DIAGNOSTIC_COREAPI.ActionWarningLink('This setting will cause lot based resources and overheads to be over-relieved. Select ''Use Actual Resources '' to avoid this problem.<BR> Please see the ', l_url, l_desc , 'for more information') ;
        end if ;

        if (wip_param_v_rec.completion_cost_source_meaning  is null or
            wip_param_v_rec.system_option is null or
            wip_param_v_rec.cost_type is null or
            wip_param_v_rec.auto_compute_final_completion is null) then

           JTF_DIAGNOSTIC_COREAPI.ActionWarningLink('Parameters not set for average cost method. Please see the ', l_url, l_desc, ' for information on how to setup WIP parameters') ;
         end if ;
     end if;
   end if ;
 end checkWIPDetails ;

 procedure checkAtoAttributes is
  begin
   SELECT count(*)
   into   l_count
   FROM dual
   WHERE exists (
     SELECT * FROM mtl_system_items mtl
     WHERE mtl.replenish_to_order_flag = 'Y'
     AND mtl.build_in_wip_flag = 'Y'
     AND mtl.wip_supply_type in (1,2,6)
     AND mtl.bom_item_type in (1,2,4)
     AND mtl.bom_enabled_flag = 'Y'
     AND mtl.organization_id =   p_org_id) ;


--   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
--   JTF_DIAGNOSTIC_COREAPI.Tab2Print('There are ' || l_count  || ' ATO items defined <BR> ');

   if l_count = 0 then
      JTF_DIAGNOSTIC_COREAPI.ActionWarningLink('Please refer ', 111874.1, ' for information on how to setup ATO parameters') ;
   end if;

  end CheckAtoAttributes ;

  procedure checkCostGroup is


   cursor cost_grp_csr is
   SELECT cst.cost_group
   FROM CST_COST_GROUPS_V cst
   WHERE cst.organization_id = p_org_id ;
  begin

   l_found := 0 ;

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

    for cost_grp_rec in cost_grp_csr loop
      JTF_DIAGNOSTIC_COREAPI.Tab2Print('Cost Group ' || cost_grp_rec.cost_group || ' <BR> ');
      l_found := 1 ;
    end loop ;

    if l_found = 0 then

      reportStr := 'No cost group defined for this organization. A cost group must be setup.' ;
      reportStr := reportStr || 'Then assign the WIP accounting class needed for the cost group' ;

      /*
      JTF_DIAGNOSTIC_COREAPI.Tab2Print('No cost group defined for this organization. A cost group must be setup <BR>');
      JTF_DIAGNOSTIC_COREAPI.Tab2Print('Then assign the WIP accounting class needed for the cost group<BR>');
      */

      JTF_DIAGNOSTIC_COREAPI.WarningPrint(reportStr) ;

      JTF_DIAGNOSTIC_COREAPI.ActionWarningLink('Please refer to note:', '1079196.6', 'for more information') ;
   end if ;

  end checkCostGroup ;

  procedure checkOpMove is

   l_string varchar2(20) ;
   cursor op_move_csr is
   SELECT wsfsc.shop_floor_status_code ,
          wsfsc.status_move_flag ,
          ml.meaning ,
          wsfsc.status_move_flag status_move_flag_code
    FROM  wip_shop_floor_status_codes wsfsc ,
          mfg_lookups ml
    WHERE ml.lookup_type = 'SYS_YES_NO'
     AND  ml.lookup_code = wsfsc.status_move_flag
     AND  organization_id = p_org_id ;

  begin

     l_found := 0 ;

     JTF_DIAGNOSTIC_COREAPI.BRPrint ;

     for op_move_rec in op_move_csr loop
       l_found := 1 ;
       if op_move_rec.status_move_flag_code = 1 then
          l_string := 'Allowed' ;
       else
          l_string := 'Not Allowed' ;
       end if ;

       JTF_DIAGNOSTIC_COREAPI.Tab2Print('Operation Moves ' || l_string || ' for shop floor status '
                                         || op_move_rec.shop_floor_status_code);
     end loop ;

     if l_found = 0  then
       reportStr := 'No operation moves allowed with pending move transaction for this organization.';
       reportStr := reportStr || 'There is no move shop floor status created or being used. This is the intended functionality if the shop floor status is not used.' ;

       JTF_DIAGNOSTIC_COREAPI.WarningPrint(reportStr) ;
       JTF_DIAGNOSTIC_COREAPI.ActionWarningLink('Please refer to note', 165224.1, 'for more information on how to setup these parameter values') ;

     end if ;
  end checkOpMove;

  procedure checkEmpRate is
  begin

   l_count := 0 ;

   SELECT count(wipl.employee_id)
   into   l_count
   FROM  wip_employee_labor_rates wipl
   WHERE wipl.organization_id = p_org_id ;

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   JTF_DIAGNOSTIC_COREAPI.Tab2Print('There are ' || l_count  || ' employees defined');

   if l_count = 0 then

      reportStr := 'There are no employee labor rates defined for this organization' ;
      JTF_DIAGNOSTIC_COREAPI.WarningPrint(reportStr) ;

      reportStr := 'Please define employee labor rates for manual resource charge. ' ;
      reportStr := reportStr || 'Please refer to note' ;

      JTF_DIAGNOSTIC_COREAPI.ActionWarningLink(reportStr, 157959.1, ' for more information') ;

   end if ;


  end checkEmpRate ;

  procedure checkAccClass is
   row_limit number;
  begin
   row_limit := 1000;
   sqltxt :=

'          SELECT  ' ||
'            wac.class_code,  ' ||
'            wac.organization_id,  ' ||
'            ml1.meaning,  ' ||
'            wac.description,  ' ||
'            wac.disable_date,  ' ||
'            gcc1.concatenated_segments material_account,  ' ||
'            gcc2.concatenated_segments material_variance_account,  ' ||
'            gcc3.concatenated_segments material_overhead_account,  ' ||
'            gcc4.concatenated_segments resource_account,  ' ||
'            gcc5.concatenated_segments resource_variance_account,  ' ||
'            gcc6.concatenated_segments outside_processing_account,  ' ||
'            gcc7.concatenated_segments outside_proc_variance_account,  ' ||
'            gcc8.concatenated_segments overhead_account,  ' ||
'            gcc9.concatenated_segments overhead_variance_account,  ' ||
'            gcc10.concatenated_segments std_cost_adjustment_account,  ' ||
'            wac.completion_cost_source,  ' ||
'            wac.cost_type_id,  ' ||
'            gcc11.concatenated_segments bridging_account,  ' ||
'            wac.system_option_id,  ' ||
'            gcc12.concatenated_segments expense_account,  ' ||
'            gcc13.concatenated_segments est_scrap_account,  ' ||
'            gcc14.concatenated_segments est_scrap_var_account  ' ||
'            FROM  ' ||
'            wip_accounting_classes wac,  ' ||
'            mfg_lookups ml1,  ' ||
'            gl_code_combinations_kfv gcc1,  ' ||
'            gl_code_combinations_kfv gcc2,  ' ||
'            gl_code_combinations_kfv gcc3,  ' ||
'            gl_code_combinations_kfv gcc4,  ' ||
'            gl_code_combinations_kfv gcc5,  ' ||
'            gl_code_combinations_kfv gcc6,  ' ||
'            gl_code_combinations_kfv gcc7,  ' ||
'            gl_code_combinations_kfv gcc8,  ' ||
'            gl_code_combinations_kfv gcc9,  ' ||
'            gl_code_combinations_kfv gcc10,  ' ||
'            gl_code_combinations_kfv gcc11,  ' ||
'            gl_code_combinations_kfv gcc12,  ' ||
'            gl_code_combinations_kfv gcc13,  ' ||
'            gl_code_combinations_kfv gcc14  ' ||
'            WHERE  ' ||
'            wac.organization_id = ' || p_org_id  || ' AND  ' ||
'            wac.disable_date is null AND  ' ||
'            ml1.lookup_code = wac.class_type AND  ' ||
'            ml1.lookup_type = ''WIP_CLASS_TYPE'' AND  ' ||
'            gcc1.code_combination_id(+) = wac.material_account AND  ' ||
'            gcc2.code_combination_id(+) = wac.material_variance_account AND  ' ||
'            gcc3.code_combination_id(+) = wac.material_overhead_account AND  ' ||
'            gcc4.code_combination_id(+) = wac.resource_account AND  ' ||
'            gcc5.code_combination_id(+) = wac.resource_variance_account AND  ' ||
'            gcc6.code_combination_id(+) = wac.outside_processing_account AND  ' ||
'            gcc7.code_combination_id(+) = wac.outside_proc_variance_account AND  ' ||
'            gcc8.code_combination_id(+) = wac.overhead_account AND  ' ||
'            gcc9.code_combination_id(+) = wac.overhead_variance_account AND  ' ||
'            gcc10.code_combination_id(+) = wac.std_cost_adjustment_account AND  ' ||
'            gcc11.code_combination_id(+) = wac.bridging_account AND  ' ||
'            gcc12.code_combination_id(+) = wac.expense_account AND  ' ||
'            gcc13.code_combination_id(+) = wac.est_scrap_account AND  ' ||
'            gcc14.code_combination_id(+) = wac.est_scrap_var_account' ;

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'WIP Accounting Classes Setup',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

   if dummy_num = 0 then


      reportStr := 'No accounting classes defined for this organization.' ;

      JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr) ;

      reportStr := 'Please define the wip accounting classes for this organization. Please see the';

      JTF_DIAGNOSTIC_COREAPI.ActionErrorLink(reportStr, l_url, l_desc ,' for more information') ;

   end if ;

  end checkAccClass ;

  procedure checkBomParams is
   row_limit number;
  begin
   row_limit := 1000;
   sqltxt :=
           'SELECT  ml1.meaning   use_phantom_routings ' ||
            ',ml2.meaning   inherit_phantom_op_seq ' ||
            'FROM    bom_parameters bp, ' ||
            'mfg_lookups ml1, ' ||
            'mfg_lookups ml2 ' ||
            'WHERE   bp.organization_id =  ' || p_org_id ||
            'AND     ml1.lookup_code = bp.use_phantom_routings ' ||
            'AND     ml1.lookup_type = ''SYS_YES_NO'' ' ||
            'AND     ml2.lookup_code = bp.inherit_phantom_op_seq ' ||
            'AND     ml2.lookup_type = ''SYS_YES_NO'' ';

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'BOM Parameters',null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

  end checkBomParams ;

  procedure checkWipProdLines is
   row_limit number;
  begin
   row_limit := 1000;
   sqltxt :=
            'SELECT ' ||
            'wl.line_id, ' ||
            'wl.organization_id, ' ||
            'wl.line_code, ' ||
            'wl.description, ' ||
            'wl.disable_date, ' ||
            'wl.minimum_rate, ' ||
            'wl.maximum_rate, ' ||
            'wl.fixed_throughput, ' ||
            'ml1.meaning, ' ||
            'to_char(to_date(wl.start_time, ' ||
            '''SSSSS''), ' ||
            '''HH24:MI:SS'') start_time, ' ||
            'to_char(to_date(wl.stop_time, ' ||
            '''SSSSS''), ' ||
            '''HH24:MI:SS'') stop_time, ' ||
            'wl.scheduling_method_id, ' ||
            'wl.atp_rule_id, ' ||
            'wl.exception_set_name, ' ||
            'mar.rule_name, ' ||
            'wl.line_schedule_type ' ||
            'FROM ' ||
            'wip_lines wl, ' ||
            'mfg_lookups ml1, ' ||
            'mtl_atp_rules mar ' ||
            'WHERE ' ||
            'ml1.lookup_code = wl.line_schedule_type AND ' ||
            'ml1.lookup_type = ''WIP_LINE_SCHED_TYPE'' AND ' ||
            'wl.organization_id = ' || p_org_id || ' AND ' ||
            'mar.rule_id(+) = wl.atp_rule_id';

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Work In Process Production Lines ',null,'Y',row_limit);

   IF (dummy_num = row_limit) THEN
      JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
   END IF;

   if dummy_num = 0 then
      JTF_DIAGNOSTIC_COREAPI.Tab2Print('No production lines have been defined <BR>');
   end if ;

  end checkWipProdLines ;

  procedure checkWipSchGrps is
   row_limit number;
  begin
   row_limit := 1000;
   sqltxt :=
           'SELECT  wsg.schedule_group_name ,' ||
           '        wsg.description,' ||
           '        wsg.inactive_on ' ||
           ' FROM   wip_schedule_groups wsg ' ||
           ' WHERE  wsg.organization_id = ' || p_org_id ;

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'In Process Schedule Groups',null,'Y',row_limit);

   IF (dummy_num = row_limit) THEN
     JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
   END IF;

  end checkWipSchGrps ;

  procedure displayConcLibProcess (p_lib_name varchar2) is
   row_limit number;
  begin
   row_limit := 1000;
   sqltxt :=
         'SELECT ' ||
            'substr(fcp.concurrent_processor_name, ' ||
            '1, ' ||
            '20) NAME, ' ||
            'substr(fcq.user_concurrent_queue_name, ' ||
            '1, ' ||
            '20) USER_NAME, ' ||
            'nvl(fcq.target_node, ' ||
            '''n/a'') NODE, ' ||
            'fcq.running_processes ACTUAL, ' ||
            'fcq.max_processes TARGET, ' ||
            'nvl(fl1.meaning, ' ||
            '''Active'') STATUS, ' ||
            'fcq.control_code control_code ' ||
            'FROM ' ||
            'fnd_concurrent_queues_vl fcq, ' ||
            'fnd_application_vl fa, ' ||
            'fnd_concurrent_processors fcp, ' ||
            'fnd_lookups fl1 ' ||
            'WHERE ' ||
            'fcp.concurrent_processor_name =''' || p_lib_name || '''  and ' ||
            'fcq.enabled_flag = ''Y'' and ' ||
            'fl1.lookup_type(+) = ''CP_CONTROL_CODE'' and ' ||
            'fcq.control_code = fl1.lookup_code (+) and ' ||
            'fa.application_id = fcq.application_id and ' ||
            'fcq.application_id = fcp.application_id and ' ||
            'fcq.concurrent_processor_id = fcp.concurrent_processor_id ' ||
            'ORDER BY     decode(fcq.application_id,0,decode(fcq.concurrent_queue_id,1,1,4,2)), ' ||
            'sign(fcq.max_processes) desc, ' ||
            'fcq.concurrent_queue_name, ' ||
            'fcq.application_id';

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Concurrent Manager',null,'Y',row_limit);

   IF (dummy_num = row_limit) THEN
     JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
   END IF;

  end displayConcLibProcess ;

  procedure checkConcProcess (p_conc_name varchar2) is
   row_limit number;
  begin
   row_limit := 1000;
   sqltxt :=
            'SELECT ' ||
            'p.user_concurrent_program_name, ' ||
            'r.phase_code, ' ||
            'r.actual_completion_date ' ||
            'FROM ' ||
            'fnd_concurrent_requests r, ' ||
            'fnd_concurrent_programs_vl p ' ||
            'WHERE ' ||
            'p.concurrent_program_name = ''' || p_conc_name || ''' and ' ||
            'p.concurrent_program_id = r.concurrent_program_id(+) ' ||
            'order by nvl(r.hold_flag,''N''), ' ||
            'r.actual_completion_date desc';

   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Concurrent Manager',null,'Y',row_limit);

   IF (dummy_num = row_limit) THEN
     JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
   END IF;
  end checkConcProcess;

  procedure docReferences is
    reportStr LONG  ;
    l_doc_url     varchar2(255) ;
    l_note        varchar2(255) ;

  begin

   l_doc_url  := 'http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&'   ;

   l_note :=  l_doc_url || 'p_id=415922.1' ;
   reportStr := 'Note   : <a href= ' || l_url || '> 415922.1 </a>' ||  ' : RELEASE CONTENT DOCUMENT - Release 12 Discrete Manufacturing - Support Enhanced Version <BR>'  ;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportStr);

  end docReferences ;

  function get_org(p_org_id in NUMBER) return varchar2 is
   l_org_code varchar2(255) ;
  begin
     select organization_code
     into   l_org_code
     from   org_organization_definitions
     where  organization_id = p_org_id ;

     return  l_org_code ;
  end ;

BEGIN





/*
sqltxt := 'select default_discrete_class,'||
'       decode(lot_number_default_type,'||
'                        1,''Job Name'','||
'                        2,''Based On Inventory Rules'','||
'                        3,''No Default'', lot_number_default_type) lot_number_default_type,'||
'        decode(so_change_response_type,'||
'                        1,''Never'','||
'                        2,''Always'','||
'                        3,''When linked 1-1Default'') so_change_response_type,'||
'        decode(mandatory_scrap_flag,1,''Yes'',2,''No'') Mandatory_Scrap_Flag,'||
'        decode(dynamic_operation_insert_flag,1,''Yes'',2,''No'') Dynamic_Oprn_Insert_Flag,'||
'        decode(moves_over_no_move_statuses,1,''Yes'',2,''No'') Moves_Over_No_Move_Status,'||
'        default_pull_supply_subinv,'||
'        default_pull_supply_locator_id,'||
'        decode(backflush_lot_entry_type,'||
'                        1, ''Manual'','||
'                        2, ''Receipt Date'','||
'                        4, ''Expiration Date'','||
'                        6, ''Transaction History'', backflush_lot_entry_type) Lot_Selection_Method ,' ;
if (l_release_name  = '11.5.10') then
   null ;
elsif (l_release_name  = '11.5.9') then
   null ;
elsif (l_release_name  = '11.5.10.2')  then
   sqltxt := sqltxt ||
  '        decode(alternate_lot_selection_method,'||
  '                        1, ''Manual'','||
  '                        2, ''Receipt Date'','||
  '                        4, ''Expiration Date'' , alternate_lot_selection_method) Alternate_Lot_Selection_Method,' ;
end if ;

sqltxt := sqltxt ||

'        decode(allocate_backflush_components,''1'',''Yes'',''2'',''No'') Allocate_Backflush_Comps,'||
'        decode(allow_backflush_qty_change,1,''Yes'',2,''No'') Allow_Backflush_Qty_Change,'||
'        decode(repetitive_variance_type,1, ''All Schedules '', 2, ''Cancelled and Complete-No Charges Only'') RepVariance, ' ||
'        autorelease_days,'||
'        osp_shop_floor_status,'||
'        decode(po_creation_time,'||
'                        1, ''At Job/Schedule Release'','||
'                        2, ''At Operation'','||
'                        3, ''Manual'', po_creation_time) PO_Creation_Time,'||
'        default_overcompl_tolerance,'||
'        production_scheduler_id,'||
'        decode(material_constrained,1,''Yes'',2,''No'') Material_Constrained,'||
'        decode(use_finite_scheduler,1,''Yes'',2,''No'') Use_Finite_Scheduler'||
' from wip_parameters'||
' where organization_id  = '  || p_org_id ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'WIP Parameters SETUP');



*/
   checkWipProfiles ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   JTF_DIAGNOSTIC_COREAPI.SectionPrint('Work In Process Organization '  || get_org(p_org_id) ) ;
   checkWIPDetails ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   JTF_DIAGNOSTIC_COREAPI.SectionPrint('Item Attributes for Assemble To Order (ATO) discrete jobs') ;
   checkAtoAttributes ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   JTF_DIAGNOSTIC_COREAPI.SectionPrint('Cost Group Setup for WIP Parameters') ;
   checkCostGroup ;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   JTF_DIAGNOSTIC_COREAPI.SectionPrint('Operation moves with Pending Move Transactions') ;
   checkOpMove;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   JTF_DIAGNOSTIC_COREAPI.SectionPrint('WIP Employee Labor Rates Definition') ;
   checkEmpRate;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   -- JTF_DIAGNOSTIC_COREAPI.SectionPrint('WIP Accounting Classes Setup') ;
   checkAccClass;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   -- JTF_DIAGNOSTIC_COREAPI.SectionPrint('BOM Parameters') ;
   checkBomParams;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   -- JTF_DIAGNOSTIC_COREAPI.SectionPrint('Work In Process Production Lines') ;
   checkWipProdLines;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   -- JTF_DIAGNOSTIC_COREAPI.SectionPrint('In Process Schedule Groups') ;
   checkWipSchGrps;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

/*
   JTF_DIAGNOSTIC_COREAPI.Tab1Print('MRCLIB') ;
   displayConcLibProcess('MRCLIB');
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

   JTF_DIAGNOSTIC_COREAPI.Tab1Print('MRCRLF') ;
   checkConcProcess('MRCRLF');
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;
*/

   JTF_DIAGNOSTIC_COREAPI.SectionPrint('References') ;
   docReferences;
   JTF_DIAGNOSTIC_COREAPI.BRPrint ;

EXCEPTION
    WHEN OTHERS then

      if wip_param_csr%ISOPEN then
         close wip_param_csr ;
      end if ;

      if wip_param_v_csr%ISOPEN then
         close wip_param_v_csr ;
      end if ;

      if inv_param_csr%ISOPEN then
         close inv_param_csr ;
      end if ;
END setup ;

procedure Pending_txns (p_org_id IN NUMBER) is
 row_limit number;
BEGIN
 row_limit := 1000;

   JTF_DIAGNOSTIC_COREAPI.Display_table('WIP_COST_TXN_INTERFACE', 'Pending Resource Transactions',
                                        'where organization_id = ' || p_org_id,
                                        'order by transaction_date',
                                        'N'
                                        );
   sqltxt :=
	'select wi.transaction_date,' ||
	'       wi.transaction_id,' ||
	'       wi.wip_entity_id,' ||
	'       wi.wip_entity_name,' ||
	'       wi.process_phase,' ||
	'       wi.process_status,' ||
	'       wtie.error_column,' ||
	'       wtie.error_message ' ||
	'from   wip_cost_txn_interface wi,' ||
	'       wip_txn_interface_errors wtie ' ||
	'where  wi.transaction_id = wtie.transaction_id ' ||
        'and    wi.organization_id = ' || p_org_id  ||
	' order  by wi.transaction_date, wi.wip_entity_id, wi.wip_entity_name'  ;

   dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Pending Resource Transactions Errors',null,'Y',row_limit) ;

   IF (dummy_num = row_limit) THEN
     JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
   END IF;

   JTF_DIAGNOSTIC_COREAPI.Display_table('WIP_MOVE_TXN_INTERFACE', 'Pending Move Transactions',
                                        'where organization_id = ' || p_org_id,
                                        'order by transaction_date',
                                        'N'
                                        );
   sqltxt :=
	'select wi.transaction_date,' ||
	'       wi.transaction_id,' ||
	'       wi.wip_entity_id,' ||
	'       wi.wip_entity_name,' ||
	'       wi.process_phase,' ||
	'       wi.process_status,' ||
	'       wtie.error_column,' ||
	'       wtie.error_message ' ||
	'from   wip_move_txn_interface wi,' ||
	'       wip_txn_interface_errors wtie ' ||
	'where  wi.transaction_id = wtie.transaction_id ' ||
        'and    wi.organization_id = ' || p_org_id  ||
	' order  by wi.transaction_date, wi.wip_entity_id, wi.wip_entity_name'  ;

   dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Pending Move Transactions Errors',null,'Y',row_limit) ;

   IF (dummy_num = row_limit) THEN
     JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
   END IF;

   JTF_DIAGNOSTIC_COREAPI.Display_table('WIP_JOB_SCHEDULE_INTERFACE', 'Pending Jobs ',
                                        'where organization_id = ' || p_org_id,
                                        'order by group_id, header_id, interface_id',
                                        'N'
                                        );
   sqltxt :=
        'select wjsi.interface_id,' ||
        '       wjsi.group_id,' ||
	'       wjsi.wip_entity_id,' ||
	'       wjsi.job_name,' ||
	'       wjsi.load_type,' ||
	'       wjsi.process_phase,' ||
	'       wjsi.process_status,' ||
	'       wie.error_type,' ||
	'       wie.error ' ||
	'from   wip_job_schedule_interface wjsi,' ||
	'       wip_interface_errors wie ' ||
	'where  wjsi.interface_id = wie.interface_id ' ||
        'and    wjsi.organization_id = ' || p_org_id  ||
	' order  by wjsi.group_id, wjsi.interface_id, wjsi.wip_entity_id, wjsi.job_name' ;

   dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Pending Jobs Error',null,'Y',row_limit) ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

   JTF_DIAGNOSTIC_COREAPI.Display_table('MTL_TRANSACTIONS_INTERFACE', 'Transactions Open Interface',
                                        'where transaction_source_type_id = 5 and organization_id = ' || p_org_id ||
                                        ' and process_flag = 3',
                                        'order by transaction_date',
                                        'N'
                                        );
   JTF_DIAGNOSTIC_COREAPI.Display_table('MTL_MATERIAL_TRANSACTIONS_TEMP', 'Pending Material Transactions',
                                        'where transaction_source_type_id = 5 and organization_id = ' || p_org_id  ||
                                        ' and process_flag = ''E''  ' ,
                                        'order by transaction_date',
                                        'N'
                                        );

   JTF_DIAGNOSTIC_COREAPI.Display_table('MTL_MATERIAL_TRANSACTIONS', 'Material Transactions',
                                        'where transaction_source_type_id = 5 and organization_id = ' || p_org_id ||
                                        ' and costed_flag = ''E'' ' ,
                                        'order by transaction_date',
                                        'N'
                                        );


/*

sqltxt := 'select * from wip_cost_txn_interface where organization_id = ' || p_org_id ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'Pending Resource Transactions');
sqltxt := 'select * from wip_job_schedule_interface where organization_id = ' || p_org_id ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'Pending Mass Load Transactions');
sqltxt := 'select * from wip_job_dtls_interface ' ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'Mass Load Errors');
sqltxt := 'select * from wip_interface_errors ';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	' Interface Errors');
sqltxt := 'select * from wip_move_txn_interface where organization_id = ' || p_org_id ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'Pending Move Transactions');
sqltxt := 'select * from mtl_transactions_interface where transaction_source_type_id  =  5 and organization_id = ' || p_org_id ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'Transaction Open Interface (MTI)');
sqltxt := 'select * from mtl_material_transactions_temp where transaction_source_type_id = 5 and organization_id = ' || p_org_id ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
	'Pending Material Transactions (MMTT)');
*/

END Pending_txns ;
BEGIN
 -- Get Release level and store it in release_level
 l_result := fnd_release.get_release(release_level, other_info) ;

END WIP_DIAG_DATA_COLL  ;

/
