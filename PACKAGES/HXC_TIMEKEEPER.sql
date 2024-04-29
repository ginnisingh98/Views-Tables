--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER" AUTHID CURRENT_USER AS
/* $Header: hxctimekeeper.pkh 120.0 2005/05/29 06:23:38 appldev noship $ */

g_debug		     BOOLEAN := FALSE;

Procedure save_timecard
           (p_blocks            in out nocopy HXC_BLOCK_TABLE_TYPE
           ,p_attributes        in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
           ,p_messages          in out nocopy HXC_MESSAGE_TABLE_TYPE
           ,p_timecard_id          out nocopy hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn         out nocopy hxc_time_building_blocks.object_version_number%type
	   ,p_timekeeper_id     in hxc_time_building_blocks.resource_id%type  DEFAULT NULL
	   ,p_tk_audit_enabled	in VARCHAR2 DEFAULT NULL
 	   ,p_tk_notify_to      in VARCHAR2 DEFAULT NULL
	   ,p_tk_notify_type    in VARCHAR2 DEFAULT NULL
           );


Procedure submit_timecard
            (p_blocks           in out nocopy HXC_BLOCK_TABLE_TYPE
            ,p_attributes       in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages         in out nocopy HXC_MESSAGE_TABLE_TYPE
            ,p_timecard_id        out nocopy hxc_time_building_blocks.time_building_block_id%type
            ,p_timecard_ovn       out nocopy hxc_time_building_blocks.object_version_number%type
 	    ,p_timekeeper_id      in hxc_time_building_blocks.resource_id%type  DEFAULT NULL
	    ,p_tk_audit_enabled	 in VARCHAR2 DEFAULT NULL
 	    ,p_tk_notify_to       in VARCHAR2 DEFAULT NULL
	    ,p_tk_notify_type     in VARCHAR2 DEFAULT NULL
            );

Procedure delete_timecard
	  (p_timecard_id  in out nocopy hxc_time_building_blocks.time_building_block_id%type
          ,p_messages        in out nocopy HXC_MESSAGE_TABLE_TYPE
           );

END HXC_TIMEKEEPER;

 

/
