--------------------------------------------------------
--  DDL for Package Body INV_SHORTSTATEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SHORTSTATEMENT_PVT" AS
/* $Header: INVSSTMB.pls 120.2 2006/06/23 00:11:11 stdavid noship $*/
G_PKG_NAME		CONSTANT VARCHAR2(30) := 'INV_ShortStatement_PVT';
  -- Start OF comments
  -- API name  : BuildDetail
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
  --
  --  x_short_stat_detail OUT LONG
  --	Detail shortage statement
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE BuildDetail (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_check_wip_flag		IN NUMBER,
  p_check_oe_flag		IN NUMBER,
  p_wip_rel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_rel_jobs 	IN NUMBER,
  p_wip_unrel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_unrel_jobs IN NUMBER,
  p_wip_hold_jobs_flag		IN NUMBER,
  p_wip_rel_rep_flag		IN NUMBER,
  p_wip_days_overdue_rel_rep    IN NUMBER,
  p_wip_unrel_rep_flag		IN NUMBER,
  p_wip_days_overdue_unrel_rep  IN NUMBER,
  p_wip_hold_rep_flag		IN NUMBER,
  p_wip_req_date_jobs_flag      IN NUMBER,
  p_wip_curr_op_jobs_flag	IN NUMBER,
  p_wip_prev_op_jobs_flag	IN NUMBER,
  p_wip_req_date_rep_flag       IN NUMBER,
  p_wip_curr_op_rep_flag        IN NUMBER,
  p_wip_prev_op_rep_flag        IN NUMBER,
  p_wip_excl_bulk_comp_flag    	IN NUMBER,
  p_wip_excl_supplier_comp_flag	IN NUMBER,
  p_wip_excl_pull_comp_flag     IN NUMBER,
  x_short_stat_detail		OUT NOCOPY LONG
  )
