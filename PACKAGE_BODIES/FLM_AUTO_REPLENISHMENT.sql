--------------------------------------------------------
--  DDL for Package Body FLM_AUTO_REPLENISHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_AUTO_REPLENISHMENT" AS
/* $Header: FLMCPARB.pls 120.2.12010000.4 2009/06/05 14:15:00 adasa ship $ */

/************************************************************************
 *	Package variables                                               *
 ************************************************************************/
G_DEBUG         BOOLEAN := (FND_PROFILE.VALUE('MRP_DEBUG') = 'Y');

/************************************************************************
 *	Private Procedures and Functions                             	*
 ************************************************************************/

/************************************************************************
 * PROCEDURE log							*
 * 	Inserts error msg into log file.				*
 *	                                                                *
 ************************************************************************/
PROCEDURE log(info	VARCHAR2) is
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, info);
END;


/************************************************************************
 * PROCEDURE Show_Exception_Messagees					*
 * 	This procedure gets Exception Messages from the message stack   *
 *	and prints it into the log file.				*
 *	                                                                *
 ************************************************************************/
PROCEDURE Show_Exception_Messages(
		p_msg_count		IN	NUMBER,
		p_msg_data		IN	VARCHAR2,
		p_schedule_number	IN	NUMBER,
		p_comp_id		IN	NUMBER,
		p_organization_id	IN	NUMBER,
		p_error_position	IN	VARCHAR2) IS

  l_comp_name	VARCHAR2(600);

BEGIN

  SELECT concatenated_segments
    INTO l_comp_name
    FROM mtl_system_items_kfv
   WHERE inventory_item_id = p_comp_id
     AND organization_id = p_organization_id;

  IF (p_error_position = G_Error_Create_Cards) THEN
    fnd_message.set_name('FLM', 'FLM_AR_ERR_CREATE_CARDS');
  ELSIF (p_error_position = G_Error_Replenish_Cards) THEN
    fnd_message.set_name('FLM', 'FLM_AR_ERR_REPLENISH_CARDS');
  END IF;

  fnd_message.set_token('COMPONENT', l_comp_name);
  fnd_message.set_token('SCHEDULE', p_schedule_number);
  log(fnd_message.get);

  IF (p_msg_count >= 1) THEN
    FOR l_count IN 1..p_msg_count LOOP
      log(FND_MSG_PUB.Get(l_count, 'F'));
    END LOOP;
  END IF;


END Show_Exception_Messages;

/************************************************************************
 * FUNCTION Is_Valid_Seq						*
 * 	Returns true if the particular Line Operation sequence is a     *
 *      Valid Line Operation.                                           *
 *	A Line Operation Sequence is a Valid Line Operation :           *
 *      a) If the LOP is present in the From_Op_Seq_id and is not part  *
 *         of a pure rework loop or                                     *
 *      b) If the LOP is present in the To_Op_Seq_id or this LOP is     *
 *         the only operation for this routing (i.e. no network exists  *
 *         for this routing).                                           *
 *                                                                      *
 ************************************************************************/
FUNCTION Is_Valid_Seq (p_op_seq_id IN NUMBER) RETURN BOOLEAN IS
  l_cnt NUMBER;

BEGIN

  IF (p_op_seq_id is null) then
    return false;
  END IF;

  /*---------------------------------------------------------------------+
   | Look at the from_op_seq_id to find out if the line-op               |
   | has a primary path originating from it.                             |
   +---------------------------------------------------------------------*/
  SELECT count(*)
    INTO l_cnt
    FROM bom_operation_networks
   WHERE from_op_seq_id = p_op_seq_id
     AND nvl(transition_type, 3) = 1;

  IF (l_cnt = 0) THEN

    /*---------------------------------------------------------------------+
     | Look at the to_op_seq_id to find out if the line-op                 |
     | is in primary path. This is the exception for the                   |
     | last line-op                                                        |
     +---------------------------------------------------------------------*/
    SELECT count(*)
      INTO l_cnt
      FROM bom_operation_networks
     WHERE to_op_seq_id = p_op_seq_id
       AND nvl(transition_type, 3) = 1;

    IF (l_cnt = 0) THEN
      /*---------------------------------------------------------------------+
       | If no network exists, then if only one line operation exists        |
       | for this routing, it's valid, otherwise it's not valid.             |
       +---------------------------------------------------------------------*/
      SELECT count(*)
        INTO l_cnt
        FROM bom_operation_sequences
       WHERE operation_type = 3
         AND routing_sequence_id = (
              SELECT max(routing_sequence_id)
                FROM bom_operation_sequences
               WHERE operation_sequence_id = p_op_seq_id
            );

      IF (l_cnt = 1) THEN
        return true;
      END IF;

      return false;
    END IF; -- end of (l_cnt = 0)

  END IF; -- end of (l_cnt = 0)

  return true;

END is_valid_seq;


/************************************************************************
 * FUNCTION get_valid_pull_sequence					*
 *      Returns the pull sequence id of the given Item if the pull      *
 *      sequence is a valid pull sequence else it returns -1.           *
 *      An item's pull sequence is valid if it satisfies following      *
 *      conditions :                                                    *
 *      a) The POU in the Pull Sequence match with those in BOM         *
 *         Inventory Components or if POU is not specified in BOM, then *
 *	   POU in Pull Sequence match with those specified in the Item  *
 *	   Master (where POU comprises of a subinventory name and the   *
 *	   the locator present).					*
 *      b) The Pull Sequence has Auto_Request flag set to 'Y'.          *
 *      c) Pull Sequence is not a Planning Only Pull sequence i.e.      *
 *         release_kanban_flag is set to 1.                             *
 *      d) The item has Supply type as Pull in Bom Inventory Components *
 *	e) The Item has Release Time Fence set to "Kanban Item (Do not  *
 *	   Release)" in the Organization Items.				*
 *                                                                      *
 ************************************************************************/
