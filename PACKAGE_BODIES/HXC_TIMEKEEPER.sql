--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER" AS
/* $Header: hxctimekeeper.pkb 120.7.12010000.14 2010/03/05 06:44:53 sabvenug ship $ */

g_package            varchar2(50) := 'HXC_TIMEKEEPER';
---
----
----
Procedure remove_blank_attribute_rows
            (p_attributes in out nocopy hxc_attribute_table_type) is

l_index number;

Begin

l_index := p_attributes.first;

Loop
  Exit when not p_attributes.exists(l_index);

if(
   (    p_attributes(l_index).attribute_category not like 'COST%'
    and p_attributes(l_index).attribute_category not like 'GRP%'
    and p_attributes(l_index).attribute_category not like 'ELEMENT%'
    and p_attributes(l_index).attribute_category not like 'PAEXPITDFF%'
    and p_attributes(l_index).attribute_category not like 'POS%'
    and p_attributes(l_index).attribute_category not like 'JOB%'
    )
  AND
   (p_attributes(l_index).attribute1 is null)
  AND
   (p_attributes(l_index).attribute2 is null)
  AND
   (p_attributes(l_index).attribute3 is null)
  AND
   (p_attributes(l_index).attribute4 is null)
  AND
   (p_attributes(l_index).attribute5 is null)
  AND
   (p_attributes(l_index).attribute6 is null)
  AND
   (p_attributes(l_index).attribute7 is null)
  AND
   (p_attributes(l_index).attribute8 is null)
  AND
   (p_attributes(l_index).attribute9 is null)
  AND
   (p_attributes(l_index).attribute10 is null)
  AND
   (p_attributes(l_index).attribute11 is null)
  AND
   (p_attributes(l_index).attribute12 is null)
  AND
   (p_attributes(l_index).attribute13 is null)
  AND
   (p_attributes(l_index).attribute14 is null)
  AND
   (p_attributes(l_index).attribute15 is null)
  AND
   (p_attributes(l_index).attribute16 is null)
  AND
   (p_attributes(l_index).attribute17 is null)
  AND
   (p_attributes(l_index).attribute18 is null)
  AND
   (p_attributes(l_index).attribute19 is null)
  AND
   (p_attributes(l_index).attribute20 is null)
  AND
   (p_attributes(l_index).attribute21 is null)
  AND
   (p_attributes(l_index).attribute22 is null)
  AND
   (p_attributes(l_index).attribute23 is null)
  AND
   (p_attributes(l_index).attribute24 is null)
  AND
   (p_attributes(l_index).attribute25 is null)
  AND
   (p_attributes(l_index).attribute26 is null)
  AND
   (p_attributes(l_index).attribute27 is null)
  AND
   (p_attributes(l_index).attribute28 is null)
  AND
   (p_attributes(l_index).attribute29 is null)
  AND
   (p_attributes(l_index).attribute30 is null)
  ) then

    p_attributes.delete(l_index);
  end if;

  l_index := p_attributes.next(l_index);

End Loop;

End remove_blank_attribute_rows;

----------------------------------------------------------------------------
-- Save Timecard Procedure
-- This procedure....
----------------------------------------------------------------------------
Procedure save_timecard
           (p_blocks          in out nocopy HXC_BLOCK_TABLE_TYPE
           ,p_attributes      in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
           ,p_messages        in out nocopy HXC_MESSAGE_TABLE_TYPE
           ,p_timecard_id        out nocopy hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn       out nocopy hxc_time_building_blocks.object_version_number%type
	   ,p_timekeeper_id   in hxc_time_building_blocks.resource_id%type DEFAULT NULL
	   ,p_tk_audit_enabled in VARCHAR2 DEFAULT NULL
 	   ,p_tk_notify_to    in VARCHAR2  DEFAULT NULL
	   ,p_tk_notify_type  in VARCHAR2  DEFAULT NULL
           ) is


cursor c_previous_timecard(
			      p_timecard_id in hxc_timecard_summary.timecard_id%type) is
  select tk_audit_item_key,tk_audit_item_type
    from hxc_timecard_summary
   where timecard_id = p_timecard_id;

l_timecard_blocks  hxc_timecard.block_list;
l_day_blocks       hxc_timecard.block_list;
l_detail_blocks    hxc_timecard.block_list;
l_transaction_info hxc_timecard.transaction_info;
l_timecard_props   hxc_timecard_prop_table_type;
l_proc             varchar2(50) := g_package||'.SAVE_CONTROLLER';
l_timecard_index   number;

l_old_style_blks   hxc_self_service_time_deposit.timecard_info;
l_old_style_attrs  hxc_self_service_time_deposit.building_block_attribute_info;
l_old_messages     hxc_self_service_time_deposit.message_table;

l_resubmit         varchar2(10) := hxc_timecard_deposit_common.c_no;

l_rollback	   BOOLEAN := FALSE;
l_status_error	   BOOLEAN := FALSE;
e_timekeeper_check EXCEPTION;

l_item_key         WF_ITEMS.ITEM_KEY%TYPE :=NULL;

l_previous_tk_item_key   hxc_timecard_summary.tk_audit_item_key%type;
l_previous_tk_item_type  hxc_timecard_summary.tk_audit_item_type%type;

tk_audit_item_type    WF_ITEMS.ITEM_TYPE%TYPE :=NULL;
tk_audit_process_name  VARCHAR2(50) :=NULL;

n number;
l_index	NUMBER;


l_resource_id      NUMBER;
l_tc_start         DATE;
l_tc_stop          DATE;
l_approval_status  VARCHAR2(20);

l_abs_ret_messages	HXC_MESSAGE_TABLE_TYPE;

Begin

--
-- Fnd initialization
--
  fnd_msg_pub.initialize;
/*
  IF g_debug THEN
    hxc_debug_timecard.writeTimecard(p_blocks,p_attributes,'HXC_TIMEKEEPER',10);
  END IF;
*/

g_debug := hr_utility.debug_enabled;
----------------------------------------------------------------------------
--  Timecard Preparation
----------------------------------------------------------------------------
  hxc_timecard_message_helper.initializeerrors;

  p_messages := hxc_message_table_type ();

  -- create savepoint
  savepoint TK_SAVE_SAVEPOINT;

  hxc_timecard_block_utils.initialize_timecard_index;

--
--  Check input parameters
--
  hxc_deposit_checks.check_inputs
    (p_blocks       => p_blocks
    ,p_attributes   => p_attributes
    ,p_deposit_mode => hxc_timecard_deposit_common.c_save
    ,p_template     => hxc_timecard_deposit_common.c_no
    ,p_messages     => p_messages
    );
/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',20);
  END IF;
*/
  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--   First we are getting the preference
--   for the resource of the timecard
--

  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

  -- this procedure has the otl setup validation
  hxc_timecard_properties.get_preference_properties
    (p_validate             => hxc_timecard_deposit_common.c_yes
    ,p_resource_id          => p_blocks(l_timecard_index).resource_id
    ,p_timecard_start_time  => fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time)
    ,p_timecard_stop_time   => fnd_date.canonical_to_date(p_blocks(l_timecard_index).stop_time)
    ,p_for_timecard         => false
    ,p_messages             => p_messages
    ,p_property_table       => l_timecard_props
    );
/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',30);
  END IF;
*/
  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--  Sort blocks
--
  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );

----------------------------------------------------------------------------
--  Timecard Prepre-Validation
----------------------------------------------------------------------------
--
--  Perform basic checks
--
  hxc_deposit_checks.perform_checks
    (p_blocks         => p_blocks
    ,p_attributes     => p_attributes
    ,p_timecard_props => l_timecard_props
    ,p_days           => l_day_blocks
    ,p_details        => l_detail_blocks
    ,p_messages       => p_messages
    );
/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',40);
  END IF;
*/
  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

----------------------------------------------------------------------------
--  Timecard Preparation
----------------------------------------------------------------------------

