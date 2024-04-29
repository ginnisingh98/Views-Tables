--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_ATTRIBUTE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_ATTRIBUTE_UTILS" AS
/* $Header: hxctcatut.pkb 115.4 2004/01/02 16:32:48 arundell noship $ */

type attribute_index is table of hxc_time_attributes.time_attribute_id%type index by binary_integer;
type bld_blk_info_type_ids is table of hxc_bld_blk_info_types.bld_blk_info_type%type index by binary_integer;

g_bld_blk_info_type_ids bld_blk_info_type_ids;

g_package varchar2(30) := 'hxc_timecard_attribute_utils';

e_no_existing_attribute exception;

Function next_time_attribute_id
           (p_attributes in hxc_attribute_table_type)
           return number is

l_next_id number;
l_index   number;

Begin

if ((p_attributes is null) OR (p_attributes.count = 0)) then
  l_next_id := 1;
else
  l_index := p_attributes.first;
  l_next_id := p_attributes(l_index).time_attribute_id;

  Loop
    Exit when not p_attributes.exists(l_index);
    if(l_next_id > p_attributes(l_index).time_attribute_id) then
      l_next_id := p_attributes(l_index).time_attribute_id;
    end if;
    l_index := p_attributes.next(l_index);
  End Loop;
end if;

if (l_next_id > 0) then
  return -100;
else
  return (l_next_id-100);
end if;

End next_time_attribute_id;

FUNCTION get_bld_blk_info_type
          (p_info_type_id in NUMBER)
           return varchar2 is

cursor get_info_type(p_info_type_id in number) is
 select bld_blk_info_type
   from hxc_bld_blk_info_types
  where bld_blk_info_type_id = p_info_type_id;

l_info_type HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE;

Begin

--
-- See if we already have the id
--
if(g_bld_blk_info_type_ids.exists(p_info_type_id)) then
  return g_bld_blk_info_type_ids(p_info_type_id);
else
  open get_info_type(p_info_type_id);
  fetch get_info_type into l_info_type;
  if(get_info_type%NOTFOUND) then
   close get_info_type;
   FND_MESSAGE.SET_NAME('HXC','HXC_XXXXXX_NO_INFO_TYPE');
   FND_MESSAGE.RAISE_ERROR;
  else
   close get_info_type;
   g_bld_blk_info_type_ids(p_info_type_id) := l_info_type;
   return l_info_type;
  end if;
end if;

End get_bld_blk_info_type;

FUNCTION get_bld_blk_info_type_id
          (p_info_type in varchar2)
         RETURN number is

cursor csr_get_bld_blk_info_type_id IS
  select bld_blk_info_type_id
    from hxc_bld_blk_info_types
   where bld_blk_info_type = p_info_type;

l_index        NUMBER;
l_info_type_id hxc_bld_blk_info_types.bld_blk_info_type_id%type := NULL;

BEGIN
--
-- Check to see if we've cache the bld blk info type already
--

l_index := g_bld_blk_info_type_ids.first;

LOOP
  EXIT when ((NOT g_bld_blk_info_type_ids.exists(l_index)) OR (l_info_type_id is NOT NULL));

  if (g_bld_blk_info_type_ids(l_index)=p_info_type) then

    l_info_type_id := l_index;

  end if;

  l_index := g_bld_blk_info_type_ids.next(l_index);
END LOOP;

if(l_info_type_id is NULL) then

  open csr_get_bld_blk_info_type_id;
  fetch csr_get_bld_blk_info_type_id into l_info_type_id;

  if(csr_get_bld_blk_info_type_id%NOTFOUND) then
    close csr_get_bld_blk_info_type_id;
    FND_MESSAGE.SET_NAME('HXC','HXC_NO_BLD_BLK_INFO_TYPE');
    FND_MESSAGE.SET_TOKEN('TYPE',p_info_type);
    FND_MESSAGE.raise_error;
  else
    close csr_get_bld_blk_info_type_id;
  end if;
  --
  -- Add this info type to the cached bunch
  -- use the id as the index in the table
  --
  g_bld_blk_info_type_ids(l_info_type_id) := p_info_type;

end if;

return l_info_type_id;

END get_bld_blk_info_type_id;

Function convert_to_dpwr_attributes
          (p_attributes in HXC_ATTRIBUTE_TABLE_TYPE)
          return HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info IS

l_attributes HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info;
l_index      NUMBER;
l_proc       varchar2(72) := g_package||'convert_to_dpwr_attributes';

BEGIN

