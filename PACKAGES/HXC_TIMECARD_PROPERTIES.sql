--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_PROPERTIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_PROPERTIES" AUTHID CURRENT_USER AS
/* $Header: hxctcprops.pkh 120.4 2006/08/28 09:13:26 gkrishna noship $ */

type t_property is record
(property_name varchar2(2000)
,preference_code hxc_pref_definitions.code%type
,property_value hxc_pref_hierarchies.attribute1%type
,date_from date
,date_to date
);

type t_prop_table is
 table of t_property
  index by binary_integer;

procedure get_preference_properties
           (p_validate            in            VARCHAR2
           ,p_resource_id         in            NUMBER
           ,p_timecard_start_time in            VARCHAR2
           ,p_timecard_stop_time  in            VARCHAR2
           ,p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE
           );

procedure get_preference_properties
           (p_validate            in            VARCHAR2,
            p_resource_id         in            NUMBER,
            p_timecard_start_time in            VARCHAR2,
            p_timecard_stop_time  in            VARCHAR2,
            p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE,
            p_messages               out nocopy HXC_MESSAGE_TABLE_TYPE
            );

procedure get_preference_properties
           (p_validate            in            VARCHAR2
           ,p_resource_id         in            NUMBER
           ,p_timecard_start_time in            date
           ,p_timecard_stop_time  in            date
           ,p_for_timecard        in            BOOLEAN
           ,p_messages            in out nocopy hxc_message_table_type
           ,p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE
           );

procedure get_preference_properties
           (p_validate            in            VARCHAR2
           ,p_resource_id         in            NUMBER
           ,p_timecard_start_time in            date
           ,p_timecard_stop_time  in            date
           ,p_for_timecard        in            BOOLEAN
           ,p_timecard_bb_id      in            hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_bb_ovn     in            hxc_time_building_blocks.object_version_number%type
           ,p_messages            in out nocopy hxc_message_table_type
           ,p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE
           );


Function find_property_value
           (p_props      in HXC_TIMECARD_PROP_TABLE_TYPE
           ,p_name       in varchar2
           ,p_code       in varchar2
           ,p_segment    in number
           ,p_start_date in date
           ,p_stop_date  in date
           ) return varchar2;

Function find_property_value
          (p_props   in HXC_TIMECARD_PROP_TABLE_TYPE
          ,p_name    in varchar2
          ,p_code    in hxc_pref_hierarchies.code%type
          ,p_segment in number
          ,p_date    in date
          ) return varchar2;

Function setup_mo_global_params
( p_resource_id in number) return Number;

END hxc_timecard_properties;

 

/
