--------------------------------------------------------
--  DDL for Package CSF_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_MAP_PVT" AUTHID CURRENT_USER AS
/* $Header: CSFVMAPS.pls 120.0 2005/09/15 21:33:48 sseshaiy noship $ */
   FUNCTION predict_time_difference (p_task_assignment_id NUMBER)
      RETURN NUMBER;

   FUNCTION get_progress_status (p_resource_id NUMBER, p_resource_type_code VARCHAR2, p_date DATE)
      RETURN NUMBER;
END csf_map_pvt;

 

/
