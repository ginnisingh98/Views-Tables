--------------------------------------------------------
--  DDL for Package Body HXC_ARRAY_TIME_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ARRAY_TIME_DEPOSIT" AS
/* $Header: hxctcardp.pkb 120.2 2005/07/14 17:40:53 arundell noship $ */

TYPE block_list is TABLE of varchar2(30) index by binary_integer;

g_resource_id NUMBER;
g_start_time VARCHAR2(100);
g_stop_time VARCHAR2(100);
g_debug_count NUMBER :=0;

e_array_time_deposit EXCEPTION;

/*
PROCEDURE debug
           (p_procedure IN VARCHAR2
           ,p_reference IN NUMBER
           ,p_text IN VARCHAR2
           ) IS

l_loc VARCHAR2(70) := 'HXC_SELF_SERVICE_TIME_DEPOSIT.'|| p_procedure;

BEGIN

g_debug_count := g_debug_count + 1;

if (g_resource_id = 12185) then

INSERT INTO hxc_timecard_debug
(LINE
,LOCATION
,REFERENCE
,TEXT
)
VALUES
(g_debug_count
,l_loc
,p_reference
,p_text
);

COMMIT;

end if;

END debug;
*/
function globalBlockDeposit
           (p_blocks in HXC_BLOCK_TABLE_TYPE
           ,p_deleted in BOOLEAN default true) return block_list is

l_block_count NUMBER;
l_deposit_block BOOLEAN;
l_blocks_deposited block_list;
l_deposit_index number := 1;

begin

l_block_count := p_blocks.first;

LOOP
  EXIT WHEN NOT p_blocks.exists(l_block_count);
  -- Call the deposit block procedure
  l_deposit_block := false;

 if(p_blocks(l_block_count) is not null) then

  if(p_deleted) then
    l_deposit_block := true;
  else

    if(fnd_date.canonical_to_date(p_blocks(l_block_count).date_to) = hr_general.end_of_time) then

      l_deposit_block := true;

    end if;

  end if;

 end if;

 if(l_deposit_block) then

/*
  None of this is required anymore.

   if(p_blocks(l_block_count).scope = 'TIMECARD') then
    if(fnd_date.canonical_to_date(p_blocks(l_block_count).date_to) = hr_general.end_of_time) then

     --
     -- check to see if there is a timecard id already for this
     -- period
     --

     if (hxc_deposit_checks.chk_timecard_deposit
           (p_blocks
           ,l_block_count
           )
        ) then
     --
     -- There is an existing timecard, stop processing.
     --
        FND_MESSAGE.SET_NAME('HXC','HXC_366333_TIMECARD_EXISTS');
        raise e_array_time_deposit;

     end if;

    end if;
   end if;
*/

  if(p_blocks(l_block_count).scope = 'TIMECARD') then

   g_resource_id := p_blocks(l_block_count).resource_id;
   g_start_time := p_blocks(l_block_count).start_time;
   g_stop_time := p_blocks(l_block_count).stop_time;

  end if;

  l_blocks_deposited(p_blocks(l_block_count).time_building_block_id) := p_blocks(l_block_count).date_to;

  HXC_SELF_SERVICE_TIME_DEPOSIT.CALL_BLOCK_DEPOSIT
    (P_TIME_BUILDING_BLOCK_ID =>p_blocks(l_block_count).TIME_BUILDING_BLOCK_ID
    ,P_TYPE =>p_blocks(l_block_count).TYPE
    ,P_MEASURE =>p_blocks(l_block_count).MEASURE
    ,P_UNIT_OF_MEASURE =>p_blocks(l_block_count).UNIT_OF_MEASURE
    ,P_START_TIME =>p_blocks(l_block_count).START_TIME
    ,P_STOP_TIME =>p_blocks(l_block_count).STOP_TIME
    ,P_PARENT_BUILDING_BLOCK_ID =>p_blocks(l_block_count).PARENT_BUILDING_BLOCK_ID
    ,P_SCOPE =>p_blocks(l_block_count).SCOPE
    ,P_OBJECT_VERSION_NUMBER =>p_blocks(l_block_count).OBJECT_VERSION_NUMBER
    ,P_APPROVAL_STATUS => p_blocks(l_block_count).APPROVAL_STATUS
    ,P_RESOURCE_ID => p_blocks(l_block_count).RESOURCE_ID
    ,P_RESOURCE_TYPE => p_blocks(l_block_count).RESOURCE_TYPE
    ,P_APPROVAL_STYLE_ID => p_blocks(l_block_count).APPROVAL_STYLE_ID
    ,P_DATE_FROM => p_blocks(l_block_count).DATE_FROM
    ,P_DATE_TO => p_blocks(l_block_count).DATE_TO
    ,P_COMMENT_TEXT => p_blocks(l_block_count).COMMENT_TEXT
    ,P_PARENT_BUILDING_BLOCK_OVN => p_blocks(l_block_count).PARENT_BUILDING_BLOCK_OVN
    ,P_NEW => p_blocks(l_block_count).NEW
    ,P_PARENT_IS_NEW => p_blocks(l_block_count).PARENT_IS_NEW
    ,P_CHANGED => p_blocks(l_block_count).CHANGED
    );

 end if;

  l_block_count := p_blocks.next(l_block_count);

