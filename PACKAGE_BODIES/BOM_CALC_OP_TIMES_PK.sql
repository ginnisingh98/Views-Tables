--------------------------------------------------------
--  DDL for Package Body BOM_CALC_OP_TIMES_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CALC_OP_TIMES_PK" AS
/* $Header: BOMOPTMB.pls 120.1 2006/05/03 06:05:21 abbhardw noship $ */

/******************calculate_operation_times***********************************/

PROCEDURE calculate_operation_times (
			arg_org_id IN NUMBER,
			arg_routing_sequence_id IN NUMBER)  IS

CURSOR Events_cur IS
	SELECT  operation_sequence_id
	FROM   bom_operation_sequences
	WHERE  routing_sequence_id = arg_routing_sequence_id
	AND    operation_type = 1
        AND    NVL(eco_for_production,2) = 2
	AND    NVL(disable_date, TRUNC(sysdate)+1) > TRUNC(sysdate);

CURSOR Processes_cur IS
	SELECT  operation_sequence_id
	FROM   bom_operation_sequences
	WHERE  routing_sequence_id = arg_routing_sequence_id
        AND    NVL(eco_for_production,2) = 2
	AND    operation_type = 2;

CURSOR Line_ops_cur IS
	SELECT  operation_sequence_id
	FROM   bom_operation_sequences
	WHERE  routing_sequence_id = arg_routing_sequence_id
        AND    NVL(eco_for_production,2) = 2
	AND    operation_type = 3;

CURSOR All_Events_cur(v_seq_id NUMBER) IS
	SELECT operation_sequence_id, operation_seq_num
                FROM  bom_operation_sequences
                WHERE operation_type = 1
                  AND (line_op_seq_id = v_seq_id OR process_op_seq_id = v_seq_id)
                  AND routing_sequence_id = arg_routing_sequence_id
		  AND effectivity_date <= sysdate
        	  AND NVL(eco_for_production,2) = 2
		  AND nvl(disable_date, sysdate + 1) > sysdate;

CURSOR opt_class_comps_cur(v_bill_seq_id NUMBER) IS
	SELECT component_item_id, planning_factor
	FROM bom_inventory_components bic, bom_bill_of_materials bom
	WHERE bom.bill_sequence_id = v_bill_seq_id
	  AND bom.common_bill_sequence_id = bic.bill_sequence_id
          AND NVL(bic.eco_for_production,2) = 2
	  AND bic.bom_item_type = 2;

event_seq_id 		NUMBER;
process_seq_id  	NUMBER;
lineop_seq_id 		NUMBER;
var_machine_time 	NUMBER;
var_labor_time 		NUMBER;
var_elapsed_time 	NUMBER;
hour_conv 		NUMBER;
lot_qty     		NUMBER;
hour_uom    		VARCHAR2(3);

x_bom_id		NUMBER;
x_alt_bom_desg		VARCHAR2(10);
avg_machine_time 	NUMBER;
avg_labor_time 		NUMBER;
avg_elapsed_time 	NUMBER;
v_machine_time 		NUMBER;
v_labor_time 		NUMBER;
v_elapsed_time 		NUMBER;
v_planning_factor	NUMBER;
opt_bill_id		NUMBER;
assoc_flag		NUMBER;

