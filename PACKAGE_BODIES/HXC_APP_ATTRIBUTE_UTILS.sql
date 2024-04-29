--------------------------------------------------------
--  DDL for Package Body HXC_APP_ATTRIBUTE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APP_ATTRIBUTE_UTILS" as
/* $Header: hxcappattut.pkb 120.3 2006/08/30 10:29:06 gkrishna noship $ */

c_deposit_process CONSTANT VARCHAR2(7) := 'DEPOSIT';
c_retrieval_process CONSTANT VARCHAR2(9) := 'RETRIEVAL';

g_mappings           mappings;
g_retrieval_map      mapping_info;
g_deposit_map        mapping_info;
g_retrieval_bbit_map mapping_info;
g_deposit_bbit_map   mapping_info;
g_appset_recips      appset_recipient_table;
g_package            varchar2(35) := 'hxc_application_attribute_utils.';
g_bbit_multiplier    pls_integer;

function get_bbit_index
           (p_comp_index in pls_integer,
	    p_bbit_index in pls_integer) return pls_integer is
   cursor c_multiplier is
     select round(ceil(max(bld_blk_info_type_id)/1000),0)*1000
       from hxc_bld_blk_info_types;

   l_index pls_integer;
begin
   if(g_bbit_multiplier is null) then
      open c_multiplier;
      fetch c_multiplier into g_bbit_multiplier;
      close c_multiplier;
   end if;

   l_index := p_comp_index*g_bbit_multiplier + p_bbit_index;

   return l_index;

end get_bbit_index;

Procedure cache_mappings is

cursor c_mappings is
select mc.segment
      ,mc.field_name
      ,bbui.building_block_category category
      ,bbit.bld_blk_info_type info_type
      ,rp.retrieval_process_id
      ,dp.deposit_process_id
      ,mc.mapping_component_id
      ,bbit.bld_blk_info_type_id
      ,to_number(nvl(replace(replace(mc.segment,'ATTRIBUTE'),'_CATEGORY'),0))
from hxc_mapping_components mc
    ,hxc_mapping_comp_usages mcu
    ,hxc_mappings m1
    ,hxc_mappings m2
    ,hxc_retrieval_processes rp
    ,hxc_deposit_processes dp
    ,hxc_bld_blk_info_types bbit
    ,hxc_bld_blk_info_type_usages bbui
where rp.mapping_id (+) = m1.mapping_id
  and dp.mapping_id (+) = m2.mapping_id
  and m1.mapping_id = mcu.mapping_id
  and m2.mapping_id = mcu.mapping_id
  and mcu.mapping_component_id = mc.mapping_component_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id
  order by 6,5,8,9;

mapping_rec    c_mappings%rowtype;
l_index        number;
l_proc         varchar2(72) := g_package||'cache_mappings';
l_start_rindex number := null;
l_comp_rindex  number := null;
l_start_dindex number := null;
l_comp_dindex  number := null;
l_bb_index pls_integer;
l_bb_start_index pls_integer;
l_bb_rindex pls_integer;
l_bb_start_rindex pls_integer;
--
-- For Debugging
--
l_map_idx      number := null;


Begin

