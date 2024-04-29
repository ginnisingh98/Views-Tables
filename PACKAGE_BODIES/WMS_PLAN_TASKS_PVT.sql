--------------------------------------------------------
--  DDL for Package Body WMS_PLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PLAN_TASKS_PVT" AS
/* $Header: WMSPTKPB.pls 120.23.12010000.8 2010/04/13 00:04:23 sfulzele ship $ */

  /*
   * Private constants to decide the destination
   * of log message
   */
  LOGFILE   CONSTANT NUMBER := 1;
  LOGTABLE  CONSTANT NUMBER := 2;
  LOGSCREEN CONSTANT NUMBER := 3;

  MODULE_NAME VARCHAR2(100) := '$RCSfile: WMSPTKPB.pls,v $($Revision: 120.23.12010000.8 $)';

   /* Procedure to write the log messages */
  i NUMBER := 0;

  PROCEDURE DEBUG(
                  p_message VARCHAR2,
                  p_module  VARCHAR2 DEFAULT 'Plans_tasks'
                 ) IS

    l_counter NUMBER := 1;
    l_substr VARCHAR2(4000);


    l_module              VARCHAR2(100) := MODULE_NAME||'.'||p_module;
    l_message_length      NUMBER        := LENGTH(p_message);
    l_message_destination NUMBER        := LOGFILE;

 --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    IF l_message_destination = LOGFILE THEN

       WHILE l_counter < l_message_length LOOP

             l_substr := SUBSTR(p_message, l_counter, 4000);
             inv_log_util.trace(SUBSTR(p_message, l_counter, 4000), l_module);
             l_counter  := l_counter + 4000;

       END LOOP;

    ELSIF l_message_destination = LOGSCREEN THEN
         --dbms_output.put_line(p_message);
         NULL;
    ELSE

       i := i+1;
       EXECUTE IMMEDIATE 'INSERT INTO my_temp_table VALUES ('||
                         p_message||','||i||')';

    END IF;
   /*
   INSERT INTO my_temp_table VALUES (p_message,i);
   i := i+1;
   COMMIT;*/
     RETURN;
  EXCEPTION

  WHEN OTHERS THEN
    IF l_message_destination = LOGSCREEN THEN
     --dbms_output.disable;
      debug('other error while printing debug msgs' || SQLERRM);
       END IF;
       inv_log_util.trace(p_message,p_module,9);
  END DEBUG;

  PROCEDURE set_inbound_source_header_line IS
   TYPE source_header_type IS TABLE OF wms_waveplan_tasks_temp.source_header%TYPE;
   TYPE line_number_type   IS TABLE OF wms_waveplan_tasks_temp.line_number%TYPE;
   TYPE temp_id_type       IS TABLE OF wms_waveplan_tasks_temp.transaction_temp_id%TYPE;
   TYPE task_type_id_type  IS TABLE OF wms_waveplan_tasks_temp.task_type_id%TYPE;

   l_source_header source_header_type;
   l_line_number   line_number_type;
   l_temp_id       temp_id_type;
   l_task_type_id  task_type_id_type;
BEGIN

-- Code added for Bug#8467334
-- code added to popluate wip Job name for the tasks

SELECT  we.WIP_ENTITY_NAME , wwtt.transaction_temp_id, wwtt.task_type_id
bulk collect INTO l_source_header,  l_temp_id, l_task_type_id
FROM  wip_entities we  ,
  wms_waveplan_tasks_temp wwtt
WHERE we.WIP_ENTITY_ID = wwtt.reference_id
    AND wwtt.reference = 'WIP JOB'
     AND wwtt.source_header IS NULL
     AND wwtt.reference_id IS NOT NULL;

   IF l_temp_id.COUNT > 0 THEN
      forall i IN l_temp_id.first..l_temp_id.last
	UPDATE wms_waveplan_tasks_temp wwtt
	SET source_header = l_source_header(i)
WHERE wwtt.transaction_temp_id = l_temp_id(i)
	AND wwtt.task_type_id = l_task_type_id(i);
   END IF;

-- End of code added to popluate wip Job name for the tasks
-- End of Code added for Bug#8467334

   SELECT ph.segment1, pl.line_num, wwtt.transaction_temp_id, wwtt.task_type_id
     bulk collect INTO l_source_header, l_line_number, l_temp_id, l_task_type_id
     FROM po_line_locations_trx_v pll,--CLM Changes, using CLM views instead of base tables
          po_headers_trx_v ph,
          po_lines_trx_v pl,
          wms_waveplan_tasks_temp wwtt
     WHERE pll.line_location_id = wwtt.reference_id
     AND pll.po_line_id = pl.po_line_id
     AND ph.po_header_id = pl.po_header_id
     AND wwtt.reference = 'PO_LINE_LOCATION_ID'
     AND wwtt.source_header IS NULL
     AND wwtt.reference_id IS NOT NULL;

   IF l_temp_id.COUNT > 0 THEN
      forall i IN l_temp_id.first..l_temp_id.last
	UPDATE wms_waveplan_tasks_temp wwtt
	SET source_header = l_source_header(i),
	    line_number   = l_line_number(i)
	WHERE wwtt.transaction_temp_id = l_temp_id(i)
	AND wwtt.task_type_id = l_task_type_id(i);
   END IF;

   SELECT ooh.order_number, ool.line_number, wwtt.transaction_temp_id, wwtt.task_type_id
     bulk collect INTO l_source_header, l_line_number, l_temp_id, l_task_type_id
     FROM oe_order_lines_all ool,
          oe_order_headers_all ooh,
          wms_waveplan_tasks_temp wwtt
     WHERE ool.line_id = wwtt.reference_id
     AND ooh.header_id = ool.header_id
     AND wwtt.reference = 'ORDER_LINE_ID'
     AND wwtt.source_header IS NULL
     AND wwtt.reference_id IS NOT NULL;

   IF l_temp_id.COUNT > 0 THEN
      forall i IN l_temp_id.first..l_temp_id.last
	UPDATE wms_waveplan_tasks_temp wwtt
	SET source_header = l_source_header(i),
	    line_number   = l_line_number(i)
	WHERE wwtt.transaction_temp_id = l_temp_id(i)
	AND wwtt.task_type_id = l_task_type_id(i);
   END IF;

   SELECT Decode(rsl.requisition_line_id, NULL, rsh.shipment_num, prh.segment1),
          Decode(rsl.requisition_line_id, NULL, rsl.line_num, prl.line_num),
          wwtt.transaction_temp_id, wwtt.task_type_id
     bulk collect INTO l_source_header, l_line_number, l_temp_id, l_task_type_id
          -- MOAC changed po_requisition_headers and po_requisition_lines to _ALL tables
     FROM po_requisition_headers_all prh,
          po_requisition_lines_all prl,
          rcv_shipment_lines rsl,
          rcv_shipment_headers rsh,
          wms_waveplan_tasks_temp wwtt
     WHERE rsl.shipment_line_id = wwtt.reference_id
     AND prh.requisition_header_id(+) = prl.requisition_header_id
     AND rsl.requisition_line_id = prl.requisition_line_id(+)
     AND rsl.shipment_header_id = rsh.shipment_header_id
     AND wwtt.reference = 'SHIPMENT_LINE_ID'
     AND wwtt.source_header IS NULL
     AND wwtt.reference_id IS NOT NULL;

   IF l_temp_id.COUNT > 0 THEN
      forall i IN l_temp_id.first..l_temp_id.last
	UPDATE wms_waveplan_tasks_temp wwtt
	SET source_header = l_source_header(i),
	    line_number   = l_line_number(i)
	WHERE wwtt.transaction_temp_id = l_temp_id(i)
	AND wwtt.task_type_id = l_task_type_id(i);
   END IF;
END set_inbound_source_header_line;

  /* wrapper procedure to fetch the inbound plans and tasks */
  PROCEDURE query_inbound_plan_tasks(x_return_status OUT NOCOPY VARCHAR2, p_summary_mode NUMBER DEFAULT 0) IS

     l_plans_query     wms_plan_tasks_pvt.long_sql;
     l_tasks_query     wms_plan_tasks_pvt.long_sql;
     l_plans_query_str wms_plan_tasks_pvt.long_sql;
     l_tasks_query_str wms_plan_tasks_pvt.long_sql;

     l_query_plans BOOLEAN := FALSE;
     l_query_tasks BOOLEAN := FALSE;

     l_query_handle         NUMBER; -- Handle for the dynamic sql
     l_query_count          NUMBER;
     l_wms_task_type	    NUMBER;
     l_task_count	    NUMBER;

     x_plans_select_str wms_plan_tasks_pvt.short_sql;
     x_plans_from_str   wms_plan_tasks_pvt.short_sql;
     x_plans_where_str  wms_plan_tasks_pvt.short_sql;
     l_insert_str       wms_plan_tasks_pvt.short_sql;

     l_module_name            VARCHAR2(30) := 'query_inbound';
     l_planned_task           VARCHAR2(80);

     l_is_range_so BOOLEAN := FALSE;
     l_from_tonum_mso_seg1    VARCHAR2(40);
     l_to_tonum_mso_seg1      VARCHAR2(40);
     l_from_mso_seg2          VARCHAR2(150);
     l_to_mso_seg2	      VARCHAR2(150);
     l_from_mso_seg1	      VARCHAR2(40);
     l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

     CURSOR upd_op_seq IS
         SELECT wooi.operation_sequence,wwtt.transaction_temp_id
         FROM
  		   wms_op_operation_instances wooi,
         (SELECT transaction_temp_id
           FROM wms_waveplan_tasks_temp
           WHERE status_id = 6
           AND plans_tasks = wms_plan_tasks_pvt.g_plan_task_types(2)) wwtt
           WHERE wooi.source_task_id = wwtt.transaction_temp_id
			 UNION ALL
			 SELECT wooih.operation_sequence,wwtt.transaction_temp_id
          FROM WMS_OP_OPERTN_INSTANCES_HIST wooih,
			 (SELECT transaction_temp_id
            FROM wms_waveplan_tasks_temp
            WHERE status_id = 6
            AND plans_tasks = wms_plan_tasks_pvt.g_plan_task_types(2)) wwtt
          where  wooih.source_task_id = wwtt.transaction_temp_id;

     TYPE wwtt_op_seq_rec IS RECORD
        ( operation_sequence NUMBER,
          transaction_temp_id NUMBER
         );
     l_wwtt_opseq_rec wwtt_op_seq_rec;

