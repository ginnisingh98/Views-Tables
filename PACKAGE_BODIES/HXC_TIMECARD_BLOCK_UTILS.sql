--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_BLOCK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_BLOCK_UTILS" AS
/* $Header: hxctcbkut.pkb 120.5 2006/03/29 12:54:44 jdupont noship $ */

g_package        varchar2(25) := 'hxc_timecard_block_utils.';
g_timecard_index number;

e_no_existing_block exception;

Function any_new_blocks
          (p_blocks in hxc_block_table_type)
          return varchar2 is

l_new   varchar2(3) := 'NO';
l_index number;
l_found boolean := false;

Begin

l_index := p_blocks.first;
Loop
  Exit when ((not p_blocks.exists(l_index)) OR (l_found));

  if(
     (p_blocks(l_index).new = 'Y')
    AND
     (is_active_block(p_blocks(l_index)))
    AND
     (p_blocks(l_index).time_building_block_id > 0)
    ) then

    l_new := 'YES';
    l_found := true;

  end if;

  l_index := p_blocks.next(l_index);
End Loop;

return l_new;

End;

Procedure initialize_timecard_index is

Begin

g_timecard_index := null;

End initialize_timecard_index;

FUNCTION find_active_timecard_index
          (p_blocks in hxc_block_table_type)
         RETURN number is

l_tc_index NUMBER := null;
l_index NUMBER;

l_proc varchar2(55) := g_package||'find_active_timecard_index';

BEGIN

if(g_timecard_index is not null) then
   if(p_blocks.exists(g_timecard_index)) then
      if(p_blocks(g_timecard_index).scope in (hxc_timecard.c_timecard_scope, hxc_timecard.c_template_scope))then
	 l_tc_index := g_timecard_index;
      else
	 g_timecard_index := null;
      end if;
   else
      g_timecard_index := null;
   end if;
end if;

if(g_timecard_index is null) then

  l_index := p_blocks.first;

  LOOP
    EXIT WHEN ((NOT p_blocks.exists(l_index)) OR (l_tc_index is NOT NULL));

    if(
       (p_blocks(l_index).scope in (hxc_timecard.c_timecard_scope, hxc_timecard.c_template_scope))
       AND
        (date_value(p_blocks(l_index).date_to) = hr_general.end_of_time)
       ) then

      l_tc_index := l_index;

    end if;

    l_index := p_blocks.next(l_index);

  END LOOP;

  g_timecard_index := l_tc_index;

end if; -- can we use the cached value?

if(l_tc_index is null) then
--
-- Most likely we are deleting the timecard.
-- just find the index corresponding to the
-- timecard scope or timecard template scope
-- block

  l_index := p_blocks.first;

  LOOP
    EXIT WHEN ((NOT p_blocks.exists(l_index)) OR (l_tc_index is NOT NULL));

    if(p_blocks(l_index).scope in (hxc_timecard.c_timecard_scope, hxc_timecard.c_template_scope))then

      l_tc_index := l_index;

    end if;

    l_index := p_blocks.next(l_index);

  END LOOP;

  g_timecard_index := l_tc_index;

end if;

return l_tc_index;

END find_active_timecard_index;

FUNCTION convert_to_dpwr_blocks
           (p_blocks in hxc_block_table_type
           ) return hxc_self_service_time_deposit.timecard_info is

l_blocks hxc_self_service_time_deposit.timecard_info;
l_index  NUMBER;

BEGIN

l_index := p_blocks.first;

LOOP

 EXIT WHEN NOT p_blocks.exists(l_index);

 l_blocks(l_index).TIME_BUILDING_BLOCK_ID := p_blocks(l_index).TIME_BUILDING_BLOCK_ID;
 l_blocks(l_index).TYPE := p_blocks(l_index).TYPE;
 l_blocks(l_index).MEASURE := p_blocks(l_index).MEASURE;
 l_blocks(l_index).UNIT_OF_MEASURE := p_blocks(l_index).UNIT_OF_MEASURE;
 l_blocks(l_index).START_TIME := date_value(p_blocks(l_index).START_TIME);
 l_blocks(l_index).STOP_TIME := date_value(p_blocks(l_index).STOP_TIME);
 l_blocks(l_index).PARENT_BUILDING_BLOCK_ID := p_blocks(l_index).PARENT_BUILDING_BLOCK_ID;
 l_blocks(l_index).PARENT_IS_NEW := p_blocks(l_index).PARENT_IS_NEW;
 l_blocks(l_index).SCOPE := p_blocks(l_index).SCOPE;
 l_blocks(l_index).OBJECT_VERSION_NUMBER := p_blocks(l_index).OBJECT_VERSION_NUMBER;
 l_blocks(l_index).APPROVAL_STATUS := p_blocks(l_index).APPROVAL_STATUS;
 l_blocks(l_index).RESOURCE_ID := p_blocks(l_index).RESOURCE_ID;
 l_blocks(l_index).RESOURCE_TYPE := p_blocks(l_index).RESOURCE_TYPE;
 l_blocks(l_index).APPROVAL_STYLE_ID := p_blocks(l_index).APPROVAL_STYLE_ID;
 l_blocks(l_index).DATE_FROM := date_value(p_blocks(l_index).DATE_FROM);
 l_blocks(l_index).DATE_TO := date_value(p_blocks(l_index).DATE_TO);
 l_blocks(l_index).COMMENT_TEXT := p_blocks(l_index).COMMENT_TEXT;
 l_blocks(l_index).PARENT_BUILDING_BLOCK_OVN := p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN;
 l_blocks(l_index).NEW := p_blocks(l_index).NEW;
 l_blocks(l_index).CHANGED := p_blocks(l_index).CHANGED;
 l_blocks(l_index).PROCESS := p_blocks(l_index).PROCESS;

 l_index := p_blocks.next(l_index);