IS
     L_api_version 	CONSTANT NUMBER := 1.0;
     L_api_name 	CONSTANT VARCHAR2(30) := 'BuildDetail';
     L_Statement	LONG;
     L_First		BOOLEAN := TRUE;
     L_Operator		VARCHAR2(10);
     L_String		VARCHAR2(255);
     L_Check_jobs	NUMBER;
     L_Check_rep	NUMBER;
     L_Order_System	VARCHAR2(10); -- The type of order entry system which is installed.
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- For WIP see whether jobs and/or schedules should be included
     IF ( p_wip_rel_jobs_flag = 1 OR p_wip_unrel_jobs_flag = 1 OR
	  p_wip_hold_jobs_flag = 1 ) THEN
        L_Check_jobs := 1;
     ELSE
	L_Check_jobs := 2;
     END IF;
     IF ( p_wip_rel_rep_flag = 1 OR p_wip_unrel_rep_flag = 1 OR
	  p_wip_hold_rep_flag = 1 ) THEN
        L_Check_rep := 1;
     ELSE
	L_Check_rep := 2;
     END IF;
     --
     -- Determine whether Order Entry or Order Management is installed.
     L_Order_System := OE_INSTALL.Get_Active_Product;
     --
     L_Statement := 'DECLARE '||FND_GLOBAL.Newline||
	      '   L_Organization_id	NUMBER; '||FND_GLOBAL.Newline||
	      '   L_Inventory_item_id	NUMBER; '||FND_GLOBAL.Newline||
	      '   L_Seq_num		NUMBER; '||FND_GLOBAL.Newline||
	      'BEGIN '||FND_GLOBAL.Newline||
	      '   L_Organization_id := :organization_id; '||FND_GLOBAL.Newline||
	      '   L_Inventory_item_id := :inventory_item_id; '||FND_GLOBAL.Newline||
	      '   L_Seq_num := :seq_num; '||FND_GLOBAL.Newline;
	IF p_check_wip_flag = 1 AND ( L_Check_jobs = 1 OR L_Check_rep = 1 ) THEN
		-- build statement
		-- select clause and general from clause
		L_Statement := L_Statement||
			'BEGIN '||FND_GLOBAL.Newline||
			'INSERT INTO mtl_short_chk_temp '||FND_GLOBAL.Newline||
			'( seq_num '||FND_GLOBAL.Newline||
			' ,organization_id '||FND_GLOBAL.Newline||
			' ,inventory_item_id '||FND_GLOBAL.Newline||
			' ,quantity_open '||FND_GLOBAL.Newline||
			' ,uom_code '||FND_GLOBAL.Newline||
			' ,object_type '||FND_GLOBAL.Newline||
			' ,object_id '||FND_GLOBAL.Newline||
 			' ,object_detail_id '||FND_GLOBAL.Newline||
			' ,last_updated_by '||FND_GLOBAL.Newline||
			' ,last_update_login '||FND_GLOBAL.Newline||
			' ,last_update_date '||FND_GLOBAL.Newline||
			' ,created_by '||FND_GLOBAL.Newline||
			' ,creation_date '||FND_GLOBAL.Newline||
			') '||FND_GLOBAL.Newline;
	--
	-- Jobs with p_inventory_item_id not null
	--
	IF L_Check_jobs = 1 THEN
		L_Statement := L_Statement||
			'SELECT '||FND_GLOBAL.Newline||
			      ' L_Seq_num '||FND_GLOBAL.Newline||
			      ',WRO.organization_id '||FND_GLOBAL.Newline||
		              ',WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      ',WRO.required_quantity-WRO.quantity_issued '||FND_GLOBAL.Newline||
			      ',MSI.primary_uom_code '||FND_GLOBAL.Newline||
			      ',1 '||FND_GLOBAL.Newline||
			      ',WRO.wip_entity_id '||FND_GLOBAL.Newline||
			      ',WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
			      ',-1 '||FND_GLOBAL.Newline||
			      ',sysdate '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
		              ',sysdate '||FND_GLOBAL.Newline||
			'FROM wip_entities WE'||FND_GLOBAL.Newline||
			    ',wip_requirement_operations WRO '||FND_GLOBAL.Newline||
			    ',mtl_system_items MSI '||FND_GLOBAL.Newline;
		-- general where clause
		L_Statement := L_Statement||
			'WHERE '||FND_GLOBAL.Newline||
			'    L_Inventory_item_id IS NOT NULL '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=MSI.inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=MSI.organization_id '||FND_GLOBAL.Newline||
			'AND NVL(MSI.check_shortages_flag,'||''''||'N'||''''||')='||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
			'AND WRO.wip_entity_id=WE.wip_entity_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=L_Organization_id '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=L_Inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.repetitive_schedule_id IS NULL '||FND_GLOBAL.Newline||
			'AND WRO.operation_seq_num>0 '||FND_GLOBAL.Newline||
		        'AND WRO.required_quantity>0 '||FND_GLOBAL.Newline||
			'AND WRO.quantity_issued>=0 '||FND_GLOBAL.Newline||
			'AND WRO.required_quantity>WRO.quantity_issued '||FND_GLOBAL.Newline;
		-- where clause: hold jobs
		IF p_wip_hold_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=6))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: released jobs (for days overdue)
		IF p_wip_rel_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WDJ.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=3'||FND_GLOBAL.Newline||
			' AND TRUNC(WDJ.scheduled_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_rel_jobs)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate)) '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: unreleased jobs (for days overdue)
		IF p_wip_unrel_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WDJ.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=1'||FND_GLOBAL.Newline||
			' AND TRUNC(WDJ.scheduled_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_unrel_jobs)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate)) '||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter required date
		IF p_wip_req_date_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' WRO.date_required<sysdate '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter current operation
		IF p_wip_curr_op_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.operation_seq_num>=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter previous operation
		IF p_wip_prev_op_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.next_operation_seq_num=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter bulk components
		IF p_wip_excl_bulk_comp_flag = 1 THEN
	             L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>4 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter supplier components
                IF p_wip_excl_supplier_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>5 '||FND_GLOBAL.Newline;
                END IF;
		-- where clause: parameter pull components
                IF p_wip_excl_pull_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type NOT IN (2,3) '||FND_GLOBAL.Newline;
                END IF;
	END IF;
	--
	-- Jobs with p_inventory_item_id null
	--
	IF L_Check_jobs = 1 THEN
		L_Statement := L_Statement||
			'UNION ALL'||FND_GLOBAL.Newline||
			'SELECT '||FND_GLOBAL.Newline||
			      ' L_Seq_num '||FND_GLOBAL.Newline||
			      ',WRO.organization_id '||FND_GLOBAL.Newline||
		              ',WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      ',WRO.required_quantity-WRO.quantity_issued '||FND_GLOBAL.Newline||
			      ',MSI.primary_uom_code '||FND_GLOBAL.Newline||
			      ',1 '||FND_GLOBAL.Newline||
			      ',WRO.wip_entity_id '||FND_GLOBAL.Newline||
			      ',WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
			      ',-1 '||FND_GLOBAL.Newline||
			      ',sysdate '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
		              ',sysdate '||FND_GLOBAL.Newline||
			'FROM wip_entities WE'||FND_GLOBAL.Newline||
			    ',wip_requirement_operations WRO '||FND_GLOBAL.Newline||
			    ',mtl_system_items MSI '||FND_GLOBAL.Newline;
		-- general where clause
		L_Statement := L_Statement||
			'WHERE '||FND_GLOBAL.Newline||
			'    L_Inventory_item_id IS NULL '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=MSI.inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=MSI.organization_id '||FND_GLOBAL.Newline||
			'AND NVL(MSI.check_shortages_flag,'||''''||'N'||''''||')='||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
			'AND WRO.wip_entity_id=WE.wip_entity_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=L_Organization_id '||FND_GLOBAL.Newline||
			'AND WRO.repetitive_schedule_id IS NULL '||FND_GLOBAL.Newline||
			'AND WRO.operation_seq_num>0 '||FND_GLOBAL.Newline||
		        'AND WRO.required_quantity>0 '||FND_GLOBAL.Newline||
			'AND WRO.quantity_issued>=0 '||FND_GLOBAL.Newline||
			'AND WRO.required_quantity>WRO.quantity_issued '||FND_GLOBAL.Newline;
		-- where clause: hold jobs
		IF p_wip_hold_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=6))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: released jobs (for days overdue)
		IF p_wip_rel_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WDJ.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=3'||FND_GLOBAL.Newline||
			' AND TRUNC(WDJ.scheduled_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_rel_jobs)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate)) '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: unreleased jobs (for days overdue)
		IF p_wip_unrel_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WDJ.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=1'||FND_GLOBAL.Newline||
			' AND TRUNC(WDJ.scheduled_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_unrel_jobs)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate)) '||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter required date
		IF p_wip_req_date_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' WRO.date_required<sysdate '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter current operation
		IF p_wip_curr_op_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.operation_seq_num>=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter previous operation
		IF p_wip_prev_op_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.next_operation_seq_num=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter bulk components
		IF p_wip_excl_bulk_comp_flag = 1 THEN
	             L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>4 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter supplier components
                IF p_wip_excl_supplier_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>5 '||FND_GLOBAL.Newline;
                END IF;
		-- where clause: parameter pull components
                IF p_wip_excl_pull_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type NOT IN (2,3) '||FND_GLOBAL.Newline;
                END IF;
	END IF;
	--
	-- Schedules with p_inventory_item_id not null
	--
        IF L_Check_rep = 1 AND L_Check_jobs = 1 THEN
                L_Statement := L_Statement||
                        'UNION ALL '||FND_GLOBAL.Newline;
        END IF;
        IF L_Check_rep = 1 THEN
                L_Statement := L_Statement||
                        'SELECT '||FND_GLOBAL.Newline||
                              ' L_Seq_num '||FND_GLOBAL.Newline||
			      ',WRO.organization_id '||FND_GLOBAL.Newline||
		              ',WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      ',INV_ShortCheckExec_PVT.get_rep_curr_open_qty '||FND_GLOBAL.Newline||
			      ' ( WRO.organization_id '||FND_GLOBAL.Newline||
			      ' , WRS.wip_entity_id '||FND_GLOBAL.Newline||
			      ' , WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			      ' , WRS.first_unit_start_date '||FND_GLOBAL.Newline||
			      ' , WRS.processing_work_days '||FND_GLOBAL.Newline||
			      ' , WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      ' , WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      ' , WRO.quantity_issued '||FND_GLOBAL.Newline||
			      ' ) '||FND_GLOBAL.Newline||
			      ',MSI.primary_uom_code '||FND_GLOBAL.Newline||
			      ',2 '||FND_GLOBAL.Newline||
			      ',WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			      ',WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
			      ',-1 '||FND_GLOBAL.Newline||
			      ',sysdate '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
		              ',sysdate '||FND_GLOBAL.Newline||
			'FROM wip_repetitive_schedules WRS'||FND_GLOBAL.Newline||
			    ',wip_requirement_operations WRO '||FND_GLOBAL.Newline||
			    ',mtl_system_items MSI '||FND_GLOBAL.Newline;
		-- general where clause
		L_Statement := L_Statement||
			'WHERE '||FND_GLOBAL.Newline||
			'    L_Inventory_item_id IS NOT NULL '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=MSI.inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=MSI.organization_id '||FND_GLOBAL.Newline||
			'AND NVL(MSI.check_shortages_flag,'||''''||'N'||''''||')='||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
			'AND WRO.repetitive_schedule_id=WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=L_Organization_id '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=L_Inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.operation_seq_num>0 '||FND_GLOBAL.Newline||
		        'AND WRO.required_quantity>0 '||FND_GLOBAL.Newline||
			'AND WRO.quantity_issued>=0 '||FND_GLOBAL.Newline||
			'AND WRO.required_quantity>WRO.quantity_issued '||FND_GLOBAL.Newline;
		-- where clause: hold schedules
		IF p_wip_hold_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' WRS.status_type=6 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: released schedules (for days overdue)
		IF p_wip_rel_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_repetitive_schedules WRS2'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WRS2.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND WRS2.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WRS2.status_type=3'||FND_GLOBAL.Newline||
			' AND TRUNC(WRS2.first_unit_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_rel_rep)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate) '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: unreleased schedules (for days overdue)
		IF p_wip_unrel_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_repetitive_schedules WRS2'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WRS2.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND WRS2.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WRS2.status_type=1'||FND_GLOBAL.Newline||
			' AND TRUNC(WRS2.first_unit_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_unrel_rep)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate) '||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter required date
		IF p_wip_req_date_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' WRO.date_required<sysdate '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter current operation
		IF p_wip_curr_op_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.operation_seq_num>=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter previous operation
		IF p_wip_prev_op_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.next_operation_seq_num=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL '||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter bulk components
		IF p_wip_excl_bulk_comp_flag = 1 THEN
	             L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>4 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter supplier components
                IF p_wip_excl_supplier_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>5 '||FND_GLOBAL.Newline;
                END IF;
		-- where clause: parameter pull components
                IF p_wip_excl_pull_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type NOT IN (2,3) '||FND_GLOBAL.Newline;
                END IF;
	END IF;
	--
	-- Schedules with p_inventory_item_id null
	--
	IF L_Check_rep = 1 THEN
		L_Statement := L_Statement||
			'UNION ALL'||FND_GLOBAL.Newline||
			'SELECT '||FND_GLOBAL.Newline||
			      ' L_Seq_num '||FND_GLOBAL.Newline||
			      ',WRO.organization_id '||FND_GLOBAL.Newline||
		              ',WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      ',INV_ShortCheckExec_PVT.get_rep_curr_open_qty '||FND_GLOBAL.Newline||
			      ' ( WRO.organization_id '||FND_GLOBAL.Newline||
			      ' , WRS.wip_entity_id '||FND_GLOBAL.Newline||
			      ' , WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			      ' , WRS.first_unit_start_date '||FND_GLOBAL.Newline||
			      ' , WRS.processing_work_days '||FND_GLOBAL.Newline||
			      ' , WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      ' , WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      ' , WRO.quantity_issued '||FND_GLOBAL.Newline||
			      ' ) '||FND_GLOBAL.Newline||
			      ',MSI.primary_uom_code '||FND_GLOBAL.Newline||
			      ',2 '||FND_GLOBAL.Newline||
			      ',WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			      ',WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
			      ',-1 '||FND_GLOBAL.Newline||
			      ',sysdate '||FND_GLOBAL.Newline||
			      ',0 '||FND_GLOBAL.Newline||
		              ',sysdate '||FND_GLOBAL.Newline||
			'FROM wip_repetitive_schedules WRS'||FND_GLOBAL.Newline||
			    ',wip_requirement_operations WRO '||FND_GLOBAL.Newline||
			    ',mtl_system_items MSI '||FND_GLOBAL.Newline;
		-- general where clause
		L_Statement := L_Statement||
			'WHERE '||FND_GLOBAL.Newline||
			'    L_Inventory_item_id IS NULL '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=MSI.inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=MSI.organization_id '||FND_GLOBAL.Newline||
			'AND NVL(MSI.check_shortages_flag,'||''''||'N'||''''||')='||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
			'AND WRS.repetitive_schedule_id=WRO.repetitive_schedule_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=L_Organization_id '||FND_GLOBAL.Newline||
			'AND WRO.operation_seq_num>0 '||FND_GLOBAL.Newline||
		        'AND WRO.required_quantity>0 '||FND_GLOBAL.Newline||
			'AND WRO.quantity_issued>=0 '||FND_GLOBAL.Newline||
			'AND WRO.required_quantity>WRO.quantity_issued '||FND_GLOBAL.Newline;
		-- where clause: hold schedules
		IF p_wip_hold_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' WRS.status_type=6 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: released schedules (for days overdue)
		IF p_wip_rel_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_repetitive_schedules WRS2'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WRS2.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND WRS2.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WRS2.status_type=3'||FND_GLOBAL.Newline||
			' AND TRUNC(WRS2.first_unit_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_rel_rep)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate) '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: unreleased schedules (for days overdue)
		IF p_wip_unrel_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_repetitive_schedules WRS2'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WRS2.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND WRS2.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WRS2.status_type=1'||FND_GLOBAL.Newline||
			' AND TRUNC(WRS2.first_unit_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_unrel_rep)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate) '||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter required date
		IF p_wip_req_date_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' WRO.date_required<sysdate '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter current operation
		IF p_wip_curr_op_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.operation_seq_num>=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter previous operation
		IF p_wip_prev_op_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.next_operation_seq_num=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter bulk components
		IF p_wip_excl_bulk_comp_flag = 1 THEN
	             L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>4 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter supplier components
                IF p_wip_excl_supplier_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>5 '||FND_GLOBAL.Newline;
                END IF;
		-- where clause: parameter pull components
                IF p_wip_excl_pull_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type NOT IN (2,3) '||FND_GLOBAL.Newline;
                END IF;
	END IF;
		L_Statement := L_Statement||
			      '; '||FND_GLOBAL.Newline||
			      'EXCEPTION '||FND_GLOBAL.Newline||
			      '  WHEN OTHERS THEN NULL; '||FND_GLOBAL.Newline||
		              'END; '||FND_GLOBAL.Newline;
	END IF;
	IF p_check_oe_flag = 1 THEN
		-- build statement
		-- Since there exist no shortage parameter for order entry
		-- we do not have to build a parameter dependent statement
		IF L_Order_System = 'OE' OR L_Order_System = 'ONT' THEN
  		  L_Statement := L_Statement ||
			'BEGIN '||FND_GLOBAL.Newline||
			'INSERT INTO mtl_short_chk_temp '||FND_GLOBAL.Newline||
			'( seq_num '||FND_GLOBAL.Newline||
			' ,organization_id '||FND_GLOBAL.Newline||
			' ,inventory_item_id '||FND_GLOBAL.Newline||
			' ,quantity_open '||FND_GLOBAL.Newline||
			' ,uom_code '||FND_GLOBAL.Newline||
			' ,object_type '||FND_GLOBAL.Newline||
			' ,object_id '||FND_GLOBAL.Newline||
 			' ,object_detail_id '||FND_GLOBAL.Newline||
			' ,last_updated_by '||FND_GLOBAL.Newline||
			' ,last_update_login '||FND_GLOBAL.Newline||
			' ,last_update_date '||FND_GLOBAL.Newline||
			' ,created_by '||FND_GLOBAL.Newline||
			' ,creation_date '||FND_GLOBAL.Newline||
			') '||FND_GLOBAL.Newline;
		END IF;
		IF L_Order_System = 'OE' THEN
		  L_Statement := L_Statement ||
 			'SELECT	'||FND_GLOBAL.Newline||
			'      L_Seq_num '||FND_GLOBAL.Newline||
			'     ,SPL.warehouse_id '||FND_GLOBAL.Newline||
			'     ,SPL.inventory_item_id '||FND_GLOBAL.Newline||
			'     ,SUM(SPLD.requested_quantity-NVL(SPLD.shipped_quantity,0)) '||FND_GLOBAL.Newline||
			'     ,SL.unit_code '||FND_GLOBAL.Newline||
			'     ,4 '||FND_GLOBAL.Newline||
			'     ,SH.header_id '||FND_GLOBAL.Newline||
			'     ,SL.line_id '||FND_GLOBAL.Newline||
			'     ,0 '||FND_GLOBAL.Newline||
			'     ,-1 '||FND_GLOBAL.Newline||
			'     ,sysdate '||FND_GLOBAL.Newline||
			'     ,0 '||FND_GLOBAL.Newline||
		        '     ,sysdate '||FND_GLOBAL.Newline||
   			'FROM  so_headers SH '||FND_GLOBAL.Newline||
        		'     ,so_lines SL '||FND_GLOBAL.Newline||
			'     ,so_line_details SLD '||FND_GLOBAL.Newline||
			'     ,so_picking_lines SPL '||FND_GLOBAL.Newline||
        		'     ,so_picking_line_details SPLD '||FND_GLOBAL.Newline||
			'     ,mtl_system_items MSI '||FND_GLOBAL.Newline||
  			'WHERE SPL.picking_header_id = 0 '||FND_GLOBAL.Newline||
    			'AND   SPL.picking_line_id = SPLD.picking_line_id '||FND_GLOBAL.Newline||
   			'AND   NVL(SPLD.released_flag,'||''''||'N'||''''||') = '||''''||'N'||''''||' '||FND_GLOBAL.Newline||
			'AND   SPLD.requested_quantity > NVL(SPLD.shipped_quantity,0) '||FND_GLOBAL.Newline||
    			'AND   SL.line_id = SPL.order_line_id '||FND_GLOBAL.Newline||
    			'AND   SH.header_id = SL.header_id '||FND_GLOBAL.Newline||
    			'AND   SLD.line_id = SL.line_id '||FND_GLOBAL.Newline||
    			'AND   SL.ordered_quantity > NVL(SL.cancelled_quantity,0) '||FND_GLOBAL.Newline||
			'AND   (SPL.inventory_item_id = L_Inventory_item_id '||FND_GLOBAL.Newline||
			' OR    L_Inventory_item_id IS NULL) '||FND_GLOBAL.Newline||
    			'AND   SPL.warehouse_id	= L_Organization_id '||FND_GLOBAL.Newline||
			'AND   SPL.inventory_item_id = MSI.inventory_item_id '||FND_GLOBAL.Newline||
			'AND   SPL.warehouse_id = MSI.organization_id '||FND_GLOBAL.Newline||
			'AND   NVL(MSI.check_shortages_flag,'||''''||'N'||''''||') = '||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
    			'AND   SL.service_parent_line_id IS NULL '||FND_GLOBAL.Newline||
    			'AND   SL.open_flag = '||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
    			'AND   SLD.released_flag = '||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
			'GROUP BY '||FND_GLOBAL.Newline||
        		'         L_Seq_num '||FND_GLOBAL.Newline||
			'	 ,SPL.warehouse_id '||FND_GLOBAL.Newline||
			'        ,SPL.inventory_item_id '||FND_GLOBAL.Newline||
			'	 ,SL.unit_code '||FND_GLOBAL.Newline||
			'	 ,4 '||FND_GLOBAL.Newline||
			'	 ,SH.header_id '||FND_GLOBAL.Newline||
			'	 ,SL.line_id '||FND_GLOBAL.Newline||
			'        ,0 '||FND_GLOBAL.Newline||
			'        ,-1 '||FND_GLOBAL.Newline||
			'        ,sysdate '||FND_GLOBAL.Newline||
			'        ,0 '||FND_GLOBAL.Newline||
		        '        ,sysdate; '||FND_GLOBAL.Newline||
			'EXCEPTION '||FND_GLOBAL.Newline||
			'  WHEN OTHERS THEN NULL; '||FND_GLOBAL.Newline||
		        'END; '||FND_GLOBAL.Newline;
		ELSE -- Order Management is installed
		  L_Statement := L_Statement ||
 			'SELECT	'||FND_GLOBAL.Newline||
			'      L_Seq_num '||FND_GLOBAL.Newline||
			'     ,wdd.organization_id '||FND_GLOBAL.Newline||
			'     ,wdd.inventory_item_id '||FND_GLOBAL.Newline||
			'     ,sum(wdd.requested_quantity) '||FND_GLOBAL.Newline||
			'     ,wdd.requested_quantity_uom '||FND_GLOBAL.Newline||
			'     ,4 '||FND_GLOBAL.Newline||
			'     ,wdd.source_header_id '||FND_GLOBAL.Newline||
			'     ,wdd.source_line_id '||FND_GLOBAL.Newline||
			'     ,0 '||FND_GLOBAL.Newline||
			'     ,-1 '||FND_GLOBAL.Newline||
			'     ,sysdate '||FND_GLOBAL.Newline||
			'     ,0 '||FND_GLOBAL.Newline||
		        '     ,sysdate '||FND_GLOBAL.Newline||
   			'FROM  wsh_delivery_details_ob_grp_v wdd '||FND_GLOBAL.Newline||
			'WHERE wdd.released_status = '|| '''' ||'B' || '''' || FND_GLOBAL.Newline||
			-- Fix bug 2115784, Notifications are sent to all planners
			-- Added the following two line to make sure the shortage_temp records
			--  are inserted only for specified org and item. Therefore, only the buyers
			--  for the specified item will be notified.
                        -- Bug 2640828. Added nvl around inventory_item_id and
			-- organization_id
			' AND  wdd.inventory_item_id = nvl(L_Inventory_item_id ,wdd.inventory_item_id)'||FND_GLOBAL.Newline||
			' AND  wdd.organization_id = nvl(L_Organization_id ,wdd.organization_id)'||FND_GLOBAL.Newline||
                        ' GROUP BY ' ||
			'      L_Seq_num '||FND_GLOBAL.Newline||
			'     ,wdd.organization_id '||FND_GLOBAL.Newline||
			'     ,wdd.inventory_item_id '||FND_GLOBAL.Newline||
			'     ,wdd.requested_quantity_uom '||FND_GLOBAL.Newline||
			'     ,4 '||FND_GLOBAL.Newline||
			'     ,wdd.source_header_id '||FND_GLOBAL.Newline||
			'     ,wdd.source_line_id '||FND_GLOBAL.Newline||
			'     ,0 '||FND_GLOBAL.Newline||
			'     ,-1 '||FND_GLOBAL.Newline||
			'     ,sysdate '||FND_GLOBAL.Newline||
			'     ,0 '||FND_GLOBAL.Newline||
		        '     ,sysdate; ' || FND_GLOBAL.Newline||
			'EXCEPTION '||FND_GLOBAL.Newline||
			'  WHEN OTHERS THEN NULL; '||FND_GLOBAL.Newline||
		        'END; '||FND_GLOBAL.Newline;
			--MR '     ,wdd.requested_quantity '||FND_GLOBAL.Newline||
		END IF;
	END IF;
     L_Statement := L_Statement||
	      'COMMIT; '||FND_GLOBAL.Newline||
	      'END; '||FND_GLOBAL.Newline;
     x_short_stat_detail := L_Statement;
     --
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
  -- Start OF comments
  -- API name  : BuildSummary
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
  --
  --  x_short_stat_sum 	 OUT LONG
  --	Summary shortage statement
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE BuildSummary (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_check_wip_flag		IN NUMBER,
  p_check_oe_flag		IN NUMBER,
  p_wip_rel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_rel_jobs 	IN NUMBER,
  p_wip_unrel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_unrel_jobs IN NUMBER,
  p_wip_hold_jobs_flag		IN NUMBER,
  p_wip_rel_rep_flag		IN NUMBER,
  p_wip_days_overdue_rel_rep    IN NUMBER,
  p_wip_unrel_rep_flag		IN NUMBER,
  p_wip_days_overdue_unrel_rep  IN NUMBER,
  p_wip_hold_rep_flag		IN NUMBER,
  p_wip_req_date_jobs_flag      IN NUMBER,
  p_wip_curr_op_jobs_flag	IN NUMBER,
  p_wip_prev_op_jobs_flag	IN NUMBER,
  p_wip_req_date_rep_flag       IN NUMBER,
  p_wip_curr_op_rep_flag        IN NUMBER,
  p_wip_prev_op_rep_flag        IN NUMBER,
  p_wip_excl_bulk_comp_flag    	IN NUMBER,
  p_wip_excl_supplier_comp_flag	IN NUMBER,
  p_wip_excl_pull_comp_flag     IN NUMBER,
  x_short_stat_sum		OUT NOCOPY LONG
  )