BEGIN
   IF l_debug = 1 THEN
     debug('in query_inbound ', 'query_inbound');
     IF wms_plan_tasks_pvt.g_include_crossdock THEN
       debug('Querying Crossdock tasks', 'query_inbound');
     ELSE
       debug('NOT Querying Crossdock tasks', 'query_inbound');
     END IF;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   /* set the planned_tasks record statuses if planned_tasks are queried*/
   IF wms_plan_tasks_pvt.g_query_planned_tasks THEN
      IF l_debug = 1 THEN
        debug('planned_tasks are queried ','query_inbound');
      END IF;
      wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded := wms_plan_tasks_pvt.g_is_loaded_task;
      wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending := wms_plan_tasks_pvt.g_is_pending_task;
      wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed := wms_plan_tasks_pvt.g_is_completed_task;
   END IF;
   /* If only planned task records are qeuried and independent tasks are not
    * queried, then set the values of global variables to related to independent
    * tasks to false
    */
   IF NOT wms_plan_tasks_pvt.g_query_independent_tasks THEN
          wms_plan_tasks_pvt.g_is_loaded_task := FALSE;
          wms_plan_tasks_pvt.g_is_pending_task := FALSE;
          wms_plan_tasks_pvt.g_is_completed_task := FALSE;
   END IF;

   If wms_plan_tasks_pvt.g_is_pending_plan
      or wms_plan_tasks_pvt.g_is_inprogress_plan
      or wms_plan_tasks_pvt.g_is_completed_plan
      or wms_plan_tasks_pvt.g_is_aborted_plan
      or wms_plan_tasks_pvt.g_is_cancelled_plan
   then
   /* plans are queried */
      IF l_debug = 1 THEN
        debug('plans are queried ', 'query_inbound');
      END IF;
      l_query_plans := TRUE;
      if wms_plan_tasks_pvt.g_is_pending_plan then
         wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending := TRUE;
      END IF;
      if wms_plan_tasks_pvt.g_is_inprogress_plan then
         wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending := TRUE;
         wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded   := TRUE;
         wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed := TRUE;
      END IF;

      IF wms_plan_tasks_pvt.g_is_completed_plan OR
         wms_plan_tasks_pvt.g_is_cancelled_plan OR
         wms_plan_tasks_pvt.g_is_aborted_plan THEN
         wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed := TRUE;
      END IF;

      wms_plan_tasks_pvt.g_query_planned_tasks := TRUE;
   Else
      IF l_debug = 1 THEN
        debug('plans are not queried ', 'query_inbound');
      END IF;
      l_query_plans := FALSE;
   End if;


   IF wms_plan_tasks_pvt.g_query_independent_tasks OR
   wms_plan_tasks_pvt.g_query_planned_tasks THEN
      IF l_debug = 1 THEN
        debug('tasks are queried ', 'query_inbound');
      END IF;
      l_query_tasks := TRUE;
   ELSE
      IF l_debug = 1 THEN
        debug('tasks are not queried ', 'query_inbound');
      END IF;
      l_query_tasks := FALSE;
   END IF;

   /*Get the insert stmt - Call the function get_insert_stmt -
     This stmt is used to insert records into wwtt.
     Fields not revelant for plans, but are relevant for tasks are also included
     in this insert stmt..for fetching plans, the corresponding select stmt
     will select null values. */

      get_col_list(l_insert_str);
      l_insert_str := 'INSERT INTO WMS_WAVEPLAN_TASKS_TEMP(' || l_insert_str || ')';
      IF l_debug = 1 THEN
        debug('l_insert_str from get_col_list' || l_insert_str, 'query_inbound');
      END IF;

    /*	Call the function get_tasks to fetch the tasks records if the user has
      made task_specific query -
      This includes independent and planned_tasks records.
      This function returns the select stmt w/o the insert stmt.
      Store this string in a local variable, say l_tasks_query_str.
    */
    IF l_query_tasks THEN
       get_tasks(l_tasks_query_str,p_summary_mode); -- p_summary_mode
    END IF;
	IF l_debug = 1 THEN
	  debug('Query String : ' || l_tasks_query_str, 'query_inbound');
	END IF;
   /* If plans are queried, then we have to query the planned_tasks also.
    * If pending plans are queried,
         fetch the pending planned_tasks.
      if in_progress plans are queried,
         fetch the pending planned_tasks +
         fetch the Loaded planned_tasks  +
         fetch the completed planned_tasks.
      if completed plans are queried,
         fetch the completed planned_tasks.

      Note: Since plans are relevant only for inbound now, the statuses
      applicable for planned_tasks are limited. When this is extended for
      outbound, more statuses should be queried for
    */

   if l_query_plans then
    /* Call the procedure get_plans to fetch the plans records query.
            This procedure returns the select stmt w/o insert stmt into the
            OUT variable Store the string in a local variable.
          */
         /* If plan_specific query is made, it is handled in get_plans */

          get_plans(l_plans_query_str);
          IF l_debug = 1 THEN
	    debug('l_plans_query_str from get_plans' || l_plans_query_str, 'query_inbound');
	  END IF;
   END IF;


   /*First insert tasks records into WWTT - execute the sql.
	Once tasks records are inserted now insert plans records -
   Now insert the plans records into WWTT */

     IF l_tasks_query_str IS NOT NULL THEN
       IF l_debug = 1 THEN
         debug('l_tasks_query_str is not null ','query_inbound_tasks');
       END IF;
      IF p_summary_mode = 1 THEN
         l_tasks_query := l_tasks_query_str;
      ELSE
         l_tasks_query := l_insert_str || l_tasks_query_str;
      END IF;
      IF l_debug = 1 THEN
	debug('l_tasks_query ' || l_tasks_query,'query_inbound');
      END IF;

      l_query_handle          := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_query_handle, l_tasks_query, DBMS_SQL.native);

      /* set the bind variables now */
      IF l_debug = 1 THEN
       debug('setting the bind_variables ','query_inbound');
      END IF;
     IF wms_plan_tasks_pvt.g_organization_id IS NOT NULL THEN
       IF l_debug = 1 THEN
         debug('wms_plan_tasks_pvt.g_organization_id is not null ','query_inbound');
       END IF;
         dbms_sql.bind_variable(l_query_handle, 'org_id', wms_plan_tasks_pvt.g_organization_id);
      END IF;

      IF wms_plan_tasks_pvt.g_subinventory_code IS NOT NULL THEN
        IF l_debug = 1 THEN
         debug('wms_plan_tasks_pvt.g_subinventory_code is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'sub_code', wms_plan_tasks_pvt.g_subinventory_code);
      END IF;

      IF wms_plan_tasks_pvt.g_locator_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_locator_id is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'loc_id', wms_plan_tasks_pvt.g_locator_id);
      END IF;

      IF wms_plan_tasks_pvt.g_to_subinventory_code  IS NOT NULL THEN
        IF l_debug = 1 THEN
	   debug('wms_plan_tasks_pvt.g_to_subinventory_code is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'to_sub_code', wms_plan_tasks_pvt.g_to_subinventory_code );
      END IF;

      IF wms_plan_tasks_pvt.g_to_locator_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_to_locator_id is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'to_loc_id', wms_plan_tasks_pvt.g_to_locator_id );
      END IF;

      IF wms_plan_tasks_pvt.g_category_set_id  IS NOT NULL THEN
         IF l_debug = 1 THEN
	   debug('wms_plan_tasks_pvt.g_category_set_id is not null ','query_inbound');
	 END IF;
         dbms_sql.bind_variable(l_query_handle, 'category_set_id', wms_plan_tasks_pvt.g_category_set_id );
      END IF;

      IF wms_plan_tasks_pvt.g_item_category_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	   debug('wms_plan_tasks_pvt.g_item_category_id is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'item_category_id', wms_plan_tasks_pvt.g_item_category_id );
      END IF;

     IF wms_plan_tasks_pvt.g_inventory_item_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_inventory_item_id is not null ','query_inbound');
	END IF;
        dbms_sql.bind_variable(l_query_handle, 'item_id', wms_plan_tasks_pvt.g_inventory_item_id );
      END IF;

     IF wms_plan_tasks_pvt.g_person_id IS NOT NULL THEN
       IF l_debug = 1 THEN
         debug('wms_plan_tasks_pvt.g_person_id is not null ','query_inbound');
       END IF;
         dbms_sql.bind_variable(l_query_handle, 'person_id', wms_plan_tasks_pvt.g_person_id);
     END IF;

     IF wms_plan_tasks_pvt.g_person_resource_id IS NOT NULL THEN
       IF l_debug = 1 THEN
         debug('wms_plan_tasks_pvt.g_person_resource_id is not null ','query_inbound');
       END IF;
         dbms_sql.bind_variable(l_query_handle, 'person_resource_id', wms_plan_tasks_pvt.g_person_resource_id);
    END IF;

    IF wms_plan_tasks_pvt.g_equipment_type_id IS NOT NULL THEN
      IF l_debug = 1 THEN
       debug('wms_plan_tasks_pvt.g_equipment_type_id is not null ','query_inbound');
      END IF;
       dbms_sql.bind_variable(l_query_handle, 'equipment_type_id', wms_plan_tasks_pvt.g_equipment_type_id);
    END IF;

    IF wms_plan_tasks_pvt.g_machine_resource_id IS NOT NULL THEN
      IF l_debug = 1 THEN
        debug('wms_plan_tasks_pvt.g_machine_resource_id is not null ','query_inbound');
      END IF;
        dbms_sql.bind_variable(l_query_handle, 'machine_resource_id', wms_plan_tasks_pvt.g_machine_resource_id);
    END IF;

    IF wms_plan_tasks_pvt.g_machine_instance IS NOT NULL THEN
      IF l_debug = 1 THEN
        debug('wms_plan_tasks_pvt.g_machine_instance is not null ','query_inbound');
      END IF;
        dbms_sql.bind_variable(l_query_handle, 'machine_instance', wms_plan_tasks_pvt.g_machine_instance);
    END IF;

   IF wms_plan_tasks_pvt.g_from_creation_date IS NOT NULL THEN
     IF l_debug = 1 THEN
       debug('wms_plan_tasks_pvt.g_from_creation_date is not null ','query_inbound');
     END IF;
       dbms_sql.bind_variable(l_query_handle, 'from_creation_date', wms_plan_tasks_pvt.g_from_creation_date);
    END IF;

    IF wms_plan_tasks_pvt.g_to_creation_date IS NOT NULL THEN
      IF l_debug = 1 THEN
        debug('wms_plan_tasks_pvt.g_to_creation_date is not null ','query_inbound');
      END IF;
        dbms_sql.bind_variable(l_query_handle, 'to_creation_date', wms_plan_tasks_pvt.g_to_creation_date);
    END IF;

    IF wms_plan_tasks_pvt.g_from_task_quantity  IS NOT NULL THEN
      IF l_debug = 1 THEN
        debug('wms_plan_tasks_pvt.g_from_task_quantity is not null ','query_inbound');
      END IF;
        dbms_sql.bind_variable(l_query_handle, 'from_task_quantity', wms_plan_tasks_pvt.g_from_task_quantity );
      END IF;

    IF wms_plan_tasks_pvt.g_to_task_quantity  IS NOT NULL THEN
      IF l_debug = 1 THEN
        debug('wms_plan_tasks_pvt.g_to_task_quantity is not null ','query_inbound');
      END IF;
        dbms_sql.bind_variable(l_query_handle, 'to_task_quantity', wms_plan_tasks_pvt.g_to_task_quantity );
      END IF;

    IF wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	 debug('wms_plan_tasks_pvt.g_from_requisition_header_id is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'from_requisition_header_id', wms_plan_tasks_pvt.g_from_requisition_header_id );
    END IF;

      IF wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
        IF l_debug = 1 THEN
           debug('wms_plan_tasks_pvt.g_to_requisition_header_id is not null ','query_inbound');
	END IF;
           dbms_sql.bind_variable(l_query_handle, 'to_requisition_header_id', wms_plan_tasks_pvt.g_to_requisition_header_id );
      END IF;

      IF wms_plan_tasks_pvt.g_from_shipment_number IS NOT NULL THEN
        IF l_debug = 1 THEN
	 debug('wms_plan_tasks_pvt.g_from_shipment_number is not null ','query_inbound');
	END IF;
         -- Bug #3746810. Modified the bin var g_from_shipment_number to from_shipment_number
         dbms_sql.bind_variable(l_query_handle, 'from_shipment_number', wms_plan_tasks_pvt.g_from_shipment_number );
      END IF;

      IF wms_plan_tasks_pvt.g_to_shipment_number IS NOT NULL THEN
         IF l_debug = 1 THEN
	   debug('wms_plan_tasks_pvt.g_to_shipment_number is not null ','query_inbound');
	 END IF;
           dbms_sql.bind_variable(l_query_handle, 'to_shipment_number', wms_plan_tasks_pvt.g_to_shipment_number );
      END IF;

      IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_from_po_header_id is not null ' || wms_plan_tasks_pvt.g_from_po_header_id,'query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'from_po_header_id', wms_plan_tasks_pvt.g_from_po_header_id );
      END IF;

      IF wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL THEN
        IF l_debug = 1 THEN
          debug('wms_plan_tasks_pvt.g_to_po_header_id is not null ' || wms_plan_tasks_pvt.g_to_po_header_id,'query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'to_po_header_id', wms_plan_tasks_pvt.g_to_po_header_id );
      END IF;

      IF wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_from_rma_header_id is not null ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'from_rma_header_id', wms_plan_tasks_pvt.g_from_rma_header_id );
      END IF;

      IF wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	 debug('wms_plan_tasks_pvt.g_to_rma_header_id is not null ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'to_rma_header_id', wms_plan_tasks_pvt.g_to_rma_header_id );
      END IF;

      IF wms_plan_tasks_pvt.g_op_plan_id   IS NOT NULL THEN
        IF l_debug = 1 THEN
	 debug('wms_plan_tasks_pvt.g_op_plan_id IS NOT NULL ','query_inbound');
	END IF;
         dbms_sql.bind_variable(l_query_handle, 'op_plan_id', wms_plan_tasks_pvt.g_op_plan_id  );
      END IF;

      IF wms_plan_tasks_pvt.g_include_crossdock THEN

         if (wms_plan_tasks_pvt.g_from_sales_order_id = wms_plan_tasks_pvt.g_to_sales_order_id) then
           l_is_range_so := FALSE;
         else/*range so is TRUE if from or to is null or form<> to*/
            l_is_range_so := TRUE;
         end if;
         if  wms_plan_tasks_pvt.g_from_sales_order_id is not null then
            select lpad(segment1,40), segment2,segment1
              INTO l_from_tonum_mso_seg1,l_from_mso_seg2,l_from_mso_seg1
              from mtl_sales_orders
             WHERE sales_order_id = wms_plan_tasks_pvt.g_from_sales_order_id;
         end if;
         IF(l_is_range_so) THEN
            /* Its a range...Query for details of to sales order */
            if  wms_plan_tasks_pvt.g_to_sales_order_id is not null then
               select lpad(segment1,40), segment2
                 INTO l_to_tonum_mso_seg1,l_to_mso_seg2
                 from mtl_sales_orders
                WHERE sales_order_id = wms_plan_tasks_pvt.g_to_sales_order_id;
             end if;/*added the above code to get the values since we are not going to join with mso 3455109*/
         ELSE
             l_to_tonum_mso_seg1 :=  l_from_tonum_mso_seg1;
             l_to_mso_seg2 :=  l_from_mso_seg2;
         END IF;


         IF wms_plan_tasks_pvt.g_include_internal_orders AND NOT wms_plan_tasks_pvt.g_include_sales_orders
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'source_type_id', 8);
         ELSIF NOT wms_plan_tasks_pvt.g_include_internal_orders AND wms_plan_tasks_pvt.g_include_sales_orders
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'source_type_id', 2);
         END IF;

         /*added if else for 3455109 since we are changing the query also need to change binds if its for completed task*/
         IF NOT g_is_completed_task THEN -- Non Completed tasks

            IF wms_plan_tasks_pvt.g_from_sales_order_id IS NOT NULL
            THEN
               DBMS_SQL.bind_variable (l_query_handle,'from_sales_order_id',wms_plan_tasks_pvt.g_from_sales_order_id);
            END IF;

            IF wms_plan_tasks_pvt.g_to_sales_order_id IS NOT NULL
            THEN
               DBMS_SQL.bind_variable (l_query_handle,'to_sales_order_id',wms_plan_tasks_pvt.g_to_sales_order_id);
            END IF;
         ELSE --completed tasks
            IF(l_is_range_so)  then
                 IF wms_plan_tasks_pvt.g_from_sales_order_id IS NOT NULL THEN
               --3240261 dbms_sql.bind_variable(l_query_handle, 'from_sales_order_id', p_from_sales_order_id);
               dbms_sql.bind_variable(l_query_handle,'l_from_tonum_mso_seg1',l_from_tonum_mso_seg1);--added for 3455109
               dbms_sql.bind_variable(l_query_handle,'l_from_mso_seg2',l_from_mso_seg2);--3455109
                 END IF;

                   IF wms_plan_tasks_pvt.g_to_sales_order_id IS NOT NULL THEN
               --3420261 dbms_sql.bind_variable(l_query_handle, 'to_sales_order_id', p_to_sales_order_id);
               dbms_sql.bind_variable(l_query_handle,'l_to_tonum_mso_seg1',l_to_tonum_mso_seg1);
               dbms_sql.bind_variable(l_query_handle,'l_to_mso_seg2',l_to_mso_seg2);
                 END IF;
             ELSE
               dbms_sql.bind_variable(l_query_handle,'l_from_mso_seg1',l_from_mso_seg1);
               dbms_sql.bind_variable(l_query_handle,'l_from_mso_seg2',l_from_mso_seg2);
             END IF;--end of range or not range so

         END IF;--end of copleted or not completed task 3455109

         IF wms_plan_tasks_pvt.g_from_pick_slip_number IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'from_pick_slip_number',wms_plan_tasks_pvt.g_from_pick_slip_number);
         END IF;

         IF wms_plan_tasks_pvt.g_to_pick_slip_number IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'to_pick_slip_number',wms_plan_tasks_pvt.g_to_pick_slip_number);
         END IF;

         IF wms_plan_tasks_pvt.g_customer_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'customer_id',wms_plan_tasks_pvt.g_customer_id);
         END IF;

         IF wms_plan_tasks_pvt.g_customer_category IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'customer_category',wms_plan_tasks_pvt.g_customer_category);
         END IF;

         IF wms_plan_tasks_pvt.g_trip_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'trip_id', wms_plan_tasks_pvt.g_trip_id);
         END IF;

         IF wms_plan_tasks_pvt.g_delivery_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'delivery_id',wms_plan_tasks_pvt.g_delivery_id);
         END IF;

         IF wms_plan_tasks_pvt.g_carrier_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'carrier_id',wms_plan_tasks_pvt.g_carrier_id);
         END IF;

         IF wms_plan_tasks_pvt.g_ship_method IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'ship_method',wms_plan_tasks_pvt.g_ship_method);
         END IF;

         IF wms_plan_tasks_pvt.g_shipment_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'shipment_priority',wms_plan_tasks_pvt.g_shipment_priority);
         END IF;

         IF wms_plan_tasks_pvt.g_from_shipment_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'from_shipment_date',wms_plan_tasks_pvt.g_from_shipment_date);
         END IF;

         IF wms_plan_tasks_pvt.g_to_shipment_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'to_shipment_date',wms_plan_tasks_pvt.g_to_shipment_date);
         END IF;
          /*
         IF wms_plan_tasks_pvt.g_time_till_shipment IS NOT NULL AND wms_plan_tasks_pvt.g_time_till_shipment_uom_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'p_time_till_shipment',wms_plan_tasks_pvt.g_time_till_shipment);
         END IF;
          */

         IF wms_plan_tasks_pvt.g_ship_to_state IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'ship_to_state',wms_plan_tasks_pvt.g_ship_to_state);
         END IF;

         IF wms_plan_tasks_pvt.g_ship_to_country IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'ship_to_country',wms_plan_tasks_pvt.g_ship_to_country);
         END IF;

         IF wms_plan_tasks_pvt.g_ship_to_postal_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'ship_to_postal_code',wms_plan_tasks_pvt.g_ship_to_postal_code);
         END IF;

         IF wms_plan_tasks_pvt.g_from_number_of_order_lines IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'from_number_of_order_lines',wms_plan_tasks_pvt.g_from_number_of_order_lines);
         END IF;

         IF wms_plan_tasks_pvt.g_to_number_of_order_lines IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,'to_number_of_order_lines',wms_plan_tasks_pvt.g_to_number_of_order_lines);
         END IF;

      END IF;

      /* end of setting the bind variables */
      IF l_debug = 1 THEN
        debug('end setting the bind variables ','query_inbound');
      END IF;
      IF p_summary_mode = 1 THEN
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 1, l_wms_task_type);
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 2, l_task_count);
      END IF;

      l_query_count           := DBMS_SQL.EXECUTE(l_query_handle);
      IF p_summary_mode = 1 THEN
		LOOP
		       IF DBMS_SQL.FETCH_ROWS(l_query_handle)>0 THEN
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 1, l_wms_task_type);
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 2, l_task_count);
			  IF l_debug = 1 THEN
			    debug(' l_wms_task_type : ' || l_wms_task_type, 'query_inbound');
			    debug(' l_wms_task_count : ' || l_task_count, 'query_inbound');
			  END IF;
			  IF l_wms_task_type > 0 THEN
				  wms_waveplan_tasks_pvt.g_wms_task_summary_tbl(l_wms_task_type).wms_task_type := l_wms_task_type;
				  wms_waveplan_tasks_pvt.g_wms_task_summary_tbl(l_wms_task_type).task_count := wms_waveplan_tasks_pvt.g_wms_task_summary_tbl(l_wms_task_type).task_count + l_task_count;
			  ELSIF l_wms_task_type = -1 THEN
			  /* There are some taks populated with task_type as -1, we will show them as putaway tasks, not sure if this is correct. Doing it this way inorder to be consitent with the results grid*/

				wms_waveplan_tasks_pvt.g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_putaway).task_count := wms_waveplan_tasks_pvt.g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_putaway).task_count + l_task_count;
			  END IF;
		       ELSE
			  EXIT; -- no more rows returned from dynamic SQL
		       END IF;
		END LOOP;
	END IF;
      IF l_debug = 1 THEN
        debug('l_query_count ' || l_query_count,'query_inbound');
      END IF;
      wms_plan_tasks_pvt.g_plans_tasks_record_count :=
         wms_plan_tasks_pvt.g_plans_tasks_record_count + l_query_count;
     END IF;

      /* Now the tasks records are inserted into the table wwtt . Next insert
         the plan records if l_plans_query_str is not null */
     IF l_plans_query_str IS NOT NULL THEN
        l_plans_query := l_insert_str || l_plans_query_str;
        IF l_debug = 1 THEN
	  debug('l_plans_query ' || l_plans_query,'query_inbound');
	END IF;
        l_query_handle          := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(l_query_handle, l_plans_query, DBMS_SQL.native);

        /* Set the bind variables now */
      IF wms_plan_tasks_pvt.g_organization_id IS NOT NULL THEN
        IF l_debug = 1 THEN
          debug('wms_plan_tasks_pvt.g_organization_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'org_id', wms_plan_tasks_pvt.g_organization_id);
      END IF;
      IF wms_plan_tasks_pvt.g_subinventory_code IS NOT NULL THEN
        IF l_debug = 1 THEN
          debug('wms_plan_tasks_pvt.g_subinventory_code IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'sub_code', wms_plan_tasks_pvt.g_subinventory_code);
      END IF;
      IF wms_plan_tasks_pvt.g_locator_id IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_locator_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'loc_id', wms_plan_tasks_pvt.g_locator_id);
      END IF;
      IF wms_plan_tasks_pvt.g_to_subinventory_code  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_to_subinventory_code IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'to_sub_code', wms_plan_tasks_pvt.g_to_subinventory_code );
      END IF;
      IF wms_plan_tasks_pvt.g_to_locator_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_to_locator_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'to_loc_id', wms_plan_tasks_pvt.g_to_locator_id );
      END IF;
      IF wms_plan_tasks_pvt.g_inventory_item_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_inventory_item_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'item_id', wms_plan_tasks_pvt.g_inventory_item_id );
      END IF;
      IF wms_plan_tasks_pvt.g_category_set_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_category_set_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'category_set_id', wms_plan_tasks_pvt.g_category_set_id );
      END IF;
      IF wms_plan_tasks_pvt.g_item_category_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_item_category_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'item_category_id', wms_plan_tasks_pvt.g_item_category_id );
      END IF;
      IF wms_plan_tasks_pvt.g_user_task_type_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_user_task_type_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'user_task_type_id', wms_plan_tasks_pvt.g_user_task_type_id );
      END IF;
      IF wms_plan_tasks_pvt.g_from_task_quantity  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_from_task_quantity IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'from_task_quantity', wms_plan_tasks_pvt.g_from_task_quantity );
      END IF;
      IF wms_plan_tasks_pvt.g_to_task_quantity  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_to_task_quantity IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'to_task_quantity', wms_plan_tasks_pvt.g_to_task_quantity );
      END IF;
      IF wms_plan_tasks_pvt.g_from_task_priority  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_from_task_priority IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'from_task_priority', wms_plan_tasks_pvt.g_from_task_priority );
      END IF;

      IF wms_plan_tasks_pvt.g_to_task_priority  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_to_task_priority IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'to_task_priority', wms_plan_tasks_pvt.g_to_task_priority );
      END IF;
      IF wms_plan_tasks_pvt.g_from_creation_date  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_from_creation_date IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'from_creation_date', wms_plan_tasks_pvt.g_from_creation_date );
      END IF;
      IF wms_plan_tasks_pvt.g_to_creation_date  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_to_creation_date IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'to_creation_date', wms_plan_tasks_pvt.g_to_creation_date );
      END IF;
      IF wms_plan_tasks_pvt.g_plan_type_id  IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_plan_type_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'plan_type_id', wms_plan_tasks_pvt.g_plan_type_id );
      END IF;
      IF wms_plan_tasks_pvt.g_op_plan_id   IS NOT NULL THEN
        IF l_debug = 1 THEN
	  debug('wms_plan_tasks_pvt.g_op_plan_id IS NOT NULL ','query_inbound');
	END IF;
          dbms_sql.bind_variable(l_query_handle, 'op_plan_id', wms_plan_tasks_pvt.g_op_plan_id  );
      END IF;
        /* end setting the bind variables */
        IF l_debug = 1 THEN
	  debug('end setting the bind variables for plans query','query_inbound');
	END IF;
        l_query_count           := DBMS_SQL.EXECUTE(l_query_handle);
        IF l_debug = 1 THEN
	  debug('l_query_count after executing the plans query ' || l_query_count ,'query_inbound');
	END IF;
        wms_plan_tasks_pvt.g_plans_tasks_record_count :=
         wms_plan_tasks_pvt.g_plans_tasks_record_count + l_query_count;
     END IF;

     set_inbound_source_header_line;
     /* delete the drop-pending record from the temp table, when both independent and planned
      * task records are queried
      */
      --IF wms_plan_tasks_pvt.g_query_independent_tasks AND
      IF wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded
      THEN
      l_planned_task := wms_plan_tasks_pvt.g_plan_task_types(2);
         DELETE FROM wms_waveplan_tasks_temp wwtt
            WHERE EXISTS (
                     SELECT 1
                       FROM wms_op_operation_instances wooi
                      WHERE wwtt.transaction_temp_id = wooi.source_task_id
                        AND wwtt.operation_sequence = wooi.operation_sequence
                        AND wooi.operation_status IN (1,2) -- added for bug 5172443 to delete drop-active record
                        AND wooi.complete_time IS NULL)
              AND wwtt.plans_tasks = l_planned_task
              AND wwtt.status_id = 4;
         IF l_debug = 1 THEN
	   DEBUG('rows deleted '|| SQL%ROWCOUNT);
	 END IF;
         wms_plan_tasks_pvt.g_plans_tasks_record_count :=
                  wms_plan_tasks_pvt.g_plans_tasks_record_count - SQL%ROWCOUNT;
      END IF;

   EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     	x_return_status := fnd_api.g_ret_sts_error ;
      IF l_debug = 1 THEN
        DEBUG(SQLERRM, 'plan_tasks.query_inbound_tasks-error');
      END IF;
   WHEN fnd_api.g_exc_unexpected_error THEN
    	x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_debug = 1 THEN
        DEBUG(SQLERRM, 'plan_tasks.query_inbound_tasks-unexpected error');
      END IF;
   WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_error ;
      IF l_debug = 1 THEN
        DEBUG(SQLERRM, 'plan_tasks.query_inbound_tasks-other error');
      END IF;

END query_inbound_plan_tasks;

PROCEDURE get_plans(x_plans_query_str OUT NOCOPY VARCHAR2) IS
--Bug6688574 :Increased the length of l_plans_query_str from 8000 to 16000.
l_plans_query_str  VARCHAR2(16000);

l_plans_str VARCHAR2(5000);
l_plans_select_str varchar2(3000);
l_plans_from_str varchar2(1000);
l_plans_where_str varchar2(3000);

l_wdth_str VARCHAR2(5000);
l_wdth_select_str VARCHAR2(3000);
l_wdth_from_str VARCHAR2(3000);
l_wdth_where_str VARCHAR2(3000);

l_inline_query VARCHAR2(500);
l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
BEGIN
   IF l_debug = 1 THEN
     debug('in get_plans ','get_plans');
   END IF;

   l_inline_query := ' (Select distinct parent_line_id, reference_id, ' ||
                     ' reference, source_header, line_number '||
                     ' from wms_waveplan_tasks_temp where ' ||
                     ' task_type_id in (2,8) ' ||
                     ' and operation_plan_id is not null ' ||
                     ' and parent_line_id is not null) wwtt ';
   /**** Get the non-completed plans query first ****/

   IF wms_plan_tasks_pvt.g_is_pending_plan OR
      wms_plan_tasks_pvt.g_is_inprogress_plan THEN

   IF l_debug = 1 THEN
     debug('pending or inprogress plans are queried ','get_plans');
   END IF;
   l_plans_select_str := 'SELECT ''+'',' ||
                     '''' || wms_plan_tasks_pvt.g_plan_task_types(3) || ''', ' ||
                     'mmtt.transaction_temp_id, '||
                     'mmtt.parent_line_id, ' ||
                     'mmtt.inventory_item_id, ' ||
                     'msiv.concatenated_segments, ' ||
                     'msiv.description, ' ||
                     'msiv.unit_weight, ' ||
                     'msiv.weight_uom_code, ' ||
                     'msiv.unit_volume, '||
                     'msiv.volume_uom_code, ' ||
                     'mmtt.organization_id, ' ||
                     'mmtt.revision, ' ||
                     'mmtt.subinventory_code, ' ||
                     'mmtt.locator_id, ' ||
                     'decode(milv.segment19, null, milv.concatenated_segments, null), ' ||
                     'wopi.status, ' ||
                     'wopi.status, ' ||
                     'decode(wopi.status,' ||
                     '1, ''' || wms_plan_tasks_pvt.g_plan_status_codes(1)
                             || ''', 2, '''
                             || wms_plan_tasks_pvt.g_plan_status_codes(2)
                             || ''', 3, '''
                             || wms_plan_tasks_pvt.g_plan_status_codes(3)
                             || ''', 4, '''
                             || wms_plan_tasks_pvt.g_plan_status_codes(4)
                             || ''', 5, '''
                             || wms_plan_tasks_pvt.g_plan_status_codes(5)
                             || ''', 6, '''
                             || wms_plan_tasks_pvt.g_plan_status_codes(6)
                             || ''', 7, '''
                             || wms_plan_tasks_pvt.g_plan_status_codes(7)
                             || '''), ' ||
                       'mmtt.transaction_type_id, ' ||
                       'mmtt.transaction_action_id, ' ||
                       'mmtt.transaction_source_type_id, ';

      IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str
        || 'mtst.transaction_source_type_name, '; --transaction_source_type
      END IF;

      l_plans_select_str  := l_plans_select_str ||
                        'mmtt.transaction_source_id, ' ||
                        'mmtt.trx_source_line_id, ' ||
                        'mmtt.transfer_organization, ';

      IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str || 'mp1.organization_code, ';
      END IF;

      l_plans_select_str:=l_plans_select_str ||
                         'mmtt.transfer_subinventory, ' ||
                         'mmtt.transfer_to_location, ';

      IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str ||
        'decode(milv1.segment19, null, milv1.concatenated_segments, null), ';
      END IF;

      l_plans_select_str := l_plans_select_str ||
                        'mmtt.transaction_uom, ' ||
                        'mmtt.transaction_quantity, '||
                        'mmtt.standard_operation_id, ';
      IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
         l_plans_select_str  := l_plans_select_str || ' NULL, ';
      END IF;
      l_plans_select_str  := l_plans_select_str ||
                        'mmtt.move_order_line_id, ' || /*move_order_line_id */
                        'mmtt.pick_slip_number, ' || /*pick_slip_number*/
                        'mmtt.cartonization_id, '; /*cartonization_id */

      IF wms_plan_tasks_pvt.g_cartonization_lpn_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str
           || 'wlpn2.license_plate_number, '; --cartonization_lpn
      END IF;

      l_plans_select_str  := l_plans_select_str ||
                        'mmtt.allocated_lpn_id, '; /*allocated_lpn_id*/

      IF wms_plan_tasks_pvt.g_allocated_lpn_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str
           || 'wlpn1.license_plate_number, '; --allocated_lpn
      END IF;

      l_plans_select_str  := l_plans_select_str ||
                        'mmtt.container_item_id, '; --container_item_id

      IF wms_plan_tasks_pvt.g_container_item_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str
                    || 'msiv1.concatenated_segments, '; --container_item
      END IF;

      l_plans_select_str := l_plans_select_str ||
	                 'mmtt.lpn_id, '; --from_lpn_id

      IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
	 l_plans_select_str := l_plans_select_str ||
	                 'wlpn5.license_plate_number, ';  --from_lpn
      END IF;

      l_plans_select_str  := l_plans_select_str ||
                         'mmtt.content_lpn_id, '; --content_lpn_id

      IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
        l_plans_select_str  := l_plans_select_str
           || 'wlpn3.license_plate_number, '; --content_lpn
      END IF;

      l_plans_select_str  := l_plans_select_str ||'mmtt.transfer_lpn_id, ';

      IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
        l_plans_select_str := l_plans_select_str || 'wlpn4.license_plate_number, ';
      END IF;
      l_plans_select_str := l_plans_select_str ||
                         'mmtt.last_update_date, ' || /*mmtt_last_update_date*/
                         'mmtt.last_updated_by, ' || /*mmtt_last_updated_by*/
                         'mmtt.task_priority, ' || /*priority*/
                         'mmtt.task_priority, ' || /*priority_original */
                         'mmtt.wms_task_type, ' || /*task_type_id */
                         'decode(mmtt.wms_task_type,'
                            || '1, '''
                            || wms_plan_tasks_pvt.g_task_types(1)
                            || ''', 2, '''
                            || wms_plan_tasks_pvt.g_task_types(2)
                            || ''', 3, '''
                            || wms_plan_tasks_pvt.g_task_types(3)
                            || ''', 4, '''
                            || wms_plan_tasks_pvt.g_task_types(4)
                            || ''', 5, '''
                            || wms_plan_tasks_pvt.g_task_types(5)
                            || ''', 6, '''
                            || wms_plan_tasks_pvt.g_task_types(6)
                            || ''', 7, '''
                            || wms_plan_tasks_pvt.g_task_types(7)
                            || ''', 8, '''
                            || wms_plan_tasks_pvt.g_task_types(8)
                            || '''), ' ||
                    'mmtt.creation_date, ' || /*creation_time  */
                    'mmtt.operation_plan_id, '; /*operation_plan_id*/
     IF wms_plan_tasks_pvt.g_operation_plan_visible = 'T' THEN
        l_plans_select_str := l_plans_select_str ||
                    'wop.operation_plan_name, '; /*operation_plan*/
     END IF;

     IF wms_plan_tasks_pvt.g_operation_sequence_visible = 'T' THEN
        l_plans_select_str := l_plans_select_str || 'to_number(null), '; --operation_sequence
     END IF;

     l_plans_select_str := l_plans_select_str ||
                    'wopi.op_plan_instance_id op_plan_instance_id, '|| /*op_plan_instance_id*/
                    --'to_number(null), '|| /*operation_sequence*/
                    'to_number(null), ' || /*task_id*/
                    'to_number(null), ' || /*person_id*/
                    'to_number(null), '|| /*person_id_original*/
                    'null, ' ||     /*person*/
                    'to_date(null), ' || /*effective_start_date*/
                    'to_date(null), ' || /*effective_end_date*/
                    'to_number(null), '; /*person_resource_id*/
     IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
        l_plans_select_str := l_plans_select_str ||
                    'null, ';/*person_resource_code*/
     END IF;
     l_plans_select_str := l_plans_select_str ||
                    'to_number(null), '; /*machine_resource_id*/
     IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
      l_plans_select_str := l_plans_select_str ||
                    'null, '; /*machine_resource_code*/
     END IF;
    l_plans_select_str := l_plans_select_str ||
                    'null, ' || /*equipment_instance*/
                    'to_date(null), ' || /*dispatched_time*/
                    'to_date(null), ' || /*loaded_time*/
                    'to_date(null), ' || /*drop_off_time*/
                    'to_date(null), ' || /*wdt_last_update_date*/
                    'to_number(null), ' || /*wdt_last_updated_by*/
                    '''N'', ' ||  /*is_modified   */
                    'mmtt.secondary_uom_code, '||
                    'mmtt.secondary_transaction_quantity ';


     /* If inbound specific query is made, select more fields */
     IF wms_plan_tasks_pvt.g_include_inbound THEN
      l_plans_select_str     := l_plans_select_str
                                || ', wwtt.reference_id '
                                || ', wwtt.reference ';
     END IF;

    IF wms_plan_tasks_pvt.g_inbound_specific_query THEN
      l_plans_select_str  := l_plans_select_str
                             || ', wwtt.source_header '
                             || ', wwtt.line_number ';
    END IF;

   IF l_debug = 1 THEN
     debug('l_plans_select_str ' ||l_plans_select_str,'get_plans');
   END IF;
