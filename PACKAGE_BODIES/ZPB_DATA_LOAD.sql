--------------------------------------------------------
--  DDL for Package Body ZPB_DATA_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DATA_LOAD" AS
/* $Header: zpbdataload.plb 120.0.12010.2 2005/12/23 07:19:04 appldev noship $ */

PROCEDURE RUN_DATA_LOAD(p_task_id IN NUMBER,
                        p_dataAW  in Varchar2,
                        p_codeAW  in Varchar2,
                        p_annotAW in Varchar2)
IS
  l_query_list        VARCHAR2(3950);
  l_instanceID        VARCHAR2(30);

BEGIN
  -- Run the first part of the load, which among other things, sets
  -- up all status-setting queries needed in the whole load.

  ZPB_AW.EXECUTE('call DL.RUN.1(' || TO_CHAR(p_task_id) || ')');

  -- Get the queue of SQL IDs that need to be executed.
--  l_query_list := zpb_aw.interp('show CM.SQLID.QUEUE');
--  l_query_list := SUBSTR(l_query_list, INSTR(l_query_list, '<<')+2);

--  ZPB_AW_STATUS.RUN_OLAPI_QUERIES(l_query_list);

  -- Run the final part of the load.
  ZPB_AW.EXECUTE('call DL.RUN.2');

  --
  -- Update the metadata map for this instance
  --
 -- select to_char(analysis_cycle_id)
  --   into l_instanceID
 --    from zpb_analysis_cycle_tasks
--     where task_id = p_task_id;

--  zpb_metadata_map_pkg.build_instance (p_dataAW, l_instanceID, 'SHARED');

  commit;
  return;

END RUN_DATA_LOAD;

END ZPB_DATA_LOAD;

/
