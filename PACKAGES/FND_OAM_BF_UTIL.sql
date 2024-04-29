--------------------------------------------------------
--  DDL for Package FND_OAM_BF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_BF_UTIL" AUTHID CURRENT_USER as
/* $Header: AFOAMFLS.pls 115.0 2003/10/31 03:58:43 ppradhan noship $ */

  --
  -- Name
  --   refresh_metrics
  --
  -- Purpose
  --   computes and rolls up metrics related to business flows such as
  --    - count of open system alerts
  --    - count of errored concurrent requests
  --    - count of errored work items
  --
  --   The resulting values will get populated into fnd_oam_bf_comp_info,
  --   fnd_oam_bf_wit_info and fnd_oam_bf_rollup_info tables.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_metrics;

  --
  -- Updates the monitored flag for the given flow
  -- Updates fnd_oam_bf_cust if record exists for given flow key
  -- Otherwise, copies entry from fnd_oam_bf to
  -- fnd_oam_bf_cust and updates the monitored_flag in
  -- fnd_oam_bf_cust.
  --
  --
  PROCEDURE update_bf_monitored_flag (
	p_flow_key varchar2,
	p_new_flag varchar2);

  --
  -- Updates the monitored flag for the given sub flow in context of the
  -- given parent flow.
  -- Updates fnd_oam_bf_assoc_cust if record exists for given parent
  -- and child. Otherwise, copies entry from fnd_oam_bf_assoc to
  -- fnd_oam_bf_assoc_cust and updates the monitored_flag in
  -- fnd_oam_bf_assoc_cust.
  --
  --
  PROCEDURE update_bf_monitored_flag (
	p_parent_flow_key varchar2,
	p_child_flow_key varchar2,
	p_new_flag varchar2);

  --
  -- Updates the monitored flag for the given component in context of the
  -- given parent flow.
  -- Updates fnd_oam_bf_comp_cust if record exists for given parent
  -- and child. Otherwise, copies entry from fnd_oam_bf_comp to
  -- fnd_oam_bf_comp_cust and updates the monitored_flag in
  -- fnd_oam_bf_comp_cust.
  --
  --
  PROCEDURE update_comp_monitored_flag (
	p_parent_flow_key varchar2,
	p_component_type varchar2,
        p_component_appl_id number,
	p_component_id number,
	p_new_flag varchar2);

  --
  -- Updates the monitored flag for the given item type in context of the
  -- given parent flow.
  -- Updates fnd_oam_bf_wit_cust if record exists for given parent
  -- and child. Otherwise, copies entry from fnd_oam_bf_wit to
  -- fnd_oam_bf_wit_cust and updates the monitored_flag in
  -- fnd_oam_bf_wit_cust.
  --
  --
  PROCEDURE update_wit_monitored_flag (
	p_parent_flow_key varchar2,
	p_item_type varchar2,
	p_new_flag varchar2);

end FND_OAM_BF_UTIL;

 

/
