--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_DEPOSIT" AUTHID CURRENT_USER AS
/* $Header: hxctimedp.pkh 120.0.12000000.1 2007/01/18 18:09:36 appldev noship $ */

Procedure execute
           (p_blocks           in out nocopy hxc_block_table_type
           ,p_attributes       in out nocopy hxc_attribute_table_type
           ,p_timecard_blocks  in            hxc_timecard.block_list
           ,p_day_blocks       in            hxc_timecard.block_list
           ,p_detail_blocks    in            hxc_timecard.block_list
           ,p_messages         in out nocopy hxc_message_table_type
           ,p_transaction_info in out nocopy hxc_timecard.transaction_info
           );

End hxc_timecard_deposit;

 

/
