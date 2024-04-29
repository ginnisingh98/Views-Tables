--------------------------------------------------------
--  DDL for Package Body FLM_CREATE_PRODUCT_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_CREATE_PRODUCT_SYNCH" AS
/* $Header: FLMCPSYB.pls 120.2 2005/08/04 12:06:28 asuherma noship $ */
-- Modified to support lot based material
-- Added basis type and qty per lot
type comp_rec is record
        (item_id                NUMBER,
         usage                  NUMBER,
         line_id                NUMBER,
	 operation_seq_num	NUMBER,
	 line_op_seq_id	        NUMBER,
         basis_type		NUMBER,
         qty_per_lot		NUMBER);

type comp_list is table of comp_rec index by BINARY_INTEGER;

g_debug     boolean := FALSE;

-- Return the operation time of a particular line-op rounded up to the
-- next takt time.
FUNCTION get_operation_times (p_line_op_seq_id NUMBER, p_takt_time NUMBER) return NUMBER IS
  l_total_time NUMBER;
BEGIN
  select CEIL(NVL(total_time_calc,0)/p_takt_time) * p_takt_time
  into l_total_time
  from bom_operation_sequences
  where operation_sequence_id = p_line_op_seq_id;

  return (l_total_time);
END get_operation_times;

-- To calculate the schedule start time of the feeder line schedule
FUNCTION feeder_line_start_date (p_org_id NUMBER,
                                 p_feeder_line_id NUMBER,
			         p_item_id NUMBER,
                                 p_qty NUMBER,
				 p_completion_date DATE) return DATE
IS
  l_start_time NUMBER;
  l_stop_time NUMBER;
  l_lead_time NUMBER;
BEGIN
  select start_time, stop_time
  into l_start_time, l_stop_time
  from wip_lines
  where line_id = p_feeder_line_id
    and organization_id = p_org_id;

  select nvl(fixed_lead_time,0) + (p_qty - 1)*nvl(variable_lead_time,0)
  into l_lead_time
  from mtl_system_items
  where organization_id = p_org_id
    and inventory_item_id = p_item_id;

  return ( MRP_LINE_SCHEDULE_ALGORITHM.calculate_begin_time(
                p_org_id ,
                p_completion_date,
                l_lead_time ,
                l_start_time,
                l_stop_time) );

END feeder_line_start_date;

-- This function is used to calculate the completion date
-- of the feeder line. The input parameter is the line_op
-- sequence id from where the feeder line goes in.
-- Using the routing networks information, it sums up the
-- operation time (rounded up to the multiple of takt time)
-- of the line-op from the given line op
-- to the last completion line op by tracing only the primary path.
-- Then substract that time from the completion time
-- (using calculate_begin_time routine) to get required
-- completion time of the feeder line at particular line op.
-- 2 parameters p_qty and p_fast_feeder_line added for bug 2373141
FUNCTION feeder_line_comp_date (p_org_id NUMBER,
				p_assembly_line_id NUMBER,
				p_assembly_item_id NUMBER,
				p_assembly_start_date DATE,
				p_assembly_comp_date DATE,
				p_line_op_seq_id NUMBER,
                                p_qty NUMBER,
				p_fast_feeder_line NUMBER) return DATE
IS
  l_takt_time NUMBER;
  l_operation_times NUMBER;
  l_date DATE;
  l_start_time NUMBER;
  l_stop_time NUMBER;
  l_working_hours NUMBER;
  l_assembly_comp_date DATE;

  cursor network_cur (cv_start_operation_sequence_id number) is
  select bon.to_op_seq_id to_op_seq_id
  from bom_operation_networks bon
  connect by prior to_op_seq_id = from_op_seq_id
             and
             nvl(bon.transition_type, 0) not in (2, 3)
  start with from_op_seq_id = cv_start_operation_sequence_id
             and
             nvl(bon.transition_type, 0) not in (2, 3);

