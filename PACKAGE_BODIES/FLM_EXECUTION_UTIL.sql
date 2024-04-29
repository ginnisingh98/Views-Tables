--------------------------------------------------------
--  DDL for Package Body FLM_EXECUTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_EXECUTION_UTIL" AS
/* $Header: FLMEXUTB.pls 120.20.12010000.2 2009/06/22 09:42:18 adasa ship $  */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'FLM_EXECUTION_UTIL';

  FUNCTION get_view_all_schedules(
                                 p_organization_id IN NUMBER,
                                 p_line_id         IN NUMBER,
                                 p_operation_id    IN NUMBER
                                 )
  RETURN VARCHAR2
  IS
    l_org_id NUMBER;
    l_line_id NUMBER;
    l_operation_id NUMBER;
    l_view_all_sch VARCHAR2(1);

  CURSOR c_view_all_lineop IS
  SELECT VIEW_ALL_SCHEDULES
  FROM   FLM_EXE_PREFERENCES
  WHERE  ORGANIZATION_ID = l_org_id
    AND  LINE_ID = l_line_id
    AND  STANDARD_OPERATION_ID = l_operation_id;

  CURSOR c_view_all_line IS
  SELECT VIEW_ALL_SCHEDULES
  FROM   FLM_EXE_PREFERENCES
  WHERE  ORGANIZATION_ID = l_org_id
    AND  LINE_ID = l_line_id
    AND  STANDARD_OPERATION_ID IS NULL;

  CURSOR c_view_all_org IS
  SELECT VIEW_ALL_SCHEDULES
  FROM   FLM_EXE_PREFERENCES
  WHERE  ORGANIZATION_ID = l_org_id
   AND   LINE_ID IS NULL
   AND   STANDARD_OPERATION_ID IS NULL;

  BEGIN
    l_org_id := p_organization_id;
    l_line_id := p_line_id;
    l_operation_id := p_operation_id;

    --Find preference at line op level
    FOR view_all_lineop_rec in c_view_all_lineop LOOP
      l_view_all_sch := view_all_lineop_rec.view_all_schedules;
    END LOOP;

    --If lineop level pref doesn't exist, find line level
    IF (l_view_all_sch is null) THEN
      FOR view_all_line_rec in c_view_all_line LOOP
        l_view_all_sch := view_all_line_rec.view_all_schedules;
      END LOOP;
    END IF;

    --If line level pref doesn't exist, find org level
    IF (l_view_all_sch is null) THEN
      FOR view_all_org_rec in c_view_all_org LOOP
        l_view_all_sch := view_all_org_rec.view_all_schedules;
      END LOOP;
    END IF;

    --Finally if no level exist, return default value
    IF(l_view_all_sch is null) THEN
      l_view_all_sch := 'N';
    END IF;

    RETURN l_view_all_sch;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END get_view_all_schedules;


FUNCTION view_all_schedules(i_op_seq_id  IN NUMBER) RETURN VARCHAR2 IS
  l_org_id       NUMBER;
  l_line_id      NUMBER;
  l_std_op_id    NUMBER;
  l_view_all_sch VARCHAR2(1);

  CURSOR c_rtg IS
  select bor.organization_id,
         bor.line_id,
         bos.standard_operation_id
  from   bom_operational_routings bor,
         bom_operation_sequences bos
  where  bos.routing_sequence_id = bor.routing_sequence_id
    and  bos.operation_sequence_id = i_op_seq_id;

BEGIN

  FOR c_rtg_rec in c_rtg LOOP
    l_org_id    := c_rtg_rec.organization_id;
    l_line_id   := c_rtg_rec.line_id;
    l_std_op_id := c_rtg_rec.standard_operation_id;
  END LOOP;
  l_view_all_sch := get_view_all_schedules(l_org_id, l_line_id, l_std_op_id);

  return (l_view_all_sch);

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END view_all_schedules;



PROCEDURE debug_output(info VARCHAR2) IS
BEGIN
  --dbms_output.put_line(info);
  null;
END;

  /******************************************************************
   * To get workstation_enabled flag for given preference by        *
   * (org_id, line_id, operation_id). If the pref. does not exist,  *
   * retrieve it from its upper-leve; if the upper-level does not   *
   * exist, return the default flag 'Y'                             *
   ******************************************************************/
  PROCEDURE get_workstation_enabled(
                                 p_organization_id IN NUMBER,
                                 p_line_id IN NUMBER,
                                 p_operation_id IN NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 x_workstation_enabled OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2
                                 )
  IS
    l_org_id NUMBER;
    l_line_id NUMBER;
    l_operation_id NUMBER;

  CURSOR c_wkstn_enabled IS
  SELECT
    WORKSTATION_ENABLED
  FROM
    FLM_EXE_PREFERENCES
  WHERE
    NVL(ORGANIZATION_ID,-1) = NVL(l_org_id,-1) AND
    NVL(LINE_ID,-1) = NVL(l_line_id,-1) AND
    NVL(STANDARD_OPERATION_ID,-1) = nvl(l_operation_id,-1);

  BEGIN

    --SAVEPOINT get_workstation_enabled;

    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_workstation_enabled := 'Y';

    l_org_id := p_organization_id;
    l_line_id := p_line_id;
    l_operation_id := p_operation_id;

    OPEN c_wkstn_enabled;

    FETCH c_wkstn_enabled INTO x_workstation_enabled;

    IF c_wkstn_enabled%NOTFOUND THEN
      CLOSE c_wkstn_enabled;

      -- look at upper-level preference
      IF (p_line_id is not null) THEN
        l_line_id := null;
        l_operation_id := null;

        IF (p_operation_id is not null) THEN
          l_line_id := p_line_id;
        END IF;

        OPEN c_wkstn_enabled;
        FETCH c_wkstn_enabled INTO x_workstation_enabled;
        IF c_wkstn_enabled%NOTFOUND THEN --line level does not exist, fetch org level
          CLOSE c_wkstn_enabled;
          l_line_id := null;
          l_operation_id := null;
          OPEN c_wkstn_enabled;
          FETCH c_wkstn_enabled INTO x_workstation_enabled;
        ELSE
          CLOSE c_wkstn_enabled;
        END IF;

      END IF;
    ELSE
      -- preference found
      CLOSE c_wkstn_enabled;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_workstation_enabled := 'N';
      ROLLBACK TO get_workstation_enabled;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_exe_pref' ,'get_workstation_enabled');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END get_workstation_enabled;


FUNCTION workstation_enabled(i_op_seq_id  IN NUMBER) RETURN VARCHAR2 IS
  l_org_id NUMBER;
  l_line_id NUMBER;
  l_std_op_id NUMBER;
  l_enabled VARCHAR2(10);
  l_status VARCHAR2(10);
  l_msg_cnt NUMBER;
  l_msg VARCHAR2(2000);
BEGIN
  -- get parameter
  select bor.organization_id, bor.line_id, bos.standard_operation_id
  into l_org_id, l_line_id, l_std_op_id
  from bom_operational_routings bor,
       bom_operation_sequences bos
  where bos.routing_sequence_id = bor.routing_sequence_id
    and bos.operation_sequence_id = i_op_seq_id;
  -- get enabled
  get_workstation_enabled(
      p_organization_id => l_org_id,
      p_line_id => l_line_id,
      p_operation_id => l_std_op_id,
      p_init_msg_list => 'T',
      x_workstation_enabled => l_enabled,
      x_return_status => l_status,
      x_msg_count => l_msg_cnt,
      x_msg_data => l_msg);
  RETURN l_enabled;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END workstation_enabled;


FUNCTION Operation_Eligible(i_org_id	IN NUMBER,
                            i_wip_entity_id 	IN NUMBER,
                            i_std_op_id	IN NUMBER) RETURN VARCHAR2 IS

  l_cnt	NUMBER := 0;
  l_op_seq_id NUMBER := 0;

  -- Cursor to find the sequence id of the operation in the routing
  -- corresponding to the schedule that references the specified
  -- standard operation.
  CURSOR op_seq_csr IS
    select bos.operation_sequence_id
    from bom_operation_sequences bos,
         wip_flow_schedules wfs,
         bom_operational_routings bor
    where wfs.wip_entity_id = i_wip_entity_id
      and bor.organization_id = i_org_id
      and bor.assembly_item_id = wfs.primary_item_id
      and nvl(bor.alternate_routing_designator, '########') = nvl(wfs.alternate_routing_designator, '########')
      and bor.common_routing_sequence_id = bos.routing_sequence_id
      and bos.operation_type = 3 -- line operation
      and bos.standard_operation_id = i_std_op_id;
  -- Cursor to find out starting operations of this routing
  CURSOR start_op_csr IS
    select bos.operation_sequence_id seq_id,
           bos.operation_seq_num seq_num
    from bom_operation_sequences bos,
         wip_flow_schedules wfs,
         bom_operational_routings bor
    where wfs.wip_entity_id = i_wip_entity_id
      and bor.organization_id = i_org_id
      and bor.assembly_item_id = wfs.primary_item_id
      and nvl(bor.alternate_routing_designator, '@@@@@@@@') = nvl(wfs.alternate_routing_designator, '@@@@@@@@')
      and bor.common_routing_sequence_id = bos.routing_sequence_id
      and bos.operation_type = 3 -- line operation
      and not exists (select '1'
                      from bom_operation_networks bon
                      where bon.to_op_seq_id = bos.operation_sequence_id
                        and bon.transition_type in (1, 2))
    order by bos.operation_seq_num;

  --cursor to find out if some operation is current for a schedule and disbaled
  CURSOR sch_cur_op_csr IS
    select next_op_seq_id seq_id
    from flm_exe_operations
    where wip_entity_id = i_wip_entity_id
    and flm_execution_util.workstation_enabled(next_op_seq_id) = 'N'
    order by next_op_seq_id;
  l_view_all_sch VARCHAR2(1);

