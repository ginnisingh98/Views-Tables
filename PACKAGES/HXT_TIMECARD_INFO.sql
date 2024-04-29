--------------------------------------------------------
--  DDL for Package HXT_TIMECARD_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIMECARD_INFO" AUTHID CURRENT_USER AS
/* $Header: hxctimotm.pkh 115.8 2004/04/14 16:15:37 mhanda noship $ */

-----------------------------------------------------------------
PROCEDURE Gen_Work_Plan( p_start DATE
                       , p_end DATE
	               , p_tws_id NUMBER
                       , p_app_attributes  IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
                       , p_timecard        IN OUT NOCOPY hxc_self_service_time_deposit.timecard_info
                       );

------------------------------------------------------------------

PROCEDURE Gen_Rot_Plan( p_start DATE
		      , p_end DATE
	 	      , p_rtp_id NUMBER
                      , p_app_attributes  OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
                      , p_timecard        OUT NOCOPY hxc_self_service_time_deposit.timecard_info
                      );
------------------------------------------------------------------
PROCEDURE Get_Work_Day( p_date IN DATE
			          , p_work_id IN NUMBER
		              , p_standard_start OUT NOCOPY NUMBER
			          , p_standard_stop OUT NOCOPY NUMBER
		              , p_hours OUT NOCOPY NUMBER);
------------------------------------------------------------------
/*
TYPE attribute_info is RECORD
(TIME_ATTRIBUTE_ID     hxc_time_attributes.time_attribute_id%TYPE
,BUILDING_BLOCK_ID     hxc_time_building_blocks.time_building_block_id%TYPE
,ATTRIBUTE_CATEGORY    hxc_time_attributes.attribute_category%TYPE
,ATTRIBUTE1            hxc_time_attributes.attribute1%TYPE
,ATTRIBUTE2            hxc_time_attributes.attribute2%TYPE
,ATTRIBUTE3            hxc_time_attributes.attribute3%TYPE
,ATTRIBUTE4            hxc_time_attributes.attribute4%TYPE
,ATTRIBUTE5            hxc_time_attributes.attribute5%TYPE
,ATTRIBUTE6            hxc_time_attributes.attribute6%TYPE
,ATTRIBUTE7            hxc_time_attributes.attribute7%TYPE
,ATTRIBUTE8            hxc_time_attributes.attribute8%TYPE
,ATTRIBUTE9            hxc_time_attributes.attribute9%TYPE
,ATTRIBUTE10           hxc_time_attributes.attribute10%TYPE
,ATTRIBUTE11           hxc_time_attributes.attribute11%TYPE
,ATTRIBUTE12           hxc_time_attributes.attribute12%TYPE
,ATTRIBUTE13           hxc_time_attributes.attribute13%TYPE
,ATTRIBUTE14           hxc_time_attributes.attribute14%TYPE
,ATTRIBUTE15           hxc_time_attributes.attribute15%TYPE
,ATTRIBUTE16           hxc_time_attributes.attribute16%TYPE
,ATTRIBUTE17           hxc_time_attributes.attribute17%TYPE
,ATTRIBUTE18           hxc_time_attributes.attribute18%TYPE
,ATTRIBUTE19           hxc_time_attributes.attribute19%TYPE
,ATTRIBUTE20           hxc_time_attributes.attribute20%TYPE
,ATTRIBUTE21           hxc_time_attributes.attribute21%TYPE
,ATTRIBUTE22           hxc_time_attributes.attribute22%TYPE
,ATTRIBUTE23           hxc_time_attributes.attribute23%TYPE
,ATTRIBUTE24           hxc_time_attributes.attribute24%TYPE
,ATTRIBUTE25           hxc_time_attributes.attribute25%TYPE
,ATTRIBUTE26           hxc_time_attributes.attribute26%TYPE
,ATTRIBUTE27           hxc_time_attributes.attribute27%TYPE
,ATTRIBUTE28           hxc_time_attributes.attribute28%TYPE
,ATTRIBUTE29           hxc_time_attributes.attribute29%TYPE
,ATTRIBUTE30           hxc_time_attributes.attribute30%TYPE
,BLD_BLK_INFO_TYPE_ID  hxc_time_attributes.bld_blk_info_type_id%TYPE
,OBJECT_VERSION_NUMBER hxc_time_attributes.object_version_number%TYPE
,NEW                   VARCHAR2(1)
);

TYPE building_block_attribute_info is TABLE OF
   attribute_info
   INDEX BY binary_integer;

TYPE building_block_info is RECORD
(TIME_BUILDING_BLOCK_ID    hxc_time_building_blocks.time_building_block_id%TYPE
,TYPE                      hxc_time_building_blocks.type%TYPE
,MEASURE                   hxc_time_building_blocks.measure%TYPE
,UNIT_OF_MEASURE           hxc_time_building_blocks.unit_of_measure%TYPE
,START_TIME                hxc_time_building_blocks.start_time%TYPE
,STOP_TIME                 hxc_time_building_blocks.stop_time%TYPE
,PARENT_BUILDING_BLOCK_ID  hxc_time_building_blocks.parent_building_block_id%TYPE
,PARENT_IS_NEW             VARCHAR2(1)
,SCOPE                     hxc_time_building_blocks.scope%TYPE
,OBJECT_VERSION_NUMBER     hxc_time_building_blocks.object_version_number%TYPE
,APPROVAL_STATUS           hxc_time_building_blocks.approval_status%TYPE
,RESOURCE_ID               hxc_time_building_blocks.resource_id%TYPE
,RESOURCE_TYPE             hxc_time_building_blocks.resource_type%TYPE
,APPROVAL_STYLE_ID         hxc_time_building_blocks.approval_style_id%TYPE
,DATE_FROM                 hxc_time_building_blocks.date_from%TYPE
,DATE_TO                   hxc_time_building_blocks.date_to%TYPE
,COMMENT_TEXT              hxc_time_building_blocks.comment_text%TYPE
,PARENT_BUILDING_BLOCK_OVN hxc_time_building_blocks.parent_building_block_ovn%TYPE
,NEW                       VARCHAR2(1)
);

TYPE timecard_info is TABLE OF
   building_block_info
   INDEX BY binary_integer;
*/
p_app_attributes hxc_self_service_time_deposit.app_attributes_info;
p_timecard hxc_self_service_time_deposit.timecard_info;
-------------------------------------------------------------------------------
PROCEDURE Generate_Time(
  p_resource_id     IN NUMBER
 ,p_start_time      IN DATE
 ,p_stop_time       IN DATE
 ,p_app_attributes  OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
 ,p_timecard        OUT NOCOPY hxc_self_service_time_deposit.timecard_info
 ,p_messages        IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
                       );

-------------------------------------------------------------------------------

END hxt_timecard_info;

 

/