BEGIN

  select start_time, stop_time, 1/maximum_rate
  into l_start_time, l_stop_time, l_takt_time
  from wip_lines
  where line_id = p_assembly_line_id
    and organization_id = p_org_id;

  if (l_stop_time > l_start_time) then
    l_working_hours := (l_stop_time - l_start_time)/3600;
  else
    l_working_hours := (l_stop_time + 24*3600 - l_start_time)/3600;
  end if;

  l_operation_times := get_operation_times(p_line_op_seq_id, l_takt_time);
  for network_rec in network_cur (p_line_op_seq_id) loop
    l_operation_times := l_operation_times +
                         get_operation_times(network_rec.to_op_seq_id,l_takt_time);
  end loop;

 /* Added for bug 2373141 */
  if ( p_fast_feeder_line > 0 ) then
    l_assembly_comp_date := p_assembly_comp_date - ((((p_qty -1) * l_takt_time) * 3600)/86400);
  else
    l_assembly_comp_date := p_assembly_comp_date;
  end if;
 /* Added for bug 2373141 */

  l_date := MRP_LINE_SCHEDULE_ALGORITHM.calculate_begin_time(
                p_org_id ,
                l_assembly_comp_date,
                l_operation_times/l_working_hours ,
                l_start_time,
                l_stop_time);

  -- If completion time is the same as line start time in the day, then
  -- the completion time is set to the previous work day at line stop time
  --fix bug#3170105
  --if ( l_date = (trunc(l_date)+l_start_time/(24*3600)) ) then
  --    l_date := mrp_calendar.prev_work_day(p_org_id,1,trunc(l_date)-1)+l_stop_time/(24*3600);
  --end if;
  if ( l_date = (flm_timezone.server_to_calendar(l_date)+l_start_time/(24*3600)) ) then
      l_date := mrp_calendar.prev_work_day(p_org_id,1,
                  flm_timezone.server_to_calendar(l_date)-1)+l_stop_time/(24*3600);
  end if;
  --end of fix bug#3170105

  return (l_date);

END feeder_line_comp_date;

-- Find out if the line-op is a valid line-op.
-- Valid line-op is line-op that is in the primary-path
FUNCTION is_valid_seq (p_op_seq_id in number) return boolean is
  l_cnt NUMBER;
BEGIN
  if (p_op_seq_id is null) then
    return false;
  end if;

  -- Look at the from_op_seq_id to find out if the line-op
  -- is in primary path.
  select count(*)
  into l_cnt
  from bom_operation_networks
  where from_op_seq_id = p_op_seq_id
      and nvl(transition_type, 3) = 1;

  if (l_cnt = 0) then
    -- Look at the to_op_seq_id to find out if the line-op
    -- is in primary path. This is the exception for the
    -- last line-op
    select count(*)
    into l_cnt
    from bom_operation_networks
    where to_op_seq_id = p_op_seq_id
      and nvl(transition_type, 3) = 1;

    if (l_cnt = 0) then
      -- If not network exists, then if only one line operation exists
      -- for this routing, it's valid, otherwise it's not valid.
      select count(*)
      into l_cnt
      from bom_operation_sequences
      where operation_type = 3
        and routing_sequence_id = (
              select max(routing_sequence_id)
              from bom_operation_sequences
              where operation_sequence_id = p_op_seq_id
            );
      if l_cnt = 1 then
        return true;
      end if;
      return false;
    end if;

  end if;

  return true;

END is_valid_seq;

-- This function returns the subassemblies that are being supplied from
-- another line. It takes all subassemblies that are being used in the
-- line operations which are in the primary path or in the alternate path.
-- It ignores any subassemblies that are used in the rework operations.
-- This routine also explodes the phantom component.
PROCEDURE get_subassemblies(
                    arg_org_id          	in      number,
                    arg_schedule_number         in      varchar2,
                    arg_top_assy_id     	in      number,
                    arg_alt_bom_desig   	in      VARCHAR2,
                    arg_alt_rtg_desig   	in      VARCHAR2,
                    arg_sched_start_date	in      DATE,
                    arg_comp_table      	in out  NOCOPY comp_list)
