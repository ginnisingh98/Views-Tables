--------------------------------------------------------
--  DDL for Package Body HXC_TBB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TBB_BUS" as
/* $Header: hxctbbrhi.pkb 120.6.12010000.1 2008/07/28 11:19:46 appldev ship $ */

-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------

g_package  varchar2(33)	:= '  hxc_tbb_bus.';  -- global package name

g_debug boolean := hr_utility.debug_enabled;

-- the following two global variables are only to be
-- used by the return_legislation_code function.

g_legislation_code            varchar2(150)  default null;
g_time_building_block_id      number         default null;


-- --------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >----------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. if an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure chk_non_updateable_args
  (p_effective_date in date
  ,p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);

begin

  -- only proceed with the validation if a row exists for the current
  -- record in the hr schema.

  if not hxc_tbb_shd.api_updating
      (p_time_building_block_id               => p_rec.time_building_block_id
      ,p_object_version_number                => p_rec.object_version_number
      ) then
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('procedure ', l_proc);
    fnd_message.set_token('STEP ', '5');
    fnd_message.raise_error;
  end if;

  if nvl(p_rec.type, hr_api.g_varchar2) <>
     nvl(hxc_tbb_shd.g_old_rec.type, hr_api.g_varchar2)
  then
    l_argument := 'p_type';
    raise l_error;
  end if;

  if nvl(p_rec.scope, hr_api.g_varchar2) <>
     nvl(hxc_tbb_shd.g_old_rec.scope, hr_api.g_varchar2)
  then
    l_argument := 'p_scope';
    raise l_error;
  end if;

  if nvl(p_rec.resource_id, hr_api.g_number) <>
     nvl(hxc_tbb_shd.g_old_rec.resource_id, hr_api.g_number)
  then
    l_argument := 'p_resource_id';
    raise l_error;
  end if;

  if nvl(p_rec.resource_type, hr_api.g_varchar2) <>
     nvl(hxc_tbb_shd.g_old_rec.resource_type, hr_api.g_varchar2)
  then
    l_argument := 'p_resource_type';
    raise l_error;
  end if;

  if nvl(p_rec.data_set_id, hr_api.g_varchar2) <>
     nvl(hxc_tbb_shd.g_old_rec.data_set_id, hr_api.g_varchar2)
  then
    l_argument := 'p_data_set_id';
    raise l_error;
  end if;

exception
  when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
  when others then
       raise;

end chk_non_updateable_args;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_type >-------------------------------------|
-- --------------------------------------------------------------------------
procedure chk_type
(p_effective_date in date
,p_type           in varchar2
) is

l_proc varchar2(72);

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_type';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- check that the type is not null.

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_type'
  ,p_argument_value => p_type
  );

  -- validate against hr_lookups.

/*  if hr_api.not_exists_in_hrstanlookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'HXC_BUILDING_BLOCK_TYPE'
     ,p_lookup_code    => p_type
     )
  then
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
    fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
    fnd_message.set_token('LOOKUP_TYPE', 'HXC_BUILDING_BLOCK_TYPE');
    fnd_message.set_token('VALUE', p_type);
    fnd_message.raise_error;
  end if;
*/
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;

end chk_type;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_measure >---------------------------------|
-- --------------------------------------------------------------------------
procedure chk_measure
(p_measure in number
,p_type     in varchar2
) is

l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_measure';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- check that measure is not null if building block is
  -- of type 'MEASURE' (measure)
  -- 2029550 Implementation
/*
  if p_type = 'MEASURE' then
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_measure'  COMMENTED PIECE OF CODE AS NOW WE ALLOW EMPTY MEASURE
    ,p_argument_value => p_measure
    );
  end if;
*/
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc,10);
  end if;

end chk_measure;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_start_time >-------------------------------|
-- --------------------------------------------------------------------------
procedure chk_start_time
(p_start_time in date
,p_type       in varchar2
) is

l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_start_time';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- check that start_time is not null if building block is
  -- of type 'RANGE' (range)

  if p_type = 'RANGE' then
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_start_time'
    ,p_argument_value => p_start_time
    );
  end if;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc,10);
  end if;

end chk_start_time;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_stop_time >-------------------------------|
-- --------------------------------------------------------------------------
procedure chk_stop_time
(p_stop_time  in date
,p_start_time in date
) is

l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_start_time';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- check that stop_time is greater than start_time if start_time
  -- is not null

  if p_stop_time < nvl(p_start_time, p_stop_time) then
    fnd_message.set_name('HXC', 'HXC_STOP_BEFORE_START');
    fnd_message.raise_error;
  end if;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc,10);
  end if;

end chk_stop_time;

-- --------------------------------------------------------------------------
-- |---------------------< chk_parent_building_block_id >-------------------|
-- --------------------------------------------------------------------------
procedure chk_parent_building_block_id
(p_parent_building_block_id in number,
 p_parent_building_block_ovn in number,
 p_scope in varchar2,
 p_date_to in date
) is

-- cursor to check that building block has a valid parent record