BEGIN

	SELECT NVL(items.lead_time_lot_size, NVL(items.std_lot_size,1))
	INTO   lot_qty
	FROM   mtl_system_items items,
		   bom_operational_routings bor
	WHERE  items.organization_id = bor.organization_id
	AND    items.inventory_item_id = bor.assembly_item_id
	AND    bor.routing_sequence_id = arg_routing_sequence_id;

	hour_uom := FND_PROFILE.VALUE('BOM:HOUR_UOM_CODE');

	SELECT conversion_rate
	INTO   hour_conv
	FROM   mtl_uom_conversions
	WHERE  uom_code = hour_uom
	AND    inventory_item_id = 0;

	OPEN Events_cur;
	LOOP
		FETCH events_cur
		INTO	event_seq_id;

        EXIT WHEN events_cur%NOTFOUND;

	BEGIN
		SELECT SUM(NVL(((bor.usage_rate_or_amount)*
				DECODE(con.conversion_rate, '', 0,'0', 0,
					con.conversion_rate)/
					DECODE(NVL(br.default_basis_type, 1) , 2, lot_qty,
					1, 1)), 0))/NVL(hour_conv, 1)
		INTO    var_machine_time
		FROM    bom_operation_sequences bos,
				bom_operation_resources bor,
				bom_department_resources bdr2,
				bom_department_resources bdr1,
				bom_resources br,
				mtl_uom_conversions con
		-- WHERE  	bor.schedule_flag <> 2
		WHERE  	bor.resource_id = br.resource_id
		AND    	br.resource_type = 1
		AND     NVL(br.disable_date, trunc(sysdate) + 1)
							> trunc(sysdate)
		AND 	bos.operation_sequence_id = event_seq_id
        AND 	bos.operation_sequence_id = bor.operation_sequence_id
        AND 	bos.department_id = bdr1.department_id
        AND 	bor.resource_id = bdr1.resource_id
        AND 	NVL(bdr1.share_from_dept_id, bdr1.department_id)
					= bdr2.department_id
        AND 	bor.resource_id = bdr2.resource_id
        AND 	bor.resource_id = br.resource_id
		AND     con.uom_code (+) = br.unit_of_measure
		AND     con.inventory_item_id (+) = 0;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		null;
        END;


	BEGIN
		SELECT SUM(NVL(((bor.usage_rate_or_amount)*
				DECODE(con.conversion_rate, '', 0,'0', 0,
					con.conversion_rate)/
					DECODE(NVL(br.default_basis_type, 1), 2, lot_qty,
					1, 1)), 0))/NVL(hour_conv, 1)
		INTO   var_labor_time
		FROM   bom_operation_sequences bos,
			   bom_operation_resources bor,
			   bom_department_resources bdr2,
	           bom_department_resources bdr1,
			   bom_resources br,
			   mtl_uom_conversions con
		-- WHERE  bor.schedule_flag <> 2
		WHERE  bor.resource_id = br.resource_id
		AND    br.resource_type = 2
		AND     NVL(br.disable_date, trunc(sysdate) + 1)
							> trunc(sysdate)
		AND    bos.operation_sequence_id = event_seq_id
		AND    bos.operation_sequence_id = bor.operation_sequence_id
		AND    bos.department_id = bdr1.department_id
		AND    bor.resource_id = bdr1.resource_id
		AND    NVL(bdr1.share_from_dept_id, bdr1.department_id)
					= bdr2.department_id
		AND    bor.resource_id = bdr2.resource_id
		AND    bor.resource_id = br.resource_id
		AND    con.uom_code (+) = br.unit_of_measure
		AND    con.inventory_item_id (+) = 0;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		null;
	END;

    BEGIN
        SELECT SUM(NVL(((bor.usage_rate_or_amount)*
                DECODE(con.conversion_rate, '', 0,'0', 0,
                    con.conversion_rate)/
                    DECODE(NVL(br.default_basis_type, 1), 2, lot_qty,
                    1, 1)), 0))/NVL(hour_conv, 1)
        INTO   var_elapsed_time
        FROM   bom_operation_sequences bos,
               bom_operation_resources bor,
               bom_department_resources bdr2,
               bom_department_resources bdr1,
               bom_resources br,
               mtl_uom_conversions con
        WHERE  bor.schedule_flag <> 2
        AND    bor.resource_id = br.resource_id
        AND    br.resource_type IN (1, 2)
        AND     NVL(br.disable_date, trunc(sysdate) + 1)
                            > trunc(sysdate)
        AND    bos.operation_sequence_id = event_seq_id
        AND    bos.operation_sequence_id = bor.operation_sequence_id
        AND    bos.department_id = bdr1.department_id
        AND    bor.resource_id = bdr1.resource_id
        AND    NVL(bdr1.share_from_dept_id, bdr1.department_id)
                    = bdr2.department_id
        AND    bor.resource_id = bdr2.resource_id
        AND    bor.resource_id = br.resource_id
        AND    con.uom_code (+) = br.unit_of_measure
        AND    con.inventory_item_id (+) = 0;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        null;
    END;


		UPDATE 	bom_operation_sequences
		SET		machine_time_calc = NVL(var_machine_time, 0),
				labor_time_calc   = NVL(var_labor_time, 0),
				total_time_calc   = NVL(var_elapsed_time, 0)
		WHERE   operation_sequence_id = event_seq_id;
		--COMMIT;
	END LOOP;

