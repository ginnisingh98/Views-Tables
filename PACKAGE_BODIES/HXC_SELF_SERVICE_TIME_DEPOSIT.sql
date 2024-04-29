--------------------------------------------------------
--  DDL for Package Body HXC_SELF_SERVICE_TIME_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SELF_SERVICE_TIME_DEPOSIT" AS
/* $Header: hxctcdpwr.pkb 120.6 2006/03/23 23:20:44 sgadipal noship $ */

g_debug boolean := hr_utility.debug_enabled;
--AI7
TYPE t_mapping_comp IS RECORD
(segment                 hxc_mapping_components.segment%TYPE,
field_name               hxc_mapping_components.field_name%TYPE,
bld_blk_info_type_id     hxc_mapping_components.bld_blk_info_type_id%TYPE,
bld_blk_info_type        hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
building_block_category  hxc_bld_blk_info_type_usages.building_block_category%TYPE);

TYPE t_mapping IS TABLE OF
  t_mapping_comp
INDEX BY BINARY_INTEGER;
--AI7

-- Bug 2384849

TYPE t_bld_blk_info_types IS TABLE OF
  HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE
INDEX BY BINARY_INTEGER;

TYPE timecard_block_order IS TABLE OF
    NUMBER
    INDEX BY BINARY_INTEGER;

TYPE retrieval_ref_cursor IS REF CURSOR;

g_attributes building_block_attribute_info;
g_messages message_table;
g_timecard timecard_info;
g_app_attributes app_attributes_info;
g_timecard_block_order timecard_block_order;
g_update_phase BOOLEAN := FALSE;
g_max_messages_displayed NUMBER:= 30;
g_bg_id number;  --AI8
g_org_id number; --AI8
g_allow_error_tc boolean;

g_deposit_mapping t_mapping; --AI7
g_deposit_process_id number; --AI7
g_retrieval_mapping t_mapping; --AI7
g_retrieval_process_id number; --AI7

g_debug_count NUMBER :=0;
g_workflow workflow_info;
g_time_attribute_id NUMBER :=0;
g_security_type_id NUMBER := 0;

g_package VARCHAR2(72) := 'HXC_SELF_SERVICE_TIME_DEPOSIT';
g_new_bbs VARCHAR2(2) := 'N';

-- Bug 2384349
g_bld_blk_info_types t_bld_blk_info_types;
g_queried_blk_info_types VARCHAR2(32000);
-- End Bug 2384349

e_approval_check EXCEPTION;
e_timecard_overlap EXCEPTION;
e_template_duplicate_name EXCEPTION;


g_resource_assignment_id NUMBER;

--AI7 routine to get information about a particular mapping component, given the field name.

PROCEDURE mapping_comp_info(p_field_name IN VARCHAR2,
                            p_mapping_component OUT NOCOPY t_mapping_comp,
                            p_mapping IN t_mapping)
IS

l_index number;

BEGIN


l_index := p_mapping.first;
LOOP
  EXIT WHEN NOT p_mapping.exists(l_index);
  IF(p_mapping(l_index).field_name = p_field_name) THEN
   if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.mapping_comp_info',
                   'Found Mapping:'||p_mapping(l_index).field_name);
   end if;
    p_mapping_component.field_name              := p_mapping(l_index).field_name;
    p_mapping_component.segment                 := p_mapping(l_index).segment;
    p_mapping_component.bld_blk_info_type_id    := p_mapping(l_index).bld_blk_info_type_id;
    p_mapping_component.bld_blk_info_type       := p_mapping(l_index).bld_blk_info_type;
    p_mapping_component.building_block_category := p_mapping(l_index).building_block_category;
    return;
  END IF;

  l_index := p_mapping.next(l_index);
END LOOP;

if(FND_LOG.LEVEL_ERROR>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	fnd_log.string(FND_LOG.LEVEL_ERROR,
               'hxc_self_service_time_deposit.mapping_comp_info',
               'Failed to find mapping'||p_field_name);
end if;

END mapping_comp_info;
-- Bug 2384849

FUNCTION cache_bld_blk_info_types
           (p_info_type in HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE) RETURN NUMBER is

l_bld_blk_id HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE_ID%TYPE;
l_count NUMBER;
l_found BOOLEAN := FALSE;

BEGIN

  if(instr(g_queried_blk_info_types,p_info_type)>0) then

    -- We know we've got the id, so look in the cached table

    l_count := g_bld_blk_info_types.first;

    LOOP

      EXIT WHEN ((NOT g_bld_blk_info_types.exists(l_count)) OR (l_found));

      if(g_bld_blk_info_types(l_count) = p_info_type) then
        l_bld_blk_id := l_count;
      end if;
      l_count := g_bld_blk_info_types.next(l_count);

    END LOOP;

  else

    -- Go to the db!

    select bld_blk_info_type_id into l_bld_blk_id
      from hxc_bld_blk_info_types
     where bld_blk_info_type = p_info_type;

    -- add this to the queried string!
    -- (not yet, we'll count the number of times the SQL is executed)

    g_queried_blk_info_types :=
      g_queried_blk_info_types ||'#'|| p_info_type;
    g_bld_blk_info_types(l_bld_blk_id) := p_info_type;

  end if;

return l_bld_blk_id;

EXCEPTION
  WHEN NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('HXC','HXC_NO_BLD_BLK_INFO_TYPE');
    FND_MESSAGE.SET_TOKEN('TYPE',p_info_type);
    FND_MESSAGE.raise_error;

END cache_bld_blk_info_types;

-- AI7 Routine make sure that we have the mapping components for the specified mapping
-- in memory. If not, it gets them.
-- Should be used before an attempt to access mapping structures is made.

PROCEDURE cache_mappings(p_deposit_process_id in number,
                         p_retrieval_process_id in number)
IS

l_index NUMBER;

CURSOR csr_retrieval_mapping(p_retrieval_process_id NUMBER)
IS
select mc.segment,
       mc.field_name,
       bbui.building_block_category,
       bbit.bld_blk_info_type_id,
       bbit.bld_blk_info_type
from hxc_mapping_components mc
    ,hxc_mapping_comp_usages mcu
    ,hxc_mappings m
    ,hxc_retrieval_processes rp
    ,hxc_bld_blk_info_types bbit
    ,hxc_bld_blk_info_type_usages bbui
where rp.mapping_id = m.mapping_id
  and rp.retrieval_process_id = p_retrieval_process_id
  and m.mapping_id = mcu.mapping_id
  and mcu.mapping_component_id = mc.mapping_component_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id;

CURSOR csr_deposit_mapping(p_deposit_process_id NUMBER)
IS
select mc.segment,
       mc.field_name,
       bbui.building_block_category,
       bbit.bld_blk_info_type_id,
       bbit.bld_blk_info_type
from hxc_mapping_components mc
    ,hxc_mapping_comp_usages mcu
    ,hxc_mappings m
    ,hxc_deposit_processes dp
    ,hxc_bld_blk_info_types bbit
    ,hxc_bld_blk_info_type_usages bbui
where dp.mapping_id = m.mapping_id
  and dp.deposit_process_id =  p_deposit_process_id
  and m.mapping_id = mcu.mapping_id
  and mcu.mapping_component_id = mc.mapping_component_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id;

BEGIN

l_index:=0;

if(p_deposit_process_id is not null) then
  -- cache if different than mapping already held
  if(nvl(g_deposit_process_id,-1) <> p_deposit_process_id) then
    -- load deposit process
   if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'HXC_SELF_SERVICE_TIME_DEPOSIT',
                   'Loading Deposit Process');
   end if;
    g_deposit_process_id := p_deposit_process_id;

    for dep_mapping_comp in csr_deposit_mapping(p_deposit_process_id) loop
    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     'HXC_SELF_SERVICE_TIME_DEPOSIT.CACHE_MAPPINGS',
                     'Field Name'||dep_mapping_comp.field_name);
      end if;

      g_deposit_mapping(l_index).segment                     := dep_mapping_comp.segment;
      g_deposit_mapping(l_index).field_name                  := dep_mapping_comp.field_name;
      g_deposit_mapping(l_index).building_block_category     := dep_mapping_comp.segment;
      g_deposit_mapping(l_index).bld_blk_info_type_id        := dep_mapping_comp.bld_blk_info_type_id;
      g_deposit_mapping(l_index).bld_blk_info_type           := dep_mapping_comp.bld_blk_info_type;
      l_index:=l_index+1;
    end loop;
  end if;
end if;

if(p_retrieval_process_id is not null) then
  -- cache if different than mapping already held
  if(nvl(g_retrieval_process_id,-1) <> p_retrieval_process_id) then
  -- load retrieval process
   if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'HXC_SELF_SERVICE_TIME_DEPOSIT.CACHE_MAPPINGS',
                   'Loading Retrieval Process');
  end if;
    g_retrieval_process_id := p_retrieval_process_id;

    for ret_mapping_comp in csr_retrieval_mapping(p_retrieval_process_id) loop
     if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     'HXC_SELF_SERVICE_TIME_DEPOSIT.CACHE_MAPPINGS',
                     'Field Name'||ret_mapping_comp.field_name);
     end if;

      g_retrieval_mapping(l_index).segment                     := ret_mapping_comp.segment;
      g_retrieval_mapping(l_index).field_name                  := ret_mapping_comp.field_name;
      g_retrieval_mapping(l_index).building_block_category     := ret_mapping_comp.segment;
      g_retrieval_mapping(l_index).bld_blk_info_type_id        := ret_mapping_comp.bld_blk_info_type_id;
      g_retrieval_mapping(l_index).bld_blk_info_type           := ret_mapping_comp.bld_blk_info_type;
      l_index:=l_index+1;
    end loop;
  end if;
end if;

END cache_mappings;

/*
--
-- Debug procedure
--
-- Used in conjuction with a temporary table to locate
-- debugging information when there is a problem
-- with submission of a timecard
--

PROCEDURE debug
           (p_procedure IN VARCHAR2
           ,p_reference IN NUMBER
           ,p_text IN VARCHAR2
           ,p_resource_id in NUMBER
           ) IS

l_loc VARCHAR2(70) := 'HXC_SELF_SERVICE_TIME_DEPOSIT.'|| p_procedure;

BEGIN

g_debug_count := g_debug_count + 1;

if (p_resource_id = 11999) then

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
/*
PROCEDURE debug
           (p_procedure IN VARCHAR2
           ,p_reference IN NUMBER
           ,p_text IN VARCHAR2
           ) IS

l_loc VARCHAR2(70) := 'HXC_SELF_SERVICE_TIME_DEPOSIT.'|| p_procedure;

BEGIN

g_debug_count := g_debug_count + 1;

if (g_timecard(1).resource_id = 11785) then

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
FUNCTION update_required(p_old IN VARCHAR2
                        ,p_new IN VARCHAR2) RETURN BOOLEAN IS

BEGIN

IF ((p_old <> p_new)
 OR((p_old IS null) AND (p_new IS NOT NULL))
 OR((p_old IS NOT NULL) AND (p_new IS null))) THEN
   RETURN TRUE;
ELSE
   RETURN FALSE;
END IF;

END update_required;

function find_parent_start_date
          (p_block_number in number) return DATE is

l_block_count NUMBER;
l_found BOOLEAN := FALSE;
l_date DATE;

BEGIN

l_block_count := g_timecard.first;

LOOP
 EXIT WHEN ((NOT g_timecard.exists(l_block_count)) OR (l_found));

 if(g_timecard(l_block_count).time_building_block_id
     = g_timecard(p_block_number).parent_building_block_id) then

   l_found := true;
   l_date := g_timecard(l_block_count).start_time;

 end if;

 l_block_count := g_timecard.next(l_block_count);

END LOOP;

return l_date;


END find_parent_start_date;
--
-- ---------------------------------------------------------
-- ---------------------------------------------------------
-- find_approval_status
--
--   Called internally only.
--
-- The function determines the approval status of the latest
-- block record associated with this parent.
--
-- ---------------------------------------------------------
-- ---------------------------------------------------------

FUNCTION find_approval_status
           (p_resource_id in NUMBER
           ,p_day_date in DATE
           ) return VARCHAR2 is

cursor c_approval_status
        (p_r_id in NUMBER
        ,p_date in DATE) is
  select approval_status
    from hxc_time_building_blocks
   where resource_id = p_r_id
     and scope = 'APPLICATION_PERIOD'
     and approval_status = 'APPROVED'
     and p_date between start_time and stop_time
     and NOT exists
     (select 'Y'
          from hxc_time_building_blocks
   where resource_id = p_r_id
     and scope = 'APPLICATION_PERIOD'
     and date_to = hr_general.end_of_time
     and approval_status = 'REJECTED'
     and p_date between start_time and stop_time
     );

l_return HXC_TIME_BUILDING_BLOCKS.APPROVAL_STATUS%TYPE;

BEGIN

open c_approval_status(p_resource_id, p_day_date);
fetch c_approval_status into l_return;

if c_approval_status%NOTFOUND then
  l_return := 'NOT_APPROVED';
end if;

close c_approval_status;

return l_return;

END find_approval_status;
--
-- ----------------------------------------------------------
-- ----------------------------------------------------------
-- check_details_exist_on_day
--
--   Called internally only.
--
--   This function checks to see if there are any details
-- bound to an existing day that has been approved.  If so,
-- and if the preference so forbids it, the user can not
-- enter additional details for a day.
--
-- ----------------------------------------------------------
-- ----------------------------------------------------------

FUNCTION check_details_exist_on_day
           (p_block_number in NUMBER) return BOOLEAN is

l_block NUMBER;
l_return BOOLEAN := false;

BEGIN

  l_block := g_timecard.first;

  LOOP
    EXIT WHEN ((NOT g_timecard.exists(l_block)) OR (l_return));
    --
    -- Check that the parent of the detail block we're checking
    -- is the same as an existing block - i.e. we already have a
    -- detail attached to this day
    --

    if (
        (g_timecard(p_block_number).parent_building_block_id
          = g_timecard(l_block).parent_building_block_id)
       AND
        (l_block <> p_block_number)
       AND
        (g_timecard(l_block).new = 'N')
       ) then

       l_return := true;

    end if;

    l_block := g_timecard.next(l_block);

  END LOOP;

  return l_return;

END check_details_exist_on_day;

FUNCTION is_working_status
          (p_block_number in NUMBER) RETURN BOOLEAN IS

cursor csr_working
        (p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE) is
  select approval_status
    from hxc_time_building_blocks
   where time_building_block_id = p_time_building_block_id
     and date_to = hr_general.end_of_time
     and approval_status = 'WORKING';

l_status HXC_TIME_BUILDING_BLOCKS.APPROVAL_STATUS%TYPE;

BEGIN

open csr_working(g_timecard(p_block_number).time_building_block_id);
fetch csr_working into l_status;

if (csr_working%FOUND) then
  close csr_working;
  return true;
else
  close csr_working;
  return false;
end if;

END is_working_status;
--
-- ----------------------------------------------------------
-- ----------------------------------------------------------
-- Check active day
--
--   Called internally only
--
--   This function makes sure that the detail entry is
-- entered on a day for which the user has an active
-- assignment.
--
-- ----------------------------------------------------------
-- ----------------------------------------------------------

FUNCTION check_active_date
           (p_date in DATE
           ,p_person_id in NUMBER) return BOOLEAN is

cursor c_date
       (p_check_date in DATE
       ,p_resource_id in NUMBER) is
    SELECT 'Y'
      FROM PER_ALL_ASSIGNMENTS_F paa,
           per_assignment_status_types typ
     WHERE paa.PERSON_ID = p_resource_id
       AND paa.ASSIGNMENT_TYPE = 'E'
       AND paa.PRIMARY_FLAG = 'Y'
       AND paa.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS = 'ACTIVE_ASSIGN'
       AND p_check_date between paa.effective_start_date and paa.effective_end_date;

l_dummy VARCHAR(5);

BEGIN

open c_date(p_date,p_person_id);
fetch c_date into l_dummy;

if c_date%FOUND then

  close c_date;
  return true;

else

  close c_date;
  return false;

end if;

END check_active_date;

--
-- ----------------------------------------------------------
-- ----------------------------------------------------------
-- check_approval_locked
--
--   Called internally only
--
--   This functions looks at the preference that determines
-- whether a user is permitted to update a building block
-- that has been previously approved.
--
-- ----------------------------------------------------------
-- ----------------------------------------------------------

FUNCTION check_approval_locked
           (p_block in number) return BOOLEAN is

l_return BOOLEAN := false;
l_parent_start_date DATE;
l_resource_start_date DATE;
l_resource_end_date DATE;
l_pref_val HXC_PREF_HIERARCHIES.ATTRIBUTE16%TYPE;
l_pref_detail_val HXC_PREF_HIERARCHIES.ATTRIBUTE17%TYPE;
l_previous_status HXC_TIME_BUILDING_BLOCKS.APPROVAL_STATUS%TYPE;
l_proc VARCHAR2(32) := 'CHECK_APPROVAL_LOCKED';

BEGIN

if(NOT is_working_status(p_block)) then

  l_parent_start_date := find_parent_start_date(p_block);
     --
     -- Check that the resource is allowed to enter time on this
     -- day.  This avoids problems with mid-period terms or hires
     --

     if(check_active_date(l_parent_start_date,g_timecard(p_block).resource_id)) then
       --
       -- Check the day preference value
       --
          l_pref_val := hxc_preference_evaluation.resource_preferences
                          (g_timecard(p_block).resource_id
                          ,'TC_W_TCRD_ST_ALW_EDITS'
                          ,16
                          ,l_parent_start_date
                          );

          if( l_pref_val = 'N') then
          --
          -- Find the approval status of the parent
          --

            l_previous_status := find_approval_status
                                   (g_timecard(p_block).resource_id
                                   ,l_parent_start_date);

            if (l_previous_status = 'APPROVED') then

              if(g_timecard(p_block).new <> 'Y') then

                -- Not allowed to change this block
                l_return := true;

              else

                if(check_details_exist_on_day(p_block)) then

                  l_return := true;

                else

                  l_return := false;

                end if;

              end if;

           end if;
         end if;

         if((NOT l_return) AND (g_timecard(p_block).new <> 'Y'))then
         --
         -- Check the detail preference value
         --
           l_pref_detail_val := hxc_preference_evaluation.resource_preferences
                                 (g_timecard(p_block).resource_id
                                 ,'TC_W_TCRD_ST_ALW_EDITS'
                                 ,17
                                 ,l_parent_start_date
                                 );

           if((l_pref_detail_val = 'N') AND (l_pref_val <> 'N')) then
               --
               -- Find the approval status of the parent
               --

               l_previous_status := find_approval_status
                                     (g_timecard(p_block).resource_id
                                     ,l_parent_start_date);

               if(l_previous_status = 'APPROVED') then

                 -- Not allowed to change this block!

                 l_return := true;

               end if;
           end if;

         end if; -- Do we need to check the detail when not new
         --
         --
     else

        hxc_time_entry_rules_utils_pkg.add_error_to_table (
                                p_message_table => g_messages
                        ,       p_message_name  => 'HXC_DETAIL_NON_ACTIVE'
                        ,       p_message_token => NULL
                        ,       p_message_level => 'ERROR'
                        ,       p_message_field         => NULL
                        ,       p_timecard_bb_id        => g_timecard(p_block).time_building_block_id
                        ,       p_timecard_bb_ovn    => g_timecard(p_block).object_version_number	--added 2822462
                        ,       p_time_attribute_id     => NULL);

     end if;

end if;

return l_return;

End check_approval_locked;

--
-- ----------------------------------------------------------
-- ----------------------------------------------------------
-- Process Block
--    Called privately only
--
--    This function works out whether a block should be
--  passed to the deposit process.
-- ----------------------------------------------------------
-- ----------------------------------------------------------

function process_block
          (p_block_number in number
          ,p_mode in VARCHAR2
          ,p_tk BOOLEAN) return BOOLEAN is

cursor csr_old_block
         (p_time_building_block_id in number
         ,p_ovn in number) is
  select *
    from hxc_time_building_blocks
   where time_building_block_id = p_time_building_block_id
     and object_version_number = p_ovn;

block_rec HXC_TIME_BUILDING_BLOCKS%ROWTYPE;

l_process BOOLEAN := false;
l_not_just_approval_status BOOLEAN := false;
l_pref_val HXC_PREF_HIERARCHIES.ATTRIBUTE16%TYPE;
l_proc varchar2(32) := 'process_block';
l_parent_date DATE;


BEGIN

--
-- Check end date first!
--
if (
    (g_timecard(p_block_number).date_to = hr_general.end_of_time)
   AND
    (p_mode = 'UPDATE')
   ) then

--
-- Check if it is a new block
--

if (g_timecard(p_block_number).new = 'Y') then

  l_not_just_approval_status := true;

  if (g_timecard(p_block_number).scope = 'DETAIL') then

   if (g_timecard(p_block_number).type = 'RANGE') then

     if(
         (
           (g_timecard(p_block_number).start_time is NOT NULL)
          OR
           (g_timecard(p_block_number).start_time <> '')
         )
       AND
         (
           (g_timecard(p_block_number).stop_time is NOT NULL)
          OR
           (g_timecard(p_block_number).stop_time <> '')
         )
       ) then

         l_process := true;
      else
        l_process := false;
      end if;
   else
     -- It's a measure, so measure had better not be null!
     if(
        (g_timecard(p_block_number).measure is NOT NULL)
       OR
        (g_timecard(p_block_number).measure <> -1)
       ) then
          l_process := true;
     else
       l_process := false;
     end if;

   end if;

  else

    l_process := true;

  end if;

else

  --
  -- Check existing block criteria
  --
  open csr_old_block(g_timecard(p_block_number).time_building_block_id
                    ,g_timecard(p_block_number).object_version_number);
  fetch csr_old_block into block_rec;
  if csr_old_block%NOTFOUND then
    --
    -- Must be a new block, how'd we get here?
    --
    l_process := true;

  else
    --
    -- Do the checks
    --

    if (update_required(g_timecard(p_block_number).measure,block_rec.measure))then
       l_process := true;
       l_not_just_approval_status := true;
    end if;

    if (g_timecard(p_block_number).start_time <> block_rec.start_time) then
      l_process := true;
       l_not_just_approval_status := true;
    end if;

    if (g_timecard(p_block_number).stop_time <> block_rec.stop_time) then
      l_process := true;
       l_not_just_approval_status := true;
    end if;

    if (update_required(g_timecard(p_block_number).comment_text,block_rec.comment_text)) then
      l_process := true;
       l_not_just_approval_status := true;
    end if;

    if (update_required(g_timecard(p_block_number).unit_of_measure,block_rec.unit_of_measure)) then
      l_process := true;
       l_not_just_approval_status := true;
    end if;

    if (update_required(g_timecard(p_block_number).approval_status,block_rec.approval_status)) then
      l_process := true;
    end if;

    if(update_required(g_timecard(p_block_number).parent_building_block_ovn, block_rec.parent_building_block_ovn)) then
      l_process := true;
    end if;

    --
    -- Check to see if we're deleting!
    --

    if ((g_timecard(p_block_number).measure is NULL)
      AND
       (g_timecard(p_block_number).start_time is NULL)
      AND
       (g_timecard(p_block_number).stop_time is NULL)
       ) then

      -- In this case we don't want to process the block through the deposit process
      -- But rather through the delete_block API.
      l_process := false;
       l_not_just_approval_status := true;

    end if;

  end if;
  close csr_old_block;

end if;

elsif ((g_timecard(p_block_number).date_to= hr_general.end_of_time)
     AND
       (p_mode = 'DELETE')) then
    --
    -- Here we are asking if a previously existing block
    -- should be deleted because it's parameters are
    -- nulled out
    --
    if ((g_timecard(p_block_number).measure is NULL)
      AND
       (g_timecard(p_block_number).start_time is NULL)
      AND
       (g_timecard(p_block_number).stop_time is NULL)
      AND
       (g_timecard(p_block_number).new <> 'Y')
       ) then

      -- Go ahead and delete the block

      l_process := true;
       l_not_just_approval_status := true;

    end if;

else

  if(p_mode='DELETE') then

    if (g_timecard(p_block_number).date_to <> hr_general.end_of_time) then

      l_process := true;
      l_not_just_approval_status := true;

    end if;

  end if;

end if;

if (NOT p_tk) then
if (l_process) then
 if(l_not_just_approval_status) then
   if(g_timecard(p_block_number).scope = 'DETAIL') then

    if(check_approval_locked(p_block_number)) then

        hxc_time_entry_rules_utils_pkg.add_error_to_table (
                                p_message_table => g_messages
                        ,       p_message_name  => 'HXC_NO_MODIFY_APPROVED_DETAIL'
                        ,       p_message_token => NULL
                        ,       p_message_level => 'ERROR'
                        ,       p_message_field         => NULL
                        ,       p_timecard_bb_id        => g_timecard(p_block_number).time_building_block_id
		        ,       p_timecard_bb_ovn   => g_timecard(p_block_number).object_version_number		--added 2822462
                        ,       p_time_attribute_id     => NULL);
/*
         IF ( hxc_timekeeper_errors.rollback_tc (
                 p_allow_error_tc => g_allow_error_tc
              ,  p_message_table  => g_messages
              ,  p_timecard       => g_timecard ) )
	THEN

		raise e_approval_check;

	END IF;
*/
    end if;
   end if;
 end if;
