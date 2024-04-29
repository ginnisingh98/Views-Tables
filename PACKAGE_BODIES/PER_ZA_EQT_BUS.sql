--------------------------------------------------------
--  DDL for Package Body PER_ZA_EQT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_EQT_BUS" as
/* $Header: pezaeqbu.pkb 115.0 2001/02/04 22:31:38 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_eqt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_qualification_type_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_qualification_type_id(p_qualification_type_id in number,
				    p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_qualification_type_id';
  l_api_updating boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_za_eqt_shd.api_updating
    (p_qualification_type_id => p_qualification_type_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
      nvl(p_qualification_type_id,hr_api.g_number)
      <> per_za_eqt_shd.g_old_rec.qualification_type_id or
      not l_api_updating) then
    --
    if p_qualification_type_id is not null and
      not l_api_updating then
      --
      -- raise error as PK not null
      --
      per_za_eqt_shd.constraint_error('PER_QUALIFICATION_TYPES_PK');
      --
    end if;
    --
    -- check if qualification_type_id has been updated
    --
    if nvl(p_qualification_type_id,hr_api.g_number)
       <> per_za_eqt_shd.g_old_rec.qualification_type_id
       and l_api_updating then
      --
      -- raise error as update is not allowed
      --
      per_za_eqt_shd.constraint_error('PER_QUALIFICATION_TYPES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
end chk_qualification_type_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qualification_name >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_qualification_name(p_qualification_type_id in number,
				 p_name    in varchar2,
			         p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_qualification_name';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   per_qualification_types per
    where  per.name = p_name;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_za_eqt_shd.api_updating
    (p_qualification_type_id => p_qualification_type_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
      nvl(p_name,hr_api.g_varchar2) <> per_za_eqt_shd.g_old_rec.name or
      not l_api_updating) then
    --
    if p_name is null then
      --
      -- raise error
      --
      per_za_eqt_shd.constraint_error('PER_QUALIFICATION_TYPES_UK');
      --
    end if;
    --
    -- check if the qualification name exists in the per_qualification_types
    -- table.
    --
    if p_name <> per_za_eqt_shd.g_old_rec.name then
      --
      -- only check if it has changed so as to avoid unneccessary accesses to
      -- the database
      --
      open c1;
	--
	fetch c1 into l_dummy;
        if c1%found then
	  --
          -- raise error
	  --
	  close c1;
          per_za_eqt_shd.constraint_error('PER_QUALIFICATION_TYPES_UK');
          --
        end if;
	--
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
end chk_qualification_name;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_category >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the category lookup exists within the
--   lookup 'PER_CATEGORIES'.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   qualification_type_id              PK of record being inserted or updated.
--   category                           value of lookup_code
--   effective_date                     effective date
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_category(p_qualification_type_id       in number,
		       p_category                    in varchar2,
		       p_effective_date              in date,
		       p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_category';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_za_eqt_shd.api_updating
    (p_qualification_type_id  => p_qualification_type_id,
     p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_category,hr_api.g_varchar2)
	      <> per_za_eqt_shd.g_old_rec.category
      or not l_api_updating) then
    --
    -- check if value of category exists in lookup 'PER_CATEGORIES'
    --
    if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'PER_CATEGORIES',
				       p_lookup_code    => p_category,
				       p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_51880_EQT_CAT_LKP');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_category;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qualification_delete >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_qualification_delete(p_qualification_type_id in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_qualification_delete';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   per_qualifications per
    where  per.qualification_type_id = p_qualification_type_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%found then
      --
      -- error cannot delete qualification_type_id as it is used in the
      -- per_qualifications table
      --
      close c1;
      hr_utility.set_message(801,'HR_51537_EQT_QUAL_TAB_REF');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
end chk_qualification_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in per_za_eqt_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_TYPE_ID
  --
  chk_qualification_type_id(p_rec.qualification_type_id,
			    p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_NAME
  -- CHK_QUALIFICATION_NAME_UNIQUE
  --
  chk_qualification_name(p_rec.qualification_type_id,
			 p_rec.name,
			 p_rec.object_version_number);
  -- Business Rule Mapping
  -- =====================
  -- CHK_CATEGORY
  --
  chk_category(p_rec.qualification_type_id,
	       p_rec.category,
	       p_effective_date,
	       p_rec.object_version_number);
  --
  -- Descriptive Flex Check
  -- ======================
  --
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_za_eqt_flex.df(p_rec => p_rec);
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_za_eqt_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_TYPE_ID
  --
  chk_qualification_type_id(p_rec.qualification_type_id,
			    p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_NAME
  -- CHK_QUALIFICATION_NAME_UNIQUE
  --
  chk_qualification_name(p_rec.qualification_type_id,
			 p_rec.name,
			 p_rec.object_version_number);
  -- Business Rule Mapping
  -- =====================
  -- CHK_CATEGORY
  --
  chk_category(p_rec.qualification_type_id,
	       p_rec.category,
	       p_effective_date,
	       p_rec.object_version_number);
  --
  -- Descriptive Flex Check
  -- ======================
  --
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_za_eqt_flex.df(p_rec => p_rec);
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_za_eqt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_DELETE
  --
  chk_qualification_delete(p_rec.qualification_type_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_za_eqt_bus;

/