BEGIN


  -- Is this operation in the routing of the assembly for the schedule?
  OPEN op_seq_csr;
  FETCH op_seq_csr INTO l_op_seq_id;
  IF op_seq_csr%NOTFOUND THEN
    CLOSE op_seq_csr;
    --debug_output('op not in routing');
    RETURN 'N';
  END IF;
  CLOSE op_seq_csr;

  --if view_all_schedules preference is set to yes, then only need to
  --perform validation that schedule is not already completed on this op
  l_view_all_sch := view_all_schedules(l_op_seq_id);
  if(l_view_all_sch = 'Y' ) then
    -- has this operation been completed?
    select count(*)
    into   l_cnt
    from   flm_exe_operations
    where  wip_entity_id = i_wip_entity_id
      and  operation_sequence_id = l_op_seq_id
      and  organization_id = i_org_id;
    IF l_cnt > 0 THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  end if;

  -- Is this operation current?
  select count(*)
  into l_cnt
  from flm_exe_operations
  where wip_entity_id = i_wip_entity_id
    and next_op_seq_id = l_op_seq_id
    and organization_id = i_org_id
    and current_flag = 'Y';
  IF l_cnt > 0 THEN
    RETURN 'Y';
  END IF;

  -- has this operation been completed?
  select count(*)
  into l_cnt
  from flm_exe_operations
  where wip_entity_id = i_wip_entity_id
    and operation_sequence_id = l_op_seq_id
    and organization_id = i_org_id;
  IF l_cnt > 0 THEN
    RETURN 'N';
  END IF;

  -- Is this operation the start point of its path (or are all operations
  -- before it on the path workstation-disabled?)
  select count(*)
  into l_cnt
  from bom_operation_networks
  where to_op_seq_id = l_op_seq_id
    and transition_type in (1,2);
  IF l_cnt <= 0 THEN
    --debug_output('start of network');
    RETURN 'Y';
  END IF;

  --find out if connection from start op to this operation consist of all disbaled workstations
  FOR op_rec IN start_op_csr LOOP
    select count(*)
    into l_cnt
    from bom_operation_networks
    where to_op_seq_id = l_op_seq_id
      and flm_execution_util.workstation_enabled(from_op_seq_id) = 'N'
      and flm_execution_util.workstation_enabled(op_rec.seq_id) = 'N'
    start with from_op_seq_id = op_rec.seq_id
    connect by prior to_op_seq_id = from_op_seq_id
                 and transition_type in (1, 2)
                 and flm_execution_util.workstation_enabled(from_op_seq_id) = 'N';
    IF l_cnt > 0 THEN
      RETURN 'Y';
    END IF;
  END LOOP;

  --return true if there is connection between current op and given lineop consist of all disabled ws
  FOR op_rec IN sch_cur_op_csr LOOP
    select count(*)
    into l_cnt
    from bom_operation_networks
    where to_op_seq_id = l_op_seq_id
      and flm_execution_util.workstation_enabled(from_op_seq_id) = 'N'
    start with from_op_seq_id = op_rec.seq_id
    connect by prior to_op_seq_id = from_op_seq_id
                 and transition_type in (1, 2)
                 and flm_execution_util.workstation_enabled(from_op_seq_id) = 'N';
    IF l_cnt > 0 THEN
      RETURN 'Y';
    END IF;
  END LOOP;

  --if none of the conditions are true then this schedule is not current for this operation
  RETURN 'N';

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';

END operation_eligible;


PROCEDURE complete_operation(i_org_id number,
				i_wip_entity_id	number,
				i_op_seq_id	number,
				i_next_op_id	number) IS
BEGIN
  insert into flm_exe_operations (
	wip_entity_id,
	organization_id,
	operation_sequence_id,
	next_op_seq_id,
	current_flag,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	object_version_number
  ) values (
	i_wip_entity_id,
	i_org_id,
	i_op_seq_id,
	i_next_op_id,
	'Y',
	1111,
	sysdate,
	1111,
	sysdate,
	1111,
	1
  );

  update flm_exe_operations
  set current_flag = 'N',
      object_version_number = object_version_number + 1
  where next_op_seq_id = i_op_seq_id
    and wip_entity_id = i_wip_entity_id;

END complete_operation;


/******************************************************************
 * To get the components for schedule assembly bom                *
 ******************************************************************/
PROCEDURE get_custom_attributes (p_wip_entity_id IN NUMBER,
                                 p_op_seq_id IN NUMBER,
                                 p_op_type IN NUMBER, --1event,2process,3lineop
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2,
                                 x_cust_attrib_tab OUT NOCOPY System.FlmCustomPropRecTab) IS
l_ret_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_cust_attrib_tab FLM_CUST_ATTRIBUTE_TBL;
l_out_attrib_tab System.FlmCustomPropRecTab := System.FlmCustomPropRecTab();

BEGIN
  get_attributes (1.0, --api_version
                  p_wip_entity_id,
                  p_op_seq_id,
                  p_op_type,
                  l_cust_attrib_tab,
                  l_ret_status,
                  l_msg_count,
                  l_msg_data);

  IF(l_cust_attrib_tab.COUNT > 0) THEN
    l_out_attrib_tab.EXTEND(l_cust_attrib_tab.COUNT);
    FOR i in l_cust_attrib_tab.FIRST .. l_cust_attrib_tab.LAST
    LOOP
      l_out_attrib_tab(i) := System.FlmCustomPropRecType(
        l_cust_attrib_tab(i).ATTRIBUTE_NAME,
        l_cust_attrib_tab(i).ATTRIBUTE_VALUE);

    END LOOP;

    x_cust_attrib_tab := l_out_attrib_tab;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_custom_attributes;


PROCEDURE get_attributes (p_api_version_number IN  NUMBER,
                          p_wip_entity_id      IN  NUMBER,
                          p_op_seq_id          IN  NUMBER,
                          p_op_type            IN  NUMBER,
                          p_cust_attrib_tab    OUT NOCOPY FLM_CUST_ATTRIBUTE_TBL,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2) IS
  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Get_Attributes';

BEGIN
  IF NOT FND_API.Compatible_API_Call
        (       l_api_version_number,
                p_api_version_number,
                l_api_name,
                G_PKG_NAME)
  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Add custom  code here
  --Example
  FOR i in 1 .. 5 LOOP
    p_cust_attrib_tab(i).ATTRIBUTE_NAME := 'Property'||to_char(i)||' Name';
    p_cust_attrib_tab(i).ATTRIBUTE_VALUE := 'Property'||to_char(i)||' Value';
  END LOOP;
  --End of custom code

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Get message count and data
  FND_MSG_PUB.Count_And_Get
  (   p_count   => x_msg_count,
      p_data    => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Attribute'
            );
    END IF;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

END get_attributes;


FUNCTION check_phantom (p_top_bill_seq_id NUMBER,
                        p_explosion_type VARCHAR2,
                        p_org_id IN NUMBER,
                        p_comp_seq_id IN NUMBER,
                        p_sort_order IN VARCHAR2) RETURN NUMBER IS

l_sort_order VARCHAR2(240);
l_sort_order_length NUMBER;
l_loop_count NUMBER;
l_temp_sort_order VARCHAR2(240);
l_overall_count NUMBER := 0;
l_count NUMBER := 0;
l_sort_code_width NUMBER := BOM_COMMON_DEFINITIONS.G_Bom_SortCode_Width;

CURSOR bom_cursor (bill_seq IN NUMBER,
                   exp_type IN VARCHAR2,
                   sort_ord IN VARCHAR2) IS
select count(top_bill_sequence_id) count
from  bom_explosions be, bom_inventory_components bic
where top_bill_sequence_id = bill_seq
      and explosion_type = exp_type
      and sort_order = sort_ord
      and be.component_sequence_id = bic.component_sequence_id
      and bic.wip_supply_type <> 6;

BEGIN
  l_sort_order := p_sort_order;
  l_sort_order := substr(l_sort_order, 0, length(l_sort_order)-l_sort_code_width);
  l_sort_order_length := length(l_sort_order);
  l_loop_count := l_sort_order_length/l_sort_code_width;

  FOR i in 2 .. l_loop_count LOOP
    l_temp_sort_order := substr(l_sort_order,0,i*l_sort_code_width);
    l_count := 0;

    FOR l_bom_cr in bom_cursor(p_top_bill_seq_id, p_explosion_type,l_temp_sort_order) LOOP
      l_count := l_bom_cr.count;
    END loop;

    l_overall_count := l_overall_count + l_count;

  END LOOP;

  return l_overall_count;

