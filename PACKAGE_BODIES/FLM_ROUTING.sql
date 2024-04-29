--------------------------------------------------------
--  DDL for Package Body FLM_ROUTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_ROUTING" AS
/* $Header: FLMRTGDB.pls 120.1 2006/05/16 14:51:15 yulin noship $  */

PROCEDURE retrieve_items (
	i_org_id	IN	NUMBER,
	i_from_item	IN	VARCHAR2,
	i_to_item	IN	VARCHAR2,
	i_product_family_id	IN	NUMBER,
	i_category_set_id	IN	NUMBER,
	i_category_id	IN	NUMBER,
	i_planner_code	IN	VARCHAR2,
	i_alternate_routing_designator	IN	VARCHAR2,
	o_item_tbl	OUT	NOCOPY	item_tbl_type,
	o_return_code	OUT	NOCOPY	NUMBER) IS

  CURSOR all_items IS
    select msik.inventory_item_id id
    from mtl_system_items_kfv msik
    where msik.organization_id = i_org_id
      and msik.bom_enabled_flag = 'Y'
      and msik.inventory_item_flag ='Y'
      and msik.bom_item_type <> 3
      and msik.pick_components_flag = 'N'
      and msik.eng_item_flag = 'N'
      and ((msik.concatenated_segments >= i_from_item or
	    i_from_item is null) and
           (msik.concatenated_segments <= i_to_item or
	    i_to_item is null))
      and (i_product_family_id is null or
           msik.inventory_item_id in (
	     select bic.component_item_id
	     from bom_bill_of_materials bbom,
	          bom_inventory_components bic
	     where bbom.assembly_item_id = i_product_family_id
	       and bbom.organization_id = i_org_id
	       and bbom.alternate_bom_designator is null
	       and bbom.bill_sequence_id = bic.bill_sequence_id))
      and (i_category_id is null or
           msik.inventory_item_id in (
             select mic.inventory_item_id
	     from mtl_item_categories mic
	     where mic.organization_id = i_org_id
	       and mic.category_set_id = i_category_set_id
	       and mic.category_id = i_category_id))
      and (i_planner_code is null or
	   msik.planner_code = i_planner_code)
      and not exists (
	    select bor.routing_sequence_id
	    from bom_operational_routings bor
	    where bor.assembly_item_id = msik.inventory_item_id
	      and bor.organization_id = i_org_id
	      -- Added for enhancement #2647023
	      and nvl(bor.alternate_routing_designator, '~$~') = nvl(i_alternate_routing_designator, '~$~') )
    order by msik.concatenated_segments;

  l_index	NUMBER;
  l_routing_id	NUMBER;
BEGIN
  o_item_tbl.delete;
  l_index := 1;
  FOR item IN all_items LOOP
    o_item_tbl(l_index) := item.id;
    l_index := l_index+1;
  END LOOP;
  o_return_code := 0;
EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;
END retrieve_items;


PROCEDURE a_retrieve_option_items (
	i_org_id		IN	NUMBER,
	i_from_item		IN	VARCHAR2,
	i_to_item	  	IN	VARCHAR2,
	i_product_family_id	IN	NUMBER,
	i_category_set_id	IN	NUMBER,
	i_category_id		IN	NUMBER,
	i_planner_code		IN	VARCHAR2,
	i_alternate_routing_designator	IN	VARCHAR2,
        i_assembly_item_id   	IN 	NUMBER,
        i_alt_designator        IN      VARCHAR2,
	o_return_code		OUT	NOCOPY	NUMBER) IS

  /* perf bug 5204346 - change in (...) to be a regular query */
  CURSOR all_option_items IS
select id from (
select distinct msik.inventory_item_id id, msik.concatenated_segments c_name
  from mtl_system_items_kfv msik, bom_bill_of_materials    bbom2,
               bom_inventory_components bic2
 where msik.organization_id = i_org_id
   and msik.bom_enabled_flag = 'Y'
   and msik.inventory_item_flag = 'Y'
   and msik.bom_item_type = 2
   and msik.pick_components_flag = 'N'
   and msik.eng_item_flag = 'N'
   and ((msik.concatenated_segments >= i_from_item or i_from_item is null) and
       (msik.concatenated_segments <= i_to_item or i_to_item is null))
   and (i_product_family_id is null or
       msik.inventory_item_id in
       (select bic.component_item_id
           from bom_bill_of_materials bbom, bom_inventory_components bic
          where bbom.assembly_item_id = i_product_family_id
            and bbom.organization_id = i_org_id
            and bbom.alternate_bom_designator is null
            and bbom.bill_sequence_id = bic.bill_sequence_id))
   and (i_category_id is null or
       msik.inventory_item_id in
       (select mic.inventory_item_id
           from mtl_item_categories mic
          where mic.organization_id = i_org_id
            and mic.category_set_id = i_category_set_id
            and mic.category_id = i_category_id))
   and (i_planner_code is null or msik.planner_code = i_planner_code)
   and not exists
 (select bor.routing_sequence_id
          from bom_operational_routings bor
         where bor.assembly_item_id = msik.inventory_item_id
           and bor.organization_id = i_org_id
              -- added for enhancement #2647023
           and nvl(bor.alternate_routing_designator, '~$~') =
               nvl(i_alternate_routing_designator, '~$~'))
  and bbom2.organization_id = i_org_id
           and bbom2.assembly_item_id = i_assembly_item_id
           and nvl(bbom2.alternate_bom_designator, '$$$') =
               nvl(i_alt_designator, '$$$')
           and bic2.bill_sequence_id = bbom2.common_bill_sequence_id
           and nvl(bic2.effectivity_date, sysdate - 1) < sysdate
           and nvl(bic2.disable_date, sysdate + 1) > sysdate
           and msik.inventory_item_id = bic2.component_item_id
) order by c_name;