END LOOP;

return l_blocks_deposited;

end globalBlockDeposit;


function checkBlockDeposited
           (p_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
           ,p_blocks_deposited in block_list)
         return boolean is

i number;
l_deposited BOOLEAN := false;
l_found_block BOOLEAN := false;

begin

i := p_blocks_deposited.first;

LOOP

  EXIT WHEN ((NOT p_blocks_deposited.exists(i)) OR (l_found_block));

  if(i = p_building_block_id) then

    if(instr(p_blocks_deposited(i),'4712')>0 ) then

      l_found_block := true;
      l_deposited := true;

    else

      l_found_block := true;
      l_deposited := false;

    end if;

  end if;

  i := p_blocks_deposited.next(i);

END LOOP;

return l_deposited;

end checkBlockDeposited;

function checkBlockDeposited
           (p_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE)
         return boolean is

l_blocks HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO;
i number;
l_deposited BOOLEAN := false;
l_found_block BOOLEAN := false;

begin

l_blocks := hxc_self_service_time_deposit.get_building_blocks;

i := l_blocks.first;

LOOP

  EXIT WHEN ((NOT l_blocks.exists(i)) OR (l_found_block));

  if(l_blocks(i).time_building_block_id = p_building_block_id) then

    if(l_blocks(i).date_to = hr_general.end_of_time) then

      l_found_block := true;
      l_deposited := true;

    else

      l_found_block := true;
      l_deposited := false;

    end if;

  end if;

  i := l_blocks.next(i);

END LOOP;

return l_deposited;

end checkBlockDeposited;

function checkAttributeValues
           (p_attributes in HXC_ATTRIBUTE_TABLE_TYPE
           ,p_attribute_number in NUMBER
           ) return BOOLEAN is

l_deposit BOOLEAN := false;

BEGIN

if ((p_attributes(p_attribute_number).attribute1 is not null)
  OR
   (p_attributes(p_attribute_number).attribute1 <> '')) then

  l_deposit := true;

end if;

return l_deposit;

END checkAttributeValues;

function checkAliasAttributeValue
           (p_attributes in HXC_ATTRIBUTE_TABLE_TYPE
           ,p_attribute_number in NUMBER
           ) return BOOLEAN is

l_deposit BOOLEAN := false;

BEGIN
/*
if(instr(p_attributes(p_attribute_number).attribute_category,'OTL_ALIAS') = 0) then

  l_deposit := true;

else

  l_deposit := checkAttributeValues(p_attributes,p_attribute_number);

end if;

return l_deposit;
*/
return true;

END checkAliasAttributeValue;

procedure globalAttributeDeposit
           (p_attributes IN HXC_ATTRIBUTE_TABLE_TYPE
           ,p_deleted in BOOLEAN default TRUE
           ,p_block_list in block_list) is

l_attribute_count NUMBER;
l_deposit_attribute BOOLEAN := FALSE;
l_deposit_alias_attribute BOOLEAN := FALSE;

begin

l_attribute_count := p_attributes.first;