END check_phantom;


FUNCTION get_current_rev (p_org_id NUMBER,
                          p_component_item_id NUMBER) RETURN VARCHAR2 IS
l_current_rev VARCHAR2(3);
BEGIN


  bom_revisions.Get_Revision(
    type         => 'PART',
    eco_status   => 'ALL',
    examine_type => 'IMPL_ONLY',
    org_id       => p_org_id,
    item_id      => p_component_item_id,
    rev_date     => sysdate,
    itm_rev      => l_current_rev);

  return l_current_rev;

END get_current_rev;


FUNCTION get_reference_designator(p_comp_seq_id NUMBER) RETURN VARCHAR2 IS
CURSOR ref_desig IS
  select component_reference_designator
  from   bom_reference_designators
  where  component_sequence_id = p_comp_seq_id
  order by component_reference_designator;
desig_string VARCHAR2(40);
ref_count NUMBER;
begin

  ref_count := 0;
  for ref_desig_c IN ref_desig LOOP
    ref_count := ref_count+1;
    if(ref_count = 1) then
      desig_string := ref_desig_c.component_reference_designator;
    elsif( (ref_count > 1) AND (ref_count < g_ref_desig_max_count+1) ) then
      desig_string := desig_string||g_ref_desig_separator||ref_desig_c.component_reference_designator;
    elsif(ref_count > g_ref_desig_max_count) then
     desig_string := desig_string||g_ref_desig_terminator;
     exit;
    end if;
  end loop;
  return desig_string;

end get_reference_designator;


procedure pick_release(p_wip_entity_id NUMBER,
                       p_org_id NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_data OUT NOCOPY VARCHAR2) IS
  l_alloc_tbl wip_picking_pub.allocate_tbl_t;
  l_plan_tasks BOOLEAN;
  l_cutoff_date DATE;
  l_mo_req_number VARCHAR2(30);
  l_conc_req_id NUMBER;
  l_print_pickslips VARCHAR2(1);
  l_grouping_rule NUMBER := -1;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);

  CURSOR c_default_pick_group IS
    select pickslip_grouping_rule_id
    from   wip_parameters
    where  organization_id = p_org_id;

begin

  l_alloc_tbl(1).wip_entity_id := p_wip_entity_id;

  l_alloc_tbl(1).use_pickset_flag := 'Y';
  l_cutoff_date := null;
  l_plan_tasks := FALSE;
  l_print_pickslips := 'T';
  --l_grouping_rule := ????;

  FOR l_pick_grp in c_default_pick_group LOOP
    l_grouping_rule := l_pick_grp.pickslip_grouping_rule_id;
  END LOOP;

  if(l_grouping_rule = -1)  then--no grouping rule found
    x_return_status := 'F';
    return;
  end if;

  wip_picking_pub.allocate(p_alloc_tbl             => l_alloc_tbl,
                           p_wip_entity_type       => 4,
                           p_cutoff_date           => l_cutoff_date,
                           p_organization_id       => p_org_id,
			   p_pick_grouping_rule_id => l_grouping_rule,
                           p_print_pick_slip       => l_print_pickslips,
			   p_plan_tasks            => l_plan_tasks,
			   x_mo_req_number         => l_mo_req_number,
			   x_conc_req_id           => l_conc_req_id,
                           x_return_status         => l_return_status,
                           x_msg_data              => l_msg_data);

  --return status = S for Successful, F for Fail
  if(l_return_status = 'P') then
    x_return_status := 'F';
  elsif(l_return_status = 'N') then
    x_return_status := 'F';
  elsif(l_return_status = fnd_api.g_ret_sts_success) then
    x_return_status := 'S';
  else
    x_return_status := 'S';
  end if;
  x_msg_data := l_msg_data;
  return;

end pick_release;



/****************************************************
 * This function  finds out if the current move     *
 * is within from primary path or from feeder line  *
 * return_status = 'Y' for feeder move              *
 * return_status = 'N' for primary path move        *
 ***************************************************/
function is_move_from_feeder(p_from_op_seq_id NUMBER,
                              p_to_op_seq_id NUMBER) return VARCHAR2 IS

l_ret_val_no VARCHAR2(1) := 'N';
l_ret_val_yes VARCHAR2(1) := 'Y';
l_op_seq_id NUMBER;
l_from_op_seq_id NUMBER;
l_to_op_seq_id NUMBER;

CURSOR start_op_csr IS
select min(operation_seq_num) operation_seq_num from
(
  select myFrom, operation_seq_num from
  (
    select from_op_seq_id myFrom, to_op_seq_id, transition_type, operation_seq_num
    from   bom_operation_networks, bom_operation_sequences
    where  from_op_seq_id = operation_sequence_id
    start with to_op_seq_id = l_op_seq_id and transition_type in (1,2)
    connect by PRIOR from_op_seq_id = to_op_seq_id
    and transition_type in (1,2)
  )
  where not exists
  (select from_op_seq_id
   from   bom_operation_networks
   where  to_op_seq_id = myFrom
          and transition_type in (1,2)
  )
);

cursor incoming_op_csr IS
select from_op_seq_id
from   bom_operation_networks
where  to_op_seq_id = l_to_op_seq_id
       and transition_type in (1,2)
       and from_op_seq_id not in (l_from_op_seq_id);

cursor op_seq_num_csr IS
select operation_seq_num
from   bom_operation_sequences
where  operation_sequence_id = l_op_seq_id;

cursor incoming_op_count_csr IS
select count(from_op_seq_id) op_count
from   bom_operation_networks
where  to_op_seq_id = l_to_op_seq_id
       and transition_type in (1,2);


l_cur_min_op_seq_num NUMBER := -1;
l_other_min_op_seq_num NUMBER := -1;
BEGIN

  --if only one operation, then its not the feeder injection
  l_to_op_seq_id := p_to_op_seq_id;
  for incoming_count_csr in incoming_op_count_csr loop
    if(nvl(incoming_count_csr.op_count,0) < 2) then
      return l_ret_val_no;
    end if;
  end loop;

  --first find out the minimum starting op seq on the current path
  l_op_seq_id := p_from_op_seq_id;
  for l_start in start_op_csr loop
    l_cur_min_op_seq_num := l_start.operation_seq_num;
  end loop;
  if(l_cur_min_op_seq_num = -1) then
    l_op_seq_id := p_from_op_seq_id;
    for l_seq in op_seq_num_csr loop
      l_cur_min_op_seq_num := l_seq.operation_seq_num;
    end loop;
  end if;

  --if current starting op is greater than any start op on other path
  --then this definitely is a feeder
  l_from_op_seq_id := p_from_op_seq_id;
  l_to_op_seq_id := p_to_op_seq_id;
  for incoming_csr in incoming_op_csr loop

    l_op_seq_id := incoming_csr.from_op_seq_id;
    l_other_min_op_seq_num := -1;
    for l_start in start_op_csr loop
      l_other_min_op_seq_num := nvl(l_start.operation_seq_num,-1);
    end loop;

    if(l_other_min_op_seq_num = -1) then
      for l_seq in op_seq_num_csr loop
        l_other_min_op_seq_num := l_seq.operation_seq_num;
      end loop;
    end if;

    if(l_cur_min_op_seq_num >  l_other_min_op_seq_num) then
      return l_ret_val_yes;
    end if;

  end loop;

  -- return no if not feeder yet
  return l_ret_val_no;

EXCEPTION
  when others then
    return l_ret_val_no;

end is_move_from_feeder;


procedure generate_serial_to_record(p_org_id          IN NUMBER,
                                    p_wip_entity_id   IN NUMBER,
                                    p_primary_item_id IN NUMBER,
                                    p_gen_qty         IN NUMBER,
                                    x_ret_code        OUT NOCOPY VARCHAR2,
                                    x_msg_buf         OUT NOCOPY VARCHAR2) IS

l_org_id          NUMBER;
l_wip_entity_id   NUMBER;
l_primary_item_id NUMBER;
l_gen_qty         NUMBER;
l_ret_code        VARCHAR2(10);
l_err_buf         VARCHAR2(2000);
BEGIN
  l_org_id          := p_org_id;
  l_wip_entity_id   := p_wip_entity_id;
  l_primary_item_id := p_primary_item_id;
  l_gen_qty         := p_gen_qty;

  INV_SERIAL_NUMBER_PUB.GENERATE_SERIALS
  (
    x_retcode     => l_ret_code,
    x_errbuf      => l_err_buf,
    p_org_id      => l_org_id,
    p_item_id     => l_primary_item_id,
    p_qty         => l_gen_qty,
    p_serial_code => null,
    p_wip_id      => null,
    p_rev         => null,
    p_lot         => null
  );
  x_ret_code := l_ret_code;
  x_msg_buf := l_err_buf;

END generate_serial_to_record;


PROCEDURE generate_lot_to_record (p_org_id          IN NUMBER,
                                  p_primary_item_id IN NUMBER,
                                  o_lot_number      OUT NOCOPY VARCHAR2,
                                  x_return_status   OUT NOCOPY VARCHAR2,
                                  x_msg_count       OUT NOCOPY NUMBER,
                                  x_msg_data        OUT NOCOPY VARCHAR2) IS