l_proc varchar2(72);

cursor c_timecard_parent is
  select null
  from hxc_time_building_blocks
  where time_building_block_id = p_parent_building_block_id
    and object_version_number = p_parent_building_block_ovn;

cursor c_valid_parent is
  select null
    from hxc_time_building_blocks
   where time_building_block_id = p_parent_building_block_id
     and object_version_number = p_parent_building_block_ovn
     and date_to = hr_general.end_of_time;

l_valid varchar2(1);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_parent_building_block_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  if ((p_parent_building_block_id is not null)OR(p_scope in ('DAY','DETAIL'))) then
    open c_timecard_parent;
    fetch c_timecard_parent into l_valid;
    if c_timecard_parent%notfound then
       close c_timecard_parent;
       fnd_message.set_name('PAY', 'HXC_NO_PARENT_BUILDING_BLOCK');
       fnd_message.raise_error;
    else
       close c_timecard_parent;
       if((p_date_to = hr_general.end_of_time) and (p_scope in ('DAY','DETAIL'))) then
          open c_valid_parent;
          if(c_valid_parent%notfound) then
             close c_valid_parent;
             fnd_message.set_name('HXC','HXC_366502_INVALID_PARENT_DEP');
             fnd_message.raise_error;
          else
             close c_valid_parent;
          end if;
       end if;
    end if;
  end if;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end chk_parent_building_block_id;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_scope >------------------------------------|
-- --------------------------------------------------------------------------
procedure chk_scope
(p_effective_date in date
,p_scope          in varchar2
) is


l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_scope';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- check that the scope is not null.

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_scope'
  ,p_argument_value => p_scope
  );

  -- validate against hr_lookups.
/*
  if hr_api.not_exists_in_hrstanlookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'HXC_BUILDING_BLOCK_SCOPE'
     ,p_lookup_code    => p_scope
     )
  then
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
    fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
    fnd_message.set_token('LOOKUP_TYPE', 'HXC_BUILDING_BLOCK_SCOPE');
    fnd_message.set_token('VALUE', p_scope);
    fnd_message.raise_error;
  end if;
*/
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;

end chk_scope;

-- --------------------------------------------------------------------------
-- |---------------------< chk_timecard_scope >-----------------------------|
-- --------------------------------------------------------------------------
procedure chk_timecard_scope
(p_resource_id          in number
,p_resource_type        in varchar2
,p_scope                in varchar2
,p_start_time           in date
,p_stop_time            in date
) is

cursor c_timecard_scope is
 select 'Y'
   from hxc_time_building_blocks
  where resource_id = p_resource_id
    and scope = 'TIMECARD'
    and resource_type = p_resource_type
    and p_start_time <= stop_time
    and p_stop_time >= start_time
    and date_to = hr_general.end_of_time;

l_two_timecards VARCHAR2(2);
l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_timecard_scope';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

if p_scope = 'TIMECARD' then

  if g_debug then
  	hr_utility.set_location(l_proc, 10);
  end if;

  open c_timecard_scope;
  fetch c_timecard_scope into l_two_timecards;

  if c_timecard_scope%NOTFOUND then

    if g_debug then
    	hr_utility.set_location(l_proc, 10);
    end if;
    close c_timecard_scope;

  else

--
-- Found a timecard scope building block with an overlapping
-- range, should error out.
--
    if g_debug then
    	hr_utility.set_location(l_proc, 10);
    end if;
    close c_timecard_scope;
    fnd_message.set_name('HXC', 'HXC_OVERLAPPING_TIMECARDS');
    fnd_message.raise_error;

  end if;

end if; -- are we inserting a timecard scope building block

if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;

end chk_timecard_scope;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_resource_id >------------------------------|
-- --------------------------------------------------------------------------
procedure chk_resource_id
(p_resource_id          in number
,p_resource_type        in varchar2
,p_date_from            in date
,p_date_to              in date
) is

l_proc varchar2(72);

-- cursor to check the number of person_records that overlap the period

cursor c_person is
  select count(*)
  from   per_all_people_f
  where  p_date_from          <= effective_end_date
    and  effective_start_date <= p_date_to
    and  person_id = p_resource_id;

l_num_person_records number;

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_resource_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  if p_resource_type = 'PERSON' then
    open c_person;
    fetch c_person into l_num_person_records;
    close c_person;
    if (l_num_person_records = 0) then
      fnd_message.set_name('HXC', 'HXC_NO_PERSON_RECORD');
      fnd_message.raise_error;
    end if;
  elsif p_resource_type = 'ROOM' then
    null; -- check validity of room
  elsif p_resource_type = 'MACHINE' then
    null; -- check validity of machine
  end if;
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end chk_resource_id;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_resource_type >----------------------------|
-- --------------------------------------------------------------------------
procedure chk_resource_type
(p_effective_date in date
,p_resource_type  in varchar2
) is

