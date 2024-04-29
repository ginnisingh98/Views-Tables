--------------------------------------------------------
--  DDL for Package Body FLM_KANBAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_KANBAN" AS
/* $Header: FLMKBNWB.pls 120.2 2006/06/30 00:20:53 ksuleman noship $  */

  FUNCTION number_of_days(sdate IN DATE, edate IN DATE, org_id IN NUMBER)
    RETURN NUMBER;

PROCEDURE retrieve_schedules (i_locator_option NUMBER,
			      i_template_sub VARCHAR2,
			      i_default_locator_id NUMBER DEFAULT NULL,
			      i_org_id NUMBER,
			      i_line_id NUMBER,
			      i_standard_operation_id NUMBER,
			      i_operation_type NUMBER,
                              i_assembly IN assembly_t,
                              i_item_attributes IN VARCHAR2,
                              i_item_from IN VARCHAR2,
                              i_item_to IN VARCHAR2,
                              i_backflush_sub IN VARCHAR2,
                              i_cat_from IN VARCHAR2,
                              i_cat_to IN VARCHAR2,
                              i_category_set_id IN NUMBER,
                              i_category_structure_id IN NUMBER,
                              o_result OUT NOCOPY ret_sch_t,
                              o_error_num OUT NOCOPY NUMBER,
			      o_error_msg OUT NOCOPY VARCHAR2) IS

  TYPE l_item_with_type IS RECORD (
    item_id INTEGER,
    type    INTEGER,
    subinv  VARCHAR2(10),
    loc_id  INTEGER
  );

  TYPE l_item_with_type_t IS TABLE OF l_item_with_type
    INDEX BY BINARY_INTEGER;

  TYPE l_list_t IS TABLE OF INTEGER
    INDEX BY BINARY_INTEGER;

  l_where_clause VARCHAR2(2000) := NULL;
  l_id_where_clause VARCHAR2(32767) := NULL;
  l_item_where_clause VARCHAR2(2000) := NULL;
  l_cat_where_clause VARCHAR2(2000) := NULL;
  l_err_buf VARCHAR2(2000);
  l_return BOOLEAN;
  l_result l_list_t;

  l_traced BOOLEAN;
  l_subinv VARCHAR2(10);
  l_subinv_1 VARCHAR2(10);
  l_inv_item_id INTEGER;
  l_loc_id INTEGER;
  l_loc_id_1 INTEGER;

  l_list l_list_t;

  l_item_id_temp INTEGER;
  l_wip_supply_type INTEGER;
  l_subinv_temp VARCHAR2(10);
  l_loc_id_temp INTEGER;
  l_cnt INTEGER;
  l_items l_item_with_type_t;
  l_line_items l_item_with_type_t;
  l_q_item_id INTEGER;
  l_first INTEGER;
  l_last INTEGER;
  l_index INTEGER;
  l_current INTEGER;

  l_cursor INTEGER;
  l_sql_stmt VARCHAR2(32767);
  l_item_id INTEGER;
  l_dummy INTEGER;

  CURSOR get_pos(p_item_id NUMBER,p_subinv VARCHAR2,p_loc_Id NUMBER) IS
    SELECT
	source_subinventory,
	source_locator_id
    FROM
	mtl_kanban_pull_sequences
    WHERE
	organization_id = i_org_id AND
	kanban_plan_id = -1 AND
	source_type = 3 AND
	inventory_item_id = p_item_id AND
	subinventory_name = p_subinv AND
	nvl(locator_id,-1) = nvl(p_loc_id,-1);

  CURSOR find_comps_primary IS
    SELECT DISTINCT
      bic.component_item_id,
      decode(bic.wip_supply_type,null,msi.wip_supply_type,bic.wip_supply_type),
      decode(bic.supply_subinventory,null,msi.wip_supply_subinventory,bic.supply_subinventory),
      decode(bic.supply_subinventory,null,msi.wip_supply_locator_id,bic.supply_locator_id)
    FROM bom_bill_of_materials bbom,
         bom_inventory_components bic,
         mtl_system_items msi
    WHERE bbom.organization_id = i_org_id AND
          bbom.alternate_bom_designator is null AND
          bbom.assembly_item_id = l_q_item_id AND
          bbom.common_bill_sequence_id = bic.bill_sequence_id AND
	  (6=decode(bic.wip_supply_type,null,msi.wip_supply_type,bic.wip_supply_type) OR
	   i_backflush_sub IS NULL OR
           i_backflush_sub=decode(bic.supply_subinventory,null,msi.wip_supply_subinventory,bic.supply_subinventory)) AND
	  bic.effectivity_date < SYSDATE AND
	  (bic.disable_date > sysdate-1 or bic.disable_date is null) AND
	  msi.organization_id = i_org_id AND
	  msi.inventory_item_id = bic.component_item_id
    ORDER BY bic.component_item_id;

  CURSOR find_comps IS
    SELECT DISTINCT
      bic.component_item_id,
      decode(bic.wip_supply_type,null,msi.wip_supply_type,bic.wip_supply_type),
      decode(bic.supply_subinventory,null,msi.wip_supply_subinventory,bic.supply_subinventory),
      decode(bic.supply_subinventory,null,msi.wip_supply_locator_id,bic.supply_locator_id)
    FROM bom_bill_of_materials bbom,
         bom_inventory_components bic,
         mtl_system_items msi
    WHERE bbom.organization_id = i_org_id AND
          -- nvl(bbom.alternate_bom_designator, 'NONE') = nvl(l_alt, 'NONE') AND
          bbom.assembly_item_id = l_q_item_id AND
          bbom.common_bill_sequence_id = bic.bill_sequence_id AND
	  (6=decode(bic.wip_supply_type,null,msi.wip_supply_type,bic.wip_supply_type) OR
	   i_backflush_sub IS NULL OR
           i_backflush_sub=decode(bic.supply_subinventory,null,msi.wip_supply_subinventory,bic.supply_subinventory)) AND
          bic.effectivity_date < SYSDATE AND
	  (bic.disable_date > sysdate-1 or bic.disable_date is null) AND
	  msi.organization_id = i_org_id AND
	  msi.inventory_item_id = bic.component_item_id
    ORDER BY bic.component_item_id;


  CURSOR find_all_comps IS
    SELECT DISTINCT
      bic.component_item_id,
      decode(bic.wip_supply_type,null,msi.wip_supply_type,bic.wip_supply_type),
      decode(bic.supply_subinventory,null,msi.wip_supply_subinventory,bic.supply_subinventory),
      decode(bic.supply_subinventory,null,msi.wip_supply_locator_id,bic.supply_locator_id)
    FROM bom_bill_of_materials bbom,
         bom_inventory_components bic,
         mtl_system_items msi
    WHERE bbom.organization_id = i_org_id AND
          -- bbom.alternate_bom_designator IS NULL AND
          bbom.common_bill_sequence_id = bic.bill_sequence_id AND
	  (6=decode(bic.wip_supply_type,null,msi.wip_supply_type,bic.wip_supply_type) OR
	   i_backflush_sub IS NULL OR
           i_backflush_sub=decode(bic.supply_subinventory,null,msi.wip_supply_subinventory,bic.supply_subinventory)) AND
           bic.effectivity_date < SYSDATE AND
	  (bic.disable_date > sysdate-1 or bic.disable_date is null) AND
	  msi.organization_id = i_org_id AND
	  msi.inventory_item_id = bic.component_item_id
    ORDER BY bic.component_item_id;

  FUNCTION Id_Where_Clause (
    i_items IN l_item_with_type_t,
    i_column_name IN VARCHAR2,
    o_clause OUT NOCOPY VARCHAR2
    ) RETURN BOOLEAN IS

    l_first INTEGER;
    l_last INTEGER;
    l_index INTEGER;
  BEGIN
