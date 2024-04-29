--------------------------------------------------------
--  DDL for Package AZW_HIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZW_HIER" AUTHID CURRENT_USER AS
/* $Header: AZWHIERS.pls 115.5 99/07/16 19:28:29 porting sh $ */

--
-- Name:        get_hierarchy
-- Description: Retrieves grouping processes, wf processes, and
--              wf tasks after applying filters.
-- Parameters:
--   	All the selection criteria from Find window
--
  PROCEDURE get_hierarchy (process_group      IN VARCHAR2,
                           process_status     IN VARCHAR2,
                           process_phase      IN NUMBER,
                           assigned_user      IN VARCHAR2,
                           task_status        IN VARCHAR2,
                           task_total_days    IN NUMBER,
                           task_total_days_op IN VARCHAR2,
                           sort_by            IN VARCHAR2);

END AZW_HIER;

 

/
