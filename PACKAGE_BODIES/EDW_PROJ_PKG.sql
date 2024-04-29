--------------------------------------------------------
--  DDL for Package Body EDW_PROJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_PROJ_PKG" AS
/* $Header: FIICAPJB.pls 120.0 2002/08/24 04:50:07 appldev noship $  */


-- ----------------------
--  function PROJECT_FK
-- ----------------------

function project_fk(p_project_id        in NUMBER,
                    p_instance_code     in VARCHAR2 := NULL)
return varchar2 is
  x_instance            varchar2(40);
begin

   if p_project_id IS NULL then
     return 'NA_EDW';
   end if;

   if p_instance_code IS NULL then
     x_instance := edw_instance.get_code;
   else
     x_instance := p_instance_code;
   end if;

   return p_project_id || '-' || x_instance || '-PJ-PRJ';

end Project_fk;

-- ----------------------------
--  function SEIBAN_NUMBER_FK
-- ----------------------------

function seiban_number_fk(p_project_id        in NUMBER,
                          p_instance_code     in VARCHAR2 := NULL)
return varchar2 is
  x_instance            varchar2(40);
begin

   if p_project_id IS NULL then
     return 'NA_EDW';
   end if;

   if p_instance_code IS NULL then
     x_instance := edw_instance.get_code;
   else
     x_instance := p_instance_code;
   end if;

   return p_project_id || '-' || x_instance || '-SB-PRJ';

end seiban_number_fk;

-- ----------------------
--  function TASK_FK
-- ----------------------

Function task_fk( p_task_id         in NUMBER,
                  p_project_id      in NUMBER := NULL,
                  p_instance_code   in VARCHAR2 := NULL)
return VARCHAR2 IS

  x_instance            varchar2(40);

BEGIN

   if p_task_id IS NULL then
     return 'NA_EDW';
   end if;

   if p_instance_code IS NULL then
     x_instance := edw_instance.get_code;
   else
     x_instance := p_instance_code;
   end if;

   return p_task_id || '-' || x_instance;

END Task_fk;

-- ----------------------
--  function TOP_TASK_FK
-- ----------------------


Function top_task_fk(p_task_id         in NUMBER,
                     p_project_id      in NUMBER := NULL,
                     p_instance_code   in VARCHAR2 := NULL)
return VARCHAR2 IS

  x_instance            varchar2(40);

BEGIN

   if p_task_id IS NULL then
     return 'NA_EDW';
   end if;

   if p_instance_code IS NULL then
     x_instance := edw_instance.get_code;
   else
     x_instance := p_instance_code;
   end if;

   return p_task_id || '-' || x_instance;

END top_task_fk;

end;

/
