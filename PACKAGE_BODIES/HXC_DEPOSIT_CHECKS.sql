--------------------------------------------------------
--  DDL for Package Body HXC_DEPOSIT_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DEPOSIT_CHECKS" AS
/* $Header: hxcdpwrck.pkb 120.9 2006/07/13 21:29:54 arundell noship $ */
--
-- Types
--
TYPE asg_dates is RECORD
      (start_date date
      ,end_date   date
      );

Type asg_info is table of asg_dates index by binary_integer;

Type block_list is table of number index by binary_integer;

-- Package Variables
--
g_package  varchar2(33) := '  hxc_deposit_checks.';

--
-- ----------------------------------------------------------------------------
-- |-------------------------< can_delete_template >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is called by the deposit controller for self service
-- timecard deposit to ensure that the template the user is requesting to
-- delete is not set as a default template for any user.  This should only
-- be an issue if the user has set one of their own templates as a default
-- or if an administrator has created a public template.
--
-- Prerequisites:
--   The template must exist.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   p_template_id             Yes Number   The id of the timecard
--                              template
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
Procedure can_delete_template
        (p_template_id in         hxc_time_building_blocks.time_building_block_id%type
        ,p_messages    in out nocopy hxc_message_table_type) is

cursor c_template_details
     (p_id in hxc_time_building_blocks.time_building_block_id%type) is
select TEMPLATE_TYPE from hxc_template_summary
where template_id = p_id;

l_exists      VARCHAR2(6);
l_template_type hxc_template_summary.template_type%type;
l_attached_public_temp_grps varchar2(1500);
l_pref_value  VARCHAR2(170);

Begin

l_attached_public_temp_grps := NULL;

open c_template_details(p_template_id);
fetch c_template_details into l_template_type;
if c_template_details%found then

  if(l_template_type='PUBLIC') then
  	--Check whether the public template can be deleted.
	l_attached_public_temp_grps := hxc_public_temp_group_comp_api.can_delete_public_template(p_template_id=>p_template_id);
  end if;

 if(l_attached_public_temp_grps is NULL) then  --Carry out the normal operations for private/public templates.

  l_pref_value := l_template_type||'|'||p_template_id;

  l_exists := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                 ('TC_W_TMPLT_DFLT_VAL_USR'
               ,1
               ,l_pref_value);
  if ( l_exists <> 0 ) THEN
    hxc_timecard_message_helper.addErrorToCollection
      (p_messages
      ,'HXC_CANT_DEL_TEMPL'
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
    l_exists := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                ('TC_W_TMPLT_DFLT_VAL_ADMIN'
                 ,1
                 ,l_pref_value);
    if ( l_exists <> 0 ) THEN
      hxc_timecard_message_helper.addErrorToCollection
     (p_messages
     ,'HXC_CANT_DEL_TEMPL'
     ,hxc_timecard.c_error
     ,null
     ,null
     ,hxc_timecard.c_hxc
     ,null
     ,null
     ,null
     ,null
     );
    END if;
   END IF;
  else

  -- Public Template Specific

    hxc_timecard_message_helper.addErrorToCollection
      (p_messages
      ,'HXC_CANT_DEL_PUB_TEMPL'
      ,hxc_timecard.c_error
      ,null
      ,'GROUPS&'||l_attached_public_temp_grps
      ,hxc_timecard.c_hxc
      ,null
      ,null
      ,null
      ,null
      );
  end if;
end if;
close c_template_details;

End can_delete_template;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_inputs >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is called by the deposit controller for self service
-- timecard deposit to ensure that the calling process has sent parameters
-- that make sense in terms of deposit.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   p_blocks                 Yes  BLOCKS   The blocks to deposit
--   p_atttributes            Yes  ATTRS    The attributes to deposit
--   p_deposit_mode           Yes  Varchar2 The mode of deposit
--   p_template               Yes  Varchar2 Is this a template?
--   p_messages               Yes  MESSAGES The application messages
--
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
PROCEDURE check_inputs
         (p_blocks          in         hxc_block_table_type
         ,p_attributes      in         hxc_attribute_table_type
         ,p_deposit_mode       in         varchar2
         ,p_template        in         varchar2
         ,p_messages        in out nocopy hxc_message_table_type
         ) is

l_proc varchar2(70) := g_package||'check_inputs';

BEGIN

--
-- We must have at least one block to deposit
--
if(p_blocks.count <1) then

  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_XXXXX_NO_BLOCKS'
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

--
-- The deposit mode must be SUBMIT, SAVE or AUDIT
-- (others not currently supported)
--
if (NOT ((p_deposit_mode=hxc_timecard.c_submit) OR (p_deposit_mode=hxc_timecard.c_save) OR p_deposit_mode=hxc_timecard.c_audit)) then

  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_XXXXX_INVALID_DEP_MODE'
    ,hxc_timecard.c_error
    ,null
    ,'MODE&'||p_deposit_mode
    ,hxc_timecard.c_hxc
    ,null
    ,null
    ,null
    ,null
    );

end if;

--
-- We must have a Y or N value for the template
--
if (NOT ((p_template='Y') OR (p_template='N'))) then

  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_XXXXX_INVALID_TEMPLATE'
    ,hxc_timecard.c_error
    ,null
    ,'VALUE&'||p_template
    ,hxc_timecard.c_hxc
    ,null
    ,null
    ,null
    ,null
    );

end if;

if ((p_template='Y') AND (p_deposit_mode = hxc_timecard.c_save)) then

  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_XXXXX_INVALID_DEP_MODE'
    ,hxc_timecard.c_error
    ,null
    ,'MODE&'||p_deposit_mode
    ,hxc_timecard.c_hxc
    ,null
    ,null
    ,null
    ,null
    );

end if;

END check_inputs;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< audit_checks >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the user has entered all reasons required
-- by the instance audit requirements.
--
-- Prerequisites:
--   A table of audit reasons exists
--
-- In Parameters:
--   Name                  Reqd Type       Description
--   p_blocks                 Yes  BLOCKS     The blocks to deposit
--   p_attributes             Yes  ATTRIBUTES The attributes
--   p_messages               Yes  MESSAGES   The failure messages
--                                /Reason messages
--
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
PROCEDURE audit_checks
        (p_blocks     in         hxc_block_table_type
        ,p_attributes in         hxc_attribute_table_type
        ,p_messages   in out nocopy hxc_message_table_type
        ) is