--    DBMS_OUTPUT.PUT_LINE('Constructing Where Clause...');
    IF i_items IS NULL OR i_items.COUNT <= 0 THEN
      o_clause := NULL;
      RETURN FALSE;
    END IF;
    l_first := i_items.FIRST;
    l_last := i_items.LAST;
    l_index := l_first;

    o_clause := ' '||i_column_name||' IN (';

    LOOP
      o_clause := o_clause||l_items(l_index).item_id||', ';
      --DBMS_OUTPUT.PUT_LINE(o_clause)
      EXIT WHEN l_index = l_last;
      l_index := i_items.NEXT(l_index);
    END LOOP;
    o_clause := o_clause||' -1)';
    --DBMS_OUTPUT.PUT_LINE(length(o_clause));
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      o_clause := NULL;
      RETURN FALSE;
  END;

  ----------------------------------------------------------------------------
  -- retrieve components for a line and/or a lineop(process)
  -- if p_restrict = 0; no restriction, return p_line_items directly
  -- if p_restrict = 1; restrict p_items by p_line_items
  --
  -- p_restrict is used for case when assembly is null, backflush_subinventory
  -- is null and line_id is not null thus we don't retrieve all components but
  -- only components for the line and/or lineop(process)
  ----------------------------------------------------------------------------
  procedure restrict_items_by_line(p_restrict IN number,
				   p_org_id IN number,
				   p_line_id IN number,
				   p_standard_operation_id IN number,
				   p_operation_type IN number,
				   p_items IN OUT NOCOPY l_item_with_type_t) is

  p_line_items l_item_with_type_t;
  no_items l_item_with_type_t;

  l_cnt	number;
  l_index number;

  i number;
  j number;
  k number;
  pou_exists boolean;

  TYPE T_COMPONENT IS RECORD (
    TOP_ASSEMBLY_ITEM_ID	NUMBER,
    ORGANIZATION_ID		NUMBER,
    ASSEMBLY_ITEM_ID		NUMBER,
    ALTERNATE_BOM_DESIGNATOR 	VARCHAR2(10),
    COMPONENT_ITEM_ID		NUMBER,
    OPERATION_SEQ_NUM		NUMBER,
    WIP_SUPPLY_TYPE		NUMBER,
    SUPPLY_SUBINVENTORY		VARCHAR2(10),
    SUPPLY_LOCATOR_ID		NUMBER,
    STD_LINEOP_ID		NUMBER,
    STD_PROCESS_ID		NUMBER
  );

  TYPE T_COMPONENT_TBL IS TABLE OF T_COMPONENT INDEX BY BINARY_INTEGER;

  G_COMPONENTS	T_COMPONENT_TBL;

  empty_component_list T_COMPONENT_TBL;

  L_INHERIT_PHANTOM_OP_SEQ NUMBER(1);

  CURSOR ALL_COMPONENTS IS
  select DISTINCT
	bom.assembly_item_id top_assembly_item_id,
	bom.organization_id,
	bom.assembly_item_id,
	bom.alternate_bom_designator,
	bic.component_item_id,
	bic.operation_seq_num,
	decode(bic.wip_supply_type, null, msi.wip_supply_type, bic.wip_supply_type),
	decode(bic.supply_subinventory, null, msi.wip_supply_subinventory, bic.supply_subinventory),
	decode(bic.supply_subinventory, null, msi.wip_supply_locator_id, bic.supply_locator_id),
	-1,
	-1
  from
	bom_bill_of_materials bom,
	bom_operational_routings bor,
	bom_inventory_components bic,
	mtl_system_items msi
  where
	bom.organization_id = p_org_id and
	bom.organization_id = bor.organization_id and
	bom.assembly_item_id = bor.assembly_item_id and
	((bom.alternate_bom_designator = bor.alternate_routing_designator) or
	 (bom.alternate_bom_designator is null and bor.alternate_routing_designator is null)) and
	bor.line_id = P_LINE_ID and
	bom.common_bill_sequence_id = bic.bill_sequence_id and
	bic.effectivity_date < sysdate and
	(bic.disable_date > sysdate - 1 or bic.disable_date is null) and
	-- bic.wip_supply_type in (2,3,6) and
	msi.organization_id = p_org_id and
	msi.inventory_item_id = bic.component_item_id
  order by
	bic.component_item_id;

  CURSOR COMPONENTS(p_top_assembly_item_id number, p_org_id number, p_assembly_item_id number, p_alt varchar2) IS
  select DISTINCT
	p_top_assembly_item_id,
	bom.organization_id,
	bom.assembly_item_id,
	bom.alternate_bom_designator,
	bic.component_item_id,
	bic.operation_seq_num,
	decode(bic.wip_supply_type, null, msi.wip_supply_type, bic.wip_supply_type),
	decode(bic.supply_subinventory, null, msi.wip_supply_subinventory, bic.supply_subinventory),
	decode(bic.supply_subinventory, null, msi.wip_supply_locator_id, bic.supply_locator_id),
	-1,
	-1
  from
	bom_bill_of_materials bom,
	bom_inventory_components bic,
	mtl_system_items msi
  where
	bom.organization_id = p_org_id and
	bom.assembly_item_id = p_assembly_item_id and
	((bom.alternate_bom_designator = p_alt) or
	 (bom.alternate_bom_designator is null and p_alt is null)) and
	bom.common_bill_sequence_id = bic.bill_sequence_id and
	bic.effectivity_date < sysdate and
	(bic.disable_date > sysdate - 1 or bic.disable_date is null) and
	-- bic.wip_supply_type in (2,3,6) and
	msi.organization_id = p_org_id and
	msi.inventory_item_id = bic.component_item_id
  order by
	bic.component_item_id;

  Cursor get_std_lineop_id(p_org_id number, p_assembly_item_id number, p_alt varchar2, p_op_seq_num number) Is
  Select
	bos2.standard_operation_id
  From
	bom_operational_routings bor,
	bom_operation_sequences bos1,
	bom_operation_sequences bos2
  Where
	bor.organization_id = p_org_id and
	bor.assembly_item_id = p_assembly_item_id and
	nvl(bor.alternate_routing_designator,'NONE') = nvl(p_alt,'NONE') and
	bos1.routing_sequence_id = bor.common_routing_sequence_id and
	bos1.line_op_seq_id = bos2.operation_sequence_id and
	bos2.operation_type = 3 and
	bos1.operation_type = 1 and
	bos1.operation_seq_num = p_op_seq_num and
	bos1.effectivity_date < sysdate and
	(bos1.disable_date > sysdate - 1 or bos1.disable_date is null);

  Cursor get_std_process_id(p_org_id number, p_assembly_item_id number, p_alt varchar2, p_op_seq_num number) Is
  Select
	bos2.standard_operation_id
  From
	bom_operational_routings bor,
	bom_operation_sequences bos1,
	bom_operation_sequences bos2
  Where
	bor.organization_id = p_org_id and
	bor.assembly_item_id = p_assembly_item_id and
	nvl(bor.alternate_routing_designator,'NONE') = nvl(p_alt,'NONE') and
	bos1.routing_sequence_id = bor.common_routing_sequence_id and
	bos1.process_op_seq_id = bos2.operation_sequence_id and
	bos2.operation_type = 2 and
	bos1.operation_type = 1 and
	bos1.operation_seq_num = p_op_seq_num and
	bos1.effectivity_date < sysdate and
	(bos1.disable_date > sysdate - 1 or bos1.disable_date is null);


  BEGIN
    select INHERIT_PHANTOM_OP_SEQ
    into L_INHERIT_PHANTOM_OP_SEQ
    from bom_parameters
    where organization_id = p_org_id;

    if (p_items.COUNT <= 0 and p_restrict = 1) then
      return;
    end if;

    G_COMPONENTS := empty_component_list;
    l_cnt := 0;
    OPEN ALL_COMPONENTS;

    LOOP
      FETCH ALL_COMPONENTS INTO G_COMPONENTS(l_cnt);
      EXIT WHEN ALL_COMPONENTS%NOTFOUND;

	Open get_std_lineop_id(G_COMPONENTS(l_cnt).organization_id,G_COMPONENTS(l_cnt).top_assembly_item_id,
		G_COMPONENTS(l_cnt).alternate_bom_designator,G_COMPONENTS(l_cnt).operation_seq_num);
	Fetch get_std_lineop_id into G_COMPONENTS(l_cnt).std_lineop_id;
	If (get_std_lineop_id%NOTFOUND) Then
	  G_COMPONENTS(l_cnt).std_lineop_id := -1;
	End If;
	Close get_std_lineop_id;

	Open get_std_process_id(G_COMPONENTS(l_cnt).organization_id,G_COMPONENTS(l_cnt).top_assembly_item_id,
		G_COMPONENTS(l_cnt).alternate_bom_designator,G_COMPONENTS(l_cnt).operation_seq_num);
	Fetch get_std_process_id into G_COMPONENTS(l_cnt).std_process_id;
	If (get_std_process_id%NOTFOUND) Then
	  G_COMPONENTS(l_cnt).std_process_id := -1;
	End If;
	Close get_std_process_id;

      l_cnt := l_cnt + 1;
    END LOOP;

    CLOSE ALL_COMPONENTS;

    -- explode all phantom-subassembly
    l_index := 0;
    WHILE l_index < l_cnt lOOP
      if (G_COMPONENTS(l_index).wip_supply_type = 6) then -- phantom
        OPEN COMPONENTS(G_COMPONENTS(l_index).top_assembly_item_id,
			G_COMPONENTS(l_index).organization_id,
			G_COMPONENTS(l_index).component_item_id,
			NULL);

        LOOP
          FETCH COMPONENTS INTO G_COMPONENTS(l_cnt);
          EXIT WHEN COMPONENTS%NOTFOUND;

          if (L_INHERIT_PHANTOM_OP_SEQ = 1) then
	    G_COMPONENTS(l_cnt).operation_seq_num := G_COMPONENTS(l_index).operation_seq_num;
          end if;


  	    Open get_std_lineop_id(G_COMPONENTS(l_cnt).organization_id,G_COMPONENTS(l_cnt).top_assembly_item_id,
	 	G_COMPONENTS(l_cnt).alternate_bom_designator,G_COMPONENTS(l_cnt).operation_seq_num);
 	    Fetch get_std_lineop_id into G_COMPONENTS(l_cnt).std_lineop_id;
	    If (get_std_lineop_id%NOTFOUND) Then
	      G_COMPONENTS(l_cnt).std_lineop_id := -1;
	    End If;
	    Close get_std_lineop_id;

	    Open get_std_process_id(G_COMPONENTS(l_cnt).organization_id,G_COMPONENTS(l_cnt).top_assembly_item_id,
		G_COMPONENTS(l_cnt).alternate_bom_designator,G_COMPONENTS(l_cnt).operation_seq_num);
	    Fetch get_std_process_id into G_COMPONENTS(l_cnt).std_process_id;
	    If (get_std_process_id%NOTFOUND) Then
	      G_COMPONENTS(l_cnt).std_process_id := -1;
	    End If;
	    Close get_std_process_id;


          l_cnt := l_cnt + 1;
        END LOOP;

        CLOSE COMPONENTS;
      end if;
      l_index := l_index + 1;
    END LOOP;

    -- remove phantoms
    l_index := 0;
    WHILE l_index < l_cnt lOOP
      if G_COMPONENTS(l_index).wip_supply_type = 6 then
        G_COMPONENTS.DELETE(l_index);
      end if;
      l_index := l_index + 1;
    END LOOP;

    -- find items attached to the std_op
    if (G_COMPONENTS.COUNT <= 0 and p_restrict = 1) then
      p_items := no_items;
      return;
    end if;

    l_cnt := 0;
    i := G_COMPONENTS.FIRST;
    j := G_COMPONENTS.LAST;

    LOOP
      if (p_standard_operation_id is null OR
	  (G_COMPONENTS(i).std_lineop_id = p_standard_operation_id and p_operation_type = 3) OR
          (G_COMPONENTS(i).std_process_id = p_standard_operation_id and p_operation_type = 2)) then

	pou_exists := false;
        for k in 0..l_cnt-1 loop
	  if (p_line_items(k).item_id = G_COMPONENTS(i).component_item_id) and
	     (p_line_items(k).type = G_COMPONENTS(i).wip_supply_type) and
	     (nvl(p_line_items(k).subinv,'#?') = nvl(G_COMPONENTS(i).supply_subinventory,'#?')) and
	     (nvl(p_line_items(k).loc_id,-1) = nvl(G_COMPONENTS(i).supply_locator_id,-1)) then
	    pou_exists := true;
	  end if;
	  exit when pou_exists;
	end loop;

	if (not pou_exists) then
	  p_line_items(l_cnt).item_id := G_COMPONENTS(i).component_item_id;
	  p_line_items(l_cnt).type := G_COMPONENTS(i).wip_supply_type;
	  p_line_items(l_cnt).subinv := G_COMPONENTS(i).supply_subinventory;
	  p_line_items(l_cnt).loc_id := G_COMPONENTS(i).supply_locator_id;
	  l_cnt := l_cnt + 1;
        end if;
      end if;

      EXIT WHEN i = j;
      i := G_COMPONENTS.NEXT(i);
    END LOOP;

    if (p_line_items.COUNT <= 0) then
      p_items := no_items;
      return;
    end if;

    if (p_restrict = 0) then
      p_items := p_line_items;
      return;
    end if;

    l_index := 0;
    j := p_items.LAST;

    WHILE l_index < l_cnt LOOP
      pou_exists := false;

      i := p_items.FIRST;
      loop
        if (p_line_items(l_index).item_id = p_items(i).item_id) and
           (nvl(p_line_items(l_index).subinv,'#?') = nvl(p_items(i).subinv,'#?')) and
           (nvl(p_line_items(l_index).loc_id,-1) = nvl(p_items(i).loc_id,-1)) then
          pou_exists := true;
        end if;
        exit when pou_exists OR i = j;
	i := p_items.NEXT(i);
      end loop;

      if (not pou_exists) then
        p_line_items.DELETE(l_index);
      end if;

      l_index := l_index + 1;
    END LOOP;

    p_items := p_line_items;

  End;


