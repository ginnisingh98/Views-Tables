--------------------------------------------------------
--  DDL for Package HXC_TIMECARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD" AUTHID CURRENT_USER AS
/* $Header: hxctimecard.pkh 120.6 2008/03/14 11:13:08 bbayragi noship $ */

Type block_list is table of number index by binary_integer;

Type transaction_record is record
  (transaction_detail_id     hxc_transaction_details.transaction_detail_id%type
  ,time_building_block_id    hxc_time_building_blocks.time_building_block_id%type
  ,object_version_number     hxc_time_building_blocks.object_version_number%type
  ,data_set_id               hxc_time_building_blocks.data_set_id%type
  ,status                    hxc_transaction_details.status%TYPE
  ,exception_desc            hxc_transaction_details.exception_description%TYPE
  );

Type transaction_info is table of transaction_record index by binary_integer;

c_yes                  CONSTANT VARCHAR2(1) := 'Y';
c_no                   CONSTANT VARCHAR2(2) := 'N';
c_submit               CONSTANT VARCHAR2(6) := 'SUBMIT';
c_save                 CONSTANT VARCHAR2(4) := 'SAVE';
c_audit                CONSTANT VARCHAR2(5) := 'AUDIT';
c_delete               CONSTANT VARCHAR2(6) := 'DELETE';
c_error                CONSTANT VARCHAR2(5) := 'ERROR';
c_confirmation         CONSTANT VARCHAR2(12):= 'CONFIRMATION';
c_information          CONSTANT VARCHAR2(11):= 'INFORMATION';
c_warning              CONSTANT VARCHAR2(7) := 'WARNING';
c_exception            CONSTANT VARCHAR2(9) := 'EXCEPTION';
c_business_message     CONSTANT VARCHAR2(16):= 'BUSINESS_MESSAGE';
c_pte                  CONSTANT VARCHAR2(3) := 'PTE';
c_hxc                  CONSTANT VARCHAR2(3) := 'HXC';
c_timecard_scope       CONSTANT VARCHAR2(8) := 'TIMECARD';
c_template_scope       CONSTANT VARCHAR2(17):= 'TIMECARD_TEMPLATE';
c_day_scope            CONSTANT VARCHAR2(3) := 'DAY';
c_detail_scope         CONSTANT VARCHAR2(6) := 'DETAIL';
c_process              CONSTANT VARCHAR2(1) := 'Y';
c_trans_error          CONSTANT VARCHAR2(6) := 'ERRORS';
c_trans_success        CONSTANT VARCHAR2(7) := 'SUCCESS';
c_template_attribute   CONSTANT VARCHAR2(9) := 'TEMPLATES';
c_layout_attribute     CONSTANT VARCHAR2(6) := 'LAYOUT';
c_reason_attribute     CONSTANT VARCHAR2(6) := 'REASON';
c_security_attribute   CONSTANT VARCHAR2(8) := 'SECURITY';
c_alias_context_prefix CONSTANT VARCHAR2(5) := 'ALIAS';
c_person_resource      CONSTANT VARCHAR2(6) := 'PERSON';
c_assignment_resource  CONSTANT VARCHAR2(10):= 'ASSIGNMENT';
c_measure_type         CONSTANT VARCHAR2(7) := 'MEASURE';
c_range_type           CONSTANT VARCHAR2(5) := 'RANGE';
c_working_status       CONSTANT VARCHAR2(7) := 'WORKING';
c_submitted_status     CONSTANT VARCHAR2(9) := 'SUBMITTED';
c_approved_status      CONSTANT VARCHAR2(8) := 'APPROVED';
c_rejected_status      CONSTANT VARCHAR2(8) := 'REJECTED';
c_nondelete            CONSTANT VARCHAR2(9) := 'NONDELETE';
c_blk_extent           CONSTANT VARCHAR2(3) := 'BLK';			--Bug#2873563
c_blk_children_extent  CONSTANT VARCHAR2(16):= 'BLK_AND_CHILDREN';	--Bug#2873563
c_hxcempitemtype       CONSTANT VARCHAR2(6) := 'HXCEMP';
c_hxcapprovalprocess   CONSTANT VARCHAR2(12):= 'HXC_APPROVAL';
c_hxcnotifyprocess     CONSTANT VARCHAR2(16):= 'HXC_APPLY_NOTIFY';
c_public_template      CONSTANT VARCHAR2(6) := 'PUBLIC';
c_private_template     CONSTANT VARCHAR2(7) := 'PRIVATE';

-- New constants added for period choice lists
c_more_period_indicator CONSTANT VARCHAR2(1) := '#';
c_existing_period_indicator CONSTANT VARCHAR2(1) := '~';
c_archived_period_indicator CONSTANT VARCHAR2(1) := '!';

Procedure create_timecard
           (p_validate     in            varchar2
           ,p_blocks       in            hxc_block_table_type
           ,p_attributes   in            hxc_attribute_table_type
           ,p_deposit_mode in            varchar2
           ,p_template     in            varchar2
           ,p_item_type    in            wf_items.item_type%type
           ,p_approval_prc in            wf_process_activities.process_name%type
           ,p_lock_rowid   in            rowid
	   ,p_cla_save     in            varchar2 default 'NO'
           ,p_timecard_id     out nocopy hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn    out nocopy hxc_time_building_blocks.object_version_number%type
           ,p_messages        out nocopy hxc_message_table_type
           );

Function load_blocks
          (p_timecard_id  in hxc_time_building_blocks.time_building_block_id%type
          ,p_timecard_ovn in hxc_time_building_blocks.object_version_number%type
          ,p_load_mode    in varchar2 default c_nondelete
          ) return hxc_block_table_type;

Function load_attributes
           (p_blocks in hxc_block_table_type)
           return hxc_attribute_table_type;

Procedure delete_timecard
           (p_mode         in            varchar2
           ,p_template     in            varchar2
           ,p_timecard_id  in            hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ok  in out nocopy varchar2
           );

-- Added for DA Enhancement
Procedure delete_null_entries
	   (p_timecard_id  in            hxc_time_building_blocks.time_building_block_id%type
	   ,p_timecard_ovn in hxc_time_building_blocks.object_version_number%type
	   );


END HXC_TIMECARD;

/