l_index number;
l_found  BOOLEAN;
l_att_index number;
l_missing_reasons hxc_message_table_type;

BEGIN

l_missing_reasons := hxc_message_table_type();

l_index := p_messages.first;

LOOP
  EXIT WHEN NOT p_messages.exists(l_index);
  IF(p_messages(l_index).message_level = 'REASON') THEN
     l_found:=TRUE;
     l_att_index:=p_attributes.first;
     LOOP
       EXIT WHEN ((NOT p_attributes.exists(l_att_index)) OR (NOT l_found));
       if (
       ( p_attributes(l_att_index).building_block_id=p_messages(l_index).time_building_block_id)
         and (p_attributes(l_att_index).ATTRIBUTE_CATEGORY = 'REASON')
	    AND (p_messages(l_index).MESSAGE_TOKENS=p_attributes(l_att_index).attribute3)
    	    AND (p_attributes(l_att_index).NEW ='Y')
	    AND (p_attributes(l_att_index).attribute1 is not null)
	  ) then
       l_found:=FALSE;
       end if;
       l_att_index:=p_attributes.next(l_att_index);
     END LOOP;

     IF l_found THEN
       hxc_timecard_message_helper.addErrorToCollection
     (p_messages => l_missing_reasons
     ,p_message_name => 'HXC_REASON_NOT_ENTERED'
     ,p_message_tokens => NULL
     ,p_message_level => hxc_timecard.c_error
     ,p_message_field => NULL
     ,p_application_short_name => hxc_timecard.c_hxc
     ,p_time_building_block_id => NULL
     ,p_time_building_block_ovn => NULL
     ,p_time_attribute_id => NULL
     ,p_time_attribute_ovn => NULL
     );
     End if;
   End if;
   l_index := p_messages.next(l_index);
END LOOP;

p_messages := l_missing_reasons;

End audit_checks;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< timecard_deleted >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function checks that if we have an existing timecard in the same
-- period as the one we are attempting to deposit, that the blocks we're
-- depositing also cause the existing time store timecard to be date effectively
-- deleted.  In that case, we can permit deposit.
--
-- Prerequisites:
--   We have found an existing timecard for this period in the time store.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   p_blocks                 Yes  BLOCKS   The blocks to deposit
--   p_timecard_id            Yes  NUMBER   The id of the existing
--                              timecard, to check that
--                              is being deleted with the
--                              deposit.
--
-- Return Values:
--   FALSE : The existing timecard is NOT being deleted with this submission.
--   TRUE  : The existing timecard is being deleted with this submission.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
FUNCTION timecard_deleted
        (p_blocks in HXC_BLOCK_TABLE_TYPE
        ,p_timecard_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
        ) return BOOLEAN is

l_deleted_tc BOOLEAN := false;
l_block_count NUMBER;

BEGIN

l_block_count := p_blocks.first;

LOOP
  EXIT WHEN l_deleted_tc;
  EXIT WHEN NOT p_blocks.exists(l_block_count);

  if(p_blocks(l_block_count).time_building_block_id = p_timecard_id) then
   if(fnd_date.canonical_to_date(p_blocks(l_block_count).date_to) <> hr_general.end_of_time) then
     l_deleted_tc := true;
   end if;
  end if;

  l_block_count := p_blocks.next(l_block_count);

END LOOP;

RETURN l_deleted_tc;

END timecard_deleted;
--
-- Overloaded version, to call from deposit wrapper.
--
FUNCTION timecard_deleted
        (p_blocks in hxc_self_service_time_deposit.timecard_info
        ,p_timecard_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
        ) return BOOLEAN is

l_deleted_tc BOOLEAN := false;
l_block_count NUMBER;

BEGIN

l_block_count := p_blocks.first;

LOOP
  EXIT WHEN l_deleted_tc;
  EXIT WHEN NOT p_blocks.exists(l_block_count);

  if(p_blocks(l_block_count).time_building_block_id = p_timecard_id) then
   if(p_blocks(l_block_count).date_to <> hr_general.end_of_time) then
     l_deleted_tc := true;
   end if;
  end if;

  l_block_count := p_blocks.next(l_block_count);

END LOOP;

RETURN l_deleted_tc;

END timecard_deleted;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_timecard_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function checks that no current timecards exist within the time
--   span of the timecard we're attempting to deposit.
--
-- Prerequisites:
--   We have the timecard resource id, start time, stop time and id which
--   we are attempting to deposit.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   p_resource_id            Yes  Number   The resource id
--   p_start_time             Yes  Date     The proposed start time
--   p_stop_time              Yes  Date     The proposed stop time
--   p_time_building_block_id       Yes  Number   The id of this timecard
--
-- Return Values:
--   NULL  : A timecard does not already exist for this period.
-- NON-NULL: The value of the time building block id of the timecard
--        that already exists, for use in further checks.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
FUNCTION chk_timecard_exists
        (p_resource_id in HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
        ,p_start_time in HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE
        ,p_stop_time in HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE
        ,p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
        ) RETURN NUMBER is

l_existing_timecard_id HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE;

begin

 select tbb.time_building_block_id into l_existing_timecard_id
   from hxc_time_building_blocks tbb
  where tbb.resource_id = p_resource_id
    and tbb.scope = 'TIMECARD'
    and tbb.date_to = hr_general.end_of_time
    and tbb.start_time <= p_stop_time
    and tbb.stop_time >= p_start_time
    and tbb.time_building_block_id <> p_time_building_block_id;


RETURN l_existing_timecard_id;

EXCEPTION
  WHEN others then
  --
  -- No data found error, so continue with deposit.
  --
    RETURN null;

END chk_timecard_exists;

