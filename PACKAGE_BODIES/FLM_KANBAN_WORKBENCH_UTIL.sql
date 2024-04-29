--------------------------------------------------------
--  DDL for Package Body FLM_KANBAN_WORKBENCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_KANBAN_WORKBENCH_UTIL" AS
/* $Header: FLMWBUTB.pls 115.0 99/09/07 14:42:45 porting ship    $  */

FUNCTION Get_Category_Id(    p_plan_id		  IN      NUMBER,
                             p_organization_id	  IN      NUMBER,
                             p_component_item_id  IN      NUMBER )
RETURN NUMBER	IS
l_category_id    NUMBER:= NULL;
BEGIN
	SELECT DISTINCT(component_category_id)
	INTO   l_category_id
	FROM   MRP_LOW_LEVEL_CODES
	WHERE  plan_id = p_plan_id
	AND    organization_id = p_organization_id
	AND    component_item_id = p_component_item_id;
	return l_category_id;
END Get_Category_Id;
END FLM_KANBAN_WORKBENCH_UTIL;

/
