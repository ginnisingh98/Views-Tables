--------------------------------------------------------
--  DDL for Package HXC_SELF_SERVICE_TIME_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SELF_SERVICE_TIME_DEPOSIT" AUTHID CURRENT_USER AS
/* $Header: hxctcdpwr.pkh 120.2 2005/12/05 14:18:50 arundell noship $ */

   TYPE translate_bb_ids_rec IS RECORD (
      actual_bb_id                  hxc_time_building_blocks.time_building_block_id%TYPE);

   TYPE translate_bb_ids_tab IS TABLE OF translate_bb_ids_rec
      INDEX BY BINARY_INTEGER;

   TYPE translate_ta_ids_rec IS RECORD (
      actual_ta_id                  hxc_time_attributes.time_attribute_id%TYPE);

   TYPE translate_ta_ids_tab IS TABLE OF translate_ta_ids_rec
      INDEX BY BINARY_INTEGER;

   TYPE workflow_info IS RECORD (
      item_type                     wf_items.item_type%TYPE,
      process_name                  wf_activities.NAME%TYPE);

   TYPE message_info IS RECORD (
      message_name                  fnd_new_messages.message_name%TYPE,
      message_level                 VARCHAR2 (30),
      message_field                 VARCHAR2(2000),
      message_tokens                VARCHAR2 (4000), -- Bug 3036930
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
      process                       VARCHAR2 (30)); --SHIV

   TYPE app_attributes_info IS TABLE OF app_attributes
      INDEX BY BINARY_INTEGER;

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
      process                       varchar2 (30),
      application_set_id            hxc_time_building_blocks.application_set_id%type,
      translation_display_key       hxc_time_building_blocks.translation_display_key%type);

   TYPE timecard_info IS TABLE OF building_block_info
      INDEX BY BINARY_INTEGER;

   PROCEDURE set_workflow_info (
      p_item_type      IN   wf_items.item_type%TYPE,
      p_process_name   IN   wf_activities.NAME%TYPE
   );

   PROCEDURE initialize_globals;

   PROCEDURE show_errors (p_messages IN OUT NOCOPY message_table);

   FUNCTION build_application_attributes (
      p_retrieval_process_id   IN   NUMBER,
      p_deposit_process_id     IN   NUMBER --AI3
                                          ,
      p_for_time_attributes    IN   BOOLEAN
   )
      RETURN app_attributes_info;

   PROCEDURE deposit_attribute_info (
      p_time_attribute_id       IN   NUMBER,
      p_building_block_id       IN   NUMBER,
      p_bld_blk_info_type       IN   VARCHAR2,
      p_attribute_category      IN   VARCHAR2,
      p_attribute1              IN   VARCHAR2,
      p_attribute2              IN   VARCHAR2,
      p_attribute3              IN   VARCHAR2,
      p_attribute4              IN   VARCHAR2,
      p_attribute5              IN   VARCHAR2,
      p_attribute6              IN   VARCHAR2,
      p_attribute7              IN   VARCHAR2,
      p_attribute8              IN   VARCHAR2,
      p_attribute9              IN   VARCHAR2,
      p_attribute10             IN   VARCHAR2,
      p_attribute11             IN   VARCHAR2,
      p_attribute12             IN   VARCHAR2,
      p_attribute13             IN   VARCHAR2,
      p_attribute14             IN   VARCHAR2,
      p_attribute15             IN   VARCHAR2,
      p_attribute16             IN   VARCHAR2,
      p_attribute17             IN   VARCHAR2,
      p_attribute18             IN   VARCHAR2,
      p_attribute19             IN   VARCHAR2,
      p_attribute20             IN   VARCHAR2,
      p_attribute21             IN   VARCHAR2,
      p_attribute22             IN   VARCHAR2,
      p_attribute23             IN   VARCHAR2,
      p_attribute24             IN   VARCHAR2,
      p_attribute25             IN   VARCHAR2,
      p_attribute26             IN   VARCHAR2,
      p_attribute27             IN   VARCHAR2,
      p_attribute28             IN   VARCHAR2,
      p_attribute29             IN   VARCHAR2,
      p_attribute30             IN   VARCHAR2,
      p_bld_blk_info_type_id    IN   NUMBER,
      p_object_version_number   IN   NUMBER,
      p_new                     IN   VARCHAR2,
      p_changed                 IN   VARCHAR2
   );

   PROCEDURE call_attribute_deposit (
      p_time_attribute_id       IN   VARCHAR2,
      p_building_block_id       IN   VARCHAR2,
      p_bld_blk_info_type       IN   VARCHAR2,
      p_attribute_category      IN   VARCHAR2,
      p_attribute1              IN   VARCHAR2,
      p_attribute2              IN   VARCHAR2,
      p_attribute3              IN   VARCHAR2,
      p_attribute4              IN   VARCHAR2,
      p_attribute5              IN   VARCHAR2,
      p_attribute6              IN   VARCHAR2,
      p_attribute7              IN   VARCHAR2,
      p_attribute8              IN   VARCHAR2,
      p_attribute9              IN   VARCHAR2,
      p_attribute10             IN   VARCHAR2,
      p_attribute11             IN   VARCHAR2,
      p_attribute12             IN   VARCHAR2,
      p_attribute13             IN   VARCHAR2,
      p_attribute14             IN   VARCHAR2,
      p_attribute15             IN   VARCHAR2,
      p_attribute16             IN   VARCHAR2,
      p_attribute17             IN   VARCHAR2,
      p_attribute18             IN   VARCHAR2,
      p_attribute19             IN   VARCHAR2,
      p_attribute20             IN   VARCHAR2,
      p_attribute21             IN   VARCHAR2,
      p_attribute22             IN   VARCHAR2,
      p_attribute23             IN   VARCHAR2,
      p_attribute24             IN   VARCHAR2,
      p_attribute25             IN   VARCHAR2,
      p_attribute26             IN   VARCHAR2,
      p_attribute27             IN   VARCHAR2,
      p_attribute28             IN   VARCHAR2,
      p_attribute29             IN   VARCHAR2,
      p_attribute30             IN   VARCHAR2,
      p_bld_blk_info_type_id    IN   VARCHAR2,
      p_object_version_number   IN   VARCHAR2,
      p_new                     IN   VARCHAR2,
      p_changed                 IN   VARCHAR2
   );

   PROCEDURE call_block_deposit (
      p_time_building_block_id      IN   VARCHAR2,
      p_type                        IN   VARCHAR2,
      p_measure                     IN   VARCHAR2,
      p_unit_of_measure             IN   VARCHAR2,
      p_start_time                  IN   VARCHAR2,
      p_stop_time                   IN   VARCHAR2,
      p_parent_building_block_id    IN   VARCHAR2,
      p_parent_is_new               IN   VARCHAR2,
      p_scope                       IN   VARCHAR2,
      p_object_version_number       IN   VARCHAR2,
      p_approval_status             IN   VARCHAR2,
      p_resource_id                 IN   VARCHAR2,
      p_resource_type               IN   VARCHAR2,
      p_approval_style_id           IN   VARCHAR2,
      p_date_from                   IN   VARCHAR2,
      p_date_to                     IN   VARCHAR2,
      p_comment_text                IN   VARCHAR2,
      p_parent_building_block_ovn   IN   VARCHAR2,
      p_new                         IN   VARCHAR2,
      p_changed                     IN   VARCHAR2
   );

   PROCEDURE deposit_block_info (
      p_time_building_block_id      IN   NUMBER,
      p_type                        IN   VARCHAR2,
      p_measure                     IN   NUMBER,
      p_unit_of_measure             IN   VARCHAR2,
      p_start_time                  IN   DATE,
      p_stop_time                   IN   DATE,
      p_parent_building_block_id    IN   NUMBER,
      p_parent_is_new               IN   VARCHAR2,
      p_scope                       IN   VARCHAR2,
      p_object_version_number       IN   NUMBER,
      p_approval_status             IN   VARCHAR2,
      p_resource_id                 IN   NUMBER,
      p_resource_type               IN   VARCHAR2,
      p_approval_style_id           IN   NUMBER,
      p_date_from                   IN   DATE,
      p_date_to                     IN   DATE,
      p_comment_text                IN   VARCHAR2,
      p_parent_building_block_ovn   IN   NUMBER,
      p_new                         IN   VARCHAR2,
      p_changed                     IN   VARCHAR2
   );

   PROCEDURE alias_translation;

   PROCEDURE deposit_blocks (
      p_timecard_id         OUT NOCOPY   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn        OUT NOCOPY   hxc_time_building_blocks.object_version_number%TYPE,
      p_mode                      VARCHAR2,
      p_deposit_process           VARCHAR2,
      p_retrieval_process         VARCHAR2 DEFAULT NULL,
      p_validate_session          BOOLEAN DEFAULT TRUE,
      p_add_security              BOOLEAN DEFAULT TRUE,
      p_allow_error_tc            BOOLEAN DEFAULT FALSE
   );

   PROCEDURE delete_timecard (
      p_time_building_block_id   IN   NUMBER,
      p_effective_date           IN   DATE,
      p_mode                          VARCHAR2,
      p_deposit_process               VARCHAR2,
      p_retrieval_process             VARCHAR2
   );

   FUNCTION get_building_blocks
      RETURN timecard_info;

   FUNCTION get_block_attributes
      RETURN building_block_attribute_info;

   FUNCTION get_app_attributes
      RETURN app_attributes_info;

   FUNCTION get_messages
      RETURN message_table;

   PROCEDURE get_app_hook_params (
      p_building_blocks   OUT NOCOPY   timecard_info,
      p_app_attributes    OUT NOCOPY   app_attributes_info,
      p_messages          OUT NOCOPY   message_table
   );

   PROCEDURE set_app_hook_params (
      p_building_blocks   IN   timecard_info,
      p_app_attributes    IN   app_attributes_info,
      p_messages          IN   message_table
   );

   PROCEDURE set_global_table (
      p_building_blocks   IN   timecard_info,
      p_attributes        IN   building_block_attribute_info
   );

   PROCEDURE set_update_phase (p_mode IN BOOLEAN); --AI2.5

   --
   -- Given a Timecard scope BB ID and OVN, get the whole timecard
   -- structure in the usual table structure.
   -- Overloaded version of next procedure
   PROCEDURE get_timecard_tables (
      p_timecard_id               IN       NUMBER,
      p_timecard_ovn              IN       NUMBER,
      p_timecard_blocks           OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
      p_timecard_app_attributes   OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info,
      p_time_recipient_id         IN       NUMBER
   );

   PROCEDURE get_timecard_tables (
      p_timecard_id               IN       NUMBER,
      p_timecard_ovn              IN       NUMBER,
      p_timecard_blocks           OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
      p_timecard_app_attributes   OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info,
      p_deposit_process_id        IN       NUMBER,
      p_retrieval_process_id      IN       NUMBER
   );

   PROCEDURE update_deposit_globals (
      p_retrieval_process_id   IN   NUMBER DEFAULT NULL,
      p_deposit_process_id     IN   NUMBER DEFAULT NULL
   );

   FUNCTION get_new_attribute_id
      RETURN NUMBER;

   FUNCTION attribute_check (
      p_to_check                 IN   VARCHAR2,
      p_time_building_block_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION get_bld_blk_type_id (p_type IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE set_g_attributes ( p_attributes building_block_attribute_info );

END hxc_self_service_time_deposit;

 

/
