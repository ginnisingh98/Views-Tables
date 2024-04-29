--------------------------------------------------------
--  DDL for Package Body WMS_ATF_DESTINATION_LPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_DESTINATION_LPN" as
 /* $Header: WMSADLPB.pls 115.25 2004/03/25 00:44:25 joabraha noship $ */
--
l_debug      number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
--
-- ------------------------------------------------------------------------------------
-- |---------------------< trace >-----------------------------------------------------|
-- ------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name        Reqd Type     Description
--   ----------  ---- -------- ---------------------------------------
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
Procedure trace(
   p_message  in varchar2
,  p_level    in number
) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_ATF_DESTINATION_LPN :', p_level);
end trace;
--
-- ---------------------------------------------------------------------------------------
-- |---------------------< exit_proc_msg >--------------------------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
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

Procedure exit_proc_msg(
   x_return_status        in  varchar2
,  x_msg_count            in  number
,  x_msg_data             in  varchar2
,  x_lpn_id               in  number
,  x_lpn_valid            in  varchar2
,  l_proc                 in  varchar2
) is
begin
    if (l_debug = 1) then
       trace(' Exiting Procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
       trace(l_proc || ' x_return_status      => ' || x_return_status);
       trace(l_proc || ' x_msg_count => ' || x_msg_count);
       trace(l_proc || ' x_msg_data => ' || x_msg_data);
       trace(l_proc || ' x_lpn_id => ' || x_lpn_id);
       trace(l_proc || ' x_lpn_valid => ' || x_lpn_valid);
    end if;
end exit_proc_msg;
--
-- ------------------------------------------------------------------------------------
-- |----------------------------< get_seed_dest_lpn >----------------------------------|
-- ------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns locator based on the specific conditions.
--
--   Package-Procedure combination
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
---  --------------------------     ---- --------  ----------------------------------
--   p_mode                         Yes  varchar2  Valid Modes are Insert and Delete.
--   p_task_id                      Yes  varchar2  MMTT.transaction_temp_id
--   p_activity_type_id             No   varchar2  1. Inbound   2. Outbound
--   p_lpn_id                       No             LPN passed in for validation purposes.
--   p_item_id                      No             Item ID passed in to use as added restriction.
--
-- Post Success:
--
--
-- Post Failure:
--   Details of the error are added to the AOL message stack. When this
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure get_seed_dest_lpn (
   x_return_status        out nocopy varchar2
,  x_msg_count            out nocopy number
,  x_msg_data             out nocopy varchar2
,  x_lpn_id               out nocopy number
,  x_lpn_valid            out nocopy varchar2
,  p_mode                 in  number
,  p_task_id              in  number
,  p_activity_type_id     in  number
,  p_lpn_id               in  number
,  p_item_id              in  number
,  p_subinventory_code    in  varchar2
,  p_locator_id           in  number
,  p_api_version          in  number
,  p_init_msg_list        in  varchar2
,  p_commit               in  varchar2
) is

       l_proc                    varchar2(72) := 'GET_SEED_DEST_LPN :';
       l_prog                    float;
       l_loop_num                number := 0;

       l_operation_plan_id	 number;
       l_operation_plan_dtl_id   number;
       l_plan_type_id		 number;
       l_activity_type_id        number;
       l_pre_specified_zone_id	 number;
       l_pre_specified_sub_code	 varchar2(100);
       l_lpn_mtrl_grp_rule_id	 number;
       l_operation_type		 number;

       l_lpn_id		         number;
       l_subinventory_code	 varchar2(100);
       l_locator_id		 number;

       l_is_in_inventory	 varchar2(1);
       l_inventory_location_id   number;
       l_subinventory_type       varchar2(100);

       l_orig_dest_sub_code      varchar2(100);
       l_orig_dest_loc_id        number;

       l_organization_id         number;
       l_zone_id                 number;

       --p_init_msg_list           varchar2(50):= 'TRUE';
       l_cursor                  varchar2(50):= null;
       l_cur_found               boolean := false;

cursor c_oper_plan_details is
select mmtt.operation_plan_id,
       nvl(mmtt.transfer_to_location, mmtt.locator_id),
       nvl(mmtt.transfer_subinventory, mmtt.subinventory_code),
       wopd.operation_plan_detail_id,
       wopi.activity_type_id,
       wopi.plan_type_id,
       wopi.orig_dest_sub_code,
       wopi.orig_dest_loc_id,
       wopd.pre_specified_zone_id,
       wopd.pre_specified_sub_code,
       wopd.lpn_mtrl_grp_rule_id,
       wopd.operation_type,
       nvl(wopd.is_in_inventory, 'N'),
       mmtt.organization_id
from   wms_op_plan_instances wopi,     -- after review on 07/30/03, replaced wms_op_plans_b table with wms_op_plan_instances.
       wms_op_plan_details wopd,
       -- wms_zones_b wzb,             -- Removed after Code Review on Sept 11th 2003.
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi                                -- Added after review on 07/30/03
where  mmtt.organization_id = wopi.organization_id
--     @@@ Commented after Code Review on Sept 11th 2003.
--     and    wzb.zone_id(+) = wopd.pre_specified_zone_id
and    wopd.operation_plan_detail_id = wooi.operation_plan_detail_id  -- Added after review on 07/30/03
--     @@@ Commented after Code Review on Sept 16th 2003.
--     and    wopd.operation_plan_id = wopi.operation_plan_id
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wopi.operation_plan_id = mmtt.operation_plan_id
and    wooi.source_task_id = mmtt.transaction_temp_id                 -- Added after review on 07/30/03
and    mmtt.transaction_temp_id = p_task_id                           -- 6583491 (dmfdv11i)
--
--     @@@ Commented after for bug fix on Sept 16th 2003. One task is tied to a combination of a Load and a Drop. This means
--     @@@ when you query the wooi with the restriction " wooi.source_task_id = mmtt.transaction_temp_id ", it'll bring back
--     @@@ 2 records, 1 each for a load and drop. We are only interested in the Drop. This is all the more important becase
--     @@@ athis API will abort if the Material Grouping Rule ID stamped on the detail line is null. There will exist no
--     @@@ Material Grouping Rule ID for the Load Operation Plan Detail line. We also know that the operation sequence for the
--     @@@ Drop Line is always greater than the Load line and hence the " order by wooi.operation_sequence desc" will bring
--     @@@ back the Drop line first and then the Load line. In any case we only consider the first recoerd and in this case now
--     @@@ it turns out to be the Drop line.
--     order by wopd.operation_type;
order by wooi.operation_sequence desc;
--
--
--
cursor c_lpn_active_wzone_witem is
select wlpn.outermost_lpn_id
from   wms_license_plate_numbers wlpn,
       mtl_material_transactions_temp mmtt,
       wms_zone_locators  wzl,
       wms_op_plan_instances wopi,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2
where  wlpn.lpn_context = decode(l_is_in_inventory, 'Y', 1, 3)
and    wlpn.organization_id = l_organization_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.lpn_id = mmtt.lpn_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooi.from_subinventory_code
and    wzl.subinventory_code = p_subinventory_code -- new
and    wzl.organization_id = l_organization_id -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooi.from_locator_id)
--     *****from the inner cursor****
and    wopi.status = 6
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed     -- Typo corrected, earlier it was wooi.operation_status = 3
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.from_subinventory_code = p_subinventory_code -- new
and    wooi.from_locator_id = p_locator_id -- new
and    wooi.organization_id = l_organization_id -- new
and    wooi.source_task_id = mmtt.transaction_temp_id -- new
and    mmtt.inventory_item_id = p_item_id -- new
and    mmtt.organization_id = l_organization_id -- new
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    wopi.activity_type_id = l_activity_type_id -- 1       (Inbound)
and    wopi.organization_id = l_organization_id -- new
and    wopi.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by wooi.last_update_date desc;
--
--
cursor c_lpn_active_wzone_woitem is
select wlpn.outermost_lpn_id
from   mtl_material_transactions_temp mmtt,
       wms_license_plate_numbers wlpn,
       wms_zone_locators  wzl,
       wms_op_plan_instances wopi,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2