BEGIN

  o_error_num := 0;

  flm_util.init_bind;
  --
  -- Find out all relevant items
  --
  l_cnt := 0;
  IF (i_assembly IS NULL OR i_assembly.COUNT <= 0)
     and (i_backflush_sub is not null or i_line_id is null)
  THEN
--    DBMS_OUTPUT.PUT_LINE('Nothing Selected!');
    OPEN find_all_comps;
    LOOP
      FETCH find_all_comps INTO l_item_id_temp, l_wip_supply_type,
				l_subinv_temp, l_loc_id_temp;
      EXIT WHEN find_all_comps%NOTFOUND;
      --DBMS_OUTPUT.PUT_LINE(l_item_id_temp||'   '||l_wip_supply_type);
      l_items(l_cnt).item_id := l_item_id_temp;
      l_items(l_cnt).type := l_wip_supply_type;
      l_items(l_cnt).subinv := l_subinv_temp;
      l_items(l_cnt).loc_id := l_loc_id_temp;
      l_cnt := l_cnt+1;
    END LOOP;
    CLOSE find_all_comps;
--    DBMS_OUTPUT.PUT_LINE('Total: '||l_cnt);
  ELSIF (i_assembly IS NOT NULL AND i_assembly.COUNT > 0) THEN  -- i_assembly IS NULL
    -- for all assembly-items passed in, find out their components
    -- which fufill the basic requirements
    l_first := i_assembly.FIRST;
    l_last := i_assembly.LAST;
    l_index := l_first;

    LOOP
      l_q_item_id := i_assembly(l_index);
      OPEN find_comps;
      LOOP
        FETCH find_comps INTO l_item_id_temp, l_wip_supply_type,
			      l_subinv_temp, l_loc_id_temp;
        EXIT WHEN find_comps%NOTFOUND;
        l_items(l_cnt).item_id := l_item_id_temp;
        l_items(l_cnt).type := l_wip_supply_type;
        l_items(l_cnt).subinv := l_subinv_temp;
        l_items(l_cnt).loc_id := l_loc_id_temp;
        l_cnt := l_cnt+1;
      END LOOP;
      CLOSE find_comps;
      IF l_index = l_last
      THEN
        EXIT;
      END IF;
      l_index := i_assembly.NEXT(l_index);
    END LOOP;
    -- repetitively find out all components of phantom-components
    l_index := 0;
    WHILE l_index < l_cnt LOOP
      IF l_items(l_index).type = 6   -- phantom
      THEN
        l_q_item_id := l_items(l_index).item_id;
        OPEN find_comps_primary;
        LOOP

          FETCH find_comps_primary INTO l_item_id_temp, l_wip_supply_type,
			        l_subinv_temp, l_loc_id_temp;
          EXIT WHEN find_comps_primary%NOTFOUND;
          l_items(l_cnt).item_id := l_item_id_temp;
          l_items(l_cnt).type := l_wip_supply_type;
          l_items(l_cnt).subinv := l_subinv_temp;
          l_items(l_cnt).loc_id := l_loc_id_temp;
          l_cnt := l_cnt+1;
        END LOOP;
        CLOSE find_comps_primary;
      END IF;
      l_index := l_index+1;
    END LOOP;
  END IF; -- i_assembly IS NULL

  l_index := 0;
  WHILE l_index < l_cnt LOOP
    IF l_items(l_index).type = 6   -- phantom
    THEN
      l_items.DELETE(l_index);
    END IF;
    l_index := l_index+1;
  END LOOP;


  if (i_line_id is not null) then
    if (i_assembly IS NULL OR i_assembly.COUNT <= 0) and
       (i_backflush_sub is null) then
     -- retrieve components by a line and/or a lineop(process) into l_items
     restrict_items_by_line(0,
			    i_org_id,
			    i_line_id,
			    i_standard_operation_id,
			    i_operation_type,
			    l_items);
    else
     -- restrict components in l_items by a line and/or a lineop(process)
     restrict_items_by_line(1,
			    i_org_id,
			    i_line_id,
			    i_standard_operation_id,
			    i_operation_type,
			    l_items);
    end if;
  end if;

  -- construct the id-where-clause
  if ( i_assembly.COUNT > 0 or i_backflush_sub is not null
       or i_line_id is not null ) then
    l_return := Id_Where_Clause(l_items,
                              'inventory_item_id',
                              l_id_where_clause);
  end if;

  -- construct the 'where' clause
  IF i_item_from IS NOT NULL AND i_item_to IS NOT NULL
  THEN
     l_return := flm_util.Item_Where_Clause(
				  i_item_from,
                                  i_item_to,
                                  'msi',
                                  l_item_where_clause,
                                  l_err_buf);
  END IF;
