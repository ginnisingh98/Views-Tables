--------------------------------------------------------
--  DDL for Package Body HXC_CREATE_FLEX_MAPPINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_CREATE_FLEX_MAPPINGS" AS
/* $Header: hxcflxdn.pkb 120.6.12010000.6 2009/08/20 12:19:30 sabvenug ship $ */
--
-- Global store for the number of global data elements
--
g_debug boolean := hr_utility.debug_enabled;
g_global_segment_count NUMBER := 0;

FUNCTION check_delete_info_type(p_info_type_basis VARCHAR2)
          return NUMBER is

cursor c_delete(p_info_type_basis in VARCHAR2) is
  select bbi.bld_blk_info_type_id
    from hxc_mapping_comp_usages mcu,
         hxc_mapping_components mc,
         hxc_bld_blk_info_types bbi
   where mcu.mapping_component_id = mc.mapping_component_id
     and mc.bld_blk_info_type_id = bbi.bld_blk_info_type_id
     and upper(bld_blk_info_type) like '%'||p_info_type_basis||'%';

l_bld_blk_info_type_id HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE_ID%TYPE;

BEGIN

  open c_delete(p_info_type_basis);
  fetch c_delete into l_bld_blk_info_type_id;

  if c_delete%NOTFOUND then
     l_bld_blk_info_type_id := NULL;
  end if;

  close c_delete;

RETURN l_bld_blk_info_type_id;

END check_delete_info_type;

FUNCTION valid_to_add_map
          (p_map_id in HXC_MAPPING_COMPONENTS.MAPPING_COMPONENT_ID%TYPE
          ,p_process_map in HXC_DEPOSIT_PROCESSES.NAME%TYPE) RETURN BOOLEAN is

cursor field_already_mapped(p_id in number,p_name in varchar2) is
  SELECT 'Y'
    from hxc_mapping_comp_usages u,
         hxc_mappings m
   where m.name = p_name
     and u.mapping_id = m.mapping_id
     and u.mapping_component_id in
         (select c2.mapping_component_id
            from hxc_mapping_components c1,
                 hxc_mapping_components c2
           where c1.mapping_component_id = p_id
             and c2.segment = c1.segment
             and c2.field_name = c1.field_name
             and c2.bld_blk_info_type_id = c1.bld_blk_info_type_id
             and c2.mapping_component_id <> c1.mapping_component_id);

cursor field_name_already
         (p_id in number
         ,p_name in varchar2) is
  select 'Y'
    from hxc_mappings m, hxc_mapping_comp_usages u, hxc_mapping_components c
   where m.mapping_id = u.mapping_id
     and m.name = p_name
     and u.mapping_component_id = c.mapping_component_id
     and c.field_name =
           (select field_name
              from hxc_mapping_components c1
             where c1.mapping_component_id = p_id);

l_valid BOOLEAN := FALSE;
l_dummy VARCHAR2(2);

BEGIN

open field_name_already(p_map_id, p_process_map);
fetch field_name_already into l_dummy;

IF (field_name_already%FOUND) then
   l_valid := FALSE;
else
   l_valid := TRUE;
end if;

close field_name_already;

if(l_valid) then

  open field_already_mapped(p_map_id, p_process_map);
  fetch field_already_mapped into l_dummy;

  if (field_already_mapped%FOUND) then
     l_valid := FALSE;
  else
     l_valid := TRUE;
  end if;

  close field_already_mapped;

end if;

return l_valid;

END valid_to_add_map;

PROCEDURE add_comp_to_proc
           (p_map_id in NUMBER
           ,p_process_name in VARCHAR2) is

cursor c_mapping_id(p_mapping_process_name in VARCHAR2) is
  select mapping_id
    from hxc_mappings m
   where m.name = p_mapping_process_name;

l_mapping_id HXC_MAPPINGS.MAPPING_ID%TYPE;
l_map_comp_usage_id NUMBER;
l_map_comp_ovn NUMBER;

BEGIN

-- Obtain the mapping id and call the
-- mapping component usage API to
-- insert the record.

open c_mapping_id(p_process_name);
fetch c_mapping_id into l_mapping_id;

if (c_mapping_id%FOUND) then

  hxc_mapping_comp_usage_api.create_mapping_comp_usage
    (FALSE
    ,l_map_comp_usage_id
    ,l_map_comp_ovn
    ,l_mapping_id
    ,p_map_id
    );

end if;

close c_mapping_id;

END add_comp_to_proc;

PROCEDURE include_mapping_components
            (p_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE)
  IS


cursor c_map_comp(
        p_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE
    ) is
   select mc.mapping_component_id
     from hxc_mapping_components mc,

          hxc_bld_blk_info_types bbit
    where upper(bbit.bld_blk_info_type) like '%'||upper(p_info_type_basis)||'%'
      and bbit.bld_blk_info_type_id = mc.bld_blk_info_type_id;


BEGIN

for map_rec in c_map_comp(p_info_type_basis) LOOP

  -- Check to see if the mapping exists in the OTL Deposit Process

  if(valid_to_add_map(map_rec.mapping_component_id
                     ,'Projects Retrieval Process Mapping')) then

    --Ok, we can add it to the process mapping.

    add_comp_to_proc
      (map_rec.mapping_component_id
      ,'Projects Retrieval Process Mapping'
      );

  end if;

  if(valid_to_add_map(map_rec.mapping_component_id
                     ,'OTL Deposit Process Mapping')) then

    add_comp_to_proc
      (map_rec.mapping_component_id
      ,'OTL Deposit Process Mapping'
      );

  end if;

END LOOP;

END include_mapping_components;

PROCEDURE remove_mapping_component(
           p_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE)
  IS

cursor c_map_comp(
        p_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE
    ) is
   select mc.mapping_component_id
     from hxc_mapping_components mc,
          hxc_bld_blk_info_types bbit
    where upper(bbit.bld_blk_info_type) like '%'||upper(p_info_type_basis)||'%'
      and bbit.bld_blk_info_type_id = mc.bld_blk_info_type_id;

BEGIN

  if(p_info_type_basis = 'PAEXPITDFF') then

    --
    -- for PA only remove the DFF based columns from the mapping
    -- component usages.
    --

    for map_rec in c_map_comp(p_info_type_basis) LOOP

      DELETE from hxc_mapping_comp_usages
       where mapping_component_id = map_rec.mapping_component_id;

    end LOOP;

  end if;

  for map_rec in c_map_comp(p_info_type_basis) LOOP

    DELETE from HXC_MAPPING_COMPONENTS
     where mapping_component_id = map_rec.mapping_component_id;

  END LOOP;

END remove_mapping_component;

PROCEDURE remove_bld_blk_usage(
           p_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE)
  IS

cursor c_bld_blk_usage(
        p_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE
    ) is
   select bbu.bld_blk_info_type_usage_id
     from hxc_bld_blk_info_type_usages bbu,
          hxc_bld_blk_info_types bbit
    where upper(bbit.bld_blk_info_type) like '%'||upper(p_info_type_basis)||'%'
      and bbit.bld_blk_info_type_id = bbu.bld_blk_info_type_id;

BEGIN

  for usage_rec in c_bld_blk_usage(p_info_type_basis) LOOP

    DELETE from HXC_BLD_BLK_INFO_TYPE_USAGES
     where bld_blk_info_type_usage_id = usage_rec.bld_blk_info_type_usage_id;

  END LOOP;

END remove_bld_blk_usage;

PROCEDURE remove_flex_context(
           p_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE,
           p_flexfield_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE,
           p_flex_context_basis in VARCHAR2) IS

  cursor c_flex(
   p_flex_context_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE
    ) is
   select bld_blk_info_type
     from hxc_bld_blk_info_types
    where upper(bld_blk_info_Type) like '%'||upper(p_flex_context_basis)||'%';

BEGIN

 for context_rec in c_flex(p_flex_context_basis) LOOP

  if FND_FLEX_DSC_API.context_exists(
           P_APPL_SHORT_NAME => p_appl_short_name,
           P_FLEXFIELD_NAME => p_flexfield_name,
           P_CONTEXT_CODE => context_rec.bld_blk_info_type
        ) then


       FND_FLEX_DSC_API.delete_context(
           APPL_SHORT_NAME => p_appl_short_name,
           FLEXFIELD_NAME => p_flexfield_name,
           CONTEXT => context_rec.bld_blk_info_type);

  end if; -- Does this element context exist?

 END LOOP;

END remove_flex_context;

PROCEDURE remove_bld_blk_info_type(
    p_bld_blk_info_type_basis in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE
      ) is

BEGIN

  DELETE from HXC_BLD_BLK_INFO_TYPES
   where upper(bld_blk_info_type) like '%'||upper(p_bld_blk_info_type_basis)||'%';

END remove_bld_blk_info_type;

PROCEDURE create_preference_definitions(
            p_flex_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE
           ,p_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE) is


cursor c_flex_context_name(
          p_flex_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE
         ,p_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE
         ) is
        select c.descriptive_flex_context_code, c.descriptive_flex_context_name
          from fnd_descr_flex_contexts_vl c,
               fnd_application a
         where c.descriptive_flexfield_name = p_flex_name
           and a.application_short_name = p_appl_short_name
           and a.application_id = c.application_id
           and c.descriptive_flex_context_code <> 'Global Data Elements';

BEGIN

--
-- Check the preference definition for each context
--

for context_rec in c_flex_context_name(p_flex_name, p_appl_short_name) LOOP

  insert into hxc_pref_definitions
  (PREF_DEFINITION_ID,
   CODE,
   DESCRIPTIVE_FLEXFIELD_NAME)
  select
   hxc_pref_definitions_s.nextval,
   context_rec.descriptive_flex_context_code,
   p_flex_name
  from dual
  where not exists(
    select 'Y'
      from hxc_pref_definitions
     where code = context_rec.descriptive_flex_context_code
       and descriptive_flexfield_name = p_flex_name);

END LOOP;


END create_preference_definitions;

/*
Added for 8645021 HR OTL Absence Integration

This procedure is called in undo part of GFMP, in which all absence info is removed
from hxc_absence_type_elements table
*/

--Change start
PROCEDURE REMOVE_HXC_ABS_ELEM_INFO(p_error_msg	OUT  NOCOPY VARCHAR2,
				   p_element_type_id	IN	hxc_absence_type_elements.element_type_id%type)
IS

CURSOR chk_abs_elem_exists(p_element_type_id	   IN	NUMBER)

IS
SELECT
   	1
FROM
 	hxc_absence_type_elements
WHERE
	element_type_id = p_element_type_id;


x_var 	NUMBER(1):=0;

BEGIN

/*
The logic would be to first delete the records with the
present element type ids and then insert it.
*/

if g_debug then
hr_utility.trace('Entered REMOVE_HXC_ABS_ELEM_INFO');
end if;


IF p_element_type_id is not null and g_abs_incl_flag = 'Y' THEN

 	OPEN chk_abs_elem_exists(p_element_type_id);

 	FETCH chk_abs_elem_exists into x_var;

 	CLOSE chk_abs_elem_exists;

 	IF x_var = 1 THEN

 		delete from hxc_absence_type_elements -- hxc_absence_type_elements
 		      where element_type_id=p_element_type_id;

 		if g_debug then

 		hr_utility.trace('REMOVE_HXC_ABS_ELEM_INFO for element ='||p_element_type_id);

 		end if;

 		--commit;

 	END IF;

END IF; --p_element_type_id and g_abs_incl_flag

p_error_msg := null;

if g_debug then
hr_utility.trace('Leaving REMOVE_HXC_ABS_ELEM_INFO');
end if;



END; -- REMOVE_HXC_ABS_ELEM_INFO


--Change end





