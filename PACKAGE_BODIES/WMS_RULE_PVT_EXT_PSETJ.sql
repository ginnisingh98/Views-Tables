--------------------------------------------------------
--  DDL for Package Body WMS_RULE_PVT_EXT_PSETJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_PVT_EXT_PSETJ" as
/* $Header: WMSOPPAB.pls 120.5 2005/10/07 10:27:01 gayu noship $ */

-- Package global variable that stores the package name
g_pkg_name    CONSTANT VARCHAR2(30) := 'WMS_RULE_PVT_EXT_PSETJ';
g_debug       NUMBER;
--
-- -----------------------------------------------------------------|
-- |---------------------< trace >----------------------------------|
-- -----------------------------------------------------------------|
--
-- {Start Of Comments}
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name        Reqd Type     Description
--   p_message   Yes  varchar2 Message to be displayed in the log file.
--   p_prompt    Yes  varchar2 Prompt.
--   p_level     No   number   Level.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- =============================================
-- Procedure to log message for Label Printing
-- =============================================
Procedure trace(p_message IN VARCHAR2, p_level number default 4) is
begin
     inv_log_util.TRACE(p_message, 'RULES_ENGINE_EXTENSION', p_level);
end trace;
--
--
-- API name    : update_mmtt
-- Type        : Private
-- Function    : Update the MMTT record with an appropriate operation plan id.
-- Input Parameters  :
--             p_task_id 		NUMBER
--             p_operation_plan_id	NUMBER
--
-- Output Parameters:
-- Version     :
--   Current version 1.0
--
-- Notes       :
--
-- This procedure update the MMTT record with an appropriate operation plan id
-- This is called from the assign_operation_plan API.
-- Date           Modification                                   Author
-- ------------   ------------                                   ------------------
-- 08 Aug. 2003   This procedure update the MMTT record with an  By Johnson Abraham
--                appropriate operation plan id                  for patchset 'J'.
--                This is called from the assign_operation_plan
--                API.
--
Procedure update_mmtt(
  p_task_id           IN    NUMBER
, p_operation_plan_id IN    NUMBER
, x_return_status     OUT   NOCOPY VARCHAR2
) is
    l_debug  NUMBER;