/*    select msik.inventory_item_id id
    from mtl_system_items_kfv msik
    where msik.organization_id = i_org_id
      and msik.bom_enabled_flag = 'Y'
      and msik.inventory_item_flag = 'Y'
      and msik.bom_item_type =2
      and msik.pick_components_flag = 'N'
      and msik.eng_item_flag = 'N'
      and ((msik.concatenated_segments >= i_from_item or
	    i_from_item is null) and
           (msik.concatenated_segments <= i_to_item or
	    i_to_item is null))
      and (i_product_family_id is null or
           msik.inventory_item_id in (
	     select bic.component_item_id
	     from bom_bill_of_materials bbom,
	          bom_inventory_components bic
	     where bbom.assembly_item_id = i_product_family_id
	       and bbom.organization_id = i_org_id
	       and bbom.alternate_bom_designator is null
	       and bbom.bill_sequence_id = bic.bill_sequence_id))
      and (i_category_id is null or
           msik.inventory_item_id in (
             select mic.inventory_item_id
	     from mtl_item_categories mic
	     where mic.organization_id = i_org_id
	       and mic.category_set_id = i_category_set_id
	       and mic.category_id = i_category_id))
      and (i_planner_code is null or
	   msik.planner_code = i_planner_code)
      and not exists (
	    select bor.routing_sequence_id
	    from bom_operational_routings bor
	    where bor.assembly_item_id = msik.inventory_item_id
	      and bor.organization_id = i_org_id
	      -- Added for enhancement #2647023
	      and nvl(bor.alternate_routing_designator, '~$~') = nvl(i_alternate_routing_designator, '~$~') )
      and msik.inventory_item_id in (
            select bic2.component_item_id
            from   mtl_system_items_b msi2,
                   bom_bill_of_materials bbom2,
                   bom_inventory_components bic2
            where  bbom2.organization_id = i_org_id and
                   bbom2.assembly_item_id = i_assembly_item_id and
                   nvl(bbom2.alternate_bom_designator,'$$$') = nvl(i_alt_designator,'$$$') and
                   bic2.bill_sequence_id = bbom2.common_bill_sequence_id and
                   msi2.organization_id = i_org_id and
                   bic2.component_item_id = msi2.inventory_item_id and
                   msi2.bom_item_type = 2 and
                   nvl(bic2.effectivity_date,sysdate-1) < sysdate and
                   nvl(bic2.disable_date,sysdate+1) > sysdate)
    order by msik.concatenated_segments; */

  l_index	NUMBER;
  l_routing_id	NUMBER;
  l_count       NUMBER;
  l_bill_count  NUMBER := 0;
  item_already_exist BOOLEAN := FALSE;
BEGIN

  select count(*)
  into   l_bill_count
  from   bom_bill_of_materials
  where  assembly_item_id = i_assembly_item_id and
         organization_id = i_org_id and
           nvl(alternate_bom_designator,'$$$') =
             nvl(i_alt_designator,'$$$');

  if(l_bill_count = 0) then
    return;
  end if;

  l_index := 1;
  FOR item IN all_option_items LOOP

    --check that this item not exist in table(check for loop also)
    item_already_exist := false;
    if(g_item_tbl.COUNT > 1) then
      for i in g_item_tbl.FIRST .. g_item_tbl.LAST
      LOOP
        if(g_item_tbl(i) = item.id) then
          item_already_exist := true;
        end if;
      END LOOP;
    end if;

    if(item_already_exist = false) then
      g_item_tbl(g_tbl_index) := item.id;
      g_tbl_index := g_tbl_index+1;
      a_retrieve_option_items(i_org_id,
      			i_from_item,
    			i_to_item,
  			i_product_family_id,
  			i_category_set_id,
			i_category_id,
			i_planner_code,
			i_alternate_routing_designator,
		        item.id,
		        i_alt_designator,
			o_return_code);
    end if;
  END LOOP;
  o_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;

