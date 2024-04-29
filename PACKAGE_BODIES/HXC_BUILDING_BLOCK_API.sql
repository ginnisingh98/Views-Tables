--------------------------------------------------------
--  DDL for Package Body HXC_BUILDING_BLOCK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_BUILDING_BLOCK_API" as
/* $Header: hxctbbapi.pkb 120.5.12000000.2 2007/05/16 10:19:04 rchennur noship $ */

g_package  varchar2(33) := '  hxc_building_block_api.';

g_debug boolean := hr_utility.debug_enabled;

-- ---------------------------------------------------------------------------
-- |-------------------< copyAttributesToBlock >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure copies the set of attributes used by one block, specified
-- by the time building block and object version number, to another block.
-- New attributes are not generated, since after the consolidation of
-- attributes work, this is not necessary.  This procedure is currently used
-- by the delete interface, to copy the attributes from the block being
-- deleted to the deleted entry.
--
-- Prerequisites:
--   Valid block id and object version number references must be passed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_from_block_id                   Y Number   Time building block id
--   p_from_block_ovn                  Y Number   Time building block ovn
--   p_to_block_id                     Y Number   Time building block id
--   p_to_block_ovn                    Y Number   Time building block ovn
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--   All non-REASON (CLA) attributes are copied to the 'to' block.
--
-- Post Failure:
--   This function does not fail, however the attributes will not be copied
-- if any of the parameters are invalid.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
  procedure copyAttributesToBlock
    (p_from_block_id  hxc_time_building_blocks.time_building_block_id%type,
     p_from_block_ovn hxc_time_building_blocks.object_version_number%type,
     p_to_block_id    hxc_time_building_blocks.time_building_block_id%type,
     p_to_block_ovn   hxc_time_building_blocks.object_version_number%type
     ) is

    cursor c_attributes
      (p_block_id  hxc_time_building_blocks.time_building_block_id%type,
       p_block_ovn hxc_time_building_blocks.object_version_number%type) is
      select tau.time_attribute_id,
             tbb.data_set_id
        from hxc_time_attribute_usages tau,
             hxc_time_attributes ta,
             hxc_time_building_blocks tbb
       where tau.time_building_block_id = p_block_id
         and tau.time_building_block_ovn = p_block_ovn
         and tau.time_building_block_id = tbb.time_building_block_id
         and tau.time_building_block_ovn = tbb.object_version_number
         and tau.time_attribute_id = ta.time_attribute_id
         and ta.attribute_category <> 'REASON';

  begin
    for attribute_record in c_attributes(p_from_block_id,p_from_block_ovn) loop
      -- Create the usage for the new block for this attribute
        insert into hxc_time_attribute_usages
                    (time_attribute_usage_id,
                     time_attribute_id,
                     time_building_block_id,
                     created_by,
                     creation_date,
                     last_updated_by,
                     last_update_date,
                     last_update_login,
                     object_version_number,
                     time_building_block_ovn,
                     data_set_id
                     ) values (hxc_time_attribute_usages_s.nextval,
                               attribute_record.time_attribute_id,
                               p_to_block_id,
                               null, -- WHO trigger sets
                               null, -- WHO trigger sets
                               null, -- WHO trigger sets
                               null, -- WHO trigger sets
                               null, -- WHO trigger sets
                               1,    -- Insert!
                               p_to_block_ovn,
                               attribute_record.data_set_id
                               );
    end loop; -- Attribute loop

  end copyAttributesToBlock;

-- ---------------------------------------------------------------------------
-- |-------------------< create_building_block >-----------------------------|
-- ---------------------------------------------------------------------------

procedure create_building_block
  (p_validate                  in     boolean default false
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_application_set_id        in     number
  ,p_translation_display_key   in     varchar2
  ,p_time_building_block_id    in out nocopy number
  ,p_object_version_number     in out nocopy number
  ) is

cursor c_latest_version is
  select max(object_version_number)
  from   hxc_time_building_blocks
  where  time_building_block_id = p_time_building_block_id
  group by time_building_block_id;

cursor c_get_tc_data_set_id (p_time_building_block_id number) is
select data_set_id
  from hxc_time_building_blocks
 where time_building_block_id = p_time_building_block_id
   and date_to = hr_general.end_of_time;

