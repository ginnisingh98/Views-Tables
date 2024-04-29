--------------------------------------------------------
--  DDL for Package Body ZPB_REPOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_REPOS" AS
/* $Header: ZPBVREPB.plb 120.0.12010.4 2006/08/03 12:07:22 appldev noship $ */

procedure upgrade_zpb_root(p_bus_area_id varchar2)
is
   system_path varchar2(5000);
   new_root varchar2(5000);
begin
  new_root := 'oracle/apps/zpb/BusArea'||p_bus_area_id||'/';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Begin upgrade of repository related tables');

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrading ZPB repos root to '||new_root);

  update ZPB_CYCLE_MODEL_DIMENSIONS
  set QUERY_OBJECT_PATH = new_root||QUERY_OBJECT_PATH
  where QUERY_OBJECT_PATH like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_CYCLE_MODEL_DIMENSIONS complete');

  update ZPB_DC_OBJECTS
  set target_obj_path = new_root||target_obj_path
  where target_obj_path like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_DC_OBJECTS complete');

  update ZPB_DC_OBJECTS
  set dataentry_obj_path = new_root||dataentry_obj_path
  where dataentry_obj_path like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_DC_OBJECTS complete');

  update zpb_status_sql
  set QUERY_PATH = new_root||QUERY_PATH
  where QUERY_PATH like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of zpb_status_sql complete');

  update ZPB_DEPENDENT_OBJECTS
  set document_name = new_root||document_name
  where document_name like '%/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_DEPENDENT_OBJECTS complete');

  update ZPB_DEPENDENT_OBJECTS
  set saved_selection_name = new_root||saved_selection_name
  where saved_selection_name like '%/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_DEPENDENT_OBJECTS complete');

  update ZPB_WRITEBACK_TRANSACTION
  set QDR = new_root||QDR
  where QDR like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_WRITEBACK_TRANSACTION complete');

  update zpb_line_dimensionality
  set sum_selection_path = new_root||sum_selection_path
  where sum_selection_path like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of zpb_line_dimensionality complete');

  update zpb_task_parameters
  set VALUE = new_root||VALUE
  where value like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of zpb_task_parameters complete');

  update ZPB_SOLVE_OUTPUT_SELECTIONS
  set selection_path = new_root||selection_path
  where selection_path like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_SOLVE_OUTPUT_SELECTIONS complete');

  update ZPB_SOLVE_INPUT_SELECTIONS
  set selection_path = new_root||selection_path
  where selection_path like 'ZPBSystem/%';

  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of ZPB_SOLVE_INPUT_SELECTIONS complete');



  zpb_log.write('zpb_repos.change_zpb_root',
                 'Upgrade of Repository-related tables complete');


end upgrade_zpb_root;

END;


/
