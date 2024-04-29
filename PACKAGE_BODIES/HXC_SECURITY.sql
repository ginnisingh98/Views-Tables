--------------------------------------------------------
--  DDL for Package Body HXC_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SECURITY" AS
/* $Header: hxcaddsec.pkb 120.7 2007/12/14 14:47:12 mikarthi noship $ */

type block_list is table of boolean index by binary_integer;

c_sec               VARCHAR2(8) := 'SECURITY';
c_sec_offset        NUMBER      := 1000000;
g_debug		    BOOLEAN	:= hr_utility.debug_enabled;

Function isTimecardForProjects
           (p_application_set_id in hxc_entity_group_comps.entity_group_id%type)
           return boolean is
  cursor c_projects_in_app_set
           (p_application_set_id in hxc_entity_group_comps.entity_group_id%type)
           is
   select 1
     from hxc_entity_group_comps egc,
          hxc_time_recipients tr
    where egc.entity_group_id = p_application_set_id
      and egc.entity_id = tr.time_recipient_id
      and tr.name = 'Projects';

  l_dummy number;

Begin
  open c_projects_in_app_set(p_application_set_id);
  fetch c_projects_in_app_set into l_dummy;
  if(c_projects_in_app_set%found) then
    close c_projects_in_app_set;
    return true;
  else
    close c_projects_in_app_set;
    return false;
  end if;
-- Should never get here!
  return true;
End isTimecardForProjects;

Function checkOrgId
  (p_blocks   in            hxc_block_table_type,
   p_org_id   in            number,
   p_messages in out nocopy hxc_message_table_type)
  return boolean is
  l_passed boolean := true;
Begin

  if(  (p_org_id is null)
       AND
         (isTimecardForProjects
           (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).
            application_set_id))) then
    if(p_messages is null) then
      p_messages := hxc_message_table_type();
    end if;
    l_passed := false;
    p_messages.extend();
    p_messages(p_messages.last) := hxc_message_type
      ('HXC_366546_NO_ORG_ID',
       hxc_timecard.c_error,
       null,
       null,
       hxc_timecard.c_hxc,
       null,
       null,
       null,
       null,
       null
       );
  end if;

  return l_passed;

End checkOrgId;

PROCEDURE obtain_block_list
           (p_attributes     in            hxc_attribute_table_type
           ,p_list              out nocopy block_list
           ,p_count             out nocopy number
           ,p_next_attribute    out nocopy number
           ) IS

l_index NUMBER;

BEGIN

l_index := p_attributes.first;
p_count := 0;
p_list.delete;
p_next_attribute := -2;

LOOP
  EXIT WHEN NOT p_attributes.exists(l_index);

  if(p_attributes(l_index).time_attribute_id <= p_next_attribute) then

    p_next_attribute := p_attributes(l_index).time_attribute_id -1;

  end if;

  if(p_attributes(l_index).attribute_category = c_sec) then

    p_list(p_attributes(l_index).building_block_id) := TRUE;
    p_count := p_count +1;

  end if;

  l_index := p_attributes.next(l_index);

END LOOP;

--
-- Need to do this because of CLA (etc.) can create attributes after
-- we've added the security attributes, and we don't want the ids
-- to get mixed up.
--
p_next_attribute := p_next_attribute - c_sec_offset;

END obtain_block_list;

PROCEDURE add_attribute
            (p_attributes         in out nocopy hxc_attribute_table_type
            ,p_bg_id              in            varchar2
            ,p_org_id             in            varchar2
            ,p_user_id            in            number
            ,p_resp_id            in            number
            ,p_resp_appl_id       in            number
            ,p_sec_grp_id         in            number
            ,p_building_block_id  in            number
            ,p_building_block_ovn in            number
            ,p_time_attribute_id  in out nocopy number
            ) is

begin

if(p_attributes is null) then
  p_attributes := hxc_attribute_table_type();
end if;

p_attributes.extend;

p_attributes(p_attributes.last) :=
    hxc_attribute_type
      (p_time_attribute_id
      ,p_building_block_id
      ,c_sec
      ,p_org_id
      ,p_bg_id
      ,p_user_id
      ,p_resp_id
      ,p_resp_appl_id
      ,p_sec_grp_id
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,hxc_timecard_attribute_utils.get_bld_blk_info_type_id(c_sec)
      ,1
      ,'Y'
      ,'N'
      ,c_sec
      ,'Y'
      ,p_building_block_ovn
      );

  p_time_attribute_id := p_time_attribute_id -1;