l_index := p_attributes.first;

LOOP
  EXIT WHEN NOT p_attributes.exists(l_index);

  l_attributes(l_index).TIME_ATTRIBUTE_ID := p_attributes(l_index).TIME_ATTRIBUTE_ID;
  l_attributes(l_index).BUILDING_BLOCK_ID := p_attributes(l_index).BUILDING_BLOCK_ID;
  l_attributes(l_index).ATTRIBUTE_CATEGORY := p_attributes(l_index).ATTRIBUTE_CATEGORY;
  l_attributes(l_index).ATTRIBUTE1 := p_attributes(l_index).ATTRIBUTE1;
  l_attributes(l_index).ATTRIBUTE2 := p_attributes(l_index).ATTRIBUTE2;
  l_attributes(l_index).ATTRIBUTE3 := p_attributes(l_index).ATTRIBUTE3;
  l_attributes(l_index).ATTRIBUTE4 := p_attributes(l_index).ATTRIBUTE4;
  l_attributes(l_index).ATTRIBUTE5 := p_attributes(l_index).ATTRIBUTE5;
  l_attributes(l_index).ATTRIBUTE6 := p_attributes(l_index).ATTRIBUTE6;
  l_attributes(l_index).ATTRIBUTE7 := p_attributes(l_index).ATTRIBUTE7;
  l_attributes(l_index).ATTRIBUTE8 := p_attributes(l_index).ATTRIBUTE8;
  l_attributes(l_index).ATTRIBUTE9 := p_attributes(l_index).ATTRIBUTE9;
  l_attributes(l_index).ATTRIBUTE10 := p_attributes(l_index).ATTRIBUTE10;
  l_attributes(l_index).ATTRIBUTE11 := p_attributes(l_index).ATTRIBUTE11;
  l_attributes(l_index).ATTRIBUTE12 := p_attributes(l_index).ATTRIBUTE12;
  l_attributes(l_index).ATTRIBUTE13 := p_attributes(l_index).ATTRIBUTE13;
  l_attributes(l_index).ATTRIBUTE14 := p_attributes(l_index).ATTRIBUTE14;
  l_attributes(l_index).ATTRIBUTE15 := p_attributes(l_index).ATTRIBUTE15;
  l_attributes(l_index).ATTRIBUTE16 := p_attributes(l_index).ATTRIBUTE16;
  l_attributes(l_index).ATTRIBUTE17 := p_attributes(l_index).ATTRIBUTE17;
  l_attributes(l_index).ATTRIBUTE18 := p_attributes(l_index).ATTRIBUTE18;
  l_attributes(l_index).ATTRIBUTE19 := p_attributes(l_index).ATTRIBUTE19;
  l_attributes(l_index).ATTRIBUTE20 := p_attributes(l_index).ATTRIBUTE20;
  l_attributes(l_index).ATTRIBUTE21 := p_attributes(l_index).ATTRIBUTE21;
  l_attributes(l_index).ATTRIBUTE22 := p_attributes(l_index).ATTRIBUTE22;
  l_attributes(l_index).ATTRIBUTE23 := p_attributes(l_index).ATTRIBUTE23;
  l_attributes(l_index).ATTRIBUTE24 := p_attributes(l_index).ATTRIBUTE24;
  l_attributes(l_index).ATTRIBUTE25 := p_attributes(l_index).ATTRIBUTE25;
  l_attributes(l_index).ATTRIBUTE26 := p_attributes(l_index).ATTRIBUTE26;
  l_attributes(l_index).ATTRIBUTE27 := p_attributes(l_index).ATTRIBUTE27;
  l_attributes(l_index).ATTRIBUTE28 := p_attributes(l_index).ATTRIBUTE28;
  l_attributes(l_index).ATTRIBUTE29 := p_attributes(l_index).ATTRIBUTE29;
  l_attributes(l_index).ATTRIBUTE30 := p_attributes(l_index).ATTRIBUTE30;
  l_attributes(l_index).BLD_BLK_INFO_TYPE_ID := p_attributes(l_index).BLD_BLK_INFO_TYPE_ID;
  l_attributes(l_index).OBJECT_VERSION_NUMBER := p_attributes(l_index).OBJECT_VERSION_NUMBER;
  l_attributes(l_index).NEW := p_attributes(l_index).NEW;
  l_attributes(l_index).CHANGED := p_attributes(l_index).CHANGED;
  l_attributes(l_index).BLD_BLK_INFO_TYPE := p_attributes(l_index).BLD_BLK_INFO_TYPE;

  l_index := p_attributes.next(l_index);