cursor c_get_tc_range_data_set_id (p_stop_time date) is
select data_set_id
  from hxc_data_sets
 where p_stop_time between start_date and end_date
   and status = 'ON_LINE';

cursor c_day_det_range_data_set_id (p_parent_building_block_id number
								   ,p_parent_building_block_ovn number
                                   ) is
select tbb.data_set_id
  from hxc_time_building_blocks tbb
 where tbb.time_building_block_id = p_parent_building_block_id
   and tbb.object_version_number = p_parent_building_block_ovn;



l_data_set_id            hxc_time_building_blocks.data_set_id%type;
l_proc                   varchar2(72);
l_object_version_number  hxc_time_building_blocks.object_version_number%type;
l_time_building_block_id hxc_time_building_blocks.time_building_block_id%type;
l_max_ovn                hxc_time_building_blocks.object_version_number%type;

e_no_ovn exception;

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	  l_proc := g_package||'create_building_block';
	  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- issue a savepoint
  savepoint create_building_block;

  if p_approval_status = 'SUBMITTED' then
    -- the user is submitting the timecard for approval, so call the
    -- additional validation from the recipient applications

    begin

      hxc_building_block_api_bk1.create_building_block_b
        (p_effective_date            => p_effective_date
        ,p_type                      => p_type
        ,p_measure                   => p_measure
        ,p_unit_of_measure           => p_unit_of_measure
        ,p_start_time                => p_start_time
        ,p_stop_time                 => p_stop_time
        ,p_parent_building_block_id  => p_parent_building_block_id
        ,p_parent_building_block_ovn => p_parent_building_block_ovn
        ,p_scope                     => p_scope
        ,p_approval_style_id         => p_approval_style_id
        ,p_approval_status           => p_approval_status
        ,p_resource_id               => p_resource_id
        ,p_resource_type             => p_resource_type
        ,p_comment_text              => p_comment_text
	    ,p_application_set_id        => p_application_set_id
        ,p_translation_display_key   => p_translation_display_key
        );

    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_building_block'
          ,p_hook_type   => 'BP'
          );
    end;

  end if;

  if p_time_building_block_id is not null then

    -- we are date-effectively updating, so end date the previous
    -- row before inserting a new one
    hxc_tbb_shd.lck
      (p_time_building_block_id => p_time_building_block_id
      ,p_object_version_number  => p_object_version_number
      );

    open c_get_tc_data_set_id(p_time_building_block_id);
    fetch c_get_tc_data_set_id into l_data_set_id;
    close c_get_tc_data_set_id;

    update hxc_time_building_blocks
    set    date_to                = decode(trunc(date_from)
			                  ,trunc(p_effective_date)
			                  ,p_effective_date
	                                  ,p_effective_date - 1)
    where  time_building_block_id = p_time_building_block_id
    and    date_to                = hr_general.end_of_time;

    hxc_tbb_ins.ins
      (p_effective_date            => p_effective_date
      ,p_type                      => p_type
      ,p_scope                     => p_scope
      ,p_approval_status           => p_approval_status
      ,p_measure                   => p_measure
      ,p_unit_of_measure           => p_unit_of_measure
      ,p_start_time                => p_start_time
      ,p_stop_time                 => p_stop_time
      ,p_parent_building_block_id  => p_parent_building_block_id
      ,p_parent_building_block_ovn => p_parent_building_block_ovn
      ,p_resource_id               => p_resource_id
      ,p_resource_type             => p_resource_type
      ,p_approval_style_id         => p_approval_style_id
      ,p_date_from                 => p_effective_date
      ,p_date_to                   => hr_general.end_of_time
      ,p_comment_text              => p_comment_text
      ,p_application_set_id        => p_application_set_id
      ,p_data_set_id               => l_data_set_id
      ,p_translation_display_key   => p_translation_display_key
      ,p_time_building_block_id    => l_time_building_block_id
      ,p_object_version_number     => l_object_version_number
      );

    -- get the most recent object_version_number of this building block
    open c_latest_version;
    fetch c_latest_version into l_max_ovn;
    if c_latest_version%found then

      -- set the true object_version_number and time_building_block_id
      -- for the row we just inserted
      update hxc_time_building_blocks
      set object_version_number    = l_max_ovn + 1,
          time_building_block_id   = p_time_building_block_id
      where time_building_block_id = l_time_building_block_id
      and   date_from              = p_effective_date
      and   date_to                = hr_general.end_of_time;

      l_object_version_number := l_max_ovn + 1;
