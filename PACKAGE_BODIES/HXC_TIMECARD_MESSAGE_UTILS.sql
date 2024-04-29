--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_MESSAGE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_MESSAGE_UTILS" as
/* $Header: hxctcmsgut.pkb 115.7 2004/07/10 10:13:56 arundell noship $ */

g_package varchar2(30) := 'hxc_timecard_message_utils.';

Procedure append_old_messages
           (p_messages             in out nocopy hxc_message_table_type
           ,p_old_messages         in            hxc_self_service_time_deposit.message_table
           ,p_retrieval_process_id in            hxc_retrieval_processes.retrieval_process_id%type
           ) is

l_index         number;
l_message_field varchar2(2000);
l_proc          varchar2(70) := g_package||'append_old_messages';

Begin

l_index := p_old_messages.first;
Loop
  Exit when not p_old_messages.exists(l_index);

  if(((p_old_messages(l_index).message_tokens <> 'CHANGE') AND (p_old_messages(l_index).message_tokens <> 'LATE')) OR (p_old_messages(l_index).message_tokens is null)) then
    l_message_field:=hxc_app_attribute_utils.findSegmentFromFieldName (p_old_messages(l_index).message_field );
  else
    l_message_field := p_old_messages(l_index).message_field;
  end if;

  p_messages.extend();
  p_messages(p_messages.last) :=
     hxc_message_type
      (p_old_messages(l_index).message_name
      ,p_old_messages(l_index).message_level
      ,l_message_field
      ,p_old_messages(l_index).message_tokens
      ,p_old_messages(l_index).application_short_name
      ,p_old_messages(l_index).time_building_block_id
      ,p_old_messages(l_index).time_building_block_ovn
      ,p_old_messages(l_index).time_attribute_id
      ,p_old_messages(l_index).time_attribute_ovn
      ,p_old_messages(l_index).message_extent			--Bug#2873563
      );

  l_index := p_old_messages.next(l_index);
End Loop;

End append_old_messages;

end hxc_timecard_message_utils;

/
