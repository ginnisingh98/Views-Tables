--------------------------------------------------------
--  DDL for Package Body HXC_BLOCK_ATTRIBUTE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_BLOCK_ATTRIBUTE_UPDATE" AS
/* $Header: hxcbkatup.pkb 120.2.12000000.1 2007/01/18 17:29:08 appldev noship $ */

type block_list is table of number index by binary_integer;
--
-- Use this procedure to convert the ids prior to a successful
-- save as a template
-- (otherwise the timecard will be overwritten with the template)
--
PROCEDURE replace_ids
            (p_blocks     in out nocopy hxc_block_table_type
            ,p_attributes in out nocopy hxc_attribute_table_type
	    ,p_duplicate_template in BOOLEAN
            ) is

cursor c_template_is_a_timecard
        (p_id in hxc_time_building_blocks.time_building_block_id%type
        ,p_ovn in hxc_time_building_blocks.object_version_number%type) is
  select scope
    from hxc_time_building_blocks
   where time_building_block_id = p_id
     and object_version_number = p_ovn;

l_block_start number := -1000000;
l_attribute_start number := -1000000;
l_block_index number;
l_attribute_index number;
l_template_index number;
l_block_replacement_ids block_list;
l_replace boolean := false;
l_dummy_scope hxc_time_building_blocks.scope%type;

Begin

--
-- First check to see if we need to replace
-- the ids
--
IF(p_duplicate_template = TRUE) THEN
	l_replace := true;
ELSE
l_template_index := hxc_timecard_block_utils.find_active_timecard_index
                      (p_blocks);


open c_template_is_a_timecard
      (p_blocks(l_template_index).time_building_block_id
      ,p_blocks(l_template_index).object_version_number
      );

fetch c_template_is_a_timecard into l_dummy_scope;
if(c_template_is_a_timecard%NOTFOUND) then
  l_replace := true;
else
  if(l_dummy_scope = hxc_timecard.c_timecard_scope) then
    l_replace := true;
  else
    l_replace := false;
  end if;
end if;
close c_template_is_a_timecard;
END IF;
if(l_replace) then
--
-- replace the block ids
--

l_block_index := p_blocks.first;
Loop
  Exit When Not p_blocks.exists(l_block_index);
  l_block_replacement_ids(p_blocks(l_block_index).time_building_block_id) := l_block_start;
  p_blocks(l_block_index).time_building_block_id := l_block_start;
  p_blocks(l_block_index).object_version_number := 1;
  p_blocks(l_block_index).changed := hxc_timecard.c_yes;
  p_blocks(l_block_index).new := hxc_timecard.c_yes;
  p_blocks(l_block_index).process := hxc_timecard.c_yes;
  p_blocks(l_block_index).parent_is_new := hxc_timecard.c_yes;

  l_block_start := l_block_start -1;
  l_block_index := p_blocks.next(l_block_index);
End Loop;
--
-- Update the parent child relationships
-- to take account of the new ids
--
l_block_index := p_blocks.first;
Loop
  Exit When Not p_blocks.exists(l_block_index);
  if((p_blocks(l_block_index).parent_building_block_id is not null) AND (p_blocks(l_block_index).parent_building_block_id <> -1)) then
    p_blocks(l_block_index).parent_building_block_id :=
      l_block_replacement_ids(p_blocks(l_block_index).parent_building_block_id);
    p_blocks(l_block_index).parent_building_block_ovn := 1;
  end if;
  l_block_index := p_blocks.next(l_block_index);
End Loop;
--
-- Update the attributes
--
l_attribute_index := p_attributes.first;
Loop
  Exit when not p_attributes.exists(l_attribute_index);
  p_attributes(l_attribute_index).time_attribute_id := l_attribute_start;
  p_attributes(l_attribute_index).object_version_number := 1;
  p_attributes(l_attribute_index).building_block_ovn :=1;
  p_attributes(l_attribute_index).building_block_id :=
    l_block_replacement_ids(p_attributes(l_attribute_index).building_block_id);
  p_attributes(l_attribute_index).changed := hxc_timecard.c_yes;
  p_attributes(l_attribute_index).new := hxc_timecard.c_yes;
  p_attributes(l_attribute_index).process := hxc_timecard.c_yes;
  l_attribute_start := l_attribute_start -1;
  l_attribute_index := p_attributes.next(l_attribute_index);
End Loop;

end if; -- do we actually need to replace these ids

End replace_ids;


PROCEDURE denormalize_time
           (p_blocks in out nocopy hxc_block_table_type
           ,p_mode   in            varchar2) IS

