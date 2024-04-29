--------------------------------------------------------
--  DDL for Package Body WMS_ATF_DEST_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_DEST_LOC" as
/* $Header: WMSADLOB.pls 115.47 2004/05/07 21:24:39 joabraha noship $ */
--
l_debug      number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_pkg        varchar2(72) := 'WMS_ATF_DEST_LOC :';

--
-- ---------------------------------------------------------------------------------------
-- |---------------------< trace >--------------------------------------------------------|
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
--

Procedure trace(
   p_message  in varchar2
,  p_level    in number
   ) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_ATF_DEST_LOC', p_level);
end trace;
--
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
,  x_locator_id           in  number
,  x_zone_id              in  number
,  x_subinventory_code    in  varchar2
,  x_loc_valid            in  varchar2
,  l_proc                 in  varchar2
) is
begin
    if (l_debug = 1) then
       trace(' Exiting Procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
       trace(l_proc || ' x_return_status      => ' || x_return_status);
       trace(l_proc || ' x_msg_count => ' || x_msg_count);
       trace(l_proc || ' x_msg_data => ' || x_msg_data);
       trace(l_proc || ' x_locator_id => ' || x_locator_id);
       trace(l_proc || ' x_zone_id => ' || x_zone_id);
       trace(l_proc || ' x_subinventory_code => ' || x_subinventory_code);
       trace(l_proc || ' x_loc_valid => ' || x_loc_valid);
    end if;
end exit_proc_msg;
--
-- ---------------------------------------------------------------------------------------
-- |----------------------------< Get_Destination_Loc >-----------------------------------|
-- ---------------------------------------------------------------------------------------
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
--   Name                           Reqd Type     Description
--   x_locator_id                   Yes  varchar2 Short name for parent Module/Business
--   x_zone_id                      Yes  varchar2 Call package to be registered                                                                              --   x_subinventory_code            Yes  varchar2 Call procedure to be registered
--   p_mode                         Yes  varchar2 Effective To Date.
--   p_activity_type                Yes  varchar2 Valid Modes are Insert, Update and
--   p_task_id                      Yes  varchar2 Indicates if this is a seeded or
--   p_locator_id                   Yes
--   p_item_id                      Yes
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
--
-- We need 2 wrappers :
-- One with Inventory item_id passed in
-- One won't pass the p_item_id.
Procedure get_seed_dest_loc (
   x_return_status        out nocopy varchar2
,  x_msg_count            out nocopy number
,  x_msg_data             out nocopy varchar2
,  x_locator_id           out nocopy number
,  x_zone_id              out nocopy number
,  x_subinventory_code    out nocopy varchar2
,  x_loc_valid            out nocopy varchar2
,  p_mode                 in  number
,  p_task_id              in  number
,  p_activity_type_id     in  number
,  p_locator_id           in  number
,  p_item_id              in  number
,  p_api_version          in  number
,  p_init_msg_list        in  varchar2
,  p_commit               in  varchar2
) is

       l_proc                    varchar2(72) := 'GET_SEED_DEST_LOC :';
       l_prog                    float := null;

       l_operation_plan_id	 number := null;
       l_operation_plan_dtl_id   number := null;
       l_plan_type_id		 number := null;
       l_activity_type_id        number := null;
       l_pre_specified_zone_id	 number := null;
       l_pre_specified_sub_code	 varchar2(100) := null;
       l_loc_mtrl_grp_rule_id	 number := null;
       l_operation_type		 number := null;

       l_lpn_id			 number := null;
       l_subinventory_code	 varchar2(100) := null;
       l_locator_id		 number := null;

       l_is_in_inventory	 varchar2(1) := null;
       l_inventory_location_id   number := null;
       l_subinventory_type       varchar2(100) := null;

       l_orig_dest_sub_code      varchar2(100) := null;
       l_orig_dest_loc_id        number := null;

       l_organization_id         number := null;
       l_zone_id                 number := null;


       l_active_cur_found        boolean := false;
       l_cursor                  varchar2(50):= null;
       l_cur_found               boolean := false;

       l_sysdate                 varchar2(100);
       l_sys_date                date;

cursor c_sysdate is
select to_char(sysdate, 'RRRR/MM/DD HH24:MI:SS')
from   dual;

cursor c_oper_plan_details is
select mmtt.operation_plan_id,
       mmtt.locator_id,
       mmtt.subinventory_code,
       wopd.operation_plan_detail_id,
       wopi.activity_type_id,
       wopi.plan_type_id,
       wopi.orig_dest_sub_code,
       wopi.orig_dest_loc_id,
       wopd.pre_specified_zone_id,
       wopd.pre_specified_sub_code,
       nvl(wopd.loc_mtrl_grp_rule_id, -99),
       wopd.operation_type,
       nvl(wopd.is_in_inventory, 'N'),
       mmtt.organization_id,
       mmtt.lpn_id
from   wms_op_plan_instances wopi,     -- after review on 07/30/03, replaced wms_op_plans_b table with wms_op_plan_instances.
       wms_op_plan_details wopd,
       -- wms_zones_b wzb,             -- Removed after Code Review on Sept 11th 2003.
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi                                -- Added after review on 07/30/03
where  mmtt.organization_id = nvl(wopi.organization_id, mmtt.organization_id)
and    wopd.operation_plan_detail_id = wooi.operation_plan_detail_id  -- Added after review on 07/30/03
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


-- Added following two (c_subloc_pend_wo_zone, c_subloc_pend_w_zone) cursors for bug 3393371  - lezhang
-- When there are two mmtts in the same LPN, Activate_Operation_Instance for both MMTTs (as well as get_seed_dest_loc)
-- will be called before each of them gets completed. The destination suggestion for the second line should consider
-- the first line also.
-- The first MMTT will have an operation instance WOOI that is drop active.

cursor c_subloc_pend_wozone_woitem is
select milk.subinventory_code, nvl(milk.physical_location_id, milk.inventory_location_id)
from   mtl_item_locations milk,
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_plan_instances wopi,
       wms_license_plate_numbers wlpn1,
       wms_license_plate_numbers wlpn2
where  wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
and    wooi.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.operation_type_id = 2   -- Drop operation
and    wooi.operation_status = 2    -- Active
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = milk.organization_id
and    mmtt.lpn_id = wlpn1.lpn_id
and    wlpn2.lpn_id = l_lpn_id
and    wlpn1.outermost_lpn_id = wlpn2.outermost_lpn_id
and    milk.subinventory_code = l_pre_specified_sub_code
and    nvl(mmtt.transfer_to_location, mmtt.locator_id) = milk.inventory_location_id
order by wooi.last_update_date desc;
--
--
cursor c_subloc_pend_wzn_wosub_woitem is
select milk.subinventory_code, nvl(milk.physical_location_id, milk.inventory_location_id)
from   mtl_item_locations milk,
       wms_zone_locators  wzl,
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_plan_instances wopi,
       wms_license_plate_numbers wlpn1,
       wms_license_plate_numbers wlpn2
where  wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
and    wooi.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.operation_type_id = 2   -- Drop operation
and    wooi.operation_status = 2    -- Active
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = milk.organization_id
and    mmtt.lpn_id = wlpn1.lpn_id
and    wlpn2.lpn_id = l_lpn_id
and    wlpn1.outermost_lpn_id = wlpn2.outermost_lpn_id
and    nvl(mmtt.transfer_to_location, mmtt.locator_id) = milk.inventory_location_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = milk.subinventory_code
and    (wzl.entire_sub_flag = 'Y'
       or wzl.inventory_location_id = nvl(milk.physical_location_id, milk.inventory_location_id))
order by wooi.last_update_date desc;
--
--
cursor c_subloc_pend_wzn_wsub_woitem is
select milk.subinventory_code, nvl(milk.physical_location_id, milk.inventory_location_id)
from   mtl_item_locations milk,
       wms_zone_locators  wzl,
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_plan_instances wopi,
       wms_license_plate_numbers wlpn1,
       wms_license_plate_numbers wlpn2
where  wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
and    wooi.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.operation_type_id = 2   -- Drop operation
and    wooi.operation_status = 2    -- Active
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = milk.organization_id
and    mmtt.lpn_id = wlpn1.lpn_id
and    wlpn2.lpn_id = l_lpn_id
and    wlpn1.outermost_lpn_id = wlpn2.outermost_lpn_id
and    nvl(mmtt.transfer_to_location, mmtt.locator_id) = milk.inventory_location_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = milk.subinventory_code
and    milk.subinventory_code = l_pre_specified_sub_code
and    (wzl.entire_sub_flag = 'Y'
       or wzl.inventory_location_id = Nvl(milk.physical_location_id, milk.inventory_location_id))
order by wooi.last_update_date desc;
--
--

cursor c_subloc_pend_wozone_witem is
select milk.subinventory_code, nvl(milk.physical_location_id, milk.inventory_location_id)
from   mtl_item_locations milk,
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_plan_instances wopi,
       wms_license_plate_numbers wlpn1,
       wms_license_plate_numbers wlpn2
where  wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
and    wooi.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.operation_type_id = 2   -- Drop operation
and    wooi.operation_status = 2    -- Active
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = milk.organization_id
and    mmtt.lpn_id = wlpn1.lpn_id
and    mmtt.inventory_item_id = p_item_id
and    wlpn2.lpn_id = l_lpn_id
and    wlpn1.outermost_lpn_id = wlpn2.outermost_lpn_id
and    milk.subinventory_code = l_pre_specified_sub_code
and    nvl(mmtt.transfer_to_location, mmtt.locator_id) = milk.inventory_location_id
order by wooi.last_update_date desc;
--
--
cursor c_subloc_pend_wzn_wosub_witem is
select milk.subinventory_code, nvl(milk.physical_location_id, milk.inventory_location_id)
from   mtl_item_locations milk,
       wms_zone_locators  wzl,
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_plan_instances wopi,
       wms_license_plate_numbers wlpn1,
       wms_license_plate_numbers wlpn2
where  wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
and    wooi.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.operation_type_id = 2   -- Drop operation
and    wooi.operation_status = 2    -- Active
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = milk.organization_id
and    mmtt.lpn_id = wlpn1.lpn_id
and    mmtt.inventory_item_id = p_item_id
and    wlpn2.lpn_id = l_lpn_id
and    wlpn1.outermost_lpn_id = wlpn2.outermost_lpn_id
and    nvl(mmtt.transfer_to_location, mmtt.locator_id) = milk.inventory_location_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = milk.subinventory_code
and    (wzl.entire_sub_flag = 'Y'
       or wzl.inventory_location_id = nvl(milk.physical_location_id, milk.inventory_location_id))
order by wooi.last_update_date desc;
--
--
cursor c_subloc_pend_wzn_wsub_witem is
select milk.subinventory_code, nvl(milk.physical_location_id, milk.inventory_location_id)
from   mtl_item_locations milk,
       wms_zone_locators  wzl,
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_plan_instances wopi,
       wms_license_plate_numbers wlpn1,
       wms_license_plate_numbers wlpn2
where  wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
and    wooi.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.operation_type_id = 2   -- Drop operation
and    wooi.operation_status = 2    -- Active
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = milk.organization_id
and    mmtt.lpn_id = wlpn1.lpn_id
and    mmtt.inventory_item_id = p_item_id
and    wlpn2.lpn_id = l_lpn_id
and    wlpn1.outermost_lpn_id = wlpn2.outermost_lpn_id
and    nvl(mmtt.transfer_to_location, mmtt.locator_id) = milk.inventory_location_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = milk.subinventory_code
and    milk.subinventory_code = l_pre_specified_sub_code
and    (wzl.entire_sub_flag = 'Y'
       or wzl.inventory_location_id = Nvl(milk.physical_location_id, milk.inventory_location_id))
order by wooi.last_update_date desc;


cursor c_act_wzone_wsub_witem is
select wooi.from_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
       wms_zone_locators   wzl,
--     ***** tables from the inner cursor *****
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2,
       wms_op_plan_instances wopi
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooi.from_subinventory_code
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooi.from_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooi.from_subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooi.from_locator_id
and    milk1.organization_id = wooi.organization_id
and    wooi.from_locator_id  = decode(p_mode, 1, wooi.from_locator_id, 2, p_locator_id)
and    wooi.organization_id = mmtt.organization_id
--     *****from the inner cursor****
and    wopi.organization_id = mmtt.organization_id
and    wopi.status = 6  -- (Operation Plan Status : Active)
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2 -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = l_organization_id
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    mmtt.transaction_temp_id <> p_task_id
and    mmtt.inventory_item_id = p_item_id
and    wopi.activity_type_id = l_activity_type_id
and    wooi.activity_type_id = l_activity_type_id
and    wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by mmtt.creation_date desc;
--
--
cursor c_comp_wzone_wsub_witem is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_zone_locators wzl,
       wms_license_plate_numbers wlpn,
       wms_dispatched_tasks_history wdth,
       mtl_item_locations milk1,
       mtl_item_locations milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- newly modified
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooih.to_locator_id -- newly modified
and    milk1.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooih.to_subinventory_code -- newly modified
and    wzl.subinventory_code = l_pre_specified_sub_code
and    wzl.subinventory_code = msi.secondary_inventory_name -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wooih.to_subinventory_code = l_pre_specified_sub_code
and    wooih.to_subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code -- new
and    msi.organization_id = l_organization_id --,newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.subinventory_code = l_pre_specified_sub_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wdth.inventory_item_id = p_item_id
and    wdth.organization_id = l_organization_id -- new
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3                                          -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id -- new
and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wooih.last_update_date desc;
--
--
cursor c_comp_wzonesubitem_destsub is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_zone_locators wzl,
       wms_license_plate_numbers wlpn,
       wms_dispatched_tasks_history wdth,
       mtl_item_locations milk1,
       mtl_item_locations milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- newly modified
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooih.to_locator_id -- newly modified
and    milk1.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooih.to_subinventory_code -- newly modified
and    wzl.subinventory_code = l_pre_specified_sub_code
and    wzl.subinventory_code = msi.secondary_inventory_name -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wooih.to_subinventory_code = l_pre_specified_sub_code
and    wooih.to_subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code -- new
and    msi.organization_id = l_organization_id --,newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.subinventory_code = l_pre_specified_sub_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wdth.inventory_item_id = p_item_id
and    wdth.organization_id = l_organization_id -- new
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3                                          -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id -- new
--and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
--and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
and    wopih.orig_dest_sub_code = l_orig_dest_sub_code
order by wooih.last_update_date desc;
--
--
cursor c_act_wzone_wsub_woitem is
select wooi.from_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from
       mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
       wms_zone_locators   wzl,
--     ***** tables from the inner cursor *****
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2,
       wms_op_plan_instances wopi
where
       milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooi.from_subinventory_code
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooi.from_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooi.from_subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooi.from_locator_id
and    milk1.organization_id = wooi.organization_id
and    wooi.from_locator_id  = decode(p_mode, 1, wooi.from_locator_id, 2, p_locator_id)
and    wooi.organization_id = l_organization_id
--     *****from the inner cursor****
and    wopi.status = 6              -- (Operation Plan Status : Active, Completed)
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    wopi.activity_type_id = l_activity_type_id
and    wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by wooi.creation_date desc;
--
--
cursor c_comp_wzone_wsub_woitem is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_zone_locators  wzl,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.inventory_location_id = wooih.to_locator_id -- new
and    milk1.organization_id = l_organization_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = wooih.to_subinventory_code -- new
and    wzl.subinventory_code = l_pre_specified_sub_code -- new
and    wzl.subinventory_code = msi.secondary_inventory_name
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code -- new
and    msi.organization_id = l_organization_id -- newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.subinventory_code = l_pre_specified_sub_code -- new
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    --     where  wooih2.op_plan_instance_id = wooih.op_plan_instance_id
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3                   -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id
and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wooih.last_update_date desc;
--
--
cursor c_comp_wzonesub_woitem_destsub is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_zone_locators  wzl,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.inventory_location_id = wooih.to_locator_id -- new
and    milk1.organization_id = l_organization_id
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = wooih.to_subinventory_code -- new
and    wzl.subinventory_code = l_pre_specified_sub_code -- new
and    wzl.subinventory_code = msi.secondary_inventory_name
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code -- new
and    msi.organization_id = l_organization_id -- newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.subinventory_code = l_pre_specified_sub_code -- new
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    --     where  wooih2.op_plan_instance_id = wooih.op_plan_instance_id
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3                   -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id
--and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
--and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
and    wopih.orig_dest_sub_code = l_orig_dest_sub_code
order by wooih.last_update_date desc;
--
--
cursor c_act_wzone_only_witem is
select wooi.from_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
       wms_zone_locators   wzl,
--     ***** tables from the inner cursor *****
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2,
       wms_op_plan_instances wopi
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooi.from_subinventory_code
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooi.from_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooi.from_subinventory_code = msi.secondary_inventory_name
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooi.from_locator_id
and    milk1.organization_id = wooi.organization_id
and    wooi.from_locator_id  = decode(p_mode, 1, wooi.from_locator_id, 2, p_locator_id)
and    wooi.organization_id = l_organization_id
--     *****from the inner cursor****
and    wopi.organization_id = l_organization_id
and    wopi.status = 6                            -- (Operation Plan Status : Active, Completed)
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2 -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.source_task_id = mmtt.transaction_temp_id
and    mmtt.organization_id = l_organization_id
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    mmtt.inventory_item_id = p_item_id
and    wopi.activity_type_id = l_activity_type_id
--and    wooi.activity_type_id = l_activity_type_id
and    wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by mmtt.creation_date desc;
--
--
cursor c_comp_wzone_only_witem is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
       wms_zone_locators   wzl,
--     ***** tables from the inner cursor *****
       wms_license_plate_numbers wlpn,
       wms_dispatched_tasks_history wdth,
       wms_op_opertn_instances_hist wooih,
       wms_op_plan_instances_hist wopih
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- newly modified
and    milk1.inventory_location_id = wooih.to_locator_id
and    milk1.inventory_location_id = decode(p_mode, 1, milk1.inventory_location_id, 2, p_locator_id)
and    milk1.organization_id = wlpn.organization_id
and    milk1.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = msi.secondary_inventory_name
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    msi.organization_id = l_organization_id -- newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = wooih.to_locator_id
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.locator_id = decode(p_mode, 1, wlpn.locator_id, 2, p_locator_id)
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6     -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wdth.inventory_item_id = p_item_id
and    wdth.organization_id = l_organization_id -- new
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = msi.secondary_inventory_name -- new
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wopih.op_plan_instance_id = wooih.op_plan_instance_id
and    wopih.status = 3                       -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id
and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wooih.last_update_date desc;
--
--
cursor c_comp_wzoneonlyitem_destsub is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
       wms_zone_locators   wzl,
--     ***** tables from the inner cursor *****
       wms_license_plate_numbers wlpn,
       wms_dispatched_tasks_history wdth,
       wms_op_opertn_instances_hist wooih,
       wms_op_plan_instances_hist wopih
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- newly modified
and    milk1.inventory_location_id = wooih.to_locator_id
and    milk1.inventory_location_id = decode(p_mode, 1, milk1.inventory_location_id, 2, p_locator_id)
and    milk1.organization_id = wlpn.organization_id
and    milk1.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = msi.secondary_inventory_name
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    msi.organization_id = l_organization_id -- newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = wooih.to_locator_id
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.locator_id = decode(p_mode, 1, wlpn.locator_id, 2, p_locator_id)
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6     -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wdth.inventory_item_id = p_item_id
and    wdth.organization_id = l_organization_id -- new
and    wooih.organization_id = l_organization_id -- new
and    wooih.to_subinventory_code = msi.secondary_inventory_name -- new
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wopih.op_plan_instance_id = wooih.op_plan_instance_id
and    wopih.status = 3                       -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id
--and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
--and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
and    wopih.orig_dest_sub_code = l_orig_dest_sub_code
order by wooih.last_update_date desc;
--
--
cursor c_act_wzone_only_woitem is
select wooi.from_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
       wms_zone_locators   wzl,
--     ***** tables from the inner cursor *****
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2,
       wms_op_plan_instances wopi
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wooi.from_subinventory_code
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooi.from_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    msi.secondary_inventory_name = wooi.from_subinventory_code
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = decode(p_mode, 1, milk1.inventory_location_id, 2, p_locator_id) -- new
and    milk1.inventory_location_id = wooi.from_locator_id
and    milk1.organization_id = wooi.organization_id
and    wooi.from_locator_id  = decode(p_mode, 1, wooi.from_locator_id, 2, p_locator_id)
and    wooi.organization_id = l_organization_id
--     *****from the inner cursor****
and    wopi.organization_id = l_organization_id
and    wopi.status = 6        -- (Operation Plan Status : Active, Completed)
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2 -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    wopi.organization_id = l_organization_id
and    wooi.activity_type_id = l_activity_type_id
and    wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by wooi.creation_date desc;
--
--
cursor c_comp_wzone_only_woitem is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_zone_locators  wzl,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- newly modified
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.inventory_location_id = wooih.to_locator_id -- new
and    milk1.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = msi.secondary_inventory_name -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    msi.secondary_inventory_name = wooih.to_subinventory_code -- new
and    msi.organization_id = l_organization_id -- newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3            -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id
and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wooih.last_update_date desc;
--
--
cursor c_comp_wzoneonlywoitem_destsub is
select wooih.to_subinventory_code, milk2.inventory_location_id, wzl.zone_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_zone_locators  wzl,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- newly modified
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.inventory_location_id = wooih.to_locator_id -- new
and    milk1.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
and    wzl.subinventory_code = wlpn.subinventory_code
and    wzl.subinventory_code = msi.secondary_inventory_name -- new
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = wooih.to_locator_id)
and    wzl.organization_id = l_organization_id
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    msi.secondary_inventory_name = wooih.to_subinventory_code -- new
and    msi.organization_id = l_organization_id -- newly modified
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3            -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.organization_id = l_organization_id
--and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
--and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
and    wopih.orig_dest_sub_code = l_orig_dest_sub_code
order by wooih.last_update_date desc;
--
--
cursor c_act_wozone_witem is
select wooi.from_subinventory_code, milk2.inventory_location_id
from
       mtl_item_locations  milk1,
       mtl_item_locations  milk2,

       mtl_secondary_inventories msi,
