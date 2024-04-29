--------------------------------------------------------
--  DDL for Package Body GMO_INSTR_ENTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTR_ENTITY_PVT" AS
/* $Header: GMOVINEB.pls 120.5 2006/06/15 08:33:42 rahugupt noship $ */



function GET_ENTITYKEY_SEPARATOR_COUNT (P_ENTITY_KEY IN VARCHAR2) RETURN NUMBER

IS

BEGIN

	return (length(replace(P_ENTITY_KEY, '$', '$$')) - length(P_ENTITY_KEY));

END GET_ENTITYKEY_SEPARATOR_COUNT;


--This function would verify if the step is locked or not.

function GET_ENTITY_DISPLAY_NAME (P_ENTITY_NAME IN VARCHAR2, P_ENTITY_KEY IN VARCHAR2) RETURN VARCHAR2

IS

l_entity_display_name varchar2(300);
l_entity_key_sep_count number;

l_inventory_item_id number;
l_organization_id number;

l_resources varchar2(300);
l_oprn_line_id number;
l_oprn_id number;
l_routingstep_id number;
l_recipe_id number;
l_formulaline_id number;


cursor get_oprn is
	select oprn_no from gmd_operations
	where oprn_id  = l_oprn_id;

cursor get_routing_oprn is
	select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'ROUTING') || ' ' || c.routing_no || ' : '  ||  routingstep_no || '-' || oprn_no
	from gmd_operations a, fm_rout_dtl b, gmd_routings c
	where a.oprn_id = b.oprn_id
	and c.routing_id = b.routing_id
	and b.routingstep_id = l_routingstep_id
	and a.oprn_id = l_oprn_id;

cursor get_recipe_oprn is

	select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'RECIPE') || ' ' || recipe_no || ' : ' || b.routingstep_no || '-' || a.oprn_no
	from gmd_operations a, fm_rout_dtl b, gmd_recipes c
	where a.oprn_id = b.oprn_id and b.routing_id = c.routing_id
	and c.recipe_id = l_recipe_id and b.routingstep_id = l_routingstep_id and a.oprn_id = l_oprn_id;


cursor get_activity is
	select activity from gmd_operation_activities where oprn_line_id = l_oprn_line_id;

cursor get_routing_activity is
	select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'ROUTING') || ' ' || c.routing_no || ' : '  || d.activity
	from gmd_operations a, fm_rout_dtl b, gmd_routings c, gmd_operation_activities d
	where a.oprn_id = b.oprn_id
	and c.routing_id = b.routing_id
	and a.oprn_id = d.oprn_id
	and d.oprn_line_id = l_oprn_line_id
	and b.routingstep_id = l_routingstep_id;

cursor get_recipe_activity is
	select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'RECIPE') || ' ' || recipe_no || ' : ' ||  d.activity
	from gmd_operations a, fm_rout_dtl b, gmd_recipes c, gmd_operation_activities d
	where a.oprn_id = b.oprn_id and b.routing_id = c.routing_id and a.oprn_id = d.oprn_id
	and b.routingstep_id = l_routingstep_id
	and c.recipe_id = l_recipe_id
	and d.oprn_line_id = l_oprn_line_id;

cursor get_resource is
	select b.resources
	from gmd_operation_activities a, gmd_operation_resources b
	where a.oprn_line_id = b.oprn_line_id
	and a.oprn_line_id = l_oprn_line_id
	and b.resources = l_resources;

cursor get_routing_resource is

	select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'ROUTING') || ' ' || c.routing_no || ' : ' || e.resources
	from gmd_operations a, fm_rout_dtl b, gmd_routings c, gmd_operation_activities d, gmd_operation_resources e
	where a.oprn_id = b.oprn_id
	and c.routing_id = b.routing_id
	and a.oprn_id = d.oprn_id
	and d.oprn_line_id = e.oprn_line_id
	and b.routingstep_id = l_routingstep_id
	and d.oprn_line_id = l_oprn_line_id
	and e.resources = l_resources;

