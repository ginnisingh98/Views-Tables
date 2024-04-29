--------------------------------------------------------
--  DDL for Package Body HR_PAC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAC_BUS" as
/* $Header: hrpacrhi.pkb 115.2 99/07/17 05:36:19 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_pac_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_SSP_rules >-------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_SSP_rules (
--
p_pattern_id		in number,
p_availability		in varchar2,
p_component_pattern_id	in number default null,
p_pattern_bit_id	in number default null
) is
--
l_proc	varchar2(72) := g_package||'chk_SSP_rules';
l_dummy	integer (1) := null;
--
cursor csr_pattern_purpose is
	--
	-- Check for a purpose of SSP qualifying pattern
	--
	select	1
	from	hr_pattern_purposes
	where	pattern_id = p_pattern_id
	and	pattern_purpose = 'QUALIFYING PATTERN';
	--
cursor csr_pattern_bit is
	--
	select	1
	from	hr_pattern_bits
	where	pattern_bit_id = p_pattern_bit_id
	and	(time_unit_multiplier <> ceil (time_unit_multiplier)
		or base_time_unit <> 'DAYS'
		or p_availability is null
		or p_availability not in ('QUALIFYING','NON QUALIFYING'))
	union all
	select	1
	from	hr_pattern_bits			BIT,
		hr_pattern_constructions	CON
	where	bit.pattern_bit_id = con.pattern_bit_id
	and	con.pattern_id = p_component_pattern_id
	and	(bit.time_unit_multiplier <> ceil (bit.time_unit_multiplier)
		or bit.base_time_unit <> 'DAYS'
		or con.availability not in ('QUALIFYING','NON QUALIFYING'));
	--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'pattern_id',
		p_argument_value => p_pattern_id);
	--
	-- There must be either a pattern bit or a component pattern id,
	-- but not both
	--
	if (p_component_pattern_id is not null
		and p_pattern_bit_id is not null)
	or (p_component_pattern_id is null
		and p_pattern_bit_id is null)
	then
	  --
	  hr_pac_shd.constraint_error ('HR_PAC_PAB_PAT_ARC');
	  --
	end if;
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
open csr_pattern_purpose;
fetch csr_pattern_purpose into l_dummy;
--
if csr_pattern_purpose%found then
  --
  -- The pattern may be used for SSP qualifying patterns. Therefore, it may
  -- only have pattern bits of whole days. That goes for any component
  -- patterns as well.
  --
  close csr_pattern_purpose;
  open csr_pattern_bit;
  fetch csr_pattern_bit into l_dummy;
  if csr_pattern_bit%found then
    --
    -- The pattern bit chosen, or one of the pattern bits in the component
    -- pattern chosen, was not a whole multiple of a day.
    --
    close csr_pattern_bit;
    hr_utility.set_message (801,'HR_51073_PAC_SSP_BITS');
    hr_utility.raise_error;
    --
  else
    --
    close csr_pattern_bit;
    --
  end if;
  --
else
  --
  close csr_pattern_purpose;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_SSP_rules;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_availability >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_availability (
--
p_availability	in varchar2
) is
--
l_proc  varchar2(72) := g_package||'chk_availability';
l_dummy	integer(1) := null;
--
cursor csr_lookup is
	--
	select	1
	from	hr_lookups
	where	lookup_code = p_availability
	and	lookup_type = 'AVAILABILITY';
--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
if p_availability is not null then
  --
  open csr_lookup;
  fetch csr_lookup into l_dummy;
  if csr_lookup%notfound then
    --
    -- The availability was not valid.
    --
    close csr_lookup;
    hr_utility.set_message (801,'HR_51074_PAC_AVAILABILITY');
    hr_utility.raise_error;
    --
  else
    --
    close csr_lookup;
    --
  end if;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_availability;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_component_pattern_id >-------------------|
-- ----------------------------------------------------------------------------
procedure chk_component_pattern_id (
--
p_component_pattern_id	in number
) is
--
l_proc	varchar2(72) := g_package||'chk_component_pattern_id';
l_dummy	integer (1) := null;
--
cursor csr_component is
	--
	-- Check that the component pattern is not itself made up of further
	-- component patterns.
	--
	select	1
	from	hr_pattern_constructions
	where	pattern_id = p_component_pattern_id
	and	component_pattern_id is not null;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
if p_component_pattern_id is not null then
  --
  open csr_component;
  fetch csr_component into l_dummy;
  if csr_component%found then
    --
    close csr_component;
    hr_utility.set_message (801,'HR_51075_PAC_PAT_HIERARCHY');
    hr_utility.raise_error;
    --
  else
   --
   close csr_component;
   --
  end if;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_component_pattern_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_pac_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_availability (p_availability=> p_rec.availability);
  --
  chk_component_pattern_id (p_component_pattern_id=>p_rec.component_pattern_id);
  --
  chk_SSP_rules (p_pattern_id=> p_rec.pattern_id,
		p_availability=> p_rec.availability,
		p_component_pattern_id=> p_rec.component_pattern_id,
		p_pattern_bit_id=> p_rec.pattern_bit_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_pac_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Update is NOT allowed
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_pac_shd.g_rec_type) is
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
end hr_pac_bus;

/
