--------------------------------------------------------
--  DDL for Package PER_RI_WORKBENCH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_WORKBENCH_UTILITY" AUTHID CURRENT_USER as
/* $Header: perriwbu.pkh 120.0.12010000.2 2008/11/28 17:51:38 sbrahmad ship $ */

  --------------------------------------------------------------------
  -- This function returns to status of the workbench items based upon the
  -- status of the tasks of the workbench items.
  -- Put logic here
  --------------------------------------------------------------------

function get_go_to_task_image_name(p_workbench_item_code  in   varchar2
                          ,p_workbench_item_type in varchar2)
  return varchar2;

function get_item_status_name (p_workbench_item_code  in   varchar2
                                ,p_workbench_item_type in varchar2)
  return varchar2;

function get_item_notes_image (p_workbench_item_code  in   varchar2
                                ,p_workbench_item_type in varchar2)
  return varchar2;

function get_item_last_modified_date (p_workbench_item_code in   varchar2)
  return varchar2;

function workbench_task_access_exist(fname varchar2,itemType number)
  return number;

end per_ri_workbench_utility;

/