-------------------------------------------------------------------------------------------
	   -- get the BOM to see if there are any option class comps.
	   BEGIN
	     select bill_sequence_id, alternate_bom_designator
	     into x_bom_id, x_alt_bom_desg
	     from bom_bill_of_materials bom, bom_operational_routings bor
	     where routing_sequence_id = arg_routing_sequence_id
	       and bor.assembly_item_id = bom.assembly_item_id
	       and bor.organization_id = bom.organization_id
	       and nvl(bor.alternate_routing_designator, 'NONE')
		   = nvl(bom.alternate_bom_designator, 'NONE');
	   EXCEPTION WHEN NO_DATA_FOUND THEN
		   x_bom_id := -1;
	   END;

	OPEN Processes_cur;
	LOOP
	   FETCH Processes_cur
	   INTO	process_seq_id;

	   EXIT WHEN Processes_cur%NOTFOUND;

           BEGIN
           SELECT SUM(NVL(machine_time_calc, 0)), SUM(NVL(labor_time_calc, 0)),
                           SUM(NVL(total_time_calc, 0))
           INTO   var_machine_time, var_labor_time, var_elapsed_time
           FROM   bom_operation_sequences
           WHERE  operation_type = 1
           AND    process_op_seq_id = process_seq_id
           AND    nvl(disable_date, sysdate + 1) > sysdate  -- BUG #2836627
           AND    routing_sequence_id = arg_routing_sequence_id;
           EXCEPTION WHEN NO_DATA_FOUND THEN
                   NULL;
           END;

           BEGIN
              avg_machine_time := 0;
              avg_labor_time := 0;
              avg_elapsed_time := 0;

              --open cursor for every event assoc with the process
              FOR All_Events_cur_rec IN All_Events_cur(process_seq_id) LOOP

                SELECT machine_time_calc, labor_time_calc, total_time_calc
                  INTO   v_machine_time, v_labor_time, v_elapsed_time
                  FROM   bom_operation_sequences
                  WHERE  operation_sequence_id = All_Events_cur_rec.operation_sequence_id;

                -- chk to see if process is associated with a non-OC component
                -- if it is then, skip the chk OC loop
                assoc_flag := 1;
                BEGIN
                SELECT NVL(planning_factor, 100)
                INTO v_planning_factor
                FROM bom_inventory_components
                WHERE bill_sequence_id = x_bom_id
                  AND operation_seq_num = All_Events_cur_rec.operation_seq_num
          	  AND NVL(eco_for_production,2) = 2
                  AND effectivity_date <= sysdate
                  AND nvl(disable_date, sysdate + 1) > sysdate
                  AND rownum = 1;
                EXCEPTION  WHEN NO_DATA_FOUND THEN
-- If there are no rows in the main table then, it means that there are rows
-- in the bom_component_operations table(1-many enhancement).
-- So we go there to get the component for the current operation and then
-- the planning factor for that component.
                  begin
                    SELECT NVL(bic.planning_factor, 100)
                    INTO v_planning_factor
                    FROM bom_inventory_components bic,
                         bom_component_operations bco
                    WHERE
                         bco.bill_sequence_id = x_bom_id
                     AND bco.operation_sequence_id =
                         All_Events_cur_rec.operation_sequence_id
                     AND bco.operation_seq_num =
                         All_Events_cur_rec.operation_seq_num
                     AND bco.component_sequence_id = bic.component_sequence_id
                     AND bic.bill_sequence_id = x_bom_id
                     AND NVL(bic.eco_for_production,2) = 2
                     AND bic.effectivity_date <= sysdate
                     AND nvl(bic.disable_date, sysdate + 1) > sysdate
                     AND rownum = 1;
                    EXCEPTION  WHEN NO_DATA_FOUND THEN
                      assoc_flag := 0;
                      v_planning_factor := 100;
                  end;
                END;

                IF assoc_flag = 0 THEN
                -- for every option class component in the BOM need to get to the OC bill
                -- and search for the operation there

                  FOR opt_class_comps_rec IN opt_class_comps_cur(x_bom_id) LOOP
		    BEGIN
                     SELECT bill_sequence_id
                       INTO opt_bill_id
                       FROM bom_bill_of_materials bom
                       WHERE bom.assembly_item_id = opt_class_comps_rec.component_item_id
                        AND bom.organization_id = arg_org_id
                        AND NVL(bom.alternate_bom_designator, 'NONE')
                                 = NVL(x_alt_bom_desg, 'NONE');

                     SELECT (NVL(planning_factor, 100)
		       * NVL(opt_class_comps_rec.planning_factor, 100))/100
                       INTO v_planning_factor
                       FROM bom_bill_of_materials bom, bom_inventory_components bic
                     WHERE bom.common_bill_sequence_id = opt_bill_id
                       AND bom.common_bill_sequence_id = bic.bill_sequence_id
                       AND bic.operation_seq_num = All_Events_cur_rec.operation_seq_num
          	       AND NVL(bic.eco_for_production,2) = 2
                       AND rownum = 1;
                     EXCEPTION  WHEN NO_DATA_FOUND THEN