PROCEDURE undo(
 p_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE
,p_flexfield_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE
,p_element_set_id in PAY_ELEMENT_SETS.ELEMENT_SET_ID%TYPE
,p_effective_date in DATE
,p_include_cost in VARCHAR2
,p_include_group in VARCHAR2
,p_include_job in VARCHAR2
,p_include_pos in VARCHAR2
,p_include_prj in VARCHAR2) is
-- 115.24 Change
cursor c_elements(p_element_set_id in number, p_effective_date in date) is
  select pet.element_type_id
    from pay_element_types_f pet,
         pay_element_type_rules per
   where per.element_set_id = p_element_set_id
     and per.include_or_exclude = 'I'
     and per.element_type_id = pet.element_type_id
     and multiple_entries_allowed_flag = 'Y'
     and p_effective_date between effective_start_date and effective_end_date;
-- End 115.24 Change
l_bld_blk_info_type_id HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE_ID%TYPE;

l_generate BOOLEAN default FALSE;
l_loop_var NUMBER default 0;
l_key_app VARCHAR2(30) := 'PAY';
l_key_flex_code VARCHAR2(30) := 'COST';

l_flex FND_DFLEX.dflex_r;
l_flex_info FND_DFLEX.dflex_dr;

l_basis_string fnd_descr_flex_contexts.descriptive_flex_context_code%type;

/*
Added for 8645021 HR OTL Absence Integration
*/

--change start
p_err_msg	VARCHAR2(1000);
--change end

BEGIN

--
-- The undo procedure will be called when the user wishes to remove
-- the mappings.
--

if p_element_set_id is not null then
-- 115.24 Change
 for ele_rec in c_elements(p_element_set_id,p_effective_date) LOOP

    l_basis_string := 'ELEMENT - '||ele_rec.element_type_id;

    l_bld_blk_info_type_id := check_delete_info_type(l_basis_string);

    if l_bld_blk_info_type_id is null then
       remove_mapping_component(l_basis_string);
       remove_bld_blk_usage(l_basis_string);
       remove_flex_context(
          p_appl_short_name => p_appl_short_name,
          p_flexfield_name => p_flexfield_name,
          p_flex_context_basis => l_basis_string);
       remove_bld_blk_info_type(l_basis_string);

       /*
       Added for 8645021 HR OTL Absence Integration

       Call to delete any existing absence info in hxc_absence_type_elements
       */
       -- change start

       remove_hxc_abs_elem_info(p_err_msg,ele_rec.element_type_id);

       --change end


    end if;

 end loop;
-- End 115.24 Change
end if;

FOR l_loop_var in 1..4 LOOP

  l_generate := FALSE;

if ((l_loop_var=1) AND (p_include_cost = 'Y')) then
    l_key_app := 'PAY';
    l_key_flex_code := 'COST';
    l_generate := TRUE;
elsif ((l_loop_var=2) AND (p_include_group = 'Y')) then
    l_key_flex_code := 'GRP';
    l_generate := TRUE;
elsif ((l_loop_var=3) AND (p_include_job = 'Y')) then
    l_key_app := 'PER';
    l_key_flex_code := 'JOB';
    l_generate := TRUE;
elsif ((l_loop_var=4) AND (p_include_pos = 'Y')) then
    l_key_flex_code := 'POS';
    l_generate := TRUE;
end if;

if l_generate then

    l_bld_blk_info_type_id := check_delete_info_type(l_key_flex_code);

    if l_bld_blk_info_type_id is null then
       remove_mapping_component(l_key_flex_code);
       remove_bld_blk_usage(l_key_flex_code);
       remove_flex_context(
          p_appl_short_name => p_appl_short_name,
          p_flexfield_name => p_flexfield_name,
          p_flex_context_basis => l_key_flex_code);
       remove_bld_blk_info_type(l_key_flex_code);
    end if;

end if; -- are we including this key flex

if p_include_prj = 'Y' then

--    l_bld_blk_info_type_id := check_delete_info_type('PAEXPITDFF');
    l_bld_blk_info_type_id := null;

    if l_bld_blk_info_type_id is null then
       remove_mapping_component('PAEXPITDFF');
       remove_bld_blk_usage('PAEXPITDFF');
       remove_flex_context(
          p_appl_short_name => p_appl_short_name,
          p_flexfield_name => p_flexfield_name,
          p_flex_context_basis => 'PAEXPITDFF');
       remove_bld_blk_info_type('PAEXPITDFF');
    else
      FND_MESSAGE.set_name('HXC','HXC_COMPONENTS_MAPPED');
      FND_MESSAGE.raise_error;
    end if;

end if;  -- remove the projects definition?

END LOOP;


END undo;

/*
  Private functions to find value sets, and generate mappings, building
  block information types etc.
*/

  FUNCTION find_value_set(l_vid in FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE)
    RETURN VARCHAR2 is

   l_value_set_name FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%type := NULL;

   l_value_set FND_VSET.VALUESET_R;
   l_value_set_format FND_VSET.VALUESET_DR;

  BEGIN

  if l_vid is not null then
   FND_VSET.GET_VALUESET(
              valueset_id => l_vid,
              valueset => l_value_set,
              format => l_value_set_format);
   l_value_set_name := l_value_set.name;

  end if;

  RETURN l_value_set_name;

  END find_value_set;

  function get_name_prefix
             (p_flex_code in varchar2
             ,p_flex_num in number) return varchar2 is

  l_prefix varchar2(21);

  begin

  select substr(id_flex_structure_code,1,20) into l_prefix
    from fnd_id_flex_structures
   where id_flex_code = p_flex_code
     and id_flex_num = p_flex_num;

  return l_prefix;

  end get_name_prefix;

  FUNCTION valid_segment_name(
                p_name in VARCHAR2
               ,p_flex_code in varchar2
               ,p_flex_num in varchar2
                 ) return VARCHAR2 is

  cursor c_dup_name
           (p_seg_name in varchar2
           ,p_id_flex_code in varchar2
           ,p_id_flex_num in number
           ,p_application_id in number
           ) is
  select 'Y'
    from fnd_id_flex_segments
   where id_flex_code = p_id_flex_code
     and id_flex_num = p_id_flex_num
     and segment_name = p_seg_name
     and application_id = p_application_id;

  l_valid_name FND_DESCR_FLEX_COLUMN_USAGES.END_USER_COLUMN_NAME%TYPE;

  l_dummy varchar2(5);

  BEGIN

  if upper(p_name) = 'GROUP' then

    l_valid_name := 'People Group';

    -- Check for duplicates

    open c_dup_name(l_valid_name,p_flex_code,p_flex_num,801);
    fetch c_dup_name into l_dummy;

    if c_dup_name%NOTFOUND then
      close c_dup_name;
    else
      close c_dup_name;
      -- we have to try again with the name.
      l_valid_name := 'HXC Group';
      open c_dup_name(l_valid_name,p_flex_code,p_flex_num,801);
      fetch c_dup_name into l_dummy;

      if c_dup_name%NOTFOUND then
        close c_dup_name;
      else
        close c_dup_name;
        -- we have to try again with the name.
        l_valid_name := get_name_prefix(p_flex_code,p_flex_num)||' Group';
        open c_dup_name(l_valid_name,p_flex_code,p_flex_num,801);
        fetch c_dup_name into l_dummy;

        if c_dup_name%NOTFOUND then
          close c_dup_name;
        else
          close c_dup_name;
          -- we can't generate a name - throw an error
          FND_MESSAGE.SET_NAME('HXC','HXC_UNABLE_TO_NAME_SEGMENT');
          FND_MESSAGE.SET_TOKEN('SEGMENT_NAME',p_name);
          FND_MESSAGE.SET_TOKEN('STRUCTURE_NUMBER',p_flex_num);
        end if;
      end if;
    end if;

  else
       l_valid_name := p_name;
  end if;

  return l_valid_name;

  END valid_segment_name;

  FUNCTION mapping_missing(
                p_name in hxc_mapping_components.name%type,
                p_field_name in hxc_mapping_components.field_name%type,
                p_bld_blk_info_type_id in hxc_bld_blk_info_types.bld_blk_info_type_id%type,
                p_segment in hxc_mapping_components.segment%type,
                p_mp_id IN OUT NOCOPY NUMBER,
                p_ovn IN OUT NOCOPY NUMBER ) RETURN BOOLEAN IS


  BEGIN

   select mapping_component_id,
	  object_version_number
     into p_mp_id,
	  p_ovn
     from hxc_mapping_components
    where field_name = p_field_name
      and name = p_name
      and segment = p_segment;

  RETURN FALSE;

  EXCEPTION
     WHEN NO_DATA_FOUND then
       RETURN TRUE;

  END;

  FUNCTION update_allowed
            (p_map_comp_id in HXC_MAPPING_COMPONENTS.MAPPING_COMPONENT_ID%TYPE) RETURN BOOLEAN is

  l_dummy VARCHAR2(2);

  BEGIN

   -- Just check to see if this mapping component is used
   -- note it can be used more than once, hence the rownum
   -- in the where clause.

   select 'Y'
     into l_dummy
    from hxc_mapping_comp_usages
   where mapping_component_id = p_map_comp_id
     and rownum =1;

   return false;

  EXCEPTION
     when no_data_found then
       return true;

  END update_allowed;

  PROCEDURE create_mapping(
                p_name in hxc_mapping_components.name%type,
                p_field_name in hxc_mapping_components.field_name%type,
                p_bld_blk_info_type_id in hxc_bld_blk_info_types.bld_blk_info_type_id%type,
                p_segment in hxc_mapping_components.segment%type) is

    l_mapping_component_id NUMBER;
    l_ovn NUMBER;

  BEGIN

if mapping_missing(
           p_name => p_name,
           p_field_name => p_field_name,
           p_bld_blk_info_type_id => p_bld_blk_info_type_id,
           p_segment => p_segment,
	   p_mp_id => l_mapping_component_id,
           p_ovn => l_ovn ) then
      hxc_mapping_component_api.create_mapping_component(
            p_validate => FALSE,
            p_mapping_component_id => l_mapping_component_id,
            p_object_version_number => l_ovn,
            p_name => p_name,
            p_field_name => p_field_name,
            p_bld_blk_info_type_id => p_bld_blk_info_type_id,
            p_segment => p_segment);

  elsif (update_allowed(l_mapping_component_id)) then
      hxc_mapping_component_api.update_mapping_component(
            p_validate => FALSE,
            p_mapping_component_id => l_mapping_component_id,
            p_object_version_number => l_ovn,
            p_name => p_name,
            p_field_name => p_field_name,
            p_bld_blk_info_type_id => p_bld_blk_info_type_id,
            p_segment => p_segment);

   end if;

  END create_mapping;

  FUNCTION create_bld_blk_info_type(
       p_appl_short_name in VARCHAR2
      ,p_flexfield_name in VARCHAR2
      ,p_legislation_code in hxc_bld_blk_info_types.legislation_code%type
      ,p_bld_blk_info_type in hxc_bld_blk_info_types.bld_blk_info_type%type
      ,p_category hxc_bld_blk_info_type_usages.building_block_category%type
            ) RETURN NUMBER is

  cursor c_info_type_id (p_info_type in hxc_bld_blk_info_types.bld_blk_info_type%type) is
   select bld_blk_info_type_id
     from HXC_BLD_BLK_INFO_TYPES
    where bld_blk_info_type = p_info_type;

   l_bld_blk_info_type_id NUMBER;

  BEGIN
--
-- Try to obtain the building block info type id
--
   OPEN c_info_type_id(p_info_type => p_bld_blk_info_type);
   FETCH c_info_type_id into l_bld_blk_info_type_id;


--
-- Create or Delete the information type record
--

  if c_info_type_id%NOTFOUND then

   insert into HXC_BLD_BLK_INFO_TYPES(
            bld_blk_info_type_id,
            legislation_code,
            descriptive_flexfield_name,
            bld_blk_info_type,
            multiple_occurences_flag,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number)
   select
            HXC_BLD_BLK_INFO_TYPES_S.NEXTVAL,
            p_legislation_code,
            p_flexfield_name,
            p_bld_blk_info_type,
            'N',
            0,
            sysdate,
            0,
            sysdate,
            0,
            1
   from     sys.dual;

  end if;

  close c_info_type_id;