--  DBMS_OUTPUT.PUT_LINE('Item where clause: '||l_item_where_clause);

  IF (i_cat_from IS NOT NULL OR i_cat_to IS NOT NULL) AND
     i_category_set_id IS NOT NULL
  THEN
     l_return := flm_util.Category_Where_Clause(
				      i_cat_from,
                                      i_cat_to,
                                      'cat',
                                      i_category_structure_id,
                                      l_cat_where_clause,
                                      l_err_buf);
    l_cat_where_clause := ' msi.inventory_item_id IN (select '||
               ' inventory_item_id from mtl_item_categories mic, '||
               ' mtl_categories cat where ' ||
               ' cat.category_id = mic.category_id' ||
               ' AND mic.organization_id = :org_id'  ||
               ' AND mic.category_set_id = :category_set_id' ||
               ' AND ' || l_cat_where_clause || ')';
  ELSIF i_category_set_id IS NOT NULL
  THEN
    l_cat_where_clause := ' msi.inventory_item_id IN (select '||
               ' inventory_item_id from mtl_item_categories mic ' ||
               ' where mic.organization_id = :org_id' ||
               ' AND mic.category_set_id = :category_set_id' || ')';
  END IF;

  flm_util.add_bind(':org_id', i_org_id);
  flm_util.add_bind(':category_set_id', i_category_set_id);

--  DBMS_OUTPUT.PUT_LINE('Category where clause: '||l_cat_where_clause);



  --
  -- Construct SQL statement
  --
  l_cnt := 1;
--  DBMS_OUTPUT.PUT_LINE('Where Clause GENERATED:');
  --DBMS_OUTPUT.PUT_LINE(l_id_where_clause);

  l_sql_stmt := 'SELECT DISTINCT inventory_item_id ' ||
                'FROM mtl_system_items msi ' ||
                'WHERE organization_id = :org_id' || ' ';

  flm_util.add_bind(':org_id', i_org_id);

  IF l_id_where_clause IS NOT NULL
  THEN
    l_sql_stmt := l_sql_stmt || ' AND ' || l_id_where_clause;
  END IF;
  IF l_item_where_clause IS NOT NULL
  THEN
    l_sql_stmt := l_sql_stmt || ' AND ' || l_item_where_clause;
  END IF;
  IF l_cat_where_clause IS NOT NULL
  THEN
    l_sql_stmt := l_sql_stmt || ' AND ' || l_cat_where_clause;
  END IF;
  IF i_item_attributes IS NOT NULL
  THEN
    l_sql_stmt := l_sql_stmt || ' AND ' || i_item_attributes;
  END IF;
--  DBMS_OUTPUT.PUT_LINE('SQL STATEMENT GENERATED:');
--  DBMS_OUTPUT.PUT_LINE(substr(l_sql_stmt, 1, 250));

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_sql_stmt, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_item_id);

  flm_util.do_binds(l_cursor);

  l_dummy := DBMS_SQL.EXECUTE(l_cursor);
  WHILE DBMS_SQL.FETCH_ROWS(l_cursor)>0 LOOP
    DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_item_id);
    l_result(l_item_id) := l_item_id;
    --l_cnt := l_cnt+1;
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(l_cursor);

l_cnt := 0;

/***
 *** Retrieve POU locators for items according to i_locator_options:
 *** 1. BOM - locators are from bom_inventory_components;
 *** 2. Pull Sequence - Starting from BOM (item_id, subinventory, locator_id),
 ***    trace down in mtl_kanban_pull_sequences, if the last POS has the same
 ***    subinventory as template (i_template_sub), retrieve its locator;
 *** 3. Default - use specified default locator (i_pou_default_locator_id).
 ***
 *** Note that for all three options, items retrieved must not be phantom,
 *** satisfy retrieve criteria, and has the same subinventory as template.
 ***/

if (i_locator_option = 1) then
  -- locator from BOM
  l_first := l_items.FIRST;
  l_last := l_items.LAST;
  l_index := l_first;

  LOOP
    IF 	l_items(l_index).type <> 6 and
	l_result.exists(l_items(l_index).item_id) and
	l_items(l_index).subinv = i_template_sub
    THEN
      o_result(l_cnt).item_id := l_items(l_index).item_id;
      o_result(l_cnt).locator_id := l_items(l_index).loc_id;
      l_cnt := l_cnt + 1;
    END IF;
    EXIT WHEN l_index = l_last;
    l_index := l_items.next(l_index);
  END LOOP;

elsif (i_locator_option = 2) then
  -- locator from existing pull sequences
  l_first := l_items.FIRST;
  l_last := l_items.LAST;
  l_index := l_first;
  l_dummy := 0;

  LOOP
    l_traced := FALSE;
    l_dummy := 0;

    IF 	l_items(l_index).type <> 6 and
	l_result.exists(l_items(l_index).item_id)
    THEN

      l_inv_item_id := l_items(l_index).item_id;
      l_subinv_1 := l_items(l_index).subinv;
      l_loc_id_1 := l_items(l_index).loc_id;

      LOOP
	l_subinv := l_subinv_1;
	l_loc_id := l_loc_id_1;
	OPEN get_pos(l_inv_item_id,l_subinv,l_loc_id);
	FETCH get_pos into l_subinv_1, l_loc_id_1;
        if get_pos%NOTFOUND then
	  CLOSE get_pos;
	  EXIT;
	end if;
	l_traced := TRUE;
	CLOSE get_pos;
	l_dummy := l_dummy + 1;
	EXIT When l_dummy >=99;

      END LOOP;


      if (l_traced) and (l_dummy < 99) and (l_subinv = i_template_sub) then
        o_result(l_cnt).item_id := l_inv_item_id;
        o_result(l_cnt).locator_id := l_loc_id;
        l_cnt := l_cnt + 1;
      end if;
    END IF;
    EXIT WHEN l_index = l_last;
    l_index := l_items.next(l_index);
  END LOOP;