--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_timecard_deposit >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function checks that no current timecards exist within the time
--   span of the timecard we're attempting to deposit.
--
-- Prerequisites:
--   The blocks we're attempting to deposit are populated.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   p_blocks                 Yes  BLOCKS   The blocks to deposit
--   p_block_number           Yes  number   The number of the block
--                              record to check.
--
-- Return Values:
--   FALSE : No timecard exists within this time period, and deposit can
--        continue
--   TRUE  : A timecard exists, we should raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
FUNCTION chk_timecard_deposit
        (p_blocks in HXC_BLOCK_TABLE_TYPE
        ,p_block_number in NUMBER
        ) return BOOLEAN is

l_test_tc_id HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE;

l_proc varchar2(72) := g_package||'chk_timceard_deposit';

BEGIN

--
-- Check that this timecard scope building block is still
-- active, and has the right scope - it should do since we
-- checked elsewhere, but double check.
--
if (p_blocks(p_block_number).scope = 'TIMECARD') then

  if (fnd_date.canonical_to_date(p_blocks(p_block_number).date_to) = hr_general.end_of_time) then
  --
  -- Run the check
  --
    l_test_tc_id := chk_timecard_exists
          (p_blocks(p_block_number).resource_id
          ,fnd_date.canonical_to_date(p_blocks(p_block_number).start_time)
          ,fnd_date.canonical_to_date(p_blocks(p_block_number).stop_time)
          ,p_blocks(p_block_number).time_building_block_id
          );

    if(l_test_tc_id is null) then
    --
    -- No existing timecard, therefore we can
    -- continue with the deposit
    --
       RETURN FALSE;
    else
    --
    -- There is another timecard out there that overlaps this
    -- period.  Now we check whether this timecard is included
    -- in the blocks that we are depositing as a deleted block
    -- in which case this is ok, otherwise, we must stop
    -- submission.
    --
       if(timecard_deleted
        (p_blocks
        ,l_test_tc_id
        )) then
       --
       -- We are deleting the existing timecard as part of this
       -- submission.  This is ok, and submission can continue.
       --
       RETURN FALSE;

       else
       --
       -- We aren't deleting the existing timecard
       -- as part of this submission.  Abort this
       -- deposit.
       --
      RETURN TRUE;

       end if;

    end if;

  end if; -- is the end date the end of time?

end if; -- Is this a timecard scope block?

--
-- If we get here, then we should deposit this block!
--

RETURN FALSE;

END chk_timecard_deposit;
--
-- Overloaded version for calling from deposit wrapper
--
FUNCTION chk_timecard_deposit
        (p_blocks in hxc_self_service_time_deposit.timecard_info
        ,p_block_number in NUMBER
        ) return BOOLEAN is

l_test_tc_id HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE;

BEGIN

--
-- Check that this timecard scope building block is still
-- active, and has the right scope - it should do since we
-- checked elsewhere, but double check.
--
if (p_blocks(p_block_number).scope = 'TIMECARD') then

  if (p_blocks(p_block_number).date_to = hr_general.end_of_time) then
  --
  -- Run the check
  --
    l_test_tc_id := chk_timecard_exists
          (p_blocks(p_block_number).resource_id
          ,p_blocks(p_block_number).start_time
          ,p_blocks(p_block_number).stop_time
          ,p_blocks(p_block_number).time_building_block_id
          );

    if(l_test_tc_id is null) then
    --
    -- No existing timecard, therefore we can
    -- continue with the deposit
    --
       RETURN FALSE;
    else
    --
    -- There is another timecard out there that overlaps this
    -- period.  Now we check whether this timecard is included
    -- in the blocks that we are depositing as a deleted block
    -- in which case this is ok, otherwise, we must stop
    -- submission.
    --
       if(timecard_deleted
        (p_blocks
        ,l_test_tc_id
        )) then
       --
       -- We are deleting the existing timecard as part of this
       -- submission.  This is ok, and submission can continue.
       --
       RETURN FALSE;

       else
       --
       -- We aren't deleting the existing timecard
       -- as part of this submission.  Abort this
       -- deposit.
       --
      RETURN TRUE;

       end if;

    end if;

  end if; -- is the end date the end of time?

end if; -- Is this a timecard scope block?

--
-- If we get here, then we should deposit this block!
--

RETURN FALSE;

END chk_timecard_deposit;

Function inactive_detail
       (p_dates in asg_info
       ,p_date  in date
       ) return BOOLEAN is

l_inactive  boolean := true;
l_index     number;

Begin

l_index := p_dates.first;
Loop
  Exit when ((NOT p_dates.exists(l_index)) OR (NOT l_inactive));

  if(p_date between p_dates(l_index).start_date and p_dates(l_index).end_date) then

    l_inactive := false;

  end if;

  l_index := p_dates.next(l_index);
End Loop;

return l_inactive;

End inactive_detail;

Procedure check_start_stop_time
        (p_blocks       	in         hxc_block_table_type
        ,p_details      	in         hxc_timecard.block_list
        ,p_messages     	in out nocopy hxc_message_table_type
        ,p_validate_on_save  in 	      hxc_pref_hierarchies.attribute1%type
        ) is
l_index       number;

BEGIN

l_index := p_details.first;
Loop
  Exit When Not p_details.exists(l_index);
  if(hxc_timecard_block_utils.is_active_block(p_blocks(p_details(l_index)))) then

      IF p_blocks(p_details(l_index)).start_time is not null and
      p_blocks(p_details(l_index)).stop_time is null  and
	 (p_blocks(p_details(l_index)).approval_status = hxc_timecard.c_submitted_status
	 or
	  p_validate_on_save = hxc_timecard.c_yes
	  )
	  THEN

       hxc_timecard_message_helper.addErrorToCollection
     (p_messages => p_messages
     ,p_message_name => 'HXC_NULL_STOP_SUBMIT'
     ,p_message_tokens => NULL
     ,p_message_level => hxc_timecard.c_error
     ,p_message_field => NULL
     ,p_application_short_name => hxc_timecard.c_hxc
     ,p_time_building_block_id => p_blocks(p_details(l_index)).time_building_block_id
     ,p_time_building_block_ovn => NULL
     ,p_time_attribute_id => NULL
     ,p_time_attribute_ovn => NULL
     );
      END IF;
  end if; -- is this an active detail
  l_index := p_details.next(l_index);
End Loop;

END check_start_stop_time;