--
--  Add the security attributes
--  ARR: 115.28 change, added p_messages
--
  hxc_security.add_security_attribute
    (p_blocks         => p_blocks
    ,p_attributes     => p_attributes
    ,p_timecard_props => l_timecard_props
    ,p_messages       => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
--
--  Translate any aliases
--
  hxc_timecard_deposit_common.alias_translation
   (p_blocks => p_blocks
   ,p_attributes => p_attributes
   ,p_messages => p_messages
   );
/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',50);
  END IF;
*/
  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--  Set the block and attribute update process flags
--  Based on the data sent and in the db
--
  hxc_block_attribute_update.set_process_flags
    (p_blocks     => p_blocks
    ,p_attributes => p_attributes
    );

--
--  Removed any deleted attributes
--

  hxc_timecard_attribute_utils.remove_deleted_attributes
    (p_attributes => p_attributes);

  remove_blank_attribute_rows (p_attributes => p_attributes);

----------------------------------------------------------------------------
--  Timecard Pre-Validation
----------------------------------------------------------------------------
--
--  Validate the set up for the user
--
/*
  hxc_timecard_deposit_common.validate_setup
     (p_deposit_mode => hxc_timecard.c_save
     ,p_blocks       => p_blocks
     ,p_attributes   => p_attributes
     ,p_messages     => p_messages
     );

  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',60);
  END IF;

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
*/
/*
  Call time entry rules for save
*/

/*
   l_old_style_blks := HXC_TIMECARD_BLOCK_UTILS.convert_to_dpwr_blocks
                       (p_blocks);

   l_old_style_attrs := HXC_TIMECARD_ATTRIBUTE_UTILS.convert_to_dpwr_attributes
                         (p_attributes);

   HXC_TIME_ENTRY_RULES_UTILS_PKG.EXECUTE_TIME_ENTRY_RULES
   (P_OPERATION            => hxc_timecard_deposit_common.c_save
   ,P_TIME_BUILDING_BLOCKS => l_old_style_blks
   ,P_TIME_ATTRIBUTES      => l_old_style_attrs
   ,P_MESSAGES             => l_old_messages
   ,P_RESUBMIT             => hxc_timecard_deposit_common.c_no
   );

  hxc_timecard_message_utils.append_old_messages
   (p_messages             => p_messages
   ,p_old_messages         => l_old_messages
   ,p_retrieval_process_id => null
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
*/

  --
  -- call the application validation
  --
  hxc_timecard_validation.recipients_update_validation
    (p_blocks        => p_blocks
    ,p_attributes    => p_attributes
    ,p_messages      => p_messages
    ,p_props         => l_timecard_props
    ,p_deposit_mode  => hxc_timecard_deposit_common.c_save
    ,p_resubmit      => l_resubmit);

/* Added for bug 8775740 HR Absence Integration

This pkg call is used to validate absence entries against the
Absences Pref setting for the particular resource_id

*/
-- Change start

if g_debug then

 hr_utility.trace('Just before verify_view_only_absences in hxctksave');
 if (p_blocks.count>0) then


    hr_utility.trace('  P_BLOCK TABLE START ');
    hr_utility.trace(' *****************');

    l_index := p_blocks.FIRST;

     LOOP
       EXIT WHEN NOT p_blocks.EXISTS (l_index);


      hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| p_blocks(l_index).TIME_BUILDING_BLOCK_ID     );
      hr_utility.trace(' TYPE =   '|| p_blocks(l_index).TYPE )    ;
      hr_utility.trace(' MEASURE =   '|| p_blocks(l_index).MEASURE)    ;
      hr_utility.trace(' UNIT_OF_MEASURE     =       '|| p_blocks(l_index).UNIT_OF_MEASURE        )    ;
      hr_utility.trace(' START_TIME     =       '|| p_blocks(l_index).START_TIME        )    ;
      hr_utility.trace(' STOP_TIME      =       '|| p_blocks(l_index).STOP_TIME        )    ;
      hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
      hr_utility.trace(' PARENT_IS_NEW     =       '|| p_blocks(l_index).PARENT_IS_NEW        )    ;
      hr_utility.trace(' SCOPE     =       '|| p_blocks(l_index).SCOPE        )    ;
      hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| p_blocks(l_index).OBJECT_VERSION_NUMBER        )    ;
      hr_utility.trace(' APPROVAL_STATUS     =       '|| p_blocks(l_index).APPROVAL_STATUS        )    ;
      hr_utility.trace(' RESOURCE_ID     =       '|| p_blocks(l_index).RESOURCE_ID        )    ;
      hr_utility.trace(' RESOURCE_TYPE    =       '|| p_blocks(l_index).RESOURCE_TYPE       )    ;
      hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| p_blocks(l_index).APPROVAL_STYLE_ID       )    ;
      hr_utility.trace(' DATE_FROM    =       '|| p_blocks(l_index).DATE_FROM       )    ;
      hr_utility.trace(' DATE_TO    =       '|| p_blocks(l_index).DATE_TO       )    ;
      hr_utility.trace(' COMMENT_TEXT    =       '|| p_blocks(l_index).COMMENT_TEXT       )    ;
      hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
      hr_utility.trace(' NEW    =       '|| p_blocks(l_index).NEW       )    ;
      hr_utility.trace(' CHANGED    =       '|| p_blocks(l_index).CHANGED       )    ;
      hr_utility.trace(' PROCESS    =       '|| p_blocks(l_index).PROCESS       )    ;
      hr_utility.trace(' APPLICATION_SET_ID    =       '|| p_blocks(l_index).APPLICATION_SET_ID       )    ;
      hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| p_blocks(l_index).TRANSLATION_DISPLAY_KEY       )    ;
      hr_utility.trace('------------------------------------------------------');

      l_index := p_blocks.NEXT (l_index);

      END LOOP;

        hr_utility.trace('  p_blocks TABLE END ');
        hr_utility.trace(' *****************');

          end if;

     if (p_messages.count>0) then


         hr_utility.trace('  P_MESSAGES TABLE START ');
         hr_utility.trace(' *****************');

         l_index := p_messages.FIRST;

          LOOP
            EXIT WHEN NOT p_messages.EXISTS (l_index);


           hr_utility.trace(' MESSAGE_NAME        =   '|| p_messages(l_index).MESSAGE_NAME     );
           hr_utility.trace(' MESSAGE_LEVEL =   '|| p_messages(l_index).MESSAGE_LEVEL )    ;
           hr_utility.trace(' MESSAGE_FIELD =   '|| p_messages(l_index).MESSAGE_FIELD)    ;
           hr_utility.trace(' MESSAGE_TOKENS     =       '|| p_messages(l_index).MESSAGE_TOKENS        )    ;
           hr_utility.trace(' APPLICATION_SHORT_NAME     =       '|| p_messages(l_index).APPLICATION_SHORT_NAME        )    ;
           hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_ID        )    ;
           hr_utility.trace(' TIME_BUILDING_BLOCK_OVN  =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_OVN        )    ;
           hr_utility.trace(' TIME_ATTRIBUTE_ID     =       '|| p_messages(l_index).TIME_ATTRIBUTE_ID        )    ;
           hr_utility.trace(' TIME_ATTRIBUTE_OVN     =       '|| p_messages(l_index).TIME_ATTRIBUTE_OVN        )    ;
           hr_utility.trace(' MESSAGE_EXTENT     =       '|| p_messages(l_index).MESSAGE_EXTENT        )    ;

           l_index := p_messages.NEXT (l_index);

           END LOOP;

             hr_utility.trace('  p_messages TABLE END ');
             hr_utility.trace(' *****************');

  end if;

     if (p_attributes.count>0) then


    hr_utility.trace('  ATTRIBUTES TABLE START ');
    hr_utility.trace(' *****************');

    l_index := p_attributes.FIRST;

     LOOP
       EXIT WHEN NOT p_attributes.EXISTS (l_index);


      hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| p_attributes(l_index).TIME_ATTRIBUTE_ID);
      hr_utility.trace(' BUILDING_BLOCK_ID =   '|| p_attributes(l_index).BUILDING_BLOCK_ID )    ;
      hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| p_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
      hr_utility.trace(' ATTRIBUTE1     =       '|| p_attributes(l_index).ATTRIBUTE1        )    ;
      hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| p_attributes(l_index).ATTRIBUTE2        )    ;
      hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| p_attributes(l_index).ATTRIBUTE3        )    ;
      hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| p_attributes(l_index).ATTRIBUTE4        )    ;
      hr_utility.trace(' ATTRIBUTE5     =       '|| p_attributes(l_index).ATTRIBUTE5        )    ;
      hr_utility.trace(' ATTRIBUTE6     =       '|| p_attributes(l_index).ATTRIBUTE6        )    ;
      hr_utility.trace(' ATTRIBUTE7     =       '|| p_attributes(l_index).ATTRIBUTE7        )    ;
      hr_utility.trace(' ATTRIBUTE8     =       '|| p_attributes(l_index).ATTRIBUTE8        )    ;
      hr_utility.trace(' ATTRIBUTE9     =       '|| p_attributes(l_index).ATTRIBUTE9        )    ;
      hr_utility.trace(' ATTRIBUTE10    =       '|| p_attributes(l_index).ATTRIBUTE10       )    ;
      hr_utility.trace(' ATTRIBUTE11    =       '|| p_attributes(l_index).ATTRIBUTE11       )    ;
      hr_utility.trace(' ATTRIBUTE12    =       '|| p_attributes(l_index).ATTRIBUTE12       )    ;
      hr_utility.trace(' ATTRIBUTE13    =       '|| p_attributes(l_index).ATTRIBUTE13       )    ;
      hr_utility.trace(' ATTRIBUTE14    =       '|| p_attributes(l_index).ATTRIBUTE14       )    ;
      hr_utility.trace(' ATTRIBUTE15    =       '|| p_attributes(l_index).ATTRIBUTE15       )    ;
      hr_utility.trace(' ATTRIBUTE16    =       '|| p_attributes(l_index).ATTRIBUTE16       )    ;
      hr_utility.trace(' ATTRIBUTE17    =       '|| p_attributes(l_index).ATTRIBUTE17       )    ;
      hr_utility.trace(' ATTRIBUTE18    =       '|| p_attributes(l_index).ATTRIBUTE18       )    ;
      hr_utility.trace(' ATTRIBUTE19    =       '|| p_attributes(l_index).ATTRIBUTE19       )    ;
      hr_utility.trace(' ATTRIBUTE20    =       '|| p_attributes(l_index).ATTRIBUTE20       )    ;
      hr_utility.trace(' ATTRIBUTE21    =       '|| p_attributes(l_index).ATTRIBUTE21       )    ;
      hr_utility.trace(' ATTRIBUTE22    =       '|| p_attributes(l_index).ATTRIBUTE22       )    ;
      hr_utility.trace(' ATTRIBUTE23    =       '|| p_attributes(l_index).ATTRIBUTE23       )    ;
      hr_utility.trace(' ATTRIBUTE24    =       '|| p_attributes(l_index).ATTRIBUTE24       )    ;
      hr_utility.trace(' ATTRIBUTE25    =       '|| p_attributes(l_index).ATTRIBUTE25       )    ;
      hr_utility.trace(' ATTRIBUTE26    =       '|| p_attributes(l_index).ATTRIBUTE26       )    ;
      hr_utility.trace(' ATTRIBUTE27    =       '|| p_attributes(l_index).ATTRIBUTE27       )    ;
      hr_utility.trace(' ATTRIBUTE28    =       '|| p_attributes(l_index).ATTRIBUTE28       )    ;
      hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| p_attributes(l_index).ATTRIBUTE29       )    ;
      hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| p_attributes(l_index).ATTRIBUTE30       )    ;
      hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| p_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
      hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| p_attributes(l_index).OBJECT_VERSION_NUMBER );
      hr_utility.trace(' NEW             =       '|| p_attributes(l_index).NEW                   );
      hr_utility.trace(' CHANGED              =  '|| p_attributes(l_index).CHANGED               );
      hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| p_attributes(l_index).BLD_BLK_INFO_TYPE     );
      hr_utility.trace(' PROCESS              =  '|| p_attributes(l_index).PROCESS               );
      hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| p_attributes(l_index).BUILDING_BLOCK_OVN    );
      hr_utility.trace('------------------------------------------------------');

      l_index := p_attributes.NEXT (l_index);

      END LOOP;

        hr_utility.trace('  ATTRIBUTES TABLE END ');
        hr_utility.trace(' *****************');

          end if;



