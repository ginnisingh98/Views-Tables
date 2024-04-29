--------------------------------------------------------
--  DDL for Package FLM_KANBAN_WORKBENCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_KANBAN_WORKBENCH_UTIL" AUTHID CURRENT_USER AS
/* $Header: FLMWBUTS.pls 115.1 99/11/01 10:45:36 porting sh $  */

FUNCTION Get_Category_Id(    p_plan_id            IN      NUMBER,
                             p_organization_id    IN      NUMBER,
                             p_component_item_id  IN      NUMBER )
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (Get_Category_Id,WNDS,WNPS);


END FLM_KANBAN_WORKBENCH_UTIL;

 

/
