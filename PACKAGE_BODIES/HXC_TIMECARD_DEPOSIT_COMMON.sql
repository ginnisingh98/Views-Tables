--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_DEPOSIT_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_DEPOSIT_COMMON" AS
/* $Header: hxctcdpcommon.pkb 120.0.12010000.4 2009/10/05 12:10:22 amakrish ship $ */

g_package            varchar2(50) := 'hxc_timecard_deposit_common';

/**************************************************************************
 Alias Translator Procedure
 This procedure....
***************************************************************************/
Procedure alias_translation
            (p_blocks     in out nocopy HXC_BLOCK_TABLE_TYPE
            ,p_attributes in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages   in out nocopy HXC_MESSAGE_TABLE_TYPE
            ) is

l_old_style_attr  HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info;
l_old_style_blks  HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;

l_proc varchar2(80) := g_package||'.alias_translation';

Begin

hxc_timecard_attribute_utils.set_bld_blk_info_type_id(p_attributes);

HXC_ALIAS_TRANSLATOR.DO_DEPOSIT_TRANSLATION
  (p_attributes => p_attributes
  ,p_messages => p_messages
  );

End alias_translation;

/**************************************************************************
 Validate Setup Procedure
 This procedure....
***************************************************************************/
/*
Procedure validate_setup
           (p_deposit_mode in     varchar2
           ,p_blocks       in out nocopy hxc_block_table_type
           ,p_attributes   in out nocopy hxc_attribute_table_type
           ,p_messages     in out nocopy hxc_message_table_type
           ) is

cursor c_deposit_process is
 select deposit_process_id
   from hxc_deposit_processes
  where name = 'OTL Deposit Process';

l_old_blocks         hxc_self_service_time_deposit.timecard_info;
l_old_attributes     hxc_self_service_time_deposit.building_block_attribute_info;
l_old_messages       hxc_self_service_time_deposit.message_table;
l_app_attributes     hxc_self_service_time_deposit.app_attributes_info;
l_deposit_process_id hxc_deposit_processes.deposit_process_id%type;

Begin

open c_deposit_process;
fetch c_deposit_process into l_deposit_process_id;
if(c_deposit_process%notfound) then
  close c_deposit_process;
  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_NO_OTL_DEPOSIT_PROC'
    ,hxc_timecard.c_error
    ,null
    ,null
    ,hxc_timecard.c_hxc
    ,null
    ,null
    ,null
    ,null
    );

else

close c_deposit_process;

l_app_attributes :=
          hxc_app_attribute_utils.create_app_attributes
           (p_attributes           => p_attributes
           ,p_retrieval_process_id => null
           ,p_deposit_process_id   => l_deposit_process_id
           );

l_old_blocks := hxc_timecard_block_utils.convert_to_dpwr_blocks
                 (p_blocks => p_blocks);

l_old_attributes := hxc_timecard_attribute_utils.convert_to_dpwr_attributes
                     (p_attributes => p_attributes);

hxc_timecard_message_utils.append_old_messages
 (p_messages             => p_messages
 ,p_old_messages         => l_old_messages
 ,p_retrieval_process_id => null
 );

end if;

End validate_setup;
*/
/**************************************************************************
 Load Block Procedure
 This procedure....

***************************************************************************/
Function load_blocks
          (p_timecard_id in out nocopy hxc_time_building_blocks.time_building_block_id%type
          ,p_timecard_ovn in out nocopy hxc_time_building_blocks.object_version_number%type
          ) return hxc_block_table_type is

cursor c_blocks
        (p_tc_id in hxc_time_building_blocks.time_building_block_id%type
        ) is
   select tbb.time_building_block_id
         ,tbb.object_version_number
     from hxc_time_building_blocks tbb
    where tbb.date_to = hr_general.end_of_time
    start with (tbb.time_building_block_id = p_tc_id)
connect by prior tbb.time_building_block_id = tbb.parent_building_block_id
       and prior tbb.object_version_number = tbb.parent_building_block_ovn;

l_blocks      hxc_block_table_type := hxc_block_table_type();
l_block_count number := 1;


Begin

for block_rec in c_blocks(p_timecard_id) loop
  l_blocks.extend;
  l_blocks(l_block_count) := hxc_timecard_block_utils.build_block
                               (block_rec.time_building_block_id
                               ,block_rec.object_version_number);
  --
  -- Date effectively end date the block
  --
  l_blocks(l_block_count).date_to := sysdate;
  l_block_count := l_block_count +1;

end loop;

return l_blocks;

End load_blocks;

/**************************************************************************
 Load Attribures Procedure
 This procedure....
***************************************************************************/
Function load_attributes
           (p_blocks in out nocopy hxc_block_table_type)
           return hxc_attribute_table_type is

cursor c_attributes
         (p_building_block_id in hxc_time_building_blocks.time_building_block_id%type
         ,p_building_block_ovn in hxc_time_building_blocks.object_version_number%type
         ) is
  select tau.time_attribute_id
    from hxc_time_attribute_usages tau
   where tau.time_building_block_id = p_building_block_id
     and tau.time_building_block_ovn = p_building_block_ovn;

l_attributes hxc_attribute_table_type := hxc_attribute_table_type();

l_block_index     number;
l_attribute_index number := 1;

Begin

l_block_index := p_blocks.first;