--     ***** tables from the inner cursor *****
       mtl_material_transactions_temp mmtt,
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2,
       wms_op_plan_instances wopi
where
       milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooi.from_subinventory_code = msi.secondary_inventory_name
and    wooi.from_subinventory_code = l_pre_specified_sub_code
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooi.from_locator_id
and    milk1.organization_id = wooi.organization_id
and    wooi.from_locator_id  = decode(p_mode, 1, wooi.from_locator_id, 2, p_locator_id)
and    wooi.organization_id = l_organization_id
--     *****from the inner cursor****
and    wopi.status = 6                          -- (Operation Plan Status : In progress, Completed)
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    wooi.source_task_id = mmtt.transaction_temp_id                    -- Added as per Amin in review.
and    mmtt.organization_id = l_organization_id
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    mmtt.transaction_temp_id <> p_task_id
and    mmtt.inventory_item_id = p_item_id
and    wopi.activity_type_id = l_activity_type_id
and    wooi.activity_type_id = l_activity_type_id
and    wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by mmtt.creation_date desc;
--
--
cursor c_comp_wozone_witem is
select wlpn.subinventory_code, milk2.inventory_location_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    wooih.to_subinventory_code = msi.secondary_inventory_name
and    wooih.to_subinventory_code = l_pre_specified_sub_code
and    wooih.organization_id = l_organization_id -- new
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = l_pre_specified_sub_code
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id  -- newly modified
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- new
and    milk1.organization_id = l_organization_id -- newly modified
and    milk1.inventory_location_id = wooih.to_locator_id -- new
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.organization_id = l_organization_id
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = wooih.to_locator_id
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wdth.organization_id  = l_organization_id
and    wdth.inventory_item_id = p_item_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wooih.organization_id = l_organization_id -- new
and    wopih.organization_id = l_organization_id -- new
and    wopih.status = 3                          -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wooih.last_update_date desc;
--
--
cursor c_comp_wozone_witem_destsub is
select wlpn.subinventory_code, milk2.inventory_location_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    wooih.to_subinventory_code = msi.secondary_inventory_name
and    wooih.to_subinventory_code = l_pre_specified_sub_code
and    wooih.organization_id = l_organization_id -- new
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = l_pre_specified_sub_code
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id  -- newly modified
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk2.organization_id = l_organization_id -- new
and    milk1.organization_id = l_organization_id -- newly modified
and    milk1.inventory_location_id = wooih.to_locator_id -- new
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.organization_id = l_organization_id
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = wooih.to_locator_id
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wdth.organization_id  = l_organization_id
and    wdth.inventory_item_id = p_item_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wooih.organization_id = l_organization_id -- new
and    wopih.organization_id = l_organization_id -- new
and    wopih.status = 3                          -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
--and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
--and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
and    wopih.orig_dest_sub_code = l_orig_dest_sub_code
order by wooih.last_update_date desc;
--
--
cursor c_act_wozone_woitem is
select wooi.from_subinventory_code, milk2.inventory_location_id
from
       mtl_item_locations  milk1,
       mtl_item_locations  milk2,
       mtl_secondary_inventories msi,