begin
   IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;
     -- Initialize API return status to success
     x_return_status  := fnd_api.g_ret_sts_success;

     if (l_debug = 1) then
         trace(' Entering procedure update_mmtt  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
         trace(  '   p_task_id   => ' || p_task_id
               ||'   p_operation_plan_id => ' || p_operation_plan_id, 4);
     end if;

     update mtl_material_transactions_temp mmtt
        set mmtt.operation_plan_id   = p_operation_plan_id
     where  mmtt.transaction_temp_id = p_task_id;

     if (l_debug =1) then
         trace(' Successfully updated MMTT record with operation_plan_id = ' || p_operation_plan_id, 1);
     end if;

     if (l_debug =1) then
        trace(' Exiting procedure update_mmtt  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
        trace(' x_return_status   => ' || x_return_status, 4);
     end if;
exception
      when others then
         -- Update return status.
         x_return_status  := fnd_api.g_ret_sts_error;

         if (l_debug =1) then
            trace(' Unable to update MMTT due to Error : ' || sqlerrm(sqlcode), 1);
            trace(' Exiting procedure update_mmtt  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
            trace(' x_return_status   => ' || x_return_status, 4);
         end if;
         return;
end update_mmtt;

--
-- API name    : Assign Operation Plan
-- Type        : Private
-- Function    : Assign Operation plan to a specific record in MMTT
-- Input Parameters  :
--           p_task_id NUMBER
--
-- Output Parameters:
-- Version     :
--   Current version 1.0
--
-- Notes       :
--
-- This procedure assign user defined operation plan to a specific task in
-- mtl_material_transactions_temp. Operation plan is implemeted by WMS rules.
-- This procedure calls the rule package created for operation plan rules to check
-- which operation plan rule actually matches the task in question.
-- Date           Modification                                   Author
-- ------------   ------------                                   ------------------
-- 08 Aug. 2003   Added 2 new input parameters in patchset 'J'.  By Johnson Abraham.
--                p_activity_type_id and p_organization_id.      for patchset 'J'.
--                For Inbound ATF, the  p_activity_type_id
--                will be passed in as a mandatory input
--                parameter.
--                The call to Outbound ATF will continue
--                via the wrapper 'assign_operation_plans'.
--                The change to the wrapper is that now
--                organization_id is also derived and hence
--                passed in to the 'assign_operation_plans'.
PROCEDURE assign_operation_plan_psetj(
  p_api_version      IN            NUMBER
, p_init_msg_list    IN            VARCHAR2
, p_commit           IN            VARCHAR2
, p_validation_level IN            NUMBER
, x_return_status    OUT NOCOPY    VARCHAR2
, x_msg_count        OUT NOCOPY    NUMBER
, x_msg_data         OUT NOCOPY    VARCHAR2
, p_task_id          IN            NUMBER
, p_activity_type_id IN            NUMBER
, p_organization_id  IN            NUMBER
) IS

    l_rule_id              NUMBER;
    l_pack_exists          NUMBER;
    l_package_name         VARCHAR2(30);
    l_count                NUMBER;
    l_return_status        NUMBER;
    l_found                BOOLEAN      := FALSE;
    l_wms_task_type        NUMBER;
    l_operation_plan_id    NUMBER;
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'Assign_operation_plan';

    -- ### new variables added for patchset 'J'
    l_plan_type_id        number;
    l_c_rules_loop        number := 0;

    l_debug            number ;
    l_loop_name        varchar2(100) := null;
    l_progress         number := null;
    l_organization_id  number := null;

    l_ret_status       varchar2(1);

    -- ### Cursor for task type rule loop
    -- ### Only rules with the same WMS system task type as the task
    -- ### will be selected
    -- ### Rules are ordered by rule weight and creation date
    -- @@@CURSOR c_rules_atf_outbound_pseti IS
    -- @@@ select rules.rule_id, mmtt.organization_id, mmtt.wms_task_type, rules.type_hdr_id
    -- @@@ from   wms_rules_b rules, wms_op_plans_b wop, mtl_material_transactions_temp mmtt
    -- @@@ where  rules.type_code = 7
    -- @@@ and    rules.enabled_flag = 'Y'
    -- @@@ and    rules.type_hdr_id = wop.operation_plan_id
    -- @@@ and    wop.system_task_type = NVL(mmtt.wms_task_type, wop.system_task_type)
    -- @@@ and    mmtt.transaction_temp_id = p_task_id
    -- @@@ and    rules.organization_id IN (mmtt.organization_id, -1)
    -- @@@ and    (wop.organization_id = mmtt.organization_id or wop.common_to_all_org = 'Y') -- changed after review
    -- @@@ and    wop.enabled_flag = 'Y'
    -- @@@ order by rules.rule_weight desc, rules.creation_date;

    -- ### Added in patchset'J'
    CURSOR c_rules_atf_outbound_psetj IS
      select rules.rule_id, mmtt.organization_id, mmtt.wms_task_type, rules.type_hdr_id
      from   wms_rules_b rules, wms_op_plans_b wop, mtl_material_transactions_temp mmtt
      where  rules.type_code = 7
      and    rules.enabled_flag = 'Y'
      and    rules.type_hdr_id = wop.operation_plan_id
      and    wop.system_task_type = NVL(mmtt.wms_task_type, wop.system_task_type)
      and    mmtt.transaction_source_type_id IN (2, 8) --restrict to sales order and internal order mmtts only
      and    mmtt.transaction_temp_id = p_task_id
      and    rules.organization_id IN (mmtt.organization_id, -1)
      and    wop.enabled_flag = 'Y'
      and    wop.activity_type_id = 2 -- (Outbound)
      order by rules.rule_weight desc, rules.creation_date;


    -- ### Added in Patchset 'J'
    CURSOR c_rules_atf_inbound IS
      select rules.rule_id, mmtt.organization_id, mmtt.wms_task_type, rules.type_hdr_id,
             wop.plan_type_id -- new column added
      from   wms_rules_b rules, wms_op_plans_b wop, mtl_material_transactions_temp mmtt,
             mtl_txn_request_lines mtrl -- new tables added
      where  rules.type_code = 7
      and    rules.enabled_flag = 'Y'
      and    rules.type_hdr_id = wop.operation_plan_id
      and    rules.organization_id in (mmtt.organization_id, -1)
      and    (wop.organization_id = mmtt.organization_id or wop.common_to_all_org = 'Y') -- changed after review
      and    wop.enabled_flag = 'Y'
      and    mmtt.transaction_temp_id = p_task_id
      and    mtrl.line_id = mmtt.move_order_line_id
      and    mtrl.organization_id = mmtt.organization_id
      and    wop.activity_type_id = 1
--
--    @@@    if (mtrl.backorder_delivery_detail_id is not null)
--    @@@    then
--    @@@       (backordered line)
--    @@@    else
--    @@@       <This emans that thisis Standard or Inspection Routing>
--    @@@       if (mtrl.inspection_flag is 1)
--    @@@       then
--    @@@         (Inspection routing)
--    @@@       elseif (mtrl.inspection_flag in (2, 3, null) or any other values)
--    @@@       then
--    @@@         (Standard Routing assumed)
--    @@@       end if;
--    @@@    end if;
      and    wop.plan_type_id  = decode(mtrl.inspection_status
					,1 --stamp inspection op plan
					,2
					--Inspection not req, stamped standard/xdock plan
					,Decode(mtrl.backorder_delivery_detail_id
						,NULL
						,1
						,3)
					)
--
      and    wop.template_flag <> 'Y'
      AND (wop.plan_type_id <> 3 OR      -- added for plan xdocking
	     (wop.plan_type_id = 3 AND
	      Nvl(wop.crossdock_to_wip_flag, 'N') = Decode(Nvl(mtrl.crossdock_type, 1), 1, 'N', 'Y')))
      order by rules.rule_weight desc, rules.creation_date;
    --{{
    --  Operation plan assignment should honor crossdock to WIP
    --}}

    -- ### Added in Patchset 'J'
    -- ### Move Order Types
    -- ### 3 Pick Wave (Outbound)
    -- ### 6 Put Away (Inbound)
    -- ### Cursor used to derive the default operation plan for Inbound.
    CURSOR c_default_op_plan_inbound IS
      select wop.plan_type_id, wop.operation_plan_id
      from   mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl,
             wms_op_plans_b wop
      where  mmtt.transaction_temp_id = p_task_id
      and    mtrl.line_id = mmtt.move_order_line_id
      and    wop.activity_type_id= 1
--
--    @@@    Changed on October 7th 2003. This decode is supposed to be read as follows:
--    @@@    if (mtrl.backorder_delivery_detail_id is not null)
--    @@@    then
--    @@@       (backordered line)
--    @@@    else
--    @@@       <This emans that thisis Standard or Inspection Routing>
--    @@@       if (mtrl.inspection_flag is 1)
--    @@@       then
--    @@@         (Inspection routing)
--    @@@       elseif (mtrl.inspection_flag in (2, 3, null) or any other values)
--    @@@       then
--    @@@         (Standard Routing assumed)
--    @@@       end if;
--    @@@    end if;
--    and    wop.plan_type_id  = decode(mtrl.backorder_delivery_detail_id, null, decode(mtrl.inspection_status, null, 1,  2), 3)
      and    wop.plan_type_id  = decode(mtrl.inspection_status
					,1 --stamp inspection op plan
					,2
					--Inspection not req, stamped standard/xdock plan
					,Decode(mtrl.backorder_delivery_detail_id
						,NULL
						,1
						,3)
					)
	AND Nvl(wop.crossdock_to_wip_flag, 'N') = Decode(Nvl(mtrl.crossdock_type, 1), 1, 'N', 'Y')

      and    enabled_flag  = 'Y'
      and    default_flag  =  'Y';

    -- ### This cursor has been modified by adding the MMTT table and joining the mtl_paramters to the MMTT.
    CURSOR c_default_op_plan_outbound IS
      select Nvl(default_pick_op_plan_id,1)
        from mtl_parameters mp, mtl_material_transactions_temp mmtt
       where mp.organization_id = mmtt.organization_id
       and   mmtt.transaction_temp_id = p_task_id
       AND   mmtt.transaction_source_type_id IN (2, 8); ----restrict to sales order and internal order mmtts only
    -- @@@ organization_id = p_organization_id



    -- ### cursor used to determine if the rule package exists
    CURSOR l_pack_gen IS
      SELECT COUNT(object_name)
        FROM user_objects
       WHERE object_name = l_package_name;

BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
          g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    if (l_debug = 1) then
       trace(' Entering procedure assign_operation_plan  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
       trace(' p_api_version      => ' || p_api_version
           ||' p_init_msg_list    => ' || p_init_msg_list
           ||' p_commit           => ' || p_commit
           ||' p_validation_level => ' || p_validation_level
           ||' p_task_id          => ' || p_task_id
           ||' p_activity_type_id => ' || p_activity_type_id
           ||' p_organization_id  => ' || p_organization_id, 4);
    end if;

   savepoint assign_operation_plan_sp;
   IF l_debug = 1 THEN
      trace(' Task ID passed to the inner call is ' || p_task_id, 1);
   END IF;
   -- ### Standard call to check for call compatibility
   if not fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   -- ### Initialize message list if p_init_msg_list is set to TRUE
   if p_init_msg_list = 'G_TRUE' then
      fnd_msg_pub.initialize;
   end if;

   --
   -- ### Initialize API return status to success
   x_return_status  := fnd_api.g_ret_sts_success;

   -- ### Validate input parameters and pre-requisites, if validation level
   -- ### requires this
   if p_validation_level <> fnd_api.g_valid_level_none then
      -- in case further needs for validation
      null;
   end if;

   -- ### Code logic branches based on the p_activity_type_id.
   -- ### Inbound  calls 'assign_operation_plan' directly with 'p_activity_type_id = 1'.
   -- ### Outbound continues to call 'assign_operation_plans'(wrapper) with 'p_activity_type_id = null'.
   -- ###
   -- ### open the eligible rules cursor based on activity_type_id
   -- ### 1. Inbound
   -- ### 2. Outbound
   if (l_debug = 1) then
      trace(' Activity Type ID passed in, is ' || nvl(p_activity_type_id, -99), 4);
      trace(' Progress Indicator : ' || l_progress, 4);
   end if;

   l_progress := 1;
   if (p_activity_type_id = 1)                                   -- Inbound.
   then
      if (l_debug = 1) then
          trace(' Within If (p_activity_type_id = 1)..... end;', 1);
          trace(' Progress Indicator : ' || l_progress , 1);
          trace(' Opening Inbound Cursor....'|| 'Progress Indicator : ' || l_progress, 1);
      end if;

      -- ### Opening cursor c_rules_atf_inbound
      open c_rules_atf_inbound;
      l_loop_name := 'c_rules_atf_inbound_loop';

   elsif (p_activity_type_id <> 1 or p_activity_type_id is null)  -- Outbound
   then
      if (l_debug = 1) then
          trace(' Within If (p_activity_type_id <> 1 or p_activity_type_id = null)..... end;', 1);
          trace(' Progress Indicator : ' || l_progress, 4);
          trace(' inv_control.g_current_release_level is ' || inv_control.g_current_release_level );
          trace(' inv_release.g_j_release_level is ' || inv_release.g_j_release_level);
      end if;

      --if inv_control.g_current_release_level >= inv_release.g_j_release_level then
      --   if (l_debug = 1) then
      --      trace(' Release level is J, Opening Outbound patchset-J Cursor....', 1);
      --      trace(' Progress Indicator : ' || l_progress, 4);
      --   end if;

         -- ### Opening cursor c_rules_atf_inbound
         open c_rules_atf_outbound_psetj;
         l_loop_name := 'c_rules_atf_outbound_psetj_loop';
      --end if;
   end if;
   --
   -- ### Enter loop only if one of the cursor(s) is open else return.
   --
   if c_rules_atf_inbound%ISOPEN or c_rules_atf_outbound_psetj%ISOPEN
   then
    l_progress := 2;
    if (l_debug = 1) then
       trace(' Entering loop ' || l_loop_name, 1);
    end if;

    -- ### loop through the rules
    loop
      if c_rules_atf_inbound%ISOPEN then
         if (l_debug = 1) then
            trace(' Fetching Inbound Cursor within the loop'
                ||' Iteration Number '|| l_c_rules_loop, 4);
         end if;

         -- ### Fetching c_rules_atf_inbound cursor
         fetch c_rules_atf_inbound
         into  l_rule_id, l_organization_id, l_wms_task_type, l_operation_plan_id, l_plan_type_id;

      elsif c_rules_atf_outbound_psetj%ISOPEN then
         if (l_debug = 1) then
            trace(' Release level is J, Fetching Outbound patchset-J Cursor....'|| 'Progress Indicator : ' || l_progress, 4);
         end if;

         -- ### Fetching c_rules_atf_outbound_psetj cursor
         fetch c_rules_atf_outbound_psetj
	 into  l_rule_id, l_organization_id, l_wms_task_type, l_operation_plan_id;

      end if;

      if c_rules_atf_inbound%ISOPEN then
         if (l_debug = 1) then
            trace(' c_rules_atf_inbound%NOTFOUND..', 4);
         end if;
         exit when c_rules_atf_inbound%NOTFOUND;
      elsif c_rules_atf_Outbound_psetj%ISOPEN then
         if (l_debug = 1) then
            trace(' c_rules_atf_Outbound_psetj%NOTFOUND..', 4);
         end if;
         exit when c_rules_atf_Outbound_psetj%NOTFOUND;
      end if;

     l_c_rules_loop := l_c_rules_loop + 1;
     if (l_debug = 1) then
        trace('Loop Counter '|| l_c_rules_loop || ' Rule ID returned ' || l_rule_id, 4);
        trace('Loop Counter '|| l_c_rules_loop || ' Organization ID returned ' || l_organization_id, 4);
        trace('Loop Counter '|| l_c_rules_loop || ' Task Type returned ' || l_wms_task_type, 4);
        trace('Loop Counter '|| l_c_rules_loop || ' Operation Plan ID returned ' || l_operation_plan_id, 4);
        trace('Loop Counter '|| l_c_rules_loop || ' Activity Type ID returned ' || p_activity_type_id, 4);
        trace('Loop Counter '|| l_c_rules_loop || ' Plan Type ID returned ' || l_plan_type_id, 4);
     end if;


        -- ### get the pre-generated package name for this rule
        if (l_debug = 1) then
           trace('Before calling procedure getpackagename'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')
                || 'Progress Indicator ' || l_progress, 1);
           trace('   p_rule_id         => ' || l_rule_id, 4);
        end if;

        wms_rule_pvt.getpackagename(l_rule_id, l_package_name);

        if (l_debug = 1) then
           trace('After calling procedure getpackagename'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')
                || 'Progress Indicator ' || l_progress, 1);
           trace('   p_package_name    => ' || l_package_name, 4);
        end if;

        --- ### Execute op Rule
        if (l_debug = 1) then
           trace('Before calling procedure execute_op_rule'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')
                || 'Progress Indicator ' || l_progress, 1);
           trace('   p_rule_id         => ' || l_rule_id
                 ||' p_task_id         => ' || p_task_id, 4);
        end if;

        wms_rule_pvt.execute_op_rule(l_rule_id, p_task_id, l_return_status);

        if (l_debug = 1) then
           trace('After calling procedure execute_op_rule'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')
                || 'Progress Indicator ' || l_progress, 1);
           trace('   x_package_name    => ' || l_return_status, 4);
        end if;


      if l_return_status > 0 then   -- the rule matches the task
         l_found  := TRUE;

         if (l_debug = 1) then
            trace('Within If l_return_status > 0...end if', 4);
            if l_found then
               trace('l_found is TRUE', 4);
            else
               trace('l_found is FALSE', 4);
            end if;
         end if;

         -- ### update mmtt table to assign the operation plan
	 -- ### Update MMTT.
         if (l_debug = 1) then
            trace('Before calling procedure update_mmtt'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')
                 || 'Progress Indicator ' || l_progress, 1);
            trace('  p_task_id    => ' || p_task_id
                 ||' p_operation_plan_id  => ' || l_operation_plan_id, 4);
         end if;

	 -- ### Update MMTT.
	 update_mmtt(
	    p_task_id           =>  p_task_id
	 ,  p_operation_plan_id =>  l_operation_plan_id
	 ,  x_return_status     =>  l_ret_status);

         if (l_debug = 1) then
            trace(' After calling procedure update_mmtt'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')
               || ' Progress Indicator ' || l_progress, 1);
            trace(' x_return_status    => ' || l_ret_status, 4);
         end if;

         if (l_debug = 1) then
            trace('Exiting Loop... ', 1);
         end if;
         exit; -- ### operation plan assigned, jump out of the rule loop

      end if; -- ### l_return_status > 0
   end loop;
   -- ### end loop through the rules
  else
    if c_rules_atf_inbound%ISOPEN then
       close c_rules_atf_inbound;
    elsif c_rules_atf_outbound_psetj%ISOPEN then
       close c_rules_atf_outbound_psetj;
    end if;

    return;
  end if;

   if (l_debug = 1) then
      trace('Out of the ' || l_loop_name || ' Loop: Closing all open cursors, if any', 4);
   end if;

   if c_rules_atf_inbound%ISOPEN then
      close c_rules_atf_inbound;
   elsif c_rules_atf_outbound_psetj%ISOPEN then
      close c_rules_atf_outbound_psetj;
   end if;

   l_progress := 3;
    -- get default operation plan if none of the rule criteria matches...
   if not l_found then
      if (l_debug = 1) then
          trace('Within If not l_found...end if', 1);
      end if;

      if p_activity_type_id = 1                              -- Inbound, new patchset 'J' code
      then
           if (l_debug = 1) then
              trace('Within If p_activity_type_id = 1...End if.....'
                    || '      Opening cursor c_default_op_plan_inbound', 4);
           end if;

           open  c_default_op_plan_inbound;
           fetch c_default_op_plan_inbound
           into  l_plan_type_id, l_operation_plan_id ; -- g_default_operation_plan_id;

           if (l_debug = 1) then
              trace('Fetching cursor c_default_op_plan_inbound', 1);
              trace('Default Operation Plan id for Activity type = '|| p_activity_type_id
                    || ', Plan Type = ' || l_plan_type_id
                    || '  '|| l_operation_plan_id, 4);
           end if;

           If c_default_op_plan_inbound%NOTFOUND then
              if (l_debug = 1) then
                 trace('*** c_default_op_plan_inbound%NOTFOUND ***', 4);
                 trace(' Inbound Setup Issue,... default not defined for activity_type_id/plan_type_id combination', 4);
              end if;
              l_operation_plan_id  := null;
              close c_default_op_plan_inbound;
              l_operation_plan_id  := null;
              return;
           else
 	      -- ### l_operation_plan_id  := g_default_operation_plan_id;
  	      close  c_default_op_plan_inbound;
           end if;

      elsif (p_activity_type_id <> 1 or p_activity_type_id is null )
      then
           if (l_debug = 1) then
              trace('Within If (p_activity_type_id <> 1 or p_activity_type_id = null )...End if.....'
                     || '      Opening cursor c_default_operation_plan', 4);
           end if;

           open  c_default_op_plan_outbound;
           fetch c_default_op_plan_outbound
           into  l_operation_plan_id; -- @@@ g_default_operation_plan_id;

           if (l_debug = 1) then
              trace('Fetching cursor c_default_op_plan_outbound', 1);
              trace('Default Operation Plan id for Activity type = '|| p_activity_type_id
                    || ', Plan Type = ' || l_plan_type_id
                    || '  '|| l_operation_plan_id, 4);
           end if;

           if c_default_op_plan_outbound%NOTFOUND then
              if (l_debug = 1) then
                 trace('*** c_get_default_op_plan_Outbound%NOTFOUND ***', 4);
                 trace(' Outbound Setup Issue,... default not defined for activity_type_id/plan_type_id combination', 4);
              end if;
              l_operation_plan_id  := null;
           end if;

           -- @@@ l_operation_plan_id  := g_default_operation_plan_id;
           close c_default_op_plan_outbound;
      end if;

  -- ### Checking to make sure that a valid Operation Plan ID is returned.
  if l_operation_plan_id is not null then
     -- ### Update MMTT.
     update_mmtt(
        p_task_id           =>  p_task_id
     ,  p_operation_plan_id =>  l_operation_plan_id
     ,  x_return_status     =>  l_ret_status
     );
  else
     IF l_debug = 1 THEN
        trace('*** Default Operation Plan ID derived is null and hence cannot update MMTT....***');
     END IF;
  end if;

  end if;

  if c_default_op_plan_inbound%ISOPEN then
     close c_default_op_plan_inbound;
  elsif c_default_op_plan_outbound%ISOPEN then
     close c_default_op_plan_outbound;
  end if;

  -- ### Standard check of p_commit
  --if p_commit in ('TRUE','T') then
  --   commit work;
  --    trace(' Exiting procedure assign_operation_plans  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
  --    trace(  '   p_api_version      => ' || p_api_version
  --            ||'   p_init_msg_list    => ' || p_init_msg_list
  --            ||'   p_init_msg_list    => ' || p_init_msg_list
  --            ||'   p_commit           => ' || p_commit
  --            ||'   p_validation_level => ' || p_validation_level
  --            ||'   p_task_id          => ' || p_task_id
  --            ||'   p_organization_id  => ' || p_organization_id, 4);

  --   return;
  --else
  --   rollback;
    IF l_debug = 1 THEN
     trace(' Exiting procedure assign_operation_plans  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
     trace(  '   p_api_version      => ' || p_api_version
           ||'   p_init_msg_list    => ' || p_init_msg_list
           ||'   p_init_msg_list    => ' || p_init_msg_list
           ||'   p_commit           => ' || p_commit
           ||'   p_validation_level => ' || p_validation_level
           ||'   p_task_id          => ' || p_task_id
           ||'   p_organization_id  => ' || p_organization_id, 4);

 --      return;
   end if;

EXCEPTION
    when fnd_api.g_exc_error then

      rollback to assign_operation_plan_sp;
      -- @@@ wms_rule_pvt.freeglobals;
      x_return_status  := fnd_api.g_ret_sts_error;

      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    when others then
       if c_rules_atf_inbound%ISOPEN then
          close c_rules_atf_inbound;
       elsif c_rules_atf_outbound_psetj%ISOPEN then
          close c_rules_atf_outbound_psetj;
       end if;

       if c_default_op_plan_inbound%ISOPEN then
          close c_default_op_plan_inbound;
       elsif c_default_op_plan_outbound%ISOPEN then
          close c_default_op_plan_outbound;
       end if;


      rollback to assign_operation_plan_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      if (l_debug =1) then
         trace(' Error Message(Error Code)....' || sqlerrm(sqlcode), 1);
      end if;

END assign_operation_plan_psetj;
--
--
end wms_rule_pvt_ext_psetj;

/