end add_attribute;

Function index_security_attributes
           (p_attributes in hxc_attribute_table_type)
         return block_list is

l_attribute_index number;
l_sec_list block_list;

Begin

l_attribute_index := p_attributes.first;
Loop
  Exit when not p_attributes.exists(l_attribute_index);
  if(p_attributes(l_attribute_index).attribute_category = hxc_timecard.c_security_attribute) then
    l_sec_list(p_attributes(l_attribute_index).building_block_id) := true;
  end if;
  l_attribute_index := p_attributes.next(l_attribute_index);
End Loop;

return l_sec_list;

End index_security_attributes;

Function need_to_reattach_security
           (p_block_id    in number
           ,p_sec_list    in block_list
           ) return boolean is

Begin

  if(p_sec_list.exists(p_block_id)) then
    return false;
  else
    return true;
  end if;

End need_to_reattach_security;

Procedure reattach_security_attributes
            (p_blocks     in            hxc_block_table_type
            ,p_attributes in out nocopy hxc_attribute_table_type
            ) is

cursor c_sec_attribute
         (p_block_id  in hxc_time_building_blocks.time_building_block_id%type
         ,p_block_ovn in hxc_time_building_blocks.object_version_number%type
         ) is
  select ta.time_attribute_id
        ,tau.time_building_block_id
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
        ,ta.object_version_number
        ,tau.time_building_block_ovn
        ,ta.bld_blk_info_type_id
        ,bbit.bld_blk_info_type
   from  hxc_time_attributes ta
        ,hxc_time_attribute_usages tau
        ,hxc_bld_blk_info_types bbit
  where  ta.time_attribute_id = tau.time_attribute_id
    and  tau.time_building_block_id = p_block_id
    and  tau.time_building_block_ovn = p_block_ovn
    and  ta.attribute_category = hxc_timecard.c_security_attribute
    and  ta.bld_blk_info_type_id = bbit.bld_blk_info_type_id;

l_index number;
l_attribute_index number;
l_sec_attr c_sec_attribute%rowtype;
l_sec_list block_list;

Begin

l_sec_list := index_security_attributes(p_attributes);

l_index := p_blocks.first;

Loop
  Exit When Not p_blocks.exists(l_index);
    if(p_blocks(l_index).new = 'N') then
      if(need_to_reattach_security(p_blocks(l_index).time_building_block_id,l_sec_list)) then
        open c_sec_attribute(p_blocks(l_index).time_building_block_id
                            ,p_blocks(l_index).object_version_number);
        fetch c_sec_attribute into l_sec_attr;
        if(c_sec_attribute%found) then
           l_attribute_index := p_attributes.last + 1;
           p_attributes.extend;
           p_attributes(l_attribute_index)
             := hxc_attribute_type
                  (l_sec_attr.time_attribute_id,
                   l_sec_attr.time_building_block_id,
                   l_sec_attr.attribute_category,
                   l_sec_attr.attribute1,
                   l_sec_attr.attribute2,
                   fnd_global.user_id,
                   fnd_global.resp_id,
                   l_sec_attr.attribute5,
                   l_sec_attr.attribute6,
                   l_sec_attr.attribute7,
                   l_sec_attr.attribute8,
                   l_sec_attr.attribute9,
                   l_sec_attr.attribute10,
                   l_sec_attr.attribute11,
                   l_sec_attr.attribute12,
                   l_sec_attr.attribute13,
                   l_sec_attr.attribute14,
                   l_sec_attr.attribute15,
                   l_sec_attr.attribute16,
                   l_sec_attr.attribute17,
                   l_sec_attr.attribute18,
                   l_sec_attr.attribute19,
                   l_sec_attr.attribute20,
                   l_sec_attr.attribute21,
                   l_sec_attr.attribute22,
                   l_sec_attr.attribute23,
                   l_sec_attr.attribute24,
                   l_sec_attr.attribute25,
                   l_sec_attr.attribute26,
                   l_sec_attr.attribute27,
                   l_sec_attr.attribute28,
                   l_sec_attr.attribute29,
                   l_sec_attr.attribute30,
                   l_sec_attr.bld_blk_info_type_id,
                   l_sec_attr.object_version_number,
                   'N', -- New
                   'N', -- Changed
                   l_sec_attr.bld_blk_info_type,
                   'N', -- Process
                   l_sec_attr.time_building_block_ovn
                   );
        end if;
        close c_sec_attribute;
      end if;
    end if;
  l_index := p_blocks.next(l_index);