/** Now build the 'from' part of the query **/
l_plans_from_str := ' FROM mtl_material_transactions_temp mmtt '
		   || ', mtl_system_items_kfv msiv '
		   || ', mtl_item_locations_kfv milv '
		   || ', wms_op_plan_instances wopi '
		   || ', wms_op_plans_vl wop ';

IF wms_plan_tasks_pvt.g_item_category_id IS NOT NULL
   OR wms_plan_tasks_pvt.g_category_set_id IS NOT NULL THEN
  l_plans_from_str  := l_plans_from_str || ', mtl_item_categories mic ';
END IF;

 IF wms_plan_tasks_pvt.g_allocated_lpn_visible = 'T' then
  l_plans_from_str  := l_plans_from_str || ', wms_license_plate_numbers wlpn1 ';
 END IF;

 IF wms_plan_tasks_pvt.g_cartonization_lpn_visible = 'T' THEN
  l_plans_from_str  := l_plans_from_str || ', wms_license_plate_numbers wlpn2 ';
 END IF;

 IF wms_plan_tasks_pvt.g_container_item_visible = 'T' THEN
   l_plans_from_str  := l_plans_from_str || ', mtl_system_items_kfv msiv1 ';
END IF;

IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
   l_plans_from_str := l_plans_from_str || ', wms_license_plate_numbers wlpn5 ';
END IF;

IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
  l_plans_from_str  := l_plans_from_str || ', wms_license_plate_numbers wlpn3 ';
END IF;

IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
  l_plans_from_str  := l_plans_from_str || ', wms_license_plate_numbers wlpn4 ';
END IF;

IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
   l_plans_from_str  := l_plans_from_str || ', mtl_parameters mp1 ';
END IF;
IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
   l_plans_from_str  := l_plans_from_str || ', mtl_item_locations_kfv milv1 ';
END IF;

IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
  l_plans_from_str  := l_plans_from_str || ', mtl_txn_source_types mtst ';
END IF;

 IF wms_plan_tasks_pvt.g_inbound_specific_query  OR
    wms_plan_tasks_pvt.g_include_inbound THEN
    l_plans_from_str := l_plans_from_str || ', ' || l_inline_query;
 END IF;

IF l_debug = 1 THEN
  debug('l_plans_from_str ' || l_plans_from_str,'get_plans');
END IF;
/** Build the plans 'where' clause **/
l_plans_where_str := ' WHERE 1=1 ';
l_plans_where_str := l_plans_where_str
           || 'AND mmtt.organization_id = msiv.organization_id '
           || 'AND mmtt.inventory_item_id = msiv.inventory_item_id '
           || 'AND mmtt.organization_id = milv.organization_id(+) '
           || 'AND mmtt.locator_id = milv.inventory_location_id(+) '
           || 'AND mmtt.operation_plan_id = wop.operation_plan_id '
           || 'AND mmtt.transaction_temp_id = wopi.source_task_id '
           || 'and mmtt.parent_line_id is null '
           || 'and mmtt.operation_plan_id is not null ';

IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
  l_plans_where_str := l_plans_where_str
         || 'AND mmtt.transfer_subinventory = milv1.subinventory_code(+) '
         || 'AND mmtt.transfer_to_location = milv1.inventory_location_id(+) ';
end if;
IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
  l_plans_where_str := l_plans_where_str
  || 'AND mmtt.transaction_source_type_id = mtst.transaction_source_type_id ';
end if;
IF wms_plan_tasks_pvt.g_allocated_lpn_visible = 'T' then
  l_plans_where_str := l_plans_where_str
           || 'AND mmtt.allocated_lpn_id = wlpn1.lpn_id(+) ';
end if;
IF wms_plan_tasks_pvt.g_cartonization_lpn_visible = 'T' then
  l_plans_where_str := l_plans_where_str
           || 'AND mmtt.cartonization_id = wlpn2.lpn_id(+) ';
end if;
IF wms_plan_tasks_pvt.g_container_item_visible = 'T' then
  l_plans_where_str := l_plans_where_str
           || 'AND mmtt.container_item_id = msiv1.inventory_item_id(+) '
           || 'AND mmtt.organization_id = msiv1.organization_id(+) ';
end if;
IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
   l_plans_where_str := l_plans_where_str
           || 'AND mmtt.lpn_id = wlpn5.lpn_id(+) ';
END IF;
IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
  l_plans_where_str := l_plans_where_str
           || 'AND mmtt.content_lpn_id = wlpn3.lpn_id(+) ';
end if;
IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
  l_plans_where_str := l_plans_where_str
           || 'AND mmtt.transfer_lpn_id = wlpn4.lpn_id(+) ';
end if;
IF wms_plan_tasks_pvt.g_organization_id IS NOT NULL THEN
   l_plans_where_str := l_plans_where_str
           || 'AND mmtt.organization_id = :org_id ';
END IF;
IF wms_plan_tasks_pvt.g_subinventory_code IS NOT NULL THEN
  l_plans_where_str := l_plans_where_str
           || 'AND mmtt.subinventory_code = :sub_code ';
END IF;

IF wms_plan_tasks_pvt.g_locator_id IS NOT NULL THEN
  l_plans_where_str  := l_plans_where_str
                 || 'AND mmtt.locator_id = :loc_id ';
END IF;

IF wms_plan_tasks_pvt.g_to_subinventory_code IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
           || 'AND mmtt.transfer_subinventory = :to_sub_code ';
END IF;

IF wms_plan_tasks_pvt.g_to_locator_id IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
                || 'AND mmtt.transfer_to_location = :to_loc_id ';
END IF;

IF wms_plan_tasks_pvt.g_inventory_item_id IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
                     || 'AND mmtt.inventory_item_id = :item_id ';
END IF;

IF wms_plan_tasks_pvt.g_category_set_id IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
                || 'AND mic.category_set_id = :category_set_id ';
END IF;

IF wms_plan_tasks_pvt.g_item_category_id IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
           || 'AND mmtt.inventory_item_id = mic.inventory_item_id '
           || 'AND mic.organization_id = mmtt.organization_id '
           || 'AND mic.category_id = :item_category_id ';
END IF;

IF wms_plan_tasks_pvt.g_user_task_type_id IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
           || 'AND mmtt.standard_operation_id = :user_task_type_id ';
END IF;

IF wms_plan_tasks_pvt.g_from_task_quantity IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
           || 'AND mmtt.transaction_quantity >= :from_task_quantity ';
END IF;

IF wms_plan_tasks_pvt.g_to_task_quantity IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
           || 'AND mmtt.transaction_quantity <= :to_task_quantity ';
END IF;

IF wms_plan_tasks_pvt.g_from_task_priority IS NOT NULL THEN
   l_plans_where_str  := l_plans_where_str
          || 'AND mmtt.task_priority <= :from_task_priority ';
END IF;

IF wms_plan_tasks_pvt.g_to_task_priority IS NOT NULL THEN
    l_plans_where_str  := l_plans_where_str
             || 'AND mmtt.task_priority <= :to_task_priority ';
END IF;

IF wms_plan_tasks_pvt.g_from_creation_date IS NOT NULL THEN
    l_plans_where_str  := l_plans_where_str
            -- || 'AND mmtt.creation_date >= :from_creation_date ';--commented in bug 6854145
	       || 'AND TRUNC(mmtt.creation_date) >= TRUNC(:from_creation_date) ';--Added TRUNC in bug 6854145
END IF;

IF wms_plan_tasks_pvt.g_to_creation_date IS NOT NULL THEN
    l_plans_where_str  := l_plans_where_str
               --|| 'AND mmtt.creation_date <= :to_creation_date ';--commented in bug 6854145
	         || 'AND TRUNC(mmtt.creation_date) <= TRUNC(:to_creation_date) ';--Added TRUNC in bug 6854145
END IF;
IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
    l_plans_where_str := l_plans_where_str
        || 'AND mmtt.transfer_organization = mp1.organization_id(+) ';
end if;

/** The following section handles the plan_specific query **/
if wms_plan_tasks_pvt.g_plan_type_id is not null then
   l_plans_where_str := l_plans_where_str
              || 'AND wop.plan_type_id = :plan_type_id ';
end if;
if wms_plan_tasks_pvt.g_op_plan_id is not null then
   l_plans_where_str := l_plans_where_str
              || 'AND wop.operation_plan_id = :op_plan_id ';
end if;

 l_plans_where_str := l_plans_where_str || ' AND wopi.status in (';
    IF wms_plan_tasks_pvt.g_is_pending_plan THEN
          l_plans_where_str := l_plans_where_str || '1';
       IF wms_plan_tasks_pvt.g_is_inprogress_plan THEN
          l_plans_where_str := l_plans_where_str || ',6';
       END IF;
    ELSIF wms_plan_tasks_pvt.g_is_inprogress_plan THEN
          l_plans_where_str := l_plans_where_str || '6';
    END IF;

    l_plans_where_str := l_plans_where_str || ')';


/** The following section handles the inbound specific query
    The challenge here is - the link between the plan mmtt/wdth
    record is lost because MMTT.move_order_line_id is made null.
    So we have to fetch the records via the child records.
    This requires that the task records are already inserted into wwtt.
    We then fetch all parent records of the task records already
    inserted into wwtt.
    But now we do not check if the planned_task records are already
    inserted into wwtt or not. This validation should be taken care of
    in the calling program - In this case, it is get_inbound_tasks
  **/
IF wms_plan_tasks_pvt.g_inbound_specific_query OR
   wms_plan_tasks_pvt.g_include_inbound THEN
   l_plans_where_str :=   l_plans_where_str
                          || ' AND mmtt.transaction_temp_id = wwtt.parent_line_id ';
END IF;
  /* Filter based on the status - pending/inprogress. */
l_plans_str := l_plans_select_str || l_plans_from_str || l_plans_where_str;

END IF; --if pending or inprogress


/* For completed/cancelled/aborted plans, call the procedure get_wdth_plan_records */
IF  wms_plan_tasks_pvt.g_is_completed_plan  OR
    wms_plan_tasks_pvt.g_is_cancelled_plan   OR
    wms_plan_tasks_pvt.g_is_aborted_plan    THEN
    IF l_debug = 1 THEN
      debug('completed/canceled/aborted plans are queried.calling get_wdth_plan_records ','get_plans');
    END IF;
    get_wdth_plan_records(l_wdth_select_str, l_wdth_from_str, l_wdth_where_str);

    IF l_debug = 1 THEN
      debug('l_wdth_select_str from get_wdth_plan_records: ' ||l_wdth_select_str,'get_plans');
      debug('l_wdth_from_str from get_wdth_plan_records: ' ||l_wdth_from_str,'get_plans');
      debug('l_wdth_where_str from get_wdth_plan_records: ' ||l_wdth_where_str,'get_plans');
    END IF;

    /** The following section handles the plan_specific query **/
   if wms_plan_tasks_pvt.g_plan_type_id is not null then
       l_wdth_where_str := l_wdth_where_str
              || 'AND wop.plan_type_id = :plan_type_id ';
   end if;
   if wms_plan_tasks_pvt.g_op_plan_id is not null then
       l_wdth_where_str := l_wdth_where_str
              || 'AND wop.operation_plan_id = :op_plan_id ';
   end if;
   /* If inbound specific query or inbound query is made, append the inline query to the
      from clause
    */
    IF wms_plan_tasks_pvt.g_inbound_specific_query  OR
       wms_plan_tasks_pvt.g_include_inbound THEN
       l_wdth_from_str := l_wdth_from_str || ', ' || l_inline_query;
    END IF;
    IF wms_plan_tasks_pvt.g_inbound_specific_query  OR
       wms_plan_tasks_pvt.g_include_inbound THEN
       IF l_debug = 1 THEN
         debug('inbound specific query is made ','get_plans');
       END IF;
        l_wdth_where_str := l_wdth_where_str
                            || ' AND wdth.transaction_id = wwtt.parent_line_id ';

       IF l_debug = 1 THEN
         debug('l_wdth_where_str after appending inbound specific query ' || l_wdth_where_str,'get_plans');
       END IF;
    END IF;
    l_wdth_str := l_wdth_select_str || l_wdth_from_str || l_wdth_where_str;
    IF l_debug = 1 THEN
      debug('l_wdth_str ' || l_wdth_str,'get_plans');
    END IF;
END IF;

IF l_plans_str IS NOT NULL THEN
   IF l_debug = 1 THEN
     debug('l_plans_str is not null' || l_plans_str,'get_plans');
   END IF;
   l_plans_query_str := l_plans_str;
   IF l_debug = 1 THEN
     debug('l_plans_query_str ' || l_plans_query_str,'get_plans');
   END IF;
   IF l_wdth_str IS NOT NULL THEN
      IF l_debug = 1 THEN
        debug('l_plans_str is not null and l_wdth_str is not null','get_plans');
      END IF;
      l_plans_query_str := l_plans_str || ' UNION ALL ' || l_wdth_str;
      IF l_debug = 1 THEN
        debug('l_plans_query_str ' || l_plans_query_str,'get_plans');
      END IF;
   END IF;
ELSIF l_wdth_str IS  NOT NULL THEN
   IF l_debug = 1 THEN
     debug('l_wdth_str is not null','get_plans');
   END IF;
   l_plans_query_str := l_wdth_str;
   IF l_debug = 1 THEN
     debug('l_plans_query_str ' || l_plans_query_str,'get_plans');
   END IF;
END IF;

x_plans_query_str := l_plans_query_str;
END get_plans;

PROCEDURE get_tasks(x_tasks_query_str OUT NOCOPY VARCHAR2, p_summary_mode NUMBER DEFAULT 0) IS
l_tasks_query_str wms_plan_tasks_pvt.long_sql:= '';

l_tasks_str  wms_plan_tasks_pvt.long_sql := NULL;
l_tasks_select_str wms_plan_tasks_pvt.short_sql := NULL;
l_tasks_from_str   wms_plan_tasks_pvt.short_sql:= NULL;
l_tasks_where_str  wms_plan_tasks_pvt.short_sql:= NULL;

l_completed_tasks_str wms_plan_tasks_pvt.long_sql:= NULL;
l_completed_tasks_select_str wms_plan_tasks_pvt.long_sql:= NULL;  /* Bug 5507934  */
l_completed_tasks_from_str wms_plan_tasks_pvt.long_sql:= NULL;
l_completed_tasks_where_str wms_plan_tasks_pvt.long_sql:= NULL;

l_completed_records_str wms_plan_tasks_pvt.long_sql:= NULL;
l_completed_records_select_str wms_plan_tasks_pvt.long_sql:= NULL;
l_completed_records_from_str wms_plan_tasks_pvt.long_sql:= NULL;
l_completed_records_where_str wms_plan_tasks_pvt.long_sql:= NULL;  /* End of Bug 5507934  */

l_inbound_select_str wms_plan_tasks_pvt.short_sql:= NULL;
l_inbound_from_str wms_plan_tasks_pvt.short_sql:= NULL;
l_inbound_where_str wms_plan_tasks_pvt.short_sql:= NULL;

l_outbound_from_str wms_plan_tasks_pvt.short_sql:= NULL;
l_outbound_where_str wms_plan_tasks_pvt.short_sql:= NULL;

l_is_pending boolean;
l_is_loaded boolean;
l_is_completed boolean;
l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
BEGIN
IF l_debug = 1 THEN
  debug('in get_tasks ', 'get_tasks');
END IF;
if wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending = TRUE OR
   wms_plan_tasks_pvt.g_is_pending_task = TRUE then
   IF l_debug = 1 THEN
     debug('query for pending task','get_tasks');
   END IF;
   l_is_pending := TRUE;
ELSE
  IF l_debug = 1 THEN
    debug('do not query for pending task','get_tasks');
  END IF;
   l_is_pending := false;
end if;

if wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded = TRUE OR
   wms_plan_tasks_pvt.g_is_loaded_task = TRUE then
   l_is_loaded := TRUE;
   IF l_debug = 1 THEN
     debug('query for loaded task','get_tasks');
   END IF;
ELSE
   IF l_debug = 1 THEN
     debug('do not query for loaded task ','get_tasks');
   END IF;
   l_is_loaded := false;
end if;

if wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed = TRUE OR
   wms_plan_tasks_pvt.g_is_completed_task = TRUE then
   l_is_completed := TRUE;
   IF l_debug = 1 THEN
     debug('query for completed task ','get_tasks');
   END IF;
ELSE
    IF l_debug = 1 THEN
      debug('do not query for completed task ','get_tasks');
    END IF;
   l_is_completed := false;
end if;

IF l_is_pending OR l_is_loaded THEN
  IF l_debug = 1 THEN
    debug('query for loaded and pending tasks. calling get_generic_select ','get_tasks');
  END IF;
  -- Bug #3754781 +1 line.
  g_inbound_cycle := TRUE;

  IF p_summary_mode = 1 THEN
	l_tasks_select_str := ' SELECT mmtt.wms_task_type, count(*) ';
  ELSE
	l_tasks_select_str := wms_waveplan_tasks_pvt.get_generic_select(
		  p_is_pending                 => l_is_pending
	        , p_is_loaded                  => l_is_loaded
		, p_is_completed               => FALSE
        );
  END IF; -- p_summary_mode
  -- Bug #3754781 +1 line.
  g_inbound_cycle := FALSE;
  IF l_debug = 1 THEN
    debug('after calling get_generic_select :','get_tasks');
    debug('l_tasks_select_str ' || l_tasks_select_str,'get_tasks');
    debug('query for loaded and pending tasks. calling get_generic_from ','get_tasks');
  END IF;
  l_tasks_from_str          :=
        wms_waveplan_tasks_pvt.get_generic_from(
          p_is_loaded                  => l_is_loaded
        , p_is_completed               => FALSE
        , p_item_category_id           => wms_plan_tasks_pvt.g_item_category_id
        , p_category_set_id            => wms_plan_tasks_pvt.g_category_set_id
        );

  l_tasks_where_str         :=
        wms_waveplan_tasks_pvt.get_generic_where(
          p_add                        => wms_plan_tasks_pvt.g_is_add
        , p_organization_id            => wms_plan_tasks_pvt.g_organization_id
        , p_subinventory_code          => wms_plan_tasks_pvt.g_subinventory_code
        , p_locator_id                 => wms_plan_tasks_pvt.g_locator_id
        , p_to_subinventory_code       => wms_plan_tasks_pvt.g_to_subinventory_code
        , p_to_locator_id              => wms_plan_tasks_pvt.g_to_locator_id
        , p_inventory_item_id          => wms_plan_tasks_pvt.g_inventory_item_id
        , p_category_set_id            => wms_plan_tasks_pvt.g_category_set_id
        , p_item_category_id           => wms_plan_tasks_pvt.g_item_category_id
        , p_person_id                  => wms_plan_tasks_pvt.g_person_id
        , p_person_resource_id         => wms_plan_tasks_pvt.g_person_resource_id
        , p_equipment_type_id          => wms_plan_tasks_pvt.g_equipment_type_id
        , p_machine_resource_id        => wms_plan_tasks_pvt.g_machine_resource_id
        , p_machine_instance           => wms_plan_tasks_pvt.g_machine_instance
        , p_from_task_quantity         => wms_plan_tasks_pvt.g_from_task_quantity
        , p_to_task_quantity           => wms_plan_tasks_pvt.g_to_task_quantity
        , p_from_creation_date         => wms_plan_tasks_pvt.g_from_creation_date
        , p_to_creation_date           => wms_plan_tasks_pvt.g_to_creation_date
        , p_is_pending                 => l_is_pending
        , p_is_loaded                  => l_is_loaded
        , p_is_completed               => FALSE
        );

   /* Now add where clauses specific to planned_tasks or independent_tasks*/
  if (wms_plan_tasks_pvt.g_is_pending_task = TRUE
      and wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending = TRUE) OR
      (wms_plan_tasks_pvt.g_is_loaded_task = TRUE
      and wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded = TRUE)
   then
      IF l_debug = 1 THEN
        debug('both independent and planned_tasks are queried ','get_tasks');
      END IF;
   null;
   elsif (wms_plan_tasks_pvt.g_is_pending_task = TRUE
      and not wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending = TRUE) OR
      (wms_plan_tasks_pvt.g_is_loaded_task = TRUE
      and NOT wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded = TRUE)
   then
      IF l_debug = 1 THEN
        debug('only independent tasks are queried ','get_tasks');
      END IF;
   l_tasks_where_str := l_tasks_where_str || ' and mmtt.operation_plan_id is null';

   elsif (not wms_plan_tasks_pvt.g_is_pending_task = TRUE
          and wms_plan_tasks_pvt.g_planned_tasks_rec.is_pending = TRUE) OR
          (NOT wms_plan_tasks_pvt.g_is_loaded_task = TRUE
           and wms_plan_tasks_pvt.g_planned_tasks_rec.is_loaded = TRUE)
   then
   l_tasks_where_str := l_tasks_where_str || ' and mmtt.operation_plan_id is not null';
   --l_tasks_where_str := l_tasks_where_str || ' and wooi.complete_time is not null';
   IF l_debug = 1 THEN
     debug('only planned tasks are queried ','get_tasks');
   END IF;
   end if;

   /* If inbound specific query is made, get the inbound specific select, from
      and where clauses, append them to the final query for non-completed tasks.
    */
   IF wms_plan_tasks_pvt.g_inbound_specific_query  OR
      wms_plan_tasks_pvt.g_include_inbound OR
      wms_plan_tasks_pvt.g_include_crossdock THEN
      IF l_debug = 1 THEN
        debug('inbound specific query is made. calling get_inbound_specific_query ','get_tasks');
      END IF;
      get_inbound_specific_query(x_inbound_select_str => l_inbound_select_str
                                ,x_inbound_from_str   => l_inbound_from_str
                                ,x_inbound_where_str  => l_inbound_where_str
                                ,p_is_completed_rec   => 0);

      IF wms_plan_tasks_pvt.g_include_crossdock THEN
        IF l_debug = 1 THEN
	  debug('Crossdock query is made. calling get_inbound_specific_query ','get_tasks');
	END IF;
         /* Bug 5259318 */
	 /*IF wms_plan_tasks_pvt.g_outbound_specific_query THEN*/
            get_outbound_specific_query(x_outbound_from_str   => l_outbound_from_str
                                       ,x_outbound_where_str  => l_outbound_where_str
                                       );
            l_outbound_where_str := l_outbound_where_str || ' AND mtrl.BACKORDER_DELIVERY_DETAIL_ID =  wdd.delivery_detail_id ';
         /*ELSE
            l_outbound_from_str  := NULL;
            l_outbound_where_str := ' AND mtrl.BACKORDER_DELIVERY_DETAIL_ID IS NOT NULL ';
         END IF;*/
	 /* End of Bug 5259318 */
      ELSE
        l_inbound_where_str := l_inbound_where_str ||  ' AND mtrl.BACKORDER_DELIVERY_DETAIL_ID IS NULL '; -- Bug 5472012
      END IF;

      IF p_summary_mode = 0 THEN
	      l_tasks_select_str := l_tasks_select_str || l_inbound_select_str; -- only for detailed select include the inbound specific select
      END IF;
      l_tasks_from_str := l_tasks_from_str || l_inbound_from_str || l_outbound_from_str;
      l_tasks_where_str := l_tasks_where_str || l_inbound_where_str || l_outbound_where_str;
   END IF;
  /* If plan specific query is made, get the plan specific select, from and
     where clauses, append them to the final query for non-completed tasks.
   */
   if wms_plan_tasks_pvt.g_op_plan_id is not null THEN
      l_tasks_where_str := l_tasks_where_str ||
         ' and mmtt.operation_plan_id = :op_plan_id ';
   END IF;

  IF p_summary_mode = 1 THEN
	l_tasks_where_str := l_tasks_where_str || ' GROUP BY mmtt.wms_task_type ';
  END IF;

  l_tasks_str := l_tasks_select_str || l_tasks_from_str || l_tasks_where_str;
  IF l_debug = 1 THEN
    debug('l_tasks_str: ' || l_tasks_str,'get_tasks');
  END IF;
