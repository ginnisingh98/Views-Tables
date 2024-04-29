--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD" AS
/* $Header: hxctimecard.pkb 120.18.12010000.15 2010/03/05 06:43:20 sabvenug ship $ */

type attribute_list is table of number index by binary_integer;

attribute_id_list attribute_list;

g_package            varchar2(12) := 'HXC_TIMECARD';
g_debug 	     boolean 	  := hr_utility.debug_enabled;
g_deposit_blocks     hxc_block_table_type;
g_deposit_attributes hxc_attribute_table_type;
g_audit_messages     hxc_message_table_type;

Procedure alias_translation
            (p_blocks     in            HXC_BLOCK_TABLE_TYPE
            ,p_attributes in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages   in out nocopy HXC_MESSAGE_TABLE_TYPE
            ) is

l_old_style_attr  HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info;
l_old_style_blks  HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;

l_proc varchar2(31) := g_package||'.alias_translation';

Begin

hxc_timecard_attribute_utils.set_bld_blk_info_type_id(p_attributes);

HXC_ALIAS_TRANSLATOR.DO_DEPOSIT_TRANSLATION
  (p_attributes => p_attributes
  ,p_messages => p_messages
  );

End alias_translation;

Procedure save_timecard
           (p_blocks          in out nocopy HXC_BLOCK_TABLE_TYPE
           ,p_attributes      in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
           ,p_timecard_props  in            HXC_TIMECARD_PROP_TABLE_TYPE
           ,p_messages        in out nocopy HXC_MESSAGE_TABLE_TYPE
           ,p_timecard_id        out nocopy hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn       out nocopy hxc_time_building_blocks.object_version_number%type
           ,p_resubmit        in            varchar2
           ) is

l_timecard_blocks  hxc_timecard.block_list;
l_day_blocks       hxc_timecard.block_list;
l_detail_blocks    hxc_timecard.block_list;
l_transaction_info hxc_timecard.transaction_info;
l_proc             varchar2(33) := g_package||'.save_timecard';
l_old_style_blks   hxc_self_service_time_deposit.timecard_info;
l_old_style_attrs  hxc_self_service_time_deposit.building_block_attribute_info;
l_old_messages     hxc_self_service_time_deposit.message_table;
l_timecard_index   number;

l_resource_id      number;
l_start_date 	   date;
l_stop_date 	   date;
l_tc_status        varchar2(20);

TC_SAVE_EXCEPTION  EXCEPTION;

Begin

  savepoint TC_SAVE_SAVEPOINT;

/*
  Sort blocks
*/
  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );

/*
  Perform basic checks
*/

  hxc_deposit_checks.perform_checks
    (p_blocks => p_blocks
    ,p_attributes => p_attributes
    ,p_timecard_props => p_timecard_props
    ,p_days => l_day_blocks
    ,p_details => l_detail_blocks
    ,p_messages => p_messages
    );



  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Add the security attributes
  ARR: 115.52 Change - add message structure
*/
  hxc_security.add_security_attribute
    (p_blocks         => p_blocks,
     p_attributes     => p_attributes,
     p_timecard_props => p_timecard_props,
     p_messages       => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Translate any aliases
*/
  alias_translation
   (p_blocks => p_blocks
   ,p_attributes => p_attributes
   ,p_messages => p_messages
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

 -- OTL - ABS Integration
 hxc_retrieve_absences.verify_view_only_absences(p_blocks => p_blocks,
                                                 p_attributes => p_attributes,
                                                 p_lock_rowid => hxc_retrieve_absences.g_lock_row_id,
                                                 p_messages => p_messages);

/*
  Set the block and attribute update process flags
  Based on the data sent and in the db
*/
  hxc_block_attribute_update.set_process_flags
    (p_blocks => p_blocks
    ,p_attributes => p_attributes
    );

/*
  Removed any deleted attributes
*/

  hxc_timecard_attribute_utils.remove_deleted_attributes
    (p_attributes => p_attributes);

 /* Fix for bug 6489820 */

 l_timecard_blocks.delete;
 l_day_blocks.delete;
 l_detail_blocks.delete;

 /* End of fix for bug 6489820 */

/* fix by senthil for bug 5099360*/
  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );
/* end of fix for bug 5099360*/

  /*
    Process Checks
   */

  hxc_deposit_checks.perform_process_checks
    (p_blocks         => p_blocks
    ,p_attributes     => p_attributes
    ,p_timecard_props => p_timecard_props
    ,p_days           => l_day_blocks
    ,p_details        => l_detail_blocks
    ,p_template       => hxc_timecard.c_no
    ,p_deposit_mode   => hxc_timecard.c_save
    ,p_messages       => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Validate blocks, attributes - including TERs.
*/

  hxc_timecard_validation.recipients_update_validation
    (p_blocks       => p_blocks
    ,p_attributes   => p_attributes
    ,p_messages     => p_messages
    ,p_props        => p_timecard_props
    ,p_deposit_mode => hxc_timecard.c_save
    ,p_resubmit     => p_resubmit
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  hxc_timecard_validation.data_set_validation
   (p_blocks       => p_blocks
   ,p_messages     => p_messages
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Store blocks and attributes
*/

if hxc_timecard_message_helper.noErrors then

 hxc_timecard_deposit.execute
   (p_blocks => p_blocks
   ,p_attributes => p_attributes
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks => l_day_blocks
   ,p_detail_blocks => l_detail_blocks
   ,p_messages => p_messages
   ,p_transaction_info => l_transaction_info
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

end if;

if hxc_timecard_message_helper.noErrors then

  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

/*
  Bug 3345143 - this is done in the summary apis now.

  hxc_find_notify_aprs_pkg.cancel_previous_notifications(p_blocks(l_timecard_index).time_building_block_id);
*/
  --
  -- Maintain summary table
  --
  hxc_timecard_summary_api.timecard_deposit
    (p_blocks                => p_blocks
    ,p_approval_item_type    => NULL
    ,p_approval_process_name => NULL
    ,p_approval_item_key     => NULL
    ,p_tk_audit_item_type     => NULL
    ,p_tk_audit_process_name  => NULL
    ,p_tk_audit_item_key      => NULL
     );

  hxc_timecard_audit.maintain_latest_details
  (p_blocks        => p_blocks );


  /* Bug 8888904 */
  hxc_timecard_audit.maintain_rdb_snapshot
   (p_blocks => p_blocks,
    p_attributes => p_attributes);



  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

end if;

p_timecard_id := p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).time_building_block_id;
p_timecard_ovn:= p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).object_version_number;


-- OTL-Absences Integration (Bug 8779478)
-- Moved the following code inside a BEGIN-EXCEPTION-END block to handle exceptions effectively
-- for Bug 8888138
BEGIN
  IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
     IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors
        and p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).SCOPE <> hxc_timecard.c_template_scope) THEN

	IF g_debug THEN
	   hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMECARD.SAVE_TIMECARD');
	END IF;

         l_start_date := hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).start_time);
         l_stop_date := hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).stop_time);
         l_resource_id := p_blocks(l_timecard_index).resource_id;
	 l_tc_status := p_blocks(l_timecard_index).approval_status;

  	HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
  					    l_start_date,
  					    l_stop_date,
  					    l_tc_status,
  					    p_messages);


  	IF g_debug THEN
  	   hr_utility.trace('ABS:p_messages.COUNT = '||p_messages.COUNT);
  	END IF;

        IF p_messages.COUNT > 0 THEN
          IF g_debug THEN
            hr_utility.trace('ABS:Error in POST_ABSENCES');
          END IF;
          raise TC_SAVE_EXCEPTION;
        END IF;


     END IF;
  END IF;