end if;



hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);


  HXC_RETRIEVE_ABSENCES.verify_view_only_absences
                  ( p_blocks => p_blocks,
                    p_attributes => p_attributes,
                    p_lock_rowid => HXC_RETRIEVE_ABSENCES.g_lock_row_id,
                    p_messages => p_messages
                 );


-- change end




if g_debug then

 hr_utility.trace('Just after verify_view_only_absences in hxctksave');
 if (p_blocks.count>0) then


    hr_utility.trace('  P_BLOCK TABLE START ');
    hr_utility.trace(' *****************');

    l_index := p_blocks.FIRST;

     LOOP
       EXIT WHEN NOT p_blocks.EXISTS (l_index);


      hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| p_blocks(l_index).TIME_BUILDING_BLOCK_ID     );
      hr_utility.trace(' TYPE =   '|| p_blocks(l_index).TYPE )    ;
      hr_utility.trace(' MEASURE =   '|| p_blocks(l_index).MEASURE)    ;
      hr_utility.trace(' UNIT_OF_MEASURE     =       '|| p_blocks(l_index).UNIT_OF_MEASURE        )    ;
      hr_utility.trace(' START_TIME     =       '|| p_blocks(l_index).START_TIME        )    ;
      hr_utility.trace(' STOP_TIME      =       '|| p_blocks(l_index).STOP_TIME        )    ;
      hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
      hr_utility.trace(' PARENT_IS_NEW     =       '|| p_blocks(l_index).PARENT_IS_NEW        )    ;
      hr_utility.trace(' SCOPE     =       '|| p_blocks(l_index).SCOPE        )    ;
      hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| p_blocks(l_index).OBJECT_VERSION_NUMBER        )    ;
      hr_utility.trace(' APPROVAL_STATUS     =       '|| p_blocks(l_index).APPROVAL_STATUS        )    ;
      hr_utility.trace(' RESOURCE_ID     =       '|| p_blocks(l_index).RESOURCE_ID        )    ;
      hr_utility.trace(' RESOURCE_TYPE    =       '|| p_blocks(l_index).RESOURCE_TYPE       )    ;
      hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| p_blocks(l_index).APPROVAL_STYLE_ID       )    ;
      hr_utility.trace(' DATE_FROM    =       '|| p_blocks(l_index).DATE_FROM       )    ;
      hr_utility.trace(' DATE_TO    =       '|| p_blocks(l_index).DATE_TO       )    ;
      hr_utility.trace(' COMMENT_TEXT    =       '|| p_blocks(l_index).COMMENT_TEXT       )    ;
      hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
      hr_utility.trace(' NEW    =       '|| p_blocks(l_index).NEW       )    ;
      hr_utility.trace(' CHANGED    =       '|| p_blocks(l_index).CHANGED       )    ;
      hr_utility.trace(' PROCESS    =       '|| p_blocks(l_index).PROCESS       )    ;
      hr_utility.trace(' APPLICATION_SET_ID    =       '|| p_blocks(l_index).APPLICATION_SET_ID       )    ;
      hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| p_blocks(l_index).TRANSLATION_DISPLAY_KEY       )    ;
      hr_utility.trace('------------------------------------------------------');

      l_index := p_blocks.NEXT (l_index);

      END LOOP;

        hr_utility.trace('  p_blocks TABLE END ');
        hr_utility.trace(' *****************');

    end if;


  if (p_messages.count>0) then


    hr_utility.trace('  P_MESSAGES TABLE START ');
    hr_utility.trace(' *****************');

    l_index := p_messages.FIRST;

     LOOP
       EXIT WHEN NOT p_messages.EXISTS (l_index);


      hr_utility.trace(' MESSAGE_NAME        =   '|| p_messages(l_index).MESSAGE_NAME     );
      hr_utility.trace(' MESSAGE_LEVEL =   '|| p_messages(l_index).MESSAGE_LEVEL )    ;
      hr_utility.trace(' MESSAGE_FIELD =   '|| p_messages(l_index).MESSAGE_FIELD)    ;
      hr_utility.trace(' MESSAGE_TOKENS     =       '|| p_messages(l_index).MESSAGE_TOKENS        )    ;
      hr_utility.trace(' APPLICATION_SHORT_NAME     =       '|| p_messages(l_index).APPLICATION_SHORT_NAME        )    ;
      hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_ID        )    ;
      hr_utility.trace(' TIME_BUILDING_BLOCK_OVN  =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_OVN        )    ;
      hr_utility.trace(' TIME_ATTRIBUTE_ID     =       '|| p_messages(l_index).TIME_ATTRIBUTE_ID        )    ;
      hr_utility.trace(' TIME_ATTRIBUTE_OVN     =       '|| p_messages(l_index).TIME_ATTRIBUTE_OVN        )    ;
      hr_utility.trace(' MESSAGE_EXTENT     =       '|| p_messages(l_index).MESSAGE_EXTENT        )    ;

      l_index := p_messages.NEXT (l_index);

      END LOOP;

        hr_utility.trace('  p_messages TABLE END ');
        hr_utility.trace(' *****************');

  end if;


     if (p_attributes.count>0) then


    hr_utility.trace('  ATTRIBUTES TABLE START ');
    hr_utility.trace(' *****************');

    l_index := p_attributes.FIRST;

     LOOP
       EXIT WHEN NOT p_attributes.EXISTS (l_index);


      hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| p_attributes(l_index).TIME_ATTRIBUTE_ID);
      hr_utility.trace(' BUILDING_BLOCK_ID =   '|| p_attributes(l_index).BUILDING_BLOCK_ID )    ;
      hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| p_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
      hr_utility.trace(' ATTRIBUTE1     =       '|| p_attributes(l_index).ATTRIBUTE1        )    ;
      hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| p_attributes(l_index).ATTRIBUTE2        )    ;
      hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| p_attributes(l_index).ATTRIBUTE3        )    ;
      hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| p_attributes(l_index).ATTRIBUTE4        )    ;
      hr_utility.trace(' ATTRIBUTE5     =       '|| p_attributes(l_index).ATTRIBUTE5        )    ;
      hr_utility.trace(' ATTRIBUTE6     =       '|| p_attributes(l_index).ATTRIBUTE6        )    ;
      hr_utility.trace(' ATTRIBUTE7     =       '|| p_attributes(l_index).ATTRIBUTE7        )    ;
      hr_utility.trace(' ATTRIBUTE8     =       '|| p_attributes(l_index).ATTRIBUTE8        )    ;
      hr_utility.trace(' ATTRIBUTE9     =       '|| p_attributes(l_index).ATTRIBUTE9        )    ;
      hr_utility.trace(' ATTRIBUTE10    =       '|| p_attributes(l_index).ATTRIBUTE10       )    ;
      hr_utility.trace(' ATTRIBUTE11    =       '|| p_attributes(l_index).ATTRIBUTE11       )    ;
      hr_utility.trace(' ATTRIBUTE12    =       '|| p_attributes(l_index).ATTRIBUTE12       )    ;
      hr_utility.trace(' ATTRIBUTE13    =       '|| p_attributes(l_index).ATTRIBUTE13       )    ;
      hr_utility.trace(' ATTRIBUTE14    =       '|| p_attributes(l_index).ATTRIBUTE14       )    ;
      hr_utility.trace(' ATTRIBUTE15    =       '|| p_attributes(l_index).ATTRIBUTE15       )    ;
      hr_utility.trace(' ATTRIBUTE16    =       '|| p_attributes(l_index).ATTRIBUTE16       )    ;
      hr_utility.trace(' ATTRIBUTE17    =       '|| p_attributes(l_index).ATTRIBUTE17       )    ;
      hr_utility.trace(' ATTRIBUTE18    =       '|| p_attributes(l_index).ATTRIBUTE18       )    ;
      hr_utility.trace(' ATTRIBUTE19    =       '|| p_attributes(l_index).ATTRIBUTE19       )    ;
      hr_utility.trace(' ATTRIBUTE20    =       '|| p_attributes(l_index).ATTRIBUTE20       )    ;
      hr_utility.trace(' ATTRIBUTE21    =       '|| p_attributes(l_index).ATTRIBUTE21       )    ;
      hr_utility.trace(' ATTRIBUTE22    =       '|| p_attributes(l_index).ATTRIBUTE22       )    ;
      hr_utility.trace(' ATTRIBUTE23    =       '|| p_attributes(l_index).ATTRIBUTE23       )    ;
      hr_utility.trace(' ATTRIBUTE24    =       '|| p_attributes(l_index).ATTRIBUTE24       )    ;
      hr_utility.trace(' ATTRIBUTE25    =       '|| p_attributes(l_index).ATTRIBUTE25       )    ;
      hr_utility.trace(' ATTRIBUTE26    =       '|| p_attributes(l_index).ATTRIBUTE26       )    ;
      hr_utility.trace(' ATTRIBUTE27    =       '|| p_attributes(l_index).ATTRIBUTE27       )    ;
      hr_utility.trace(' ATTRIBUTE28    =       '|| p_attributes(l_index).ATTRIBUTE28       )    ;
      hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| p_attributes(l_index).ATTRIBUTE29       )    ;
      hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| p_attributes(l_index).ATTRIBUTE30       )    ;
      hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| p_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
      hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| p_attributes(l_index).OBJECT_VERSION_NUMBER );
      hr_utility.trace(' NEW             =       '|| p_attributes(l_index).NEW                   );
      hr_utility.trace(' CHANGED              =  '|| p_attributes(l_index).CHANGED               );
      hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| p_attributes(l_index).BLD_BLK_INFO_TYPE     );
      hr_utility.trace(' PROCESS              =  '|| p_attributes(l_index).PROCESS               );
      hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| p_attributes(l_index).BUILDING_BLOCK_OVN    );
      hr_utility.trace('------------------------------------------------------');

      l_index := p_attributes.NEXT (l_index);

      END LOOP;

        hr_utility.trace('  ATTRIBUTES TABLE END ');
        hr_utility.trace(' *****************');

          end if;