elsif (i_locator_option = 3) then
  -- locator is specified default
  l_first := l_result.FIRST;
  l_last := l_result.LAST;
  l_index := l_first;
  LOOP
    o_result(l_cnt).item_id := l_result(l_index);
    o_result(l_cnt).locator_id := i_default_locator_id;
    l_cnt := l_cnt + 1;
    EXIT WHEN l_index = l_last;
    l_index := l_result.next(l_index);
  END LOOP;

end if;

-- remove duplicate tuple(item_id, subinv, loc_id) from o_result ?


EXCEPTION
  WHEN OTHERS THEN
    o_error_num := 1;
    RETURN;
END;


PROCEDURE demand_pegging_tree (i_pull_sequence_id IN NUMBER,
                              o_result OUT NOCOPY t_sres,
                              o_numdays OUT NOCOPY NUMBER,
                              o_error_num OUT NOCOPY NUMBER,
                              o_error_msg OUT NOCOPY VARCHAR2) IS

  --
  -- Some constants
  --
  l_max_strlen	INTEGER := 550; -- Maximum Length of a String

  --
  -- The subinventory and location we want to explore
  --
  l_des_sub	VARCHAR2(10);
  l_des_loc	VARCHAR2(204);
  l_des_compid	INTEGER;
  l_kp_id	INTEGER;
  l_des_locid	INTEGER;
  l_org_id	NUMBER;

  -- A row
  TYPE t_arow IS RECORD (
    -- database fields
    item	VARCHAR2(40),	-- name of the item
    item_id	INTEGER,	-- id of the item
    item_sub	VARCHAR2(10),	-- subinventory of the item
    item_loc	VARCHAR2(204),	-- location of the item
    de_item	VARCHAR2(40),	-- name of the demand item
    de_item_id	INTEGER,	-- id of the demand item
    de_item_sub	VARCHAR2(10),	-- subinventory of the demand item
    de_item_loc	VARCHAR2(204),	-- location of the demand item
    quantity	INTEGER,	-- quantity of the item
    unit_qty	INTEGER,	-- unit quantity of item to build demand item
    -- tree info
    id		INTEGER,	-- row id
    parent	INTEGER,	-- parent row id
    child	INTEGER,	-- child row id
    mid		INTEGER,	-- id merged to
    tid		INTEGER,	-- id of the corresponding tree node
    total_qty	INTEGER,	-- total quantity
    child_qty	INTEGER		-- total child quantity
  );

  -- A result row
  TYPE t_resrow IS RECORD (
    id		INTEGER,	-- id of this node in the tree
    item_id	INTEGER,	-- id of the item
    item_name	VARCHAR2(40),   -- name of the item
    quantity	INTEGER,	-- quantity of the item
    parent	INTEGER		-- id of the parent node in this tree
  );

  -- Relevant table structure
  TYPE t_relevant IS TABLE OF t_arow
    INDEX BY BINARY_INTEGER;
  -- Result table structure
  TYPE t_res IS TABLE OF t_resrow
    INDEX BY BINARY_INTEGER;
  TYPE t_sres IS TABLE OF VARCHAR2(32767)
    INDEX BY BINARY_INTEGER;

  --
  -- tables
  --
  l_relevant	t_relevant;
  l_res		t_res;
  l_resstring	t_sres;	-- the result in an array of string
  l_numstring	INTEGER; -- the number of result strings
  l_numdays	NUMBER; -- the total number of days

  --
  -- Temporary variables
  --
  l_item	VARCHAR2(40);
  l_item_id	INTEGER;
  l_item_sub	VARCHAR2(10);
  l_item_loc	VARCHAR2(204);
  l_de_item	VARCHAR2(40);
  l_de_item_id	INTEGER;
  l_de_item_sub	VARCHAR2(10);
  l_de_item_loc	VARCHAR2(204);
  l_quantity	INTEGER;

  l_cnt		INTEGER;
  l_total	INTEGER;
  l_j		INTEGER;
  l_k		INTEGER;
  l_sdate	DATE;
  l_edate	DATE;

  --
  -- Cursors
  --
  CURSOR leaves IS
    SELECT msi1.segment1 item,
      mkd.inventory_item_id item_id,
      mkd.subinventory item_sub,
      substr(mil1.concatenated_segments, 0, 5) item_loc,
      msi2.segment1 de_item,
      mkd.assembly_item_id de_item_id,
      mkd.assembly_subinventory de_item_sub,
      substr(mil2.concatenated_segments, 0, 5) de_item_loc,
      demand_quantity quantity
    FROM mrp_kanban_demand mkd, mtl_system_items msi1, mtl_system_items msi2,
      mtl_item_locations_kfv mil1, mtl_item_locations_kfv mil2
    WHERE mkd.kanban_plan_id = l_kp_id
      AND mkd.inventory_item_id = l_des_compid
      AND mkd.subinventory = l_des_sub
      AND (substr(mil1.concatenated_segments, 0, 5) = l_des_loc OR
           (l_des_loc IS NULL AND
            substr(mil1.concatenated_segments, 0, 5) IS NULL))
      AND mkd.organization_id = msi1.organization_id
      AND mkd.organization_id = msi2.organization_id
      AND mkd.inventory_item_id = msi1.inventory_item_id
      AND mkd.assembly_item_id = msi2.inventory_item_id
      AND mkd.locator_id = mil1.inventory_location_id(+)
      AND mkd.assembly_locator_id = mil2.inventory_location_id(+)
     ORDER BY msi1.segment1, mkd.subinventory, msi2.segment1, mkd.assembly_subinventory;

  CURSOR findchild IS
    SELECT msi1.segment1,
      mkd.inventory_item_id, mkd.subinventory,
      substr(mil1.concatenated_segments, 0, 5),
      msi2.segment1, mkd.assembly_item_id,
      mkd.assembly_subinventory,
      substr(mil2.concatenated_segments, 0, 5),
      demand_quantity
    FROM mrp_kanban_demand mkd, mtl_system_items msi1, mtl_system_items msi2,
      mtl_item_locations_kfv mil1, mtl_item_locations_kfv mil2
    WHERE mkd.kanban_plan_id = l_kp_id
      AND mkd.organization_id = msi1.organization_id
      AND mkd.organization_id = msi2.organization_id
      AND mkd.inventory_item_id = msi1.inventory_item_id
      AND mkd.assembly_item_id = msi2.inventory_item_id
      AND mkd.locator_id = mil1.inventory_location_id(+)
      AND mkd.assembly_locator_id = mil2.inventory_location_id(+)
      AND mkd.inventory_item_id = l_relevant(l_cnt).de_item_id  -- id match
      AND (mkd.subinventory = l_relevant(l_cnt).de_item_sub OR
           ((mkd.subinventory IS NULL) AND
            (l_relevant(l_cnt).de_item_sub IS NULL)))
      AND (substr(mil1.concatenated_segments, 0, 5) = l_relevant(l_cnt).de_item_loc OR
           ((mil1.concatenated_segments IS NULL) AND
            (l_relevant(l_cnt).de_item_loc IS NULL)))
      AND (demand_quantity*l_relevant(l_cnt).unit_qty)=l_relevant(l_cnt).quantity; -- quantity match

  FUNCTION mergable (
    r1	INTEGER,
    r2	INTEGER,
    t	t_relevant
    )RETURN BOOLEAN IS
  BEGIN
    -- not for same item? return false
    IF t(r1).item_id <> t(r2).item_id OR
       t(r1).item_sub <> t(r2).item_sub OR
       t(r1).item_loc <> t(r2).item_loc
    THEN
      RETURN FALSE;
    END IF;
    -- both on first level? return true
    IF (t(r1).parent<0) AND (t(r2).parent<0)
    THEN
      RETURN TRUE;
    END IF;
    -- not same level? return false
    IF (t(r1).parent<0) OR (t(r2).parent<0)
    THEN
      RETURN FALSE;
    END IF;
    -- if parents mergable, then mergable
    RETURN mergable(t(r1).parent, t(r2).parent, t);
  END;

  --
  -- Put the result tree into a string/multiple strings, which
  -- is taken as a message/multiple messages to transmit in Oracle
  -- Form environment.
  -- Return the number of strings
  --
  -- Format used:
  -- RES := 'COMMAND/INIT/OTHER/TOTAL/SEQN/'ROW['@'ROW]*'/'
  -- ROW := ID'%'ITEM_ID'%'ITEM_NAME'%'QUANTITY'%'PARENT
  -- TOTAL := [0-9]+
  -- SEQN := [0-9]+
  -- ID := [0-9]+
  -- ITEM_ID := [0-9]+
  -- ITEM_NAME := [A-Z|a-z|0-9|' '|'_'|'.']+
  -- QUANTITY := [0-9]+
  -- PARENT := [-][0-9]+
  --
  FUNCTION toStrings (
    tree	IN	t_res,
    numnode	IN	INTEGER,
    sres	OUT	NOCOPY t_sres
    ) RETURN INTEGER IS
    l_unit_len  INTEGER := 50;
    l_unit_num  INTEGER;
    l_total	INTEGER := 0;
    l_j		INTEGER;
    l_k		INTEGER;
    l_up	INTEGER;
  BEGIN
    -- nothing?
    IF numnode <= 0
    THEN
      RETURN 0;
    END IF;
    -- total number of strings
    l_unit_num := (l_max_strlen/l_unit_len)-2;
    l_total := CEIL(numnode/l_unit_num);
    --put strings
    FOR l_j IN 0..l_total-1 LOOP
