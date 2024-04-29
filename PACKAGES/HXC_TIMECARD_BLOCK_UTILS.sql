--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_BLOCK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_BLOCK_UTILS" AUTHID CURRENT_USER AS
/* $Header: hxctcbkut.pkh 120.1 2005/08/12 18:41:30 arundell noship $ */

Function any_new_blocks
          (p_blocks in hxc_block_table_type)
          return varchar2;

Procedure initialize_timecard_index;

FUNCTION find_active_timecard_index
          (p_blocks in hxc_block_table_type)
         RETURN number;

FUNCTION convert_to_dpwr_blocks
           (p_blocks in hxc_block_table_type
           ) return hxc_self_service_time_deposit.timecard_info;

Function is_new_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function is_active_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function is_timecard_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function is_day_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function is_existing_block
           (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function is_detail_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function is_parent_block
          (p_block      in HXC_BLOCK_TYPE
          ,p_parent_id  in hxc_time_building_blocks.time_building_block_id%type
          ,p_parent_ovn in hxc_time_building_blocks.object_version_number%type
          ,p_check_id   in boolean
          ) return pls_integer;

Function is_parent_block
          (p_block      in HXC_BLOCK_TYPE
          ,p_parent_id  in hxc_time_building_blocks.time_building_block_id%type
          ,p_parent_ovn in hxc_time_building_blocks.object_version_number%type
          ) return BOOLEAN;

Function is_updated_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN;

Function parent_has_changed
           (p_blocks in HXC_BLOCK_TABLE_TYPE
           ,p_parent_block_id in hxc_time_building_blocks.time_building_block_id%type
           ) return BOOLEAN;

Function process_block
          (p_block in HXC_BLOCK_TYPE
          ) return BOOLEAN;

Function can_process_block
          (p_block in hxc_block_type
          ) return boolean;

Function date_value
          (p_block_value in varchar2
          ) return date;

Function build_block
          (p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
          ) return HXC_BLOCK_TYPE;

Function blocks_are_different
          (p_block1 in HXC_BLOCK_TYPE
          ,p_block2 in HXC_BLOCK_TYPE
          ) return boolean;

Procedure sort_blocks
           (p_blocks          in            HXC_BLOCK_TABLE_TYPE
           ,p_timecard_blocks    out nocopy HXC_TIMECARD.BLOCK_LIST
           ,p_day_blocks         out nocopy HXC_TIMECARD.BLOCK_LIST
           ,p_detail_blocks      out nocopy HXC_TIMECARD.BLOCK_LIST
           );

Function next_block_id
           (p_blocks in HXC_BLOCK_TABLE_TYPE
           ) return number;

END hxc_timecard_block_utils;

 

/