END IF; --if l_is_pending OR l_is_loaded

/* Now fetch the completed tasks - We have two different procedures for
 * fetching the completed task records - one for planned_tasks and the other
 * for independent tasks
 */

/* Fetch the planned_task completed records - either if the user has chosen
 * the task status 'completed' on the tasks tab + user also checked the
 * planned_task checkbox in inbound plans tab (OR) user has chosen to view the
 * 'completed' plans and/or 'In Progress' plans
 */

 /* Bug 3540981 When the user performs manual drop into a receiving sub/loc,
  * the task should be shown as an independent task. This record is archived
  * only in WDTH, but not in MMT. Hence we need to fetch records from WDTH
  * always even when the user queries for independent tasks also. i.e., a
  * 'Union All' with string returned from get_completed_records is present
  * always. But based on the query combination of Planned and Independent tasks
  * the where clause would be modified
  */

-- #1 Fetch records from WDTH first
IF l_is_completed THEN
   get_completed_records(l_completed_records_select_str,
                         l_completed_records_from_str,
                         l_completed_records_where_str);
   /* If inbound specific query is made,
    * #1 Call the function get_inbound_specific_query_str to fetch the tasks
    *   specific and inbound specific  additional query.
    * #2 Append the string returned from this function to l_tasks_query_str.
    */

   IF wms_plan_tasks_pvt.g_inbound_specific_query = TRUE  OR
      wms_plan_tasks_pvt.g_include_inbound  OR
      wms_plan_tasks_pvt.g_include_crossdock THEN
         IF l_debug = 1 THEN
           debug('inbound specific query is made','get_tasks');
	 END IF;
          get_inbound_specific_query(x_inbound_select_str => l_inbound_select_str
                                   ,x_inbound_from_str   => l_inbound_from_str
                                   ,x_inbound_where_str  => l_inbound_where_str
                                   ,p_is_completed_rec   => 1);
          l_inbound_where_str  := l_inbound_where_str
                 || ' AND wdth.source_document_id = rt.transaction_id (+) ';

          IF wms_plan_tasks_pvt.g_include_crossdock THEN
	     IF l_debug = 1 THEN
               debug('Crossdock query is made','get_tasks');
	     END IF;
                /* Bug 5259318 */
		/*IF wms_plan_tasks_pvt.g_outbound_specific_query THEN*/
                   get_outbound_specific_query(x_outbound_from_str   => l_outbound_from_str
                                              ,x_outbound_where_str  => l_outbound_where_str
                                              );
                /*ELSE
                  l_outbound_from_str  := NULL;
                  l_outbound_where_str := ' AND mtrl.BACKORDER_DELIVERY_DETAIL_ID IS NOT NULL ';
                END IF;
          ELSE
                --l_inbound_where_str  := l_inbound_where_str || ' AND mtrl.BACKORDER_DELIVERY_DETAIL_ID IS NULL ';
	       null; /* Bug 5223606 */
         END IF; --Crossdock query
         /* End of Bug 5259318 */

         l_completed_records_select_str := l_completed_records_select_str
                                           || l_inbound_select_str;
         l_completed_records_from_str := l_completed_records_from_str
                                           || l_inbound_from_str || l_outbound_from_str;
         l_completed_records_where_str := l_completed_records_where_str
                                           || l_inbound_where_str|| l_outbound_where_str;

         /* If plan specific query is made, get the plan specific select, from and
          * where clauses, append them to the final query for non-completed tasks.
          */
         if wms_plan_tasks_pvt.g_op_plan_id is not null THEN
            l_completed_records_where_str := l_completed_records_where_str ||
               ' and wdth.operation_plan_id = :op_plan_id ';
         END IF;


    end if; --inbound specific query

   /* Filter on operation_plan_id only if either planned_task or independent
    * tasks are queried, but not both together. In the latter case, we dont
    * filter on operation_plan_id
    */
   IF wms_plan_tasks_pvt.g_query_independent_tasks AND
      wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed = FALSE THEN
      l_completed_records_where_str := l_completed_records_where_str ||
             ' and wdth.operation_plan_id is null ';
   ELSIF wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed = TRUE AND
         wms_plan_tasks_pvt.g_query_independent_tasks = FALSE THEN
         l_completed_records_where_str := l_completed_records_where_str
          || 'and wdth.operation_plan_id is not null ';
   END IF;

  /* Filter based on the task_type */

debug('Filter based on the task_type');

   l_completed_records_where_str := l_completed_records_where_str ||
             ' and wdth.task_type IN (2,8) ' ||
             ' and ('||
             ' (wdth.transaction_source_type_id = 1 ' ||
             ' and wdth.transaction_action_id = 27) OR '||
             ' (wdth.transaction_source_type_id = 12 ' ||
             ' and wdth.transaction_action_id = 27) OR '||
             ' (wdth.transaction_source_type_id = 7 ' ||
             ' and wdth.transaction_action_id = 12) OR '||
             ' (wdth.transaction_source_type_id = 13 ' ||
             ' and wdth.transaction_action_id = 12) OR '||
             ' (wdth.transaction_source_type_id = 4 ' ||  --Bug #3789492
             ' and wdth.transaction_action_id = 2) OR '||    --Bug #3789492
	     ' (wdth.transaction_source_type_id = 4 ' ||  --Bug #5231114
             ' and wdth.transaction_action_id = 27) '||    --Bug #5231114
	     ' OR (wdth.transaction_source_type_id = 5  ' || -- Code for Bug#8467334
             ' and wdth.transaction_action_id =  31) ' ||  --  Code for Bug#8467334
             ') ';

	---fix for bug 6826562
 	     IF wms_plan_tasks_pvt.g_subinventory_code IS NOT NULL THEN
 	       l_completed_records_where_str := l_completed_records_where_str
 	                || 'AND wdth.source_subinventory_code = :sub_code ';
 	     END IF;

 	     IF wms_plan_tasks_pvt.g_locator_id IS NOT NULL THEN
 	       l_completed_records_where_str  := l_completed_records_where_str
 	                      || 'AND wdth.source_locator_id = :loc_id ';
 	     END IF;

 	     IF wms_plan_tasks_pvt.g_to_subinventory_code IS NOT NULL THEN
 	        l_completed_records_where_str  := l_completed_records_where_str
 	                || 'AND wdth.dest_subinventory_code = :to_sub_code ';
 	     END IF;

 	     IF wms_plan_tasks_pvt.g_to_locator_id IS NOT NULL THEN
 	        l_completed_records_where_str  := l_tasks_where_str
 	                     || 'AND wdth.dest_locator_id = :to_loc_id ';
 	     END IF;
 	 ---fix for bug 6826562

   IF p_summary_mode = 0 THEN
	l_completed_records_str := l_completed_records_select_str ||
		              l_completed_records_from_str ||
		              l_completed_records_where_str;
   ELSE
	l_completed_records_str := ' SELECT wdth.task_type,count(*) ' || l_completed_records_from_str ||
		              l_completed_records_where_str || ' GROUP BY wdth.task_type ';
   END IF;

   IF l_debug = 1 THEN
     debug('completed_records_str ' || l_completed_records_str);
   END IF;
--fetching the completed independent tasks
if wms_plan_tasks_pvt.g_is_completed_task
    AND wms_plan_tasks_pvt.g_query_independent_tasks then

   /*Bug 3627575:Setting the variable to true for Inbound queries*/
        wms_plan_tasks_pvt.g_from_inbound :=TRUE;

    IF l_debug = 1 THEN
      debug('fetching the completed independent tasks ','get_tasks');
    END IF;
   g_inbound_cycle := TRUE;
   IF p_summary_mode = 1 THEN
	l_completed_tasks_select_str := ' SELECT wdth.task_type, count(*) ';
   ELSE
	   l_completed_tasks_select_str := wms_waveplan_tasks_pvt.get_generic_select(
		  p_is_pending                 => FALSE
	        , p_is_loaded                  => FALSE
		, p_is_completed               => l_is_completed
        );
   END IF;

     g_inbound_cycle := FALSE;

    l_completed_tasks_from_str          :=
        wms_waveplan_tasks_pvt.get_generic_from(
          p_is_loaded                  => FALSE
        , p_is_completed               => l_is_completed
        , p_item_category_id           => wms_plan_tasks_pvt.g_item_category_id
        , p_category_set_id            => wms_plan_tasks_pvt.g_category_set_id
        );

    l_completed_tasks_where_str         :=
        wms_waveplan_tasks_pvt.get_generic_where(
          p_add                        => wms_plan_tasks_pvt.g_is_add
        , p_organization_id            => wms_plan_tasks_pvt.g_organization_id
        , p_subinventory_code          => wms_plan_tasks_pvt.g_subinventory_code
        , p_locator_id                 => wms_plan_tasks_pvt.g_locator_id
        , p_to_subinventory_code       => wms_plan_tasks_pvt.g_to_subinventory_code
        , p_to_locator_id              => wms_plan_tasks_pvt.g_to_locator_id
        , p_inventory_item_id          => wms_plan_tasks_pvt.g_inventory_item_id
        , p_category_set_id            => wms_plan_tasks_pvt.g_category_set_id
        , p_item_category_id           => wms_plan_tasks_pvt.g_item_category_id
        , p_person_id                  => wms_plan_tasks_pvt.g_person_id
        , p_person_resource_id         => wms_plan_tasks_pvt.g_person_resource_id
        , p_equipment_type_id          => wms_plan_tasks_pvt.g_equipment_type_id
        , p_machine_resource_id        => wms_plan_tasks_pvt.g_machine_resource_id
        , p_machine_instance           => wms_plan_tasks_pvt.g_machine_instance
        , p_from_task_quantity         => wms_plan_tasks_pvt.g_from_task_quantity
        , p_to_task_quantity           => wms_plan_tasks_pvt.g_to_task_quantity
        , p_from_creation_date         => wms_plan_tasks_pvt.g_from_creation_date
        , p_to_creation_date           => wms_plan_tasks_pvt.g_to_creation_date
        , p_is_pending                 => FALSE
        , p_is_loaded                  => FALSE
        , p_is_completed               => l_is_completed
        );

    l_tasks_where_str := l_tasks_where_str || ' and wdth.operation_plan_id is null';

   IF wms_plan_tasks_pvt.g_inbound_specific_query  OR
       wms_plan_tasks_pvt.g_include_inbound  OR
      wms_plan_tasks_pvt.g_include_crossdock THEN

      IF l_debug = 1 THEN
        debug('inbound specific query is made. calling get_inbound_specific_query ','get_tasks');
      END IF;
      get_inbound_specific_query(x_inbound_select_str => l_inbound_select_str
                             ,x_inbound_from_str   => l_inbound_from_str
                             ,x_inbound_where_str  => l_inbound_where_str
                             ,p_is_completed_rec   => 1);
      /*Bug 3627575:Made the join with rcv_transactions an outer join*/
      l_inbound_where_str  := l_inbound_where_str
                                || ' AND mmt.rcv_transaction_id = rt.transaction_id(+) ';
      /*Bug 4000897:Added the where clause to fetch only non-planned tasks*/
      l_inbound_where_str  := l_inbound_where_str
                                || ' AND wdth.is_parent IS NULL ';
      /*Bug 3627575:added filter for task type for Inbound tasks*/
      l_inbound_where_str := l_inbound_where_str
                                || ' AND wdth.task_type in (2,8) ';
      l_inbound_where_str := l_inbound_where_str||' and ('||
               ' (wdth.transaction_source_type_id = 1 ' ||
               ' and wdth.transaction_action_id = 27) OR '||
               ' (wdth.transaction_source_type_id = 12 ' ||
               ' and wdth.transaction_action_id = 27) OR '||
               ' (wdth.transaction_source_type_id = 7 ' ||
               ' and wdth.transaction_action_id = 12) OR '||
               ' (wdth.transaction_source_type_id = 13 ' ||
               ' and wdth.transaction_action_id = 12) OR '||
               ' (wdth.transaction_source_type_id = 4 ' ||  --Bug #3789492
               ' and wdth.transaction_action_id = 2) OR'||    --Bug #3789492
               ' (wdth.transaction_source_type_id = 4 ' ||  --Bug #5231114
               ' and wdth.transaction_action_id = 27) '||   --Bug #5231114
               ') ';

	---fix for bug 6826562

 	     IF wms_plan_tasks_pvt.g_subinventory_code IS NOT NULL THEN
 	       l_completed_tasks_where_str := l_completed_tasks_where_str
 	                || 'AND wdth.source_subinventory_code = :sub_code ';
 	     END IF;

 	     IF wms_plan_tasks_pvt.g_locator_id IS NOT NULL THEN
 	       l_completed_tasks_where_str  := l_completed_tasks_where_str
 	                     || 'AND wdth.source_locator_id = :loc_id ';
 	     END IF;

 	     IF wms_plan_tasks_pvt.g_to_subinventory_code IS NOT NULL THEN
 	        l_completed_tasks_where_str  := l_completed_tasks_where_str
 	                || 'AND wdth.dest_subinventory_code = :to_sub_code ';
 	     END IF;

 	     IF wms_plan_tasks_pvt.g_to_locator_id IS NOT NULL THEN
 	        l_completed_tasks_where_str  := l_completed_tasks_where_str
 	                     || 'AND wdth.dest_locator_id = :to_loc_id ';
 	     END IF;

 	 ---fix for bug 6826562

      IF wms_plan_tasks_pvt.g_include_crossdock THEN
        IF l_debug = 1 THEN
          debug('Crossdock query is made. calling get_inbound_specific_query ','get_tasks');
	END IF;
         l_completed_tasks_from_str := l_completed_tasks_from_str || ', mtl_txn_request_lines mtrl';
         l_completed_tasks_where_str := l_completed_tasks_where_str || ' AND wdth.organization_id = mtrl.organization_id ';
         l_completed_tasks_where_str := l_completed_tasks_where_str || ' AND wdth.inventory_item_id = mtrl.inventory_item_id ';
         l_completed_tasks_where_str := l_completed_tasks_where_str || ' AND wdth.move_order_line_id = mtrl.line_id ';
         /* Bug 5259318 */
	 /*IF wms_plan_tasks_pvt.g_outbound_specific_query THEN*/
            -- for crossdock tasks with outbound criteria specified
            l_completed_tasks_where_str := l_completed_tasks_where_str || ' AND mtrl.backorder_delivery_detail_id = wdd.delivery_detail_id ';
            get_outbound_specific_query(x_outbound_from_str   => l_outbound_from_str
                                       ,x_outbound_where_str  => l_outbound_where_str
                                       );
         /*ELSE
            -- for crossdock tasks without outbound criteria specified
            debug('!@#$%^&*(): not calling get_outbound specific query' ,'get_tasks');
            l_completed_tasks_where_str := l_completed_tasks_where_str || ' AND mtrl.backorder_delivery_detail_id is not null ';
         END IF;*/
	/* End of Bug 5259318 */
      ELSE
         -- for inbound tasks
         /*l_completed_tasks_where_str := l_completed_tasks_where_str || ' AND mtrl.backorder_delivery_detail_id is null ';*/
	 null; /*  Bug 5223606 */
      END IF;

      IF p_summary_mode = 0 THEN
	      l_completed_tasks_select_str := l_completed_tasks_select_str || l_inbound_select_str;
      END IF;
      l_completed_tasks_from_str := l_completed_tasks_from_str || l_inbound_from_str || l_outbound_from_str;
      l_completed_tasks_where_str := l_completed_tasks_where_str || l_inbound_where_str || l_outbound_where_str;

      IF p_summary_mode = 1 THEN
		l_completed_tasks_where_str := l_completed_tasks_where_str || ' GROUP BY wdth.task_type ' ;
      END IF;

   END IF;

   l_completed_tasks_str := l_completed_tasks_select_str || l_completed_tasks_from_str ||
                         l_completed_tasks_where_str;
   IF l_debug = 1 THEN
     debug('l_completed_tasks_str: ' || l_completed_tasks_str,'get_tasks');
   END IF;
 end if;

END IF; --if l_is_completed
/* Now we have 1 to 3 strings :
l_tasks_str             - string for the non-completed tasks(independent+planned)
l_completed_tasks_str   - String for the completed independent_tasks
l_completed_records_str - string for the completed planned_tasks
*/
IF l_tasks_str IS NOT NULL THEN
   IF l_debug = 1 THEN
     debug('l_tasks_str is not null ','get_tasks');
   END IF;
   l_tasks_query_str := l_tasks_str;
   IF  l_completed_tasks_str IS NOT NULL THEN
      l_tasks_query_str := l_tasks_query_str || ' UNION ALL ' || l_completed_tasks_str;
      IF l_debug = 1 THEN
        debug('l_tasks_str is not null..l_completed_tasks_str is not null ','get_tasks');
        debug('l_tasks_query_str: ' || l_tasks_query_str,'get_tasks');
      END IF;
   END IF;
   IF l_completed_records_str IS NOT NULL THEN
     IF l_debug = 1 THEN
       debug('l_completed_records_str is not null ','get_tasks');
     END IF;
      l_tasks_query_str := l_tasks_query_str || ' UNION ALL ' ||
                           l_completed_records_str;
      IF l_debug = 1 THEN
        debug('l_tasks_str is not null..l_completed_records_str is not null ','get_tasks');
        debug('l_tasks_query_str: ' || l_tasks_query_str,'get_tasks');
      END IF;
   END IF;

ELSIF l_completed_tasks_str IS NOT NULL THEN
   IF l_debug = 1 THEN
     debug('l_completed_tasks_str is not null ','get_tasks');
   END IF;
   l_tasks_query_str := l_completed_tasks_str;
   IF l_completed_records_str IS NOT NULL THEN
     IF l_debug = 1 THEN
       debug('l_completed_records_str is not null ','get_tasks');
     END IF;
      l_tasks_query_str := l_tasks_query_str || ' UNION ALL ' ||
                           l_completed_records_str;
      IF l_debug = 1 THEN
        debug('l_completed_tasks_str is not null and l_completed_records_str is not null','get_tasks');
      END IF;
   END IF;
ELSIF l_completed_records_str IS NOT NULL THEN
      l_tasks_query_str := l_completed_records_str;
END IF;
x_tasks_query_str := l_tasks_query_str;
IF l_debug = 1 THEN
  debug('returning l_tasks_query_str: ' || l_tasks_query_str,'get_tasks');
END IF;
END get_tasks;

PROCEDURE get_col_list(x_col_list_str OUT NOCOPY VARCHAR2) IS
l_col_list_str wms_plan_tasks_pvt.short_sql;
BEGIN
  l_col_list_str  := 'expansion_code'
                     || ', plans_tasks'
                     || ', transaction_temp_id '
                     || ', parent_line_id '
                     || ', inventory_item_id '
                     || ', item '
                     || ', item_description '
                     || ', unit_weight '
                     || ', weight_uom_code '
                     || ', unit_volume '
                     || ', volume_uom_code '
                     || ', organization_id '
                     || ', revision '
                     || ', subinventory '
                     || ', locator_id '
                     || ', locator '
                     || ', status_id '
                     || ', status_id_original '
                     || ', status '
                     || ', transaction_type_id '
                     || ', transaction_action_id '
                     || ', transaction_source_type_id ';

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
    l_col_list_str := l_col_list_str || ', transaction_source_type ';
    END IF;

    l_col_list_str := l_col_list_str
                    || ', transaction_source_id '
                    || ', transaction_source_line_id '
                    || ', to_organization_id ';

    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
    l_col_list_str := l_col_list_str || ', to_organization_code ';
    END IF;

    l_col_list_str := l_col_list_str
                    || ', to_subinventory '
                    || ', to_locator_id ';

    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
     l_col_list_str := l_col_list_str || ', to_locator ';
    END IF;

    l_col_list_str := l_col_list_str
                    || ', transaction_uom '
                    || ', transaction_quantity '
                    || ', user_task_type_id ';
    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
      l_col_list_str  := l_col_list_str || ', user_task_type ';
    END IF;
    l_col_list_str := l_col_list_str
                    || ', move_order_line_id '
                    || ', pick_slip_number '
                    || ', cartonization_id ';

    IF wms_plan_tasks_pvt.g_cartonization_lpn_visible = 'T' THEN
    l_col_list_str := l_col_list_str || ', cartonization_lpn ';
    END IF;

    l_col_list_str := l_col_list_str || ', allocated_lpn_id ';

    IF wms_plan_tasks_pvt.g_allocated_lpn_visible = 'T' THEN
      l_col_list_str := l_col_list_str || ', allocated_lpn ';
    END IF;

    l_col_list_str := l_col_list_str || ', container_item_id ';

    IF wms_plan_tasks_pvt.g_container_item_visible = 'T' THEN
       l_col_list_str := l_col_list_str || ', container_item ';
    END IF;

    l_col_list_str := l_col_list_str || ', from_lpn_id ';

    IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
       l_col_list_str := l_col_list_str || ', from_lpn ';
    END IF;

    l_col_list_str := l_col_list_str || ', content_lpn_id ';

    IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
      l_col_list_str := l_col_list_str || ', content_lpn ';
    END IF;

    l_col_list_str := l_col_list_str || ', to_lpn_id ';

    IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
      l_col_list_str := l_col_list_str || ', to_lpn ';
    END IF;

    l_col_list_str := l_col_list_str
                    || ', mmtt_last_update_date '
                    || ', mmtt_last_updated_by '
                    || ', priority '
                    || ', priority_original '
                    || ', task_type_id '
                    || ', task_type '
                    || ', creation_time '
                    || ', operation_plan_id ';
    IF wms_plan_tasks_pvt.g_operation_plan_visible = 'T' THEN
       l_col_list_str := l_col_list_str
                    || ', operation_plan ';
    END IF;
    IF wms_plan_tasks_pvt.g_operation_sequence_visible = 'T' THEN
        l_col_list_str := l_col_list_str || ', operation_sequence ';
    END IF;
    l_col_list_str := l_col_list_str
                    || ', op_plan_instance_id '
                    --|| ', operation_sequence '
                    || ', task_id '
                    || ', person_id '
                    || ', person_id_original '
                    || ', person '
                    || ', effective_start_date '
                    || ', effective_end_date '
                    || ', person_resource_id ';
    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
       l_col_list_str := l_col_list_str
                    || ', person_resource_code ';
    END IF;
    l_col_list_str := l_col_list_str
                    || ', machine_resource_id ';
    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
       l_col_list_str := l_col_list_str
                    || ', machine_resource_code ';
    END IF;
       l_col_list_str := l_col_list_str
                    || ', equipment_instance '
                    || ', dispatched_time '
                    || ', loaded_time '
                    || ', drop_off_time '
                    || ', wdt_last_update_date '
                    || ', wdt_last_updated_by '
                    || ', is_modified '
                    || ', secondary_transaction_uom '
                    || ', secondary_transaction_quantity ';
    IF wms_plan_tasks_pvt.g_include_inbound OR wms_plan_tasks_pvt.g_include_crossdock THEN
      l_col_list_str        := l_col_list_str
                             || ', reference_id '
                             || ', reference ';
    END IF;

    IF wms_plan_tasks_pvt.g_inbound_specific_query THEN
      l_col_list_str  := l_col_list_str
                       || ', source_header '
                       || ', line_number ';
    END IF;

    /* Bug 5259318 */
    IF wms_plan_tasks_pvt.g_include_crossdock THEN
      l_col_list_str        := l_col_list_str || ', delivery ';
    END IF;
    /* End of Bug 5259318 */