--      sres(l_j) := 'COMMAND/INIT/OTHER/'||l_total||'/'||l_j||'/';
      sres(l_j) := l_total||'/'||l_j||'/';
      IF l_j >= l_total-1  -- last one?
      THEN
        l_up := numnode;
      ELSE
        l_up := (l_j+1)*l_unit_num;
      END IF;
      FOR l_k IN l_j*l_unit_num..l_up-1 LOOP
        sres(l_j) := sres(l_j) || tree(l_k).id || '%';
        sres(l_j) := sres(l_j) || tree(l_k).item_id || '%';
        sres(l_j) := sres(l_j) || tree(l_k).item_name || '%';
        sres(l_j) := sres(l_j) || tree(l_k).quantity || '%';
        sres(l_j) := sres(l_j) || tree(l_k).parent;
        IF l_k >= l_up-1
        THEN
          sres(l_j) := sres(l_j) || '/';
        ELSE
          sres(l_j) := sres(l_j) || '@';
        END IF;
      END LOOP;
    END LOOP;
    RETURN l_total;
  END;

BEGIN

  -- find out the kanban-plan-id, subinventory, locator-id, item, and organization id
  SELECT kanban_plan_id, subinventory_name, locator_id, inventory_item_id, organization_id
  INTO l_kp_id, l_des_sub, l_des_locid, l_des_compid, l_org_id
  FROM mtl_kanban_pull_sequences
  WHERE pull_sequence_id = i_pull_sequence_id;

  IF NOT l_des_locid IS NULL
  THEN
    SELECT substr(concatenated_segments, 0, 5)
    INTO l_des_loc
    FROM mtl_item_locations_kfv
    WHERE inventory_location_id = l_des_locid;
  END IF;

  --
  -- Get the total number of days
  --
  SELECT plan_start_date, plan_cutoff_date
  INTO l_sdate, l_edate
  FROM mrp_kanban_plans
  WHERE kanban_plan_id = l_kp_id;

  l_numdays := number_of_days(l_sdate, l_edate, l_org_id);

  --
  -- Fetch those leaves(items whose sub and loc are as indicated).
  --
  l_cnt := 0;

  OPEN leaves;

  LOOP
    -- get next row
    FETCH leaves INTO l_item, l_item_id, l_item_sub, l_item_loc, l_de_item, l_de_item_id, l_de_item_sub, l_de_item_loc, l_quantity;
    EXIT WHEN leaves%NOTFOUND;
    -- put it into the res
    l_relevant(l_cnt).item := l_item;
    l_relevant(l_cnt).item_id := l_item_id;
    l_relevant(l_cnt).item_sub := l_item_sub;
    l_relevant(l_cnt).item_loc := l_item_loc;
    l_relevant(l_cnt).de_item := l_de_item;
    l_relevant(l_cnt).de_item_id := l_de_item_id;
    l_relevant(l_cnt).de_item_sub := l_de_item_sub;
    l_relevant(l_cnt).de_item_loc := l_de_item_loc;
    l_relevant(l_cnt).quantity := l_quantity;
    l_relevant(l_cnt).id := l_cnt;
    l_relevant(l_cnt).parent := -1;
    l_relevant(l_cnt).child := -1;
    l_relevant(l_cnt).mid := l_cnt;
    l_cnt := l_cnt+1;
  END LOOP;

  CLOSE leaves;

  --
  -- Processing
  --

  -- find the unit quantity
  l_total := l_cnt;
  l_cnt := 0;
  FOR l_j IN 0..l_total-1 LOOP
    IF l_relevant(l_j).item_id = l_relevant(l_j).de_item_id
    THEN
      -- same item
      l_relevant(l_j).unit_qty := 1;
    ELSE
      -- find it in database
      SELECT sum(bic.component_quantity)
      INTO l_relevant(l_j).unit_qty
      FROM bom_inventory_components bic, bom_bill_of_materials bbom
	WHERE l_relevant(l_j).de_item_id = bbom.assembly_item_id
	and bbom.organization_id = l_org_id
	and bbom.alternate_bom_designator is null
        AND bbom.bill_sequence_id = bic.bill_sequence_id
        AND bic.component_item_id = l_relevant(l_j).item_id
        AND bic.supply_subinventory = l_relevant(l_j).item_sub;
      --DBMS_OUTPUT.PUT_LINE('UNIT_qty: '||l_relevant(l_j).unit_qty);
    END IF;
  END LOOP;

  -- repetitively find children
  LOOP
    EXIT WHEN l_cnt >= l_total;
    -- find the child
    OPEN findchild;
    FETCH findchild INTO l_relevant(l_total).item, l_relevant(l_total).item_id,
      l_relevant(l_total).item_sub, l_relevant(l_total).item_loc,
      l_relevant(l_total).de_item, l_relevant(l_total).de_item_id,
      l_relevant(l_total).de_item_sub, l_relevant(l_total).de_item_loc,
      l_relevant(l_total).quantity;
    IF findchild%FOUND
    THEN
      -- unit quantity
      IF l_relevant(l_total).item_id = l_relevant(l_total).de_item_id
      THEN
	-- same item
        l_relevant(l_total).unit_qty := 1;
      ELSE
        select sum(bic.COMPONENT_QUANTITY)
        into l_relevant(l_total).unit_qty
        from BOM_INVENTORY_COMPONENTS bic, BOM_BILL_OF_MATERIALS bbom
	  where l_relevant(l_total).de_item_id = bbom.ASSEMBLY_ITEM_ID
	  and bbom.organization_id = l_org_id
	  and bbom.alternate_bom_designator is null
          AND bbom.BILL_SEQUENCE_ID = bic.BILL_SEQUENCE_ID
          AND bic.COMPONENT_ITEM_ID = l_relevant(l_total).item_id
          AND (bic.SUPPLY_SUBINVENTORY = l_relevant(l_total).item_sub OR
               ((bic.SUPPLY_SUBINVENTORY IS NULL) AND
                (l_relevant(l_total).item_sub IS NULL)));
      END IF;
      -- id, parent ...
      l_relevant(l_total).id := l_total;
      l_relevant(l_total).parent := l_relevant(l_cnt).id;
      l_relevant(l_total).child := -1;
      l_relevant(l_cnt).child := l_total;
      l_relevant(l_total).mid := l_relevant(l_total).id;
      -- increase total
      l_total := l_total+1;
    END IF;
    CLOSE findchild;
    l_cnt := l_cnt+1;
  END LOOP;

  -- change the quantity to that of the corresponding leaf component
  FOR l_j IN 0..l_total-1 LOOP
    IF l_relevant(l_j).parent >= 0
    THEN
      l_relevant(l_j).quantity := l_relevant(l_relevant(l_j).parent).quantity;
    END IF;
  END LOOP;
  -- set total quantity and child quantity to quantity
  FOR l_j IN 0..l_total-1 LOOP
    l_relevant(l_j).total_qty := l_relevant(l_j).quantity;
    l_relevant(l_j).child_qty := l_relevant(l_j).quantity;
  END LOOP;

  -- merging...
  FOR l_j IN 1..l_total-1 LOOP
    FOR l_k IN 0..l_j-1 LOOP
      IF mergable(l_j, l_k, l_relevant)
      THEN
        -- merge them
        l_relevant(l_k).total_qty := l_relevant(l_k).total_qty+l_relevant(l_j).quantity;
        l_relevant(l_j).mid := l_relevant(l_k).mid;
	-- leaf node?
	IF l_relevant(l_k).child < 0 AND
	   l_relevant(l_k).de_item_id = l_relevant(l_j).de_item_id AND
	   l_relevant(l_k).child_qty >= 0
	   --l_relevant(l_k).de_item_sub = l_relevant(l_j).de_item_sub AND
	   --l_relevant(l_k).de_item_loc = l_relevant(l_j).de_item_loc
	THEN
	  l_relevant(l_k).child_qty := l_relevant(l_k).child_qty+l_relevant(l_j).child_qty;
	  l_relevant(l_j).child_qty := -1;
	END IF;
      END IF;
    END LOOP;
  END LOOP;

  --
  -- build the tree
  --
  -- root
  l_res(0).id := 0;
  l_res(0).item_id := 0;
  l_res(0).item_name := l_des_sub||' '||l_des_loc;
  l_res(0).quantity := 0;
  l_res(0).parent := -1;

  l_cnt := 1;

  FOR l_j IN 0..l_total-1 LOOP
    -- not a merged one?
    IF l_relevant(l_j).id = l_relevant(l_j).mid
    THEN
      -- add it to the result tree
      l_res(l_cnt).id := l_cnt;
      l_res(l_cnt).item_id := l_relevant(l_j).item_id;
      IF l_relevant(l_j).parent < 0
      THEN
        l_res(l_cnt).item_name := l_relevant(l_j).item;
      ELSE
        IF l_relevant(l_j).item_id <> l_relevant(l_relevant(l_j).parent).item_id
        THEN
          l_res(l_cnt).item_name := l_relevant(l_j).item;
        ELSE
          l_res(l_cnt).item_name := l_relevant(l_j).item_sub||' '||l_relevant(l_j).item_loc;
        END IF;
      END IF;
      l_res(l_cnt).quantity := l_relevant(l_j).total_qty;
      IF l_relevant(l_j).parent < 0
      THEN
        l_res(l_cnt).parent := 0;
      ELSE
        l_res(l_cnt).parent := l_relevant(l_relevant(l_relevant(l_j).parent).mid).tid;
      END IF;
      l_relevant(l_j).tid := l_cnt;
      l_cnt := l_cnt+1;
    END IF;
    --leaf item?
    IF l_relevant(l_j).child < 0 AND
       l_relevant(l_j).child_qty > 0
    THEN
      l_res(l_cnt).id := l_cnt;
      l_res(l_cnt).item_id := l_relevant(l_j).de_item_id;
      IF l_relevant(l_j).de_item_id <> l_relevant(l_j).item_id
      THEN
        l_res(l_cnt).item_name := l_relevant(l_j).de_item;
      ELSE
        l_res(l_cnt).item_name := l_relevant(l_j).de_item_sub||' '||l_relevant(l_j).de_item_loc;
      END IF;
      l_res(l_cnt).quantity := l_relevant(l_j).child_qty;
      l_res(l_cnt).parent := l_relevant(l_relevant(l_j).mid).tid;
      l_cnt := l_cnt+1;
    END IF;
  END LOOP;

  --
  -- print result
  --

  --output the result to a string/multiple strings
