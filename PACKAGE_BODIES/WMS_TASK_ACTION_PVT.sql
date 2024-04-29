--------------------------------------------------------
--  DDL for Package Body WMS_TASK_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_ACTION_PVT" AS
   /* $Header: WMSTACPB.pls 120.6.12010000.2 2009/03/25 09:17:31 mitgupta ship $ */
	l_is_unreleased			BOOLEAN;
	l_is_pending			BOOLEAN;
	l_is_queued			BOOLEAN;
	l_is_dispatched			BOOLEAN;
	l_is_active			BOOLEAN;
	l_is_loaded			BOOLEAN;
	l_is_completed			BOOLEAN;
	l_include_inbound		BOOLEAN;
	l_include_outbound		BOOLEAN;
   l_include_crossdock		BOOLEAN;
	l_include_manufacturing		BOOLEAN;
	l_include_warehousing		BOOLEAN;
	l_include_sales_orders		BOOLEAN;
	l_include_internal_orders	BOOLEAN;
	l_include_replenishment		BOOLEAN;
	l_include_mo_transfer		BOOLEAN;
	l_include_mo_issue		BOOLEAN;
	l_include_lpn_putaway		BOOLEAN;
	l_include_staging_move		BOOLEAN;
	l_include_cycle_count		BOOLEAN;
	l_is_pending_plan		BOOLEAN;
	l_is_inprogress_plan		BOOLEAN;
	l_is_completed_plan		BOOLEAN;
	l_is_cancelled_plan		BOOLEAN;
	l_is_aborted_plan		BOOLEAN;
	l_query_independent_tasks	BOOLEAN;
	l_query_planned_tasks		BOOLEAN;

	l_organization_id		NUMBER;
	l_subinventory			VARCHAR2(240);
	l_locator_id			NUMBER;
	l_to_subinventory		VARCHAR2(240);
	l_to_locator_id			NUMBER;
	l_inventory_item_id		NUMBER;
	l_category_set_id		NUMBER;
	l_item_category_id		NUMBER;
	l_employee_id			NUMBER;
	l_equipment_type_id		NUMBER;
	l_equipment			VARCHAR2(240);
	l_user_task_type_id		NUMBER;
	l_from_task_quantity		NUMBER;
	l_to_task_quantity		NUMBER;
	l_from_task_priority		NUMBER;
	l_to_task_priority		NUMBER;
	l_from_creation_date		DATE;
	l_to_creation_date		DATE;
	l_from_purchase_order		VARCHAR2(240);
	l_from_po_header_id		NUMBER;
	l_to_purchase_order		VARCHAR2(240);
	l_to_po_header_id		NUMBER;
	l_from_rma			VARCHAR2(240);
	l_from_rma_header_id		NUMBER;
	l_to_rma			VARCHAR2(240);
	l_to_rma_header_id		NUMBER;
	l_from_requisition		VARCHAR2(240);
	l_from_requisition_header_id	NUMBER;
	l_to_requisition		VARCHAR2(240);
	l_to_requisition_header_id	NUMBER;
	l_from_shipment			VARCHAR2(240);
	l_to_shipment			VARCHAR2(240);
	l_from_sales_order_id		NUMBER;
	l_to_sales_order_id		NUMBER;
	l_from_pick_slip		NUMBER;
	l_to_pick_slip			NUMBER;
	l_customer_id			NUMBER;
	l_customer_category		VARCHAR2(240);
	l_delivery_id			NUMBER;
	l_carrier_id			NUMBER;
	l_ship_method_code		VARCHAR2(240);
	l_trip_id			NUMBER;
	l_shipment_priority		VARCHAR2(240);
	l_from_shipment_date  		DATE;
	l_to_shipment_date  		DATE;
	l_ship_to_state			VARCHAR2(240);
	l_ship_to_country		VARCHAR2(240);
	l_ship_to_postal_code		VARCHAR2(240);
	l_from_lines_in_sales_order	NUMBER;
	l_to_lines_in_sales_order	NUMBER;
	l_manufacturing_type		VARCHAR2(240);
	l_from_job			VARCHAR2(240);
	l_to_job			VARCHAR2(240);
	l_assembly_id			NUMBER;
	l_from_start_date  		DATE;
	l_to_start_date  		DATE;
	l_from_line			VARCHAR2(240);
	l_to_line			VARCHAR2(240);
	l_department_id			NUMBER;
	l_from_replenishment_mo		VARCHAR2(240);
	l_to_replenishment_mo		VARCHAR2(240);
	l_from_transfer_issue_mo	VARCHAR2(240);
	l_to_transfer_issue_mo		VARCHAR2(240);
	l_cycle_count_name		VARCHAR2(240);
	l_op_plan_activity_id		NUMBER;
	l_op_plan_type_id		NUMBER;
	l_op_plan_id			NUMBER;

	l_action_description		VARCHAR2(1000);
	l_tasks_total			NUMBER;
	l_action_type			VARCHAR2(10);
	l_status			VARCHAR2(60);
	l_status_code			NUMBER;
	l_priority_type			VARCHAR2(10);
	l_priority			NUMBER;
	l_clear_priority		VARCHAR2(100);
	l_assign_type			VARCHAR2(100);
	l_employee			VARCHAR2(100);
	l_user_task_type		VARCHAR2(100);
	l_effective_start_date		DATE;
	l_effective_end_date		DATE;
	l_person_resource_id		NUMBER;
	l_person_resource_code		VARCHAR2(100);
	l_override_emp_check		BOOLEAN;

	l_return_status			VARCHAR2(1);
	l_temp_query			BOOLEAN;
	l_temp_action			BOOLEAN;
	l_wave_header_id		NUMBER;
PROCEDURE DEBUG
(
	p_message   VARCHAR2,
	p_module    VARCHAR2 DEFAULT 'WMS_TASK_ACTION_PVT'
)
IS
	l_counter   NUMBER := 1;
	i NUMBER ;
BEGIN
	WHILE l_counter < LENGTH (p_message)
	LOOP
		inv_log_util.TRACE (SUBSTR (p_message, l_counter, 80), p_module);
		l_counter := l_counter + 80;
	END LOOP;
	RETURN;
END DEBUG;

PROCEDURE GET_TRANSACTION_TASK_IDS
(	p_task_type_id			IN		NUMBER,
	p_transaction_temp_id_tbl	OUT NOCOPY	wms_waveplan_tasks_pvt.transaction_temp_table_type,
	p_task_type_id_table		OUT NOCOPY	wms_waveplan_tasks_pvt.task_type_id_table_type,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_return_message		OUT NOCOPY	VARCHAR2
)
IS
	i			NUMBER;
	l_transaction_temp_id	wms_waveplan_tasks_temp.transaction_temp_id%type;
	l_task_type_id		wms_waveplan_tasks_temp.task_type_id%type;
	CURSOR	c_transaction_task_ids( p_task_type_id NUMBER)
	IS
		SELECT  DISTINCT transaction_temp_id
		FROM	wms_waveplan_tasks_temp
		WHERE	task_type_id = p_task_type_id;
BEGIN
	DEBUG( 'Inside GET_TRANSACTION_TASK_IDS procedure.');
	DEBUG( 'p_task_type_id = ' || p_task_type_id);
	i:= 1;
	l_task_type_id := p_task_type_id;

	DEBUG( 'Pupulating transaction id table');

	FOR rec_ids IN c_transaction_task_ids( p_task_type_id )
	LOOP
		l_transaction_temp_id := rec_ids.transaction_temp_id;
		p_transaction_temp_id_tbl(i) := l_transaction_temp_id;
		p_task_type_id_table(i) := l_task_type_id;
		 i := i+1;
	END LOOP;

	DEBUG( 'Transaction id table populated');

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting GET_TRANSACTION_TASK_IDS');

EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.GET_TRANSACTION_TASK_IDS. '
					|| 'Oracle error message is ' || SQLERRM;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM , 'WMS_TASK_ACTION_PVT.SUBMIT_REQUEST' );
END GET_TRANSACTION_TASK_IDS;