l_lot_number VARCHAR2(30);
l_object_id NUMBER;
l_exp_date DATE := null;
BEGIN
  l_lot_number := inv_lot_api_pub.auto_gen_lot(
                    p_org_id            => p_org_id,
                    p_inventory_item_id => p_primary_item_id,
                    p_api_version       => 1.0,
                    p_commit            => fnd_api.g_true,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data);
  if(x_return_status = 'S') then
	  INV_LOT_API_PUB.InsertLot (
	    p_api_version       => 1.0,
	    p_init_msg_list     => 'F',
	    p_commit            => 'T',
	    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
	    p_inventory_item_id => p_primary_item_id,
	    p_organization_id   => p_org_id,
	    p_lot_number        => l_lot_number,
	    p_expiration_date   => l_exp_date,
	    x_object_id         => l_object_id,
	    x_return_status     => x_return_status,
	    x_msg_count         => x_msg_count,
	    x_msg_data          => x_msg_data );

	  if(x_return_status = 'S') then
      o_lot_number := l_lot_number;
    else
      o_lot_number := null;
    end if;
   END IF;
END generate_lot_to_record;


PROCEDURE get_eligible_ops (p_org_id        IN NUMBER,
                            p_line_id       IN NUMBER,
                            p_rtg_seq_id    IN NUMBER,
                            p_wip_entity_id IN NUMBER,
                            x_lop_tbl       OUT NOCOPY operation_seq_tbl_type) IS
CURSOR all_ops(p_rtg_seq_id NUMBER) IS
  select operation_sequence_id
  from   bom_operation_sequences
  where  routing_sequence_id = p_rtg_seq_id
    and  operation_type = 3;

CURSOR lowest_op(p_rtg_seq_id NUMBER) IS
  select operation_sequence_id
  from   bom_operation_sequences
  where  routing_sequence_id = p_rtg_seq_id
    and  operation_type = 3
    and  operation_seq_num = (
      select min(operation_seq_num)
      from   bom_operation_sequences
      where  routing_sequence_id = p_rtg_seq_id
      and    operation_type = 3);


CURSOR completed_ops(p_org_id     NUMBER,
                     p_wip_ent_id NUMBER) IS
  select distinct operation_sequence_id
    from flm_exe_operations
   where wip_entity_id = p_wip_ent_id
     and organization_id = p_org_id
  order by operation_sequence_id;

CURSOR completed_operations(p_org_id     NUMBER,
                     p_wip_ent_id NUMBER) IS
  select distinct operation_sequence_id, next_op_seq_id
    from flm_exe_operations
   where wip_entity_id = p_wip_ent_id
     and organization_id = p_org_id
  order by operation_sequence_id;

CURSOR primary_ops(p_op_seq_id NUMBER) IS
    select from_op_seq_id, to_op_seq_id, transition_type, operation_seq_num
    from   bom_operation_networks, bom_operation_sequences
    where  from_op_seq_id = operation_sequence_id and transition_type=1
    start with from_op_seq_id = p_op_seq_id
    connect by PRIOR to_op_seq_id = from_op_seq_id
    and prior transition_type =1;

CURSOR event_seq_num (p_rtg_seq_id NUMBER, p_lop_seq_id NUMBER) IS
  select operation_seq_num
    from bom_operation_sequences
   where routing_sequence_id = p_rtg_seq_id
     and line_op_seq_id = p_lop_seq_id
     and operation_type = 1;

CURSOR next_op_count(p_org_id NUMBER, p_wip_ent_id NUMBER, p_from_op_seq NUMBER) IS
  select count(operation_sequence_id) opcount
    from flm_exe_operations
   where wip_entity_id = p_wip_ent_id
     and organization_id = p_org_id
     and operation_sequence_id = p_from_op_seq;

l_op_seq_tbl operation_seq_tbl_type;
l_all_op_seq_tbl operation_seq_tbl_type;
v_idx NUMBER;
l_bf_option NUMBER;
l_event_seq_num_tbl operation_seq_tbl_type;
TYPE event_seq_num_tbl_type IS TABLE OF APPS.BOM_OPERATION_SEQUENCES.OPERATION_SEQ_NUM%TYPE;
l_event_seq_num_tbl1 event_seq_num_tbl_type;
l_completed_op_exist boolean := false;
l_op_count NUMBER;

BEGIN
  l_bf_option := get_backflush_option(p_org_id, p_line_id);

  if(l_bf_option = G_BFLUSH_OPTION_ALL) then --All operations to be included in backflush
    for c_all_ops in all_ops(p_rtg_seq_id) loop
      l_all_op_seq_tbl(c_all_ops.operation_sequence_id) := c_all_ops.operation_sequence_id;
    end loop;
  elsif(l_bf_option = G_BFLUSH_OPTION_ACT_PRI) then --Only Actual/Primary operations to be included in backflush
/*
    for c_completed_ops in completed_ops(p_org_id, p_wip_entity_id) LOOP
      l_completed_op_exist := true;
      l_op_seq_tbl(c_completed_ops.operation_sequence_id) := c_completed_ops.operation_sequence_id;
      for c_primary_ops in primary_ops(c_completed_ops.operation_sequence_id) LOOP
        l_all_op_seq_tbl(c_primary_ops.from_op_seq_id) := c_primary_ops.from_op_seq_id;
        l_all_op_seq_tbl(c_primary_ops.to_op_seq_id) := c_primary_ops.to_op_seq_id;
      end loop;
    end loop;
*/
    for c_completed_ops in completed_operations(p_org_id, p_wip_entity_id) LOOP
      l_completed_op_exist := true;
      l_all_op_seq_tbl(c_completed_ops.operation_sequence_id) := c_completed_ops.operation_sequence_id;
      l_all_op_seq_tbl(c_completed_ops.next_op_seq_id) := c_completed_ops.next_op_seq_id;
      --bug 5599353
      --find if any operation is completed after this op, if yes, then just follow this path,
      --otherwise follow primary path from here
      l_op_count := 0;
      for c_next_op_count in next_op_count(p_org_id, p_wip_entity_id, c_completed_ops.next_op_seq_id) loop
        l_op_count := c_next_op_count.opcount;
        if (l_op_count = 0) then --follow primary path
          for c_primary_ops in primary_ops(c_completed_ops.next_op_seq_id) LOOP
            l_all_op_seq_tbl(c_primary_ops.from_op_seq_id) := c_primary_ops.from_op_seq_id;
            l_all_op_seq_tbl(c_primary_ops.to_op_seq_id) := c_primary_ops.to_op_seq_id;
	  end loop;
        else
          null; --do nothing
        end if;
      end loop;
    end loop;

    if(l_completed_op_exist <> true) then --if no completed op exist, then we find out lowest op seq num and follow primary path
      for c_lowest_op in lowest_op(p_rtg_seq_id) loop
        l_op_seq_tbl(c_lowest_op.operation_sequence_id) := c_lowest_op.operation_sequence_id;
        for c_primary_ops in primary_ops(c_lowest_op.operation_sequence_id) LOOP
          l_all_op_seq_tbl(c_primary_ops.from_op_seq_id) := c_primary_ops.from_op_seq_id;
          l_all_op_seq_tbl(c_primary_ops.to_op_seq_id) := c_primary_ops.to_op_seq_id;
        end loop;
      end loop;
    end if;
  end if;

  v_idx := l_all_op_seq_tbl.FIRST;
  WHILE v_idx IS NOT NULL LOOP
    for c_event_seq_num in event_seq_num(p_rtg_seq_id, l_all_op_seq_tbl(v_idx)) loop
      l_event_seq_num_tbl(c_event_seq_num.operation_seq_num) := c_event_seq_num.operation_seq_num;
    end loop;
    v_idx := l_all_op_seq_tbl.NEXT(v_idx);
  END LOOP;

  x_lop_tbl := l_event_seq_num_tbl;
/*
  v_idx := x_lop_tbl.FIRST;
  WHILE v_idx IS NOT NULL LOOP
    --dbms_output.put_line('eligible ops='||x_lop_tbl(v_idx));
    v_idx := x_lop_tbl.NEXT(v_idx);
  END LOOP;
 */

END get_eligible_ops;



PROCEDURE get_recorded_event_seq_num (p_org_id        IN NUMBER,
					                            p_wip_entity_id IN NUMBER,
					                            x_event_tbl       OUT NOCOPY operation_seq_tbl_type) IS

CURSOR recorded_ops(p_org_id     NUMBER,
                     p_wip_ent_id NUMBER) IS
  select distinct operation_seq_num
  from   flm_exe_req_operations fero
  where  fero.organization_id = p_org_id
    and  fero.wip_entity_id = p_wip_ent_id;

BEGIN
  for c_recorded_ops in recorded_ops(p_org_id, p_wip_entity_id) loop
    x_event_tbl(c_recorded_ops.operation_seq_num) := c_recorded_ops.operation_seq_num;
  end loop;


END get_recorded_event_seq_num;




FUNCTION get_backflush_option(p_org_id IN NUMBER, p_line_id IN NUMBER) RETURN NUMBER IS
--1 = Actual/Primary
--2 = ALL