EXCEPTION

 WHEN TC_SAVE_EXCEPTION THEN
  IF g_debug THEN
    hr_utility.trace('ABS: Exception TC_SAVE_EXCEPTION');
  END IF;

  rollback to TC_SAVE_SAVEPOINT;
  hxc_timecard_message_helper.processerrors
      	    (p_messages => p_messages);


END ;  -- Absences end

IF g_debug THEN
  hr_utility.trace('Leaving SAVE_TIMECARD');
END IF;

End save_timecard;

Procedure deposit_controller
            (p_validate        in            varchar2
            ,p_blocks          in            HXC_BLOCK_TABLE_TYPE
            ,p_attributes      in            HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages        in out nocopy HXC_MESSAGE_TABLE_TYPE
            ,p_deposit_mode    in            VARCHAR2
            ,p_template        in            VARCHAR2
            ,p_item_type       in            VARCHAR2
            ,p_approval_prc    in            VARCHAR2
	    ,p_cla_save        in            varchar2 default 'NO'
            ,p_timecard_id        out nocopy hxc_time_building_blocks.time_building_block_id%type
            ,p_timecard_ovn       out nocopy hxc_time_building_blocks.object_version_number%type
            ) IS

l_timecard_blocks  hxc_timecard.block_list;
l_day_blocks       hxc_timecard.block_list;
l_detail_blocks    hxc_timecard.block_list;
l_attributes       hxc_attribute_table_type;
l_blocks           hxc_block_table_type;
l_transaction_info hxc_timecard.transaction_info;
l_timecard_props   hxc_timecard_prop_table_type;
l_proc             varchar2(33) := g_package||'.DEPOSIT_CONTROLLER';
l_can_deposit      boolean := true;
l_resubmit         varchar2(10) := c_no;
l_timecard_index   number;
l_item_key         WF_ITEMS.ITEM_KEY%TYPE :=NULL;
l_tbb_id           hxc_time_building_blocks.time_building_block_id%type; -- declare two variables for ID and OVN
l_tbb_ovn          hxc_time_building_blocks.object_version_number%type;
l_attribute_index  number;
l_audit_layout     number;

l_restrict_blank_rows_on_save varchar2(10) := 'Y';
l_pref_table  hxc_preference_evaluation.t_pref_table;
p_master_pref_table hxc_preference_evaluation.t_pref_table;
l_start_date date;
l_stop_date date;
l_resource_id number;
l_tc_status varchar2(20);
l_active_index number;
l_index number;
l_idx   number;
bb_id_exists VARCHAR2(2) := 'N';
l_abs_ix	number;

TC_SUB_EXCEPTION  EXCEPTION;

BEGIN

savepoint TC_SUB_SAVEPOINT ;

l_blocks := p_blocks;
l_attributes := p_attributes;

hxc_timecard_block_utils.initialize_timecard_index;

----------------- Default Attributes -------------------------------------------------------
         l_active_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);
         l_start_date := hxc_timecard_block_utils.date_value(p_blocks(l_active_index).start_time);
         l_stop_date := hxc_timecard_block_utils.date_value(p_blocks(l_active_index).stop_time);
         l_resource_id := p_blocks(l_active_index).resource_id;


       hxc_preference_evaluation.resource_preferences(p_resource_id  => l_resource_id,
        			 p_preference_code => 'TS_PER_VALIDATE_ON_SAVE',
                                 p_start_evaluation_date => l_start_date,
                                 p_end_evaluation_date => l_stop_date,
                                 p_sorted_pref_table => l_pref_table,
                                 p_master_pref_table => p_master_pref_table );

         IF l_pref_table.count > 0 THEN
                l_restrict_blank_rows_on_save := l_pref_table(1).attribute2;   --Restrict Blank Rows on Save.
         END IF;
--------------------- Default Attributes -----------------------------------
/*
  Check input parameters
*/

  hxc_deposit_checks.check_inputs
    (p_blocks => p_blocks
    ,p_attributes => l_attributes
    ,p_deposit_mode => p_deposit_mode
    ,p_template => p_template
    ,p_messages => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Determine if this is a resubmitted timecard
*/

  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

  if(hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).date_to) = hr_general.end_of_time) then
    l_resubmit := hxc_timecard_approval.is_timecard_resubmitted
                   (p_blocks(l_timecard_index).time_building_block_id
                   ,p_blocks(l_timecard_index).object_version_number
                   ,p_blocks(l_timecard_index).resource_id
                   ,hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).start_time)
                   ,hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).stop_time)
                   );
  else
    l_resubmit := c_delete;
  end if;

/*
  Obtain the timecard properties
  This might be changed to send
  this information in from the
  middle tier, to avoid another
  pref evaluation
*/
l_tbb_id :=p_blocks(hxc_timecard_block_utils.find_active_timecard_index (p_blocks)).time_building_block_id;
l_tbb_ovn :=p_blocks(hxc_timecard_block_utils.find_active_timecard_index (p_blocks)).object_version_number;

 if (l_tbb_id <0 ) then -- when we are creating tmecard/template the id will be -ve value,so in this case we pass
  l_tbb_id := null;      -- NULL instead of -ve value
  l_tbb_ovn :=null;
  end if;

  hxc_timecard_properties.get_preference_properties
    (p_validate             => c_yes
    ,p_resource_id          => p_blocks(l_timecard_index).resource_id
    ,p_timecard_start_time  => hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).start_time)
    ,p_timecard_stop_time   => hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).stop_time)
    ,p_for_timecard         => false
    ,p_messages             => p_messages
    ,p_property_table       => l_timecard_props
    ,p_timecard_bb_id       => l_tbb_id -- passs the extra parameter timecard ID
    ,p_timecard_bb_ovn      => l_tbb_ovn -- pass the extra parameter  timecard OVN
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  p_messages.delete;

/*
  Sort the blocks - needed for deposit
  and all sorts of short cuts!
*/

if(p_deposit_mode = c_save) then

  save_timecard
   (p_blocks         => l_blocks
   ,p_attributes     => l_attributes
   ,p_timecard_props => l_timecard_props
   ,p_messages       => p_messages
   ,p_timecard_id    => p_timecard_id
   ,p_timecard_ovn   => p_timecard_ovn
   ,p_resubmit       => l_resubmit
   );

