--------------------------------------------------------
--  DDL for Package Body HR_PAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAP_BUS" as
/* $Header: hrpaprhi.pkb 115.2 99/07/17 05:36:33 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_pap_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_pattern_purpose >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_pattern_purpose (
--
p_pattern_purpose	in varchar2,
p_pattern_id		in number
) is
--
l_proc	varchar2(72) := g_package||'chk_pattern_purpose';
l_dummy	integer (1) :=null;
--
cursor csr_lookup is
	--
	select	1
	from	hr_lookups
	where	lookup_type = 'PATTERN_PURPOSE'
	and	lookup_code = p_pattern_purpose;
	--
cursor csr_non_SSP_pattern is
	--
	-- Find pattern which is not required to start at midnight
	--
	select	1
	from	hr_patterns
	where	pattern_id = p_pattern_id
	and	pattern_start_time <> '00:00'
	--
	-- Find, for construction rows based directly on pattern bits, any
	-- row which is not based on whole multiples of a day or which is
	-- not a qualifying or non-qualifying day.
	--
	union all
	select  1
	from    hr_pattern_bits			BIT,
		hr_pattern_constructions	CON
	where   con.pattern_bit_id = bit.pattern_bit_id
	and	con.pattern_id = p_pattern_id
	and     (bit.time_unit_multiplier <> ceil (bit.time_unit_multiplier)
		or bit.base_time_unit <> 'DAYS'
		or con.availability is null
		or con.availability not in ('QUALIFYING','NON QUALIFYING'))
	--
	-- Find, for construction rows based on other patterns , any
	-- row which is not based on whole multiples of a day or which is
	-- not a qualifying or non-qualifying day.
	--
	union all
	select  1
	from    hr_pattern_bits                 BIT,
		hr_pattern_constructions        CON,
		hr_pattern_constructions	CON2
	where   bit.pattern_bit_id = con2.pattern_bit_id
	and	con.pattern_id = p_pattern_id
	and	con.component_pattern_id = con2.pattern_id
	and     (bit.time_unit_multiplier <> ceil (bit.time_unit_multiplier)
		or bit.base_time_unit <> 'DAYS'
		or con2.availability not in ('QUALIFYING','NON QUALIFYING'));
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
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'pattern_purpose',
		p_argument_value => p_pattern_purpose);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
-- Check that the pattern purpose is a valid lookup code.
--
open csr_lookup;
fetch csr_lookup into l_dummy;
if csr_lookup%notfound then
  --
  -- The pattern purpose is not valid.
  --
  close csr_lookup;
  hr_utility.set_message (801,'HR_51078_PAP_PATTERN_PURPOSE');
  hr_utility.raise_error;
  --
else
  --
  close csr_lookup;
  --
end if;
--
-- Check SSP-specific rules
--
if p_pattern_purpose = 'QUALIFYING PATTERN' then
  --
  -- Look for any reason why this pattern is not a valid SSP qualifying pattern
  --
  open csr_non_SSP_pattern;
  fetch csr_non_SSP_pattern into l_dummy;
  if csr_non_SSP_pattern%found then
    --
    close csr_non_SSP_pattern;
    hr_utility.set_message (801,'HR_51079_PAP_SSP_PATTERN');
    hr_utility.raise_error;
    --
  else
    --
    close csr_non_SSP_pattern;
    --
  end if;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_pattern_purpose;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_pattern_purpose (	p_pattern_purpose=> p_rec.pattern_purpose,
			p_pattern_id=> p_rec.pattern_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_pap_shd.g_rec_type) is
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
end hr_pap_bus;

/