FUNCTION Get_Valid_Pull_Sequence(
			p_item_id		IN	NUMBER,
			p_organization_id	IN	NUMBER,
			p_item_sequence_id	IN	NUMBER) RETURN NUMBER
IS

  l_pull_sequence_id	NUMBER;

BEGIN

  BEGIN
    SELECT mkps.pull_sequence_id
      INTO l_pull_sequence_id
      FROM mtl_kanban_pull_sequences mkps,
           bom_inventory_components bic,
	   mtl_system_items msi
     WHERE mkps.inventory_item_id = p_item_id
       AND mkps.organization_id = p_organization_id
       AND mkps.auto_request = 'Y'
       AND mkps.release_kanban_flag = 1
       AND mkps.inventory_item_id = bic.component_item_id
       AND msi.inventory_item_id = p_item_id
       AND msi.organization_id = p_organization_id
       AND msi.release_time_fence_code = G_Release_Time_Kanban_Item
       AND bic.component_sequence_id = p_item_sequence_id
       AND ( (bic.supply_subinventory IS NOT NULL AND mkps.subinventory_name = bic.supply_subinventory)
           OR (bic.supply_subinventory IS NULL AND mkps.subinventory_name = msi.wip_supply_subinventory) )
       AND ( (bic.supply_subinventory IS NOT NULL AND nvl(mkps.locator_id, '-0909090909') = nvl(bic.supply_locator_id, '-0909090909'))
           OR (bic.supply_subinventory IS NULL AND nvl(mkps.locator_id, '-0909090909') = nvl(msi.wip_supply_locator_id, '-0909090909')) )
       AND bic.wip_supply_type IN (G_Supply_Type_Assembly_Pull, G_Supply_Type_Operation_Pull);

  EXCEPTION
    WHEN OTHERS THEN
      l_pull_sequence_id := -1;
  END;

  return l_pull_sequence_id;

END Get_Valid_Pull_Sequence;


/************************************************************************
 * PROCEDURE Get_Subassemlies						*
 * 	This function returns the subassemblies that are being supplied *
 *      from another line. It takes all subassemblies that are being    *
 *      used in the line operations which are in the primary path or in *
 *      the alternate path. It ignores any subassemblies that are used  *
 *      in the rework operations.					*
 *      This routine also explodes the phantom component.		*
 *	                                                                *
 ************************************************************************/
PROCEDURE Get_Subassemblies(
                    p_org_id          	IN      NUMBER,
                    p_schedule_number   IN      VARCHAR2,
                    p_top_assy_id     	IN      NUMBER,
                    p_alt_bom_desig   	IN      VARCHAR2,
                    p_alt_rtg_desig   	IN      VARCHAR2,
                    p_sched_start_date	IN      DATE,
                    p_comp_table      	IN OUT  NOCOPY comp_list)
IS

    l_assy_id                       NUMBER;
    assy_table                      comp_list;
    max_assy_count                  NUMBER;
    max_comp_count                  NUMBER;
    curr_assy_count                 NUMBER;
    l_comp_id                       NUMBER;
    l_comp_name                     VARCHAR(40);
    l_usage                         NUMBER;
    l_wip_supply_type               NUMBER;
    l_line_id                       NUMBER;
    l_operation_seq_num             NUMBER;
    l_component_sequence_id         NUMBER;
    l_routing_sequence_id           NUMBER;
    l_line_op_seq_id         	    NUMBER;
    l_count         	    	    NUMBER;
    l_status			    BOOLEAN;
    l_inherit_phantom		    NUMBER;
    l_pull_sequence_id              NUMBER;
    l_stmt_no                       NUMBER;
    l_top_bill_sequence_id	    NUMBER;
    l_bill_sequence_id		    NUMBER;
    l_basis_type		    NUMBER;
    l_qty_per_lot		    NUMBER;

    cnt NUMBER :=0;
    CURSOR comp(l_assy_id number) IS
            SELECT  expl.component_item_id component_item_id,
		    comp.operation_seq_num operation_seq_num,
                    SUM(comp.component_quantity) extended_quantity,
                    MIN(DECODE(comp.wip_supply_type, NULL,
                            DECODE(sys.wip_supply_type, NULL,
                                    1, sys.wip_supply_type),
                            comp.wip_supply_type)) wip_supply_type,
		    MIN(comp.component_quantity) component_quantity,
		    MIN(nvl(comp.basis_type,WIP_CONSTANTS.ITEM_BASED_MTL)) basis_type
              FROM  mtl_system_items sys,
                    bom_inventory_components comp,
                    bom_explosions expl,
                    bom_bill_of_materials bbm
             WHERE  bbm.organization_id = sys.organization_id
               AND  comp.component_item_id = sys.inventory_item_id
               AND  comp.component_sequence_id = expl.component_sequence_id
               AND  sys.bom_item_type = 4
               AND  comp.component_item_id = expl.component_item_id
               AND  comp.bill_sequence_id =  expl.bill_sequence_id
               AND  bbm.organization_id = p_org_id
               AND  bbm.assembly_item_id = l_assy_id
               AND  (NVL(bbm.alternate_bom_designator, 'ABD756fhh466')
                        = NVL(p_alt_bom_desig, 'ABD756fhh466')
                    OR
                    (bbm.alternate_bom_designator is null AND
                    NOT EXISTS
                    (SELECT null
                       FROM bom_bill_of_materials bbm1
                      WHERE bbm1.alternate_bom_designator = p_alt_bom_desig
                        AND bbm1.organization_id = bbm.organization_id
                        AND bbm1.assembly_item_id = bbm.assembly_item_id)))
               AND  bbm.common_bill_sequence_id = expl.bill_sequence_id
	       AND  expl.top_bill_sequence_id = l_top_bill_sequence_id
               AND  expl.assembly_item_id is not null