PROCEDURE UPDATE_TASK
(	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
	l_transaction_temp_id_tbl	wms_waveplan_tasks_pvt.transaction_temp_table_type;
	l_task_type_id_table		wms_waveplan_tasks_pvt.task_type_id_table_type;
	l_result			wms_waveplan_tasks_pvt.result_table_type;
	l_message			wms_waveplan_tasks_pvt.message_table_type;
	l_task_id			wms_waveplan_tasks_pvt.task_id_table_type;
	l_return_msg			VARCHAR2( 120);
	l_msg_count			NUMBER;
	l_task_type_id			NUMBER;
	l_return_message		VARCHAR2( 4000 );

	CURSOR	c_task_type_id
	IS
		SELECT	distinct to_number(wwtt.task_type_id) task_type_id,
			mfl.meaning
		FROM	wms_waveplan_tasks_temp wwtt,
			mfg_lookups mfl
		WHERE	wwtt.task_type_id = mfl.lookup_code
		AND	mfl.lookup_type = 'WMS_TASK_TYPES';
BEGIN
	DEBUG( 'Inside UPDATE_TASK');
	DEBUG( 'Opening cursor c_task_type_id');

	FOR rec_task_type_id in c_task_type_id
	LOOP
		l_task_type_id := rec_task_type_id.task_type_id;

		DEBUG( 'Calling GET_TRANSACTION_TASK_IDS');
		DEBUG( 'Task type id passed = ' || l_task_type_id );
		--Calling GET_TRANSACTION_TASK_IDS to get transaction_temp_id and saved_action_type

		GET_TRANSACTION_TASK_IDS
		(
			p_task_type_id			=> l_task_type_id,
			p_transaction_temp_id_tbl	=> l_transaction_temp_id_tbl,
			p_task_type_id_table		=> l_task_type_id_table,
			x_return_status			=> l_return_status,
			x_return_message		=> l_return_message
		);

		DEBUG( 'GET_TRANSACTION_TASK_IDS return status = ' || l_return_status );
		DEBUG( 'GET_TRANSACTION_TASK_IDS return message = ' || l_return_message );

		IF l_return_status = fnd_api.g_ret_sts_error OR
		   l_return_status = fnd_api.g_ret_sts_unexp_error
		THEN
			DEBUG (' Error in GET_TRANSACTION_TASK_IDS ' );
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_return_message:= ( 'GET_TRANSACTION_TASK_IDS returned with Error status.'
						||' Error message is ' || l_return_message);
			return;
		END IF;

		DEBUG( 'Task_Type_Id = ' || l_task_type_id );
		DEBUG( 'Task Type in process = ' || rec_task_type_id.meaning );
		DEBUG( 'No of tasks to be updated = ' || l_transaction_temp_id_tbl.count );

		IF ( ( l_transaction_temp_id_tbl.count > 0 ) and ( l_task_type_id_table.count > 0 ) )
		THEN
			/* Bug 5485730 - The employee details should be null if the status is being updated
			                 to Pending or Unreleased */
			IF l_status_code IN (1,8) THEN
			  l_employee	         := NULL;
			  l_employee_id	         := NULL;
			  l_user_task_type       := NULL;
			  l_user_task_type_id    := NULL;
			  l_effective_start_date := NULL;
			  l_effective_end_date   := NULL;
			  l_person_resource_id   := NULL;
			  l_person_resource_code := NULL;
			END IF;
			/* End of Bug 5485730 */
			--call update task
			DEBUG( 'Calling WMS_WAVEPLAN_TASKS_PVT.UPDATE_TASK');
			DEBUG( 'Following are the input parameters');
			DEBUG( 'p_employee		=> ' || l_employee);
			DEBUG( 'p_employee_id		=> ' || l_employee_id);
			DEBUG( 'p_user_task_type	=> ' || l_user_task_type);
			DEBUG( 'p_user_task_type_id	=> ' || l_user_task_type_id);
			DEBUG( 'p_effective_start_date	=> ' || l_effective_start_date);
			DEBUG( 'p_effective_end_date	=> ' || l_effective_end_date);
			DEBUG( 'p_person_resource_id	=> ' || l_person_resource_id);
			DEBUG( 'p_person_resource_code	=> ' || l_person_resource_code);
			DEBUG( 'p_to_status		=> ' || l_status);
			DEBUG( 'p_to_status_id		=> ' || l_status_code);
			DEBUG( 'p_update_priority_type	=> ' || l_priority_type);
			DEBUG( 'p_update_priority	=> ' || l_priority);
			DEBUG( 'p_clear_priority	=> ' || l_clear_priority);

			IF l_override_emp_check = TRUE
			THEN
				DEBUG( 'p_force_employee_change	=> TRUE');
			ELSE
				DEBUG( 'p_force_employee_change	=> FALSE');
			END IF;

			wms_waveplan_tasks_pvt.update_task
			(
				p_transaction_temp_id	=> l_transaction_temp_id_tbl,
				p_task_type_id		=> l_task_type_id_table,
				p_employee		=> l_employee,
				p_employee_id		=> l_employee_id,
				p_user_task_type	=> l_user_task_type,
				p_user_task_type_id	=> l_user_task_type_id,
				p_effective_start_date	=> l_effective_start_date,
				p_effective_end_date	=> l_effective_end_date,
				p_person_resource_id	=> l_person_resource_id,
				p_person_resource_code	=> l_person_resource_code,
				p_force_employee_change	=> l_override_emp_check,
				p_to_status		=> l_status,
				p_to_status_id		=> l_status_code,
				p_update_priority_type	=> l_priority_type,
				p_update_priority	=> l_priority,
				p_clear_priority	=> l_clear_priority,
				x_result		=> l_result,
				x_message		=> l_message,
				x_task_id		=> l_task_id,
				x_return_status		=> l_return_status,
				x_return_msg		=> l_return_msg,
				x_msg_count		=> l_msg_count
			);

                        DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.UPDATE_TASK return status = '|| l_return_status );
			DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.UPDATE_TASK return message = '|| l_return_msg );

			DEBUG( 'No of tasks updated = ' || l_task_id.count );

			IF l_return_status = FND_API.G_RET_STS_ERROR OR
			   l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
			THEN
				DEBUG (' Error in WMS_WAVEPLAN_TASKS_PVT.UPDATE_TASK ' || l_return_msg );
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				x_return_message:= 'Error in wms_waveplan_tasks_pvt.update_task. '
							|| 'Error message is ' || l_return_msg;
				return;
			END IF;
		END IF;
	END LOOP;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting UPDATE_TASK');

EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.UPDATE_TASK. '
					|| 'Oracle error message is ' || SQLERRM ;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM , 'WMS_TASK_ACTION_PVT.SUBMIT_REQUEST' );
END UPDATE_TASK;


PROCEDURE CANCEL_TASK
(	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	   OUT NOCOPY	VARCHAR2
)
IS
	l_transaction_temp_id_tbl	wms_waveplan_tasks_pvt.transaction_temp_table_type;
	l_task_type_id_table		wms_waveplan_tasks_pvt.task_type_id_table_type;
	l_result			wms_waveplan_tasks_pvt.result_table_type;
	l_message			wms_waveplan_tasks_pvt.message_table_type;
	l_task_id			wms_waveplan_tasks_pvt.task_id_table_type;
	l_return_msg			VARCHAR2( 120);
	l_msg_count			NUMBER;
	l_task_type_id			NUMBER;
	l_return_message		VARCHAR2( 4000 );

	CURSOR	c_task_type_id
	IS
		SELECT	distinct to_number(wwtt.task_type_id) task_type_id,
			mfl.meaning
		FROM	wms_waveplan_tasks_temp wwtt,
			mfg_lookups mfl
		WHERE	wwtt.task_type_id = mfl.lookup_code
		AND	mfl.lookup_type = 'WMS_TASK_TYPES';
BEGIN
	DEBUG( 'Inside CANCEL_TASK');
	DEBUG( 'Opening cursor c_task_type_id');

	FOR rec_task_type_id in c_task_type_id
	LOOP
		l_task_type_id := rec_task_type_id.task_type_id;

		DEBUG( 'Calling GET_TRANSACTION_TASK_IDS');
		DEBUG( 'Task type id passed = ' || l_task_type_id );
		--Calling GET_TRANSACTION_TASK_IDS to get transaction_temp_id and saved_action_type

		GET_TRANSACTION_TASK_IDS
		(
			p_task_type_id			=> l_task_type_id,
			p_transaction_temp_id_tbl	=> l_transaction_temp_id_tbl,
			p_task_type_id_table		=> l_task_type_id_table,
			x_return_status			=> l_return_status,
			x_return_message		=> l_return_message
		);

		DEBUG( 'GET_TRANSACTION_TASK_IDS return status = ' || l_return_status );
		DEBUG( 'GET_TRANSACTION_TASK_IDS return message = ' || l_return_message );

		IF l_return_status = fnd_api.g_ret_sts_error OR
		   l_return_status = fnd_api.g_ret_sts_unexp_error
		THEN
			DEBUG (' Error in GET_TRANSACTION_TASK_IDS ' );
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_return_message:= ( 'GET_TRANSACTION_TASK_IDS returned with Error status.'
						||' Error message is ' || l_return_message);
			return;
		END IF;

		DEBUG( 'Task_Type_Id = ' || l_task_type_id );
		DEBUG( 'Task Type in process = ' || rec_task_type_id.meaning );
		DEBUG( 'No of tasks to be cancelled = ' || l_transaction_temp_id_tbl.count );

		IF ( ( l_transaction_temp_id_tbl.count > 0 ) and ( l_task_type_id_table.count > 0 ) )
		THEN
			--call update task
			DEBUG( 'Calling WMS_WAVEPLAN_TASKS_PVT.CANCEL_TASK');
                        IF (wms_plan_tasks_pvt.g_include_crossdock ) THEN
                               DEBUG( 'global variable wms_plan_tasks_pvt.g_include_crossdock = TRUE ');
                        ELSE
                               DEBUG( 'global variable wms_plan_tasks_pvt.g_include_crossdock = FALSE ');
                        END IF;

			wms_waveplan_tasks_pvt.cancel_task
			(
				p_transaction_temp_id	=> l_transaction_temp_id_tbl,
				p_task_type_id		=> l_task_type_id_table,
                                p_is_crossdock          => wms_plan_tasks_pvt.g_include_crossdock, --Bug#6075802.
				x_result		=> l_result,
				x_message		=> l_message,
				x_task_id		=> l_task_id,
				x_return_status		=> l_return_status,
				x_return_msg		=> l_return_msg,
				x_msg_count		=> l_msg_count
			);

         DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.CANCEL_TASK return status = '|| l_return_status );
			DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.CANCEL_TASK return message = '|| l_return_msg );

			DEBUG( 'No of tasks cancelled = ' || l_task_id.count );

			IF l_return_status = FND_API.G_RET_STS_ERROR OR
			   l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
			THEN
				DEBUG (' Error in WMS_WAVEPLAN_TASKS_PVT.CANCEL_TASK ' || l_return_msg );
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				x_return_message:= 'Error in wms_waveplan_tasks_pvt.cancel_task. '
							|| 'Error message is ' || l_return_msg;
				return;
			END IF;
		END IF;
	END LOOP;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting CANCEL_TASK');

EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.CANCEL_TASK. '
					|| 'Oracle error message is ' || SQLERRM ;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM , 'WMS_TASK_ACTION_PVT.SUBMIT_REQUEST' );
END CANCEL_TASK;

PROCEDURE SET_QUERY_TASKS_PARAMETERS
(
	p_field_name_table	IN		wms_task_action_pvt.field_name_table_type,
	p_field_value_table	IN		wms_task_action_pvt.field_value_table_type,
	p_organization_id_table	IN		wms_task_action_pvt.organization_id_table_type,
	p_query_type_table	IN		wms_task_action_pvt.query_type_table_type,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
	i	number;
BEGIN
	DEBUG( 'Inside SET_QUERY_TASKS_PARAMETERS');

	IF p_field_name_table.count <> 0
	THEN
		FOR i in p_field_name_table.first .. p_field_name_table.last
		LOOP
			IF ( p_field_name_table(i) = 'FIND_TASKS.UNRELEASED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_unreleased := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PENDING'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_pending := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.QUEUED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_queued := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.DISPATCHED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_dispatched := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.ACTIVE'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_active := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.LOADED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_loaded := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.COMPLETED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_completed := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.INBOUND'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_inbound := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.OUTBOUND'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_outbound := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.CROSSDOCK'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_crossdock := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.MANUFACTURING'
			       AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_manufacturing := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.WAREHOUSING'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_warehousing := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.ORDER_TYPE'
			     AND p_field_value_table(i) = 'S' )
			THEN
				l_include_sales_orders := TRUE;
			ELSIF ( p_field_name_table(i) = 'FIND_TASKS.ORDER_TYPE'
				AND p_field_value_table(i) = 'I' )
			THEN
				l_include_internal_orders := TRUE;
			ELSIF ( p_field_name_table(i) = 'FIND_TASKS.ORDER_TYPE'
				AND p_field_value_table(i) = 'B' )
			THEN
				l_include_sales_orders := TRUE;
				l_include_internal_orders := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.REPLENISHMENT_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_replenishment := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.MO_TRANSFER_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_mo_transfer := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.MO_ISSUE_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_mo_issue := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.LPN_PUTAWAY_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_lpn_putaway := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.STAGING_MOVE'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_staging_move := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.CYCLE_COUNT_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_include_cycle_count := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PLAN_PENDING'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_pending_plan := TRUE;
         END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PLAN_IN_PROGRESS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_inprogress_plan := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PLAN_COMPLETED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_completed_plan := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PLAN_CANCELLED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_cancelled_plan := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PLAN_ABORTED'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_is_aborted_plan := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.PLANNED_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_query_planned_tasks := TRUE;
			END IF;

			IF ( p_field_name_table(i) = 'FIND_TASKS.INDEPENDENT_TASKS'
			     AND p_field_value_table(i) = 'Y' )
			THEN
				l_query_independent_tasks := TRUE;
			END IF;

			IF p_field_name_table(i) = 'FIND_TASKS.SUBINVENTORY'
			THEN
				l_subinventory := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.LOCATOR_ID'
			THEN
				l_locator_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_SUBINVENTORY'
			THEN
				l_to_subinventory := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_LOCATOR_ID'
			THEN
				l_to_locator_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.INVENTORY_ITEM_ID'
			THEN
				l_inventory_item_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.CATEGORY_SET_ID'
			THEN
				l_category_set_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.ITEM_CATEGORY_ID'
			THEN
				l_item_category_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.EMPLOYEE_ID'
			THEN
				l_employee_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.PERSON_RESOURCE_ID'
			THEN
				l_person_resource_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.EQUIPMENT_TYPE_ID'
			THEN
				l_equipment_type_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.EQUIPMENT'
			THEN
				l_equipment := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.USER_TASK_TYPE_ID'
			THEN
				l_user_task_type_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_TASK_QUANTITY'
			THEN
				l_from_task_quantity := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_TASK_QUANTITY'
			THEN
				l_to_task_quantity := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_TASK_PRIORITY'
			THEN
				l_from_task_priority := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_TASK_PRIORITY'
			THEN
				l_to_task_priority := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_CREATION_DATE'
			THEN
				l_from_creation_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_CREATION_DATE'
			THEN
				l_to_creation_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_PURCHASE_ORDER'
			THEN
				l_from_purchase_order	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_PO_HEADER_ID'
			THEN
				l_from_po_header_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_PURCHASE_ORDER'
			THEN
				l_to_purchase_order	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_PO_HEADER_ID'
			THEN
				l_to_po_header_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_RMA'
			THEN
				l_from_rma	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_RMA_HEADER_ID'
			THEN
				l_from_rma_header_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_RMA'
			THEN
				l_to_rma	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_RMA_HEADER_ID'
			THEN
				l_to_rma_header_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_REQUISITION'
			THEN
				l_from_requisition	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_REQUISITION_HEADER_ID'
			THEN
				l_from_requisition_header_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.TO_REQUISITION'
			THEN
				l_to_requisition	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.TO_REQUISITION_HEADER_ID'
			THEN
				l_to_requisition_header_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.FROM_SHIPMENT'
			THEN
				l_from_shipment	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.TO_SHIPMENT'
			THEN
				l_to_shipment	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.FROM_SALES_ORDER_ID'
			THEN
				l_from_sales_order_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.TO_SALES_ORDER_ID'
			THEN
				l_to_sales_order_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_PICK_SLIP'
			THEN
				l_from_pick_slip	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_PICK_SLIP'
			THEN
				l_to_pick_slip	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.CUSTOMER_ID'
			THEN
				l_customer_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.CUSTOMER_CATEGORY'
			THEN
				l_customer_category	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.DELIVERY_ID'
			THEN
				l_delivery_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.CARRIER_ID'
			THEN
				l_carrier_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_METHOD_CODE'
			THEN
				l_ship_method_code	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TRIP_ID'
			THEN
				l_trip_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIPMENT_PRIORITY'
			THEN
				l_shipment_priority	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_SHIPMENT_DATE'
			THEN
				l_from_shipment_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_SHIPMENT_DATE'
			THEN
				l_to_shipment_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_TO_STATE'
			THEN
				l_ship_to_state	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_TO_COUNTRY'
			THEN
				l_ship_to_country	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_TO_POSTAL_CODE'
			THEN
				l_ship_to_postal_code	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_LINES_IN_SALES_ORDER'
			THEN
				l_from_lines_in_sales_order	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_LINES_IN_SALES_ORDER'
			THEN
				l_to_lines_in_sales_order	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.MANUFACTURING_TYPE'
			THEN
				l_manufacturing_type	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_JOB'
			THEN
				l_from_job	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_JOB'
			THEN
				l_to_job	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.ASSEMBLY_ID'
			THEN
				l_assembly_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_START_DATE'
			THEN
				l_from_start_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_START_DATE'
			THEN
				l_to_start_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) =  'FIND_TASKS.FROM_LINE'
			THEN
				l_from_line	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_LINE'
			THEN
				l_to_line	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.DEPARTMENT_ID'
			THEN
				l_department_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) =  'FIND_TASKS.FROM_REPLENISHMENT_MO'
			THEN
				l_from_replenishment_mo	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_REPLENISHMENT_MO'
			THEN
				l_to_replenishment_mo	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_TRANSFER_ISSUE_MO'
			THEN
				l_from_transfer_issue_mo	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_TRANSFER_ISSUE_MO'
			THEN
				l_to_transfer_issue_mo	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.CYCLE_COUNT_NAME'
			THEN
				l_cycle_count_name	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.OP_PLAN_ACTIVITY_ID'
			THEN
				l_op_plan_activity_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.OP_PLAN_TYPE_ID'
			THEN
				l_op_plan_type_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.OP_PLAN_ID'
			THEN
				l_op_plan_id	:= p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'FIND_TASKS.WAVE_HEADER_ID'
			THEN
				l_wave_header_id := p_field_value_table(i);
			END IF;

		END LOOP;
	END IF;

	i := 1;
	l_organization_id := p_organization_id_table( i );

	IF p_query_type_table(i) = 'TEMP_TASK_PLANNING'
	THEN
		l_temp_query := TRUE;
	ELSE
		l_temp_query := FALSE;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting SET_QUERY_TASKS_PARAMETERS');

EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.SET_QUERY_TASKS_PARAMETERS. '
					|| 'Oracle error message is ' || SQLERRM;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM, 'WMS_TASK_ACTION_PVT.SET_QUERY_TASKS_PARAMETERS - other error');

END SET_QUERY_TASKS_PARAMETERS;

PROCEDURE SET_ACTION_TASKS_PARAMETERS
(
	p_field_name_table	IN		wms_task_action_pvt.field_name_table_type,
	p_field_value_table	IN		wms_task_action_pvt.field_value_table_type,
	p_query_type_table	IN		wms_task_action_pvt.query_type_table_type,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
	i	number;
BEGIN
	DEBUG( 'Inside SET_ACTION_TASKS_PARAMETERS');

	IF p_field_name_table.count <> 0
	THEN
		FOR i IN p_field_name_table.first .. p_field_name_table.last
		LOOP
			IF p_field_name_table(i) = 'MANAGE_TASKS.ACTION_TYPE'
			THEN
				l_action_type := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.STATUS'
			THEN
				l_status := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.STATUS_CODE'
			THEN
				l_status_code := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PRIORITY_TYPE'
			THEN
				l_priority_type := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PRIORITY'
			THEN
				l_priority := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.CLEAR_PRIORITY'
			THEN
				l_clear_priority := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.ASSIGN_TYPE'
			THEN
				l_assign_type := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EMPLOYEE'
			THEN
				l_employee := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EMPLOYEE_ID'
			THEN
				l_employee_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.USER_TASK_TYPE'
			THEN
				l_user_task_type := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.USER_TASK_TYPE_ID'
			THEN
				l_user_task_type_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EFFECTIVE_START_DATE'
			THEN
				l_effective_start_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EFFECTIVE_END_DATE'
			THEN
				l_effective_end_date := FND_DATE.CHARDT_TO_DATE( p_field_value_table(i) );
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PERSON_RESOURCE_ID'
			THEN
				l_person_resource_id := p_field_value_table(i);
			ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PERSON_RESOURCE_CODE'
			THEN
				l_person_resource_code := p_field_value_table(i);
			END IF;

			IF ( ( p_field_name_table(i) = 'MANAGE_TASKS.OVERRIDE_EMP_CHECK' )
			   and ( p_field_value_table(i) = 'Y' ) )
			THEN
				l_override_emp_check := TRUE;
			END IF;

		END LOOP;
	END IF;
	i	:= 1;
	IF p_query_type_table(i) = 'TEMP_TASK_ACTION'
	THEN
		l_temp_action := TRUE;
	ELSE
		l_temp_action := FALSE;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting SET_ACTION_TASKS_PARAMETERS');

EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.SET_ACTION_TASKS_PARAMETERS. '
					|| 'Oracle error message is ' || SQLERRM;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			||SQLERRM, 'WMS_TASK_ACTION_PVT.SET_ACTION_TASKS_PARAMETERS - other error');
END SET_ACTION_TASKS_PARAMETERS;

PROCEDURE DELETE_TEMP_QUERY
(	p_query_name		IN		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
BEGIN
	DEBUG( 'Inside DELETE_TEMP_QUERY');

	BEGIN
		delete
		from	wms_saved_queries
		where	query_name = p_query_name
		and	query_type = 'TEMP_TASK_PLANNING';

		DEBUG( 'Temporary query records cleaned. Records deleted = ' || sql%rowcount );
	EXCEPTION
		WHEN	OTHERS
		THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			x_return_message
				:= 'Unexpected error has occured in '
					|| 'WMS_TASK_ACTION_PVT.DELETE_TEMP_QUERY. '
					|| 'Oracle error message is ' || SQLERRM;
			DEBUG
			(	'Unexpected error has occured in '
				|| 'WMS_TASK_ACTION_PVT.DELETE_TEMP_QUERY. '
				|| 'Oracle error message is ' || SQLERRM
				, 'WMS_TASK_ACTION_PVT.DELETE_TEMP_QUERY - other error'
			);
	END;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting DELETE_TEMP_QUERY');
EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.DELETE_TEMP_QUERY '
					|| 'Oracle error message is ' || SQLERRM;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			||SQLERRM, 'WMS_TASK_ACTION_PVT.DELETE_TEMP_QUERY - other error');
END DELETE_TEMP_QUERY;

PROCEDURE DELETE_TEMP_ACTION
(	p_action_name		IN		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
BEGIN
	DEBUG( 'Inside DELETE_TEMP_ACTION');

	BEGIN
		delete
		from	wms_saved_queries
		where	query_name = p_action_name
		and	query_type = 'TEMP_TASK_ACTION';

		DEBUG( 'Temporary action records cleaned. Records deleted = ' || sql%rowcount );

	EXCEPTION
		WHEN	OTHERS
		THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			x_return_message
				:= 'Unexpected error has occured in '
					|| 'WMS_TASK_ACTION_PVT.DELETE_TEMP_ACTION. '
					|| 'Oracle error message is ' || SQLERRM;
			DEBUG
			(	'Unexpected error has occured in '
				|| 'WMS_TASK_ACTION_PVT.DELETE_TEMP_ACTION. '
				, 'WMS_TASK_ACTION_PVT.DELETE_TEMP_ACTION - other error'
			);
	END;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting DELETE_TEMP_ACTION');
EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.DELETE_TEMP_ACTION '
					|| 'Oracle error message is ' || SQLERRM;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			||SQLERRM, 'WMS_TASK_ACTION_PVT.DELETE_TEMP_ACTION - other error');
END DELETE_TEMP_ACTION;

PROCEDURE TASK_ACTION_CONC_PROG
(
	errbuf		OUT NOCOPY	VARCHAR2,
	retcode		OUT NOCOPY	VARCHAR2,
	p_query_name	IN		VARCHAR2,
	p_action	IN		VARCHAR2,
	p_action_name	IN		VARCHAR2
)
IS
	l_request_id		NUMBER;
	l_return_status		VARCHAR2(1);
	l_return_message	VARCHAR2(4000);
	l_msg_data		VARCHAR2( 120 );
	l_msg_count		NUMBER;
	l_save_count		NUMBER;
	l_return_msg		VARCHAR2( 120) ;
	l_rowcount		NUMBER;
   ret         BOOLEAN;