END LOOP;

return l_attributes;

End convert_to_dpwr_attributes;

Function convert_to_type
          (p_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info)
          return HXC_ATTRIBUTE_TABLE_TYPE is

l_attributes HXC_ATTRIBUTE_TABLE_TYPE;
l_index      NUMBER;

Begin

-- Initialize the collection

l_attributes := HXC_ATTRIBUTE_TABLE_TYPE();

l_index := p_attributes.first;

LOOP

  EXIT WHEN NOT p_attributes.exists(l_index);

  l_attributes.extend;

  l_attributes(l_attributes.last) :=
    HXC_ATTRIBUTE_TYPE
       (p_attributes(l_index).TIME_ATTRIBUTE_ID
       ,p_attributes(l_index).BUILDING_BLOCK_ID
       ,p_attributes(l_index).ATTRIBUTE_CATEGORY
       ,p_attributes(l_index).ATTRIBUTE1
       ,p_attributes(l_index).ATTRIBUTE2
       ,p_attributes(l_index).ATTRIBUTE3
       ,p_attributes(l_index).ATTRIBUTE4
       ,p_attributes(l_index).ATTRIBUTE5
       ,p_attributes(l_index).ATTRIBUTE6
       ,p_attributes(l_index).ATTRIBUTE7
       ,p_attributes(l_index).ATTRIBUTE8
       ,p_attributes(l_index).ATTRIBUTE9
       ,p_attributes(l_index).ATTRIBUTE10
       ,p_attributes(l_index).ATTRIBUTE11
       ,p_attributes(l_index).ATTRIBUTE12
       ,p_attributes(l_index).ATTRIBUTE13
       ,p_attributes(l_index).ATTRIBUTE14
       ,p_attributes(l_index).ATTRIBUTE15
       ,p_attributes(l_index).ATTRIBUTE16
       ,p_attributes(l_index).ATTRIBUTE17
       ,p_attributes(l_index).ATTRIBUTE18
       ,p_attributes(l_index).ATTRIBUTE19
       ,p_attributes(l_index).ATTRIBUTE20
       ,p_attributes(l_index).ATTRIBUTE21
       ,p_attributes(l_index).ATTRIBUTE22
       ,p_attributes(l_index).ATTRIBUTE23
       ,p_attributes(l_index).ATTRIBUTE24
       ,p_attributes(l_index).ATTRIBUTE25
       ,p_attributes(l_index).ATTRIBUTE26
       ,p_attributes(l_index).ATTRIBUTE27
       ,p_attributes(l_index).ATTRIBUTE28
       ,p_attributes(l_index).ATTRIBUTE29
       ,p_attributes(l_index).ATTRIBUTE30
       ,p_attributes(l_index).BLD_BLK_INFO_TYPE_ID
       ,p_attributes(l_index).OBJECT_VERSION_NUMBER
       ,p_attributes(l_index).NEW
       ,p_attributes(l_index).CHANGED
       ,p_attributes(l_index).BLD_BLK_INFO_TYPE
       ,'N' -- New process flag
       ,null -- building block ovn
       );

  l_index := p_attributes.next(l_index);

END LOOP;

return l_attributes;

End convert_to_type;

Function is_new_attribute
          (p_attribute in HXC_ATTRIBUTE_TYPE)
           return BOOLEAN is

Begin

if(p_attribute.new='Y') then
  return true;
else
  return false;
end if;

End is_new_Attribute;

Function is_new_attribute2
          (p_attribute in HXC_ATTRIBUTE_TYPE)
           return BOOLEAN is

Begin

if(p_attribute.new='Y') then
  return true;
else
  return false;
end if;

End is_new_Attribute2;

Function is_corresponding_block
          (p_attribute in HXC_ATTRIBUTE_TYPE
          ,p_block_id  in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ) RETURN BOOLEAN is

Begin

if(p_attribute.building_block_id =  p_block_id) then
  return true;
else
  return false;
end if;

End is_corresponding_block;

Function is_corresponding_block
          (p_attribute in HXC_ATTRIBUTE_TYPE
          ,p_block     in HXC_BLOCK_TYPE
          ) RETURN BOOLEAN is

Begin

if(p_attribute.building_block_id =  p_block.time_building_block_id) then
  return true;
else
  return false;
end if;

End is_corresponding_block;


Function is_system_context
          (p_attribute in HXC_ATTRIBUTE_TYPE)
          RETURN BOOLEAN is