IS

    var_assy_id                     NUMBER;
    assy_table                      comp_list;
    max_assy_count                  NUMBER;
    max_comp_count                  NUMBER;
    curr_assy_count                 NUMBER;
    var_comp_id                     NUMBER;
    var_comp_name                   VARCHAR(40);
    var_usage                       NUMBER;
    var_wip_supply_type             NUMBER;
    var_line_id                     NUMBER;
    var_operation_seq_num           NUMBER;
    var_routing_sequence_id         NUMBER;
    var_line_op_seq_id         	    NUMBER;
    var_count         	    	    NUMBER;
    var_status			    BOOLEAN;
    var_inherit_phantom		    NUMBER;
    var_basis_type		    NUMBER;
    var_qty_per_lot		    NUMBER;

    l_top_bill_sequence_id	    NUMBER;
    l_bill_sequence_id		    NUMBER;

    CURSOR comp(var_assy_id NUMBER,p_start_date DATE) IS  --fix bug#3170105
            select  expl.component_item_id component_item_id,
		    comp.operation_seq_num operation_seq_num,
                    SUM(comp.component_quantity) extended_quantity,
                    MIN(DECODE(comp.wip_supply_type, NULL,
                            DECODE(sys.wip_supply_type, NULL,
                                    1, sys.wip_supply_type),
                            comp.wip_supply_type)) wip_supply_type,
		    MIN(comp.component_quantity) component_quantity,
		    MIN(nvl(comp.basis_type,WIP_CONSTANTS.ITEM_BASED_MTL)) basis_type
            from    mtl_system_items sys,
                    bom_inventory_components comp,
                    bom_explosions expl,
                    bom_bill_of_materials bbm
            where   sys.planning_make_buy_code = 1
            and     bbm.organization_id = sys.organization_id
            and     comp.component_item_id = sys.inventory_item_id
/* Fixed bug #2503750
   Added condition to take into consideration bom effectivity dates. */
            and     comp.component_sequence_id = expl.component_sequence_id
/* Updated by Liye Ma.  Mar.5th 2001
   Fixed bug 1668713
   Select only components whose type is standard */
            and     sys.bom_item_type = 4
/* End of Update */
            and     comp.component_item_id = expl.component_item_id
            and     comp.bill_sequence_id =  expl.bill_sequence_id
            and     bbm.organization_id = arg_org_id
            and     bbm.assembly_item_id = var_assy_id
            and     (NVL(bbm.alternate_bom_designator, 'ABD756fhh466')
                        = NVL(arg_alt_bom_desig, 'ABD756fhh466')
                    or
                    (bbm.alternate_bom_designator is null and
                    not exists
                    (select null
                     from   bom_bill_of_materials bbm1
                     where  bbm1.alternate_bom_designator =
                                arg_alt_bom_desig
                     and    bbm1.organization_id = bbm.organization_id
                     and    bbm1.assembly_item_id = bbm.assembly_item_id)))
            and     bbm.common_bill_sequence_id = expl.bill_sequence_id
/* Added the following clause for the bug 1817962 */
/*            and     expl.top_bill_sequence_id =
                               (select bill_sequence_id from
                                      bom_bill_of_materials
                               where assembly_item_id = arg_top_assy_id
                               and organization_id = arg_org_id
                               and nvl(alternate_bom_designator,'@@@') =
                                                nvl(arg_alt_bom_desig,'@@@'))
*/
	    and	    expl.top_bill_sequence_id = l_top_bill_sequence_id
            and     expl.assembly_item_id is not null
            and     expl.effectivity_date <= p_start_date  --fix bug#3170105
            and     NVL(expl.disable_date,p_start_date+1) > p_start_date
            and     expl.explosion_type = 'ALL'
            group by expl.component_item_id,comp.operation_seq_num;

