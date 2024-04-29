--------------------------------------------------------
--  DDL for Package HXC_DEPOSIT_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DEPOSIT_CHECKS" AUTHID CURRENT_USER AS
/* $Header: hxcdpwrck.pkh 115.4 2003/12/30 17:38:58 arundell noship $ */

--
-- Package body contains comments.
--

Procedure can_delete_template
           (p_template_id in            hxc_time_building_blocks.time_building_block_id%type
           ,p_messages    in out nocopy hxc_message_table_type);

PROCEDURE check_inputs
            (p_blocks             in            hxc_block_table_type
            ,p_attributes         in            hxc_attribute_table_type
            ,p_deposit_mode       in            varchar2
            ,p_template           in            varchar2
            ,p_messages           in out nocopy hxc_message_table_type
            );

FUNCTION chk_timecard_deposit
           (p_blocks in HXC_BLOCK_TABLE_TYPE
           ,p_block_number in NUMBER
           ) return BOOLEAN;

FUNCTION chk_timecard_deposit
           (p_blocks in hxc_self_service_time_deposit.timecard_info
           ,p_block_number in NUMBER
           ) return BOOLEAN;

PROCEDURE audit_checks
           (p_blocks     in            hxc_block_table_type
           ,p_attributes in            hxc_attribute_table_type
           ,p_messages   in out nocopy hxc_message_table_type
           );

PROCEDURE perform_checks
           (p_blocks         in            hxc_block_table_type
           ,p_attributes     in            hxc_attribute_table_type
           ,p_timecard_props in            hxc_timecard_prop_table_type
           ,p_days           in            hxc_timecard.block_list
           ,p_details        in            hxc_timecard.block_list
           ,p_messages       in out nocopy hxc_message_table_type
           );

PROCEDURE perform_process_checks
           (p_blocks         in            hxc_block_table_type
           ,p_attributes     in            hxc_attribute_table_type
           ,p_timecard_props in            hxc_timecard_prop_table_type
           ,p_days           in            hxc_timecard.block_list
           ,p_details        in            hxc_timecard.block_list
           ,p_template       in            varchar2
           ,p_deposit_mode   in            varchar2
           ,p_messages       in out nocopy hxc_message_table_type
           );

END hxc_deposit_checks;

 

/