CURSOR line_bf_option(p_org_id IN NUMBER, p_line_id IN NUMBER) IS
  select nvl(backflush_option, G_BFLUSH_OPTION_ALL) backflush_option
  from   flm_exe_preferences
  where  organization_id = p_org_id
    and  line_id = p_line_id;

CURSOR org_bf_option(p_org_id IN NUMBER) IS
  select nvl(backflush_option,G_BFLUSH_OPTION_ALL) backflush_option
  from   flm_exe_preferences
  where  organization_id = p_org_id;
l_bf_option NUMBER;

BEGIN
  for c_line_bf_option in line_bf_option(p_org_id, p_line_id) loop
    l_bf_option := c_line_bf_option.backflush_option;
  end loop;
  if(l_bf_option is null) then
    for c_org_bf_option in org_bf_option(p_org_id) loop
      l_bf_option := c_org_bf_option.backflush_option;
    end loop;
  end if;

  if l_bf_option is null then
    l_bf_option := G_BFLUSH_OPTION_ALL;
  end if;

  return l_bf_option;

EXCEPTION when others then
  l_bf_option := G_BFLUSH_OPTION_ALL;
  return l_bf_option;

END get_backflush_option;


PROCEDURE get_backflush_comps(
  p_wip_ent_id      in  number default NULL,
  p_line_id         in  number default NULL,
  p_assyID          in  number,
  p_orgID           in  number,
  p_qty             in  number,
  p_altBomDesig     in  varchar2,
  p_altOption       in  number,
  p_bomRevDate      in  date default NULL,
  p_txnDate         in  date,
  p_projectID       in  number,
  p_taskID          in  number,
  p_toOpSeqNum      in  number,
  p_altRoutDesig    in  varchar2,
  x_compInfo        in out nocopy system.wip_lot_serial_obj_t,
  x_returnStatus    out nocopy varchar2) IS

CURSOR routing_seq_no_alt(p_org_id NUMBER, p_assembly_id NUMBER) IS
  select common_routing_sequence_id
  from   bom_operational_routings
  where  organization_id = p_org_id
    and  assembly_item_id = p_assembly_id;

CURSOR routing_seq_alt(p_org_id NUMBER, p_assembly_id NUMBER, p_alt_desig VARCHAR2) IS
  select common_routing_sequence_id
  from   bom_operational_routings
  where  organization_id = p_org_id
    and  assembly_item_id = p_assembly_id
    and  alternate_routing_designator = p_alt_desig;


l_compTbl system.wip_component_tbl_t;
l_compLotSerTbl system.wip_lot_serial_obj_t;
l_rtg_seq_id NUMBER;
l_curItem system.wip_component_obj_t;

BEGIN

  --if this is not scheduled completion, then no records can be merged
  if(p_wip_ent_id is null) then
    return;
  end if;

  if(p_altRoutDesig is null) then
    for c_routing_seq_no_alt in routing_seq_no_alt(p_orgID, p_assyID) loop
      l_rtg_seq_id := c_routing_seq_no_alt.common_routing_sequence_id;
    end loop;
  else
    for c_routing_seq_alt in routing_seq_alt(p_orgID, p_assyID, p_altRoutDesig) loop
      l_rtg_seq_id := c_routing_seq_alt.common_routing_sequence_id;
    end loop;
  end if;

  --if this item has no routing, then no records can be merged
  if(l_rtg_seq_id is null) then
    return;
  end if;

  flm_execution_util.merge_backflush_comps(
	  p_wip_ent_id   => p_wip_ent_id,
	  p_line_id      => p_line_id,
	  p_assyID       => p_assyID,
	  p_orgID        => p_orgID,
	  p_qty          => p_qty,
	  p_altBomDesig  => p_altBomDesig,
	  p_altOption    => p_altOption,
	  p_bomRevDate   => p_bomRevDate,
	  p_txnDate      => p_txnDate,
	  p_projectID    => p_projectID,
	  p_taskID       => p_taskID,
	  p_toOpSeqNum   => p_toOpSeqNum,
	  p_rtg_seq_id   => l_rtg_seq_id,
	  x_compTbl      => x_compInfo,
	  x_returnStatus => x_returnStatus);


  --Now we want to default the lot and serials if exist
  default_comp_lot_serials(
  p_wip_ent_id   => p_wip_ent_id,
  p_line_id      => p_line_id,
  p_assyID       => p_assyID,
  p_orgID        => p_orgID,
  p_qty          => p_qty,
  p_altBomDesig  => p_altBomDesig,
  p_altOption    => p_altOption,
  p_bomRevDate   => p_bomRevDate,
  p_txnDate      => p_txnDate,
  p_projectID    => p_projectID,
  p_taskID       => p_taskID,
  p_toOpSeqNum   => p_toOpSeqNum,
  p_altRoutDesig => p_altRoutDesig,
  x_compTbl      => x_compInfo,
  x_returnStatus => x_returnStatus);

END get_backflush_comps;



PROCEDURE merge_backflush_comps(
  p_wip_ent_id      in  number default NULL,
  p_line_id         in  number default NULL,
  p_assyID          in  number,
  p_orgID           in  number,
  p_qty             in  number,
  p_altBomDesig     in  varchar2,
  p_altOption       in  number,
  p_bomRevDate      in  date default NULL,
  p_txnDate         in  date,
  p_projectID       in  number,
  p_taskID          in  number,
  p_toOpSeqNum      in  number,
  p_rtg_seq_id      in  number,
  x_compTbl         in out nocopy system.wip_lot_serial_obj_t,
  x_returnStatus    out nocopy varchar2) is

CURSOR sub_exist(p_org_id NUMBER, p_wip_ent_id NUMBER) IS
  select 1 as subs
  from  dual
  where exists (
  select inventory_item_id
  from   flm_exe_req_operations
  where  organization_id = p_org_id
    and  wip_entity_id = p_wip_ent_id
    and  inventory_item_id <> -1);


CURSOR op_events (p_rtg_seq_id NUMBER, p_lop_seq_id NUMBER) IS
  select operation_sequence_id, operation_seq_num
  from   bom_operation_sequences
  where  routing_sequence_id = p_rtg_seq_id
    and  line_op_seq_id = p_lop_seq_id
    and  operation_type = 1;

CURSOR recorded_comps (p_org_id NUMBER, p_wip_ent_id NUMBER) IS
  select fero.organization_id,
         fero.inventory_item_id,
         fero.operation_seq_num,
         fero.quantity_per_assembly,
         fero.supply_subinventory,
         fero.supply_locator_id,
         fero.component_sequence_id,
         nvl(fero.basis_type,WIP_CONSTANTS.ITEM_BASED_MTL) basis_type,
         msi.primary_uom_code,
         flm_util.get_key_flex_item(fero.inventory_item_id,fero.organization_id) inventory_item_name,
         msi.serial_number_control_code,
         msi.lot_control_code,
         msi.restrict_subinventories_code,
         msi.restrict_locators_code,
         msi.description,
         msi.revision_qty_control_code,
         msi.location_control_code
    from flm_exe_req_operations fero,
         mtl_system_items msi
   where fero.organization_id = p_org_id
     and fero.wip_entity_id = p_wip_ent_id
     and fero.inventory_item_id = msi.inventory_item_id
     and msi.organization_id = fero.organization_id
  order by operation_seq_num;


l_compTbl system.wip_component_tbl_t;
l_bf_option NUMBER;
l_sub_exist NUMBER := 2;
l_op_seq_tbl operation_seq_tbl_type;
l_count NUMBER := 1;
v_idx NUMBER;
l_comp_ev_seq_num NUMBER;
l_rec_event_seq_num_tbl operation_seq_tbl_type;
l_revision VARCHAR2(3);
l_qty NUMBER;
l_insertPhantom number := WIP_CONSTANTS.NO;
l_msiSubinv varchar2(10);
l_msiLocatorID number;
l_wpSubinv varchar2(10);
l_wpLocatorID number;
l_success boolean;
l_locatorID number;

