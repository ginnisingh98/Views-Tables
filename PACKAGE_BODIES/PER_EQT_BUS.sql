--------------------------------------------------------
--  DDL for Package Body PER_EQT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EQT_BUS" as
/* $Header: peeqtrhi.pkb 115.15 2004/03/30 18:11:30 ynegoro ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_eqt_bus.';  -- Global package name
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
  l_api_updating := per_eqt_shd.api_updating
    (p_qualification_type_id => p_qualification_type_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
      nvl(p_qualification_type_id,hr_api.g_number)
      <> per_eqt_shd.g_old_rec.qualification_type_id or
      not l_api_updating) then
    --
    if p_qualification_type_id is not null and
      not l_api_updating then
      --
      -- raise error as PK not null
      --
      per_eqt_shd.constraint_error('PER_QUALIFICATION_TYPES_PK');
      --
    end if;
    --
    -- check if qualification_type_id has been updated
    --
    if nvl(p_qualification_type_id,hr_api.g_number)
       <> per_eqt_shd.g_old_rec.qualification_type_id
       and l_api_updating then
      --
      -- raise error as update is not allowed
      --
      per_eqt_shd.constraint_error('PER_QUALIFICATION_TYPES_PK');
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
  l_api_updating := per_eqt_shd.api_updating
    (p_qualification_type_id  => p_qualification_type_id,
     p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_category,hr_api.g_varchar2)
	      <> per_eqt_shd.g_old_rec.category
      or not l_api_updating) then
    --
    -- check if value of category exists in lookup 'PER_CATEGORIES'
    --
    if hr_api.not_exists_in_leg_lookups(p_lookup_type    => 'PER_CATEGORIES',
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
  -- BUG3356369
  --
  cursor c2 is
    select null
    from   per_competence_elements comp
    where  comp.qualification_type_id = p_qualification_type_id;
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
  hr_utility.set_location(l_proc,10);
  --
  open c2;
    --
    fetch c2 into l_dummy;
    --
    if c2%found then
      --
      -- error cannot delete qualification_type_id as it is used in the
      -- per_competence_elements table
      --
      close c2;
      hr_utility.set_message(800,'HR_449133_QUA_FWK_EQT_TAB_REF');
      hr_utility.raise_error;
      --
    end if;
    --
  close c2;
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
end chk_qualification_delete;
--
-------------------------------------------------------------------------------
-------------------------< chk_qual_framework_id >-----------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a qual_framework_id is unique
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_qual_framework_id
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_qual_framework_id
(p_qualification_type_id  in  per_qualification_types.qualification_type_id%TYPE
,p_qual_framework_id      in  per_qualification_types.qual_framework_id%TYPE
,p_object_version_number  in  per_qualification_types.object_version_number%TYPE
)
is
--
  --
  -- declare cursor
  --
   cursor csr_qual_framework_id is
      select 1 from per_qualification_types
      where qual_framework_id = p_qual_framework_id;

   --
     l_proc            varchar2(72)  :=  g_package||'chk_qual_framework_id';
     l_api_updating    boolean;
     l_exists          varchar2(1);
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for qualification_type type has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_qual_framework_id is not null then
      if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.qual_framework_id,
                                  hr_api.g_number)
                          <> nvl(p_qual_framework_id,hr_api.g_number)
           ) or
          (NOT l_api_updating)
        ) then
         --
         hr_utility.set_location(l_proc, 20);
         open csr_qual_framework_id;
         fetch csr_qual_framework_id into l_exists;
         if csr_qual_framework_id%FOUND then
           close csr_qual_framework_id;
           --
           hr_utility.set_location(l_proc, 30);
           --
           hr_utility.set_message(800, 'HR_449144_QUA_FWK_ID_EXISTS');
           hr_utility.raise_error;
           --
         END IF;
         close csr_qual_framework_id;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_qual_framework_id;
--
--
-------------------------------------------------------------------------------
-------------------------< chk_qualification_type >----------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a qualification type exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_QUAL_TYPE'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_qualification_type
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_qualification_type
(p_qualification_type_id  in  per_qualification_types.qualification_type_id%TYPE
,p_qualification_type     in  per_qualification_types.qualification_type%TYPE
,p_object_version_number  in  per_qualification_types.object_version_number%TYPE
,p_effective_date	   in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_qualification_type';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for qualification_type type has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_qualification_type is not null then
      if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.qualification_type,
                                  hr_api.g_varchar2)
                          <> nvl(p_qualification_type,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_QUAL_TYPE'
        ,p_lookup_code           => p_qualification_type) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449101_QUA_FWK_QUAL_TYP_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_qualification_type;
--
-------------------------------------------------------------------------------
----------------------------< chk_credit_type >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a credit_type exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_CREDIT_TYPE'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_credit_type
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_credit_type
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_credit_type             in  per_qualification_types.credit_type%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date	   in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_credit_type';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for credit type has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_credit_type is not null then
      if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.credit_type,
                                  hr_api.g_varchar2)
                          <> nvl(p_credit_type,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_CREDIT_TYPE'
        ,p_lookup_code           => p_credit_type) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449092_QUA_FWK_CRDT_TYP_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_credit_type;
--
--
-------------------------------------------------------------------------------
----------------------------< chk_level_type >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a level_type exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_LEVEL_TYPE'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_level_type
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_level_type
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_level_type              in  per_qualification_types.level_type%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date          in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_level_type';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for level type has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_level_type is not null then
    if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.level_type,
                                  hr_api.g_varchar2)
                          <> nvl(p_level_type,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_LEVEL_TYPE'
        ,p_lookup_code           => p_level_type) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449090_QUA_FWK_LVL_TYPE_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_level_type;
--
--
-------------------------------------------------------------------------------
----------------------------< chk_level_number >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a level_number exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_LEVEL'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_level_number
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_level_number
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_level_number            in  per_qualification_types.level_number%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date          in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_level_number';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for level has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_level_number is not null then
    if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.level_number,
                                  hr_api.g_number)
                          <> nvl(p_level_number,hr_api.g_number)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_LEVEL'
        ,p_lookup_code           => p_level_number) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449091_QUA_FWK_LEVEL_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_level_number;
--
--
-------------------------------------------------------------------------------
----------------------------------< chk_field >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a field exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_FIELD'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_field
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_field
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_field                   in  per_qualification_types.field%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date          in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_field';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for field has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_field is not null then
    if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.field,
                                  hr_api.g_varchar2)
                          <> nvl(p_field,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_FIELD'
        ,p_lookup_code           => p_field) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449093_QUA_FWK_FIELD_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_field;
--
--
-------------------------------------------------------------------------------
----------------------------< chk_sub_field >----------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a sub_field exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_SUB_FIELD'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_sub_field
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_sub_field
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_sub_field               in  per_qualification_types.sub_field%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date          in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_sub_field';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for sub field has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_sub_field is not null then
    if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.sub_field,
                                  hr_api.g_varchar2)
                          <> nvl(p_sub_field,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_SUB_FIELD'
        ,p_lookup_code           => p_sub_field) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449094_QUA_FWK_SUB_FLD_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_sub_field;
--
--
-------------------------------------------------------------------------------
-------------------------------< chk_provider >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a provider exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_PROVIDER'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_provider
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_provider
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_provider                in  per_qualification_types.provider%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date          in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_provider';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for provider has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_provider is not null then
    if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.provider,
                                  hr_api.g_varchar2)
                          <> nvl(p_provider,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_PROVIDER'
        ,p_lookup_code           => p_provider) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449095_QUA_FWK_PROVIDER_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_provider;
--
--
-------------------------------------------------------------------------------
------------------------< chk_qa_organization >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a qa_organization exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_QA_ORG'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_qualification_type_id
--    p_qa_organization
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_qa_organization
(p_qualification_type_id   in  per_qualification_types.qualification_type_id%TYPE
,p_qa_organization         in  per_qualification_types.qa_organization%TYPE
,p_object_version_number   in  per_qualification_types.object_version_number%TYPE
,p_effective_date          in  date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_qa_organization';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for qa organization has changed
  --
  l_api_updating := per_eqt_shd.api_updating
         (p_qualification_type_id  => p_qualification_type_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_qa_organization is not null then
    if (  (l_api_updating and nvl(per_eqt_shd.g_old_rec.qa_organization,
                                  hr_api.g_varchar2)
                          <> nvl(p_qa_organization,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_QA_ORG'
        ,p_lookup_code           => p_qa_organization) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449096_QUA_FWK_QA_ORG_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_qa_organization;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in per_eqt_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.qualification_type_id is not null) and (
    nvl(per_eqt_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.qualification_type_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_QUALIFICATION_TYPES'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_df;

-- mvankada
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--     are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_ddf
  (p_rec in per_eqt_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --

   if ((p_rec.qualification_type_id is not null) and (
    nvl(per_eqt_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2) or
    nvl(per_eqt_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2)))
    or
    (p_rec.qualification_type_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'Qualification Types DDF'
      ,p_attribute_category => p_rec.information_category
      ,p_attribute1_name    => 'INFORMATION1'
      ,p_attribute1_value   => p_rec.information1
      ,p_attribute2_name    => 'INFORMATION2'
      ,p_attribute2_value   => p_rec.information2
      ,p_attribute3_name    => 'INFORMATION3'
      ,p_attribute3_value   => p_rec.information3
      ,p_attribute4_name    => 'INFORMATION4'
      ,p_attribute4_value   => p_rec.information4
      ,p_attribute5_name    => 'INFORMATION5'
      ,p_attribute5_value   => p_rec.information5
      ,p_attribute6_name    => 'INFORMATION6'
      ,p_attribute6_value   => p_rec.information6
      ,p_attribute7_name    => 'INFORMATION7'
      ,p_attribute7_value   => p_rec.information7
      ,p_attribute8_name    => 'INFORMATION8'
      ,p_attribute8_value   => p_rec.information8
      ,p_attribute9_name    => 'INFORMATION9'
      ,p_attribute9_value   => p_rec.information9
      ,p_attribute10_name   => 'INFORMATION10'
      ,p_attribute10_value  => p_rec.information10
      ,p_attribute11_name   => 'INFORMATION11'
      ,p_attribute11_value  => p_rec.information11
      ,p_attribute12_name   => 'INFORMATION12'
      ,p_attribute12_value  => p_rec.information12
      ,p_attribute13_name   => 'INFORMATION13'
      ,p_attribute13_value  => p_rec.information13
      ,p_attribute14_name   => 'INFORMATION14'
      ,p_attribute14_value  => p_rec.information14
      ,p_attribute15_name   => 'INFORMATION15'
      ,p_attribute15_value  => p_rec.information15
      ,p_attribute16_name   => 'INFORMATION16'
      ,p_attribute16_value  => p_rec.information16
      ,p_attribute17_name   => 'INFORMATION17'
      ,p_attribute17_value  => p_rec.information17
      ,p_attribute18_name   => 'INFORMATION18'
      ,p_attribute18_value  => p_rec.information18
      ,p_attribute19_name   => 'INFORMATION19'
      ,p_attribute19_value  => p_rec.information19
      ,p_attribute20_name   => 'INFORMATION20'
      ,p_attribute20_value  => p_rec.information20
      ,p_attribute21_name   => 'INFORMATION21'
      ,p_attribute21_value  => p_rec.information21
      ,p_attribute22_name   => 'INFORMATION22'
      ,p_attribute22_value  => p_rec.information22
      ,p_attribute23_name   => 'INFORMATION23'
      ,p_attribute23_value  => p_rec.information23
      ,p_attribute24_name   => 'INFORMATION24'
      ,p_attribute24_value  => p_rec.information24
      ,p_attribute25_name   => 'INFORMATION25'
      ,p_attribute25_value  => p_rec.information25
      ,p_attribute26_name   => 'INFORMATION26'
      ,p_attribute26_value  => p_rec.information26
      ,p_attribute27_name   => 'INFORMATION27'
      ,p_attribute27_value  => p_rec.information27
      ,p_attribute28_name   => 'INFORMATION28'
      ,p_attribute28_value  => p_rec.information28
      ,p_attribute29_name   => 'INFORMATION29'
      ,p_attribute29_value  => p_rec.information29
      ,p_attribute30_name   => 'INFORMATION30'
      ,p_attribute30_value  => p_rec.information30
      );
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_ddf;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in per_eqt_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  -- Fix for bug 2723065
  -- Commented line which hardcodes security profile to '0'
  -- hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
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
  -- CHK_CATEGORY
  --
  chk_category(p_rec.qualification_type_id,
	       p_rec.category,
	       p_effective_date,
	       p_rec.object_version_number);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUAL_FRAMEWORK_ID
  --
  per_eqt_bus.chk_qual_framework_id
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_qual_framework_id         =>      p_rec.qual_framework_id
   ,p_object_version_number     =>      p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 40);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_TYPE
  --
  per_eqt_bus.chk_qualification_type
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_qualification_type        =>      p_rec.qualification_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 50);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CREDIT_TYPE
  --
  per_eqt_bus.chk_credit_type
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_credit_type               =>      p_rec.credit_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 60);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LEVEL_TYPE
  --
 per_eqt_bus.chk_level_type
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_level_type                =>      p_rec.level_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 70);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LEVEL_LEVEL
  --
  per_eqt_bus.chk_level_number
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_level_number              =>      p_rec.level_number
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 80);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FIELD
  --
  per_eqt_bus.chk_field
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_field                     =>      p_rec.field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 90);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_SUB_FIELD
  --
  per_eqt_bus.chk_sub_field
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_sub_field                 =>      p_rec.sub_field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 100);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROVIDER
  --
  -- Rule check provider
  --
  per_eqt_bus.chk_provider
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_provider                  =>      p_rec.provider
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
 );
  hr_utility.set_location(l_proc, 110);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QA_ORGANIZATION
  --
  per_eqt_bus.chk_qa_organization
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_qa_organization           =>      p_rec.qa_organization
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 120);
  --
  -- Descriptive Flex Check
  -- ======================
  --
  per_eqt_bus.chk_df(p_rec => p_rec);
  --
  -- mvankada
  --
  -- Developer Descriptive Flex Check
  -- ================================
  --
  per_eqt_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_eqt_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
    -- Fix for bug 2723065
  -- Commented line which hardcodes security profile to '0'
  --hr_api.set_security_group_id(p_security_group_id => 0);
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
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CATEGORY
  --
  chk_category(p_rec.qualification_type_id,
	       p_rec.category,
	       p_effective_date,
	       p_rec.object_version_number);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUAL_FRAMEWORK_ID
  --
  per_eqt_bus.chk_qual_framework_id
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_qual_framework_id         =>      p_rec.qual_framework_id
   ,p_object_version_number     =>      p_rec.object_version_number
   );
  hr_utility.set_location(l_proc, 40);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_TYPE
  --
  per_eqt_bus.chk_qualification_type
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_qualification_type        =>      p_rec.qualification_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 50);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CREDIT_TYPE
  --
  per_eqt_bus.chk_credit_type
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_credit_type               =>      p_rec.credit_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 60);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LEVEL_TYPE
  --
 per_eqt_bus.chk_level_type
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_level_type                =>      p_rec.level_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 70);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LEVEL_LEVEL
  --
  per_eqt_bus.chk_level_number
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_level_number              =>      p_rec.level_number
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 80);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FIELD
  --
  per_eqt_bus.chk_field
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_field                     =>      p_rec.field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 90);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_SUB_FIELD
  --
  per_eqt_bus.chk_sub_field
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_sub_field                 =>      p_rec.sub_field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 100);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROVIDER
  --
  -- Rule check provider
  --
  per_eqt_bus.chk_provider
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_provider                  =>      p_rec.provider
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
 );
  hr_utility.set_location(l_proc, 110);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QA_ORGANIZATION
  --
  per_eqt_bus.chk_qa_organization
   (p_qualification_type_id     =>      p_rec.qualification_type_id
   ,p_qa_organization           =>      p_rec.qa_organization
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 120);
  --
  -- Descriptive Flex Check
  -- ======================
  --
  per_eqt_bus.chk_df(p_rec => p_rec);

  -- mvankada

  -- Developer Descriptive Flex Check
  -- ======================
  --
  per_eqt_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_eqt_shd.g_rec_type) is
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
end per_eqt_bus;

/