x_col_list_str := l_col_list_str;
END get_col_list;

/* This procedure fetched the 'Planned_task' records from WDTH */
procedure get_completed_records(x_wdth_select_str OUT NOCOPY varchar2,
                                x_wdth_from_str OUT NOCOPY varchar2,
                                x_wdth_where_str OUT NOCOPY varchar2) is
l_wdth_select_str wms_plan_tasks_pvt.short_sql:= NULL;
l_wdth_from_str wms_plan_tasks_pvt.short_sql:= NULL;
l_wdth_where_str wms_plan_tasks_pvt.short_sql:= NULL;
l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

begin
/**** First build the Select string ****/
  IF l_debug = 1 THEN
    debug('in get_completed_records ','get_completed_records');
  END IF;
 l_wdth_select_str  := 'SELECT '
         || 'decode(wdth.is_parent,''N'',null,''+''), '
         || 'decode(wdth.is_parent,''N'', decode(wdth.operation_plan_id,null,'
         || 'decode(wdth.parent_transaction_id,null,'''
         || wms_plan_tasks_pvt.g_plan_task_types(1) || ''','''
         || wms_plan_tasks_pvt.g_plan_task_types(5)
         || '''),'''|| wms_plan_tasks_pvt.g_plan_task_types(2)
         || '''),decode(wdth.transaction_action_id,28,'''||wms_plan_tasks_pvt.g_plan_task_types(4)
         || ''',''' || wms_plan_tasks_pvt.g_plan_task_types(3) || ''')), ' /*plan_task */
         || 'wdth.transaction_id, ' /* transaction_temp_id */
         || 'wdth.parent_transaction_id, ' /*parent_line_id*/
         || 'wdth.inventory_item_id, ' /*inventory_item_id*/
         || 'msiv.concatenated_segments, '/*item*/
         || 'msiv.description, ' /*item description*/
         || 'msiv.unit_weight, ' /*unit_weight*/
         || 'msiv.weight_uom_code, ' /*weight_uom_code*/
         || 'msiv.unit_volume, ' /*unit_volume*/
         || 'msiv.volume_uom_code, ' /*volume_uom_code*/
         || 'wdth.organization_id, ' /*organization_id*/
         || 'wdth.revision, ' /*revision*/
         || 'wdth.source_subinventory_code, ' /*subinventory*/
         || 'wdth.source_locator_id, ' /*locator_id*/
         || 'decode(milv.segment19, null, milv.concatenated_segments, null), '/*locator*/
         || 'wdth.status, '  /*status_id*/
         || 'wdth.status, ' /*status_id_original*/
         || 'decode(wdth.status,'
         || '6, '''
         || wms_plan_tasks_pvt.g_plan_status_codes(3)
         || ''', 11, '''
         || wms_plan_tasks_pvt.g_plan_status_codes(4)
         || ''', 12, '''
         || wms_plan_tasks_pvt.g_plan_status_codes(5)/*status*/
         || '''), '
         || 'wdth.transaction_type_id, '/*transaction_type_id*/
         || 'wdth.transaction_action_id, '/*transaction_action_id*/
         || 'wdth.transaction_source_type_id, '; --transaction_source_type_id

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
     l_wdth_select_str  := l_wdth_select_str
            || 'mtst.transaction_source_type_name, '; --transaction_source_type
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                     || 'to_number(null), '  /*transaction_source_id*/
                     || 'to_number(null), ' /*transaction_source_line_id*/
                     || 'wdth.transfer_organization_id, ';/* to_organization_id*/

    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
       l_wdth_select_str  := l_wdth_select_str
                     || 'mp1.organization_code, '; /* to_organization_code */
    END IF;
    l_wdth_select_str  := l_wdth_select_str
                     || 'wdth.dest_subinventory_code, ' /*to_subinventory*/
                     || 'wdth.dest_locator_id,  '; /*to_locator_id*/

    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str
        || 'decode(milv1.segment19, null, milv1.concatenated_segments, null), ';
        /* to_locator */
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                     || 'wdth.transaction_uom_code, '  /* transaction_uom */
                     || 'wdth.transaction_quantity, ' /*transaction_quantity */
                     || 'wdth.user_task_type, '; /*user_task_type_id*/

    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN

      l_wdth_select_str  := l_wdth_select_str
                     || 'bso.operation_code, '; --user_task_type
    END IF;



    l_wdth_select_str  := l_wdth_select_str
                     || 'to_number(null), ' /*move_order_line_id*/
                     || 'to_number(null), ' /*pick_slip_number*/
                     || 'to_number(null), '; /*cartonization_id*/
        IF g_cartonization_lpn_visible = 'T' THEN
         l_wdth_select_str := l_wdth_select_str || 'null, ';
         --cartonization_lpn
        END IF;
         l_wdth_select_str := l_wdth_select_str
             || 'to_number(null), '; /*allocated_lpn_id*/


    IF wms_plan_tasks_pvt.g_allocated_lpn_visible = 'T' THEN
           l_wdth_select_str  := l_wdth_select_str || 'null, '; --allocated_lpn
    END IF;
    l_wdth_select_str  := l_wdth_select_str
                     || 'to_number(null), '; /*container_item_id*/

    IF g_container_item_visible = 'T' THEN
       l_wdth_select_str := l_wdth_select_str || 'null, '; /*container item */
    end if;

    l_wdth_select_str := l_wdth_select_str || 'wdth.lpn_id, ' ; /*from_lpn_id*/

    IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
       l_wdth_select_str := l_wdth_select_str
	 || 'wlpn5.license_plate_number, ' ; /*from_lpn*/
    END IF;

    l_wdth_select_str := l_wdth_select_str || 'wdth.content_lpn_id, '; /*content_lpn_id*/

    IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
       l_wdth_select_str  := l_wdth_select_str
	 || 'wlpn3.license_plate_number, '; --content_lpn
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                     || 'wdth.transfer_lpn_id, '; --to_lpn_id

   IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
      l_wdth_select_str  :=  l_wdth_select_str
                     || 'wlpn4.license_plate_number, '; --to_lpn
   END IF;
   l_wdth_select_str  := l_wdth_select_str
                     || 'to_date(null), ' /*mmt_last_update_date*/
                     || 'to_number(null), ' /*mmt_last_updated_by*/
                     || 'wdth.priority, '/*priority*/
                     || 'wdth.priority, ' /*priority_original*/
                     || 'wdth.task_type, ' /*task_type_id*/
                     || 'decode(wdth.task_type,'
                     || '1, '''
                     || wms_plan_tasks_pvt.g_task_types(1)
                     || ''', 2, '''
                     || wms_plan_tasks_pvt.g_task_types(2)
                     || ''', 3, '''
                     || wms_plan_tasks_pvt.g_task_types(3)
                     || ''', 4, '''
                     || wms_plan_tasks_pvt.g_task_types(4)
                     || ''', 5, '''
                     || wms_plan_tasks_pvt.g_task_types(5)
                     || ''', 6, '''
                     || wms_plan_tasks_pvt.g_task_types(6)
                     || ''', 7, '''
                     || wms_plan_tasks_pvt.g_task_types(7)
                     || ''', 8, '''
                     || wms_plan_tasks_pvt.g_task_types(8)
                     || '''), '/*task*/
                     || 'to_date(null), ' /*creation_time */
                     || 'wdth.operation_plan_id, ';/*operation_plan_id*/
   IF wms_plan_tasks_pvt.g_operation_plan_visible = 'T' THEN
   l_wdth_select_str := l_wdth_select_str
                     || 'wop.operation_plan_name, ';/*operation_plan*/
   END IF;
   IF wms_plan_tasks_pvt.g_operation_sequence_visible = 'T' THEN
        l_wdth_select_str := l_wdth_select_str || ' to_number(null), '; --operation_sequence
   END IF;
   l_wdth_select_str := l_wdth_select_str
                     || 'to_number(wdth.op_plan_instance_id), '/*operation_instance_id*/
                     --|| 'to_number(null), '/*operation_sequence*/
                     || 'wdth.task_id, '/*task_id*/
                     || 'wdth.person_id, '/*person_id*/
                     || 'wdth.person_id, ';/*person_id_original*/

    IF wms_plan_tasks_pvt.g_person_visible = 'T' THEN
       l_wdth_select_str  := l_wdth_select_str || 'pap.full_name, '; --person_id
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                      || 'wdth.effective_start_date, '/*effective_start_date*/
                      || 'wdth.effective_end_date, '/*effective_end_date*/
                      || 'wdth.person_resource_id, '; /*person_resource_id*/

    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
       l_wdth_select_str  := l_wdth_select_str
                      || 'br1.resource_code, '; --person_resource_code
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                      || 'wdth.machine_resource_id, '; --machine_resource_id

    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
       l_wdth_select_str  := l_wdth_select_str
                      || 'br2.resource_code, '; --machine_resource_code
    END IF;
    l_wdth_select_str  := l_wdth_select_str
                      || 'wdth.equipment_instance, '/*equipment_instance*/
                      || 'wdth.dispatched_time, '/*dispatched_time*/
                      || 'wdth.loaded_time, '/*loaded_time*/
                      || 'wdth.drop_off_time, '/*drop_off_time*/
                      || 'to_date(null), '/*wdt_last_update_date*/
                      || 'to_number(null), '/*wdt_last_updated_by*/
                      || '''N'', '/*is modified*/
                      || 'wdth.SECONDARY_TRANSACTION_UOM_CODE, '
                      || 'wdth.SECONDARY_TRANSACTION_QUANTITY';


/**** Now build the From string ****/
    l_wdth_from_str  := ' FROM wms_dispatched_tasks_history wdth'
                     || ', mtl_txn_request_lines mtrl '
                     || ', mtl_system_items_kfv msiv '
                     || ', mtl_item_locations_kfv milv ';

    IF wms_plan_tasks_pvt.g_include_crossdock THEN /* CKR */
      l_wdth_from_str  := l_wdth_from_str || ', mtl_txn_request_headers mtrh ';
    END IF;

    IF wms_plan_tasks_pvt.g_item_category_id IS NOT NULL
       OR wms_plan_tasks_pvt.g_category_set_id IS NOT NULL THEN
      l_wdth_from_str  := l_wdth_from_str
                     || ', mtl_item_categories mic ';
    END IF;

    IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
       l_wdth_from_str := l_wdth_from_str
	              || ', wms_license_plate_numbers wlpn5 ';
    END IF;

    IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                     || ', wms_license_plate_numbers wlpn3 ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                    || ', wms_license_plate_numbers wlpn4 ';
    END IF;

    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                    || ', bom_standard_operations bso ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', mtl_parameters mp1 ';
    END IF;

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                    || ', mtl_txn_source_types mtst ';
    END IF;

    l_wdth_from_str  := l_wdth_from_str || ', wms_op_plans_vl wop ';

    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', bom_resources br1 ';
    END IF;


    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', bom_resources br2 ';
    END IF;

    IF wms_plan_tasks_pvt.g_person_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                          || ', per_all_people_f pap ';
    END IF;
    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', mtl_item_locations_kfv milv1 ';
    END IF;


/**** Now get the Where string ****/
 l_wdth_where_str := 'WHERE 1=1 ';
 l_wdth_where_str  := l_wdth_where_str
       || 'AND wdth.organization_id = msiv.organization_id '
       || 'AND wdth.inventory_item_id = msiv.inventory_item_id '
       || 'AND wdth.organization_id = milv.organization_id(+) '
       || 'AND wdth.source_locator_id = milv.inventory_location_id(+) '
       || 'AND wdth.organization_id = mtrl.organization_id '
       || 'AND wdth.inventory_item_id = mtrl.inventory_item_id ';


    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
       l_wdth_where_str  :=  l_wdth_where_str
         || 'AND wdth.transfer_organization_id = mp1.organization_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
      l_wdth_where_str  := l_wdth_where_str
	    || 'AND wdth.transaction_source_type_id = mtst.transaction_source_type_id (+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
     l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.person_resource_id = br1.resource_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
      l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.machine_resource_id = br2.resource_id(+) ';
    END IF;
    IF wms_plan_tasks_pvt.g_person_visible = 'T' THEN
     l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.person_id = pap.person_id (+)'
           || 'AND wdth.effective_start_date >= pap.effective_start_date (+) '
           || 'AND wdth.effective_end_date <= pap.effective_end_date (+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
       l_wdth_where_str := l_wdth_where_str
	   || 'AND wdth.lpn_id = wlpn5.lpn_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
      l_wdth_where_str  :=  l_wdth_where_str
           || 'AND wdth.content_lpn_id = wlpn3.lpn_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
     l_wdth_where_str  :=  l_wdth_where_str
          || 'AND wdth.transfer_lpn_id = wlpn4.lpn_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
     l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.user_task_type = bso.standard_operation_id(+) '
         || 'AND wdth.organization_id = bso.organization_id(+) ';
    END IF;

   l_wdth_where_str  :=  l_wdth_where_str
         || 'AND wdth.operation_plan_id = wop.operation_plan_id(+) ';
    IF wms_plan_tasks_pvt.g_organization_id IS NOT NULL THEN
      l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.organization_id = :org_id ';
    END IF;

    IF wms_plan_tasks_pvt.g_category_set_id IS NOT NULL THEN
     l_wdth_where_str  := l_wdth_where_str
          || 'AND mic.category_set_id = :category_set_id ';
    END IF;

    IF wms_plan_tasks_pvt.g_item_category_id IS NOT NULL THEN
     l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.inventory_item_id = mic.inventory_item_id (+) '
         || 'AND mic.organization_id(+) = wdth.organization_id '
         || 'AND mic.category_id = :item_category_id ';
    END IF;

    IF wms_plan_tasks_pvt.g_inventory_item_id IS NOT NULL THEN
     l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.inventory_item_id = :item_id ';
    END IF;

    IF wms_plan_tasks_pvt.g_from_task_quantity IS NOT NULL THEN
    l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.transaction_quantity >= :from_task_quantity ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_task_quantity IS NOT NULL THEN
      l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.transaction_quantity <= :to_task_quantity ';
     END IF;

    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
      l_wdth_where_str  := l_wdth_where_str
                           || 'and wdth.dest_locator_id = milv1.inventory_location_id (+)'
                           || 'AND wdth.dest_subinventory_code = milv1.subinventory_code (+)';
    END IF;
    /* Since this procedure is called for planned_tasks records only,
       add a where clause to restrict on operation_plan_id and is_parent
     */
    l_wdth_where_str  := l_wdth_where_str
                         || 'and wdth.is_parent = ''N'''
                         || 'and wdth.move_order_line_id = mtrl.line_id ';
   -- bug5163661
   IF wms_plan_tasks_pvt.g_include_crossdock THEN
      l_wdth_where_str  := l_wdth_where_str
                           /*|| 'and mtrl.backorder_delivery_detail_id IS NOT NULL '; --= wdd.delivery_detail_id ';*/ /* Bug 5259318 */
			   || 'and mtrl.backorder_delivery_detail_id = wdd.delivery_detail_id ';
      l_wdth_where_str  := l_wdth_where_str
                           || 'and mtrh.header_id = mtrl.header_id ';
      /* Bug 5259318 */
   ELSE
      l_wdth_where_str  := l_wdth_where_str
                           || 'and mtrl.backorder_delivery_detail_id is null '; /*Bug 5223606 */
   END IF;

   /* Bug 5507934 */
   IF wms_plan_tasks_pvt.g_from_sales_order_id IS NOT NULL OR wms_plan_tasks_pvt.g_to_sales_order_id IS NOT NULL
   THEN
     l_wdth_where_str := l_wdth_where_str || 'AND wdd.organization_id = wdth.organization_id ';
     l_wdth_where_str := l_wdth_where_str || 'AND wdd.inventory_item_id = wdth.inventory_item_id ';
   END IF;
   /* End of Bug 5507934 */
   --BUG 6342338
    IF wms_plan_tasks_pvt.g_from_creation_date IS NOT NULL THEN
      l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.creation_date >= :from_creation_date  ';
     END IF;

    IF wms_plan_tasks_pvt.g_to_creation_date IS NOT NULL THEN
      l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.creation_date <= :to_creation_date ';
     END IF;
  --End Bug 6342338


    IF l_debug = 1 THEN
      debug('l_wdth_select_str## ' || l_wdth_select_str, 'get_completed_records');
      debug('l_wdth_from_str## ' || l_wdth_from_str, 'get_completed_records');
      debug('l_wdth_where_str## ' || l_wdth_where_str, 'get_completed_records');
    END IF;

    x_wdth_select_str := l_wdth_select_str;
    x_wdth_from_str := l_wdth_from_str;
    x_wdth_where_str := l_wdth_where_str;

   end get_completed_records;

/** Procedure that sets the global variables. This takes in all the fields
on the form as input parameters.
Each of the input parameter is a record representing each of the tabs on
form
**/
PROCEDURE set_globals(
    p_organization_id                          NUMBER DEFAULT NULL
  , p_subinventory_code                        VARCHAR2 DEFAULT NULL
  , p_locator_id                               NUMBER DEFAULT NULL
  , p_to_subinventory_code                     VARCHAR2 DEFAULT NULL
  , p_to_locator_id                            NUMBER DEFAULT NULL
  , p_inventory_item_id                        NUMBER DEFAULT NULL
  , p_category_set_id                          NUMBER DEFAULT NULL
  , p_item_category_id                         NUMBER DEFAULT NULL
  , p_person_id                                NUMBER DEFAULT NULL
  , p_person_resource_id                       NUMBER DEFAULT NULL
  , p_equipment_type_id                        NUMBER DEFAULT NULL
  , p_machine_resource_id                      NUMBER DEFAULT NULL
  , p_machine_instance                         VARCHAR2 DEFAULT NULL
  , p_user_task_type_id                        NUMBER DEFAULT NULL
  , p_from_task_quantity                       NUMBER DEFAULT NULL
  , p_to_task_quantity                         NUMBER DEFAULT NULL
  , p_from_task_priority                       NUMBER DEFAULT NULL
  , p_to_task_priority                         NUMBER DEFAULT NULL
  , p_from_creation_date                       DATE DEFAULT NULL
  , p_to_creation_date                         DATE DEFAULT NULL
  , p_is_unreleased_task                       BOOLEAN DEFAULT FALSE
  , p_is_pending_task                          BOOLEAN DEFAULT FALSE
  , p_is_queued_task                           BOOLEAN DEFAULT FALSE
  , p_is_dispatched_task                       BOOLEAN DEFAULT FALSE
  , p_is_active_task                           BOOLEAN DEFAULT FALSE
  , p_is_loaded_task                           BOOLEAN DEFAULT FALSE
  , p_is_completed_task                        BOOLEAN DEFAULT FALSE
  , p_include_inbound                          BOOLEAN DEFAULT FALSE
  , p_include_outbound                         BOOLEAN DEFAULT FALSE
  , p_include_crossdock                        BOOLEAN DEFAULT FALSE
  , p_include_manufacturing                    BOOLEAN DEFAULT FALSE
  , p_include_warehousing                      BOOLEAN DEFAULT FALSE
  , p_from_po_header_id                        NUMBER DEFAULT NULL
  , p_to_po_header_id                          NUMBER DEFAULT NULL
  , p_from_purchase_order                      VARCHAR2 DEFAULT NULL
  , p_to_purchase_order                        VARCHAR2 DEFAULT NULL
  , p_from_rma_header_id                       NUMBER DEFAULT NULL
  , p_to_rma_header_id                         NUMBER DEFAULT NULL
  , p_from_rma                                 VARCHAR2 DEFAULT NULL
  , p_to_rma                                   VARCHAR2 DEFAULT NULL
  , p_from_requisition_header_id               NUMBER DEFAULT NULL
  , p_to_requisition_header_id                 NUMBER DEFAULT NULL
  , p_from_requisition                         VARCHAR2 DEFAULT NULL
  , p_to_requisition                           VARCHAR2 DEFAULT NULL
  , p_from_shipment_number                     VARCHAR2 DEFAULT NULL
  , p_to_shipment_number                       VARCHAR2 DEFAULT NULL
  , p_include_sales_orders                     BOOLEAN DEFAULT TRUE
  , p_include_internal_orders                  BOOLEAN DEFAULT TRUE
  , p_from_sales_order_id                      NUMBER DEFAULT NULL
  , p_to_sales_order_id                        NUMBER DEFAULT NULL
  , p_from_pick_slip_number                    NUMBER DEFAULT NULL
  , p_to_pick_slip_number                      NUMBER DEFAULT NULL
  , p_customer_id                              NUMBER DEFAULT NULL
  , p_customer_category                        VARCHAR2 DEFAULT NULL
  , p_delivery_id                              NUMBER DEFAULT NULL
  , p_carrier_id                               NUMBER DEFAULT NULL
  , p_ship_method                              VARCHAR2 DEFAULT NULL
  , p_shipment_priority                        VARCHAR2 DEFAULT NULL
  , p_trip_id                                  NUMBER DEFAULT NULL
  , p_from_shipment_date                       DATE DEFAULT NULL
  , p_to_shipment_date                         DATE DEFAULT NULL
  , p_ship_to_state                            VARCHAR2 DEFAULT NULL
  , p_ship_to_country                          VARCHAR2 DEFAULT NULL
  , p_ship_to_postal_code                      VARCHAR2 DEFAULT NULL
  , p_from_number_of_order_lines               NUMBER DEFAULT NULL
  , p_to_number_of_order_lines                 NUMBER DEFAULT NULL
  , p_manufacturing_type                       VARCHAR2 DEFAULT NULL
  , p_from_job                                 VARCHAR2 DEFAULT NULL
  , p_to_job                                   VARCHAR2 DEFAULT NULL
  , p_assembly_id                              NUMBER DEFAULT NULL
  , p_from_start_date                          DATE DEFAULT NULL
  , p_to_start_date                            DATE DEFAULT NULL
  , p_from_line                                VARCHAR2 DEFAULT NULL
  , p_to_line                                  VARCHAR2 DEFAULT NULL
  , p_department_id                            NUMBER DEFAULT NULL
  , p_include_replenishment                    BOOLEAN DEFAULT TRUE
  , p_from_replenishment_mo                    VARCHAR2 DEFAULT NULL
  , p_to_replenishment_mo                      VARCHAR2 DEFAULT NULL
  , p_include_mo_transfer                      BOOLEAN DEFAULT TRUE
  , p_include_mo_issue                         BOOLEAN DEFAULT TRUE
  , p_from_transfer_issue_mo                   VARCHAR2 DEFAULT NULL
  , p_to_transfer_issue_mo                     VARCHAR2 DEFAULT NULL
  , p_include_lpn_putaway                      BOOLEAN DEFAULT TRUE
  , p_include_staging_move                     BOOLEAN DEFAULT FALSE
  , p_include_cycle_count                      BOOLEAN DEFAULT TRUE
  , p_cycle_count_name                         VARCHAR2 DEFAULT NULL
  , p_query_independent_tasks                  BOOLEAN DEFAULT TRUE
  , p_query_planned_tasks                      BOOLEAN DEFAULT TRUE
  , p_is_pending_plan                          BOOLEAN DEFAULT FALSE
  , p_is_inprogress_plan                       BOOLEAN DEFAULT FALSE
  , p_is_completed_plan                        BOOLEAN DEFAULT FALSE
  , p_is_cancelled_plan                         BOOLEAN DEFAULT FALSE
  , p_is_aborted_plan                          BOOLEAN DEFAULT FALSE
  , p_activity_id                              NUMBER DEFAULT NULL
  , p_plan_type_id                             NUMBER DEFAULT NULL
  , p_op_plan_id                               NUMBER DEFAULT NULL) IS

   l_module_name CONSTANT VARCHAR2(20) := 'set_globals';
   l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