BEGIN

	DEBUG( 'Calling TASK_ACTION');
        DEBUG( 'Input parameters passed are');
	DEBUG( 'p_query_name => ' || p_query_name);
	DEBUG( 'p_action => ' || p_action );
	DEBUG( 'p_action_name => ' || p_action_name );

	TASK_ACTION
	(	p_query_name => p_query_name,
		p_action => p_action,
		p_action_name => p_action_name ,
		p_online => 'N' ,
		x_rowcount => l_rowcount ,
		x_return_status => l_return_status,
		x_return_message => l_return_message
	);

	DEBUG( 'TASK_ACTION x_rowcount => ' || l_rowcount );
	DEBUG( 'TASK_ACTION x_return_status => ' || l_return_status);
	DEBUG( 'TASK_ACTION x_return_message => ' || l_return_message);

	IF l_temp_query
	THEN
		DEBUG( 'l_temp_query = TRUE');
	ELSE
		DEBUG( 'l_temp_query = FALSE');
	END IF;

	IF l_temp_action
	THEN
		DEBUG( 'l_temp_action = TRUE');
	ELSE
		DEBUG( 'l_temP_action = FALSE');
	END IF;

	IF l_return_status = fnd_api.g_ret_sts_error OR
	   l_return_status = fnd_api.g_ret_sts_unexp_error
	THEN
		retcode := '2';
		errbuf := 'Error: ' || l_return_message;

		IF l_temp_query
		THEN
			DEBUG( 'Calling DELETE_TEMP_QUERY');

			DELETE_TEMP_QUERY
			(
				p_query_name => p_query_name,
				x_return_status => l_return_status,
				x_return_message => l_return_message
			);

			DEBUG( 'DELETE_TEMP_QUERY return status = ' || l_return_status );
			DEBUG( 'DELETE_TEMP_QUERY return message = ' || l_return_message );

			IF l_return_status = fnd_api.g_ret_sts_error
			   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
			THEN
				errbuf := errbuf || l_return_message;
			ELSE
				COMMIT WORK;
			END IF;
		END IF;

		IF l_temp_action
		THEN
			DEBUG( 'Calling DELETE_TEMP_ACTION');

                       	DELETE_TEMP_ACTION
			(
				p_action_name => p_action_name,
				x_return_status => l_return_status,
				x_return_message => l_return_message
			);

			DEBUG( 'DELETE_TEMP_ACTION return status = ' || l_return_status );
			DEBUG( 'DELETE_TEMP_ACTION return message = ' || l_return_message );

			IF l_return_status = fnd_api.g_ret_sts_error
			   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
			THEN
				errbuf := errbuf || l_return_message;
			ELSE
				COMMIT WORK;
			END IF;
		END IF;

                return;
	END IF;

	IF l_rowcount <> 0
	THEN
		DEBUG( 'Calling wms_waveplan_tasks_pvt.save_tasks ');
		DEBUG( 'Input Parameters passed');
		DEBUG( 'p_commit	=> TRUE');
		DEBUG( 'p_user_id	=> ' || fnd_global.user_id);
		DEBUG( 'p_login_id	=> ' || fnd_global.login_id);

        	wms_waveplan_tasks_pvt.save_tasks
        	(
         p_task_action	=> p_action,
			p_commit	=> TRUE,
			p_user_id	=> fnd_global.user_id,
			p_login_id	=> fnd_global.login_id,
			x_save_count	=> l_save_count,
			x_return_status	=> l_return_status,
			x_msg_data	=> l_msg_data,
			x_msg_count	=> l_msg_count
		);

		DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.SAVE_TASKS return Status = ' || l_return_status );
		DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.SAVE_TASKS l_save_count = ' || l_save_count );
		DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.SAVE_TASKS l_msg_data = ' || l_msg_data );
		DEBUG( 'WMS_WAVEPLAN_TASKS_PVT.SAVE_TASKS l_msg_count = ' || l_msg_count );


		IF l_return_status = fnd_api.g_ret_sts_error
		   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
		THEN
			retcode := '2';
			errbuf := 'Error: ' || l_return_message;

			IF l_temp_query
			THEN
				DEBUG( 'Calling DELETE_TEMP_QUERY');

            DELETE_TEMP_QUERY
				(
					p_query_name => p_query_name,
					x_return_status => l_return_status,
					x_return_message => l_return_message
				);
				DEBUG( 'DELETE_TEMP_QUERY return status = ' || l_return_status );
				DEBUG( 'DELETE_TEMP_QUERY return message = ' || l_return_message );

				IF l_return_status = fnd_api.g_ret_sts_error
				   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
				THEN
					errbuf := errbuf || l_return_message;
				ELSE
					COMMIT WORK;
				END IF;
			END IF;

			IF l_temp_action
			THEN
				DEBUG( 'Calling DELETE_TEMP_ACTION');

                        	DELETE_TEMP_ACTION
				(
					p_action_name => p_action_name,
					x_return_status => l_return_status,
					x_return_message => l_return_message
				);

				DEBUG( 'DELETE_TEMP_ACTION return status = ' || l_return_status );
				DEBUG( 'DELETE_TEMP_ACTION return message = ' || l_return_message );

				IF l_return_status = fnd_api.g_ret_sts_error
				   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
				THEN
					errbuf := errbuf || l_return_message;
				ELSE
					COMMIT WORK;
				END IF;
			END IF;

			return;
		END IF;
	END IF;

	IF l_temp_query
	THEN
		DEBUG( 'Calling DELETE_TEMP_QUERY');
			DELETE_TEMP_QUERY
		(
			p_query_name => p_query_name,
			x_return_status => l_return_status,
			x_return_message => l_return_message
		);
		DEBUG( 'DELETE_TEMP_QUERY return status = ' || l_return_status );
		DEBUG( 'DELETE_TEMP_QUERY return message = ' || l_return_message );
		IF l_return_status = fnd_api.g_ret_sts_error
		   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
		THEN
			retcode := '2';
			errbuf := errbuf || l_return_message;
		ELSE
			COMMIT WORK;
		END IF;
	END IF;

	IF l_temp_action
	THEN
		DEBUG( 'Calling DELETE_TEMP_ACTION');
		DELETE_TEMP_ACTION
		(
			p_action_name => p_action_name,
			x_return_status => l_return_status,
			x_return_message => l_return_message
		);
		DEBUG( 'DELETE_TEMP_ACTION return status = ' || l_return_status );
		DEBUG( 'DELETE_TEMP_ACTION return message = ' || l_return_message );
		IF l_return_status = fnd_api.g_ret_sts_error
		   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
		THEN
			retcode := '2';
			errbuf := errbuf || l_return_message;
		ELSE
			COMMIT WORK;
		END IF;
	END IF;

	retcode := '0';
   ret      := fnd_concurrent.set_completion_status('NORMAL', errbuf);
	DEBUG( 'Exiting TASK_ACTION_CONC_PROG with status = '||retcode);

EXCEPTION
	WHEN	OTHERS
	THEN
		retcode := '2';
		errbuf := 'Unexpected error has occured in WMS_TASK_ACTION_PVT.TASK_ACTION_CONC_PROG. '
				|| 'Oracle error message is ' || SQLERRM;
      ret      := fnd_concurrent.set_completion_status('ERROR', errbuf);
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			||SQLERRM, 'WMS_TASK_ACTION_PVT.TASK_ACTION_CONC_PROG - other error');
END TASK_ACTION_CONC_PROG;