--
-- Find the bld_blk_type_id for this information type
--
    OPEN c_info_type_id(p_bld_blk_info_type);
    FETCH c_info_type_id into l_bld_blk_info_type_id;
    CLOSE c_info_type_id;

--
-- Create the information type category usage record
--
   insert into HXC_BLD_BLK_INFO_TYPE_USAGES(
            bld_blk_info_type_usage_id,
            building_block_category,
            bld_blk_info_type_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number)
   select
            hxc_bld_blk_info_type_usages_s.nextval,
            p_category,
            l_bld_blk_info_type_id,
            0,
            sysdate,
            0,
            sysdate,
            0,
            1
   from     sys.dual
   where not exists(
            select 'Y'
              from hxc_bld_blk_info_type_usages
             where bld_blk_info_type_id = l_bld_blk_info_type_id);

  RETURN l_bld_blk_info_type_id;

  END create_bld_blk_info_type;

  PROCEDURE create_missing_type_usages(
       p_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE
      ,p_flex_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE
     ) IS

   cursor c_missing(
       p_flex_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE
            )is
      select fdfc.DESCRIPTIVE_FLEX_CONTEXT_CODE
        from fnd_descr_flex_contexts fdfc
       where descriptive_flexfield_name = p_flex_name
         and fdfc.descriptive_flex_context_code <> 'Global Data Elements'
         and not exists (
              select 'Y'
                from hxc_bld_blk_info_types bbi
               where bbi.bld_blk_info_type = fdfc.descriptive_flex_context_code
                 );
   l_dummy_info_type_id NUMBER;

  BEGIN

     for miss_rec in c_missing(p_flex_name) LOOP

       l_dummy_info_type_id := create_bld_blk_info_type(
            p_appl_short_name => p_appl_short_name
           ,p_flexfield_name => p_flex_name
           ,p_legislation_code => NULL
           ,p_bld_blk_info_type => miss_rec.descriptive_flex_context_code
           ,p_category => miss_rec.descriptive_flex_context_code);

     END LOOP;


  END create_missing_type_usages;

  PROCEDURE create_dummy_context(
               p_appl_short_name in VARCHAR2,
               p_flexfield_name in VARCHAR2,
               p_context_name in VARCHAR2,
               p_segment_name_prefix in VARCHAR2,
               p_max_segments in NUMBER
                   ) IS

    l_building_block_info_id NUMBER;

    l_segment_name_prefix VARCHAR2(50);
    l_sequence_number NUMBER;
    l_map_comp_name VARCHAR2(50);
    l_map_comp_field_name VARCHAR2(50);

  BEGIN

  --
  -- Create the dummy context
  --


  if FND_FLEX_DSC_API.context_exists(
           P_APPL_SHORT_NAME => p_appl_short_name,
           P_FLEXFIELD_NAME => p_flexfield_name,
           P_CONTEXT_CODE => 'Dummy '||initcap(p_context_name)||' Context'
        ) then
       FND_FLEX_DSC_API.delete_context(
           APPL_SHORT_NAME => p_appl_short_name,
           FLEXFIELD_NAME => p_flexfield_name,
           CONTEXT => 'Dummy '||initcap(p_context_name)||' Context');

  end if; -- Does this element context exist?

    FND_FLEX_DSC_API.create_context(
      APPL_SHORT_NAME => p_appl_short_name,
      FLEXFIELD_NAME => p_flexfield_name,
      CONTEXT_CODE => 'Dummy '||initcap(p_context_name)||' Context',
      CONTEXT_NAME => 'Dummy '||initcap(p_context_name)||' Context',
      DESCRIPTION => 'Auto generated HXC context',
      ENABLED => 'Y',
      GLOBAL_FLAG => 'N');



  --
  -- Next create the dummy information type
  --
    l_building_block_info_id := create_bld_blk_info_type(
            p_appl_short_name => p_appl_short_name,
            p_flexfield_name => p_flexfield_name,
            p_legislation_code => NULL,
            p_bld_blk_info_type => 'Dummy '||initcap(p_context_name)||' Context',
            p_category => p_context_name);
  --
  -- Now create the dummy mappings
  --
     create_mapping(
                p_name =>'Dummy '||initcap(p_context_name)||' Context',
                p_field_name => 'Dummy '||initcap(p_context_name)||' Context',
                p_bld_blk_info_type_id => l_building_block_info_id,
                p_segment => 'ATTRIBUTE_CATEGORY');

   --
   -- Now create all the dummy segments
   --

   for i in 1..p_max_segments LOOP

    FND_FLEX_DSC_API.create_segment(
      APPL_SHORT_NAME => p_appl_short_name,
      FLEXFIELD_NAME => p_flexfield_name,
      CONTEXT_NAME => 'Dummy '||initcap(p_context_name)||' Context',
      NAME => p_segment_name_prefix||to_char(i),
      COLUMN => 'ATTRIBUTE'||to_char(i),
      DESCRIPTION => 'Auto generated HXC context segment',
      SEQUENCE_NUMBER => i,
      ENABLED => 'N',
      DISPLAYED => 'N',
      VALUE_SET => NULL,
      DEFAULT_TYPE => NULL,
      DEFAULT_VALUE => NULL,
      REQUIRED => 'N',
      SECURITY_ENABLED => 'N',
      DISPLAY_SIZE => 30,
      DESCRIPTION_SIZE => 50,
      CONCATENATED_DESCRIPTION_SIZE => 10,
      LIST_OF_VALUES_PROMPT => p_segment_name_prefix||to_char(i),
      WINDOW_PROMPT => p_segment_name_prefix||to_char(i),
      RANGE => NULL,
      SRW_PARAMETER => NULL);

  --
  -- Now create the dummy mappings
  --
     create_mapping(
                p_name =>p_segment_name_prefix||to_char(i),
                p_field_name => p_segment_name_prefix||to_char(i),
                p_bld_blk_info_type_id => l_building_block_info_id,
                p_segment => 'ATTRIBUTE'||to_char(i));

   END LOOP;

   IF(p_context_name = 'ELEMENT') THEN
	FOR i in 1..4 LOOP

		IF (i=1) THEN
		    l_segment_name_prefix := 'NAStateName';
		    l_sequence_number := 27;
		    l_map_comp_field_name := 'NA_STATE_NAME';
		    l_map_comp_name := 'NA State Name';
		ELSIF (i=2) THEN
		    l_segment_name_prefix := 'NACountyName';
		    l_sequence_number := 28;
		    l_map_comp_field_name := 'NA_COUNTY_NAME';
		    l_map_comp_name := 'NA County Name';
		ELSIF (i=3) THEN
		    l_segment_name_prefix := 'NACityName';
		    l_sequence_number := 29;
		    l_map_comp_field_name := 'NA_CITY_NAME';
		    l_map_comp_name := 'NA City Name';
		ELSIF (i=4) THEN
		    l_segment_name_prefix := 'NAZipCode';
		    l_sequence_number := 30;
		    l_map_comp_field_name := 'NA_ZIP_CODE';
		    l_map_comp_name := 'NA Zip Code';
		END IF;

	FND_FLEX_DSC_API.create_segment(
	      APPL_SHORT_NAME => p_appl_short_name,
	      FLEXFIELD_NAME => p_flexfield_name,
	      CONTEXT_NAME => 'Dummy '||initcap(p_context_name)||' Context',
	      NAME => l_segment_name_prefix,
	      COLUMN => 'ATTRIBUTE'||to_char(l_sequence_number),
	      DESCRIPTION => 'Auto generated HXC context segment',
	      SEQUENCE_NUMBER => l_sequence_number,
	      ENABLED => 'N',
	      DISPLAYED => 'N',
	      VALUE_SET => NULL,
	      DEFAULT_TYPE => NULL,
	      DEFAULT_VALUE => NULL,
	      REQUIRED => 'N',
	      SECURITY_ENABLED => 'N',
	      DISPLAY_SIZE => 30,
	      DESCRIPTION_SIZE => 50,
	      CONCATENATED_DESCRIPTION_SIZE => 10,
	      LIST_OF_VALUES_PROMPT => l_segment_name_prefix,
	      WINDOW_PROMPT => l_segment_name_prefix,
	      RANGE => NULL,
	      SRW_PARAMETER => NULL);

	create_mapping(
                p_name =>l_map_comp_name,
                p_field_name => l_map_comp_field_name,
                p_bld_blk_info_type_id => l_building_block_info_id,
                p_segment => 'ATTRIBUTE'||to_char(l_sequence_number));

	  END LOOP;
    END IF;
  END create_dummy_context;


 PROCEDURE create_segments(
     p_otc_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE
    ,p_context in FND_DFLEX.context_r
    ,p_otc_flex_name in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE
    ,p_context_code in FND_DESCR_FLEX_CONTEXTS.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE
   ) is

    l_segments FND_DFLEX.segments_dr;
    l_segment_index NUMBER;
    l_segment_count NUMBER;


  BEGIN

      FND_DFLEX.get_Segments(
                 context => p_context
                ,segments => l_segments
                ,enabled_only => TRUE);

      l_segment_index := l_segments.segment_name.first;

      --
      -- Ok, is this is the global context, then we can set
      -- the segment count to zero, otherwise we will already
      -- have used a few attributes in creating those global
      -- segments, so we'll need to increase the starting segment
      -- count to account for this.
      --
      if p_context.context_code = 'Global Data Elements' then

        l_segment_count := 0;
        g_global_segment_count := l_segments.segment_name.count;

      else

        l_segment_count := g_global_segment_count;

      end if;

      LOOP

        EXIT WHEN not l_segments.segment_name.exists(l_segment_index);
        l_segment_count := l_segment_count +1;
        --
        -- Create the segment in the OTC flex as it's
        -- defined in the other flexfield
        --

    FND_FLEX_DSC_API.create_segment(
      APPL_SHORT_NAME => p_otc_appl_short_name,
      FLEXFIELD_NAME => p_otc_flex_name,
      CONTEXT_NAME => p_context_code,
      NAME => l_segments.segment_name(l_segment_index),
--      COLUMN => 'ATTRIBUTE'||to_char(l_segment_count),
      COLUMN => l_segments.application_column_name(l_segment_index),
      DESCRIPTION =>l_segments.description(l_segment_index),
--      SEQUENCE_NUMBER => l_segments.sequence(l_segment_index),
      SEQUENCE_NUMBER => l_segment_count,
      ENABLED => 'N',
      DISPLAYED => 'N',
      VALUE_SET => find_value_set(l_segments.value_set(l_segment_index)),
      DEFAULT_TYPE => l_segments.default_type(l_segment_index),
      DEFAULT_VALUE =>l_segments.default_value(l_segment_index),
      REQUIRED => 'N',
      SECURITY_ENABLED => 'N',
      DISPLAY_SIZE => l_segments.display_size(l_segment_index),
      DESCRIPTION_SIZE => l_segments.display_size(l_segment_index),
      CONCATENATED_DESCRIPTION_SIZE => l_segments.display_size(l_segment_index),
      LIST_OF_VALUES_PROMPT => l_segments.column_prompt(l_segment_index),
      WINDOW_PROMPT => l_segments.row_prompt(l_segment_index),
      RANGE => NULL,
      SRW_PARAMETER => NULL);

        l_segment_index := l_segments.segment_name.next(l_segment_index);

      END LOOP; -- segments loop

  END create_segments;

  FUNCTION check_contexts
            (p_contexts in FND_DFLEX.contexts_dr)
   RETURN BOOLEAN is

  -- Here we ascertain whether the flex
  -- we are duplicating only has
  -- the global context associated with it.
  -- Note: all flexs have at least the global context
  -- If that's true we have to handle it in a slightly
  -- different way to the case when there are context
  -- segments.

  -- Note, since flex impose a rule that a flexfield
  -- must always have global data elements, we can
  -- just check the number of contexts, and if only
  -- one - we know we only have global data elements!

