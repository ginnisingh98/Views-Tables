--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_WF_UTIL" AUTHID CURRENT_USER as
/* $Header: hxcapprwfut.pkh 120.0 2005/05/29 06:12:23 appldev noship $ */

   Procedure copy_previous_approvers
      (p_item_type   in wf_item_types.name%type,
       p_current_key in wf_item_attribute_values.item_key%type,
       p_copyto_key  in wf_item_attribute_values.item_key%type);

   Function get_previous_approver
      (p_item_type     in wf_item_types.name%type,
       p_item_key      in wf_item_attribute_values.item_key%type,
       p_app_period_id in hxc_app_period_summary.application_period_id%type)
      Return number;

   Function keep_previous_approver
      (p_item_type     in wf_item_types.name%type,
       p_item_key      in wf_item_attribute_values.item_key%type,
       p_app_period_id in hxc_app_period_summary.application_period_id%type)
      Return number;

End hxc_approval_wf_util;

 

/
