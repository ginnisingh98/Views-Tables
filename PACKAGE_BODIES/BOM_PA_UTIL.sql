--------------------------------------------------------
--  DDL for Package Body BOM_PA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_PA_UTIL" AS
/* $Header: BOMPAUTB.pls 120.1 2006/02/01 04:34:25 arudresh noship $ */
/***************************************************************************
--
--
--  FILENAME
--
--      BOMPAUTB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_PA_Util
--
--  NOTES
--
--  HISTORY
--
--  27-JUN-03 Refai Farook  Initial Creation
--
--
****************************************************************************/

   Function Get_Lifecycle(p_lifecycle_id NUMBER) RETURN VARCHAR2 is
     l_name VARCHAR2(240);
   BEGIN
     IF p_lifecycle_id IS NULL
     THEN
       Return NULL;
     ELSE
       SELECT name INTO l_name FROM pa_ego_lifecycles_v WHERE proj_element_id = p_lifecycle_id AND
        object_type = 'PA_STRUCTURES';
       Return l_name;
     END IF;
    EXCEPTION WHEN OTHERS THEN
      Return NULL;
   END;

   Function Get_Phase(p_phase_id NUMBER) RETURN VARCHAR2 is
     l_name VARCHAR2(240);
   BEGIN
     IF p_phase_id IS NULL
     THEN
       Return NULL;
     ELSE
       SELECT name INTO l_name FROM pa_ego_phases_v WHERE proj_element_id = p_phase_id AND
        object_type = 'PA_TASKS';
       Return l_name;
     END IF;
    EXCEPTION WHEN OTHERS THEN
      Return NULL;
   END;

END BOM_PA_Util;

/