--  DBMS_OUTPUT.PUT_LINE('TOTAL: '||l_cnt);
  l_numstring := toStrings(l_res, l_cnt, l_resstring);
  FOR l_j IN 0..l_numstring-1 LOOP
--    DBMS_OUTPUT.PUT_LINE(l_resstring(l_j));
    o_result(l_j) := l_resstring(l_j);
  END LOOP;
  o_numdays := l_numdays;


  --
  -- Send Message
  --

  -- To Be Finished: send out all strings in l_resstring, each as a message

EXCEPTION
  WHEN OTHERS THEN
--    DBMS_OUTPUT.PUT_LINE(SQLERRM);
--    DBMS_OUTPUT.PUT_LINE(SQLCODE);
   null;
END;

PROCEDURE demand_graph (i_pull_sequence_id IN NUMBER,
                        o_result OUT NOCOPY t_sres,
                        o_error_num OUT NOCOPY NUMBER,
                        o_error_msg OUT NOCOPY VARCHAR2) IS
  --
  -- Some constants
  --
  l_max_strlen	INTEGER := 550; -- Maximum Length of a String

  --
  -- The subinventory, location, component, and dates we want to explore
  --
  l_des_sub	VARCHAR2(40);
  l_des_loc	VARCHAR2(204);
  l_des_comp	VARCHAR2(40);
  l_des_locid	INTEGER;
  l_des_compid	INTEGER;
  l_kp_id	INTEGER;
  l_org_id	INTEGER;

  --
  -- Types
  --
  TYPE t_arow IS RECORD (
    item	VARCHAR2(40),
    item_id	INTEGER,
    item_sub	VARCHAR2(10),
    item_loc	VARCHAR2(204),
    de_date	DATE,
    quantity	INTEGER
  );

  TYPE t_quan IS RECORD (
    ddate	DATE,
    quantity	INTEGER
  );

  TYPE t_data IS TABLE OF t_arow
    INDEX BY BINARY_INTEGER;

  TYPE t_res IS TABLE OF t_quan
    INDEX BY BINARY_INTEGER;

  --
  -- Variables
  --
  l_res		t_res;
  l_sres	t_sres;
  l_numstring	INTEGER;

  l_arow	t_arow;
  l_numrec	INTEGER;
  l_j		INTEGER;
  l_sdate	DATE;
  l_edate	DATE;

  --
  -- Cursors
  --
  CURSOR relevant IS
    SELECT msi.segment1 item,
      mkd.inventory_item_id item_id,
      mkd.subinventory item_sub,
      substr(mil.concatenated_segments, 0, 5) item_loc,
      trunc(demand_date) d,
      demand_quantity quantity
    FROM mrp_kanban_demand mkd, mtl_system_items msi,
         mtl_item_locations_kfv mil
    WHERE mkd.kanban_plan_id = l_kp_id
      AND (mkd.subinventory = l_des_sub OR
           (mkd.subinventory IS NULL AND
	    l_des_sub IS NULL))
      AND (substr(mil.concatenated_segments, 0, 5) = l_des_loc OR
           (l_des_loc IS NULL AND
            substr(mil.concatenated_segments, 0, 5) IS NULL))
      AND mkd.organization_id = msi.organization_id
      AND mkd.inventory_item_id = msi.inventory_item_id
      AND msi.segment1 = l_des_comp
      AND mkd.locator_id = mil.inventory_location_id(+)
     ORDER BY demand_date, msi.segment1, mkd.subinventory;


  --
  -- Put the result tree into a string/multiple strings, which
  -- is taken as a message/multiple messages to transmit in Oracle
  -- Form environment.
  -- Return the number of strings
  --
  -- Format used:
  -- RES := 'COMMAND/INIT/OTHER/TOTAL/SEQN/[SUB/LOC/COMP/SDATE/EDATE]'
  --         ROW['@'ROW]*'/'
  -- ROW := DATE'%'QUANTITY
  -- TOTAL := [0-9]+
  -- SEQN := [0-9]+
  -- SDATE := DATE
  -- EDATE := DATE
  -- DATE := MMDDYYYY
  -- QUANTITY := [0-9]+
  -- SUB := IDENTIFIER
  -- LOC := IDENTIFIER
  -- COMP:= IDENTIFIER
  -- IDENTIFIER := ['A'-'Z'|'a'-'z'|'0'-'9'|'_'|'.']+
  --
  FUNCTION toStrings (
    list	IN	t_res,
    numitem	IN	INTEGER,
    sres	OUT	NOCOPY	t_sres
    ) RETURN INTEGER IS
    l_unit_len  INTEGER := 30;
    l_unit_num  INTEGER;
    l_total	INTEGER := 0;
    l_j		INTEGER;
    l_k		INTEGER;
    l_up	INTEGER;
  BEGIN
    -- nothing?
    IF numitem <= 0
    THEN
      RETURN 0;
    END IF;
    -- total number of strings
    l_unit_num := (l_max_strlen/l_unit_len)-2;
    l_total := CEIL(numitem/l_unit_num);
    --put strings
    FOR l_j IN 0..l_total-1 LOOP
