--------------------------------------------------------
--  DDL for Package PJI_FM_SUM_BKLG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_SUM_BKLG" AUTHID CURRENT_USER AS
/* $Header: PJISF12S.pls 120.2 2005/11/10 20:22:04 appldev noship $ */

  --Name: Init_Drmt_Bklg
  --Type: Procedure
  --
  --Description:
  -- The procedure initiates the calculation for following project-related
  -- 1) Revenue at Risk
  -- 2) Dormant Backlog
  -- 3) Not Started Backlog
  -- 4) Lost Backlog
  -- 5) Active Backlog
  --
  -- This procedure is called by PJI Summarization Process
  --
  -- At the start of this procedure, this procedure retrieves selected
  -- enterprise calendar ITD numbersand stores them in a persistent table
  -- for subsequent insert processing.
  --
  -- This procedure inserts project day records to the
  -- PJI_FM_AGGR_ACT partitioned tmp table. The insert
  -- generates most of the required numbers.
  --
  -- Subsequently, the tmp table rows are merged back into the
  -- PJI_AC_PROJ_F fact table.
  --
  --NOTE:
  --
  --
  --Called subprograms:
  --
  --
  --History:
  -- 25-JUL-2002	vgautam	Created
  --

  procedure ROWID_ACTIVITY_DATES_FIN  (p_worker_id in number);

  procedure UPDATE_ACTIVITY_DATES_FIN (p_worker_id in number);

  procedure ROWID_ACTIVITY_DATES_ACT  (p_worker_id in number);

  procedure UPDATE_ACTIVITY_DATES_ACT (p_worker_id in number);

  procedure SCOPE_PROJECTS_BKLG       (p_worker_id in number);

  procedure CLEANUP_INT_TABLE         (p_worker_id in number);

  procedure PROCESS_DRMT_BKLG         (p_worker_id in number);

end PJI_FM_SUM_BKLG;

 

/