end if;


/* fix for bug 6130457 */

 l_timecard_blocks.delete;
 l_day_blocks.delete;
 l_detail_blocks.delete;

 /* end of fix for bug 6130457 */

/* fix by senthil for bug 5099360*/
  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );
/* end of fix for bug 5099360*/

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  hxc_timecard_validation.data_set_validation
   (p_blocks       => p_blocks
   ,p_messages     => p_messages
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--  At this point of the process
--  we know if the timecard needs to be in error.
--
  -- get all the errors
  p_messages := hxc_timecard_message_helper.getMessages;
/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',70);
  END IF;
*/
  hxc_timekeeper_errors.rollback_tc_or_set_err_status
     (p_message_table	=> p_messages
     ,p_blocks          => p_blocks
     ,p_attributes	=> p_attributes
     ,p_rollback	=> l_rollback
     ,p_status_error	=> l_status_error);

  --p_messages.delete;
--
-- if the rollback is set then we need to execute it
--
  IF l_rollback THEN
    -- we are setting the error to be
    -- send
    raise e_timekeeper_check;

  ELSE
   -- p_messages.delete;
  --
  --  Store blocks and attributes
  --

    -- get all the errors before the deposit
    -- in order to main the -ve ids
    -- at this point p_messages is not delete
    -- so we still have the full message structures

    hxc_timecard_deposit.execute
    (p_blocks           => p_blocks
    ,p_attributes       => p_attributes
    ,p_timecard_blocks  => l_timecard_blocks
    ,p_day_blocks       => l_day_blocks
    ,p_detail_blocks    => l_detail_blocks
    ,p_messages 	=> p_messages
    ,p_transaction_info => l_transaction_info
    );

    p_timecard_id :=
       p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).time_building_block_id;
    p_timecard_ovn:=
       p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).object_version_number;

  hxc_timecard_audit.maintain_latest_details
  (p_blocks        => p_blocks );

  /* Bug 8888904 */

  hxc_timecard_audit.maintain_rdb_snapshot
  (p_blocks => p_blocks,
   p_attributes => p_attributes);


 IF p_timekeeper_id IS NOT NULL and
    p_tk_audit_enabled = 'Y'    and
    p_tk_notify_to <> 'NONE' THEN

    open c_previous_timecard(p_timecard_id);
    fetch c_previous_timecard into l_previous_tk_item_key,l_previous_tk_item_type;
    if (c_previous_timecard%found)  then

   --Cancel notifications for TK Audit

	hxc_timekeeper_wf_pkg.cancel_previous_notifications
	( p_tk_audit_item_type => l_previous_tk_item_type
	 ,p_tk_audit_item_key =>  l_previous_tk_item_key
	);

    end if;
    close c_previous_timecard;

    l_item_key :=
	  hxc_timekeeper_wf_pkg.begin_audit_process
	  (p_timecard_id    =>  p_timecard_id
	  ,p_timecard_ovn   =>  p_timecard_ovn
	  ,p_resource_id    =>  p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).resource_id
	  ,p_timekeeper_id  =>  p_timekeeper_id
	  ,p_tk_audit_enabled => p_tk_audit_enabled
	  ,p_tk_notify_to   =>  p_tk_notify_to
	  ,p_tk_notify_type =>  p_tk_notify_type
          ,p_property_table => l_timecard_props
           );
 END IF;

 IF l_item_key IS NOT NULL THEN
    tk_audit_process_name := 'HXC_TK_AUDIT_PROCESS';
    tk_audit_item_type    := 'HXCTKWF';
 END IF;

    --hxc_timecard_message_helper.processerrors
    --(p_messages => p_messages);

    --
    -- Maintain summary table
    --

   hxc_timecard_summary_api.timecard_deposit
      (p_blocks => p_blocks
      ,p_approval_item_type     => NULL
      ,p_approval_process_name  => NULL
      ,p_approval_item_key      => NULL
      ,p_tk_audit_item_type     => tk_audit_item_type
      ,p_tk_audit_process_name  => tk_audit_process_name
      ,p_tk_audit_item_key      => l_item_key
       );

  hxc_timecard_audit.audit_deposit
    (p_transaction_info => l_transaction_info
    ,p_messages => p_messages
    );


    hr_utility.trace('Calling maintain_errors');

        hxc_timekeeper_errors.maintain_errors
      	(p_messages 	=> p_messages
      	,p_timecard_id  => p_timecard_id
  	,p_timecard_ovn => p_timecard_ovn);

    --
    -- store error
    --
    -- get all the errors
--    p_messages := hxc_timecard_message_helper.getMessages;

    -- OTL-Absences Integration (Bug 8779478)
    -- Modified code to rollback in case on online retrieval errors (Bug 8888138)
    IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
      IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors) THEN

       IF g_debug THEN
         hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMEKEEPER.SAVE_TIMECARD');
       END IF;

       l_abs_ret_messages:= HXC_MESSAGE_TABLE_TYPE();

       l_resource_id     := p_blocks(l_timecard_index).resource_id;
       l_tc_start        := fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time);
       l_tc_stop         := fnd_date.canonical_to_date(p_blocks(l_timecard_index).stop_time);
       l_approval_status := p_blocks(l_timecard_index).approval_status;


       HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES (l_resource_id,
  	  			            l_tc_start,
  					    l_tc_stop,
  					    l_approval_status,
  					    l_abs_ret_messages);

       IF g_debug THEN
  	hr_utility.trace('ABS:p_messages.COUNT = '||l_abs_ret_messages.COUNT);
       END IF;

       IF l_abs_ret_messages.COUNT > 0 THEN
	    IF g_debug THEN
	      hr_utility.trace('ABS: Online Retrieval failed - Rollback changes');
	    END IF;

	    rollback to TK_SAVE_SAVEPOINT;

	    hxc_timekeeper_errors.maintain_errors
	    	          	(p_messages 	=> l_abs_ret_messages
	    	          	,p_timecard_id  => p_timecard_id
  	                	,p_timecard_ovn => p_timecard_ovn);

       END IF;

      END IF;
    END IF;



  END IF;

--dbms_profiler.stop_profiler;

EXCEPTION
  WHEN e_timekeeper_check then
    hxc_timecard_message_helper.prepareErrors;
    rollback;

End save_timecard;


----------------------------------------------------------------------------
-- Submit Timecard Procedure
-- This procedure....
----------------------------------------------------------------------------

Procedure submit_timecard
            (p_blocks           in out nocopy HXC_BLOCK_TABLE_TYPE
            ,p_attributes       in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages         in out nocopy HXC_MESSAGE_TABLE_TYPE
            ,p_timecard_id        out nocopy hxc_time_building_blocks.time_building_block_id%type
            ,p_timecard_ovn       out nocopy hxc_time_building_blocks.object_version_number%type
	    ,p_timekeeper_id    in hxc_time_building_blocks.resource_id%type DEFAULT NULL
	    ,p_tk_audit_enabled	in VARCHAR2 DEFAULT NULL
 	    ,p_tk_notify_to     in VARCHAR2 DEFAULT NULL
	    ,p_tk_notify_type   in VARCHAR2 DEFAULT NULL
            ) IS

cursor c_previous_timecard(
			      p_timecard_id in hxc_timecard_summary.timecard_id%type) is
  select tk_audit_item_key,tk_audit_item_type
    from hxc_timecard_summary
   where timecard_id = p_timecard_id;


l_timecard_blocks  hxc_timecard.block_list;
l_day_blocks       hxc_timecard.block_list;
l_detail_blocks    hxc_timecard.block_list;
l_transaction_info hxc_timecard.transaction_info;
l_timecard_props   hxc_timecard_prop_table_type;

l_proc             varchar2(50) := g_package||'.SUBMIT_TIMECARD';
l_can_deposit      boolean := true;
l_resubmit         varchar2(10) := hxc_timecard_deposit_common.c_no;
l_timecard_index   number;

l_rollback	   BOOLEAN := FALSE;

l_status_error	   BOOLEAN := FALSE;

l_item_key            WF_ITEMS.ITEM_KEY%TYPE :=NULL;
tk_item_key	      WF_ITEMS.ITEM_KEY%TYPE :=NULL;
tk_audit_item_type    WF_ITEMS.ITEM_TYPE%TYPE :=NULL;
tk_audit_process_name  VARCHAR2(50) :=NULL;

l_previous_tk_item_key   hxc_timecard_summary.tk_audit_item_key%type;
l_previous_tk_item_type  hxc_timecard_summary.tk_audit_item_type%type;

l_index	NUMBER;

l_resource_id      NUMBER;
l_tc_start         DATE;
l_tc_stop          DATE;
l_approval_status  VARCHAR2(20);

l_abs_ret_messages	HXC_MESSAGE_TABLE_TYPE;

BEGIN

--
-- Fnd initialization
--
  fnd_msg_pub.initialize;

g_debug:= hr_utility.debug_enabled;

----------------------------------------------------------------------------
--  Timecard Preparation
----------------------------------------------------------------------------

  hxc_timecard_block_utils.initialize_timecard_index;

  hxc_timecard_message_helper.initializeerrors;

  p_messages := hxc_message_table_type ();

  -- set savepoint
  savepoint TK_SUB_SAVEPOINT;
--
--  Check input parameters
--

  hxc_deposit_checks.check_inputs
    (p_blocks 	    => p_blocks
    ,p_attributes   => p_attributes
    ,p_deposit_mode => hxc_timecard_deposit_common.c_submit
    ,p_template     => hxc_timecard_deposit_common.c_no
    ,p_messages     => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--  Determine if this is a resubmitted timecard
--
  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

  if(hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).date_to)
               = hr_general.end_of_time)
  then
    l_resubmit := hxc_timecard_approval.is_timecard_resubmitted
                   (p_blocks(l_timecard_index).time_building_block_id
                   ,p_blocks(l_timecard_index).object_version_number
                   ,p_blocks(l_timecard_index).resource_id
                   ,hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).start_time)
                   ,hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).stop_time)
                   );
  else
    l_resubmit := hxc_timecard_deposit_common.c_delete;
  end if;