end if;
end if;

return l_process;

END process_block;

-- Procedure to check to see if blocks marked for update
-- are actually going to be updated in the database.
-- Blocks are marked for update by Time Sources. This
-- update may not acurrately reflect what will happen in the
-- database. For this reason we check and correct the the update
-- flag so that any Time Recipient Application validation will
-- get accurate information

PROCEDURE correct_update_flags(p_tk in BOOLEAN)
IS
l_block number;
--l_max_loop number:=0;
x number;


BEGIN
  if(FND_LOG.LEVEL_PROCEDURE>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  'HXC_SELF_SERVICE_TIME_DEPOSIT.CORRECT_UPDATE_FLAGS',
                  'Entering');
  end if;

-- loop over blocks in global (non-application) block structure
   l_block := g_timecard_block_order.first;

   LOOP
     EXIT WHEN NOT g_timecard_block_order.exists(l_block);
     x := g_timecard_block_order(l_block);

     -- for each block marked for update,
     -- use process_block to check to see if the  block will actually be updated

     if(g_timecard(x).changed='Y') then
       if(process_block(x,'UPDATE',p_tk) = FALSE) then

         g_timecard(x).changed:='N';

	if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                        'HXC_SELF_SERVICE_TIME_DEPOSIT.CORRECT_UPDATE_FLAGS',
                        'Updating CHANGED flag for tbbid:'||g_timecard(x).time_building_block_id);
        end if;

       end if;
     end if;

     l_block := g_timecard_block_order.next(l_block);

   END LOOP;


-- for each block marked for update,
--  use process_block to check to see if the  block will actually be updated


-- if block will not really be updated, set the update flag to N
-- as it must be the same as the orginal block

  if(FND_LOG.LEVEL_PROCEDURE>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  'HXC_SELF_SERVICE_TIME_DEPOSIT.CORRECT_UPDATE_FLAGS',
                  'Leaving');
  end if;

END correct_update_flags;


FUNCTION template_name_exists
           (p_resource_id in NUMBER
           ,p_name_to_check in VARCHAR2
           ,p_time_building_block_id in number
           ) return boolean is

cursor c_is_dynamic_template
        (p_name_to_check in varchar2) is
  select 'Y'
    from hr_lookups
   where lookup_type = 'HXC_DYNAMIC_TEMPLATES'
     and meaning = p_name_to_check;

cursor c_is_private_template
         (p_name_to_check in varchar2
         ,p_resoure_id in number
         ,p_time_building_block_id in number
         ) is
   select 'Y'
     from hxc_time_building_blocks tbb
         ,hxc_time_attribute_usages tau
         ,hxc_time_attributes ta
    where ta.time_attribute_id = tau.time_attribute_id
      and tau.time_building_block_id = tbb.time_building_block_id
      and tau.time_building_block_ovn = tbb.object_version_number
      and tbb.date_to = hr_general.end_of_time
      and ta.attribute_category = 'TEMPLATES'
      and ta.attribute2 = 'PRIVATE'
      and tbb.scope = 'TIMECARD_TEMPLATE'
      and tbb.time_building_block_id <> p_time_building_block_id
      and tbb.resource_id = p_resource_id
      and ta.attribute1 = p_name_to_check;

cursor c_is_public_template
        (p_name_to_check in varchar2
        ,p_time_building_block_id in number) is
  select 'Y'
     from hxc_time_building_blocks tbb
         ,hxc_time_attribute_usages tau
         ,hxc_time_attributes ta
    where ta.time_attribute_id = tau.time_attribute_id
      and tau.time_building_block_id = tbb.time_building_block_id
      and tau.time_building_block_ovn = tbb.object_version_number
      and tbb.date_to = hr_general.end_of_time
      and ta.attribute_category = 'TEMPLATES'
      and ta.attribute2 = 'PUBLIC'
      and tbb.scope = 'TIMECARD_TEMPLATE'
      and tbb.time_building_block_id <> p_time_building_block_id
      and ta.attribute1 = p_name_to_check;

l_proc VARCHAR2(30) := 'TEMPLATE_NAME_EXISTS';

l_dummy VARCHAR2(2);
value BOOLEAN := FALSE;

BEGIN

open c_is_dynamic_template(p_name_to_check);
fetch c_is_dynamic_template into l_dummy;
if c_is_dynamic_template%NOTFOUND then

  close c_is_dynamic_template;
  open c_is_private_template(p_name_to_check,p_resource_id,p_time_building_block_id);
  fetch c_is_private_template into l_dummy;
  if c_is_private_template%NOTFOUND then
    close c_is_private_template;
    open c_is_public_template(p_name_to_check,p_time_building_block_id);
    fetch c_is_public_template into l_dummy;
    if c_is_public_template%NOTFOUND then
      close c_is_public_template;
    else
      close c_is_public_template;
      value:=true;
    end if;
  else
    close c_is_private_template;
    value:=true;
  end if;
else
  close c_is_dynamic_template;
  value := true;
end if;

return value;

end template_name_exists;

PROCEDURE initialize_globals IS

l_counter BINARY_INTEGER;

BEGIN

IF g_attributes.count > 0 THEN

   g_attributes.delete;

END IF;

IF g_timecard.count >0 THEN

   g_timecard.delete;

END IF;

IF g_messages.count >0 THEN

   g_messages.delete;

END IF;

g_new_bbs := 'N';

FND_MSG_PUB.INITIALIZE;

END initialize_globals;

--
-- This procedure is called from the middle tier to
-- initialize the workflow information variables.
--
PROCEDURE set_workflow_info
            (p_item_type IN WF_ITEMS.ITEM_TYPE%TYPE
            ,p_process_name IN WF_ACTIVITIES.NAME%TYPE
            ) IS

l_proc VARCHAR2(30) := 'set_workflow_info';

BEGIN

g_workflow.item_type := p_item_type;
g_workflow.process_name := p_process_name;

END set_workflow_info;

PROCEDURE find_app_deposit_process
            (p_time_recipient_id IN HXC_TIME_RECIPIENTS.TIME_RECIPIENT_ID%TYPE
            ,p_app_function IN HXC_TIME_RECIPIENTS.APPLICATION_RETRIEVAL_FUNCTION%TYPE
            ,p_retrieval_process_id OUT NOCOPY NUMBER) IS

 c_ret_pro retrieval_ref_cursor;

 CURSOR c_retrieval_process
          (p_app IN HXC_TIME_RECIPIENTS.TIME_RECIPIENT_ID%TYPE
          ,p_process_name IN HXC_RETRIEVAL_PROCESSES.NAME%TYPE)
          IS
  SELECT retrieval_process_id
    FROM HXC_RETRIEVAL_PROCESSES
   WHERE name = p_process_name
     AND time_recipient_id = p_app;

 l_sql VARCHAR2(32000);
 l_app_process_name HXC_RETRIEVAL_PROCESSES.NAME%TYPE;
 l_proc VARCHAR2(30) := 'find_app_deposit_process';

 BEGIN

   --
   -- Build the SQL we need
   --
   l_sql := 'select '||p_app_function||' from dual';
   --
   -- Execute this using native dynamic SQL
   --

   OPEN c_ret_pro FOR l_sql;
   FETCH c_ret_pro INTO l_app_process_name;


   IF c_ret_pro%NOTFOUND THEN
     CLOSE c_ret_pro;
     FND_MESSAGE.SET_NAME('HXC','HXC_XXXXX_NO_APP_RET_PROC_NAME');
     FND_MSG_PUB.ADD;

   ELSE

     CLOSE c_ret_pro;

   END IF;
   --
   -- Next, find the process id we wish to use
   --

   OPEN c_retrieval_process
          (p_time_recipient_id
          ,l_app_process_name);

   FETCH c_retrieval_process INTO p_retrieval_process_id;

   IF c_retrieval_process%NOTFOUND THEN
     CLOSE c_retrieval_process;
     FND_MESSAGE.SET_NAME('HXC','HXC_XXXXX_NO_RET_PROC_BY_NAME');
     FND_MSG_PUB.ADD;

   ELSE

     CLOSE c_retrieval_process;

   END IF;

END find_app_deposit_process;

FUNCTION code_chk
           (p_code IN VARCHAR2) RETURN BOOLEAN IS

BEGIN

-- This change is done with respect to bug 4897975 wherein user_source is
-- being used for checking the existence of a package body.
-- Refer to TMSTask12613 for further analysis.

RETURN TRUE;

END code_chk;

PROCEDURE order_building_blocks IS

l_number_timecard_blocks NUMBER :=1;
l_timecard_start NUMBER :=1;
l_day_start NUMBER := l_timecard_start;
l_detail_start NUMBER := g_timecard.count;
l_block_count NUMBER :=0;
l_order_count NUMBER :=0;
l_proc VARCHAR2(70) := 'ORDER_BUILDING_BLOCKS';
l_block NUMBER;

BEGIN

l_block := g_timecard.first;

LOOP

  EXIT WHEN NOT g_timecard.exists(l_block);

  if ((g_timecard(l_block).scope = 'TIMECARD')
     OR (g_timecard(l_block).scope = 'TIMECARD_TEMPLATE')) then

    l_day_start := l_day_start +1;

    if(g_timecard(l_block).date_to = hr_general.end_of_time) then

      if(hxc_deposit_checks.chk_timecard_deposit
          (g_timecard
          ,l_block
          )
        ) then

        --
        -- We can't deposit this timecard, as it already exists!
        --

        fnd_message.set_name('HXC','HXC_OVERLAPPING_TIMECARDS');
        raise e_timecard_overlap;

      end if;

    end if;

  end if;
  l_block := g_timecard.next(l_block);

END LOOP;

--
-- Initialize the global record structure
-- if the count is greater than zero
--

if (g_timecard_block_order.count > 0) then


  g_timecard_block_order.delete;

end if;


l_block_count := g_timecard.first;

LOOP
  EXIT WHEN NOT g_timecard.exists(l_block_count);

  IF (g_timecard(l_block_count).scope = 'TIMECARD') THEN
    g_timecard_block_order(l_timecard_start) := l_block_count;
    l_timecard_start := l_timecard_start +1;
  elsif (g_timecard(l_block_count).scope = 'TIMECARD_TEMPLATE') then
    g_timecard_block_order(l_timecard_start) := l_block_count;
  ELSIF (g_timecard(l_block_count).scope = 'DAY') THEN
    g_timecard_block_order(l_day_start) := l_block_count;
    l_day_start := l_day_start +1;
  ELSIF (g_timecard(l_block_count).scope = 'DETAIL') THEN
    g_timecard_block_order(l_detail_start) := l_block_count;
    l_detail_start := l_detail_start -1;
  END IF;

  l_block_count := g_timecard.next(l_block_count);

END LOOP;

l_block := g_timecard_block_order.first;

END order_building_blocks;


FUNCTION find_block_index
           (p_attribute_number IN number)
           RETURN NUMBER IS
l_block NUMBER;
l_error VARCHAR(300);

BEGIN

  l_block := g_timecard.first;

  LOOP

   EXIT WHEN
     ( NOT g_timecard.exists(l_block))
     OR
     (g_timecard(l_block).time_building_block_id = g_attributes(p_attribute_number).building_block_id);

     l_block := g_timecard.next(l_block);

  END LOOP;

if l_block is null then
  fnd_message.set_name('HXC', 'HXC_XXXXX_NULL_IDX_BLOCK');
  fnd_msg_pub.add;
end if;

RETURN l_block;

EXCEPTION
  WHEN OTHERS THEN
      fnd_message.set_name('HXC', 'HXC_XXXXX_DEPOSIT_EXCEPTION');
      fnd_msg_pub.add;

END find_block_index;

FUNCTION valid_attribute(
           p_attribute_number IN NUMBER
             ) RETURN BOOLEAN IS

l_valid_attribute BOOLEAN := FALSE;
l_block_index NUMBER := find_block_index(p_attribute_number);
l_proc varchar2(32) := 'valid_attribute';

BEGIN

--dbms_output.put_line('L_BLOCK_INDEX'||l_block_index||'<<');
--dbms_output.put_line('NUMBER OF BLOCKS'||g_timecard.count);

if (l_block_index is null) then

 -- This is a serious exception.  We must raise the problem.
 -- not just add it to the stack!

    FND_MESSAGE.raise_error;

else

  IF g_timecard(l_block_index).scope <> 'DETAIL' THEN


  IF ((g_attributes(p_attribute_number).attribute1 is not NULL)
    AND
    (NOT l_valid_attribute)) THEN
    l_valid_attribute := TRUE;
  END IF;

  IF (g_attributes(p_attribute_number).attribute2 is not NULL)
    AND
     (NOT l_valid_attribute)
    THEN
    l_valid_attribute := TRUE;
  END IF;

  IF (g_attributes(p_attribute_number).attribute3 is not NULL)
     AND
      (NOT l_valid_attribute)
     THEN
    l_valid_attribute := TRUE;
  END IF;

  IF (g_attributes(p_attribute_number).attribute4 is not NULL)
     AND
      (NOT l_valid_attribute)
     THEN
    l_valid_attribute := TRUE;
  END IF;