l_block_index number;

BEGIN
--
-- No need to check inputs, since if invalid mode we just will not do anything.
--
-- note that we denormalise measure for ALL range start_time stop_times (regardless of scope)
-- note also that the UOM for these blocks is HOURS
-- This is done for ALL scopes of building blocks since we dont need to
-- start adding scope specific code.

l_block_index := p_blocks.first;

WHILE ( l_block_index is NOT NULL ) LOOP

  IF (p_mode = 'ADD') THEN

    IF(p_blocks(l_block_index).type = 'RANGE' ) THEN
      p_blocks(l_block_index).measure:=
        (hxc_timecard_block_utils.date_value(p_blocks(l_block_index).stop_time)
        -hxc_timecard_block_utils.date_value(p_blocks(l_block_index).start_time)
        )*24;
      p_blocks(l_block_index).unit_of_measure:= 'HOURS';
    END IF;

  ELSIF (p_mode = 'REMOVE') THEN

    IF(p_blocks(l_block_index).type = 'RANGE' ) THEN
      p_blocks(l_block_index).measure:= null;
--      p_blocks(l_block_index).unit_of_measure:= null;
    END IF;

  END IF;

  l_block_index := p_blocks.next(l_block_index);

END LOOP;

END denormalize_time;

Procedure set_block_process_flags
            (p_blocks in out nocopy hxc_block_table_type
            ) is


l_index     NUMBER;
l_block     HXC_BLOCK_TYPE;
l_old_block HXC_BLOCK_TYPE;
l_proc      varchar2(72):= 'blockattrup.setprocessflags';
Begin

l_index := p_blocks.first;

LOOP
  EXIT WHEN NOT p_blocks.exists(l_index);

  l_block := p_blocks(l_index);

  if(hxc_timecard_block_utils.is_new_block(l_block)) then

     if(hxc_timecard_block_utils.is_active_block(l_block)) then
       p_blocks(l_index).process := 'Y';
     else
       p_blocks(l_index).process := 'N';
     end if;

  else
    begin
      l_old_block := hxc_timecard_block_utils.build_block
                    (p_time_building_block_id  => l_block.time_building_block_id
                    ,p_time_building_block_ovn => l_block.object_version_number
                    );

      if(hxc_timecard_block_utils.blocks_are_different
          (p_block1 => l_block
          ,p_block2 => l_old_block
          )
        ) then

         p_blocks(l_index).process := 'Y';

      else
         p_blocks(l_index).process := 'N';
         p_blocks(l_index).changed := 'N';
      end if;
    exception
      when others then
       p_blocks(l_index).process := 'N';

    end;

    if(hxc_timecard_block_utils.parent_has_changed(p_blocks,p_blocks(l_index).parent_building_block_id)) then
       p_blocks(l_index).process := 'Y';
   end if;

  end if;

  l_index := p_blocks.next(l_index);

END LOOP;

End set_block_process_flags;

Procedure set_attribute_process_flags
           (p_attributes in out nocopy hxc_attribute_table_type
           ) is

l_index              NUMBER;
l_attribute          HXC_ATTRIBUTE_TYPE;
l_old_attribute      HXC_ATTRIBUTE_TYPE;

l_test boolean;

Begin

l_index := p_attributes.first;

LOOP
  EXIT WHEN NOT p_attributes.exists(l_index);

  l_attribute := p_attributes(l_index);

  if(l_attribute.new='Y') then

    p_attributes(l_index).process := 'Y';

  else
    if(NOT hxc_timecard_attribute_utils.is_system_context(l_attribute)) then
      begin
        l_old_attribute := hxc_timecard_attribute_utils.build_attribute
                            (p_time_attribute_id      => l_attribute.time_attribute_id
                            ,p_object_version_number  => l_attribute.object_version_number
                            ,p_time_building_block_id => l_attribute.building_block_id
                            ,p_time_building_block_ovn => l_attribute.building_block_ovn
                            );

        if(hxc_timecard_attribute_utils.attributes_are_different
            (p_attribute1 => l_attribute
            ,p_attribute2 => l_old_attribute
            )
          ) then
          p_attributes(l_index).process := 'Y';
     	else
	  p_attributes(l_index).process := 'N';		--3025733
        end if;

	if p_attributes(l_index).process='N' then	--3025733
	   p_attributes(l_index).changed:='N';
	end if;

      exception
        when others then
          null;
      end;
    end if; -- is this a system context, and therefore we don't care about differences.

  end if;

  l_index := p_attributes.next(l_index);