LOOP
  EXIT WHEN NOT p_attributes.exists(l_attribute_count);
  l_deposit_attribute := false;


 if(p_attributes(l_attribute_count).time_attribute_id is not null) then

   if(p_deleted) then
     l_deposit_attribute := true;
   else
     l_deposit_attribute := checkBlockDeposited(p_attributes(l_attribute_count).BUILDING_BLOCK_ID, p_block_list);
   end if;

   l_deposit_alias_attribute := checkAliasAttributeValue(p_attributes,l_attribute_count);

 end if;

 if((l_deposit_attribute) AND (l_deposit_alias_attribute))then

  HXC_SELF_SERVICE_TIME_DEPOSIT.CALL_ATTRIBUTE_DEPOSIT
    (P_TIME_ATTRIBUTE_ID => p_attributes(l_attribute_count).TIME_ATTRIBUTE_ID
    ,P_BUILDING_BLOCK_ID => p_attributes(l_attribute_count).BUILDING_BLOCK_ID
    ,P_ATTRIBUTE_CATEGORY=> p_attributes(l_attribute_count).ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1        => p_attributes(l_attribute_count).ATTRIBUTE1
    ,P_ATTRIBUTE2        => p_attributes(l_attribute_count).ATTRIBUTE2
    ,P_ATTRIBUTE3        => p_attributes(l_attribute_count).ATTRIBUTE3
    ,P_ATTRIBUTE4        => p_attributes(l_attribute_count).ATTRIBUTE4
    ,P_ATTRIBUTE5        => p_attributes(l_attribute_count).ATTRIBUTE5
    ,P_ATTRIBUTE6        => p_attributes(l_attribute_count).ATTRIBUTE6
    ,P_ATTRIBUTE7        =>  p_attributes(l_attribute_count).ATTRIBUTE7
    ,P_ATTRIBUTE8        =>  p_attributes(l_attribute_count).ATTRIBUTE8
    ,P_ATTRIBUTE9        =>  p_attributes(l_attribute_count).ATTRIBUTE9
    ,P_ATTRIBUTE10       =>  p_attributes(l_attribute_count).ATTRIBUTE10
    ,P_ATTRIBUTE11       =>  p_attributes(l_attribute_count).ATTRIBUTE11
    ,P_ATTRIBUTE12       =>  p_attributes(l_attribute_count).ATTRIBUTE12
    ,P_ATTRIBUTE13       =>  p_attributes(l_attribute_count).ATTRIBUTE13
    ,P_ATTRIBUTE14       =>  p_attributes(l_attribute_count).ATTRIBUTE14
    ,P_ATTRIBUTE15       =>  p_attributes(l_attribute_count).ATTRIBUTE15
    ,P_ATTRIBUTE16       =>  p_attributes(l_attribute_count).ATTRIBUTE16
    ,P_ATTRIBUTE17       =>  p_attributes(l_attribute_count).ATTRIBUTE17
    ,P_ATTRIBUTE18       =>  p_attributes(l_attribute_count).ATTRIBUTE18
    ,P_ATTRIBUTE19       =>  p_attributes(l_attribute_count).ATTRIBUTE19
    ,P_ATTRIBUTE20       =>  p_attributes(l_attribute_count).ATTRIBUTE20
    ,P_ATTRIBUTE21       =>  p_attributes(l_attribute_count).ATTRIBUTE21
    ,P_ATTRIBUTE22       =>  p_attributes(l_attribute_count).ATTRIBUTE22
    ,P_ATTRIBUTE23       =>  p_attributes(l_attribute_count).ATTRIBUTE23
    ,P_ATTRIBUTE24       =>  p_attributes(l_attribute_count).ATTRIBUTE24
    ,P_ATTRIBUTE25       =>  p_attributes(l_attribute_count).ATTRIBUTE25
    ,P_ATTRIBUTE26       =>  p_attributes(l_attribute_count).ATTRIBUTE26
    ,P_ATTRIBUTE27       =>  p_attributes(l_attribute_count).ATTRIBUTE27
    ,P_ATTRIBUTE28       =>  p_attributes(l_attribute_count).ATTRIBUTE28
    ,P_ATTRIBUTE29       =>  p_attributes(l_attribute_count).ATTRIBUTE29
    ,P_ATTRIBUTE30       =>  p_attributes(l_attribute_count).ATTRIBUTE30
    ,P_BLD_BLK_INFO_TYPE_ID =>  p_attributes(l_attribute_count).BLD_BLK_INFO_TYPE_ID
    ,P_OBJECT_VERSION_NUMBER =>  p_attributes(l_attribute_count).OBJECT_VERSION_NUMBER
    ,P_NEW =>  p_attributes(l_attribute_count).NEW
    ,P_CHANGED =>  p_attributes(l_attribute_count).CHANGED
    ,P_BLD_BLK_INFO_TYPE => p_attributes(l_attribute_count).BLD_BLK_INFO_TYPE
    );

  end if;

  l_attribute_count := p_attributes.next(l_attribute_count);