BEGIN

     if (p_contexts.ncontexts = 1) then
       return false;
     else
       return true;
     end if;

  END check_contexts;

  PROCEDURE duplicate_desc_flex
     (p_appl_short_name     in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE,
      p_flexfield_name      in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE,
      p_otc_appl_short_name in FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE,
      p_otc_flex_name       in FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE,
      p_context_prefix      in varchar2,
      p_preserve            in boolean
      ) is

-- This cursor retrieves the Sequence Number from the context code like
--PAEXPITDFFC - Number(PAEXPITDFFC - 4252), where Number is the maximum,
--so that the next context like PAEXPITDFFC is created with the code
--PAEXPITDFFC - (Sequence Number +1)

     CURSOR get_max_sequence IS
       select max(to_number(substrB(DESCRIPTIVE_FLEX_CONTEXT_CODE,
                                    instr(DESCRIPTIVE_FLEX_CONTEXT_CODE,'-')+2)))
         FROM fnd_descr_flex_contexts_vl
        WHERE descriptive_flexfield_name = 'OTC Information Types'
          AND application_id = 809
          AND  substrB(DESCRIPTIVE_FLEX_CONTEXT_CODE,0,
                       instr(DESCRIPTIVE_FLEX_CONTEXT_CODE,'-')-2)
               =substrB(DESCRIPTIVE_FLEX_CONTEXT_name,0,
                        instr(DESCRIPTIVE_FLEX_CONTEXT_name,'-')-2)||'C';

     l_max_sequence_code fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
     l_max_sequence_no      VARCHAR2(30);
     l_flex                 FND_DFLEX.dflex_r;
     l_flex_info            FND_DFLEX.dflex_dr;
     l_contexts             FND_DFLEX.contexts_dr;
     l_current_context      FND_DFLEX.context_r;
     l_global_context       FND_DFLEX.context_r;
     l_segments             FND_DFLEX.segments_dr;
     l_context_index        NUMBER;
     l_segment_index        NUMBER;
     l_bld_blk_info_type_id NUMBER;
     l_segment_count        NUMBER;
     l_count                NUMBER;
     l_sequence_code        fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE DEFAULT NULL;
     l_sequence_no          NUMBER;
     l_message              VARCHAR2(100);
     l_preserve             BOOLEAN;
  BEGIN
     --
     -- Default is not to preserve the
     -- flexfield definitions.  By default, we will replace the
     -- definition.
     --
     if(p_preserve is null) then
        l_preserve := false;
     else
        l_preserve := true;
     end if;
     --
     -- Tell the API we're seeding data
     --
     FND_FLEX_DSC_API.set_session_mode('seed_data');
     --
     -- First fetch the flexfield
     --
     FND_DFLEX.get_flexfield
        (appl_short_name => p_appl_short_name,
         flexfield_name => p_flexfield_name,
         flexfield => l_flex,
         flexinfo => l_flex_info);
     --
     -- Next get the contexts
     --
     FND_DFLEX.get_contexts
        (flexfield => l_flex,
         contexts => l_contexts
         );
     --
     -- OK, if we have more than just the
     -- global context have to do things one
     -- way, if only the global context
     -- then have to do things slightly differently.
     --

     if (check_contexts(l_contexts)) then
        l_global_context := FND_DFLEX.make_context
           (flexfield => l_flex,
            context_code =>'Global Data Elements'
            );
        --
        -- For each context, create the information type
        -- and the usage, and create a context of the same
        -- name against OTC Information types
        --
        l_context_index := l_contexts.context_code.first;

        LOOP
           EXIT WHEN not l_contexts.context_code.exists(l_context_index);
           --
           -- Must avoid create a global data elements context
           -- those segments are handled a different way
           --
           if (
               (l_contexts.context_code(l_context_index) <> 'Global Data Elements')
              AND
               (hxc_otl_info_type_helper.build_otl_contexts
                  (p_otc_appl_short_name,
                   p_otc_flex_name,
                   p_context_prefix,
                   l_flex,
                   l_contexts,
                   l_context_index,
                   l_global_context,
                   l_preserve
                   )
               )
              )then
              -- Create the context against OTC Information types but
              -- delete it first to make the process rerunable not as
              -- performant as leaving it there, but this way we are
              -- ensured to keep the OTC information in step with the
              -- descriptive flex information If the length of the
              -- Expenditure Items Context Code is less than or equal
              -- to 17 then the usual process , i.e the context code
              -- will remain like 'PAEXPITDFF''
              IF (LENGTH(l_contexts.context_code(l_context_index)) <=
                  30-((LENGTH(p_context_prefix)+3))) THEN
                 -- Follow the existing logic

                 if FND_FLEX_DSC_API.context_exists
                    (P_APPL_SHORT_NAME => p_otc_appl_short_name,
                     P_FLEXFIELD_NAME => p_otc_flex_name,
                     P_CONTEXT_CODE => substr(p_context_prefix||' - '||l_contexts.context_code(l_context_index),1,30)
                     ) then
                    FND_FLEX_DSC_API.delete_context
                       (APPL_SHORT_NAME => p_otc_appl_short_name,
                        FLEXFIELD_NAME => p_otc_flex_name,
                        CONTEXT => substr(p_context_prefix||' - '||l_contexts.context_code(l_context_index),1,30));

                 end if; -- Does this context exist?

                 FND_FLEX_DSC_API.create_context
                    (APPL_SHORT_NAME => p_otc_appl_short_name,
                     FLEXFIELD_NAME => p_otc_flex_name,
                     CONTEXT_CODE => substr(p_context_prefix||' - '||l_contexts.context_code(l_context_index),1,30),
                     CONTEXT_NAME => l_contexts.context_name(l_context_index),
                     DESCRIPTION => l_contexts.context_description(l_context_index),
                     ENABLED => 'N',
                     GLOBAL_FLAG => 'N'
                     );
                 --
                 -- Create the Building block information type for this context
                 --
                 l_bld_blk_info_type_id := create_bld_blk_info_type
                    (p_appl_short_name => p_otc_appl_short_name,
                     p_flexfield_name => p_otc_flex_name,
                     p_legislation_code => NULL,
                     p_bld_blk_info_type => substr(p_context_prefix||' - '||l_contexts.context_code(l_context_index),1,30),
                     p_category => p_flexfield_name
                     );
                 --
                 -- Now, since we're using the OTC information types flexfield
                 -- as a general flexfield, we can't simply add the global data
                 -- segments within that context.  So, we must add them to
                 -- each context generated with the flexfield we're currently
                 -- duplicating.  This is irritating, but the only way to do it
                 -- currently.
                 --
                 create_segments
                    (p_otc_appl_short_name => p_otc_appl_short_name,
                     p_context => l_global_context,
                     p_otc_flex_name => p_otc_flex_name,
                     p_context_code => substr(p_context_prefix||' - '||l_contexts.context_code(l_context_index),1,30)
                     );
                 --
                 -- Next get the segments for this context, and create them against
                 -- OTC context, AOL require us to "make" the context first
                 --
                 l_current_context := FND_DFLEX.make_context
                    (flexfield => l_flex,
                     context_code =>l_contexts.context_code(l_context_index)
                     );

                 create_segments
                    (p_otc_appl_short_name => p_otc_appl_short_name,
                     p_context => l_current_context,
                     p_otc_flex_name => p_otc_flex_name,
                     p_context_code => substr(p_context_prefix||' - '||l_contexts.context_code(l_context_index),1,30)
                     );

              ELSE
                 -- If the length of the Expenditure Item Context Code
                 -- is greater than 17 then, context should be like
                 -- PAEXPITDFFC - 14235252 and the Context Name will
                 -- hold the usual context code like PAEXPITDFF -
                 -- Painting&Decorating If the context code of
                 -- Expenditure Items is already greater than 17 and
                 -- the corresponding context code already exist in
                 -- the OTL Information Types, then do nothing else
                 -- create the context code like PAEXPITDFFC -
                 -- 14235252

                  IF (not fnd_flex_dsc_api.context_exists
                             (p_appl_short_name=> p_otc_appl_short_name,
                              p_flexfield_name=> p_otc_flex_name,
                              p_context_code=>substr( p_context_prefix || ' - '|| l_contexts.context_code(l_context_index), 1, 30))
                          )THEN

                     l_sequence_code := NULL;
                     -- Check out if the code already exist , say, if
                     --the context code is 'Painting&Decorating' then
                     --if PAEXPITDFF - Painting&Decorating exist as
                     --the context name, then the sequence code will
                     --be populated with PAEXPITDFFC - 14235252

                     if not (hxc_deposit_wrapper_utilities.get_dupdff_code
                               (p_context_prefix||' - '|| l_contexts.context_code(l_context_index))=
                                p_context_prefix||' - '|| l_contexts.context_code(l_context_index)
                             ) then

                        l_sequence_code := hxc_deposit_wrapper_utilities.get_dupdff_code
                           (p_context_prefix||' - '|| l_contexts.context_code(l_context_index)
                            );
                     end if;

                     if (l_sequence_code is not null) then
                        -- The context code exist and so it requires
                        -- to be deleted and once again created
                        fnd_flex_dsc_api.delete_context
                           (appl_short_name=> p_otc_appl_short_name,
                            flexfield_name=> p_otc_flex_name,
                            CONTEXT=> l_sequence_code
                            );
                     else
                       -- If the context code does not exist for the
                       --PAEXPITDFF - Painting&Decorating, then obtain
                       --context code needs to be created like
                       --'PAEXPITDFFC - Sequence Number, where
                       --Sequence Number is the maximum
                        OPEN get_max_sequence;
                        FETCH get_max_sequence INTO l_sequence_no;

                        IF l_sequence_no IS NULL   THEN
                           -- If the context like PAEXPITDFFC is
                           --created for the first time , then
                           --starting the sequenc from 1
                           l_sequence_code := p_context_prefix || 'C - 1';
                         ELSE
                            -- Sequence Number is populated with the maximum sequence +1
                            l_sequence_no := l_sequence_no + 1;
                            l_sequence_code :=  p_context_prefix || 'C - ' || l_sequence_no;
                         END IF;
                         CLOSE get_max_sequence;
                      end if;
                      hr_utility.set_message(809,'HXC_DFF_SYSTEM_CONTEXT');


                      -- Description of the messages needs to be
                      --'System context, do not modify.Context Name.
                      --Description'. So keeping in view to avoid
                      --translation problems, a message is created
                      --with the above name and the text as 'System
                      --context, do not modify''
                      l_message := hr_utility.get_message;
                      -- Creates the context
                      fnd_flex_dsc_api.create_context
                         (appl_short_name=> p_otc_appl_short_name,
                          flexfield_name=> p_otc_flex_name,
                          context_code=> l_sequence_code,
                          context_name=> p_context_prefix
                                         || ' - '
                                         || l_contexts.context_code( l_context_index),
                          description=>  substr(l_message
                                                || l_contexts.context_name(l_context_index)
                                                || '.'
                                                || l_contexts.context_description( l_context_index ),1,240),
                          enabled=> 'N',
                          global_flag=> 'N'
                          );

                      --Create the building block information
                      l_bld_blk_info_type_id :=
                         create_bld_blk_info_type
                           (p_appl_short_name=> p_otc_appl_short_name,
                            p_flexfield_name=> p_otc_flex_name,
                            p_legislation_code=> NULL,
                            p_bld_blk_info_type=> l_sequence_code,
                            p_category=> p_flexfield_name
                            );
                      -- Create the segments
                      create_segments
                         (p_otc_appl_short_name=> p_otc_appl_short_name,
                          p_context=> l_global_context,
                          p_otc_flex_name=> p_otc_flex_name,
                          p_context_code=> l_sequence_code
                          );

                      l_current_context :=
                         fnd_dflex.make_context
                           (flexfield=> l_flex,
                            context_code=> l_contexts.context_code(l_context_index)
                            );

                      create_segments
                         (p_otc_appl_short_name=> p_otc_appl_short_name,
                          p_context=> l_current_context,
                          p_otc_flex_name=> p_otc_flex_name,
                          p_context_code=> l_sequence_code
                          );

                   end if;
                END IF;
             end if; -- avoiding the global data elements.
             l_context_index := l_contexts.context_code.next(l_context_index);
          END LOOP; -- Contexts loop
  else
     --
     -- In this case, we've only got the global contexts
     -- just set up a p_context_prefix - global context.
     -- No loop needed, since there is only one context.

     l_global_context := FND_DFLEX.make_context
        (flexfield => l_flex,
         context_code =>'Global Data Elements'
         );

      if FND_FLEX_DSC_API.context_exists
           (P_APPL_SHORT_NAME => p_otc_appl_short_name,
            P_FLEXFIELD_NAME => p_otc_flex_name,
            P_CONTEXT_CODE => substr(p_context_prefix||' - GLOBAL',1,30)
            ) then
         FND_FLEX_DSC_API.delete_context
            (APPL_SHORT_NAME => p_otc_appl_short_name,
             FLEXFIELD_NAME => p_otc_flex_name,
             CONTEXT => substr(p_context_prefix||' - GLOBAL',1,30)
             );

      end if; -- Does this context exist?

      FND_FLEX_DSC_API.create_context
         (APPL_SHORT_NAME => p_otc_appl_short_name,
          FLEXFIELD_NAME => p_otc_flex_name,
          CONTEXT_CODE => substr(p_context_prefix||' - GLOBAL',1,30),
          CONTEXT_NAME => substr(p_context_prefix||' - GLOBAL',1,30),
          DESCRIPTION => substr(p_context_prefix||' - GLOBAL',1,30)||' auto generated by the magic process',
          ENABLED => 'N',
          GLOBAL_FLAG => 'N'
          );
      --
      -- Create the Building block information type for this context
      --
      l_bld_blk_info_type_id := create_bld_blk_info_type
         (p_appl_short_name => p_otc_appl_short_name,
          p_flexfield_name => p_otc_flex_name,
          p_legislation_code => NULL,
          p_bld_blk_info_type => substr(p_context_prefix||' - GLOBAL',1,30),
          p_category => p_flexfield_name
          );
      --
      -- Finally create the global segments in the special
      -- OTL context created for these globals.
      --
      create_segments
         (p_otc_appl_short_name => p_otc_appl_short_name,
          p_context => l_global_context,
          p_otc_flex_name => p_otc_flex_name,
          p_context_code => substr(p_context_prefix||' - GLOBAL',1,30)
          );
  end if;

