--------------------------------------------------------
--  DDL for Package HXC_INTEGRATION_LAYER_V1_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_INTEGRATION_LAYER_V1_GRP" AUTHID CURRENT_USER AS
/* $Header: hxcintegrationv1.pkh 115.6 2004/06/23 14:03:38 jdupont noship $ */


--
-- HXC_SELF_SERVICE_TIME_DEPOSIT
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_app_hook_params    >----------------------|
-- ----------------------------------------------------------------------------
procedure get_app_hook_params(
                       p_building_blocks IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info
                      ,p_app_attributes  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info
                      ,p_messages        IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table);

-- ----------------------------------------------------------------------------
-- |---------------------------< set_app_hook_params    >----------------------|
-- ----------------------------------------------------------------------------
procedure set_app_hook_params(
                        p_building_blocks IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info
                       ,p_app_attributes  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info
                       ,p_messages        IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table);

--
-- HXC_GENERIC_RETRIEVAL_PKG
--
-- ----------------------------------------------------------------------------
-- |---------------------------< execute_retrieval_process >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE execute_retrieval_process (
	 p_process		in	hxc_retrieval_processes.name%TYPE
	,p_transaction_code 	in	VARCHAR2
	,p_start_date		in	DATE default null
	,p_end_date		in	DATE default null
	,p_incremental		in	VARCHAR2 default 'Y'
	,p_rerun_flag		in	VARCHAR2 default 'N'
	,p_where_clause		in	VARCHAR2
	,p_scope		in	VARCHAR2 default 'DAY'
	,p_clusive		in	VARCHAR2 default 'EX'
	,p_unique_params 	in      VARCHAR2 default null);


-- ----------------------------------------------------------------------------
-- |---------------------------< Update_Transaction_Status >-------------------|
-- ----------------------------------------------------------------------------
Procedure Update_Transaction_Status (
				p_process			hxc_retrieval_processes.name%TYPE
			       ,p_status			hxc_transactions.status%TYPE
			       ,p_exception_description   	hxc_transactions.exception_description%TYPE
			       ,p_rollback 			BOOLEAN DEFAULT FALSE );

--
-- HXC_GENERIC_RETRIEVAL_UTILS
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_parent_statuses >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_parent_statuses;

-- ----------------------------------------------------------------------------
-- |---------------------------< time_bld_blk_changed >------------------------|
-- ----------------------------------------------------------------------------

FUNCTION time_bld_blk_changed ( p_bb_id	 NUMBER
		,		p_bb_ovn NUMBER )RETURN BOOLEAN;


--
-- HXC_TIME_ENTRY_RULES_UTILS_PKG
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_error_to_table >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_error_to_table (
		p_message_table	in out nocopy   HXC_USER_TYPE_DEFINITION_GRP.MESSAGE_TABLE
	,	p_message_name  in     		FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
	,	p_message_token in    		VARCHAR2
	,	p_message_level in     		VARCHAR2
        ,	p_message_field in     		VARCHAR2
	,	p_application_short_name 	IN VARCHAR2 default 'HXC'
	,	p_timecard_bb_id     in     NUMBER
	,	p_time_attribute_id  in     NUMBER
        ,       p_timecard_bb_ovn    in     NUMBER   default null
        ,       p_time_attribute_ovn in     NUMBER   default null
        ,	p_message_extent     in     VARCHAR2 default null);


--
-- HXC_MAPPING_UTILITIES
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_mappingvalue_sum >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_mappingvalue_sum ( p_bld_blk_info_type VARCHAR2
		,	        p_field_name1       VARCHAR2
		,	        p_field_name2       VARCHAR2
		,               p_field_value2      VARCHAR2
		,               p_status            VARCHAR2
                ,               p_resource_id       VARCHAR2
		) RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mapping_exists >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION chk_mapping_exists ( p_bld_blk_info_type VARCHAR2
		,	      p_field_name  VARCHAR2
		,             p_field_value VARCHAR2
		,             p_scope       VARCHAR2
                ,             p_retrieval_process_name VARCHAR2 DEFAULT 'None'
                ,             p_status   VARCHAR2 DEFAULT 'None'
                ,             p_end_date DATE DEFAULT null) RETURN BOOLEAN;


--
-- HXC_DEPOSIT_WRAPPER_UTILITIES
--
-- ----------------------------------------------------------------------------
-- |---------------------------< messages_to_string >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION messages_to_string
           (p_messages IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
           RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |---------------------------< attributes_to_string >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION attributes_to_string(
  p_attributes IN OUT NOCOPY  HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |---------------------------< blocks_to_string >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION blocks_to_string
           (p_blocks IN OUT NOCOPY  HXC_USER_TYPE_DEFINITION_GRP.timecard_info)
           RETURN VARCHAR2;


--
-- HXC_PERIOD_EVALUATION
--
-- ----------------------------------------------------------------------------
-- |---------------------------< period_start_stop >------------------------|
-- ----------------------------------------------------------------------------
procedure period_start_stop(p_current_date 		date,
                            p_rec_period_start_date 	date,
                            l_period_start 		in out nocopy date,
                            l_period_end 		in out nocopy date,
                            l_base_period_type 		varchar2);

--
-- HXC_APPROVAL_WF_PKG
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_wf_G_Time_Building_Blocks >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_wf_g_time_building_blocks
           RETURN HXC_USER_TYPE_DEFINITION_GRP.timecard_info;
-- ----------------------------------------------------------------------------
-- |-----------------< get_wf_G_Time_App_Attributes >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_wf_g_time_app_attributes
           RETURN HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info;


--
--  HXC_TIMECARD_INFO
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_status >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_approval_status
	(p_timecard_id in hxc_timecard_summary.timecard_id%type)
	    RETURN hxc_timecard_summary.approval_status%type;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_status 2>------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_approval_status
	(p_resource_id in hxc_timecard_summary.resource_id%type
 	,p_start_time in hxc_timecard_summary.start_time%type
 	,p_stop_time in hxc_timecard_summary.stop_time%type)
	    RETURN hxc_timecard_summary.approval_status%type;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_submission_date 2>------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_submission_date
	(p_timecard_id in hxc_timecard_summary.timecard_id%type)
	   RETURN hxc_timecard_summary.submission_date%type;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_submission_date 2>------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_submission_date
	(p_resource_id in hxc_timecard_summary.resource_id%type
 	,p_start_time in hxc_timecard_summary.start_time%type
 	,p_stop_time in hxc_timecard_summary.stop_time%type)
	  RETURN hxc_timecard_summary.submission_date%type;


-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_date    >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_approval_date
	(p_timecard_id in hxc_timecard_summary.timecard_id%type)
	  RETURN hxc_timecard_summary.submission_date%type;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_date 2  >------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_timecard_approval_date
	(p_resource_id in hxc_timecard_summary.resource_id%type
 	,p_start_time in hxc_timecard_summary.start_time%type
 	,p_stop_time in hxc_timecard_summary.stop_time%type)
	  RETURN hxc_timecard_summary.submission_date%type;

--
--  Straight Interface
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------< build_block >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION build_block
          (p_time_building_block_id  IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
          ) RETURN HXC_USER_TYPE_DEFINITION_GRP.building_block_info;

-- ----------------------------------------------------------------------------
-- |-------------------------------< build_attribute >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION build_attribute
          (p_time_building_block_id  in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
          ,p_attribute_category	     in hxc_time_attributes.attribute_category%type
          ) return HXC_USER_TYPE_DEFINITION_GRP.building_block_attribute_info;

END HXC_INTEGRATION_LAYER_V1_GRP;

 

/