END LOOP;
/*
exception
  when others then
   FND_MESSAGE.SET_NAME('HXC','HXC_GLOBAL_ATTRIBUTE_DEPOSIT');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MESSAGE.RAISE_ERROR;
*/
end globalAttributeDeposit;

procedure add_layout_attribute
            (p_old_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.BUILDING_BLOCK_ATTRIBUTE_INFO
            ,p_exploded_attributes in out nocopy HXC_SELF_SERVICE_TIME_DEPOSIT.BUILDING_BLOCK_ATTRIBUTE_INFO
            ) is

l_found_attribute boolean := false;
l_next_attribute_index NUMBER;
l_attribute_index NUMBER;

begin

l_next_attribute_index := p_exploded_attributes.last;
l_next_attribute_index := l_next_attribute_index +1;

l_attribute_index := p_old_attributes.first;

LOOP

  EXIT WHEN ( (not p_old_attributes.exists(l_attribute_index)) OR (l_found_attribute));

  if(p_old_attributes(l_attribute_index).attribute_category = 'LAYOUT') then

   l_found_attribute := true;

   p_exploded_attributes(l_next_attribute_index).TIME_ATTRIBUTE_ID     := p_old_attributes(l_attribute_index).TIME_ATTRIBUTE_ID     ;
   p_exploded_attributes(l_next_attribute_index).BUILDING_BLOCK_ID     := p_old_attributes(l_attribute_index).BUILDING_BLOCK_ID     ;
   p_exploded_attributes(l_next_attribute_index).BLD_BLK_INFO_TYPE     := p_old_attributes(l_attribute_index).BLD_BLK_INFO_TYPE     ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE_CATEGORY    := p_old_attributes(l_attribute_index).ATTRIBUTE_CATEGORY    ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE1            := p_old_attributes(l_attribute_index).ATTRIBUTE1            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE2            := p_old_attributes(l_attribute_index).ATTRIBUTE2            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE3            := p_old_attributes(l_attribute_index).ATTRIBUTE3            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE4            := p_old_attributes(l_attribute_index).ATTRIBUTE4            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE5            := p_old_attributes(l_attribute_index).ATTRIBUTE5            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE6            := p_old_attributes(l_attribute_index).ATTRIBUTE6            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE7            := p_old_attributes(l_attribute_index).ATTRIBUTE7            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE8            := p_old_attributes(l_attribute_index).ATTRIBUTE8            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE9            := p_old_attributes(l_attribute_index).ATTRIBUTE9            ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE10           := p_old_attributes(l_attribute_index).ATTRIBUTE10           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE11           := p_old_attributes(l_attribute_index).ATTRIBUTE11           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE12           := p_old_attributes(l_attribute_index).ATTRIBUTE12           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE13           := p_old_attributes(l_attribute_index).ATTRIBUTE13           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE14           := p_old_attributes(l_attribute_index).ATTRIBUTE14           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE15           := p_old_attributes(l_attribute_index).ATTRIBUTE15           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE16           := p_old_attributes(l_attribute_index).ATTRIBUTE16           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE17           := p_old_attributes(l_attribute_index).ATTRIBUTE17           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE18           := p_old_attributes(l_attribute_index).ATTRIBUTE18           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE19           := p_old_attributes(l_attribute_index).ATTRIBUTE19           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE20           := p_old_attributes(l_attribute_index).ATTRIBUTE20           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE21           := p_old_attributes(l_attribute_index).ATTRIBUTE21           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE22           := p_old_attributes(l_attribute_index).ATTRIBUTE22           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE23           := p_old_attributes(l_attribute_index).ATTRIBUTE23           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE24           := p_old_attributes(l_attribute_index).ATTRIBUTE24           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE25           := p_old_attributes(l_attribute_index).ATTRIBUTE25           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE26           := p_old_attributes(l_attribute_index).ATTRIBUTE26           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE27           := p_old_attributes(l_attribute_index).ATTRIBUTE27           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE28           := p_old_attributes(l_attribute_index).ATTRIBUTE28           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE29           := p_old_attributes(l_attribute_index).ATTRIBUTE29           ;
   p_exploded_attributes(l_next_attribute_index).ATTRIBUTE30           := p_old_attributes(l_attribute_index).ATTRIBUTE30           ;
   p_exploded_attributes(l_next_attribute_index).BLD_BLK_INFO_TYPE_ID  := p_old_attributes(l_attribute_index).BLD_BLK_INFO_TYPE_ID  ;
   p_exploded_attributes(l_next_attribute_index).OBJECT_VERSION_NUMBER := p_old_attributes(l_attribute_index).OBJECT_VERSION_NUMBER ;
   p_exploded_attributes(l_next_attribute_index).NEW                   := p_old_attributes(l_attribute_index).NEW                   ;
   p_exploded_attributes(l_next_attribute_index).CHANGED               := p_old_attributes(l_attribute_index).CHANGED               ;

  end if;

  l_attribute_index := p_old_attributes.next(l_attribute_index);