cursor get_recipe_resource is
	select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'RECIPE') || ' ' || recipe_no || ' : ' ||  e.resources
	from gmd_operations a, fm_rout_dtl b, gmd_recipes c, gmd_operation_activities d, gmd_operation_resources e
	where a.oprn_id = b.oprn_id and b.routing_id = c.routing_id and a.oprn_id = d.oprn_id and d.oprn_line_id = e.oprn_line_id
	and c.recipe_id = l_recipe_id
	and b.routingstep_id = l_routingstep_id
	and e.oprn_line_id = l_oprn_line_id
	and e.resources = l_resources;

cursor get_formula_material is
	Select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'FORMULA') || ' ' || c.formula_no || ' : ' || b.Concatenated_segments
	from fm_matl_dtl a, mtl_system_items_kfv b, fm_form_mst c
	where a.inventory_item_id = b.inventory_item_id
	and a.organization_id = b.organization_id
	and a.formula_id = c.formula_id
	and a.inventory_item_id = l_inventory_item_id
	and a.formulaline_id = l_formulaline_id;

cursor get_recipe_material is
	Select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'RECIPE') || ' ' || c.recipe_no || ' : ' || b.Concatenated_segments
	from fm_matl_dtl a, mtl_system_items_kfv b, gmd_recipes c
	where a.inventory_item_id = b.inventory_item_id
	and a.organization_id=b.organization_id
	and a.formula_id = c.formula_id
	and a.inventory_item_id = l_inventory_item_id
	and a.formulaline_id = l_formulaline_id
	and c.recipe_id = l_recipe_id;

cursor get_dispense_item is
	Select a.Concatenated_segments
	from mtl_system_items_kfv a
	where a.inventory_item_id = l_inventory_item_id;

cursor get_org_dispense_item is
	Select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'ORGANIZATION') || ' ' || b.organization_code || ' : ' || a.Concatenated_segments
	from mtl_system_items_kfv a, mtl_parameters b
	where a.organization_id=b.organization_id
	and a.inventory_item_id = l_inventory_item_id
	and a.organization_id = l_organization_id;


cursor get_recipe_dispense_item is
	Select gmo_utilities.get_lookup_meaning ('GMO_INSTR_ENTITY_CODES', 'RECIPE') || ' ' || c.recipe_no || ' : ' || a.Concatenated_segments
	from mtl_system_items_kfv a, mtl_parameters b, gmd_recipes c, fm_matl_dtl d
	where a.organization_id=b.organization_id
	and d.formula_id = c.formula_id
	and d.inventory_item_id = a.inventory_item_id
	and a.inventory_item_id = l_inventory_item_id
	and a.organization_id = l_organization_id
	and c.recipe_id = l_recipe_id;

cursor get_dispense_config_details is
        select inventory_item_id,
               organization_id,
               recipe_id
        from   gmo_dispense_config
        where  config_id = to_number(p_entity_key,'999999999999.999999');