Begin

--
-- These should be ordered so the most likely attribute
-- is first
--

if(p_attribute.attribute_category = hxc_timecard.c_security_attribute) then
  return true;
elsif(p_attribute.attribute_category = hxc_timecard.c_reason_attribute) then
  return true;
elsif(p_attribute.attribute_category = hxc_timecard.c_layout_attribute) then
  return true;
else
  return false;
end if;

End is_system_context;

Function process_attribute
          (p_attribute in hxc_attribute_type
          ) return BOOLEAN is

Begin

if(p_attribute.process = hxc_timecard.c_process) then
  return true;
else
  return false;
end if;

End process_attribute;

Function build_attribute
          (p_time_attribute_id in HXC_TIME_ATTRIBUTES.TIME_ATTRIBUTE_ID%TYPE
          ,p_object_version_number in HXC_TIME_ATTRIBUTES.OBJECT_VERSION_NUMBER%TYPE
          ,p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
          ) return HXC_ATTRIBUTE_TYPE is

cursor c_attribute
        (p_time_attribute_id in HXC_TIME_ATTRIBUTES.TIME_ATTRIBUTE_ID%TYPE
        ,p_object_version_number in HXC_TIME_ATTRIBUTES.OBJECT_VERSION_NUMBER%TYPE
        ) is
  select *
    from hxc_time_attributes
   where time_attribute_id = p_time_attribute_id
     and object_version_number = p_object_version_number;

l_new_attribute HXC_ATTRIBUTE_TYPE;
l_attribute_row c_attribute%ROWTYPE;

Begin

open c_attribute
       (p_time_attribute_id
       ,p_object_version_number
       );
fetch c_attribute into l_attribute_row;

if(c_attribute%FOUND) then
  close c_attribute;
  l_new_attribute :=
    HXC_ATTRIBUTE_TYPE
     (l_attribute_row.TIME_ATTRIBUTE_ID
     ,p_time_building_block_id
     ,l_attribute_row.ATTRIBUTE_CATEGORY
     ,l_attribute_row.ATTRIBUTE1
     ,l_attribute_row.ATTRIBUTE2
     ,l_attribute_row.ATTRIBUTE3
     ,l_attribute_row.ATTRIBUTE4
     ,l_attribute_row.ATTRIBUTE5
     ,l_attribute_row.ATTRIBUTE6
     ,l_attribute_row.ATTRIBUTE7
     ,l_attribute_row.ATTRIBUTE8
     ,l_attribute_row.ATTRIBUTE9
     ,l_attribute_row.ATTRIBUTE10
     ,l_attribute_row.ATTRIBUTE11
     ,l_attribute_row.ATTRIBUTE12
     ,l_attribute_row.ATTRIBUTE13
     ,l_attribute_row.ATTRIBUTE14
     ,l_attribute_row.ATTRIBUTE15
     ,l_attribute_row.ATTRIBUTE16
     ,l_attribute_row.ATTRIBUTE17
     ,l_attribute_row.ATTRIBUTE18
     ,l_attribute_row.ATTRIBUTE19
     ,l_attribute_row.ATTRIBUTE20
     ,l_attribute_row.ATTRIBUTE21
     ,l_attribute_row.ATTRIBUTE22
     ,l_attribute_row.ATTRIBUTE23
     ,l_attribute_row.ATTRIBUTE24
     ,l_attribute_row.ATTRIBUTE25
     ,l_attribute_row.ATTRIBUTE26
     ,l_attribute_row.ATTRIBUTE27
     ,l_attribute_row.ATTRIBUTE28
     ,l_attribute_row.ATTRIBUTE29
     ,l_attribute_row.ATTRIBUTE30
     ,l_attribute_row.BLD_BLK_INFO_TYPE_ID
     ,l_attribute_row.OBJECT_VERSION_NUMBER
     ,'N'
     ,'N'
     ,get_bld_blk_info_type(l_attribute_row.BLD_BLK_INFO_TYPE_ID)
     ,'N'
     ,p_time_building_block_ovn
     );

else
  close c_attribute;
  raise e_no_existing_attribute;
end if;

return l_new_attribute;

End Build_Attribute;

Function attributes_are_different
           (p_attribute1 in HXC_ATTRIBUTE_TYPE
           ,p_attribute2 in HXC_ATTRIBUTE_TYPE
           ) return BOOLEAN is

Begin

