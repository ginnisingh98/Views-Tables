--------------------------------------------------------
--  DDL for Package Body MSC_SEARCH_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SEARCH_TREE" AS
        /* $Header: MSCSRCHB.pls 120.1 2005/07/06 13:31:37 pabram noship $ */

PROCEDURE query_results(p_query_id NUMBER, p_where VARCHAR2, p_type VARCHAR2) IS

  stmt_str	VARCHAR2(2000);

BEGIN

  IF p_type = 'MSC_ORGANIZATIONS_TREE' THEN

    stmt_str := 'INSERT INTO msc_form_query ' ||
	'(query_id,last_update_date, last_updated_by, creation_date, '||
	'created_by, last_update_login, ' ||
	'number1, char1, number2, number3, char2, number4, char3, ' ||
	'number5, char4, number6, char5, number7, char6, ' ||
	'number8, char7, number9, char8, number10, char9) ' ||
	'SELECT distinct :query_id, sysdate, 1, sysdate, 1, 1, ' ||
	'search.plan_id, search.compile_designator, search.sr_instance_id, ' ||
	'search.organization_id, search.organization_code, '||
	'search.category_id, search.category_name, '||
        'search.product_family_id, search.product_family_name, '||
	'search.inventory_item_id, search.item_name, search.component_id, '||
	'search.component_name, search.department_id, '||
	'search.department_code, search.resource_id, search.resource_code, '||
	'search.line_id, search.line_code ' ||
	'FROM msc_search_orgs_v search ' ||
	'WHERE 1=1 '|| p_where;

  ELSIF p_type = 'MSC_ITEMS_TREE' THEN

    stmt_str := 'INSERT INTO msc_form_query ' ||
	'(query_id,last_update_date, last_updated_by, creation_date, '||
	'created_by, last_update_login, ' ||
	'number1, char1, number2, number3, char2, number4, char3, ' ||
	'number5, number6, char4, number7, char5, number8, char6, ' ||
	'number9, char7, number10, char8, number11, char9) ' ||
	'SELECT :query_id, sysdate, 1, sysdate, 1, 1, ' ||
	'plan_id, compile_designator, sr_instance_id, organization_id, '||
	'organization_code, product_family_id, product_family_name, '||
	'category_set_id, category_id, category_name, inventory_item_id, ' ||
	'item_name, component_id, component_name, department_id, '||
	'department_code, resource_id, resource_code, line_id, line_code ' ||
	'FROM msc_search_items_v search ' ||
	'WHERE 1=1 ' || p_where;

  ELSIF p_type = 'MSC_RESOURCES_TREE' THEN

    stmt_str := 'INSERT INTO msc_form_query ' ||
	'(query_id,last_update_date, last_updated_by, creation_date, '||
	'created_by, last_update_login, ' ||
	'number1, char1, number2, number3, char2, char3, ' ||
	'char4, number4, char5, ' ||
	'number5, char6, number6, char7, number7, char8) ' ||
	'SELECT :query_id, sysdate, 1, sysdate, 1, 1, ' ||
	'plan_id, compile_designator, sr_instance_id, organization_id, '||
	'organization_code, department_class, resource_group, '||
	'inventory_item_id, item_name, department_id, '||
	'department_code, resource_id, resource_code, line_id, line_code ' ||
	'FROM msc_search_resources_v search ' ||
	'WHERE 1=1 ' || p_where;

  ELSIF p_type = 'MSC_PROJECTS_TREE' THEN

    stmt_str := 'INSERT INTO msc_form_query ' ||
	'(query_id,last_update_date, last_updated_by, creation_date, '||
	'created_by, last_update_login, ' ||
	'number1, char1, number2, number3, char2, char3, ' ||
	'number4, char4, number5, char5, number6, char6) ' ||
	'SELECT :query_id, sysdate, 1, sysdate, 1, 1, ' ||
	'plan_id, compile_designator, sr_instance_id, organization_id, '||
	'organization_code, planning_group, '||
	'inventory_item_id, item_name, project_id, '||
	'project_name, task_id, task_name ' ||
	'FROM msc_search_projects_v search ' ||
	'WHERE 1=1 ' || p_where;

  ELSIF p_type = 'MSC_ACTIONS_TREE' THEN

    stmt_str := 'INSERT INTO msc_form_query ' ||
	'(query_id,last_update_date, last_updated_by, creation_date, '||
	'created_by, last_update_login, ' ||
	'number1, char1, number2, number3, char2, char3, ' ||
	'number4, char4, number5, char5) ' ||
	'SELECT :query_id, sysdate, 1, sysdate, 1, 1, ' ||
	'plan_id, compile_designator, sr_instance_id, organization_id, '||
	'organization_code, version, exception_type, exception_type_text, '||
	'inventory_item_id, item_name '||
	'FROM msc_search_actions_v search ' ||
	'WHERE 1=1 ' || p_where;

  END IF;

  EXECUTE IMMEDIATE stmt_str
	USING p_query_id;

END query_results;

END MSC_SEARCH_TREE;

/