BEGIN

	l_entity_key_sep_count := GET_ENTITYKEY_SEPARATOR_COUNT(p_entity_key);

	if (p_entity_name = 'OPERATION') then

		if (l_entity_key_sep_count = 0) then

			l_oprn_id := to_number(p_entity_key);
			open get_oprn;
			fetch get_oprn into l_entity_display_name;
			close get_oprn;

		elsif (l_entity_key_sep_count = 1) then

			l_routingstep_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_oprn_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1));
			open get_routing_oprn;
			fetch get_routing_oprn into l_entity_display_name;
			close get_routing_oprn;

		elsif (l_entity_key_sep_count = 2) then

			l_recipe_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_routingstep_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1, (instr (p_entity_key, '$', 1,2 )-1) - instr (p_entity_key, '$')));
			l_oprn_id := to_number(substr(p_entity_key, instr (p_entity_key, '$', 1,2) + 1));

			open get_recipe_oprn;
			fetch get_recipe_oprn into l_entity_display_name;
			close get_recipe_oprn;
		end if;

	elsif (p_entity_name = 'ACTIVITY') then

		if (l_entity_key_sep_count = 0) then

			l_oprn_line_id := to_number(p_entity_key);
			open get_activity;
			fetch get_activity into l_entity_display_name;
			close get_activity;

		elsif (l_entity_key_sep_count = 1) then

			l_routingstep_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_oprn_line_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1));
			open get_routing_activity;
			fetch get_routing_activity into l_entity_display_name;
			close get_routing_activity;

		elsif (l_entity_key_sep_count = 2) then

			l_recipe_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_routingstep_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1, (instr (p_entity_key, '$', 1,2 )-1) - instr (p_entity_key, '$')));
			l_oprn_line_id := to_number(substr(p_entity_key, instr (p_entity_key, '$', 1,2) + 1));
			open get_recipe_activity;
			fetch get_recipe_activity into l_entity_display_name;
			close get_recipe_activity;

		end if;

	elsif (p_entity_name = 'RESOURCE') then

		if (l_entity_key_sep_count = 1) then

			l_oprn_line_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_resources := substr(p_entity_key, instr (p_entity_key, '$') + 1);
			open get_resource;
			fetch get_resource into l_entity_display_name;
			close get_resource;

		elsif (l_entity_key_sep_count = 2) then

			l_routingstep_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_oprn_line_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1, (instr (p_entity_key, '$', 1,2 )-1) - instr (p_entity_key, '$')));
			l_resources := substr(p_entity_key, instr (p_entity_key, '$', 1,2) + 1);
			open get_routing_resource;
			fetch get_routing_resource into l_entity_display_name;
			close get_routing_resource;

		elsif (l_entity_key_sep_count = 3) then


			l_recipe_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_routingstep_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1, (instr (p_entity_key, '$', 1,2 )-1) - instr (p_entity_key, '$')));
			l_oprn_line_id := to_number (substr(p_entity_key, instr (p_entity_key, '$', 1,2) + 1, (instr (p_entity_key, '$', 1,3)-1) - instr (p_entity_key, '$', 1,2)));
			l_resources := substr(p_entity_key, instr (p_entity_key, '$', 1,3) + 1);

			open get_recipe_resource;
			fetch get_recipe_resource into l_entity_display_name;
			close get_recipe_resource;
		end if;

	elsif (p_entity_name = 'MATERIAL') then

		if (l_entity_key_sep_count = 1) then

			l_formulaline_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_inventory_item_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1));

			open get_formula_material;
			fetch get_formula_material into l_entity_display_name;
			close get_formula_material;
		elsif (l_entity_key_sep_count = 2) then

			l_recipe_id := to_number (substr(p_entity_key, 1, instr (p_entity_key, '$') - 1));
			l_formulaline_id := to_number (substr(p_entity_key, instr (p_entity_key, '$') + 1, (instr (p_entity_key, '$', 1,2 )-1) - instr (p_entity_key, '$')));
			l_inventory_item_id := to_number(substr(p_entity_key, instr (p_entity_key, '$', 1,2) + 1));

			open get_recipe_material;
			fetch get_recipe_material into l_entity_display_name;
			close get_recipe_material;

		end if;
	elsif (p_entity_name = 'DISPENSE_ITEM') then

                open get_dispense_config_details;
                fetch get_dispense_config_details into l_inventory_item_id,l_organization_id,l_recipe_id;
		close get_dispense_config_details;

		if (l_inventory_item_id is not null and l_organization_id is null and l_recipe_id is null) then

			open get_dispense_item;
			fetch get_dispense_item into l_entity_display_name;
			close get_dispense_item;

		elsif (l_inventory_item_id is not null and l_organization_id is not null and l_recipe_id is null) then

			open get_org_dispense_item;
			fetch get_org_dispense_item into l_entity_display_name;
			close get_org_dispense_item;

		elsif (l_inventory_item_id is not null and l_organization_id is not null and l_recipe_id is not null) then

			open get_recipe_dispense_item;
			fetch get_recipe_dispense_item into l_entity_display_name;
			close get_recipe_dispense_item;
		end if;

	end if;

	return l_entity_display_name;