if(nvl(p_attribute1.attribute_category,'NULL') <> nvl(p_attribute2.attribute_category,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute1,'NULL') <> nvl(p_attribute2.attribute1,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute2,'NULL') <> nvl(p_attribute2.attribute2,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute3,'NULL') <> nvl(p_attribute2.attribute3,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute4,'NULL') <> nvl(p_attribute2.attribute4,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute5,'NULL') <> nvl(p_attribute2.attribute5,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute6,'NULL') <> nvl(p_attribute2.attribute6,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute7,'NULL') <> nvl(p_attribute2.attribute7,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute8,'NULL') <> nvl(p_attribute2.attribute8,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute9,'NULL') <> nvl(p_attribute2.attribute9,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute10,'NULL') <> nvl(p_attribute2.attribute10,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute11,'NULL') <> nvl(p_attribute2.attribute11,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute12,'NULL') <> nvl(p_attribute2.attribute12,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute13,'NULL') <> nvl(p_attribute2.attribute13,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute14,'NULL') <> nvl(p_attribute2.attribute14,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute15,'NULL') <> nvl(p_attribute2.attribute15,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute16,'NULL') <> nvl(p_attribute2.attribute16,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute17,'NULL') <> nvl(p_attribute2.attribute17,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute18,'NULL') <> nvl(p_attribute2.attribute18,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute19,'NULL') <> nvl(p_attribute2.attribute19,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute20,'NULL') <> nvl(p_attribute2.attribute20,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute21,'NULL') <> nvl(p_attribute2.attribute21,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute22,'NULL') <> nvl(p_attribute2.attribute22,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute23,'NULL') <> nvl(p_attribute2.attribute23,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute24,'NULL') <> nvl(p_attribute2.attribute24,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute25,'NULL') <> nvl(p_attribute2.attribute25,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute26,'NULL') <> nvl(p_attribute2.attribute26,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute27,'NULL') <> nvl(p_attribute2.attribute27,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute28,'NULL') <> nvl(p_attribute2.attribute28,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute29,'NULL') <> nvl(p_attribute2.attribute29,'NULL')) then
  return true;
end if;

if(nvl(p_attribute1.attribute30,'NULL') <> nvl(p_attribute2.attribute30,'NULL')) then
  return true;
end if;
--
-- If we get here, everything (that the user can change) is the same
-- so, don't process.
--
return false;

End attributes_are_different;

Function get_attribute_index
          (p_attributes        in hxc_attribute_table_type
          ,p_context           in hxc_time_attributes.attribute_category%type
          ,p_building_block_id in hxc_time_building_blocks.time_building_block_id%type default null
          ) return NUMBER is

l_index     number;
l_found     boolean := false;
l_attribute number;

Begin

l_index := p_attributes.first;

Loop
  Exit when ((not p_attributes.exists(l_index)) or (l_found));

  if(p_attributes(l_index).attribute_category = p_context) then
    if(p_building_block_id is not null) then
      if(p_building_block_id = p_attributes(l_index).building_block_id) then
      l_found := true;
      l_attribute := l_index;
      end if;
    else
      l_found := true;
      l_attribute := l_index;
    end if;
  end if;
  l_index := p_attributes.next(l_index);
End Loop;

return l_attribute;

End get_attribute_index;

Procedure set_bld_blk_info_type_id
           (p_attributes in out nocopy hxc_attribute_table_type) is

l_index number;

Begin

l_index := p_attributes.first;

Loop
  Exit when not p_attributes.exists(l_index);
  if(((p_attributes(l_index).bld_blk_info_type_id is null)
    OR
     (p_attributes(l_index).bld_blk_info_type_id = -1))
    AND
     (instr(p_attributes(l_index).bld_blk_info_type,hxc_timecard.c_alias_context_prefix) <1)
    )then

    p_attributes(l_index).bld_blk_info_type_id := get_bld_blk_info_type_id(p_attributes(l_index).bld_blk_info_type);
  end if;

  l_index := p_attributes.next(l_index);

End Loop;

End set_bld_blk_info_type_id;

Function index_deposit_attributes(p_deposit_attributes in hxc_attribute_table_type)
           return attribute_index is

l_index           number;
l_attribute_index attribute_index;

Begin

l_index := p_deposit_attributes.first;
Loop
  Exit when not p_deposit_attributes.exists(l_index);
  l_attribute_index(p_deposit_attributes(l_index).time_attribute_id) := l_index;
  l_index := p_deposit_attributes.next(l_index);
End Loop;