BEGIN
    -- Find the routing for the arg_top_assy_id
    select --routing_sequence_id
    common_routing_sequence_id --3701766 3891345.999
    into var_routing_sequence_id
    from bom_operational_routings
    where organization_id = arg_org_id
      and assembly_item_id = arg_top_assy_id
      and NVL(alternate_routing_designator, 'ABD756fhh456') =
         NVL(arg_alt_rtg_desig, 'ABD756fhh456');

    max_assy_count := 1;
    curr_assy_count := 0;
    assy_table(1).item_id := arg_top_assy_id;
    assy_table(1).usage := 1;
    max_comp_count := 0;

    if g_debug then
        MRP_UTIL.MRP_LOG('In get assemblies');
    end if;
    /* Added to retrive inherit_phantom_op_seq value for Bug # 1973152 */
     SELECT inherit_phantom_op_seq  INTO var_inherit_phantom
    from bom_parameters
    where organization_id = arg_org_id;

    BEGIN
      l_bill_sequence_id := null;
      select bill_sequence_id
      into l_bill_sequence_id
      from bom_bill_of_materials
      where organization_id = arg_org_id
        and assembly_item_id = arg_top_assy_id
        and nvl(alternate_bom_designator, '@@@@') =
	    nvl(arg_alt_bom_desig, '@@@@');
      l_top_bill_sequence_id := l_bill_sequence_id;
      select max(top_bill_sequence_id)
      into l_top_bill_sequence_id
      from bom_explosions
      where component_item_id = arg_top_assy_id
        and organization_id = arg_org_id;
    EXCEPTION
      WHEN OTHERS THEN
	l_top_bill_sequence_id := l_bill_sequence_id;
    END;

    LOOP
        curr_assy_count := curr_assy_count + 1;
        if curr_assy_count > max_assy_count then
            exit;
        end if;

        var_assy_id := assy_table(curr_assy_count).item_id;

        FOR comp_record IN comp(var_assy_id,arg_sched_start_date) LOOP
            var_comp_id := comp_record.component_item_id;
            var_usage := comp_record.extended_quantity;
            var_wip_supply_type := comp_record.wip_supply_type;
            -- This stores the operation_seq_num from the parent's BOM
            var_operation_seq_num := comp_record.operation_seq_num;

            -- Added to support lot based material
            -- Retrieve the basis type and component quantity from bom_explosions table.
            var_basis_type := comp_record.basis_type;
	    var_qty_per_lot := comp_record.component_quantity;

            if g_debug then
                MRP_UTIL.MRP_LOG(' Component ' || to_char(var_comp_id) ||
                                    ' Usage '|| to_char(var_usage) ||
                                    ' Wip Supply type '|| to_char(var_wip_supply_type) ||
                                    ' Basis Type '||to_char(var_basis_type) ||
                                    ' Qty '||to_char(var_qty_per_lot));
            end if;
            if var_wip_supply_type = 6 then
                if g_debug then
                    MRP_UTIL.MRP_LOG('Phantom Component ');
                end if;
                max_assy_count := max_assy_count + 1;
                assy_table(max_assy_count).item_id := var_comp_id;
                assy_table(max_assy_count).usage :=
                    assy_table(curr_assy_count).usage * var_usage;

                -- Two cases :
                -- a. For 1st level Subassembly, the operation_seq_num is the
                --    obtained from the BOM of its parent which is the top assembly.
                -- b. Otherwise, the operation_seq_num is the operation_seq_num of
                --    its parent.
                if (var_inherit_phantom = 1) then
                   if (curr_assy_count = 1) then
                      assy_table(max_assy_count).operation_seq_num := var_operation_seq_num;
                   else
                      assy_table(max_assy_count).operation_seq_num :=
                      assy_table(curr_assy_count).operation_seq_num;
                   end if;
                 end if;
                 if (var_inherit_phantom = 2) then
                    assy_table(max_assy_count).operation_seq_num := var_operation_seq_num;
                 end if;
            else
                begin
		/* Changed the where clause of the query for bug #2508196 to
		   pick up the line on which primary routing of the item exists. */
		    select  line_id
                    into    var_line_id
                    from    bom_operational_routings flow_rtg
                    where   flow_rtg.assembly_item_id = var_comp_id
		    and     flow_rtg.organization_id = arg_org_id
                    and     flow_rtg.cfm_routing_flag = 1
                    and     flow_rtg.alternate_routing_designator is null;