-- 1-many enhancement for the options class as well!
                       begin
                         SELECT (NVL(planning_factor, 100)
		         * NVL(opt_class_comps_rec.planning_factor, 100))/100
                         INTO v_planning_factor
                         FROM bom_bill_of_materials bom,
                              bom_inventory_components bic,
                              bom_component_operations bco
                         --WHERE bom.common_bill_sequence_id = opt_bill_id	-- BUG 5199596
                         WHERE bom.bill_sequence_id = opt_bill_id
                         AND bom.common_bill_sequence_id = bco.bill_sequence_id
                         AND bco.operation_sequence_id =
                             All_Events_cur_rec.operation_sequence_id
                         AND bco.operation_seq_num =
                             All_Events_cur_rec.operation_seq_num
                         AND bco.component_sequence_id = bic.component_sequence_id
                         AND bom.common_bill_sequence_id = bic.bill_sequence_id
          	         AND NVL(bic.eco_for_production,2) = 2
                         AND rownum = 1;
                         EXCEPTION  WHEN NO_DATA_FOUND THEN
                           null;
                        END;
                    END;

                   END LOOP;
                end if;
                 -- calculate the operations times
                 avg_machine_time := avg_machine_time
                                        + (v_machine_time * v_planning_factor/100);
                 avg_labor_time := avg_labor_time
                                        + (v_labor_time * v_planning_factor/100);
                 avg_elapsed_time := avg_elapsed_time
                                        + (v_elapsed_time * v_planning_factor/100);
               END LOOP;

           EXCEPTION WHEN NO_DATA_FOUND THEN
                   NULL;
           END;

           IF (avg_machine_time <> 0
                   OR avg_labor_time <> 0 OR avg_elapsed_time <> 0) THEN
                   var_machine_time := avg_machine_time;
                   var_labor_time   := avg_labor_time;
                   var_elapsed_time := avg_elapsed_time;
           END IF;

	   UPDATE bom_operation_sequences
	   SET    machine_time_calc = NVL(var_machine_time, 0),
		   labor_time_calc = NVL(var_labor_time, 0),
		   total_time_calc = NVL(var_elapsed_time, 0)
	   WHERE  operation_sequence_id = process_seq_id;

	   --COMMIT;
	END LOOP;

-------------------------------------------------------------------------------------------

	OPEN Line_ops_cur;
	LOOP
	   FETCH Line_ops_cur
	   INTO	lineop_seq_id;

	   EXIT WHEN Line_ops_cur%NOTFOUND;

           BEGIN
           SELECT SUM(NVL(machine_time_calc, 0)), SUM(NVL(labor_time_calc, 0)),
                           SUM(NVL(total_time_calc, 0))
           INTO   var_machine_time, var_labor_time, var_elapsed_time
           FROM   bom_operation_sequences
           WHERE  operation_type = 1
           AND    line_op_seq_id = lineop_seq_id
           AND    nvl(disable_date, sysdate + 1) > sysdate  -- BUG #2836627
           AND    routing_sequence_id = arg_routing_sequence_id;
           EXCEPTION WHEN NO_DATA_FOUND THEN
                   NULL;
           END;


	   BEGIN
	      avg_machine_time := 0;
	      avg_labor_time := 0;
	      avg_elapsed_time := 0;

  	      --open cursor for every event assoc with the line-op
	      FOR All_Events_cur_rec IN All_Events_cur(lineop_seq_id) LOOP

	        SELECT machine_time_calc, labor_time_calc, total_time_calc
                  INTO   v_machine_time, v_labor_time, v_elapsed_time
                  FROM   bom_operation_sequences
                  WHERE  operation_sequence_id = All_Events_cur_rec.operation_sequence_id;

		-- chk to see if event is associated with a non-OC component
		-- (or maybe not associated at all)
		-- if it is then, skip the chk OC loop
		assoc_flag := 1;
		BEGIN
		SELECT nvl(planning_factor, 100)
		INTO v_planning_factor
		FROM bom_inventory_components
		WHERE bill_sequence_id = x_bom_id
		  AND operation_seq_num = All_Events_cur_rec.operation_seq_num
		  AND effectivity_date <= sysdate
		  AND nvl(disable_date, sysdate + 1) > sysdate
          	  AND NVL(eco_for_production,2) = 2
                  AND rownum = 1;
		EXCEPTION  WHEN NO_DATA_FOUND THEN