return l_attribute_index;

End index_deposit_attributes;

Function attribute_present
           (p_attribute_id in number
           ,p_attribute_index in attribute_index
           ) return boolean is

Begin

if(p_attribute_index.exists(p_attribute_id)) then
  return true;
else
  return false;
end if;

End attribute_present;

Procedure append_additional_reasons
            (p_deposit_attributes in out nocopy hxc_attribute_table_type
            ,p_attributes in                    hxc_attribute_table_type) is

l_attribute_index attribute_index;
l_index           NUMBER;

l_to_delete BOOLEAN;
l_index_to_delete 	NUMBER;

Begin

--First we need to remove the reason attributes which were added
--and not saved in the database.This happens when users first time
--enters the reaosns and then click on back and removes the reasons

l_index:=p_deposit_attributes.first;
LOOP
EXIT WHEN NOT p_deposit_attributes.exists(l_index);

l_to_delete := FALSE;

if p_deposit_attributes(l_index).attribute_category='REASON' AND
   p_deposit_attributes(l_index).time_attribute_id < 0 then

	l_to_delete		:= TRUE;
	l_index_to_delete	:=l_index;
end if;
l_index:=p_deposit_attributes.next(l_index);

     IF l_to_delete = TRUE then
	p_deposit_attributes.delete(l_index_to_delete);
     END IF;
END LOOP;

--now we can add the new reasons

l_attribute_index := index_deposit_attributes(p_deposit_attributes);

l_index := p_attributes.first;
Loop
  Exit when not p_attributes.exists(l_index);
  if(p_attributes(l_index).attribute_category = hxc_timecard.c_reason_attribute) then
    if(NOT attribute_present(p_attributes(l_index).time_attribute_id,l_attribute_index)) then
      if(is_new_attribute(p_attributes(l_index))) then
        p_deposit_attributes.extend;
        p_deposit_attributes(p_deposit_attributes.last) := p_attributes(l_index);
        p_deposit_attributes(p_deposit_attributes.last).process := hxc_timecard.c_yes;
      end if;
    end if;
  end if;
  l_index := p_attributes.next(l_index);
End Loop;

End append_additional_reasons;

Function effectively_deleted_attribute
           (p_attribute in hxc_attribute_type)
           return boolean is
Begin

if(
   (p_attribute.attribute_category is null)
  AND
   (p_attribute.attribute1 is null)
  AND
   (p_attribute.attribute2 is null)
  AND
   (p_attribute.attribute3 is null)
  AND
   (p_attribute.attribute4 is null)
  AND
   (p_attribute.attribute5 is null)
  AND
   (p_attribute.attribute6 is null)
  AND
   (p_attribute.attribute7 is null)
  AND
   (p_attribute.attribute8 is null)
  AND
   (p_attribute.attribute9 is null)
  AND
   (p_attribute.attribute10 is null)
  AND
   (p_attribute.attribute11 is null)
  AND
   (p_attribute.attribute12 is null)
  AND
   (p_attribute.attribute13 is null)
  AND
   (p_attribute.attribute14 is null)
  AND
   (p_attribute.attribute15 is null)
  AND
   (p_attribute.attribute16 is null)
  AND
   (p_attribute.attribute17 is null)
  AND
   (p_attribute.attribute18 is null)
  AND
   (p_attribute.attribute19 is null)
  AND
   (p_attribute.attribute20 is null)
  AND
   (p_attribute.attribute21 is null)
  AND
   (p_attribute.attribute22 is null)
  AND
   (p_attribute.attribute23 is null)
  AND
   (p_attribute.attribute24 is null)
  AND
   (p_attribute.attribute25 is null)
  AND
   (p_attribute.attribute26 is null)
  AND
   (p_attribute.attribute27 is null)
  AND
   (p_attribute.attribute28 is null)
  AND
   (p_attribute.attribute29 is null)
  AND
   (p_attribute.attribute30 is null)
  ) then
   return true;
  else
   return false;
end if;

End effectively_deleted_attribute;

Procedure remove_deleted_attributes
            (p_attributes in out nocopy hxc_attribute_table_type) is

l_index number;

Begin

l_index := p_attributes.first;

Loop
  Exit when not p_attributes.exists(l_index);

  if(effectively_deleted_attribute(p_attributes(l_index))) then
    p_attributes.delete(l_index);
  end if;

  l_index := p_attributes.next(l_index);

End Loop;

End remove_deleted_attributes;

END hxc_timecard_attribute_utils;

/