BEGIN

  l_compTbl := x_compTbl.items;

  for c_sub_exist in sub_exist(p_orgId, p_wip_ent_id) loop
    l_sub_exist := c_sub_exist.subs;
  end loop;

  get_eligible_ops(p_orgID,
                   p_line_id,
                   p_rtg_seq_id,
                   p_wip_ent_id,
                   l_op_seq_tbl);


  --first pass, remove all components from unneeded events
  l_bf_option := get_backflush_option(p_orgID, p_line_id);
  if(l_bf_option = G_BFLUSH_OPTION_ALL) then --All operations to be included in backflush
    null; --dont need to remove any component
  elsif(l_bf_option = G_BFLUSH_OPTION_ACT_PRI) then --Only Actual/Primary operations to be included in backflush
	  v_idx := l_compTbl.FIRST;
	  WHILE v_idx IS NOT NULL LOOP
	    l_comp_ev_seq_num := l_compTbl(v_idx).operation_seq_num;
	    IF NOT l_op_seq_tbl.EXISTS(l_comp_ev_seq_num) then
	      l_compTbl.delete(v_idx);
	    END IF;
	    v_idx := l_compTbl.NEXT(v_idx);
	  END LOOP;
  end if;


  --remove the phantom comps if bom param for use_phantom_routing is not set to yes
  l_insertPhantom := wip_globals.use_phantom_routings(p_orgID);
  v_idx := l_compTbl.FIRST;
  WHILE v_idx IS NOT NULL LOOP
    if(nvl(l_compTbl(v_idx).wip_supply_type, 1) = WIP_CONSTANTS.PHANTOM) then
      if(l_insertPhantom <> WIP_CONSTANTS.YES) then
        l_compTbl.delete(v_idx);
      elsif(l_insertPhantom = WIP_CONSTANTS.YES) then
        if(l_compTbl(v_idx).operation_seq_num > 0) then
          l_compTbl(v_idx).operation_seq_num := -1*abs(l_compTbl(v_idx).operation_seq_num);
        end if;
      end if;
    end if;
    v_idx := l_compTbl.NEXT(v_idx);
  END LOOP;


  if((l_sub_exist is null) or (l_sub_exist = 2)) then --no substitutions
    x_compTbl.items := l_compTbl;
    return;
  end if;


  --at this point we need to merge recorded components
  --first remove the components of operation that are recorded
  get_recorded_event_seq_num(p_orgID,
                             p_wip_ent_id,
                             l_rec_event_seq_num_tbl);
	  v_idx := l_compTbl.FIRST;
	  WHILE v_idx IS NOT NULL LOOP
	    l_comp_ev_seq_num := l_compTbl(v_idx).operation_seq_num;
	    IF l_rec_event_seq_num_tbl.EXISTS(l_comp_ev_seq_num) then
	      l_compTbl.delete(v_idx);
	    END IF;
	    v_idx := l_compTbl.NEXT(v_idx);
	  END LOOP;

  --then add the recorded components
  --l_compTbl.extend(2); --todo, change with component count

  x_compTbl.items := l_compTbl;

  v_idx := nvl(l_compTbl.LAST,0);

  for c_recorded_comps in recorded_comps(p_orgID, p_wip_ent_id) loop
	  v_idx := v_idx +1;
		l_compTbl.extend;
    if(c_recorded_comps.revision_qty_control_code = wip_constants.revision_controlled) then
      bom_revisions.get_revision(examine_type => 'ALL',
                                 org_id => p_orgID,
                                 item_id => c_recorded_comps.inventory_item_id,
                                 rev_date => p_txnDate,
                                 itm_rev => l_revision);
    else
      l_revision := null;
    end if;
                if(c_recorded_comps.basis_type = WIP_CONSTANTS.ITEM_BASED_MTL) then
  		  l_qty := nvl(c_recorded_comps.quantity_per_assembly * p_qty,0);
                else
                  l_qty := nvl(c_recorded_comps.quantity_per_assembly,0);
                end if;

    if ( c_recorded_comps.supply_subinventory is null ) then
      select msi.wip_supply_subinventory,
             msi.wip_supply_locator_id,
             wp.default_pull_supply_subinv,
             wp.default_pull_supply_locator_id
        into l_msiSubinv,
             l_msiLocatorID,
             l_wpSubinv,
             l_wpLocatorID
        from mtl_system_items msi,
             wip_parameters wp
       where msi.organization_id = wp.organization_id
         and msi.organization_id = p_orgID
         and msi.inventory_item_id = c_recorded_comps.inventory_item_id;
      if ( l_msiSubinv is not null ) then
        c_recorded_comps.supply_subinventory := l_msiSubinv;
        l_locatorID := l_msiLocatorID;
      else
        c_recorded_comps.supply_subinventory := l_wpSubinv;
        l_locatorID := l_wpLocatorID;
      end if;
    else
      if c_recorded_comps.supply_locator_id is not null then
        l_locatorID :=  c_recorded_comps.supply_locator_id;
      else
        l_locatorID := null;
      end if;
    end if;

    if(l_locatorID is not null) then
      l_success := pjm_project_locator.get_component_projectSupply(
                                p_organization_id => p_orgID,
                                p_project_id      => p_projectID,
                                p_task_id         => p_taskID,
                                p_wip_entity_id   => null,--unused
                                p_supply_sub      => c_recorded_comps.supply_subinventory,
                                p_supply_loc_id   => l_locatorID,
                                p_item_id         => c_recorded_comps.inventory_item_id,
                                p_org_loc_control => null); --unused
      c_recorded_comps.supply_locator_id := l_locatorID;
    end if;

    if(c_recorded_comps.quantity_per_assembly <> -9999) then --bug 5181888, add this clause to remove the deleted comps in final merge
      x_compTbl.addItem
        (p_opSeqNum            => c_recorded_comps.operation_seq_num,
         p_itemID              => c_recorded_comps.inventory_item_id,
         p_itemName            => c_recorded_comps.inventory_item_name ,
         p_priQty              => l_qty,
         p_priUomCode          => c_recorded_comps.primary_uom_code,
         p_supplySubinv        => c_recorded_comps.supply_subinventory,
         p_supplyLocID         => c_recorded_comps.supply_locator_id,
         p_wipSupplyType       => wip_constants.assy_pull,
         p_txnActionID         => wip_constants.isscomp_action,
         p_mtlTxnsEnabledFlag  => null,
         p_serialControlCode   => c_recorded_comps.serial_number_control_code,
         p_lotControlCode      => c_recorded_comps.lot_control_code,
         p_revision            => l_revision,
         p_departmentID        => 1,
         p_restrictSubsCode    => c_recorded_comps.restrict_subinventories_code,
         p_restrictLocsCode    =>c_recorded_comps.restrict_locators_code,
         p_projectID           => p_projectID,
         p_taskID              => p_taskID,
         p_componentSeqID      => c_recorded_comps.component_sequence_id,
         p_cmpTxnID            => null,
         p_itemDescription     => c_recorded_comps.description,
         p_locatorName         => flm_util.get_key_flex_location(c_recorded_comps.supply_locator_id,p_orgID),
         p_revisionContolCode  => c_recorded_comps.revision_qty_control_code,
         p_locationControlCode => c_recorded_comps.location_control_code,
         p_locatorProjectID    => null,
         p_locatorTaskID       => null);
    end if;
  end loop;

END merge_backflush_comps;




PROCEDURE default_comp_lot_serials(
  p_wip_ent_id      in  number default NULL,
  p_line_id         in  number default NULL,
  p_assyID          in  number,
  p_orgID           in  number,
  p_qty             in  number,
  p_altBomDesig     in  varchar2,
  p_altOption       in  number,
  p_bomRevDate      in  date default NULL,
  p_txnDate         in  date,
  p_projectID       in  number,
  p_taskID          in  number,
  p_toOpSeqNum      in  number,
  p_altRoutDesig    in  varchar2,
  x_compTbl         in out nocopy system.wip_lot_serial_obj_t,
  x_returnStatus    out nocopy varchar2) IS
  l_curItem system.wip_component_obj_t;

cursor comp_lot (p_wip_ent_id  NUMBER,
                 p_org_id      NUMBER,
                 p_op_seq_num  NUMBER,
                 p_inv_item_id NUMBER) IS
 select lot_number, lot_quantity, parent_lot_number, creation_date
 from   flm_exe_lot_numbers
 where  organization_id = p_org_id
   and  wip_entity_id = p_wip_ent_id
   and  inventory_item_id = p_inv_item_id
   and  operation_seq_num = p_op_seq_num
 order by creation_date, lot_number;

cursor comp_serial (p_wip_ent_id  NUMBER,
                    p_org_id      NUMBER,
                    p_op_seq_num  NUMBER,
                    p_inv_item_id NUMBER) IS
 select fm_serial_number, to_serial_number, serial_quantity, lot_number, parent_serial_number, creation_date
 from   flm_exe_serial_numbers
 where  organization_id = p_org_id
   and  wip_entity_id = p_wip_ent_id
   and  inventory_item_id = p_inv_item_id
   and  operation_seq_num = p_op_seq_num
 order by creation_date, fm_serial_number;

cursor comp_lot_serial (p_wip_ent_id  NUMBER,
                    p_org_id      NUMBER,
                    p_op_seq_num  NUMBER,
                    p_inv_item_id NUMBER,
                    p_comp_lot_num VARCHAR2) IS
 select fm_serial_number, to_serial_number, serial_quantity, lot_number, parent_serial_number, creation_date
 from   flm_exe_serial_numbers
 where  organization_id = p_org_id
   and  wip_entity_id = p_wip_ent_id
   and  inventory_item_id = p_inv_item_id
   and  operation_seq_num = p_op_seq_num
   and  lot_number = p_comp_lot_num
 order by creation_date, fm_serial_number;

 compReqQty NUMBER := 0;
 compRemainQty NUMBER :=0;
 compAvailToTxnLotQty NUMBER := 0;
 compAvailToTxnSerQty NUMBER := 0;