If ((g_mappings.count <1) or (g_deposit_bbit_map.count <1) or (g_retrieval_bbit_map.count<1)) then
l_index := 0;
--
-- Cache the mappings
--
  open c_mappings;
  Loop
    fetch c_mappings into mapping_rec;
    Exit When c_mappings%NOTFOUND;
    l_index := l_index +1;

    g_mappings(l_index).segment              := mapping_rec.segment              ;
    g_mappings(l_index).field_name           := mapping_rec.field_name           ;
    g_mappings(l_index).category             := mapping_rec.category             ;
    g_mappings(l_index).info_type            := mapping_rec.info_type            ;
    g_mappings(l_index).retrieval_process_id := mapping_rec.retrieval_process_id ;
    g_mappings(l_index).deposit_process_id   := mapping_rec.deposit_process_id   ;
    g_mappings(l_index).mapping_component_id := mapping_rec.mapping_component_id ;

    if(mapping_rec.deposit_process_id is not null) then
      if(l_comp_dindex is null) then
        l_start_dindex := l_index;
        l_comp_dindex  := mapping_rec.deposit_process_id;
	l_bb_index := mapping_rec.bld_blk_info_type_id;
	l_bb_start_index := l_index;
      else
        if(mapping_rec.deposit_process_id <> l_comp_dindex) then
          g_deposit_map(l_comp_dindex).start_index := l_start_dindex;
          g_deposit_map(l_comp_dindex).stop_index  := l_index-1;
	  g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).start_index := l_bb_start_index;
	  g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).stop_index := l_index -1;
          l_start_dindex := l_index;
          l_comp_dindex := mapping_rec.deposit_process_id;
	  l_bb_index := mapping_rec.bld_blk_info_type_id;
	  l_bb_start_index := l_index;
        else
	   if(mapping_rec.bld_blk_info_type_id <> l_bb_index) then
	      g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).start_index := l_bb_start_index;
	      g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).stop_index := l_index -1;
	      l_bb_index := mapping_rec.bld_blk_info_type_id;
	      l_bb_start_index := l_index;
	   end if;
        end if;
      end if;
    else
      if(l_comp_dindex is not null) then
        g_deposit_map(l_comp_dindex).start_index := l_start_dindex;
        g_deposit_map(l_comp_dindex).stop_index  := l_index-1;
	g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).start_index := l_bb_start_index;
	g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).stop_index := l_index -1;
        l_start_dindex := null;
        l_comp_dindex := null;
	l_bb_index := null;
	l_bb_start_index := null;
      end if;
    end if;

    if(mapping_rec.retrieval_process_id is not null) then
      if(l_comp_rindex is null) then
	 l_start_rindex := l_index;
	 l_comp_rindex  := mapping_rec.retrieval_process_id;
	 l_bb_rindex := mapping_rec.bld_blk_info_type_id;
	 l_bb_start_rindex := l_index;
      else
	 if(mapping_rec.retrieval_process_id <> l_comp_rindex) then
	    g_retrieval_map(l_comp_rindex).start_index := l_start_rindex;
	    g_retrieval_map(l_comp_rindex).stop_index  := l_index-1;
	    g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).start_index := l_bb_start_rindex;
	    g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).stop_index := l_index -1;
	    l_start_rindex := l_index;
	    l_comp_rindex := mapping_rec.retrieval_process_id;
	    l_bb_rindex := mapping_rec.bld_blk_info_type_id;
	    l_bb_start_rindex := l_index;
	 else
	    if(mapping_rec.bld_blk_info_type_id <> l_bb_rindex) then
	       g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).start_index := l_bb_start_rindex;
	       g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).stop_index := l_index -1;
	       l_bb_rindex := mapping_rec.bld_blk_info_type_id;
	       l_bb_start_rindex := l_index;
	    end if;
	 end if;
      end if;
   else
      if(l_comp_rindex is not null) then
	 g_retrieval_map(l_comp_rindex).start_index := l_start_rindex;
	 g_retrieval_map(l_comp_rindex).stop_index  := l_index-1;
	 g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).start_index := l_bb_start_rindex;
	 g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).stop_index := l_index -1;
	 l_start_rindex := null;
	 l_comp_rindex := null;
	 l_bb_start_rindex := null;
	 l_bb_rindex := null;
      end if;
   end if;

  End Loop;
  --
  -- Do the final deposit/retrieval process map caching
  --
  if(l_comp_rindex is not null) then
    g_retrieval_map(l_comp_rindex).start_index := l_start_rindex;
    g_retrieval_map(l_comp_rindex).stop_index  := l_index;
    g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).start_index := l_bb_start_rindex;
    g_retrieval_bbit_map(get_bbit_index(l_comp_rindex,l_bb_rindex)).stop_index := l_index;
  end if;
  if(l_comp_dindex is not null) then
    g_deposit_map(l_comp_dindex).start_index := l_start_dindex;
    g_deposit_map(l_comp_dindex).stop_index  := l_index;
    g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).start_index := l_bb_start_index;
    g_deposit_bbit_map(get_bbit_index(l_comp_dindex,l_bb_index)).stop_index := l_index;
  end if;

  close c_mappings;

end if;

end cache_mappings;

  Procedure clear_mapping_cache is

  Begin
    g_mappings.delete;
    g_deposit_map.delete;
    g_deposit_bbit_map.delete;
    g_retrieval_map.delete;
    g_retrieval_bbit_map.delete;
  End clear_mapping_cache;

Procedure set_recip_value
           (p_appset_id     in            number
           ,p_time_recip_id in            number
           ) is

Begin

if(g_appset_recips(p_appset_id).recipient1 is null) then
  g_appset_recips(p_appset_id).recipient1 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient2 is null) then
  g_appset_recips(p_appset_id).recipient2 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient3 is null) then
  g_appset_recips(p_appset_id).recipient3 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient4 is null) then
  g_appset_recips(p_appset_id).recipient4 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient5 is null) then
  g_appset_recips(p_appset_id).recipient5 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient6 is null) then
  g_appset_recips(p_appset_id).recipient6 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient7 is null) then
  g_appset_recips(p_appset_id).recipient7 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient8 is null) then
  g_appset_recips(p_appset_id).recipient8 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient9 is null) then
  g_appset_recips(p_appset_id).recipient9 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient10 is null) then
  g_appset_recips(p_appset_id).recipient10 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient11 is null) then
  g_appset_recips(p_appset_id).recipient11 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient12 is null) then
  g_appset_recips(p_appset_id).recipient12 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient13 is null) then
  g_appset_recips(p_appset_id).recipient13 := p_time_recip_id;
elsif(g_appset_recips(p_appset_id).recipient14 is null) then
  g_appset_recips(p_appset_id).recipient14 := p_time_recip_id;
else
  g_appset_recips(p_appset_id).recipient15 := p_time_recip_id;
end if;

End set_recip_value;

Procedure cache_appset_recipient is

Cursor c_appset_rets is
   select ascv.application_set_id
         ,ascv.time_recipient_id
     from hxc_application_Set_comps_v ascv;

l_application_set_id number;
l_time_recipient_id  number;

Begin

if(g_appset_recips.count <1) then

open c_appset_rets;

LOOP
  fetch c_appset_rets into l_application_set_id, l_time_recipient_id;
  EXIT when c_appset_rets%notfound;

  if(g_appset_recips.exists(l_application_set_id)) then
    set_recip_value(l_application_set_id,l_time_recipient_id);
  else
    g_appset_recips(l_application_set_id).recipient1 := l_time_recipient_id;
  end if;

END LOOP;

end if;

End cache_appset_recipient;

Function findSegmentFromFieldName
          (p_field_name           in hxc_mapping_components.field_name%type
          ) return varchar2 is

cursor c_otl_deposit_process is
  select deposit_process_id
    from hxc_deposit_processes
   where name = 'OTL Deposit Process';