--Bug 6691128  Removing Trunc So that Time to be considered
--             AND  trunc(expl.effectivity_date) <= trunc(p_sched_start_date)
--             AND  NVL(expl.disable_date, p_sched_start_date + 1)
--                     > trunc(p_sched_start_date)
               AND  expl.effectivity_date <= p_sched_start_date
               AND  NVL(expl.disable_date, p_sched_start_date + 1)
                     > p_sched_start_date
               AND  expl.explosion_type = 'ALL'
          GROUP BY  expl.component_item_id,comp.operation_seq_num;

    CURSOR component_sequence_cur IS
	SELECT component_sequence_id
	  FROM bom_explosions
	 WHERE top_bill_sequence_id = l_top_bill_sequence_id
	   AND explosion_type = 'ALL'
	   AND component_item_id = l_comp_id
	   AND operation_seq_num = l_operation_seq_num
--Bug 6691128 Removing Trunc So that Time to be considered
--         AND trunc(effectivity_date) <= trunc(p_sched_start_date);
           AND effectivity_date <= p_sched_start_date
           AND  NVL(disable_date, p_sched_start_date + 1)
                     > p_sched_start_date;

BEGIN

  l_stmt_no := 100;

  -- Find the routing for the p_top_assy_id
  SELECT routing_sequence_id
    INTO l_routing_sequence_id
    FROM bom_operational_routings
   WHERE organization_id = p_org_id
     AND assembly_item_id = p_top_assy_id
     AND NVL(alternate_routing_designator, 'ABD756fhh456') =
         NVL(p_alt_rtg_desig, 'ABD756fhh456');

  l_stmt_no := 105;

  max_assy_count := 1;
  curr_assy_count := 0;
  assy_table(1).item_id := p_top_assy_id;
  assy_table(1).usage := 1;
  max_comp_count := 0;

  l_stmt_no := 110;

  -- To retrive inherit_phantom_op_seq value
  SELECT inherit_phantom_op_seq
    INTO l_inherit_phantom
    FROM bom_parameters
   WHERE organization_id = p_org_id;

  BEGIN
    l_stmt_no := 115;

    l_bill_sequence_id := null;

    SELECT bill_sequence_id
      INTO l_bill_sequence_id
      FROM bom_bill_of_materials
     WHERE organization_id = p_org_id
       AND assembly_item_id = p_top_assy_id
       AND nvl(alternate_bom_designator, '@@@@') =
	    nvl(p_alt_bom_desig, '@@@@');

    l_top_bill_sequence_id := l_bill_sequence_id;

    l_stmt_no := 120;

    SELECT max(top_bill_sequence_id)
      INTO l_top_bill_sequence_id
      FROM bom_explosions
     WHERE component_item_id = p_top_assy_id
       AND organization_id = p_org_id;
  EXCEPTION
    WHEN OTHERS THEN
	l_top_bill_sequence_id := l_bill_sequence_id;
  END;

  LOOP
    cnt := cnt + 1;
    curr_assy_count := curr_assy_count + 1;

    IF curr_assy_count > max_assy_count THEN
       EXIT;
    END IF;

    l_assy_id := assy_table(curr_assy_count).item_id;


    FOR comp_record IN comp(l_assy_id) LOOP
      l_comp_id := comp_record.component_item_id;
      l_usage := comp_record.extended_quantity;
      l_wip_supply_type := comp_record.wip_supply_type;

      -- This stores the operation_seq_num from the parent's BOM
      l_operation_seq_num := comp_record.operation_seq_num;

      -- Added for Lot Based Material Support
      -- Retrieve the basis type and component quantity from the bom_explosions table.
      l_basis_type := comp_record.basis_type;
      l_qty_per_lot := comp_record.component_quantity;

      IF l_wip_supply_type = G_Supply_Type_Phantom THEN
        max_assy_count := max_assy_count + 1;
        assy_table(max_assy_count).item_id := l_comp_id;
        assy_table(max_assy_count).usage :=
        assy_table(curr_assy_count).usage * l_usage;

        /*---------------------------------------------------------------------+
	 | Two cases :                                                         |
         | a. For 1st level Subassembly, the operation_seq_num is the          |
         |    obtained from the BOM of its parent which is the top assembly.   |
         | b. Otherwise, the operation_seq_num is the operation_seq_num of     |
         |    its parent.                                                      |
	 +---------------------------------------------------------------------*/
        IF (l_inherit_phantom = 1) THEN
          IF (curr_assy_count = 1) THEN
            assy_table(max_assy_count).operation_seq_num := l_operation_seq_num;
          ELSE
            assy_table(max_assy_count).operation_seq_num :=
                  assy_table(curr_assy_count).operation_seq_num;
          END IF;
        END IF;

        IF (l_inherit_phantom = 2) THEN
          assy_table(max_assy_count).operation_seq_num := l_operation_seq_num;
        END IF;

      ELSE  /* l_wip_supply_type != G_Supply_Type_Phantom */

        l_stmt_no := 125;

	-- Get the Component sequence id
	FOR l_component_seequence_cur IN component_sequence_cur
	LOOP
	  l_component_sequence_id := l_component_seequence_cur.component_sequence_id;

  	  /*---------------------------------------------------------------------+
	   | If it's 1st level Subassembly, the component operation_seq_num      |
           | is the operation_seq_num obtained from the BOM. Otherwise,          |
           | it's the operation_seq_num of the 1st subassembly parent.           |
	   +---------------------------------------------------------------------*/
          IF ((l_inherit_phantom = 1) and (curr_assy_count <> 1)) THEN
	    l_operation_seq_num := assy_table(curr_assy_count).operation_seq_num;
  	  END IF;

          /*---------------------------------------------------------------------+
	   | Get the corresponding line_op_seq_id for the given operation_seq_num|
	   | in the routing of the top assembly                                  |
	   +---------------------------------------------------------------------*/
          BEGIN
            l_stmt_no := 130;

	    SELECT line_op_seq_id
              INTO l_line_op_seq_id
              FROM bom_operation_sequences
             WHERE routing_sequence_id = l_routing_sequence_id
               AND operation_seq_num = l_operation_seq_num
               AND operation_type = 1
               AND effectivity_date =
                   (SELECT max(effectivity_date)
                      FROM bom_operation_sequences
                     WHERE routing_sequence_id = l_routing_sequence_id
                       AND operation_seq_num = l_operation_seq_num
                       AND operation_type = 1);

          EXCEPTION
            WHEN no_data_found THEN
              l_line_op_seq_id := NULL;
          END;

          l_stmt_no := 135;

  	  -- Get pull sequence id of the component
 	  l_pull_sequence_id := Get_Valid_Pull_Sequence(l_comp_id, p_org_id, l_component_sequence_id);

          /*---------------------------------------------------------------------+
	   | Include only components that :                                      |
           |  1. Has a valid Line Operation Sequence.                            |
           |  2. Has a valid Pull Sequence                                       |
	   +---------------------------------------------------------------------*/

          IF (is_valid_seq(l_line_op_seq_id) and l_pull_sequence_id <> -1) THEN
            l_stmt_no := 140;
            IF (G_DEBUG) THEN
              log('Valid Component is '||l_comp_id);
            END IF;
            max_comp_count                                 := max_comp_count + 1;
            p_comp_table(max_comp_count).item_id           := l_comp_id;
            p_comp_table(max_comp_count).usage             := l_usage * assy_table(curr_assy_count).usage;
            p_comp_table(max_comp_count).line_id           := l_line_id;
            p_comp_table(max_comp_count).operation_seq_num := l_operation_seq_num;
            p_comp_table(max_comp_count).line_op_seq_id    := l_line_op_seq_id;
	    p_comp_table(max_comp_count).pull_sequence_id  := l_pull_sequence_id;
  	    p_comp_table(max_comp_count).schedule_number   := p_schedule_number;

            -- Added for Lot Based Material Support
            -- Storing the basis type and qty per lot in the p_comp_table.
  	    p_comp_table(max_comp_count).basis_type   	   := l_basis_type;
  	    p_comp_table(max_comp_count).qty_per_lot       := l_qty_per_lot;
          END IF;

        END LOOP; -- end of For Loop for component_sequence_cur

      END IF; -- end of if for l_wip_supply_type = G_Supply_Type_Phantom

    END LOOP; -- end of FOR LOOP

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF (G_DEBUG) THEN
      log ('Exception in Get_subassemblies at line number '||l_stmt_no);
    END IF;

