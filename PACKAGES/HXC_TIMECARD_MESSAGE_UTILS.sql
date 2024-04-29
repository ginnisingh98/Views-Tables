--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_MESSAGE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_MESSAGE_UTILS" AUTHID CURRENT_USER as
/* $Header: hxctcmsgut.pkh 115.1 2003/05/15 16:26:21 arundell noship $ */

Procedure append_old_messages
           (p_messages             in out nocopy hxc_message_table_type
           ,p_old_messages         in            hxc_self_service_time_deposit.message_table
           ,p_retrieval_process_id in            hxc_retrieval_processes.retrieval_process_id%type
           );

end hxc_timecard_message_utils;

 

/