-- 1-many enhancement as for the process
                  begin
                    SELECT NVL(bic.planning_factor, 100)
                    INTO v_planning_factor
                    FROM bom_inventory_components bic,
                         bom_component_operations bco
                    WHERE
                         bco.bill_sequence_id = x_bom_id
                     AND bco.operation_sequence_id =
                         All_Events_cur_rec.operation_sequence_id
                     AND bco.operation_seq_num =
                         All_Events_cur_rec.operation_seq_num
                     AND bco.component_sequence_id = bic.component_sequence_id
                     AND bic.bill_sequence_id = x_bom_id
                     AND NVL(bic.eco_for_production,2) = 2
                     AND bic.effectivity_date <= sysdate
                     AND nvl(bic.disable_date, sysdate + 1) > sysdate
                     AND rownum = 1;
                    EXCEPTION  WHEN NO_DATA_FOUND THEN
                      assoc_flag := 0;
                      v_planning_factor := 100;
                  end;
		END;

		IF assoc_flag = 0  THEN
		-- for every option class component in the BOM need to get to the OC bill
		-- and search for the operation there

		  FOR opt_class_comps_rec IN opt_class_comps_cur(x_bom_id) LOOP
		    BEGIN
		     SELECT bill_sequence_id
		       INTO opt_bill_id
		       FROM bom_bill_of_materials bom
		       WHERE bom.assembly_item_id = opt_class_comps_rec.component_item_id
			AND bom.organization_id = arg_org_id
			AND NVL(bom.alternate_bom_designator, 'NONE')
				 = NVL(x_alt_bom_desg, 'NONE');

	 	     SELECT (nvl(planning_factor, 100)
				* nvl(opt_class_comps_rec.planning_factor, 100))/100
		       INTO v_planning_factor
		       FROM bom_bill_of_materials bom, bom_inventory_components bic
		     WHERE bom.common_bill_sequence_id = opt_bill_id
		       AND bom.common_bill_sequence_id = bic.bill_sequence_id
		       AND bic.operation_seq_num = All_Events_cur_rec.operation_seq_num
          	       AND NVL(bic.eco_for_production,2) = 2
		       AND rownum = 1;

		     EXCEPTION  WHEN NO_DATA_FOUND THEN
-- 1-many enhancement as for the process option class
                       begin
                         SELECT (NVL(planning_factor, 100)
		         * NVL(opt_class_comps_rec.planning_factor, 100))/100
                         INTO v_planning_factor
                         FROM bom_bill_of_materials bom,
                              bom_inventory_components bic,
                              bom_component_operations bco
                         --WHERE bom.common_bill_sequence_id = opt_bill_id	-- BUG 5199596
                         WHERE bom.bill_sequence_id = opt_bill_id
                         AND bom.common_bill_sequence_id = bco.bill_sequence_id
                         AND bco.operation_sequence_id =
                             All_Events_cur_rec.operation_sequence_id
                         AND bco.operation_seq_num =
                             All_Events_cur_rec.operation_seq_num
                         AND bco.component_sequence_id = bic.component_sequence_id
                         AND bom.common_bill_sequence_id = bic.bill_sequence_id
          	         AND NVL(bic.eco_for_production,2) = 2
                         AND rownum = 1;
                         EXCEPTION  WHEN NO_DATA_FOUND THEN
                           null;
                        END;
		    END;
		   END LOOP;
		END IF;
		 -- calculate the operations times
		 avg_machine_time := avg_machine_time
					+ (v_machine_time * v_planning_factor/100);
		 avg_labor_time := avg_labor_time
	 				+ (v_labor_time * v_planning_factor/100);
		 avg_elapsed_time := avg_elapsed_time
	 				+ (v_elapsed_time * v_planning_factor/100);
	       END LOOP;

              EXCEPTION WHEN NO_DATA_FOUND THEN
			NULL;
           END;
		IF (avg_machine_time <> 0
			OR avg_labor_time <> 0 OR avg_elapsed_time <> 0) THEN
			var_machine_time := avg_machine_time;
			var_labor_time   := avg_labor_time;
			var_elapsed_time := avg_elapsed_time;
		END IF;

		UPDATE bom_operation_sequences
		SET    	machine_time_calc = NVL(var_machine_time, 0),
		   	labor_time_calc   = NVL(var_labor_time, 0),
			total_time_calc   = NVL(var_elapsed_time, 0)
		WHERE operation_sequence_id = lineop_seq_id;

		--COMMIT;
	END LOOP;
END;

END BOM_CALC_OP_TIMES_PK;

/