IF (g_attributes(p_attribute_number).attribute5 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute6 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute7 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute8 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute9 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute10 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute11 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute12 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute13 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute14 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute15 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute16 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute17 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute18 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute19 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute20 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute21 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute22 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute23 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute24 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute25 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute26 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute27 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute28 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute29 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

IF (g_attributes(p_attribute_number).attribute30 is not NULL)
   AND
    (NOT l_valid_attribute)
   THEN
  l_valid_attribute := TRUE;
END IF;

ELSE

--
-- Slightly different for detail building blocks
--

 IF g_attributes(p_attribute_number).attribute_category IS NOT NULL THEN
  IF (g_timecard(l_block_index).date_to <> hr_general.end_of_time) THEN
    --
    -- We want to make sure that attributes that go with deleted blocks
    -- are also sent to the validation procdures
    --
    l_valid_attribute := TRUE;
  ELSE
    IF g_timecard(l_block_index).type = 'RANGE' THEN
      IF g_timecard(l_block_index).start_time IS NOT NULL THEN
         l_valid_attribute := TRUE;
      ELSE
         l_valid_attribute := FALSE;
      END IF;
    ELSE
      IF g_timecard(l_block_index).measure IS NOT NULL THEN
          l_valid_attribute := TRUE;
      ELSE
          l_valid_attribute := FALSE;
      END IF;
    END IF;
  END IF;
 ELSE
  l_valid_attribute := FALSE;
 END IF;

END IF; -- is the building block associated with this attribute DETAIL?

end if; -- do we have a valid block index

RETURN l_valid_attribute;

END valid_attribute;

FUNCTION build_application_attributes(
            p_retrieval_process_id IN NUMBER
           ,p_deposit_process_id   IN NUMBER        --AI3
           ,p_for_time_attributes  IN BOOLEAN
           ) RETURN app_attributes_info IS

l_app_attributes app_attributes_info;

CURSOR csr_mapping_components(p_retrieval_process_id NUMBER
                             ,p_attribute_category VARCHAR2)
IS
SELECT
  mc.segment,
  mc.field_name,
  bbui.building_block_category
FROM
  hxc_mapping_components mc,
  hxc_bld_blk_info_type_usages bbui,
  hxc_bld_blk_info_types bbit
WHERE
  mc.mapping_component_id in (Select mcu.mapping_component_id from
	hxc_mappings m      ,
	hxc_mapping_comp_usages mcu,
	hxc_retrieval_processes rp
		WHERE
		rp.mapping_id = m.mapping_id    and
		rp.retrieval_process_id = p_retrieval_process_id    and
		m.mapping_id = mcu.mapping_id    )

  AND
  mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id    AND
  bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id    AND
  bbit.bld_blk_info_type = p_attribute_category;

CURSOR csr_wtd_components(p_attribute_category VARCHAR2)
IS
select mc.segment, mc.field_name, bbui.building_block_category
from hxc_mapping_components mc
    ,hxc_mapping_comp_usages mcu
    ,hxc_mappings m
    ,hxc_deposit_processes dp
    ,hxc_bld_blk_info_types bbit
    ,hxc_bld_blk_info_type_usages bbui
where dp.mapping_id = m.mapping_id
  and dp.deposit_process_id = p_deposit_process_id    --AI3
  and m.mapping_id = mcu.mapping_id
  and mcu.mapping_component_id = mc.mapping_component_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id
  AND bbit.bld_blk_info_type = p_attribute_category;


l_attribute BINARY_INTEGER;
l_attribute_index BINARY_INTEGER :=0;
l_proc VARCHAR2(70) := 'BUILD_APPLICATION_ATTRIBUTES';
l_exception EXCEPTION;
l_attribute_category HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE;

BEGIN

 l_app_attributes.delete;

 l_attribute := g_attributes.first;

 LOOP
   EXIT WHEN NOT g_attributes.exists(l_attribute);
--
-- Check to see if we need this attribute
--
   IF valid_attribute(l_attribute) THEN

-- IF g_attributes(l_attribute).attribute_category IS NOT NULL THEN
--
-- Ok, inefficiency here.  We should get all the mapping
-- components into a structure for each of the different
-- types of attribute category, and loop through those,
-- rather than opening the cursor each time.
--
  IF p_for_time_attributes THEN

    FOR map_rec IN csr_wtd_components
                     (g_attributes(l_attribute).bld_blk_info_type) LOOP

--
-- Think of a way of doing this once, and not here and in build
-- timecard structure.  Continue here for the moment.
--
      l_attribute_index := l_attribute_index + 1;
      --
      l_app_attributes(l_attribute_index).time_attribute_id := g_attributes(l_attribute).time_attribute_id;
      l_app_attributes(l_attribute_index).building_block_id := g_attributes(l_attribute).building_block_id;
      l_app_attributes(l_attribute_index).category := map_rec.building_block_category;
      l_app_attributes(l_attribute_index).bld_blk_info_type := g_attributes(l_attribute).bld_blk_info_type;
      l_app_attributes(l_attribute_index).changed := g_attributes(l_attribute).changed;
      IF map_rec.segment = 'ATTRIBUTE1' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute1;
      ELSIF map_rec.segment = 'ATTRIBUTE2' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute2;
      ELSIF map_rec.segment = 'ATTRIBUTE3' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute3;
      ELSIF map_rec.segment = 'ATTRIBUTE4' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute4;
      ELSIF map_rec.segment = 'ATTRIBUTE5' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute5;
      ELSIF map_rec.segment = 'ATTRIBUTE6' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute6;
      ELSIF map_rec.segment = 'ATTRIBUTE7' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute7;
      ELSIF map_rec.segment = 'ATTRIBUTE8' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute8;
      ELSIF map_rec.segment = 'ATTRIBUTE9' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute9;
      ELSIF map_rec.segment = 'ATTRIBUTE10' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute10;
      ELSIF map_rec.segment = 'ATTRIBUTE11' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute11;
      ELSIF map_rec.segment = 'ATTRIBUTE12' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute12;
      ELSIF map_rec.segment = 'ATTRIBUTE13' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute13;
      ELSIF map_rec.segment = 'ATTRIBUTE14' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute14;
      ELSIF map_rec.segment = 'ATTRIBUTE15' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute15;
      ELSIF map_rec.segment = 'ATTRIBUTE16' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute16;
      ELSIF map_rec.segment = 'ATTRIBUTE17' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute17;
      ELSIF map_rec.segment = 'ATTRIBUTE18' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute18;
      ELSIF map_rec.segment = 'ATTRIBUTE19' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute19;
      ELSIF map_rec.segment = 'ATTRIBUTE20' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute20;
      ELSIF map_rec.segment = 'ATTRIBUTE21' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute21;
      ELSIF map_rec.segment = 'ATTRIBUTE22' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute22;
      ELSIF map_rec.segment = 'ATTRIBUTE23' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute23;
      ELSIF map_rec.segment = 'ATTRIBUTE24' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute24;
      ELSIF map_rec.segment = 'ATTRIBUTE25' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute25;
      ELSIF map_rec.segment = 'ATTRIBUTE26' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute26;
      ELSIF map_rec.segment = 'ATTRIBUTE27' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute27;
      ELSIF map_rec.segment = 'ATTRIBUTE28' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute28;
      ELSIF map_rec.segment = 'ATTRIBUTE29' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute29;
      ELSIF map_rec.segment = 'ATTRIBUTE30' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute30;
      ELSIF map_rec.segment = 'ATTRIBUTE_CATEGORY' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute_category;
      ELSE
         RAISE l_exception;
      END IF;

    END LOOP; -- mapping loop

  ELSE

    FOR map_rec IN csr_mapping_components
                     (p_retrieval_process_id
                     ,g_attributes(l_attribute).bld_blk_info_type) LOOP

--
-- Think of a way of doing this once, and not here and in build
-- timecard structure.  Continue here for the moment.
--
      l_attribute_index := l_attribute_index + 1;
      --
      l_app_attributes(l_attribute_index).time_attribute_id := g_attributes(l_attribute).time_attribute_id;
      l_app_attributes(l_attribute_index).building_block_id := g_attributes(l_attribute).building_block_id;
      l_app_attributes(l_attribute_index).category := map_rec.building_block_category;
      l_app_attributes(l_attribute_index).bld_blk_info_type := g_attributes(l_attribute).bld_blk_info_type;
      l_app_attributes(l_attribute_index).changed := g_attributes(l_attribute).changed;
      IF map_rec.segment = 'ATTRIBUTE1' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute1;
      ELSIF map_rec.segment = 'ATTRIBUTE2' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute2;
      ELSIF map_rec.segment = 'ATTRIBUTE3' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute3;
      ELSIF map_rec.segment = 'ATTRIBUTE4' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute4;
      ELSIF map_rec.segment = 'ATTRIBUTE5' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute5;
      ELSIF map_rec.segment = 'ATTRIBUTE6' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute6;
      ELSIF map_rec.segment = 'ATTRIBUTE7' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute7;
      ELSIF map_rec.segment = 'ATTRIBUTE8' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute8;
      ELSIF map_rec.segment = 'ATTRIBUTE9' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute9;
      ELSIF map_rec.segment = 'ATTRIBUTE10' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute10;
      ELSIF map_rec.segment = 'ATTRIBUTE11' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute11;
      ELSIF map_rec.segment = 'ATTRIBUTE12' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute12;
      ELSIF map_rec.segment = 'ATTRIBUTE13' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute13;
      ELSIF map_rec.segment = 'ATTRIBUTE14' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute14;
      ELSIF map_rec.segment = 'ATTRIBUTE15' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute15;
      ELSIF map_rec.segment = 'ATTRIBUTE16' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute16;
      ELSIF map_rec.segment = 'ATTRIBUTE17' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute17;
      ELSIF map_rec.segment = 'ATTRIBUTE18' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute18;
      ELSIF map_rec.segment = 'ATTRIBUTE19' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute19;
      ELSIF map_rec.segment = 'ATTRIBUTE20' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute20;
      ELSIF map_rec.segment = 'ATTRIBUTE21' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute21;
      ELSIF map_rec.segment = 'ATTRIBUTE22' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute22;
      ELSIF map_rec.segment = 'ATTRIBUTE23' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute23;
      ELSIF map_rec.segment = 'ATTRIBUTE24' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute24;
      ELSIF map_rec.segment = 'ATTRIBUTE25' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute25;
      ELSIF map_rec.segment = 'ATTRIBUTE26' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute26;
      ELSIF map_rec.segment = 'ATTRIBUTE27' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute27;
      ELSIF map_rec.segment = 'ATTRIBUTE28' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute28;
      ELSIF map_rec.segment = 'ATTRIBUTE29' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute29;
      ELSIF map_rec.segment = 'ATTRIBUTE30' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute30;
      ELSIF map_rec.segment = 'ATTRIBUTE_CATEGORY' THEN
         l_app_attributes(l_attribute_index).attribute_name   := map_rec.field_name;
         l_app_attributes(l_attribute_index).attribute_value  := g_attributes(l_attribute).attribute_category;
      ELSE
         RAISE l_exception;
      END IF;

    END LOOP; -- mapping loop

   END IF; -- Is this for time attributes

  END IF; -- Is this a viable attribute.

  l_attribute := g_attributes.next(l_attribute);

 END LOOP; -- attribute loop

 RETURN l_app_attributes;

END build_application_attributes;

FUNCTION get_new_attribute_id RETURN NUMBER IS

l_att_count NUMBER :=0;
l_proc VARCHAR2(30) := 'GET_NEW_ATTRIBUTE_ID';
l_low_value NUMBER :=0;


BEGIN

  IF g_time_attribute_id = 0 THEN

    --
    -- Find the last new time attribute id
    --

      l_att_count := g_attributes.first;

      LOOP
        EXIT WHEN NOT g_attributes.exists(l_att_count);

          IF l_low_value > g_attributes(l_att_count).time_Attribute_id THEN

            l_low_value := g_attributes(l_att_count).time_attribute_id;

          END IF;

        l_att_count := g_attributes.next(l_att_count);
      END LOOP;

      g_time_attribute_id := l_low_value-10000000;

  ELSE

    g_time_attribute_id := g_time_attribute_id -1;

  END IF;

RETURN g_time_attribute_id;

END get_new_attribute_id;

FUNCTION get_bld_blk_type_id(p_type IN varchar2) RETURN NUMBER IS

CURSOR csr_bld_blk_id(p_type IN varchar2) IS
  SELECT bld_blk_info_type_id
    FROM hxc_bld_blk_info_types
   WHERE bld_blk_info_type = p_type;

BEGIN

  IF g_security_type_id = 0 THEN

    OPEN csr_bld_blk_id(p_type);
    FETCH csr_bld_blk_id INTO g_security_type_id;

    IF csr_bld_blk_id%NOTFOUND THEN
      CLOSE csr_bld_blk_id;
      FND_MESSAGE.SET_NAME('HXC','HXC_XXXXX_NO_SECURITY_CONTEXT');
      fnd_msg_pub.add;

    END IF;

    CLOSE csr_bld_blk_id;

  END IF;

RETURN g_security_type_id;

END get_bld_blk_type_id;

FUNCTION attribute_check
           (p_to_check IN VARCHAR2
           ,p_time_building_block_id IN hxc_time_building_blocks.time_building_block_id%TYPE
           ) RETURN BOOLEAN IS

l_doesnt_exist BOOLEAN := TRUE;
l_attribute_count NUMBER;
l_proc VARCHAR2(30) := 'attribute_check';


BEGIN

l_attribute_count := g_attributes.first;

LOOP
  EXIT WHEN ((NOT g_attributes.exists(l_attribute_count)) OR (NOT l_doesnt_exist));

  IF (
     (g_attributes(l_attribute_count).building_block_id = p_time_building_block_id)
   AND
     (g_attributes(l_attribute_count).attribute_category = p_to_check)
     ) THEN
    if(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(1,'hxc_self_service_time_deposit.attribute_check',
                 ' Found the expected attribute');
    end if;

    l_doesnt_exist := FALSE;

  END IF;

  l_attribute_count := g_attributes.next(l_attribute_count);

END LOOP;

RETURN l_doesnt_exist;

END attribute_check;

--

PROCEDURE denormalize_time_info(p_mode in VARCHAR2) IS

l_index number;


BEGIN

if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_DENORMALIZE_BLOCK_INFO',
               'Enter denormalize_block_info, mode ='||p_mode);
end if;

-- note that we denormalise measure for ALL range start_time stop_times (regardless of scope)
-- note also that the UOM for these blocks is HOURS
-- This is done for ALL scopes of building blocks since we dont need to
-- start adding scope specific code.

l_index := g_timecard.first;

WHILE ( l_index IS NOT NULL ) LOOP

  IF (p_mode = 'ADD') THEN

    IF(g_timecard(l_index).type = 'RANGE' ) THEN
      g_timecard(l_index).measure:= (g_timecard(l_index).stop_time-g_timecard(l_index).start_time)*24;
      g_timecard(l_index).unit_of_measure:= 'HOURS';
      if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_DENORMALIZE_BLOCK_INFO',
                     'NEW MEASURE VAL '||g_timecard(l_index).measure ||
                     ' l_timecard_id :'||g_timecard(l_index).time_building_block_id);
      end if;
    END IF;

  ELSIF (p_mode = 'REMOVE') THEN

    IF(g_timecard(l_index).type = 'RANGE' ) THEN
      g_timecard(l_index).measure:= null;
      g_timecard(l_index).unit_of_measure:= null;
      if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_DENORMALIZE_BLOCK_INFO',
                     'NEW MEASURE VAL'||g_timecard(l_index).measure);
      end if;
    END IF;

  END IF;

  l_index := g_timecard.next(l_index);

END LOOP;

END denormalize_time_info;


--AI8
PROCEDURE set_security(p_validate_session IN BOOLEAN) IS

-- GPM v115.78

PRAGMA AUTONOMOUS_TRANSACTION;

l_defined BOOLEAN;
l_validate_session BOOLEAN;

BEGIN

-- Determine security information to be added where block has no security attribute
/*
if(p_validate_session) then     -- icx_sec.validateSession sets all the fnd profile values
--   l_validate_session := icx_sec.validateSession;
  null;
end if;
*/
-- Note that the global variables set here will be used by add_security

fnd_profile.get_specific('ORG_ID',null,null,null,g_org_id, l_defined);
g_bg_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

-- Both should be set, so raise an error if there is a problem
-- TO BE COMPLETED

END set_security;
--AI8



PROCEDURE add_security IS

l_last_attribute NUMBER;
l_block_count NUMBER;
l_create BOOLEAN := FALSE;
l_proc VARCHAR2(30) := 'ADD_SECURITY';
l_profile_org NUMBER;


BEGIN

-- 115.110 Change.

if (g_attributes.count >0) then
  l_last_attribute := g_attributes.last;
else
  l_last_attribute := 1;
end if;

-- End 115.110 Change.

--
-- Now for each building block, we need to add
-- a security attribute, highlighting the business group
-- id and org id
--

l_block_count := g_timecard.first;


LOOP
  EXIT WHEN NOT g_timecard.exists(l_block_count);
  l_last_attribute := l_last_attribute+1;

  --
  -- Create the time attribute for security for this block
  -- if a security context doesn't already exist
  --
  if(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
  fnd_log.string(1,'hxc_self_service_time_deposit.add_security',
                 ' tbb '||g_timecard(l_block_count).time_building_block_id);
  end if;

  l_create := attribute_check
                (p_to_check => 'SECURITY'
                ,p_time_building_block_id => g_timecard(l_block_count).time_building_block_id
                );


  IF l_create THEN


  if(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	fnd_log.string(1,'hxc_self_service_time_deposit.add_security',
                 ' Creating a security attribute!');
  end if;


     g_attributes(l_last_attribute).TIME_ATTRIBUTE_ID := get_new_attribute_id;

     g_attributes(l_last_attribute).BUILDING_BLOCK_ID := g_timecard(l_block_count).time_building_block_id;
     g_attributes(l_last_attribute).BLD_BLK_INFO_TYPE := 'SECURITY';
     g_attributes(l_last_attribute).ATTRIBUTE_CATEGORY := 'SECURITY';
     g_attributes(l_last_attribute).ATTRIBUTE1  := g_org_id;   -- AI8
     g_attributes(l_last_attribute).ATTRIBUTE2  := g_bg_id;    -- AI8
     g_attributes(l_last_attribute).ATTRIBUTE3  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE4  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE5  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE6  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE7  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE8  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE9  := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE10 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE11 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE12 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE13 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE14 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE15 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE16 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE17 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE18 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE19 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE20 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE21 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE22 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE23 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE24 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE25 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE26 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE27 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE28 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE29 := NULL;
     g_attributes(l_last_attribute).ATTRIBUTE30 := NULL;
     g_attributes(l_last_attribute).BLD_BLK_INFO_TYPE_ID := cache_bld_blk_info_types('SECURITY');
     g_attributes(l_last_attribute).OBJECT_VERSION_NUMBER  := 1;
     g_attributes(l_last_attribute).NEW := 'Y';

  END IF;

  l_block_count := g_timecard.next(l_block_count);

END LOOP;

EXCEPTION
  when others then
--    debug(l_proc,10,substr(SQLERRM,1,2000));
    FND_MESSAGE.SET_NAME('HXC','HXC_PROBLEM');
    FND_MESSAGE.SET_TOKEN('CLIENT_INFO',userenv('CLIENT_INFO'));
    FND_MESSAGE.SET_TOKEN('CLIENT_INFO_START',substr(userenv('CLIENT_INFO'),1,10));
    FND_MESSAGE.RAISE_ERROR;
END add_security;

FUNCTION replacement_attribute
           (p_block_number in number
           ,p_attribute_number in number) RETURN BOOLEAN is

l_return BOOLEAN := false;
l_tbb_id NUMBER := g_attributes(p_attribute_number).building_block_id;
l_bb_info HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE := g_attributes(p_attribute_number).bld_blk_info_type;
l_acount NUMBER;
l_proc VARCHAR2(35) := 'REPLACEMENT_ATTRIBUTE';

BEGIN

l_acount := g_attributes.first;

LOOP
  EXIT WHEN ((NOT g_attributes.exists(l_acount)) OR (l_return));

  if(
     (g_attributes(l_acount).NEW <> 'Y')
    AND
     (l_acount <> p_attribute_number)
    AND
     (g_attributes(l_acount).bld_blk_info_type = l_bb_info)
    AND
     (g_attributes(l_acount).building_block_id = l_tbb_id)
    ) then

    l_return := true;

  end if;

  l_acount := g_attributes.next(l_acount);

END LOOP;

return l_return;

END replacement_attribute;

PROCEDURE build_timecard_structure(
            p_block              IN     NUMBER
           ,p_deposit_process_id IN     NUMBER
           ,p_timecard           IN OUT NOCOPY hxc_time_attributes_api.timecard
           ,p_update_required    IN OUT NOCOPY BOOLEAN)
           IS
CURSOR csr_bb_attributes(p_time_attribute_id NUMBER,
                         p_ta_ovn NUMBER) IS
select *
  from hxc_time_attributes
 where time_attribute_id = p_time_attribute_id
   and (
         (object_version_number = p_ta_ovn)
       OR
         (p_ta_ovn IS NULL)
       );
--
CURSOR csr_mapping_components(p_deposit_process_id NUMBER
                             ,p_bbit_id NUMBER)
IS
select mc.segment, mc.field_name,bbit.bld_blk_info_type
from hxc_mapping_components mc
    ,hxc_mapping_comp_usages mcu
    ,hxc_mappings m
    ,hxc_deposit_processes dp
    ,hxc_bld_blk_info_types bbit
where dp.mapping_id = m.mapping_id
  and dp.deposit_process_id = p_deposit_process_id
  and m.mapping_id = mcu.mapping_id
  and mcu.mapping_component_id = mc.mapping_component_id
  and mc.bld_blk_info_type_id = p_bbit_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id;
--


l_attribute_index        NUMBER;
l_bld_blk_info_type_id   HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE_ID%TYPE;
l_bld_blk_info_type	 VARCHAR2(150);
l_proc                   VARCHAR2(30) := 'build_timecard_structure';
l_old_attribute          HXC_TIME_ATTRIBUTES%ROWTYPE;
l_exception              EXCEPTION;
l_att_count              NUMBER;
y                        NUMBER;
l_replacement            BOOLEAN := false;

BEGIN

      l_attribute_index := 0;

      p_update_required := FALSE;

--      FOR y IN 1 .. g_attributes.count LOOP

      y := g_attributes.first;

      LOOP
        EXIT WHEN NOT g_attributes.exists(y);
      --
      -- Check to see if this attribute record
      -- corresponds to the building block
      -- under current consideration.
      --

       if (g_attributes(y).building_block_id = g_timecard(p_block).time_building_block_id) then

         -- we need to do a reverse lookup on the attribute name...
         -- find the building block info type id

         l_bld_blk_info_type_id := cache_bld_blk_info_types(g_attributes(y).bld_blk_info_type);

            --
            -- we need to get the old time attribute id record, to see
            -- if anything has changed before we can update the record
            --

            IF (g_attributes(y).new = 'N') THEN

              BEGIN
              open csr_bb_attributes(
                        g_attributes(y).time_attribute_id
                       ,g_attributes(y).object_version_number
                        );
              fetch csr_bb_attributes into l_old_attribute;
              close csr_bb_attributes;
              EXCEPTION
                WHEN OTHERS THEN
                  FND_MESSAGE.set_name('HXC','HXC_XXXXX_OLD_ATTRIBUTE');
                  FND_MESSAGE.set_token('TOKEN',g_attributes(y).time_attribute_id);
                  fnd_msg_pub.add;
              END;
            ELSIF (g_attributes(y).new = 'Y') THEN
              p_update_required := TRUE;
            END IF;
            --
         -- now for each mapping component we need to loop through the columns to find which one matches
         FOR comp IN csr_mapping_components(p_deposit_process_id, l_bld_blk_info_type_id) LOOP
            -- increment the timecard structure index
            l_attribute_index := l_attribute_index + 1;
            --
            IF comp.segment = 'ATTRIBUTE1' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute1;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE then
                 p_update_required:= update_required(l_old_attribute.attribute1, g_attributes(y).attribute1);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE2' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute2;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute2, g_attributes(y).attribute2);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE3' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute3;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute3, g_attributes(y).attribute3);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE4' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute4;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute4, g_attributes(y).attribute4);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE5' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute5;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute5, g_attributes(y).attribute5);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE6' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute6;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute6, g_attributes(y).attribute6);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE7' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute7;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute7, g_attributes(y).attribute7);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE8' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute8;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute8, g_attributes(y).attribute8);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE9' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute9;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute9, g_attributes(y).attribute9);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE10' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute10;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute10, g_attributes(y).attribute10);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE11' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute11;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute11, g_attributes(y).attribute11);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE12' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute12;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute12, g_attributes(y).attribute12);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE13' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute13;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute13, g_attributes(y).attribute13);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE14' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute14;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute14, g_attributes(y).attribute14);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE15' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute15;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute15, g_attributes(y).attribute15);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE16' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute16;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute16, g_attributes(y).attribute16);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE17' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute17;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute17, g_attributes(y).attribute17);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE18' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute18;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute18, g_attributes(y).attribute18);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE19' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute19;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute19, g_attributes(y).attribute19);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE20' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute20;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute20, g_attributes(y).attribute20);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE21' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute21;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute21, g_attributes(y).attribute21);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE22' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute22;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute22, g_attributes(y).attribute22);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE23' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute23;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute23, g_attributes(y).attribute23);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE24' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute24;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute24, g_attributes(y).attribute24);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE25' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute25;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute25, g_attributes(y).attribute25);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE26' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute26;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute26, g_attributes(y).attribute26);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE27' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute27;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute27, g_attributes(y).attribute27);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE28' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute28;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute28, g_attributes(y).attribute28);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE29' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute29;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute29, g_attributes(y).attribute29);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE30' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute30;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute30, g_attributes(y).attribute30);
               END IF;
            ELSIF comp.segment = 'ATTRIBUTE_CATEGORY' THEN
               p_timecard(l_attribute_index).attribute_name   := comp.field_name;
               p_timecard(l_attribute_index).attribute_value  := g_attributes(y).attribute_category;
               p_timecard(l_attribute_index).information_type := g_attributes(y).bld_blk_info_type;
               IF p_update_required <> TRUE THEN
                  p_update_required:= update_required(l_old_attribute.attribute_category, g_attributes(y).attribute_category);
               END IF;
            ELSE
               RAISE l_exception;
            END IF;
            -- add the new column name information
            p_timecard(l_attribute_index).column_name       := comp.segment;
            p_timecard(l_attribute_index).info_mapping_type := comp.bld_blk_info_type;

         END LOOP;


       --
       -- Check to see if we're allowed to update this attribute
       --
       if((g_timecard(p_block).new <> 'Y') AND (g_timecard(p_block).scope = 'DETAIL')) then

        if(
           ((g_attributes(y).changed = 'Y')AND(p_update_required))
          ) then

         if(check_approval_locked(p_block))then

            hxc_time_entry_rules_utils_pkg.add_error_to_table (
                                p_message_table => g_messages
                        ,       p_message_name  => 'HXC_NO_MODIFY_APPROVED_DETAIL'
                        ,       p_message_token => NULL
                        ,       p_message_level => 'ERROR'
                        ,       p_message_field         => NULL
                        ,       p_timecard_bb_id        => g_timecard(p_block).time_building_block_id
			,       p_timecard_bb_ovn       => g_timecard(p_block).object_version_number	--added 2822462
                        ,       p_time_attribute_id     => NULL);
/*
         IF ( hxc_timekeeper_errors.rollback_tc (
                 p_allow_error_tc => g_allow_error_tc
              ,  p_message_table  => g_messages
              ,  p_timecard       => g_timecard ) )
	THEN

	      raise e_approval_check;

	END IF;
*/
       end if;
       end if;
       end if;

       end if;  -- is this attribute record for this building block

       y:= g_attributes.next(y);

      END LOOP;

END build_timecard_structure;

PROCEDURE update_attribute_record
            (p_attribute_number     IN     BINARY_INTEGER
            ,p_app_attribute_count  IN     NUMBER
            ,p_mapping              IN     t_mapping
            ,p_app_attributes       IN OUT NOCOPY app_attributes_info
            ) IS

CURSOR csr_segment(p_retrieval_process_id NUMBER
                  ,p_attribute_category VARCHAR2
                  ,p_field_name VARCHAR2)
IS
select mc.segment
from hxc_mapping_components mc
    ,hxc_mapping_comp_usages mcu
    ,hxc_mappings m
    ,hxc_retrieval_processes rp
    ,hxc_bld_blk_info_types bbit
    ,hxc_bld_blk_info_type_usages bbui
where rp.mapping_id = m.mapping_id
  AND mc.field_name = p_field_name
  and rp.retrieval_process_id = p_retrieval_process_id
  and m.mapping_id = mcu.mapping_id
  and mcu.mapping_component_id = mc.mapping_component_id
  and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id
  AND bbit.bld_blk_info_type = p_attribute_category;

l_time_attribute_id    hxc_time_attributes.time_attribute_id%TYPE;
l_segment              hxc_mapping_components.segment%TYPE;
l_att_count            NUMBER;
l_mapping_component    t_mapping_comp;  --AI7

l_proc varchar2(32);
l_dummy number;
BEGIN



--
-- Obtain the time attribute id process id
--

l_time_attribute_id := p_app_attributes(p_app_attribute_count).time_attribute_id;

--
-- Next loop over the APP attributes, to find the ones with the same
-- time attribute id, and check those against the mapping components
-- to find out which attribute to update.
--

l_att_count := p_app_attributes.first;

LOOP

  EXIT WHEN NOT p_app_attributes.exists(l_att_count);

  IF p_app_attributes(l_att_count).time_attribute_id = l_time_Attribute_id THEN
  --
  -- This name value pair belongs to the current attribute record
  -- and therefore we should update the record.
  -- Fetch the segment associated with this field name, so that we
  -- know where to store the modified value.
  --
