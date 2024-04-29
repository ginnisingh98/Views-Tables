--------------------------------------------------------
--  DDL for Package HXC_ARRAY_TIME_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ARRAY_TIME_DEPOSIT" AUTHID CURRENT_USER AS
/* $Header: hxctcardp.pkh 115.3 2003/06/13 23:08:44 arundell noship $ */

procedure getExplodedHours
            (p_blocks in out nocopy HXC_BLOCK_TABLE_TYPE
            ,p_attributes in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages in out nocopy HXC_MESSAGE_TABLE_TYPE
            );

procedure deposit_blocks
  (p_timecard_id out nocopy HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_timecard_ovn out nocopy HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  ,p_blocks IN HXC_BLOCK_TABLE_TYPE
  ,p_attributes IN HXC_ATTRIBUTE_TABLE_TYPE
  ,p_item_type in WF_ITEMS.ITEM_TYPE%TYPE
  ,p_process_name in WF_ACTIVITIES.NAME%TYPE
  ,p_mode in varchar2
  ,p_deposit_process in varchar2
  ,p_retrieval_process in varchar2
  ,p_sql_error out nocopy varchar2
  ,p_validate_session in boolean default TRUE
  ,p_add_security in boolean default TRUE
  );

end hxc_array_time_deposit;

 

/
