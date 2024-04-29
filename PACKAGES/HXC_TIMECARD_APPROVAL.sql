--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_APPROVAL" AUTHID CURRENT_USER as
/* $Header: hxctimeapprove.pkh 120.1 2006/08/15 22:13:23 arundell noship $ */
  Function is_timecard_resubmitted
    (p_timecard_id  in hxc_time_building_blocks.time_building_block_id%type,
     p_timecard_ovn in hxc_time_building_blocks.object_version_number%type,
     p_resource_id  in hxc_time_building_blocks.resource_id%type,
     p_start_time   in hxc_time_building_blocks.start_time%type,
     p_stop_time    in hxc_time_building_blocks.stop_time%type
     ) return varchar2;
  -- 115.4 Added timecard properties and messages
  Function begin_approval
    (p_blocks         in            hxc_block_table_type,
     p_item_type      in            wf_items.item_type%type,
     p_process_name   in            wf_process_activities.process_name%type,
     p_resubmitted    in            varchar2,
     p_timecard_props in            hxc_timecard_prop_table_type,
     p_messages       in out nocopy hxc_message_table_type
     ) return VARCHAR2;

end hxc_timecard_approval;

 

/