/*AI7     OPEN csr_segment
            (p_retrieval_process_id => p_retrieval_process_id
            ,p_attribute_category   => p_app_attributes(l_att_count).Bld_Blk_Info_Type
            ,p_field_name           => p_app_attributes(l_att_count).attribute_name
            );
     FETCH csr_segment INTO l_segment;
     IF csr_segment%notfound THEN
       --
       -- The field specified is not found.
       -- We don't know where to put the data
       -- Show an error
       --
          CLOSE csr_segment;
          FND_MESSAGE.set_name('HXC','HXC_NO_MAPPING_COMPONENT');
*/
--AI7  Use cache mapping info to find segment
     mapping_comp_info(p_field_name => p_app_attributes(l_att_count).attribute_name,
                       p_mapping_component => l_mapping_component,
                       p_mapping => p_mapping);

     if(l_mapping_component.field_name is null) then
       FND_MESSAGE.set_name('HXC','HXC_NO_MAPPING_COMPONENT');
     ELSE
       l_segment:=l_mapping_component.segment;
--AI7
       --
       -- We need to update the appropriate segment in the correct time
       -- attribute record.
       --
--AI7       CLOSE csr_segment;

       IF l_segment = 'ATTRIBUTE1' THEN
         g_attributes(p_attribute_number).attribute1 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE2' THEN
         g_attributes(p_attribute_number).attribute2 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE3' THEN
         g_attributes(p_attribute_number).attribute3 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE4' THEN
         g_attributes(p_attribute_number).attribute4 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE5' THEN
         g_attributes(p_attribute_number).attribute5 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE6' THEN
         g_attributes(p_attribute_number).attribute6 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE7' THEN
         g_attributes(p_attribute_number).attribute7 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE8' THEN
         g_attributes(p_attribute_number).attribute8 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE9' THEN
         g_attributes(p_attribute_number).attribute9 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE10' THEN
         g_attributes(p_attribute_number).attribute10 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE11' THEN
         g_attributes(p_attribute_number).attribute11 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE12' THEN
         g_attributes(p_attribute_number).attribute12 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE13' THEN
         g_attributes(p_attribute_number).attribute13 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE14' THEN
         g_attributes(p_attribute_number).attribute14 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE15' THEN
         g_attributes(p_attribute_number).attribute15 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE16' THEN
         g_attributes(p_attribute_number).attribute16 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE17' THEN
         g_attributes(p_attribute_number).attribute17 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE18' THEN
         g_attributes(p_attribute_number).attribute18 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE19' THEN
         g_attributes(p_attribute_number).attribute19 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE20' THEN
         g_attributes(p_attribute_number).attribute20 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE21' THEN
         g_attributes(p_attribute_number).attribute21 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE22' THEN
         g_attributes(p_attribute_number).attribute22 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE23' THEN
         g_attributes(p_attribute_number).attribute23 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE24' THEN
         g_attributes(p_attribute_number).attribute24 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE25' THEN
         g_attributes(p_attribute_number).attribute25 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE26' THEN
         g_attributes(p_attribute_number).attribute26 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE27' THEN
         g_attributes(p_attribute_number).attribute27 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE28' THEN
         g_attributes(p_attribute_number).attribute28 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE29' THEN
         g_attributes(p_attribute_number).attribute29 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       ELSIF l_segment = 'ATTRIBUTE30' THEN
         g_attributes(p_attribute_number).attribute30 := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
-- GPM v115.87
       ELSIF l_segment = 'ATTRIBUTE_CATEGORY' THEN
         g_attributes(p_attribute_number).attribute_category := p_app_attributes(l_att_count).attribute_value;
         p_app_attributes(l_att_count).updated := 'Y';
	 p_app_attributes(l_att_count).process := 'Y';	--SHIV
       END IF;

     END IF;


  END IF;

  l_att_count := p_app_attributes.next(l_att_count);

END LOOP;

IF g_attributes(p_attribute_number).changed IS NULL THEN
   begin
   select 1 into l_dummy
   from hxc_time_attributes
   where time_attribute_id = p_app_attributes(p_app_attribute_count).time_attribute_id
     and object_version_number = (select max(object_version_number)
                                    from hxc_time_attributes ta2
                                   where ta2.time_attribute_id = time_attribute_id)
     and NVL(attribute1,'NULL') = NVL(g_attributes(p_attribute_number).attribute1,'NULL')
     and NVL(attribute2,'NULL') = NVL(g_attributes(p_attribute_number).attribute2,'NULL')
     and NVL(attribute3,'NULL') = NVL(g_attributes(p_attribute_number).attribute3,'NULL')
     and NVL(attribute4,'NULL') = NVL(g_attributes(p_attribute_number).attribute4,'NULL')
     and NVL(attribute5,'NULL') = NVL(g_attributes(p_attribute_number).attribute5,'NULL')
     and NVL(attribute6,'NULL') = NVL(g_attributes(p_attribute_number).attribute6,'NULL')
     and NVL(attribute7,'NULL') = NVL(g_attributes(p_attribute_number).attribute7,'NULL')
     and NVL(attribute8,'NULL') = NVL(g_attributes(p_attribute_number).attribute8,'NULL')
     and NVL(attribute9,'NULL') = NVL(g_attributes(p_attribute_number).attribute9,'NULL')
     and NVL(attribute10,'NULL') = NVL(g_attributes(p_attribute_number).attribute10,'NULL')
     and NVL(attribute11,'NULL') = NVL(g_attributes(p_attribute_number).attribute11,'NULL')
     and NVL(attribute12,'NULL') = NVL(g_attributes(p_attribute_number).attribute12,'NULL')
     and NVL(attribute13,'NULL') = NVL(g_attributes(p_attribute_number).attribute13,'NULL')
     and NVL(attribute14,'NULL') = NVL(g_attributes(p_attribute_number).attribute14,'NULL')
     and NVL(attribute15,'NULL') = NVL(g_attributes(p_attribute_number).attribute15,'NULL')
     and NVL(attribute16,'NULL') = NVL(g_attributes(p_attribute_number).attribute16,'NULL')
     and NVL(attribute17,'NULL') = NVL(g_attributes(p_attribute_number).attribute17,'NULL')
     and NVL(attribute18,'NULL') = NVL(g_attributes(p_attribute_number).attribute18,'NULL')
     and NVL(attribute19,'NULL') = NVL(g_attributes(p_attribute_number).attribute19,'NULL')
     and NVL(attribute20,'NULL') = NVL(g_attributes(p_attribute_number).attribute20,'NULL')
     and NVL(attribute21,'NULL') = NVL(g_attributes(p_attribute_number).attribute21,'NULL')
     and NVL(attribute22,'NULL') = NVL(g_attributes(p_attribute_number).attribute22,'NULL')
     and NVL(attribute23,'NULL') = NVL(g_attributes(p_attribute_number).attribute23,'NULL')
     and NVL(attribute24,'NULL') = NVL(g_attributes(p_attribute_number).attribute24,'NULL')
     and NVL(attribute25,'NULL') = NVL(g_attributes(p_attribute_number).attribute25,'NULL')
     and NVL(attribute26,'NULL') = NVL(g_attributes(p_attribute_number).attribute26,'NULL')
     and NVL(attribute27,'NULL') = NVL(g_attributes(p_attribute_number).attribute27,'NULL')
     and NVL(attribute28,'NULL') = NVL(g_attributes(p_attribute_number).attribute28,'NULL')
     and NVL(attribute29,'NULL') = NVL(g_attributes(p_attribute_number).attribute29,'NULL')
     and NVL(attribute30,'NULL') = NVL(g_attributes(p_attribute_number).attribute30,'NULL')
     and attribute_category = g_attributes(p_attribute_number).attribute_category;
     g_attributes(p_attribute_number).changed := 'N';
     if g_debug then
     	l_proc := 'UpdateAttributeRecord';
     	hr_utility.trace('Same Attribute found');
     end if;
     exception
     when no_data_found then
        g_attributes(p_attribute_number).changed := 'Y';
        if g_debug then
        	hr_utility.trace('Same Attribute NOT found');
        end if;
     end;
END IF;
END update_attribute_record;

PROCEDURE create_attribute_record
           (p_app_attribute_count  IN NUMBER
           ,p_mapping              IN t_mapping
           ,p_app_attributes       IN OUT NOCOPY app_attributes_info
           ) IS

l_next_attribute_id NUMBER;
l_bld_blk_info_type_id NUMBER;
l_attribute_category HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE;
l_att_count NUMBER;

cursor csr_attribute
        (p_time_attribute_id in HXC_TIME_ATTRIBUTES.TIME_ATTRIBUTE_ID%TYPE
        ) is
  select 1
    from hxc_time_attributes ta
   where ta.time_attribute_id = p_time_attribute_id;

l_attribute_row csr_attribute%ROWTYPE;
l_new varchar2(30);
l_changed varchar2(30);

BEGIN



--
-- Fetch the bld blk information type id
--
l_bld_blk_info_type_id := cache_bld_blk_info_types(p_app_attributes(p_app_attribute_count).bld_blk_info_type);
--
-- Trick here is to create a new attribute by depositing a blank one,
-- then calling the update attribute record procedure to create it
-- properly.
--

-- GPM v115.58

if (p_app_attributes(p_app_attribute_count).time_attribute_id is NOT NULL) then

  l_next_attribute_id := p_app_attributes(p_app_attribute_count).time_attribute_id;

else


IF ( g_attributes.LAST IS NULL )
THEN
	l_next_attribute_id := 1;
ELSE
	l_next_attribute_id := g_attributes(g_attributes.LAST).time_attribute_id+1;
END IF;

end if;

IF ( p_app_attributes(p_app_attribute_count).bld_blk_info_type like 'Dummy%' )
THEN
	l_attribute_category := NULL;
ELSE
	l_attribute_category := p_app_attributes(p_app_attribute_count).bld_blk_info_type;
END IF;

if g_debug then
	hr_utility.trace('Before API Check');
end if;
-- check if this code was called from the Timestore Deposit API
if  p_app_attributes(p_app_attribute_count).changed is null then
   if g_debug then
   	hr_utility.trace('API Call');
   end if;
   -- Determine if this is a new attribute or an existing one
   open csr_attribute
          ( p_app_attributes(p_app_attribute_count).time_attribute_id
          );

   fetch csr_attribute into l_attribute_row;
   if(csr_attribute%FOUND) then
   if g_debug then
   	hr_utility.trace('attribute found');
   end if;
      l_new := 'N';
      l_changed := NULL;
   else
   if g_debug then
   	hr_utility.trace('attribute NOT found');
   end if;
      l_new := 'Y';
      l_changed := 'Y';
   end if;
   close csr_attribute;
else
   l_new := 'Y';
   l_changed := 'Y';
end if;

call_attribute_deposit(
 p_TIME_ATTRIBUTE_ID     => l_next_attribute_id
,p_BUILDING_BLOCK_ID     => p_app_attributes(p_app_attribute_count).building_block_id
,p_BLD_BLK_INFO_TYPE     => p_app_attributes(p_app_attribute_count).bld_blk_info_type
,p_ATTRIBUTE_CATEGORY    => l_attribute_category -- GPM v115.100
,p_ATTRIBUTE1            => NULL
,p_ATTRIBUTE2            => NULL
,p_ATTRIBUTE3            => NULL
,p_ATTRIBUTE4            => NULL
,p_ATTRIBUTE5            => NULL
,p_ATTRIBUTE6            => NULL
,p_ATTRIBUTE7            => NULL
,p_ATTRIBUTE8            => NULL
,p_ATTRIBUTE9            => NULL
,p_ATTRIBUTE10           => NULL
,p_ATTRIBUTE11           => NULL
,p_ATTRIBUTE12           => NULL
,p_ATTRIBUTE13           => NULL
,p_ATTRIBUTE14           => NULL
,p_ATTRIBUTE15           => NULL
,p_ATTRIBUTE16           => NULL
,p_ATTRIBUTE17           => NULL
,p_ATTRIBUTE18           => NULL
,p_ATTRIBUTE19           => NULL
,p_ATTRIBUTE20           => NULL
,p_ATTRIBUTE21           => NULL
,p_ATTRIBUTE22           => NULL
,p_ATTRIBUTE23           => NULL
,p_ATTRIBUTE24           => NULL
,p_ATTRIBUTE25           => NULL
,p_ATTRIBUTE26           => NULL
,p_ATTRIBUTE27           => NULL
,p_ATTRIBUTE28           => NULL
,p_ATTRIBUTE29           => NULL
,p_ATTRIBUTE30           => NULL
,p_BLD_BLK_INFO_TYPE_ID  => l_bld_blk_info_type_id
,p_OBJECT_VERSION_NUMBER => 1
,p_NEW                   => l_new -- 'Y'
,P_CHANGED               => l_changed -- 'Y'
);

--
-- Next call the update procedure
-- to add the attribute values.
--

update_attribute_record
  (p_attribute_number     => g_attributes.last
  ,p_app_attribute_count  => p_app_attribute_count
  ,p_mapping              => p_mapping
  ,p_app_attributes       => p_app_attributes
  );

END create_attribute_record;
/*
procedure dump_attributes is

l_proc varchar2(30) := 'dump_attributes';

l_attribute number;

begin

l_attribute := g_attributes.first;

loop

  exit when not g_attributes.exists(l_attribute);

    debug(l_proc,5,'Time Attribute Id:'||g_attributes(l_attribute).time_attribute_id);
    debug(l_proc,5,'Time BB Id:'||g_attributes(l_attribute).building_block_id);
    debug(l_proc,5,'Bld Blk Info Type:'||g_attributes(l_attribute).bld_blk_info_type);
    debug(l_proc,5,'Attribute Category:'||g_attributes(l_attribute).attribute_category);
    debug(l_proc,5,'Attribute 1:'||g_attributes(l_attribute).attribute1);
    debug(l_proc,5,'Attribute 2:'||g_attributes(l_attribute).attribute2);
    debug(l_proc,5,'Attribute 3:'||g_attributes(l_attribute).attribute3);
    debug(l_proc,5,'Attribute 4:'||g_attributes(l_attribute).attribute4);
    debug(l_proc,5,'Attribute 5:'||g_attributes(l_attribute).attribute5);

  l_attribute := g_attributes.next(l_attribute);

end loop;

end dump_attributes;
*/
/*
procedure dump_app_attributes is

l_proc varchar2(30) := 'dump_app_attributes';

l_attribute number;

begin

l_attribute := g_app_attributes.first;

loop

  exit when not g_app_attributes.exists(l_attribute);

  debug(l_proc,10,'Time_Attribute_Id:'||g_app_attributes(l_attribute).time_attribute_id);
  debug(l_proc,15,'Building_Block_Id:'||g_app_attributes(l_attribute).building_block_id);
  debug(l_proc,20,'Attribute_Name   :'||g_app_attributes(l_attribute).attribute_name);
  debug(l_proc,25,'Attribute_Value  :'||g_app_attributes(l_attribute).attribute_value);
  debug(l_proc,30,'Bld_Blk_Info_Type:'||g_app_attributes(l_attribute).bld_blk_info_type);
  debug(l_proc,35,'Category         :'||g_app_attributes(l_attribute).category);
  debug(l_proc,40,'Updated          :'||g_app_attributes(l_attribute).updated);
  debug(l_proc,45,'Changed          :'||g_app_attributes(l_attribute).changed);
  debug(l_proc,50,'Process          :'||g_app_attributes(l_attribute).process);

  debug(l_proc,55,'');

  l_attribute := g_app_attributes.next(l_attribute);


end loop;

end dump_app_attributes;
*/

PROCEDURE update_deposit_globals(
            p_retrieval_process_id IN NUMBER default null,
            p_deposit_process_id IN NUMBER default null
            ) IS

l_blocks        timecard_info;
l_attributes    app_attributes_info;
l_count         BINARY_INTEGER;
l_blk_count     BINARY_INTEGER;
l_att_count     BINARY_INTEGER;
l_new_attribute BOOLEAN := TRUE;
l_mapping       t_mapping;  --AI7
l_proc          VARCHAR2(30) := 'UPDATE_DEPOSIT_GLOBALS';


BEGIN

--
-- Update the attributes
--
--AI7 will use mapping information, so make sure its available

cache_mappings(p_retrieval_process_id => p_retrieval_process_id,
               p_deposit_process_id => p_deposit_process_id);

if(p_retrieval_process_id is not null) then
--  dbms_output.put_line('Using Retrieval Process Mapping');
  l_mapping:=g_retrieval_mapping;
else
--  dbms_output.put_line('Using Deposit Process Mapping');
  l_mapping:=g_deposit_mapping;
end if;
--AI7


l_count := g_app_attributes.first;

LOOP

  EXIT WHEN NOT g_app_attributes.exists(l_count);

  --
  -- Loop over the global attributes
  --

  l_new_attribute := TRUE;
  l_att_count := g_attributes.first;

  LOOP

    EXIT WHEN NOT g_attributes.exists(l_att_count);

    IF (
        (g_app_attributes(l_count).time_attribute_id =
         g_attributes(l_att_count).time_attribute_id)
       AND
        (NVL(g_app_attributes(l_count).updated,'N') <> 'Y')
       ) THEN
    --
    -- This can't be a new attribute
    --
       l_new_attribute := FALSE;
    --
    -- Now we need to check whether there are any differences in the attribute records
    --
    -- Use the mapping components to work out whether there are any changes
    --

      update_attribute_record
        (p_attribute_number     => l_att_count
        ,p_app_attribute_count  => l_count
        ,p_mapping              => l_mapping
        ,p_app_attributes       => g_app_attributes
        );

    END IF;

    l_att_count := g_attributes.next(l_att_count);

  END LOOP;

  IF (
       (l_new_attribute)
     AND
       (g_app_attributes(l_count).updated <> 'Y')
     ) THEN
  --
  -- Create the new attribute record
  --
       create_attribute_record
         (p_app_attribute_count  => l_count
         ,p_mapping              => l_mapping
         ,p_app_attributes       => g_app_attributes
         );

  END IF;

  l_count := g_app_attributes.next(l_count);

END LOOP;

END update_deposit_globals;

PROCEDURE show_errors(p_messages IN OUT NOCOPY message_table) IS

l_message_count NUMBER;
l_error_message VARCHAR2(4000);
l_fnd_separator VARCHAR2(5) := FND_GLOBAL.LOCAL_CHR(0);
l_token_table hxc_deposit_wrapper_utilities.t_simple_table;

BEGIN
--
-- loop over the error msgs. return immediately if the message_table is blank
--
if(p_messages is null) then
  return;
end if;

l_message_count:=p_messages.first;

LOOP

 EXIT WHEN NOT p_messages.exists(l_message_count);
 EXIT WHEN l_message_count > g_max_messages_displayed;

 if (((p_messages(l_message_count).message_level) is NULL)
   OR
    (instr(upper(p_messages(l_message_count).message_level),'ERR') > 0)) then

   if(p_messages(l_message_count).on_oa_msg_stack = FALSE ) then
         --AI5 message hasnt been processed yet
     --
     -- Set on 'stack'
     --
     FND_MESSAGE.SET_NAME
        (p_messages(l_message_count).application_short_name
        ,p_messages(l_message_count).message_name
        );

     IF p_messages(l_message_count).message_tokens IS NOT NULL THEN
        --
        -- parse string into a more accessible form
        --
        hxc_deposit_wrapper_utilities.string_to_table('&',
                                                    '&'||p_messages(l_message_count).message_tokens,
                                                    l_token_table);

        -- table should be full of TOKEN, VALUE pairs. The number of TOKEN, VALUE pairs is l_token_table/2

        FOR l_token in 0..(l_token_table.count/2)-1 LOOP

          FND_MESSAGE.SET_TOKEN
          (TOKEN => l_token_table(2*l_token)
          ,VALUE => l_token_table(2*l_token+1)
          );

        END LOOP;
      END IF;  -- end tokens

      --
      -- Add this message to the message list
      --
      fnd_msg_pub.add;
      --AI5 set flag to say this has been stacked
      p_messages(l_message_count).on_oa_msg_stack := TRUE;

      END IF; -- is this msg already stacked?
    END IF; -- is this really an error message?

  l_message_count:=p_messages.next(l_message_count);

  END LOOP; -- loop over msg table

--AI5 no longer delete contents of msg table

END show_errors;

FUNCTION info_type_id_exists(p_id in NUMBER) return boolean
is

l_dummy VARCHAR2(10);

BEGIN

select 'Y' into l_dummy
  from hxc_bld_blk_info_types
 where bld_blk_info_type_id = p_id;

return true;

EXCEPTION
  when others then
   return false;

END info_type_id_exists;

procedure deposit_attribute_info(
 p_TIME_ATTRIBUTE_ID     in NUMBER
,p_BUILDING_BLOCK_ID     in NUMBER
,p_BLD_BLK_INFO_TYPE     in VARCHAR2
,p_ATTRIBUTE_CATEGORY    in VARCHAR2
,p_ATTRIBUTE1            in VARCHAR2
,p_ATTRIBUTE2            in VARCHAR2
,p_ATTRIBUTE3            in VARCHAR2
,p_ATTRIBUTE4            in VARCHAR2
,p_ATTRIBUTE5            in VARCHAR2
,p_ATTRIBUTE6            in VARCHAR2
,p_ATTRIBUTE7            in VARCHAR2
,p_ATTRIBUTE8            in VARCHAR2
,p_ATTRIBUTE9            in VARCHAR2
,p_ATTRIBUTE10           in VARCHAR2
,p_ATTRIBUTE11           in VARCHAR2
,p_ATTRIBUTE12           in VARCHAR2
,p_ATTRIBUTE13           in VARCHAR2
,p_ATTRIBUTE14           in VARCHAR2
,p_ATTRIBUTE15           in VARCHAR2
,p_ATTRIBUTE16           in VARCHAR2
,p_ATTRIBUTE17           in VARCHAR2
,p_ATTRIBUTE18           in VARCHAR2
,p_ATTRIBUTE19           in VARCHAR2
,p_ATTRIBUTE20           in VARCHAR2
,p_ATTRIBUTE21           in VARCHAR2
,p_ATTRIBUTE22           in VARCHAR2
,p_ATTRIBUTE23           in VARCHAR2
,p_ATTRIBUTE24           in VARCHAR2
,p_ATTRIBUTE25           in VARCHAR2
,p_ATTRIBUTE26           in VARCHAR2
,p_ATTRIBUTE27           in VARCHAR2
,p_ATTRIBUTE28           in VARCHAR2
,p_ATTRIBUTE29           in VARCHAR2
,p_ATTRIBUTE30           in VARCHAR2
,p_BLD_BLK_INFO_TYPE_ID  in NUMBER
,p_OBJECT_VERSION_NUMBER in NUMBER
,p_NEW                   in VARCHAR2
,p_changed               in VARCHAR2
) IS

cursor c_bld_blk_info_id
        (p_info_type in varchar2) is
  select bld_blk_info_type_id
    from hxc_bld_blk_info_types
   where bld_blk_info_type = p_info_type;