END Get_Subassemblies;    -- end of procedure


/************************************************************************
 * FUNCTION Get_Operation_Times						*
 * 	Returns the Operation Time of a given Line Operation rounded	*
 *      up to the next takt time.                                       *
 *                                                                      *
 ************************************************************************/
FUNCTION Get_Operation_Times(
		p_line_op_seq_id	NUMBER,
		p_takt_time		NUMBER) RETURN NUMBER
IS

  l_total_time	NUMBER;

BEGIN

  SELECT CEIL(NVL(total_time_calc, 0) / p_takt_time) * p_takt_time
    INTO l_total_time
    FROM bom_operation_sequences
   WHERE operation_sequence_id = p_line_op_seq_id;

  RETURN l_total_time;

END Get_Operation_Times;


/************************************************************************
 * FUNCTION Need_By_Date						*
 * 	Returns the need by date of a component at a particular Line    *
 *      operation for the given assembly item routing on a given line.  *
 *	                                                                *
 ************************************************************************/
FUNCTION Need_By_Date(
		p_organization_id	NUMBER,
		p_line_id		NUMBER,
		p_assembly_item_id	NUMBER,
		p_assembly_comp_date	DATE,
		p_assembly_start_date	DATE,
		p_line_op_seq_id	NUMBER,
		p_quantity		NUMBER) RETURN DATE