IS
     L_api_version CONSTANT NUMBER := 1.0;
     L_api_name CONSTANT VARCHAR2(30) := 'BuildSummary';
     L_Statement	LONG;
     L_First		BOOLEAN := TRUE;
     L_Operator		VARCHAR2(10);
     L_String		VARCHAR2(255);
     L_Check_jobs	NUMBER;
     L_Check_rep	NUMBER;
     L_Order_System	VARCHAR2(10); -- The type of order entry system which is installed.
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- For WIP see whether jobs and/or schedules should be included
     IF ( p_wip_rel_jobs_flag = 1 OR p_wip_unrel_jobs_flag = 1 OR
	  p_wip_hold_jobs_flag = 1 ) THEN
        L_Check_jobs := 1;
     ELSE
	L_Check_jobs := 2;
     END IF;
     IF ( p_wip_rel_rep_flag = 1 OR p_wip_unrel_rep_flag = 1 OR
	  p_wip_hold_rep_flag = 1 ) THEN
        L_Check_rep := 1;
     ELSE
	L_Check_rep := 2;
     END IF;
     --
     -- Determine whether Order Entry or Order Management is installed.
     L_Order_System := OE_INSTALL.Get_Active_Product;
     --
     L_Statement := 'DECLARE '||FND_GLOBAL.Newline||
	      '   L_Organization_id		NUMBER; '||FND_GLOBAL.Newline||
	      '   L_Inventory_item_id		NUMBER; '||FND_GLOBAL.Newline||
	      '   L_WIP_short_quantity		NUMBER; '||FND_GLOBAL.Newline||
	      '   L_OE_short_quantity		NUMBER; '||FND_GLOBAL.Newline||
	      '   L_WIP_jobs_short_quantity	NUMBER := 0; '||FND_GLOBAL.Newline||
	      '   L_WIP_rep_short_quantity	NUMBER := 0; '||FND_GLOBAL.Newline||
	      'BEGIN '||FND_GLOBAL.Newline||
	      '   L_Organization_id := :organization_id; '||FND_GLOBAL.Newline||
	      '   L_Inventory_item_id := :inventory_item_id; '||FND_GLOBAL.Newline||
	      '   L_WIP_short_quantity := :wip_short_quantity; '||FND_GLOBAL.Newline||
	      '   L_OE_short_quantity := :oe_short_quantity; '||FND_GLOBAL.Newline;
	IF p_check_wip_flag = 1 AND ( L_Check_jobs = 1 OR L_Check_rep =1 ) THEN
	--
	-- Jobs
	--
	IF L_Check_jobs = 1 THEN
		-- build statement
		-- select clause and general from clause
		L_Statement := L_Statement||
		      	'SELECT '||
			      'NVL(SUM(WRO.required_quantity-WRO.quantity_issued),0) '||FND_GLOBAL.Newline||
			'INTO '||FND_GLOBAL.Newline||
			'      L_WIP_jobs_short_quantity '||FND_GLOBAL.Newline||
			'FROM wip_entities WE'||FND_GLOBAL.Newline||
			    ',wip_requirement_operations WRO '||FND_GLOBAL.Newline;
		-- general where clause
		L_Statement := L_Statement||
			'WHERE WRO.wip_entity_id=WE.wip_entity_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=L_Organization_id '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=L_Inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.operation_seq_num>0 '||FND_GLOBAL.Newline||
		        'AND WRO.required_quantity>0 '||FND_GLOBAL.Newline||
			'AND WRO.quantity_issued>=0 '||FND_GLOBAL.Newline||
			'AND WRO.required_quantity>WRO.quantity_issued '||FND_GLOBAL.Newline;
		-- where clause: hold jobs
		IF p_wip_hold_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=6))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: released jobs (for days overdue)
		IF p_wip_rel_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WDJ.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=3'||FND_GLOBAL.Newline||
			' AND TRUNC(WDJ.scheduled_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_rel_jobs)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate)) '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: unreleased jobs (for days overdue)
		IF p_wip_unrel_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' (WRO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
       			' AND EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_discrete_jobs WDJ'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
			'     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WDJ.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WDJ.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
			' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WDJ.status_type=1'||FND_GLOBAL.Newline||
			' AND TRUNC(WDJ.scheduled_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_unrel_jobs)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate)) '||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter required date
		IF p_wip_req_date_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' WRO.date_required<sysdate '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter current operation
		IF p_wip_curr_op_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.operation_seq_num>=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter previous operation
		IF p_wip_prev_op_jobs_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.next_operation_seq_num=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id IS NULL'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter bulk components
		IF p_wip_excl_bulk_comp_flag = 1 THEN
	             L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>4 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter supplier components
                IF p_wip_excl_supplier_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>5 '||FND_GLOBAL.Newline;
                END IF;
		-- where clause: parameter pull components
                IF p_wip_excl_pull_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type NOT IN (2,3) '||FND_GLOBAL.Newline;
                END IF;
		L_Statement := L_Statement||
			'; '||FND_GLOBAL.Newline;
	END IF;
	--
	-- Schedules
	--
	IF L_Check_rep = 1 THEN
		-- build statement
		-- select clause and general from clause
		L_Statement := L_Statement||
		      	'SELECT'||FND_GLOBAL.Newline||
			      'NVL(SUM(INV_ShortCheckExec_PVT.get_rep_curr_open_qty '||FND_GLOBAL.Newline||
			      '           ( WRO.organization_id '||FND_GLOBAL.Newline||
			      '           , WRS.wip_entity_id '||FND_GLOBAL.Newline||
			      '           , WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			      '           , WRS.first_unit_start_date '||FND_GLOBAL.Newline||
			      '           , WRS.processing_work_days '||FND_GLOBAL.Newline||
			      '           , WRO.operation_seq_num '||FND_GLOBAL.Newline||
			      '           , WRO.inventory_item_id '||FND_GLOBAL.Newline||
			      '           , WRO.quantity_issued '||FND_GLOBAL.Newline||
			      '           ) '||FND_GLOBAL.Newline||
			      '       ) '||FND_GLOBAL.Newline||
			      '   , 0 '||FND_GLOBAL.Newline||
			      '   ) '||FND_GLOBAL.Newline||
			'INTO '||FND_GLOBAL.Newline||
			'      L_WIP_rep_short_quantity '||FND_GLOBAL.Newline||
			'FROM wip_repetitive_schedules WRS'||FND_GLOBAL.Newline||
			    ',wip_requirement_operations WRO '||FND_GLOBAL.Newline;
		-- general where clause
		L_Statement := L_Statement||
			'WHERE WRO.repetitive_schedule_id=WRS.repetitive_schedule_id '||FND_GLOBAL.Newline||
			'AND WRO.wip_entity_id=WRS.wip_entity_id '||FND_GLOBAL.Newline||
			'AND WRO.organization_id=L_Organization_id '||FND_GLOBAL.Newline||
			'AND WRO.inventory_item_id=L_Inventory_item_id '||FND_GLOBAL.Newline||
			'AND WRO.operation_seq_num>0 '||FND_GLOBAL.Newline||
		        'AND WRO.required_quantity>0 '||FND_GLOBAL.Newline||
			'AND WRO.quantity_issued>=0 '||FND_GLOBAL.Newline||
			'AND WRO.required_quantity>WRO.quantity_issued '||FND_GLOBAL.Newline;
		-- where clause: hold schedules
		IF p_wip_hold_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' WRS.status_type=6 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: released schedules (for days overdue)
		IF p_wip_rel_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_repetitive_schedules WRS2'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WRS2.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND WRS2.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WRS2.status_type=3'||FND_GLOBAL.Newline||
			' AND TRUNC(WRS2.first_unit_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_rel_rep)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate) '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: unreleased schedules (for days overdue)
		IF p_wip_unrel_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
        		' EXISTS'||FND_GLOBAL.Newline||
       			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_repetitive_schedules WRS2'||FND_GLOBAL.Newline||
			'     ,mtl_parameters MP'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD1'||FND_GLOBAL.Newline||
                        '     ,bom_calendar_dates BCD2'||FND_GLOBAL.Newline||
			' WHERE WRS2.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND WRS2.organization_id=MP.organization_id'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD1.calendar_code'||FND_GLOBAL.Newline||
                        ' AND MP.calendar_code=BCD2.calendar_code'||FND_GLOBAL.Newline||
        		' AND WRS2.status_type=1'||FND_GLOBAL.Newline||
			' AND TRUNC(WRS2.first_unit_start_date)=BCD1.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD1.calendar_date+NVL('||
			TO_CHAR(p_wip_days_overdue_unrel_rep)||',0)=BCD2.calendar_date'||FND_GLOBAL.Newline||
			' AND BCD2.calendar_date<=sysdate) '||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		     L_First := TRUE;
		END IF;
		-- where clause: parameter required date
		IF p_wip_req_date_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' WRO.date_required<sysdate '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter current operation
		IF p_wip_curr_op_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.operation_seq_num>=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter previous operation
		IF p_wip_prev_op_rep_flag = 1 THEN
		     IF L_First THEN
			L_First := FALSE;
 			L_Operator := 'AND ( ';
		     ELSE L_Operator := 'OR ';
		     END IF;
		     L_Statement := L_Statement||L_Operator||
			' EXISTS'||FND_GLOBAL.Newline||
			' (SELECT '||''''||'X'||''''||' '||FND_GLOBAL.Newline||
			' FROM wip_operations WO'||FND_GLOBAL.Newline||
			' WHERE WO.wip_entity_id=WRO.wip_entity_id'||FND_GLOBAL.Newline||
			' AND WO.next_operation_seq_num=WRO.operation_seq_num'||FND_GLOBAL.Newline||
			' AND WO.repetitive_schedule_id=WRO.repetitive_schedule_id'||FND_GLOBAL.Newline||
			' AND (WO.quantity_in_queue>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_running>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_waiting_to_move>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_rejected>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_scrapped>0'||FND_GLOBAL.Newline||
			' OR   WO.quantity_completed>0))'||FND_GLOBAL.Newline;
		END IF;
		IF NOT L_First THEN
		     L_Statement := L_Statement||')'||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter bulk components
		IF p_wip_excl_bulk_comp_flag = 1 THEN
	             L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>4 '||FND_GLOBAL.Newline;
		END IF;
		-- where clause: parameter supplier components
                IF p_wip_excl_supplier_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type<>5 '||FND_GLOBAL.Newline;
                END IF;
		-- where clause: parameter pull components
                IF p_wip_excl_pull_comp_flag = 1 THEN
                     L_Statement := L_Statement||
                        ' AND WRO.wip_supply_type NOT IN (2,3) '||FND_GLOBAL.Newline;
                END IF;
	    L_Statement := L_Statement||
		'; '||FND_GLOBAL.Newline;
	  END IF;
	  L_Statement := L_Statement||
		':wip_short_quantity := L_WIP_jobs_short_quantity '||FND_GLOBAL.Newline||
		'			+ L_WIP_rep_short_quantity; '||FND_GLOBAL.Newline;
	END IF;
	IF p_check_oe_flag = 1 THEN
	   -- build statement
	   -- Since there exist no shortage parameters for order entry
	   -- we do not have to build a parameter dependent statement
	   IF L_Order_System = 'OE' OR L_Order_System = 'ONT' THEN
  	     IF L_Order_System = 'OE' THEN
		L_Statement := L_Statement ||
 			'SELECT	'||FND_GLOBAL.Newline||
			'      NVL(SUM(DECODE(SL.unit_code, '||FND_GLOBAL.Newline||
			'	MSI.primary_uom_code, (SPLD.requested_quantity - NVL(SPLD.shipped_quantity,0)), '||FND_GLOBAL.Newline||
			'	INV_CONVERT.INV_UM_CONVERT ( '||FND_GLOBAL.Newline||
			'		 SPL.inventory_item_id '||FND_GLOBAL.Newline||
			'		,NULL '||FND_GLOBAL.Newline||
			'		,(SPLD.requested_quantity - NVL(SPLD.shipped_quantity,0))'||FND_GLOBAL.Newline||
			'		,SL.unit_code '||FND_GLOBAL.Newline||
			'		,MSI.primary_uom_code '||FND_GLOBAL.Newline||
			'		,NULL '||FND_GLOBAL.Newline||
			'		,NULL ) ) ),0) '||FND_GLOBAL.Newline||
			'INTO '||FND_GLOBAL.Newline||
			'      :oe_short_quantity '||FND_GLOBAL.Newline||
   			'FROM  so_headers SH '||FND_GLOBAL.Newline||
        		'     ,so_lines SL '||FND_GLOBAL.Newline||
			'     ,so_line_details SLD '||FND_GLOBAL.Newline||
			'     ,so_picking_lines SPL '||FND_GLOBAL.Newline||
        		'     ,so_picking_line_details SPLD '||FND_GLOBAL.Newline||
			'     ,mtl_system_items MSI '||FND_GLOBAL.Newline||
  			'WHERE SPL.picking_header_id = 0 '||FND_GLOBAL.Newline||
    			'AND   SPL.picking_line_id = SPLD.picking_line_id '||FND_GLOBAL.Newline||
   			'AND   NVL(SPLD.released_flag,'||''''||'N'||''''||') = '||''''||'N'||''''||' '||FND_GLOBAL.Newline||
			'AND   SPLD.requested_quantity > NVL(SPLD.shipped_quantity,0) '||FND_GLOBAL.Newline||
    			'AND   SL.line_id = SPL.order_line_id '||FND_GLOBAL.Newline||
    			'AND   SH.header_id = SL.header_id '||FND_GLOBAL.Newline||
    			'AND   SLD.line_id = SL.line_id '||FND_GLOBAL.Newline||
    			'AND   SL.ordered_quantity > NVL(SL.cancelled_quantity,0) '||FND_GLOBAL.Newline||
			'AND   SPL.inventory_item_id = MSI.inventory_item_id '||FND_GLOBAL.Newline||
			'AND   MSI.organization_id = L_Organization_id '||FND_GLOBAL.Newline||
    			'AND   SPL.inventory_item_id = L_Inventory_item_id '||FND_GLOBAL.Newline||
    			'AND   SPLD.warehouse_id = L_Organization_id '||FND_GLOBAL.Newline||
    			'AND   SL.service_parent_line_id IS NULL '||FND_GLOBAL.Newline||
    			'AND   SL.open_flag = '||''''||'Y'||''''||' '||FND_GLOBAL.Newline||
    			'AND   SLD.released_flag = '||''''||'Y'||''''||'; '||FND_GLOBAL.Newline;
	     ELSE -- Order management system is installed
		L_Statement := L_Statement ||
 			'SELECT	'||FND_GLOBAL.Newline||
			'      NVL(sum(DECODE(wdd.requested_quantity_uom, '||FND_GLOBAL.Newline||
			'	MSI.primary_uom_code, wdd.requested_quantity, '||FND_GLOBAL.Newline||
			'	INV_CONVERT.INV_UM_CONVERT ( '||FND_GLOBAL.Newline||
			'		 wdd.inventory_item_id '||FND_GLOBAL.Newline||
			'		,NULL '||FND_GLOBAL.Newline||
			'		,wdd.requested_quantity '||FND_GLOBAL.Newline||
			'		,wdd.requested_quantity_uom '||FND_GLOBAL.Newline||
			'		,MSI.primary_uom_code '||FND_GLOBAL.Newline||
			'		,NULL '||FND_GLOBAL.Newline||
			'		,NULL ) ) ),0) '||FND_GLOBAL.Newline||
			'INTO '||FND_GLOBAL.Newline||
			'      :oe_short_quantity '||FND_GLOBAL.Newline||
   			'FROM  wsh_delivery_details_ob_grp_v wdd '||FND_GLOBAL.Newline||
			'     ,mtl_system_items MSI '||FND_GLOBAL.Newline||
			'WHERE wdd.inventory_item_id = L_Inventory_item_id '||FND_GLOBAL.Newline||
			'AND   MSI.inventory_item_id = wdd.inventory_item_id '||FND_GLOBAL.Newline||
			'AND   MSI.organization_id = L_Organization_id '||FND_GLOBAL.Newline||
			'AND   wdd.organization_id = L_Organization_id '||FND_GLOBAL.Newline||
			-- Fix bug 2101710, short alert appears even for not backordered sales order
			-- added the following line to query only the backordered lines.
			-- this is to make the where clauses consistent with the detail statements
			'AND   wdd.released_status = '|| '''' ||'B' || '''' || FND_GLOBAL.Newline||
			'AND   (wdd.requested_quantity IS NOT NULL ' ||FND_GLOBAL.Newline||
			'AND   wdd.requested_quantity > 0); '||FND_GLOBAL.Newline;
			--'AND   MOL.quantity - NVL(MOL.quantity_detailed,0) > 0; '||FND_GLOBAL.Newline;
	     END IF;
	   END IF;
	END IF;
     L_Statement := L_Statement||
	      'END; '||FND_GLOBAL.Newline;
     x_short_stat_sum := L_Statement;
     --
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
  -- Start OF comments
  -- API name  : InsertUpdate
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE InsertUpdate (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_short_stat_sum		IN LONG,
  p_short_stat_detail		IN LONG
  )