l_last_index BINARY_INTEGER;
l_next_index BINARY_INTEGER;
l_proc VARCHAR2(30) := 'DEPOSIT ATTRIBUTE INFO';
l_attribute1 HXC_TIME_ATTRIBUTES.ATTRIBUTE1%TYPE := P_ATTRIBUTE1;
l_attribute_category HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE%TYPE;
l_bld_blk_info_type_id HXC_BLD_BLK_INFO_TYPES.BLD_BLK_INFO_TYPE_ID%TYPE;

BEGIN
--
-- Find the next index
--
l_last_index := g_attributes.last;

if (l_last_index is null) then

  l_next_index := 1;

else

  l_next_index := l_last_index +1;

end if;

if (info_type_id_exists(p_bld_blk_info_type_id)) then

  l_bld_blk_info_type_id := p_bld_blk_info_Type_id;

else
  open c_bld_blk_info_id(p_BLD_BLK_INFO_TYPE);
  fetch c_bld_blk_info_id into l_bld_blk_info_type_id;
  close c_bld_blk_info_id;

end if;

--
-- Check the element context!
--

if (p_bld_blk_info_type = 'Dummy Element Context') THEN

 if (INSTR(p_attribute_category,'ELEMENT') =0) then
  l_attribute_category := 'ELEMENT - '||p_attribute_category;
 else
  l_attribute_category := p_attribute_category;
 end if;

else

  l_attribute_category := p_attribute_category;

end if;

--
-- Nasty Hack for Oracle Internal
--

IF (p_attribute_category = 'ORACLE_INTERNAL') THEN
 IF (INSTR(p_attribute1,'ELEMENT') = 0) THEN
  l_attribute1 := 'ELEMENT - '||p_attribute1;
 END IF;
ELSE
  l_attribute1 := p_attribute1;
END IF;

g_attributes(l_next_index).TIME_ATTRIBUTE_ID     := p_time_attribute_id;
g_attributes(l_next_index).BUILDING_BLOCK_ID     := p_BUILDING_BLOCK_ID     ;
g_attributes(l_next_index).BLD_BLK_INFO_TYPE     := p_BLD_BLK_INFO_TYPE     ;
g_attributes(l_next_index).ATTRIBUTE_CATEGORY    := l_ATTRIBUTE_CATEGORY    ;
g_attributes(l_next_index).ATTRIBUTE1            := l_ATTRIBUTE1            ;
g_attributes(l_next_index).ATTRIBUTE2            := p_ATTRIBUTE2            ;
g_attributes(l_next_index).ATTRIBUTE3            := p_ATTRIBUTE3            ;
g_attributes(l_next_index).ATTRIBUTE4            := p_ATTRIBUTE4            ;
g_attributes(l_next_index).ATTRIBUTE5            := p_ATTRIBUTE5            ;
g_attributes(l_next_index).ATTRIBUTE6            := p_ATTRIBUTE6            ;
g_attributes(l_next_index).ATTRIBUTE7            := p_ATTRIBUTE7            ;
g_attributes(l_next_index).ATTRIBUTE8            := p_ATTRIBUTE8            ;
g_attributes(l_next_index).ATTRIBUTE9            := p_ATTRIBUTE9            ;
g_attributes(l_next_index).ATTRIBUTE10           := p_ATTRIBUTE10           ;
g_attributes(l_next_index).ATTRIBUTE11           := p_ATTRIBUTE11           ;
g_attributes(l_next_index).ATTRIBUTE12           := p_ATTRIBUTE12           ;
g_attributes(l_next_index).ATTRIBUTE13           := p_ATTRIBUTE13           ;
g_attributes(l_next_index).ATTRIBUTE14           := p_ATTRIBUTE14           ;
g_attributes(l_next_index).ATTRIBUTE15           := p_ATTRIBUTE15           ;
g_attributes(l_next_index).ATTRIBUTE16           := p_ATTRIBUTE16           ;
g_attributes(l_next_index).ATTRIBUTE17           := p_ATTRIBUTE17           ;
g_attributes(l_next_index).ATTRIBUTE18           := p_ATTRIBUTE18           ;
g_attributes(l_next_index).ATTRIBUTE19           := p_ATTRIBUTE19           ;
g_attributes(l_next_index).ATTRIBUTE20           := p_ATTRIBUTE20           ;
g_attributes(l_next_index).ATTRIBUTE21           := p_ATTRIBUTE21           ;
g_attributes(l_next_index).ATTRIBUTE22           := p_ATTRIBUTE22           ;
g_attributes(l_next_index).ATTRIBUTE23           := p_ATTRIBUTE23           ;
g_attributes(l_next_index).ATTRIBUTE24           := p_ATTRIBUTE24           ;
g_attributes(l_next_index).ATTRIBUTE25           := p_ATTRIBUTE25           ;
g_attributes(l_next_index).ATTRIBUTE26           := p_ATTRIBUTE26           ;
g_attributes(l_next_index).ATTRIBUTE27           := p_ATTRIBUTE27           ;
g_attributes(l_next_index).ATTRIBUTE28           := p_ATTRIBUTE28           ;
g_attributes(l_next_index).ATTRIBUTE29           := p_ATTRIBUTE29           ;
g_attributes(l_next_index).ATTRIBUTE30           := p_ATTRIBUTE30           ;
g_attributes(l_next_index).BLD_BLK_INFO_TYPE_ID  := l_bld_blk_info_type_id  ;
g_attributes(l_next_index).OBJECT_VERSION_NUMBER := p_OBJECT_VERSION_NUMBER ;
g_attributes(l_next_index).NEW                   := p_NEW ;
g_attributes(l_next_index).changed               := p_changed ;

exception
  when others then
   FND_MESSAGE.SET_NAME('HXC','HXC_deposit_ATTRIBUTE_info');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM||' : '||length(l_attribute_category));
   FND_MESSAGE.RAISE_ERROR;

END deposit_attribute_info;

procedure call_attribute_deposit(
 p_TIME_ATTRIBUTE_ID     in VARCHAR2
,p_BUILDING_BLOCK_ID     in VARCHAR2
,p_BLD_BLK_INFO_TYPE     in VARCHAR2
,p_ATTRIBUTE_CATEGORY    in VARCHAR2
,p_ATTRIBUTE1            in VARCHAR2
,p_ATTRIBUTE2            in VARCHAR2
,p_ATTRIBUTE3            in VARCHAR2
,p_ATTRIBUTE4            in VARCHAR2
,p_ATTRIBUTE5            in VARCHAR2
,p_ATTRIBUTE6            in VARCHAR2
,p_ATTRIBUTE7            in VARCHAR2
,p_ATTRIBUTE8            in VARCHAR2
,p_ATTRIBUTE9            in VARCHAR2
,p_ATTRIBUTE10           in VARCHAR2
,p_ATTRIBUTE11           in VARCHAR2
,p_ATTRIBUTE12           in VARCHAR2
,p_ATTRIBUTE13           in VARCHAR2
,p_ATTRIBUTE14           in VARCHAR2
,p_ATTRIBUTE15           in VARCHAR2
,p_ATTRIBUTE16           in VARCHAR2
,p_ATTRIBUTE17           in VARCHAR2
,p_ATTRIBUTE18           in VARCHAR2
,p_ATTRIBUTE19           in VARCHAR2
,p_ATTRIBUTE20           in VARCHAR2
,p_ATTRIBUTE21           in VARCHAR2
,p_ATTRIBUTE22           in VARCHAR2
,p_ATTRIBUTE23           in VARCHAR2
,p_ATTRIBUTE24           in VARCHAR2
,p_ATTRIBUTE25           in VARCHAR2
,p_ATTRIBUTE26           in VARCHAR2
,p_ATTRIBUTE27           in VARCHAR2
,p_ATTRIBUTE28           in VARCHAR2
,p_ATTRIBUTE29           in VARCHAR2
,p_ATTRIBUTE30           in VARCHAR2
,p_BLD_BLK_INFO_TYPE_ID  in VARCHAR2
,p_OBJECT_VERSION_NUMBER in VARCHAR2
,p_NEW                   in VARCHAR2
,p_changed               in varchar2
) is

l_time_attribute_id NUMBER := to_number(p_TIME_ATTRIBUTE_ID);
l_ovn NUMBER := to_number(p_OBJECT_VERSION_NUMBER);
l_building_block_id NUMBER := to_number(p_BUILDING_BLOCK_ID);
l_bld_blk_info_type_id NUMBER := TO_NUMBER(P_BLD_BLK_INFO_TYPE_ID);

begin


deposit_attribute_info(
 p_TIME_ATTRIBUTE_ID     => l_time_attribute_id
,p_BUILDING_BLOCK_ID     => l_building_block_id
,p_BLD_BLK_INFO_TYPE  => p_BLD_BLK_INFO_TYPE
,p_ATTRIBUTE_CATEGORY => p_ATTRIBUTE_CATEGORY
,p_ATTRIBUTE1         => p_ATTRIBUTE1
,p_ATTRIBUTE2         => p_ATTRIBUTE2
,p_ATTRIBUTE3         => p_ATTRIBUTE3
,p_ATTRIBUTE4         => p_ATTRIBUTE4
,p_ATTRIBUTE5         => p_ATTRIBUTE5
,p_ATTRIBUTE6         => p_ATTRIBUTE6
,p_ATTRIBUTE7         => p_ATTRIBUTE7
,p_ATTRIBUTE8         => p_ATTRIBUTE8
,p_ATTRIBUTE9         => p_ATTRIBUTE9
,p_ATTRIBUTE10        => p_ATTRIBUTE10
,p_ATTRIBUTE11        => p_ATTRIBUTE11
,p_ATTRIBUTE12        => p_ATTRIBUTE12
,p_ATTRIBUTE13        => p_ATTRIBUTE13
,p_ATTRIBUTE14        => p_ATTRIBUTE14
,p_ATTRIBUTE15        => p_ATTRIBUTE15
,p_ATTRIBUTE16        => p_ATTRIBUTE16
,p_ATTRIBUTE17        => p_ATTRIBUTE17
,p_ATTRIBUTE18        => p_ATTRIBUTE18
,p_ATTRIBUTE19        => p_ATTRIBUTE19
,p_ATTRIBUTE20        => p_ATTRIBUTE20
,p_ATTRIBUTE21        => p_ATTRIBUTE21
,p_ATTRIBUTE22        => p_ATTRIBUTE22
,p_ATTRIBUTE23        => p_ATTRIBUTE23
,p_ATTRIBUTE24        => p_ATTRIBUTE24
,p_ATTRIBUTE25        => p_ATTRIBUTE25
,p_ATTRIBUTE26        => p_ATTRIBUTE26
,p_ATTRIBUTE27        => p_ATTRIBUTE27
,p_ATTRIBUTE28        => p_ATTRIBUTE28
,p_ATTRIBUTE29        => p_ATTRIBUTE29
,p_ATTRIBUTE30        => p_ATTRIBUTE30
,p_BLD_BLK_INFO_TYPE_ID => p_BLD_BLK_INFO_TYPE_ID
,p_OBJECT_VERSION_NUMBER => l_ovn
,p_NEW                   => p_NEW
,p_changed               => p_changed);

end call_attribute_deposit;

procedure call_block_deposit(
                        P_TIME_BUILDING_BLOCK_ID   in VARCHAR2
                       ,P_TYPE                     in VARCHAR2
                       ,P_MEASURE                  in VARCHAR2
                       ,P_UNIT_OF_MEASURE          in VARCHAR2
                       ,P_START_TIME               in VARCHAR2
                       ,P_STOP_TIME                in VARCHAR2
                       ,P_PARENT_BUILDING_BLOCK_ID in VARCHAR2
                       ,P_PARENT_IS_NEW            IN VARCHAR2
                       ,P_SCOPE                    in VARCHAR2
                       ,P_OBJECT_VERSION_NUMBER    in VARCHAR2
                       ,P_APPROVAL_STATUS          in VARCHAR2
                       ,P_RESOURCE_ID              in VARCHAR2
                       ,P_RESOURCE_TYPE            in VARCHAR2
                       ,P_APPROVAL_STYLE_ID        in VARCHAR2
                       ,P_DATE_FROM                in VARCHAR2
                       ,P_DATE_TO                  in VARCHAR2
                       ,P_COMMENT_TEXT             in VARCHAR2
                       ,P_PARENT_BUILDING_BLOCK_OVN in  VARCHAR2
                       ,P_NEW                       in  VARCHAR2
                       ,P_CHANGED                   in VARCHAR2
                       ) is


l_building_block_id         NUMBER := to_number(P_TIME_BUILDING_BLOCK_ID);
l_measure                   NUMBER := to_number(P_MEASURE);
l_start_time                DATE   := fnd_date.canonical_to_date(P_START_TIME);
l_stop_time                 DATE   := fnd_date.canonical_to_date(P_STOP_TIME);
l_parent_building_block_id  NUMBER := to_number(P_PARENT_BUILDING_BLOCK_ID);
l_object_version_number     NUMBER := to_number(P_OBJECT_VERSION_NUMBER);
l_resource_id               NUMBER := to_number(P_RESOURCE_ID);
l_approval_style_id         NUMBER := to_number(P_APPROVAL_STYLE_ID);
l_date_from                 DATE   := fnd_date.canonical_to_date(P_DATE_FROM);
l_date_to                   DATE   := fnd_date.canonical_to_date(P_DATE_TO);
l_parent_building_block_ovn NUMBER := to_number(P_PARENT_BUILDING_BLOCK_OVN);
l_proc                      VARCHAR2(30):= 'CALL_BLOCK_DEPOSIT';


BEGIN

--
-- Check the Java null values, and see if we need to
-- reset any of the passed values.
--

IF (l_parent_building_block_id = -1) then
  l_parent_building_block_id := NULL;
end if;

-- Bug 2336662
-- This if condition is commented out for the Enhancement for the Performance
-- of Template view
-- It is to ensure that we actually save a public template with resource id -1

--if (l_resource_id = -1) then
--  l_resource_id := NULL;
--end if;

-- End of change

if (l_approval_style_id = -1) then
  l_approval_style_id := NULL;
end if;

if (l_parent_building_block_ovn = -1) then
  l_parent_building_block_ovn := NULL;
end if;

--
--  Now that the type conversion has been performed,
--  call the deposit block information procedure
--  to store this set of block information.
--

deposit_block_info(
 P_TIME_BUILDING_BLOCK_ID   => l_building_block_id
,P_TYPE                     => P_TYPE
,P_MEASURE                  => l_measure
,P_UNIT_OF_MEASURE          => P_UNIT_OF_MEASURE
,P_START_TIME               => l_start_time
,P_STOP_TIME                => l_stop_time
,P_PARENT_BUILDING_BLOCK_ID => l_parent_building_block_id
,P_PARENT_IS_NEW            => p_parent_is_new
,P_SCOPE                    => P_SCOPE
,P_OBJECT_VERSION_NUMBER    => l_object_version_number
,P_APPROVAL_STATUS          => P_APPROVAL_STATUS
,P_RESOURCE_ID              => l_resource_id
,P_RESOURCE_TYPE            => P_RESOURCE_TYPE
,P_APPROVAL_STYLE_ID        => l_approval_style_id
,P_DATE_FROM                => l_date_from
,P_DATE_TO                  => l_date_to
,P_COMMENT_TEXT             => P_COMMENT_TEXT
,P_PARENT_BUILDING_BLOCK_OVN => l_parent_building_block_ovn
,P_NEW                       => P_NEW
,P_CHANGED                   => P_CHANGED
);


end call_block_deposit;

procedure deposit_block_info(
                        P_TIME_BUILDING_BLOCK_ID   in NUMBER
                       ,P_TYPE                     in VARCHAR2
                       ,P_MEASURE                  in NUMBER
                       ,P_UNIT_OF_MEASURE          in VARCHAR2
                       ,P_START_TIME               in DATE
                       ,P_STOP_TIME                in DATE
                       ,P_PARENT_BUILDING_BLOCK_ID in NUMBER
                       ,P_PARENT_IS_NEW            IN VARCHAR2
                       ,P_SCOPE                    in VARCHAR2
                       ,P_OBJECT_VERSION_NUMBER    in NUMBER
                       ,P_APPROVAL_STATUS          in VARCHAR2
                       ,P_RESOURCE_ID              in NUMBER
                       ,P_RESOURCE_TYPE            in VARCHAR2
                       ,P_APPROVAL_STYLE_ID        in NUMBER
                       ,P_DATE_FROM                in DATE
                       ,P_DATE_TO                  in DATE
                       ,P_COMMENT_TEXT             in VARCHAR2
                       ,P_PARENT_BUILDING_BLOCK_OVN in  NUMBER
                       ,P_NEW                       in VARCHAR2
                       ,P_CHANGED                   in VARCHAR2
                       ) is


l_last_index BINARY_INTEGER;
l_next_index BINARY_INTEGER;
l_proc VARCHAR2(32) := 'DEPOSIT_BLOCK_INFO';
BEGIN

--
-- Add the information to the timecard record
--

l_last_index := g_timecard.last;

if (l_last_index is null) then
  l_next_index := 1;
else
  l_next_index := l_last_index +1;
end if;

--
-- Insert the new building block record
--
g_timecard(l_next_index).TIME_BUILDING_BLOCK_ID   := P_TIME_BUILDING_BLOCK_ID;
g_timecard(l_next_index).TYPE                     := P_TYPE;
g_timecard(l_next_index).MEASURE                  := P_MEASURE;
g_timecard(l_next_index).UNIT_OF_MEASURE          := P_UNIT_OF_MEASURE;
g_timecard(l_next_index).START_TIME               := P_START_TIME;
g_timecard(l_next_index).STOP_TIME                := P_STOP_TIME;
g_timecard(l_next_index).PARENT_BUILDING_BLOCK_ID := P_PARENT_BUILDING_BLOCK_ID;
g_timecard(l_next_index).PARENT_IS_NEW            := P_PARENT_IS_NEW;
g_timecard(l_next_index).SCOPE                    := P_SCOPE;
g_timecard(l_next_index).OBJECT_VERSION_NUMBER    := P_OBJECT_VERSION_NUMBER;
g_timecard(l_next_index).APPROVAL_STATUS          := P_APPROVAL_STATUS;
g_timecard(l_next_index).RESOURCE_ID              := P_RESOURCE_ID;
g_timecard(l_next_index).RESOURCE_TYPE            := P_RESOURCE_TYPE;
g_timecard(l_next_index).APPROVAL_STYLE_ID        := P_APPROVAL_STYLE_ID;
g_timecard(l_next_index).DATE_FROM                := P_DATE_FROM;
g_timecard(l_next_index).DATE_TO                  := P_DATE_TO;
g_timecard(l_next_index).COMMENT_TEXT             := P_COMMENT_TEXT;
g_timecard(l_next_index).PARENT_BUILDING_BLOCK_OVN := P_PARENT_BUILDING_BLOCK_OVN;
g_timecard(l_next_index).NEW                       := P_NEW;
g_timecard(l_next_index).CHANGED                   := P_CHANGED;

if ((p_new='Y') and (g_new_bbs='N')) then

  g_new_bbs := 'Y';

end if;

END deposit_block_info;


procedure zdeposit_blocks
is
begin
   null;
end zdeposit_blocks;

procedure update_ovns
           (p_block_id in NUMBER
           ,p_new_parent_ovn in NUMBER
           ) is

l_block number;

BEGIN

--
-- Make sure that the newly inserted parents ovn is updated in
-- in the blocks structure
--

l_block := g_timecard.first;

LOOP
  EXIT WHEN NOT g_timecard.exists(l_block);

  if (g_timecard(l_block).parent_building_block_id = p_block_id) then

     g_timecard(l_block).parent_building_block_ovn := p_new_parent_ovn;

  end if;

  l_block := g_timecard.next(l_block);

END LOOP;


end update_ovns;

function public_private return varchar2 is

l_public_private HXC_TIME_ATTRIBUTES.ATTRIBUTE2%TYPE;

begin

if (fnd_profile.value('HXC_CREATE_PUBLIC_TEMPLATES') = 'Y') then

  l_public_private := 'PUBLIC';

else

  l_public_private := 'PRIVATE';

end if;

return l_public_private;

end public_private;

procedure alias_translation is

l_attribute_array 	HXC_ATTRIBUTE_TABLE_TYPE;
l_block_array     	HXC_BLOCK_TABLE_TYPE;
l_messages		HXC_MESSAGE_TABLE_TYPE;

begin

  l_attribute_array := hxc_deposit_wrapper_utilities.attributes_to_array(
                         p_attributes => g_attributes);

   HXC_ALIAS_TRANSLATOR.DO_DEPOSIT_TRANSLATION
      (p_attributes => l_attribute_array,
       p_messages   => l_messages);

  g_attributes := hxc_deposit_wrapper_utilities.array_to_attributes(
                         p_attribute_array => l_attribute_array);


exception
  when others then
   FND_MESSAGE.set_name('HXC','HXC_ALIAS_TRANSLATION');
   FND_MESSAGE.RAISE_ERROR;

end;

procedure deposit_blocks
  (p_timecard_id out nocopy HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_timecard_ovn out nocopy HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  ,p_mode varchar2
  ,p_deposit_process varchar2
  ,p_retrieval_process varchar2 default null
  ,p_validate_session boolean default TRUE   --AI8
  ,p_add_security boolean default TRUE       --AI8
  ,p_allow_error_tc boolean default FALSE -- GPM v115.87
  ) IS
--
l_old_block                HXC_TIME_BUILDING_BLOCKS%ROWTYPE;
l_old_attribute            HXC_TIME_ATTRIBUTES%ROWTYPE;
l_time_building_block_id   HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE;
l_object_version_number    HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE;
l_max_ovn                  HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE;
l_deposit_process_id       NUMBER;
l_time_source_id           hxc_time_sources.time_source_id%TYPE;
l_time_source_name         hxc_time_sources.name%TYPE;
l_timecard                 hxc_time_attributes_api.timecard;
l_attribute_index          NUMBER;
l_bld_blk_info_type_id     NUMBER;
l_mapping_comp_usage_id    NUMBER;
l_component_row            hxc_mapping_components%ROWTYPE;
l_exception                EXCEPTION;
l_update_required          BOOLEAN := FALSE;
l_attribute_update_req     BOOLEAN := FALSE;
l_date                     DATE := SYSDATE;
l_block                    NUMBER;
x                          NUMBER;
l_proc                     VARCHAR2(30):='deposit_blocks';
l_app_valid_proc_id        HXC_RETRIEVAL_PROCESSES.RETRIEVAL_PROCESS_ID%TYPE;
l_retrieval_id             HXC_RETRIEVAL_PROCESSES.RETRIEVAL_PROCESS_ID%TYPE;
--l_app_attributes           app_attributes_info;
l_upd_sql                  VARCHAR2(2000);
l_val_sql                  VARCHAR2(2000);
l_block_string             VARCHAR2(32767);
l_attribute_string         VARCHAR2(32767);
l_bld_blk_attribute_string VARCHAR2(32767);
--l_message_string           VARCHAR2(32767);
l_message_count            NUMBER;
l_mode                     VARCHAR2(30) := 'UPDATE';
l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
l_resubmitted              VARCHAR2(3);
l_fnd_separator VARCHAR2(5) := FND_GLOBAL.LOCAL_CHR(0);
l_error_message            VARCHAR2(4000);
l_temp_temp_name           hxc_time_Attributes.attribute1%type;
l_transaction_tab	   hxc_deposit_wrapper_utilities.t_transaction;
l_overall_status	   varchar2(7) := 'SUCCESS';
l_approval_style_id	   HXC_APPROVAL_STYLES.APPROVAL_STYLE_ID%TYPE;

