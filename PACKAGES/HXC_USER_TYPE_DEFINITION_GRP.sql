--------------------------------------------------------
--  DDL for Package HXC_USER_TYPE_DEFINITION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_USER_TYPE_DEFINITION_GRP" AUTHID CURRENT_USER AS
/* $Header: hxcusertypedef.pkh 120.1 2005/12/05 14:19:00 arundell noship $ */

   --
   -- TIMECARD
   --
   TYPE building_block_info IS RECORD (
      time_building_block_id        hxc_time_building_blocks.time_building_block_id%TYPE,
      TYPE                          hxc_time_building_blocks.TYPE%TYPE,
      measure                       hxc_time_building_blocks.measure%TYPE,
      unit_of_measure               hxc_time_building_blocks.unit_of_measure%TYPE,
      start_time                    hxc_time_building_blocks.start_time%TYPE,
      stop_time                     hxc_time_building_blocks.stop_time%TYPE,
      parent_building_block_id      hxc_time_building_blocks.parent_building_block_id%TYPE,
      parent_is_new                 VARCHAR2 (1),
      SCOPE                         hxc_time_building_blocks.SCOPE%TYPE,
      object_version_number         hxc_time_building_blocks.object_version_number%TYPE,
      approval_status               hxc_time_building_blocks.approval_status%TYPE,
      resource_id                   hxc_time_building_blocks.resource_id%TYPE,
      resource_type                 hxc_time_building_blocks.resource_type%TYPE,
      approval_style_id             hxc_time_building_blocks.approval_style_id%TYPE,
      date_from                     hxc_time_building_blocks.date_from%TYPE,
      date_to                       hxc_time_building_blocks.date_to%TYPE,
      comment_text                  hxc_time_building_blocks.comment_text%TYPE,
      parent_building_block_ovn     hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      NEW                           VARCHAR2 (30),
      changed                       VARCHAR2 (30),
      process                       VARCHAR2 (30),
      application_set_id            hxc_time_building_blocks.application_set_id%type);

   TYPE timecard_info IS TABLE OF building_block_info
      INDEX BY BINARY_INTEGER;

   --
   -- MESSAGE
   --
   TYPE message_info IS RECORD (
      message_name                  fnd_new_messages.message_name%TYPE,
      message_level                 VARCHAR2 (30),
      message_field                 VARCHAR2(2000),
      message_tokens                VARCHAR2 (240), -- Bug 3036930
      application_short_name        fnd_application.application_short_name%TYPE,
      time_building_block_id        hxc_time_building_blocks.time_building_block_id%TYPE,
      time_building_block_ovn       hxc_time_building_blocks.object_version_number%TYPE,
      time_attribute_id             hxc_time_attributes.time_attribute_id%TYPE,
      time_attribute_ovn            hxc_time_attributes.object_version_number%TYPE,
      on_oa_msg_stack               BOOLEAN := FALSE, --AI5
      message_extent                VARCHAR2 (20)		--Bug#2873563
                       );

   TYPE message_table IS TABLE OF message_info
      INDEX BY BINARY_INTEGER;


   --
   -- APP_ATTRIBUTES
   --
   TYPE app_attributes IS RECORD (
      time_attribute_id             hxc_time_attributes.time_attribute_id%TYPE,
      building_block_id             hxc_time_building_blocks.time_building_block_id%TYPE,
      attribute_name                hxc_mapping_components.field_name%TYPE,
      attribute_value               hxc_time_attributes.attribute1%TYPE,
      attribute_index               number,
      segment                       hxc_mapping_components.segment%type,
      bld_blk_info_type             hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
      CATEGORY                      hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      updated                       VARCHAR2 (30),
      changed                       VARCHAR2 (30),
      process                       VARCHAR2 (30));

   TYPE app_attributes_info IS TABLE OF app_attributes
      INDEX BY BINARY_INTEGER;


   --
   -- ATTRIBUTES
   --
   TYPE attribute_info IS RECORD (
      time_attribute_id             hxc_time_attributes.time_attribute_id%TYPE,
      building_block_id             hxc_time_building_blocks.time_building_block_id%TYPE,
      bld_blk_info_type             hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
      attribute_category            hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
      attribute1                    hxc_time_attributes.attribute1%TYPE,
      attribute2                    hxc_time_attributes.attribute2%TYPE,
      attribute3                    hxc_time_attributes.attribute3%TYPE,
      attribute4                    hxc_time_attributes.attribute4%TYPE,
      attribute5                    hxc_time_attributes.attribute5%TYPE,
      attribute6                    hxc_time_attributes.attribute6%TYPE,
      attribute7                    hxc_time_attributes.attribute7%TYPE,
      attribute8                    hxc_time_attributes.attribute8%TYPE,
      attribute9                    hxc_time_attributes.attribute9%TYPE,
      attribute10                   hxc_time_attributes.attribute10%TYPE,
      attribute11                   hxc_time_attributes.attribute11%TYPE,
      attribute12                   hxc_time_attributes.attribute12%TYPE,
      attribute13                   hxc_time_attributes.attribute13%TYPE,
      attribute14                   hxc_time_attributes.attribute14%TYPE,
      attribute15                   hxc_time_attributes.attribute15%TYPE,
      attribute16                   hxc_time_attributes.attribute16%TYPE,
      attribute17                   hxc_time_attributes.attribute17%TYPE,
      attribute18                   hxc_time_attributes.attribute18%TYPE,
      attribute19                   hxc_time_attributes.attribute19%TYPE,
      attribute20                   hxc_time_attributes.attribute20%TYPE,
      attribute21                   hxc_time_attributes.attribute21%TYPE,
      attribute22                   hxc_time_attributes.attribute22%TYPE,
      attribute23                   hxc_time_attributes.attribute23%TYPE,
      attribute24                   hxc_time_attributes.attribute24%TYPE,
      attribute25                   hxc_time_attributes.attribute25%TYPE,
      attribute26                   hxc_time_attributes.attribute26%TYPE,
      attribute27                   hxc_time_attributes.attribute27%TYPE,
      attribute28                   hxc_time_attributes.attribute28%TYPE,
      attribute29                   hxc_time_attributes.attribute29%TYPE,
      attribute30                   hxc_time_attributes.attribute30%TYPE,
      bld_blk_info_type_id          hxc_time_attributes.bld_blk_info_type_id%TYPE,
      object_version_number         hxc_time_attributes.object_version_number%TYPE,
      NEW                           VARCHAR2 (30),
      changed                       VARCHAR2 (30),
      process                       VARCHAR2 (30));

   TYPE building_block_attribute_info IS TABLE OF attribute_info
      INDEX BY BINARY_INTEGER;

   --
   --
   -- GENERIC RETRIEVAL
   --
   --
   TYPE t_status
      IS TABLE OF hxc_transaction_details.status%TYPE INDEX BY BINARY_INTEGER;
   TYPE t_exception_description
      IS TABLE OF hxc_transaction_details.exception_description%TYPE INDEX BY BINARY_INTEGER;

   TYPE r_building_blocks IS RECORD (
	 bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
 	,type			hxc_time_building_blocks.type%TYPE
	,measure			hxc_time_building_blocks.measure%TYPE
	,start_time		hxc_time_building_blocks.start_time%TYPE
	,stop_time		hxc_time_building_blocks.stop_time%TYPE
	,parent_bb_id 		hxc_time_building_blocks.parent_building_block_id%TYPE
	,scope			hxc_time_building_blocks.scope%TYPE
	,resource_id		hxc_time_building_blocks.resource_id%TYPE
	,resource_type		hxc_time_building_blocks.resource_type%TYPE
	,comment_text		hxc_time_building_blocks.comment_text%TYPE
	,uom			hxc_time_building_blocks.unit_of_measure%TYPE
	,ovn			hxc_time_building_blocks.object_version_number%TYPE
	,changed			VARCHAR2(1)
	,deleted			VARCHAR2(1)
	,timecard_bb_id		hxc_time_building_blocks.time_building_block_id%TYPE
	,timecard_ovn		hxc_time_building_blocks.object_version_number%TYPE );

   TYPE t_building_blocks
      IS TABLE OF r_building_blocks INDEX BY BINARY_INTEGER;

   TYPE r_time_attributes IS RECORD (
 	bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
       ,field_name		hxc_mapping_components.field_name%TYPE
       ,value			hxc_time_attributes.attribute1%TYPE
       ,context			hxc_bld_blk_info_types.bld_blk_info_type%TYPE
       ,category		hxc_bld_blk_info_type_usages.building_block_category%TYPE );

   TYPE t_time_attribute
      IS TABLE OF r_time_attributes INDEX BY BINARY_INTEGER;

   TYPE t_time_building_block_ovn
      IS TABLE OF hxc_transaction_details.time_building_block_ovn%TYPE INDEX BY BINARY_INTEGER;

   TYPE t_time_building_block_id
      IS TABLE OF hxc_transaction_details.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;

   TYPE r_timecard_block IS RECORD (
      start_time          hxc_time_building_blocks.start_time%TYPE
     ,stop_time           hxc_time_building_blocks.stop_time%TYPE
     ,comment_text        hxc_time_building_blocks.comment_text%TYPE );

   TYPE t_timecard_blocks IS TABLE OF r_timecard_block INDEX BY BINARY_INTEGER;

   t_tx_detail_status 		t_status;

   t_tx_detail_exception 	t_exception_description;

   t_detail_bld_blks	        t_building_blocks;
   t_day_bld_blks		t_building_blocks;
   t_old_detail_bld_blks 	t_building_blocks;
   t_old_day_bld_blks 		t_building_blocks;

   t_time_bld_blks 		t_timecard_blocks;

   t_detail_attributes		t_time_attribute;
   t_old_detail_attributes      t_time_attribute;

   t_tx_day_bb_ovn 		t_time_building_block_ovn;
   t_tx_time_bb_ovn 		t_time_building_block_ovn;
   t_tx_day_parent_id 		t_time_building_block_id;
   t_tx_detail_bb_id 		t_time_building_block_id;

   --
   --  TIMECARD
   --
   c_error                CONSTANT VARCHAR2(5) := 'ERROR';
   c_warning              CONSTANT VARCHAR2(7) := 'WARNING';
   c_blk_children_extent  CONSTANT VARCHAR2(16):= 'BLK_AND_CHILDREN';



END HXC_USER_TYPE_DEFINITION_GRP;

 

/