END LOOP;

end add_layout_attribute;

function getValidExplosionBlocks
          (p_explosion_blocks in HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO
           ) return HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO is

  l_valid_blocks HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO;
  l_block_counter binary_integer;
  l_block_index binary_integer;

begin

  l_block_counter := p_explosion_blocks.first;
  l_block_index := 0;
  Loop
    Exit When not p_explosion_blocks.exists(l_block_counter);
    if((p_explosion_blocks(l_block_counter).TYPE = 'MEASURE')
      OR
       (p_explosion_blocks(l_block_counter).TYPE = 'RANGE')) then

      l_block_index := l_block_index + 1;

      l_valid_blocks(l_block_index).TIME_BUILDING_BLOCK_ID := p_explosion_blocks(l_block_counter).TIME_BUILDING_BLOCK_ID;
      l_valid_blocks(l_block_index).TYPE := p_explosion_blocks(l_block_counter).TYPE;
      l_valid_blocks(l_block_index).MEASURE := p_explosion_blocks(l_block_counter).MEASURE;
      l_valid_blocks(l_block_index).UNIT_OF_MEASURE := p_explosion_blocks(l_block_counter).UNIT_OF_MEASURE;
      l_valid_blocks(l_block_index).START_TIME := p_explosion_blocks(l_block_counter).START_TIME;
      l_valid_blocks(l_block_index).STOP_TIME := p_explosion_blocks(l_block_counter).STOP_TIME;
      l_valid_blocks(l_block_index).PARENT_BUILDING_BLOCK_ID := p_explosion_blocks(l_block_counter).PARENT_BUILDING_BLOCK_ID;
      l_valid_blocks(l_block_index).PARENT_IS_NEW := p_explosion_blocks(l_block_counter).PARENT_IS_NEW;
      l_valid_blocks(l_block_index).SCOPE := p_explosion_blocks(l_block_counter).SCOPE;
      l_valid_blocks(l_block_index).OBJECT_VERSION_NUMBER := p_explosion_blocks(l_block_counter).OBJECT_VERSION_NUMBER;
      l_valid_blocks(l_block_index).APPROVAL_STATUS := p_explosion_blocks(l_block_counter).APPROVAL_STATUS;
      l_valid_blocks(l_block_index).RESOURCE_ID := p_explosion_blocks(l_block_counter).RESOURCE_ID;
      l_valid_blocks(l_block_index).RESOURCE_TYPE := p_explosion_blocks(l_block_counter).RESOURCE_TYPE;
      l_valid_blocks(l_block_index).APPROVAL_STYLE_ID := p_explosion_blocks(l_block_counter).APPROVAL_STYLE_ID;
      l_valid_blocks(l_block_index).DATE_FROM := p_explosion_blocks(l_block_counter).DATE_FROM;
      l_valid_blocks(l_block_index).DATE_TO := p_explosion_blocks(l_block_counter).DATE_TO;
      l_valid_blocks(l_block_index).COMMENT_TEXT := p_explosion_blocks(l_block_counter).COMMENT_TEXT;
      l_valid_blocks(l_block_index).PARENT_BUILDING_BLOCK_OVN := p_explosion_blocks(l_block_counter).PARENT_BUILDING_BLOCK_OVN;
      l_valid_blocks(l_block_index).NEW := p_explosion_blocks(l_block_counter).NEW;
      l_valid_blocks(l_block_index).CHANGED := p_explosion_blocks(l_block_counter).CHANGED;

    end if;

    l_block_counter := p_explosion_blocks.next(l_block_counter);

    end loop;

  return l_valid_blocks;

end getValidExplosionBlocks;