cursor c_prompt_name(p_comp_id in number) is
select substr(fcu.form_left_prompt,1,30) prompt
from hxc_mapping_components mc
    ,hxc_bld_blk_info_types bbit
    ,fnd_descr_flex_col_usage_tl fcu
where mc.mapping_component_id = p_comp_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  and fcu.application_column_name = mc.segment
  and fcu.descriptive_flex_context_code = bbit.bld_blk_info_type
  and fcu.descriptive_flexfield_name = 'OTC Information Types'
  and fcu.application_id = 809
  and fcu.language = userenv('LANG');

l_index        number;
l_found        boolean := false;
l_segment      hxc_mapping_components.segment%type;
l_field_prompt fnd_descr_flex_col_usage_tl.form_left_prompt%type;
l_prompt       fnd_descr_flex_col_usage_tl.form_left_prompt%type;
l_field_no     number;
l_field_names  hxc_deposit_wrapper_utilities.t_simple_table;
l_ret_string   varchar2(4000) := '';
l_deposit_proc number;

Begin

if(g_mappings.count <1) then
  cache_mappings;
end if;

open c_otl_deposit_process;
fetch c_otl_deposit_process into l_deposit_proc;
close c_otl_deposit_process;

hxc_deposit_wrapper_utilities.string_to_table
  (':'
  ,':'||p_field_name
  ,l_field_names);

for l_field_no in 0..l_field_names.count-1 loop

  l_found := false;
  l_index := g_mappings.first;
  Loop
    Exit when ((not g_mappings.exists(l_index)) or (l_found));
    if(
        (g_mappings(l_index).field_name = l_field_names(l_field_no))
       AND
        (g_mappings(l_index).deposit_process_id=l_deposit_proc)
      ) then
      l_found := true;
      open c_prompt_name(g_mappings(l_index).mapping_component_id);
      fetch c_prompt_name into l_field_prompt;
      if(c_prompt_name%notfound) then
        l_prompt := initcap(replace(g_mappings(l_index).field_name,'_',' '));
      else
        l_prompt := l_field_prompt;
      end if;
      close c_prompt_name;
      l_ret_string := g_mappings(l_index).info_type||'|'||
                      g_mappings(l_index).segment||'|'||
                      l_prompt||':'||l_ret_string;
    end if;
    l_index := g_mappings.next(l_index);
  End Loop;

end loop;

return l_ret_string;

End findSegmentFromFieldName;

Procedure set_value
       (p_attributes          in            hxc_attribute_table_type
       ,p_attribute_index     in            number
       ,p_mapping_index       in            number
       ,p_app_attributes      in out nocopy hxc_self_service_time_deposit.app_attributes_info
       ,p_app_attribute_index in            number
       ) is

Begin

if(g_mappings(p_mapping_index).segment='ATTRIBUTE_CATEGORY') then
-- If the attribute category is like PAEXPITDFFC-NNNN then the attribute value needs
--to be populated with the original attribute category that is like PAEXPITDFF- ABCDSGS


        p_app_attributes(p_app_attribute_index).attribute_value :=
	hxc_deposit_wrapper_utilities.get_dupdff_name(p_attributes(p_attribute_index).attribute_category);

--   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE_CATEGORY;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE1') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE1;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE2') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE2;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE3') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE3;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE4') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE4;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE5') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE5;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE6') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE6;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE7') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE7;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE8') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE8;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE9') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE9;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE10') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE10;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE11') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE11;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE12') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE12;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE13') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE13;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE14') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE14;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE15') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE15;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE16') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE16;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE17') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE17;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE18') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE18;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE19') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE19;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE20') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE20;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE21') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE21;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE22') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE22;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE23') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE23;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE24') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE24;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE25') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE25;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE26') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE26;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE27') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE27;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE28') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE28;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE29') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE29;
elsif(g_mappings(p_mapping_index).segment='ATTRIBUTE30') then
   p_app_attributes(p_app_attribute_index).attribute_value := p_attributes(p_attribute_index).ATTRIBUTE30;
end if;

End set_value;

Function mapping_applies
           (p_attribute  in hxc_attribute_type
           ,p_mapping_index in number
           ,p_retrieval_process_id in number
           ,p_deposit_process_id in number
           ) return boolean is

Begin

if(p_attribute.bld_blk_info_type = g_mappings(p_mapping_index).info_type) then
  if(p_deposit_process_id is NULL) then
    if(p_retrieval_process_id = g_mappings(p_mapping_index).retrieval_process_id) then
      return true;
    else
      return false;
    end if;
  else
    if(p_deposit_process_id = g_mappings(p_mapping_index).deposit_process_id) then
      return true;
    else
      return false;
    end if;
  end if;
else
  return false;
end if;

End mapping_applies;

Function retrieval_applies
           (p_application_set_id   in number
           ,p_retrieval_process_id in number
           ,p_recipients           in hxc_timecard_validation.recipient_application_table
           ) return BOOLEAN is

l_recipient_id hxc_time_recipients.time_recipient_id%type := null;
l_index number;
l_found boolean;

Begin

l_index := p_recipients.first;
Loop
  Exit when ((not p_recipients.exists(l_index)) or (l_found));
  if(p_recipients(l_index).appl_retrieval_process_id = p_retrieval_process_id) then
    l_found := true;
    l_recipient_id := p_recipients(l_index).time_recipient_id;
  end if;
  l_index := p_recipients.next(l_index);
End Loop;

if(l_recipient_id is not null) then

  if(g_appset_recips(p_application_set_id).recipient1 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient2 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient3 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient4 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient5 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient6 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient7 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient8 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient9 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient10 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient11 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient12 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient13 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient14 = l_recipient_id) then
    return true;
  elsif(g_appset_recips(p_application_set_id).recipient15= l_recipient_id) then
    return true;
  else
    return false;
  end if;