where  wlpn.lpn_context = decode(l_is_in_inventory, 'Y', 1, 3)
and    wlpn.organization_id = l_organization_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.lpn_id = mmtt.lpn_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooi.from_subinventory_code
and    wzl.subinventory_code = p_subinventory_code -- new
and    wzl.organization_id = l_organization_id -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooi.from_locator_id)
--     *****from the inner cursor****
and    wopi.status = 6
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed     -- Typo corrected, earlier it was wooi.operation_status = 3
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.from_subinventory_code = p_subinventory_code -- new
and    wooi.from_locator_id = p_locator_id -- new
and    wooi.organization_id = l_organization_id -- new
and    wooi.source_task_id = mmtt.transaction_temp_id -- new
and    mmtt.organization_id = l_organization_id -- new
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    wopi.activity_type_id = l_activity_type_id -- 1
and    wopi.organization_id = l_organization_id -- new
and    wopi.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by mmtt.last_update_date desc;
--
--
cursor c_lpn_active_wozone_witem is
select wlpn.outermost_lpn_id
from   mtl_material_transactions_temp mmtt,
       wms_license_plate_numbers wlpn,
       wms_op_plan_instances wopi,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2
where  wlpn.lpn_context = decode(l_is_in_inventory, 'Y', 1, 3)
and    wlpn.organization_id = l_organization_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.lpn_id = mmtt.lpn_id
and    wopi.status = 6
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    nvl(wooi.is_in_inventory, 'N') =  l_is_in_inventory -- new
and    wooi.from_subinventory_code = p_subinventory_code -- new
and    wooi.from_locator_id = p_locator_id -- new
and    wooi.organization_id = l_organization_id -- new
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.inventory_item_id = p_item_id
and    mmtt.organization_id = l_organization_id -- new
and    wopi.activity_type_id = l_activity_type_id
and    wopi.organization_id = l_organization_id  -- new
and    wopi.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by wooi.last_update_date desc;
--
--
--
cursor c_lpn_active_wozone_woitem is
select wlpn.outermost_lpn_id
from   mtl_material_transactions_temp mmtt,
       wms_license_plate_numbers wlpn,
       wms_op_plan_instances wopi,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2