IS

  l_start_time		NUMBER;
  l_stop_time		NUMBER;
  l_takt_time		NUMBER;
  l_working_hours	NUMBER;
  l_operation_times	NUMBER;
  l_lead_time		NUMBER;
  l_op_comp_date	DATE;
  l_op_start_date	DATE;

  CURSOR Network_Csr (i_start_operation_sequence_id	NUMBER) IS
    SELECT to_op_seq_id
      FROM Bom_Operation_Networks
          CONNECT BY PRIOR to_op_seq_id = from_op_seq_id
	               AND nvl(transition_type, 0) NOT IN (2,3)
                START WITH from_op_seq_id = i_start_operation_sequence_id
		       AND nvl(transition_type, 0) NOT IN (2,3);

BEGIN

  SELECT start_time,
         stop_time,
	 1/maximum_rate
    INTO l_start_time,
         l_stop_time,
	 l_takt_time
    FROM wip_lines
   WHERE line_id = p_line_id
     AND organization_id = p_organization_id;

  IF (l_stop_time > l_start_time) THEN
    l_working_hours := (l_stop_time - l_start_time) / 3600;
  ELSE
    l_working_hours := (l_stop_time + 24 * 3600 - l_start_time) / 3600;
  END IF;

  l_operation_times := Get_Operation_Times(p_line_op_seq_id, l_takt_time);

  FOR l_Network_Rec in Network_Csr(p_line_op_seq_id)
  LOOP
    l_operation_times := l_operation_times +
		Get_Operation_Times(l_Network_Rec.to_op_seq_id, l_takt_time);
  END LOOP;

  -- Operation completion time
  l_op_comp_date := MRP_LINE_SCHEDULE_ALGORITHM.calculate_begin_time(
			p_organization_id,
			p_assembly_comp_date,
			l_operation_times / l_working_hours,
			l_start_time,
			l_stop_time);

  SELECT nvl(fixed_lead_time, 0) + (p_quantity - 1) * nvl(variable_lead_time, 0)
    INTO l_lead_time
    FROM mtl_system_items
   WHERE inventory_item_id = p_assembly_item_id
     AND organization_id = p_organization_id;

  -- Operation Start time
  l_op_start_date := MRP_LINE_SCHEDULE_ALGORITHM.calculate_begin_time(
			p_organization_id,
			l_op_comp_date,
			l_lead_time,
			l_start_time,
			l_stop_time);

  return l_op_start_date;

END Need_By_Date;


/************************************************************************
 * PROCEDURE Update_Flow_Schedule					*
 * 	Updates the Auto Replenish flag of the given Flow Schedule.	*
 *	                                                                *
 ************************************************************************/
PROCEDURE Update_Flow_Schedule(
		p_schedule_number	IN	VARCHAR2) IS

BEGIN

    UPDATE wip_flow_schedules
       SET auto_replenish = 'Y'
     WHERE schedule_number = p_Schedule_Number;

END Update_Flow_Schedule;


/************************************************************************
 * PROCEDURE Print_Kanban_Cards						*
 * 	Prints the Kanban Cards.					*
 *	                                                                *
 ************************************************************************/
PROCEDURE Print_Kanban_Cards(
	p_Kanban_Card_Ids	IN	Kanban_Card_Id_Tbl_Type) IS

  l_report_id	NUMBER;
  l_card_count	NUMBER;
  l_req_id	NUMBER;
  l_sort_by	NUMBER;
  l_call_from	NUMBER;
BEGIN

  SELECT MTL_KANBAN_CARD_PRINT_TEMP_S.nextval
    INTO l_report_id
    FROM dual;

  FOR l_card_count in 1..p_Kanban_Card_Ids.COUNT
  LOOP

    INSERT into MTL_KANBAN_CARD_PRINT_TEMP(
		REPORT_ID,
		KANBAN_CARD_ID)
	 VALUES (l_report_id,
	         p_Kanban_Card_Ids(l_card_count));

  END LOOP; -- end of for loop

  l_sort_by	:= 3; -- for sort by Subinventory, locator
  l_call_from	:= 2; -- as we are passing report_id

  l_req_id := fnd_request.submit_request( 'INV',
                                          'INVKBCPR',
                                           NULL,
                                           NULL,
                                           FALSE,
                                           NULL, /* p_org_id */
                                           NULL, /* p_date_created_low */
                                           NULL, /* p_date_created_high */
                                           NULL, /* p_kanban_card_number_low */
                                           NULL, /* p_kanban_card_number_high */
                                           NULL, /* p_item_low */
                                           NULL, /* p_item_high */
                                           NULL, /* p_subinv */
                                           NULL, /* p_locator_low */
                                           NULL, /* p_locator_high */
                                           NULL, /* p_source_type */
                                           NULL, /* p_kanban_card_type */
                                           NULL, /* p_supplier */
                                           NULL, /* p_supplier_site */
                                           NULL, /* p_source_org_id */
                                           NULL, /* p_source_subinv */
                                           NULL, /* p_source_loc_id */
                                           l_sort_by,   /* p_sort_by */
                                           l_call_from, /* p_call_from */
                                           NULL,        /* p_kanban_card_id */
                                           l_report_id  /* p_report_id */
                                        );

  IF l_req_id = 0 THEN
    DELETE FROM mtl_kanban_card_print_temp
          WHERE report_id = l_report_id;
  END IF;
  Commit;

END Print_Kanban_Cards;


/************************************************************************
 *	Public Procedures and Functions                             	*
 ************************************************************************/