BEGIN
  x_compTbl.reset;
  loop
    if(x_compTbl.getCurrentItem(l_curItem)) then

	    --try to default lot numbers for component
	    if(l_curItem.lot_control_code = 2) then

		    compReqQty := 0;
		    compRemainQty := 0;
		    compReqQty := l_curItem.primary_quantity;
		    compRemainQty := compReqQty;

	      for c_comp_lot in comp_lot(p_wip_ent_id, p_orgID,
	                                 l_curItem.operation_seq_num, l_curItem.inventory_item_id) LOOP
	        compAvailToTxnLotQty := c_comp_lot.lot_quantity;
	        x_compTbl.addLot(p_lotNumber  => c_comp_lot.lot_number,
	                         p_priQty     => least(compRemainQty, compAvailToTxnLotQty),
	                         p_attributes => null);
	        compRemainQty := compRemainQty - least(compRemainQty, compAvailToTxnLotQty);
	        if(l_curItem.serial_number_control_code in (2,5,6)) then --if item is under both lot and serial control, bug 5572880
	          for c_comp_ls in comp_lot_serial(p_wip_ent_id, p_orgID,
	                                           l_curItem.operation_seq_num, l_curItem.inventory_item_id,
	                                           c_comp_lot.lot_number) LOOP
	            x_compTbl.addLotSerial
	              (p_fmSerial     => c_comp_ls.fm_serial_number,
	               p_toSerial     => c_comp_ls.to_serial_number,
	               p_parentSerial => c_comp_ls.parent_serial_number,
	               p_priQty       => c_comp_ls.serial_quantity,
	               p_attributes   => null);
	          END LOOP; -- component serial loop
	        end if;

	        if(compRemainQty = 0) then
	          exit;
	        end if;
	      END LOOP; -- component lot loop
	    end if;

      --only serial control
	    --try to default serial number for component for predefined,at receipt, so issue
	    if((l_curItem.lot_control_code <> 2) AND
	       (l_curItem.serial_number_control_code in ( 2,5,6))) then --bug 5572880
		    compReqQty    := 0;
		    compRemainQty := 0;
		    compReqQty    := l_curItem.primary_quantity;
		    compRemainQty := compReqQty;

	      for c_comp_serial in comp_serial(p_wip_ent_id,
	                                       p_orgID,
	                                       l_curItem.operation_seq_num,
	                                       l_curItem.inventory_item_id) LOOP
	        compAvailToTxnSerQty := c_comp_serial.serial_quantity;
	        x_compTbl.addSerial(p_fmSerial      => c_comp_serial.fm_serial_number,
	                             p_toSerial     => c_comp_serial.to_serial_number,
	                             p_parentSerial => c_comp_serial.parent_serial_number,
	                             p_priQty       => c_comp_serial.serial_quantity,
	                             p_attributes   => null);
	        compRemainQty := compRemainQty - least(compRemainQty, compAvailToTxnSerQty);
	        if(compRemainQty = 0) then
	          exit;
	        end if;
	      END LOOP;
	    end if;
	  end if;
    exit when not x_compTbl.setNextItem;
  end loop;

END default_comp_lot_serials;


FUNCTION scheduleRecordedDetailsExist(orgId Number, schNum Varchar2)
  return VARCHAR2 IS
  l_wip_ent_id NUMBER := 0;
BEGIN

  select wip_entity_id
    into l_wip_ent_id
  from wip_flow_schedules
  where organization_id = orgId
    and schedule_number = schNum;

  return (scheduleRecordedDetailsExist(orgId, l_wip_ent_id));

END scheduleRecordedDetailsExist;


FUNCTION scheduleRecordedDetailsExist(orgId Number, wipEntId Number)
  return VARCHAR2 IS
  CURSOR recordedOperation(p_orgId Number, p_wipEntId Number ) IS
    select count(wip_entity_id) count
    from   flm_exe_operations
    where  organization_id = p_orgId
      and  wip_entity_id = p_wipEntId;

  CURSOR recordedDetails(p_orgId Number, p_wipEntId Number) IS
    select count(wip_entity_id) count
    from   flm_exe_req_operations
    where  organization_id = p_orgId
      and  wip_entity_id = p_wipEntId;
  l_count NUMBER := 0;
BEGIN

  for c_recordedOperation in recordedOperation(orgId, wipEntId) loop
    l_count := c_recordedOperation.count;
  end loop;
  if(l_count > 0) then
    return 'Y';
  else
          for c_recordedDetails in recordedDetails(orgId, wipEntId) loop
            l_count := c_recordedDetails.count;
          end loop;
          if(l_count > 0) then
            return 'Y';
          end if;
  end if;
  return 'N';

  exception when others then
    return 'N';


END scheduleRecordedDetailsExist;


FUNCTION kanban_card_activity_exist(p_wip_entity_id IN NUMBER)
RETURN NUMBER IS
l_exists NUMBER := 0;
CURSOR kanban_card_csr(l_wip_entity_id IN NUMBER) IS
  select 1 as kanban_exists
    from dual
   where exists
     (select kanban_card_id
        from mtl_kanban_card_activity
       where source_wip_entity_id = l_wip_entity_id
     );
BEGIN
  for c_kanban_card_csr in kanban_card_csr(p_wip_entity_id) loop
    l_exists := c_kanban_card_csr.kanban_exists;
  end loop;

 if(l_exists = 1) then
   return 1;
 else
   return 2;
 end if;

EXCEPTION
  when others then
    return 2;

END Kanban_card_activity_exist;


PROCEDURE exp_ser_single_op(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
p_operation_seq_num NUMBER) IS

CURSOR op_items(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
p_operation_seq_num NUMBER) IS
select organization_id, wip_entity_id, operation_seq_num, inventory_item_id
from   flm_exe_req_operations
where  organization_id = p_org_id
  and  wip_entity_id = p_wip_entity_id
  and  operation_seq_num = p_operation_seq_num;

BEGIN
  for c_op_items in op_items(p_org_id, p_wip_entity_id, p_operation_seq_num) LOOP
    exp_ser_single_item(c_op_items.organization_id,
                        c_op_items.wip_entity_id,
                        c_op_items.operation_seq_num,
                        c_op_items.inventory_item_id);
  END LOOP;
END exp_ser_single_op;


PROCEDURE exp_ser_single_item(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
p_operation_seq_num NUMBER, p_inventory_item_id NUMBER) IS

CURSOR item_serials(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
p_operation_seq_num NUMBER, p_inventory_item_id NUMBER) IS
select organization_id, wip_entity_id, operation_seq_num, inventory_item_id,
       fm_serial_number, to_serial_number, parent_serial_number, lot_number
from   flm_exe_serial_numbers fesn
where  organization_id = p_org_id
  and  wip_entity_id = p_wip_entity_id
  and  operation_seq_num = p_operation_seq_num
  and  inventory_item_id = p_inventory_item_id;

l_fm_serial VARCHAR2(30);
l_to_serial VARCHAR2(30);

BEGIN
  for c_item_serial in item_serials(p_org_id, p_wip_entity_id, p_operation_seq_num, p_inventory_item_id) LOOP
	  if(c_item_serial.fm_serial_number = c_item_serial.to_serial_number) then
	    null;  --no need to explode
	  else
      exp_ser_single_range(c_item_serial.organization_id,
                           c_item_serial.wip_entity_id,
                           c_item_serial.operation_seq_num,
                           c_item_serial.inventory_item_id,
                           c_item_serial.fm_serial_number,
                           c_item_serial.to_serial_number,
                           c_item_serial.parent_serial_number,
                           c_item_serial.lot_number);
	  end if;
  END LOOP;
END exp_ser_single_item;



PROCEDURE exp_ser_single_range(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
  p_operation_seq_num NUMBER, p_inventory_item_id NUMBER, p_fm_serial VARCHAR2,
  p_to_serial VARCHAR2, p_parent_serial_number VARCHAR2, p_lot_number VARCHAR2) IS

l_from_ser_number NUMBER;
l_to_ser_number NUMBER;
l_range_numbers NUMBER;
l_cur_ser_number NUMBER;
l_cur_serial_number VARCHAR2(30);
l_temp_prefix VARCHAR2(30);
l_user_id NUMBER;
l_login_id NUMBER;
BEGIN
	l_user_id := FND_GLOBAL.user_id;
	l_login_id := FND_GLOBAL.login_id;

  --get the number part of from serial
  inv_validate.number_from_sequence(p_fm_serial, l_temp_prefix, l_from_ser_number);
  -- get the number part of the to serial
  inv_validate.number_from_sequence(p_to_serial, l_temp_prefix, l_to_ser_number);
  -- total number of serials inserted
  l_range_numbers  := l_to_ser_number - l_from_ser_number + 1;

  FOR i IN 1 .. l_range_numbers LOOP
    l_cur_ser_number  := l_from_ser_number + i - 1;

    -- concatenate the serial number to be inserted
    l_cur_serial_number  := SUBSTR(p_fm_serial, 1, LENGTH(p_fm_serial) - LENGTH(l_cur_ser_number))
                         || l_cur_ser_number;
    insert into flm_exe_serial_numbers(
      requirement_serial_id,
      organization_id,
      wip_entity_id,
      operation_seq_num,
      inventory_item_id,
      fm_serial_number,
      to_serial_number,
      parent_serial_number,
      lot_number,
      serial_quantity,
      object_version_number,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by)
    values
      (
      flm_exe_serial_numbers_s.nextval,
      p_org_id,
      p_wip_entity_id,
      p_operation_seq_num,
      p_inventory_item_id,
      l_cur_serial_number,
      l_cur_serial_number,
      p_parent_serial_number,
      p_lot_number,
      1,
      1,
      l_user_id,
      sysdate,
      l_login_id,
      sysdate,
      l_user_id
      );
  END LOOP;
  --now delete the original range row
  delete from flm_exe_serial_numbers
  where organization_id = p_org_id
    and wip_entity_id = p_wip_entity_id
    and operation_seq_num = p_operation_seq_num
    and inventory_item_id = p_inventory_item_id
    and fm_serial_number = p_fm_serial
    and to_serial_number = p_to_serial;