/*		    where   flow_rtg.routing_sequence_id =
                            (select min(routing_sequence_id)
                             from   bom_operational_routings rtg1
                             where  rtg1.assembly_item_id = var_comp_id
                             and    rtg1.organization_id = arg_org_id
                             and    rtg1.cfm_routing_flag = 1
                             and    NVL(rtg1.priority, 1) =
                                (select NVL(min(priority), 1)
                                 from   bom_operational_routings rtg
                                 where  rtg.assembly_item_id = var_comp_id
                                 and    rtg.organization_id = arg_org_id));
  */
		exception
                    WHEN no_data_found THEN
                        var_line_id := NULL;
                end;
                if g_debug then
                    MRP_UTIL.MRP_LOG(' Line '|| to_char(var_line_id));
                end if;
                if var_line_id is not null then
                  -- If it's 1st level Subassembly, the component operation_seq_num
                  -- is the operation_seq_num obtained from the BOM. Otherwise,
                  -- it's the operation_seq_num of the 1st subassembly parent.
                  /* commented out for bug #1973152
                  if (curr_assy_count <> 1) then
                    var_operation_seq_num := assy_table(curr_assy_count).operation_seq_num;
		  end if;
			*/

		 if ((var_inherit_phantom = 1) and (curr_assy_count <> 1)) then
		       var_operation_seq_num := assy_table(curr_assy_count).operation_seq_num;
		 end if;

                  -- Get the corresponding line_op_seq_id for the given operation_seq_num in
                  -- the routing of the top assembly
                  begin
                    select line_op_seq_id
                    into var_line_op_seq_id
                    from bom_operation_sequences
                    where routing_sequence_id = var_routing_sequence_id
                      and operation_seq_num = var_operation_seq_num
                      and operation_type = 1
                      and effectivity_date =
                        (select max(effectivity_date)
                         from bom_operation_sequences
                         where routing_sequence_id = var_routing_sequence_id
                         and operation_seq_num = var_operation_seq_num
                         and operation_type = 1);

                  exception
                    WHEN no_data_found THEN
                        select concatenated_segments
			into var_comp_name
			from mtl_system_items_kfv
			where inventory_item_id = var_comp_id
			  and organization_id = arg_org_id;

                        fnd_message.set_name('FLM','FLM_SYNCH_INVALID_SEQ');
                        fnd_message.set_token('SCHEDULE',arg_schedule_number);
                        fnd_message.set_token('COMPONENT',var_comp_name);
			MRP_UTIL.MRP_LOG(fnd_message.get);
                        var_line_op_seq_id := NULL;
                        var_status := fnd_concurrent.set_completion_status( status => 'WARNING',
                                                                          message => '');

                  end;
                  if g_debug then
                    MRP_UTIL.MRP_LOG(' Line-Op : '|| to_char(var_line_op_seq_id));
                  end if;
                  if g_debug then
                    MRP_UTIL.MRP_LOG(' Line-op : '|| to_char(var_operation_seq_num));
                  end if;

                  -- Find out if the component used in the particular operation seq number has
                  -- been synchronized
                  select count(*)
                  into var_count
                  from wip_flow_schedules
                  where primary_item_id = var_comp_id
                    and NVL(synch_schedule_num,FND_API.G_MISS_CHAR) = arg_schedule_number
                    and NVL(synch_operation_seq_num,FND_API.G_MISS_NUM) = var_operation_seq_num;

                  -- Include only components that :
                  -- 1. hasn't been synchronized.
                  -- 2. feeder line goes into the primary path
                  if (var_count = 0 and is_valid_seq(var_line_op_seq_id)) then
                    max_comp_count := max_comp_count + 1;
                    arg_comp_table(max_comp_count).item_id := var_comp_id;
                    arg_comp_table(max_comp_count).usage := var_usage *
                                    assy_table(curr_assy_count).usage;
                    arg_comp_table(max_comp_count).line_id := var_line_id;
                    arg_comp_table(max_comp_count).operation_seq_num := var_operation_seq_num;
                    arg_comp_table(max_comp_count).line_op_seq_id := var_line_op_seq_id;

                    -- Added to support lot based material
		    -- Stores the basis type and qty per lot in the arg_comp_table
                    arg_comp_table(max_comp_count).basis_type := var_basis_type;
                    arg_comp_table(max_comp_count).qty_per_lot := var_qty_per_lot;

                  end if;
                end if;
            end if;
        END LOOP;
    END LOOP;