BEGIN
   IF l_debug = 1 THEN
     debug(' in set_globals ','set_globals');
   END IF;
   wms_plan_tasks_pvt.g_organization_id         :=               p_organization_id;
   wms_plan_tasks_pvt.g_subinventory_code       :=               p_subinventory_code;
   wms_plan_tasks_pvt.g_locator_id              :=               p_locator_id;
   wms_plan_tasks_pvt.g_to_subinventory_code    :=               p_to_subinventory_code;
   wms_plan_tasks_pvt.g_to_locator_id           :=               p_to_locator_id;
   wms_plan_tasks_pvt.g_inventory_item_id       :=               p_inventory_item_id;
   wms_plan_tasks_pvt.g_category_set_id         :=               p_category_set_id;
   wms_plan_tasks_pvt.g_item_category_id        :=               p_item_category_id;
   wms_plan_tasks_pvt.g_person_id               :=               p_person_id;
   wms_plan_tasks_pvt.g_person_resource_id      :=               p_person_resource_id;
   wms_plan_tasks_pvt.g_equipment_type_id       :=               p_equipment_type_id;
   wms_plan_tasks_pvt.g_machine_resource_id     :=               p_machine_resource_id;
   wms_plan_tasks_pvt.g_machine_instance        :=               p_machine_instance;
   wms_plan_tasks_pvt.g_user_task_type_id       :=               p_user_task_type_id;
   wms_plan_tasks_pvt.g_from_task_quantity      :=               p_from_task_quantity;
   wms_plan_tasks_pvt.g_to_task_quantity        :=               p_to_task_quantity;
   wms_plan_tasks_pvt.g_from_task_priority      :=               p_from_task_priority;
   wms_plan_tasks_pvt.g_to_task_priority        :=               p_to_task_priority;
   wms_plan_tasks_pvt.g_from_creation_date      :=               p_from_creation_date;
   wms_plan_tasks_pvt.g_to_creation_date        :=               p_to_creation_date;

   wms_plan_tasks_pvt.g_is_unreleased_task           :=               p_is_unreleased_task;
   wms_plan_tasks_pvt.g_is_pending_task              :=               p_is_pending_task;
   wms_plan_tasks_pvt.g_is_queued_task               :=               p_is_queued_task;
   wms_plan_tasks_pvt.g_is_dispatched_task           :=               p_is_dispatched_task;
   wms_plan_tasks_pvt.g_is_active_task               :=               p_is_active_task;
   wms_plan_tasks_pvt.g_is_loaded_task               :=               p_is_loaded_task;
   wms_plan_tasks_pvt.g_is_completed_task            :=               p_is_completed_task ;

   wms_plan_tasks_pvt.g_include_inbound         :=               p_include_inbound;
   wms_plan_tasks_pvt.g_include_outbound        :=               p_include_outbound;
   wms_plan_tasks_pvt.g_include_crossdock       :=               p_include_crossdock;
   wms_plan_tasks_pvt.g_include_manufacturing   :=               p_include_manufacturing;
   wms_plan_tasks_pvt.g_include_warehousing     :=               p_include_warehousing;
   wms_plan_tasks_pvt.g_from_po_header_id       :=               p_from_po_header_id;
   wms_plan_tasks_pvt.g_to_po_header_id         :=               p_to_po_header_id;
   wms_plan_tasks_pvt.g_from_purchase_order     :=               p_from_purchase_order;
   wms_plan_tasks_pvt.g_to_purchase_order       :=               p_to_purchase_order;
   wms_plan_tasks_pvt.g_from_rma_header_id      :=               p_from_rma_header_id;
   wms_plan_tasks_pvt.g_to_rma_header_id        :=               p_to_rma_header_id;
   wms_plan_tasks_pvt.g_from_rma                :=               p_from_rma;
   wms_plan_tasks_pvt.g_to_rma                  :=               p_to_rma;
   wms_plan_tasks_pvt.g_from_requisition_header_id :=            p_from_requisition_header_id;
   wms_plan_tasks_pvt.g_to_requisition_header_id:=               p_to_requisition_header_id;
   wms_plan_tasks_pvt.g_from_requisition        :=               p_from_requisition;
   wms_plan_tasks_pvt.g_to_requisition           :=              p_to_requisition;
   wms_plan_tasks_pvt.g_from_shipment_number     :=              p_from_shipment_number;
   wms_plan_tasks_pvt.g_to_shipment_number       :=              p_to_shipment_number;
   wms_plan_tasks_pvt.g_include_sales_orders     :=              p_include_sales_orders;
   wms_plan_tasks_pvt.g_include_internal_orders  :=              p_include_internal_orders;
   wms_plan_tasks_pvt.g_from_sales_order_id      :=              p_from_sales_order_id;
   wms_plan_tasks_pvt.g_to_sales_order_id        :=              p_to_sales_order_id;
   wms_plan_tasks_pvt.g_from_pick_slip_number    :=              p_from_pick_slip_number;
   wms_plan_tasks_pvt.g_to_pick_slip_number      :=              p_to_pick_slip_number;
   wms_plan_tasks_pvt.g_customer_id              :=              p_customer_id;
   wms_plan_tasks_pvt.g_customer_category        :=              p_customer_category;
   wms_plan_tasks_pvt.g_delivery_id              :=              p_delivery_id;
   wms_plan_tasks_pvt.g_carrier_id               :=              p_carrier_id;
   wms_plan_tasks_pvt.g_ship_method              :=              p_ship_method;
   wms_plan_tasks_pvt.g_shipment_priority        :=              p_shipment_priority;
   wms_plan_tasks_pvt.g_trip_id                  :=              p_trip_id;
   wms_plan_tasks_pvt.g_from_shipment_date       :=              p_from_shipment_date;
   wms_plan_tasks_pvt.g_to_shipment_date         :=              p_to_shipment_date;
   wms_plan_tasks_pvt.g_ship_to_state            :=              p_ship_to_state;
   wms_plan_tasks_pvt.g_ship_to_country          :=              p_ship_to_country;
   wms_plan_tasks_pvt.g_ship_to_postal_code      :=              p_ship_to_postal_code;
   wms_plan_tasks_pvt.g_from_number_of_order_lines :=            p_from_number_of_order_lines;
   wms_plan_tasks_pvt.g_to_number_of_order_lines   :=            p_to_number_of_order_lines;
   wms_plan_tasks_pvt.g_manufacturing_type         :=            p_manufacturing_type;
   wms_plan_tasks_pvt.g_from_job                   :=            p_from_job;
   wms_plan_tasks_pvt.g_to_job                     :=            p_to_job;
   wms_plan_tasks_pvt.g_assembly_id                :=            p_assembly_id;
   wms_plan_tasks_pvt.g_from_start_date            :=            p_from_start_date;
   wms_plan_tasks_pvt.g_to_start_date              :=            p_to_start_date;
   wms_plan_tasks_pvt.g_from_line                  :=            p_from_line;
   wms_plan_tasks_pvt.g_to_line                    :=            p_to_line;
   wms_plan_tasks_pvt.g_department_id              :=            p_department_id;
   wms_plan_tasks_pvt.g_include_replenishment      :=            p_include_replenishment;
   wms_plan_tasks_pvt.g_from_replenishment_mo      :=            p_from_replenishment_mo;
   wms_plan_tasks_pvt.g_to_replenishment_mo        :=            p_to_replenishment_mo;
   wms_plan_tasks_pvt.g_include_mo_transfer        :=            p_include_mo_transfer;
   wms_plan_tasks_pvt.g_include_mo_issue           :=            p_include_mo_issue;
   wms_plan_tasks_pvt.g_from_transfer_issue_mo     :=            p_from_transfer_issue_mo;
   wms_plan_tasks_pvt.g_to_transfer_issue_mo       :=            p_to_transfer_issue_mo;
   wms_plan_tasks_pvt.g_include_lpn_putaway        :=            p_include_lpn_putaway;
   wms_plan_tasks_pvt.g_include_staging_move       :=            p_include_staging_move;
   wms_plan_tasks_pvt.g_include_cycle_count        :=            p_include_cycle_count;
   wms_plan_tasks_pvt.g_cycle_count_name           :=            p_cycle_count_name;

   wms_plan_tasks_pvt.g_query_independent_tasks := p_query_independent_tasks;
   wms_plan_tasks_pvt.g_query_planned_tasks := p_query_planned_tasks;

   wms_plan_tasks_pvt.g_is_pending_plan    := p_is_pending_plan;
   wms_plan_tasks_pvt.g_is_inprogress_plan := p_is_inprogress_plan;
   wms_plan_tasks_pvt.g_is_completed_plan  := p_is_completed_plan;
   wms_plan_tasks_pvt.g_is_cancelled_plan   := p_is_cancelled_plan;
   wms_plan_tasks_pvt.g_is_aborted_plan    := p_is_aborted_plan;

   wms_plan_tasks_pvt.g_activity_id    := p_activity_id;
   wms_plan_tasks_pvt.g_plan_type_id    := p_plan_type_id;
   wms_plan_tasks_pvt.g_op_plan_id    := p_op_plan_id;

   IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
      wms_plan_tasks_pvt.g_inbound_specific_query := TRUE;
   END IF;

   IF wms_plan_tasks_pvt.g_from_sales_order_id   IS NOT NULL  OR
   wms_plan_tasks_pvt.g_to_sales_order_id     IS NOT NULL  OR
   wms_plan_tasks_pvt.g_customer_id           IS NOT NULL  OR
   wms_plan_tasks_pvt.g_customer_category     IS NOT NULL  OR
   wms_plan_tasks_pvt.g_delivery_id           IS NOT NULL  OR
   wms_plan_tasks_pvt.g_carrier_id            IS NOT NULL  OR
   wms_plan_tasks_pvt.g_ship_method           IS NOT NULL  OR
   wms_plan_tasks_pvt.g_shipment_priority     IS NOT NULL  OR
   wms_plan_tasks_pvt.g_trip_id               IS NOT NULL  OR
   wms_plan_tasks_pvt.g_from_shipment_date    IS NOT NULL  OR
   wms_plan_tasks_pvt.g_to_shipment_date      IS NOT NULL  OR
   wms_plan_tasks_pvt.g_ship_to_state         IS NOT NULL  OR
   wms_plan_tasks_pvt.g_ship_to_country       IS NOT NULL  OR
   wms_plan_tasks_pvt.g_ship_to_postal_code   IS NOT NULL  THEN
      wms_plan_tasks_pvt.g_outbound_specific_query := TRUE;
   END IF;



/*
   IF wms_waveplan_tasks_pvt.g_task_types.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_task_types.count LOOP
         wms_plan_tasks_pvt.g_task_types(i) := wms_waveplan_tasks_pvt.g_task_types(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_task_types_orig.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_task_types_orig.count LOOP
         wms_plan_tasks_pvt.g_task_types_orig(i) := wms_waveplan_tasks_pvt.g_task_types_orig(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_status_codes.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_status_codes.count LOOP
         wms_plan_tasks_pvt.g_status_codes(i) := wms_waveplan_tasks_pvt.g_status_codes(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_status_codes_orig.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_status_codes_orig.count LOOP
         wms_plan_tasks_pvt.g_status_codes_orig(i) := wms_waveplan_tasks_pvt.g_status_codes_orig(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_plan_task_types.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_plan_task_types.count LOOP
         wms_plan_tasks_pvt.g_plan_task_types(i) := wms_waveplan_tasks_pvt.g_plan_task_types(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_plan_task_types_orig.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_plan_task_types_orig.count LOOP
         wms_plan_tasks_pvt.g_plan_task_types_orig(i) := wms_waveplan_tasks_pvt.g_plan_task_types_orig(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_plan_status_codes.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_plan_status_codes.count LOOP
         wms_plan_tasks_pvt.g_plan_status_codes(i) := wms_waveplan_tasks_pvt.g_plan_status_codes(i);
      END LOOP;
   END IF;

   IF wms_waveplan_tasks_pvt.g_plan_status_codes_orig.count > 0  THEN
      FOR i IN 1..wms_waveplan_tasks_pvt.g_plan_status_codes_orig.count LOOP
         wms_plan_tasks_pvt.g_plan_status_codes_orig(i) := wms_waveplan_tasks_pvt.g_plan_status_codes_orig(i);
      END LOOP;
   END IF;
 */

   wms_plan_tasks_pvt.g_task_types             := wms_waveplan_tasks_pvt.g_task_types;
   wms_plan_tasks_pvt.g_task_types_orig        := wms_waveplan_tasks_pvt.g_task_types_orig;
   wms_plan_tasks_pvt.g_status_codes           := wms_waveplan_tasks_pvt.g_status_codes;
   wms_plan_tasks_pvt.g_status_codes_orig      := wms_waveplan_tasks_pvt.g_status_codes_orig;
   wms_plan_tasks_pvt.g_plan_task_types        := wms_waveplan_tasks_pvt.g_plan_task_types;
   wms_plan_tasks_pvt.g_plan_task_types_orig   := wms_waveplan_tasks_pvt.g_plan_task_types_orig;
   wms_plan_tasks_pvt.g_plan_status_codes      := wms_waveplan_tasks_pvt.g_plan_status_codes;
   wms_plan_tasks_pvt.g_plan_status_codes_orig := wms_waveplan_tasks_pvt.g_plan_status_codes_orig;

   wms_plan_tasks_pvt.g_plans_tasks_record_count := 0;

END set_globals;

PROCEDURE get_inbound_specific_query(
                   x_inbound_select_str OUT NOCOPY VARCHAR2
                   ,x_inbound_from_str   OUT NOCOPY VARCHAR2
                   ,x_inbound_where_str  OUT NOCOPY VARCHAR2
                   ,p_is_completed_rec   IN NUMBER) IS
   l_inbound_select wms_plan_tasks_pvt.short_sql;
   l_inbound_from wms_plan_tasks_pvt.short_sql;
   l_inbound_where VARCHAR2(5000);
   l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   L_MOVER_ORDER_LINE  VARCHAR2(5000); --code  for Bug#8467334
   --Hardik LSP bug 9274233
   l_from_client_code VARCHAR2(30);
   l_delimiter VARCHAR2(1);
   l_is_po_number VARCHAR2(60);--CLM Changes; PO number can be alphanumeric
   --Hardik LSP bug 9274233 End
BEGIN
   /**** Inbound specific queries ****/
   --
   IF p_is_completed_rec = 0 THEN --not a completed record
        IF l_debug = 1 THEN
	  debug(' not a completed record ','get_inbound_specific_query');
	END IF;

	-- Code for Bug#8467334 .Added to popluate TXN_SOURCE_ID and transaction_source_type_id of loaded tasks in WMS_WAVEPLAN_TASKS_TEMP .
	-- We'll use this info -- Populate Job No In ctl Board
 l_inbound_select  :=',  Nvl2(mtrl.reference ,mtrl.reference_id , mtrl.TXN_SOURCE_ID)  ' ||
                     ' , Nvl( mtrl.reference , Decode (mtrl.transaction_source_type_id,5 , ' ||'''WIP JOB'' ,  NULL ) ) ';
/* Original Code        l_inbound_select  := ', mtrl.reference_id ' || /*reference_id */
                             /*', mtrl.reference '; -- reference */

-- End of code for Bug#8467334

     ELSE
        IF l_debug = 1 THEN
	  debug(' querying for completed_record ','get_inbound_specific_query');
	END IF;
	 -- Code for Bug#8467334
-- Code added to popluate TXN_SOURCE_ID and transaction_source_type_id of completed tasks in WMS_WAVEPLAN_TASKS_TEMP . We'll use this info
-- Populate Job No In ctl Board
L_MOVER_ORDER_LINE := '' ;
if wms_plan_tasks_pvt.g_planned_tasks_rec.is_completed = TRUE OR
   wms_plan_tasks_pvt.g_is_completed_task = TRUE then

   l_mover_order_line := ' wdth.MOVE_ORDER_LINE_ID ';

END IF;

        -- reference
        l_inbound_select  := ', decode(rt.source_document_code, '
                        || '''INVENTORY'', rt.shipment_line_id, '
                        || '''PO'', rt.po_line_location_id, '
                        || '''REQ'', rt.shipment_line_id, '
                        || '''RMA'', rt.oe_order_line_id '
			|| ' , NULL ' ||' , '|| '( SELECT distinct TXN_SOURCE_ID FROM    mtl_txn_request_lines '
			|| ' WHERE line_id = '|| l_mover_order_line || ' ))'  --  Code for Bug#8467334
                        || ', decode(rt.source_document_code, '
                        || '''INVENTORY'', ''SHIPMENT_LINE_ID'', '
                        || '''PO'', ''PO_LINE_LOCATION_ID'', '
                        || '''REQ'', ''SHIPMENT_LINE_ID'', '
                        || '''RMA'', ''ORDER_LINE_ID''  '
			||', NULL '||' , ' || '( SELECT Distinct (Decode (transaction_source_type_id,5 , '
			||'''WIP JOB'' ,  NULL )) FROM mtl_material_transactions WHERE MOVE_ORDER_LINE_ID =
			'|| l_mover_order_line || ' ) )';  --  Code for  Bug#8467334