/************************************************************************
 * PROCEDURE Create_And_Replenish_Cards					*
 *  	This is the procedure which is called by the Concurrent	Request *
 *	The Input parameters for this procedure are :			*
 *	p_organization_id - Organization Identifier			*
 *	p_min_line_code   - From Line Identifier			*
 *	p_max_line_code   - To Line Identifier				*
 *			  - To find flow schedules which are on lines	*
			    between From and To Lines identifier	*
 *	p_completion_date - Completion Date of Flow Schedules		*
 *			  - To find flow schedules which have scheduled *
 *			    completion date less than the given date 	*
 *			    greater than the sysdate			*
 *	p_build_sequence  - Build Sequence of Flow Schedules		*
 *			  - To find flow schedules which have build	*
 *			    sequence less than or equal to the given	*
 *			    build sequence and if this parameter is null*
 *			    then find all flow schedules which have not *
 *			    not build sequence				*
 *	p_print_card	  - Print Kanban Cards Option (Yes/No)		*
 ************************************************************************/
PROCEDURE Create_And_Replenish_Cards(
	o_error_code			OUT NOCOPY	NUMBER,
	o_error_msg			OUT NOCOPY	VARCHAR2,
	p_organization_id		IN	NUMBER,
	p_min_line_code			IN	VARCHAR2,
	p_max_line_code			IN	VARCHAR2,
	p_from_completion_date          IN      VARCHAR2, /*Added for bug 6816497 */
	p_completion_date		IN	VARCHAR2,
	p_from_build_sequence           IN      NUMBER, /*Added for bug 6816497 */
	p_build_sequence		IN	NUMBER,
	p_print_card			IN	VARCHAR2) IS

  l_api_version_number	CONSTANT NUMBER := 1.0;

  l_comp_count		NUMBER;
  l_Card_Count		NUMBER := 0;
  l_schedule_number	VARCHAR2(30);
  l_auto_replenish	VARCHAR2(1);
  l_wip_entity_id	NUMBER;
  l_build_sequence	NUMBER;
  l_primary_item_id	NUMBER;
  l_line_id		NUMBER;
  l_open_qty		NUMBER;
  l_alt_bom		VARCHAR2(10);
  l_alt_rtg		VARCHAR2(10);
  l_Kanban_Card_Id	NUMBER;
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_return_status	VARCHAR2(10);
  l_comp_name		VARCHAR2(600);
  l_client_tz_id	NUMBER;
  l_server_tz_id	NUMBER;

  /*------------------------------------------------------------------------+
   | l_program_status signifies the status of concurrent program. It has    |
   | following values :-                                                    |
   |    'I' - Initial Status (default), when program is picking schedules   |
   |    'F' - Fail Status, which signfies that all schedules have component |
   |          to be picked, and none of them resulted in replenishment of   |
   |          the card and thus status is fail.                             |
   |    'S' - Success Status, which signifies that status was not fail      |
   |          (Note : Even if program status has value 'S', still program   |
   |                  may finish with Warning status                        |
   +------------------------------------------------------------------------*/
  l_program_status	VARCHAR2(1) := 'I';

  l_start_date		DATE;
  l_completion_date	DATE;
  l_need_by_date	DATE;
  l_server_compl_date	DATE;
  l_server_from_compl_date DATE; /*Added for bug 6816497 */

  l_Request_Status	BOOLEAN;

  l_comp_table		comp_list;
  l_Kanban_Card_Ids	Kanban_Card_Id_Tbl_Type;

  create_exception	EXCEPTION;
  update_exception	EXCEPTION;
  replenish_exception	EXCEPTION;
  timezone_exception	EXCEPTION;
  update_ar_exception   EXCEPTION;  --bug 6816497

  l_usage		NUMBER;
  -- cursor to retrieve the flow schedules based on the criteria
  CURSOR flow_schedule_csr IS
    SELECT      flow.schedule_number,
		flow.build_sequence build_sequence,
                flow.primary_item_id primary_item_id,
                flow.line_id line_id,
                (flow.planned_quantity - nvl(flow.quantity_completed, 0)) open_quantity,
                flow.scheduled_start_date scheduled_start_date,
                flow.scheduled_completion_date scheduled_completion_date,
                flow.alternate_bom_designator alternate_bom_designator,
                flow.alternate_routing_designator alternate_routing_designator
    FROM        wip_flow_schedules flow,
                wip_lines lines
    WHERE       flow.planned_quantity - nvl(flow.quantity_completed, 0) > 0
    AND         flow.status <> 2
    AND         flow.scheduled_completion_date <= (l_server_compl_date + 1)
    AND         flow.scheduled_completion_date >= nvl(l_server_from_compl_date,sysdate) /*Added for bug 6816497 */
    AND         flow.line_id = lines.line_id
    AND         flow.organization_id = lines.organization_id
    AND         lines.organization_id = p_organization_id
    AND         lines.line_code BETWEEN p_min_line_code AND p_max_line_code
    AND         ( (p_build_sequence is not null AND flow.build_sequence <= p_build_sequence AND
                   flow.build_sequence >= nvl(p_from_build_sequence,flow.build_sequence)) /*Added for bug 6816497 */
		 OR (p_build_sequence is null AND flow.build_sequence is not null))
    AND		nvl(flow.auto_replenish, 'N') = 'N';