--
--  Obtain the timecard properties
--  This might be changed to send
--  this information in from the
--  middle tier, to avoid another
--  pref evaluation
--

  hxc_timecard_properties.get_preference_properties
    (p_validate             => hxc_timecard_deposit_common.c_yes
    ,p_resource_id          => p_blocks(l_timecard_index).resource_id
    ,p_timecard_start_time  => fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time)
    ,p_timecard_stop_time   => fnd_date.canonical_to_date(p_blocks(l_timecard_index).stop_time)
    ,p_for_timecard         => false
    ,p_messages             => p_messages
    ,p_property_table       => l_timecard_props
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--  Sort the blocks - needed for deposit
--  and all sorts of short cuts!
--

  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );

--
--  Main deposit controls
--  ^^^^^^^^^^^^^^^^^^^^^
--  Reform time data, if required
--  e.g Denormalize time data
--

  hxc_block_attribute_update.denormalize_time
   (p_blocks => p_blocks
   ,p_mode => 'ADD'
   );

--
--  Perform basic checks, e.g.
--  Are there any other timecards for this period?
--

  hxc_deposit_checks.perform_checks
      (p_blocks         => p_blocks
      ,p_attributes     => p_attributes
      ,p_timecard_props => l_timecard_props
      ,p_days           => l_day_blocks
      ,p_details        => l_detail_blocks
      ,p_messages       => p_messages
      );

  hxc_timecard_message_helper.processerrors
      (p_messages => p_messages);

--
--  Add the security attributes
--  ARR: 115.28 change, added p_messages
--
  hxc_security.add_security_attribute
      (p_blocks         => p_blocks,
       p_attributes     => p_attributes,
       p_timecard_props => l_timecard_props,
       p_messages       => p_messages
      );

  hxc_timecard_message_helper.processerrors
      (p_messages => p_messages);
--
--  Translate any aliases
--
  hxc_timecard_deposit_common.alias_translation
   (p_blocks     => p_blocks
   ,p_attributes => p_attributes
   ,p_messages   => p_messages
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
--  Set the block and attribute update process flags
--  Based on the data sent and in the db
--
  hxc_block_attribute_update.set_process_flags
    (p_blocks     => p_blocks
    ,p_attributes => p_attributes
    );

--
--  Removed any deleted attributes
--

  hxc_timecard_attribute_utils.remove_deleted_attributes
    (p_attributes => p_attributes);


--
--  Perform process checks
--
  hxc_deposit_checks.perform_process_checks
    (p_blocks         => p_blocks
    ,p_attributes     => p_attributes
    ,p_timecard_props => l_timecard_props
    ,p_days           => l_day_blocks
    ,p_details        => l_detail_blocks
    ,p_template       => hxc_timecard_deposit_common.c_no
    ,p_deposit_mode   => hxc_timecard_deposit_common.c_submit
    ,p_messages       => p_messages
    );

  --in case of rejected TC again resubmit so remove the error raised
  --for SS as TK dosn't work in same way .
  --set process/changed flag to 'Y'.

  IF p_messages.count > 0 THEN

    hxc_timekeeper_utilities.check_msg_set_process_flag
			  (  p_blocks	   => p_blocks
			    ,p_attributes  => p_attributes
			    ,p_messages    => p_messages
			   );
  END IF;


  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
--
--  Validate blocks, attributes
--
/*
  hxc_timecard_validation.deposit_validation
    (p_blocks        => p_blocks
    ,p_attributes    => p_attributes
    ,p_messages      => p_messages
    ,p_props         => l_timecard_props
    ,p_deposit_mode  => hxc_timecard_deposit_common.c_submit
    ,p_template      => hxc_timecard_deposit_common.c_no
    ,p_resubmit      => l_resubmit
    ,p_can_deposit   => l_can_deposit
    );
*/



  hxc_timecard_validation.recipients_update_validation
    (p_blocks        => p_blocks
    ,p_attributes    => p_attributes
    ,p_messages      => p_messages
    ,p_props         => l_timecard_props
    ,p_deposit_mode  => hxc_timecard_deposit_common.c_submit
    ,p_resubmit      => l_resubmit);

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);


  hxc_timecard_validation.data_set_validation
   (p_blocks       => p_blocks
   ,p_messages     => p_messages
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);


--
-- Validate the set up for the user
-- Do this only for timecards, and not
-- for templates.
--
/*
  hxc_timecard_deposit_common.validate_setup
       (p_deposit_mode => hxc_timecard_deposit_common.c_submit
       ,p_blocks       => p_blocks
       ,p_attributes   => p_attributes
       ,p_messages     => p_messages
       );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
*/
--
--  Reform time data, if required
--  e.g Denormalize time data
--
  hxc_block_attribute_update.denormalize_time
   (p_blocks => p_blocks
   ,p_mode   => 'REMOVE'
   );

--
--  At this point of the process
--  we know if the timecard needs to be in error.
--


/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',70);
  END IF;