End Loop;

End reattach_security_attributes;

PROCEDURE add_security_attribute
           (p_blocks         in            hxc_block_table_type,
            p_attributes     in out nocopy hxc_attribute_table_type,
            p_timecard_props in            hxc_timecard_prop_table_type,
            p_messages       in out nocopy hxc_message_table_type
           ) IS

  l_list           block_list;
  l_count          NUMBER;
  l_next_attribute NUMBER;
  l_index          NUMBER;
  l_org_id         fnd_profile_option_values.profile_option_value%type;
  l_bg_id          fnd_profile_option_values.profile_option_value%type;
  l_defined        BOOLEAN;
  l_test           BOOLEAN;
  l_passed         BOOLEAN;
  l_user_id        number;
  l_resp_id        number;
  l_resp_appl_id   number;
  l_sec_grp_id     number;

BEGIN

  g_debug:=hr_utility.debug_enabled;

  reattach_security_attributes
    (p_blocks     => p_blocks
    ,p_attributes => p_attributes
    );

  obtain_block_list
    (p_attributes     => p_attributes
    ,p_list           => l_list
    ,p_count          => l_count
    ,p_next_attribute => l_next_attribute
    );

  if(l_count <> p_blocks.count) then
    --
    -- We need to add to at least sec attr to one block
    --

    l_org_id := hxc_timecard_properties.find_property_value
      (p_timecard_props,
       'ResourceOrgId',
       null,
       null,
       sysdate
       );

    l_passed := checkOrgId(p_blocks,l_org_id,p_messages);

    if(l_passed) then

      l_bg_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
      l_user_id := fnd_global.user_id;
      l_resp_id := fnd_global.resp_id;
      l_resp_appl_id := fnd_global.resp_appl_id;
      l_sec_grp_id := fnd_global.security_group_id;
      --
      -- Loop over the blocks, and when we have one that
      -- does have a sec attribute, add it.
      --

      l_index := p_blocks.first;

      LOOP
        EXIT WHEN NOT p_blocks.exists(l_index);
        if(l_count > 0) then
          --
          -- Check to see if this block has a security attribute
          --
          BEGIN
            --
            -- Check for a block in the structure
            --
            l_test := l_list(p_blocks(l_index).time_building_block_id);
            --
            -- If we get here, then the block was in the list
            --
          EXCEPTION
            WHEN OTHERS then
              --
              -- If we get here, then the block wasn't in the list
              -- add the attribute
              --
              add_attribute
                (p_attributes         => p_attributes,
                 p_bg_id              => l_bg_id,
                 p_org_id             => l_org_id,
                 p_user_id            => l_user_id,
                 p_resp_id            => l_resp_id,
                 p_resp_appl_id       => l_resp_appl_id,
                 p_sec_grp_id         => l_sec_grp_id,
                 p_building_block_id  => p_blocks(l_index).time_building_block_id,
                 p_building_block_ovn => p_blocks(l_index).object_version_number,
                 p_time_attribute_id  => l_next_attribute
                 );
          END;
        else
          --
          -- No blocks have the sec attr, add to this block anyway
          --
          add_attribute
		  (p_attributes         => p_attributes,
		   p_bg_id              => l_bg_id,
		   p_org_id             => l_org_id,
		   p_user_id            => l_user_id,
		   p_resp_id            => l_resp_id,
		   p_resp_appl_id       => l_resp_appl_id,
		   p_sec_grp_id         => l_sec_grp_id,
		   p_building_block_id  => p_blocks(l_index).time_building_block_id,
		   p_building_block_ovn => p_blocks(l_index).object_version_number,
		   p_time_attribute_id  => l_next_attribute
                 );

        end if;-- Is there a list of blocks that already have the sec attribute

        l_index := p_blocks.next(l_index);

      END LOOP;

    end if; -- Did we pass the org id check?

  end if; -- Are any blocks missing security attributes?


END add_security_attribute;

END hxc_security;

/