PROCEDURE TASK_ACTION
(
	p_query_name		IN		VARCHAR2,
	p_action_name		IN		VARCHAR2,
	p_action		IN		VARCHAR2,
	p_online		IN		VARCHAR2,
   x_rowcount              OUT NOCOPY      NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
	CURSOR	c_saved_queries ( p_query_name VARCHAR2 ) IS
		select	field_name,
			--ltrim(rtrim(field_value)) field_value,
			field_value,
			organization_id,
			query_type
		from	wms_saved_queries
		where	query_name = p_query_name
		and	(query_type = 'TASK_PLANNING' or query_type = 'TEMP_TASK_PLANNING')
		FOR UPDATE NOWAIT;

	CURSOR	c_saved_actions ( p_action_name varchar2 ) IS
		select	field_name,
			field_value,
			query_type
		from	wms_saved_queries
		where	query_name = p_action_name
		and	(query_type = 'TASK_ACTION' or query_type = 'TEMP_TASK_ACTION')
		FOR UPDATE NOWAIT;

	CURSOR	c_query_type ( p_action_name varchar2 ) IS
		select	distinct query_type
		from	wms_saved_queries
		where	query_name = p_action_name;

	rec_saved_queries	c_saved_queries%rowtype;
	rec_saved_actions	c_saved_actions%rowtype;

	l_field_name_table	wms_task_action_pvt.field_name_table_type;
	l_field_value_table	wms_task_action_pvt.field_value_table_type;
	l_organization_id_table	wms_task_action_pvt.organization_id_table_type;
	l_query_type_table	wms_task_action_pvt.query_type_table_type;

	l_return_status		VARCHAR2( 1 );
	l_msg_data		VARCHAR2( 120 );
	l_msg_count		NUMBER;
	l_save_count		NUMBER;
	l_return_msg		VARCHAR2( 120) ;
	l_record_count		NUMBER;

	l_query_name		varchar2(100);
	l_return_message	VARCHAR2(4000);
BEGIN

	l_record_count			:= 0;
	l_is_unreleased			:= FALSE;
	l_is_pending			:= FALSE;
	l_is_queued			:= FALSE;
	l_is_dispatched			:= FALSE;
	l_is_active			:= FALSE;
	l_is_loaded			:= FALSE;
	l_is_completed			:= FALSE;
	l_include_inbound		:= FALSE;
	l_include_outbound		:= FALSE;
   l_include_crossdock		:= FALSE;
	l_include_manufacturing		:= FALSE;
	l_include_warehousing		:= FALSE;
	l_include_sales_orders		:= FALSE;
	l_include_internal_orders	:= FALSE;
	l_include_replenishment		:= FALSE;
	l_include_mo_transfer		:= FALSE;
	l_include_mo_issue		:= FALSE;
	l_include_lpn_putaway		:= FALSE;
	l_include_staging_move		:= FALSE;
	l_include_cycle_count		:= FALSE;
	l_is_pending_plan		:= FALSE;
	l_is_inprogress_plan		:= FALSE;
	l_is_completed_plan		:= FALSE;
	l_is_cancelled_plan		:= FALSE;
	l_is_aborted_plan		:= FALSE;
	l_query_independent_tasks	:= FALSE;
	l_query_planned_tasks		:= FALSE;
	l_override_emp_check		:= FALSE;

	DEBUG ( 'Inside TASK_ACTION procedure' );
	DEBUG ( 'p_query_name => ' || p_query_name );
	DEBUG ( 'p_action_name => ' || p_action_name );
	DEBUG ( 'p_action => ' || p_action );

	DEBUG( 'Opening c_saved_queries');

	OPEN	c_saved_queries( p_query_name );

	FETCH	c_saved_queries
		BULK COLLECT INTO
			l_field_name_table,
			l_field_value_table,
			l_organization_id_table,
			l_query_type_table;

	-- If no records founds for the given query name
	-- then close the cursor and return informing invalid query name.

        DEBUG( 'c_saved_queries%ROWCOUNT = ' || c_saved_queries%ROWCOUNT );
        x_rowcount	:= c_saved_queries%ROWCOUNT;

        IF c_saved_queries%ROWCOUNT = 0
	THEN
		CLOSE c_saved_queries;
		DEBUG ('No data found for query name = ' || p_query_name);
                x_rowcount      := 0;
		x_return_status := fnd_api.g_ret_sts_success;
		x_return_message:= 'No data found for query name = ' || p_query_name ;

		FOR rec_query_type IN c_query_type( p_action_name )
		LOOP
			IF rec_query_type.query_type = 'TEMP_TASK_ACTION'
			THEN
				l_temp_action := TRUE;
			ELSE
				l_temp_action := FALSE;
			END IF;
		END LOOP;

		RETURN;
	END IF;

	CLOSE c_saved_queries;

	DEBUG ( 'Bulk collect from c_saved_queries successful and closed c_saved_queries cursor' );

	DEBUG ( 'Calling SET_QUERY_TASKS_PARAMETERS' );

	SET_QUERY_TASKS_PARAMETERS
	(	p_field_name_table => l_field_name_table,
		p_field_value_table => l_field_value_table ,
		p_organization_id_table => l_organization_id_table,
		p_query_type_table => l_query_type_table,
		x_return_status => l_return_status,
		x_return_message => l_return_message
	);

	DEBUG( 'SET_QUERY_TASKS_PARAMETERS return status = ' || l_return_status );
	DEBUG( 'SET_QUERY_TASKS_PARAMETERS return message = ' || l_return_message );

	IF l_return_status = fnd_api.g_ret_sts_error OR
	   l_return_status = fnd_api.g_ret_sts_unexp_error
	THEN
		DEBUG (' Error in SET_QUERY_TASKS_PARAMETERS ' );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_message:= 'SET_QUERY_TASKS_PARAMETERS returned with Error status'
					|| 'Error message = ' || l_return_message ;
		return;
	END IF;

	DEBUG ( 'Calling WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS' );
	DEBUG ( 'Input parameters passed');
	DEBUG( 'p_add				=> NULL' );
	DEBUG( 'p_organization_id		=> ' || l_organization_id );
	DEBUG( 'p_subinventory_code		=> ' || l_subinventory );
	DEBUG( 'p_locator_id			=> ' || l_locator_id );
	DEBUG( 'p_to_subinventory_code		=> ' || l_to_subinventory );
	DEBUG( 'p_to_locator_id			=> ' || l_to_locator_id );
	DEBUG( 'p_inventory_item_id		=> ' || l_inventory_item_id );
	DEBUG( 'p_category_set_id		=> ' || l_category_set_id );
	DEBUG( 'p_item_category_id		=> ' || l_item_category_id );
	DEBUG( 'p_person_id			=> ' || l_employee_id );
	DEBUG( 'p_person_resource_id		=> ' || l_person_resource_id );
	DEBUG( 'p_equipment_type_id		=> ' || l_equipment_type_id );
	DEBUG( 'p_machine_instance		=> ' || l_equipment );
	DEBUG( 'p_user_task_type_id		=> ' || l_user_task_type_id );
	DEBUG( 'p_from_task_quantity		=> ' || l_from_task_quantity );
	DEBUG( 'p_to_task_quantity		=> ' || l_to_task_quantity );
	DEBUG( 'p_from_task_priority		=> ' || l_from_task_priority );
	DEBUG( 'p_to_task_priority		=> ' || l_to_task_priority );
	DEBUG( 'p_from_creation_date		=> ' || FND_DATE.DATE_TO_CHARDATE(l_from_creation_date) );
	DEBUG( 'p_to_creation_date		=> ' || FND_DATE.DATE_TO_CHARDATE(l_to_creation_date) );

	IF l_is_unreleased
	THEN
		DEBUG( 'p_is_unreleased		=> TRUE' );
	ELSE
		DEBUG( 'p_is_unreleased		=> FALSE' );
	END IF;

	IF l_is_pending
	THEN
		DEBUG( 'p_is_pending		=> TRUE');
	ELSE
		DEBUG( 'p_is_pending		=> FALSE');
	END IF;

	IF l_is_queued
	THEN
		DEBUG( 'p_is_queued		=> TRUE' );
	ELSE
		DEBUG( 'p_is_queued		=> FALSE' );
	END IF;

	IF l_is_dispatched
	THEN
		DEBUG( 'p_is_dispatched		=> TRUE' );
	ELSE
		DEBUG( 'p_is_dispatched		=> FALSE' );
	END IF;

	IF l_is_active
	THEN
		DEBUG( 'p_is_active		=> TRUE');
	ELSE
		DEBUG( 'p_is_active		=> FALSE');
	END IF;

	IF l_is_loaded
	THEN
		DEBUG( 'p_is_loaded		=> TRUE' );
	ELSE
		DEBUG( 'p_is_loaded		=> FALSE' );
	END IF;

	IF l_is_completed
	THEN
		DEBUG( 'p_is_completed		=> TRUE' );
	ELSE
		DEBUG( 'p_is_completed		=> FALSE' );
	END IF;

	IF l_include_inbound
	THEN
		DEBUG( 'p_include_inbound	=> TRUE' );
	ELSE
		DEBUG( 'p_include_inbound	=> FALSE' );
	END IF;

	IF l_include_outbound
	THEN
		DEBUG( 'p_include_outbound	=> TRUE' );
	ELSE
		DEBUG( 'p_include_outbound	=> FALSE' );
	END IF;

	IF l_include_crossdock
	THEN
		DEBUG( 'p_include_crossdock	=> TRUE' );
	ELSE
		DEBUG( 'p_include_crossdock	=> FALSE' );
	END IF;


	IF l_include_manufacturing
	THEN
		DEBUG( 'p_include_manufacturing	=> TRUE' );
	ELSE
		DEBUG( 'p_include_manufacturing	=> FALSE' );
	END IF;

	IF l_include_warehousing
	THEN
		DEBUG( 'p_include_warehousing	=> TRUE' );
	ELSE
		DEBUG( 'p_include_warehousing	=> FALSE' );
	END IF;

	DEBUG( 'p_to_purchase_order		=> ' || l_to_purchase_order );
	DEBUG( 'p_to_po_header_id		=> ' || l_to_po_header_id );
	DEBUG( 'p_from_rma			=> ' || l_from_rma );
	DEBUG( 'p_from_rma_header_id		=> ' || l_from_rma_header_id );
	DEBUG( 'p_to_rma			=> ' || l_to_rma );
	DEBUG( 'p_to_rma_header_id		=> ' || l_to_rma_header_id );
	DEBUG( 'p_from_requisition		=> ' || l_from_requisition );
	DEBUG( 'p_from_requisition_header_id	=> ' || l_from_requisition_header_id );
	DEBUG( 'p_to_requisition		=> ' || l_to_requisition );
	DEBUG( 'p_to_requisition_header_id	=> ' || l_to_requisition_header_id );
	DEBUG( 'p_from_shipment_number		=> ' || l_from_shipment );
	DEBUG( 'p_to_shipment_number		=> ' || l_to_shipment );
	DEBUG( 'p_from_sales_order_id		=> ' || l_from_sales_order_id );
	DEBUG( 'p_to_sales_order_id		=> ' || l_to_sales_order_id );
	DEBUG( 'p_from_pick_slip_number		=> ' || l_from_pick_slip );
	DEBUG( 'p_to_pick_slip_number		=> ' || l_to_pick_slip );
	DEBUG( 'p_customer_id			=> ' || l_customer_id );
	DEBUG( 'p_customer_category		=> ' || l_customer_category );
	DEBUG( 'p_delivery_id			=> ' || l_delivery_id );
	DEBUG( 'p_carrier_id			=> ' || l_carrier_id );
	DEBUG( 'p_ship_method			=> ' || l_ship_method_code );
	DEBUG( 'p_trip_id			=> ' || l_trip_id );
	DEBUG( 'p_shipment_priority		=> ' || l_shipment_priority );
	DEBUG( 'p_from_shipment_date		=> ' || l_from_shipment_date );
	DEBUG( 'p_to_shipment_date		=> ' || l_to_shipment_date );
	DEBUG( 'p_ship_to_state			=> ' || l_ship_to_state );
	DEBUG( 'p_ship_to_country		=> ' || l_ship_to_country );
	DEBUG( 'p_ship_to_postal_code		=> ' || l_ship_to_postal_code );
	DEBUG( 'p_from_number_of_order_lines	=> ' || l_from_lines_in_sales_order );
	DEBUG( 'p_to_number_of_order_lines	=> ' || l_to_lines_in_sales_order );
	DEBUG( 'p_manufacturing_type		=> ' || l_manufacturing_type );
	DEBUG( 'p_from_job			=> ' || l_from_job );
	DEBUG( 'p_to_job			=> ' || l_to_job );
	DEBUG( 'p_assembly_id			=> ' || l_assembly_id );
	DEBUG( 'p_from_start_date		=> ' || l_from_start_date );
	DEBUG( 'p_to_start_date			=> ' || l_to_start_date );
	DEBUG( 'p_from_line			=> ' || l_from_line );
	DEBUG( 'p_to_line			=> ' || l_to_line );
	DEBUG( 'p_department_id			=> ' || l_department_id );

	IF l_include_sales_orders
	THEN
		DEBUG( 'p_include_sales_orders	=> TRUE' );
	ELSE
		DEBUG( 'p_include_sales_orders	=> FALSE' );
	END IF;

	IF l_include_internal_orders
	THEN
		DEBUG( 'p_include_internal_orders => TRUE' );
	ELSE
		DEBUG( 'p_include_internal_orders => FALSE' );
	END IF;

	IF l_include_replenishment
	THEN
		DEBUG( 'p_include_replenishment	=> TRUE' );
	ELSE
		DEBUG( 'p_include_replenishment => FALSE' );
	END IF;

	DEBUG( 'p_from_replenishment_mo		=> ' || l_from_replenishment_mo );
	DEBUG( 'p_to_replenishment_mo		=> ' || l_to_replenishment_mo );

	IF l_include_mo_transfer
	THEN
		DEBUG( 'p_include_mo_transfer	=> TRUE' );
	ELSE
		DEBUG( 'p_include_mo_transfer	=> FALSE' );
	END IF;

	IF l_include_mo_issue
	THEN
		DEBUG( 'p_include_mo_issue	=> TRUE' );
	ELSE
		DEBUG( 'p_include_mo_issue	=> FALSE' );
	END IF;

	DEBUG( 'p_from_transfer_issue_mo	=> ' || l_from_transfer_issue_mo );
	DEBUG( 'p_to_transfer_issue_mo		=> ' || l_to_transfer_issue_mo );

	IF l_include_lpn_putaway
	THEN
		DEBUG( 'p_include_lpn_putaway	=> TRUE' );
	ELSE
		DEBUG( 'p_include_lpn_putaway	=> FALSE' );
	END IF;

	IF l_include_staging_move
	THEN
		DEBUG( 'p_include_staging_move	=> TRUE' );
	ELSE
		DEBUG( 'p_include_staging_move	=> FALSE' );
	END IF;

	IF l_include_cycle_count
	THEN
		DEBUG( 'p_include_cycle_count	=> TRUE' );
	ELSE
		DEBUG( 'p_include_cycle_count	=> FALSE' );
	END IF;

	DEBUG( 'p_cycle_count_name		=> ' || l_cycle_count_name );

	IF l_query_independent_tasks
	THEN
		DEBUG( 'p_query_independent_tasks => TRUE' );
	ELSE
		DEBUG( 'p_query_independent_tasks => FALSE' );
	END IF;

	IF l_query_planned_tasks
	THEN
		DEBUG( 'p_query_planned_tasks	=> TRUE' );
	ELSE
		DEBUG( 'p_query_planned_tasks	=> FALSE' );
	END IF;

	IF l_is_pending_plan
	THEN
		DEBUG( 'p_is_pending_plan	=> TRUE' );
	ELSE
		DEBUG( 'p_is_pending_plan	=> FALSE' );
	END IF;

	IF l_is_inprogress_plan
	THEN
		DEBUG( 'p_is_inprogress_plan	=> TRUE' );
	ELSE
		DEBUG( 'p_is_inprogress_plan	=> FALSE' );
	END IF;

	IF l_is_completed_plan
	THEN
		DEBUG( 'p_is_completed_plan	=> TRUE' );
	ELSE
		DEBUG( 'p_is_completed_plan	=> FALSE' );
	END IF;

	IF l_is_cancelled_plan
	THEN
		DEBUG( 'p_is_cancelled_plan	=> TRUE' );
	ELSE
		DEBUG( 'p_is_cancelled_plan	=> FALSE' );
	END IF;

	IF l_is_aborted_plan
	THEN
		DEBUG( 'p_is_aborted_plan	=> TRUE'  );
	ELSE
		DEBUG( 'p_is_aborted_plan	=> FALSE'  );
	END IF;

	DEBUG( 'p_activity_id			=> ' || l_op_plan_activity_id );
	DEBUG( 'p_plan_type_id			=> ' || l_op_plan_type_id );
	DEBUG( 'p_op_plan_id			=> ' || l_op_plan_id );

	wms_waveplan_tasks_pvt.query_tasks
	(	p_add				=> NULL ,
		p_organization_id		=> l_organization_id,
		p_subinventory_code		=> l_subinventory,
		p_locator_id			=> l_locator_id,
		p_to_subinventory_code		=> l_to_subinventory,
		p_to_locator_id			=> l_to_locator_id,
		p_inventory_item_id		=> l_inventory_item_id,
		p_category_set_id		=> l_category_set_id,
		p_item_category_id		=> l_item_category_id,
		p_person_id			=> l_employee_id,
		p_person_resource_id		=> l_person_resource_id,
		p_equipment_type_id		=> l_equipment_type_id,
		p_machine_instance		=> l_equipment,
		p_user_task_type_id		=> l_user_task_type_id,
		p_from_task_quantity		=> l_from_task_quantity,
		p_to_task_quantity		=> l_to_task_quantity,
		p_from_task_priority		=> l_from_task_priority,
		p_to_task_priority		=> l_to_task_priority,
		p_from_creation_date		=> l_from_creation_date,
		p_to_creation_date		=> l_to_creation_date,
		p_is_unreleased			=> l_is_unreleased,
		p_is_pending			=> l_is_pending,
		p_is_queued			=> l_is_queued,
		p_is_dispatched			=> l_is_dispatched,
		p_is_active			=> l_is_active,
		p_is_loaded			=> l_is_loaded,
		p_is_completed			=> l_is_completed,
		p_include_inbound		=> l_include_inbound,
		p_include_outbound		=> l_include_outbound,
      p_include_crossdock     => l_include_crossdock,
		p_include_manufacturing		=> l_include_manufacturing,
		p_include_warehousing		=> l_include_warehousing,
		p_from_purchase_order		=> l_from_purchase_order,
		p_from_po_header_id		=> l_from_po_header_id,
		p_to_purchase_order		=> l_to_purchase_order,
		p_to_po_header_id		=> l_to_po_header_id,
		p_from_rma			=> l_from_rma,
		p_from_rma_header_id		=> l_from_rma_header_id,
		p_to_rma			=> l_to_rma,
		p_to_rma_header_id		=> l_to_rma_header_id,
		p_from_requisition		=> l_from_requisition,
		p_from_requisition_header_id	=> l_from_requisition_header_id,
		p_to_requisition		=> l_to_requisition,
		p_to_requisition_header_id	=> l_to_requisition_header_id,
		p_from_shipment_number		=> l_from_shipment,
		p_to_shipment_number		=> l_to_shipment,
		p_from_sales_order_id		=> l_from_sales_order_id,
		p_to_sales_order_id		=> l_to_sales_order_id,
		p_from_pick_slip_number		=> l_from_pick_slip,
		p_to_pick_slip_number		=> l_to_pick_slip,
		p_customer_id			=> l_customer_id,
		p_customer_category		=> l_customer_category,
		p_delivery_id			=> l_delivery_id,
		p_carrier_id			=> l_carrier_id,
		p_ship_method			=> l_ship_method_code,
		p_trip_id			=> l_trip_id,
		p_shipment_priority		=> l_shipment_priority,
		p_from_shipment_date		=> l_from_shipment_date,
		p_to_shipment_date		=> l_to_shipment_date,
		p_ship_to_state			=> l_ship_to_state,
		p_ship_to_country		=> l_ship_to_country,
		p_ship_to_postal_code		=> l_ship_to_postal_code,
		p_from_number_of_order_lines	=> l_from_lines_in_sales_order,
		p_to_number_of_order_lines	=> l_to_lines_in_sales_order,
		p_manufacturing_type		=> l_manufacturing_type,
		p_from_job			=> l_from_job,
		p_to_job			=> l_to_job,
		p_assembly_id			=> l_assembly_id,
		p_from_start_date		=> l_from_start_date,
		p_to_start_date			=> l_to_start_date,
		p_from_line			=> l_from_line,
		p_to_line			=> l_to_line,
		p_department_id			=> l_department_id,
		p_include_sales_orders		=> l_include_sales_orders,
		p_include_internal_orders	=> l_include_internal_orders,
		p_include_replenishment		=> l_include_replenishment,
		p_from_replenishment_mo		=> l_from_replenishment_mo,
		p_to_replenishment_mo		=> l_to_replenishment_mo,
		p_include_mo_transfer		=> l_include_mo_transfer,
		p_include_mo_issue		=> l_include_mo_issue,
		p_from_transfer_issue_mo	=> l_from_transfer_issue_mo,
		p_to_transfer_issue_mo		=> l_to_transfer_issue_mo,
		p_include_lpn_putaway		=> l_include_lpn_putaway,
		p_include_staging_move		=> l_include_staging_move,
		p_include_cycle_count		=> l_include_cycle_count,
		p_cycle_count_name		=> l_cycle_count_name,
		x_return_status			=> l_return_status,
		x_msg_data			=> l_msg_data,
		x_msg_count			=> l_msg_count,
		x_record_count			=> l_record_count,
		p_query_independent_tasks	=> l_query_independent_tasks,
		p_query_planned_tasks		=> l_query_planned_tasks,
		p_is_pending_plan		=> l_is_pending_plan,
		p_is_inprogress_plan		=> l_is_inprogress_plan,
		p_is_completed_plan		=> l_is_completed_plan,
		p_is_cancelled_plan		=> l_is_cancelled_plan,
		p_is_aborted_plan		=> l_is_aborted_plan,
		p_activity_id			=> l_op_plan_activity_id,
		p_plan_type_id			=> l_op_plan_type_id,
		p_op_plan_id			=> l_op_plan_id
	);

	DEBUG ( 'WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_return_status => ' || l_return_status );
	DEBUG ( 'WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_msg_data => ' || l_msg_data);
	DEBUG ( 'WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_msg_count => ' || l_msg_count);
	DEBUG ( 'WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_record_count => ' || l_record_count);

	IF l_return_status = fnd_api.g_ret_sts_error
	THEN
		DEBUG (' Error in WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS ' );
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_return_message:= 'WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS returned with Error status'
					|| 'Error message is ' || l_return_message;
		return;
	END IF;

	-- Clearing the tables.
	l_field_name_table.delete;
	l_field_value_table.delete;
	l_query_type_table.delete;

	DEBUG ('Cleared pl/sql tables l_query_type_table, l_field_name_table and l_field_value_table.' );

	DEBUG ( 'Opening c_saved_actions cursor');

	OPEN	c_saved_actions( p_action_name );
	FETCH	c_saved_actions
		BULK COLLECT INTO l_field_name_table, l_field_value_table, l_query_type_table;

	-- If no records founds for the given query name
	-- then close the cursor and return informing invalid query name.

        DEBUG( 'c_saved_actions%ROWCOUNT = ' || c_saved_actions%ROWCOUNT );

	x_rowcount	:= c_saved_actions%ROWCOUNT;

        IF c_saved_actions%ROWCOUNT = 0
	THEN
		CLOSE c_saved_actions;

		DEBUG ('No data found for action name. ' || p_action_name);
		x_rowcount	:= 0;
		x_return_status := fnd_api.g_ret_sts_success;
		x_return_message:= 'No data found for action name. ' || p_action_name;

		FOR rec_query_type IN c_query_type( p_query_name )
		LOOP
			IF rec_query_type.query_type = 'TEMP_TASK_ACTION'
			THEN
				l_temp_action := TRUE;
			ELSE
				l_temp_action := FALSE;
			END IF;
		END LOOP;

		RETURN;
	END IF;

	CLOSE c_saved_actions;

	DEBUG ( 'Bulk collect successful and closed c_saved_actions cursor');

	DEBUG ( 'Calling SET_ACTION_TASKS_PARAMETERS');

	SET_ACTION_TASKS_PARAMETERS
	(	p_field_name_table	=> l_field_name_table,
		p_field_value_table	=> l_field_value_table ,
		p_query_type_table	=> l_query_type_table ,
		x_return_status		=> l_return_status,
		x_return_message	=> l_return_message
	);


	DEBUG ( 'SET_ACTION_TASKS_PARAMETERS return status = ' || l_return_status );
	DEBUG ( 'SET_ACTION_TASKS_PARAMETERS return message = ' || l_return_message );

	-- If set_action_tasks_parameters returns error then log message and return.
	IF l_return_status = fnd_api.g_ret_sts_error OR
	   l_return_status = fnd_api.g_ret_sts_unexp_error
	THEN
		DEBUG (' Error in SET_ACTION_TASKS_PARAMETERS ' );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		return;
	END IF;

	DEBUG ( 'No of eligible tasks to be updated are ' || l_field_name_table.count );

	IF p_action = l_action_type
	THEN
		IF p_action = 'U'
		THEN
			DEBUG( 'Calling UPDATE_TASK');

         UPDATE_TASK
			(	x_return_status => l_return_status,
				x_return_message=> l_return_message
			);

			IF l_return_status = fnd_api.g_ret_sts_error OR
			   l_return_status = fnd_api.g_ret_sts_unexp_error
			THEN
				DEBUG (' Error in UPDATE_TASK ' );
				x_return_status := FND_API.G_RET_STS_ERROR;
				x_return_message:= 'UPDATE_TASK returned with Error status'
							|| 'Error message is ' || l_return_message;
				return;
			END IF;
      ELSIF p_action = 'C' THEN
			DEBUG( 'Calling CANCEL_TASK');

         CANCEL_TASK
			(	x_return_status => l_return_status,
				x_return_message=> l_return_message
			);

			IF l_return_status = fnd_api.g_ret_sts_error OR
			   l_return_status = fnd_api.g_ret_sts_unexp_error
			THEN
				DEBUG (' Error in CANCEL_TASK ' );
				x_return_status := FND_API.G_RET_STS_ERROR;
				x_return_message:= 'CANCEL_TASK returned with Error status'
							|| 'Error message is ' || l_return_message;
				return;
			END IF;

		END IF;
	ELSE
		DEBUG( 'Could not perform specified Action.' );
		DEBUG( 'Action type of input parameter Action Name, "' || l_action_type ||
                        '", does not match with Action parameter, "'|| p_action || '".');
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_return_message:= 'Could not perform specified Action.'
					|| 'Action type of input parameter Action Name,"'
					|| l_action_type ||
					'", does not match with Action parameter,"'
					|| p_action || '".';
		return;
	END IF;

	IF p_online = 'Y'
	THEN
		IF l_temp_query
		THEN
			DEBUG( 'Calling DELETE_TEMP_QUERY');
				DELETE_TEMP_QUERY
			(
				p_query_name => p_query_name,
				x_return_status => l_return_status,
				x_return_message => l_return_message
			);

			DEBUG( 'DELETE_TEMP_QUERY return status = ' || l_return_status );
			DEBUG( 'DELETE_TEMP_QUERY return message = ' || l_return_message );

			IF l_return_status = fnd_api.g_ret_sts_error
			   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
			THEN
				x_return_status := fnd_api.g_ret_sts_error;
				x_return_message := l_return_message;
			END IF;
		END IF;

		IF l_temp_action
		THEN
			DEBUG( 'Calling DELETE_TEMP_ACTION');
			DELETE_TEMP_ACTION
			(
				p_action_name => p_action_name,
				x_return_status => l_return_status,
				x_return_message => l_return_message
			);

			DEBUG( 'DELETE_TEMP_ACTION return status = ' || l_return_status );
			DEBUG( 'DELETE_TEMP_ACTION return message = ' || l_return_message );

			IF l_return_status = fnd_api.g_ret_sts_error
			   OR  l_return_status = fnd_api.g_ret_sts_unexp_error
			THEN
				x_return_status := fnd_api.g_ret_sts_error;
				x_return_message := l_return_message;
			END IF;
		END IF;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting TASK_ACTION');

EXCEPTION
	WHEN OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_message:= 'Unexpected error has occured in TASK_ACTION. '
					|| 'Oracle error message is ' || SQLERRM;
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM , 'WMS_TASK_ACTION_PVT.TASK_ACTION' );
END TASK_ACTION;