--
-- ARR 115.6
-- Must not only set object version number, but the id as well
-- since we overwrite the id we first created.
--
      l_time_building_block_id := p_time_building_block_id;

     -- set the parent_building_block_ovn to l_object_version_number for
     -- the child records of the row we just inserted.

/*
   We shouldn't be doing this!!

     update hxc_time_building_blocks
     set parent_building_block_ovn = l_object_version_number
     where parent_building_block_id = p_time_building_block_id;

*/
    else

      raise e_no_ovn;

    end if;

  else

	--new bb
	--let us check the scope

	if p_scope ='TIMECARD' then

		open c_get_tc_range_data_set_id(p_stop_time);
		fetch c_get_tc_range_data_set_id into l_data_set_id;
		close c_get_tc_range_data_set_id;
	elsif p_scope in ('DAY','DETAIL') then

	    open c_day_det_range_data_set_id(p_parent_building_block_id
	                                    ,p_parent_building_block_ovn
	                                    );
		fetch c_day_det_range_data_set_id into l_data_set_id;
		close c_day_det_range_data_set_id;
        elsif p_scope='APPLICATION_PERIOD' then
                 l_data_set_id:=null;
	end if;


    -- call the row handler
    hxc_tbb_ins.ins
      (p_effective_date            => p_effective_date
      ,p_type                      => p_type
      ,p_scope                     => p_scope
      ,p_approval_status           => p_approval_status
      ,p_measure                   => p_measure
      ,p_unit_of_measure           => p_unit_of_measure
      ,p_start_time                => p_start_time
      ,p_stop_time                 => p_stop_time
      ,p_parent_building_block_id  => p_parent_building_block_id
      ,p_parent_building_block_ovn => p_parent_building_block_ovn
      ,p_resource_id               => p_resource_id
      ,p_resource_type             => p_resource_type
      ,p_approval_style_id         => p_approval_style_id
      ,p_date_from                 => p_effective_date
      ,p_date_to                   => hr_general.end_of_time
      ,p_comment_text              => p_comment_text
      ,p_application_set_id        => p_application_set_id
      ,p_data_set_id               => l_data_set_id
      ,p_translation_display_key   => p_translation_display_key
      ,p_time_building_block_id    => l_time_building_block_id
      ,p_object_version_number     => l_object_version_number
      );

  end if;

  begin

    -- call after process user hook
    hxc_building_block_api_bk1.create_building_block_a
      (p_effective_date            => p_effective_date
      ,p_type                      => p_type
      ,p_measure                   => p_measure
      ,p_unit_of_measure           => p_unit_of_measure
      ,p_start_time                => p_start_time
      ,p_stop_time                 => p_stop_time
      ,p_parent_building_block_id  => p_parent_building_block_id
      ,p_parent_building_block_ovn => p_parent_building_block_ovn
      ,p_scope                     => p_scope
      ,p_approval_style_id         => p_approval_style_id
      ,p_approval_status           => p_approval_status
      ,p_resource_id               => p_resource_id
      ,p_resource_type             => p_resource_type
      ,p_comment_text              => p_comment_text
      ,p_time_building_block_id    => l_time_building_block_id
      ,p_object_version_number     => l_object_version_number
      ,p_application_set_id        => p_application_set_id
      ,p_translation_display_key   => p_translation_display_key
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_building_block'
        ,p_hook_type   => 'AP'
        );
  end;

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- set out parameters
  p_object_version_number  := l_object_version_number;
  p_time_building_block_id := l_time_building_block_id;

  if g_debug then
  	hr_utility.set_location('  Leaving:'||l_proc, 20);
  end if;

exception
  when hr_api.validate_enabled then
    rollback to create_building_block;
  when others then
    raise;

end create_building_block;

-- 115.16 start kSethi
-- New proc create_reversing_entry, used only for ELP
-- reversing entry.
--
-- ---------------------------------------------------------------------------
-- |-------------------< create_reversing_entry >-----------------------------|
-- ---------------------------------------------------------------------------

