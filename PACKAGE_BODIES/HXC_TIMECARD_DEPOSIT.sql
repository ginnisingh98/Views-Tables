--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_DEPOSIT" AS
/* $Header: hxctimedp.pkb 120.10.12010000.10 2009/09/18 07:43:26 bbayragi ship $ */

  g_debug boolean := hr_utility.debug_enabled;

  Procedure add_transaction_info
    (p_time_building_block_id in          hxc_time_building_blocks.time_building_block_id%type
     ,p_object_version_number  in          hxc_time_building_blocks.object_version_number%type
     ,p_exception_desc       in          varchar2
     ,p_transaction_info       in out nocopy hxc_timecard.transaction_info
     ,p_messages             in out nocopy hxc_message_table_type
     ) is

    l_index  number;
    l_status varchar2(20);

  Begin

    if(p_time_building_block_id is null) then

      hxc_timecard_message_helper.addErrorToCollection
        (p_messages
         ,'HXC_NULL_TRANS_BLOCK'
         ,hxc_timecard.c_error
         ,null
         ,null
         ,'HXC'
         ,null
         ,null
         ,null
         ,null
         );

    else


      l_index := p_transaction_info.count + 1;

      if(p_exception_desc is not null) then
        l_status := hxc_timecard.c_trans_error;
      else
        l_status := hxc_timecard.c_trans_success;
      end if;

      p_transaction_info(l_index).time_building_block_id := p_time_building_block_id;
      p_transaction_info(l_index).object_version_number  := p_object_version_number;
      p_transaction_info(l_index).exception_desc := p_exception_desc;
      p_transaction_info(l_index).status := l_status;

    end if;

  End add_transaction_info;

  Procedure deposit_error
    (p_messages       in out nocopy hxc_message_table_type
     ,p_transaction_info in out nocopy hxc_timecard.transaction_info
     ,p_time_building_block_id in hxc_time_building_blocks.time_building_block_id%type
     ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
     ) is

    l_exception_desc varchar2(2000);

  Begin

    hr_message.provide_error;


    if(hr_message.last_message_name is not null) then

      --
      -- If we have a specific error, then I think
      -- we shouldn't associate the blocks in this case
      -- the reason is that we have no corresponding web beans
      -- on the page at this point to set the item level errors
      -- on.

      hxc_timecard_message_helper.addErrorToCollection
        (p_messages
         ,hr_message.last_message_name
         ,hxc_timecard.c_error
         ,null
         ,null
         ,hr_message.last_message_app
         ,null
         ,null
         ,null
         ,null
         );

      l_exception_desc := hr_message.get_message_text;

    else

      if(SQLERRM is not null) then
        -- fix for 3266231, v115.6
        -- adding 'BLK_AND_CHILDREN' for "MESSAGE_EXTENT"
        hxc_timecard_message_helper.addErrorToCollection
          (p_messages
           ,'HXC_HXT_DEP_VAL_ORAERR'
           ,hxc_timecard.c_error
           ,null
           ,substr('ERROR&' || SQLERRM,1,240)
           ,'HXC'
           ,null
           ,null
           ,null
           ,null
           ,'BLK_AND_CHILDREN'
           );

        l_exception_desc := substr(SQLERRM,1,2000);

      else
        -- Unable to determine error from stack or SQLERRM,
        -- set to internal block deposit error.

        hxc_timecard_message_helper.addErrorToCollection
          (p_messages
           ,'HXC_XXXXXX_UNKN_BLOCK_DEP'
           ,hxc_timecard.c_error
           ,null
           ,null
           ,hxc_timecard.c_hxc
           ,p_time_building_block_id
           ,p_time_building_block_ovn
           ,null
           ,null
           );

        l_exception_desc := 'An Unknown error has occurred.'
          ||'  HXC_TIMECARD_DEPOSIT.DEPOSIT_ERROR';
      end if;

    end if;

    --
    -- Create some new transaction info for this building block
    --

    add_transaction_info
      (p_time_building_block_id => p_time_building_block_id
       ,p_object_version_number  => p_time_building_block_ovn
       ,p_exception_desc       => l_exception_desc
       ,p_transaction_info       => p_transaction_info
       ,p_messages             => p_messages
       );

  End deposit_error;

  Procedure update_dependent_attributes
    (p_attributes       in out nocopy hxc_attribute_table_type
     ,p_building_block_id  in          number
     ) is

    l_index     number;
    l_attribute hxc_attribute_type;

  Begin

    --
    -- now do the attributes
    -- These aren't sorted, so we go through
    -- them all.
    --
    l_index := p_attributes.first;
    LOOP
      EXIT WHEN NOT p_attributes.exists(l_index);

      l_attribute := p_attributes(l_index);

      if(hxc_timecard_attribute_utils.is_corresponding_block
  (p_attribute => l_attribute
   ,p_block_id  => p_building_block_id
   )
         ) then

        p_attributes(l_index).process := 'Y';

      end if;

      l_index := p_attributes.next(l_index);

    END LOOP;

  End update_dependent_attributes;

  Function set_child_process
    (p_block in hxc_block_type)
    return varchar2 is

  Begin

    if(hxc_timecard_block_utils.is_new_block(p_block)) then
      --
      -- Process flag is set to No for new block.
      -- User probably entered it, then deleted it
      -- without commit to db inbetween.  Don't
      -- process
      return 'N';
    else
      return 'Y';
    end if;

  End set_child_process;

  Procedure maintain_error_table
    (p_messages     in out nocopy hxc_message_table_type
     ,p_old_ta_id    in          hxc_time_building_blocks.time_building_block_id%type
     ,p_old_ta_ovn   in          hxc_time_building_blocks.object_version_number%type
     ,p_new_ta_id    in          hxc_time_building_blocks.time_building_block_id%type
     ,p_new_ta_ovn   in          hxc_time_building_blocks.object_version_number%type
     ,p_timecard_id  in          hxc_time_building_blocks.time_building_block_id%type
     ,p_timecard_ovn in          hxc_time_building_blocks.object_version_number%type
     ) is

    l_index number;

  Begin

    l_index := p_messages.first;

    Loop
      Exit when not p_messages.exists(l_index);
      if((p_messages(l_index).time_attribute_id = p_old_ta_id)
         AND
           (p_messages(l_index).time_attribute_ovn = p_old_ta_ovn)) then
        p_messages(l_index).time_attribute_id := p_new_ta_id;
        p_messages(l_index).time_attribute_ovn := p_new_ta_ovn;
      end if;
      if((p_messages(l_index).time_attribute_id is null)
         AND
           (p_messages(l_index).time_building_block_id is null)) then
        p_messages(l_index).time_building_block_id  := p_timecard_id;
        p_messages(l_index).time_building_block_ovn := p_timecard_ovn;
      end if;
      l_index := p_messages.next(l_index);
    End Loop;

  End maintain_error_table;

  Procedure maintain_error_table
    (p_messages     in out nocopy hxc_message_table_type
     ,p_old_bb_id    in          hxc_time_building_blocks.time_building_block_id%type
     ,p_old_bb_ovn   in          hxc_time_building_blocks.object_version_number%type
     ,p_new_bb_id    in          hxc_time_building_blocks.time_building_block_id%type
     ,p_new_bb_ovn   in          hxc_time_building_blocks.object_version_number%type
     ,p_timecard_id  in          hxc_time_building_blocks.time_building_block_id%type
     ,p_timecard_ovn in          hxc_time_building_blocks.object_version_number%type
     ) is

    l_index number;

  Begin

    l_index := p_messages.first;

    Loop
      Exit when not p_messages.exists(l_index);
      if((p_messages(l_index).time_building_block_id = p_old_bb_id)
         AND
           (nvl(p_messages(l_index).time_building_block_ovn,p_old_bb_ovn) = p_old_bb_ovn)) then
        p_messages(l_index).time_building_block_id := p_new_bb_id;
        p_messages(l_index).time_building_block_ovn := p_new_bb_ovn;
      end if;
      if(p_messages(l_index).time_building_block_id is null) then
        p_messages(l_index).time_building_block_id := p_timecard_id;
        p_messages(l_index).time_building_block_ovn := p_timecard_ovn;
      end if;
      l_index := p_messages.next(l_index);
    End Loop;

  End maintain_error_table;

  Procedure maintain_dependents
    (p_blocks       in out nocopy hxc_block_table_type
     ,p_attributes   in out nocopy hxc_attribute_table_type
     ,p_messages     in out nocopy hxc_message_table_type
     ,p_block_list   in          hxc_timecard.block_list
     ,l_old_bb_id    in          hxc_time_building_blocks.time_building_block_id%type
     ,l_old_ovn      in          hxc_time_building_blocks.object_version_number%type
     ,l_new_bb_id    in          hxc_time_building_blocks.time_building_block_id%type
     ,l_new_ovn      in          hxc_time_building_blocks.object_version_number%type
     ,p_timecard_id  in          hxc_time_building_blocks.time_building_block_id%type
     ,p_timecard_ovn in          hxc_time_building_blocks.object_version_number%type
     ) is

    l_parent_chk pls_integer;
    l_index      number;
    l_block      hxc_block_type;
    l_attribute  hxc_attribute_type;

  Begin
    --
    -- Loop through the specified blocks, looking for the parents
    --
    l_index := p_block_list.first;
    LOOP
      EXIT WHEN NOT p_block_list.exists(l_index);

      l_block := p_blocks(p_block_list(l_index));

      l_parent_chk := hxc_timecard_block_utils.is_parent_block
        (p_block      => l_block,
         p_parent_id  => l_old_bb_id,
         p_parent_ovn => l_old_ovn,
         p_check_id   => true
         );

      if(l_parent_chk = 0)then

        p_blocks(p_block_list(l_index)).parent_building_block_id := l_new_bb_id;
        p_blocks(p_block_list(l_index)).parent_building_block_ovn := l_new_ovn;
        if(p_blocks(p_block_list(l_index)).process <> 'Y') then
          p_blocks(p_block_list(l_index)).process := set_child_process(p_blocks(p_block_list(l_index)));
          update_dependent_attributes(p_attributes,p_blocks(p_block_list(l_index)).time_building_block_id);
        end if;
      elsif(l_parent_chk = 1) then
        --
        -- This means the id matched, but the ovn did not.
        -- This should never happen when depositing a timecard
        -- Some likely corruption going on, raise error.
        --
        hxc_timecard_message_helper.addErrorToCollection
          (p_messages
           ,'HXC_366502_INVALID_PARENT_DEP'
           ,hxc_timecard.c_error
           ,null
           ,null
           ,'HXC'
           ,l_block.time_building_block_id
           ,l_block.object_version_number
           ,null
           ,null
           );

      end if;

      l_index := p_block_list.next(l_index);
    END LOOP;
    --
    -- now do the attributes
    -- These aren't sorted, so we go through
    -- them all.
    --
    l_index := p_attributes.first;
    LOOP
      EXIT WHEN NOT p_attributes.exists(l_index);

      --l_attribute := p_attributes(l_index);

      if(hxc_timecard_attribute_utils.is_corresponding_block
  (p_attribute => p_attributes(l_index)
   ,p_block_id  => l_old_bb_id
   )
         ) then

        p_attributes(l_index).building_block_id := l_new_bb_id;
        p_attributes(l_index).building_block_ovn := l_new_ovn;

      end if;

      l_index := p_attributes.next(l_index);

    END LOOP;

    --
    -- Lastly the messages.  This is done for
    -- timekeeper, there shouldn't be any messages
    -- at this point for self service.
    --
    maintain_error_table
      (p_messages     => p_messages
       ,p_old_bb_id    => l_old_bb_id
       ,p_old_bb_ovn   => l_old_ovn
       ,p_new_bb_id    => l_new_bb_id
       ,p_new_bb_ovn   => l_new_ovn
       ,p_timecard_id  => p_timecard_id
       ,p_timecard_ovn => p_timecard_ovn
       );

  End maintain_dependents;

  Procedure deposit_new_block
    (p_block          in out nocopy HXC_BLOCK_TYPE
     ,p_old_bb_id         out nocopy NUMBER
     ,p_new_bb_id         out nocopy NUMBER
     ,p_transaction_info in out nocopy hxc_timecard.transaction_info
     ,p_messages       in out nocopy hxc_message_table_type
     ) is

    l_object_version_number HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE;
    l_time_building_block_id HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE := null;

  Begin

    p_old_bb_id := p_block.time_building_block_id;

    --
    -- Call the block Api to create the new block
    --
    hxc_building_block_api.create_building_block
      (p_effective_date          => sysdate
       ,p_type                  => p_block.type
       ,p_measure               => p_block.measure
       ,p_unit_of_measure         => p_block.unit_of_measure
       ,p_start_time            => hxc_timecard_block_utils.date_value(p_block.start_time)
       ,p_stop_time             => hxc_timecard_block_utils.date_value(p_block.stop_time)
       ,p_parent_building_block_id  => p_block.parent_building_block_id
       ,p_parent_building_block_ovn => p_block.parent_building_block_ovn
       ,p_scope                 => p_block.scope
       ,p_approval_style_id       => p_block.approval_style_id
       ,p_approval_status         => p_block.approval_status
       ,p_resource_id             => p_block.resource_id
       ,p_resource_type           => p_block.resource_type
       ,p_comment_text            => p_block.comment_text
       ,p_application_set_id      => p_block.application_set_id
       ,p_translation_display_key   => p_block.translation_display_key
       ,p_time_building_block_id    => l_time_building_block_id
       ,p_object_version_number     => l_object_version_number
       );
    --
    -- Keep for the out parameter
    --
    p_new_bb_id := l_time_building_block_id;
    --
    -- Set the values in the structure
    --
    p_block.time_building_block_id := p_new_bb_id;
    p_block.object_version_number  := 1;

  Exception
    when others then
      --
      -- Here the save of the building block
      -- has failed, so we should maintain
      -- the error.  However, we don't reraise
      -- the error, since that will be handled
      -- by timekeeper, or in the case of self
      -- service, the commit will fail, the inserts
      -- rolledback, and all the errors for all the
      -- blocks shown to the user.

      deposit_error
        (p_messages => p_messages
         ,p_transaction_info => p_transaction_info
         ,p_time_building_block_id => p_block.time_building_block_id
         ,p_time_building_block_ovn => p_block.object_version_number
         );

  End deposit_new_block;

  Procedure deposit_old_block
    (p_block            in out nocopy hxc_block_type,
     p_old_ovn             out nocopy number,
     p_new_ovn             out nocopy number,
     p_deleted_blocks   in out nocopy hxc_timecard.block_list,
     p_transaction_info in out nocopy hxc_timecard.transaction_info,
     p_messages         in out nocopy hxc_message_table_type
     ) is

    l_object_version_number hxc_time_building_blocks.object_version_number%type;

  Begin
    --
    -- Keep the old ovn for future use
    --
    p_old_ovn := p_block.object_version_number;
    --
    -- Since we want a history of the timecard, we
    -- don't update the row, rather create a new
    -- block, then update it with the old
    -- id and ovn +1 - currently the block API
    -- handles this for us, based on the value
    -- passed in the time_building_block_id
    -- parameter!
    -- Call the API, with the real values!
    --


    if(hxc_timecard_block_utils.is_active_block(p_block)) then

      hxc_building_block_api.create_building_block
        (p_effective_date          => sysdate
         ,p_type                  => p_block.type
         ,p_measure               => p_block.measure
         ,p_unit_of_measure         => p_block.unit_of_measure
         ,p_start_time            => hxc_timecard_block_utils.date_value(p_block.start_time)
         ,p_stop_time             => hxc_timecard_block_utils.date_value(p_block.stop_time)
         ,p_parent_building_block_id  => p_block.parent_building_block_id
         ,p_parent_building_block_ovn => p_block.parent_building_block_ovn
         ,p_scope                 => p_block.scope
         ,p_approval_style_id       => p_block.approval_style_id
         ,p_approval_status         => p_block.approval_status
         ,p_resource_id             => p_block.resource_id
         ,p_resource_type           => p_block.resource_type
         ,p_comment_text            => p_block.comment_text
         ,p_application_set_id      => p_block.application_set_id
         ,p_translation_display_key   => p_block.translation_display_key
         ,p_time_building_block_id    => p_block.time_building_block_id
         ,p_object_version_number     => l_object_version_number
         );

    else

      hxc_building_block_api.delete_building_block
        (p_object_version_number  => l_object_version_number
         ,p_time_building_block_id => p_block.time_building_block_id
         ,p_effective_date       => sysdate
         ,p_application_set_id     => p_block.application_set_id
         );
      --
      -- Record this as a deleted block
      --
      p_deleted_blocks(p_block.time_building_block_id) := p_block.object_version_number;

    end if;
    --
    -- Keep for the out parameter
    --
    p_new_ovn := l_object_version_number;
    --
    -- Set the values in the structure
    --
    p_block.object_version_number  := l_object_version_number;

  Exception
    when others then
      --
      -- Here the save of the building block
      -- has failed, so we should maintain
      -- the error.  However, we don't reraise
      -- the error, since that will be handled
      -- by timekeeper, or in the case of self
      -- service, the commit will fail, the inserts
      -- rolledback, and all the errors for all the
      -- blocks shown to the user.

      deposit_error
        (p_messages => p_messages
         ,p_transaction_info => p_transaction_info
         ,p_time_building_block_id => p_block.time_building_block_id
         ,p_time_building_block_ovn => p_block.object_version_number
         );

  End deposit_old_block;

  Procedure deposit_timecard_blocks
    (p_blocks           in out nocopy hxc_block_table_type,
     p_attributes       in out nocopy hxc_attribute_table_type,
     p_timecard_blocks  in          hxc_timecard.block_list,
     p_day_blocks       in          hxc_timecard.block_list,
     p_deleted_blocks   in out nocopy hxc_timecard.block_list,
     p_transaction_info in out nocopy hxc_timecard.transaction_info,
     p_messages         in out nocopy hxc_message_table_type
     ) is

    l_index NUMBER;
    l_block HXC_BLOCK_TYPE;

    l_new_bb_id hxc_time_building_blocks.time_building_block_id%type;
    l_old_bb_id hxc_time_building_blocks.time_building_block_id%type;
    l_new_ovn   hxc_time_building_blocks.object_version_number%type;
    l_old_ovn   hxc_time_building_blocks.object_version_number%type;

  Begin

    l_index := p_timecard_blocks.first;

    LOOP
      EXIT WHEN NOT p_timecard_blocks.exists(l_index);

      l_block := p_blocks(p_timecard_blocks(l_index));
      --  if(p_messages.count < 1) then
      if(hxc_timecard_block_utils.process_block(l_block)) then
        if(hxc_timecard_block_utils.is_timecard_block(l_block)) then

          if(hxc_timecard_block_utils.is_new_block(l_block)) then
            deposit_new_block(l_block,l_old_bb_id,l_new_bb_id,p_transaction_info,p_messages);
            if(l_new_bb_id is not null) then
              add_transaction_info(l_new_bb_id,1,null,p_transaction_info,p_messages);
            end if;
            p_blocks(p_timecard_blocks(l_index)) := l_block;
            maintain_dependents
              (p_blocks
               ,p_attributes
               ,p_messages
               ,p_day_blocks
               ,l_old_bb_id
               ,1
               ,l_new_bb_id
               ,1
               ,l_new_bb_id
               ,1
               );
          else
            deposit_old_block(l_block,l_old_ovn,l_new_ovn,p_deleted_blocks,p_transaction_info,p_messages);
            add_transaction_info(l_block.time_building_block_id,l_new_ovn,null,p_transaction_info,p_messages);
            p_blocks(p_timecard_blocks(l_index)) := l_block;
            maintain_dependents
              (p_blocks
               ,p_attributes
               ,p_messages
               ,p_day_blocks
               ,l_block.time_building_block_id
               ,l_old_ovn
               ,l_block.time_building_block_id
               ,l_new_ovn
               ,l_block.time_building_block_id
               ,l_new_ovn
               );
          end if;

        end if;
      end if;
      --  end if; -- only want to continue processing while there are no errors.
      l_index := p_timecard_blocks.next(l_index);

    END LOOP;

  End deposit_timecard_blocks;

  Procedure deposit_day_blocks
    (p_blocks           in out nocopy hxc_block_table_type,
     p_attributes       in out nocopy hxc_attribute_table_type,
     p_day_blocks       in          hxc_timecard.block_list,
     p_detail_blocks    in          hxc_timecard.block_list,
     p_deleted_blocks   in out nocopy hxc_timecard.block_list,
     p_transaction_info in out nocopy hxc_timecard.transaction_info,
     p_messages         in out nocopy hxc_message_table_type,
     p_timecard_id      in          number,
     p_timecard_ovn     in          number
     ) is

    l_index NUMBER;
    l_block HXC_BLOCK_TYPE;

    l_new_bb_id hxc_time_building_blocks.time_building_block_id%type;
    l_old_bb_id hxc_time_building_blocks.time_building_block_id%type;
    l_new_ovn   hxc_time_building_blocks.object_version_number%type;
    l_old_ovn   hxc_time_building_blocks.object_version_number%type;

  Begin

    l_index := p_day_blocks.first;

    LOOP
      EXIT WHEN NOT p_day_blocks.exists(l_index);

      l_block := p_blocks(p_day_blocks(l_index));

      if(hxc_timecard_block_utils.process_block(l_block)) then
        if(hxc_timecard_block_utils.is_day_block(l_block)) then

          if(hxc_timecard_block_utils.is_new_block(l_block)) then
            deposit_new_block(l_block,l_old_bb_id,l_new_bb_id,p_transaction_info,p_messages);
            add_transaction_info(l_new_bb_id,1,null,p_transaction_info,p_messages);
            p_blocks(p_day_blocks(l_index)) := l_block;
            maintain_dependents
              (p_blocks
               ,p_attributes
               ,p_messages
               ,p_detail_blocks
               ,l_old_bb_id
               ,1
               ,l_new_bb_id
               ,1
               ,p_timecard_id
               ,p_timecard_ovn
               );
          else
            deposit_old_block(l_block,l_old_ovn,l_new_ovn,p_deleted_blocks,p_transaction_info,p_messages);
            add_transaction_info(l_block.time_building_block_id,l_new_ovn,null,p_transaction_info,p_messages);
            p_blocks(p_day_blocks(l_index)) := l_block;
            maintain_dependents
              (p_blocks
               ,p_attributes
               ,p_messages
               ,p_detail_blocks
               ,l_block.time_building_block_id
               ,l_old_ovn
               ,l_block.time_building_block_id
               ,l_new_ovn
               ,p_timecard_id
               ,p_timecard_ovn
               );
          end if;

        end if;
      end if;
      l_index := p_day_blocks.next(l_index);

    END LOOP;

  End deposit_day_blocks;

	Function is_duplicate_block(p_blocks in HXC_BLOCK_TABLE_TYPE,
				p_block_new in HXC_BLOCK_TYPE)
	return boolean
	IS

	l_index number;
	isDuplicate boolean := false;

	Begin

	IF g_debug
	THEN
	    hr_utility.trace(' Entering is_duplicate_block .. ');
	    hr_utility.trace(' p_block_new.time_building_block_id is : ' || p_block_new.time_building_block_id);
	    hr_utility.trace(' In is_duplicate_block p_block_new.translation_display_key is : ' || p_block_new.translation_display_key);
	END IF;

	l_index := p_blocks.first;

	LOOP
		EXIT WHEN not p_blocks.exists(l_index) or isDuplicate;

		IF g_debug
		THEN
		   hr_utility.trace(' l_index is : ' || l_index);
		   hr_utility.trace(' time_building_block_id is : ' || p_blocks(l_index).time_building_block_id);
		   hr_utility.trace(' scope is : ' || p_blocks(l_index).scope);
		   hr_utility.trace(' translation_display_key is : ' || p_blocks(l_index).translation_display_key);
		   hr_utility.trace(' parent_building_block_id is : ' || p_blocks(l_index).parent_building_block_id);
		   hr_utility.trace(' parent_building_block_ovn is : ' || p_blocks(l_index).parent_building_block_ovn);
		   hr_utility.trace(' date_to is : ' || p_blocks(l_index).date_to);
		END IF;


		if(p_blocks(l_index).scope = 'DETAIL'
			AND p_blocks(l_index).time_building_block_id <> p_block_new.time_building_block_id
			AND p_blocks(l_index).date_to = fnd_date.date_to_canonical(hr_general.end_of_time)
			AND p_blocks(l_index).parent_building_block_id = p_block_new.parent_building_block_id
			AND p_blocks(l_index).parent_building_block_ovn = p_block_new.parent_building_block_ovn
			AND p_blocks(l_index).translation_display_key is NOT NULL
			AND p_block_new.translation_display_key is NOT NULL
			AND p_blocks(l_index).translation_display_key = p_block_new.translation_display_key
			)
		then
			hr_utility.trace(' DUPLICATE is TRUE ');
			isDuplicate := true;
		end if;

		l_index := p_blocks.next(l_index);
	END LOOP;

	if(NOT isDuplicate) then
		hr_utility.trace(' DUPLICATE is FALSE ');
	end if;

	return isDuplicate;

        End is_duplicate_block;

  Procedure deposit_detail_blocks
    (p_blocks           in out nocopy hxc_block_table_type,
     p_attributes       in out nocopy hxc_attribute_table_type,
     p_detail_blocks    in          hxc_timecard.block_list,
     p_deleted_blocks   in out nocopy hxc_timecard.block_list,
     p_transaction_info in out nocopy hxc_timecard.transaction_info,
     p_messages         in out nocopy hxc_message_table_type,
     p_timecard_id      in          number,
     p_timecard_ovn     in          number
     ) is

    l_index NUMBER;
    l_block HXC_BLOCK_TYPE;
    l_list  hxc_timecard.block_list;

    l_new_bb_id hxc_time_building_blocks.time_building_block_id%type;
    l_old_bb_id hxc_time_building_blocks.time_building_block_id%type;
    l_new_ovn   hxc_time_building_blocks.object_version_number%type;
    l_old_ovn   hxc_time_building_blocks.object_version_number%type;

    l_duplicate_block BOOLEAN := false;
    l_overlapping_block BOOLEAN := false;

    -- OTL - ABS Integration
    l_element     NUMBER;

    FUNCTION find_element( p_attributes   IN  HXC_ATTRIBUTE_TABLE_TYPE,
                           p_bb_id        IN  NUMBER)
    RETURN NUMBER
    IS

      l_element   NUMBER := 0;
      l_ind       BINARY_INTEGER;

    BEGIN
         IF p_attributes.COUNT > 0
         THEN
            l_ind := p_attributes.FIRST;
            LOOP
               hr_utility.trace('Ash : Time building_block '||p_attributes(l_ind).building_block_id);
               IF p_attributes(l_ind).building_block_id = p_bb_id
                 AND p_attributes(l_ind).attribute_category LIKE 'ELEMENT%'
               THEN
                  l_element := REPLACE(p_attributes(l_ind).attribute_category,'ELEMENT - ');
                  EXIT;
                END IF;
                l_ind := p_attributes.NEXT(l_ind);
                EXIT WHEN NOT p_attributes.EXISTS(l_ind);
            END LOOP;
          END IF;

          RETURN l_element;
    END find_element;


  Begin


   IF (nvl(fnd_profile.value('HXC_DEBUG_CHECK_ENABLED'), 'N') = 'Y') THEN -- 8888138

   -- Checking for duplicate records for detail blocks
   l_index := p_detail_blocks.first;

    LOOP
      EXIT WHEN NOT p_detail_blocks.exists(l_index) OR l_duplicate_block;

      l_block := p_blocks(p_detail_blocks(l_index));

      if(hxc_timecard_block_utils.is_active_block(l_block) AND is_duplicate_block(p_blocks, l_block)) then
	hr_utility.trace(' DUPLICATE BLOCK is TRUE ');
	l_duplicate_block := true;
      end if;

      l_index := p_detail_blocks.next(l_index);

    END LOOP;

    END IF; -- end of IF (nvl(fnd_profile.value('HXC_DEBUG_CHECK_ENABLED'), 'N') = 'Y') THEN


    IF(l_duplicate_block) THEN

	hr_utility.trace(' Adding error to table for block : ' || l_block.time_building_block_id);
	hxc_timecard_message_helper.addErrorToCollection
	(p_messages
	,'HXC_DUP_TIME_BUILDING_BLOCKS'
	,hxc_timecard.c_error
	,null
	,null
	,'HXC'
	,null
	,null
	,l_block.time_building_block_id
	,l_block.object_version_number
	,null);

    ELSE

   -- Depositing detail blocks

    l_index := p_detail_blocks.first;

    LOOP
      EXIT WHEN NOT p_detail_blocks.exists(l_index);

      l_block := p_blocks(p_detail_blocks(l_index));

      if(hxc_timecard_block_utils.process_block(l_block)) then
        if(hxc_timecard_block_utils.is_detail_block(l_block)) then

          if(hxc_timecard_block_utils.is_new_block(l_block)) then
            if(hxc_timecard_block_utils.is_active_block(l_block)) then
              deposit_new_block(l_block,l_old_bb_id,l_new_bb_id,p_transaction_info,p_messages);
              -- OTL - ABS Integration
               l_element := find_element(p_attributes,l_old_bb_id);
               IF g_debug
               THEN
                  hr_utility.trace('ABS : l_element '||l_element);
               	  hr_utility.trace('ABS : time_building_block_id '||l_block.time_building_block_id);
               	  hr_utility.trace('ABS : old time_building_block_id '||l_old_bb_id);
               	  hr_utility.trace('ABS : new time_building_block_id '||l_new_bb_id);
               END IF;
              hxc_retrieve_absences.update_co_absences(p_old_bb_id => l_old_bb_id,
                                                       p_new_bb_id => l_new_bb_id,
                                                       p_start_time=> FND_DATE.CANONICAL_TO_DATE(l_block.start_time),
                                                       p_stop_time => FND_DATE.CANONICAL_TO_DATE(l_block.stop_time),
                                                       p_element_id => l_element);
              add_transaction_info(l_new_bb_id,1,null,p_transaction_info,p_messages);
              p_blocks(p_detail_blocks(l_index)) := l_block;
              maintain_dependents
                (p_blocks
                 ,p_attributes
                 ,p_messages
                 ,l_list
                 ,l_old_bb_id
                 ,1
                 ,l_new_bb_id
                 ,1
                 ,p_timecard_id
                 ,p_timecard_ovn
                 );
            end if;
          else
            deposit_old_block(l_block,l_old_ovn,l_new_ovn,p_deleted_blocks,p_transaction_info,p_messages);
            -- OTL - ABS Integration
            IF hxc_timecard_block_utils.is_active_block(l_block)
            then
               l_element := find_element(p_attributes,l_block.time_building_block_id);
               IF g_debug
               THEN
                  hr_utility.trace('ABS : l_element '||l_element);
               	  hr_utility.trace('ABS : time_building_block_id '||l_block.time_building_block_id);
               	  hr_utility.trace('ABS l_old_ovn '||l_old_ovn);
               	  hr_utility.trace('ABS l_old_ovn '||l_new_ovn);
               END IF;
               hxc_retrieve_absences.update_co_absences_ovn(p_old_bb_id =>  l_block.time_building_block_id,
                                                            p_new_ovn   =>  l_new_ovn,
                                                            p_start_time => FND_DATE.CANONICAL_TO_DATE(l_block.start_time),
                                                            p_stop_time  => FND_DATE.CANONICAL_TO_DATE(l_block.stop_time),
                                                            p_element_id => l_element);
            END IF;
            add_transaction_info(l_block.time_building_block_id,l_new_ovn,null,p_transaction_info,p_messages);
            p_blocks(p_detail_blocks(l_index)) := l_block;
            maintain_dependents
              (p_blocks
               ,p_attributes
               ,p_messages
               ,l_list
               ,l_block.time_building_block_id
               ,l_old_ovn
               ,l_block.time_building_block_id
               ,l_new_ovn
               ,p_timecard_id
               ,p_timecard_ovn
               );
          end if;

        end if;
      end if;
      l_index := p_detail_blocks.next(l_index);

    END LOOP;

    END IF;

  End deposit_detail_blocks;



    FUNCTION get_days_to_hours_factor(p_resource_id IN number,
    				    p_evaluation_date IN date,
    				    p_dividing_factor in varchar2)
    RETURN NUMBER
    is

    l_hours NUMBER;
    l_day_hours NUMBER;
    l_dividing_factor number;
    l_pref_frequency varchar2(10);
    l_asg_frequency varchar2(10);

    CURSOR get_hours(p_reource_id IN number,
    		p_evaluation_date IN date,
    		p_dividing_factor IN number)
    IS
    SELECT normal_hours/p_dividing_factor
    FROM per_all_assignments_f
    WHERE person_id =p_reource_id
    AND assignment_type in ('E','C')
    AND primary_flag = 'Y'
    AND TRUNC(p_evaluation_date) BETWEEN effective_start_date AND effective_end_Date;

    BEGIN

    OPEN get_hours(p_resource_id, p_evaluation_date, p_dividing_factor);
    FETCH get_hours INTO l_hours;
    CLOSE get_hours;

    	return nvl(round(l_hours,2),1);

    END get_days_to_hours_factor;


  FUNCTION get_block_index(p_blocks in  hxc_block_table_type, p_tbb_id in number)
  return number
  IS

  l_index number;
  l_found boolean;
  l_block number;
  BEGIN

  l_index := p_blocks.first;

     Loop
       Exit when ((not p_blocks.exists(l_index)) or (l_found));

           if(p_tbb_id = p_blocks(l_index).time_building_block_id) then
           	l_found := true;
           	l_block := l_index;
           end if;


       l_index := p_blocks.next(l_index);
     End Loop;

     return l_block;

  END    get_block_index;

    Procedure deposit_attributes
      (p_attributes     in out nocopy hxc_attribute_table_type,
       p_messages       in out nocopy hxc_message_table_type,
       p_timecard_id    in            hxc_time_building_blocks.time_building_block_id%type,
       p_timecard_ovn   in            hxc_time_building_blocks.object_version_number%type,
       p_deleted_blocks in   out nocopy         hxc_timecard.block_list,
       p_blocks         in   out nocopy         hxc_block_table_type,
       p_transaction_info in out nocopy hxc_timecard.transaction_info
       ) is

      l_index     number;
      l_attribute hxc_attribute_type;

      l_time_attribute_id     hxc_time_attributes.time_attribute_id%type;
      l_object_version_number hxc_time_attributes.object_version_number%type;

      l_conversion_factor number;
      p_tco_att           hxc_self_service_time_deposit.building_block_attribute_info;
      l_tc_id             number;
      l_pref_table  hxc_preference_evaluation.t_pref_table;
      l_start_date date;
      l_stop_date date;
      l_resource_id number;
      l_dividing_factor number;
      l_active_index number;
      p_master_pref_table hxc_preference_evaluation.t_pref_table;
      l_update boolean := false;
      l_count number;
      l_block_index number;
      l_old_ovn number;
      l_new_ovn number;
      l_block HXC_BLOCK_TYPE;
      l_list  hxc_timecard.block_list;
      l_timecard_id number;
      l_timecard_ovn number;
      l_block_updated number := -999;

      l_new_bb_id hxc_time_building_blocks.time_building_block_id%type;
      l_old_bb_id hxc_time_building_blocks.time_building_block_id%type;
      l_updated_blocks hxc_timecard.block_list;
      l_local_index number;

    Begin

         --***********DAYS Vs HOURS - Start ************
         l_active_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);
         l_timecard_id := p_blocks(l_active_index).time_building_block_id;
         l_timecard_ovn := p_blocks(l_active_index).object_version_number;
         l_start_date := hxc_timecard_block_utils.date_value(p_blocks(l_active_index).start_time);
         l_stop_date := hxc_timecard_block_utils.date_value(p_blocks(l_active_index).stop_time);
         l_resource_id := p_blocks(l_active_index).resource_id;

       --Get the Preference value - Time Store Days to Hour Conversion
       hxc_preference_evaluation.resource_preferences(p_resource_id  => l_resource_id,
        			 p_preference_code => 'TS_PER_DAYS_TO_HOURS',
                                 p_start_evaluation_date => l_start_date,
                                 p_end_evaluation_date => l_stop_date,
                                 p_sorted_pref_table => l_pref_table,
                                 p_master_pref_table => p_master_pref_table );

         IF l_pref_table.count > 0 THEN
         	l_tc_id:=l_pref_table(1).attribute1;   --Time Category Identifying Day Elements
                l_dividing_factor := l_pref_table(1).attribute2;   --Number of Days in Assignment Frequency
         END IF;

       IF l_tc_id IS NOT NULL THEN

        	 hxc_time_category_utils_pkg.initialise_time_category (
                	                         p_time_category_id => l_tc_id
                           		        ,p_tco_att          => p_tco_att );

      	 l_conversion_factor:= get_days_to_hours_factor(l_resource_id,l_stop_date,l_dividing_factor );

      END IF;

       --***********DAYS Vs HOURS - End ************

      -- Loop over all attributes, and deposit the ones
      -- that need it.
      --

        l_index := p_attributes.first;

      LOOP
        EXIT WHEN NOT p_attributes.exists(l_index);


        --
        -- If the attribute should be processed - deposit
        -- it.
        --

         l_attribute := p_attributes(l_index);

          --***********DAYS Vs HOURS - Start ************

         IF l_tc_id IS NOT NULL THEN

           IF (l_attribute.ATTRIBUTE_CATEGORY LIKE 'ELEMENT%' OR
             l_attribute.ATTRIBUTE_CATEGORY = 'PROJECTS')THEN -- Process only Payroll and Projects attributes

                 if l_attribute.process <> hxc_timecard.c_process
  	          and not l_updated_blocks.exists(l_attribute.BUILDING_BLOCK_ID) then

		--When the block/atribute not touched, but the value of the Preference changed like
		--Time Category chnaged from NULL => TC1 or TC1=> NULL or TC1=>TC2, so in this case
		--we need to process the block/attribute to take the new value of preference.

  	            IF hxc_time_category_utils_pkg.chk_tc_bb_ok ( l_attribute.BUILDING_BLOCK_ID )
  	            	AND nvl(l_attribute.ATTRIBUTE26,1) <> l_conversion_factor then
  	            	l_update := true;
  	            	l_attribute.ATTRIBUTE26 :=l_conversion_factor;
  	            elsif  NOT hxc_time_category_utils_pkg.chk_tc_bb_ok ( l_attribute.BUILDING_BLOCK_ID )
  	            and nvl(l_attribute.ATTRIBUTE26,1) <> 1  THEN
 			l_update := true;
  	            	l_attribute.ATTRIBUTE26 :=null;

  	            END IF;

         	 end if;

  	       if ( hxc_time_category_utils_pkg.chk_tc_bb_ok ( l_attribute.BUILDING_BLOCK_ID ) )  then
  		       l_attribute.ATTRIBUTE26 :=l_conversion_factor;
  	       else
  		       l_attribute.ATTRIBUTE26:=1;
  	       end if;
  	  END IF;

         ELSE
	     IF (l_attribute.ATTRIBUTE_CATEGORY = 'PROJECTS')THEN
	     		--l_attribute.ATTRIBUTE_CATEGORY LIKE 'ELEMENT%' OR

		if l_attribute.process <> hxc_timecard.c_process
		 and nvl(l_attribute.ATTRIBUTE26,1) <> 1
		 and not l_updated_blocks.exists(l_attribute.BUILDING_BLOCK_ID)
		then
			--When the Time category is changed from TC1 => NULL, although the block is not touched
			--we must resubmit the block.
			l_update := true;

		end if;

		l_attribute.ATTRIBUTE26 :=null;

	      END IF;
         END IF;

         IF l_update THEN

             l_update:= false;

             l_updated_blocks(l_attribute.BUILDING_BLOCK_ID) := 1;

             l_block_index:= get_block_index(p_blocks, l_attribute.BUILDING_BLOCK_ID);
             l_block := p_blocks(l_block_index);

             deposit_old_block(l_block,l_old_ovn,l_new_ovn,p_deleted_blocks,p_transaction_info,p_messages);

             add_transaction_info(l_block.time_building_block_id
          	,l_new_ovn,null,p_transaction_info,p_messages);

  	   p_blocks(l_block_index) := l_block;
   	   p_blocks(l_block_index).process := 'Y';

  	   l_local_index := p_attributes.first;

  	    LOOP
  	      EXIT WHEN NOT p_attributes.exists(l_local_index);

            	if(hxc_timecard_attribute_utils.is_corresponding_block
  		  (p_attribute => p_attributes(l_local_index)
  		   ,p_block_id  => l_block.time_building_block_id
  		   )
  	         ) then

  			p_attributes(l_local_index).building_block_id := l_block.time_building_block_id;
  			p_attributes(l_local_index).building_block_ovn := l_new_ovn;
   			p_attributes(l_local_index).process := hxc_timecard.c_process;
    	        end if;

  	      l_local_index := p_attributes.next(l_local_index);

             END LOOP;

             l_attribute.building_block_id := p_attributes(l_index).building_block_id;
             l_attribute.building_block_ovn := p_attributes(l_index).building_block_ovn;
             l_attribute.process := p_attributes(l_index).process;

         END IF;

	 --***********DAYS Vs HOURS - End ************

        if((hxc_timecard_attribute_utils.process_attribute(p_attribute => l_attribute))
           AND
             (not p_deleted_blocks.exists(l_attribute.building_block_id))
           ) then

          hxc_time_attributes_api.create_attribute
            (P_ATTRIBUTE_CATEGORY         => l_attribute.ATTRIBUTE_CATEGORY,
             P_ATTRIBUTE1               => l_attribute.ATTRIBUTE1,
             P_ATTRIBUTE2               => l_attribute.ATTRIBUTE2,
             P_ATTRIBUTE3               => l_attribute.ATTRIBUTE3,
             P_ATTRIBUTE4               => l_attribute.ATTRIBUTE4,
             P_ATTRIBUTE5               => l_attribute.ATTRIBUTE5,
             P_ATTRIBUTE6               => l_attribute.ATTRIBUTE6,
             P_ATTRIBUTE7               => l_attribute.ATTRIBUTE7,
             P_ATTRIBUTE8               => l_attribute.ATTRIBUTE8,
             P_ATTRIBUTE9               => l_attribute.ATTRIBUTE9,
             P_ATTRIBUTE10              => l_attribute.ATTRIBUTE10,
             P_ATTRIBUTE11              => l_attribute.ATTRIBUTE11,
             P_ATTRIBUTE12              => l_attribute.ATTRIBUTE12,
             P_ATTRIBUTE13              => l_attribute.ATTRIBUTE13,
             P_ATTRIBUTE14              => l_attribute.ATTRIBUTE14,
             P_ATTRIBUTE15              => l_attribute.ATTRIBUTE15,
             P_ATTRIBUTE16              => l_attribute.ATTRIBUTE16,
             P_ATTRIBUTE17              => l_attribute.ATTRIBUTE17,
             P_ATTRIBUTE18              => l_attribute.ATTRIBUTE18,
             P_ATTRIBUTE19              => l_attribute.ATTRIBUTE19,
             P_ATTRIBUTE20              => l_attribute.ATTRIBUTE20,
             P_ATTRIBUTE21              => l_attribute.ATTRIBUTE21,
             P_ATTRIBUTE22              => l_attribute.ATTRIBUTE22,
             P_ATTRIBUTE23              => l_attribute.ATTRIBUTE23,
             P_ATTRIBUTE24              => l_attribute.ATTRIBUTE24,
             P_ATTRIBUTE25              => l_attribute.ATTRIBUTE25,
             P_ATTRIBUTE26              => l_attribute.ATTRIBUTE26,
             P_ATTRIBUTE27              => l_attribute.ATTRIBUTE27,
             P_ATTRIBUTE28              => l_attribute.ATTRIBUTE28,
             P_ATTRIBUTE29              => l_attribute.ATTRIBUTE29,
             P_ATTRIBUTE30              => l_attribute.ATTRIBUTE30,
             P_TIME_BUILDING_BLOCK_ID   => l_attribute.BUILDING_BLOCK_ID,
             P_TBB_OVN                  => l_attribute.BUILDING_BLOCK_OVN,
             P_BLD_BLK_INFO_TYPE_ID     => nvl(l_attribute.BLD_BLK_INFO_TYPE_ID,
                                                  hxc_timecard_attribute_utils.get_bld_blk_info_type_id(l_attribute.bld_blk_info_type)),
             P_TIME_ATTRIBUTE_ID        => l_time_attribute_id,
             P_OBJECT_VERSION_NUMBER    => l_object_version_number
             );
          --
          -- Maintain the errors structure
          --
          maintain_error_table
            (p_messages     => p_messages,
             p_old_ta_id    => p_attributes(l_index).time_attribute_id,
             p_old_ta_ovn   => p_attributes(l_index).object_version_number,
             p_new_ta_id    => l_time_attribute_id,
             p_new_ta_ovn   => l_object_version_number,
             p_timecard_id  => p_timecard_id,
             p_timecard_ovn => p_timecard_ovn
             );

          --
          -- Maintain the structure
          --
          p_attributes(l_index).time_attribute_id := l_time_attribute_id;
          p_attributes(l_index).object_version_number := l_object_version_number;

        end if;

        l_index := p_attributes.next(l_index);
      END LOOP;

  End deposit_attributes;


  procedure populate_transaction_data_set(p_transaction_info in out nocopy hxc_timecard.transaction_info)
  is

    cursor c_get_data_set_id(p_tbb_id number,p_tbb_ovn number) is
      select data_set_id
        from hxc_time_building_blocks
       where time_building_block_id = p_tbb_id
         and object_version_number = p_tbb_ovn;

    l_data_set_id hxc_transaction_details.data_set_id%TYPE;
    l_index BINARY_INTEGER;
  begin



    l_index := p_transaction_info.first;
    if l_index is not null then
      open c_get_data_set_id(p_transaction_info(l_index).time_building_block_id,
                             p_transaction_info(l_index).object_version_number);
      fetch c_get_data_set_id into l_data_set_id;
      close c_get_data_set_id;
    end if;

    While l_index is not null loop
      p_transaction_info(l_index).data_set_id := l_data_set_id;
      if g_debug then
        hr_utility.trace(p_transaction_info(l_index).time_building_block_id||'-'||p_transaction_info(l_index).data_set_id);
      end if;
      l_index := p_transaction_info.next(l_index);
    End loop;

  end populate_transaction_data_set;


  Procedure execute
      (p_blocks         in out nocopy hxc_block_table_type,
       p_attributes       in out nocopy hxc_attribute_table_type,
       p_timecard_blocks  in          hxc_timecard.block_list,
       p_day_blocks       in          hxc_timecard.block_list,
       p_detail_blocks    in          hxc_timecard.block_list,
       p_messages       in out nocopy hxc_message_table_type,
       p_transaction_info in out nocopy hxc_timecard.transaction_info
       ) is

      l_timecard_id  hxc_time_building_blocks.time_building_block_id%type;
      l_timecard_ovn hxc_time_building_blocks.object_version_number%type;

      l_deleted_blocks hxc_timecard.block_list;
      l_dummy boolean;

       cursor c_check_bussiness_group_id(p_person_id number, p_timecard_start_date date) is
            	SELECT business_group_id,
            	  organization_id
            	FROM per_all_assignments_f
            	WHERE person_id = p_person_id
            	 AND assignment_type IN('E',   'C')
            	 AND primary_flag = 'Y'
            	 AND p_timecard_start_date BETWEEN effective_start_date AND effective_end_date;

     l_business_group_id per_all_assignments_f.business_group_id%type;
     l_organization_id   per_all_assignments_f.organization_id%type;


    Begin

      g_debug := hr_utility.debug_enabled;

      -- A new Savepoint has been introduced to makesure we rollback the
      -- block transaction incase of any exception being thrown.
      savepoint deposit_timecard;


                    hr_utility.trace('*********************InvalidSecurityContext Trace Start**********************************');
                    hr_utility.trace('InvalidSecurityContext > PER_BUSINESS_GROUP_ID from fnd profile : '||fnd_profile.value('PER_BUSINESS_GROUP_ID'));
                    hr_utility.trace('InvalidSecurityContext > ORG_ID from fnd profile : '||fnd_profile.value('ORG_ID'));
                    hr_utility.trace('InvalidSecurityContext > Resource_id : '||  p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).resource_id);
                    hr_utility.trace('InvalidSecurityContext > Timecard Start Time :'||  p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time);

    open c_check_bussiness_group_id(p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).resource_id,
				 hxc_timecard_block_utils.date_value(p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time));
	  fetch c_check_bussiness_group_id into l_business_group_id,l_organization_id;
    close c_check_bussiness_group_id;

    hr_utility.trace('InvalidSecurityContext > BUSINESS_GROUP_ID of the person : '||l_business_group_id);
    hr_utility.trace('InvalidSecurityContext > ORG_ID of the person : '||l_organization_id);

    IF l_business_group_id <> fnd_profile.value('PER_BUSINESS_GROUP_ID') THEN

	     hxc_timecard_message_helper.addErrorToCollection
		      (p_messages
		       ,'HXC_366551_INVALID_SEC_CONTEXT' -- You cannot submit this timecard because of invalid security context. Please logout and try again or contact your system administrator.
		       ,hxc_timecard.c_error
		       ,null
		       ,null
		       ,'HXC'
		       ,null
		       ,null
		       ,null
		       ,null
	   );
	    hr_utility.trace('InvalidSecurityContext >l_business_group_id <> fnd_profile.value(PER_BUSINESS_GROUP_ID) : True');

    ELSE
      	    hr_utility.trace('InvalidSecurityContext >l_business_group_id <> fnd_profile.value(PER_BUSINESS_GROUP_ID) : False');
      l_deleted_blocks.delete;

            -- OTL - ABS Integration
            IF hxc_retrieve_absences.g_detail_trans_tab.COUNT > 0
            THEN
               hxc_retrieve_absences.g_detail_trans_tab.DELETE;
            END IF;


      -- Blocks have to be in order, to ensure
      -- self referential integrity

      deposit_timecard_blocks(p_blocks,p_attributes,p_timecard_blocks,p_day_blocks,l_deleted_blocks,p_transaction_info,p_messages);
      l_timecard_id := p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).time_building_block_id;
      l_timecard_ovn := p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).object_version_number;
      deposit_day_blocks(p_blocks,p_attributes,p_day_blocks,p_detail_blocks,l_deleted_blocks,p_transaction_info,p_messages,l_timecard_id,l_timecard_ovn);
      deposit_detail_blocks(p_blocks,p_attributes,p_detail_blocks,l_deleted_blocks,p_transaction_info,p_messages,l_timecard_id,l_timecard_ovn);
      --
      -- And now corresponding attributes
      --
      hxc_time_category_utils_pkg.push_timecard(p_blocks, p_attributes);

      deposit_attributes(p_attributes,p_messages,l_timecard_id,l_timecard_ovn,l_deleted_blocks,
      			p_blocks, p_transaction_info);
      --
      -- Maintain the timecard summary structures
      populate_transaction_data_set(p_transaction_info);

      -- OTL - ABS Integration
      IF  p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).SCOPE <> hxc_timecard.c_template_scope THEN

        hxc_retrieve_absences.manage_retrieval_audit (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).resource_id,
                                                      FND_DATE.canonical_to_date(p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time),
                                                      TRUNC(FND_DATE.canonical_to_date(p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).stop_time)));
      END IF;



  END IF;
        hr_utility.trace('*********************InvalidSecurityContext Trace End*************************************');


    Exception
      When Others then
        rollback to deposit_timecard;

        --Pickup the last message(HXC_USAGE_DATA_MISSING) that has been set.
        hr_message.provide_error;
        if (hr_message.last_message_name is not null) then
  	hxc_timecard_message_helper.addErrorToCollection
            (p_messages,
             hr_message.last_message_name,
             hxc_timecard.c_error,
             null,
             null,
             'HXC',
             null,
             null,
             null,
             null
             );
        else
          raise; --If any other exception occurs without errormsg being set.
        end if;

    End execute;

End hxc_timecard_deposit;

/