loop
  exit when not p_blocks.exists(l_block_index);
  for attribute_rec in c_attributes(p_blocks(l_block_index).time_building_block_id,p_blocks(l_block_index).object_version_number) loop
    l_attributes.extend;
    l_attributes(l_attribute_index) := hxc_timecard_attribute_utils.build_attribute
                                        (attribute_rec.time_attribute_id
                                        ,1
                                        ,p_blocks(l_block_index).time_building_block_id
                                        ,p_blocks(l_block_index).object_version_number
                                        );
    l_attribute_index := l_attribute_index +1;
  end loop;
  l_block_index := p_blocks.next(l_block_index);
end loop;

return l_attributes;

End load_attributes;

/**************************************************************************
 Delete Timecard Procedure
 This procedure....
***************************************************************************/
Procedure delete_timecard
           (p_mode         in varchar2
           ,p_template     in varchar2
           ,p_timecard_id  in out nocopy hxc_time_building_blocks.time_building_block_id%type
           ) is

cursor c_timecard_ovn
        (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is
  select tbb.object_version_number
    from hxc_time_building_blocks tbb
   where tbb.time_building_block_id = p_timecard_id
     and tbb.date_to = hr_general.end_of_time;

l_blocks     hxc_block_table_type     := hxc_block_table_type();
l_attributes hxc_attribute_table_type := hxc_attribute_table_type();
l_messages   hxc_message_table_type   := hxc_message_table_type();

l_timecard_blocks  hxc_timecard.block_list;
l_day_blocks       hxc_timecard.block_list;
l_detail_blocks    hxc_timecard.block_list;

l_transaction_info hxc_timecard.transaction_info;
l_timecard_props   hxc_timecard_prop_table_type;

l_dummy boolean := true;

l_timecard_ovn     hxc_time_building_blocks.object_version_number%type;
l_timecard_index   number;

l_resource_id  NUMBER;
l_tc_start  DATE;
l_tc_stop   DATE;

Begin

--
-- Find the corresponding ovn of the timecard
--

open c_timecard_ovn(p_timecard_id);
fetch c_timecard_ovn into l_timecard_ovn;
if(c_timecard_ovn%notfound) then
  close c_timecard_ovn;
  fnd_message.set_name('HXC','HXC_NO_ACTIVE_TIMECARD');
  fnd_message.raise_error;
end if;

close c_timecard_ovn;

--
-- Initialize the message stack
--

fnd_msg_pub.initialize;
hxc_timecard_message_helper.initializeErrors;
--
-- Get the timecard or timecard template blocks and attributes
--

  l_blocks := load_blocks(p_timecard_id, l_timecard_ovn);
  l_attributes := load_attributes(l_blocks);

--
-- Main delete processing
--

  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(l_blocks);

  hxc_timecard_properties.get_preference_properties
    (p_validate             => hxc_timecard.c_yes
    ,p_resource_id          => l_blocks(l_timecard_index).resource_id
    ,p_timecard_start_time  => fnd_date.canonical_to_date(l_blocks(l_timecard_index).start_time)
    ,p_timecard_stop_time   => fnd_date.canonical_to_date(l_blocks(l_timecard_index).stop_time)
    ,p_for_timecard         => false
    ,p_messages             => l_messages
    ,p_property_table       => l_timecard_props
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => l_messages);

  l_messages.delete;

  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => l_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );

  hxc_block_attribute_update.set_process_flags
    (p_blocks => l_blocks
    ,p_attributes => l_attributes
    );

  hxc_timecard_validation.deposit_validation
    (p_blocks        => l_blocks
    ,p_attributes    => l_attributes
    ,p_messages      => l_messages
    ,p_props         => l_timecard_props
    ,p_deposit_mode  => hxc_timecard.c_submit
    ,p_template      => p_template
    ,p_resubmit      => c_delete
    ,p_can_deposit   => l_dummy
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => l_messages);

  hxc_timecard_deposit.execute
   (p_blocks => l_blocks
   ,p_attributes => l_attributes
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks => l_day_blocks
   ,p_detail_blocks => l_detail_blocks
   ,p_messages => l_messages
   ,p_transaction_info => l_transaction_info
   );
  hxc_timecard_message_helper.processerrors
    (p_messages => l_messages);

  hxc_timecard_summary_api.delete_timecard
      (p_blocks => l_blocks
      ,p_timecard_id => p_timecard_id
      );

  hxc_timecard_audit.audit_deposit
    (p_transaction_info => l_transaction_info
    ,p_messages => l_messages
    );
  hxc_timecard_message_helper.processerrors
    (p_messages => l_messages);

  hxc_timecard_message_helper.prepareErrors;

-- OTL-Absences Integration (Bug 8779478)
  IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
     IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors) THEN

      	hr_utility.trace('Initiated Online Retrieval from HXC_TIMECARD_DEPOSIT_COMMON.DELETE_TIMECARD');

        l_resource_id := l_blocks(l_timecard_index).resource_id;
        l_tc_start  :=  fnd_date.canonical_to_date(l_blocks(l_timecard_index).start_time);
        l_tc_stop   := fnd_date.canonical_to_date(l_blocks(l_timecard_index).stop_time);

  	hxc_abs_retrieval_pkg.post_absences(l_resource_id,
  					    l_tc_start,
  					    l_tc_stop,
  					    'DELETED',
  					    l_messages);

  	hxc_timecard_message_helper.processerrors
	    (p_messages => l_messages);

        hxc_timecard_message_helper.prepareErrors;

     END IF;
  END IF;

End delete_timecard;

END hxc_timecard_deposit_common;

/
