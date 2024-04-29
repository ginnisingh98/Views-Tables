--------------------------------------------------------
--  DDL for Package EDW_PROJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_PROJ_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICAPJS.pls 120.0 2002/08/24 04:50:11 appldev noship $  */

-- ------------------------
-- Public Functions
-- ------------------------
Function project_fk(
   p_project_id        in NUMBER,
   p_instance_code     in VARCHAR2 := NULL)
   return VARCHAR2;

Function seiban_number_fk(
   p_project_id        in NUMBER,
   p_instance_code     in VARCHAR2 := NULL)
   return VARCHAR2;

Function task_fk(
   p_task_id           in NUMBER,
   p_project_id        in NUMBER   := NULL,
   p_instance_code     in VARCHAR2 := NULL)
   return VARCHAR2;

Function top_task_fk(
   p_task_id           in NUMBER,
   p_project_id        in NUMBER   := NULL,
   p_instance_code     in VARCHAR2 := NULL)
   return VARCHAR2;

PRAGMA RESTRICT_REFERENCES (project_fk,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (task_fk,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (top_task_fk,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (seiban_number_fk,WNDS,WNPS, RNPS);
end;

 

/
