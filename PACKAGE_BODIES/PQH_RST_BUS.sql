--------------------------------------------------------
--  DDL for Package Body PQH_RST_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RST_BUS" as
/* $Header: pqrstrhi.pkb 120.2.12000000.2 2007/04/19 12:46:34 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rst_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |                     LOCAL Functions                           |
-- ----------------------------------------------------------------------------
--
function get_rule_set_name (p_rule_set_id in number) return varchar2 is
   l_rule_set_name pqh_rule_sets_tl.rule_set_name%type;
cursor c1 is select rule_set_name
             from pqh_rule_sets_vl
             where rule_set_id = p_rule_set_id;
begin
   open c1;
   fetch c1 into l_rule_set_name;
   close c1;
   return l_rule_set_name;
end;
--
-- ----------------------------------------------------------------------------
-- |                     LOCAL Functions END                       |
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------< chk_rule_set_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rule_set_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_rule_set_id(p_rule_set_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rule_set_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rule_set_id,hr_api.g_number)
     <>  pqh_rst_shd.g_old_rec.rule_set_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rst_shd.constraint_error('RULE_SETS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_rule_set_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rst_shd.constraint_error('RULE_SETS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rule_set_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rule_set_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the rule set name is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rule_set_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_rule_set_name(p_rule_set_id                 in number,
                            p_rule_set_name               in varchar2,
                            p_object_version_number       in number) is
  --
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  Cursor csr_rst_name is
  select null
    from pqh_rule_sets_vl
   where rule_set_name = p_rule_set_name;
  --
  l_proc         varchar2(72) := g_package||'chk_rule_set_name';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rule_set_name,hr_api.g_varchar2)
     <>  pqh_rst_shd.g_old_rec.rule_set_name
     OR NOT l_api_updating) then
    --
    -- raise error as PK has changed
    --
    Open csr_rst_name;
    Fetch csr_rst_name into l_dummy;
    If csr_rst_name%found then
       Close csr_rst_name;
       hr_utility.set_message(8302,'PQH_DUPLICATE_RULE_SET_NAME');
       hr_utility.raise_error;
    End if;
    Close csr_rst_name;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rule_set_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_referenced_rule_set_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rule_set_id PK
--   p_referenced_rule_set_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_referenced_rule_set_id (p_rule_set_id            in number,
                                      p_referenced_rule_set_id in number,
                                      p_rule_category          in varchar2,
                                      p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_referenced_rule_set_id';
  l_api_updating boolean;
  l_seeded_rule_flag pqh_rule_sets.seeded_rule_flag%type;
  l_rule_category pqh_rule_sets.rule_category%type;
  l_ref_rule_set_name pqh_rule_sets_tl.rule_set_name%type;
  --
  cursor c1 is
    select seeded_rule_flag,rule_set_name,rule_category
    from   pqh_rule_sets_vl
    where  rule_set_id = p_referenced_rule_set_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating and
     (nvl(p_referenced_rule_set_id,hr_api.g_number)
      <> nvl(pqh_rst_shd.g_old_rec.referenced_rule_set_id,hr_api.g_number)
      or nvl(p_rule_category,hr_api.g_number)
      <> nvl(pqh_rst_shd.g_old_rec.rule_category,hr_api.g_number))
      or not l_api_updating) then
    --
    if p_referenced_rule_set_id is not null then
       open c1;
       fetch c1 into l_seeded_rule_flag,l_ref_rule_set_name,l_rule_category;
       if c1%notfound then
          close c1;
          pqh_rst_shd.constraint_error('PQH_RULE_SETS_FK4');
       else
          close c1;
          if l_rule_category <> p_rule_category then
             hr_utility.set_location ('rule category does not match with reference rule',10);
             hr_utility.set_message(8302,'PQH_CBR_RULE_CAT_REF');
             hr_utility.set_message_token('CATEGORY_REF',l_rule_category);
             hr_utility.set_message_token('CATEGORY_RULS',p_rule_category);
             hr_utility.raise_error;
          end if;
          if l_seeded_rule_flag <> 'Y' then
             hr_utility.set_location ('user defined rule is being made reference rule',10);
             hr_utility.set_message(8302,'PQH_CBR_USER_DEF_REF');
             hr_utility.set_message_token('REFERENCE_RULE_SET',l_ref_rule_set_name);
             hr_utility.raise_error;
          end if;
       end if;
    else
       if p_rule_category <> 'REALLOCATION' then
          hr_utility.set_location('Reference rule has to be there',20);
          hr_utility.set_message(8302,'PQH_CBR_BGT_REALLOC_NO_REF');
          hr_utility.raise_error;
       end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_referenced_rule_set_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_business_group_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rule_set_id PK
--   p_business_group_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_business_group_id (p_rule_set_id          in number,
                            p_business_group_id        in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_business_group_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_business_groups a
    where  a.organization_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_business_group_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.business_group_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if business_group_id exists in hr_all_organization_units table
    --
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        pqh_rst_shd.constraint_error('PQH_RULE_SETS_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_business_group_id;
--
-- ----------------------------------------------------------------------------
-- |----------< chk_duplicate_rule_set >--------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rule_set_id PK
--   p_organization_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_duplicate_rule_set (p_rule_set_id               in number,
                                  p_organization_id           in number,
                                  p_organization_structure_id in NUMBER,
                                  p_business_group_id         in number,
                                  p_starting_organization_id  in number,
                                  p_rule_category	      in varchar2,
                                  p_referenced_rule_set_id    in number,
                                  p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_rule_set';
  l_api_updating boolean;
  l_business_group_id hr_all_organization_units.business_group_id%type;
  l_rule_set_name   pqh_rule_sets_tl.rule_set_name%type;
  l_rule_set_id     pqh_rule_sets.rule_set_id%type;
  --
  cursor c1 is
    select rule_set_id
    from   pqh_rule_sets
    where ((p_organization_id is null and organization_id is null) or
                         (organization_id = p_organization_id))
    and ((p_organization_structure_id is null and organization_structure_id is null) or
                         (organization_structure_id = p_organization_structure_id))
    and ((p_business_group_id is null and business_group_id is null) or
                         (business_group_id = p_business_group_id))
    and ((p_starting_organization_id is null and starting_organization_id is null) or
                         (starting_organization_id = p_starting_organization_id))
    and ((p_rule_category is null and rule_category is null) or
    			 (rule_category = p_rule_category))
    and ((p_referenced_rule_set_id is null and referenced_rule_set_id is null) or
    			 (referenced_rule_set_id = p_referenced_rule_set_id))
    and rule_set_id <> p_rule_set_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating and (
      nvl(p_organization_id,hr_api.g_number) <> nvl(pqh_rst_shd.g_old_rec.organization_id,hr_api.g_number)
   or nvl(p_organization_structure_id,hr_api.g_number) <> nvl(pqh_rst_shd.g_old_rec.organization_structure_id,hr_api.g_number)
   or nvl(p_business_group_id,hr_api.g_number) <> nvl(pqh_rst_shd.g_old_rec.business_group_id,hr_api.g_number)
   or nvl(p_starting_organization_id,hr_api.g_number) <> nvl(pqh_rst_shd.g_old_rec.starting_organization_id,hr_api.g_number)
   or nvl(p_rule_category,hr_api.g_varchar2) <> nvl(pqh_rst_shd.g_old_rec.rule_category,hr_api.g_varchar2)
   or nvl(p_referenced_rule_set_id,hr_api.g_number) <> nvl(pqh_rst_shd.g_old_rec.referenced_rule_set_id,hr_api.g_number))
     or not l_api_updating) then
     --
     -- check for duplicate rule sets
     --
      open c1;
      fetch c1 into l_rule_set_id;
      if c1%found then
        close c1;
        --
        l_rule_set_name := get_rule_set_name(p_rule_set_id);
        --
        hr_utility.set_message(8302,'PQH_DUP_RULE_SET');
        hr_utility.set_message_token('REFERENCE_RULE_SET',l_rule_set_name);
        hr_utility.raise_error;
        --
      end if;
      --
      close c1;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_duplicate_rule_set;
--
--
-- ----------------------------------------------------------------------------
-- |----------< chk_dup_rule_set >--------------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks whether Rule being inserted or updated does not
--   already exist for the same scope and referenced rule.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rule_set_id PK
--   p_organization_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
  PROCEDURE chk_dup_rule_set(p_rule_set_id               IN NUMBER,
                             p_organization_id           IN NUMBER,
                             p_organization_structure_id IN NUMBER,
                             p_business_group_id         IN NUMBER,
                             p_starting_organization_id  IN NUMBER,
                             p_rule_category	         IN VARCHAR2,
                             p_referenced_rule_set_id    IN NUMBER,
                             p_seeded_rule_flag          IN VARCHAR2,
                             p_object_version_number     IN NUMBER) IS
  --
    l_proc              VARCHAR2(72) := g_package||'chk_ins_dup_rule_set';
    l_rule_set_id       PQH_RULE_SETS.rule_set_id%TYPE;
    l_ref_rule_set_name PQH_RULE_SETS_TL.rule_set_name%TYPE;
  --
    CURSOR c1 IS
    SELECT rule_set_id
      FROM pqh_rule_sets
     WHERE rule_set_id                      <> NVL(p_rule_set_id,-1)
       AND NVL(business_group_id,-1)         = NVL(p_business_group_id,-1)
       AND NVL(organization_structure_id,-1) = NVL(p_organization_structure_id,-1)
       AND NVL(starting_organization_id,-1)  = NVL(p_starting_organization_id,-1)
       AND NVL(organization_id,-1)           = NVL(p_organization_id,-1)
       AND rule_category                     = p_rule_category
       AND referenced_rule_set_id            = p_referenced_rule_set_id
       AND NVL(seeded_rule_flag,'N')         = 'N'
       AND NVL(p_seeded_rule_flag,'N')       = 'N';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering: '||l_proc,5);
  --
    OPEN c1;
    FETCH c1 into l_rule_set_id;
    IF c1%FOUND THEN
       CLOSE c1;
       l_ref_rule_set_name := get_rule_set_name(p_referenced_rule_set_id);
       HR_UTILITY.set_message(8302,'PQH_DUP_RULE_SET');
       HR_UTILITY.set_message_token('REFERENCE_RULE_SET',l_ref_rule_set_name);
       HR_UTILITY.raise_error;
    END IF;
    CLOSE c1;
  --
    HR_UTILITY.set_location('Leaving: '||l_proc,10);
  --
  END chk_dup_rule_set;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_organization_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rule_set_id PK
--   p_organization_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_organization_id (p_rule_set_id            in number,
                            p_organization_id           in number,
                            p_business_group_id         in number,
                            p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_business_group_id hr_all_organization_units.business_group_id%type;
  --
  cursor c1 is
    select business_group_id
    from   hr_all_organization_units a
    where  a.organization_id = p_organization_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  -- if business group is changed or organization is changed this rule should kick in
  -- provided organization id is there
  --
  if (l_api_updating
     and (nvl(p_business_group_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.business_group_id,hr_api.g_number)
     or nvl(p_organization_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.organization_id,hr_api.g_number))
     or not l_api_updating)
     and p_organization_id is not null then
     --
     -- check if organization value exists in hr_all_organization_units table
     --
      open c1;
      --
      fetch c1 into l_business_group_id;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        hr_utility.set_message(8302,'PQH_ORG_NOT_VALID');
        hr_utility.raise_error;
        --
      end if;
      --
      close c1;
      --
      --
      -- Check if the organization_structure belongs to the same business_group
      -- As the passed business_group
      --
      If l_business_group_id <> p_business_group_id then
         --
         hr_utility.set_message(8302,'PQH_ORG_NOT_IN_BG');
         hr_utility.raise_error;
         --
      End if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_organization_structure_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rule_set_id PK
--   p_organization_structure_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_organization_structure_id (p_rule_set_id               in number,
                                         p_organization_structure_id in number,
                                         p_business_group_id         in number,
                                         p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_structure_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
l_business_group_id per_organization_structures.business_group_id%type;

  --
  cursor c1 is
    select business_group_id
    from   per_organization_structures a
    where  a.organization_structure_id = p_organization_structure_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_organization_structure_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.organization_structure_id,hr_api.g_number)
     or nvl(p_organization_structure_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.organization_structure_id,hr_api.g_number))
     or not l_api_updating) and
     p_organization_structure_id is not null then
    --
    -- check if organization_structure_id value exists in per_organization_structures table
    --
    open c1;
      --
      fetch c1 into l_business_group_id;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_organization_structures
        -- table.
        --
        pqh_rst_shd.constraint_error('PQH_RULE_SETS_FK2');
        --
      end if;
      --
    close c1;
    --
    --
    -- Check if the organization_structure belongs to the same business_group
    -- As the passed business_group
    --
    If l_business_group_id <> p_business_group_id then
      hr_utility.set_message(8302,'PQH_ORG_STRUCT_NOT_IN_BG');
      hr_utility.raise_error;
    End if;
    --

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_structure_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rule_level_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rule_set_id PK of record being inserted or updated.
--   rule_level_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_rule_level_cd(p_rule_set_id                in number,
                            p_rule_level_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rule_level_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rule_level_cd
      <> nvl(pqh_rst_shd.g_old_rec.rule_level_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rule_level_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_RULE_LEVEL',
           p_lookup_code    => p_rule_level_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rule_level_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_rule_applicability >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rule_set_id PK of record being inserted or updated.
--   rule_applicability Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_rule_applicability(p_rule_set_id                in number,
                                 p_rule_applicability          in varchar2,
                                 p_rule_category               in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rule_applicability';
  l_api_updating boolean;
  l_rule_category_meaning varchar2(240);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (p_rule_applicability <> nvl(pqh_rst_shd.g_old_rec.rule_applicability,hr_api.g_varchar2)
      or p_rule_category <> nvl(pqh_rst_shd.g_old_rec.rule_category,hr_api.g_varchar2))
      or not l_api_updating)
      and p_rule_applicability is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_CBR_APPLICABILITY',
           p_lookup_code    => p_rule_applicability,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    if p_rule_category ='REALLOCATION' then
       if p_rule_applicability not in ('DONOR','RECEIVER') then
          hr_utility.set_message(8302,'PQH_CBR_BR_APPL_MISMATCH');
          hr_utility.raise_error;
       end if;
    else
       if p_rule_applicability not in ('NONE') then
	select hr_general.decode_lookup('PQH_CBR_RULE_CATEGORY', p_rule_category)
	into l_rule_category_meaning from dual;
		if l_rule_category_meaning is not null then
			l_rule_category_meaning := '"'||l_rule_category_meaning||'"';
		end if;
	hr_utility.set_message(8302,'PQH_CBR_OTHER_APPL_MISMATCH');
	hr_utility.set_message_token('CATEGORY_RULE', l_rule_category_meaning);
        hr_utility.raise_error;
       end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rule_applicability;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_rule_category >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rule_set_id PK of record being inserted or updated.
--   rule_category Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_rule_category(p_rule_set_id                in number,
                            p_rule_category               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rule_category';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
    (p_rule_set_id                => p_rule_set_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_rule_category
      <> nvl(pqh_rst_shd.g_old_rec.rule_category,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rule_category is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_CBR_RULE_CATEGORY',
           p_lookup_code    => p_rule_category,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rule_category;
--
----------------------------Extra API checks----------------------------------
--
-- ----------------------------------------------------------------------------
-- |------< get_org_structure_version_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if there is a overlap of entered
--   org structure and existing org structures for the Business Group
--   and Referenced rule set
--
Procedure get_org_structure_version_id
                              (p_org_structure_id IN   NUMBER,
                               p_org_structure_version_id  OUT NOCOPY  NUMBER) is
Cursor c1 is
  Select org_structure_version_id
    From per_org_structure_versions
   Where organization_structure_id = p_org_structure_id
     AND version_number =
         (select max(version_number)
          From per_org_structure_versions
          Where organization_structure_id = p_org_structure_id);
Begin
  --
  Open c1;
  Fetch c1 into p_org_structure_version_id;
  Close c1;
  --
  --
End;
--
--
--
Procedure chk_org_in_org_structure
                           (p_rule_set_id                    in number,
                            p_starting_organization_id       in number,
                            p_organization_structure_id      in number,
                            p_object_version_number          in number) is
--
  l_proc                      varchar2(72) := g_package||'chk_org_in_org_structure';
  l_dummy                     varchar2(1);
  l_api_updating boolean;
  l_org_structure_version_id  per_org_structure_versions.org_structure_version_id%type;
--
Cursor c1 is
  Select null
   FROM per_org_structure_elements a
   WHERE a.org_structure_version_id   = l_org_structure_version_id
   AND   a.organization_id_child      = p_starting_organization_id
  UNION
  Select null
   FROM per_org_structure_elements b
   WHERE b.org_structure_version_id   = l_org_structure_version_id
   AND   b.organization_id_parent     = p_starting_organization_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
     (p_rule_set_id            => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and ( nvl(p_starting_organization_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.starting_organization_id,hr_api.g_number)
     or nvl(p_organization_structure_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.organization_structure_id,hr_api.g_number))
     or not l_api_updating) then
    --
    If p_organization_structure_id IS NOT NULL then
    --
    -- get version id for the structure;
    --
      get_org_structure_version_id
      (p_org_structure_id         => p_organization_structure_id,
       p_org_structure_version_id => l_org_structure_version_id);
      --
      Open c1;
      --
      Fetch c1 into l_dummy;
      --
      If c1%notfound then
        Close c1;
        hr_utility.set_message(8302, 'PQH_ORG_NOT_IN_ORG_STRUCT');
        hr_utility.raise_error;
      End if;
      --
      Close c1;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End;
--
--
Procedure chk_rule_scope (p_rule_set_id                    in number,
                          p_starting_organization_id       in number,
                          p_organization_id                in number,
                          p_organization_structure_id      in number,
                          p_object_version_number          in number) is
--
  l_proc                      varchar2(72) := g_package||'chk_rule_scope';
  l_api_updating boolean;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rst_shd.api_updating
     (p_rule_set_id            => p_rule_set_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and ( nvl(p_starting_organization_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.starting_organization_id,hr_api.g_number)
     or nvl(p_organization_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.organization_id,hr_api.g_number)
     or nvl(p_organization_structure_id,hr_api.g_number)
     <> nvl(pqh_rst_shd.g_old_rec.organization_structure_id,hr_api.g_number))
     or not l_api_updating) then
    --
       if p_organization_structure_id is not null and p_organization_id is not null then
          hr_utility.set_location('org hier entered, org must be null',20);
          hr_utility.set_message(8302, 'PQH_ORG_WITH_ORG_STRUCT');
          hr_utility.raise_error;
       end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End;
--
-- The foll procedures are written to check for org_structure overlap
--
------------------------------------------------------------------------------
-- |--------------------------< get_ref_rule_set_name>-----------------------
------------------------------------------------------------------------------
--
Procedure get_ref_rule_set_name(p_rule_set_id    in number,
                                p_rule_set_name out nocopy varchar2) is
--
Cursor csr_ref is
 Select rule_set_name
   From pqh_rule_sets_tl
  Where rule_set_id = p_rule_set_id;
--
  l_proc    varchar2(72) := g_package||'get_ref_rule_set_name';
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc, 5);
  --
  Open csr_ref;
  --
  Fetch csr_ref into p_rule_set_name;
  --
  Close csr_ref;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rst_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_rule_set_id
  (p_rule_set_id          => p_rec.rule_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rule_set_name
  (p_rule_set_id            => p_rec.rule_set_id,
   p_rule_set_name          => p_rec.rule_set_name,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_referenced_rule_set_id
  (p_rule_set_id            => p_rec.rule_set_id,
   p_referenced_rule_set_id => p_rec.referenced_rule_set_id,
   p_rule_category          => p_rec.rule_category,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_business_group_id
  (p_rule_set_id          => p_rec.rule_set_id,
   p_business_group_id        => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_rule_set_id          => p_rec.rule_set_id,
   p_business_group_id        => p_rec.business_group_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_structure_id
  (p_rule_set_id          => p_rec.rule_set_id,
   p_business_group_id        => p_rec.business_group_id,
   p_organization_structure_id          => p_rec.organization_structure_id,
   p_object_version_number => p_rec.object_version_number);
  --
/* Commented by deenath. Now calling chk_dup_rule_set.
  chk_duplicate_rule_set
  (p_rule_set_id               => p_rec.rule_set_id,
   p_business_group_id         => p_rec.business_group_id,
   p_organization_id           => p_rec.organization_id,
   p_referenced_rule_set_id    => p_rec.referenced_rule_Set_id,
   p_organization_structure_id => p_rec.organization_structure_id,
   p_starting_organization_id  => p_rec.starting_organization_id,
   p_rule_category             => p_rec.rule_category,
   p_object_version_number     => p_rec.object_version_number);
*/
  chk_dup_rule_set
  (p_rule_set_id               => p_rec.rule_set_id,
   p_business_group_id         => p_rec.business_group_id,
   p_organization_id           => p_rec.organization_id,
   p_referenced_rule_set_id    => p_rec.referenced_rule_Set_id,
   p_organization_structure_id => p_rec.organization_structure_id,
   p_starting_organization_id  => p_rec.starting_organization_id,
   p_rule_category             => p_rec.rule_category,
   p_seeded_rule_flag          => p_rec.seeded_rule_flag,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_org_in_org_structure
  (p_rule_set_id                => p_rec.rule_set_id,
   p_starting_organization_id   => p_rec.starting_organization_id,
   p_organization_structure_id  => p_rec.organization_structure_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_rule_scope
  (p_rule_set_id                => p_rec.rule_set_id,
   p_starting_organization_id   => p_rec.starting_organization_id,
   p_organization_id            => p_rec.organization_id,
   p_organization_structure_id  => p_rec.organization_structure_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_rule_level_cd
  (p_rule_set_id          => p_rec.rule_set_id,
   p_rule_level_cd         => p_rec.rule_level_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rule_category
  (p_rule_set_id          => p_rec.rule_set_id,
   p_rule_category         => p_rec.rule_category,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rule_applicability
  (p_rule_set_id          => p_rec.rule_set_id,
   p_rule_applicability         => p_rec.rule_applicability,
   p_rule_category              => p_rec.rule_category,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- call hr_api.validate_bus_grp_id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rst_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_rule_set_id
  (p_rule_set_id          => p_rec.rule_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rule_set_name
  (p_rule_set_id            => p_rec.rule_set_id,
   p_rule_set_name          => p_rec.rule_set_name,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_referenced_rule_set_id
  (p_rule_set_id            => p_rec.rule_set_id,
   p_referenced_rule_set_id => p_rec.referenced_rule_set_id,
   p_rule_category          => p_rec.rule_category,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_business_group_id
  (p_rule_set_id           => p_rec.rule_set_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_rule_set_id               => p_rec.rule_set_id,
   p_business_group_id         => p_rec.business_group_id,
   p_organization_id           => p_rec.organization_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_organization_structure_id
  (p_rule_set_id               => p_rec.rule_set_id,
   p_business_group_id         => p_rec.business_group_id,
   p_organization_structure_id => p_rec.organization_structure_id,
   p_object_version_number     => p_rec.object_version_number);
  --
/* Commented by deenath. Now calling chk_dup_rule_set.
  chk_duplicate_rule_set
  (p_rule_set_id          => p_rec.rule_set_id,
   p_business_group_id         => p_rec.business_group_id,
   p_organization_id           => p_rec.organization_id,
   p_referenced_rule_set_id    => p_rec.referenced_rule_Set_id,
   p_organization_structure_id => p_rec.organization_structure_id,
   p_starting_organization_id  => p_rec.starting_organization_id,
   p_rule_category             => p_rec.rule_category,
   p_object_version_number => p_rec.object_version_number);
*/
  chk_dup_rule_set
  (p_rule_set_id               => p_rec.rule_set_id,
   p_business_group_id         => p_rec.business_group_id,
   p_organization_id           => p_rec.organization_id,
   p_referenced_rule_set_id    => p_rec.referenced_rule_Set_id,
   p_organization_structure_id => p_rec.organization_structure_id,
   p_starting_organization_id  => p_rec.starting_organization_id,
   p_rule_category             => p_rec.rule_category,
   p_seeded_rule_flag          => p_rec.seeded_rule_flag,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_org_in_org_structure
  (p_rule_set_id                => p_rec.rule_set_id,
   p_starting_organization_id   => p_rec.starting_organization_id,
   p_organization_structure_id  => p_rec.organization_structure_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_rule_scope
  (p_rule_set_id                => p_rec.rule_set_id,
   p_starting_organization_id   => p_rec.starting_organization_id,
   p_organization_id            => p_rec.organization_id,
   p_organization_structure_id  => p_rec.organization_structure_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_rule_level_cd
  (p_rule_set_id           => p_rec.rule_set_id,
   p_rule_level_cd         => p_rec.rule_level_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rule_category
  (p_rule_set_id           => p_rec.rule_set_id,
   p_rule_category         => p_rec.rule_category,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rule_applicability
  (p_rule_set_id           => p_rec.rule_set_id,
   p_rule_applicability    => p_rec.rule_applicability,
   p_rule_category              => p_rec.rule_category,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- call hr_api.validate_bus_grp_id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rst_shd.g_rec_type
                         ,p_effective_date in date) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_rule_set_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pqh_rule_sets b
    where b.rule_set_id      = p_rule_set_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'rule_set_id',
                             p_argument_value => p_rule_set_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pqh_rst_bus;

/