*/


 /* Added for bug 8775740 HR Absence Integration

  This pkg call is used to validate absence entries against the
  Absences Pref setting for the particular resource_id

  */
 -- Change start

   if g_debug then

      hr_utility.trace('Just before verify_view_only_absences in hxctksubmit');
      if (p_blocks.count>0) then


         hr_utility.trace('  P_BLOCK TABLE START ');
         hr_utility.trace(' *****************');

         l_index := p_blocks.FIRST;

          LOOP
            EXIT WHEN NOT p_blocks.EXISTS (l_index);


           hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| p_blocks(l_index).TIME_BUILDING_BLOCK_ID     );
           hr_utility.trace(' TYPE =   '|| p_blocks(l_index).TYPE )    ;
           hr_utility.trace(' MEASURE =   '|| p_blocks(l_index).MEASURE)    ;
           hr_utility.trace(' UNIT_OF_MEASURE     =       '|| p_blocks(l_index).UNIT_OF_MEASURE        )    ;
           hr_utility.trace(' START_TIME     =       '|| p_blocks(l_index).START_TIME        )    ;
           hr_utility.trace(' STOP_TIME      =       '|| p_blocks(l_index).STOP_TIME        )    ;
           hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
           hr_utility.trace(' PARENT_IS_NEW     =       '|| p_blocks(l_index).PARENT_IS_NEW        )    ;
           hr_utility.trace(' SCOPE     =       '|| p_blocks(l_index).SCOPE        )    ;
           hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| p_blocks(l_index).OBJECT_VERSION_NUMBER        )    ;
           hr_utility.trace(' APPROVAL_STATUS     =       '|| p_blocks(l_index).APPROVAL_STATUS        )    ;
           hr_utility.trace(' RESOURCE_ID     =       '|| p_blocks(l_index).RESOURCE_ID        )    ;
           hr_utility.trace(' RESOURCE_TYPE    =       '|| p_blocks(l_index).RESOURCE_TYPE       )    ;
           hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| p_blocks(l_index).APPROVAL_STYLE_ID       )    ;
           hr_utility.trace(' DATE_FROM    =       '|| p_blocks(l_index).DATE_FROM       )    ;
           hr_utility.trace(' DATE_TO    =       '|| p_blocks(l_index).DATE_TO       )    ;
           hr_utility.trace(' COMMENT_TEXT    =       '|| p_blocks(l_index).COMMENT_TEXT       )    ;
           hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
           hr_utility.trace(' NEW    =       '|| p_blocks(l_index).NEW       )    ;
           hr_utility.trace(' CHANGED    =       '|| p_blocks(l_index).CHANGED       )    ;
           hr_utility.trace(' PROCESS    =       '|| p_blocks(l_index).PROCESS       )    ;
           hr_utility.trace(' APPLICATION_SET_ID    =       '|| p_blocks(l_index).APPLICATION_SET_ID       )    ;
           hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| p_blocks(l_index).TRANSLATION_DISPLAY_KEY       )    ;
           hr_utility.trace('------------------------------------------------------');

           l_index := p_blocks.NEXT (l_index);

           END LOOP;

             hr_utility.trace('  p_blocks TABLE END ');
             hr_utility.trace(' *****************');

               end if;


          if (p_messages.count>0) then


	      hr_utility.trace('  P_MESSAGES TABLE START ');
	      hr_utility.trace(' *****************');

	      l_index := p_messages.FIRST;

	       LOOP
	         EXIT WHEN NOT p_messages.EXISTS (l_index);


	        hr_utility.trace(' MESSAGE_NAME        =   '|| p_messages(l_index).MESSAGE_NAME     );
	        hr_utility.trace(' MESSAGE_LEVEL =   '|| p_messages(l_index).MESSAGE_LEVEL )    ;
	        hr_utility.trace(' MESSAGE_FIELD =   '|| p_messages(l_index).MESSAGE_FIELD)    ;
	        hr_utility.trace(' MESSAGE_TOKENS     =       '|| p_messages(l_index).MESSAGE_TOKENS        )    ;
	        hr_utility.trace(' APPLICATION_SHORT_NAME     =       '|| p_messages(l_index).APPLICATION_SHORT_NAME        )    ;
	        hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_ID        )    ;
	        hr_utility.trace(' TIME_BUILDING_BLOCK_OVN  =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_OVN        )    ;
	        hr_utility.trace(' TIME_ATTRIBUTE_ID     =       '|| p_messages(l_index).TIME_ATTRIBUTE_ID        )    ;
	        hr_utility.trace(' TIME_ATTRIBUTE_OVN     =       '|| p_messages(l_index).TIME_ATTRIBUTE_OVN        )    ;
	        hr_utility.trace(' MESSAGE_EXTENT     =       '|| p_messages(l_index).MESSAGE_EXTENT        )    ;

	        l_index := p_messages.NEXT (l_index);

	        END LOOP;

	          hr_utility.trace('  p_messages TABLE END ');
	          hr_utility.trace(' *****************');

          end if;



          if (p_attributes.count>0) then


         hr_utility.trace('  ATTRIBUTES TABLE START ');
         hr_utility.trace(' *****************');

         l_index := p_attributes.FIRST;

          LOOP
            EXIT WHEN NOT p_attributes.EXISTS (l_index);


           hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| p_attributes(l_index).TIME_ATTRIBUTE_ID);
           hr_utility.trace(' BUILDING_BLOCK_ID =   '|| p_attributes(l_index).BUILDING_BLOCK_ID )    ;
           hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| p_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
           hr_utility.trace(' ATTRIBUTE1     =       '|| p_attributes(l_index).ATTRIBUTE1        )    ;
           hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| p_attributes(l_index).ATTRIBUTE2        )    ;
           hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| p_attributes(l_index).ATTRIBUTE3        )    ;
           hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| p_attributes(l_index).ATTRIBUTE4        )    ;
           hr_utility.trace(' ATTRIBUTE5     =       '|| p_attributes(l_index).ATTRIBUTE5        )    ;
           hr_utility.trace(' ATTRIBUTE6     =       '|| p_attributes(l_index).ATTRIBUTE6        )    ;
           hr_utility.trace(' ATTRIBUTE7     =       '|| p_attributes(l_index).ATTRIBUTE7        )    ;
           hr_utility.trace(' ATTRIBUTE8     =       '|| p_attributes(l_index).ATTRIBUTE8        )    ;
           hr_utility.trace(' ATTRIBUTE9     =       '|| p_attributes(l_index).ATTRIBUTE9        )    ;
           hr_utility.trace(' ATTRIBUTE10    =       '|| p_attributes(l_index).ATTRIBUTE10       )    ;
           hr_utility.trace(' ATTRIBUTE11    =       '|| p_attributes(l_index).ATTRIBUTE11       )    ;
           hr_utility.trace(' ATTRIBUTE12    =       '|| p_attributes(l_index).ATTRIBUTE12       )    ;
           hr_utility.trace(' ATTRIBUTE13    =       '|| p_attributes(l_index).ATTRIBUTE13       )    ;
           hr_utility.trace(' ATTRIBUTE14    =       '|| p_attributes(l_index).ATTRIBUTE14       )    ;
           hr_utility.trace(' ATTRIBUTE15    =       '|| p_attributes(l_index).ATTRIBUTE15       )    ;
           hr_utility.trace(' ATTRIBUTE16    =       '|| p_attributes(l_index).ATTRIBUTE16       )    ;
           hr_utility.trace(' ATTRIBUTE17    =       '|| p_attributes(l_index).ATTRIBUTE17       )    ;
           hr_utility.trace(' ATTRIBUTE18    =       '|| p_attributes(l_index).ATTRIBUTE18       )    ;
           hr_utility.trace(' ATTRIBUTE19    =       '|| p_attributes(l_index).ATTRIBUTE19       )    ;
           hr_utility.trace(' ATTRIBUTE20    =       '|| p_attributes(l_index).ATTRIBUTE20       )    ;
           hr_utility.trace(' ATTRIBUTE21    =       '|| p_attributes(l_index).ATTRIBUTE21       )    ;
           hr_utility.trace(' ATTRIBUTE22    =       '|| p_attributes(l_index).ATTRIBUTE22       )    ;
           hr_utility.trace(' ATTRIBUTE23    =       '|| p_attributes(l_index).ATTRIBUTE23       )    ;
           hr_utility.trace(' ATTRIBUTE24    =       '|| p_attributes(l_index).ATTRIBUTE24       )    ;
           hr_utility.trace(' ATTRIBUTE25    =       '|| p_attributes(l_index).ATTRIBUTE25       )    ;
           hr_utility.trace(' ATTRIBUTE26    =       '|| p_attributes(l_index).ATTRIBUTE26       )    ;
           hr_utility.trace(' ATTRIBUTE27    =       '|| p_attributes(l_index).ATTRIBUTE27       )    ;
           hr_utility.trace(' ATTRIBUTE28    =       '|| p_attributes(l_index).ATTRIBUTE28       )    ;
           hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| p_attributes(l_index).ATTRIBUTE29       )    ;
           hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| p_attributes(l_index).ATTRIBUTE30       )    ;
           hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| p_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
           hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| p_attributes(l_index).OBJECT_VERSION_NUMBER );
           hr_utility.trace(' NEW             =       '|| p_attributes(l_index).NEW                   );
           hr_utility.trace(' CHANGED              =  '|| p_attributes(l_index).CHANGED               );
           hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| p_attributes(l_index).BLD_BLK_INFO_TYPE     );
           hr_utility.trace(' PROCESS              =  '|| p_attributes(l_index).PROCESS               );
           hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| p_attributes(l_index).BUILDING_BLOCK_OVN    );
           hr_utility.trace('------------------------------------------------------');

           l_index := p_attributes.NEXT (l_index);

           END LOOP;

             hr_utility.trace('  ATTRIBUTES TABLE END ');
             hr_utility.trace(' *****************');

               end if;



     end if;


   HXC_RETRIEVE_ABSENCES.verify_view_only_absences
                   ( p_blocks => p_blocks,
                     p_attributes => p_attributes,
                     p_lock_rowid => HXC_RETRIEVE_ABSENCES.g_lock_row_id,
                     p_messages => p_messages
                  );

   if g_debug then

         hr_utility.trace('Just after verify_view_only_absences in hxctksubmit');
         if (p_blocks.count>0) then


            hr_utility.trace('  P_BLOCK TABLE START ');
            hr_utility.trace(' *****************');

            l_index := p_blocks.FIRST;

             LOOP
               EXIT WHEN NOT p_blocks.EXISTS (l_index);


              hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| p_blocks(l_index).TIME_BUILDING_BLOCK_ID     );
              hr_utility.trace(' TYPE =   '|| p_blocks(l_index).TYPE )    ;
              hr_utility.trace(' MEASURE =   '|| p_blocks(l_index).MEASURE)    ;
              hr_utility.trace(' UNIT_OF_MEASURE     =       '|| p_blocks(l_index).UNIT_OF_MEASURE        )    ;
              hr_utility.trace(' START_TIME     =       '|| p_blocks(l_index).START_TIME        )    ;
              hr_utility.trace(' STOP_TIME      =       '|| p_blocks(l_index).STOP_TIME        )    ;
              hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
              hr_utility.trace(' PARENT_IS_NEW     =       '|| p_blocks(l_index).PARENT_IS_NEW        )    ;
              hr_utility.trace(' SCOPE     =       '|| p_blocks(l_index).SCOPE        )    ;
              hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| p_blocks(l_index).OBJECT_VERSION_NUMBER        )    ;
              hr_utility.trace(' APPROVAL_STATUS     =       '|| p_blocks(l_index).APPROVAL_STATUS        )    ;
              hr_utility.trace(' RESOURCE_ID     =       '|| p_blocks(l_index).RESOURCE_ID        )    ;
              hr_utility.trace(' RESOURCE_TYPE    =       '|| p_blocks(l_index).RESOURCE_TYPE       )    ;
              hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| p_blocks(l_index).APPROVAL_STYLE_ID       )    ;
              hr_utility.trace(' DATE_FROM    =       '|| p_blocks(l_index).DATE_FROM       )    ;
              hr_utility.trace(' DATE_TO    =       '|| p_blocks(l_index).DATE_TO       )    ;
              hr_utility.trace(' COMMENT_TEXT    =       '|| p_blocks(l_index).COMMENT_TEXT       )    ;
              hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
              hr_utility.trace(' NEW    =       '|| p_blocks(l_index).NEW       )    ;
              hr_utility.trace(' CHANGED    =       '|| p_blocks(l_index).CHANGED       )    ;
              hr_utility.trace(' PROCESS    =       '|| p_blocks(l_index).PROCESS       )    ;
              hr_utility.trace(' APPLICATION_SET_ID    =       '|| p_blocks(l_index).APPLICATION_SET_ID       )    ;
              hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| p_blocks(l_index).TRANSLATION_DISPLAY_KEY       )    ;
              hr_utility.trace('------------------------------------------------------');

              l_index := p_blocks.NEXT (l_index);

              END LOOP;

                hr_utility.trace('  p_blocks TABLE END ');
                hr_utility.trace(' *****************');

                  end if;


             if (p_messages.count>0) then


	         hr_utility.trace('  P_MESSAGES TABLE START ');
	         hr_utility.trace(' *****************');

	         l_index := p_messages.FIRST;

	          LOOP
	            EXIT WHEN NOT p_messages.EXISTS (l_index);


	           hr_utility.trace(' MESSAGE_NAME        =   '|| p_messages(l_index).MESSAGE_NAME     );
	           hr_utility.trace(' MESSAGE_LEVEL =   '|| p_messages(l_index).MESSAGE_LEVEL )    ;
	           hr_utility.trace(' MESSAGE_FIELD =   '|| p_messages(l_index).MESSAGE_FIELD)    ;
	           hr_utility.trace(' MESSAGE_TOKENS     =       '|| p_messages(l_index).MESSAGE_TOKENS        )    ;
	           hr_utility.trace(' APPLICATION_SHORT_NAME     =       '|| p_messages(l_index).APPLICATION_SHORT_NAME        )    ;
	           hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_ID        )    ;
	           hr_utility.trace(' TIME_BUILDING_BLOCK_OVN  =       '|| p_messages(l_index).TIME_BUILDING_BLOCK_OVN        )    ;
	           hr_utility.trace(' TIME_ATTRIBUTE_ID     =       '|| p_messages(l_index).TIME_ATTRIBUTE_ID        )    ;
	           hr_utility.trace(' TIME_ATTRIBUTE_OVN     =       '|| p_messages(l_index).TIME_ATTRIBUTE_OVN        )    ;
	           hr_utility.trace(' MESSAGE_EXTENT     =       '|| p_messages(l_index).MESSAGE_EXTENT        )    ;

	           l_index := p_messages.NEXT (l_index);

	           END LOOP;

	             hr_utility.trace('  p_messages TABLE END ');
	             hr_utility.trace(' *****************');

             end if;


             if (p_attributes.count>0) then


            hr_utility.trace('  ATTRIBUTES TABLE START ');
            hr_utility.trace(' *****************');

            l_index := p_attributes.FIRST;

             LOOP
               EXIT WHEN NOT p_attributes.EXISTS (l_index);


              hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| p_attributes(l_index).TIME_ATTRIBUTE_ID);
              hr_utility.trace(' BUILDING_BLOCK_ID =   '|| p_attributes(l_index).BUILDING_BLOCK_ID )    ;
              hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| p_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
              hr_utility.trace(' ATTRIBUTE1     =       '|| p_attributes(l_index).ATTRIBUTE1        )    ;
              hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| p_attributes(l_index).ATTRIBUTE2        )    ;
              hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| p_attributes(l_index).ATTRIBUTE3        )    ;
              hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| p_attributes(l_index).ATTRIBUTE4        )    ;
              hr_utility.trace(' ATTRIBUTE5     =       '|| p_attributes(l_index).ATTRIBUTE5        )    ;
              hr_utility.trace(' ATTRIBUTE6     =       '|| p_attributes(l_index).ATTRIBUTE6        )    ;
              hr_utility.trace(' ATTRIBUTE7     =       '|| p_attributes(l_index).ATTRIBUTE7        )    ;
              hr_utility.trace(' ATTRIBUTE8     =       '|| p_attributes(l_index).ATTRIBUTE8        )    ;
              hr_utility.trace(' ATTRIBUTE9     =       '|| p_attributes(l_index).ATTRIBUTE9        )    ;
              hr_utility.trace(' ATTRIBUTE10    =       '|| p_attributes(l_index).ATTRIBUTE10       )    ;
              hr_utility.trace(' ATTRIBUTE11    =       '|| p_attributes(l_index).ATTRIBUTE11       )    ;
              hr_utility.trace(' ATTRIBUTE12    =       '|| p_attributes(l_index).ATTRIBUTE12       )    ;
              hr_utility.trace(' ATTRIBUTE13    =       '|| p_attributes(l_index).ATTRIBUTE13       )    ;
              hr_utility.trace(' ATTRIBUTE14    =       '|| p_attributes(l_index).ATTRIBUTE14       )    ;
              hr_utility.trace(' ATTRIBUTE15    =       '|| p_attributes(l_index).ATTRIBUTE15       )    ;
              hr_utility.trace(' ATTRIBUTE16    =       '|| p_attributes(l_index).ATTRIBUTE16       )    ;
              hr_utility.trace(' ATTRIBUTE17    =       '|| p_attributes(l_index).ATTRIBUTE17       )    ;
              hr_utility.trace(' ATTRIBUTE18    =       '|| p_attributes(l_index).ATTRIBUTE18       )    ;
              hr_utility.trace(' ATTRIBUTE19    =       '|| p_attributes(l_index).ATTRIBUTE19       )    ;
              hr_utility.trace(' ATTRIBUTE20    =       '|| p_attributes(l_index).ATTRIBUTE20       )    ;
              hr_utility.trace(' ATTRIBUTE21    =       '|| p_attributes(l_index).ATTRIBUTE21       )    ;
              hr_utility.trace(' ATTRIBUTE22    =       '|| p_attributes(l_index).ATTRIBUTE22       )    ;
              hr_utility.trace(' ATTRIBUTE23    =       '|| p_attributes(l_index).ATTRIBUTE23       )    ;
              hr_utility.trace(' ATTRIBUTE24    =       '|| p_attributes(l_index).ATTRIBUTE24       )    ;
              hr_utility.trace(' ATTRIBUTE25    =       '|| p_attributes(l_index).ATTRIBUTE25       )    ;
              hr_utility.trace(' ATTRIBUTE26    =       '|| p_attributes(l_index).ATTRIBUTE26       )    ;
              hr_utility.trace(' ATTRIBUTE27    =       '|| p_attributes(l_index).ATTRIBUTE27       )    ;
              hr_utility.trace(' ATTRIBUTE28    =       '|| p_attributes(l_index).ATTRIBUTE28       )    ;
              hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| p_attributes(l_index).ATTRIBUTE29       )    ;
              hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| p_attributes(l_index).ATTRIBUTE30       )    ;
              hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| p_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
              hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| p_attributes(l_index).OBJECT_VERSION_NUMBER );
              hr_utility.trace(' NEW             =       '|| p_attributes(l_index).NEW                   );
              hr_utility.trace(' CHANGED              =  '|| p_attributes(l_index).CHANGED               );
              hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| p_attributes(l_index).BLD_BLK_INFO_TYPE     );
              hr_utility.trace(' PROCESS              =  '|| p_attributes(l_index).PROCESS               );
              hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| p_attributes(l_index).BUILDING_BLOCK_OVN    );
              hr_utility.trace('------------------------------------------------------');

              l_index := p_attributes.NEXT (l_index);

              END LOOP;

                hr_utility.trace('  ATTRIBUTES TABLE END ');
                hr_utility.trace(' *****************');

                  end if;



        end if;



     hxc_timecard_message_helper.processerrors
     (p_messages => p_messages);

  -- change end
  -- Bug 8888138
  --  Get_Messages should be used after verify_view_only
  -- get all the errors
  p_messages := hxc_timecard_message_helper.getMessages;


  hxc_timekeeper_errors.rollback_tc_or_set_err_status
     (p_message_table	=> p_messages
     ,p_blocks          => p_blocks
     ,p_attributes	=> p_attributes
     ,p_rollback	=> l_rollback
     ,p_status_error	=> l_status_error);

  --p_messages.delete;
  -- at this point we have the full message structure
  -- so we can pass it to deposit to main the -ve ids
  -- in the error table.