elsif (p_deposit_mode = c_audit) then


  l_blocks     := g_deposit_blocks;
  hxc_timecard_attribute_utils.append_additional_reasons
    (g_deposit_attributes
    ,p_attributes);
  l_attributes := g_deposit_attributes;

  p_messages := g_audit_messages;
  l_attribute_index:=p_attributes.first;
           LOOP  EXIT WHEN NOT p_attributes.exists(l_attribute_index);
  	         if(p_attributes(l_attribute_index).attribute_category = 'LAYOUT')
  	         then
  	               	l_audit_layout := p_attributes(l_attribute_index).attribute6;
  	         	exit;
  	         end if;
  	         l_attribute_index := p_attributes.next(l_attribute_index);

  	    end loop;
  IF ( l_audit_layout IS NOT NULL )
  THEN
  hxc_deposit_checks.audit_checks
   (p_blocks     => l_blocks
   ,p_attributes => l_attributes
   ,p_messages   => p_messages
   );
  END IF;
  hxc_deposit_checks.audit_checks
   (p_blocks     => l_blocks
   ,p_attributes => l_attributes
   ,p_messages   => p_messages
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Hold the completed blocks and attributes
  for immeadiate deposit if required if
  there were no error messages from audit
  validation
*/

  if(hxc_timecard_message_helper.noerrors) then
    g_deposit_blocks := l_blocks;
    g_deposit_attributes := l_attributes;
  end if;

else
  if((p_validate = c_yes)OR(p_template=c_yes)) then

  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );

/*
  Main deposit controls
  ^^^^^^^^^^^^^^^^^^^^^
  Reform time data, if required
  e.g Denormalize time data
*/

 hxc_block_attribute_update.denormalize_time
   (p_blocks => l_blocks
   ,p_mode => 'ADD'
   );

/*
  Perform basic checks, e.g.
  Are there any other timecards for this period?
*/

  if(p_template=c_no) then

    hxc_deposit_checks.perform_checks
      (p_blocks => p_blocks
      ,p_attributes => l_attributes
      ,p_timecard_props => l_timecard_props
      ,p_days => l_day_blocks
      ,p_details => l_detail_blocks
      ,p_messages => p_messages
      );


    hxc_timecard_message_helper.processerrors
      (p_messages => p_messages);

    p_messages.delete;

  end if;

