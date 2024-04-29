--------------------------------------------------------
--  DDL for Package Body HR_PAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAT_BUS" as
/* $Header: hrpatrhi.pkb 115.2 99/07/17 05:36:40 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_pat_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_pattern_name >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_pattern_name (
--
p_pattern_name		in varchar2,
p_pattern_id		in number default null,
p_object_version_number	in number default null
) is
--
l_proc		varchar2(72) := g_package||'chk_pattern_name';
l_dummy		integer (1) := null;
l_api_updating	boolean := FALSE;
--
cursor csr_duplicate is
	--
	select	1
	from	hr_patterns
	where	upper (pattern_name) = upper (p_pattern_name)
	and	(p_pattern_id is null
		or p_pattern_id <> pattern_id);
	--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name       => l_proc,
		p_argument       => 'pattern_name',
		p_argument_value => p_pattern_name);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
-- Only perform check if we are not updating or if we are updating the
-- pattern name to something different from its present value.
--
l_api_updating := hr_pat_shd.api_updating (p_pattern_id=> p_pattern_id,
			p_object_version_number=> p_object_version_number);
--
if ((l_api_updating and hr_pat_shd.g_old_rec.pattern_name <> p_pattern_name)
or (not l_api_updating))
then
  --
  -- Look for a duplicate pattern name
  --
  open csr_duplicate;
  fetch csr_duplicate into l_dummy;
  if csr_duplicate%found then
    --
    close csr_duplicate;
    hr_utility.set_message (801,'HR_51081_PAT_UK01');
    hr_utility.raise_error;
    --
  else
    --
    close csr_duplicate;
    --
  end if;
  --
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
end chk_pattern_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_pat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_pattern_name (p_pattern_name=> p_rec.pattern_name);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_pat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_pattern_name (p_pattern_name=> p_rec.pattern_name,
		p_pattern_id=> p_rec.pattern_id,
		p_object_version_number=> p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_pat_shd.g_rec_type) is
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
end hr_pat_bus;

/