END GET_ENTITY_DISPLAY_NAME;

--Bug 5203096: start
function GET_TARGET_TASK_ATTRIBUTE
(
P_ENTITY_NAME IN VARCHAR2,
P_SOURCE_ENTITY_KEY IN VARCHAR2,
P_TARGET_ENTITY_KEY IN VARCHAR2,
P_TASK_ID IN NUMBER,
P_TASK_ATTRIBUTE_ID IN VARCHAR2
)
RETURN VARCHAR2
IS
l_task_attribute_id varchar2(4000);
l_new_task_attribute_id varchar2(4000);
l_oprn_line_id number;
l_other varchar2(4000);
t_old_oprn_line_id fnd_table_of_varchar2_255;
t_new_oprn_line_id fnd_table_of_varchar2_255;
l_old_oprn_line_id number;
l_new_oprn_line_id number;
j binary_integer;
l_task_id number;
l_task_name varchar2(100);
l_source_entity_key_sep number;
l_target_entity_key_sep number;
l_source_oprn_id number;
l_target_oprn_id number;

cursor get_task_name is select task_name from gmo_instr_task_defn_b where task_id = P_TASK_ID;

cursor get_old_oprn_line is select oprn_line_id FROM gmd_operation_activities where oprn_id = l_source_oprn_id order by oprn_line_id;
cursor get_new_oprn_line is select oprn_line_id FROM gmd_operation_activities where oprn_id = l_target_oprn_id order by oprn_line_id;

BEGIN

	l_task_name := '';

	open get_task_name;
	fetch get_task_name into l_task_name;
	close get_task_name;

	t_old_oprn_line_id := fnd_table_of_varchar2_255();
	t_new_oprn_line_id := fnd_table_of_varchar2_255();
	l_task_attribute_id := P_TASK_ATTRIBUTE_ID;

	if ( (l_task_attribute_id is not null) and
	     (l_task_name = GMO_CONSTANTS_GRP.TASK_RESOURCE_TRANSACTION or l_task_name = GMO_CONSTANTS_GRP.TASK_PROCESS_PARAMETER) and
	      (P_ENTITY_NAME = GMO_CONSTANTS_GRP.ENTITY_OPERATION)
	) then

		l_source_entity_key_sep := GET_ENTITYKEY_SEPARATOR_COUNT(P_SOURCE_ENTITY_KEY);
		l_target_entity_key_sep := GET_ENTITYKEY_SEPARATOR_COUNT(P_TARGET_ENTITY_KEY);

		--at operation level
		if (l_source_entity_key_sep = 0) then
			l_source_oprn_id := P_SOURCE_ENTITY_KEY;
		--at routing level
		elsif (l_source_entity_key_sep = 1) then
			l_source_oprn_id := substr(P_SOURCE_ENTITY_KEY, instr(P_SOURCE_ENTITY_KEY, '$') + 1);
		--at recipe level
		elsif (l_source_entity_key_sep = 2) then
       		        l_source_oprn_id := substr(P_SOURCE_ENTITY_KEY, instr (P_SOURCE_ENTITY_KEY, '$', 1,2) + 1);
		end if;

		if (l_target_entity_key_sep = 0) then
			l_target_oprn_id := P_TARGET_ENTITY_KEY;
		elsif (l_target_entity_key_sep = 1) then
			l_target_oprn_id := substr(P_TARGET_ENTITY_KEY, instr(P_TARGET_ENTITY_KEY, '$') + 1);
		elsif (l_target_entity_key_sep = 2) then
       	     	        l_target_oprn_id := substr(P_TARGET_ENTITY_KEY, instr (P_TARGET_ENTITY_KEY, '$', 1,2) + 1);
		end if;

		-- pattern = OprnLineId$Resources or OprnLineId$Resources$ParamId
		l_oprn_line_id := to_number (substr(l_task_attribute_id, 1, instr (l_task_attribute_id, '$') - 1));
		l_other := substr(l_task_attribute_id, instr (l_task_attribute_id, '$') + 1);

		l_new_task_attribute_id := null;

		--we need to take care at operating level only
		--at routing and recipe level, the oprnid remains same
		if (l_source_entity_key_sep = 0) then

			j := 0;
			open get_old_oprn_line;
			loop
			fetch get_old_oprn_line into l_old_oprn_line_id;
			exit when get_old_oprn_line%NOTFOUND;

				t_old_oprn_line_id.extend;
				j := j+1;
				t_old_oprn_line_id(j) := l_old_oprn_line_id;
			end loop;
			close get_old_oprn_line;

			j := 0;
       	                open get_new_oprn_line;
                        loop
                        fetch get_new_oprn_line into l_new_oprn_line_id;
                        exit when get_new_oprn_line%NOTFOUND;

                                t_new_oprn_line_id.extend;
                                j := j+1;
                                t_new_oprn_line_id(j) := l_new_oprn_line_id;
                        end loop;
                        close get_new_oprn_line;

			for i in 1 .. t_old_oprn_line_id.count loop
				if l_oprn_line_id =to_number(t_old_oprn_line_id(i)) then
					if (t_new_oprn_line_id.count >= i) then
						l_new_task_attribute_id := t_new_oprn_line_id(i) || '$' || l_other;
					end if;
				end if;
			end loop;

		end if;
	end if;
	if (l_new_task_attribute_id is null) then
		l_new_task_attribute_id := P_TASK_ATTRIBUTE_ID;
	end if;
	return l_new_task_attribute_id;