where  wlpn.lpn_context = decode(l_is_in_inventory, 'Y', 1, 3)
and    wlpn.organization_id = l_organization_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.lpn_id = mmtt.lpn_id
and    wopi.status = 6
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.organization_id = l_organization_id  -- new
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = l_organization_id  -- new
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    nvl(wooi.is_in_inventory, 'N') =  l_is_in_inventory -- new
and    wooi.from_subinventory_code = p_subinventory_code -- new
and    wooi.from_locator_id = p_locator_id -- new
and    wopi.activity_type_id = l_activity_type_id
and    wopi.organization_id = l_organization_id  -- new
and    wopi.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by mmtt.last_update_date desc;
--
--
--
cursor c_lpn_comp_wzone_witem is
select wlpn.outermost_lpn_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       wms_zone_locators  wzl,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn
where  wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = p_subinventory_code -- new
and    wzl.organization_id = l_organization_id -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wlpn.locator_id)
and    wlpn.subinventory_code = wdth.dest_subinventory_code
and    wlpn.locator_id = wdth.dest_locator_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.dest_locator_id = p_locator_id
and    wdth.dest_subinventory_code = p_subinventory_code
and    wdth.organization_id = l_organization_id -- new
and    wdth.inventory_item_id = p_item_id
and    wdth.status = 6         -- Completed task. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = p_subinventory_code -- new
and    wooih.to_locator_id = p_locator_id -- new
and    wopih.status = 3   -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id -- new
and    wopih.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
and    wopih.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wlpn.last_update_date desc;
--
--
cursor c_lpn_comp_wzone_woitem is
select wlpn.outermost_lpn_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       wms_zone_locators  wzl,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn
where  wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = p_subinventory_code -- new
and    wzl.organization_id = l_organization_id -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wlpn.locator_id)
and    wlpn.subinventory_code = wdth.dest_subinventory_code
and    wlpn.locator_id = wdth.dest_locator_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.dest_locator_id = p_locator_id
and    wdth.dest_subinventory_code = p_subinventory_code
and    wdth.organization_id = l_organization_id -- new
and    wdth.status = 6         -- Completed task. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = p_subinventory_code -- new
and    wooih.to_locator_id = p_locator_id -- new
and    wopih.status = 3   -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id -- new
and    wopih.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
and    wopih.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wlpn.last_update_date desc;
--
--
cursor c_lpn_comp_wozone_witem is
select wlpn.outermost_lpn_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn
where  wlpn.subinventory_code = wdth.dest_subinventory_code
and    wlpn.locator_id = wdth.dest_locator_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.dest_locator_id = p_locator_id
and    wdth.dest_subinventory_code = p_subinventory_code
and    wdth.inventory_item_id = p_item_id -- new
and    wdth.organization_id = l_organization_id -- new
and    wdth.status = 6   -- Completed task. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = p_subinventory_code -- new
and    wooih.to_locator_id = p_locator_id -- new
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = p_subinventory_code -- new
and    wooih.to_locator_id = p_locator_id -- new
and    wopih.status = 3   -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id -- new
and    wopih.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
and    wopih.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wlpn.last_update_date desc;
--
--
cursor c_lpn_comp_wozone_woitem is
select wlpn.outermost_lpn_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn
where  wlpn.subinventory_code = wdth.dest_subinventory_code
and    wlpn.locator_id = wdth.dest_locator_id
and    wlpn.subinventory_code = p_subinventory_code -- new
and    wlpn.locator_id = p_locator_id -- new
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.dest_locator_id = p_locator_id
and    wdth.dest_subinventory_code = p_subinventory_code
--and    wdth.inventory_item_id = p_item_id -- new
and    wdth.organization_id = l_organization_id -- new
and    wdth.status = 6   -- Completed task. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = p_subinventory_code -- new
and    wooih.to_locator_id = p_locator_id -- new
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = p_subinventory_code -- new
and    wooih.to_locator_id = p_locator_id -- new
and    wopih.status = 3   -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id -- new
and    wopih.plan_type_id = decode(l_lpn_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
and    wopih.orig_dest_sub_code = decode(l_lpn_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_lpn_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wlpn.last_update_date desc;
--
--     ### End of Cursor and Variable Declaration section
--
begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ### Initialize message stack since p_init_msg_list is set to TRUE
   -- ### The p_init_msg_list is set to 'TRUE' in this code and so the message stack will always be initialised.
   -- if fnd_api.to_boolean(p_init_msg_list) then
   --    fnd_msg_pub.initialize;
   -- end if;

   l_prog := 10;
   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc || ' p_mode      => ' || p_mode);
      trace(l_proc || ' p_task_id    => ' || p_task_id);
      trace(l_proc || ' p_activity_type_id    => ' || p_activity_type_id);
      trace(l_proc || ' p_lpn_id           => ' || p_lpn_id);
      trace(l_proc || ' p_item_id => ' || p_item_id);
   end if;

   if (l_debug = 1) then
      trace(l_proc || ' Opening/Fetching Cursor "c_oper_plan_details"...', 1);
   end if;
   -- ### Derive Operation Plan details to start with.
   open  c_oper_plan_details;
   fetch c_oper_plan_details
   into  l_operation_plan_id, l_locator_id, l_subinventory_code, l_operation_plan_dtl_id,
         l_activity_type_id, l_plan_type_id, l_orig_dest_sub_code, l_orig_dest_loc_id,
         l_pre_specified_zone_id, l_pre_specified_sub_code, l_lpn_mtrl_grp_rule_id,
         l_operation_type, l_is_in_inventory, l_organization_id;

   if c_oper_plan_details%NOTFOUND
   then
      fnd_message.set_name('WMS', 'WMS_OPERTN_PLAN_ID_INVALID');
      fnd_msg_pub.ADD;
      raise fnd_api.g_exc_error;                 -- Added after Code Review on Sept 11th 2003.
   else
      -- ### Print values detived from teh cursor in nthe log file.
      if (l_debug = 1) then
         trace(l_proc || ' Printing Operation Plan Detail Information...');
         trace(l_proc || ' l_operation_plan_id : '|| l_operation_plan_id);
         trace(l_proc || ' l_locator_id : '|| l_locator_id);
         trace(l_proc || ' l_subinventory_code : '|| l_subinventory_code);
         trace(l_proc || ' l_operation_plan_detail_id : '|| l_operation_plan_dtl_id);
         trace(l_proc || ' l_activity_type_id : '|| l_activity_type_id);
         trace(l_proc || ' l_plan_type_id : '|| l_plan_type_id);
         trace(l_proc || ' l_orig_dest_sub_code : '|| l_orig_dest_sub_code);
         trace(l_proc || ' l_orig_dest_loc_id : '|| l_orig_dest_loc_id);
         trace(l_proc || ' l_pre_specified_zone_id : '|| l_pre_specified_zone_id);
         trace(l_proc || ' l_pre_specified_sub_code : '|| l_pre_specified_sub_code);
         trace(l_proc || ' l_lpn_mtrl_grp_rule_id : '|| l_lpn_mtrl_grp_rule_id);
         trace(l_proc || ' l_operation_type : '|| l_operation_type);
         trace(l_proc || ' l_is_in_inventory : '|| l_is_in_inventory);
         trace(l_proc || ' l_organization_id : '|| l_organization_id);
      end if;
      -- ### Close the above cursor.
      close c_oper_plan_details;
      l_prog := 11;
      -- ### Check to see if a valid Material Grouping Rule is stamped on the oeration plan detail.
      -- ### The LOV on the Form field allows to select a valid Rule only. Hence the possible cases
      -- ### are that either there is a value which is valid or a null value. Hence check only for null.
      if l_lpn_mtrl_grp_rule_id is null then
         fnd_message.set_name('WMS', 'WMS_MTRL_GRP_RULE_ID_IS_NULL');
         fnd_msg_pub.ADD;
         raise fnd_api.g_exc_error;              -- Added after Code Review on Sept 11th 2003.
      end if;
   end if;

   l_prog := 20;
   --
   if (l_debug = 1) then
      trace(l_proc || ' Now that a Material Grouping Rule "' || l_lpn_mtrl_grp_rule_id || '" is stamped on the Operation Plan Detail Line....', 1);
      trace(l_proc || ' Proceeding further into the code logic.....');
   end if;
   -- @@@ As per the new design as of Sept 16th 2003, the code logic will fork based on if the variable
   -- @@@ " l_pre_specified_zone_id" is populated from the fetch of the Operation Plan Detail cursor.
   -- @@@ Now the same cursor is opened irrespective of the Material Grouping Rule stamped on the Operation
   -- @@@ Plan Detail Line.

   -- ### Prespecified Zone is not null. For th LPN Suggestion logic, the Subinventory and Locator derived by calling
   -- ### the Locator Suggection API is passed in irrespective. Hence pre-specified Subinventory and Locator is always
   -- ### available for the LPN Suggestion Cursors as a restiriction, unlike the Locator Sugegstion API Cusrors.
   if l_pre_specified_zone_id is not null
   then
      -- ### Setting Cursor Name.
      if (l_debug =1 ) then
         trace(l_proc || ' Within "l_pre_specified_zone_id is not null" segment....', 1);
         trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
      end if;

      -- @@@ Zone and Item Specified
      if p_item_id is not null
      then
         l_cursor := 'c_lpn_active_wzone_witem';
         -- ### Open Cursor c_lpn_active_wzone_witem to look within "active operation" plans.
         open  c_lpn_active_wzone_witem;
         fetch c_lpn_active_wzone_witem
         into  l_lpn_id;

         if c_lpn_active_wzone_witem%NOTFOUND then
            if (l_debug =1 ) then
               trace(l_proc || ' "c_lpn_active_wzone_witem" failed with %NOTFOUND...', 1);
	       trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from Active tables...');
               trace(l_proc || ' Commencing search in History tables with Task ID '|| p_task_id, 1);
               trace(l_proc || ' Setting OUT variables to null...', 1);
               trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
            end if;
            x_lpn_id := null;
	    close c_lpn_active_wzone_witem;
	    l_cursor := null;

    	    -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
    	    -- ### Opening cursor c_lpn_active_without_zone to look for completed operations.
    	    -- ### Setting Cursor Name
            l_cursor := 'c_lpn_comp_wzone_witem';
            if (l_debug =1 ) then
               trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
            end if;

            l_cursor := 'c_lpn_comp_wzone_witem';
    	    -- ### Open Cursor c_lpn_comp_wzone_witem to look within "completed operation" plans.
    	    open  c_lpn_comp_wzone_witem;
    	    fetch c_lpn_comp_wzone_witem
    	    into  l_lpn_id;

   	       if c_lpn_comp_wzone_witem%NOTFOUND then
   	 	  if (l_debug = 1) then
   		     trace(l_proc || ' "c_lpn_comp_wzone_witem" failed with %NOTFOUND...', 1);
   		     trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from History tables...');
   		     trace(l_proc || ' Technical end of API Execution...');
   		     trace(l_proc || ' Setting OUT variables to null...', 1);
        	     trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		  end if;
                  x_lpn_id := null;
	          close c_lpn_comp_wzone_witem;
	          l_cursor := null;
	       elsif c_lpn_comp_wzone_witem%FOUND then
                 -- c_lpn_comp_wzone_witem Cursor found..
                  if (l_debug = 1) then
                     trace(l_proc || ' "c_lpn_comp_wzone_witem" FOUND...', 1);
                     trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
                  end if;
                  close c_lpn_comp_wzone_witem;
                  l_cur_found := true;
               end if;-- @@@ Marker: c_lpn_comp_wzone_witem FOUND/NOTFOUND
	 elsif c_lpn_active_wzone_witem%FOUND then
             -- c_lpn_active_wzone_witem Cursor found..
             if (l_debug = 1) then
                 trace(l_proc || ' "c_lpn_active_wzone_witem" FOUND...', 1);
                 trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
             end if;
             close c_lpn_active_wzone_witem;
             l_cur_found := true;
         end if;-- @@@ Marker: c_lpn_active_wzone_witem FOUND/NOTFOUND
      -- @@@ Zone Specified but Item Not Specified
      elsif p_item_id is  null
      then
         l_cursor := 'c_lpn_active_wzone_woitem';
          -- ### Open Cursor c_lpn_active_wzone_woitem to look within "active operation" plans.
         open  c_lpn_active_wzone_woitem;
         fetch c_lpn_active_wzone_woitem
         into  l_lpn_id;

         if c_lpn_active_wzone_woitem%NOTFOUND then
            if (l_debug =1 ) then
               trace(l_proc || ' "c_lpn_active_wzone_woitem" failed with %NOTFOUND...', 1);
	       trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from Active tables...');
               trace(l_proc || ' Commencing search in History tables with Task ID '|| p_task_id, 1);
               trace(l_proc || ' Setting OUT variables to null...', 1);
               trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
            end if;
            x_lpn_id := null;
	    close c_lpn_active_wzone_woitem;
	    l_cursor := null;

    	    -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
    	    -- ### Opening cursor c_lpn_active_without_zone to look for completed operations.
    	    -- ### Setting Cursor Name
            l_cursor := 'c_lpn_comp_wzone_woitem';
            if (l_debug =1 ) then
               trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
            end if;

            l_cursor := 'c_lpn_comp_wzone_woitem';
    	    -- ### Open Cursor c_lpn_comp_wzone_woitem to look within "completed operation" plans.
    	    open  c_lpn_comp_wzone_woitem;
    	    fetch c_lpn_comp_wzone_woitem
    	    into  l_lpn_id;

   	       if c_lpn_comp_wzone_woitem%NOTFOUND then
   	 	  if (l_debug = 1) then
   		     trace(l_proc || ' "c_lpn_comp_wzone_woitem" failed with %NOTFOUND...', 1);
   		     trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from History tables...');
   		     trace(l_proc || ' Technical end of API Execution...');
   		     trace(l_proc || ' Setting OUT variables to null...', 1);
        	     trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		  end if;
                  x_lpn_id := null;
	          close c_lpn_comp_wzone_woitem;
	          l_cursor := null;
	       elsif c_lpn_comp_wzone_woitem%FOUND then
                 -- c_lpn_comp_wzone_witem Cursor found..
                  if (l_debug = 1) then
                     trace(l_proc || ' "c_lpn_comp_wzone_woitem" FOUND...', 1);
                     trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
                  end if;
                  close c_lpn_comp_wzone_woitem;
                  l_cur_found := true;
               end if;-- @@@ Marker: c_lpn_comp_wzone_woitem FOUND/NOTFOUND
	 elsif c_lpn_active_wzone_woitem%FOUND then
             -- c_lpn_active_wzone_woitem Cursor found..
             if (l_debug = 1) then
                 trace(l_proc || ' "c_lpn_active_wzone_woitem" FOUND...', 1);
                 trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
             end if;
             close c_lpn_active_wzone_woitem;
             l_cur_found := true;
         end if;-- @@@ Marker: c_lpn_active_wzone_woitem FOUND/NOTFOUND
      end if;-- @@@ Marker: Check for p_item_id
   -- ### Prespecified Zone is null..
   elsif l_pre_specified_zone_id is null
   then
      -- ### Setting Cursor Name.
      if (l_debug =1 ) then
         trace(l_proc || ' Within "l_pre_specified_zone_id is  null" segment....', 1);
         trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
      end if;

      -- @@@ Zone Not Specified but Item Specified
      if p_item_id is not null
      then
         l_cursor := 'c_lpn_active_wozone_witem';
         -- ### Open Cursor c_lpn_active_wzone_witem to look within "active operation" plans.
         open  c_lpn_active_wozone_witem;
         fetch c_lpn_active_wozone_witem
         into  l_lpn_id;

         if c_lpn_active_wozone_witem%NOTFOUND then
            if (l_debug =1 ) then
               trace(l_proc || ' "c_lpn_active_wozone_witem" failed with %NOTFOUND...', 1);
	       trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from Active tables...');
               trace(l_proc || ' Commencing search in History tables with Task ID '|| p_task_id, 1);
               trace(l_proc || ' Setting OUT variables to null...', 1);
               trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
            end if;
            x_lpn_id := null;
	    close c_lpn_active_wozone_witem;
	    l_cursor := null;

    	    -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
    	    -- ### Opening cursor c_lpn_active_without_zone to look for completed operations.
    	    -- ### Setting Cursor Name
            if (l_debug =1 ) then
               trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
            end if;

            l_cursor := 'c_lpn_comp_wozone_witem';
    	    -- ### Open Cursor c_lpn_comp_wzone_witem to look within "completed operation" plans.
    	    open  c_lpn_comp_wozone_witem;
    	    fetch c_lpn_comp_wozone_witem
    	    into  l_lpn_id;

   	       if c_lpn_comp_wozone_witem%NOTFOUND then
   	 	  if (l_debug = 1) then
   		     trace(l_proc || ' "c_lpn_comp_wozone_witem" failed with %NOTFOUND...', 1);
   		     trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from History tables...');
   		     trace(l_proc || ' Technical end of API Execution...');
   		     trace(l_proc || ' Setting OUT variables to null...', 1);
        	     trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		  end if;
                  x_lpn_id := null;
	          close c_lpn_comp_wozone_witem;
	          l_cursor := null;
	       elsif c_lpn_comp_wozone_witem%FOUND then
                 -- c_lpn_comp_wzone_witem Cursor found..
                  if (l_debug = 1) then
                     trace(l_proc || ' "c_lpn_comp_wozone_witem" FOUND...', 1);
                     trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
                  end if;
                  close c_lpn_comp_wozone_witem;
                  l_cur_found := true;
               end if;-- @@@ Marker: c_lpn_comp_wozone_witem FOUND/NOTFOUND
         elsif c_lpn_active_wozone_witem%FOUND then
             -- c_lpn_active_wozone_witem Cursor found..
             if (l_debug = 1) then
                 trace(l_proc || ' "c_lpn_active_wozone_witem" FOUND...', 1);
                 trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
             end if;
             close c_lpn_active_wozone_witem;
             l_cur_found := true;
         end if;-- @@@ Marker: c_lpn_active_wozone_witem FOUND/NOTFOUND
      -- @@@ Zone Not Specified and Item Not Specified
      elsif p_item_id is  null
      then
         l_cursor := 'c_lpn_active_wozone_woitem';
         -- ### Open Cursor c_lpn_active_wozone_woitem to look within "active operation" plans.
         open  c_lpn_active_wozone_woitem;
         fetch c_lpn_active_wozone_woitem
         into  l_lpn_id;

         if c_lpn_active_wozone_woitem%NOTFOUND then
            if (l_debug =1 ) then
               trace(l_proc || ' "c_lpn_active_wozone_woitem" failed with %NOTFOUND...', 1);
	       trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from Active tables...');
               trace(l_proc || ' Commencing search in History tables with Task ID '|| p_task_id, 1);
               trace(l_proc || ' Setting OUT variables to null...', 1);
               trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
            end if;
            x_lpn_id := null;
	    close c_lpn_active_wozone_woitem;
	    l_cursor := null;

    	    -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
    	    -- ### Opening cursor c_lpn_active_without_zone to look for completed operations.
    	    -- ### Setting Cursor Name
            l_cursor := 'c_lpn_comp_wzone_woitem';
            if (l_debug =1 ) then
               trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
            end if;

            l_cursor := 'c_lpn_comp_wozone_woitem';
    	    -- ### Open Cursor c_lpn_comp_wozone_woitem to look within "completed operation" plans.
    	    open  c_lpn_comp_wozone_woitem;
    	    fetch c_lpn_comp_wozone_woitem
    	    into  l_lpn_id;

   	       if c_lpn_comp_wozone_woitem%NOTFOUND then
   	 	  if (l_debug = 1) then
   		     trace(l_proc || ' "c_lpn_comp_wozone_woitem" failed with %NOTFOUND...', 1);
   		     trace(l_proc || ' Task ID "'|| p_task_id|| '" could not derive records from History tables...');
   		     trace(l_proc || ' Technical end of API Execution...');
   		     trace(l_proc || ' Setting OUT variables to null...', 1);
        	     trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		  end if;
                  x_lpn_id := null;
	          close c_lpn_comp_wozone_woitem;
	          l_cursor := null;
	       elsif c_lpn_comp_wozone_woitem%FOUND then
                 -- c_lpn_comp_wozone_woitem Cursor found..
                  if (l_debug = 1) then
                     trace(l_proc || ' "c_lpn_comp_wozone_woitem" FOUND...', 1);
                     trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
                  end if;
                  close c_lpn_comp_wozone_woitem;
                  l_cur_found := true;
               end if;-- @@@ Marker: c_lpn_comp_wozone_woitem FOUND/NOTFOUND
         elsif c_lpn_active_wozone_woitem%FOUND then
             -- c_lpn_active_wozone_woitem Cursor found..
             if (l_debug = 1) then
                 trace(l_proc || ' "c_lpn_active_wozone_woitem" FOUND...', 1);
                 trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
             end if;
             close c_lpn_active_wozone_woitem;
             l_cur_found := true;
         end if;-- @@@ Marker: c_lpn_active_wozone_woitem FOUND/NOTFOUND
      end if;-- @@@ Marker: Check for p_item_id
   end if;-- @@@ Marker: Check for l_pre_specified_zone_id
   -- ### Common code to set out values if either the "active" or "complete" "with Zone cursor is FOUND.
   -- ### This is achieved by setting the value of the boolean "l_cur_found" appropriately.
   if l_cur_found
   then
      if (l_debug =1 ) then
         trace(l_proc || 'Within "if l_cur_found " is entered...', 1);
         trace(l_proc || '"' || l_cursor || '" FOUND...', 1);
         trace(l_proc || ' LPN ID returned by cursor "' || l_cursor || '" => ' || l_lpn_id, 4);
      end if;
      x_lpn_id := l_lpn_id;
      --
      --### Call trace message before exiting...
      --
      exit_proc_msg(
         x_return_status  => x_return_status
      ,  x_msg_count =>  x_msg_count
      ,  x_msg_data  => x_msg_data
      ,  x_lpn_id  =>  x_lpn_id
      ,  x_lpn_valid  =>   x_lpn_valid
      ,  l_proc  =>  l_proc
      );
      l_cursor := null;
      return;
   end if;


exception
   when fnd_api.g_exc_error then
      x_return_status  := fnd_api.g_ret_sts_error;

      if (l_debug = 1) then
         trace(' Progress at the time of failure is ' || l_prog, 1);
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;

      if (l_prog = 10) then
         if (l_debug = 1) then
            trace(l_proc || ' "c_oper_plan_details" failed with %NOTFOUND...', 1);
            trace(l_proc || ' Task ID '|| p_task_id|| ' is invalid. Please pass a Valid Task.');
         end if;
      else
         null;
      end if;

      if (l_prog = 20) then
         if (l_debug = 1) then
            trace(' Material Grouping Rule not stamped on the Operation Plan Detail line. Unable to proceed. Aborting execution...');
         end if;
      else
         null;
      end if;

      if c_oper_plan_details%ISOPEN then
         close c_oper_plan_details;
      end if;

      if c_lpn_active_wzone_witem%ISOPEN then
         close c_lpn_active_wzone_witem;
      end if;

      if c_lpn_active_wzone_woitem%ISOPEN then
         close c_lpn_active_wzone_woitem;
      end if;

      if c_lpn_comp_wzone_witem%ISOPEN then
         close c_lpn_comp_wzone_witem;
      end if;

      if c_lpn_comp_wzone_woitem%ISOPEN then
         close c_lpn_comp_wzone_woitem;
      end if;

      if c_lpn_active_wozone_witem%ISOPEN then
         close c_lpn_active_wozone_witem;
      end if;

      if c_lpn_active_wozone_woitem%ISOPEN then
         close c_lpn_active_wozone_woitem;
      end if;

      if c_lpn_comp_wozone_witem%ISOPEN then
         close c_lpn_comp_wozone_witem;
      end if;

      if c_lpn_comp_wozone_woitem%ISOPEN then
         close c_lpn_comp_wozone_woitem;
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Error Message(Error Code) ' || sqlerrm(sqlcode));
      end if;

      --
      --### Call trace message before exiting...
      --
      exit_proc_msg(
         x_return_status  => x_return_status
      ,  x_msg_count =>  x_msg_count
      ,  x_msg_data  => x_msg_data
      ,  x_lpn_id  =>  x_lpn_id
      ,  x_lpn_valid  =>   x_lpn_valid
      ,  l_proc  =>  l_proc
      );

   when others then
      if (l_debug = 1) then
         trace(' Progress at the time of failure is ' || l_prog, 1);
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;

      if c_oper_plan_details%ISOPEN then
         close c_oper_plan_details;
      end if;

      if c_lpn_active_wzone_witem%ISOPEN then
         close c_lpn_active_wzone_witem;
      end if;

      if c_lpn_active_wzone_woitem%ISOPEN then
         close c_lpn_active_wzone_woitem;
      end if;

      if c_lpn_comp_wzone_witem%ISOPEN then
         close c_lpn_comp_wzone_witem;
      end if;

      if c_lpn_comp_wzone_woitem%ISOPEN then
         close c_lpn_comp_wzone_woitem;
      end if;

      if c_lpn_active_wozone_witem%ISOPEN then
         close c_lpn_active_wozone_witem;
      end if;

      if c_lpn_active_wozone_woitem%ISOPEN then
         close c_lpn_active_wozone_woitem;
      end if;

      if c_lpn_comp_wozone_witem%ISOPEN then
         close c_lpn_comp_wozone_witem;
      end if;

      if c_lpn_comp_wozone_woitem%ISOPEN then
         close c_lpn_comp_wozone_woitem;
      end if;

      if (l_debug = 1) then
         trace(l_proc || ' Error Message(Error Code) ' || sqlerrm(sqlcode));
      end if;

      --
      --### Call trace message before exiting...
      --
      exit_proc_msg(
         x_return_status  => x_return_status
      ,  x_msg_count =>  x_msg_count
      ,  x_msg_data  => x_msg_data
      ,  x_lpn_id  =>  x_lpn_id
      ,  x_lpn_valid  =>   x_lpn_valid
      ,  l_proc  =>  l_proc
      );
end get_seed_dest_lpn;

end wms_atf_destination_lpn;

/