--     ***** tables from the inner cursor *****
       wms_op_operation_instances wooi,
       wms_op_operation_instances wooi2,
       wms_op_plan_instances wopi
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooi.from_subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = wooi.organization_id
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooi.from_locator_id
and    milk1.organization_id = wooi.organization_id
and    wooi.from_locator_id  = decode(p_mode, 1, wooi.from_locator_id, 2, p_locator_id)
--     *****from the inner cursor****
and    wopi.status = 6                             -- (Operation Plan Status : In progress, Completed)
and    wopi.op_plan_instance_id = wooi.op_plan_instance_id
and    wooi2.operation_status = 3   -- Completed
and    wooi2.operation_type_id = 2  -- Drop
and    wooi2.op_plan_instance_id = wopi.op_plan_instance_id
and    (wooi.operation_status = 1 and wooi.operation_type_id <> 2)
and    wopi.activity_type_id = l_activity_type_id
and    wooi.organization_id = l_organization_id
and    wopi.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopi.plan_type_id)
and    wopi.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopi.orig_dest_sub_code )
and    wopi.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopi.orig_dest_loc_id)
order by wooi.creation_date desc;
--
--
cursor c_comp_wozone_woitem is
select wlpn.subinventory_code, milk2.inventory_location_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooih.to_subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooih.to_locator_id
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.organization_id = l_organization_id
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = wooih.to_locator_id
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3                                          -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
order by wooih.last_update_date desc;
--
--
cursor c_comp_wozone_woitem_destsub is
select wlpn.subinventory_code, milk2.inventory_location_id
from   wms_op_plan_instances_hist wopih,
       wms_op_opertn_instances_hist wooih,
       mtl_secondary_inventories msi,
       wms_dispatched_tasks_history wdth,
       wms_license_plate_numbers wlpn,
       mtl_item_locations  milk1,
       mtl_item_locations  milk2
where  milk2.subinventory_code = msi.secondary_inventory_name
and    milk2.organization_id = msi.organization_id
and   ((milk2.disable_date is null and msi.disable_date is null)
       or (not (   milk2.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk2.disable_date is null or milk2.disable_date >= l_sys_date)))
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    wooih.to_subinventory_code = msi.secondary_inventory_name
and    wlpn.subinventory_code = msi.secondary_inventory_name
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id
and    milk2.segment19 is null
and    milk2.segment20 is null
and    milk2.inventory_location_id = nvl(milk1.physical_location_id, milk1.inventory_location_id)
and    milk1.organization_id = milk2.organization_id
and    milk1.inventory_location_id = wooih.to_locator_id
and    milk1.inventory_location_id = wlpn.locator_id
and    milk1.organization_id = l_organization_id
and    wooih.to_locator_id = decode(p_mode, 1, wooih.to_locator_id, 2, p_locator_id)
and    wlpn.locator_id = wooih.to_locator_id
and    wlpn.subinventory_code = wooih.to_subinventory_code
and    wlpn.organization_id = l_organization_id
and    wlpn.lpn_id = nvl(wdth.transfer_lpn_id, wdth.content_lpn_id)
and    wdth.status = 6   -- Completed. lookup_type is WMS_TASK_STATUS
and    wdth.transaction_id  = wooih.source_task_id
and    wooih.operation_sequence in (select max(operation_sequence)
				    from   wms_op_opertn_instances_hist wooih2
				    where  wooih2.op_plan_instance_id = wopih.op_plan_instance_id
				    and    wooih2.operation_type_id in (2,9)
				    and    wooih2.operation_status = 3)
and    wooih.op_plan_instance_id = wopih.op_plan_instance_id
and    wopih.status = 3                                          -- Plan Completed
and    wopih.activity_type_id = l_activity_type_id
--and    wopih.plan_type_id = decode(l_loc_mtrl_grp_rule_id,1,l_plan_type_id,wopih.plan_type_id)
--and    wopih.orig_dest_sub_code = decode(l_loc_mtrl_grp_rule_id,2,l_orig_dest_sub_code,wopih.orig_dest_sub_code )
--and    wopih.orig_dest_loc_id   = decode(l_loc_mtrl_grp_rule_id,3,l_orig_dest_loc_id,wopih.orig_dest_loc_id)
and    wopih.orig_dest_sub_code = l_orig_dest_sub_code
order by wooih.last_update_date desc;
--
--
cursor c_aux_wzone_wsub is
select milk.inventory_location_id, milk.subinventory_code, wzl.zone_id
from   mtl_secondary_inventories msi,
       mtl_item_locations milk,
       wms_zone_locators wzl
where  milk.subinventory_code = msi.secondary_inventory_name
and    milk.organization_id = msi.organization_id
and   ((milk.disable_date is null and msi.disable_date is null)
       or (not (   milk.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk.disable_date is null or milk.disable_date >= l_sys_date)))
and    milk.segment20 is null
and    milk.segment19 is null
and    milk.subinventory_code = msi.secondary_inventory_name
and    milk.subinventory_code = l_pre_specified_sub_code
and    milk.organization_id = l_organization_id -- new
and    msi.secondary_inventory_name = wzl.subinventory_code
and    msi.secondary_inventory_name = l_pre_specified_sub_code -- new
and    msi.organization_id = l_organization_id -- new
and    milk.inventory_location_id = decode(p_mode, 1, milk.inventory_location_id, 2, p_locator_id)
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = milk.inventory_location_id)
and    wzl.organization_id = l_organization_id
and    wzl.subinventory_code = l_pre_specified_sub_code
and    wzl.zone_id = l_pre_specified_zone_id
order by nvl(milk.empty_flag, 'N') desc, nvl(milk.location_suggested_units, 0), milk.dropping_order asc, milk.picking_order asc;
--
--
cursor c_aux_wzone_only is
select milk.inventory_location_id, milk.subinventory_code, wzl.zone_id
from   mtl_secondary_inventories msi,
       mtl_item_locations milk,
       wms_zone_locators wzl
where  milk.subinventory_code = msi.secondary_inventory_name
and    milk.organization_id = msi.organization_id
and   ((milk.disable_date is null and msi.disable_date is null)
       or (not (   milk.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk.disable_date is null or milk.disable_date >= l_sys_date)))
and    milk.segment20 is null
and    milk.segment19 is null
and    milk.subinventory_code = msi.secondary_inventory_name
and    milk.organization_id = l_organization_id -- new
and    nvl(msi.subinventory_type, 1) = decode(l_is_in_inventory, 'Y', 1, 2) -- 1:storage, 2:receiving
and    msi.secondary_inventory_name = wzl.subinventory_code
and    msi.organization_id = l_organization_id -- new
and    milk.inventory_location_id = decode(p_mode, 1, milk.inventory_location_id, 2, p_locator_id)
and    (wzl.entire_sub_flag = 'Y' or wzl.inventory_location_id = milk.inventory_location_id)
and    wzl.organization_id = l_organization_id -- newly modified
and    wzl.zone_id = l_pre_specified_zone_id
order by nvl(milk.empty_flag, 'N') desc, nvl(milk.location_suggested_units, 0), milk.dropping_order asc, milk.picking_order asc;
--
--
cursor c_aux_wsub_only is
select milk.inventory_location_id, milk.subinventory_code
from   mtl_secondary_inventories msi,
       mtl_item_locations milk
where  ((milk.disable_date is null and msi.disable_date is null)
       or (not (   milk.disable_date < l_sys_date
                or msi.disable_date < l_sys_date))
       or (    msi.disable_date = to_date('01/01/1700', 'DD/MM/RRRR')
           and msi.subinventory_type = 2
           and (milk.disable_date is null or milk.disable_date >= l_sys_date)))
