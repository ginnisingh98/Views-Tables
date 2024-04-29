--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_ATTRIBUTE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_ATTRIBUTE_UTILS" AUTHID CURRENT_USER AS
/* $Header: hxctcatut.pkh 115.3 2004/01/02 16:30:10 arundell noship $ */

Function next_time_attribute_id
           (p_attributes in hxc_attribute_table_type)
           return number;

FUNCTION get_bld_blk_info_type_id
          (p_info_type in varchar2)
         RETURN number;

Function convert_to_dpwr_attributes
          (p_attributes in HXC_ATTRIBUTE_TABLE_TYPE)
          return HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info;

Function convert_to_type
          (p_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info)
          return HXC_ATTRIBUTE_TABLE_TYPE;

Function is_new_attribute
          (p_attribute in HXC_ATTRIBUTE_TYPE)
           return BOOLEAN;

Function is_new_attribute2
          (p_attribute in HXC_ATTRIBUTE_TYPE)
           return BOOLEAN;

Function is_corresponding_block
          (p_attribute in HXC_ATTRIBUTE_TYPE
          ,p_block_id  in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ) RETURN BOOLEAN;

Function is_corresponding_block
          (p_attribute in HXC_ATTRIBUTE_TYPE
          ,p_block     in HXC_BLOCK_TYPE
          ) RETURN BOOLEAN;

Function is_system_context
          (p_attribute in HXC_ATTRIBUTE_TYPE)
          RETURN BOOLEAN;

Function process_attribute
          (p_attribute in hxc_attribute_type
          ) return BOOLEAN;

Function build_attribute
          (p_time_attribute_id in HXC_TIME_ATTRIBUTES.TIME_ATTRIBUTE_ID%TYPE
          ,p_object_version_number in HXC_TIME_ATTRIBUTES.OBJECT_VERSION_NUMBER%TYPE
          ,p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
          ) return HXC_ATTRIBUTE_TYPE;

Function attributes_are_different
           (p_attribute1 in HXC_ATTRIBUTE_TYPE
           ,p_attribute2 in HXC_ATTRIBUTE_TYPE
           ) return BOOLEAN;

Function get_attribute_index
          (p_attributes        in hxc_attribute_table_type
          ,p_context           in hxc_time_attributes.attribute_category%type
          ,p_building_block_id in hxc_time_building_blocks.time_building_block_id%type default null
          ) return NUMBER;

Procedure set_bld_blk_info_type_id
           (p_attributes in out nocopy hxc_attribute_table_type);

Procedure append_additional_reasons
            (p_deposit_attributes in out nocopy hxc_attribute_table_type
            ,p_attributes in                    hxc_attribute_table_type);

Procedure remove_deleted_attributes
            (p_attributes in out nocopy hxc_attribute_table_type);

END hxc_timecard_attribute_utils;

 

/