END;    -- end of procedure

PROCEDURE create_schedules(
                    errbuf                      out   NOCOPY  varchar2,
                    retcode                     out   NOCOPY  number,
                    arg_org_id                  in      number,
                    arg_min_line_code           in      varchar2,
                    arg_max_line_code           in      varchar2,
                    arg_start_date              in      varchar2,
                    arg_end_date                in      varchar2,
                    arg_commit                  in      varchar2 DEFAULT NULL)
IS
    CURSOR scheds(p_start_date DATE, p_end_date DATE, p_sysdate DATE) IS  --fix bug#3170105
    SELECT      flow.schedule_number,
		flow.build_sequence build_sequence,
                flow.primary_item_id primary_item_id,
                flow.line_id line_id,
                flow.planned_quantity planned_quantity,
                flow.scheduled_start_date scheduled_start_date,
                flow.scheduled_completion_date scheduled_completion_date,
                flow.alternate_bom_designator alternate_bom_designator,
                flow.alternate_routing_designator alternate_routing_designator,
		nvl(flow.roll_forwarded_flag,2) roll_forwarded_flag
    FROM        wip_flow_schedules flow,
                wip_lines lines
    WHERE       flow.planned_quantity - nvl(flow.quantity_completed, 0) > 0
    AND         flow.scheduled_start_date >= p_sysdate
    AND         flow.scheduled_start_date between p_start_date and p_end_date
    AND         flow.line_id = lines.line_id
    AND         flow.organization_id = lines.organization_id
    AND         lines.organization_id = arg_org_id
    AND         lines.line_code BETWEEN arg_min_line_code AND
                    arg_max_line_code;

    var_schedule_number     varchar2(30);
    var_build_seq_id        number;
    var_assy_item_id        number;
    var_line_id             number;
    var_qty                 number;
    var_start_date          date;
    var_completion_date     date;
    var_alt_bom             varchar2(10);
    var_alt_rtg             varchar2(10);
    var_comp_tbl            comp_list;
    var_x                   number;
    var_y                   number;
    var_count               number;
    var_current_row         number;
    var_bom_exists          number;
    var_rtg_exists          number;
    loop_count              number;
    var_roll_forwarded_flag number;

    -- declarations reqd for Flow schedule API
    l_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
    l_x_flow_schedule_rec   MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
    l_old_flow_schedule_rec
                            MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
    l_control_rec           MRP_GLOBALS.Control_Rec_Type := MRP_GLOBALS.G_MISS_CONTROL_REC;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(240);

    l_fast_feeder_line      NUMBER;

    --fix bug#3170105
    l_start_date            DATE;
    l_end_date              DATE;
    l_sysdate               DATE;
    --end of fix bug#3170105

