--------------------------------------------------------
--  DDL for Package CN_CW_WORKBENCH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CW_WORKBENCH_UTILITY" AUTHID CURRENT_USER AS
-- $Header: cnvcwuts.pls 120.1 2005/08/08 03:17 raramasa noship $

function get_go_to_task_image_name(p_org_id in number)
  return varchar2;

function get_item_status_name (p_workbench_item_code  in   varchar2,p_org_id in varchar2)
  return varchar2;

function get_required_field (p_workbench_item_code  in   varchar2)
  return varchar2;

END CN_CW_WORKBENCH_UTILITY;
 

/