else
  return false;
end if;

End retrieval_applies;

Function appsetid_applies
          (p_application_set_id   in number
          ,p_retrieval_process_id in number
          ,p_recipients           in hxc_timecard_validation.recipient_application_table
          ) return BOOLEAN is

Begin
  if(g_appset_recips.exists(p_application_set_id)) then
    if(retrieval_applies(p_application_set_id,p_retrieval_process_id,p_recipients)) then
      return true;
    else
      return false;
    end if;
  else
    return false;
  end if;

End appsetid_applies;

Function mapping_applies
           (p_attribute  in hxc_attribute_type
           ,p_mapping_index in number
           ,p_retrieval_process_id in number
           ,p_deposit_process_id in number
           ,p_application_set_id in number
           ,p_recipients         in hxc_timecard_validation.recipient_application_table
           ) return boolean is

Begin

if(appsetid_applies(p_application_set_id,p_retrieval_process_id,p_recipients)) then
 if(p_attribute.bld_blk_info_type = g_mappings(p_mapping_index).info_type) then
  if(p_deposit_process_id is NULL) then
    if(p_retrieval_process_id = g_mappings(p_mapping_index).retrieval_process_id) then
      return true;
    else
      return false;
    end if;
  else
    if(p_deposit_process_id = g_mappings(p_mapping_index).deposit_process_id) then
      return true;
    else
      return false;
    end if;
  end if;
 else
  return false;
 end if;
else
 return false;
end if;

End mapping_applies;

Function maximumAttribute
           (p_attribute in HXC_ATTRIBUTE_TYPE) return pls_integer is
   l_max_populated_attribute pls_integer;
Begin

   l_max_populated_attribute := 0;

   if(p_attribute.attribute1 is not null) then
      l_max_populated_attribute := 1;
   end if;
   if(p_attribute.attribute2 is not null) then
      l_max_populated_attribute := 2;
   end if;
   if(p_attribute.attribute3 is not null) then
      l_max_populated_attribute := 3;
   end if;
   if(p_attribute.attribute4 is not null) then
      l_max_populated_attribute := 4;
   end if;
   if(p_attribute.attribute5 is not null) then
      l_max_populated_attribute := 5;
   end if;
   if(p_attribute.attribute6 is not null) then
      l_max_populated_attribute := 6;
   end if;
   if(p_attribute.attribute7 is not null) then
      l_max_populated_attribute := 7;
   end if;
   if(p_attribute.attribute8 is not null) then
      l_max_populated_attribute := 8;
   end if;
   if(p_attribute.attribute9 is not null) then
      l_max_populated_attribute := 9;
   end if;
   if(p_attribute.attribute10 is not null) then
      l_max_populated_attribute := 10;
   end if;
   if(p_attribute.attribute11 is not null) then
      l_max_populated_attribute := 11;
   end if;
   if(p_attribute.attribute12 is not null) then
      l_max_populated_attribute := 12;
   end if;
   if(p_attribute.attribute13 is not null) then
      l_max_populated_attribute := 13;
   end if;
   if(p_attribute.attribute14 is not null) then
      l_max_populated_attribute := 14;
   end if;
   if(p_attribute.attribute15 is not null) then
      l_max_populated_attribute := 15;
   end if;
   if(p_attribute.attribute16 is not null) then
      l_max_populated_attribute := 16;
   end if;
   if(p_attribute.attribute17 is not null) then
      l_max_populated_attribute := 17;
   end if;
   if(p_attribute.attribute18 is not null) then
      l_max_populated_attribute := 18;
   end if;
   if(p_attribute.attribute19 is not null) then
      l_max_populated_attribute := 19;
   end if;
   if(p_attribute.attribute20 is not null) then
      l_max_populated_attribute := 20;
   end if;
   if(p_attribute.attribute21 is not null) then
      l_max_populated_attribute := 21;
   end if;
   if(p_attribute.attribute22 is not null) then
      l_max_populated_attribute := 22;
   end if;
   if(p_attribute.attribute23 is not null) then
      l_max_populated_attribute := 23;
   end if;
   if(p_attribute.attribute24 is not null) then
      l_max_populated_attribute := 24;
   end if;
   if(p_attribute.attribute25 is not null) then
      l_max_populated_attribute := 25;
   end if;
   if(p_attribute.attribute26 is not null) then
      l_max_populated_attribute := 26;
   end if;
   if(p_attribute.attribute27 is not null) then
      l_max_populated_attribute := 27;
   end if;
   if(p_attribute.attribute28 is not null) then
      l_max_populated_attribute := 28;
   end if;
   if(p_attribute.attribute29 is not null) then
      l_max_populated_attribute := 29;
   end if;
   if(p_attribute.attribute30 is not null) then
      l_max_populated_attribute := 30;
   end if;

   return l_max_populated_attribute;

End maximumAttribute;

Function skip_attribute_entry(p_attribute in HXC_ATTRIBUTE_TYPE) return BOOLEAN is
l_return boolean := FALSE;
begin
if(p_attribute.attribute_category = 'APPROVAL') AND (maximumAttribute(p_attribute)=0) then
	return true;
else
	return false;
end if;
END skip_attribute_entry;