IS
     CURSOR crsStatement ( p_organization_id	NUMBER,
			   p_detail_sum_flag	NUMBER ) IS
	SELECT 	1
	FROM	mtl_short_chk_statements
	WHERE	organization_id	= p_organization_id
	AND	detail_sum_flag	= p_detail_sum_flag;
     --
     L_api_version 		CONSTANT NUMBER := 1.0;
     L_api_name 		CONSTANT VARCHAR2(30) := 'InsertUpdate';
     L_Object_Exists 		NUMBER;
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- Insert/Update of shortage statement table
     -- First the detail statement
     OPEN crsStatement ( p_organization_id,
			 1 );
     FETCH crsStatement INTO L_Object_Exists;
     IF crsStatement%NOTFOUND THEN
     	INSERT INTO mtl_short_chk_statements (
		organization_id,
		detail_sum_flag,
		short_statement,
		last_updated_by,
		last_update_login,
		last_update_date,
		created_by,
		creation_date
        )
        VALUES (
		p_organization_id,
		1,
		p_short_stat_detail,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.LOGIN_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		sysdate
        );
     ELSE
     UPDATE 	mtl_short_chk_statements
     SET	short_statement 	= p_short_stat_detail,
	        last_update_date	= sysdate,
	        last_updated_by		= FND_GLOBAL.USER_ID,
	        last_update_login	= FND_GLOBAL.LOGIN_ID
     WHERE	organization_id		= p_organization_id
     AND	detail_sum_flag		= 1;
     END IF;
     CLOSE crsStatement;
     -- Then the summary statement
     OPEN crsStatement ( p_organization_id,
			 2 );
     FETCH crsStatement INTO L_Object_Exists;
     IF crsStatement%NOTFOUND THEN
     	INSERT INTO mtl_short_chk_statements (
		organization_id,
		detail_sum_flag,
		short_statement,
		last_updated_by,
		last_update_login,
		last_update_date,
		created_by,
		creation_date
        )
        VALUES (
		p_organization_id,
		2,
		p_short_stat_sum,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.LOGIN_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		sysdate
        );
     ELSE
     UPDATE 	mtl_short_chk_statements
     SET	short_statement 	= p_short_stat_sum,
	        last_update_date	= sysdate,
	        last_updated_by		= FND_GLOBAL.USER_ID,
	        last_update_login	= FND_GLOBAL.LOGIN_ID
     WHERE	organization_id		= p_organization_id
     AND	detail_sum_flag		= 2;
     END IF;
     CLOSE crsStatement;
     --
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
  -- Start OF comments
  -- API name  : StartBuild
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --  p_commit           IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE
  --
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
  --
  --  x_short_stat_sum	 OUT LONG,
  --	Summary shortage statement
  --
  --  x_short_stat_detail OUT LONG
  --	Detail shortage statement
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE StartBuild (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit 			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_check_wip_flag		IN NUMBER,
  p_check_oe_flag		IN NUMBER,
  p_wip_rel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_rel_jobs 	IN NUMBER,
  p_wip_unrel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_unrel_jobs IN NUMBER,
  p_wip_hold_jobs_flag		IN NUMBER,
  p_wip_rel_rep_flag		IN NUMBER,
  p_wip_days_overdue_rel_rep    IN NUMBER,
  p_wip_unrel_rep_flag		IN NUMBER,
  p_wip_days_overdue_unrel_rep  IN NUMBER,
  p_wip_hold_rep_flag		IN NUMBER,
  p_wip_req_date_jobs_flag      IN NUMBER,
  p_wip_curr_op_jobs_flag	IN NUMBER,
  p_wip_prev_op_jobs_flag	IN NUMBER,
  p_wip_req_date_rep_flag       IN NUMBER,
  p_wip_curr_op_rep_flag        IN NUMBER,
  p_wip_prev_op_rep_flag        IN NUMBER,
  p_wip_excl_bulk_comp_flag    	IN NUMBER,
  p_wip_excl_supplier_comp_flag	IN NUMBER,
  p_wip_excl_pull_comp_flag     IN NUMBER
  )