/*
  Add the security attributes
  ARR: 115.52 Change - add message structure
*/
  hxc_security.add_security_attribute
    (p_blocks         => p_blocks,
     p_attributes     => l_attributes,
     p_timecard_props => l_timecard_props,
     p_messages       => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Translate any aliases
*/


  alias_translation
   (p_blocks => p_blocks
   ,p_attributes => l_attributes
   ,p_messages => p_messages
   );


  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

/*
  Set the block and attribute update process flags
  Based on the data sent and in the db
*/


  hxc_block_attribute_update.set_process_flags
    (p_blocks => l_blocks
    ,p_attributes => l_attributes
    );

/*
  Removed any effectively deleted attributes
*/

 if p_cla_save = 'NO' then      ------------- CLA change


  hxc_timecard_attribute_utils.remove_deleted_attributes
    (p_attributes => l_attributes);

/*
  Perform process checks
*/

  hxc_deposit_checks.perform_process_checks
    (p_blocks         => l_blocks
    ,p_attributes     => l_attributes
    ,p_timecard_props => l_timecard_props
    ,p_days           => l_day_blocks
    ,p_details        => l_detail_blocks
    ,p_template       => p_template
    ,p_deposit_mode   => p_deposit_mode
    ,p_messages       => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
/*
  Validate blocks, attributes
*/
-- OTL - ABS Integration
 hxc_retrieve_absences.verify_view_only_absences(p_blocks => p_blocks,
                                                 p_attributes => l_attributes,
                                                 p_lock_rowid => hxc_retrieve_absences.g_lock_row_id,
                                                 p_messages => p_messages);


  hxc_timecard_validation.deposit_validation
    (p_blocks        => l_blocks
    ,p_attributes    => l_attributes
    ,p_messages      => p_messages
    ,p_props         => l_timecard_props
    ,p_deposit_mode  => p_deposit_mode
    ,p_template      => p_template
    ,p_resubmit      => l_resubmit
    ,p_can_deposit   => l_can_deposit
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

--
-- Validate the set up for the user
-- Do this only for timecards, and not
-- for templates.
--
/*
  if(p_template = c_no) then

    validate_setup
       (p_deposit_mode => p_deposit_mode
       ,p_blocks       => l_blocks
       ,p_attributes   => l_attributes
       ,p_messages     => p_messages
       );

  end if;

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

*/
/*
  Reform time data, if required
  e.g Denormalize time data
*/


    elsif p_cla_save = 'YES' then                          ------- CLA change

	hxc_timecard_validation.timecard_validation
            (p_blocks       => l_blocks,
             p_attributes   => l_attributes,
             p_messages     => p_messages,
             p_props        => l_timecard_props,
             p_deposit_mode => 'SAVE',
             p_resubmit     => l_resubmit
             );
    END IF;

 hxc_block_attribute_update.denormalize_time
   (p_blocks => l_blocks
   ,p_mode => 'REMOVE'
   );

/*
  Hold the completed blocks and attributes
  for immeadiate deposit if required
*/
  g_deposit_blocks := l_blocks;
  g_deposit_attributes := l_attributes;
  g_audit_messages := hxc_timecard_message_helper.getMessages;

end if;

if(((p_validate=c_no)OR(p_template=c_yes))AND(l_can_deposit))then

  if(l_day_blocks.count = 0) then
    --
    -- Only bother to resort if we have to
    --
    hxc_timecard_block_utils.sort_blocks
     (p_blocks          => g_deposit_blocks
     ,p_timecard_blocks => l_timecard_blocks
     ,p_day_blocks      => l_day_blocks
     ,p_detail_blocks   => l_detail_blocks
     );

  end if;

 if(p_template = c_no) then
  /*
    Perform basic checks
  */
    hxc_deposit_checks.perform_checks
      (p_blocks => g_deposit_blocks
      ,p_attributes => g_deposit_attributes
      ,p_timecard_props => l_timecard_props
      ,p_days => l_day_blocks
      ,p_details => l_detail_blocks
      ,p_messages => p_messages
      );

    hxc_timecard_message_helper.processerrors
      (p_messages => p_messages);

    p_messages.delete;

 end if;

/*
  Store blocks and attributes
*/
  if(hxc_timecard_message_helper.noErrors) then

/*
   At this point, if we're saving a template,
   we should look to see if the id corresponding
   to the template block is actually a timecard
   in which case, we'll need to replace the ids
   to ensure the template is saved properly
*/

    if(p_template = hxc_timecard.c_yes) then

      hxc_block_attribute_update.replace_ids
       (p_blocks => g_deposit_blocks
       ,p_attributes => g_deposit_attributes
       , p_duplicate_template => FALSE
       );

    end if;

--------------------------- Default Attributes -----------------------------------------
IF l_restrict_blank_rows_on_save = 'N'
   OR l_restrict_blank_rows_on_save = 'No' THEN

  IF g_debug THEN

	hr_utility.trace('>deposit_controller g_deposit_blocks 1');
	l_index := g_deposit_blocks.first;
		LOOP
	      EXIT WHEN NOT g_deposit_blocks.exists(l_index);
		hr_utility.trace(
		'RESOURCE_ID :'||g_deposit_blocks(l_index).RESOURCE_ID
		||'BB id : '||g_deposit_blocks(l_index).TIME_BUILDING_BLOCK_ID
		||'['||g_deposit_blocks(l_index).OBJECT_VERSION_NUMBER||']'
		||' PARENT_BUILDING_BLOCK_ID: '||g_deposit_blocks(l_index).PARENT_BUILDING_BLOCK_ID
		||' DATE_TO: '||g_deposit_blocks(l_index).DATE_TO
		||' SCOPE: '||g_deposit_blocks(l_index).SCOPE
		||' MEASURE : '||g_deposit_blocks(l_index).MEASURE
		||' START_TIME : '||g_deposit_blocks(l_index).START_TIME
		||' STOP_TIME : '||g_deposit_blocks(l_index).STOP_TIME
		||' TRANSLATION_DISPLAY_KEY : '||g_deposit_blocks(l_index).TRANSLATION_DISPLAY_KEY
		||' APPROVAL_STATUS: '||g_deposit_blocks(l_index).APPROVAL_STATUS
	  ||' APPROVAL_STYLE_ID: '||g_deposit_blocks(l_index).APPROVAL_STYLE_ID
		);

	      l_index := g_deposit_blocks.next(l_index);
		END LOOP;


	hr_utility.trace('>deposit_controller l_blocks 1.1 ');
	l_index := l_blocks.first;
		LOOP
	      EXIT WHEN NOT l_blocks.exists(l_index);
		hr_utility.trace(
		'RESOURCE_ID :'||l_blocks(l_index).RESOURCE_ID
		||'BB id : '||l_blocks(l_index).TIME_BUILDING_BLOCK_ID
		||'['||l_blocks(l_index).OBJECT_VERSION_NUMBER||']'
		||' PARENT_BUILDING_BLOCK_ID: '||l_blocks(l_index).PARENT_BUILDING_BLOCK_ID
		||' DATE_TO: '||l_blocks(l_index).DATE_TO
		||' SCOPE: '||l_blocks(l_index).SCOPE
		||' MEASURE : '||l_blocks(l_index).MEASURE
		||' START_TIME : '||l_blocks(l_index).START_TIME
		||' STOP_TIME : '||l_blocks(l_index).STOP_TIME
		||' TRANSLATION_DISPLAY_KEY : '||l_blocks(l_index).TRANSLATION_DISPLAY_KEY
		||' APPROVAL_STATUS: '||l_blocks(l_index).APPROVAL_STATUS
	  ||' APPROVAL_STYLE_ID: '||l_blocks(l_index).APPROVAL_STYLE_ID
		);
	      l_index := l_blocks.next(l_index);
		END LOOP;
  END IF;


  hr_utility.trace('Restrict Blank Rows on  Save : '||l_restrict_blank_rows_on_save);
  -- Added for DA
  IF((p_template <> c_yes) and (hxc_timecard_message_helper.noErrors)) THEN
	l_index := g_deposit_blocks.first;
	LOOP
	EXIT WHEN NOT g_deposit_blocks.exists(l_index);

	  bb_id_exists := 'N';

	  l_idx := l_blocks.first;
	  LOOP
	  EXIT WHEN NOT l_blocks.exists(l_idx);
	    IF g_deposit_blocks(l_index).TIME_BUILDING_BLOCK_ID
	       = l_blocks(l_idx).TIME_BUILDING_BLOCK_ID THEN
	      bb_id_exists := 'Y';
	      EXIT;
	    END IF;

	  l_idx := l_blocks.next(l_idx);
	  END LOOP;

	  hr_utility.trace('g_deposit_blocks(l_index).TIME_BUILDING_BLOCK_ID : '||
	  g_deposit_blocks(l_index).TIME_BUILDING_BLOCK_ID || '- sysdate :'||to_char(SYSDATE,'yyyy/mm/dd'));
	  hr_utility.trace('bb_id_exists :'|| bb_id_exists);

	  IF bb_id_exists = 'N' THEN
	    g_deposit_blocks(l_index).DATE_TO := to_char(SYSDATE,'yyyy/mm/dd');
	  END IF;

	l_index := g_deposit_blocks.next(l_index);
	END LOOP;

    hxc_trans_display_key_utils.alter_translation_key
    (p_g_deposit_blocks => g_deposit_blocks
     ,p_actual_blocks => l_blocks
    );

  END IF;
  -- End of DA

  IF g_debug THEN

  hr_utility.trace('>deposit_controller 2');
	l_index := g_deposit_blocks.first;
		LOOP
	      EXIT WHEN NOT g_deposit_blocks.exists(l_index);
		hr_utility.trace(
		'RESOURCE_ID :'||g_deposit_blocks(l_index).RESOURCE_ID
		||'BB id : '||g_deposit_blocks(l_index).TIME_BUILDING_BLOCK_ID
		||'['||g_deposit_blocks(l_index).OBJECT_VERSION_NUMBER||']'
		||' PARENT_BUILDING_BLOCK_ID: '||g_deposit_blocks(l_index).PARENT_BUILDING_BLOCK_ID
		||' DATE_TO: '||g_deposit_blocks(l_index).DATE_TO
		||' SCOPE: '||g_deposit_blocks(l_index).SCOPE
		||' MEASURE : '||g_deposit_blocks(l_index).MEASURE
		||' START_TIME : '||g_deposit_blocks(l_index).START_TIME
		||' STOP_TIME : '||g_deposit_blocks(l_index).STOP_TIME
		||' TRANSLATION_DISPLAY_KEY : '||g_deposit_blocks(l_index).TRANSLATION_DISPLAY_KEY
		||' APPROVAL_STATUS: '||g_deposit_blocks(l_index).APPROVAL_STATUS
	  ||' APPROVAL_STYLE_ID: '||g_deposit_blocks(l_index).APPROVAL_STYLE_ID
		);

	      l_index := g_deposit_blocks.next(l_index);
		END LOOP;

  hr_utility.trace('>deposit_controller 2.1');
	l_index := l_blocks.first;
		LOOP
	      EXIT WHEN NOT l_blocks.exists(l_index);
		hr_utility.trace(
		'RESOURCE_ID :'||l_blocks(l_index).RESOURCE_ID
		||'BB id : '||l_blocks(l_index).TIME_BUILDING_BLOCK_ID
		||'['||l_blocks(l_index).OBJECT_VERSION_NUMBER||']'
		||' PARENT_BUILDING_BLOCK_ID: '||l_blocks(l_index).PARENT_BUILDING_BLOCK_ID
		||' DATE_TO: '||l_blocks(l_index).DATE_TO
		||' SCOPE: '||l_blocks(l_index).SCOPE
		||' MEASURE : '||l_blocks(l_index).MEASURE
		||' START_TIME : '||l_blocks(l_index).START_TIME
		||' STOP_TIME : '||l_blocks(l_index).STOP_TIME
		||' TRANSLATION_DISPLAY_KEY : '||l_blocks(l_index).TRANSLATION_DISPLAY_KEY
		||' APPROVAL_STATUS: '||l_blocks(l_index).APPROVAL_STATUS
	  ||' APPROVAL_STYLE_ID: '||l_blocks(l_index).APPROVAL_STYLE_ID
		);

	      l_index := l_blocks.next(l_index);
		END LOOP;
  END IF;


END IF; --  IF l_restrict_blank_rows_on_save = 'N'

--------------------------- Default Attributes -----------------------------------------

    hxc_timecard_deposit.execute
     (p_blocks => g_deposit_blocks
     ,p_attributes => g_deposit_attributes
     ,p_timecard_blocks => l_timecard_blocks
     ,p_day_blocks => l_day_blocks
     ,p_detail_blocks => l_detail_blocks
     ,p_messages => p_messages
     ,p_transaction_info => l_transaction_info
     );

    hxc_timecard_message_helper.processerrors
      (p_messages => p_messages);

    p_timecard_id := g_deposit_blocks
                       (hxc_timecard_block_utils.find_active_timecard_index(g_deposit_blocks)).time_building_block_id;

    p_timecard_ovn := g_deposit_blocks
                       (hxc_timecard_block_utils.find_active_timecard_index(g_deposit_blocks)).object_version_number;

 if((p_template <> c_yes) and (hxc_timecard_message_helper.noErrors)) then


  -- Maintain summary table

  hxc_timecard_summary_api.timecard_deposit
    (p_blocks                => g_deposit_blocks
    ,p_approval_item_type    => NULL
    ,p_approval_process_name => NULL
    ,p_approval_item_key     => NULL
    ,p_tk_audit_item_type     => NULL
    ,p_tk_audit_process_name  => NULL
    ,p_tk_audit_item_key      => NULL
     );

  hxc_timecard_audit.maintain_latest_details
  (p_blocks        => g_deposit_blocks );


  /*Bug 8888904 */
  hxc_timecard_audit.maintain_rdb_snapshot
     (p_blocks => g_deposit_blocks,
     p_attributes => g_deposit_attributes);


  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

 -- OTL-Absences Integration (Bug 8779478)
 -- Moved the following code inside a BEGIN-EXCEPTION-END block to handle exceptions effectively
 -- for Bug 8888138
  BEGIN
   IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y')
   THEN
     IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors
          and p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).SCOPE <> hxc_timecard.c_template_scope)
     THEN

        IF g_debug THEN
  	  hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMECARD.DEPOSIT_CONTROLLER');
	END IF;

        l_resource_id          := p_blocks(l_timecard_index).resource_id    ;
        l_start_date  := hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).start_time);
        l_stop_date   := hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).stop_time) ;
        l_tc_status          := p_blocks(l_timecard_index).approval_status ;

  	HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
  					    l_start_date,
  					    l_stop_date,
  					    l_tc_status,
  					    p_messages);

	IF g_debug THEN
	  hr_utility.trace('ABS:p_messages.COUNT = '||p_messages.COUNT);
	END IF;

	if p_messages.COUNT > 0
	then
	  IF g_debug THEN
	     hr_utility.trace('ABS:Error in POST_ABSENCES');
	  END IF;
	  raise TC_SUB_EXCEPTION;
	end if;

     END IF;
   END IF;

 EXCEPTION
   WHEN TC_SUB_EXCEPTION THEN
      IF g_debug THEN
        hr_utility.trace('ABS: Exception TC_SUB_EXCEPTION');
      END IF;

      rollback to TC_SUB_SAVEPOINT;
      hxc_timecard_message_helper.processerrors
          	    (p_messages => p_messages);


 END;
 -- Absences end

   hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  l_item_key :=
    hxc_timecard_approval.begin_approval
    (p_blocks         => g_deposit_blocks,
     p_item_type      => p_item_type,
     p_process_name   => p_approval_prc,
     p_resubmitted    => l_resubmit,
     p_timecard_props => l_timecard_props,
     p_messages       => p_messages
     );

  -- Absences start
  -- Moved the following code inside a BEGIN-EXCEPTION-END block to handle exceptions effectively
  -- for Bug 8888138
  BEGIN
   IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y')  THEN
      IF g_debug THEN
	hr_utility.trace('ABS:Checking status of BEGIN_APPROVAL');
	hr_utility.trace('ABS:p_messages.COUNT = '||p_messages.COUNT);
      END IF;

	if p_messages.COUNT > 0
	then
	  IF g_debug THEN
	    hr_utility.trace('ABS:Error in POST_ABSENCES');
	  END IF;
	    raise TC_SUB_EXCEPTION;
  	end if;
    END IF;
  EXCEPTION
   WHEN TC_SUB_EXCEPTION THEN
      IF g_debug THEN
        hr_utility.trace('ABS: Exception TC_SUB_EXCEPTION');
      END IF;
      rollback to TC_SUB_SAVEPOINT;
      hxc_timecard_message_helper.processerrors
          	    (p_messages => p_messages);


  END;
  -- Absences end


  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  hxc_timecard_summary_pkg.update_summary_row
    (p_timecard_id => p_timecard_id
    ,p_approval_item_type    => p_item_type
    ,p_approval_process_name => p_approval_prc
    ,p_approval_item_key     => l_item_key
    );