END duplicate_desc_flex;

/*
Added for 8645021 HR OTL Absence Integration

Call to insert absence info from the element set to hxc_absence_type_elements
*/

--change start
PROCEDURE INSERT_INTO_HXC_ABSENCES(p_error_msg	OUT  NOCOPY	VARCHAR2,
				  p_abs_info	IN	hxc_create_flex_mappings.hxc_abs_tab_type)
IS

CURSOR chk_abs_elem_exists(p_absence_attendance_type_id IN	NUMBER,
			   p_element_type_id	   IN	NUMBER)
			   --p_uom		   IN	VARCHAR2,
			   --p_absence_category	   IN	VARCHAR2)
IS
SELECT
   	1
FROM
 	hxc_absence_type_elements
WHERE
	absence_attendance_type_id = p_absence_attendance_type_id AND
	element_type_id = p_element_type_id;


x_var 	NUMBER(1);

BEGIN

/*
The logic would be to first delete the records with the
present element type ids and den insert it.
*/

if g_debug then
hr_utility.trace('Entered INSERT_INTO_HXC_ABSENCES');
end if;

IF p_abs_info.COUNT > 0 THEN

FOR tab_count in p_abs_info.FIRST .. p_abs_info.LAST
 LOOP

 	OPEN chk_abs_elem_exists(
 	p_abs_info(tab_count).ABSENCE_ATTENDANCE_TYPE_ID,
 	p_abs_info(tab_count).ELEMENT_TYPE_ID
 				);

 	FETCH chk_abs_elem_exists into x_var;

 	IF (chk_abs_elem_exists%NOTFOUND) THEN

 	        if g_debug then

 	        hr_utility.trace('Inserting');
 	        hr_utility.trace('ABSENCE_ATTENDANCE_TYPE_ID = '||p_abs_info(tab_count).ABSENCE_ATTENDANCE_TYPE_ID);
 	        hr_utility.trace('ELEMENT_TYPE_ID = '||p_abs_info(tab_count).ELEMENT_TYPE_ID);
 	        hr_utility.trace('EDIT_FLAG = '||p_abs_info(tab_count).EDIT_FLAG);
 	        hr_utility.trace('UOM = '||p_abs_info(tab_count).UOM);
 	        hr_utility.trace('ABSENCE_CATEGORY = '||p_abs_info(tab_count).ABSENCE_CATEGORY);


 	        end if;

 		insert into hxc_absence_type_elements -- hxc_absence_type_elements
 		(
 		ABSENCE_ATTENDANCE_TYPE_ID,
 		ELEMENT_TYPE_ID,
 		EDIT_FLAG,
 		UOM,
 		ABSENCE_CATEGORY
 		)

 		VALUES
 		(
 		p_abs_info(tab_count).ABSENCE_ATTENDANCE_TYPE_ID,
 		p_abs_info(tab_count).ELEMENT_TYPE_ID,
 		p_abs_info(tab_count).EDIT_FLAG,
 		p_abs_info(tab_count).UOM,
 		p_abs_info(tab_count).ABSENCE_CATEGORY
		);

 	 ELSE
 	         if g_debug then
 	         hr_utility.trace('Updating');
                 hr_utility.trace('ABSENCE_ATTENDANCE_TYPE_ID = '||p_abs_info(tab_count).ABSENCE_ATTENDANCE_TYPE_ID);
		 hr_utility.trace('ELEMENT_TYPE_ID = '||p_abs_info(tab_count).ELEMENT_TYPE_ID);
		 hr_utility.trace('EDIT_FLAG NEW = '||p_abs_info(tab_count).EDIT_FLAG);
		 hr_utility.trace('UOM NEW= '||p_abs_info(tab_count).UOM);
		 hr_utility.trace('ABSENCE_CATEGORY NEW = '||p_abs_info(tab_count).ABSENCE_CATEGORY);
 	         end if;


 	        UPDATE hxc_absence_type_elements
 	           SET UOM = p_abs_info(tab_count).UOM,
 	               ABSENCE_CATEGORY = p_abs_info(tab_count).ABSENCE_CATEGORY
 	         WHERE absence_attendance_type_id = p_abs_info(tab_count).ABSENCE_ATTENDANCE_TYPE_ID
 	           AND element_type_id = p_abs_info(tab_count).ELEMENT_TYPE_ID;


 	END IF;

 	CLOSE chk_abs_elem_exists;

 END LOOP;

--commit;

END IF;

p_error_msg := null;

/*
EXCEPTION

WHEN OTHERS THEN

	p_error_msg:= 'ERROR';

*/

END; -- insert_into_hxc_absence

-- change end

procedure run_process(
           p_errmsg OUT NOCOPY VARCHAR2
          ,p_errcode OUT NOCOPY NUMBER
          ,p_undo in VARCHAR2 default 'N'
          ,p_element_set_id in NUMBER default null
          ,p_effective_date in VARCHAR2
          ,p_generate_cost in VARCHAR2 default 'Y'
          ,p_generate_group in VARCHAR2 default 'Y'
          ,p_generate_job in VARCHAR2 default 'Y'
          ,p_generate_pos in VARCHAR2 default 'Y'
          ,p_generate_prj in VARCHAR2 default 'Y'
          ,p_business_group_id in VARCHAR2
          ,p_incl_abs_flg  in VARCHAR2 default 'N') is  -- Added for 8645021 HR Absence intg
          /*
          p_incl_abs_flg indicates Include Absence Information Param.
          */
--Change the parameters to create_alias_definitions.
cursor c_alias_type(p_alias_context_code varchar2) is
   select hat.alias_type_id
     from hxc_alias_types hat
    where reference_object = p_alias_context_code;

cursor c_prompt (p_alias_context_code varchar2) is
   select fdfc.descriptive_flex_context_name
from  fnd_descr_flex_contexts_vl fdfc
where  application_id = 809
   and DESCRIPTIVE_FLEXFIELD_NAME = 'OTC Aliases'
   and fdfc.descriptive_flex_context_code = p_alias_context_code;

cursor c_elements(p_element_set_id in number, p_effective_date in date) is
  select pet.element_name, pet.element_type_id, pet.reporting_name
    from pay_element_types_f pet,
         pay_element_type_rules per
   where per.element_set_id = p_element_set_id
     and per.include_or_exclude = 'I'
     and per.element_type_id = pet.element_type_id
     and multiple_entries_allowed_flag = 'Y'
     and p_effective_date between effective_start_date and effective_end_date;

cursor csr_chk_an_exists(p_an_name varchar2,
                         p_bg_id   number) is
   select 'Y', alias_definition_id
     from hxc_alias_definitions
    where alias_definition_name = p_an_name
      and business_group_id = p_bg_id;

cursor csr_value_exists(p_ele_type_id    number,
                        p_an_id          number) is
                        -- p_effective_date date) is
   select 'Y'
     from hxc_alias_values
    where alias_definition_id = p_an_id
      and attribute1 = to_char(p_ele_type_id);
      -- and p_effective_date between date_from and date_to;

cursor c_ipvs(p_element_type_id in number, p_effective_date in date) is
  select display_sequence, name, input_value_id, mandatory_flag
    from pay_input_values_f
   where element_type_id = p_element_type_id
     and p_effective_date between effective_start_date and effective_end_date
order by display_sequence, name;
/*
Bug no : 3353252
This cursor csr_chk_repname_exists will check for the duplicate reporting name in an alias_defintion
and return the number of same reporting names available.
*/

cursor csr_chk_repname_exists(p_an_id		number,
			      p_ele_rep_name	varchar2) is
select count(*)
  from hxc_alias_values
 where alias_definition_id = p_an_id
 AND (alias_value_name like '% ~ '||p_ele_rep_name or alias_value_name = p_ele_rep_name);


/*
   Added for 8645021 HR OTL Absence Integration

   Cursor added to pick up all absence type elements in the element set
*/

--change start
CURSOR abs_elements (p_effective_date	IN DATE	,
                       p_element_set_id	IN NUMBER
                       )
  	 	IS
 select
  	   pat.absence_attendance_type_id,
  	   pet.element_type_id,
  	   'N'	EDIT_FLAG,
  	   decode(piv.UOM, 'ND', 'DAYS'
  	                 , 'H_H','HOURS'
  			 , 'H_DECIMAL1','HOURS'
  			 , 'H_DECIMAL2','HOURS'
  			 , 'H_DECIMAL3','HOURS'
  			 , 'H_HHMM','HOURS'
  			 , NULL) UOM,
  	   pat.absence_category
  from
  	pay_element_types_f pet ,
  	pay_input_values_f	piv,
  	per_absence_attendance_types pat,
 	pay_element_type_rules       per
  where
  	 per.element_set_id= p_element_set_id	AND
 	 per.include_or_exclude = 'I'	AND
 	 per.element_type_id=pet.element_type_id AND
 	 pet.multiple_entries_allowed_flag='Y'	 AND
 	 p_effective_date between
  	         nvl(pet.effective_start_date,hr_general.start_of_time)
  			 and
  			   nvl(pet.effective_end_date,hr_general.end_of_time) AND
  	 piv.element_type_id=pet.element_type_id AND
  	 p_effective_date between
  	 		nvl(piv.effective_start_date,hr_general.start_of_time)
  			 and
  			  nvl(piv.effective_end_date ,hr_general.end_of_time) AND
  	 pat.input_value_id=piv.input_value_id AND
  	 p_effective_date between
  	 		nvl(pat.date_effective,hr_general.start_of_time)
  			 and
			  nvl(pat.date_end ,hr_general.end_of_time);