-- End of code  for Bug#8467334

      END IF;

      IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL THEN
        l_inbound_select  := l_inbound_select || ', ph.segment1 ' || /* source_header*/
                             ', pl.line_num '; -- line_number
      ELSIF wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL THEN
        l_inbound_select  := l_inbound_select || ', ooh.order_number '; -- source_header
        l_inbound_select  := l_inbound_select || ', ool.line_number '; -- line_number
      ELSIF wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
        l_inbound_select  := l_inbound_select || ', prh.segment1 '; -- source_header
        l_inbound_select  := l_inbound_select || ', prl.line_num '; -- line_number
      END IF;

      /* Bug 5259318 */
      IF g_delivery_visible = 'T'
      THEN
	IF wms_plan_tasks_pvt.g_include_crossdock then
          l_inbound_select := l_inbound_select || ', wnd.name '; --delivery
	END IF;
      END IF;
      /* End of Bug 5259318 */


      /* inbound specific from */
      IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL THEN
        IF p_is_completed_rec = 0 THEN
          l_inbound_from  := l_inbound_from || ', po_line_locations_trx_v pll';
        END IF;

        l_inbound_from  := l_inbound_from
                           || ', po_headers_trx_v ph'--CLM Changes, using CLM views instead of base tables
                           ||', po_lines_trx_v pl';
      ELSIF wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL THEN
            l_inbound_from  := l_inbound_from
                               || ', oe_order_headers_all ooh'
                               || ', oe_order_lines_all ool';
      ELSIF wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
            l_inbound_from  := l_inbound_from
                               || ', rcv_shipment_headers rsh'
                               || ', rcv_shipment_lines rsl'
      -- MOAC changed po_requisition_headers and po_requisition_lines to _ALL tables
                               || ', po_requisition_headers_all prh'
                               || ', po_requisition_lines_all prl';
      ELSIF wms_plan_tasks_pvt.g_from_shipment_number IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_shipment_number IS NOT NULL THEN
            l_inbound_from  := l_inbound_from
                               || ', rcv_shipment_headers rsh'
                               || ', rcv_shipment_lines rsl';
      END IF;

      IF p_is_completed_rec = 0 THEN --not completed
        l_inbound_from  := l_inbound_from
                           || ', mtl_txn_request_headers mtrh '
                           || ', mtl_txn_request_lines mtrl ';
      ELSE -- completed tasks

        l_inbound_from  := l_inbound_from || ', rcv_transactions rt ';
      END IF;

      IF p_is_completed_rec = 0 THEN
         l_inbound_where  := l_inbound_where
                      || ' AND mtrh.header_id = mtrl.header_id '
                      || ' AND mtrh.move_order_type = 6 '
                      || ' AND mmtt.move_order_line_id = mtrl.line_id ';

        IF NOT(
               wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL
               OR wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL
               OR wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL
               OR wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL
               OR wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL
               OR wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL
              ) THEN
          l_inbound_where  := l_inbound_where
               || ' AND '
	       || '( '  -- Code for Bug#8467334
	       ||' mtrl.reference in (''PO_LINE_LOCATION_ID'', ''ORDER_LINE_ID'', ''SHIPMENT_LINE_ID'') ';

	        -- Code for Bug#8467334
	 -- Code added to show Put away of WIP Job for Loaded tasks
               l_inbound_where  := l_inbound_where
               || '  OR  mtrl.reference IS NULL ) ';
  --End of Code added to show Put away of WIP Job for Loaded tasks
  -- End of Code for Bug#8467334

        END IF;
      END IF;

      -- Build the inbound section(FROM and WHERE) of the query

      IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL
         OR wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL THEN
        l_inbound_where  := l_inbound_where
                            || ' AND pl.po_header_id = ph.po_header_id ';

        IF p_is_completed_rec = 0 THEN --not completed
          l_inbound_where  := l_inbound_where
                       || ' AND pll.po_line_id = pl.po_line_id '
                       || ' AND pll.line_location_id = mtrl.reference_id ';
          IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
                || 'AND pll.po_header_id >= :from_po_header_id ';
          END IF;

          IF wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
                  || 'AND pll.po_header_id <= :to_po_header_id ';
          END IF;

          --Hardik LSP bug 9274233

          l_from_client_code := wms_deploy.get_po_client_code(wms_plan_tasks_pvt.g_from_po_header_id);
          l_delimiter := wms_deploy.get_item_flex_delimiter;
          l_is_po_number := wms_deploy.get_po_number(wms_plan_tasks_pvt.g_from_purchase_order);

          IF l_is_po_number <> '-1' THEN
            IF l_from_client_code IS NOT NULL THEN
              l_inbound_where  := l_inbound_where
                    || 'AND ph.segment1 LIKE ' || '''' || '%' || l_delimiter || l_from_client_code || '''';
            ELSE
              l_inbound_where  := l_inbound_where
                  || 'AND to_char(wms_deploy.get_po_number(ph.segment1)) = ph.segment1';
            END IF;
          END IF;
          --Hardik LSP End bug 9274233

        ELSE -- is completed

          l_inbound_where  := l_inbound_where
                        || ' AND rt.po_line_id = pl.po_line_id ';

          IF wms_plan_tasks_pvt.g_from_po_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
                 || 'AND rt.po_header_id >= :from_po_header_id ';
          END IF;

          IF wms_plan_tasks_pvt.g_to_po_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
                   || 'AND rt.po_header_id <= :to_po_header_id ';
          END IF;
        END IF;
      ELSIF wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL THEN
        l_inbound_where  := l_inbound_where
                        || ' AND ooh.header_id = ool.header_id ';

        IF p_is_completed_rec = 0 THEN -- not completed
          l_inbound_where  := l_inbound_where
                      || ' AND mtrl.reference_id = ool.line_id '
                      || ' AND mtrl.reference = ''ORDER_LINE_ID'' ';

          IF wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
                  || 'AND ooh.header_id >= :from_rma_header_id ';
          END IF;

          IF wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
                    || 'AND ooh.header_id <= :to_rma_header_id ';
          END IF;
        ELSE
          l_inbound_where  := l_inbound_where
                    || ' AND rt.oe_order_line_id = ool.line_id ';

          IF wms_plan_tasks_pvt.g_from_rma_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
               || 'AND rt.oe_order_header_id >= :from_rma_header_id ';
          END IF;

          IF wms_plan_tasks_pvt.g_to_rma_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
               || 'AND rt.oe_order_header_id <= :to_rma_header_id ';
          END IF;
        END IF;
      ELSIF wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
        l_inbound_where  := l_inbound_where
           || ' AND rsl.requisition_line_id = prl.requisition_line_id '
           || ' AND rsh.shipment_header_id = rsl.shipment_header_id '
           || ' AND prh.requisition_header_id = prl.requisition_header_id ';

        IF p_is_completed_rec = 0 THEN -- not completed
          l_inbound_where  := l_inbound_where
             || ' AND mtrl.reference_id = rsl.shipment_line_id '
             || ' AND mtrl.reference = ''SHIPMENT_LINE_ID'' ';

          IF wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
               || 'AND prh.requisition_header_id >= :from_requisition_header_id ';
          END IF;

          IF wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
               || 'AND prh.requisition_header_id <= :to_requisition_header_id ';
          END IF;
        ELSE -- completed
          l_inbound_where  := l_inbound_where
             || ' AND rt.shipment_line_id = rsl.shipment_line_id ';

          IF wms_plan_tasks_pvt.g_from_requisition_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
               || 'AND prh.requisition_header_id >= :from_requisition_header_id ';
          END IF;

          IF wms_plan_tasks_pvt.g_to_requisition_header_id IS NOT NULL THEN
            l_inbound_where  := l_inbound_where
               || 'AND prh.requisition_header_id <= :to_requisition_header_id ';
          END IF;
        END IF;
      ELSIF wms_plan_tasks_pvt.g_from_shipment_number IS NOT NULL
            OR wms_plan_tasks_pvt.g_to_shipment_number IS NOT NULL THEN
        l_inbound_where  := l_inbound_where
           || ' AND rsh.shipment_header_id = rsl.shipment_header_id '
           || ' AND rsl.requisition_line_id IS NULL ';

        IF p_is_completed_rec = 0 THEN -- not completed
          l_inbound_where  := l_inbound_where
             || ' AND mtrl.reference_id = rsl.shipment_line_id '
             || ' AND mtrl.reference = ''SHIPMENT_LINE_ID'' ';
        ELSE -- completed
          l_inbound_where  := l_inbound_where
             || ' AND rsh.shipment_header_id = rt.shipment_header_id '
             || ' AND rsl.shipment_line_id = rt.shipment_line_id '
             || ' AND rt.po_line_id IS NULL '
             || ' AND rt.oe_order_header_id IS NULL ';
        END IF;

        IF wms_plan_tasks_pvt.g_from_shipment_number IS NOT NULL THEN
          l_inbound_where  := l_inbound_where
             || ' AND rsh.shipment_num >= :from_shipment_number ';
        END IF;

        IF wms_plan_tasks_pvt.g_to_shipment_number IS NOT NULL THEN
          l_inbound_where  := l_inbound_where
              || ' AND rsh.shipment_num <= :to_shipment_number ';
        END IF;
      END IF;

      x_inbound_select_str := l_inbound_select;
      x_inbound_from_str := l_inbound_from;
      x_inbound_where_str := l_inbound_where;

END get_inbound_specific_query;


/* This is used to add-in the outbound query criteria while
   querying crossdock tasks */
PROCEDURE get_outbound_specific_query(
                    x_outbound_from_str   OUT NOCOPY VARCHAR2
                   ,x_outbound_where_str  OUT NOCOPY VARCHAR2
                   ) IS
   --l_inbound_select wms_plan_tasks_pvt.short_sql;
   l_from_outbound wms_plan_tasks_pvt.short_sql;
   l_where_outbound wms_plan_tasks_pvt.short_sql;
   l_is_range_so BOOLEAN;
   l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

BEGIN
   /**** Outbound specific queries ****/
   IF l_debug = 1 THEN
     debug(' in get_outbound_specific_query.. ' );
   END IF;
   if (wms_plan_tasks_pvt.g_from_sales_order_id = wms_plan_tasks_pvt.g_to_sales_order_id) then
     l_is_range_so := FALSE;
   else/*range so is TRUE if from or to is null or form<> to*/
      l_is_range_so := TRUE;
   end if;

   -- BUILD THE FROM CLAUSE
   l_from_outbound := ', wsh_delivery_details_ob_grp_v wdd ';
   if NOT g_is_completed_task then/*3455109 we will no longer use mso for completed tasks*/
      IF wms_plan_tasks_pvt.g_from_sales_order_id IS NOT NULL
      THEN
         l_from_outbound := l_from_outbound || ', mtl_sales_orders mso1 ';
      END IF;

      IF wms_plan_tasks_pvt.g_to_sales_order_id IS NOT NULL
      THEN
         l_from_outbound := l_from_outbound || ', mtl_sales_orders mso2 ';
      END IF;
   END IF;

   IF g_customer_visible = 'T' OR wms_plan_tasks_pvt.g_customer_category IS NOT NULL
   THEN
      l_from_outbound := l_from_outbound || ', hz_parties hp ';
      l_from_outbound := l_from_outbound || ', hz_cust_accounts hca ';
   END IF;

   IF g_carrier_visible = 'T'
   THEN
      l_from_outbound := l_from_outbound || ', wsh_carriers wc ';
   END IF;

   IF g_ship_method_visible = 'T'
   THEN
      l_from_outbound :=
                       l_from_outbound || ', fnd_lookup_values_vl flv ';
   END IF;

   IF wms_plan_tasks_pvt.g_trip_id IS NOT NULL
   THEN
           --Change
      /*l_from_outbound := l_from_outbound || ', wsh_trips wt, wsh_trip_stops wts ';
      l_from_outbound := l_from_outbound || ', wsh_delivery_legs wdl, wsh_new_deliveries wnd ';
      l_from_outbound := l_from_outbound || ', wsh_delivery_assignments wda ';   */
      l_from_outbound :=
            l_from_outbound
         || ', wsh_trips_ob_grp_v wt, wsh_trip_stops_ob_grp_v wts ';
      l_from_outbound :=
            l_from_outbound
         || ', wsh_delivery_legs_ob_grp_v wdl, wsh_new_deliveries_ob_grp_v wnd ';
      l_from_outbound :=
                    l_from_outbound || ', wsh_delivery_assignments wda ';
   --End of change
   ELSIF wms_plan_tasks_pvt.g_delivery_id IS NOT NULL
   THEN
      l_from_outbound :=
                   l_from_outbound || ', wsh_delivery_assignments wda ';
   END IF;

   IF g_delivery_visible = 'T' AND wms_plan_tasks_pvt.g_trip_id IS NULL
   THEN
           --Change
      --l_from_outbound := l_from_outbound || ', wsh_new_deliveries wnd ';
      l_from_outbound :=
                l_from_outbound || ', wsh_new_deliveries_ob_grp_v wnd ';

      -- End of change
      IF wms_plan_tasks_pvt.g_delivery_id IS NULL
      THEN
         l_from_outbound :=
                   l_from_outbound || ', wsh_delivery_assignments wda ';
      END IF;
   END IF;

   IF    wms_plan_tasks_pvt.g_ship_to_state IS NOT NULL
      OR wms_plan_tasks_pvt.g_ship_to_country IS NOT NULL
      OR wms_plan_tasks_pvt.g_ship_to_postal_code IS NOT NULL
      OR g_ship_to_country_visible = 'T'
      OR g_ship_to_state_visible = 'T'
      OR g_ship_to_postal_code_visible = 'T'
   THEN
      l_from_outbound := l_from_outbound || ', hz_locations hl ';
   END IF;

   IF    wms_plan_tasks_pvt.g_from_number_of_order_lines IS NOT NULL
      OR wms_plan_tasks_pvt.g_to_number_of_order_lines IS NOT NULL
   THEN
      l_from_outbound :=
            l_from_outbound
         || ', (SELECT COUNT(line_id) line_sum, header_id FROM oe_order_lines_all ';

      IF wms_plan_tasks_pvt.g_customer_id IS NOT NULL
      THEN
         l_from_outbound :=
             l_from_outbound || ' WHERE sold_to_org_id = :customer_id ';
      END IF;

      l_from_outbound :=
                        l_from_outbound || ' GROUP BY header_id) oolac ';
   END IF;

   -- BUILD THE WHERE CLAUSE
   IF NOT g_is_completed_task THEN -- Non Completed tasks
      -- Build the outbound where section of the query
      -- l_where_outbound := 'AND mmtt.transaction_action_id = 28 ';

      IF    (wms_plan_tasks_pvt.g_include_internal_orders AND NOT wms_plan_tasks_pvt.g_include_sales_orders
            )
         OR (NOT wms_plan_tasks_pvt.g_include_internal_orders AND wms_plan_tasks_pvt.g_include_sales_orders)
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND mmtt.transaction_source_type_id = :source_type_id ';
      END IF;

      IF wms_plan_tasks_pvt.g_from_sales_order_id IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND mso1.sales_order_id = :from_sales_order_id ';
         l_where_outbound :=
               l_where_outbound
            || 'AND to_number(wdd.source_header_number) >= to_number(mso1.segment1) ';
         l_where_outbound :=
               l_where_outbound
            || 'AND wdd.source_header_type_name >= mso1.segment2 ';
      END IF;

      IF wms_plan_tasks_pvt.g_to_sales_order_id IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND mso2.sales_order_id = :to_sales_order_id ';
         l_where_outbound :=
               l_where_outbound
            || 'AND to_number(wdd.source_header_number) <= to_number(mso2.segment1) ';
         l_where_outbound :=
               l_where_outbound
            || 'AND wdd.source_header_type_name <= mso2.segment2 ';
      END IF;

      IF wms_plan_tasks_pvt.g_from_pick_slip_number IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND mmtt.pick_slip_number >= :from_pick_slip_number ';
      END IF;

      IF wms_plan_tasks_pvt.g_to_pick_slip_number IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND mmtt.pick_slip_number <= :to_pick_slip_number ';
      END IF;
      /*
      l_where_outbound := l_where_outbound || 'AND mmtt.move_order_line_id = wdd.move_order_line_id ';
      l_where_outbound := l_where_outbound || 'AND wdd.delivery_detail_id = (select delivery_detail_id from wsh_delivery_details_ob_grp_v ';
      l_where_outbound := l_where_outbound || ' where mmtt.trx_source_line_id = source_line_id ';
      l_where_outbound := l_where_outbound || ' and mmtt.move_order_line_id = move_order_line_id ';
      l_where_outbound := l_where_outbound || ' and rownum < 2) ';
      */
   ELSE   -- Completed tasks
      -- Build the outbound where section of the query for completed tasks
      IF    (wms_plan_tasks_pvt.g_include_internal_orders AND NOT wms_plan_tasks_pvt.g_include_sales_orders
            )
         OR (NOT wms_plan_tasks_pvt.g_include_internal_orders AND wms_plan_tasks_pvt.g_include_sales_orders)
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND wdth.transaction_source_type_id = :source_type_id ';
      END IF;


      /*Logic if L_is_range_so then we need to add the greater than or  less
        than but change it to bind rather than from mso 3455109 else use equals*/
      IF(l_is_range_so)  then
         IF wms_plan_tasks_pvt.g_from_sales_order_id IS NOT NULL
         THEN
            -- 3455109 l_where_outbound := l_where_outbound || 'AND mso1.sales_order_id = :from_sales_order_id ';
            l_where_outbound := l_where_outbound || ' AND lpad(wdd.source_header_number,40) >= :l_from_tonum_mso_seg1 ';
            l_where_outbound := l_where_outbound || ' AND wdd.source_header_type_name >= :l_from_mso_seg2 ';
         END IF;

         IF wms_plan_tasks_pvt.g_to_sales_order_id IS NOT NULL
         THEN
            l_where_outbound := l_where_outbound || 'AND lpad(wdd.source_header_number,40) <= :l_to_tonum_mso_seg1 ';
            l_where_outbound := l_where_outbound || 'AND wdd.source_header_type_name <= :l_to_mso_seg2 ';
         END IF;
      ELSE
         l_where_outbound := l_where_outbound || 'AND (wdd.source_header_number) = :l_from_mso_seg1 ';
         l_where_outbound := l_where_outbound || 'AND wdd.source_header_type_name = :l_from_mso_seg2 ';
      END IF;
      -- commenting since there is no MMT available for crossdock tasks )
      /*
      IF wms_plan_tasks_pvt.g_from_pick_slip_number IS NOT NULL
      THEN
         l_where_outbound := l_where_outbound || 'AND mmt.pick_slip_number >= :from_pick_slip_number ';
      END IF;

      IF wms_plan_tasks_pvt.g_to_pick_slip_number IS NOT NULL
      THEN
         l_where_outbound := l_where_outbound || 'AND mmt.pick_slip_number <= :to_pick_slip_number ';
      END IF;
      */
   END IF;

   IF wms_plan_tasks_pvt.g_customer_id IS NOT NULL
   THEN
      l_where_outbound :=
              l_where_outbound || 'AND wdd.customer_id = :customer_id ';
   END IF;

   IF g_customer_visible = 'T' OR wms_plan_tasks_pvt.g_customer_category IS NOT NULL
   THEN
      l_where_outbound :=
            l_where_outbound || 'AND hca.party_id = hp.party_id ';

   --Bug 6069381: wdd.customer_id is not always same as hp.party_id.
   --It is same as hca.cust_account_id which is taken care below.
      /*l_where_outbound :=
            l_where_outbound || 'AND wdd.customer_id = hp.party_id ';*/

      /* Bug 5507934 */
      l_where_outbound :=
            l_where_outbound || 'AND wdd.customer_id = hca.cust_account_id ';
      /* End of Bug 5507934 */

      IF wms_plan_tasks_pvt.g_customer_category IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND hca.customer_class_code = :customer_category ';
      END IF;
   END IF;

   IF g_carrier_visible = 'T'
   THEN
      l_where_outbound :=
           l_where_outbound || 'AND wdd.carrier_id = wc.carrier_id(+) ';
   END IF;

   IF g_ship_method_visible = 'T'
   THEN
      l_where_outbound :=
            l_where_outbound
         || 'AND flv.lookup_code(+) = wdd.ship_method_code ';
      l_where_outbound :=
         l_where_outbound || 'AND flv.lookup_type(+) = ''SHIP_METHOD'' ';
      l_where_outbound :=
            l_where_outbound
         || 'AND nvl(flv.start_date_active(+), sysdate) <= sysdate ';
      l_where_outbound :=
            l_where_outbound
         || 'AND nvl(flv.end_date_active(+), sysdate) >= sysdate ';
      l_where_outbound :=
               l_where_outbound || 'AND flv.view_application_id(+) = 3 ';
   END IF;

   IF wms_plan_tasks_pvt.g_carrier_id IS NOT NULL
   THEN
      l_where_outbound :=
                l_where_outbound || 'AND wdd.carrier_id = :carrier_id ';
   END IF;

   IF wms_plan_tasks_pvt.g_ship_method IS NOT NULL
   THEN
      l_where_outbound :=
         l_where_outbound || 'AND wdd.ship_method_code = :ship_method ';
   END IF;

   IF wms_plan_tasks_pvt.g_shipment_priority IS NOT NULL
   THEN
      l_where_outbound :=
            l_where_outbound
         || 'AND wdd.shipment_priority_code = :shipment_priority ';
   END IF;

   IF wms_plan_tasks_pvt.g_from_shipment_date IS NOT NULL
   THEN
      l_where_outbound :=
            l_where_outbound
         || 'AND wdd.date_scheduled >= :from_shipment_date ';
   END IF;

   IF wms_plan_tasks_pvt.g_to_shipment_date IS NOT NULL
   THEN
      l_where_outbound :=
            l_where_outbound
         || 'AND wdd.date_scheduled <= :to_shipment_date ';
   END IF;

   IF wms_plan_tasks_pvt.g_trip_id IS NOT NULL OR wms_plan_tasks_pvt.g_delivery_id IS NOT NULL
   THEN
      IF wms_plan_tasks_pvt.g_trip_id IS NOT NULL
      THEN
         l_where_outbound :=
                       l_where_outbound || 'AND wt.trip_id = :trip_id ';
         l_where_outbound :=
                    l_where_outbound || 'AND wt.trip_id = wts.trip_id ';
         l_where_outbound :=
            l_where_outbound
            || 'AND wdl.pick_up_stop_id = wts.stop_id ';
         l_where_outbound :=
            l_where_outbound
            || 'AND wnd.delivery_id = wdl.delivery_id ';
         l_where_outbound :=
            l_where_outbound
            || 'AND wnd.delivery_id = wda.delivery_id ';
      END IF;

      l_where_outbound :=
            l_where_outbound
         || 'AND wdd.delivery_detail_id = wda.delivery_detail_id ';

      IF wms_plan_tasks_pvt.g_delivery_id IS NOT NULL
      THEN
         l_where_outbound :=
              l_where_outbound || 'AND wda.delivery_id = :delivery_id ';
      END IF;
   END IF;

   IF g_delivery_visible = 'T' AND wms_plan_tasks_pvt.g_trip_id IS NULL
   THEN
      IF wms_plan_tasks_pvt.g_delivery_id IS NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND wdd.delivery_detail_id = wda.delivery_detail_id(+) ';
      END IF;

      l_where_outbound :=
         l_where_outbound || 'AND wnd.delivery_id(+) = wda.delivery_id ';
   END IF;

   IF    wms_plan_tasks_pvt.g_ship_to_state IS NOT NULL
      OR wms_plan_tasks_pvt.g_ship_to_country IS NOT NULL
      OR wms_plan_tasks_pvt.g_ship_to_postal_code IS NOT NULL
      OR g_ship_to_country_visible = 'T'
      OR g_ship_to_state_visible = 'T'
      OR g_ship_to_postal_code_visible = 'T'
   THEN
      l_where_outbound :=
            l_where_outbound
         || 'AND wdd.ship_to_location_id = hl.location_id ';

      IF wms_plan_tasks_pvt.g_ship_to_state IS NOT NULL
      THEN
         l_where_outbound :=
                   l_where_outbound || 'AND hl.state = :ship_to_state ';
      END IF;

      IF wms_plan_tasks_pvt.g_ship_to_country IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound || 'AND hl.country = :ship_to_country ';
      END IF;

      IF wms_plan_tasks_pvt.g_ship_to_postal_code IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND hl.postal_code = :ship_to_postal_code ';
      END IF;
   END IF;

   IF    wms_plan_tasks_pvt.g_from_number_of_order_lines IS NOT NULL
      OR wms_plan_tasks_pvt.g_to_number_of_order_lines IS NOT NULL
   THEN
      IF wms_plan_tasks_pvt.g_from_number_of_order_lines IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND oolac.line_sum >= :from_number_of_order_lines ';
      END IF;

      IF wms_plan_tasks_pvt.g_to_number_of_order_lines IS NOT NULL
      THEN
         l_where_outbound :=
               l_where_outbound
            || 'AND oolac.line_sum <= :to_number_of_order_lines ';
      END IF;

      l_where_outbound :=
            l_where_outbound
         || 'AND oolac.header_id = wdd.source_header_id ';
   END IF;
   x_outbound_from_str  := l_from_outbound;
   x_outbound_where_str := l_where_outbound;

END get_outbound_specific_query;

/* This procedure fetches the 'PLAN' records from WDTH. */
PROCEDURE get_wdth_plan_records(x_wdth_select_str OUT NOCOPY VARCHAR2,
                           x_wdth_from_str OUT NOCOPY VARCHAR2,
                           x_wdth_where_str OUT NOCOPY VARCHAR2) IS