hr_utility.trace('Restrict Blank Rows on  Save : '||l_restrict_blank_rows_on_save);

IF l_restrict_blank_rows_on_save = 'N'  OR l_restrict_blank_rows_on_save = 'No' THEN
  -- Added for DA
 delete_null_entries(p_timecard_id => p_timecard_id
 		     ,p_timecard_ovn => p_timecard_ovn);
  -- end
END IF;
       --
       --115.43 Change Note: The delete on the structures are
       --in both the if and elsif clauses here, since we must only
       --delete the structures if there has been a successful deposit,
       --namely the hxc_timecard_message_helper.noErrors function
       --returns true.  Customer tested this configuration.
       --
       g_deposit_blocks.delete;
       g_deposit_attributes.delete;
       g_audit_messages.delete;
     elsif((p_template = c_yes) and (hxc_timecard_message_helper.noErrors)) then
	 hxc_template_summary_api.template_deposit
         (p_blocks => g_deposit_blocks,
          p_attributes =>g_deposit_attributes,
          p_template_id =>p_timecard_id);

         g_deposit_blocks.delete;
         g_deposit_attributes.delete;
         g_audit_messages.delete;
  end if;

 end if;
end if;

/*
  Audit this transaction
*/

  hxc_timecard_audit.audit_deposit
    (p_transaction_info => l_transaction_info
    ,p_messages => p_messages
    );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

end if;

/*
  Finally, deal with the errors
*/

p_messages := hxc_timecard_message_helper.prepareMessages;


END deposit_controller;

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
           ) is

l_proc varchar2(30) := g_package||'.CREATE_TIMECARD';
l_index number;
l_process_locker_type  varchar2(80) := hxc_lock_util.c_ss_timecard_action;
l_released_success boolean := false;

l_valid_lock boolean := false;
l_lock_rowid rowid;
l_timecard_index number;