and    milk.segment20 is null
and    milk.segment19 is null
and    milk.inventory_location_id = decode(p_mode, 1, milk.inventory_location_id, 2, p_locator_id)
and    milk.subinventory_code = msi.secondary_inventory_name
and    milk.organization_id = l_organization_id -- new
and    milk.subinventory_code =  l_pre_specified_sub_code -- new
and    msi.secondary_inventory_name = l_pre_specified_sub_code
and    msi.organization_id = l_organization_id
order by nvl(milk.empty_flag, 'N') desc, nvl(milk.location_suggested_units, 0), milk.dropping_order asc, milk.picking_order asc;
--
--
begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize message stack since p_init_msg_list is set to TRUE
   -- The p_init_msg_list is set to 'TRUE' in this code and so the message stack will always be initialised.
   --if fnd_api.to_boolean(p_init_msg_list) then
   --   fnd_msg_pub.initialize;
   --end if;

   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc || ' p_mode      => ' || p_mode);
      trace(l_proc || ' p_task_id    => ' || p_task_id);
      trace(l_proc || ' p_activity_type_id    => ' || p_activity_type_id);
      trace(l_proc || ' p_locator_id           => ' || p_locator_id);
      trace(l_proc || ' p_item_id => ' || p_item_id);
   end if;

   open c_sysdate;
   fetch c_sysdate into l_sysdate;
   close c_sysdate;

   dbms_output.put_line(' l_sysdate => ' || l_sysdate);
   l_sys_date   := to_date(l_sysdate, 'RRRR/MM/DD HH24:MI:SS');

   l_prog := 10;
   -- ### Setting Cursor Name
   l_cursor := 'c_oper_plan_details';
   if (l_debug =1 ) then
      trace(l_proc || ' Opening "Operation Plan Details" cursor "' ||l_cursor||'"', 1);
   end if;

   -- ### Derive Operation Plan details to start with.
   open  c_oper_plan_details;
   fetch c_oper_plan_details
   into  l_operation_plan_id, l_locator_id, l_subinventory_code, l_operation_plan_dtl_id,
         l_activity_type_id, l_plan_type_id, l_orig_dest_sub_code, l_orig_dest_loc_id,
         l_pre_specified_zone_id, l_pre_specified_sub_code, l_loc_mtrl_grp_rule_id,
         l_operation_type, l_is_in_inventory, l_organization_id, l_lpn_id;

   if c_oper_plan_details%NOTFOUND then
      fnd_message.set_name('WMS', 'WMS_OPERTN_PLAN_ID_INVALID');
      fnd_msg_pub.ADD;
      raise fnd_api.g_exc_error;                 -- Added after Code Review on Sept 11th 2003.
   else
      if (l_debug = 1) then
          trace(l_proc || ' Operation Plan ID  => ' || nvl(l_operation_plan_id, -99));
          trace(l_proc || ' Locator ID  => ' || nvl(l_locator_id, -99));
          trace(l_proc || ' Subinventory Code  => ' || nvl(l_subinventory_code, '@@@'));
          trace(l_proc || ' Operation Plan Detail ID  => ' || nvl(l_operation_plan_dtl_id, -99));
          trace(l_proc || ' Activity Type ID  => ' || nvl(l_activity_type_id, -99));
          trace(l_proc || ' Plan Type ID  => ' || nvl(l_plan_type_id, -99));
          trace(l_proc || ' Original Dest Sub Code  => ' || nvl(l_orig_dest_sub_code, '@@@'));
          trace(l_proc || ' Original Dest Loc ID  => ' || nvl(l_orig_dest_loc_id, -99));
          trace(l_proc || ' Pre-specified Zone ID  => ' || nvl(l_pre_specified_zone_id, -99));
          trace(l_proc || ' Pre-specified Sub Code  => ' || nvl(l_pre_specified_sub_code, '@@@'));
          trace(l_proc || ' Material Grouping Rule ID  => ' || nvl(l_loc_mtrl_grp_rule_id, -99));
          trace(l_proc || ' Operation Plan Type  => ' || nvl(l_operation_type, -99));
          trace(l_proc || ' Is In INV Flag  => ' || nvl(l_is_in_inventory, 'N'));
          trace(l_proc || ' Organization ID  => ' || nvl(l_organization_id, -1));
	  trace(l_proc || ' l_lpn_id  => ' || l_lpn_id);
          trace(l_proc || ' Closing " Operation Details " cursor "' ||l_cursor||'"', 4);
      end if;
      -- ### Close the above cursor.
      close c_oper_plan_details;
      l_prog := 11;
      -- ### Check to see if a valid Material Grouping Rule is stamped on the oeration plan detail.
      -- ### The LOV on the Form field allows to select a valid Rule only. Hence the possible cases
      -- ### are that either there is a valid value or a null value. Hence check only for null.
      -- ### Changes effected Oct. 6th 2003.
      -- ### Since an nvl has been added to all the derived variables in the cursor the check to see if
      -- ### l_loc_mtrl_grp_rule_id is null is being removed.
      -- if (l_loc_mtrl_grp_rule_id is null or l_loc_mtrl_grp_rule_id not in (1,2,3)) then
      if (l_loc_mtrl_grp_rule_id not in (1,2,3)) then
         trace('Incorrect Material Group ID  stamped on the operation plan detail line ... Cannot Proceed');
         fnd_message.set_name('WMS', 'WMS_MTRL_GRP_RULE_ID_IS_NULL');
         fnd_msg_pub.ADD;
         raise fnd_api.g_exc_error;              -- Added after Code Review on Sept 11th 2003.
      end if;
      -- ### Added after review with Amin on Oct 3rd 2003.
      -- ### Check to make sure for valid data.
      -- ### Changes effected Oct. 6th 2003.
      -- ### Commented out the following statement. The assumption here is that the is_in_inventory flag on the detail line
      -- ### will not be null. It'll be either 'Y' or 'N'. But to accomodate cases where the is_in_inventory is null, the
      -- ### SELECT clause of the _oper_plan_details cursor has been modified as follows:
      -- ### Before :
      -- ### wopd.is_in_inventory,
      -- ### After:
      -- ### nvl(wopd.is_in_inventory, 'N'),
      -- if (l_is_in_inventory is null or l_is_in_inventory not in ('Y','N')) then
      if (l_is_in_inventory not in ('Y','N')) then
         trace('Incorrect is_in_inventory flag stamped on the operation plan detail line ... Cannot Proceed');
         fnd_message.set_name('WMS', 'WMS_INVALID_ISININVFLAG');
         fnd_msg_pub.ADD;
         raise fnd_api.g_exc_error;              -- Added after Code Review on Sept 11th 2003.
      end if;
   end if;

   l_prog := 20;
   --
   -- @@@ As per the new design as of Sept 16th 2003, the code logic will fork based on if the variable
   -- @@@ " l_pre_specified_zone_id" is populated from the fetch of the Operation Plan Detail cursor.
   -- @@@ Now the same cursor is opened irrespective of the Material Grouping Rule stamped on the Operation
   -- @@@ Plan Detail Line.
   -- ### Prespecified Zone is not null..
   if l_pre_specified_zone_id is not null then
      -- @@@ Pending Cursors are being coded within separate if..then..end if enclosures while checking for
      -- @@@ pre-specified sub codes.
      if l_pre_specified_sub_code is not null then

         -- Added for bug 3393371

	 IF p_item_id IS NULL THEN
	    l_cursor := 'c_subloc_pend_wzn_wsub_woitem';
	    if (l_debug =1 ) then
	       trace(l_proc || ' Within "l_pre_specified_zone_id is not null" segment....', 1);
	       trace(l_proc || ' Within "l_pre_specified_sub_code is not null" segment....', 1);
	       trace(l_proc || ' Within "p_item_id is null" segment....', 1);
	       trace(l_proc || ' Opening "Pending operations" cursor "' ||l_cursor||'"', 1);
	    end if;

	    open  c_subloc_pend_wzn_wsub_woitem;
	    fetch c_subloc_pend_wzn_wsub_woitem
	      into  x_subinventory_code, x_locator_id;

	    if c_subloc_pend_wzn_wsub_woitem%NOTFOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' "c_subloc_pend_wzn_wsub_woitem" failed with %NOTFOUND...', 1);
		  trace(l_proc || ' Setting OUT variables to null...', 1);
		  trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
	       end if;
	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_subloc_pend_wzn_wsub_woitem;
	       l_cursor := null;
	     elsif c_subloc_pend_wzn_wsub_woitem%FOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' Found sub/loc from pending task within the same LPN.', 1);
		  trace(l_proc || ' x_subinventory_code = '||x_subinventory_code, 1);
		  trace(l_proc || ' x_locator_id = '||x_locator_id, 1);
	       end if;
	       close c_subloc_pend_wzn_wsub_woitem;
	       --
	       -- ### Call trace message before exiting...
	       --
	       exit_proc_msg( x_return_status => x_return_status
			      ,  x_msg_count =>  x_msg_count
			      ,  x_msg_data  => x_msg_data
			      ,  x_locator_id  =>  x_locator_id
			      ,  x_zone_id  => x_zone_id
			      ,  x_subinventory_code  =>  x_subinventory_code
			      ,  x_loc_valid  =>   x_loc_valid
			      ,  l_proc  =>  l_proc);
	       return;
	    end if;-- Marker: c_subloc_pend_wzn_wsub_woitem FOUND/NOTFOUND

	  ELSE  -- IF p_item_id IS NULL
	    l_cursor := 'c_subloc_pend_wzn_wsub_witem';
	    if (l_debug =1 ) then
	       trace(l_proc || ' Within "l_pre_specified_zone_id is not null" segment....', 1);
	       trace(l_proc || ' Within "l_pre_specified_sub_code is not null" segment....', 1);
	       trace(l_proc || ' Within "p_item_id is not null" segment....', 1);
	       trace(l_proc || ' Opening "Pending operations" cursor "' ||l_cursor||'"', 1);
	    end if;

	    open  c_subloc_pend_wzn_wsub_witem;
	    fetch c_subloc_pend_wzn_wsub_witem
	      into  x_subinventory_code, x_locator_id;

	    if c_subloc_pend_wzn_wsub_witem%NOTFOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' "c_subloc_pend_wzn_wsub_witem" failed with %NOTFOUND...', 1);
		  trace(l_proc || ' Setting OUT variables to null...', 1);
		  trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
	       end if;
	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_subloc_pend_wzn_wsub_witem;
	       l_cursor := null;
	     elsif c_subloc_pend_wzn_wsub_witem%FOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' Found sub/loc from pending task within the same LPN.', 1);
		  trace(l_proc || ' x_subinventory_code = '||x_subinventory_code, 1);
		  trace(l_proc || ' x_locator_id = '||x_locator_id, 1);
	       end if;
	       close c_subloc_pend_wzn_wsub_witem;
	       --
	       -- ### Call trace message before exiting...
	       --
	       exit_proc_msg( x_return_status => x_return_status
			      ,  x_msg_count =>  x_msg_count
			      ,  x_msg_data  => x_msg_data
			      ,  x_locator_id  =>  x_locator_id
			      ,  x_zone_id  => x_zone_id
			      ,  x_subinventory_code  =>  x_subinventory_code
			      ,  x_loc_valid  =>   x_loc_valid
			      ,  l_proc  =>  l_proc);
	       return;
	    end if;-- Marker: c_subloc_pend_wzn_wsub_witem FOUND/NOTFOUND

	 END IF; -- IF p_item_id IS NULL

      elsif l_pre_specified_sub_code is null then
         -- Added for bug 3393371
	 IF p_item_id IS NULL THEN
	    l_cursor := 'c_subloc_pend_wzn_wosub_woitem';
	    if (l_debug =1 ) then
	       trace(l_proc || ' Within "l_pre_specified_zone_id is not null" segment....', 1);
	       trace(l_proc || ' Within "l_pre_specified_sub_code is null" segment....', 1);
	       trace(l_proc || ' Within "p_item_id is null" segment....', 1);
	       trace(l_proc || ' Opening "Pending operations" cursor "' ||l_cursor||'"', 1);
	    end if;

	    open  c_subloc_pend_wzn_wosub_woitem;
	    fetch c_subloc_pend_wzn_wosub_woitem
	      into  x_subinventory_code, x_locator_id;

	    if c_subloc_pend_wzn_wosub_woitem%NOTFOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' "c_subloc_pend_wzn_wosub_woitem" failed with %NOTFOUND...', 1);
		  trace(l_proc || ' Setting OUT variables to null...', 1);
		  trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
	       end if;
	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_subloc_pend_wzn_wosub_woitem;
	       l_cursor := null;
	     elsif c_subloc_pend_wzn_wosub_woitem%FOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' Found sub/loc from pending task within the same LPN.', 1);
		  trace(l_proc || ' x_subinventory_code = '||x_subinventory_code, 1);
		  trace(l_proc || ' x_locator_id = '||x_locator_id, 1);
	       end if;
	       close c_subloc_pend_wzn_wosub_woitem;
	       --
	       -- ### Call trace message before exiting...
	       --
	       exit_proc_msg(x_return_status => x_return_status
			     ,  x_msg_count =>  x_msg_count
			     ,  x_msg_data  => x_msg_data
			     ,  x_locator_id  =>  x_locator_id
			     ,  x_zone_id  => x_zone_id
			     ,  x_subinventory_code  =>  x_subinventory_code
			     ,  x_loc_valid  =>   x_loc_valid
			     ,  l_proc  =>  l_proc);
	       return;
	    end if;-- Marker: c_subloc_pend_wzn_wosub_woitem FOUND/NOTFOUND

	  ELSE -- IF p_item_id IS NULL
	    l_cursor := 'c_subloc_pend_wzn_wosub_witem';
	    if (l_debug =1 ) then
	       trace(l_proc || ' Within "l_pre_specified_zone_id is not null" segment....', 1);
	       trace(l_proc || ' Within "l_pre_specified_sub_code is null" segment....', 1);
	       trace(l_proc || ' Within "p_item_id is not null" segment....', 1);
	       trace(l_proc || ' Opening "Pending operations" cursor "' ||l_cursor||'"', 1);
	    end if;

	    open  c_subloc_pend_wzn_wosub_witem;
	    fetch c_subloc_pend_wzn_wosub_witem
	      into  x_subinventory_code, x_locator_id;

	    if c_subloc_pend_wzn_wosub_witem%NOTFOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' "c_subloc_pend_wzn_wosub_witem" failed with %NOTFOUND...', 1);
		  trace(l_proc || ' Setting OUT variables to null...', 1);
		  trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
	       end if;
	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_subloc_pend_wzn_wosub_witem;
	       l_cursor := null;
	     elsif c_subloc_pend_wzn_wosub_witem%FOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' Found sub/loc from pending task within the same LPN.', 1);
		  trace(l_proc || ' x_subinventory_code = '||x_subinventory_code, 1);
		  trace(l_proc || ' x_locator_id = '||x_locator_id, 1);
	       end if;
	       close c_subloc_pend_wzn_wosub_witem;
	       --
	       -- ### Call trace message before exiting...
	       --
	       exit_proc_msg(x_return_status => x_return_status
			     ,  x_msg_count =>  x_msg_count
			     ,  x_msg_data  => x_msg_data
			     ,  x_locator_id  =>  x_locator_id
			     ,  x_zone_id  => x_zone_id
			     ,  x_subinventory_code  =>  x_subinventory_code
			     ,  x_loc_valid  =>   x_loc_valid
			     ,  l_proc  =>  l_proc);
	       return;
	    end if;-- Marker: c_subloc_pend_wzn_wosub_witem FOUND/NOTFOUND

	 END IF; -- IF p_item_id IS NULL

      end if;-- Marker: Check l_pre_specified_sub_code


      if l_pre_specified_sub_code is not null then
         -- @@@ With Zone, With Subinventory, With Item
   	 if p_item_id is not null then
   	    -- ### Setting Cursor Name.
   	    l_cursor := 'c_act_wzone_wsub_witem';
   	    if (l_debug =1 ) then
   	       trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
   	    end if;
   	    -- ### Open Cursor c_act_wzone_wsub_witem to look for "active operation" plans.
   	    open  c_act_wzone_wsub_witem;
   	    fetch c_act_wzone_wsub_witem
   	    into  l_subinventory_code, l_locator_id, l_zone_id;

   	    if c_act_wzone_wsub_witem%NOTFOUND then
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' "c_act_wzone_wsub_witem" failed with %NOTFOUND...', 1);
   	          trace(l_proc || ' Setting OUT variables to null...', 1);
   	          trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
   	       end if;
   	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_act_wzone_wsub_witem;
	       l_cursor := null;

   	       -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
   	       -- ### Opening cursor c_comp_wzone_wsub_witem to look for completed operations.
   	       -- ### Setting Cursor Name
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
   	       end if;

   	       --  ### Check for Material grouping rule when opening the completed operations cursor.
   	       if l_loc_mtrl_grp_rule_id = 2 then
   	       -- ### Open Cursor c_comp_wzonesubitem_destsub to look for "completed operation" plans.
   	          l_cursor := 'c_comp_wzonesubitem_destsub';
   	          open  c_comp_wzonesubitem_destsub;
   	          fetch c_comp_wzonesubitem_destsub
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzonesubitem_destsub%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzonesubitem_destsub" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzonesubitem_destsub;
		     l_cursor := null;
	          elsif c_comp_wzonesubitem_destsub%FOUND then
	          -- c_comp_wzonesubitem_destsub cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzonesubitem_destsub" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzonesubitem_destsub;
	             l_cur_found := true;
                  end if;-- @@@ Marker :c_comp_wzonesubitem_destsub FOUND/NOTFOUND
	       elsif l_loc_mtrl_grp_rule_id <> 2 then
   	       -- ### Open Cursor c_comp_wzone_wsub_witem to look for "completed operation" plans.
   	          l_cursor := 'c_comp_wzone_wsub_witem';
   	          open  c_comp_wzone_wsub_witem;
   	          fetch c_comp_wzone_wsub_witem
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzone_wsub_witem%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzone_wsub_witem" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzone_wsub_witem;
		     l_cursor := null;
	          elsif c_comp_wzone_wsub_witem%FOUND then
	             -- c_comp_wzone_wsub_witem cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzone_wsub_witem" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzone_wsub_witem;
	             l_cur_found := true;
                  end if; -- @@@ Marker :c_comp_wzone_wsub_witem FOUND/NOTFOUND
	       end if; -- @@@ Marker: Check for material grouping rule(l_loc_mtrl_grp_rule_id)

	       if (l_debug =1 ) then
		  trace(l_proc || ' Both main cursors failed to return any values...', 1);
		  trace(l_proc || ' Plan "B": Opening Auxillary Cursors to find a location ID ', 4);
	       end if;
            elsif c_act_wzone_wsub_witem%FOUND then
	      -- c_act_wzone_wsub_witem cursor found.
	      if (l_debug = 1) then
	         trace(l_proc || ' "c_act_wzone_wsub_witem" FOUND...', 1);
	         trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	      end if;
	      close c_act_wzone_wsub_witem;
	      l_cur_found := true;
            end if; -- @@@ Marker:   c_act_wzone_wsub_witem FOUND/NOTFOUND
         elsif p_item_id is null then
            -- @@@ With Zone, With Subinventory, Without Item
   	    -- ### Setting Cursor Name.
   	    l_cursor := 'c_act_wzone_wsub_woitem';
   	    if (l_debug =1 ) then
   	       trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
   	    end if;
   	    -- ### Open Cursor c_act_wzone_wsub_woitem to look for "active operation" plans.
   	    open  c_act_wzone_wsub_woitem;
   	    fetch c_act_wzone_wsub_woitem
   	    into  l_subinventory_code, l_locator_id, l_zone_id;

   	    if c_act_wzone_wsub_woitem%NOTFOUND then
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' "c_act_wzone_wsub_woitem" failed with %NOTFOUND...', 1);
   	          trace(l_proc || ' Setting OUT variables to null...', 1);
   	          trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
   	       end if;
   	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_act_wzone_wsub_woitem;
	       l_cursor := null;

   	       -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
   	       -- ### Opening cursor c_comp_wzone_wsub_woitem to look for completed operations.
   	       -- ### Setting Cursor Name
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
   	       end if;

   	       --  ### Check for Material grouping rule when opening the completed operations cursor.
   	       if l_loc_mtrl_grp_rule_id = 2 then
   	          l_cursor := 'c_comp_wzonesub_woitem_destsub';
     	          -- ### Open Cursor c_comp_wzone_wsub_woitem to look for "completed operation" plans.
   	          open  c_comp_wzonesub_woitem_destsub;
   	          fetch c_comp_wzonesub_woitem_destsub
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzonesub_woitem_destsub%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzonesub_woitem_destsub" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzonesub_woitem_destsub;
		     l_cursor := null;
		  elsif c_comp_wzonesub_woitem_destsub%FOUND then
	             -- c_comp_wzonesub_woitem_destsub cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzonesub_woitem_destsub" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzonesub_woitem_destsub;
	             l_cur_found := true;
		  end if; -- @@@ Marker:   c_comp_wzonesub_woitem_destsub FOUND/NOTFOUND
	       elsif l_loc_mtrl_grp_rule_id <> 2 then -- Check for material grouping rule while opening Completed cursors......
   	          l_cursor := 'c_comp_wzone_wsub_woitem';
     	          -- ### Open Cursor c_comp_wzone_wsub_woitem to look for "completed operation" plans.
   	          open  c_comp_wzone_wsub_woitem;
   	          fetch c_comp_wzone_wsub_woitem
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzone_wsub_woitem%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzone_wsub_woitem" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzone_wsub_woitem;
		     l_cursor := null;
		  elsif c_comp_wzone_wsub_woitem%FOUND then
	             -- c_comp_wzone_wsub_woitem cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzone_wsub_woitem" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzone_wsub_woitem;
	             l_cur_found := true;
		  end if; -- @@@ Marker:   c_comp_wzone_wsub_woitem FOUND/NOTFOUND
	       end if;  -- @@@ Check for material grouping rule while opening Completed cursors......

      	       if (l_debug =1 ) then
		  trace(l_proc || ' Both main cursors failed to return any values...', 1);
		  trace(l_proc || ' Plan "B": Opening Auxillary Cursors to find a location ID ', 4);
	       end if;
            elsif c_act_wzone_wsub_woitem%FOUND then
	      -- c_act_wzone_wsub_woitem cursor found.
	      if (l_debug = 1) then
	         trace(l_proc || ' "c_act_wzone_wsub_woitem" FOUND...', 1);
	         trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	      end if;
	      close c_act_wzone_wsub_woitem;
	      l_cur_found := true;
            end if; -- 	@@@ Marker: c_act_wzone_wsub_woitem FOUND/NOTFOUND
	 end if; -- @@@ Marker: Check for p_item_id when l_pre_specified_sub_code is not null.
      elsif l_pre_specified_sub_code is null then
         -- @@@ With Zone, Without Subinventory, With Item
   	 if p_item_id is not null then
   	    -- ### Setting Cursor Name.
   	    l_cursor := 'c_act_wzone_only_witem';
   	    if (l_debug =1 ) then
   	       trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
   	    end if;
   	    -- ### Open Cursor c_act_wzone_only_witem to look for "active operation" plans.
   	    open  c_act_wzone_only_witem;
   	    fetch c_act_wzone_only_witem
   	    into  l_subinventory_code, l_locator_id, l_zone_id;

   	    if c_act_wzone_only_witem%NOTFOUND then
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' "c_act_wzone_only_witem" failed with %NOTFOUND...', 1);
   	          trace(l_proc || ' Setting OUT variables to null...', 1);
   	          trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
   	       end if;
   	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_act_wzone_only_witem;
	       l_cursor := null;

   	       -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
   	       -- ### Opening cursor c_comp_wzone_only_witem to look for completed operations.
   	       -- ### Setting Cursor Name
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
   	       end if;

   	       --  ### Check for Material grouping rule when opening the completed operations cursor.
   	       if l_loc_mtrl_grp_rule_id = 2 then
   	          l_cursor := 'c_comp_wzoneonlyitem_destsub';
   	          -- ### Open Cursor c_comp_wzone_only_witem to look for "completed operation" plans.
   	          open  c_comp_wzoneonlyitem_destsub;
   	          fetch c_comp_wzoneonlyitem_destsub
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzoneonlyitem_destsub%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzoneonlyitem_destsub" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzoneonlyitem_destsub;
		     l_cursor := null;
		  elsif  c_comp_wzoneonlyitem_destsub%FOUND then
	             -- c_act_wzone_wsub_woitem cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_act_wzone_wsub_woitem" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzoneonlyitem_destsub;
	             l_cur_found := true;
		  end if; -- @@@ Marker: c_comp_wzoneonlyitem_destsub FOUND/NOTFOUND
	       elsif l_loc_mtrl_grp_rule_id <> 2 then -- Check for material grouping rule while opening Completed cursors......
   	          l_cursor := 'c_comp_wzone_only_witem';
   	          -- ### Open Cursor c_comp_wzone_only_witem to look for "completed operation" plans.
   	          open  c_comp_wzone_only_witem;
   	          fetch c_comp_wzone_only_witem
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzone_only_witem%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzone_only_witem" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzone_only_witem;
		     l_cursor := null;
		  elsif  c_comp_wzone_only_witem%FOUND then
	             -- c_comp_wzone_wsub_woitem cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzone_only_witem" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzone_only_witem;
	             l_cur_found := true;
	          end if;-- @@@ Marker: c_comp_wzone_only_witem FOUND/NOTFOUND
	       end if;  -- @@@ Marker: Check for material grouping rule while opening Completed cursors.....

	       if (l_debug =1 ) then
		  trace(l_proc || ' Both main cursors failed to return any values...', 1);
		  trace(l_proc || ' Plan "B": Opening Auxillary Cursors to find a location ID ', 4);
	       end if;
	    elsif c_act_wzone_only_witem%FOUND then
	         -- ### c_act_wzone_only_witem cursor found.
	         if (l_debug = 1) then
	            trace(l_proc || ' "c_act_wzone_only_witem" FOUND...', 1);
	            trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	         end if;
	         close c_act_wzone_only_witem;
	         l_cur_found := true;
            end if;-- @@@ Marker: c_act_wzone_only_witem FOUND/NOTFOUND
         elsif p_item_id is null then
            -- @@@ With Zone, Without Subinventory, Without Item
   	    -- ### Setting Cursor Name.
   	    l_cursor := 'c_act_wzone_only_woitem';
   	    if (l_debug =1 ) then
   	       trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
   	    end if;
   	    -- ### Open Cursor c_act_wzone_only_woitem to look for "active operation" plans.
   	    open  c_act_wzone_only_woitem;
   	    fetch c_act_wzone_only_woitem
   	    into  l_subinventory_code, l_locator_id, l_zone_id;

   	    if c_act_wzone_only_woitem%NOTFOUND then
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' "c_act_wzone_only_woitem" failed with %NOTFOUND...', 1);
   	          trace(l_proc || ' Setting OUT variables to null...', 1);
   	          trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
   	       end if;
   	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_act_wzone_only_woitem;
	       l_cursor := null;

   	       -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
   	       -- ### Opening cursor c_comp_wzone_only_woitem to look for completed operations.
   	       -- ### Setting Cursor Name
   	       if (l_debug =1 ) then
   	          trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
   	       end if;

   	       --  ### Check for Material grouping rule when opening the completed operations cursor.
   	       if l_loc_mtrl_grp_rule_id = 2 then
   	          l_cursor := 'c_comp_wzoneonlyitem_destsub';
   	          -- ### Open Cursor c_comp_wzoneonlywoitem_destsub to look for "completed operation" plans.
   	          open  c_comp_wzoneonlywoitem_destsub;
   	          fetch c_comp_wzoneonlywoitem_destsub
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzoneonlywoitem_destsub%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzoneonlywoitem_destsub" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzoneonlywoitem_destsub;
		     l_cursor := null;
		     if (l_debug =1 ) then
		        trace(l_proc || ' Both main cursors failed to return any values...', 1);
		        trace(l_proc || ' Plan "B": Opening Auxillary Cursors to find a location ID ', 4);
		     end if;
	          elsif c_comp_wzoneonlywoitem_destsub%FOUND then
	             -- ### c_comp_wzoneonlywoitem_destsub cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzoneonlywoitem_destsub" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzoneonlywoitem_destsub;
	             l_cur_found := true;
                  end if;-- @@@ Marker: c_comp_wzoneonlywoitem_destsub FOUND/NOTFOUND
   	       elsif l_loc_mtrl_grp_rule_id <> 2 then
   	          l_cursor := 'c_comp_wzone_only_witem';
   	          -- ### Open Cursor c_comp_wzone_only_woitem to look for "completed operation" plans.
   	          open  c_comp_wzone_only_woitem;
   	          fetch c_comp_wzone_only_woitem
   	          into  l_subinventory_code, l_locator_id, l_zone_id;

   	          if c_comp_wzone_only_woitem%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wzone_only_woitem" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
        	        trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wzone_only_woitem;
		     l_cursor := null;
		     if (l_debug =1 ) then
		        trace(l_proc || ' Both main cursors failed to return any values...', 1);
		        trace(l_proc || ' Plan "B": Opening Auxillary Cursors to find a location ID ', 4);
		     end if;
	          elsif c_comp_wzone_only_woitem%FOUND then
	             -- ### c_comp_wzone_only_woitem cursor found.
	             if (l_debug = 1) then
	                trace(l_proc || ' "c_comp_wzone_only_woitem" FOUND...', 1);
	                trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;
	             close c_comp_wzone_only_woitem;
	             l_cur_found := true;
                  end if; -- @@@ Marker: c_comp_wzone_only_woitem FOUND/NOTFOUND
               end if;-- @@@ Marker:  Check l_loc_mtrl_grp_rule_id
            elsif c_act_wzone_only_woitem%FOUND then
	       -- ### c_act_wzone_only_woitem cursor found.
	       if (l_debug = 1) then
	          trace(l_proc || ' "c_act_wzone_only_woitem" FOUND...', 1);
	          trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	       end if;
	       close c_act_wzone_only_woitem;
	       l_cur_found := true;
            end if; -- 	@@@ Marker: c_act_wzone_only_woitem  FOUND/NOTFOUND
	 end if;  -- @@@ Marker: Check for p_item_id when l_pre_specified_sub_code is null.
      end if;  -- @@@ Marker: Check for l_pre_specified_sub_code
   elsif l_pre_specified_zone_id is null then
   -- @@@ Zone Not specified, but Subiventory is specified. This is the ATF design wherein either the Zone
   -- @@@ or the Subinventory  needs to be specified when the Operation Plan details are specified for a
   -- @@@ Drop Operation.
      -- @@@ Pending Cursors are being coded within separate if..then..end if enclosures while checking for
      -- @@@ pre-specified sub codes.
      if l_pre_specified_sub_code is not null then

	 IF p_item_id IS NULL THEN
	    -- Added for bug 3393371
	    l_cursor := 'c_subloc_pend_wozone_woitem';
	    if (l_debug =1 ) then
	       trace(l_proc || ' Within "l_pre_specified_zone_id is null" segment....', 1);
	       trace(l_proc || ' Within "l_pre_specified_sub_code is not null" segment....', 1);
	       trace(l_proc || ' Within "p_item_id is null" segment....', 1);
	       trace(l_proc || ' Opening "Pending operations" cursor "' ||l_cursor||'"', 1);
	    end if;

	    open  c_subloc_pend_wozone_woitem;
	    fetch c_subloc_pend_wozone_woitem
	      into  x_subinventory_code, x_locator_id;

	    if c_subloc_pend_wozone_woitem%NOTFOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' "c_subloc_pend_wozone_woitem" failed with %NOTFOUND...', 1);
		  trace(l_proc || ' Setting OUT variables to null...', 1);
		  trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
	       end if;
	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_subloc_pend_wozone_woitem;
	       l_cursor := null;
	     elsif c_subloc_pend_wozone_woitem%FOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' Found sub/loc from pending task within the same LPN.', 1);
		  trace(l_proc || ' x_subinventory_code = '||x_subinventory_code, 1);
		  trace(l_proc || ' x_locator_id = '||x_locator_id, 1);
	       end if;
	       close c_subloc_pend_wozone_woitem;
	       --
	       -- ### Call trace message before exiting...
	       --
	       exit_proc_msg(x_return_status => x_return_status
			     ,  x_msg_count =>  x_msg_count
			     ,  x_msg_data  => x_msg_data
			     ,  x_locator_id  =>  x_locator_id
			     ,  x_zone_id  => x_zone_id
			     ,  x_subinventory_code  =>  x_subinventory_code
			     ,  x_loc_valid  =>   x_loc_valid
			     ,  l_proc  =>  l_proc);
	       return;
	    end if;-- Marker: c_subloc_pend_wozone_woitem FOUND/NOTFOUND

	  ELSE -- IF p_item_id IS NULL THEN
	    l_cursor := 'c_subloc_pend_wozone_witem';
	    if (l_debug =1 ) then
	       trace(l_proc || ' Within "l_pre_specified_zone_id is null" segment....', 1);
	       trace(l_proc || ' Within "l_pre_specified_sub_code is not null" segment....', 1);
	       trace(l_proc || ' Opening "Pending operations" cursor "' ||l_cursor||'"', 1);
	    end if;

	    open  c_subloc_pend_wozone_witem;
	    fetch c_subloc_pend_wozone_witem
	      into  x_subinventory_code, x_locator_id;

	    if c_subloc_pend_wozone_witem%NOTFOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' "c_subloc_pend_wozone_witem" failed with %NOTFOUND...', 1);
		  trace(l_proc || ' Setting OUT variables to null...', 1);
		  trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
	       end if;
	       x_locator_id := null;
	       x_zone_id    := null;
	       x_subinventory_code := null;
	       close c_subloc_pend_wozone_witem;
	       l_cursor := null;
	     elsif c_subloc_pend_wozone_witem%FOUND then
	       if (l_debug =1 ) then
		  trace(l_proc || ' Found sub/loc from pending task within the same LPN.', 1);
		  trace(l_proc || ' x_subinventory_code = '||x_subinventory_code, 1);
		  trace(l_proc || ' x_locator_id = '||x_locator_id, 1);
	       end if;
	       close c_subloc_pend_wozone_witem;
	       --
	       -- ### Call trace message before exiting...
	       --
	       exit_proc_msg(x_return_status => x_return_status
			     ,  x_msg_count =>  x_msg_count
			     ,  x_msg_data  => x_msg_data
			     ,  x_locator_id  =>  x_locator_id
			     ,  x_zone_id  => x_zone_id
			     ,  x_subinventory_code  =>  x_subinventory_code
			     ,  x_loc_valid  =>   x_loc_valid
			     ,  l_proc  =>  l_proc);
	       return;
	    end if;-- Marker: c_subloc_pend_wozone_witem FOUND/NOTFOUND
	 END IF; -- IF p_item_id IS NULL THEN

      end if;-- Marker: Check l_pre_specified_sub_code

        -- @@@ Without Zone, With Subinventory, With Item
   	if p_item_id is not null then
   	   -- ### Setting Cursor Name.
   	   l_cursor := 'c_act_wozone_witem';
   	   if (l_debug =1 ) then
   	      trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
   	   end if;
   	   -- ### Open Cursor c_act_wozone_witem to look for "active operation" plans.
   	   open  c_act_wozone_witem;
   	   fetch c_act_wozone_witem
   	   into  l_subinventory_code, l_locator_id;

   	   if c_act_wozone_witem%NOTFOUND then
   	      if (l_debug =1 ) then
   	         trace(l_proc || ' "c_act_wozone_witem" failed with %NOTFOUND...', 1);
   	         trace(l_proc || ' Setting OUT variables to null...', 1);
   	         trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
   	      end if;
   	      x_locator_id := null;
	      x_zone_id    := null;
	      x_subinventory_code := null;
	      close c_act_wozone_witem;
	      l_cursor := null;

   	      -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
   	      -- ### Opening cursor c_comp_wozone_witem to look for completed operations.
   	      -- ### Setting Cursor Name
   	      if (l_debug =1 ) then
   	         trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
   	      end if;

   	      --  ### Check for Material grouping rule when opening the completed operations cursor.
   	      if l_loc_mtrl_grp_rule_id = 2 then
   	          l_cursor := 'c_comp_wozone_witem_destsub';
   	          -- ### Open Cursor c_comp_wozone_witem to look for "completed operation" plans.
   	          open  c_comp_wozone_witem_destsub;
   	          fetch c_comp_wozone_witem_destsub
   	          into  l_subinventory_code, l_locator_id;

   	          if c_comp_wozone_witem_destsub%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wozone_witem_destsub" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
      	                trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wozone_witem_destsub;
		     l_cursor := null;
	          elsif c_comp_wozone_witem_destsub%FOUND then
	              -- ### c_comp_wozone_witem_destsub cursor found.
	              if (l_debug = 1) then
	                  trace(l_proc || ' "c_comp_wozone_witem_destsub" FOUND...', 1);
	                  trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	              end if;
	              close c_comp_wozone_witem_destsub;
	              l_cur_found := true;
	          end if;-- @@@ Marker: c_comp_wozone_witem_destsub FOUND/NOTFOUND
	      elsif l_loc_mtrl_grp_rule_id <> 2 then
   	          l_cursor := 'c_comp_wozone_witem';
   	          -- ### Open Cursor c_comp_wozone_witem to look for "completed operation" plans.
   	          open  c_comp_wozone_witem;
   	          fetch c_comp_wozone_witem
   	          into  l_subinventory_code, l_locator_id;

   	          if c_comp_wozone_witem%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wozone_witem" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
      	                trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wozone_witem;
		     l_cursor := null;
	          elsif c_comp_wozone_witem%FOUND then
	             -- ### c_comp_wozone_witem cursor found.
	             if (l_debug = 1) then
	                 trace(l_proc || ' "c_comp_wozone_witem" FOUND...', 1);
	                 trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	             end if;-- @@@ Marker: c_comp_wozone_witem FOUND/NOTFOUND
	             close c_comp_wozone_witem;
	             l_cur_found := true;
	          end if;-- @@@ Marker: c_comp_wozone_witem  FOUND/NOTFOUND
              end if;-- @@@ Marker: Check l_loc_mtrl_grp_rule_id

              if (l_debug =1 ) then
		 trace(l_proc || ' Both main cursors failed to return any values...', 1);
		 trace(l_proc || ' Plan "B": Opening Auxillary Cursors to find a location ID ', 4);
	      end if;
           elsif c_act_wozone_witem%FOUND then
	      -- c_act_wozone_witem cursor found.
	      if (l_debug = 1) then
	         trace(l_proc || ' "c_act_wozone_witem" FOUND...', 1);
	         trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	      end if;
	      close c_act_wozone_witem;
	      l_cur_found := true;
           end if;-- @@@ Marker: c_act_wozone_witem FOUND/NOTFOUND
      elsif p_item_id is null then
           -- @@@ Without Zone, With Subinventory, Without Item
   	   -- ### Setting Cursor Name.
   	   l_cursor := 'c_act_wozone_woitem';
   	   if (l_debug =1 ) then
   	      trace(l_proc || ' Opening "active operations" cursor "' ||l_cursor||'"', 1);
   	   end if;
   	   -- ### Open Cursor c_act_wozone_woitem to look for "active operation" plans.
   	   open  c_act_wozone_woitem;
   	   fetch c_act_wozone_woitem
   	   into  l_subinventory_code, l_locator_id;

   	   if c_act_wozone_woitem%NOTFOUND then
   	      if (l_debug =1 ) then
   	         trace(l_proc || ' "c_act_wozone_woitem" failed with %NOTFOUND...', 1);
   	         trace(l_proc || ' Setting OUT variables to null...', 1);
   	         trace(l_proc || ' Closing "active operations" cursor "' ||l_cursor||'"', 1);
   	      end if;
   	      x_locator_id := null;
	      x_zone_id    := null;
	      x_subinventory_code := null;
	      close c_act_wozone_woitem;
	      l_cursor := null;

   	      -- ### "active operations" cursor did not return any records, open the "completed operations" cursor
   	      -- ### Opening cursor c_comp_wozone_woitem_destsub to look for completed operations.
   	      -- ### Setting Cursor Name
   	      if (l_debug =1 ) then
   	         trace(l_proc || ' Opening "completed operations" cursor "' ||l_cursor||'"', 1);
   	      end if;

   	      --  ### Check for Material grouping rule when opening the completed operations cursor.
   	      if l_loc_mtrl_grp_rule_id = 2 then
   	          l_cursor := 'c_comp_wozone_woitem_destsub';
   	          -- ### Open Cursor c_comp_wozone_witem to look for "completed operation" plans.
   	          open  c_comp_wozone_woitem_destsub;
   	          fetch c_comp_wozone_woitem_destsub
   	          into  l_subinventory_code, l_locator_id;

   	          if c_comp_wozone_woitem_destsub%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wozone_woitem_destsub" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
      	                trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wozone_woitem_destsub;
		     l_cursor := null;
	          elsif c_comp_wozone_woitem_destsub%FOUND then
	              -- ### c_comp_wozone_woitem_destsub cursor found.
	              if (l_debug = 1) then
	                  trace(l_proc || ' "c_comp_wozone_woitem_destsub" FOUND...', 1);
	                  trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	              end if;
		     close c_comp_wozone_woitem_destsub;
		     l_cursor := null;
                  end if;-- @@@ Marker: c_comp_wozone_woitem_destsub FOUND/NOTFOUND
	      elsif l_loc_mtrl_grp_rule_id <> 2 then
   	          l_cursor := 'c_comp_wozone_woitem';
   	          -- ### Open Cursor c_comp_wozone_woitem to look for "completed operation" plans.
   	          open  c_comp_wozone_woitem;
   	          fetch c_comp_wozone_woitem
   	          into  l_subinventory_code, l_locator_id;

   	          if c_comp_wozone_woitem%NOTFOUND then
   		     if (l_debug = 1) then
   		        trace(l_proc || ' "c_comp_wozone_woitem" failed with %NOTFOUND...', 1);
   		        trace(l_proc || ' Setting OUT variables to null...', 1);
      	                trace(l_proc || ' Closing "completed operations" cursor "' ||l_cursor||'"', 1);
   		     end if;
   		     x_locator_id := null;
		     x_zone_id    := null;
		     x_subinventory_code := null;
		     close c_comp_wozone_woitem;
		     l_cursor := null;
	          elsif c_comp_wozone_woitem%FOUND then
	              -- ### c_comp_wozone_woitem cursor found.
	              if (l_debug = 1) then
	                  trace(l_proc || ' "c_comp_wozone_woitem" FOUND...', 1);
	                  trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	              end if;-- @@@ Marker:
	              close c_comp_wozone_woitem;
	              l_cur_found := true;
	          end if;-- @@@ Marker:  c_comp_wozone_woitem FOUND/NOTFOUND
              end if;-- @@@ Marker:  Check l_loc_mtrl_grp_rule_id
           elsif c_act_wozone_woitem%FOUND then
	     -- c_act_wozone_woitem cursor found.
	     if (l_debug = 1) then
	        trace(l_proc || ' "c_act_wozone_woitem" FOUND...', 1);
	        trace(l_proc || ' Closing cursor "' ||l_cursor||'"', 1);
	     end if;
	     close c_act_wozone_woitem;
	     l_cur_found := true;
           end if; -- 	@@@ Marker:  c_act_wozone_woitem FOUND/NOTFOUND
	end if;  -- @@@ Marker: Check for p_item_id when l_pre_specified_sub_code is null.
   end if;    -- @@@ Marker: Check for l_pre_specified_zone_id.


   -- ### Now that a valid loc/sub/zone was not found using both the main cursors. Checking out the with the auxillary
   -- ### cursors. l_cur_found is initially set to 'false' and set to 'true' when any of the cursors return a location,
   -- ### sub and zone. Hence checking the 'not' so that this part of the code will be traversed only if a location was
   -- ### not returned by the acive or completed cursors.
   if (l_debug =1 ) then
      trace(l_proc || ' Commencing Plan "B"', 1);
      trace(l_proc || ' Opening Auxillary cursors to derive based on prespecified Zone and/or Sub, if available..', 1);
   end if;

   if not l_cur_found then
      if l_pre_specified_zone_id is not null then
         if l_pre_specified_sub_code is not null then
            -- @@@ With Zone, With Subinventory
            l_cursor := 'c_aux_wzone_wsub';
            if (l_debug =1 ) then
               trace(l_proc || ' Opening "c_aux_wzone_wsub" cursor "' ||l_cursor||'"', 1);
            end if;

            -- ### Open Cursor c_aux_wzone_wsub to look for "active operation" plans.
            open  c_aux_wzone_wsub;
            fetch c_aux_wzone_wsub
            into  l_locator_id, l_subinventory_code, l_zone_id;

            if c_aux_wzone_wsub%NOTFOUND then
               if (l_debug = 1) then
                  trace(l_proc || ' "c_aux_wzone_wsub" failed with %NOTFOUND...', 1);
                  trace(l_proc || ' Setting OUT variables to null...', 1);
                  trace(l_proc || ' Closing Auxillary cursor "' ||l_cursor||'"', 1);
               end if;
               x_locator_id := null;
               x_zone_id    := null;
               x_subinventory_code := null;
               close c_aux_wzone_wsub;
               l_cursor := null;
	    elsif c_aux_wzone_wsub%FOUND then
	       -- ### c_aux_wzone_wsub cursor found.
	       if (l_debug = 1) then
	          trace(l_proc || ' "c_aux_wzone_wsub" FOUND...', 1);
	          trace(l_proc || ' Closing Auxillary cursor "' ||l_cursor||'"', 1);
	       end if;
	       close c_aux_wzone_wsub;
	       l_cur_found := true;
	    end if;-- @@@ Marker: c_aux_wzone_wsub FOUND/NOTFOUND
         elsif l_pre_specified_sub_code is null then
            -- @@@ With Zone Only
            l_cursor := 'c_aux_wzone_only';
            if (l_debug =1 ) then
               trace(l_proc || ' Opening "c_aux_wzone_only" cursor "' ||l_cursor||'"', 1);
            end if;

            -- ### Open Cursor c_aux_wzone_only to look for "active operation" plans.
            open  c_aux_wzone_only;
            fetch c_aux_wzone_only
            into  l_locator_id, l_subinventory_code, l_zone_id;

            if c_aux_wzone_only%NOTFOUND then
               if (l_debug = 1) then
                  trace(l_proc || ' "c_aux_wzone_only" failed with %NOTFOUND...', 1);
                  trace(l_proc || ' Setting OUT variables to null...', 1);
                  trace(l_proc || ' Closing Auxillary cursor "' ||l_cursor||'"', 1);
               end if;
               x_locator_id := null;
               x_zone_id    := null;
               x_subinventory_code := null;
               close c_aux_wzone_only;
               l_cursor := null;
	    elsif c_aux_wzone_only%FOUND then
	       -- ### c_aux_wzone_only cursor found.
	       if (l_debug = 1) then
	          trace(l_proc || ' "c_aux_wzone_only" FOUND...', 1);
	          trace(l_proc || ' Closing Auxillary cursor "' ||l_cursor||'"', 1);
	       end if;
	       close c_aux_wzone_only;
	       l_cur_found := true;
	    end if;-- @@@ Marker: c_aux_wzone_only FOUND/NOTFOUND
         end if; -- @@@ Marker: Check l_pre_specified_sub_code
      elsif l_pre_specified_zone_id is null then
            if l_pre_specified_sub_code is not null then
               -- @@@ With Subinventory Only
               l_cursor := 'c_aux_wsub_only';
               if (l_debug =1 ) then
                  trace(l_proc || ' Opening "c_aux_wsub_only" cursor "' ||l_cursor||'"', 1);
               end if;

               -- ### Open Cursor c_aux_wsub_only to look for "active operation" plans.
               open  c_aux_wsub_only;
               fetch c_aux_wsub_only
               into  l_locator_id, l_subinventory_code;

               if c_aux_wsub_only%NOTFOUND then
                  if (l_debug = 1) then
                     trace(l_proc || ' "c_aux_wsub_only" failed with %NOTFOUND...', 1);
                     trace(l_proc || ' Setting OUT variables to null...', 1);
                     trace(l_proc || ' Closing Auxillary cursor "' ||l_cursor||'"', 1);
                  end if;
                  x_locator_id := null;
                  x_zone_id    := null;
                  x_subinventory_code := null;
                  close c_aux_wsub_only;
                  l_cursor := null;
	       elsif c_aux_wsub_only%FOUND then
	          -- ### c_aux_wsub_only cursor found.
	          if (l_debug = 1) then
	             trace(l_proc || ' "c_aux_wsub_only" FOUND...', 1);
	             trace(l_proc || ' Closing Auxillary cursor "' ||l_cursor||'"', 1);
	          end if;
	          close c_aux_wsub_only;
	          l_cur_found := true;
	       end if;-- @@@ Marker: c_aux_wsub_only FOUND/NOTFOUND
            end if;-- @@@ Marker: Check l_pre_specified_zone_id
      end if;-- @@@ Marker: Check l_pre_specified_zone_id
   end if;-- @@@ Marker: not l_cur_found


   -- ### Common code to set out values if either the "active" or "complete" "with Zone cursor is FOUND.
   -- ### This is achieved by setting the value of the boolean "l_cur_found_wzone" appropriately.
   -- ### "l_cur_found_wzone" is set to true if either the "c_subloczone_act_wzone" or "c_subloczone_comp_wzone"
   -- ### cursors are found.
   if l_cur_found then
      if (l_debug =1 ) then
         trace(l_proc || 'Within "if l_cur_found_wzone " is entered...', 1);
         trace(l_proc || l_cursor || ' FOUND...', 1);
         trace(l_proc || ' Subinventory Code returned by cursor ' || l_cursor || ' => ' || l_subinventory_code, 4);
         trace(l_proc || ' Location ID returned by cursor ' || l_cursor || ' => ' || l_locator_id, 4);
         trace(l_proc || ' Zone ID returned by cursor ' || l_cursor || ' => ' || nvl(l_zone_id, -99), 4);
      end if;

      -- ### 'W' means Warning. Though the locator may belong to the prespecified sub and zone, it may not be the
      -- ### optimal location since it was not returned by neither the active nor the completed plan cursors.
      -- ### DLD says 'Locator could not be validated, but it is in the same zone/sub'.
      -- ### 'E' means Error. Locator does not belong to the prespecified sub and zone and hence return a status
      -- ### of 'Error'.
      if (p_mode = 2 and l_cursor not in ('c_aux_wsub_only', 'c_aux_wzone_only', 'c_aux_wzone_wsub')) then
         x_loc_valid := 'Y';
      elsif l_cursor in ('c_aux_wsub_only', 'c_aux_wzone_only', 'c_aux_wzone_wsub') then
         x_loc_valid := 'W';
      end if;

      x_locator_id := l_locator_id;
      x_zone_id    := l_zone_id;
      x_subinventory_code := l_subinventory_code;
      --
      -- ### Call trace message before exiting...
      --
      exit_proc_msg(
         x_return_status  => x_return_status
      ,  x_msg_count =>  x_msg_count
      ,  x_msg_data  => x_msg_data
      ,  x_locator_id  =>  x_locator_id
      ,  x_zone_id  => x_zone_id
      ,  x_subinventory_code  =>  x_subinventory_code
      ,  x_loc_valid  =>   x_loc_valid
      ,  l_proc  =>  l_proc);
      l_cursor := null;
      return;
   else
      -- @@@ Fix for bug 3583898. At this point, none of the cursors are found and hence the l_cur_found is not true.
      -- @@@
      if (l_debug =1 ) then
         trace(l_proc || 'l_cursor is => '|| nvl(l_cursor, '@@@@'), 1);
      end if;

      if (p_mode = 2 and l_cursor is null) then
         x_loc_valid := 'E';
      end if;
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
      end if;

      if (l_prog = 11) then
         if (l_debug = 1) then
            trace(' Material Grouping Rule not stamped on the Operation Plan Detail line.');
            trace(' Unable to proceed. Aborting execution...');
         end if;
      end if;

      if c_oper_plan_details%isopen then close c_oper_plan_details; end if;
      if c_subloc_pend_wozone_woitem%isopen then close c_subloc_pend_wozone_woitem; end if;
      if c_subloc_pend_wzn_wosub_woitem%isopen then close c_subloc_pend_wzn_wosub_woitem; end if;
      if c_subloc_pend_wzn_wsub_woitem%isopen then close c_subloc_pend_wzn_wsub_woitem; end if;
      if c_subloc_pend_wozone_witem%isopen then close c_subloc_pend_wozone_witem; end if;
      if c_subloc_pend_wzn_wosub_witem%isopen then close c_subloc_pend_wzn_wosub_witem; end if;
      if c_subloc_pend_wzn_wsub_witem%isopen then close c_subloc_pend_wzn_wsub_witem; end if;

      if c_act_wzone_wsub_witem%ISOPEN then close c_act_wzone_wsub_witem; end if;
      if c_act_wzone_wsub_woitem%isopen then close c_act_wzone_wsub_woitem; end if;
      if c_act_wzone_only_witem%isopen then close c_act_wzone_only_witem; end if;
      if c_act_wzone_only_woitem%isopen then close c_act_wzone_only_woitem; end if;
      if c_act_wozone_witem%isopen then close c_act_wozone_witem; end if;
      if c_act_wozone_woitem%isopen then close c_act_wozone_woitem; end if;

      if c_comp_wzone_wsub_witem%ISOPEN then close c_comp_wzone_wsub_witem; end if;
      if c_comp_wzone_wsub_woitem%isopen then close c_comp_wzone_wsub_woitem; end if;
      if c_comp_wzone_only_witem%isopen then close c_comp_wzone_only_witem; end if;
      if c_comp_wzone_only_woitem%isopen then close c_comp_wzone_only_woitem; end if;
      if c_comp_wozone_witem%isopen then close c_comp_wozone_witem; end if;
      if c_comp_wozone_woitem%isopen then close c_comp_wozone_woitem; end if;

      if c_comp_wzonesubitem_destsub%ISOPEN then close c_comp_wzonesubitem_destsub; end if;
      if c_comp_wzonesub_woitem_destsub%isopen then close c_comp_wzonesub_woitem_destsub; end if;
      if c_comp_wzoneonlyitem_destsub%isopen then close c_comp_wzoneonlyitem_destsub; end if;
      if c_comp_wzoneonlywoitem_destsub%isopen then close c_comp_wzoneonlywoitem_destsub; end if;
      if c_comp_wozone_witem_destsub%isopen then close c_comp_wozone_witem_destsub; end if;
      if c_comp_wozone_woitem_destsub%isopen then close c_comp_wozone_woitem_destsub; end if;

      --
      --### Call trace message before exiting...
      --
      exit_proc_msg(
         x_return_status => x_return_status
      ,  x_msg_count =>  x_msg_count
      ,  x_msg_data  => x_msg_data
      ,  x_locator_id  =>  x_locator_id
      ,  x_zone_id  => x_zone_id
      ,  x_subinventory_code  =>  x_subinventory_code
      ,  x_loc_valid  =>   x_loc_valid
      ,  l_proc  =>  l_proc);

   when others  then
      x_return_status  := fnd_api.g_ret_sts_error;
      if (l_debug = 1) then
         trace(' Progress at the time of failure is ' || l_prog, 1);
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;

      if c_oper_plan_details%isopen then close c_oper_plan_details; end if;
      if c_subloc_pend_wozone_woitem%isopen then close c_subloc_pend_wozone_woitem; end if;
      if c_subloc_pend_wzn_wosub_woitem%isopen then close c_subloc_pend_wzn_wosub_woitem; end if;
      if c_subloc_pend_wzn_wsub_woitem%isopen then close c_subloc_pend_wzn_wsub_woitem; end if;
      if c_subloc_pend_wozone_witem%isopen then close c_subloc_pend_wozone_witem; end if;
      if c_subloc_pend_wzn_wosub_witem%isopen then close c_subloc_pend_wzn_wosub_witem; end if;
      if c_subloc_pend_wzn_wsub_witem%isopen then close c_subloc_pend_wzn_wsub_witem; end if;

      if c_act_wzone_wsub_witem%isopen then close c_act_wzone_wsub_witem; end if;
      if c_act_wzone_wsub_woitem%isopen then close c_act_wzone_wsub_woitem; end if;
      if c_act_wzone_only_witem%isopen then close c_act_wzone_only_witem; end if;
      if c_act_wzone_only_woitem%isopen then close c_act_wzone_only_woitem; end if;
      if c_act_wozone_witem%isopen then close c_act_wozone_witem; end if;
      if c_act_wozone_woitem%isopen then close c_act_wozone_woitem; end if;

      if c_comp_wzone_wsub_witem%isopen then close c_comp_wzone_wsub_witem; end if;
      if c_comp_wzone_wsub_woitem%isopen then close c_comp_wzone_wsub_woitem; end if;
      if c_comp_wzone_only_witem%isopen then close c_comp_wzone_only_witem; end if;
      if c_comp_wzone_only_woitem%isopen then close c_comp_wzone_only_woitem; end if;
      if c_comp_wozone_witem%isopen then close c_comp_wozone_witem; end if;
      if c_comp_wozone_woitem%isopen then close c_comp_wozone_woitem; end if;

      if c_comp_wzonesubitem_destsub%isopen then close c_comp_wzonesubitem_destsub; end if;
      if c_comp_wzonesub_woitem_destsub%isopen then close c_comp_wzonesub_woitem_destsub; end if;
      if c_comp_wzoneonlyitem_destsub%isopen then close c_comp_wzoneonlyitem_destsub; end if;
      if c_comp_wzoneonlywoitem_destsub%isopen then close c_comp_wzoneonlywoitem_destsub; end if;
      if c_comp_wozone_witem_destsub%isopen then close c_comp_wozone_witem_destsub; end if;
      if c_comp_wozone_woitem_destsub%isopen then close c_comp_wozone_woitem_destsub; end if;

      --
      --### Call trace message before exiting...
      --
      exit_proc_msg(
         x_return_status => x_return_status
      ,  x_msg_count =>  x_msg_count
      ,  x_msg_data  => x_msg_data
      ,  x_locator_id  =>  x_locator_id
      ,  x_zone_id  => x_zone_id
      ,  x_subinventory_code  =>  x_subinventory_code
      ,  x_loc_valid  =>   x_loc_valid
      ,  l_proc  =>  l_proc);

end get_seed_dest_loc;

end wms_atf_dest_loc;

/
