--------------------------------------------------------
--  DDL for Package Body HR_CAU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAU_BUS" as
/* $Header: hrcaurhi.pkb 120.0 2005/05/29 02:29:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_cau_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_start_date >-----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_start_date (
--
p_start_date		in date,
p_calendar_id		in number,
p_calendar_usage_id	in number default null,
p_object_version_number in number default null
) is
--
cursor csr_calendar is
	--
	-- Check the usage start/end dates
	--
	select	calendar_start_time
	from	hr_calendars
	where	calendar_id = p_calendar_id;
	--
l_proc			varchar2(72) := g_package||'chk_start_date';
l_calendar_start_time	date := null;
l_api_updating		boolean := FALSE;
--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'calendar_id',
		p_argument_value => p_calendar_id);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'start_date',
		p_argument_value => p_start_date);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
l_api_updating := hr_cau_shd.api_updating (
--
	p_calendar_usage_id => p_calendar_usage_id,
	p_object_version_number => p_object_version_number);
--
if ((l_api_updating and p_start_date <> hr_cau_shd.g_old_rec.end_date)
      or (not l_api_updating))
then
  --
  open csr_calendar;
  fetch csr_calendar into l_calendar_start_time;
  --
  if csr_calendar%notfound then
    --
    -- There was no calendar identified by the ID
    --
    hr_utility.set_message(801, 'HR_51068_CAU_CAL_FK');
    hr_utility.raise_error;
    --
  elsif l_calendar_start_time > p_start_date then
    --
    -- The usage starts before its calendar
    --
    hr_utility.set_message (801,'HR_51038_CAU_INVALID_START');
    hr_utility.set_message_token ('CALENDAR_START_DATE',
				to_char (l_calendar_start_time,
					'DD-MON-YYYY HH24:MI'));
    hr_utility.raise_error;
    --
  end if;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc, 10);
--
end chk_start_date;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_entity_purpose >-------------------------|
-- ----------------------------------------------------------------------------
procedure chk_entity_purpose (
--
p_purpose_usage_id	in number,
p_primary_key_value	in number,
p_start_date		in date,
p_end_date		in date,
p_calendar_usage_id	in number default null) is
--
l_proc	varchar2(72) := g_package||'chk_entity_purpose';
l_dummy	integer (1) := null;
--
cursor csr_overlap is
	--
	-- Check for overlapping calendar use
	--
	select	1
	from	hr_calendar_usages
	where	purpose_usage_id = p_purpose_usage_id
	and	(p_calendar_usage_id is null
		or p_calendar_usage_id <> calendar_usage_id)
	and	primary_key_value = p_primary_key_value
	and	p_start_date <= end_date
	and	p_end_date   >= start_date;
	--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'purpose_usage_id',
		p_argument_value => p_purpose_usage_id);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'primary_key_value',
		p_argument_value => p_primary_key_value);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'start_date',
		p_argument_value => p_start_date);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'end_date',
		p_argument_value => p_end_date);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
open csr_overlap;
fetch csr_overlap into l_dummy;
--
if csr_overlap%found then
  --
  close csr_overlap;
  hr_utility.set_message (801, 'HR_51072_CAU_USAGE_OVERLAP');
  hr_utility.raise_error;
  --
else
  close csr_overlap;
end if;
--
hr_utility.set_location ('Leaving '||l_proc,1);
--
end chk_entity_purpose;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_purpose_usage_id >-----------------------|
-- ----------------------------------------------------------------------------
procedure chk_purpose_usage_id (
--
p_purpose_usage_id	in number,
p_calendar_id		in number) is
--
l_proc  	varchar2(72) := g_package||'chk_purpose_usage_id';
l_purpose	varchar2 (30) := null;
l_dummy		integer (1) := null;
--
cursor csr_pattern_construction is
	--
	-- Check the pattern construction for any bit with an availability not
	-- equal to 'QUALIFYING' or 'NON QUALIFYING'. This is an SSP-specific
	-- test.
	--
	select	1
	from	hr_pattern_constructions	CON,
		hr_pattern_constructions	CON2,
		hr_calendars			CAL
	where	cal.calendar_id = p_calendar_id
	and	cal.pattern_id = con.pattern_id
	and	con.component_pattern_id = con2.pattern_id (+)
	and	(nvl (con.availability,con2.availability)
		not in ('QUALIFYING', 'NON QUALIFYING'));
	--
cursor csr_purpose is
	--
	-- Get the purpose of the calendar pattern
	--
	select	pattern_purpose
	from	hr_pattern_purpose_usages
	where	purpose_usage_id = p_purpose_usage_id;
	--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'purpose_usage_id',
		p_argument_value => p_purpose_usage_id);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'calendar_id',
		p_argument_value => p_calendar_id);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
open csr_purpose;
fetch csr_purpose into l_purpose;
if csr_purpose%notfound then
  --
  -- The purpose usage id was invalid.
  hr_cau_shd.constraint_error ('HR_CAU_PPU_FK');
  --
end if;
--
if l_purpose = 'QUALIFYING PATTERN' then
  --
  open csr_pattern_construction;
  fetch csr_pattern_construction into l_dummy;
  if csr_pattern_construction%found then
    --
    -- A pattern construction row was found which is not appropriate for SSP
    --
    hr_utility.set_message (801,'HR_51071_CAU_SSP_AVAILABILITY');
    hr_utility.raise_error;
    --
  end if;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_purpose_usage_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_calendar_id >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_calendar_id (
--
p_calendar_id		in out nocopy number,
p_start_date		in date,
p_purpose_usage_id	in number) is
--
l_proc  varchar2(72) := g_package||'chk_calendar_id';
--
cursor csr_hierarchy is
	--
	-- Get the next level up the hierarchy of defaulting
	--
	select	cau.purpose_usage_id,
		cau.primary_key_value
	from	hr_pattern_purpose_usages PPU1,
		hr_calendar_usages	CAU
	where	ppu1.pattern_purpose = (
		select ppu2.pattern_purpose
		from hr_pattern_purpose_usages PPU2
		where ppu2.purpose_usage_id = p_purpose_usage_id
		and ppu1.hierarchy_level < ppu2.hierarchy_level)
	and	cau.purpose_usage_id = ppu1.purpose_usage_id
	and	p_start_date between cau.start_date and cau.end_date
	order by ppu1.hierarchy_level desc;
	--
cursor csr_default (
	--
	-- Get the default calendar
	--
	p_primary_key_value	in number,
	p_purpose_usage_id	in number,
	p_start_date		in date) is
	--
	select	calendar_id
	from	hr_calendar_usages
	where	primary_key_value = p_primary_key_value
	and	purpose_usage_id = p_purpose_usage_id
	and	p_start_date between start_date and end_date;
	--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'purpose_usage_id',
		p_argument_value => p_purpose_usage_id);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'start_date',
		p_argument_value => p_start_date);
	--
	end check_parameters;
  --
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
if p_calendar_id is null then
  --
  -- We must default the calendar_id from the hierarchy
  --
  for higher_level in csr_hierarchy LOOP
    --
    -- Climb up the hierarchy, looking for a valid calendar_id to use as a
    -- default.
    --
    open csr_default (higher_level.primary_key_value,
		higher_level.purpose_usage_id,
		p_start_date);
		--
    fetch csr_default into p_calendar_id;
    --
    if csr_default%found then
      --
      -- We have found a valid calendar from higher in the hierarchy
      -- so stop looking.
      --
      close csr_default;
      exit;
      --
    end if;
    --
  end loop;
  --
end if;
--
-- If the calendar_id is still null at this point then no valid default
-- existed for the date specified, but we can leave the error to the constraint.
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_calendar_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_primary_key_value >----------------------|
-- ----------------------------------------------------------------------------
procedure chk_primary_key_value (
--
p_purpose_usage_id	in number,
p_primary_key_value	in number,
p_start_date		in date,
p_end_date		in date) is
--
cursor csr_person is
	--
	-- Check for a valid person id
	--
	select	1
	from	per_all_people_f
	where	person_id = p_primary_key_value
	and	p_start_date between effective_start_date
				and effective_end_date;
	--
cursor csr_assignment is
	--
	-- Check for a valid assignment id
	--
	select	1
	from	per_assignments_f
	where	assignment_id = p_primary_key_value
	and	p_start_date between effective_start_date
				and effective_end_date;
	--
cursor csr_location is
	--
	-- Check for a valid location id
	--
	select	1
	from	hr_locations
	where	location_id = p_primary_key_value
	and	p_start_date < nvl (inactive_date, hr_general.end_of_time);
	--
cursor csr_job is
	--
	-- Check for a valid job id
	--
	select	1
	from	per_jobs
	where	job_id = p_primary_key_value
	and	p_start_date between date_from
				and nvl (date_to, hr_general.end_of_time);
	--
cursor csr_organization is
	--
	-- Check for a valid organization id
	--
	select	1
	from	per_business_groups_perf
	where	business_group_id = p_primary_key_value
	and	p_start_date between date_from
				and nvl (date_to, hr_general.end_of_time);
	--
cursor csr_position is
	--
	-- Check for a valid position id
        -- Changed 12-Oct-99 SCNair (per_positions to hr_positions) dt track position req.
	--
	select	1
	from	hr_positions_f
	where	position_id = p_primary_key_value
	and	p_start_date between date_effective
				and nvl (hr_general.get_position_date_end(position_id), hr_general.end_of_time);
	--
cursor csr_entity_name is
	--
	-- Get the entity name for the pattern purpose usage
	--
	select	entity_name
	from 	hr_pattern_purpose_usages
	where	purpose_usage_id = p_purpose_usage_id;
	--
l_dummy			integer (1) := null;
l_entity_name		varchar2 (30);
l_table_name		varchar2 (30) := null;
l_primary_key_name	varchar2 (30) := null;
l_proc			varchar2(72) := g_package||'chk_primary_key_value';
--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'purpose_usage_id',
		p_argument_value => p_purpose_usage_id);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'primary_key_value',
		p_argument_value => p_primary_key_value);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'start_date',
		p_argument_value => p_start_date);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc, 1);
--
check_parameters;
--
open csr_entity_name;
fetch csr_entity_name into l_entity_name;
if csr_entity_name%notfound then
  --
  -- The p_purpose_usage_id must be invalid
  --
  close csr_entity_name;
  hr_cau_shd.constraint_error ('HR_CAU_PPU_FK');
  --
else
  --
  close csr_entity_name;
  --
end if;
--
if l_entity_name = 'PERSON' then
  --
  open csr_person;
  fetch csr_person into l_dummy;
  close csr_person;
  --
elsif l_entity_name = 'ASSIGNMENT' then
  --
  open csr_assignment;
  fetch csr_assignment into l_dummy;
  close csr_assignment;
  --
elsif l_entity_name = 'ORGANIZATION' then
  --
  open csr_organization;
  fetch csr_organization into l_dummy;
  close csr_organization;
  --
elsif l_entity_name = 'JOB' then
  --
  open csr_job;
  fetch csr_job into l_dummy;
  close csr_job;
  --
elsif l_entity_name = 'POSITION' then
  --
  open csr_position;
  fetch csr_position into l_dummy;
  close csr_position;
  --
elsif l_entity_name = 'LOCATION' then
  --
  open csr_location;
  fetch csr_location into l_dummy;
  close csr_location;
  --
else
  --
  -- An unexpected error occurred; the entity name is invalid.
  --
  hr_utility.set_message (801,' HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE',l_proc);
  hr_utility.set_message_token ('STEP','1');
  hr_utility.raise_error;
  --
end if;
--
if l_dummy is null then
  --
  -- The primary key did not exist on its table.
  --
  hr_utility.set_message (801,'HR_51067_CAU_PRIMARY_KEY_VALUE');
  hr_utility.set_message_token ('ENTITY_NAME',l_entity_name);
  hr_utility.set_message_token ('START_DATE',to_char (p_start_date));
  hr_utility.raise_error;
  --
end if;
--
end chk_primary_key_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in out nocopy hr_cau_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_start_date (	p_start_date	=> p_rec.start_date,
			p_calendar_id	=> p_rec.calendar_id);
  --
  chk_calendar_id (	p_calendar_id		=> p_rec.calendar_id,
  			p_start_date		=> p_rec.start_date,
  			p_purpose_usage_id	=> p_rec.purpose_usage_id);
  --
  chk_primary_key_value (p_purpose_usage_id=> p_rec.purpose_usage_id,
			p_primary_key_value=> p_rec.primary_key_value,
			p_start_date=> p_rec.start_date,
			p_end_date=> p_rec.end_date);
  --
  chk_purpose_usage_id (p_purpose_usage_id=> p_rec.purpose_usage_id,
  			p_calendar_id=> p_rec.calendar_id);
  --
  chk_entity_purpose (p_purpose_usage_id=> p_rec.purpose_usage_id,
			p_primary_key_value=> p_rec.primary_key_value,
			p_start_date=> p_rec.start_date,
			p_end_date=> p_rec.end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_cau_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_start_date (	p_start_date		=> p_rec.start_date,
			p_calendar_id		=> p_rec.calendar_id,
			p_calendar_usage_id	=> p_rec.calendar_usage_id,
			p_object_version_number	=> p_rec.object_version_number);
  --
  chk_entity_purpose (p_purpose_usage_id=> p_rec.purpose_usage_id,
			p_calendar_usage_id=> p_rec.calendar_usage_id,
			p_primary_key_value=> p_rec.primary_key_value,
			p_start_date=> p_rec.start_date,
			p_end_date=> p_rec.end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_cau_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_cau_bus;

/
