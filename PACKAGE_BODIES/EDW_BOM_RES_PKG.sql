--------------------------------------------------------
--  DDL for Package Body EDW_BOM_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_BOM_RES_PKG" AS
/* $Header: ENIBRESB.pls 115.4 2004/01/30 20:42:20 sbag noship $  */

Function Resource_FK(
        p_dept_line_id                  in NUMBER,
        p_resource_id                   in NUMBER ) return VARCHAR2 IS
  l_res         VARCHAR2(80) := 'NA_EDW';

  CURSOR c1 is
  select  res.resource_code||'-'||dept.department_code||'-'||
                mp.organization_code||'-'||inst.instance_code
      from      mtl_parameters mp,
                bom_departments dept,
                bom_resources res,
                bom_department_resources dept_res,
		edw_local_instance inst
      where     mp.organization_id = dept.organization_id
      and       dept.department_id = nvl(dept_res.share_from_dept_id,
                                         dept_res.department_id)
      and       res.resource_id = dept_res.resource_id
      and       dept_res.department_id = p_dept_line_id
      and       dept_res.resource_id = p_resource_id;
  CURSOR c2 is
  select  lines.line_code||'-'||mp.organization_code||'-'||inst.instance_code
      from      mtl_parameters mp,
                wip_lines lines,
		edw_local_instance inst
      where     mp.organization_id = lines.organization_id
      and       lines.line_id = p_dept_line_id;
BEGIN
  if (p_dept_line_id is not NULL) then

    if (p_resource_id is not NULL) then
      -- ---------------------------------
      -- If it's a discrete resources
      -- ---------------------------------
        OPEN c1;
        FETCH c1 into l_res;
        CLOSE c1;
    else
      -- ---------------------------------
      -- If it's an assembly line
      -- ---------------------------------
        OPEN c2;
        FETCH c2 into l_res;
        CLOSE c2;
    end if;

  end if;

  return(l_res);

EXCEPTION when others then
  if (p_resource_id is not NULL) then
        CLOSE c1;
  else
	CLOSE c2;
  end if;

  return('Invalid '||to_char(p_dept_line_id)||'-'||
         to_char(p_resource_id));

END Resource_FK;

END; --package body

/