l_approval_timecard_id     HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE := null;
l_approval_timecard_ovn    HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE := null;

l_block_processed boolean :=false;

l_attributes_cp building_block_attribute_info;
l_timecard_cp timecard_info;
l_app_attributes_cp app_attributes_info;
--
l_submitted BOOLEAN;

--
CURSOR csr_time_building_block(p_building_block_id NUMBER
                              ,p_bb_ovn NUMBER) IS
select *
  from hxc_time_building_blocks
 where time_building_block_id = p_building_block_id
   and object_version_number = p_bb_ovn;
--
CURSOR csr_time_recipients(p_application_set_id IN NUMBER) IS
 SELECT tr.TIME_RECIPIENT_ID
       ,tr.NAME
       ,tr.APPLICATION_ID
       ,tr.OBJECT_VERSION_NUMBER
       ,tr.APPLICATION_RETRIEVAL_FUNCTION
       ,tr.APPLICATION_UPDATE_PROCESS
       ,tr.APPL_VALIDATION_PROCESS
  FROM hxc_time_recipients tr
      ,hxc_application_set_comps_v asc1
  where p_application_set_id = asc1.application_set_id
  and asc1.time_recipient_id = tr.time_recipient_id;
--
-- Removed cursor c_code_chk - No usage reference found
-- Refer to TMSTask12613 for further analysis.
--
CURSOR csr_resubmitted
         (p_timecard_id IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
         ,p_max_ovn     IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
         ) IS
 SELECT 'YES'
   FROM hxc_time_building_blocks
  WHERE time_building_block_id = p_timecard_id
    AND object_version_number < p_max_ovn
    AND approval_status = 'SUBMITTED';
--
/*
CURSOR csr_item_key
        (p_item_type IN wf_item_types.name%TYPE
        ) IS
 SELECT NVL(MAX(TO_NUMBER(item_key)),1)
   FROM wf_item_attribute_values
  WHERE item_type = p_item_type;
*/

cursor csr_item_key is
  select hxc_approval_item_key_s.nextval
    from dual;

-- GPM v115.42

CURSOR	csr_get_auto_approve IS
SELECT	has.approval_style_id
FROM	hxc_approval_styles has
WHERE	has.name = 'OTL Auto Approve';

-- GPM v115.42

CURSOR  csr_get_retrieval IS
SELECT  rp.retrieval_process_id
FROM    hxc_retrieval_processes rp
WHERE   name = p_retrieval_process;


l_template_name hxc_time_attributes.attribute1%type;

l_temp_att_count 	NUMBER := 0;
l_found_name 		BOOLEAN := FALSE;
l_index 		BINARY_INTEGER;
l_index_tc 		NUMBER :=0;

l_translated_bb_tab hxc_self_service_time_deposit.translate_bb_ids_tab;
l_translated_ta_tab hxc_self_service_time_deposit.translate_ta_ids_tab;

l_application_set_id NUMBER;

l_ind BINARY_INTEGER;

--
begin
--
--


savepoint start_deposit_wrapper;   --AI20 was rolling back beyond deposit wrapper

g_allow_error_tc := p_allow_error_tc;

l_submitted := FALSE; -- Used for Santos error check

l_max_ovn := 1;

l_mode := p_mode;
--
   -- loop through the arrays for building blocks and attributes
   -- and assign sequence numbers to any rows with the new flag
   -- set to 'Y'
   -- get the deposit process id

   SELECT dp.deposit_process_id, dp.time_source_id, ts.name
     INTO l_deposit_process_id, l_time_source_id, l_time_source_name
     FROM hxc_time_sources ts
	, hxc_deposit_processes dp
    WHERE dp.name = p_deposit_process -- GPM v115.42
      AND ts.time_source_id = dp.time_source_id;

    -- Order the time building blocks
    order_building_blocks;

    -- Denormalization of hours for RANGE type building blocks
    denormalize_time_info(p_mode=>'ADD');

    -- Set security information from profiles AI8
    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'start the set_security');
    end if;

    set_security(p_validate_session);

    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'end the set_security');
    end if;

    -- Add the security context if required
    if(p_add_security) then  --AI8
      add_security;
    end if;

    -- Correct update flags to reflect database inserts
    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'start the correct_update_flags');
    end if;

    correct_update_flags(p_allow_error_tc);

    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'end the correct_update_flags');
    end if;

    -- Next translate the entered attributes into the real attributes, in case
    -- there were any aliased fields on the timecard.
    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'start the alias_translation');
    end if;

    alias_translation;

    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'end the alias_translation');
    end if;

    --
    -- Don't do any validation for templates!
    --
  if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'g_timecard_block_oder(1)).scope :');
    end if;

    if (instr(g_timecard(
      g_timecard_block_order(1)).scope,'TIMECARD_TEMPLATE') < 1) then

    -- Don't do the validation for save!
    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'p_mode :'||p_mode);
    end if;

    if(p_mode <> 'SAVE') then

    -- Find the application validation process


    l_application_set_id:=
      hxc_preference_evaluation.resource_preferences(
            g_timecard(g_timecard_block_order(1)).resource_id,'TS_PER_APPLICATION_SET|1|');


-- Start change version 115.130
     -- Added by ksethi for support to ELP changes
     --
     -- Call to the ELP UTILS Procedure to update the
     -- Time Building Blocks with the Application Set
     -- information, once this proc is executed
     -- all TBB with SCOPE = ('TIMECARD','DAY', n 'DETAIL')
     -- have the application set id set
     --
     hxc_elp_utils.set_time_bb_appl_set_tk
                 (P_TIME_BUILDING_BLOCKS 	=>  g_timecard
     	   	 ,P_APPLICATION_SET_ID          =>  l_application_set_id
            	 );

-- End change version 115.130

    -- allow global tables to be updated from recipient application code
    set_update_phase(TRUE); --AI2.5

    FOR recipt_rec IN csr_time_recipients(l_application_set_id) LOOP

      --
      -- Make a call to get the application retrieval process id
      -- to use to build the structures we're going to send to the
      -- recipient applications for validation purposes
      --


      IF recipt_rec.application_retrieval_function IS NOT NULL THEN
        IF code_chk(recipt_rec.application_retrieval_function) THEN
          find_app_deposit_process
            (p_time_recipient_id => recipt_rec.time_recipient_id
            ,p_app_function => recipt_rec.application_retrieval_function
            ,p_retrieval_process_id => l_app_valid_proc_id
            );

          g_app_attributes := build_application_attributes(
              p_retrieval_process_id => l_app_valid_proc_id
             ,p_deposit_process_id => NULL --AI3
             ,p_for_time_attributes => FALSE);


        END IF;

      IF recipt_rec.application_update_process IS NOT NULL THEN
        IF code_chk(recipt_rec.application_update_process) THEN

          l_upd_sql := 'BEGIN '||fnd_global.newline
                   ||recipt_rec.application_update_process ||fnd_global.newline
                   ||'(p_operation => :1);'||fnd_global.newline
                   ||'END;';

           EXECUTE IMMEDIATE l_upd_sql
             using IN OUT l_mode;

    -- Update the g_attributes table from the g_app_attributes table

          update_deposit_globals (p_retrieval_process_id => l_app_valid_proc_id);
         END IF;
        END IF;

       END IF; -- If the application retrieval function is NULL

    END LOOP;

    -- disallow global tables to be updated from recipient application code
    set_update_phase(FALSE); --AI2.5

    --
    -- Do the validation rather than update.
    --
    FOR recipt_rec IN csr_time_recipients
                       (l_application_set_id) LOOP

      --
      -- Make a call to get the application retrieval process id
      -- to use to build the structures we're going to send to the
      -- recipient applications for validation purposes
      --

      IF recipt_rec.application_retrieval_function IS NOT NULL THEN
        IF code_chk(recipt_rec.application_retrieval_function) THEN
        find_app_deposit_process
          (p_time_recipient_id => recipt_rec.time_recipient_id
          ,p_app_function => recipt_rec.application_retrieval_function
          ,p_retrieval_process_id => l_app_valid_proc_id
          );
        g_app_attributes.delete;
        g_app_attributes := build_application_attributes(
            p_retrieval_process_id => l_app_valid_proc_id
           ,p_deposit_process_id => NULL --AI3
           ,p_for_time_attributes => FALSE);
        END IF;

      IF recipt_rec.appl_validation_process IS NOT NULL THEN
        IF code_chk(recipt_rec.appl_validation_process) THEN

        l_val_sql := 'BEGIN '||fnd_global.newline
                   ||recipt_rec.appl_validation_process ||fnd_global.newline
                   ||'(p_operation => :1);'||fnd_global.newline
                   ||'END;';

        EXECUTE IMMEDIATE l_val_sql
             using IN OUT l_mode;

       END IF;
      END IF;

      END IF; -- application retrieval function is null?


    END LOOP;

   --
   -- Execute the time entry rules stuff - working time directive
   -- Call this package directly, as it is required for all locales,
   -- for all businesses - GPM 3/28/2001
   --

		fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
		fnd_message.set_token('PROCEDURE', l_proc);
		fnd_message.set_token('STEP','This Deposit Wrapper no longer supported');
		FND_MSG_PUB.add;

   end if; --p_mode <> 'Save'

    --
    -- Call OTL Specific validation, to make sure everything is set up
    -- to use for the time store. We do this on SAVE as well as
    -- submit.
    --
   if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'g_app_attributes step ');
   end if;

   g_app_attributes := build_application_attributes(
                          p_retrieval_process_id => NULL
                         ,p_deposit_process_id => l_deposit_process_id   --AI3
                         ,p_for_time_attributes => TRUE);


  if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'HXC_SETUP_VALIDATION_PKG.EXECUTE_OTC_VALIDATION step ');
   end if;
/*
   HXC_SETUP_VALIDATION_PKG.EXECUTE_OTC_VALIDATION
   (P_OPERATION => l_mode
   ,P_TIME_BUILDING_BLOCKS => g_timecard
   ,P_TIME_ATTRIBUTES => g_attributes
   ,P_TIME_ATT_INFO => g_app_attributes
   ,P_MESSAGES => g_messages
   );
*/
else -- then it is a template
  --
  -- if this is a template, then we should check the name
  -- but only if we're creating a template, otherwise
  -- the name can be updated, and we should raise the
  -- same error, but if the name is the same, then we're ok
  --

  l_temp_att_count := g_attributes.first;

  loop

   exit when not (
                  (g_attributes.exists(l_temp_att_count))
                 OR
                  (NOT l_found_name)
                 );

     if (g_attributes(l_temp_att_count).building_block_id
          = g_timecard(g_timecard_block_order(1)).time_building_block_id) then


     -- ok have a timecard template attribute

     if (g_Attributes(l_temp_att_count).attribute_category = 'TEMPLATES') then

       l_template_name := g_attributes(l_temp_att_count).attribute1;

     --
     -- Check the value of the public/private flag based on the profile
     -- option value
     --
       g_attributes(l_temp_att_count).attribute2 := public_private;

     -- Bug 2336662
     -- This code segment is added for the Enhancement to the
     -- Performance of Template view.
     -- Here Resource Id of all Public Templates is made -1

        if g_attributes(l_temp_att_count).attribute2='PUBLIC' then
	           g_timecard(g_timecard_block_order(1)).resource_id := -1;
                   g_timecard(g_timecard_block_order(1)).resource_type := -1;
	end if;

     -- End of change

       l_found_name := TRUE;

     end if;

     end if;

   l_temp_att_count := g_attributes.next(l_temp_att_count);

  end loop;


  -- now check the template name

  if (template_name_exists(g_timecard(g_timecard_block_order(1)).resource_id
                          ,l_template_name
                          ,g_timecard(g_timecard_block_order(1)).time_building_block_id)) then

     --FND_MESSAGE.set_name('HXC','HXC_366204_TEMPLATE_NAME');
     --FND_MESSAGE.set_token('TEMPLATE_NAME',l_template_name);
     --FND_MSG_PUB.add;
     raise e_template_duplicate_name;
  end if;

end if;  -- only do the validation if this isn't a timecard template


   -- now for each building block... do some stuff

   -- Check that we've got no messages on the stack first, because
   -- that would indicate an error
/*
IF ( hxc_timekeeper_errors.rollback_tc (
        p_allow_error_tc => p_allow_error_tc
     ,  p_message_table  => g_messages
     ,  p_timecard       => g_timecard ) )
THEN

     -- remove any changes
     rollback to start_deposit_wrapper;   --AI20 was rolling back beyond deposit wrapper

ELSE
*/
	-- deposit as normal ( errored TC manipulation already performed
        -- in roolabck_tc )

-- GPM v115.42

IF ( p_mode = 'MIGRATION' AND g_messages.count = 0 )
THEN

	IF ( p_retrieval_process IS NOT NULL )
	THEN
		OPEN  csr_get_retrieval;
		FETCH csr_get_retrieval INTO l_retrieval_id;
		CLOSE csr_get_retrieval;
	ELSE
		FND_MESSAGE.set_name('HXC','HXC_0075_HDP_DPROC_NAME_MAND');
		FND_MSG_PUB.add;
	END IF;

	IF ( l_retrieval_id IS NULL )
	THEN
		fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
		fnd_message.set_token('PROCEDURE', l_proc);
		fnd_message.set_token('STEP','1');
		FND_MSG_PUB.add;
	END IF;

	-- if the mode is MIGRATION then this data needs
        -- also to be submitted as APPROVED.
        -- Override the person approval style to be
        -- OTL Auto Approve

	OPEN  csr_get_auto_approve;
	FETCH csr_get_auto_approve INTO l_approval_style_id;
	CLOSE csr_get_auto_approve;

	-- GPM v115.58

	HXC_SELF_SERVICE_TIME_DEPOSIT.SET_WORKFLOW_INFO(P_ITEM_TYPE    =>'HXCEMP',
                                                        P_PROCESS_NAME => 'HXC_APPROVAL');

	-- loop through the global table to override the
	-- approval style id

	l_index := g_timecard.FIRST;

	WHILE ( l_index IS NOT NULL )
	LOOP
		g_timecard(l_index).approval_style_id := l_approval_style_id;
                g_timecard(l_index).approval_status := 'SUBMITTED';

		l_index := g_timecard.NEXT(l_index);

	END LOOP;

END IF; -- IF p_mode = 'MIGRATION'

-- Clear out denormalization of start/stop times so that we dont store this information
   denormalize_time_info(p_mode => 'REMOVE');

   l_block := g_timecard_block_order.first;


   if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'l_block :'||l_block);
   end if;

   LOOP

     EXIT WHEN NOT g_timecard_block_order.exists(l_block);

      --
      -- Obtain the current parent information,
      -- we shouldn't have to do this because
      -- the API really ought not to allow us to update
      -- this, but it does at the moment.
      --
      x := g_timecard_block_order(l_block);

      IF g_timecard(x).NEW = 'Y' THEN
      --
      -- This building block doesn't exist
      -- Therefore it must be new
      -- We must still deposit it in the same
      -- way as before.
      -- The attached attributes must also be connected
      -- to this building block.
      --
      -- The end of time check is there to support
      -- performance advantage in the middle tier
      -- this avoids us having to regenerate the page
      -- if the user creates, and then immeadiately
      -- deletes rows in the timecard.  DO NOT REMOVE!


      IF(process_block(x,'UPDATE',p_allow_error_tc))
         THEN

         build_timecard_structure(
            p_block  => x
           ,p_deposit_process_id => l_deposit_process_id
           ,p_timecard    => l_timecard
           ,p_update_required  => l_attribute_update_req);
      --
      -- Next we perform the deposit of this block and
      -- attribute record.
      --
         l_time_building_block_id := NULL;
         l_object_version_number := NULL;
      --
      -- Put this into it's own PL/SQL block to ensure that
      -- we catch any PL/SQL errors, and show them in the
      -- correct way.  Here we won't be using multiple
      -- error messages, rather just one message, because
      -- the user should never see an error from this API

      BEGIN
        if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'process 2 ');
        end if;



        hxc_deposit_process_pkg.execute_deposit_process
           (p_time_building_block_id     => l_time_building_block_id
           ,p_process_name               => p_deposit_process
           ,p_source_name                => l_time_source_name
           ,p_effective_date             => sysdate
           ,p_type                       => g_timecard(x).type
           ,p_measure                    => g_timecard(x).measure
           ,p_unit_of_measure            => g_timecard(x).unit_of_measure
           ,p_start_time                 => g_timecard(x).start_time
           ,p_stop_time                  => g_timecard(x).stop_time
           ,p_parent_building_block_id   => g_timecard(x).parent_building_block_id
           ,p_parent_building_block_ovn  => g_timecard(x).parent_building_block_ovn
           ,p_scope                      => g_timecard(x).scope
           ,p_approval_style_id          => g_timecard(x).approval_style_id
           ,p_approval_status            => g_timecard(x).approval_status
           ,p_resource_id                => g_timecard(x).resource_id
           ,p_resource_type              => g_timecard(x).resource_type
           ,p_comment_text               => g_timecard(x).comment_text
           ,p_application_set_id         => g_timecard(x).application_set_id
           ,p_timecard                   => l_timecard
           ,p_object_version_number      => l_object_version_number
           );

        l_block_processed := true;

        if(g_timecard(x).scope = 'TIMECARD') then
          if(g_timecard(x).approval_status = 'SUBMITTED') then

            l_approval_timecard_id := l_time_building_block_id;
            l_approval_timecard_ovn := l_object_version_number;

          end if;
        end if;

        if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'l_time_building_block_id  :'||l_time_building_block_id||
                   ' l_object_version_number :'||l_object_version_number);
        end if;

	l_transaction_tab(x).tbb_id	:= l_time_building_block_id;
	l_transaction_tab(x).tbb_ovn	:= l_object_version_number;
	l_transaction_tab(x).status	:= 'SUCCESS';

       EXCEPTION
        when others then
		l_transaction_tab(x).tbb_id	:= NVL(l_time_building_block_id, -1);
		l_transaction_tab(x).tbb_ovn	:= NVL(l_object_version_number, -1);
		l_transaction_tab(x).status	:= 'ERRORS';
		l_transaction_tab(x).exception_desc	:= SUBSTR(SQLERRM,1,2000);
		l_overall_status		:= 'ERRORS';

          raise;
       END;

      -- Keep track of max OVN of all the building blocks in this timecard
      -- so that approvals process knows whether it is a resubmit or not.
      --
      IF l_max_ovn < l_object_version_number THEN
         l_max_ovn := l_object_version_number;
      END IF;
    if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'l_max_ovn  :'||l_max_ovn);
      end if;
      --
      -- Once the building block has been deposited, we can find all
      -- instances of other building blocks which pointed to this one
      -- as the parent, and update those records to point to the newly
      -- db created building block
      --
      if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'z  :');
      end if;

      l_index_tc := g_timecard.first;
	LOOP
     	  EXIT WHEN NOT g_timecard.exists(l_index_tc);
            IF (
              (g_timecard(l_index_tc).parent_building_block_id
               = g_timecard(x).time_building_block_id)
             AND
              (g_timecard(l_index_tc).parent_is_new = 'Y')
             ) THEN
             g_timecard(l_index_tc).parent_building_block_id := l_time_building_block_id;
             g_timecard(l_index_tc).parent_building_block_ovn := 1;
           END IF;

         l_index_tc := g_timecard.next(l_index_tc);
         END LOOP;


      -- Next we must update the actual values of the building block id etc.
      -- Held in our internal structure, in case we need these later, e.g.
      -- for the approvals process.

	l_translated_bb_tab(g_timecard(x).time_building_block_id).actual_bb_id := l_time_building_block_id;

        g_timecard(x).time_building_block_id := l_time_building_block_id;
        g_timecard(x).object_version_number := 1;

       END IF;
      ELSE
      --
      -- This is an existing building block, therefore
      -- we can check to see if anything has changed,
      -- to see whether we need to update this block
      --
         l_update_required := FALSE;
      --
      -- If the block corresponds to a NULLED out
      -- detail, we don't want to update it, if
      -- any of the other things have changed.
      --
         l_attribute_update_req := FALSE;

         open csr_time_building_block
                (g_timecard(x).time_building_block_id
                ,g_timecard(x).object_version_number);
         fetch csr_time_building_block into l_old_block;
         close csr_time_building_block;

         l_update_required := process_block(x,'UPDATE',p_allow_error_tc);

            build_timecard_structure(
              p_block  => x
             ,p_deposit_process_id => l_deposit_process_id
             ,p_timecard    => l_timecard
             ,p_update_required  => l_attribute_update_req);

      --
      -- execute the deposit process, passing the derived
      -- parent information, and only if something has
      -- change which requires the deposit.
      --
      if (
          (l_update_required OR l_attribute_update_req)
         AND
          (NOT process_block(x,'DELETE',p_allow_error_tc))
         ) THEN
       BEGIN
      if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'hxc_self_service_time_deposit.start_deposit_wrapper',
                   'process :'||g_timecard(x).time_building_block_id);
        end if;

        hxc_deposit_process_pkg.execute_deposit_process
           (p_time_building_block_id     => g_timecard(x).time_building_block_id
           ,p_process_name               => p_deposit_process
           ,p_source_name                => l_time_source_name
           ,p_effective_date             => sysdate
           ,p_type                       => g_timecard(x).type
           ,p_measure                    => g_timecard(x).measure
           ,p_unit_of_measure            => g_timecard(x).unit_of_measure
           ,p_start_time                 => g_timecard(x).start_time
           ,p_stop_time                  => g_timecard(x).stop_time
           ,p_parent_building_block_id   => g_timecard(x).parent_building_block_id
           ,p_parent_building_block_ovn  => g_timecard(x).parent_building_block_ovn
           ,p_scope                      => g_timecard(x).scope
           ,p_approval_style_id          => g_timecard(x).approval_style_id
           ,p_approval_status            => g_timecard(x).approval_status
           ,p_resource_id                => g_timecard(x).resource_id
           ,p_resource_type              => g_timecard(x).resource_type
           ,p_comment_text               => g_timecard(x).comment_text
           ,p_application_set_id         => g_timecard(x).application_set_id
           ,p_timecard                   => l_timecard
           ,p_object_version_number      => g_timecard(x).object_version_number
           );


        l_block_processed := true;

        if(g_timecard(x).scope = 'TIMECARD') then
          if(g_timecard(x).approval_status = 'SUBMITTED') then

            l_approval_timecard_id := g_timecard(x).time_building_block_id;
            l_approval_timecard_ovn := g_timecard(x).object_version_number;

          end if;
        end if;

	l_transaction_tab(x).tbb_id	:= g_timecard(x).time_building_block_id;
	l_transaction_tab(x).tbb_ovn	:= g_timecard(x).object_version_number;
	l_transaction_tab(x).status	:= 'SUCCESS';

       EXCEPTION
        when others then
		l_transaction_tab(x).tbb_id	:= g_timecard(x).time_building_block_id;
		l_transaction_tab(x).tbb_ovn	:= g_timecard(x).object_version_number;
		l_transaction_tab(x).status	:= 'ERRORS';
		l_transaction_tab(x).exception_desc	:= SUBSTR(SQLERRM, 1,2000);
		l_overall_status		:= 'ERRORS';

	  raise;
       END;
        --
        -- Keep track of max OVN of all the building blocks in this timecard
        -- so that approvals process knows whether it is a resubmit or not.
        --
        IF l_max_ovn < g_timecard(x).object_version_number THEN
           l_max_ovn := g_timecard(x).object_version_number;
        END IF;
        --
        -- Keep object version numbers in sync
        --
        update_ovns(g_timecard(x).time_building_block_id,
                    g_timecard(x).object_version_number);
        --
       ELSIF ( process_block(x,'DELETE',p_allow_error_tc)
             ) THEN
       --
       -- In this case, we've deleted a block in the timecard
       -- typically this will happen when the user clicks on the
       -- delete attribute row icon of the timecard
       --
       -- In this case, call the building block API directly, to
       -- date effectively end date the building block.
       -- FIX: Will this cause inconsistencies with the deposit API?
       --
       IF (g_timecard(x).measure IS NULL) THEN
          l_date := SYSDATE;
       ELSE
          l_date := g_timecard(x).date_to;
       END IF;

         l_block_processed := true;

         hxc_building_block_api.delete_building_block
          (p_validate => FALSE
          ,p_object_version_number => g_timecard(x).object_version_number
          ,p_time_building_block_id => g_timecard(x).time_building_block_id
          ,p_effective_date => l_date
          );