END LOOP;

End set_attribute_process_flags;
--
-- Procedure added for version 115.1
--
Procedure set_corresponding_attributes
            (p_attributes      in out nocopy hxc_attribute_table_type
            ,p_attribute_index in            number
            ,p_process_value   in            varchar2
            ) is

l_attribute_index number;
l_block_id        number;

Begin

l_block_id := p_attributes(p_attribute_index).building_block_id;

l_attribute_index := p_attributes.first;

Loop
  Exit when ((l_attribute_index=p_attribute_index) or (not p_attributes.exists(l_attribute_index)));
  if(p_attributes(l_attribute_index).building_block_id = l_block_id) then
    p_attributes(l_attribute_index).process := p_process_value;
  end if;
  l_attribute_index := p_attributes.next(l_attribute_index);
End Loop;

End set_corresponding_attributes;

Procedure set_dependent_process_flags
            (p_blocks     in out nocopy hxc_block_table_type
            ,p_attributes in out nocopy hxc_attribute_table_type
            ) is

l_block_index     NUMBER;
l_attribute_index NUMBER;
l_attribute       hxc_attribute_type;
l_process_blocks  block_list;

Begin
--
-- For performance, remove the nested loops.
-- Use an indexed PL/SQL table for better
-- performnace.
--
-- 1. Build the index of blocks to process
-- based on the block process flags
--
l_block_index := p_blocks.first;
Loop
  Exit when not p_blocks.exists(l_block_index);

   if(p_blocks(l_block_index).process = hxc_timecard.c_yes) then
     l_process_blocks(p_blocks(l_block_index).time_building_block_id) := l_block_index;
   end if;

  l_block_index := p_blocks.next(l_block_index);
End Loop;
--
-- 2.  Loop over all the attributes and set the corresponding
-- process flag for them if the process flag of the block is
-- set.  We do this twice to make sure that we get *all* the
-- attributes set correctly.  The reason for this is that the
-- attribute set is not ordered by process flag.  So attribute n
-- might be set to be processed, but attribute n-1 and n-5 say,
-- which correspond to the same block are not set to be processed
-- if we didn't do this twice, the n-1 and n-5 attributes would
-- not get processed properly along with there block and the
-- n attribute.
--
for i in 1..2 Loop
  l_attribute_index := p_attributes.first;
  Loop
    Exit when not p_attributes.exists(l_attribute_index);

      if(p_attributes(l_attribute_index).process = hxc_timecard.c_yes) then
        l_process_blocks(p_attributes(l_attribute_index).building_block_id):= l_attribute_index;
--        p_attributes(l_attribute_index).changed := hxc_timecard.c_yes; -- SHIV
      else
        if(l_process_blocks.exists(p_attributes(l_attribute_index).building_block_id))then
--          p_attributes(l_attribute_index).changed := hxc_timecard.c_yes; --Doubt
          p_attributes(l_attribute_index).process := hxc_timecard.c_yes; --Doubt
        else
--          p_attributes(l_attribute_index).changed := hxc_timecard.c_no;
          p_attributes(l_attribute_index).process := hxc_timecard.c_no;
        end if;
      end if;
    l_attribute_index := p_attributes.next(l_attribute_index);
  End Loop;
end loop;
--
-- 3. Now finally, we loop over the blocks again, and set the process
-- and changed flags appropriately in case any of the attributes
-- had been changed, but the blocks had not.
--
l_block_index := p_blocks.first;
Loop
  Exit when not p_blocks.exists(l_block_index);
   if(l_process_blocks.exists(p_blocks(l_block_index).time_building_block_id)) then
     p_blocks(l_block_index).process := hxc_timecard.c_yes;
   else
     p_blocks(l_block_index).process := hxc_timecard.c_no;
   end if;

  -- This is for PA validation
--SHIV
--  if(hxc_timecard_block_utils.parent_has_changed(p_blocks,p_blocks(l_block_index).parent_building_block_id)) then
--    p_blocks(l_block_index).changed := hxc_timecard.c_yes;
--  end if;

  l_block_index := p_blocks.next(l_block_index);
End Loop;

End set_dependent_process_flags;

Procedure set_process_flags
           (p_blocks     in out nocopy hxc_block_table_type
           ,p_attributes in out nocopy hxc_attribute_table_type
           ) is
Begin

set_block_process_flags(p_blocks);
set_attribute_process_flags(p_attributes);
set_dependent_process_flags
  (p_blocks
  ,p_attributes
  );

End set_process_flags;

END hxc_block_attribute_update;

/