function get_translation_blocks
          (p_blocks in HXC_BLOCK_TABLE_TYPE
          ,p_details_blocks in HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO
          ) return HXC_BLOCK_TABLE_TYPE IS -- HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO is

l_block number;
l_index number := 0;
l_trans_blocks HXC_BLOCK_TABLE_TYPE := HXC_BLOCK_TABLE_TYPE(); --hxc_self_service_time_deposit.timecard_info;

begin

l_block := p_blocks.first;

Loop
  Exit when not p_blocks.exists(l_block);

  if((p_blocks(l_block).scope = 'TIMECARD') OR (p_blocks(l_block).scope = 'DAY')) then

      l_trans_blocks.extend;
      l_index := l_trans_blocks.last;
      l_trans_blocks(l_index) :=
      HXC_BLOCK_TYPE(
        p_blocks(l_block).TIME_BUILDING_BLOCK_ID
       ,p_blocks(l_block).TYPE
       ,p_blocks(l_block).MEASURE
       ,p_blocks(l_block).UNIT_OF_MEASURE
       ,p_blocks(l_block).START_TIME--fnd_date.date_to_canonical(p_blocks(l_block).START_TIME)
       ,p_blocks(l_block).STOP_TIME--fnd_date.date_to_canonical(p_blocks(l_block).STOP_TIME)
       ,p_blocks(l_block).PARENT_BUILDING_BLOCK_ID
       ,p_blocks(l_block).PARENT_IS_NEW
       ,p_blocks(l_block).SCOPE
       ,p_blocks(l_block).OBJECT_VERSION_NUMBER
       ,p_blocks(l_block).APPROVAL_STATUS
       ,p_blocks(l_block).RESOURCE_ID
       ,p_blocks(l_block).RESOURCE_TYPE
       ,p_blocks(l_block).APPROVAL_STYLE_ID
       ,p_blocks(l_block).DATE_FROM--fnd_date.date_to_canonical(p_blocks(l_block).DATE_FROM)
       ,p_blocks(l_block).DATE_TO--fnd_date.date_to_canonical(p_blocks(l_block).DATE_TO)
       ,p_blocks(l_block).COMMENT_TEXT
       ,p_blocks(l_block).PARENT_BUILDING_BLOCK_OVN
       ,p_blocks(l_block).NEW
       ,p_blocks(l_block).CHANGED
       ,null
       ,null
       ,p_blocks(l_block).TRANSLATION_DISPLAY_KEY
     );

  end if;

  l_block := p_blocks.next(l_block);
End Loop;
--
-- Now append the exploded details
--
l_block := p_details_blocks.first;

Loop
  Exit when not p_details_blocks.exists(l_block);

      l_trans_blocks.extend;
      l_index := l_trans_blocks.last;
      l_trans_blocks(l_index) :=
      HXC_BLOCK_TYPE(
        p_details_blocks(l_block).TIME_BUILDING_BLOCK_ID
       ,p_details_blocks(l_block).TYPE
       ,p_details_blocks(l_block).MEASURE
       ,p_details_blocks(l_block).UNIT_OF_MEASURE
       ,fnd_date.date_to_canonical(p_details_blocks(l_block).START_TIME)
       ,fnd_date.date_to_canonical(p_details_blocks(l_block).STOP_TIME)
       ,p_details_blocks(l_block).PARENT_BUILDING_BLOCK_ID
       ,p_details_blocks(l_block).PARENT_IS_NEW
       ,p_details_blocks(l_block).SCOPE
       ,p_details_blocks(l_block).OBJECT_VERSION_NUMBER
       ,p_details_blocks(l_block).APPROVAL_STATUS
       ,p_details_blocks(l_block).RESOURCE_ID
       ,p_details_blocks(l_block).RESOURCE_TYPE
       ,p_details_blocks(l_block).APPROVAL_STYLE_ID
       ,fnd_date.date_to_canonical(p_details_blocks(l_block).DATE_FROM)
       ,fnd_date.date_to_canonical(p_details_blocks(l_block).DATE_TO)
       ,p_details_blocks(l_block).COMMENT_TEXT
       ,p_details_blocks(l_block).PARENT_BUILDING_BLOCK_OVN
       ,p_details_blocks(l_block).NEW
       ,p_details_blocks(l_block).CHANGED
       ,null
       ,null
       ,null -- can't set the display key at the moment.
     );

  l_block:=p_details_blocks.next(l_block);