l_wdth_str VARCHAR2(6000);
l_wdth_select_str wms_plan_tasks_pvt.short_sql;
l_wdth_from_str VARCHAR2(500);
l_wdth_where_str wms_plan_tasks_pvt.short_sql;
l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
BEGIN
   IF l_debug = 1 THEN
     debug(' in get_wdth_plan_records','get_wdth_plan_records');
   END IF;
 l_wdth_select_str :=
      'SELECT ' ||
      ' decode(wdth.is_parent,''N'',decode(wdth.operation_plan_id,null,null,null),''+''), ' || /* expansion_code*/
      ' ''' || wms_plan_tasks_pvt.g_plan_task_types(3) || ''',' || /*plan_task*/
      ' wdth.transaction_id, ' ||  /*transaction_temp_id*/
      ' wdth.parent_transaction_id,' || /*parent_line_id*/
      ' wdth.inventory_item_id, ' ||  /*inventory_item_id*/
      ' msiv.concatenated_segments, ' || /*item*/
      ' msiv.description, ' || /*item description*/
      ' msiv.unit_weight, ' || /*unit_weight*/
      ' msiv.weight_uom_code, ' || /*weight_uom_code*/
      ' msiv.unit_volume, ' || /*unit_volume*/
      ' msiv.volume_uom_code, ' || /*volume_uom_code*/
      ' wdth.organization_id, ' || /*organization_id*/
      ' wdth.revision, ' || /*revision*/
      ' wdth.source_subinventory_code, ' ||/* subinventory*/
      ' wdth.source_locator_id, ' || /*locator_id*/
      ' decode(milv.segment19, null, milv.concatenated_segments, null), ' || /*locator*/
      ' wdth.status, ' || /*status_id*/
      ' wdth.status, ' || /*status_id_original*/
      ' decode(wdth.status,'
       || '6, '''
       || g_status_codes(6)
       || ''', 11, '''
       || g_status_codes(11)
       || ''', 12, '''
       || g_status_codes(12)
       || '''), ' ||
      ' wdth.transaction_type_id, ' || /*transaction_type_id*/
      ' wdth.transaction_action_id, ' || /*transaction_action_id   */
      ' wdth.transaction_source_type_id, '; /*transaction_source_type_id*/

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str
                 || ' mtst.transaction_source_type_name, '; --transaction_source_type
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                         || ' to_number(null), ' || /*transaction_source_id*/
                            ' to_number(null), ' || /*transaction_source_line_id*/
                            ' wdth.transfer_organization_id, '; /*to_organization_id*/

    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str
                            || 'mp1.organization_code, '; --to_organization_id
    END IF;

    l_wdth_select_str  := l_wdth_select_str
                          || 'wdth.dest_subinventory_code, ' /*to_subinventory*/
                          || 'wdth.dest_locator_id,  '; /*to_locator_id*/

    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
      --to locator
      l_wdth_select_str  := l_wdth_select_str ||
         'decode(milv1.segment19, null, milv1.concatenated_segments, null), ';
    END IF;

    l_wdth_select_str  := l_wdth_select_str ||
                          'wdth.transaction_uom_code, ' || /*transaction_uom*/
                          ' wdth.transaction_quantity, ' || /*transaction_quantity*/
                          ' wdth.user_task_type, '; /*user_task_type_id*/

    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str
                            || 'bso.operation_code, '; --user_task_type
    END IF;

    l_wdth_select_str  := l_wdth_select_str ||
                          ' to_number(null), ' || /*move_order_line_id*/
                          ' to_number(null), ' || /*pick_slip_number*/
                          ' to_number(null), ';/*cartonization_id*/
     IF g_cartonization_lpn_visible = 'T' THEN
         l_wdth_select_str := l_wdth_select_str || 'null, ';
         --cartonization_lpn
     END IF;
    l_wdth_select_str := l_wdth_select_str || ' to_number(null), ' ; /*allocated_lpn_id*/
    IF wms_plan_tasks_pvt.g_allocated_lpn_visible = 'T' THEN
       l_wdth_select_str  := l_wdth_select_str || 'null, '; --allocated_lpn
    END IF;
    l_wdth_select_str  := l_wdth_select_str || ' to_number(null), ';/*container_item_id*/
     IF g_container_item_visible = 'T' THEN
      l_wdth_select_str := l_wdth_select_str || 'null, '; /*container item */
     end if;

     l_wdth_select_str := l_wdth_select_str || ' wdth.lpn_id, ';/*from_lpn_id*/

     IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
	l_wdth_select_str := l_wdth_select_str
	  || 'wlpn5.license_plate_number, ';/*from_lpn*/
     END IF;

     l_wdth_select_str := l_wdth_select_str || ' wdth.content_lpn_id, ';/*content_lpn_id*/

     IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
	l_wdth_select_str  := l_wdth_select_str
	  || 'wlpn3.license_plate_number, '; --content_lpn
     END IF;

    l_wdth_select_str  := l_wdth_select_str
                          || 'wdth.transfer_lpn_id, '; --to_lpn_id
   IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str
                        || 'wlpn4.license_plate_number, '; --to_lpn
   END IF;

    l_wdth_select_str  := l_wdth_select_str ||
                          ' to_date(null), ' || /*mmt_last_update_date*/
                          ' to_number(null), ' || /*mmt_last_updated_by*/
                          ' wdth.priority, ' || /*priority*/
                          ' wdth.priority, ' || /*priority_original*/
                          ' wdth.task_type, ' || /*task_type_id*/
                          ' decode(wdth.task_type,'
                            || '1, '''
                            || wms_plan_tasks_pvt.g_task_types(1)
                            || ''', 2, '''
                            || wms_plan_tasks_pvt.g_task_types(2)
                            || ''', 3, '''
                            || wms_plan_tasks_pvt.g_task_types(3)
                            || ''', 4, '''
                            || wms_plan_tasks_pvt.g_task_types(4)
                            || ''', 5, '''
                            || wms_plan_tasks_pvt.g_task_types(5)
                            || ''', 6, '''
                            || wms_plan_tasks_pvt.g_task_types(6)
                            || ''', 7, '''
                            || wms_plan_tasks_pvt.g_task_types(7)
                            || ''', 8, '''
                            || wms_plan_tasks_pvt.g_task_types(8)
                            || '''), ' ||
                          ' to_date(null), ' || /*creation_time  */
                          ' wdth.operation_plan_id, '; /*operation_plan_id*/
    IF wms_plan_tasks_pvt.g_operation_plan_visible = 'T' THEN
   l_wdth_select_str := l_wdth_select_str
                     || 'wop.operation_plan_name, ';/*operation_plan*/
   END IF;
   IF wms_plan_tasks_pvt.g_operation_sequence_visible = 'T' THEN
        l_wdth_select_str := l_wdth_select_str || ' to_number(null), ';
    END IF;
   l_wdth_select_str := l_wdth_select_str ||
          ' to_number(wdth.op_plan_instance_id), ' || /*operation_instance_id*/
                          --' to_number(null), '|| /*operation_sequence*/
                          ' wdth.task_id, ' ||/*task_id */
                          ' wdth.person_id, ' || /*person_id*/
                          ' wdth.person_id, '; /*person_id_original*/

    IF wms_plan_tasks_pvt.g_person_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str || 'pap.full_name, '; --person_id
    END IF;
    l_wdth_select_str  := l_wdth_select_str ||
                          ' wdth.effective_start_date, ' || /*effective_start_date*/
                          ' wdth.effective_end_date, ' || /*effective_end_date*/
                          ' wdth.person_resource_id, '; --person_resource_id

    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
      l_wdth_select_str  :=  l_wdth_select_str
                             || 'br1.resource_code, '; --person_resource_code
    END IF;

    l_wdth_select_str  := l_wdth_select_str ||
                          ' wdth.machine_resource_id, '; --machine_resource_id

    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
      l_wdth_select_str  := l_wdth_select_str
                            || 'br2.resource_code, '; --machine_resource_code
    END IF;

    l_wdth_select_str  := l_wdth_select_str ||
                          ' wdth.equipment_instance, ' || /*equipment_instance*/
                          ' wdth.dispatched_time, ' || /*dispatched_time*/
                          ' wdth.loaded_time, ' || /*loaded_time*/
                          ' wdth.drop_off_time, ' || /*drop_off_time*/
                          ' to_date(null), ' || /*wdt_last_update_date*/
                          ' to_number(null), '  || /*wdt_last_updated_by*/
                          '''N'', '||     --is modified
                          'wdth.secondary_transaction_uom_code, '||
                          'wdth.secondary_transaction_quantity ';

     IF wms_plan_tasks_pvt.g_include_inbound THEN
      l_wdth_select_str     := l_wdth_select_str
                                || ', wwtt.reference_id '
                                || ', wwtt.reference ';
     END IF;

    IF wms_plan_tasks_pvt.g_inbound_specific_query THEN
      l_wdth_select_str  := l_wdth_select_str
                             || ', wwtt.source_header '
                             || ', wwtt.line_number ';
    END IF;
    /* Build the from clause of the query */
    l_wdth_from_str  := ' FROM wms_dispatched_tasks_history wdth' ||
                             ', mtl_system_items_kfv msiv ' ||
                             ', mtl_item_locations_kfv milv ';

    IF wms_plan_tasks_pvt.g_item_category_id IS NOT NULL
       OR wms_plan_tasks_pvt.g_category_set_id IS NOT NULL THEN
      l_wdth_from_str  :=  l_wdth_from_str ||
                           ', mtl_item_categories mic ';
    END IF;

    IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
       l_wdth_from_str := l_wdth_from_str
	 || ', wms_license_plate_numbers wlpn5 ';
    END IF;

    IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                    || ', wms_license_plate_numbers wlpn3 ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                    || ', wms_license_plate_numbers wlpn4 ';
    END IF;

    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                        || ', bom_standard_operations bso ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', mtl_parameters mp1 ';
    END IF;

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                          || ', mtl_txn_source_types mtst ';
    END IF;

    l_wdth_from_str  := l_wdth_from_str || ', wms_op_plans_vl wop ';

    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', bom_resources br1 ';
    END IF;

    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', bom_resources br2 ';
    END IF;

    IF wms_plan_tasks_pvt.g_person_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str
                               || ', per_all_people_f pap ';
    END IF;
    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
      l_wdth_from_str  := l_wdth_from_str || ', mtl_item_locations_kfv milv1 ';
    END IF;

    l_wdth_where_str := 'WHERE 1 = 1 ';
    l_wdth_where_str  := l_wdth_where_str
       || 'AND wdth.organization_id = msiv.organization_id '
       || 'AND wdth.inventory_item_id = msiv.inventory_item_id '
       || 'AND wdth.organization_id = milv.organization_id(+) '
       || 'AND wdth.source_locator_id = milv.inventory_location_id(+) ';
    IF wms_plan_tasks_pvt.g_to_organization_code_visible = 'T' THEN
       l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.transfer_organization_id = mp1.organization_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_txn_source_type_visible = 'T' THEN
       l_wdth_where_str  := l_wdth_where_str
	    || 'AND wdth.transaction_source_type_id = mtst.transaction_source_type_id (+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_person_resource_visible = 'T' THEN
       l_wdth_where_str  := l_wdth_where_str
        || 'AND wdth.person_resource_id = br1.resource_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_machine_resource_visible = 'T' THEN
      l_wdth_where_str  := l_wdth_where_str
      || 'AND wdth.machine_resource_id = br2.resource_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_person_visible = 'T' THEN
     l_wdth_where_str  := l_wdth_where_str
               || 'AND wdth.person_id = pap.person_id (+)'
               || 'AND wdth.effective_start_date >= pap.effective_start_date (+) '
               || 'AND wdth.effective_end_date <= pap.effective_end_date (+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_from_lpn_visible = 'T' THEN
       l_wdth_where_str := l_wdth_where_str
	 || 'AND wdth.lpn_id = wlpn5.lpn_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_content_lpn_visible = 'T' THEN
      l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.content_lpn_id = wlpn3.lpn_id(+) ';
     END IF;

    IF wms_plan_tasks_pvt.g_to_lpn_visible = 'T' THEN
       l_wdth_where_str  := l_wdth_where_str
          || 'AND wdth.transfer_lpn_id = wlpn4.lpn_id(+) ';
    END IF;

    IF wms_plan_tasks_pvt.g_user_task_type_visible = 'T' THEN
       l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.user_task_type = bso.standard_operation_id(+) '
         || 'AND wdth.organization_id = bso.organization_id(+) ';
    END IF;

    l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.operation_plan_id = wop.operation_plan_id(+) ';

    IF wms_plan_tasks_pvt.g_organization_id IS NOT NULL THEN
     l_wdth_where_str  := l_wdth_where_str
                  || 'AND wdth.organization_id = :org_id ';
   END IF;

    IF wms_plan_tasks_pvt.g_category_set_id IS NOT NULL THEN
       l_wdth_where_str  := l_wdth_where_str
          || 'AND mic.category_set_id = :category_set_id ';
    END IF;

    IF wms_plan_tasks_pvt.g_item_category_id IS NOT NULL THEN
      l_wdth_where_str  := l_wdth_where_str
                           || 'AND wdth.inventory_item_id = mic.inventory_item_id (+) '
                           || 'AND mic.organization_id = wdth.organization_id '
                           || 'AND mic.category_id = :item_category_id ';
      END IF;

    l_wdth_where_str  := l_wdth_where_str
                         || ' AND wdth.is_parent = ''Y'' '
                         || ' AND wdth.operation_plan_id is not null ';

    IF wms_plan_tasks_pvt.g_inventory_item_id IS NOT NULL THEN
      l_wdth_where_str  := l_wdth_where_str
         || 'AND wdth.inventory_item_id = :item_id ';
    END IF;

    IF wms_plan_tasks_pvt.g_from_task_quantity IS NOT NULL THEN
    l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.transaction_quantity >= :from_task_quantity ';
    END IF;

    IF wms_plan_tasks_pvt.g_to_task_quantity IS NOT NULL THEN
    l_wdth_where_str  := l_wdth_where_str
           || 'AND wdth.transaction_quantity <= :to_task_quantity ';
    END IF;

      IF wms_plan_tasks_pvt.g_from_creation_date IS NOT NULL THEN
         l_wdth_where_str  := l_wdth_where_str
             --|| 'AND wdth.creation_date >= :from_creation_date ';--Commented in bug 6854145
               || 'AND TRUNC(wdth.creation_date) >= TRUNC(:from_creation_date) ';--Added TRUNC in bug 6854145
      END IF;

      IF wms_plan_tasks_pvt.g_to_creation_date IS NOT NULL THEN
        l_wdth_where_str  := l_wdth_where_str
               --|| 'AND wdth.creation_date <= :to_creation_date ';--Commented in bug 6854145
	         || 'AND TRUNC(wdth.creation_date) <= TRUNC(:to_creation_date) ';--Added TRUNC in bug 6854145
     END IF;

    IF wms_plan_tasks_pvt.g_to_locator_visible = 'T' THEN
      l_wdth_where_str  := l_wdth_where_str
      || 'and wdth.dest_locator_id = milv1.inventory_location_id (+) '
      || 'AND wdth.dest_subinventory_code = milv1.subinventory_code (+) ';
    END IF;
    /* Filter based on the status - completed/cancelled/aborted. */
    l_wdth_where_str := l_wdth_where_str || 'AND wdth.status in (';
    IF wms_plan_tasks_pvt.g_is_completed_plan THEN
       l_wdth_where_str := l_wdth_where_str || '6';
       IF wms_plan_tasks_pvt.g_is_cancelled_plan THEN
          l_wdth_where_str := l_wdth_where_str || ',12';
       END IF;
       IF wms_plan_tasks_pvt.g_is_aborted_plan THEN
          l_wdth_where_str := l_wdth_where_str || ',11';
       END IF;
    ELSIF wms_plan_tasks_pvt.g_is_cancelled_plan THEN
          l_wdth_where_str := l_wdth_where_str || '12';
          IF wms_plan_tasks_pvt.g_is_aborted_plan THEN
          l_wdth_where_str := l_wdth_where_str || ',11';
       END IF;
    ELSIF wms_plan_tasks_pvt.g_is_aborted_plan THEN
          l_wdth_where_str := l_wdth_where_str || '11';
    END IF;

    l_wdth_where_str := l_wdth_where_str || ')';

    IF l_debug = 1 THEN
      debug(' l_wdth_select_str ' || l_wdth_select_str,'get_wdth_plan_records');
      debug(' l_wdth_from_str ' || l_wdth_from_str,'get_wdth_plan_records');
      debug(' l_wdth_where_str ' || l_wdth_where_str,'get_wdth_plan_records');
    END IF;

    x_wdth_select_str := l_wdth_select_str;
    x_wdth_from_str   := l_wdth_from_str;
    x_wdth_where_str  := l_wdth_where_str;

 END get_wdth_plan_records;

 PROCEDURE clear_globals IS

   l_module_name CONSTANT VARCHAR2(20) := 'clear_globals';
   l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
 BEGIN
   IF l_debug = 1 THEN
     debug(' in clear_globals ',l_module_name);
   END IF;
   --wms_plan_tasks_pvt.g_add                     :=               FALSE;
   wms_plan_tasks_pvt.g_organization_id         :=               NULL;
   wms_plan_tasks_pvt.g_subinventory_code       :=               NULL;
   wms_plan_tasks_pvt.g_locator_id              :=               NULL;
   wms_plan_tasks_pvt.g_to_subinventory_code    :=               NULL;
   wms_plan_tasks_pvt.g_to_locator_id           :=               NULL;
   wms_plan_tasks_pvt.g_inventory_item_id       :=               NULL;
   wms_plan_tasks_pvt.g_category_set_id         :=               NULL;
   wms_plan_tasks_pvt.g_item_category_id        :=               NULL;
   wms_plan_tasks_pvt.g_person_id               :=               NULL;
   wms_plan_tasks_pvt.g_person_resource_id      :=               NULL;
   wms_plan_tasks_pvt.g_equipment_type_id       :=               NULL;
   wms_plan_tasks_pvt.g_machine_resource_id     :=               NULL;
   wms_plan_tasks_pvt.g_machine_instance        :=               NULL;
   wms_plan_tasks_pvt.g_user_task_type_id       :=               NULL;
   wms_plan_tasks_pvt.g_from_task_quantity      :=               NULL;
   wms_plan_tasks_pvt.g_to_task_quantity        :=               NULL;
   wms_plan_tasks_pvt.g_from_task_priority      :=               NULL;
   wms_plan_tasks_pvt.g_to_task_priority        :=               NULL;
   wms_plan_tasks_pvt.g_from_creation_date      :=               NULL;
   wms_plan_tasks_pvt.g_to_creation_date        :=               NULL;

   wms_plan_tasks_pvt.g_is_unreleased_task           :=               FALSE;
   wms_plan_tasks_pvt.g_is_pending_task              :=               FALSE;
   wms_plan_tasks_pvt.g_is_queued_task               :=               FALSE;
   wms_plan_tasks_pvt.g_is_dispatched_task           :=               FALSE;
   wms_plan_tasks_pvt.g_is_active_task               :=               FALSE;
   wms_plan_tasks_pvt.g_is_loaded_task               :=               FALSE;
   wms_plan_tasks_pvt.g_is_completed_task            :=               FALSE ;

   wms_plan_tasks_pvt.g_include_inbound         :=               FALSE;
   wms_plan_tasks_pvt.g_include_outbound        :=               FALSE;
   wms_plan_tasks_pvt.g_include_manufacturing   :=               FALSE;
   wms_plan_tasks_pvt.g_include_warehousing     :=               FALSE;
   wms_plan_tasks_pvt.g_from_po_header_id       :=               NULL;
   wms_plan_tasks_pvt.g_to_po_header_id         :=               NULL;
   wms_plan_tasks_pvt.g_from_purchase_order     :=               NULL;
   wms_plan_tasks_pvt.g_to_purchase_order       :=               NULL;
   wms_plan_tasks_pvt.g_from_rma_header_id      :=               NULL;
   wms_plan_tasks_pvt.g_to_rma_header_id        :=               NULL;
   wms_plan_tasks_pvt.g_from_rma                :=               NULL;
   wms_plan_tasks_pvt.g_to_rma                  :=               NULL;
   wms_plan_tasks_pvt.g_from_requisition_header_id :=            NULL;
   wms_plan_tasks_pvt.g_to_requisition_header_id:=               NULL;
   wms_plan_tasks_pvt.g_from_requisition        :=               NULL;
   wms_plan_tasks_pvt.g_to_requisition           :=              NULL;
   wms_plan_tasks_pvt.g_from_shipment_number     :=              NULL;
   wms_plan_tasks_pvt.g_to_shipment_number       :=              NULL;
   wms_plan_tasks_pvt.g_include_sales_orders     :=              TRUE;
   wms_plan_tasks_pvt.g_include_internal_orders  :=              TRUE;
   wms_plan_tasks_pvt.g_from_sales_order_id      :=              NULL;
   wms_plan_tasks_pvt.g_to_sales_order_id        :=              NULL;
   wms_plan_tasks_pvt.g_from_pick_slip_number    :=              NULL;
   wms_plan_tasks_pvt.g_to_pick_slip_number      :=              NULL;
   wms_plan_tasks_pvt.g_customer_id              :=              NULL;
   wms_plan_tasks_pvt.g_customer_category        :=              NULL;
   wms_plan_tasks_pvt.g_delivery_id              :=              NULL;
   wms_plan_tasks_pvt.g_carrier_id               :=              NULL;
   wms_plan_tasks_pvt.g_ship_method              :=              NULL;
   wms_plan_tasks_pvt.g_shipment_priority        :=              NULL;
   wms_plan_tasks_pvt.g_trip_id                  :=              NULL;
   wms_plan_tasks_pvt.g_from_shipment_date       :=              NULL;
   wms_plan_tasks_pvt.g_to_shipment_date         :=              NULL;
   wms_plan_tasks_pvt.g_ship_to_state            :=              NULL;
   wms_plan_tasks_pvt.g_ship_to_country          :=              NULL;
   wms_plan_tasks_pvt.g_ship_to_postal_code      :=              NULL;
   wms_plan_tasks_pvt.g_from_number_of_order_lines :=            NULL;
   wms_plan_tasks_pvt.g_to_number_of_order_lines   :=            NULL;
   wms_plan_tasks_pvt.g_manufacturing_type         :=            NULL;
   wms_plan_tasks_pvt.g_from_job                   :=            NULL;
   wms_plan_tasks_pvt.g_to_job                     :=            NULL;
   wms_plan_tasks_pvt.g_assembly_id                :=            NULL;
   wms_plan_tasks_pvt.g_from_start_date            :=            NULL;
   wms_plan_tasks_pvt.g_to_start_date              :=            NULL;
   wms_plan_tasks_pvt.g_from_line                  :=            NULL;
   wms_plan_tasks_pvt.g_to_line                    :=            NULL;
   wms_plan_tasks_pvt.g_department_id              :=            NULL;
   wms_plan_tasks_pvt.g_include_replenishment      :=            TRUE;
   wms_plan_tasks_pvt.g_from_replenishment_mo      :=            NULL;
   wms_plan_tasks_pvt.g_to_replenishment_mo        :=            NULL;
   wms_plan_tasks_pvt.g_include_mo_transfer        :=            TRUE;
   wms_plan_tasks_pvt.g_include_mo_issue           :=            TRUE;
   wms_plan_tasks_pvt.g_from_transfer_issue_mo     :=            NULL;
   wms_plan_tasks_pvt.g_to_transfer_issue_mo       :=            NULL;
   wms_plan_tasks_pvt.g_include_lpn_putaway        :=            TRUE;
   wms_plan_tasks_pvt.g_include_staging_move       :=            FALSE;
   wms_plan_tasks_pvt.g_include_cycle_count        :=            TRUE;
   wms_plan_tasks_pvt.g_cycle_count_name           :=            NULL;

   wms_plan_tasks_pvt.g_query_independent_tasks := NULL;
   wms_plan_tasks_pvt.g_query_planned_tasks := FALSE;

   wms_plan_tasks_pvt.g_is_pending_plan    := FALSE;
   wms_plan_tasks_pvt.g_is_inprogress_plan := FALSE;
   wms_plan_tasks_pvt.g_is_completed_plan  := FALSE;
   wms_plan_tasks_pvt.g_is_cancelled_plan   := FALSE;
   wms_plan_tasks_pvt.g_is_aborted_plan    := FALSE;

   wms_plan_tasks_pvt.g_activity_id    := NULL;
   wms_plan_tasks_pvt.g_plan_type_id    := NULL;
   wms_plan_tasks_pvt.g_op_plan_id    := NULL;

   wms_plan_tasks_pvt.g_inbound_specific_query := FALSE;
   wms_plan_tasks_pvt.g_outbound_specific_query := FALSE;
   wms_plan_tasks_pvt.g_plans_tasks_record_count := 0;
   wms_plan_tasks_pvt.g_from_inbound := FALSE;


 END clear_globals;

END;

/
