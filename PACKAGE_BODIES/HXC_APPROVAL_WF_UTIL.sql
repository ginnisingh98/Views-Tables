--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_WF_UTIL" as
/* $Header: hxcapprwfut.pkb 120.0 2005/05/29 06:12:16 appldev noship $ */

c_previous_root          constant varchar2(12) := 'PREVIOUS_APP';
c_previous_approver_name constant varchar2(17) := 'PREVIOUS_APPROVER';
c_app_id_name            constant varchar2(17) := 'PREVIOUS_APP_ID';

   Procedure copy_previous_approvers
      (p_item_type   in wf_item_types.name%type,
       p_current_key in wf_item_attribute_values.item_key%type,
       p_copyto_key  in wf_item_attribute_values.item_key%type) is


      cursor c_copy_approvers
              (p_item_type in wf_item_types.name%type,
               p_item_key  in wf_item_attribute_values.item_key%type) is
       select name, number_value
         from wf_item_attribute_values
        where item_type = p_item_type
          and item_key = p_item_key
          and name like c_previous_root||'%';

   Begin

      for copy_approvers_rec in c_copy_approvers(p_item_type,p_current_key) loop

         wf_engine.additemattr
            (p_item_type,
             p_copyto_key,
             copy_approvers_rec.name,
             null,
             copy_approvers_rec.number_value,
             null);

      end loop;

   end copy_previous_approvers;

   Function get_previous_approver
      (p_item_type     in wf_item_types.name%type,
       p_item_key      in wf_item_attribute_values.item_key%type,
       p_app_period_id in hxc_app_period_summary.application_period_id%type)
      Return number is

      cursor c_previous_approver
                (p_item_type in wf_item_types.name%type,
                 p_item_key in wf_item_attribute_values.item_key%type,
                 p_app_period_id in hxc_app_period_summary.application_period_id%type) is
        select preapr.number_value
          from wf_item_attribute_values appid,
               wf_item_attribute_values preapr
         where appid.number_value = p_app_period_id
           and appid.item_type = p_item_type
           and appid.item_key = p_item_key
           and appid.name like c_app_id_name||'%'
           and preapr.item_type = appid.item_type
           and preapr.item_key = appid.item_key
           and preapr.name = replace(appid.name,c_app_id_name,c_previous_approver_name);

      l_previous_approver wf_item_attribute_values.number_value%type;

   Begin
      open c_previous_approver(p_item_type,p_item_key,p_app_period_id);
      fetch c_previous_approver into l_previous_approver;
      if(c_previous_approver%notfound) then
         l_previous_approver := -1;
      end if;
      close c_previous_approver;

      return l_previous_approver;

   End get_previous_approver;

   Function keep_previous_approver
      (p_item_type     in wf_item_types.name%type,
       p_item_key      in wf_item_attribute_values.item_key%type,
       p_app_period_id in hxc_app_period_summary.application_period_id%type)
      RETURN number is

      cursor c_previous_approver
         (p_app_id in hxc_app_period_summary.application_period_id%type) is
        select approver_id
          from hxc_app_period_summary
         where application_period_id = p_app_id;

      cursor c_previous_approvers
         (p_item_type in wf_item_types.name%type,
          p_item_key in wf_item_attribute_values.item_key%type) is
        select count(*)
          from wf_item_attribute_values
         where item_type = p_item_type
           and item_key = p_item_key
           and name like c_previous_approver_name||'%';

      l_previous_approver     hxc_app_period_summary.approver_id%type;
      l_previous_approvers    number;
      l_item_attribute_name   wf_item_attribute_values.name%type;
      l_item_attr_app_id_name wf_item_attribute_values.name%type;

   Begin
      --
      -- 0. Find the last approver of this application period
      --
      open c_previous_approver(p_app_period_id);
      fetch c_previous_approver into l_previous_approver;
      if(c_previous_approver%notfound) then
         --
         -- 0.5 set the previous approver to -1.
         --
         l_previous_approver := -1;
      end if;
      close c_previous_approver;
      --
      -- 1. Set the item attribute value to store it
      --
      open c_previous_approvers(p_item_type, p_item_key);
      fetch c_previous_approvers into l_previous_approvers;
      if (c_previous_approvers%notfound) then
         l_previous_approvers := 0;
      end if;
      close c_previous_approvers;
      l_item_attribute_name := c_previous_approver_name||l_previous_approvers;
      l_item_attr_app_id_name := c_app_id_name||l_previous_approvers;
      --
      -- Store the application period id
      --
      wf_engine.additemattr
         (p_item_type,
          p_item_key,
          l_item_attr_app_id_name,
          null,
          p_app_period_id,
          null);
      --
      -- Store the previous approver
      --
      wf_engine.additemattr
         (p_item_type,
          p_item_key,
          l_item_attribute_name,
          null,
          l_previous_approver,
          null);

      return l_previous_approvers;

   End keep_previous_approver;

End hxc_approval_wf_util;

/