Procedure setMappings
            (p_process_id in number,
	     p_process_type in varchar2,
	     p_attributes in hxc_attribute_table_type,
	     p_app_attributes in out nocopy hxc_self_service_time_deposit.app_attributes_info) is

   l_attribute HXC_ATTRIBUTE_TYPE;

   l_mapping_index pls_integer;
   l_mapping_end pls_integer;
   l_attribute_index pls_integer;
   l_max_attribute_number pls_integer;
   l_index pls_integer;
   l_attribute_required boolean;

   l_map_complete boolean;

Begin
   l_index := 0;
   l_attribute_index := p_attributes.first;
   Loop
      Exit when not p_attributes.exists(l_attribute_index);
      l_attribute := p_attributes(l_attribute_index);
      l_attribute_required := true;
      if(p_process_type = c_deposit_process) then
	 l_attribute_required := g_deposit_bbit_map.exists(get_bbit_index(p_process_id,l_attribute.bld_blk_info_type_id));
      else
	 l_attribute_required := g_retrieval_bbit_map.exists(get_bbit_index(p_process_id,l_attribute.bld_blk_info_type_id));
      end if;

      if(l_attribute_required) then

      l_max_attribute_number := maximumAttribute(l_attribute);
      l_map_complete := false;

      if(p_process_type = c_deposit_process) then
	 l_mapping_index := g_deposit_bbit_map(get_bbit_index(p_process_id,l_attribute.bld_blk_info_type_id)).start_index;
	 l_mapping_end := g_deposit_bbit_map(get_bbit_index(p_process_id,l_attribute.bld_blk_info_type_id)).stop_index;
      else
	 l_mapping_index := g_retrieval_bbit_map(get_bbit_index(p_process_id,l_attribute.bld_blk_info_type_id)).start_index;
	 l_mapping_end := g_retrieval_bbit_map(get_bbit_index(p_process_id,l_attribute.bld_blk_info_type_id)).stop_index;
      end if;
      --
      -- Attribute Category
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 0)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE_CATEGORY') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute_category;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute1
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 1)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE1') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute1;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute2
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 2)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE2') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute2;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute3
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 3)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE3') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute3;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute4
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 4)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE4') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute4;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute5
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 5)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE5') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute5;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute6
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 6)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE6') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute6;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute7
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 7)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE7') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute7;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute8
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 8)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE8') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute8;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute9
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 9)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE9') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute9;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute10
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 10)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE10') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute10;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute11
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 11)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE11') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute11;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute12
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 12)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE12') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute12;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute13
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 13)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE13') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute13;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute14
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 14)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE14') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute14;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute15
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 15)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE15') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute15;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute16
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 16)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE16') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute16;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute17
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 17)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE17') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute17;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute18
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 18)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE18') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute18;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute19
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 19)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE19') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute19;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute20
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 20)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE20') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute20;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute21
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 21)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE21') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute21;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute22
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 22)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE22') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute22;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute23
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 23)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE23') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute23;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute24
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 24)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE24') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute24;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute25
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 25)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE25') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute25;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute26
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 26)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE26') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute26;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute27
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 27)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE27') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute27;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute28
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 28)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE28') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute28;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute29
      --
      if((NOT l_map_complete) AND (l_max_attribute_number >= 29)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE29') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute29;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      --
      -- Attribute30
      --
      if((NOT l_map_complete) AND (l_max_attribute_number = 30)) then
      if(g_mappings.exists(l_mapping_index)) then
	 if(g_mappings(l_mapping_index).segment = 'ATTRIBUTE30') then
	    l_index := l_index + 1;
	    p_app_attributes(l_index).time_attribute_id := l_attribute.time_attribute_id;
	    p_app_attributes(l_index).building_block_id := l_attribute.building_block_id;
	    p_app_attributes(l_index).category := g_mappings(l_mapping_index).category;
	    p_app_attributes(l_index).bld_blk_info_type := l_attribute.bld_blk_info_type;
	    p_app_attributes(l_index).attribute_index := l_attribute_index;
	    p_app_attributes(l_index).segment := g_mappings(l_mapping_index).segment;
	    p_app_attributes(l_index).changed := l_attribute.changed;
	    p_app_attributes(l_index).process := l_attribute.process; --SHIV
	    p_app_attributes(l_index).attribute_name := g_mappings(l_mapping_index).field_name;
	    p_app_attributes(l_index).attribute_value := l_attribute.attribute30;
	    l_mapping_index := l_mapping_index +1;
	    if(l_mapping_index > l_mapping_end) then
	       l_map_complete := true;
	    end if;
	 end if;
      end if;
      end if;
      end if;
      l_attribute_index := p_attributes.next(l_attribute_index);
   End Loop;

End setMappings;
--
-- New more performant version.
--
Function create_app_attributes
           (p_attributes           in     hxc_attribute_table_type
           ,p_retrieval_process_id in     hxc_retrieval_processes.retrieval_process_id%type
           ,p_deposit_process_id   in     hxc_deposit_processes.deposit_process_id%type
           ) return hxc_self_service_time_deposit.app_attributes_info is

l_index pls_integer;
l_app_attributes      hxc_self_service_time_deposit.app_attributes_info;
l_map_idx pls_integer;

Begin
--
-- Make sure we have the mappings
--
   cache_mappings;
--
-- Set the index basis, deposit or retrieval?
--
   if(p_deposit_process_id is not null) then
      setMappings(p_deposit_process_id,c_deposit_process,p_attributes, l_app_attributes);
   else
      setMappings(p_retrieval_process_id,c_retrieval_process,p_attributes, l_app_attributes);
   end if;

   return l_app_attributes;

End create_app_attributes;

Function attribute_needed
          (p_blocks in hxc_block_table_type
          ,p_time_building_block_id in number
          ) return boolean is

l_index number;
l_found boolean := false;

Begin

l_index := p_blocks.first;

Loop
  Exit when ((not p_blocks.exists(l_index)) OR (l_found));

  if(p_blocks(l_index).time_building_block_id = p_time_building_block_id) then
    l_found := true;
  end if;

  l_index := p_blocks.next(l_index);
End Loop;

return l_found;

End attribute_needed;

Function find_corresponding_app_set_id
          (p_blocks in hxc_block_table_type
          ,p_time_building_block_id in number
          ) return number is

l_index     number;
l_appset_id number := -1;
l_found     boolean := false;

Begin

l_index := p_blocks.first;

Loop
  Exit when ((not p_blocks.exists(l_index)) OR (l_found));

  if(p_blocks(l_index).time_building_block_id = p_time_building_block_id) then
    l_appset_id := p_blocks(l_index).application_set_id;
    l_found := true;
  end if;

  l_index := p_blocks.next(l_index);
End Loop;

return l_appset_id;

End find_corresponding_app_set_id;

Function create_app_attributes
           (p_blocks               in     hxc_block_table_type
           ,p_attributes           in     hxc_attribute_table_type
           ,p_retrieval_process_id in     hxc_retrieval_processes.retrieval_process_id%type
           ,p_deposit_process_id   in     hxc_deposit_processes.deposit_process_id%type
           ,p_recipients           in     hxc_timecard_validation.recipient_application_table
           ) return hxc_self_service_time_deposit.app_attributes_info is

l_attribute_index     number;
l_mapping_index       number;
l_app_attribute_index number := 0;
l_app_attributes      hxc_self_service_time_deposit.app_attributes_info;
g_appset_recips       appset_recipient_table;
l_block_app_set       number;
l_mapping_start       number;
l_mapping_stop        number;

l_proc varchar2(70) := 'create_app_attributes(block)';

Begin
--
-- Make sure we have the mappings
  cache_mappings;
--
-- Cache all the recipients and corresponding application sets
--
  cache_appset_recipient;
--
-- Loop over the attributes
--
l_attribute_index := p_attributes.first;

Loop
  Exit When Not p_attributes.exists(l_attribute_index);
  l_block_app_set := find_corresponding_app_set_id(p_blocks,p_attributes(l_attribute_index).building_block_id);
  if(l_block_app_set <> -1) then
    --
    -- Loop over the mappings, to find those
    -- that correspond to this app attributes request
    -- We can guess this, based on the mapping info
    -- we built when we cached the mappings

    if(p_retrieval_process_id is not null) then
      l_mapping_start := g_retrieval_map(p_retrieval_process_id).start_index;
      l_mapping_stop  := g_retrieval_map(p_retrieval_process_id).stop_index;
    end if;
    if(p_deposit_process_id is not null) then
      l_mapping_start := g_deposit_map(p_deposit_process_id).start_index;
      l_mapping_stop := g_deposit_map(p_deposit_process_id).stop_index;
    end if;
/*
    Loop
      Exit When Not g_mappings.exists(l_mapping_index);
*/

 if (skip_attribute_entry(p_attributes(l_attribute_index)) = FALSE) Then
    For l_mapping_index in l_mapping_start..l_mapping_stop Loop
      if(mapping_applies(p_attributes(l_attribute_index),l_mapping_index,p_retrieval_process_id, p_deposit_process_id,l_block_app_set,p_recipients)) then
         l_app_attribute_index := l_app_attribute_index +1 ;

         l_app_attributes(l_app_attribute_index).time_attribute_id
           := p_attributes(l_attribute_index).time_attribute_id;
         l_app_attributes(l_app_attribute_index).building_block_id
           := p_attributes(l_attribute_index).building_block_id;
         l_app_attributes(l_app_attribute_index).category
           := g_mappings(l_mapping_index).category;
         l_app_attributes(l_app_attribute_index).bld_blk_info_type
           := p_attributes(l_attribute_index).bld_blk_info_type;
         l_app_attributes(l_app_attribute_index).attribute_index
           := l_attribute_index;
         l_app_attributes(l_app_attribute_index).segment
           := g_mappings(l_mapping_index).segment;
         l_app_attributes(l_app_attribute_index).changed
           := p_attributes(l_attribute_index).changed;
         l_app_attributes(l_app_attribute_index).process
           := p_attributes(l_attribute_index).process; --SHIV
         l_app_attributes(l_app_attribute_index).attribute_name
           := g_mappings(l_mapping_index).field_name;

       set_value
         (p_attributes
         ,l_attribute_index
         ,l_mapping_index
         ,l_app_attributes
         ,l_app_attribute_index
         );

      end if;

--      l_mapping_index := g_mappings.next(l_mapping_index);
    End Loop;
  End if;
  end if; -- is this attribute needed
  l_attribute_index := p_attributes.next(l_attribute_index);
End Loop;

return l_app_attributes;

End create_app_attributes;

Procedure update_value
           (p_attributes in out nocopy hxc_attribute_table_type
           ,p_index      in            number
           ,p_segment    in            hxc_mapping_components.segment%type
           ,p_value      in            hxc_time_attributes.attribute1%type
           ) is

Begin

if(p_segment = 'ATTRIBUTE1') then
  p_attributes(p_index).attribute1 := p_value;
elsif(p_segment='ATTRIBUTE2') then
  p_attributes(p_index).ATTRIBUTE2 := p_value;
elsif(p_segment='ATTRIBUTE3') then
  p_attributes(p_index).ATTRIBUTE3 := p_value;
elsif(p_segment='ATTRIBUTE4') then
  p_attributes(p_index).ATTRIBUTE4 := p_value;
elsif(p_segment='ATTRIBUTE5') then
  p_attributes(p_index).ATTRIBUTE5 := p_value;
elsif(p_segment='ATTRIBUTE6') then
  p_attributes(p_index).ATTRIBUTE6 := p_value;
elsif(p_segment='ATTRIBUTE7') then
  p_attributes(p_index).ATTRIBUTE7 := p_value;
elsif(p_segment='ATTRIBUTE8') then
  p_attributes(p_index).ATTRIBUTE8 := p_value;
elsif(p_segment='ATTRIBUTE9') then
  p_attributes(p_index).ATTRIBUTE9 := p_value;
elsif(p_segment='ATTRIBUTE10') then
  p_attributes(p_index).ATTRIBUTE10 := p_value;
elsif(p_segment='ATTRIBUTE11') then
  p_attributes(p_index).ATTRIBUTE11 := p_value;
elsif(p_segment='ATTRIBUTE12') then
  p_attributes(p_index).ATTRIBUTE12 := p_value;
elsif(p_segment='ATTRIBUTE13') then
  p_attributes(p_index).ATTRIBUTE13 := p_value;
elsif(p_segment='ATTRIBUTE14') then
  p_attributes(p_index).ATTRIBUTE14 := p_value;
elsif(p_segment='ATTRIBUTE15') then
  p_attributes(p_index).ATTRIBUTE15 := p_value;
elsif(p_segment='ATTRIBUTE16') then
  p_attributes(p_index).ATTRIBUTE16 := p_value;
elsif(p_segment='ATTRIBUTE17') then
  p_attributes(p_index).ATTRIBUTE17 := p_value;
elsif(p_segment='ATTRIBUTE18') then
  p_attributes(p_index).ATTRIBUTE18 := p_value;
elsif(p_segment='ATTRIBUTE19') then
  p_attributes(p_index).ATTRIBUTE19 := p_value;
elsif(p_segment='ATTRIBUTE20') then
  p_attributes(p_index).ATTRIBUTE20 := p_value;
elsif(p_segment='ATTRIBUTE21') then
  p_attributes(p_index).ATTRIBUTE21 := p_value;
elsif(p_segment='ATTRIBUTE22') then
  p_attributes(p_index).ATTRIBUTE22 := p_value;
elsif(p_segment='ATTRIBUTE23') then
  p_attributes(p_index).ATTRIBUTE23 := p_value;
elsif(p_segment='ATTRIBUTE24') then
  p_attributes(p_index).ATTRIBUTE24 := p_value;
elsif(p_segment='ATTRIBUTE25') then
  p_attributes(p_index).ATTRIBUTE25 := p_value;
elsif(p_segment='ATTRIBUTE26') then
  p_attributes(p_index).ATTRIBUTE26 := p_value;
elsif(p_segment='ATTRIBUTE27') then
  p_attributes(p_index).ATTRIBUTE27 := p_value;
elsif(p_segment='ATTRIBUTE28') then
  p_attributes(p_index).ATTRIBUTE28 := p_value;
elsif(p_segment='ATTRIBUTE29') then
  p_attributes(p_index).ATTRIBUTE29 := p_value;
elsif(p_segment='ATTRIBUTE30') then
  p_attributes(p_index).ATTRIBUTE30 := p_value;
elsif(p_segment='ATTRIBUTE_CATEGORY') then
  p_attributes(p_index).attribute_category :=
  hxc_deposit_wrapper_utilities.get_dupdff_code(p_value);
  --p_attributes(p_index).ATTRIBUTE_CATEGORY := p_value;
end if;

End update_value;

Procedure set_new_attribute_value
           (p_attribute in out nocopy hxc_attribute_type
           ,p_segment   in            hxc_mapping_components.segment%type
           ,p_value     in            hxc_time_attributes.attribute1%type
           ) is

Begin

if(p_segment = 'ATTRIBUTE1') then
  p_attribute.attribute1 := p_value;
elsif(p_segment='ATTRIBUTE2') then
  p_attribute.ATTRIBUTE2 := p_value;
elsif(p_segment='ATTRIBUTE3') then
  p_attribute.ATTRIBUTE3 := p_value;
elsif(p_segment='ATTRIBUTE4') then
  p_attribute.ATTRIBUTE4 := p_value;
elsif(p_segment='ATTRIBUTE5') then
  p_attribute.ATTRIBUTE5 := p_value;
elsif(p_segment='ATTRIBUTE6') then
  p_attribute.ATTRIBUTE6 := p_value;
elsif(p_segment='ATTRIBUTE7') then
  p_attribute.ATTRIBUTE7 := p_value;
elsif(p_segment='ATTRIBUTE8') then
  p_attribute.ATTRIBUTE8 := p_value;
elsif(p_segment='ATTRIBUTE9') then
  p_attribute.ATTRIBUTE9 := p_value;
elsif(p_segment='ATTRIBUTE10') then
  p_attribute.ATTRIBUTE10 := p_value;
elsif(p_segment='ATTRIBUTE11') then
  p_attribute.ATTRIBUTE11 := p_value;
elsif(p_segment='ATTRIBUTE12') then
  p_attribute.ATTRIBUTE12 := p_value;
elsif(p_segment='ATTRIBUTE13') then
  p_attribute.ATTRIBUTE13 := p_value;
elsif(p_segment='ATTRIBUTE14') then
  p_attribute.ATTRIBUTE14 := p_value;
elsif(p_segment='ATTRIBUTE15') then
  p_attribute.ATTRIBUTE15 := p_value;
elsif(p_segment='ATTRIBUTE16') then
  p_attribute.ATTRIBUTE16 := p_value;
elsif(p_segment='ATTRIBUTE17') then
  p_attribute.ATTRIBUTE17 := p_value;
elsif(p_segment='ATTRIBUTE18') then
  p_attribute.ATTRIBUTE18 := p_value;
elsif(p_segment='ATTRIBUTE19') then
  p_attribute.ATTRIBUTE19 := p_value;
elsif(p_segment='ATTRIBUTE20') then
  p_attribute.ATTRIBUTE20 := p_value;
elsif(p_segment='ATTRIBUTE21') then
  p_attribute.ATTRIBUTE21 := p_value;
elsif(p_segment='ATTRIBUTE22') then
  p_attribute.ATTRIBUTE22 := p_value;
elsif(p_segment='ATTRIBUTE23') then
  p_attribute.ATTRIBUTE23 := p_value;
elsif(p_segment='ATTRIBUTE24') then
  p_attribute.ATTRIBUTE24 := p_value;
elsif(p_segment='ATTRIBUTE25') then
  p_attribute.ATTRIBUTE25 := p_value;
elsif(p_segment='ATTRIBUTE26') then
  p_attribute.ATTRIBUTE26 := p_value;
elsif(p_segment='ATTRIBUTE27') then
  p_attribute.ATTRIBUTE27 := p_value;
elsif(p_segment='ATTRIBUTE28') then
  p_attribute.ATTRIBUTE28 := p_value;
elsif(p_segment='ATTRIBUTE29') then
  p_attribute.ATTRIBUTE29 := p_value;
elsif(p_segment='ATTRIBUTE30') then
  p_attribute.ATTRIBUTE30 := p_value;
elsif(p_segment='ATTRIBUTE_CATEGORY') then
  p_attribute.attribute_category :=
     hxc_deposit_wrapper_utilities.get_dupdff_code(p_value);
--  p_attribute.ATTRIBUTE_CATEGORY := p_value;
end if;

End set_new_attribute_value;

Procedure create_new_attribute
           (p_attributes     in out nocopy hxc_attribute_table_type
           ,p_app_attributes in out nocopy hxc_self_service_time_deposit.app_attributes_info
           ,p_app_index      in            number
           ) is

l_new_time_attribute_id number;
l_new_attribute         hxc_attribute_type;
l_index                 number;
l_attribute_category    hxc_bld_blk_info_types.bld_blk_info_type%type;

Begin

if(instr(p_app_attributes(p_app_index).bld_blk_info_type,'Dummy')<1) then
  l_attribute_category := substr(p_app_attributes(p_app_index).bld_blk_info_type,1,30);
else
  l_attribute_category := null;
end if;

l_new_time_attribute_id := hxc_timecard_attribute_utils.next_time_attribute_id(p_attributes);

l_new_attribute := hxc_attribute_type
                    (l_new_time_attribute_id
                    ,p_app_attributes(p_app_index).building_block_id
                    ,l_attribute_category
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
                    ,null
                    ,null
                    ,null
                    ,null
                    ,null
                    ,null
                    ,hxc_timecard_attribute_utils.get_bld_blk_info_type_id
                      (p_app_attributes(p_app_index).bld_blk_info_type)
                    ,1
                    ,'Y'
                    ,'N'
                    ,p_app_attributes(p_app_index).bld_blk_info_type
                    ,'Y'
                    ,null
                    );

l_index := p_app_attributes.first;
Loop
  Exit when not p_app_attributes.exists(l_index);
  if(
     (p_app_attributes(l_index).bld_blk_info_type = p_app_attributes(p_app_index).bld_blk_info_type)
    AND
     (p_app_attributes(l_index).time_attribute_id = p_app_attributes(p_app_index).time_attribute_id)
    ) then
    set_new_attribute_value
      (l_new_attribute
      ,p_app_attributes(l_index).segment
      ,p_app_attributes(l_index).attribute_value
      );
    p_app_attributes(l_index).updated := 'Y';
    p_app_attributes(l_index).process := 'Y'; --SHIV
  end if;
  l_index := p_app_attributes.next(l_index);
End Loop;

p_attributes.extend();

p_attributes(p_attributes.last) := l_new_attribute;

End create_new_attribute;

Procedure update_attributes
           (p_attributes     in out nocopy hxc_attribute_table_type
           ,p_app_attributes in out nocopy hxc_self_service_time_deposit.app_attributes_info
           ) is

l_index number;

Begin

l_index := p_app_attributes.first;
Loop
  Exit when not p_app_attributes.exists(l_index);
  if (NVL(p_app_attributes(l_index).updated,'N') = 'N') then
    if (p_app_attributes(l_index).attribute_index is not null) then
      update_value
        (p_attributes => p_attributes
        ,p_index      => p_app_attributes(l_index).attribute_index
        ,p_segment    => p_app_attributes(l_index).segment
        ,p_value      => p_app_attributes(l_index).attribute_value
        );
    else
      create_new_attribute
        (p_attributes     => p_attributes
        ,p_app_attributes => p_app_attributes
        ,p_app_index      => l_index
        );
    end if;
    p_app_attributes(l_index).updated := 'Y';
    p_app_attributes(l_index).process := 'Y'; --SHIV
  end if;
  l_index := p_app_attributes.next(l_index);
End Loop;

End update_attributes;

end hxc_app_attribute_utils;

/