-- A. Rundell 115.118 Change.
-- Added to ensure the parent OVN of deleted parents
-- is set correctly.  note: this means that the
-- children of a deleted parent are implicitly also
-- deleted.

        update_ovns(g_timecard(x).time_building_block_id,
                    g_timecard(x).object_version_number);

--
-- End 115.118 Change
--

       end if;

    END IF;-- Is this a new or existing building block

    if (g_timecard(x).scope = 'TIMECARD') then

      p_timecard_id := g_timecard(x).time_building_block_id;
      p_timecard_ovn := g_timecard(x).object_version_number;

    end if;

    l_timecard.delete;

    l_block := g_timecard_block_order.next(l_block);

   END LOOP;

	-- GPM v115.87
	-- GPM v115.89 - added .FIRST

	IF ( g_timecard((g_timecard.FIRST)).approval_status = 'ERROR' )
	THEN
		l_overall_status := 'ERRORS';
	END IF;

	hxc_deposit_wrapper_utilities.audit_transaction (
		p_effective_date         => sysdate
	,	p_transaction_type	 => 'DEPOSIT'
	,	p_transaction_process_id => l_deposit_process_id
	,	p_overall_status         => l_overall_status
	,	p_transaction_tab        => l_transaction_tab );

	-- GPM v115.42

	IF ( p_mode = 'MIGRATION' AND l_overall_status = 'SUCCESS' )
	THEN

		hxc_deposit_wrapper_utilities.audit_transaction (
			p_effective_date         => sysdate
		,	p_transaction_type	 => 'RETRIEVAL'
		,	p_transaction_process_id => l_app_valid_proc_id
		,	p_overall_status         => l_overall_status
		,	p_transaction_tab        => l_transaction_tab );

	END IF;

--   COMMIT;

-- Add denormalization again. This is for those applications that use the approval
-- extensions
    denormalize_time_info(p_mode=>'ADD');

--
-- Now check to see if we have to resubmit
--
 if((l_approval_timecard_id is null) and (l_block_processed)) then

   -- find the timecard id!
   l_block := g_timecard.first;
   l_block_processed :=false;

   LOOP
    EXIT WHEN ((not g_timecard.exists(l_block)) OR (l_block_processed));

    if((g_timecard(l_block).time_building_block_id > 0)
     AND
       (g_timecard(l_block).scope='TIMECARD')
     AND
       (g_timecard(l_block).approval_status = 'SUBMITTED')
     AND
       (g_timecard(l_block).date_to = hr_general.end_of_time)
      ) then

        l_approval_timecard_id := g_timecard(l_block).time_building_block_id;
        l_approval_timecard_ovn := g_timecard(l_block).object_version_number;
        l_block_processed := true;

    end if;

    l_block := g_timecard.next(l_block);

   END LOOP;

 end if;

 --
 -- Don't bother to check approval for templates!
 --

 if((l_approval_timecard_id is not null) AND ((p_mode <> 'DELETE') or (p_mode <> 'SAVE'))) THEN
--
-- Next include the approvals process
--
-- Until we workflow the timecard, we need to start the
-- approvals process here.
-- Get the item key
--
    OPEN csr_item_key;
    FETCH csr_item_key into l_item_key;
    close csr_item_key;

    OPEN csr_resubmitted
         (p_timecard_id => g_timecard(g_timecard_block_order(1)).time_building_block_id
         ,p_max_ovn => l_max_ovn
         );
    FETCH csr_resubmitted INTO l_resubmitted;

    IF csr_resubmitted%NOTFOUND THEN

      l_resubmitted := 'NO';

    END IF;

    CLOSE csr_resubmitted;

     HXC_APPROVAL_WF_PKG.start_approval_wf_process
       (p_item_type => g_workflow.item_type
       ,p_item_key => l_item_key
       ,p_tc_bb_id => l_approval_timecard_id
       ,p_tc_ovn => l_approval_timecard_ovn
       ,p_tc_resubmitted => l_resubmitted
       ,p_error_table => g_messages
       ,p_time_building_blocks => g_timecard
       ,p_time_attributes => g_attributes
       ,p_bb_new => g_new_bbs
       );

     l_submitted := true;

 end if;

--
--end if; -- were any errors in the update, validate or set up checks?

--
-- Check that if the mode was submit, the timecard
-- did actually get submitted and the workflow started
-- if not, throw an error.  This functionality was
-- added for Santos.  It will be removed in future
-- when the time entry rule functions are used for this
-- purpose.


  if(g_messages.count = 0) then
   if((p_mode = 'SUBMIT') AND (NOT l_submitted)) then


            hxc_time_entry_rules_utils_pkg.add_error_to_table (
                                p_message_table => g_messages
                        ,       p_message_name  => 'HXC_TIMECARD_NOT_SUBMITTED'
                        ,       p_message_token => NULL
                        ,       p_message_level => 'ERROR'
                        ,       p_message_field         => NULL
                        ,       p_timecard_bb_id        => g_timecard(g_timecard.FIRST).time_building_block_id
		        ,	p_timecard_bb_ovn   => g_timecard(g_timecard.FIRST).object_version_number     --added 2822462
                        ,       p_time_attribute_id     => NULL);
/*
         IF ( hxc_timekeeper_errors.rollback_tc (
                 p_allow_error_tc => p_allow_error_tc
              ,  p_message_table  => g_messages
              ,  p_timecard       => g_timecard ) )
	THEN

	     raise e_approval_check;

	END IF;
*/
   end if;
  end if;

-- now maintain the error table
/*
IF ( g_messages.COUNT <> 0 AND l_transaction_tab.COUNT <> 0 )
THEN

	hxc_timekeeper_errors.maintain_errors (
	  p_translated_bb_ids_tab => l_translated_bb_tab
	, p_translated_ta_ids_tab => l_translated_ta_tab -- GAZ - need to get TA trans tab
	, p_messages              => g_messages
	, p_transactions          => l_transaction_tab );

END IF;
*/

    show_errors(p_messages => g_messages );

EXCEPTION
  when e_timecard_overlap then
    rollback to start_deposit_wrapper;
    fnd_msg_pub.add;
    fnd_message.clear;

  when e_approval_check then
    rollback to start_deposit_wrapper;
    show_errors ( p_messages => g_messages );

    when e_template_duplicate_name then
        hxc_time_entry_rules_utils_pkg.add_error_to_table (
	 	                                p_message_table => g_messages
	 	                        ,       p_message_name  => 'HXC_366204_TEMPLATE_NAME'
	 	                        ,       p_message_token => 'TEMPLATE_NAME&'||l_template_name
	 	                        ,       p_message_level => 'ERROR'
	 	                        ,       p_message_field => NULL
			                ,	p_timecard_bb_id	=> NULL
			                ,	p_time_attribute_id	=> NULL
                                        ,       p_timecard_bb_ovn       => NULL
                                        ,       p_time_attribute_ovn    => NULL
                                                        );


         show_errors( p_messages => g_messages );

  when others then

	hxc_time_entry_rules_utils_pkg.add_error_to_table (
				p_message_table	=> g_messages
			,	p_message_name	=> 'EXCEPTION' -- GPM v115.116
			,	p_message_token	=> NULL
			,	p_message_level	=> 'ERROR'
			,	p_message_field		=> NULL
			,	p_timecard_bb_id	=> g_timecard(g_timecard.FIRST).time_building_block_id
			,	p_time_attribute_id	=> NULL
                        ,       p_timecard_bb_ovn       => g_timecard(g_timecard.FIRST).object_Version_number
                        ,       p_time_attribute_ovn    => NULL );

	show_errors( p_messages => g_messages );

IF ( l_transaction_tab.count <> 0 )
THEN

	l_overall_status := 'ERROR';

	hxc_deposit_wrapper_utilities.audit_transaction (
		p_effective_date         => sysdate
	,	p_transaction_type	 => 'DEPOSIT'
	,	p_transaction_process_id => l_deposit_process_id
	,	p_overall_status         => l_overall_status
	,	p_transaction_tab        => l_transaction_tab );

	-- GPM V115.116
/*
         IF ( hxc_timekeeper_errors.rollback_tc (
                 p_allow_error_tc => p_allow_error_tc
              ,  p_message_table  => g_messages
              ,  p_timecard       => g_timecard ) )
	THEN
		rollback to start_deposit_wrapper;
		raise;
	ELSE
		hxc_timekeeper_errors.maintain_errors (
		  p_translated_bb_ids_tab => l_translated_bb_tab
		, p_translated_ta_ids_tab => l_translated_ta_tab -- GAZ - need to get TA trans tab
		, p_messages              => g_messages
		, p_transactions          => l_transaction_tab );

	END IF;
*/
END IF;

--
END deposit_blocks;

-- procedure
--   delete_timecard
--
-- description
--   deletes (effectively end-dates) an entire timecard in the time store
--   The method used to delete the timecard is to read back all the blocks
--   involved and use block deposits to end_date each block and update the
--   ovns. The deleted timecard is then deposited using deposit blocks which
--   makes sure that applications have the chance to validate the deleted timecard
--   and also that if a submitted timecard is deleted then the empty timecard
--   gets submitted. The deletion of details that this routine carries out should
--   be indentical to that which happens if you use the timecard to individually
--   delete each of those entries
--
-- parameters
--   p_time_building_block_id   - time building block id
--   p_effective_date           - effective date

procedure delete_timecard
  (p_time_building_block_id in number
  ,p_effective_date         in date
  ,p_mode varchar2
  ,p_deposit_process varchar2
  ,p_retrieval_process varchar2
  ) is

cursor get_attributes(p_tbb_id in number,p_tbb_ovn in number)
is
select
 ta.TIME_ATTRIBUTE_ID   ta_id
,bbit.BLD_BLK_INFO_TYPE ta_BLD_BLK_INFO_TYPE
,ta.ATTRIBUTE_CATEGORY  ta_ATTRIBUTE_CATEGORY
,ta.ATTRIBUTE1          ta_ATTRIBUTE1
,ta.ATTRIBUTE2          ta_ATTRIBUTE2
,ta.ATTRIBUTE3          ta_ATTRIBUTE3
,ta.ATTRIBUTE4          ta_ATTRIBUTE4
,ta.ATTRIBUTE5          ta_ATTRIBUTE5
,ta.ATTRIBUTE6          ta_ATTRIBUTE6
,ta.ATTRIBUTE7          ta_ATTRIBUTE7
,ta.ATTRIBUTE8          ta_ATTRIBUTE8
,ta.ATTRIBUTE9          ta_ATTRIBUTE9
,ta.ATTRIBUTE10         ta_ATTRIBUTE10
,ta.ATTRIBUTE11         ta_ATTRIBUTE11
,ta.ATTRIBUTE12         ta_ATTRIBUTE12
,ta.ATTRIBUTE13         ta_ATTRIBUTE13
,ta.ATTRIBUTE14         ta_ATTRIBUTE14
,ta.ATTRIBUTE15         ta_ATTRIBUTE15
,ta.ATTRIBUTE16         ta_ATTRIBUTE16
,ta.ATTRIBUTE17         ta_ATTRIBUTE17
,ta.ATTRIBUTE18         ta_ATTRIBUTE18
,ta.ATTRIBUTE19         ta_ATTRIBUTE19
,ta.ATTRIBUTE20         ta_ATTRIBUTE20
,ta.ATTRIBUTE21         ta_ATTRIBUTE21
,ta.ATTRIBUTE22         ta_ATTRIBUTE22
,ta.ATTRIBUTE23         ta_ATTRIBUTE23
,ta.ATTRIBUTE24         ta_ATTRIBUTE24
,ta.ATTRIBUTE25         ta_ATTRIBUTE25
,ta.ATTRIBUTE26         ta_ATTRIBUTE26
,ta.ATTRIBUTE27         ta_ATTRIBUTE27
,ta.ATTRIBUTE28         ta_ATTRIBUTE28
,ta.ATTRIBUTE29         ta_ATTRIBUTE29
,ta.ATTRIBUTE30         ta_ATTRIBUTE30
,ta.BLD_BLK_INFO_TYPE_ID  ta_INFO_TYPE
,ta.OBJECT_VERSION_NUMBER  ta_OVN
from   hxc_time_attribute_usages tau,
       hxc_time_attributes ta,
       hxc_bld_blk_info_types bbit
where  tau.time_building_block_id = p_tbb_id
and    tau.time_building_block_ovn = p_tbb_ovn
and    ta.time_attribute_id = tau.time_attribute_id
and    ta.bld_blk_info_type_id = bbit.bld_blk_info_type_id;

cursor get_timecard_building_block(p_timecard_block in number)
is
select
tbb_tim.time_building_block_id  tbb_tim_id,
tbb_tim.object_version_number   tbb_tim_ovn,
tbb_tim.type                    tbb_tim_type,
tbb_tim.measure                 tbb_tim_measure,
tbb_tim.unit_of_measure         tbb_tim_unit_of_measure,
tbb_tim.start_time              tbb_tim_start_time,
tbb_tim.stop_time               tbb_tim_stop_time,
tbb_tim.scope                   tbb_tim_scope,
tbb_tim.approval_status         tbb_tim_approval_status,
tbb_tim.resource_id             tbb_tim_resource_id,
tbb_tim.resource_type           tbb_tim_resource_type,
tbb_tim.approval_style_id       tbb_tim_approval_style,
tbb_tim.date_from               tbb_tim_date_from,
tbb_tim.date_to                 tbb_tim_date_to,
tbb_tim.comment_text            tbb_tim_comment_text
from   hxc_time_building_blocks tbb_tim
where  tbb_tim.time_building_block_id = p_timecard_block
and    tbb_tim.date_to = hr_general.end_of_time
and    (tbb_tim.scope='TIMECARD' or tbb_tim.scope='TIMECARD_TEMPLATE');

cursor get_day_building_blocks(p_timecard_block in number,p_timecard_ovn in number)
is
select
tbb_day.time_building_block_id tbb_day_id,
tbb_day.object_version_number  tbb_day_ovn,
tbb_day.type                   tbb_day_type,
tbb_day.measure                tbb_day_measure,
tbb_day.unit_of_measure        tbb_day_unit_of_measure,
tbb_day.start_time             tbb_day_start_time,
tbb_day.stop_time              tbb_day_stop_time,
tbb_day.scope                  tbb_day_scope,
tbb_day.approval_status        tbb_day_approval_status,
tbb_day.resource_id            tbb_day_resource_id,
tbb_day.resource_type          tbb_day_resource_type,
tbb_day.approval_style_id      tbb_day_approval_style,
tbb_day.date_from              tbb_day_date_from,
tbb_day.date_to                tbb_day_date_to,
tbb_day.comment_text           tbb_day_comment_text
from  hxc_time_building_blocks tbb_day
where tbb_day.parent_building_block_ovn = p_timecard_ovn
and   tbb_day.parent_building_block_id  = p_timecard_block
and   tbb_day.date_to = hr_general.end_of_time
and   tbb_day.scope='DAY';

cursor get_detail_building_blocks(p_timecard_block in number,p_timecard_ovn in number)
is
select
tbb_det.time_building_block_id tbb_det_id,
tbb_det.object_version_number  tbb_det_ovn,
tbb_day.time_building_block_id tbb_day_id,
tbb_day.object_version_number  tbb_day_ovn,
tbb_det.type                   tbb_det_type,
tbb_det.measure                tbb_det_measure,
tbb_det.unit_of_measure        tbb_det_unit_of_measure,
tbb_det.start_time             tbb_det_start_time,
tbb_det.stop_time              tbb_det_stop_time,
tbb_det.scope                  tbb_det_scope,
tbb_det.approval_status        tbb_det_approval_status,
tbb_det.resource_id            tbb_det_resource_id,
tbb_det.resource_type          tbb_det_resource_type,
tbb_det.approval_style_id      tbb_det_approval_style,
tbb_det.date_from              tbb_det_date_from,
tbb_det.date_to                tbb_det_date_to,
tbb_det.comment_text           tbb_det_comment_text
from   hxc_time_building_blocks tbb_day,
       hxc_time_building_blocks tbb_det
where  tbb_day.parent_building_block_ovn = p_timecard_ovn
and    tbb_day.parent_building_block_id  = p_timecard_block
and    tbb_det.parent_building_block_ovn = tbb_day.object_version_number
and    tbb_det.parent_building_block_id  = tbb_day.time_building_block_id
and    tbb_det.date_to = hr_general.end_of_time
-- Why this condition is not met for a submitted timecard but is for saved timecards?
-- and    tbb_day.date_to = hr_general.end_of_time
and    tbb_det.scope='DETAIL';

-- Bug Fix for 2388621
-- Cursor to fetch the template details
cursor get_template_details(p_time_building_block_id in number)
is
select attribute2||'|'||tau.time_building_block_id
from hxc_time_attributes ta,
     hxc_time_attribute_usages tau
where ta.time_attribute_id=tau.time_attribute_id
and   ta.attribute_category='TEMPLATES'
and   tau.time_building_block_id=p_time_building_block_id;

l_timecard_ovn number;
l_timecard_block number;
l_returned_timecard_id number;
l_returned_timecard_ovn number;
l_scope hxc_time_building_blocks.scope%TYPE;

e_no_such_timecard   exception;
e_not_timecard_scope exception;

l_exists      VARCHAR2(6)   := NULL;
l_pref_value  VARCHAR2(170) := NULL;

begin

HXC_SELF_SERVICE_TIME_DEPOSIT.SET_WORKFLOW_INFO(P_ITEM_TYPE =>'HXCEMP',
                                                P_PROCESS_NAME => 'HXC_APPROVAL');
HXC_SELF_SERVICE_TIME_DEPOSIT.INITIALIZE_GLOBALS;

-- Pick up the timecard block. Trap the no_data_found exeption for this
-- pl/sql block as it means that p_timecard_block is not a valid building_block

begin
for l_tc in get_timecard_building_block(p_time_building_block_id) loop

HXC_SELF_SERVICE_TIME_DEPOSIT.deposit_block_info(
 P_TIME_BUILDING_BLOCK_ID   => l_tc.tbb_tim_id
,P_TYPE                     => l_tc.tbb_tim_type
,P_MEASURE                  => l_tc.tbb_tim_measure
,P_UNIT_OF_MEASURE          => l_tc.tbb_tim_unit_of_measure
,P_START_TIME               => l_tc.tbb_tim_start_time
,P_STOP_TIME                => l_tc.tbb_tim_stop_time
,P_PARENT_BUILDING_BLOCK_ID => null
,P_PARENT_IS_NEW            => 'N'
,P_SCOPE                    => l_tc.tbb_tim_scope
,P_OBJECT_VERSION_NUMBER    => l_tc.tbb_tim_ovn
,P_APPROVAL_STATUS          => l_tc.tbb_tim_approval_status
,P_RESOURCE_ID              => l_tc.tbb_tim_resource_id
,P_RESOURCE_TYPE            => l_tc.tbb_tim_resource_type
,P_APPROVAL_STYLE_ID        => l_tc.tbb_tim_approval_style
,P_DATE_FROM                => l_tc.tbb_tim_date_from
,P_DATE_TO                  => p_effective_date
,P_COMMENT_TEXT             => l_tc.tbb_tim_comment_text
,P_PARENT_BUILDING_BLOCK_OVN => null
,P_NEW                       => 'N'
,P_CHANGED                   => 'Y'
);

  for l_tc_attribute in get_attributes(l_tc.tbb_tim_id, l_tc.tbb_tim_ovn) loop

