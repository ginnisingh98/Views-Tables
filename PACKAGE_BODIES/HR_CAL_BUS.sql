--------------------------------------------------------
--  DDL for Package Body HR_CAL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAL_BUS" as
/* $Header: hrcalrhi.pkb 115.3 99/10/07 08:14:01 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_cal_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_CALENDAR_NAME >--------------------------|
-- ----------------------------------------------------------------------------
procedure CHK_CALENDAR_NAME (
--
p_calendar_name		in varchar2,
p_calendar_id		in number default null,
p_object_version_number	in number default null) is
--
cursor csr_duplicate is
	--
	-- Return a row if the parameter calendar name is NOT unique
	--
	select	1
	from	hr_calendars
	where	upper(calendar_name) = upper (p_calendar_name)
	and	(p_calendar_id is null or calendar_id <> p_calendar_id);
	--
l_proc		varchar2(72) := g_package||'chk_calendar_name';
l_api_updating	boolean;
l_dummy		integer (1);
--
begin
--
hr_utility.trace ('Entering '||l_proc);
--
hr_api.mandatory_arg_error
	(p_api_name       => l_proc,
	p_argument       => 'calendar name',
	p_argument_value => p_calendar_name);
--
l_api_updating := hr_cal_shd.api_updating (
			p_calendar_id => p_calendar_id,
			p_object_version_number => p_object_version_number);
--
if (l_api_updating and hr_cal_shd.g_old_rec.calendar_name <> p_calendar_name)
or (not l_api_updating) then
  --
  open csr_duplicate;
  fetch csr_duplicate into l_dummy;
  if csr_duplicate%found then
    --
    close csr_duplicate;
    hr_cal_shd.constraint_error ('HR_PAT_NAME_UK');
    --
  else
    --
    close csr_duplicate;
    --
  end if;
  --
end if;
--
hr_utility.trace ('Leaving '||l_proc);
--
end chk_calendar_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_PATTERN_START_POSITION >-----------------|
-- ----------------------------------------------------------------------------
procedure CHK_PATTERN_START_POSITION (
--
p_pattern_start_position	in number,
p_pattern_id			in number) is
--
cursor csr_construction_rows is
	--
	-- Get the number of pattern construction rows for the pattern
	--
	select	count (*)
	from	hr_pattern_constructions
	where	pattern_id = p_pattern_id;
	--
l_construction_rows	integer := null;
l_proc  		varchar2(72) := g_package||'chk_pattern_start_position';
--
begin
--
hr_utility.trace ('Entering '||l_proc);
--
hr_api.mandatory_arg_error
	(p_api_name       => l_proc,
	p_argument       => 'pattern_id',
	p_argument_value => p_pattern_id);
--
hr_api.mandatory_arg_error
	(p_api_name       => l_proc,
	p_argument       => 'pattern_start_position',
	p_argument_value => p_pattern_start_position);
--
open csr_construction_rows;
fetch csr_construction_rows into l_construction_rows;
--
if csr_construction_rows%notfound then
  --
  -- The pattern id must be invalid
  --
  close csr_construction_rows;
  hr_cal_shd.constraint_error ('HR_CAL_PAT_FK');
  --
else
  --
  close csr_construction_rows;
  --
end if;
--
if p_pattern_start_position > l_construction_rows then
  --
  -- The start position is invalid
  --
  hr_utility.set_message(801, 'HR_51060_PAY_START_POSITION');
  hr_utility.set_message_token ('MAXIMUM',to_char (l_construction_rows));
  hr_utility.raise_error;
  --
end if;
--
hr_utility.trace ('Leaving '||l_proc);
--
end chk_pattern_start_position;
-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_CALENDAR_START_TIME >--------------------|
-- ----------------------------------------------------------------------------
procedure CHK_CALENDAR_START_TIME (
--
p_calendar_start_time		in date,
p_pattern_start_position	in number,
p_pattern_id			in number) is
--
cursor csr_pattern_construction is
	--
	-- Get the denormalised construction of the pattern, breaking down
	-- any patterns within patterns into their component bits. We need this
	-- information in order to establish the start time and weekday of the
	-- calendar taking into account the offset of the pattern start
	-- position. See the business rules document hrcal.bru for a fuller
	-- explanation.
	--
	select  bit1.time_unit_multiplier,
		bit1.base_time_unit,
		con1.sequence_no,
		0
	from    hr_pattern_constructions        CON1,
		hr_pattern_bits                 BIT1
	where   bit1.pattern_bit_id = con1.pattern_bit_id
	and     con1.pattern_id = p_pattern_id
	union all
	select  bit2.time_unit_multiplier,
		bit2.base_time_unit,
		con2.sequence_no,
		con3.sequence_no
	from    hr_pattern_bits                 BIT2,
		hr_pattern_constructions        CON2,
		hr_pattern_constructions        CON3
	where   bit2.pattern_bit_id = con3.pattern_bit_id
	and     con2.component_pattern_id = con3.pattern_id
	and     con2.pattern_id = p_pattern_id
	order by 3,4;
	--
cursor csr_pattern_details is
	--
	-- Get the attributes of the pattern
	--
	select	*
	from	hr_patterns
	where	pattern_id = p_pattern_id;
	--
l_proc			varchar2(72) := g_package||'chk_calendar_start_time';
l_pattern		csr_pattern_details%rowtype;
l_construction		csr_pattern_construction%rowtype;
l_calendar_start_time	date := p_calendar_start_time;
l_weekday		varchar2 (3);
l_time			varchar2 (5);
--
function TO_DAYS (
	--
	-- Convert user-defined time unit into days for ease of comparison and
	-- manipulation.
	--
	quantity        number,
	units           varchar2) return number is
	--
	conversion_factor       number :=1;
	--
	begin
	--
	if units = 'H' then
	  conversion_factor := 24;
	  --
	elsif units = 'W' then
	  conversion_factor := 1/7;
	  --
	end if;
	--
	return (quantity / conversion_factor);
	--
	end to_days;
--
procedure check_parameters is
	--
	-- Check the main procedure parameters
	--
	begin
	--
	-- Check that the parameters are not null
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'calendar_start_time',
		p_argument_value => p_calendar_start_time);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'pattern_id',
		p_argument_value => p_pattern_id);
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'pattern_start_position',
		p_argument_value => p_pattern_start_position);
	--
	end check_parameters;
	--
begin
--
hr_utility.trace ('Entering '||l_proc);
--
check_parameters;
--
-- Get the pattern details
--
open csr_pattern_details;
fetch csr_pattern_details into l_pattern;
--
if csr_pattern_details%notfound then -- the pattern id must be invalid
  close csr_pattern_details;
  hr_cal_shd.constraint_error ('HR_CAL_PAT_FK');
else
  close csr_pattern_details;
end if;
--
if p_pattern_start_position > 1 then
  --
  -- The start time validation must allow for the fact that, although the
  -- pattern must start on, say, Wednesday and the calendar does not start on
  -- a Wednesday, the calendar does not start on bit 1 of the pattern. Therefore
  -- we must calculate where bit 1 of the pattern would start.
  --
  for offset in csr_pattern_construction LOOP
    --
    -- Set the virtual calendar start time back by the duration of the
    -- pattern bit.
    --
    l_calendar_start_time := l_calendar_start_time
				- to_days (offset.time_unit_multiplier,
					offset.base_time_unit);
    --
    -- Stop when we get to the start position of the calendar
    --
    exit when csr_pattern_construction%rowcount = p_pattern_start_position;
    --
  end loop;
  --
end if;
--
l_weekday := to_char (l_calendar_start_time, 'DY');
l_time := to_char (l_calendar_start_time, 'HH24:MI');
--
if l_weekday <> l_pattern.pattern_start_weekday then
  --
  -- The calendar does not start on the correct weekday
  hr_utility.set_message (801, 'HR_51062_CAL_START_WEEKDAY');
  hr_utility.set_message_token ('WEEKDAY',l_pattern.pattern_start_weekday);
  hr_utility.raise_error;
  --
elsif l_time <> l_pattern.pattern_start_time then
  --
  -- The calendar does not start at the correct time of day
  hr_utility.set_message (801, 'HR_51063_CAL_START_TIME');
  hr_utility.set_message_token ('START_TIME',l_pattern.pattern_start_time);
  hr_utility.raise_error;
  --
end if;
--
hr_utility.trace ('Leaving '||l_proc);
--
end chk_calendar_start_time;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_cal_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_pattern_start_position (	p_rec.pattern_start_position,
				p_rec.pattern_id);
  --
  chk_calendar_start_time (p_calendar_start_time => p_rec.calendar_start_time,
		p_pattern_start_position => p_rec.pattern_start_position,
		p_pattern_id => p_rec.pattern_id);
  --
  chk_calendar_name (p_rec.calendar_name);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_cal_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_calendar_name (p_calendar_name => p_rec.calendar_name,
			p_calendar_id => p_rec.calendar_id,
			p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_cal_shd.g_rec_type) is
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
end hr_cal_bus;

/
