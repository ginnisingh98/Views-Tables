--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_DEPOSIT_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_DEPOSIT_COMMON" AUTHID CURRENT_USER AS
/* $Header: hxctcdpcommon.pkh 115.0 2003/04/23 18:59:51 jdupont noship $ */


c_yes                  CONSTANT VARCHAR2(1) := 'Y';
c_no                   CONSTANT VARCHAR2(2) := 'N';
c_submit               CONSTANT VARCHAR2(6) := 'SUBMIT';
c_save                 CONSTANT VARCHAR2(4) := 'SAVE';
c_audit                CONSTANT VARCHAR2(5) := 'AUDIT';
c_delete               CONSTANT VARCHAR2(6) := 'DELETE';
c_error                CONSTANT VARCHAR2(5) := 'ERROR';
c_confirmation         CONSTANT VARCHAR2(12) := 'CONFIRMATION';
c_information          CONSTANT VARCHAR2(11) := 'INFORMATION';
c_warning              CONSTANT VARCHAR2(7) := 'WARNING';
c_exception            CONSTANT VARCHAR2(9) := 'EXCEPTION';
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
c_alias_context_prefix CONSTANT VARCHAR2(5) := 'ALIAS';
c_person_resource      CONSTANT VARCHAR2(6) := 'PERSON';
c_assignment_resource  CONSTANT VARCHAR2(10) := 'ASSIGNMENT';
c_measure_type         CONSTANT VARCHAR2(7) := 'MEASURE';
c_range_type           CONSTANT VARCHAR2(5) := 'RANGE';
c_working_status       CONSTANT VARCHAR2(7) := 'WORKING';
c_submitted_status     CONSTANT VARCHAR2(9) := 'SUBMITTED';
c_approved_status      CONSTANT VARCHAR2(8) := 'APPROVED';
c_rejected_status      CONSTANT VARCHAR2(8) := 'REJECTED';
c_public_template      CONSTANT VARCHAR2(8) := 'PUBLIC';
c_private_template     CONSTANT VARCHAR2(8) := 'PRIVATE';
c_hxcempitemtype       CONSTANT VARCHAR2(8) := 'HXCEMP';
c_hxcapprovalprocess   CONSTANT VARCHAR2(12) := 'HXC_APPROVAL';


Procedure alias_translation
            (p_blocks     in out nocopy HXC_BLOCK_TABLE_TYPE
            ,p_attributes in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages   in out nocopy HXC_MESSAGE_TABLE_TYPE
            );
/*
Procedure validate_setup
           (p_deposit_mode in varchar2
           ,p_blocks       in out nocopy hxc_block_table_type
           ,p_attributes   in out nocopy hxc_attribute_table_type
           ,p_messages     in out nocopy hxc_message_table_type
           ) ;
*/

Function load_blocks
          (p_timecard_id  in out nocopy hxc_time_building_blocks.time_building_block_id%type
          ,p_timecard_ovn in out nocopy hxc_time_building_blocks.object_version_number%type
          ) return hxc_block_table_type;

Function load_attributes
           (p_blocks in out nocopy hxc_block_table_type)
           return hxc_attribute_table_type;

Procedure delete_timecard
           (p_mode         in varchar2
           ,p_template     in varchar2
           ,p_timecard_id  in out nocopy hxc_time_building_blocks.time_building_block_id%type
           );

END hxc_timecard_deposit_common;

 

/