-- change end


l_attr_prompt pay_input_values_f.name%TYPE;
l_temp_segment_choice NUMBER :=0;

l_appl_short_name VARCHAR2(3) := 'HXC';
l_flexfield_name VARCHAR2(30) := 'OTC Information Types';
l_segment_count NUMBER := 0;
l_segment_choice NUMBER :=0;

l_element_count NUMBER := 0;
l_key_flex_structure_count NUMBER :=0;

l_max_input_value_count NUMBER:=0;
l_max_segment_count NUMBER :=0;

l_key_app VARCHAR2(30) := 'PAY';
l_key_flex_code VARCHAR2(30) := 'COST';

l_key_flex FND_FLEX_KEY_API.FLEXFIELD_TYPE;

l_key_structure_list FND_FLEX_KEY_API.STRUCTURE_LIST;
l_key_segment_list FND_FLEX_KEY_API.SEGMENT_LIST;

l_key_structure FND_FLEX_KEY_API.STRUCTURE_TYPE;
l_key_segment FND_FLEX_KEY_API.SEGMENT_TYPE;

l_structure_count NUMBER;

l_structures NUMBER;
l_segments NUMBER;

l_building_block_info_id NUMBER;

i NUMBER;

l_element_set_name      VARCHAR2(80);
l_an_context            VARCHAR2(30) := 'PAYROLL_ELEMENTS';
l_an_enabled            VARCHAR2(80);
l_an_disabled           VARCHAR2(80);
l_an_en_exists          VARCHAR2(1) := 'N';
l_an_dis_exists         VARCHAR2(1) := 'N';
l_an_en_id              NUMBER;
l_an_en_ovn             NUMBER;
l_an_dis_id             NUMBER;
l_an_dis_ovn            NUMBER;
l_en_value_exists       VARCHAR2(1) := 'N';
l_dis_value_exists      VARCHAR2(1) := 'N';
l_av_id                 NUMBER;
l_av_ovn                NUMBER;
l_bg_id                 NUMBER;
-- Change Parameters to create_alias_definitions
l_alias_type_id         NUMBER;
l_prompt                varchar2(240);

l_generate BOOLEAN;

l_effective_date DATE;
l_bgp_id FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
l_bgp_def BOOLEAN;

l_ret_bg_id VARCHAR2(2000);

l_new_en_repname	PAY_ELEMENT_TYPES_F.REPORTING_NAME%TYPE;
l_new_dis_repname	PAY_ELEMENT_TYPES_F.REPORTING_NAME%TYPE;

l_alt_name_change       VARCHAR2(1) := 'N';
l_name                  VARCHAR2(1000);

l_warning_string	VARCHAR2(1000):='';
l_warning_string1       VARCHAR2(5000):='';
l_temp_msg		VARCHAR2(5000):='';
c_warning		CONSTANT	NUMBER	:= 1;
l_cnt_repname		NUMBER(10):=0;

l_disp_count		NUMBER := 0; 			-- Bug 5919417

/*
Added for 8645021 HR OTL Absence Integration

Variables added for Abs_Intg
*/

--change start
 hxc_abs_tab		hxc_abs_tab_type;
 abs_elem_exists	abs_elem_exists_type;
 l_tab_counter		NUMBER:=1;
 l_non_abs_elem_exists	VARCHAR2(1):='Y';
 l_abs_elem_flg		VARCHAR2(1):='N';
 l_err_msg		VARCHAR2(1000);

 PROFILE_NOT_SET	EXCEPTION;
--change end



BEGIN

/*
Added for 8645021 HR OTL Absence Integration

Setting up the global variable with the absence inclusion parameter
*/

-- change start
g_abs_incl_flag:= p_incl_abs_flg;
-- change end


/* Bug fix for 3353252
Initialize the string for the warning messages which will be printed if there is any duplication in the alternate names*/
   hr_utility.set_message (809, 'HXC_GEN_FLEX_MOD_ALT_WAR_MSG');
   l_name:=HR_UTILITY.GET_MESSAGE;
/* end of fix for 3353252*/

--
-- Convert the entered date into real date format
--

l_effective_date := FND_DATE.CANONICAL_TO_DATE(p_effective_date);

--
-- Set the business group id if passed in
--

if (p_business_group_id is not null) then

FND_PROFILE.PUT('PER_BUSINESS_GROUP_ID',p_business_group_id);

else

--
-- Is there a problem with fnd_profile caching?
--
FND_PROFILE.GET_SPECIFIC('PER_BUSINESS_GROUP_ID',null,null,null,l_bgp_id,l_bgp_def);
if (l_bgp_def) then
  FND_PROFILE.PUT('PER_BUSINESS_GROUP_ID',l_bg_id);
else
  FND_PROFILE.PUT('PER_BUSINESS_GROUP_ID',null);
end if;

end if;

/*
Added for 8645021 HR OTL Absence Integration

Check for Profile Parameter mismatch
*/

-- change start
if (fnd_profile.value('HR_ABS_OTL_INTEGRATION') is null or
    fnd_profile.value('HR_ABS_OTL_INTEGRATION') <> 'Y') then

    if g_abs_incl_flag='Y' then

       g_abs_incl_flag:= 'N';
       --RAISE PROFILE_NOT_SET;

       FND_MESSAGE.set_name('HXC','HXC_ABS_PROF_PARAM_MISMATCH');
       FND_MESSAGE.raise_error;

    end if;

 end if;
--change end

--
-- Check the undo flag, if set, then attempt to undo
-- the flex and mapping component creation
--

 if p_undo = 'Y' then
     undo(
      p_appl_short_name=> l_appl_short_name
     ,p_flexfield_name => l_flexfield_name
     ,p_element_set_id => p_element_set_id
     ,p_effective_date => l_effective_date
     ,p_include_cost => p_generate_cost
     ,p_include_group => p_generate_group
     ,p_include_job => p_generate_job
     ,p_include_pos => p_generate_pos
     ,p_include_prj => p_generate_prj);

 else

--
--  Tell the flex field API we're seeding data
--

  FND_FLEX_DSC_API.set_session_mode('seed_data');
-- Create alias definitions (Enabled and Disabled) and for the element set,
-- if it does not already exist.
--
--
-- Create the dummy element context and mappings
--
  create_dummy_context(
      p_appl_short_name => l_appl_short_name,
      p_flexfield_name => l_flexfield_name,
      p_context_name => 'ELEMENT',
      p_segment_name_prefix=>'InputValue',
      p_max_segments => 15
           );

IF p_element_set_id IS NOT NULL THEN

   /*
   Added for 8645021 HR OTL Absence Integration

  Need to populate hxc_abs_tab and abs_elem_exists plsql tables
   */

   -- change start
IF p_incl_abs_flg='Y' THEN

     l_tab_counter:=0;

     FOR abs_info IN abs_elements (l_effective_date,
         		               p_element_set_id
         		              )
           LOOP
        	l_tab_counter := l_tab_counter + 1;

        	hxc_abs_tab(l_tab_counter).ABSENCE_ATTENDANCE_TYPE_ID :=
        		abs_info.ABSENCE_ATTENDANCE_TYPE_ID;
        	hxc_abs_tab(l_tab_counter).ELEMENT_TYPE_ID :=
        		abs_info.ELEMENT_TYPE_ID;
        	hxc_abs_tab(l_tab_counter).EDIT_FLAG :=
        		abs_info.EDIT_FLAG;
        	hxc_abs_tab(l_tab_counter).UOM :=
        		abs_info.UOM;
        	hxc_abs_tab(l_tab_counter).ABSENCE_CATEGORY :=
        		abs_info.ABSENCE_CATEGORY;

      END LOOP; -- abs_info

      if g_debug then

      hr_utility.trace('hxc_abs_tab.COUNT = '||hxc_abs_tab.COUNT);



         if hxc_abs_tab.count>0 then

             FOR i in hxc_abs_tab.FIRST .. hxc_abs_tab.LAST
             LOOP

             if hxc_abs_tab.EXISTS(i) then

             hr_utility.trace('hxc_abs_tab(i).ABSENCE_ATTENDANCE_TYPE_ID = '||hxc_abs_tab(i).ABSENCE_ATTENDANCE_TYPE_ID);
             hr_utility.trace('hxc_abs_tab(i).ELEMENT_TYPE_ID = '||hxc_abs_tab(i).ELEMENT_TYPE_ID);
             hr_utility.trace('hxc_abs_tab(i).EDIT_FLAG = '||hxc_abs_tab(i).EDIT_FLAG);
             hr_utility.trace('hxc_abs_tab(i).UOM = '||hxc_abs_tab(i).UOM);
             hr_utility.trace('hxc_abs_tab(i).ABSENCE_CATEGORY = '||hxc_abs_tab(i).ABSENCE_CATEGORY);

             end if;

             END LOOP;

          end if;

      end if; -- g_debug

      IF hxc_abs_tab.COUNT>0 THEN

      	FOR i in hxc_abs_tab.first .. hxc_abs_tab.last
      	LOOP

      	  abs_elem_exists(hxc_abs_tab(i).element_type_id):= 1;

      	END LOOP; -- hxc_abs_tab plsql table loop

      if g_debug then
      hr_utility.trace('abs_elem_exists.COUNT = '||abs_elem_exists.COUNT);
      end if;


      END IF; -- hxc_abs_tab.count

      -- now to check for non_absence_elements in the element set at all

       l_non_abs_elem_exists := 'N';

       FOR ele_rec in c_elements(p_element_set_id, l_effective_date) LOOP

       	IF NOT(abs_elem_exists.EXISTS(ele_rec.element_type_id)) THEN

       		l_non_abs_elem_exists := 'Y';

       	END IF;

       END LOOP;


   END IF; -- p_incl_abs_flg
   -- change end

   if g_debug then
         hr_utility.trace('l_non_abs_elem_exists = '||l_non_abs_elem_exists);
      end if;
   --
   -- Get the element set name.
   --
   SELECT element_set_name, business_group_id
     INTO l_element_set_name, l_bg_id
     FROM pay_element_sets
    WHERE element_set_id = p_element_set_id;

   --
   l_an_enabled := rtrim(substr(l_element_set_name, 1, 70)) || ' - Enabled';
   l_an_disabled := rtrim(substr(l_element_set_name, 1, 69)) || ' - Disabled';
/* Bug fix for 3353252
The following code is used to get the alias_definiton_name which will be used in warning message
if there is an alternate name change by the application.*/
   FND_MESSAGE.SET_NAME('HXC', 'HXC_GEN_FLEX_MOD_ALS_DEF_NAME');
   FND_MESSAGE.SET_TOKEN('ALIAS_DEFINITION_NAME',l_an_enabled);
   l_temp_msg:=FND_MESSAGE.GET();
   l_warning_string:=l_warning_string || l_temp_msg || '
';
   FND_MESSAGE.SET_NAME ('HXC', 'HXC_GEN_FLEX_MOD_ALS_DEF_NAME');
   FND_MESSAGE.SET_TOKEN('ALIAS_DEFINITION_NAME',l_an_disabled);
   l_temp_msg:=FND_MESSAGE.GET();
   l_warning_string1:=l_warning_string1 || l_temp_msg || '