begin

    g_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

    --fix bug#3170105
    flm_timezone.init_timezone(arg_org_id);
    l_start_date := flm_timezone.client_to_server(fnd_date.canonical_to_date(arg_start_date));
    l_end_date :=  flm_timezone.client_to_server(fnd_date.canonical_to_date(arg_end_date))+1-1/(24*60*60);
    l_sysdate := flm_timezone.sysdate00_in_server;
    --end of fix bug#3170105

    FOR scheds1 IN scheds(l_start_date, l_end_date, l_sysdate) LOOP  --fix bug#3170105
        var_build_seq_id := scheds1.build_sequence;
        var_schedule_number := scheds1.schedule_number;
        var_assy_item_id := scheds1.primary_item_id;
        var_line_id := scheds1.line_id;
        var_qty := scheds1.planned_quantity;
        var_start_date := scheds1.scheduled_start_date;
        var_completion_date := scheds1.scheduled_completion_date;
        var_alt_bom := scheds1.alternate_bom_designator;
        var_alt_rtg := scheds1.alternate_routing_designator;
	var_roll_forwarded_flag := scheds1.roll_forwarded_flag;

        if (var_roll_forwarded_flag = 1) then
          fnd_message.set_name('FLM','FLM_SYNCH_ROLL_FORWARDED');
          fnd_message.set_token('SCHEDULE',var_schedule_number);
	  MRP_UTIL.MRP_LOG(fnd_message.get);
        else
          if g_debug then
              MRP_UTIL.MRP_LOG('Retrieved Schedules '||
                                   ' Assy '|| to_char(var_assy_item_id) ||
                                   ' Line '|| to_char(var_line_id) ||
                                   ' Qty '||  to_char(var_qty) ||
                                   ' Start Date'|| to_char(var_start_date) ||
                                   ' Alt BOM ' || var_alt_bom ||
                                   ' Alt Rtg ' || var_alt_rtg);
          end if;

          -- Make sure to empty out the pl/sql table. Fix bug 1125219
          if (var_comp_tbl.COUNT <> 0) then
            var_comp_tbl.DELETE;
          end if;

          -- get all the sub components for this assembly
          get_subassemblies(arg_org_id,
  			    var_schedule_number,
                            var_assy_item_id,
                            var_alt_bom,
                            var_alt_rtg,
                            var_start_date,
                            var_comp_tbl);

          var_current_row := 1;

          while var_comp_tbl.EXISTS(var_current_row) LOOP
            if g_debug then
                MRP_UTIL.MRP_LOG(
                        ' Component '||
                            to_char(var_comp_tbl(var_current_row).item_id) ||
                        ' Usage '||
                            to_char(var_comp_tbl(var_current_row).usage));
            end if;
            select  count(*)
            INTO    var_rtg_exists
            from    bom_operational_routings rtg
            where   rtg.organization_id = arg_org_id
            and     rtg.assembly_item_id =
                        var_comp_tbl(var_current_row).item_id
            and     NVL(rtg.alternate_routing_designator, 'ABD756fhh456') =
                        NVL(var_alt_rtg, 'ABD756fhh456');

            select  count(*)
            INTO    var_bom_exists
            from    bom_bill_of_materials bom
            where   bom.organization_id = arg_org_id
            and     bom.assembly_item_id =
                        var_comp_tbl(var_current_row).item_id
            and     NVL(bom.alternate_bom_designator, 'ABD756fhh456') =
                        NVL(var_alt_bom, 'ABD756fhh456');

            -- create flow schedule using the API
            l_flow_schedule_rec.organization_id := arg_org_id;
            l_flow_schedule_rec.primary_item_id :=
                var_comp_tbl(var_current_row).item_id;

            -- Added for Lot Based Material Support
            -- For item basis type, the usage is the subassembly cumulative usage * flow schedule qty
            -- For lot basis type, the usage is the qty per assembly for that subassembly.
  	    if (var_comp_tbl(var_current_row).basis_type = WIP_CONSTANTS.ITEM_BASED_MTL) then
		l_flow_schedule_rec.planned_quantity := var_comp_tbl(var_current_row).usage * var_qty;
	    else
                l_flow_schedule_rec.planned_quantity := var_comp_tbl(var_current_row).qty_per_lot;
	    end if;

            l_flow_schedule_rec.line_id :=
                var_comp_tbl(var_current_row).line_id;
            if var_bom_exists = 1 then
                l_flow_schedule_rec.alternate_bom_designator := var_alt_bom;
            else
                l_flow_schedule_rec.alternate_bom_designator := null;
            end if;
            if var_rtg_exists = 1 then
                l_flow_schedule_rec.alternate_routing_desig := var_alt_rtg;
            else
                l_flow_schedule_rec.alternate_routing_desig := null;
            end if;

            /* Added for bug 2373141 */
            Select (fl.maximum_rate - ml.maximum_rate)
            INTO   l_fast_feeder_line
            FROM   wip_lines fl, wip_lines ml
            Where  ml.line_id = var_line_id
            and    fl.line_id = var_comp_tbl(var_current_row).line_id;
            /* Added for bug 2373141 */

             l_flow_schedule_rec.scheduled_completion_date :=
              feeder_line_comp_date ( arg_org_id, var_line_id,
                                      var_assy_item_id, var_start_date, var_completion_date,
                         	      var_comp_tbl(var_current_row).line_op_seq_id ,var_qty, l_fast_feeder_line);

            l_flow_schedule_rec.scheduled_start_date :=
               feeder_line_start_date ( arg_org_id, l_flow_schedule_rec.line_id,
                                        l_flow_schedule_rec.primary_item_id,
                                        l_flow_schedule_rec.planned_quantity,
                                        l_flow_schedule_rec.scheduled_completion_date);

            l_flow_schedule_rec.synch_schedule_num := var_schedule_number;
            l_flow_schedule_rec.synch_operation_seq_num := var_comp_tbl(var_current_row).operation_seq_num;
            l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;

            --  check if build sequence exists for same line, org,
            --  component combination from wip_flow_schedules
            var_count := 0;
            loop_count := 1;
            var_build_seq_id := scheds1.build_sequence;
            LOOP
                select  count(*)
                into    var_count
                from    wip_flow_schedules flow
                where