Procedure find_detail_date_extremes
        (p_blocks       in         hxc_block_table_type
        ,p_days      in         hxc_timecard.block_list
        ,p_details      in         hxc_timecard.block_list
        ,p_early_detail in out nocopy date
        ,p_late_detail  in out nocopy date
        ) is
l_index       number;
l_detail_date date;

Begin

l_index := p_details.first;

Loop
  Exit When Not p_details.exists(l_index);
  if(hxc_timecard_block_utils.is_active_block(p_blocks(p_details(l_index)))) then
    l_detail_date := trunc(
                 hxc_timecard_block_utils.date_value(
                p_blocks(
                  p_days(
                    p_blocks(p_details(l_index)).parent_building_block_id
                      )
                      ).start_time
                 ));

    if(l_detail_date < p_early_detail) then
      p_early_detail := l_detail_date;
    end if;
    if(l_detail_date > p_late_detail) then
      p_late_detail := l_detail_date;
    end if;
  end if; -- is this an active detail
  l_index := p_details.next(l_index);
End Loop;

End find_detail_date_extremes;

Procedure chk_inactive_details
       (p_blocks     in         hxc_block_table_type
       ,p_props      in         hxc_timecard_prop_table_type
       ,p_days       in         hxc_timecard.block_list
       ,p_details    in         hxc_timecard.block_list
       ,p_block_idxs    out nocopy block_list
       ) is

l_early_detail  date := hr_general.end_of_time;
l_late_detail   date := hr_general.start_of_time;
l_detail_date   date;
l_asg_info      asg_info;
l_index      number;
l_block_index   number;

l_all_active    boolean;

l_proc       varchar2(70) := g_package||'chk_inactive_details';

Begin
--
-- Calculate earliest and latest detail dates
--

find_detail_date_extremes
 (p_blocks       => p_blocks
 ,p_days      => p_days
 ,p_details      => p_details
 ,p_early_detail => l_early_detail
 ,p_late_detail  => l_late_detail
 );

--
-- So 99% Case, check to see if the earliest detail
-- and latest detail lie within an active assignment
-- period.  Loop over the
--

l_all_active := false;

l_index := p_props.first;

Loop
  Exit When ((Not p_props.exists(l_index)) or l_all_active);

  if(p_props(l_index).property_name = 'ResourceAssignmentId') then
    --
    -- Check to see if the details are contained within this assignment
    --
    if((p_props(l_index).date_from <= l_early_detail)
     AND
      (p_props(l_index).date_to >= l_late_detail)) then

      l_all_active := true;

    end if;
    --
    -- Keep a record of the dates, in case we need to do the other
    -- check
    --
    l_asg_info(l_index).start_date := p_props(l_index).date_from;
    l_asg_info(l_index).end_date := p_props(l_index).date_to;

  end if;

  l_index := p_props.next(l_index);
End Loop;

if(NOT l_all_active) then
--
-- Ok, not all the details corresponded to one
-- active assignment.  Now look across
-- assignments.  This is much less likely.
--
l_all_active := true;

l_block_index := p_details.first;

Loop
  Exit When Not p_details.exists(l_block_index);
  if(hxc_timecard_block_utils.is_active_block(p_blocks(p_details(l_block_index)))) then
    l_detail_date := trunc(
               hxc_timecard_block_utils.date_value(
                 p_blocks(
                p_days(
                  p_blocks(p_details(l_block_index)).parent_building_block_id
                    )
                    ).start_time
               ));

    if(inactive_detail(l_asg_info,l_detail_date)) then

      l_all_active := false;
      p_block_idxs(l_block_index) := l_block_index;

    end if;
  end if;

  l_block_index := p_details.next(l_block_index);
End Loop;

end if;

End chk_inactive_details;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< perform_checks >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs all the basic checks on the timecard information
-- pre-deposit.
--
-- Prerequisites:
--   Middle tier has sent some blocks, attributes.  I.e. we've passed
-- check inputs.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   p_blocks                 Yes  BLOCKS   The blocks to deposit
--   p_atttributes            Yes  ATTRS    The attributes to deposit
--   p_messages               Yes  MESSAGES The application messages
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
PROCEDURE perform_checks
        (p_blocks      in         hxc_block_table_type
        ,p_attributes     in         hxc_attribute_table_type
        ,p_timecard_props in         hxc_timecard_prop_table_type
        ,p_days        in         hxc_timecard.block_list
        ,p_details     in         hxc_timecard.block_list
        ,p_messages       in out nocopy hxc_message_table_type
        ) IS

l_tc_index NUMBER;
l_index    NUMBER;
l_idx      NUMBER;

l_inactive_detail_id  hxc_time_building_blocks.time_building_block_id%type;
l_inactive_detail_ovn hxc_time_building_blocks.object_version_number%type;
l_block_idxs       block_list;

l_proc     varchar2(72) := g_package||'perform_checks';

l_validate_on_save    hxc_pref_hierarchies.attribute1%type := hxc_timecard.c_no;


BEGIN

--
-- First find the "active" timecard scope building block
-- index.
--

l_tc_index := hxc_timecard_block_utils.find_active_timecard_index
          (p_blocks => p_blocks);


l_validate_on_save := hxc_timecard_properties.find_property_value
                (p_timecard_props
                ,'TsPerValidateOnSaveValidateOnSave'
                ,null
                ,null
                ,fnd_date.canonical_to_date(p_blocks(l_tc_index).start_time)
                ,fnd_date.canonical_to_date(p_blocks(l_tc_index).stop_time)
                );