';
/* end of fix for 3353252*/
   --
   -- Check to see whether they already exist.
   --
   open csr_chk_an_exists(l_an_enabled, l_bg_id);
   fetch csr_chk_an_exists into l_an_en_exists, l_an_en_id;
   IF csr_chk_an_exists%NOTFOUND THEN
      l_an_en_exists := 'N';
   END IF;
   close csr_chk_an_exists;
   --
   open csr_chk_an_exists(l_an_disabled, l_bg_id);
   fetch csr_chk_an_exists into l_an_dis_exists, l_an_dis_id;
   IF csr_chk_an_exists%NOTFOUND THEN
      l_an_dis_exists := 'N';
   END IF;
   close csr_chk_an_exists;
   --
--   l_ret_bg_id := FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
--   dbms_output.put_line('Profile business group id is:'||l_ret_bg_id);
   --

   -- change parameters to create_alias_definitions
   open c_alias_type(l_an_context);
       fetch c_alias_type into l_alias_type_id;
       if (l_alias_type_id is null) then
          hr_utility.set_message(809,'HXC_SEED_ALT_NOT_FOUND');
	  hr_utility.raise_error;
       end if;
   close c_alias_type;

   open c_prompt(l_an_context);
       fetch c_prompt into l_prompt;
   close c_prompt;


/*
Added for 8645021 HR OTL Absence Integration

Check for, if at all any non absence elements exist
*/

-- change start
 IF l_non_abs_elem_exists = 'Y' then  --
-- change end

  if g_debug then
     hr_utility.trace('Creating Alias Definitions');
  end if;

   IF l_an_en_exists = 'N' THEN
      hxc_alias_definitions_api.create_alias_definition
           (p_alias_definition_id           => l_an_en_id
           ,p_alias_definition_name         => l_an_enabled
           ,p_business_group_id             => l_bg_id
           ,p_legislation_code              => NULL
           ,p_description                   => 'Created for renaming elements'
	   ,p_prompt 			    => l_prompt
           ,p_timecard_field                => 'ElementComponent'
           ,p_object_version_number         => l_an_en_ovn
	   ,p_alias_type_id                 => l_alias_type_id
           );
   END IF;
   --
   --
   IF l_an_dis_exists = 'N' THEN
      hxc_alias_definitions_api.create_alias_definition
           (p_alias_definition_id           => l_an_dis_id
           ,p_alias_definition_name         => l_an_disabled
           ,p_business_group_id             => l_bg_id
           ,p_legislation_code              => NULL
           ,p_description                   => 'Created for renaming elements'
	   ,p_prompt 			    => l_prompt
           ,p_timecard_field                => 'ElementComponent'
           ,p_object_version_number         => l_an_dis_ovn
	   ,p_alias_type_id                 => l_alias_type_id
           );
   END IF;

  END IF; --l_non_abs_elem_exists

   --
END IF; -- p_element_set_id
--

/*
  Open the element type cursor, and fetch the first element
*/


for ele_rec in c_elements(p_element_set_id, l_effective_date) LOOP
   -- Check if this element already exists in the values for
   -- the two alias definitions.
   --
   open csr_value_exists(ele_rec.element_type_id, l_an_en_id);
   fetch csr_value_exists into l_en_value_exists;
   IF csr_value_exists%NOTFOUND THEN
	l_en_value_exists := 'N';
   END IF;
   close csr_value_exists;

   --
   open csr_value_exists(ele_rec.element_type_id, l_an_dis_id);
   fetch csr_value_exists into l_dis_value_exists;
   IF csr_value_exists%NOTFOUND THEN
      l_dis_value_exists := 'N';
   END IF;
   close csr_value_exists;

   --
   /*
   Added for 8645021 HR OTL Absence Integration

   Checking whether the element is attached to an absence type
   */
   --change start
   l_abs_elem_flg:='N';

      IF p_incl_abs_flg = 'Y' then -- abs_intg

        IF abs_elem_exists.EXISTS(ele_rec.element_type_id) then
           l_abs_elem_flg:='Y';
        ELSE
           l_abs_elem_flg:='N';
        END IF; -- abs_elem_exists

      END IF; -- p_incl_abs_flg



   IF l_abs_elem_flg ='N' then -- svg abs_intg
   -- change end

   if g_debug then
      hr_utility.trace('Creating Alias Values for '||ele_rec.element_type_id);
   end if;


   IF l_en_value_exists = 'N' THEN
   l_cnt_repname:=0;
      open csr_chk_repname_exists(l_an_en_id,nvl(ele_rec.reporting_name,ele_rec.element_name));
      fetch csr_chk_repname_exists into l_cnt_repname;
      IF l_cnt_repname=0 THEN
	hxc_alias_values_api.create_alias_value
         (p_alias_value_id                => l_av_id
         ,p_alias_value_name              => nvl(ele_rec.reporting_name,
                                                 ele_rec.element_name)
         ,p_date_from                     => hr_general.start_of_time
         ,p_date_to                       => NULL
         ,p_alias_definition_id           => l_an_en_id
         ,p_enabled_flag                  => 'Y'
         ,p_attribute_category            => l_an_context
         ,p_attribute1                    => ele_rec.element_type_id
         ,p_object_version_number         => l_av_ovn);
      ELSE
/*Bug fix 3353252 Modifying the alternate name to be unique by prefixing the number */
     	l_new_en_repname:=l_cnt_repname ||' ~ ' || nvl(ele_rec.reporting_name,ele_rec.element_name);
	hxc_alias_values_api.create_alias_value
         (p_alias_value_id                => l_av_id
         ,p_alias_value_name              => l_new_en_repname
         ,p_date_from                     => hr_general.start_of_time
         ,p_date_to                       => NULL
         ,p_alias_definition_id           => l_an_en_id
         ,p_enabled_flag                  => 'Y'
         ,p_attribute_category            => l_an_context
         ,p_attribute1                    => ele_rec.element_type_id
         ,p_object_version_number         => l_av_ovn);
	FND_MESSAGE.SET_NAME ('HXC', 'HXC_GEN_FLEX_MOD_ALT_NAME');
	FND_MESSAGE.SET_TOKEN('REP_NAME',nvl(ele_rec.reporting_name,ele_rec.element_name));
	FND_MESSAGE.SET_TOKEN('NEW_REP_NAME',l_new_en_repname);
	l_temp_msg:=FND_MESSAGE.GET();
	l_warning_string:=l_warning_string || l_temp_msg || '
';
	l_alt_name_change:='Y';
/*end of fix for 3353252*/
      END IF;
     close csr_chk_repname_exists;
   END IF;
   --
   IF l_dis_value_exists = 'N' THEN
   l_cnt_repname:=0;
      open csr_chk_repname_exists(l_an_dis_id,nvl(ele_rec.reporting_name,ele_rec.element_name));
      fetch csr_chk_repname_exists into l_cnt_repname;
      IF l_cnt_repname=0 THEN
        hxc_alias_values_api.create_alias_value
         (p_alias_value_id                => l_av_id
         ,p_alias_value_name              => nvl(ele_rec.reporting_name,
                                                 ele_rec.element_name)
         ,p_date_from                     => hr_general.start_of_time
         ,p_date_to                       => NULL
         ,p_alias_definition_id           => l_an_dis_id
         ,p_enabled_flag                  => 'N'
         ,p_attribute_category            => l_an_context
         ,p_attribute1                    => ele_rec.element_type_id
         ,p_object_version_number         => l_av_ovn);
      ELSE
/*Bug fix 3353252 Modifying the alternate name to be unique by prefixing the number */
        l_new_dis_repname:=l_cnt_repname ||' ~ ' || nvl(ele_rec.reporting_name,ele_rec.element_name);
        hxc_alias_values_api.create_alias_value
         (p_alias_value_id                => l_av_id
         ,p_alias_value_name              => l_new_dis_repname
         ,p_date_from                     => hr_general.start_of_time
         ,p_date_to                       => NULL
         ,p_alias_definition_id           => l_an_dis_id
         ,p_enabled_flag                  => 'N'
         ,p_attribute_category            => l_an_context
         ,p_attribute1                    => ele_rec.element_type_id
         ,p_object_version_number         => l_av_ovn);
	 l_alt_name_change:='Y';
	FND_MESSAGE.SET_NAME ('HXC', 'HXC_GEN_FLEX_MOD_ALT_NAME');
	FND_MESSAGE.SET_TOKEN('REP_NAME',nvl(ele_rec.reporting_name,ele_rec.element_name));
	FND_MESSAGE.SET_TOKEN('NEW_REP_NAME',l_new_dis_repname);
	l_temp_msg:=FND_MESSAGE.GET();
	l_warning_string1:=l_warning_string1 || l_temp_msg || '
';
/*end of fix for 3353252*/
      END IF;
     close csr_chk_repname_exists;
   END IF;
   --
   --
   END IF; --l_abs_elem_flg

if FND_FLEX_DSC_API.context_exists(
         P_APPL_SHORT_NAME => l_appl_short_name,
         P_FLEXFIELD_NAME => l_flexfield_name,
         P_CONTEXT_CODE => 'ELEMENT - '|| ele_rec.element_type_id
      ) then
       FND_FLEX_DSC_API.delete_context(
           APPL_SHORT_NAME => l_appl_short_name,
           FLEXFIELD_NAME => l_flexfield_name,
           CONTEXT => 'ELEMENT - '|| ele_rec.element_type_id);

end if; -- Does this element context exist?

  FND_FLEX_DSC_API.create_context(
    APPL_SHORT_NAME => l_appl_short_name,
    FLEXFIELD_NAME => l_flexfield_name,
    CONTEXT_CODE => 'ELEMENT - '|| ele_rec.element_type_id,
    CONTEXT_NAME => ele_rec.element_name,
    DESCRIPTION => 'Auto generated HXC element context',
    ENABLED => 'Y',
    GLOBAL_FLAG => 'N');

  l_element_count := l_element_count +1;


--
-- Create the Building block information type for this context
--
    l_building_block_info_id := create_bld_blk_info_type(
            p_appl_short_name => l_appl_short_name,
            p_flexfield_name => l_flexfield_name,
            p_legislation_code => NULL,
            p_bld_blk_info_type => 'ELEMENT - '|| ele_rec.element_type_id,
            p_category => 'ELEMENT');


/*  Bug 5919417 Start */

--
-- Find the number of input values with display_sequence 12,13,14 or 15 before generating segments
--

   for seq_rec in c_ipvs(ele_rec.element_type_id, l_effective_date)
   LOOP
      if((seq_rec.display_sequence > 11) AND (seq_rec.display_sequence < 16) AND (seq_rec.mandatory_flag <> 'X')) then
 	 l_disp_count := l_disp_count + 1;
      end if;
   END LOOP;

/*  Bug 5919417 End */




--
--  Now fetch each input value and generate segments, if we are creating
--
 l_segment_count := 0;
   for ipv_rec in c_ipvs(ele_rec.element_type_id, l_effective_date) LOOP


    if((ipv_rec.display_sequence < 12) OR (ipv_rec.display_sequence > 15)) then

    	l_segment_count := l_segment_count +1;

    end if;

    if (ipv_rec.mandatory_flag <> 'X') then

      if((ipv_rec.display_sequence > 11) AND (ipv_rec.display_sequence < 16)) then

        l_segment_choice := ipv_rec.display_sequence;

      else

       -- l_segment_count := l_segment_count + 1;		/*  Bug 5919417 */

        l_segment_choice := l_segment_count;

      end if;


/*  Bug 5919417 Start */

      if (l_segment_count = 11) then
	  l_segment_count := l_segment_count + l_disp_count;
      end if;

