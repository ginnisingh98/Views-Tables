--------------------------------------------------------
--  DDL for Package HXC_TIMESTORE_DEPOSIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMESTORE_DEPOSIT_UTIL" AUTHID CURRENT_USER AS
/* $Header: hxctsdputil.pkh 120.4.12010000.2 2009/10/22 07:54:42 amakrish ship $ */
   TYPE translated_message_info IS RECORD (
      message_name              fnd_new_messages.message_name%TYPE,
      MESSAGE_TEXT              VARCHAR2 (4000),
      time_building_block_id    hxc_time_building_blocks.time_building_block_id%TYPE,
      time_building_block_ovn   hxc_time_building_blocks.object_version_number%TYPE,
      time_attribute_id         hxc_time_attributes.time_attribute_id%TYPE,
      time_attribute_ovn        hxc_time_attributes.object_version_number%TYPE
   );

   TYPE translated_message_table IS TABLE OF translated_message_info
      INDEX BY BINARY_INTEGER;

   FUNCTION get_retrieval_process_id (
      p_retrieval_process_name   IN   hxc_retrieval_processes.NAME%TYPE
   )
      RETURN hxc_retrieval_processes.retrieval_process_id%TYPE;

   FUNCTION approval_style_id (
      p_approval_style_name   hxc_approval_styles.NAME%TYPE
   )
      RETURN hxc_approval_styles.approval_style_id%TYPE;

   PROCEDURE begin_approval (
      p_timecard_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_blocks        IN   hxc_block_table_type
   );

   PROCEDURE save_timecard (
      p_blocks         IN OUT NOCOPY   hxc_block_table_type,
      p_attributes     IN OUT NOCOPY   hxc_attribute_table_type,
      p_messages       IN OUT NOCOPY   hxc_message_table_type,
      p_timecard_id    OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   );

   PROCEDURE submit_timecard (
      p_item_type           IN              wf_items.item_type%TYPE,
      p_approval_prc        IN              wf_process_activities.process_name%TYPE,
      p_template            IN              VARCHAR2,
      p_mode                IN              VARCHAR2,
      p_retrieval_process   IN              hxc_retrieval_processes.NAME%TYPE
            DEFAULT NULL,
      p_blocks              IN OUT NOCOPY   hxc_block_table_type,
      p_attributes          IN OUT NOCOPY   hxc_attribute_table_type,
      p_messages            IN OUT NOCOPY   hxc_message_table_type,
      p_timecard_id         OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn        OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   );

   FUNCTION convert_new_trans_info_to_old (
      p_transaction_info   IN   hxc_timecard.transaction_info
   )
      RETURN hxc_deposit_wrapper_utilities.t_transaction;

   FUNCTION convert_tbb_to_type (
      p_blocks   IN   hxc_self_service_time_deposit.timecard_info
   )
      RETURN hxc_block_table_type;

   PROCEDURE convert_app_attributes_to_type (
      p_attributes       IN OUT NOCOPY   hxc_attribute_table_type,
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

   FUNCTION convert_to_dpwr_messages (p_messages IN hxc_message_table_type)
      RETURN hxc_self_service_time_deposit.message_table;

-- NOT USED
/*   FUNCTION convert_msg_to_type (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   )
      RETURN hxc_message_table_type; */
   FUNCTION get_approval_status (p_mode IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE find_parent_building_block (
      p_start_time       IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id      IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type    IN              hxc_time_building_blocks.resource_type%TYPE,
      p_scope            IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_app_blocks       IN              hxc_block_table_type,
      p_timecard_bb_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn     OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   );

   PROCEDURE find_parent_building_block (
      p_start_time       IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id      IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type    IN              hxc_time_building_blocks.resource_type%TYPE,
      p_scope            IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_app_blocks       IN              hxc_self_service_time_deposit.timecard_info,
      p_timecard_bb_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn     OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   );

   PROCEDURE set_new_change_flags (
      p_attributes   IN OUT NOCOPY   hxc_attribute_table_type
   );

   PROCEDURE get_timecard_bb_id (
      p_bb_id            IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_bb_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn     OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   );

   FUNCTION get_index_in_bb_table (
      p_bb_table        IN   hxc_block_table_type,
      p_bb_id_to_find   IN   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN PLS_INTEGER;

   FUNCTION get_deposit_process_id (
      p_deposit_process_name   IN   hxc_deposit_processes.NAME%TYPE
   )
      RETURN hxc_deposit_processes.deposit_process_id%TYPE;

   FUNCTION get_index_in_attr_table (
      p_attr_table               IN   hxc_self_service_time_deposit.app_attributes_info,
      p_attr_id_to_find          IN   hxc_time_attributes.time_attribute_id%TYPE,
      p_attribute_name_to_find   IN   hxc_mapping_components.field_name%TYPE
   )
      RETURN PLS_INTEGER;
 -- ARR: Next two procedures add p_clear_mapping_cache for update case
   PROCEDURE get_timecard_tables (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_clear_mapping_cache IN            BOOLEAN default false,
      p_app_blocks          OUT NOCOPY      hxc_block_table_type,
      p_app_attributes      OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info
   );

   PROCEDURE get_timecard_tables (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
--      p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_clear_mapping_cache IN            BOOLEAN default false,
      p_app_blocks          OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info
   );

   PROCEDURE get_bld_blk_info_type (
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_bld_blk_info_type   OUT NOCOPY      hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
      p_segment             OUT NOCOPY      hxc_mapping_components.SEGMENT%TYPE
   );

   PROCEDURE clear_building_block_table (
      p_app_blocks   IN OUT NOCOPY   hxc_block_table_type
   );

   PROCEDURE clear_attribute_table (
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

   PROCEDURE clear_message_table (
      p_messages   IN OUT NOCOPY   hxc_message_table_type
   );

   PROCEDURE request_lock (
      p_app_blocks       IN              hxc_block_table_type,
      p_messages         IN OUT NOCOPY   hxc_message_table_type,
      p_locked_success   OUT NOCOPY      BOOLEAN,
      p_row_lock_id      OUT NOCOPY      ROWID
   );

   PROCEDURE release_lock (
      p_app_blocks         IN              hxc_block_table_type,
      p_messages           IN OUT NOCOPY   hxc_message_table_type,
      p_released_success   OUT NOCOPY      BOOLEAN,
      p_row_lock_id        IN OUT NOCOPY   ROWID
   );

   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_block_table_type,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   );

   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   );

   PROCEDURE log_messages (p_messages IN hxc_message_table_type);

   PROCEDURE log_messages (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   );

   FUNCTION translate_message_table (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   )
      RETURN translated_message_table;

   PROCEDURE find_current_period (
      p_resource_id     IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type   IN              hxc_time_building_blocks.resource_type%TYPE,
      p_day             IN              hxc_time_building_blocks.start_time%TYPE,
      p_start_time      OUT NOCOPY      DATE,
      p_stop_time       OUT NOCOPY      DATE
   );

   FUNCTION cla_enabled (
      p_building_block_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN BOOLEAN;

-- Procedure added for bug 8900783
   PROCEDURE get_past_future_limits (
      p_resource_id 	     IN  	     hxc_time_building_blocks.resource_id%TYPE,
      p_timecard_start_time  IN  	     date,
      p_timecard_stop_time   IN  	     date,
      p_messages             IN OUT NOCOPY   hxc_message_table_type
   );

END hxc_timestore_deposit_util;

/