End Loop;

return l_trans_blocks;

End get_translation_blocks;

procedure getExplodedHours
            (p_blocks in out nocopy HXC_BLOCK_TABLE_TYPE
            ,p_attributes in out nocopy HXC_ATTRIBUTE_TABLE_TYPE
            ,p_messages in out nocopy HXC_MESSAGE_TABLE_TYPE
            ) is

l_blocks 		 HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO;
l_valid_blocks 		 HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO;
l_blocks_for_translation HXC_BLOCK_TABLE_TYPE;
l_attributes 		 HXC_SELF_SERVICE_TIME_DEPOSIT.BUILDING_BLOCK_ATTRIBUTE_INFO;
l_old_attributes 	 HXC_SELF_SERVICE_TIME_DEPOSIT.BUILDING_BLOCK_ATTRIBUTE_INFO;
l_app_attributes 	 HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info;
l_deposit_process_id     HXC_DEPOSIT_PROCESSES.DEPOSIT_PROCESS_ID%TYPE;
l_messages 		 HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE;
l_messages_table	 HXC_MESSAGE_TABLE_TYPE;
l_att_count 		 NUMBER;
l_blocks_deposited       block_list;
l_exploded_details       HXC_BLOCK_TABLE_TYPE := HXC_BLOCK_TABLE_TYPE();
l_exploded_attributes    HXC_ATTRIBUTE_TABLE_TYPE:= HXC_ATTRIBUTE_TABLE_TYPE();

cursor c_dep_prc_id is
   select deposit_process_id
     from hxc_deposit_processes
    where name = 'OTL Deposit Process';

begin

--
-- Bug 3411488: Use new methods for doing the translation.
--

hxc_timecard_attribute_utils.set_bld_blk_info_type_id(p_attributes);
hxc_alias_translator.do_deposit_translation(p_attributes,p_messages);

--
-- Call to initialize the global variables!
--
p_messages := hxc_message_table_type();
hxc_self_service_time_deposit.initialize_globals;

-- set up the blocks and attributes
-- we don't just pass these because the hours explosion api
-- picks up the global variables!

--Bug 2770487  Sonarasi  04-Apr-2003
--Description : The p_deleted parameter of the function globalBlockDeposit
--and procedure globalAttributeDeposit determines whether deleted blocks can be
--passed to global tables or not. Deleted blocks will be considered for explosion
--if p_deleted parameter is true.

--Modifying the following call so that p_deleted is true.

--l_blocks_deposited := globalBlockDeposit(p_blocks, false);
--globalAttributeDeposit(p_attributes, false, l_blocks_deposited);

--Modified call
l_blocks_deposited := globalBlockDeposit(p_blocks, true);
globalAttributeDeposit(p_attributes, true, l_blocks_deposited);

--Bug 2770487  Sonarasi  Over

l_old_attributes := HXC_SELF_SERVICE_TIME_DEPOSIT.get_block_attributes;

--
-- Obtain the application attributes expected by
-- the hours explosion API
--

open c_dep_prc_id;
fetch c_dep_prc_id into l_deposit_process_id;
close c_dep_prc_id;
--
-- Bug 3411488: Use new methods for creating the application
-- attribtes.
--
l_app_attributes := hxc_app_attribute_utils.create_app_attributes
                      (p_attributes => p_attributes
                      ,p_retrieval_process_id => null
                      ,p_deposit_process_id => l_deposit_process_id
                      );

hxc_timecard_message_helper.initializeErrors;
--
-- Call the hours explosion API
--

hxt_hxc_retrieval_process.otlr_review_details
  (p_time_building_blocks => hxc_self_service_time_deposit.get_building_blocks
  ,p_time_attributes      => l_app_attributes
  ,p_messages             => l_messages
  ,p_detail_build_blocks  => l_blocks
  ,p_detail_attributes    => l_attributes
  );

if(l_messages.count >0) then

  hxc_timecard_message_utils.append_old_messages
   (p_messages             => p_messages
   ,p_old_messages         => l_messages
   ,p_retrieval_process_id => null
   );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  p_messages := hxc_timecard_message_helper.prepareMessages;

elsif(l_blocks.count > 0) then
  l_valid_blocks := getValidExplosionBlocks(l_blocks);