END a_retrieve_option_items;


PROCEDURE retrieve_option_items (
	i_org_id		IN	NUMBER,
	i_from_item		IN	VARCHAR2,
	i_to_item	  	IN	VARCHAR2,
	i_product_family_id	IN	NUMBER,
	i_category_set_id	IN	NUMBER,
	i_category_id		IN	NUMBER,
	i_planner_code		IN	VARCHAR2,
	i_alternate_routing_designator	IN	VARCHAR2,
        i_assembly_item_id   	IN 	NUMBER,
        i_alt_designator        IN      VARCHAR2,
	o_item_tbl		OUT	NOCOPY	item_tbl_type,
	o_return_code		OUT	NOCOPY	NUMBER) IS
BEGIN

  g_item_tbl.delete;
  g_tbl_index := 0;

  a_retrieve_option_items(i_org_id,
			i_from_item,
			i_to_item,
			i_product_family_id,
			i_category_set_id,
			i_category_id,
			i_planner_code,
			i_alternate_routing_designator,
		        i_assembly_item_id,
		        i_alt_designator,
			o_return_code);
  --return the table of items
  o_item_tbl := g_item_tbl;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;

END retrieve_option_items;


PROCEDURE retrieve_mass_change_items (
	i_org_id	IN	NUMBER,
	i_line_id	IN	NUMBER,
	i_from_item	IN	VARCHAR2,
	i_to_item	IN	VARCHAR2,
	i_product_family_id	IN	NUMBER,
	i_category_set_id	IN	NUMBER,
	i_category_id	IN	NUMBER,
	i_planner_code	IN	VARCHAR2,
	i_alt_desig_code IN   	VARCHAR2,
	i_alt_desig_check IN    NUMBER,
        i_item_type_pf    IN    NUMBER,
	o_item_tbl	OUT	NOCOPY	item_rtg_tbl_type,
	o_return_code	OUT	NOCOPY	NUMBER) IS

  CURSOR all_items IS
    select msik.inventory_item_id id, bor1.alternate_routing_designator alt
    from mtl_system_items_kfv msik, bom_operational_routings bor1
    where msik.organization_id = i_org_id
      and msik.organization_id = bor1.organization_id
      and msik.inventory_item_id = bor1.assembly_item_id
      and msik.bom_enabled_flag = 'Y'
      and msik.inventory_item_flag = 'Y'
      and msik.bom_item_type <> 3
      and msik.pick_components_flag = 'N'
      and bor1.routing_type = 1
      and msik.eng_item_flag = 'N'
      and ((msik.concatenated_segments >= i_from_item or
	    i_from_item is null) and
           (msik.concatenated_segments <= i_to_item or
	    i_to_item is null))
      and (i_product_family_id is null or
           msik.inventory_item_id in (
	     select bic.component_item_id
	     from bom_bill_of_materials bbom,
	          bom_inventory_components bic
	     where bbom.assembly_item_id = i_product_family_id
	       and bbom.organization_id = i_org_id
	       and bbom.alternate_bom_designator is null
	       and bbom.bill_sequence_id = bic.bill_sequence_id))
      and (i_category_id is null or
           msik.inventory_item_id in (
             select mic.inventory_item_id
	     from mtl_item_categories mic
	     where mic.organization_id = i_org_id
	       and mic.category_set_id = i_category_set_id
	       and mic.category_id = i_category_id))
      and (i_planner_code is null or
	   msik.planner_code = i_planner_code)
      and ( (nvl(i_alt_desig_check,2) = 2) or
            (i_alt_desig_check = 1 and
              nvl(bor1.alternate_routing_designator,'$$$') =
              nvl(i_alt_desig_code,'$$$') ) )
      and ( (i_item_type_pf = 1 and msik.bom_item_type = 5) or
            (i_item_type_pf = 2 and msik.bom_item_type <> 5)
          )
   order by msik.concatenated_segments;

  l_index	NUMBER;
  l_routing_id	NUMBER;
  l_routing_found NUMBER:=0;
  l_max_level     NUMBER;
  dummy NUMBER;
BEGIN

  o_item_tbl.delete;
  l_index := 1;

  FOR item IN all_items LOOP

    l_routing_found := 0;

    select count(routing_sequence_id)
    into   l_routing_found
    from   bom_operational_routings
    where  organization_id = i_org_id and
           line_id = i_line_id and
           assembly_item_id = item.id and
           nvl(alternate_routing_designator,'$$$') =
             nvl(item.alt,'$$$');

    if(l_routing_found > 0) then
      o_item_tbl(l_index).item_id := item.id;
      o_item_tbl(l_index).routing_designator := item.alt;
      l_index := l_index+1;
    end if;

  END LOOP;
  o_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;

END retrieve_mass_change_items;

END flm_routing;

/