--
-- 1. Check that we're allowed to deposit this timecard
--

  if (chk_timecard_deposit
       (p_blocks
       ,l_tc_index
       )
     ) then
     --
     -- There is an existing timecard, stop processing.
     --
     hxc_timecard_message_helper.addErrorToCollection
      (p_messages
      ,'HXC_366333_TIMECARD_EXISTS'
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

--
-- 2. Check that all the details have start_time and stop_time in submission
--
    check_start_stop_time
     (p_blocks       		=> p_blocks
     ,p_details      		=> p_details
     ,p_messages    		=> p_messages
     ,p_validate_on_save 	=> l_validate_on_save
     );

--
-- 3. Check that all the details lie within a valid primary
-- assignment range.
--

  chk_inactive_details(p_blocks,p_timecard_props,p_days,p_details,l_block_idxs);

  if(l_block_idxs.count > 0) then

     l_idx := l_block_idxs.first;
     Loop
       Exit When not l_block_idxs.exists(l_idx);

       hxc_timecard_message_helper.addErrorToCollection
     (p_messages
     ,'HXC_DETAIL_NON_ACTIVE'
     ,hxc_timecard.c_error
     ,null
     ,null
     ,hxc_timecard.c_hxc
     ,p_blocks(p_details(l_idx)).time_building_block_id
     ,p_blocks(p_details(l_idx)).object_version_number
     ,null
     ,null
     );
       l_idx := l_block_idxs.next(l_idx);
     End Loop;

  end if;

END perform_checks;

Function prohibitedAttributeChange
        (p_block      in hxc_block_type,
         p_attributes in hxc_attribute_table_type)
   Return Boolean is

   cursor c_old_attribute(p_id in hxc_time_attributes.time_attribute_id%type) is
     select *
       from hxc_time_attributes
      where time_attribute_id = p_id;

   l_old_attribute c_old_attribute%rowtype;

   l_prohibited boolean;
   l_index pls_integer;

Begin

   l_prohibited := false;
   l_index := p_attributes.first;
   Loop
      Exit when not p_attributes.exists(l_index);


      Exit when (
            (not p_attributes.exists(l_index))
           OR
            (l_prohibited)
           );
      if(p_attributes(l_index).building_block_id = p_block.time_building_block_id) then

      open c_old_attribute(p_attributes(l_index).time_attribute_id);
      fetch c_old_attribute into l_old_attribute;
      close c_old_attribute;

      if(l_old_attribute.time_attribute_id is null) then
         -- A new attribute.  Not allowed.
         l_prohibited := true;
      else
         -- Check for changes.
         if(l_old_attribute.attribute_category <> p_attributes(l_index).attribute_category) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute1,'A') <> nvl(p_attributes(l_index).attribute1,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute2,'A') <> nvl(p_attributes(l_index).attribute2,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute3,'A') <> nvl(p_attributes(l_index).attribute3,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute4,'A') <> nvl(p_attributes(l_index).attribute4,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute5,'A') <> nvl(p_attributes(l_index).attribute5,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute6,'A') <> nvl(p_attributes(l_index).attribute6,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute7,'A') <> nvl(p_attributes(l_index).attribute7,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute8,'A') <> nvl(p_attributes(l_index).attribute8,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute9,'A') <> nvl(p_attributes(l_index).attribute9,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute10,'A') <> nvl(p_attributes(l_index).attribute10,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute11,'A') <> nvl(p_attributes(l_index).attribute11,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute12,'A') <> nvl(p_attributes(l_index).attribute12,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute13,'A') <> nvl(p_attributes(l_index).attribute13,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute14,'A') <> nvl(p_attributes(l_index).attribute14,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute15,'A') <> nvl(p_attributes(l_index).attribute15,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute16,'A') <> nvl(p_attributes(l_index).attribute16,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute17,'A') <> nvl(p_attributes(l_index).attribute17,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute18,'A') <> nvl(p_attributes(l_index).attribute18,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute19,'A') <> nvl(p_attributes(l_index).attribute19,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute20,'A') <> nvl(p_attributes(l_index).attribute20,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute21,'A') <> nvl(p_attributes(l_index).attribute21,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute22,'A') <> nvl(p_attributes(l_index).attribute22,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute23,'A') <> nvl(p_attributes(l_index).attribute23,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute24,'A') <> nvl(p_attributes(l_index).attribute24,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute25,'A') <> nvl(p_attributes(l_index).attribute25,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute26,'A') <> nvl(p_attributes(l_index).attribute26,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute27,'A') <> nvl(p_attributes(l_index).attribute27,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute28,'A') <> nvl(p_attributes(l_index).attribute28,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute29,'A') <> nvl(p_attributes(l_index).attribute29,'A')) then
            l_prohibited := true;
         elsif(nvl(l_old_attribute.attribute30,'A') <> nvl(p_attributes(l_index).attribute30,'A')) then
            l_prohibited := true;
         end if;
      end if;
      end if;
      l_index := p_attributes.next(l_index);
   End Loop;

   return l_prohibited;

End prohibitedAttributeChange;

Function prohibitedBlockChange
           (p_block      in hxc_block_type,
            p_attributes in hxc_attribute_table_type)
   Return Boolean is

   cursor c_old_block
            (p_id in hxc_time_building_blocks.time_building_block_id%type,
             p_ovn in hxc_time_building_blocks.object_version_number%type) is
     select *
       from hxc_time_building_blocks
      where time_building_block_id = p_id
        and object_version_number = p_ovn;

   l_old_block c_old_block%rowtype;
   l_prohibited boolean;

Begin
   if(p_block.process = 'N') then
     l_prohibited := false;
   else
      open c_old_block
             (p_block.time_building_block_id,
              p_block.object_version_number);
      fetch c_old_block into l_old_block;
      close c_old_block;

      if(l_old_block.time_building_block_id is null) then
         -- How did we get here, must be a new block!
         l_prohibited := false;
      else
         -- Check all user updateable attributes, except
         -- approval style id, which Santos do not want
         -- included in this check.
         if(l_old_block.TYPE <> p_block.TYPE) then
            l_prohibited := true;
         else
            if(round(l_old_block.MEASURE,3) <> round(p_block.MEASURE,3)) then
               l_prohibited := true;
            else
               if(l_old_block.UNIT_OF_MEASURE <> p_block.UNIT_OF_MEASURE) then
                  l_prohibited := true;
               else
                  if(l_old_block.START_TIME <> fnd_date.canonical_to_date(p_block.START_TIME)) then
                     l_prohibited := true;
                  else
                     if(l_old_block.STOP_TIME <> fnd_date.canonical_to_date(p_block.STOP_TIME)) then
                        l_prohibited := true;
                     else
                        if(l_old_block.APPROVAL_STATUS <> p_block.APPROVAL_STATUS) then
                           l_prohibited := true;
                        else
                           if(l_old_block.DATE_TO <> fnd_date.canonical_to_date(p_block.DATE_TO)) then
                              l_prohibited := true;
                           else
                              if(nvl(l_old_block.COMMENT_TEXT,'COMMENT') <> nvl(p_block.COMMENT_TEXT,'COMMENT')) then
                                 l_prohibited := true;
                                 --
                                 -- Ok, all the block attributes are the same
                                 -- Are the attributes the same?
                               else
                                 if(prohibitedAttributeChange(p_block,p_attributes)) then
                                   l_prohibited := true;
                                 else
                                   l_prohibited := false;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end if;

   return l_prohibited;