l_blocks_for_translation := get_translation_blocks(p_blocks,l_valid_blocks);
--
-- Translate back into alias understandable attributes, but first
-- add the layout attribute back in so that the translation code
-- knows which fields are translated on the layout!
--

add_layout_attribute(l_old_attributes,l_attributes);
l_exploded_attributes := hxc_deposit_wrapper_utilities.attributes_to_array
                            (p_attributes => l_attributes);

hxc_alias_translator.do_retrieval_translation
  (p_attributes  => l_exploded_attributes
  ,p_blocks      => l_blocks_for_translation
  ,p_start_time  => FND_DATE.CANONICAL_TO_DATE(g_start_time)
  ,p_stop_time   => FND_DATE.CANONICAL_TO_DATE(g_stop_time)
  ,p_resource_id => g_resource_id
  ,p_messages	 => l_messages_table
  );

-- Now we have to populate the block and attribute
-- tables to pass back to the middle tier
--
l_exploded_details := hxc_deposit_wrapper_utilities.blocks_to_array
              (p_blocks => l_valid_blocks);

elsif(l_blocks.count = 0) then

   hxc_timecard_message_helper.adderrortocollection
      (p_messages => p_messages,
       p_message_name => 'HXC_NO_EXPLODED_BLOCKS',
       p_message_level => 'WARNING',
       p_message_field => null,
       p_message_tokens => null,
       p_application_short_name => 'HXC',
       p_time_building_block_id => null,
       p_time_building_block_ovn => null,
       p_time_attribute_id => null,
       p_time_attribute_ovn => null,
       p_message_extent => null
       );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);

  p_messages := hxc_timecard_message_helper.prepareMessages;

end if;

p_blocks := l_exploded_details;
p_attributes := l_exploded_attributes;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('HXC','HXC_GET_EXPLODED_HOURS');
    FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE',SQLERRM);
    FND_MSG_PUB.add;

end getExplodedHours;

procedure deposit_blocks
  (p_timecard_id out nocopy HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_timecard_ovn out nocopy HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  ,p_blocks IN HXC_BLOCK_TABLE_TYPE
  ,p_attributes IN HXC_ATTRIBUTE_TABLE_TYPE
  ,p_item_type in WF_ITEMS.ITEM_TYPE%TYPE
  ,p_process_name in WF_ACTIVITIES.NAME%TYPE
  ,p_mode in varchar2
  ,p_deposit_process in varchar2
  ,p_retrieval_process in varchar2
  ,p_sql_error out nocopy varchar2
  ,p_validate_session in boolean default TRUE
  ,p_add_security in boolean default TRUE
  ) is

l_blocks HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO;
l_attributes  HXC_SELF_SERVICE_TIME_DEPOSIT.BUILDING_BLOCK_ATTRIBUTE_INFO;

l_timecard_id HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE;
l_timecard_ovn HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE;

l_block_count NUMBER;
l_attribute_count NUMBER;

l_blocks_deposited block_list;

BEGIN

--
-- Initialize the global variables
--

hxc_self_Service_time_deposit.initialize_globals;


--
-- Initialize the workflow globals
--

hxc_self_service_time_deposit.set_workflow_info
  (p_item_type => p_item_type
  ,p_process_name => p_process_name
  );

-- Create the block and attribute records, and pass to the
-- timecard deposit process.

l_blocks_deposited := globalBlockDeposit(p_blocks, true);

--
-- OK, now do the same with the attributes
--
globalAttributeDeposit(p_attributes, true, l_blocks_deposited);

--
-- Call the main deposit blocks procedure to actually
-- deposit the timecard information now that the globals
-- have been initialized
--

hxc_self_service_time_deposit.deposit_blocks
  (p_timecard_id => l_timecard_id
  ,p_timecard_ovn => l_timecard_ovn
  ,p_mode => p_mode
  ,p_deposit_process => p_deposit_process
  ,p_retrieval_process => p_retrieval_process
  ,p_validate_session => p_validate_session
  ,p_add_security => p_add_security
  );

--
-- Set the timecard id and ovn, and exit.
--

p_timecard_id := l_timecard_id;
p_timecard_ovn := l_timecard_ovn;

EXCEPTION
  WHEN e_array_time_deposit THEN
    FND_MSG_PUB.ADD;
    FND_MESSAGE.clear;

  WHEN OTHERS THEN
    p_sql_error := SQLERRM;
    raise;

END deposit_blocks;

end hxc_array_time_deposit;

/