procedure create_reversing_entry
  (p_validate                  in     boolean default false
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_application_set_id        in     number
  ,p_date_to                   in     date
  ,p_translation_display_key   in     varchar2
  ,p_time_building_block_id    in out nocopy number
  ,p_object_version_number     in out nocopy number
  ) is

cursor c_latest_version is
  select max(object_version_number)
  from   hxc_time_building_blocks
  where  time_building_block_id = p_time_building_block_id
  group by time_building_block_id;

cursor c_get_parent_data_set_id (p_parent_building_block_id number
								   ,p_parent_building_block_ovn number
                                   ) is
select tbb.data_set_id
  from hxc_time_building_blocks tbb
 where tbb.time_building_block_id = p_parent_building_block_id
   and tbb.object_version_number = p_parent_building_block_ovn;



l_data_set_id            hxc_time_building_blocks.data_set_id%type;

l_proc                   varchar2(72);
l_object_version_number  hxc_time_building_blocks.object_version_number%type;
l_time_building_block_id hxc_time_building_blocks.time_building_block_id%type;
l_max_ovn                hxc_time_building_blocks.object_version_number%type;

e_no_ovn exception;

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'create_reversing_entry';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- issue a savepoint
  savepoint create_reversing_entry;

  if p_approval_status = 'SUBMITTED' then
    -- the user is submitting the timecard for approval, so call the
    -- additional validation from the recipient applications

	--new bb
	--let us check the scope

	    open c_get_parent_data_set_id(p_parent_building_block_id
	                                    ,p_parent_building_block_ovn
	                                    );
		fetch c_get_parent_data_set_id into l_data_set_id;
		close c_get_parent_data_set_id;

    begin

      hxc_building_block_api_bk1.create_building_block_b
        (p_effective_date            => p_effective_date
        ,p_type                      => p_type
        ,p_measure                   => p_measure
        ,p_unit_of_measure           => p_unit_of_measure
        ,p_start_time                => p_start_time
        ,p_stop_time                 => p_stop_time
        ,p_parent_building_block_id  => p_parent_building_block_id
        ,p_parent_building_block_ovn => p_parent_building_block_ovn
        ,p_scope                     => p_scope
        ,p_approval_style_id         => p_approval_style_id
        ,p_approval_status           => p_approval_status
        ,p_resource_id               => p_resource_id
        ,p_resource_type             => p_resource_type
        ,p_comment_text              => p_comment_text
	,p_application_set_id        => p_application_set_id
        ,p_translation_display_key   => p_translation_display_key
        );

    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_building_block'
          ,p_hook_type   => 'BP'
          );
    end;

  end if;

    -- call the row handler
    hxc_tbb_ins.ins
      (p_effective_date            => p_effective_date
      ,p_type                      => p_type
      ,p_scope                     => p_scope
      ,p_approval_status           => p_approval_status
      ,p_measure                   => p_measure
      ,p_unit_of_measure           => p_unit_of_measure
      ,p_start_time                => p_start_time
      ,p_stop_time                 => p_stop_time
      ,p_parent_building_block_id  => p_parent_building_block_id
      ,p_parent_building_block_ovn => p_parent_building_block_ovn
      ,p_resource_id               => p_resource_id
      ,p_resource_type             => p_resource_type
      ,p_approval_style_id         => p_approval_style_id
      ,p_date_from                 => p_effective_date
      ,p_date_to                   => p_date_to
      ,p_comment_text              => p_comment_text
      ,p_application_set_id        => p_application_set_id
      ,p_data_set_id               => l_data_set_id
      ,p_translation_display_key   => p_translation_display_key
      ,p_time_building_block_id    => l_time_building_block_id
      ,p_object_version_number     => l_object_version_number
      );


  begin

    -- call after process user hook
    hxc_building_block_api_bk1.create_building_block_a
      (p_effective_date            => p_effective_date
      ,p_type                      => p_type
      ,p_measure                   => p_measure
      ,p_unit_of_measure           => p_unit_of_measure
      ,p_start_time                => p_start_time
      ,p_stop_time                 => p_stop_time
      ,p_parent_building_block_id  => p_parent_building_block_id
      ,p_parent_building_block_ovn => p_parent_building_block_ovn
      ,p_scope                     => p_scope
      ,p_approval_style_id         => p_approval_style_id
      ,p_approval_status           => p_approval_status
      ,p_resource_id               => p_resource_id
      ,p_resource_type             => p_resource_type
      ,p_comment_text              => p_comment_text
      ,p_time_building_block_id    => l_time_building_block_id
      ,p_object_version_number     => l_object_version_number
      ,p_application_set_id        => p_application_set_id
      ,p_translation_display_key   => p_translation_display_key
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_building_block'
        ,p_hook_type   => 'AP'
        );
  end;

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- set out parameters
  p_object_version_number  := l_object_version_number;
  p_time_building_block_id := l_time_building_block_id;

  if g_debug then
  	hr_utility.set_location('  Leaving:'||l_proc, 20);
  end if;