l_resource_id 				hxc_time_building_blocks.resource_id%type;
l_timecard_start_time hxc_time_building_blocks.start_time%type;
l_timecard_stop_time hxc_time_building_blocks.stop_time%type;

d_lock_rowid		varchar2(100);

Begin

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    hr_utility.trace('ABS> In hxc_timecard.create_timecard procedure');
      l_index := p_attributes.first;
      LOOP
        EXIT WHEN NOT p_attributes.exists(l_index);
        --  l_attribute := p_attributes(l_index);

          hr_utility.trace('ABS> '||
          	'BB id : '||p_attributes(l_index).BUILDING_BLOCK_ID
          	||'['||p_attributes(l_index).BUILDING_BLOCK_OVN||']'
          	||' ATT CAT: '||p_attributes(l_index).ATTRIBUTE_CATEGORY
          	||' ATTRIBUTE1: '||p_attributes(l_index).ATTRIBUTE1
          	||' ATTRIBUTE2: '||p_attributes(l_index).ATTRIBUTE2
          	||' ATTRIBUTE3: '||p_attributes(l_index).ATTRIBUTE3
          	||' ATTRIBUTE4: '||p_attributes(l_index).ATTRIBUTE4
          	||' ATTRIBUTE5: '||p_attributes(l_index).ATTRIBUTE5
          	||' ATTRIBUTE6: '||p_attributes(l_index).ATTRIBUTE6
          	||' ATTRIBUTE7: '||p_attributes(l_index).ATTRIBUTE7
          	||' ATTRIBUTE8: '||p_attributes(l_index).ATTRIBUTE8
          	||' ATTRIBUTE9: '||p_attributes(l_index).ATTRIBUTE9
                ||' ATT ID '||p_attributes(l_index).TIME_ATTRIBUTE_ID
                );

         l_index := p_attributes.next(l_index);
       END LOOP;

       l_index := p_blocks.first;
       LOOP
         EXIT WHEN NOT p_blocks.exists(l_index);
           hr_utility.trace('ABS> '||
                  'RESOURCE_ID :'||p_blocks(l_index).RESOURCE_ID
                  ||'BB id : '||p_blocks(l_index).TIME_BUILDING_BLOCK_ID
                  ||'['||p_blocks(l_index).OBJECT_VERSION_NUMBER||']'
                  ||' PARENT_BUILDING_BLOCK_ID: '||p_blocks(l_index).PARENT_BUILDING_BLOCK_ID
                  ||' DATE_TO: '||p_blocks(l_index).DATE_TO
                  ||' SCOPE: '||p_blocks(l_index).SCOPE
                  ||' MEASURE : '||p_blocks(l_index).MEASURE
                  ||' START_TIME : '||p_blocks(l_index).START_TIME
                  ||' STOP_TIME : '||p_blocks(l_index).STOP_TIME
                  ||' TRANSLATION_DISPLAY_KEY : '||p_blocks(l_index).TRANSLATION_DISPLAY_KEY
                  ||' APPROVAL_STATUS: '||p_blocks(l_index).APPROVAL_STATUS
        	  ||' APPROVAL_STYLE_ID: '||p_blocks(l_index).APPROVAL_STYLE_ID
                  );

         l_index := p_blocks.next(l_index);
       END LOOP;
  END IF;


/*
  For bug 3220588, we need to rollback in case there have been any
  changes in the PA code, which require us to revert.  E.g. the
  transaction reference has been updated, but the user has clicked
  the back button.  No code should be updated in the validate phase
  in OTL
*/
if(p_validate=hxc_timecard.c_yes) then
  rollback;
end if;

fnd_msg_pub.initialize;

hxc_timecard_message_helper.initializeErrors;

p_messages := hxc_message_table_type();

if(p_template = hxc_timecard.c_no) then
  if(hxc_lock_api.check_lock(p_lock_rowid)) then
     l_valid_lock := true;
  else
  --
  -- For bug
  -- If the lock is invalid, it might just have timed out, therefore
  -- request a new lock.
  --
     l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

     if(hxc_timecard_block_utils.is_new_block(p_blocks(l_timecard_index))) then

       hxc_lock_api.request_lock
	 (p_process_locker_type=> hxc_lock_util.c_ss_timecard_action
	 ,p_resource_id=> p_blocks(l_timecard_index).resource_id
	 ,p_start_time=> fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time)
	 ,p_stop_time=> fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time)
	 ,p_time_building_block_id=> null
	 ,p_time_building_block_ovn=> null
	 ,p_transaction_lock_id=> null
	 ,p_expiration_time=> 10
	 ,p_messages=> p_messages
	 ,p_row_lock_id=> l_lock_rowid
	 ,p_locked_success=> l_valid_lock
	 );
     else

       hxc_lock_api.request_lock
	 (p_process_locker_type=> hxc_lock_util.c_ss_timecard_action
	 ,p_resource_id=> p_blocks(l_timecard_index).resource_id
	 ,p_start_time=> fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time)
	 ,p_stop_time=> fnd_date.canonical_to_date(p_blocks(l_timecard_index).start_time)
	 ,p_time_building_block_id=> p_blocks(l_timecard_index).time_building_block_id
	 ,p_time_building_block_ovn=> p_blocks(l_timecard_index).object_version_number
	 ,p_transaction_lock_id=> null
	 ,p_expiration_time=> 10
	 ,p_messages=> p_messages
	 ,p_row_lock_id=> l_lock_rowid
	 ,p_locked_success=> l_valid_lock
	 );
     end if;
   end if;
end if;

-- OTL - ABS Integration

l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

hxc_retrieve_absences.g_lock_row_id := p_lock_rowid;
hxc_retrieve_absences.g_person_id   := p_blocks(l_timecard_index).resource_id;
hxc_retrieve_absences.g_start_time   := FND_DATE.canonical_to_date(p_blocks(l_timecard_index).start_time);
hxc_retrieve_absences.g_stop_time   := FND_DATE.canonical_to_date(p_blocks(l_timecard_index).stop_time);

-- Added for OTL ABS Integration 8888902
-- OTL-ABS START
IF g_debug THEN
  hr_utility.trace('ABS> In hxc_timecard.create_timeecard');
  hr_utility.trace('ABS> call hxc_retrieve_absences.insert_absence_summary_row');
END IF;