HXC_SELF_SERVICE_TIME_DEPOSIT.deposit_attribute_info(
 p_TIME_ATTRIBUTE_ID     => l_tc_attribute.ta_id
,p_BUILDING_BLOCK_ID     => l_tc.tbb_tim_id
,p_BLD_BLK_INFO_TYPE  => l_tc_attribute.ta_BLD_BLK_INFO_TYPE
,p_ATTRIBUTE_CATEGORY => l_tc_attribute.ta_ATTRIBUTE_CATEGORY
,p_ATTRIBUTE1         => l_tc_attribute.ta_ATTRIBUTE1
,p_ATTRIBUTE2         => l_tc_attribute.ta_ATTRIBUTE2
,p_ATTRIBUTE3         => l_tc_attribute.ta_ATTRIBUTE3
,p_ATTRIBUTE4         => l_tc_attribute.ta_ATTRIBUTE4
,p_ATTRIBUTE5         => l_tc_attribute.ta_ATTRIBUTE5
,p_ATTRIBUTE6         => l_tc_attribute.ta_ATTRIBUTE6
,p_ATTRIBUTE7         => l_tc_attribute.ta_ATTRIBUTE7
,p_ATTRIBUTE8         => l_tc_attribute.ta_ATTRIBUTE8
,p_ATTRIBUTE9         => l_tc_attribute.ta_ATTRIBUTE9
,p_ATTRIBUTE10        => l_tc_attribute.ta_ATTRIBUTE10
,p_ATTRIBUTE11        => l_tc_attribute.ta_ATTRIBUTE11
,p_ATTRIBUTE12        => l_tc_attribute.ta_ATTRIBUTE12
,p_ATTRIBUTE13        => l_tc_attribute.ta_ATTRIBUTE13
,p_ATTRIBUTE14        => l_tc_attribute.ta_ATTRIBUTE14
,p_ATTRIBUTE15        => l_tc_attribute.ta_ATTRIBUTE15
,p_ATTRIBUTE16        => l_tc_attribute.ta_ATTRIBUTE16
,p_ATTRIBUTE17        => l_tc_attribute.ta_ATTRIBUTE17
,p_ATTRIBUTE18        => l_tc_attribute.ta_ATTRIBUTE18
,p_ATTRIBUTE19        => l_tc_attribute.ta_ATTRIBUTE19
,p_ATTRIBUTE20        => l_tc_attribute.ta_ATTRIBUTE20
,p_ATTRIBUTE21        => l_tc_attribute.ta_ATTRIBUTE21
,p_ATTRIBUTE22        => l_tc_attribute.ta_ATTRIBUTE22
,p_ATTRIBUTE23        => l_tc_attribute.ta_ATTRIBUTE23
,p_ATTRIBUTE24        => l_tc_attribute.ta_ATTRIBUTE24
,p_ATTRIBUTE25        => l_tc_attribute.ta_ATTRIBUTE25
,p_ATTRIBUTE26        => l_tc_attribute.ta_ATTRIBUTE26
,p_ATTRIBUTE27        => l_tc_attribute.ta_ATTRIBUTE27
,p_ATTRIBUTE28        => l_tc_attribute.ta_ATTRIBUTE28
,p_ATTRIBUTE29        => l_tc_attribute.ta_ATTRIBUTE29
,p_ATTRIBUTE30        => l_tc_attribute.ta_ATTRIBUTE30
,p_BLD_BLK_INFO_TYPE_ID => l_tc_attribute.ta_info_type
,p_OBJECT_VERSION_NUMBER => l_tc_attribute.ta_ovn
,p_NEW                   => 'N'
,p_changed               => 'N');

-- keep some information about the timecard block for use later
l_timecard_block := l_tc.tbb_tim_id;
l_timecard_ovn   := l_tc.tbb_tim_ovn;
l_scope          := l_tc.tbb_tim_scope;

  end loop;
end loop;
exception
  when no_data_found then
    raise e_no_such_timecard;
end;

-- double check that p_timecard_block is of the right scope
if l_scope not in ('TIMECARD', 'TIMECARD_TEMPLATE') then
  raise e_not_timecard_scope;
end if;


-- Bug Fix for 2388621 - Start
-- Check whether the template is used in 'Self-Service Default
-- Template Selected by User' and 'Self-Service Default Template
-- assigned by Sys Admin' Preferences. If so, the template can't be
-- deleted and  raise the exception.
-- This exception will be handled by the TemplatesVOImpl.java file.

if l_scope = 'TIMECARD_TEMPLATE' then
  open get_template_details(p_time_building_block_id);
  fetch get_template_details into l_pref_value;
  if get_template_details%found then
     l_exists := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                       ('TC_W_TMPLT_DFLT_VAL_USR'
                        ,1
                        ,l_pref_value);
      if ( l_exists <> 0 ) THEN
         close get_template_details;
         FND_MESSAGE.SET_NAME('HXC','HXC_CANT_DEL_TEMPL');
         FND_MESSAGE.RAISE_ERROR;
      END if;

     l_exists := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                       ('TC_W_TMPLT_DFLT_VAL_ADMIN'
                        ,1
                        ,l_pref_value);
      if ( l_exists <> 0 ) THEN
         close get_template_details;
         FND_MESSAGE.SET_NAME('HXC','HXC_CANT_DEL_TEMPL');
         FND_MESSAGE.RAISE_ERROR;
      END if;
   END IF;
  close get_template_details;
END IF;

-- Bug Fix for 2388621 - End

-- now for the DETAILs

for l_detail in get_detail_building_blocks(l_timecard_block,l_timecard_ovn) loop

HXC_SELF_SERVICE_TIME_DEPOSIT.deposit_block_info(
 P_TIME_BUILDING_BLOCK_ID   => l_detail.tbb_det_id
,P_TYPE                     => l_detail.tbb_det_type
,P_MEASURE                  => l_detail.tbb_det_measure
,P_UNIT_OF_MEASURE          => l_detail.tbb_det_unit_of_measure
,P_START_TIME               => l_detail.tbb_det_start_time
,P_STOP_TIME                => l_detail.tbb_det_stop_time
,P_PARENT_BUILDING_BLOCK_ID => l_detail.tbb_day_id
,P_PARENT_IS_NEW            => 'N'
,P_SCOPE                    => l_detail.tbb_det_scope
,P_OBJECT_VERSION_NUMBER    => l_detail.tbb_det_ovn
,P_APPROVAL_STATUS          => l_detail.tbb_det_approval_status
,P_RESOURCE_ID              => l_detail.tbb_det_resource_id
,P_RESOURCE_TYPE            => l_detail.tbb_det_resource_type
,P_APPROVAL_STYLE_ID        => l_detail.tbb_det_approval_style
,P_DATE_FROM                => l_detail.tbb_det_date_from
,P_DATE_TO                  => p_effective_date
,P_COMMENT_TEXT             => l_detail.tbb_det_comment_text
,P_PARENT_BUILDING_BLOCK_OVN => l_detail.tbb_day_ovn+1
,P_NEW                       => 'N'
,P_CHANGED                   => 'Y'
);

  for l_detail_attribute in get_attributes(l_detail.tbb_det_id, l_detail.tbb_det_ovn) loop

HXC_SELF_SERVICE_TIME_DEPOSIT.deposit_attribute_info(
 p_TIME_ATTRIBUTE_ID     => l_detail_attribute.ta_id
,p_BUILDING_BLOCK_ID     => l_detail.tbb_det_id
,p_BLD_BLK_INFO_TYPE  => l_detail_attribute.ta_BLD_BLK_INFO_TYPE
,p_ATTRIBUTE_CATEGORY => l_detail_attribute.ta_ATTRIBUTE_CATEGORY
,p_ATTRIBUTE1         => l_detail_attribute.ta_ATTRIBUTE1
,p_ATTRIBUTE2         => l_detail_attribute.ta_ATTRIBUTE2
,p_ATTRIBUTE3         => l_detail_attribute.ta_ATTRIBUTE3
,p_ATTRIBUTE4         => l_detail_attribute.ta_ATTRIBUTE4
,p_ATTRIBUTE5         => l_detail_attribute.ta_ATTRIBUTE5
,p_ATTRIBUTE6         => l_detail_attribute.ta_ATTRIBUTE6
,p_ATTRIBUTE7         => l_detail_attribute.ta_ATTRIBUTE7
,p_ATTRIBUTE8         => l_detail_attribute.ta_ATTRIBUTE8
,p_ATTRIBUTE9         => l_detail_attribute.ta_ATTRIBUTE9
,p_ATTRIBUTE10        => l_detail_attribute.ta_ATTRIBUTE10
,p_ATTRIBUTE11        => l_detail_attribute.ta_ATTRIBUTE11
,p_ATTRIBUTE12        => l_detail_attribute.ta_ATTRIBUTE12
,p_ATTRIBUTE13        => l_detail_attribute.ta_ATTRIBUTE13
,p_ATTRIBUTE14        => l_detail_attribute.ta_ATTRIBUTE14
,p_ATTRIBUTE15        => l_detail_attribute.ta_ATTRIBUTE15
,p_ATTRIBUTE16        => l_detail_attribute.ta_ATTRIBUTE16
,p_ATTRIBUTE17        => l_detail_attribute.ta_ATTRIBUTE17
,p_ATTRIBUTE18        => l_detail_attribute.ta_ATTRIBUTE18
,p_ATTRIBUTE19        => l_detail_attribute.ta_ATTRIBUTE19
,p_ATTRIBUTE20        => l_detail_attribute.ta_ATTRIBUTE20
,p_ATTRIBUTE21        => l_detail_attribute.ta_ATTRIBUTE21
,p_ATTRIBUTE22        => l_detail_attribute.ta_ATTRIBUTE22
,p_ATTRIBUTE23        => l_detail_attribute.ta_ATTRIBUTE23
,p_ATTRIBUTE24        => l_detail_attribute.ta_ATTRIBUTE24
,p_ATTRIBUTE25        => l_detail_attribute.ta_ATTRIBUTE25
,p_ATTRIBUTE26        => l_detail_attribute.ta_ATTRIBUTE26
,p_ATTRIBUTE27        => l_detail_attribute.ta_ATTRIBUTE27
,p_ATTRIBUTE28        => l_detail_attribute.ta_ATTRIBUTE28
,p_ATTRIBUTE29        => l_detail_attribute.ta_ATTRIBUTE29
,p_ATTRIBUTE30        => l_detail_attribute.ta_ATTRIBUTE30
,p_BLD_BLK_INFO_TYPE_ID => l_detail_attribute.ta_info_type
,p_OBJECT_VERSION_NUMBER => l_detail_attribute.ta_ovn
,p_NEW                   => 'N'
,p_changed               => 'N');
  end loop;
end loop;

-- now for the DAYs

for l_day in get_day_building_blocks(l_timecard_block,l_timecard_ovn) loop

HXC_SELF_SERVICE_TIME_DEPOSIT.deposit_block_info(
 P_TIME_BUILDING_BLOCK_ID   => l_day.tbb_day_id
,P_TYPE                     => l_day.tbb_day_type
,P_MEASURE                  => l_day.tbb_day_measure
,P_UNIT_OF_MEASURE          => l_day.tbb_day_unit_of_measure
,P_START_TIME               => l_day.tbb_day_start_time
,P_STOP_TIME                => l_day.tbb_day_stop_time
,P_PARENT_BUILDING_BLOCK_ID => l_timecard_block
,P_PARENT_IS_NEW            => 'N'
,P_SCOPE                    => l_day.tbb_day_scope
,P_OBJECT_VERSION_NUMBER    => l_day.tbb_day_ovn
,P_APPROVAL_STATUS          => l_day.tbb_day_approval_status
,P_RESOURCE_ID              => l_day.tbb_day_resource_id
,P_RESOURCE_TYPE            => l_day.tbb_day_resource_type
,P_APPROVAL_STYLE_ID        => l_day.tbb_day_approval_style
,P_DATE_FROM                => l_day.tbb_day_date_from
--,P_DATE_TO                => l_day.tbb_day_date_to
,P_DATE_TO                  => p_effective_date
,P_COMMENT_TEXT             => l_day.tbb_day_comment_text
,P_PARENT_BUILDING_BLOCK_OVN => l_timecard_ovn+1
,P_NEW                       => 'N'
,P_CHANGED                   => 'Y'
);

for l_day_attribute in get_attributes(l_day.tbb_day_id, l_day.tbb_day_ovn) loop

HXC_SELF_SERVICE_TIME_DEPOSIT.deposit_attribute_info(
 p_TIME_ATTRIBUTE_ID     => l_day_attribute.ta_id
,p_BUILDING_BLOCK_ID     => l_day.tbb_day_id
,p_BLD_BLK_INFO_TYPE => l_day_attribute.ta_BLD_BLK_INFO_TYPE
,p_ATTRIBUTE_CATEGORY => l_day_attribute.ta_ATTRIBUTE_CATEGORY
,p_ATTRIBUTE1         => l_day_attribute.ta_ATTRIBUTE1
,p_ATTRIBUTE2         => l_day_attribute.ta_ATTRIBUTE2
,p_ATTRIBUTE3         => l_day_attribute.ta_ATTRIBUTE3
,p_ATTRIBUTE4         => l_day_attribute.ta_ATTRIBUTE4
,p_ATTRIBUTE5         => l_day_attribute.ta_ATTRIBUTE5
,p_ATTRIBUTE6         => l_day_attribute.ta_ATTRIBUTE6
,p_ATTRIBUTE7         => l_day_attribute.ta_ATTRIBUTE7
,p_ATTRIBUTE8         => l_day_attribute.ta_ATTRIBUTE8
,p_ATTRIBUTE9         => l_day_attribute.ta_ATTRIBUTE9
,p_ATTRIBUTE10        => l_day_attribute.ta_ATTRIBUTE10
,p_ATTRIBUTE11        => l_day_attribute.ta_ATTRIBUTE11
,p_ATTRIBUTE12        => l_day_attribute.ta_ATTRIBUTE12
,p_ATTRIBUTE13        => l_day_attribute.ta_ATTRIBUTE13
,p_ATTRIBUTE14        => l_day_attribute.ta_ATTRIBUTE14
,p_ATTRIBUTE15        => l_day_attribute.ta_ATTRIBUTE15
,p_ATTRIBUTE16        => l_day_attribute.ta_ATTRIBUTE16
,p_ATTRIBUTE17        => l_day_attribute.ta_ATTRIBUTE17
,p_ATTRIBUTE18        => l_day_attribute.ta_ATTRIBUTE18
,p_ATTRIBUTE19        => l_day_attribute.ta_ATTRIBUTE19
,p_ATTRIBUTE20        => l_day_attribute.ta_ATTRIBUTE20
,p_ATTRIBUTE21        => l_day_attribute.ta_ATTRIBUTE21
,p_ATTRIBUTE22        => l_day_attribute.ta_ATTRIBUTE22
,p_ATTRIBUTE23        => l_day_attribute.ta_ATTRIBUTE23
,p_ATTRIBUTE24        => l_day_attribute.ta_ATTRIBUTE24
,p_ATTRIBUTE25        => l_day_attribute.ta_ATTRIBUTE25
,p_ATTRIBUTE26        => l_day_attribute.ta_ATTRIBUTE26
,p_ATTRIBUTE27        => l_day_attribute.ta_ATTRIBUTE27
,p_ATTRIBUTE28        => l_day_attribute.ta_ATTRIBUTE28
,p_ATTRIBUTE29        => l_day_attribute.ta_ATTRIBUTE29
,p_ATTRIBUTE30        => l_day_attribute.ta_ATTRIBUTE30
,p_BLD_BLK_INFO_TYPE_ID => l_day_attribute.ta_info_type
,p_OBJECT_VERSION_NUMBER => l_day_attribute.ta_ovn
,p_NEW                   => 'N'
,p_changed               => 'N');

  end loop;
end loop;

-- now deposit the delete timecard

HXC_SELF_SERVICE_TIME_DEPOSIT.DEPOSIT_BLOCKS
  (p_timecard_id => l_returned_timecard_id
  ,p_timecard_ovn => l_returned_timecard_ovn
  ,p_mode => p_mode
  ,p_deposit_process => p_deposit_process
  ,p_retrieval_process => p_retrieval_process
);

exception
  when e_no_such_timecard then
    raise;
  when e_not_timecard_scope then
    raise;
  when others then
    raise;

end delete_timecard;

----
-- procedures supporting argument passing where dynamic sql is required
----

function get_building_blocks return timecard_info is
begin
 return g_timecard;
end get_building_blocks;

function get_block_attributes return building_block_attribute_info is
begin
 return g_attributes;
end get_block_attributes;

function get_app_attributes return app_attributes_info is
begin
 return g_app_attributes;
end get_app_attributes;

function get_messages return message_table is
begin
 return g_messages;
end get_messages;


procedure get_app_hook_params(
                       p_building_blocks OUT NOCOPY timecard_info,
                       p_app_attributes  OUT NOCOPY app_attributes_info,
                       p_messages        OUT NOCOPY message_table)
is
begin

p_building_blocks := g_timecard;
p_app_attributes  := g_app_attributes;
p_messages        := g_messages;

end;


procedure set_app_hook_params(
                       p_building_blocks IN timecard_info,
                       p_app_attributes  IN app_attributes_info,
                       p_messages        IN message_table)
is
begin

-- only allow blocks and attributes to be updated if in an update phase
if(g_update_phase) then --AI2.5
  g_timecard := p_building_blocks;
  g_app_attributes := p_app_attributes;
end if; --AI2.5

g_messages := p_messages;

end;



procedure set_global_table(
                       p_building_blocks 	IN timecard_info,
                       p_attributes  		IN building_block_attribute_info)
is
begin

  g_timecard 	:= p_building_blocks;
  g_attributes 	:= p_attributes;

end;


--AI2.5
PROCEDURE set_update_phase(p_mode in BOOLEAN)
IS
BEGIN

g_update_phase := p_mode;

END set_update_phase;
--AI2.5


--
PROCEDURE get_timecard_tables (
   p_timecard_id               IN       NUMBER,
   p_timecard_ovn              IN       NUMBER,
   p_timecard_blocks           OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
   p_timecard_app_attributes   OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info,
   p_time_recipient_id         IN       NUMBER
)
IS
   CURSOR csr_time_recipients (p_time_recipient_id IN NUMBER)
   IS
      SELECT tr.application_retrieval_function
        FROM hxc_time_recipients tr
       WHERE tr.time_recipient_id = p_time_recipient_id;

   l_retrieval_process_id   NUMBER          := NULL;
   l_retrieval_function     VARCHAR2 (2000);
BEGIN
   OPEN csr_time_recipients (p_time_recipient_id);
   FETCH csr_time_recipients INTO l_retrieval_function;
   CLOSE csr_time_recipients;

   IF l_retrieval_function IS NOT NULL
   THEN
      IF code_chk (l_retrieval_function)
      THEN
         find_app_deposit_process (
            p_time_recipient_id=> p_time_recipient_id,
            p_app_function=> l_retrieval_function,
            p_retrieval_process_id=> l_retrieval_process_id
         );
      END IF;
   END IF;

   get_timecard_tables (
      p_timecard_id=> p_timecard_id,
      p_timecard_ovn=> p_timecard_ovn,
      p_timecard_blocks=> p_timecard_blocks,
      p_timecard_app_attributes=> p_timecard_app_attributes,
      p_deposit_process_id=> NULL,
      p_retrieval_process_id=> l_retrieval_process_id
   );
END;

PROCEDURE get_timecard_tables (
   p_timecard_id               IN              NUMBER,
   p_timecard_ovn              IN              NUMBER,
   p_timecard_blocks           OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
   p_timecard_app_attributes   OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info,
   p_deposit_process_id        IN              NUMBER,
   p_retrieval_process_id      IN              NUMBER
)
IS
   CURSOR c_time_building_blocks (
      p_timecard_id    IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn   IN   hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      SELECT     htbb.time_building_block_id, htbb.TYPE, htbb.measure,
                 htbb.unit_of_measure, htbb.start_time, htbb.stop_time,
                 htbb.parent_building_block_id, 'N' parent_is_new, htbb.SCOPE,
                 htbb.object_version_number, htbb.approval_status,
                 htbb.resource_id, htbb.resource_type, htbb.approval_style_id,
                 htbb.date_from, htbb.date_to, htbb.comment_text,
                 htbb.parent_building_block_ovn, 'N' NEW, 'N' changed, 'N' process,
                 htbb.application_set_id, htbb.translation_display_key
            FROM hxc_time_building_blocks htbb
           WHERE SYSDATE BETWEEN htbb.date_from AND htbb.date_to
      START WITH (    htbb.time_building_block_id = p_timecard_id
                  AND htbb.object_version_number = p_timecard_ovn
                 )
      CONNECT BY PRIOR htbb.time_building_block_id =
                                                htbb.parent_building_block_id
             AND PRIOR htbb.object_version_number =
                                               htbb.parent_building_block_ovn
        ORDER BY htbb.time_building_block_id ASC;

   CURSOR c_block_attributes (
      p_build_block_id    IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_build_block_ovn   IN   hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      SELECT hta.time_attribute_id, htau.time_building_block_id,
             hbbit.bld_blk_info_type, hta.attribute_category, hta.attribute1,
             hta.attribute2, hta.attribute3, hta.attribute4, hta.attribute5,
             hta.attribute6, hta.attribute7, hta.attribute8, hta.attribute9,
             hta.attribute10, hta.attribute11, hta.attribute12,
             hta.attribute13, hta.attribute14, hta.attribute15,
             hta.attribute16, hta.attribute17, hta.attribute18,
             hta.attribute19, hta.attribute20, hta.attribute21,
             hta.attribute22, hta.attribute23, hta.attribute24,
             hta.attribute25, hta.attribute26, hta.attribute27,
             hta.attribute28, hta.attribute29, hta.attribute30,
             hta.bld_blk_info_type_id, hta.object_version_number, 'N' NEW,
             'N' changed, 'N' process
        FROM hxc_time_attributes hta,
             hxc_time_attribute_usages htau,
             hxc_bld_blk_info_types hbbit
       WHERE htau.time_building_block_id = p_build_block_id
         AND htau.time_building_block_ovn = p_build_block_ovn
         AND htau.time_attribute_id = hta.time_attribute_id
         AND hta.bld_blk_info_type_id = hbbit.bld_blk_info_type_id;

   l_block_index            NUMBER          := 1;
   l_attribute_index        NUMBER          := 1;
   l_retrieval_process_id   NUMBER          := NULL;
   l_retrieval_function     VARCHAR2 (2000);
BEGIN
   g_timecard.DELETE;
   g_attributes.DELETE;
   OPEN c_time_building_blocks (
      p_timecard_id=> p_timecard_id,
      p_timecard_ovn=> p_timecard_ovn
   );

   LOOP
      FETCH c_time_building_blocks INTO g_timecard (l_block_index);
      EXIT WHEN c_time_building_blocks%NOTFOUND;
      -- get the attributes associated to this block
      OPEN c_block_attributes (
         p_build_block_id=> g_timecard (l_block_index).time_building_block_id,
         p_build_block_ovn=> g_timecard (l_block_index).object_version_number
      );

      LOOP
         FETCH c_block_attributes INTO g_attributes (l_attribute_index);
         EXIT WHEN c_block_attributes%NOTFOUND;
         l_attribute_index :=   l_attribute_index
                              + 1;
      END LOOP;

      CLOSE c_block_attributes;
      l_block_index :=   l_block_index
                       + 1;
   END LOOP;

   CLOSE c_time_building_blocks;
   g_app_attributes.DELETE;

   IF (p_retrieval_process_id IS NOT NULL)
   THEN
      g_app_attributes :=
            build_application_attributes (
               p_retrieval_process_id=> p_retrieval_process_id,
               p_deposit_process_id=> NULL,
               p_for_time_attributes=> FALSE
            );
   ELSIF (p_deposit_process_id IS NOT NULL)
   THEN
      g_app_attributes :=
            build_application_attributes (
               p_retrieval_process_id=> NULL,
               p_deposit_process_id=> p_deposit_process_id,
               p_for_time_attributes=> TRUE
            );
   ELSE -- ERROR
      NULL;
   END IF;

   p_timecard_blocks := g_timecard;
   p_timecard_app_attributes := g_app_attributes;

   IF p_timecard_blocks.COUNT = 0
   THEN
      --
      hr_utility.set_message (809, 'HXC_APR_NO_TIMECARD_INFO');
      hr_utility.raise_error;
   END IF;
END get_timecard_tables;


PROCEDURE set_g_attributes ( p_attributes building_block_attribute_info ) IS

BEGIN

	g_attributes := p_attributes;

END set_g_attributes;
--
end hxc_self_service_time_deposit;

/