IS
     L_api_version 		CONSTANT NUMBER := 1.0;
     L_api_name 		CONSTANT VARCHAR2(30) := 'StartBuild';
     L_Short_stat_sum		LONG;
     L_Short_stat_detail	LONG;
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     BuildDetail (
	p_api_version			=> 1.0,
  	p_init_msg_list			=> p_init_msg_list,
  	x_return_status			=> x_return_status,
  	x_msg_count			=> x_msg_count,
  	x_msg_data			=> x_msg_data,
  	p_organization_id		=> p_organization_id,
  	p_check_wip_flag		=> p_check_wip_flag,
  	p_check_oe_flag			=> p_check_oe_flag,
  	p_wip_rel_jobs_flag		=> p_wip_rel_jobs_flag,
	p_wip_days_overdue_rel_jobs   	=> p_wip_days_overdue_rel_jobs,
  	p_wip_unrel_jobs_flag		=> p_wip_unrel_jobs_flag,
  	p_wip_days_overdue_unrel_jobs 	=> p_wip_days_overdue_unrel_jobs,
  	p_wip_hold_jobs_flag		=> p_wip_hold_jobs_flag,
  	p_wip_rel_rep_flag		=> p_wip_rel_rep_flag,
	p_wip_days_overdue_rel_rep    	=> p_wip_days_overdue_rel_rep,
  	p_wip_unrel_rep_flag		=> p_wip_unrel_rep_flag,
  	p_wip_days_overdue_unrel_rep 	=> p_wip_days_overdue_unrel_rep,
  	p_wip_hold_rep_flag		=> p_wip_hold_rep_flag,
        p_wip_req_date_jobs_flag        => p_wip_req_date_jobs_flag,
  	p_wip_curr_op_jobs_flag		=> p_wip_curr_op_jobs_flag,
  	p_wip_prev_op_jobs_flag		=> p_wip_prev_op_jobs_flag,
	p_wip_req_date_rep_flag        	=> p_wip_req_date_rep_flag,
        p_wip_curr_op_rep_flag         	=> p_wip_curr_op_rep_flag,
        p_wip_prev_op_rep_flag         	=> p_wip_prev_op_rep_flag,
  	p_wip_excl_bulk_comp_flag 	=> p_wip_excl_bulk_comp_flag,
  	p_wip_excl_supplier_comp_flag 	=> p_wip_excl_supplier_comp_flag,
	p_wip_excl_pull_comp_flag   	=> p_wip_excl_pull_comp_flag,
  	x_short_stat_detail		=> L_Short_stat_detail
     );
     BuildSummary (
	p_api_version			=> 1.0,
  	p_init_msg_list			=> p_init_msg_list,
  	x_return_status			=> x_return_status,
  	x_msg_count			=> x_msg_count,
  	x_msg_data			=> x_msg_data,
  	p_organization_id		=> p_organization_id,
  	p_check_wip_flag		=> p_check_wip_flag,
  	p_check_oe_flag			=> p_check_oe_flag,
  	p_wip_rel_jobs_flag		=> p_wip_rel_jobs_flag,
	p_wip_days_overdue_rel_jobs   	=> p_wip_days_overdue_rel_jobs,
  	p_wip_unrel_jobs_flag		=> p_wip_unrel_jobs_flag,
  	p_wip_days_overdue_unrel_jobs 	=> p_wip_days_overdue_unrel_jobs,
  	p_wip_hold_jobs_flag		=> p_wip_hold_jobs_flag,
  	p_wip_rel_rep_flag		=> p_wip_rel_rep_flag,
	p_wip_days_overdue_rel_rep    	=> p_wip_days_overdue_rel_rep,
  	p_wip_unrel_rep_flag		=> p_wip_unrel_rep_flag,
  	p_wip_days_overdue_unrel_rep 	=> p_wip_days_overdue_unrel_rep,
  	p_wip_hold_rep_flag		=> p_wip_hold_rep_flag,
        p_wip_req_date_jobs_flag        => p_wip_req_date_jobs_flag,
  	p_wip_curr_op_jobs_flag		=> p_wip_curr_op_jobs_flag,
  	p_wip_prev_op_jobs_flag		=> p_wip_prev_op_jobs_flag,
	p_wip_req_date_rep_flag        	=> p_wip_req_date_rep_flag,
        p_wip_curr_op_rep_flag         	=> p_wip_curr_op_rep_flag,
        p_wip_prev_op_rep_flag         	=> p_wip_prev_op_rep_flag,
  	p_wip_excl_bulk_comp_flag 	=> p_wip_excl_bulk_comp_flag,
  	p_wip_excl_supplier_comp_flag 	=> p_wip_excl_supplier_comp_flag,
	p_wip_excl_pull_comp_flag   	=> p_wip_excl_pull_comp_flag,
  	x_short_stat_sum		=> L_Short_stat_sum
     );
     InsertUpdate (
  	p_api_version			=> 1.0,
  	p_init_msg_list			=> p_init_msg_list ,
  	x_return_status			=> x_return_status,
  	x_msg_count			=> x_msg_count,
  	x_msg_data			=> x_msg_data,
  	p_organization_id		=> p_organization_id,
  	p_short_stat_sum		=> L_Short_stat_sum,
  	p_short_stat_detail		=> L_Short_stat_detail
     );
     --
     -- Standard check of p_commit
     IF FND_API.to_Boolean(p_commit) THEN
        COMMIT;
     END IF;
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
END INV_ShortStatement_PVT;

/