/*  Bug 5919417 Start */


      FND_FLEX_DSC_API.create_segment(
        APPL_SHORT_NAME => l_appl_short_name,
        FLEXFIELD_NAME => l_flexfield_name,
        CONTEXT_NAME => 'ELEMENT - '||ele_rec.element_type_id,
        NAME => ipv_rec.name,
        COLUMN => 'ATTRIBUTE'||to_char(l_segment_choice),
        DESCRIPTION => 'Auto generated HXC element input value context segment',
        SEQUENCE_NUMBER => l_segment_choice,
        ENABLED => 'N',
        DISPLAYED => 'N',
        VALUE_SET => NULL,
        DEFAULT_TYPE => NULL,
        DEFAULT_VALUE => NULL,
        REQUIRED => 'N',
        SECURITY_ENABLED => 'N',
        DISPLAY_SIZE => 30,
        DESCRIPTION_SIZE => 50,
        CONCATENATED_DESCRIPTION_SIZE => 10,
        LIST_OF_VALUES_PROMPT => ipv_rec.name,
        WINDOW_PROMPT => ipv_rec.name,
        RANGE => NULL,
        SRW_PARAMETER => NULL);

      if(ipv_rec.name = 'Jurisdiction') then

        FOR i in 1..4 LOOP

		if (i=1) then
		    l_temp_segment_choice := 27;
		    l_attr_prompt := 'State';
		elsif (i=2) then
		    l_temp_segment_choice := 28;
		    l_attr_prompt := 'County';
		elsif (i=3) then
		    l_temp_segment_choice := 29;
		    l_attr_prompt := 'City';
		elsif (i=4) then
		    l_temp_segment_choice := 30;
		    l_attr_prompt := 'Zipcode';
		end if;

		FND_FLEX_DSC_API.create_segment(
			APPL_SHORT_NAME => l_appl_short_name,
			FLEXFIELD_NAME => l_flexfield_name,
			CONTEXT_NAME => 'ELEMENT - '||ele_rec.element_type_id,
			NAME => l_attr_prompt,
			COLUMN => 'ATTRIBUTE'||to_char(l_temp_segment_choice),
			DESCRIPTION => 'Auto generated HXC element input value context segment',
			SEQUENCE_NUMBER => l_temp_segment_choice,
			ENABLED => 'N',
			DISPLAYED => 'N',
			VALUE_SET => NULL,
			DEFAULT_TYPE => NULL,
			DEFAULT_VALUE => NULL,
			REQUIRED => 'N',
			SECURITY_ENABLED => 'N',
			DISPLAY_SIZE => 30,
			DESCRIPTION_SIZE => 50,
			CONCATENATED_DESCRIPTION_SIZE => 10,
			LIST_OF_VALUES_PROMPT => l_attr_prompt,
			WINDOW_PROMPT => l_attr_prompt,
			RANGE => NULL,
			SRW_PARAMETER => NULL);
           end loop;
      end if;
    end if; -- is this a user enterable segment

  end LOOP; -- Input value loop

  if l_max_input_value_count < l_segment_count then
     l_max_input_value_count := l_segment_count;
  end if;

end LOOP; -- Element loop

/*
Added for 8645021 HR OTL Absence Integration

Insertion into hxc_absence_type_elements
*/
-- change start
IF (p_incl_abs_flg = 'Y' and hxc_abs_tab.COUNT>0)  THEN

    insert_into_hxc_absences (p_error_msg  => l_err_msg,
    			     p_abs_info  	=> hxc_abs_tab);

 END IF;
-- change end

/*Bug fix for 3353252, End the concurrent request in warning and Throw a warning message if the alternate names are
modified.Here we are concatenating all the warning messages.*/
  IF l_alt_name_change='Y' then
      -- Set retcode to 1, indicating a WARNING to the ConcMgr
	  p_errcode := c_warning;
	  fnd_file.put_line (fnd_file.LOG, l_name );
	  fnd_file.put_line (fnd_file.LOG, l_warning_string);
	  fnd_file.put_line (fnd_file.LOG, l_warning_string1);
--	  null;
  END IF;
/*end of fix for 3353252*/

/*
  Ok next create the key flexfield information

  First fetch all the information from the key flex tables

*/

  fnd_flex_key_api.set_session_mode('seed_data');


FOR i in 1..4 LOOP

  l_generate := FALSE;

if ((i=1) AND (p_generate_cost = 'Y')) then
    l_key_app := 'PAY';
    l_key_flex_code := 'COST';
    l_generate := TRUE;
elsif ((i=2) AND (p_generate_group = 'Y')) then
    l_key_app := 'PAY';
    l_key_flex_code := 'GRP';
    l_generate := TRUE;
elsif ((i=3) AND (p_generate_job = 'Y')) then
    l_key_app := 'PER';
    l_key_flex_code := 'JOB';
    l_generate := TRUE;
elsif ((i=4) AND (p_generate_pos = 'Y')) then
    l_key_app := 'PER';
    l_key_flex_code := 'POS';
    l_generate := TRUE;
end if;

if l_generate then

l_max_segment_count := 0;
l_key_flex_structure_count :=0;

--
-- Create the dummy element context and mappings
--
  create_dummy_context(
      p_appl_short_name => l_appl_short_name,
      p_flexfield_name => l_flexfield_name,
      p_context_name => l_key_flex_code,
      p_segment_name_prefix=>initcap(l_key_flex_code)||'Segment',
      p_max_segments => 30
           );

  l_key_flex := fnd_flex_key_api.find_flexfield(
                          appl_short_name => l_key_app
                         ,flex_code => l_key_flex_code);

/*
  Next fetch all the stuctures associated with this
  flexfield
*/


  fnd_flex_key_api.get_structures(flexfield => l_key_flex,
                             enabled_only => TRUE,
                             nstructures => l_structures,
                             structures => l_key_structure_list);

  l_structure_count := l_key_structure_list.first;

  LOOP

     EXIT WHEN not l_key_structure_list.exists(l_structure_count);

/*
   If the context exists, delete it and recreate otherwise just create it
*/

     if FND_FLEX_DSC_API.context_exists(
          P_APPL_SHORT_NAME => l_appl_short_name,
          P_FLEXFIELD_NAME => l_flexfield_name,
          P_CONTEXT_CODE => l_key_flex_code||' - '
                            ||to_char(l_key_structure_list(l_structure_count))
        ) then
       FND_FLEX_DSC_API.delete_context(
           APPL_SHORT_NAME => l_appl_short_name,
           FLEXFIELD_NAME => l_flexfield_name,
           CONTEXT => l_key_flex_code||' - '
                            ||to_char(l_key_structure_list(l_structure_count)));

     end if; -- Does this context exist?

/*
   Get information about the structure
*/

   l_key_structure := FND_FLEX_KEY_API.find_structure(
                         flexfield => l_key_flex,
                         structure_number => l_key_structure_list(l_structure_count));

    FND_FLEX_DSC_API.create_context(
        APPL_SHORT_NAME => l_appl_short_name,
        FLEXFIELD_NAME => l_flexfield_name,
        CONTEXT_CODE => l_key_flex_code||' - '
                        ||to_char(l_key_structure_list(l_structure_count)),
        CONTEXT_NAME => l_key_structure.structure_code,
        DESCRIPTION => 'Auto generated HXC '||l_key_flex_code||' context',
        ENABLED => 'Y',
        GLOBAL_FLAG => 'N');

   l_key_flex_structure_count := l_key_flex_structure_count +1;

--
-- Create the Building block information type for this context
--
    l_building_block_info_id := create_bld_blk_info_type(
            p_appl_short_name => l_appl_short_name,
            p_flexfield_name => l_flexfield_name,
            p_legislation_code => NULL,
            p_bld_blk_info_type =>l_key_flex_code||' - '
                        ||to_char(l_key_structure_list(l_structure_count)),
            p_category => l_key_flex_code);

/*
  Now, fetch the key flex segment information, and recreate the segments
  in the descriptive flexfield case
*/

  fnd_flex_key_api.get_segments(flexfield => l_key_flex,
                             structure => l_key_structure,
                             enabled_only => TRUE,
                             nsegments => l_segments,
                             segments => l_key_segment_list);

  l_segment_count := l_key_segment_list.first;

  LOOP

     EXIT WHEN not l_key_segment_list.exists(l_segment_count);
/*
  Get information about this segment
*/
     l_key_segment := FND_FLEX_KEY_API.find_segment(
                         flexfield => l_key_flex,
                         structure => l_key_structure,
                         segment_name => l_key_segment_list(l_segment_count));
/*
  Create the descriptive flexfield segment for this corresponding segment
*/

    FND_FLEX_DSC_API.create_segment(
      APPL_SHORT_NAME => l_appl_short_name,
      FLEXFIELD_NAME => l_flexfield_name,
      CONTEXT_NAME => l_key_flex_code||' - '
                        ||to_char(l_key_structure_list(l_structure_count)),
      NAME => valid_segment_name(l_key_segment.segment_name,l_key_flex_code,l_key_structure_list(l_structure_count)),
      COLUMN => 'ATTRIBUTE'||to_char(l_segment_count),
      DESCRIPTION => 'Auto generated HXC '||l_key_flex_code||' context segment',
      SEQUENCE_NUMBER => l_key_segment.segment_number,
      ENABLED => 'N',
      DISPLAYED => 'N',
      VALUE_SET => find_value_set(l_key_segment.value_set_id),
      DEFAULT_TYPE => l_key_segment.default_type,
      DEFAULT_VALUE => l_key_segment.default_value,
      REQUIRED => l_key_segment.required_flag,
      SECURITY_ENABLED => l_key_segment.security_flag,
      DISPLAY_SIZE => l_key_segment.display_size,
      DESCRIPTION_SIZE => l_key_segment.description_size,
      CONCATENATED_DESCRIPTION_SIZE => l_key_segment.concat_size,
      LIST_OF_VALUES_PROMPT => l_key_segment.lov_prompt,
      WINDOW_PROMPT => l_key_segment.window_prompt,
      RANGE => NULL,
      SRW_PARAMETER => NULL);

     l_segment_count := l_key_segment_list.next(l_segment_count);
  END LOOP;

  if l_max_segment_count < l_segment_count then
     l_max_segment_count := l_segment_count;
  end if;

   l_structure_count := l_key_structure_list.next(l_structure_count);

  END LOOP;

end if; -- should we generate on this pass.

END LOOP;

--
-- Do we need to check for missing types and
-- usages?  We are always going to do this now
--

  create_missing_type_usages(
       p_appl_short_name => 'HXC'
      ,p_flex_name => l_flexfield_name);

  if p_generate_prj = 'Y' then

  create_dummy_context(
      p_appl_short_name => l_appl_short_name,
      p_flexfield_name => l_flexfield_name,
      p_context_name => 'PAEXPITDFF',
      p_segment_name_prefix=>'PADFFAttribute',
      p_max_segments => 10
           );

--
-- Next loop through all the projects contexts,
-- and create the information types and usages
--
  duplicate_desc_flex
     (p_appl_short_name => 'PA',
      p_flexfield_name => 'PA_EXPENDITURE_ITEMS_DESC_FLEX',
      p_otc_appl_short_name => 'HXC',
      p_otc_flex_name => l_flexfield_name,
      p_context_prefix => 'PAEXPITDFF',
      p_preserve => true
      );

  include_mapping_components('PAEXPITDFF');

  end if; -- are we generating mappings for the projects flex?

end if; -- are we undoing?

--
-- This next section updates preference definitions from the
-- flex definition of OTC PREFERENCES
--

   create_preference_definitions(
       p_flex_name => 'OTC PREFERENCES'
      ,p_appl_short_name => 'HXC'
      );


commit;

/*
Added for 8645021 HR OTL Absence Integration

Calling the Error msg

EXCEPTION
WHEN PROFILE_NOT_SET THEN
     FND_MESSAGE.SET_NAME ('HXC', 'HXC_ABS_PROF_PARAM_MISMATCH');
      l_temp_msg:=FND_MESSAGE.GET();
      fnd_file.put_line(fnd_file.log,l_temp_msg);
      RAISE;
*/

END run_process;

END hxc_create_flex_mappings;

/