End prohibitedBlockChange;

Function never_locked
       (p_timecard_props in hxc_timecard_prop_table_type
       ,p_early_date     in date
       ,p_late_date      in date
       ) return boolean is

l_index     number;
l_found     boolean := false;
l_day_found    boolean := false;
l_detail_found boolean := false;
l_day       boolean := false;
l_detail       boolean := false;
l_result       boolean := false;
l_proc      varchar2(30) := 'never_locked';
Begin


l_index := p_timecard_props.first;
Loop
  Exit when ((not p_timecard_props.exists(l_index)) or (l_found));

  if(p_timecard_props(l_index).property_name = 'TcWTcrdStAlwEditsModifyApprovedTcDetails') then
    if(p_timecard_props(l_index).date_from < p_early_date) then
      if(p_timecard_props(l_index).date_to > p_late_date) then
     l_detail_found := true;
     if((p_timecard_props(l_index).property_value <> 'N') OR (p_timecard_props(l_index).property_value is null))then
       l_detail := true;
     end if;
      end if;
    end if;
  end if;

  if(p_timecard_props(l_index).property_name = 'TcWTcrdStAlwEditsModifyApprovedTcDays') then
    if(p_timecard_props(l_index).date_from < p_early_date) then
      if(p_timecard_props(l_index).date_to > p_late_date) then
     l_day_found := true;
     if((p_timecard_props(l_index).property_value <> 'N') OR (p_timecard_props(l_index).property_value is null))then
       l_day := true;
     end if;
      end if;
    end if;
  end if;

  if(l_day_found) AND (l_detail_found) then
    l_found := true;
    if(l_day) and (l_detail) then
      l_result := true;
    end if;
  end if;

  l_index := p_timecard_props.next(l_index);
End Loop;

--
-- 115.6 Change: Bug 2888528
--

if(not l_found) then

  if((l_day_found) AND (NOT l_day)) then
    l_result := false;
  elsif((l_detail_found) AND (NOT l_detail)) then
    l_result := false;
  else
    l_result := true;
  end if;

end if;

return l_result;

End never_locked;

Function find_locking_preference
       (p_timecard_props in hxc_timecard_prop_table_type
       ,p_date        in date
       ,p_preference     in varchar2
       ) return varchar2 is

l_preference varchar2(2) := 'Y';
l_index      number;
l_found      boolean := false;
Begin

l_index := p_timecard_props.first;
Loop
  Exit when ((not p_timecard_props.exists(l_index)) or (l_found));
  if(p_preference = 'DAY') then
    if(p_timecard_props(l_index).property_name = 'TcWTcrdStAlwEditsModifyApprovedTcDays') then
      if(p_date between p_timecard_props(l_index).date_from and p_timecard_props(l_index).date_to) then
     l_preference := p_timecard_props(l_index).property_value;
     l_found := true;
      end if;
    end if;
  else
    if(p_timecard_props(l_index).property_name = 'TcWTcrdStAlwEditsModifyApprovedTcDetails') then
      if(p_date between p_timecard_props(l_index).date_from and p_timecard_props(l_index).date_to) then
     l_preference := p_timecard_props(l_index).property_value;
     l_found := true;
      end if;
    end if;
  end if;
  l_index := p_timecard_props.next(l_index);
End Loop;

return l_preference;

End find_locking_preference;

Function day_approved
       (p_resource_id    in hxc_time_building_blocks.resource_id%type
       ,p_date        in date
       ) return boolean is

cursor c_approved_day
     (p_resource_id    in hxc_time_building_blocks.resource_id%type
     ,p_date        in date) is
  select ap.approval_status
    from hxc_time_building_blocks ap, hxc_time_building_blocks tc
   where ap.resource_id = p_resource_id
     and ap.scope = 'APPLICATION_PERIOD'
     and ap.approval_status = 'APPROVED'
     and p_date between ap.start_time and ap.stop_time
     and ap.resource_id = tc.resource_id
     and ap.creation_date >= tc.creation_date
     and tc.date_to = hr_general.end_of_time
     and tc.scope = 'TIMECARD'
     and tc.start_time <= ap.stop_time
     and tc.stop_time >= ap.start_time
     and NOT exists
     (select 'Y'
       from hxc_time_building_blocks
   where resource_id = p_resource_id
     and scope = 'APPLICATION_PERIOD'
     and date_to = hr_general.end_of_time
     and approval_status = 'REJECTED'
     and p_date between start_time and stop_time
     );

l_dummy hxc_time_building_blocks.approval_status%type;

Begin

open c_approved_day(p_resource_id,p_date);
fetch c_approved_day into l_dummy;
if(c_approved_day%found) then
  close c_approved_day;
  return true;
else
  close c_approved_day;
  return false;
end if;

End day_approved;
--
-- Added detail_with_day in version 115.115.  This is for the
-- santos locking of approved days functionality.
--
FUNCTION detail_with_day
  (p_date IN DATE,
   p_resource_id IN hxc_time_building_blocks.resource_id%TYPE
   ) RETURN BOOLEAN IS