PROCEDURE SUBMIT_REQUEST
(
	p_query_name		IN		VARCHAR2,
	p_action		IN		VARCHAR2,
	p_action_name		IN		VARCHAR2,
	x_request_id		OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
)
IS
	l_request_id	NUMBER;
	l_return	VARCHAR2(1);
begin

	DEBUG( 'Calling program unit FND_REQUEST.Submit_Request');
	DEBUG( 'Current Time is ',SYSDATE);
	DEBUG( 'Parameters passed to Concurrent program are as follows');
	DEBUG( 'argument1 = ' || p_query_name );
 	DEBUG( 'argument2 = ' || p_action );
	DEBUG( 'argument3 = ' || p_action_name );
	l_request_id := FND_REQUEST.SUBMIT_REQUEST
			(
				application => 'WMS',
				program     => 'WMSCBTAC',
				description => '',
				start_time  => '',
				sub_request => FALSE,
				argument1   => p_query_name,
				argument2   => p_action,
				argument3   => p_action_name
			);

	 -- If request submission failed, exit with error.
         IF l_request_id <= 0
	 THEN
		DEBUG('Request submission failed', 'WMS_TASK_ACTION_PVT.SUBMIT_REQUEST');
		l_return := FND_API.G_RET_STS_ERROR;
		RETURN;
	ELSE
		DEBUG( 'Request '||l_request_id||' submitted successfully');
                COMMIT WORK;
	END IF;

	x_request_id	:= l_request_id;

	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	DEBUG( 'Exiting SUBMIT_REQUEST' );

EXCEPTION
	WHEN	OTHERS
	THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_message:= 'Unexpected error has occured in WMS_TASK_ACTION_PVT.SUBMIT_REQUEST. '
					|| 'Oracle error message is ' || SQLERRM;

		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM , 'WMS_TASK_ACTION_PVT.SUBMIT_REQUEST' );
		DEBUG( 'Unexpected error has occured. Oracle error message is '
			|| SQLERRM , 'WMS_TASK_ACTION_PVT.SUBMIT_REQUEST' );
END SUBMIT_REQUEST;

END WMS_TASK_ACTION_PVT;

/