END LOOP;

return l_blocks;

END convert_to_dpwr_blocks;

Function is_new_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN is

Begin

if(p_block.new = 'Y') then
  return true;
else
  return false;
end if;

End is_new_block;

Function is_active_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN is

Begin

if(fnd_date.canonical_to_date(p_block.date_to) = hr_general.end_of_time) then
  return true;
else
  return false;
end if;

End is_active_block;

Function is_timecard_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN is
Begin

if(
   (p_block.scope = hxc_timecard.c_timecard_scope)
  OR
   (p_block.scope = hxc_timecard.c_template_scope)
  )then
  return true;
else
  return false;
end if;

End is_timecard_block;

Function is_day_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN is
Begin

if(p_block.scope = hxc_timecard.c_day_scope) then
  return true;
else
  return false;
end if;

End is_day_block;

Function is_existing_block
           (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN is

cursor c_existing
         (p_block_id in hxc_time_building_blocks.time_building_block_id%type
         ,p_block_ovn in hxc_time_building_blocks.object_version_number%type
         ) is
  select 'Y'
    from hxc_time_building_blocks tbb
   where tbb.time_building_block_id = p_block_id
     and tbb.object_version_number = p_block_ovn;

l_dummy varchar2(1);

Begin

open c_existing(p_block.time_building_block_id,p_block.object_version_number);
fetch c_existing into l_dummy;
if(c_existing%notfound) then
  close c_existing;
  return false;
else
  close c_existing;
  return true;
end if;

End is_existing_block;

Function is_detail_block
          (p_block in HXC_BLOCK_TYPE)
           return BOOLEAN is
Begin

if(p_block.scope = hxc_timecard.c_detail_scope)then
  return true;
else
  return false;
end if;

End is_detail_block;

Function is_parent_block
          (p_block      in HXC_BLOCK_TYPE
          ,p_parent_id  in hxc_time_building_blocks.time_building_block_id%type
          ,p_parent_ovn in hxc_time_building_blocks.object_version_number%type
          ,p_check_id   in boolean
          ) return pls_integer is
Begin

if(
   (p_block.parent_building_block_id = p_parent_id)
  AND
   (p_block.parent_building_block_ovn = p_parent_ovn)
  ) then
   return 0;
elsif(p_block.parent_building_block_id = p_parent_id) then
   return 1;
else
  return 2;
end if;

End is_parent_block;

Function is_parent_block
          (p_block      in HXC_BLOCK_TYPE
          ,p_parent_id  in hxc_time_building_blocks.time_building_block_id%type
          ,p_parent_ovn in hxc_time_building_blocks.object_version_number%type
          ) return BOOLEAN is

Begin
   if(is_parent_block(p_block,p_parent_id,p_parent_ovn,true)=0) then
      return true;
   else
      return false;
   end if;
End is_parent_block;

Function is_updated_block
          (p_block in HXC_BLOCK_TYPE)
          return BOOLEAN is

l_prev_block hxc_block_type;

Begin

if(is_new_block(p_block)) then
  if(p_block.changed = 'Y') then
    return true;
  else
    return false;
  end if;
else
  l_prev_block := build_block(p_block.time_building_block_id,p_block.object_version_number);
  if(blocks_are_different(p_block,l_prev_block)) then
    return true;
  else
    -- 115.5 Change
    -- We might be processing this block due to a change in the
    -- attributes, so we should check the process flag as well
    if(process_block(p_block)) then
      return true;
    else
      return false;
    end if;
    -- end 115.5 Change
  end if;
end if;

End is_updated_block;

Function parent_has_changed
           (p_blocks in HXC_BLOCK_TABLE_TYPE
           ,p_parent_block_id in hxc_time_building_blocks.time_building_block_id%type
           ) return BOOLEAN is

l_index number;
l_parent_changed boolean := false;
l_parent_found boolean := false;

Begin

l_index := p_blocks.first;

Loop
  Exit when ((not p_blocks.exists(l_index)) or (l_parent_found));
  if(p_blocks(l_index).time_building_block_id = p_parent_block_id) then
    if((p_blocks(l_index).changed = 'Y')OR(process_block(p_blocks(l_index)))) then
      l_parent_changed := true;
    end if;
    l_parent_found := true;
  end if;
  l_index := p_blocks.next(l_index);
End loop;

return l_parent_changed;

End parent_has_changed;

Function process_block
          (p_block in HXC_BLOCK_TYPE
          ) return BOOLEAN is

Begin

if(p_block.process = hxc_timecard.c_process) then
 return true;
else
 return false;
end if;

End process_block;

Function can_process_block
          (p_block in hxc_block_type
          ) return boolean is

Begin

if(process_block(p_block)) then
  return true;
else
  if(is_new_block(p_block)) then
    return false;
  else
    return true;
  end if;
end if;

End can_process_block;

Function date_value
          (p_block_value in varchar2
          ) return date is

Begin

return fnd_date.canonical_to_date(p_block_value);

end date_value;

Function build_block
          (p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
          ) return HXC_BLOCK_TYPE is

cursor c_block
        (p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
        ,p_time_building_block_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
        ) is
select *
  from hxc_time_building_blocks
 where time_building_block_id = p_time_building_block_id
   and object_version_number = p_time_building_block_ovn;


l_block     c_block%ROWTYPE;
l_new_block HXC_BLOCK_TYPE;

BEGIN

open c_block(p_time_building_block_id,p_time_building_block_ovn);
fetch c_block into l_block;

if(c_block%FOUND) then

  close c_block;

  -- Convert to the type

  l_new_block :=
    HXC_BLOCK_TYPE
     (l_block.TIME_BUILDING_BLOCK_ID
     ,l_block.TYPE
     ,l_block.MEASURE
     ,l_block.UNIT_OF_MEASURE
     ,fnd_date.date_to_canonical(l_block.START_TIME)
     ,fnd_date.date_to_canonical(l_block.STOP_TIME)
     ,l_block.PARENT_BUILDING_BLOCK_ID
     ,'N' --l_block.PARENT_IS_NEW
     ,l_block.SCOPE
     ,l_block.OBJECT_VERSION_NUMBER
     ,l_block.APPROVAL_STATUS
     ,l_block.RESOURCE_ID
     ,l_block.RESOURCE_TYPE
     ,l_block.APPROVAL_STYLE_ID
     ,fnd_date.date_to_canonical(l_block.DATE_FROM)
     ,fnd_date.date_to_canonical(l_block.DATE_TO)
     ,l_block.COMMENT_TEXT
     ,l_block.PARENT_BUILDING_BLOCK_OVN
     ,'N' --l_block.NEW
     ,'N' --l_block.CHANGED
     ,'N' --l_block.process
     ,l_block.application_set_id
     ,l_block.translation_display_key
     );

else
  --
  -- No block with this id and ovn
  --
  close c_block;
  raise e_no_existing_block;

end if;


return l_new_block;

END build_block;

Function blocks_are_different
          (p_block1 in HXC_BLOCK_TYPE
          ,p_block2 in HXC_BLOCK_TYPE
          ) return boolean is

l_proc varchar2(70) := 'block_utils.blocks_are_different';

Begin

if(p_block1.scope = 'DETAIL') then

--
-- There is only a subset of things that
-- can be changed in the block, we
-- look for these things
--
-- 1. Measure
-- 2029550 Implementation
-- We need to consider 3 cases
-- compare a none null measure with a none null measure
-- compare a null measure with a none null measure
-- compare a none null measure with a null measure
   if(p_block1.type='MEASURE' AND p_block2.type='MEASURE') then
      if p_block1.measure <> p_block2.measure then
       return true;
      end if;
      if nvl(p_block1.measure,0) <> p_block2.measure then
       return true;
      end if;
      if p_block1.measure <> nvl(p_block2.measure,0) then
       return true;
      end if;
    end if;
    if(p_block1.type='RANGE' AND p_block2.type = 'RANGE') then
  -- 2. Start Time
    if(nvl(p_block1.start_time,'NULL') <> nvl(p_block2.start_time,'NULL')) then
      return true;
    end if;
  -- 3. Stop Time
    if(nvl(p_block1.stop_time,'NULL') <> nvl(p_block2.stop_time,'NULL')) then
      return true;
    end if;
  end if;
-- 4. Comment
  if(nvl(p_block1.comment_text,'NULL') <> nvl(p_block2.comment_text,'NULL')) then
    return true;
  end if;
-- 5. Approval Status
  if(nvl(p_block1.approval_status,'NULL') <> nvl(p_block2.approval_status,'NULL')) then
    return true;
  end if;
-- 6. Unit of measure
  if(nvl(p_block1.unit_of_measure,'NULL') <> nvl(p_block2.unit_of_measure,'NULL')) then
    return true;
  end if;
-- 7. Parent Building block OVN
-- Actually, this one won't work, since the parent OVN isn't updated yet.
-- Is this a problem?
  if(nvl(p_block1.parent_building_block_ovn,0) <> nvl(p_block2.parent_building_block_ovn,0)) then
    return true;
  end if;
-- 8. Date to
  if(nvl(p_block1.date_to,hr_general.end_of_time) <> nvl(p_block2.date_to,hr_general.end_of_time)) then
    return true;
  end if;
-- 9. Type
  if(nvl(p_block1.type,'RANGE') <> nvl(p_block2.type,'RANGE')) then
    return true;
  end if;
-- 10. Approval style id
  if(nvl(p_block1.approval_style_id,1) <> nvl(p_block2.approval_style_id,1)) then
    return true;
  end if;
-- 11. Translation Display Key
  if(nvl(p_block1.translation_display_key,'NULL') <> nvl(p_block2.translation_display_key,'NULL')) then
     return true;
  end if;
elsif((p_block1.scope=hxc_timecard.c_timecard_scope)OR(p_block1.scope=hxc_timecard.c_template_scope)) then
-- 1. Comment
  if(nvl(p_block1.comment_text,'NULL') <> nvl(p_block2.comment_text,'NULL')) then
    return true;
  end if;
-- 2. Approval Status
  if(nvl(p_block1.approval_status,'NULL') <> nvl(p_block2.approval_status,'NULL')) then
    return true;
  end if;
-- 3. Date to
  if(nvl(p_block1.date_to,hr_general.end_of_time) <> nvl(p_block2.date_to,hr_general.end_of_time)) then
    return true;
  end if;
-- 4. Approval style id
  if(nvl(p_block1.approval_style_id,1) <> nvl(p_block2.approval_style_id,1)) then
    return true;
  end if;
elsif(p_block1.scope='DAY') then
-- 1. Approval Status
  if(nvl(p_block1.approval_status,'NULL') <> nvl(p_block2.approval_status,'NULL')) then
    return true;
  end if;
-- 2. Date to
  if(nvl(p_block1.date_to,hr_general.end_of_time) <> nvl(p_block2.date_to,hr_general.end_of_time)) then
    return true;
  end if;
-- 3. Approval style id
  if(nvl(p_block1.approval_style_id,1) <> nvl(p_block2.approval_style_id,1)) then
    return true;
  end if;
end if;

--
-- If we get here, the blocks are (at least in terms of the user) the same
--
  return false;

End blocks_are_different;

Procedure sort_blocks
           (p_blocks          in            HXC_BLOCK_TABLE_TYPE
           ,p_timecard_blocks    out nocopy HXC_TIMECARD.BLOCK_LIST
           ,p_day_blocks         out nocopy HXC_TIMECARD.BLOCK_LIST
           ,p_detail_blocks      out nocopy HXC_TIMECARD.BLOCK_LIST
           ) is

l_block    HXC_BLOCK_TYPE;
l_index    NUMBER;

Begin

l_index := p_blocks.first;
LOOP
  EXIT WHEN NOT p_blocks.exists(l_index);
  l_block := p_blocks(l_index);

  if(is_timecard_block(l_block)) then
    --
    -- 115.3 Change.  In cases where we have more than one
    -- timecard block, one will always be end dated, the other
    -- new.  In this case we must process the deleted one first
    -- which means we must place the timecard blocks in the
    -- sorted arrays in reverse order of id.
    --
    p_timecard_blocks((-1*l_block.time_building_block_id)) := l_index;

  elsif(is_day_block(l_block)) then

    p_day_blocks(l_block.time_building_block_id) := l_index;

  elsif(is_detail_block(l_block)) then

    p_detail_blocks(l_block.time_building_block_id) := l_index;

  end if;
  l_index := p_blocks.next(l_index);
END LOOP;

End sort_blocks;

Function next_block_id
           (p_blocks in HXC_BLOCK_TABLE_TYPE
           ) return number is

l_index number;
l_bb_id number := -2;

Begin

l_index := p_blocks.first;

Loop
  Exit when not p_blocks.exists(l_index);

  if(p_blocks(l_index).time_building_block_id < l_bb_id) then
    l_bb_id := p_blocks(l_index).time_building_block_id;
  end if;
  l_index := p_blocks.next(l_index);
End Loop;

-- return large negative number to work round strange Santos
-- issue.

return (l_bb_id-100);

End next_block_id;

END hxc_timecard_block_utils;

/