BEGIN

  Savepoint spBegin;

  IF (G_DEBUG) THEN
    log('Welcome to Auto Replenishment');
    log('Org = '||p_organization_id);
    log('Min Line = '||p_min_line_code);
    log('Max Line = '||p_max_line_code);
    log('From Compl Date ='||p_from_completion_date); /*Added for bug 6816497 */
    log('To Compl Date = '||p_completion_date);
    log('From Build Seq = '||p_from_build_sequence); /*Added for bug 6816497 */
    log('To Build Seq = '||p_build_sequence);
    log('Print = '||p_print_card);
  END IF;

  /* To convert the completion date entered by the user in the concurrent program to the
     Server timezone */
  l_client_tz_id := to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
  l_server_tz_id := to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

  HZ_TIMEZONE_PUB.Get_Time(
		p_api_version		=> 1.0,
		p_init_msg_list		=> 'F',
		p_source_tz_id		=> l_client_tz_id,
		p_dest_tz_id		=> l_server_tz_id,
		p_source_day_time	=> fnd_date.canonical_to_date(p_completion_date),
		x_dest_day_time		=> l_server_compl_date,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    raise timezone_exception;
  END IF;

 /************Added for bug 6816497 ************ */

   HZ_TIMEZONE_PUB.Get_Time(
                   p_api_version                => 1.0,
                   p_init_msg_list                => 'F',
                   p_source_tz_id                => l_client_tz_id,
                   p_dest_tz_id                => l_server_tz_id,
                   p_source_day_time        => fnd_date.canonical_to_date(p_from_completion_date),
                   x_dest_day_time                => l_server_from_compl_date,
                   x_return_status                => l_return_status,
                   x_msg_count                => l_msg_count,
                   x_msg_data                => l_msg_data);

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       raise timezone_exception;
   END IF;

   /*********************************************************/


  FOR l_flow_schedule_csr IN flow_schedule_csr
  LOOP
    l_schedule_number := l_flow_schedule_csr.schedule_number;
    l_build_sequence  := l_flow_schedule_csr.build_sequence;
    l_primary_item_id := l_flow_schedule_csr.primary_item_id;
    l_line_id         := l_flow_schedule_csr.line_id;
    l_open_qty        := l_flow_schedule_csr.open_quantity;
    l_start_date      := l_flow_schedule_csr.scheduled_start_date;
    l_completion_date := l_flow_schedule_csr.scheduled_completion_date;
    l_alt_bom         := l_flow_schedule_csr.alternate_bom_designator;
    l_alt_rtg         := l_flow_schedule_csr.alternate_routing_designator;

    IF (G_DEBUG) THEN
      log('Retrieved Schedules, Schedule = '|| l_schedule_number ||
                             ', Assy = '|| l_primary_item_id ||
	                     ', Line = '|| l_line_id ||
			     ', Qty = '|| l_open_qty ||
			     ', Completion Date = '|| l_completion_date ||
			     ', Alt BOM = '|| l_alt_bom ||
			     ', Alt Routing = '|| l_alt_rtg);
    END IF;

    BEGIN
      Savepoint spSchedule;

      -- Lock the flow schedule for update of auto_replenish flag
      BEGIN
           SELECT auto_replenish
             INTO l_auto_replenish
             FROM wip_flow_schedules
            WHERE schedule_number = l_schedule_number
       FOR UPDATE OF auto_replenish NOWAIT;
      EXCEPTION
        WHEN OTHERS THEN
          raise update_exception;
      END;

      --Bug 6816497
         BEGIN
           --before locking check the auto_replenish flag, this schedule may have been updated by other request
            SELECT NVL(auto_replenish, 'N')
              INTO l_auto_replenish
              FROM wip_flow_schedules
             WHERE schedule_number = l_schedule_number;


           IF l_auto_replenish = 'Y' then
             raise update_ar_exception;
           END IF;
         END;

      IF (l_comp_table.COUNT <> 0) THEN
        l_comp_table.DELETE;
      END IF;

      -- Get all the components
      get_subassemblies(p_organization_id,
			l_schedule_number,
			l_primary_item_id,
			l_alt_bom,
			l_alt_rtg,
			l_start_date,
			l_comp_table);

      l_comp_count := 1;
      while l_comp_table.EXISTS(l_comp_count) LOOP
        IF (G_DEBUG) THEN
          log('Retrieved Valid Components in Assembly, Comp = '|| l_comp_table(l_comp_count).item_id ||
	                              ', Comp Pull Sequence = '|| l_comp_table(l_comp_count).pull_sequence_id);
        END IF;

	IF (nvl(l_program_status, 'I') <> 'S') THEN
	  l_program_status := 'F';
	END IF;

        -- Added for Lot Based Material Support
        -- For item basis type, the usage is the component cumulative usage * flow schedule open qty
        -- For lot basis type, the usage is the qty per assembly for that component.
	if (l_comp_table(l_comp_count).basis_type = WIP_CONSTANTS.ITEM_BASED_MTL) then
	  l_usage:=l_comp_table(l_comp_count).usage*l_open_qty;
	else
          l_usage:=l_comp_table(l_comp_count).qty_per_lot;
	end if;

        -- Create Non-replenishable Kanban Card
        INV_Kanban_GRP.Create_Non_Replenishable_Card(
		X_return_status		=> l_return_status,
		X_msg_data		=> l_msg_data,
		X_msg_count		=> l_msg_count,
		X_Kanban_Card_Id	=> l_Kanban_Card_id,
		p_pull_sequence_id	=> l_comp_table(l_comp_count).pull_sequence_id,
		p_kanban_size		=> l_usage);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS and l_Kanban_Card_Id IS NULL) THEN

	  Show_Exception_Messages(
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_schedule_number	=> l_schedule_number,
		p_comp_id		=> l_comp_table(l_comp_count).item_id,
		p_organization_id	=> p_organization_id,
		p_error_position	=> G_Error_Create_Cards);

	  l_Request_Status := fnd_concurrent.set_completion_status(status	=> 'WARNING',
                                                                   message	=> '');
	  raise create_exception;

        END IF;

        IF (G_DEBUG) THEN
          log('Created Non-Replenishable Kanban Card, Card Id = '|| l_Kanban_Card_Id);
        END IF;

        -- Get Need By date for the component
        l_need_by_date := Need_By_Date(p_organization_id,
				l_line_id,
				l_comp_table(l_comp_count).item_id,
				l_completion_date,
				l_start_date,
				l_comp_table(l_comp_count).line_op_seq_id,
				l_usage);

        -- Replenish the Cards
        SELECT wip_entity_id
          INTO l_wip_entity_id
   	  FROM wip_flow_schedules
         WHERE schedule_number = l_comp_table(l_comp_count).schedule_number
	   AND organization_id = p_organization_id;

        INV_Kanban_GRP.Update_Card_Supply_Status(
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		x_return_status		=> l_return_status,
		p_api_version_number	=> l_api_version_number,
		p_init_msg_list		=> NULL,
		p_commit		=> NULL,
		p_Kanban_Card_Id	=> l_Kanban_Card_Id,
		p_Supply_Status		=> G_Supply_Status_Empty,
		p_Document_Type		=> NULL,
		p_Document_Header_Id	=> NULL,
		p_Document_Detail_Id	=> NULL,
		p_Need_By_Date		=> l_need_by_date,
		p_Source_Wip_Entity_Id	=> l_wip_entity_id);

	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

	  Show_Exception_Messages(
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_schedule_number	=> l_schedule_number,
		p_comp_id		=> l_comp_table(l_comp_count).item_id,
		p_organization_id	=> p_organization_id,
		p_error_position	=> G_Error_Replenish_Cards);

	  l_Request_Status := fnd_concurrent.set_completion_status(status	=> 'WARNING',
                                                                   message	=> '');
	  raise replenish_exception;

        END IF;

        IF (G_DEBUG) THEN
          log('Replenished Kanban Card, Card Id = '|| l_Kanban_Card_Id);
        END IF;

        -- Update Auto_Replenish flag in Flow Scheules
        Update_Flow_Schedule(l_comp_table(l_comp_count).schedule_number);

        IF (G_DEBUG) THEN
          log('Updated Auto Replenish flag of Flow schedules, Schedule number = '|| l_comp_table(l_comp_count).schedule_number);
        END IF;

        l_Card_Count := l_Card_Count + 1;
        l_Kanban_Card_Ids(l_Card_Count) := l_Kanban_Card_Id;

        l_comp_count := l_comp_count + 1;

	l_program_status := 'S';

      END LOOP; -- end of while loop

      l_program_status := 'S';

    EXCEPTION
      WHEN create_exception THEN
        Rollback to spSchedule;
      WHEN replenish_exception THEN
        Rollback to spSchedule;
      WHEN update_exception THEN
        fnd_message.set_name('FLM', 'FLM_AR_ERR_LOCK_SCHEDULE');
        log(fnd_message.get);
        Rollback to spSchedule;
      --Bug 6816497
      WHEN update_ar_exception THEN
        fnd_message.set_name('FLM', 'FLM_AR_ERR_SCHEDULE_UPDATED');
        log(fnd_message.get);
        Rollback to spSchedule;

      WHEN OTHERS THEN
        Rollback to spSchedule;

    END; -- end of Begin

  END LOOP; -- end of for loop

  /*-------------------------------------------------------------------------------------------+
   | Print Kanban Cards                                                                        |
   | If Print Kanban Cards option is selected and cards have been created then only print cards|
   +-------------------------------------------------------------------------------------------*/
  IF (p_print_card = 1 AND l_Kanban_Card_Ids.COUNT > 0) THEN

    Print_Kanban_Cards(l_Kanban_Card_Ids);

    IF (G_DEBUG) THEN
      log('Print request generated for creating Kanban Cards');
    END IF;

  END IF;

  /*-------------------------------------------------------------------------------------------+
   | If program_status has not been set to 'S', it signifies that all the flow schedules have  |
   | failed, i.e. all schedules have components to be replenished and none of the flow schedule|
   | succeeded, thus setting the request completion status to ERROR.                           |
   +-------------------------------------------------------------------------------------------*/

  IF ( nvl(l_program_status, 'I') = 'F' ) THEN
    l_Request_Status := fnd_concurrent.set_completion_status(status	=> 'ERROR',
                                                             message	=> '');
  END IF;

EXCEPTION
  WHEN timezone_exception THEN
    fnd_message.set_name('FLM', 'FLM_AR_ERR_TIMEZONE');
    log(fnd_message.get);
  WHEN OTHERS THEN
    fnd_message.set_name('FLM', 'FLM_AR_ERR_UNEXP');
    log(fnd_message.get);
END create_and_replenish_cards;


END FLM_AUTO_REPLENISHMENT;

/