IF (NVL(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
  hxc_retrieve_absences.insert_absence_summary_row;
END IF;
-- OTL-ABS END

if((l_valid_lock) OR (p_template = hxc_timecard.c_yes)) then

  deposit_controller
   (p_validate        => p_validate
   ,p_blocks          => p_blocks
   ,p_attributes      => p_attributes
   ,p_messages        => p_messages
   ,p_deposit_mode    => p_deposit_mode
   ,p_template        => p_template
   ,p_item_type       => p_item_type
   ,p_approval_prc    => p_approval_prc
   ,p_cla_save        => p_cla_save
   ,p_timecard_id     => p_timecard_id
   ,p_timecard_ovn    => p_timecard_ovn
   );

  if(
     ((p_deposit_mode = hxc_timecard.c_save) AND (hxc_timecard_message_helper.noerrors))
     OR
     ((p_deposit_mode = hxc_timecard.c_submit) AND (p_validate = hxc_timecard.c_no) AND (p_template = hxc_timecard.c_no))
    ) then

    hxc_lock_api.release_lock
      (P_ROW_LOCK_ID => p_lock_rowid
      ,P_PROCESS_LOCKER_TYPE => l_process_locker_type
      ,P_TRANSACTION_LOCK_ID => null
      ,P_RESOURCE_ID => null
      ,P_START_TIME => null
      ,P_STOP_TIME =>  null
      ,P_TIME_BUILDING_BLOCK_ID => null
      ,P_TIME_BUILDING_BLOCK_OVN => null
      ,P_MESSAGES => p_messages
      ,P_RELEASED_SUCCESS => l_released_success
      );

  elsif ((p_template = hxc_timecard.c_yes) AND (hxc_timecard_message_helper.noerrors))then
  --
  -- This is important, because we might have saved
  -- a timecard as a template, in which case, we should
  -- release the lock that we might have
  --
     hxc_lock_api.release_lock
       (p_row_lock_id => p_lock_rowid);

  end if;

else

  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_TIMECARD_LOCK_FAILED'
    ,hxc_timecard.c_error
    ,null
    ,null
    ,hxc_timecard.c_hxc
    ,null
    ,null
    ,null
    ,null
    );


end if;

End create_timecard;

Function load_blocks
          (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
          ,p_timecard_ovn in hxc_time_building_blocks.object_version_number%type
          ,p_load_mode   in varchar2 default c_nondelete
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
  if(p_load_mode = c_delete) then
    --
    -- Date effectively end date the block
    --
    l_blocks(l_block_count).date_to := fnd_date.date_to_canonical(sysdate);
  end if;

  l_block_count := l_block_count +1;

end loop;

return l_blocks;

End load_blocks;

Function load_attributes
           (p_blocks in hxc_block_table_type)
           return hxc_attribute_table_type is

cursor c_attributes
         (p_building_block_id in hxc_time_building_blocks.time_building_block_id%type
         ,p_building_block_ovn in hxc_time_building_blocks.object_version_number%type
         ) is
  select ta.time_attribute_id
        ,ta.attribute_category
        ,ta.attribute1
        ,ta.attribute2
        ,ta.attribute3
        ,ta.attribute4
        ,ta.attribute5
        ,ta.attribute6
        ,ta.attribute7
        ,ta.attribute8
        ,ta.attribute9
        ,ta.attribute10
        ,ta.attribute11
        ,ta.attribute12
        ,ta.attribute13
        ,ta.attribute14
        ,ta.attribute15
        ,ta.attribute16
        ,ta.attribute17
        ,ta.attribute18
        ,ta.attribute19
        ,ta.attribute20
        ,ta.attribute21
        ,ta.attribute22
        ,ta.attribute23
        ,ta.attribute24
        ,ta.attribute25
        ,ta.attribute26
        ,ta.attribute27
        ,ta.attribute28
        ,ta.attribute29
        ,ta.attribute30
        ,ta.bld_blk_info_type_id
        ,ta.object_version_number
        ,bbit.bld_blk_info_type
    from hxc_time_attribute_usages tau, hxc_time_attributes ta, hxc_bld_blk_info_types bbit
   where tau.time_building_block_id = p_building_block_id
     and tau.time_building_block_ovn = p_building_block_ovn
     and ta.time_attribute_id = tau.time_attribute_id
     and ta.bld_blk_info_type_id = bbit.bld_blk_info_type_id;

l_attributes hxc_attribute_table_type := hxc_attribute_table_type();

l_block_index     number;
l_attribute_index number := 1;

Begin

l_block_index := p_blocks.first;

loop
  exit when not p_blocks.exists(l_block_index);

  for attribute_rec in
    c_attributes(p_blocks(l_block_index).time_building_block_id,p_blocks(l_block_index).object_version_number)
  loop

    l_attributes.extend;
    l_attributes(l_attribute_index) :=  HXC_ATTRIBUTE_TYPE
                                         (attribute_rec.TIME_ATTRIBUTE_ID
                                         ,p_blocks(l_block_index).time_building_block_id
                                         ,attribute_rec.ATTRIBUTE_CATEGORY
                                         ,attribute_rec.ATTRIBUTE1
                                         ,attribute_rec.ATTRIBUTE2
                                         ,attribute_rec.ATTRIBUTE3
                                         ,attribute_rec.ATTRIBUTE4
                                         ,attribute_rec.ATTRIBUTE5
                                         ,attribute_rec.ATTRIBUTE6
                                         ,attribute_rec.ATTRIBUTE7
                                         ,attribute_rec.ATTRIBUTE8
                                         ,attribute_rec.ATTRIBUTE9
                                         ,attribute_rec.ATTRIBUTE10
                                         ,attribute_rec.ATTRIBUTE11
                                         ,attribute_rec.ATTRIBUTE12
                                         ,attribute_rec.ATTRIBUTE13
                                         ,attribute_rec.ATTRIBUTE14
                                         ,attribute_rec.ATTRIBUTE15
                                         ,attribute_rec.ATTRIBUTE16
                                         ,attribute_rec.ATTRIBUTE17
                                         ,attribute_rec.ATTRIBUTE18
                                         ,attribute_rec.ATTRIBUTE19
                                         ,attribute_rec.ATTRIBUTE20
                                         ,attribute_rec.ATTRIBUTE21
                                         ,attribute_rec.ATTRIBUTE22
                                         ,attribute_rec.ATTRIBUTE23
                                         ,attribute_rec.ATTRIBUTE24
                                         ,attribute_rec.ATTRIBUTE25
                                         ,attribute_rec.ATTRIBUTE26
                                         ,attribute_rec.ATTRIBUTE27
                                         ,attribute_rec.ATTRIBUTE28
                                         ,attribute_rec.ATTRIBUTE29
                                         ,attribute_rec.ATTRIBUTE30
                                         ,attribute_rec.BLD_BLK_INFO_TYPE_ID
                                         ,attribute_rec.OBJECT_VERSION_NUMBER
                                         ,'N'
                                         ,'N'
                                         ,attribute_rec.bld_blk_info_type
                                         ,'N'
                                         ,p_blocks(l_block_index).object_version_number
                                         );

    l_attribute_index := l_attribute_index +1;
  end loop;
  l_block_index := p_blocks.next(l_block_index);
end loop;

return l_attributes;

End load_attributes;

Procedure delete_timecard
           (p_mode         in            varchar2
           ,p_template     in            varchar2
           ,p_timecard_id  in            hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ok  in out nocopy varchar2
           ) is

cursor c_timecard_ovn
        (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is
 select tbb.object_version_number, tbb.resource_id, tbb.start_time, tbb.stop_time
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
l_resource_id      hxc_time_building_blocks.resource_id%type;
l_start_time       hxc_time_building_blocks.start_time%type;
l_stop_time       hxc_time_building_blocks.stop_time%type;
l_timecard_index   number;
l_lock_rowid       rowid;
l_lock_success     boolean;

l_delete_allowed   varchar2(5) := 'FALSE';

TC_DEL_EXCEPTION  EXCEPTION;

Begin
--
-- Find the corresponding ovn of the timecard
--

open c_timecard_ovn(p_timecard_id);
fetch c_timecard_ovn into l_timecard_ovn, l_resource_id, l_start_time, l_stop_time;
if(c_timecard_ovn%notfound) then
  close c_timecard_ovn;
  p_timecard_ok := hxc_timecard.c_no;
else

savepoint TC_DEL_SAVEPOINT;
--
-- Timecard is ok, continue.
--
p_timecard_ok := hxc_timecard.c_yes;
close c_timecard_ovn;

--
-- Initialize the message stack
--

fnd_msg_pub.initialize;
hxc_timecard_message_helper.initializeErrors;
--
-- Get the timecard or timecard template blocks and attributes
--

  l_blocks := load_blocks(p_timecard_id, l_timecard_ovn, c_delete);
  l_attributes := load_attributes(l_blocks);
--
-- Main delete processing
--

  l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(l_blocks);

  hxc_timecard_properties.get_preference_properties
    (p_validate             => hxc_timecard.c_yes
    ,p_resource_id          => l_blocks(l_timecard_index).resource_id
    ,p_timecard_start_time  => hxc_timecard_block_utils.date_value(l_blocks(l_timecard_index).start_time)
    ,p_timecard_stop_time   => hxc_timecard_block_utils.date_value(l_blocks(l_timecard_index).stop_time)
    ,p_for_timecard         => false
    ,p_messages             => l_messages
    ,p_property_table       => l_timecard_props
    ,p_timecard_bb_id       => p_timecard_id  --passs the extra parameter timecard ID
    ,p_timecard_bb_ovn      => l_timecard_ovn -- pass the extra parameter  timecard OVN
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

--
-- Don't want to issue this validation for
-- timecard scope.  The PA validation will
-- fail.
--

  if(l_blocks(l_timecard_index).scope = c_timecard_scope) then

     hxc_deposit_checks.perform_process_checks
        (p_blocks         => l_blocks,
         p_attributes     => l_attributes,
         p_timecard_props => l_timecard_props,
         p_days           => l_day_blocks,
         p_details        => l_detail_blocks,
         p_template       => p_template,
         p_deposit_mode   => p_mode,
         p_messages       => l_messages
         );

     hxc_timecard_message_helper.processerrors
      (p_messages => l_messages);

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

  elsif(l_blocks(l_timecard_index).scope = c_template_scope) then

    hxc_deposit_checks.can_delete_template
      (l_blocks(l_timecard_index).time_building_block_id
      ,l_messages
      );

   hxc_timecard_message_helper.processerrors
      (p_messages => l_messages);

  end if;

  if(hxc_timecard_message_helper.noErrors) then

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

/*
    Bug 3345143
    Removed following call.  This is done inside delete_timecard on the
    summary api.
    hxc_find_notify_aprs_pkg.cancel_previous_notifications(p_timecard_id);
*/

    if(hxc_timecard_message_helper.noErrors) then
      if(l_blocks(l_timecard_index).scope = c_template_scope) then --Only for templates.
	hxc_template_summary_api.DELETE_TEMPLATE(l_blocks(l_timecard_index).time_building_block_id);
      else							--For Timecard.
	    hxc_timecard_summary_api.delete_timecard
	      (p_blocks => l_blocks
	      ,p_timecard_id => p_timecard_id
	      );

	hxc_timecard_audit.audit_deposit
	      (p_transaction_info => l_transaction_info
	      ,p_messages => l_messages
	      );

	  hxc_timecard_audit.maintain_latest_details
	  (p_blocks        => l_blocks );

	  /* Bug 8888904 */
	  hxc_timecard_audit.maintain_rdb_snapshot
	    (p_blocks => l_blocks,
             p_attributes => l_attributes);


	  hxc_timecard_message_helper.processerrors
      	  (p_messages => l_messages);


	 -- OTL-Absences Integration (Bug 8779478)
	 -- Moved the following code inside a BEGIN-EXCEPTION-END block to handle exceptions effectively
	 -- for Bug 8888138
	 BEGIN
	   IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
	     IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors) THEN
	        IF g_debug THEN
		  hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMECARD.DELETE_TIMECARD');
		END IF;

  		HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
  						    l_start_time,
  						    l_stop_time,
  						    'DELETED',
  						    l_messages);


		IF g_debug THEN
		  hr_utility.trace('ABS:l_messages.COUNT = '||l_messages.COUNT);
		END IF;

		if l_messages.COUNT > 0 then
		  IF g_debug THEN
		    hr_utility.trace('ABS:Error in POST_ABSENCES');
		  END IF;
		  raise TC_DEL_EXCEPTION;
		end if;

	     END IF;
	   END IF;

	 EXCEPTION
	   WHEN TC_DEL_EXCEPTION THEN
	      IF g_debug THEN
	        hr_utility.trace('ABS: Exception TC_DEL_EXCEPTION');
	      END IF;

	      rollback to TC_DEL_SAVEPOINT;
	      hxc_timecard_message_helper.processerrors
	          	    (p_messages => l_messages);


	 END;  -- Absences end

      end if;
    end if;



  end if;

  hxc_lock_api.release_lock
    (p_row_lock_id => l_lock_rowid);

  hxc_timecard_message_helper.prepareErrors;

end if; -- Is the timecard ok?

End delete_timecard;

-- Added for DA Enhancement
Procedure delete_null_entries
           (p_timecard_id  in hxc_time_building_blocks.time_building_block_id%type
            ,p_timecard_ovn in hxc_time_building_blocks.object_version_number%type
	   )is

cursor c_null_blocks
        (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
        ) is

        SELECT  det.time_building_block_id ,
        	det.object_version_number
  	FROM    hxc_time_building_blocks DET,
          	HXC_TIME_BUILDING_BLOCKS DAY
 	WHERE   day.parent_building_block_id = p_timecard_id
   	AND     det.parent_building_block_ovn = day.object_version_number
   	AND     det.parent_building_block_id  = day.time_building_block_id
 	AND     det.scope       = 'DETAIL'
	AND 	det.measure    IS NULL
	AND 	det.start_time IS NULL
    	AND 	det.stop_time  IS NULL;

TYPE building_blocks_tab IS TABLE of NUMBER ;

bb_id_tab  building_blocks_tab;
bb_ovn_tab building_blocks_tab;



Begin


  OPEN c_null_blocks(p_timecard_id);

    FETCH c_null_blocks
    BULK COLLECT INTO bb_id_tab,bb_ovn_tab;

      FORALL i IN bb_id_tab.FIRST..bb_id_tab.LAST

      DELETE
      FROM    hxc_time_building_blocks
      WHERE   time_building_block_id = bb_id_tab(i)
      AND     object_version_number  = bb_ovn_tab(i);


  CLOSE c_null_blocks;

End delete_null_entries;

END hxc_timecard;


/