CURSOR c_detail_exists
  (p_date IN DATE,
   p_resource_id IN hxc_time_building_blocks.resource_id%TYPE
   ) IS
       SELECT 'Y'
	FROM hxc_time_building_blocks detail,
	     hxc_time_building_blocks day,
	     hxc_time_building_blocks parent
	WHERE detail.parent_building_block_id = day.time_building_block_id
	AND detail.parent_building_block_ovn = day.object_version_number
	AND detail.date_to = hr_general.end_of_time
	AND detail.resource_id = p_resource_id
	AND detail.scope = 'DETAIL'
	AND detail.creation_date <=(select max(ap.creation_date)
	    from hxc_time_building_blocks ap
	    where ap.resource_id = p_resource_id
	     and ap.scope = 'APPLICATION_PERIOD'
	     and ap.approval_status = 'APPROVED'
	     and p_date between ap.start_time and ap.stop_time
	     and ap.resource_id = parent.resource_id
	     and ap.creation_date >= parent.creation_date
	     and parent.date_to = hr_general.end_of_time
	     and parent.start_time <= ap.stop_time
	     and parent.stop_time >= ap.start_time)
	AND day.scope = 'DAY'
	AND Trunc(day.start_time) = Trunc(p_date)
	AND day.date_to = hr_general.end_of_time
	AND day.resource_id = p_resource_id
     and parent.time_building_block_id=day.parent_building_block_id
	and parent.object_version_number=day.parent_building_block_ovn
	and parent.scope='TIMECARD'
	AND parent.date_to = hr_general.end_of_time
	AND parent.resource_id = p_resource_id;

l_dummy varchar2(1);

BEGIN
   OPEN c_detail_exists(p_date,p_resource_id);
   FETCH c_detail_exists INTO l_dummy;
   IF(c_detail_exists%found) THEN
      CLOSE c_detail_exists;
      RETURN TRUE;
    ELSE
      CLOSE c_detail_exists;
      RETURN FALSE;
   END IF;
END detail_with_day;

Function day_locked
       (p_timecard_props in hxc_timecard_prop_table_type
       ,p_resource_id    in hxc_time_building_blocks.resource_id%type
       ,p_date        in date
       ) return boolean is

l_locked boolean := false;
l_pref   varchar2(2);

Begin

l_pref := find_locking_preference
        (p_timecard_props
        ,p_date
        ,'DAY'
        );
if(l_pref = 'N') then
  if(day_approved(p_resource_id,p_date)) then
     IF(detail_with_day(p_date,p_resource_id)) then
	l_locked := true;
      ELSE
	l_locked := FALSE;
     END IF;
  else
    l_locked := false;
  end if;
else
  l_locked := false;
end if;

return l_locked;

End day_locked;

   Function detail_locked
      (p_timecard_props in hxc_timecard_prop_table_type,
       p_resource_id    in hxc_time_building_blocks.resource_id%type,
       p_date           in date,
       p_detail_id      in hxc_ap_detail_links.time_building_block_id%type,
       p_detail_ovn     in hxc_ap_detail_links.time_building_block_ovn%type
       ) return boolean is

      cursor c_detail_approved
         (p_detail_id in hxc_ap_detail_links.time_building_block_id%type,
          p_detail_ovn in hxc_ap_detail_links.time_building_block_ovn%type) is
        select 'Y'
          from hxc_ap_detail_links adl,
               hxc_app_period_summary aps
         where adl.time_building_block_id = p_detail_id
           and adl.time_building_block_ovn = p_detail_ovn
           and adl.application_period_id = aps.application_period_id
       and aps.approval_status = hxc_timecard.c_approved_status
           and not exists(select 1
                            from hxc_ap_detail_links adl2,
                                 hxc_app_period_summary aps2
                           where adl2.time_building_block_id = adl.time_building_block_id
                             and adl2.time_building_block_ovn = adl.time_building_block_ovn
                             and adl2.application_period_id <> adl.application_period_id
                             and adl2.application_period_id = aps2.application_period_id
                             and aps2.approval_status <> hxc_timecard.c_approved_status);

      l_locked boolean := false;
      l_pref   varchar2(2);
      l_dummy  varchar2(1);

   Begin

      l_pref := find_locking_preference
         (p_timecard_props,
          p_date,
          'DETAIL'
          );

      if(l_pref = 'N') then
         open c_detail_approved(p_detail_id,p_detail_ovn);
         fetch c_detail_approved into l_dummy;
         if(c_detail_approved%notfound) then
            l_locked := false;
         else
            l_locked := true;
         end if;
         close c_detail_approved;
      else
         l_locked := false;
      end if;

      return l_locked;

   End detail_locked;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_approved_locked_days >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs all the basic checks on the timecard information
-- pre-deposit, but once the processing state of the blocks in known.  At the
-- the moment, this is simply the implementation of the Santos-built approval
-- locking of days.
--
-- Prerequisites:
--   Middle tier has sent some blocks, attributes.  I.e. we've passed
-- check inputs.
--
-- In Parameters:
--   Name                  Reqd Type      Description
--   p_blocks                 Yes  BLOCKS    The blocks to deposit
--   p_timecard_props            Yes  PROPS     The preferences
--   p_days                Yes  BlockList The Day building blocks
--   p_details                Yes  Blocklist The detail building blocks
--   p_messages               Yes  MESSAGES  The application messages
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
PROCEDURE chk_approved_locked_days
        (p_blocks      in         hxc_block_table_type,
         p_attributes     in         hxc_attribute_table_type
        ,p_timecard_props in         hxc_timecard_prop_table_type
        ,p_days        in         hxc_timecard.block_list
        ,p_details     in         hxc_timecard.block_list
        ,p_messages       in out nocopy hxc_message_table_type
        ) IS

l_modify_days    varchar2(2) := 'N';
l_modify_details varchar2(2) := 'N';
l_detail_date    date;
l_detail_index   number;
l_early_detail   date := hr_general.end_of_time;
l_late_detail    date := hr_general.start_of_time;
l_proc        varchar2(72) := g_package||'chk_approved_locked_days';
Begin

find_detail_date_extremes
 (p_blocks       => p_blocks
 ,p_days      => p_days
 ,p_details      => p_details
 ,p_early_detail => l_early_detail
 ,p_late_detail  => l_late_detail
 );

if(never_locked(p_timecard_props, l_early_detail, l_late_detail)) then
  --
  -- No need to check, since the preferences are not set.
  --
  null;