exception
  when hr_api.validate_enabled then
    rollback to create_reversing_entry;
  when others then
    raise;

end create_reversing_entry;
--
--

-- ---------------------------------------------------------------------------
-- |-------------------< update_building_block >-----------------------------|
-- ---------------------------------------------------------------------------

procedure update_building_block
  (p_validate                  in     boolean default false
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_time_building_block_id    in     number
  ,p_application_set_id        in     number
  ,p_translation_display_key   in     varchar2
  ,p_object_version_number     in out nocopy number
  ) is

l_proc                  varchar2(72);
l_object_version_number hxc_time_building_blocks.object_version_number%type;

cursor c_get_data_set_id(p_tbb_id number,p_tbb_ovn number)
is
select tbb.data_set_id
  from hxc_time_building_blocks tbb
 where tbb.time_building_block_id = p_tbb_id
   and tbb.object_version_number = p_tbb_ovn;

l_data_set_id hxc_data_sets.data_set_id%TYPE;

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'update_building_block';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- issue a savepoint
  savepoint update_building_block;

  open c_get_data_set_id(p_time_building_block_id,p_object_version_number);
  fetch c_get_data_set_id into l_data_set_id;
  close c_get_data_set_id;


  -- call the row handler
  hxc_tbb_upd.upd
    (p_effective_date            => p_effective_date
    ,p_approval_status           => p_approval_status
    ,p_measure                   => p_measure
    ,p_unit_of_measure           => p_unit_of_measure
    ,p_start_time                => p_start_time
    ,p_stop_time                 => p_stop_time
    ,p_parent_building_block_id  => p_parent_building_block_id
    ,p_parent_building_block_ovn => p_parent_building_block_ovn
    ,p_approval_style_id         => p_approval_style_id
    ,p_date_from                 => null
    ,p_date_to                   => null
    ,p_comment_text              => p_comment_text
    ,p_data_set_id               => l_data_set_id
    ,p_time_building_block_id    => p_time_building_block_id
    ,p_application_set_id        => p_application_set_id
    ,p_translation_display_key   => p_translation_display_key
    ,p_object_version_number     => l_object_version_number
    );

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- set out parameters
  p_object_version_number := l_object_version_number;

  if g_debug then
  	hr_utility.set_location('  Leaving:'||l_proc, 20);
  end if;

exception
  when hr_api.validate_enabled then
    rollback to update_building_block;
  when others then
    raise;

end update_building_block;