END GET_TARGET_TASK_ATTRIBUTE;

procedure UPDATE_TASK_ATTRIBUTE
(
P_INSTRUCTION_PROCESS_ID IN NUMBER,
P_INSTRUCTION_SET_ID IN NUMBER,
P_ENTITY_NAME IN VARCHAR2,
P_SOURCE_ENTITY_KEY IN VARCHAR2,
P_TARGET_ENTITY_KEY IN VARCHAR2
)
IS
l_instruction_id number;
l_task_attribute_id varchar2(4000);
l_new_task_attribute_id varchar2(4000);
l_task_id number;

cursor get_instr_details is select instruction_id, task_id, task_attribute_id from gmo_instr_defn_t where instruction_process_id = P_INSTRUCTION_PROCESS_ID and instruction_set_id=P_INSTRUCTION_SET_ID;


BEGIN
	IF (P_SOURCE_ENTITY_KEY <> P_TARGET_ENTITY_KEY) THEN
		open get_instr_details;
		loop
		fetch get_instr_details into l_instruction_id,l_task_id, l_task_attribute_id;
		exit when get_instr_details%NOTFOUND;

			if (l_task_attribute_id is not null) then
				l_new_task_attribute_id := GET_TARGET_TASK_ATTRIBUTE (
								P_ENTITY_NAME => P_ENTITY_NAME,
								P_SOURCE_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
								P_TARGET_ENTITY_KEY => P_TARGET_ENTITY_KEY,
								P_TASK_ID => L_TASK_ID,
								P_TASK_ATTRIBUTE_ID => L_TASK_ATTRIBUTE_ID
							);

				update gmo_instr_defn_t set task_attribute_id = l_new_task_attribute_id
				where instruction_process_id = P_INSTRUCTION_PROCESS_ID and instruction_id = l_instruction_id;
			end if;

		end loop;
		close get_instr_details;
	END IF;
END UPDATE_TASK_ATTRIBUTE;
--Bug 5203096: end

END GMO_INSTR_ENTITY_PVT;

/