--      sres(l_j) := 'COMMAND/INIT/OTHER/'||l_total||'/'||l_j||'/';
      sres(l_j) := l_total||'/'||l_j||'/';
      IF l_j = 0 -- first one?
      THEN
        sres(l_j) := sres(l_j)||l_des_sub||'/'||l_des_loc||'/'||l_des_comp||
                     '/'||TO_CHAR(l_sdate, 'MMDDYYYY')||'/'||
                     TO_CHAR(l_edate, 'MMDDYYYY')||'/';
      END IF;
      IF l_j >= l_total-1  -- last one?
      THEN
        l_up := numitem;
      ELSE
        l_up := (l_j+1)*l_unit_num;
      END IF;
      FOR l_k IN l_j*l_unit_num..l_up-1 LOOP
        sres(l_j) := sres(l_j) || TO_CHAR(list(l_k).ddate, 'MMDDYYYY') || '%';
        sres(l_j) := sres(l_j) || list(l_k).quantity || '%';
        IF l_k >= l_up-1
        THEN
          sres(l_j) := sres(l_j) || '/';
        ELSE
          sres(l_j) := sres(l_j) || '@';
        END IF;
      END LOOP;
    END LOOP;
    RETURN l_total;
  END;

BEGIN

  -- find out the kanban-plan-id, subinventory, locator-id, and item
  SELECT kanban_plan_id, subinventory_name, locator_id, inventory_item_id, organization_id
  INTO l_kp_id, l_des_sub, l_des_locid, l_des_compid, l_org_id
  FROM mtl_kanban_pull_sequences
  WHERE pull_sequence_id = i_pull_sequence_id;

--  DBMS_OUTPUT.PUT_LINE(l_kp_id || l_des_sub || l_des_locid || l_des_compid);

  -- find out the start-date and end-date
  --SELECT plan_start_date, plan_cutoff_date
  --Added nvl for start/end dates by ks for bug 3883026
  SELECT nvl(plan_start_date,sysdate), nvl(plan_cutoff_date,sysdate)
  INTO l_sdate, l_edate
  FROM mrp_kanban_plans
  WHERE kanban_plan_id = l_kp_id;

  SELECT DISTINCT segment1
  INTO l_des_comp
  FROM mtl_system_items
  WHERE inventory_item_id = l_des_compid AND
        organization_id = l_org_id;

  IF NOT l_des_locid IS NULL
  THEN
    SELECT substr(concatenated_segments, 0, 5)
    INTO l_des_loc
    FROM mtl_item_locations_kfv
    WHERE inventory_location_id = l_des_locid;
  END IF;

  -- retrieve data from database and process it
  OPEN relevant;
  l_numrec := 1;
  l_res(0).ddate := l_sdate;
  l_res(0).quantity := 0;
  LOOP
    FETCH relevant INTO l_arow;
    EXIT WHEN relevant%NOTFOUND;
/*    IF l_numrec = 0 OR
       l_res(l_numrec-1).ddate <> l_arow.de_date
    THEN
      -- a new one
      l_numrec := l_numrec+1;
      l_res(l_numrec-1).quantity := 0;
    END IF;*/

    WHILE l_res(l_numrec-1).ddate < l_arow.de_date
    LOOP
      -- a new one
      l_numrec := l_numrec+1;
      l_res(l_numrec-1).quantity := 0;
      IF l_numrec <= 1
      THEN
        l_res(l_numrec-1).ddate := l_arow.de_date;
      ELSE
        l_res(l_numrec-1).ddate := mrp_calendar.next_work_day(l_org_id, 1, l_res(l_numrec-2).ddate+1);
      END IF;
    END LOOP;

    l_res(l_numrec-1).ddate := l_arow.de_date;
    l_res(l_numrec-1).quantity := l_res(l_numrec-1).quantity + l_arow.quantity;
    --DBMS_OUTPUT.PUT_LINE(l_arow.item||'   '||l_arow.item_sub||'   '||l_arow.item_loc||'   '||l_arow.de_date||'   '||l_arow.quantity);
  END LOOP;
  WHILE l_res(l_numrec-1).ddate < l_edate
  LOOP
    l_numrec := l_numrec+1;
    l_res(l_numrec-1).ddate := mrp_calendar.next_work_day(l_org_id, 1, l_res(l_numrec-2).ddate+1);
    l_res(l_numrec-1).quantity := 0;
  END LOOP;
  CLOSE relevant;

  --
  -- put result into string(s)
  --
  l_numstring := toStrings(l_res, l_numrec, l_sres);
  FOR l_j IN 0..l_numstring-1 LOOP
--    DBMS_OUTPUT.PUT_LINE(l_sres(l_j));
    o_result(l_j) := l_sres(l_j);
  END LOOP;

  --
  -- Send Message
  --

  -- To Be Finished: send out all strings in l_sres, each as a message

END demand_graph;

FUNCTION Plan_Prod_Same_Pos ( p_plan_pull_seq_id NUMBER
			     ,p_prod_pull_seq_id NUMBER)
Return BOOLEAN
IS
	l_plan_Rec INV_Kanban_Pvt.Pull_sequence_Rec_Type;
	l_prod_Rec INV_Kanban_Pvt.Pull_sequence_Rec_Type;
	l_same_pos	number:=0;
BEGIN
	l_plan_Rec := INV_PullSequence_PKG.query_row(p_plan_pull_seq_id);
	l_prod_Rec := INV_PullSequence_PKG.query_row(p_prod_pull_seq_id);

	IF(l_plan_Rec.source_type = l_prod_Rec.source_type ) THEN

		IF (l_plan_Rec.source_type = G_Source_Type_InterOrg) THEN	/*Inter org*/
			IF (l_plan_rec.source_organization_id = l_prod_Rec.source_organization_id) THEN
				IF( (l_plan_rec.source_subinventory = l_prod_rec.source_subinventory)
				    AND (nvl(l_plan_rec.source_locator_id,-1) = nvl(l_prod_rec.source_locator_id,-1))) THEN
					return true;
				END IF;
			END IF;
		ELSIF (l_plan_Rec.source_type = G_Source_Type_Supplier) THEN  /*Supplier*/
			--IF( (l_plan_rec.supplier_id = l_prod_rec.supplier_id)
                        IF( (nvl(l_plan_rec.supplier_id,-1) = nvl(l_prod_rec.supplier_id,-1)) --bug 5156587
			    AND (nvl(l_plan_rec.supplier_site_id,-1) = nvl(l_prod_rec.supplier_site_id,-1))) THEN
				return true;
			end if;
		ELSIF (l_plan_Rec.source_type = G_Source_Type_IntraOrg) THEN  /*Intra org*/
			IF( (l_plan_rec.source_subinventory = l_prod_rec.source_subinventory)
			    AND (nvl(l_plan_rec.source_locator_id,-1) = nvl(l_prod_rec.source_locator_id,-1))) THEN
				return true;
			END IF;
		ELSE					/*Production*/
			--IF( l_plan_rec.wip_line_id = l_prod_rec.wip_line_id) THEN
                        IF( nvl(l_plan_rec.wip_line_id,-1) = nvl(l_prod_rec.wip_line_id,-1)) THEN --bug 5156587
				return true;
			END IF;
		END IF;
	END IF;
	return false;

END Plan_Prod_Same_Pos;

FUNCTION number_of_days(sdate IN DATE, edate IN DATE, org_id IN NUMBER)
  RETURN NUMBER IS
  l_result NUMBER := 1;
  l_d1 DATE;
BEGIN
  l_d1 := sdate;
  WHILE l_d1 < edate LOOP
    l_d1 := mrp_calendar.next_work_day(org_id, 1, l_d1+1);
    l_result := l_result+1;
  END LOOP;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 1;
END number_of_days;


END flm_kanban;

/