else
  --
  -- Check each detail to see if allowed to change.
  --
  l_detail_index := p_details.first;
  Loop
    Exit when not p_details.exists(l_detail_index);

    if(((prohibitedBlockChange
           (p_blocks(p_details(l_detail_index)),
            p_attributes
            )
         )
        OR
         (hxc_timecard_block_utils.is_new_block(p_blocks(p_details(l_detail_index)))))
      --AND
       --(hxc_timecard_block_utils.is_active_block(p_blocks(p_details(l_detail_index))))
      )then

      l_detail_date := trunc(hxc_timecard_block_utils.date_value
                               (p_blocks(p_days(p_blocks(p_details(l_detail_index)).parent_building_block_id)).start_time
                             ));
      if(day_locked(p_timecard_props, p_blocks(p_details(l_detail_index)).resource_id,l_detail_date)) then
        hxc_timecard_message_helper.addErrorToCollection
          (p_messages
           ,'HXC_NO_MODIFY_APPROVED_DETAIL'
           ,hxc_timecard.c_error
           ,null
           ,null
           ,hxc_timecard.c_hxc
           ,p_blocks(p_details(l_detail_index)).time_building_block_id
           ,null
           ,null
           ,null
           );
      else
        if(hxc_timecard_block_utils.is_new_block(p_blocks(p_details(l_detail_index)))) then
          --
          -- It is ok, this entry is allowed, the day is not locked, and it is a new
          -- building block
          --
          null;
        else
          if(detail_locked
               (p_timecard_props,
                p_blocks(p_details(l_detail_index)).resource_id,
                l_detail_date,
                p_blocks(p_details(l_detail_index)).time_building_block_id,
                p_blocks(p_details(l_detail_index)).object_version_number
                )) then
            hxc_timecard_message_helper.addErrorToCollection
              (p_messages
               ,'HXC_NO_MODIFY_APPROVED_DETAIL'
               ,hxc_timecard.c_error
               ,null
               ,null
               ,hxc_timecard.c_hxc
               ,p_blocks(p_details(l_detail_index)).time_building_block_id
               ,null
               ,null
               ,null
               );
          end if;
        end if;
      end if;
    end if; -- is the block new or changed?
    l_detail_index := p_details.next(l_detail_index);
  End Loop;
end if;

End chk_approved_locked_days;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< perform_process_checks >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--       This procedure checks that if the deposit mode is submit, then we're
-- going to process at least one or more block or attribute.  If not, then the
-- approval workflow will not be started, and we should not show the
-- confirmation page to the user.
--
-- Prerequisites:
--   Middle tier has sent some blocks, attributes.  I.e. we've passed
-- check inputs.
--
-- In Parameters:
--   Name                  Reqd Type      Description
--   p_blocks                 Yes  BLOCKS    The blocks to deposit
--   p_atttributes            Yes  ATTRS     The attributes to deposit
--   p_messages               Yes  MESSAGES  The application messages
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
PROCEDURE chk_some_processing
        (p_blocks      in         hxc_block_table_type
        ,p_attributes     in         hxc_attribute_table_type
        ,p_messages       in out nocopy hxc_message_table_type
        ) is

l_index number;
l_found boolean := false;

l_proc varchar2(70) := g_package||'chk_some_processing';

Begin

l_index := p_blocks.first;
LOOP
  Exit When ((Not p_blocks.exists(l_index)) or (l_found));
  if(hxc_timecard_block_utils.process_block(p_blocks(l_index))) then
    l_found := true;
  end if;
  l_index := p_blocks.next(l_index);
END LOOP;

if (not l_found) then
  l_index := p_attributes.first;
  LOOP
    Exit When ((Not p_attributes.exists(l_index)) or (l_found));
    if(hxc_timecard_attribute_utils.process_attribute(p_attributes(l_index))) then
      l_found := true;
    end if;
    l_index := p_attributes.next(l_index);
  END LOOP;
end if;

if (not l_found) then
  hxc_timecard_message_helper.addErrorToCollection
    (p_messages
    ,'HXC_TIMECARD_NOT_SUBMITTED'
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

End chk_some_processing;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< perform_process_checks >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs all the basic checks on the timecard information
-- pre-deposit, but once the processing state of the blocks in known.  At the
-- the moment, this is simply the implementation of the Santos-built approval
-- locking of days.
--
-- Prerequisites:
--   Middle tier has sent some blocks, attributes.  I.e. we've passed
-- check inputs.
--
-- In Parameters:
--   Name                  Reqd Type      Description
--   p_blocks                 Yes  BLOCKS    The blocks to deposit
--   p_atttributes            Yes  ATTRS     The attributes to deposit
--   p_timecard_props            Yes  PROPS     The preferences
--   p_days                Yes  BlockList The Day building blocks
--   p_details                Yes  Blocklist The detail building blocks
--   p_template               Yes  VARCHAR2  Is this a template?
--   p_deposit_mode           Yes  VARCHAR2  The current deposit mode
--   p_messages               Yes  MESSAGES  The application messages
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
PROCEDURE perform_process_checks
        (p_blocks      in         hxc_block_table_type
        ,p_attributes     in         hxc_attribute_table_type
        ,p_timecard_props in         hxc_timecard_prop_table_type
        ,p_days        in         hxc_timecard.block_list
        ,p_details     in         hxc_timecard.block_list
        ,p_template       in         varchar2
        ,p_deposit_mode   in         varchar2
        ,p_messages       in out nocopy hxc_message_table_type
        ) IS

l_modify_days    varchar2(2) := 'N';
l_modify_details varchar2(2) := 'N';
l_detail_date    date;
l_detail_index   number;

Begin

if(p_template <> 'Y') then

  chk_approved_locked_days
   (p_blocks      => p_blocks
   ,p_attributes     => p_attributes
   ,p_timecard_props => p_timecard_props
   ,p_days        => p_days
   ,p_details     => p_details
   ,p_messages       => p_messages
   );

  if(p_deposit_mode = 'SUBMIT') then
   chk_some_processing
    (p_blocks     => p_blocks
    ,p_attributes    => p_attributes
    ,p_messages      => p_messages
    );
  end if;
end if;

End perform_process_checks;

END hxc_deposit_checks;

/
