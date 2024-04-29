--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_VALIDATION" AUTHID CURRENT_USER as
/* $Header: hxctimevalid.pkh 120.1 2005/07/04 05:03:41 valvarsa noship $ */

type appset_retrieval is record
  (retrieval_process_id  hxc_retrieval_processes.retrieval_process_id%type);

type appset_retrieval_table is table of appset_retrieval index by binary_integer;

type recipient_application is record
  (time_recipient_id              hxc_time_recipients.time_recipient_id%type
  ,name                           hxc_time_recipients.name%type
  ,application_retrieval_function hxc_time_recipients.application_retrieval_function%type
  ,application_update_process     hxc_time_recipients.application_update_process%type
  ,appl_validation_process        hxc_time_recipients.appl_validation_process%type
  ,appl_retrieval_process_id      hxc_retrieval_processes.retrieval_process_id%type
  );

type recipient_application_table is table of recipient_application index by binary_integer;

Procedure recipients_update_validation
            (p_blocks       in out nocopy hxc_block_table_type
            ,p_attributes   in out nocopy hxc_attribute_table_type
            ,p_messages     in out nocopy hxc_message_table_type
            ,p_props        in            hxc_timecard_prop_table_type
            ,p_deposit_mode in            varchar2
            ,p_resubmit     in            varchar2
            );

procedure deposit_validation
            (p_blocks       in out nocopy hxc_block_table_type
            ,p_attributes   in out nocopy hxc_attribute_table_type
            ,p_messages     in out nocopy hxc_message_table_type
            ,p_props        in            hxc_timecard_prop_table_type
            ,p_deposit_mode in            varchar2
            ,p_template     in            varchar2
            ,p_resubmit     in            varchar2
            ,p_can_deposit     out nocopy boolean
            );

procedure  data_set_validation
           (p_blocks        in out nocopy hxc_block_table_type
           ,p_messages      in out nocopy hxc_message_table_type
           );


Procedure timecard_validation
      (p_blocks       in out nocopy hxc_block_table_type,
       p_attributes   in out nocopy hxc_attribute_table_type,
       p_messages     in out nocopy hxc_message_table_type,
       p_props        in            hxc_timecard_prop_table_type,
       p_deposit_mode in            varchar2,
       p_resubmit     in            varchar2
       );
end hxc_timecard_validation;

 

/