l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_resource_type';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- validate against hr_lookups.
/*
  if hr_api.not_exists_in_hrstanlookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'HXC_RESOURCE_TYPE'
     ,p_lookup_code    => p_resource_type
     )
  then
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
    fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
    fnd_message.set_token('LOOKUP_TYPE', 'HXC_RESOURCE_TYPE');
    fnd_message.set_token('VALUE', p_resource_type);
    fnd_message.raise_error;
  end if;
*/
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;

end chk_resource_type;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_approval_status >--------------------------|
-- --------------------------------------------------------------------------
procedure chk_approval_status
(p_effective_date  in date
,p_approval_status in varchar2
) is

l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_approval_status';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- check that the approval status is not null.

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_approval_status'
  ,p_argument_value => p_approval_status
  );

  -- validate against hr_lookups.
/*
  if hr_api.not_exists_in_hrstanlookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'HXC_APPROVAL_STATUS'
     ,p_lookup_code    => p_approval_status
     )
  then
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
    fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
    fnd_message.set_token('LOOKUP_TYPE', 'HXC_APPROVAL_STATUS');
    fnd_message.set_token('VALUE', p_approval_status);
    fnd_message.raise_error;
  end if;
*/
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;

end chk_approval_status;

-- --------------------------------------------------------------------------
-- |------------------------< chk_data_set_offline >------------------------|
-- --------------------------------------------------------------------------

procedure chk_data_set_offline
   (p_rec in hxc_tbb_shd.g_rec_type )
is
  cursor c_data_set(p_stop_time date) is
   select 1
   from hxc_data_sets d
   where p_stop_time between d.start_date and d.end_date
     and d.status in ('OFF_LINE','RESTORE_IN_PROGRESS','BACKUP_IN_PROGRESS');

  l_dummy number;

begin

  if p_rec.scope in ('TIMECARD','APPLICATION_PERIOD') then
	open c_data_set(p_rec.stop_time);
	fetch c_data_set into l_dummy;
	if c_data_set%found then
		close c_data_set;
		fnd_message.set_name('HXC', 'HXC_TC_OFFLINE_PERIOD_CONFLICT');
    	fnd_message.raise_error;
	end if;
	close c_data_set;
  end if;
end chk_data_set_offline;

-- --------------------------------------------------------------------------
-- |---------------------------< insert_validate >--------------------------|
-- --------------------------------------------------------------------------
procedure insert_validate
  (p_effective_date in date
  ,p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call all supporting business operations
  -- (no business group context.  HR_STANDARD_LOOKUPS used for validation)

  chk_type
  (p_effective_date => p_effective_date
  ,p_type           => p_rec.type
  );

  chk_measure
  (p_measure => p_rec.measure
  ,p_type     => p_rec.type
  );

if(NOT(p_rec.type = 'RANGE'
and p_rec.start_time is null
and p_rec.stop_time is null
and p_rec.date_to = hr_general.end_of_time))
then

  chk_start_time
  (p_start_time => p_rec.start_time
  ,p_type       => p_rec.type
  );

  chk_stop_time
  (p_stop_time  => p_rec.stop_time
  ,p_start_time => p_rec.start_time
  );

 end if;

  chk_parent_building_block_id
     (p_parent_building_block_id => p_rec.parent_building_block_id,
      p_parent_building_block_ovn => p_rec.parent_building_block_ovn,
      p_scope => p_rec.scope,
      p_date_to => p_rec.date_to
      );

  chk_scope
  (p_effective_date => p_effective_date
  ,p_scope          => p_rec.scope
  );

  chk_resource_id
  (p_resource_id          => p_rec.resource_id
  ,p_resource_type        => p_rec.resource_type
  ,p_date_from => p_rec.date_from
  ,p_date_to   => p_rec.date_to
  );

  chk_resource_type
  (p_effective_date => p_effective_date
  ,p_resource_type  => p_rec.resource_type
  );

  chk_approval_status
  (p_effective_date  => p_effective_date
  ,p_approval_status => p_rec.approval_status
  );

  chk_timecard_scope
   (p_resource_id   => p_rec.resource_id
   ,p_resource_type => p_rec.resource_type
   ,p_scope         => p_rec.scope
   ,p_start_time    => p_rec.start_time
   ,p_stop_time     => p_rec.stop_time
   );

  chk_data_set_offline
   (p_rec => p_rec
   );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end insert_validate;

-- --------------------------------------------------------------------------
-- |---------------------------< update_validate >--------------------------|
-- --------------------------------------------------------------------------
procedure update_validate
  (p_effective_date in date
  ,p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'update_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call all supporting business operations
  -- (no business group context.  HR_STANDARD_LOOKUPS used for validation)

  chk_non_updateable_args
    (p_effective_date => p_effective_date
      ,p_rec          => p_rec
    );

  chk_data_set_offline
   (p_rec => p_rec
   );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end update_validate;

-- --------------------------------------------------------------------------
-- |---------------------------< delete_validate >--------------------------|
-- --------------------------------------------------------------------------
procedure delete_validate
  (p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'delete_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call all supporting business operations

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end delete_validate;

end hxc_tbb_bus;

/