--			flow.primary_item_id =
--                            var_comp_tbl(var_current_row).item_id
--                and
			flow.line_id =
                            var_comp_tbl(var_current_row).line_id
                and     flow.organization_id = arg_org_id
                and     flow.build_sequence = var_build_seq_id
		and     scheduled_completion_date between  --fix bug#3170105
                        l_flow_schedule_rec.scheduled_completion_date and
                        l_flow_schedule_rec.scheduled_completion_date+1-(1/(24*60*60));

                loop_count := loop_count + 1;

                EXIT WHEN var_count = 0;
                if g_debug then
                    MRP_UTIL.MRP_LOG('Found build sequence '||
                        to_char(var_build_seq_id));
                end if;
                var_x := ROUND(1/(10*loop_count), 6);
                var_y := ROUND(1/(10*(loop_count-1)), 6);
                if var_x = var_y then
                    var_x := ROUND(1/(10*loop_count),1) + 0.1;
                end if;
                if var_count > 0 then
                    var_build_seq_id := var_build_seq_id + var_x;
                end if;
            END LOOP;

            -- at this point, var_build_seq_id holds the correct build_sequence
            l_flow_schedule_rec.build_sequence := var_build_seq_id;

            if g_debug then
                MRP_UTIL.MRP_LOG('Creating schedule: '||
                    ' Assy ' ||
                    to_char(l_flow_schedule_rec.primary_item_id) ||
                    ' Line ' ||
                    to_char(l_flow_schedule_rec.line_id) ||
                    ' Alt BOM '||
                    l_flow_schedule_rec.alternate_bom_designator ||
                    ' Alt Rtg '||
                    l_flow_schedule_rec.alternate_routing_desig ||
                    ' Date '||
                    to_char(l_flow_schedule_rec.scheduled_completion_date) ||
                    ' Build Sequence ' ||
                    to_char(l_flow_schedule_rec.build_sequence) ||
                    ' Qty ' ||
                    to_char(l_flow_schedule_rec.planned_quantity));
            end if;

            /* Added p_explode_bom for bug number 2079836 */
            MRP_Flow_Schedule_PVT.Process_Flow_Schedule(
                p_api_version_number    => 1.0,
                p_init_msg_list         => FND_API.G_TRUE,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
		p_control_rec		=> l_control_rec,
                p_flow_schedule_rec     => l_flow_schedule_rec,
                x_flow_schedule_rec     => l_x_flow_schedule_rec,
                p_old_flow_schedule_rec => l_old_flow_schedule_rec,
                p_explode_bom           => 'Y');

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            var_current_row := var_current_row + 1;

          end loop; -- end of while loop

        end if; -- end of if (var_roll_forwarded_flag = 2)

    END LOOP;  -- end of FOR scheds1 IN scheds LOOP

    if NVL(arg_commit,'Y') = 'Y' then
        COMMIT;
    end if;

end;  -- end of procedure


END;  -- package

/