--
--  Store blocks and attributes
--
  hxc_timecard_deposit.execute
   (p_blocks          => p_blocks
   ,p_attributes      => p_attributes
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   ,p_messages        => p_messages
   ,p_transaction_info=> l_transaction_info
   );


  p_timecard_id :=
       p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).time_building_block_id;
  p_timecard_ovn:=
       p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).object_version_number;

  --hxc_timecard_message_helper.processerrors
  --  (p_messages => p_messages);

  hxc_timecard_audit.maintain_latest_details
  (p_blocks        => p_blocks );

  /* Bug  8888904 */

  hxc_timecard_audit.maintain_rdb_snapshot
      (p_blocks => p_blocks,
     p_attributes => p_attributes);


 IF p_timekeeper_id IS NOT NULL and
    p_tk_audit_enabled = 'Y'    and
    p_tk_notify_to <> 'NONE' THEN

    open c_previous_timecard(p_timecard_id);
    fetch c_previous_timecard into l_previous_tk_item_key,l_previous_tk_item_type;
    if (c_previous_timecard%found)  then

   --Cancel notifications for TK Audit

	hxc_timekeeper_wf_pkg.cancel_previous_notifications
	( p_tk_audit_item_type => l_previous_tk_item_type
	 ,p_tk_audit_item_key =>  l_previous_tk_item_key
	);

    end if;
    close c_previous_timecard;

    tk_item_key :=
	  hxc_timekeeper_wf_pkg.begin_audit_process
	  (p_timecard_id   =>  p_timecard_id
	  ,p_timecard_ovn  =>  p_timecard_ovn
	  ,p_resource_id   =>  p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).resource_id
	  ,p_timekeeper_id => p_timekeeper_id
	  ,p_tk_audit_enabled => p_tk_audit_enabled
	  ,p_tk_notify_to   =>  p_tk_notify_to
	  ,p_tk_notify_type =>  p_tk_notify_type
	  ,p_property_table       => l_timecard_props
           );

END IF;

 IF TK_ITEM_KEY IS NOT NULL THEN
    tk_audit_process_name := 'HXC_TK_AUDIT_PROCESS';
    tk_audit_item_type    := 'HXCTKWF';
 END IF;
  --
  -- Maintain summary table
  --
  hxc_timecard_summary_api.timecard_deposit
    (p_blocks => p_blocks
    ,p_approval_item_type    => NULL
    ,p_approval_process_name => NULL
    ,p_approval_item_key     => NULL
    ,p_tk_audit_item_type     => tk_audit_item_type
    ,p_tk_audit_process_name  => tk_audit_process_name
    ,p_tk_audit_item_key      => tk_item_key
    );

--
-- Starting Approval
--
IF not(l_status_error) THEN

l_item_key :=
   hxc_timecard_approval.begin_approval
     (p_blocks         => p_blocks
     ,p_item_type      => hxc_timecard_deposit_common.c_hxcempitemtype
     ,p_process_name   => hxc_timecard_deposit_common.c_hxcapprovalprocess
     ,p_resubmitted    => l_resubmit
     ,p_timecard_props => l_timecard_props
     ,p_messages       => p_messages
     );

END IF;

  -- start the approval only if the timecard has
  -- a different status than 'Error'
--
--  Audit this transaction
--
  --p_messages.delete;

  hxc_timecard_audit.audit_deposit
    (p_transaction_info => l_transaction_info
    ,p_messages => p_messages
    );



  --hxc_timecard_message_helper.processerrors
  --  (p_messages => p_messages);

  -- get all the errors
  --p_messages := hxc_timecard_message_helper.getMessages;


  -- set the out parameters --

  hxc_timecard_summary_pkg.update_summary_row
    (p_timecard_id => p_timecard_id
    ,p_approval_item_type    => hxc_timecard_deposit_common.c_hxcempitemtype
    ,p_approval_process_name => hxc_timecard_deposit_common.c_hxcapprovalprocess
    ,p_approval_item_key     => l_item_key
    );

  hr_utility.trace('Calling maintain_errors');

  hxc_timekeeper_errors.maintain_errors
  	(p_messages 	=> p_messages
  	,p_timecard_id  => p_timecard_id
  	,p_timecard_ovn => p_timecard_ovn);