-- ---------------------------------------------------------------------------
-- |-------------------< delete_building_block >-----------------------------|
-- ---------------------------------------------------------------------------

   procedure delete_building_block
     (p_validate               in     boolean default false,
      p_object_version_number  in out nocopy number,
      p_time_building_block_id in     number,
      p_effective_date         in     date,
      p_application_set_id     in     number
      ) is

     cursor c_old_rec is
       select *
         from hxc_time_building_blocks
        where time_building_block_id = p_time_building_block_id
          and date_to = hr_general.end_of_time;

     cursor c_latest_bb_version is
       select max(object_version_number)
         from   hxc_time_building_blocks
        where  time_building_block_id = p_time_building_block_id
        group by time_building_block_id;

     cursor c_time_attribute_usage(p_ovn number, p_building_block_id number) is
       SELECT htau.time_attribute_id time_attribute_id
         FROM hxc_time_attribute_usages htau ,
              hxc_time_attributes hta
        WHERE htau.time_building_block_ovn = p_ovn
          AND htau.time_building_block_id =  p_building_block_id
          AND hta.time_attribute_id = htau.time_attribute_id
          AND hta.ATTRIBUTE_CATEGORY <> 'REASON';

     l_proc                    varchar2(72);
     l_object_version_number   hxc_time_building_blocks.object_version_number%type;
     l_time_building_block_id  number;
     l_time_record             hxc_time_building_blocks%rowtype;
     l_max_ovn                 number;
     l_time_attribute_usage_id number;
     l_time_attribute_id       number;
     l_status hxc_time_building_blocks.approval_status%TYPE;

   begin

     g_debug := hr_utility.debug_enabled;

     if g_debug then
       l_proc := g_package||'delete_building_block';
       hr_utility.set_location('Entering:'|| l_proc, 10);
     end if;

     -- issue a savepoint
     savepoint delete_building_block;

     -- call before process user hook
     begin

       hxc_building_block_api_bk3.delete_building_block_b
         (p_effective_date           => p_effective_date);

     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
           (p_module_name => 'delete_building_block',
            p_hook_type   => 'BP'
            );
     end;

     open c_old_rec;
     fetch c_old_rec into l_time_record;
     if c_old_rec%found then
       close c_old_rec;
         update hxc_time_building_blocks
            set date_to = p_effective_date
          where time_building_block_id = p_time_building_block_id
            and date_to = hr_general.end_of_time;

       l_time_building_block_id := null;

       if(l_time_record.scope = 'DETAIL' )then
         l_status := 'SUBMITTED';
       else
         l_status := l_time_record.approval_status;
       end if;

       hxc_tbb_ins.ins
         (p_effective_date            => p_effective_date,
          p_type                      => l_time_record.type,
          p_scope                     => l_time_record.scope,
          p_approval_status           => l_status,
          p_measure                   => l_time_record.measure,
          p_unit_of_measure           => l_time_record.unit_of_measure,
          p_start_time                => l_time_record.start_time,
          p_stop_time                 => l_time_record.stop_time,
          p_parent_building_block_id  => l_time_record.parent_building_block_id,
          p_parent_building_block_ovn => l_time_record.parent_building_block_ovn,
          p_resource_id               => l_time_record.resource_id,
          p_resource_type             => l_time_record.resource_type,
          p_approval_style_id         => l_time_record.approval_style_id,
          p_date_from                 => p_effective_date,
          p_date_to                   => hr_general.end_of_time,
          p_comment_text              => l_time_record.comment_text,
          p_application_set_id        => NVL(p_application_set_id, l_time_record.application_set_id),
          p_data_set_id               => l_time_record.data_set_id,
          p_translation_display_key   => l_time_record.translation_display_key,
          p_time_building_block_id    => l_time_building_block_id,
          p_object_version_number     => l_object_version_number
          );

       open c_latest_bb_version;
       fetch c_latest_bb_version into l_max_ovn;
       close c_latest_bb_version;

       -- set the true object_version_number, time_building_block_id
       -- and date_to for the row we just inserted
         update hxc_time_building_blocks
            set object_version_number    = l_max_ovn + 1,
                time_building_block_id   = p_time_building_block_id,
                date_to                  = p_effective_date
          where time_building_block_id = l_time_building_block_id
            and   date_from              = p_effective_date
            and   date_to                = hr_general.end_of_time;

       --
       -- Ensure the attributes associated with the deleted block
       -- are the same as the ones from the previous block.
       --
       copyAttributesToBlock
         (p_from_block_id => p_time_building_block_id,
          p_from_block_ovn => l_max_ovn,
          p_to_block_id => p_time_building_block_id,
          p_to_block_ovn => (l_max_ovn)+1
          );

     else
       close c_old_rec;
     end if;

    -- call after process user hook
    begin

      hxc_building_block_api_bk3.delete_building_block_a
        (p_effective_date           => p_effective_date,
         p_time_building_block_id   => l_time_building_block_id,
         p_object_version_number    => l_object_version_number
         );

    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_building_block',
           p_hook_type   => 'AP'
           );
    end;

    if p_validate then
      raise hr_api.validate_enabled;
    end if;

    p_object_version_number := (l_max_ovn +1);

  exception
    when hr_api.validate_enabled then
      rollback to delete_building_block;
    when others then
      raise;

  end delete_building_block;


end hxc_building_block_api;

/
