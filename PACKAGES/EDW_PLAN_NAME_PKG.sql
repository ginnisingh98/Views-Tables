--------------------------------------------------------
--  DDL for Package EDW_PLAN_NAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_PLAN_NAME_PKG" AUTHID CURRENT_USER AS

   FUNCTION get_plan_name_fk (
      p_compile_designator IN VARCHAR2,
      p_organization_id IN NUMBER,
      p_instance_code in VARCHAR2 := NULL)	RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_plan_name_fk, WNDS, WNPS, RNPS);

END edw_plan_name_pkg;

 

/