/*
  if g_debug THEN
   hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',80);
  end if;
*/

   -- OTL-Absences Integration (Bug 8779478)
  -- Modified code to rollback in case on online retrieval errors (Bug 8888138)
  IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
    IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors ) THEN

	l_abs_ret_messages:= HXC_MESSAGE_TABLE_TYPE();

	IF g_debug THEN
	  hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMEKEEPER.SUBMIT_TIMECARD');
	END IF;

        l_resource_id     := p_blocks(l_timecard_index).resource_id;
        l_tc_start        := fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time);
        l_tc_stop         := fnd_date.canonical_to_date(p_blocks(l_timecard_index).stop_time);
        l_approval_status := p_blocks(l_timecard_index).approval_status;


        HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES (l_resource_id,
  	  			            l_tc_start,
  					    l_tc_stop,
  					    l_approval_status,
  					    l_abs_ret_messages);

  	IF g_debug THEN
  	  hr_utility.trace('ABS:p_messages.COUNT = '||l_abs_ret_messages.COUNT);
  	END IF;

	IF l_abs_ret_messages.COUNT > 0 THEN
	    IF g_debug THEN
	      hr_utility.trace('ABS: Online Retrieval failed - Rollback changes');
	    END IF;

	    rollback to TK_SUB_SAVEPOINT;

	    hxc_timekeeper_errors.maintain_errors
	    	    	          	(p_messages 	=> l_abs_ret_messages
	    	    	          	,p_timecard_id  => p_timecard_id
  	                	        ,p_timecard_ovn => p_timecard_ovn);


	END IF;

    END IF;
  END IF;



END submit_timecard;

----------------------------------------------------------------------------
-- Delete Timecard Procedure
-- This procedure....
----------------------------------------------------------------------------
Procedure delete_timecard
           (p_timecard_id  in out nocopy hxc_time_building_blocks.time_building_block_id%type
           ,p_messages        in out nocopy HXC_MESSAGE_TABLE_TYPE
           ) is

/*
  hxc_timecard_deposit_common.delete_timecard
           (p_mode         => 'DELETE'
           ,p_template     => 'N'
           ,p_timecard_id  => p_timecard_id
           );
*/

cursor c_previous_timecard(
			      p_timecard_id in hxc_timecard_summary.timecard_id%type) is
  select tk_audit_item_key,tk_audit_item_type,timecard_ovn
    from hxc_timecard_summary
   where timecard_id = p_timecard_id;

/*
cursor c_timecard_ovn
        (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is
  select tbb.object_version_number
    from hxc_time_building_blocks tbb
   where tbb.time_building_block_id = p_timecard_id
     and tbb.date_to = hr_general.end_of_time;
*/

CURSOR  csr_chk_transfer (p_timecard_id hxc_time_building_blocks.time_building_block_id%type) IS
SELECT  1
FROM	dual
WHERE EXISTS (
	SELECT	1
	FROM	hxc_transactions t
	,	hxc_transaction_details td
	WHERE	td.time_building_block_id	= p_timecard_id
	AND	t.transaction_id	= td.transaction_id
	AND	t.type			= 'RETRIEVAL'
	AND	t.status		= 'SUCCESS' );

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

l_status_error	   BOOLEAN := FALSE;

l_rollback	   BOOLEAN := FALSE;
e_timekeeper_check EXCEPTION;

l_previous_tk_item_key   hxc_timecard_summary.tk_audit_item_key%type;
l_previous_tk_item_type  hxc_timecard_summary.tk_audit_item_type%type;

l_dummy_num		NUMBER(1);

l_resource_id      NUMBER;
l_tc_start         DATE;
l_tc_stop          DATE;
l_approval_status  VARCHAR2(20);

l_abs_ret_messages	HXC_MESSAGE_TABLE_TYPE;

Begin

g_debug:= hr_utility.debug_enabled;

-- set savepoint
savepoint TK_DEL_SAVEPOINT;

--
-- Find the corresponding ovn of the timecard
--

open c_previous_timecard(p_timecard_id);
fetch c_previous_timecard into l_previous_tk_item_key,l_previous_tk_item_type,l_timecard_ovn;
if(c_previous_timecard%notfound) then
  close c_previous_timecard;
  fnd_message.set_name('HXC','HXC_NO_ACTIVE_TIMECARD');
  fnd_message.raise_error;
else

  --Cancel notifications for TK Audit
  hxc_timekeeper_wf_pkg.cancel_previous_notifications
   ( p_tk_audit_item_type => l_previous_tk_item_type
    ,p_tk_audit_item_key =>  l_previous_tk_item_key
   );
close c_previous_timecard;

end if;

--
-- Initialize the message stack
--

  fnd_msg_pub.initialize;
  hxc_timecard_message_helper.initializeErrors;
--
-- Get the timecard or timecard template blocks and attributes
--

  l_blocks := hxc_timecard_deposit_common.load_blocks(p_timecard_id, l_timecard_ovn);
  l_attributes := hxc_timecard_deposit_common.load_attributes(l_blocks);

--
-- Main delete processing
--

  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(l_blocks);

-- we need to check if the timecard is in error and
-- if it has been retrieved.
  IF (l_blocks(l_timecard_index).approval_status = 'ERROR')
  THEN
    OPEN  csr_chk_transfer(p_timecard_id);
    FETCH csr_chk_transfer INTO l_dummy_num;

    IF csr_chk_transfer%FOUND
    THEN
      close csr_chk_transfer;

      -- add the message in the message table
      hxc_timecard_message_helper.addErrorToCollection
            (p_messages,
             'HXC_DEL_ERROR_RET',
             hxc_timecard.c_error,
             null,
             null,
             hxc_timecard.c_hxc,
             null,
             null,
             null,
             null
             );

      raise e_timekeeper_check;
    END IF;

    close csr_chk_transfer;
  END IF;

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
    ,p_template      => 'N'
    ,p_resubmit      => hxc_timecard_deposit_common.c_delete
    ,p_can_deposit   => l_dummy
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => l_messages);


  -- get all the errors
  l_messages := hxc_timecard_message_helper.getMessages;
/*
  -- debug
  IF g_debug THEN
    hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',70);
  END IF;
*/
  hxc_timekeeper_errors.rollback_tc_or_set_err_status
     (p_message_table	=> l_messages
     ,p_blocks          => l_blocks
     ,p_attributes	=> l_attributes
     ,p_rollback	=> l_rollback
     ,p_status_error	=> l_status_error);

--  l_messages.delete;
--
-- if the rollback is set then we need to execute it
--
  IF l_rollback THEN
    -- we are setting the error to be
    -- send
    p_messages := l_messages;
    l_messages.delete;
    raise e_timekeeper_check;

  ELSE

    --l_messages.delete;
    hxc_timecard_deposit.execute
    (p_blocks 		=> l_blocks
    ,p_attributes 	=> l_attributes
    ,p_timecard_blocks 	=> l_timecard_blocks
    ,p_day_blocks 	=> l_day_blocks
    ,p_detail_blocks 	=> l_detail_blocks
    ,p_messages 	=> l_messages
    ,p_transaction_info => l_transaction_info
    );

    --hxc_timecard_message_helper.processerrors
    --(p_messages => l_messages);


    hxc_timecard_summary_api.delete_timecard
      (p_blocks => l_blocks
      ,p_timecard_id => p_timecard_id
      );

    --l_messages.delete;
    hxc_timecard_audit.audit_deposit
    (p_transaction_info => l_transaction_info
    ,p_messages => l_messages
    );
   -- hxc_timecard_message_helper.processerrors
   -- (p_messages => l_messages);

  hxc_timecard_audit.maintain_latest_details
  (p_blocks        => l_blocks );

  /* Bug 8888904 */
  hxc_timecard_audit.maintain_rdb_snapshot
      (p_blocks => l_blocks,
       p_attributes => l_attributes);

  hr_utility.trace('Calling maintain_errors');

    hxc_timecard_message_helper.prepareErrors;

    hxc_timekeeper_errors.maintain_errors
  	(p_messages 	=> l_messages
  	,p_timecard_id  => p_timecard_id
  	,p_timecard_ovn => l_timecard_ovn);



    -- get all the errors
    --l_messages := hxc_timecard_message_helper.getMessages;
/*
    if g_debug THEN
     hxc_debug_timecard.writeMessages(p_messages,'HXC_TIMEKEEPER',80);
    end if;
*/

    -- OTL-Absences Integration (Bug 8779478)
    -- Modified code to rollback in case on online retrieval errors (Bug 8888138)
    IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
      IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors) THEN

	IF g_debug THEN
	  hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMEKEEPER.DELETE_TIMECARD');
	END IF;

	l_abs_ret_messages:= HXC_MESSAGE_TABLE_TYPE();

        l_resource_id     := l_blocks(l_timecard_index).resource_id;
        l_tc_start        := fnd_date.canonical_to_date(l_blocks(l_timecard_index).start_time);
        l_tc_stop         := fnd_date.canonical_to_date(l_blocks(l_timecard_index).stop_time);
        l_approval_status := l_blocks(l_timecard_index).approval_status;


        HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES (l_resource_id,
  	  			             l_tc_start,
  					     l_tc_stop,
  					     'DELETED',
  					     l_abs_ret_messages);

  	IF g_debug THEN
  	  hr_utility.trace('ABS:l_messages.COUNT = '||l_abs_ret_messages.COUNT);
  	END IF;

	IF l_abs_ret_messages.COUNT > 0 THEN
	    IF g_debug THEN
	      hr_utility.trace('ABS: Online Retrieval failed - Rollback changes');
	    END IF;

	    rollback to TK_DEL_SAVEPOINT;

	    hxc_timekeeper_errors.maintain_errors
	      	(p_messages 	=> l_abs_ret_messages
	      	,p_timecard_id  => p_timecard_id
  	        ,p_timecard_ovn => l_timecard_ovn);


	END IF;

      END IF;
    END IF;



  end if;


EXCEPTION
  WHEN e_timekeeper_check then
    hxc_timecard_message_helper.prepareErrors;
    rollback;

End delete_timecard;



END hxc_timekeeper;

/