END exp_ser_single_range;


FUNCTION get_single_assy_ser(p_org_id IN NUMBER, p_inv_item_id IN NUMBER) RETURN VARCHAR2 IS
CURSOR assy_serials IS
select serial_number
  from mtl_serial_numbers msn,
       mtl_transaction_types mtt
 where (msn.group_mark_id is null or msn.group_mark_id = -1)
   and msn.current_status in (1,  4 )
   and msn.inventory_item_id = p_inv_item_id
   and msn.current_organization_id = p_org_id
   and mtt.transaction_type_id = 44
   and inv_material_status_grp.is_status_applicable(
         null,
         null,
         mtt.transaction_type_id
         ,       NULL
         ,       null
         ,       msn.current_organization_id
         ,       msn.inventory_item_id
         ,       NULL
         ,       NULL
         ,       NULL
         ,       serial_number
         ,       'S') = 'Y';
ser_cnt NUMBER := 0;
ser_num VARCHAR2(30);
assy_ser VARCHAR2(30) := null;
BEGIN
  for c_assy_ser in assy_serials loop
    ser_num := c_assy_ser.serial_number;
    ser_cnt := ser_cnt+1;
  end loop;

  if ser_cnt = 1 then
    assy_ser := ser_num;
  end if;

  return assy_ser;

END get_single_assy_ser;


FUNCTION get_single_assy_lot(p_org_id IN NUMBER, p_inv_item_id IN NUMBER) RETURN VARCHAR2 IS
CURSOR assy_lots IS
select lot_number
  from mtl_lot_numbers mln,
       mtl_transaction_types mtt
 where mln.inventory_item_id = p_inv_item_id
   and mln.organization_id = p_org_id
   and mtt.transaction_type_id = 44
   and inv_material_status_grp.is_status_applicable(
                null
        ,       null
        ,       mtt.transaction_type_id
        ,       null
        ,       NULL
        ,       mln.organization_id
        ,       mln.inventory_item_id
        ,       NULL
        ,       NULL
        ,       lot_number
        ,       NULL
        ,       'O') = 'Y'
   and nvl(disable_flag,2)=2;
lot_cnt NUMBER := 0;
lot_num VARCHAR2(80);
assy_lot VARCHAR2(80) := null;
BEGIN
  for c_assy_lot in assy_lots loop
    lot_num := c_assy_lot.lot_number;
    lot_cnt := lot_cnt+1;
  end loop;

  if lot_cnt = 1 then
    assy_lot := lot_num;
  end if;

  return assy_lot;

END get_single_assy_lot;


FUNCTION get_txn_bfcomp_cnt(txn_intf_id NUMBER)
  RETURN NUMBER IS
l_cnt NUMBER := 0;
BEGIN
  if(txn_intf_id is not null) then
    select count(transaction_interface_id)
      into l_cnt
      from mtl_transactions_interface
     where parent_id is not null
       and parent_id = txn_intf_id;
  end if;
  return l_cnt;
END get_txn_bfcomp_cnt;


FUNCTION get_ser_range_cnt(p_fm_serial VARCHAR2, p_to_serial VARCHAR2)
  RETURN NUMBER IS
l_cnt NUMBER := 0;
l_from_ser_number NUMBER;
l_to_ser_number NUMBER;
l_temp_prefix VARCHAR2(30);
BEGIN

  --get the number part of from serial
  inv_validate.number_from_sequence(p_fm_serial, l_temp_prefix, l_from_ser_number);
  -- get the number part of the to serial
  inv_validate.number_from_sequence(p_to_serial, l_temp_prefix, l_to_ser_number);
  -- total number of serials inserted
  l_cnt  := l_to_ser_number - l_from_ser_number + 1;

  return l_cnt;
Exception
  when others then
    return -1;
END get_ser_range_cnt;


FUNCTION non_txncomp_exist(p_wip_entity_id IN NUMBER, p_org_id IN NUMBER)
  RETURN NUMBER IS

  l_bill_seq_id NUMBER;
  l_bom_rev_date DATE;
  l_nontxn_comp_cnt NUMBER;
  l_ret_val NUMBER := 2;

  CURSOR bill_seq IS
    select bbom.bill_sequence_id,
           wfs.bom_revision_date
      from bom_bill_of_materials bbom,
           wip_flow_schedules wfs
     where wfs.wip_entity_id = p_wip_entity_id
       and wfs.organization_id = p_org_id
       and bbom.assembly_item_id = wfs.primary_item_id
       and bbom.organization_id = wfs.organization_id
       and nvl(bbom.alternate_bom_designator, 'NULL') = nvl(wfs.alternate_bom_designator, 'NULL');

  CURSOR nontxn_comp_cnt IS
    select count(component_item_id) comp_cnt
      from bom_inventory_components bic,
           mtl_system_items msi
     where bill_sequence_id = l_bill_seq_id
       and msi.inventory_item_id = bic.component_item_id
       and bic.effectivity_date < nvl(l_bom_rev_date,sysdate)
       and ((bic.disable_date is null) or
            (bic.disable_date is not null and
             bic.disable_date > nvl(l_bom_rev_date, sysdate)))
       and msi.organization_id = p_org_id
       and nvl(msi.mtl_transactions_enabled_flag,'N') = 'N'
       and nvl(bic.wip_supply_type,msi.wip_supply_type) <> 6;

BEGIN

  for c_bill_seq in bill_seq LOOP
    l_bill_seq_id := c_bill_seq.bill_sequence_id;
    l_bom_rev_date := c_bill_seq.bom_revision_date;
  END LOOP;

  if(l_bill_seq_id is NULL) then
    l_ret_val := 2;
    return l_ret_val;
  end if;

  for c_nontxn_comp_cnt in nontxn_comp_cnt LOOP
    l_nontxn_comp_cnt := c_nontxn_comp_cnt.comp_cnt;
    if(l_nontxn_comp_cnt > 0) then
      l_ret_val := 1;
    else
      l_ret_val := 2;
    end if;
  END LOOP;

  return l_ret_val;

END non_txncomp_exist;

/*Added for bugfix 6152984 */
/****************************************************
    * This function  finds out if any event is         *
    * attached to the operation seq based on passed    *
    * std op in the routing for this schedule          *
    * return_status = 'Y' for One or more Event Exist  *
    * return_status = 'N' for No event exist           *
    ***************************************************/
   function event_exist(p_org_id NUMBER,
                        p_wip_entity_id NUMBER,
                        p_std_op_id NUMBER) return VARCHAR2 IS

     l_event_exist VARCHAR2(1) := 'N';
     l_common_routing_seq_id NUMBER;
     l_operation_seq_id NUMBER;
     l_rtg_rev_date DATE;

     -- Cursor to find the sequence id of the operation in the routing
     -- corresponding to the schedule that references the specified
     -- standard operation.
     CURSOR op_seq_csr IS
       select bos.operation_sequence_id, bor.common_routing_sequence_id,
              nvl(wfs.routing_revision_date, wfs.scheduled_completion_date)
              as routing_revision_date
         from bom_operation_sequences bos,
              wip_flow_schedules wfs,
              bom_operational_routings bor
        where wfs.wip_entity_id = p_wip_entity_id
          and wfs.organization_id = p_org_id
          and bor.organization_id = p_org_id
          and bor.assembly_item_id = wfs.primary_item_id
          and nvl(bor.alternate_routing_designator, '########') =
                nvl(wfs.alternate_routing_designator, '########')
          and bor.common_routing_sequence_id = bos.routing_sequence_id
          and bos.operation_type = 3 -- line operation
          and bos.standard_operation_id = p_std_op_id;


     CURSOR event_exist_csr IS
       select 'Y' as event_exist
         from dual
        where exists (
          select bos.operation_sequence_id
            from bom_operation_sequences bos
           where bos.routing_sequence_id = l_common_routing_seq_id
             and bos.line_op_seq_id = l_operation_seq_id
             and bos.operation_type = 1
             and bos.effectivity_date <= l_rtg_rev_date
             and nvl(bos.disable_date,l_rtg_rev_date+1) > l_rtg_rev_date );


   BEGIN

     for c_op_seq in op_seq_csr loop
       l_common_routing_seq_id := c_op_seq.common_routing_sequence_id;
       l_operation_seq_id      := c_op_seq.operation_sequence_id;
       l_rtg_rev_date          := c_op_seq.routing_revision_date;
     end loop;

     if((l_common_routing_seq_id is not null) AND
        (l_operation_seq_id is not null))
     then
       for c_event_exist in event_exist_csr loop
         l_event_exist := c_event_exist.event_exist;
       end loop;
     end if;
     return l_event_exist;

   END event_exist;

END flm_execution_util;

/
