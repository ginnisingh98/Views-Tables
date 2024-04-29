--------------------------------------------------------
--  DDL for Package Body PQH_RFT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RFT_BUS" as
/* $Header: pqrftrhi.pkb 120.2 2005/10/12 20:19:02 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rft_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ref_template_id >------|
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
--   ref_template_id PK of record being inserted or updated.
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
Procedure chk_ref_template_id(p_ref_template_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ref_template_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rft_shd.api_updating
    (p_ref_template_id                => p_ref_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ref_template_id,hr_api.g_number)
     <>  pqh_rft_shd.g_old_rec.ref_template_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rft_shd.constraint_error('PQH_REF_TEMPLATES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ref_template_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rft_shd.constraint_error('PQH_REF_TEMPLATES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ref_template_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_base_template_id >------|
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
--   p_ref_template_id PK
--   p_base_template_id ID of FK column
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
Procedure chk_base_template_id (p_ref_template_id       in number,
                                p_base_template_id      in number,
                                p_reference_type_cd     in varchar2,
                                p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_base_template_id';
  l_api_updating        boolean;
  l_dummy               varchar2(1);
  l_enable_flag         pqh_templates.enable_flag%type;
  l_attribute_only_flag pqh_templates.attribute_only_flag%type;
  l_freeze_status_cd    pqh_templates.freeze_status_cd%type;
  --
  cursor c1 is
    select nvl(enable_flag,hr_api.g_varchar2),
           nvl(attribute_only_flag,hr_api.g_varchar2),
           nvl(freeze_status_cd ,hr_api.g_varchar2)
    from   pqh_templates a
    where  a.template_id = p_base_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rft_shd.api_updating
     (p_ref_template_id         => p_ref_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_base_template_id,hr_api.g_number)
     <> nvl(pqh_rft_shd.g_old_rec.base_template_id,hr_api.g_number)
     or not l_api_updating) then

    --
    -- check if base_template_id value exists in pqh_templates table
    --
    open c1;
      --
      fetch c1 into l_enable_flag,l_attribute_only_flag,l_freeze_status_cd;
      --      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_templates
        -- table.
        --
        pqh_rft_shd.constraint_error('PQH_REF_TEMPLATES_FK2');
        --
      end if;
      --
    close c1;
    --
    -- The referenced template must be enabled .
    --
    if l_enable_flag <> 'Y' then
       if p_reference_type_cd = 'REFERENCE' then
          hr_utility.set_message(8302,'PQH_RFT_NOT_ENABLED');
          hr_utility.raise_error;
       Else
          hr_utility.set_message(8302,'PQH_COPY_TEM_NOT_ENABLED');
          hr_utility.raise_error;
       End if;
    end if;
    --
    -- Can refernce only templates marked as reference templates.
    --
    if p_reference_type_cd = 'REFERENCE' and  l_attribute_only_flag <> 'Y' then
     hr_utility.set_message(8302,'PQH_INVALID_RFT');
     hr_utility.raise_error;
    end if;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_base_template_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_parent_template_id >------|
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
--   p_ref_template_id PK
--   p_parent_template_id ID of FK column
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
Procedure chk_parent_template_id (p_ref_template_id       in number,
                            p_parent_template_id          in number,
                            p_reference_type_cd           in varchar2,
                            p_object_version_number in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_parent_template_id';
  l_api_updating        boolean;
  l_dummy               varchar2(1);
  l_freeze_status_cd    pqh_templates.freeze_status_cd%type;
  l_attribute_only_flag pqh_templates.attribute_only_flag%type;
  --
  cursor c1 is
    select nvl(freeze_status_cd,hr_api.g_varchar2) ,
           nvl(attribute_only_flag,hr_api.g_varchar2)
    from   pqh_templates a
    where  a.template_id = p_parent_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rft_shd.api_updating
     (p_ref_template_id         => p_ref_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_parent_template_id,hr_api.g_number)
     <> nvl(pqh_rft_shd.g_old_rec.parent_template_id,hr_api.g_number)
     or not l_api_updating) and
     p_parent_template_id is not null then
    --
    -- check if parent_template_id value exists in pqh_templates table
    --
    open c1;
      --
      fetch c1 into l_freeze_status_cd,l_attribute_only_flag;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_templates
        -- table.
        --
        pqh_rft_shd.constraint_error('PQH_REF_TEMPLATES_FK1');
        --
      end if;
      --
    close c1;
    --
    -- If inserting  reference template to a parent reference template
    -- raise error
    --
    if l_attribute_only_flag = 'Y'  and p_reference_type_cd = 'REFERENCE' then
       hr_utility.set_message(8302,'PQH_PARENT_TEM_IS_ATTR_ONLY');
       hr_utility.raise_error;
    End if;
    --
  end if;
  --
  if l_freeze_status_cd = 'FREEZE_TEMPLATE' then
     hr_utility.set_message(8302,'PQH_NO_ADD_REF_TO_PARENT');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_parent_template_id;
--
-- Check the compatability of the legislation code of the parent/base templates
--
Procedure chk_legislation_code (p_ref_template_id          in number,
                            p_parent_template_id          in number,
                            p_base_template_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_legislation_code';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  l_base_leg_code varchar2(30);
  l_base_template_name varchar2(100);
  l_parent_leg_code varchar2(30);
  l_parent_template_name varchar2(100);
  --
  cursor c1(p_template_id number) is
  select legislation_code, template_name
  from pqh_templates_vl
  where template_id = p_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  l_api_updating := pqh_rft_shd.api_updating
     (p_ref_template_id            => p_ref_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_base_template_id,hr_api.g_number)
     <> nvl(pqh_rft_shd.g_old_rec.base_template_id,hr_api.g_number)
     or not l_api_updating) then
     --
     open c1(p_parent_template_id);
     fetch c1 into l_parent_leg_code, l_parent_template_name;
     close c1;
     open c1(p_base_template_id);
     fetch c1 into l_base_leg_code, l_base_template_name;
     close c1;
     --
     if l_parent_leg_code is null then
       if l_base_leg_code is not null then
        hr_utility.set_message(8302,'PQH_NO_LEG_REF_TEM');
        hr_utility.set_message_token('REF_TEMPLATE', l_base_template_name);
        hr_utility.set_message_token('PARENT_TEMPLATE', l_parent_template_name);
        hr_utility.raise_error;
       end if;
     else
       if nvl(l_base_leg_code,l_parent_leg_code)  <> l_parent_leg_code then
        hr_utility.set_message(8302,'PQH_REF_TEM_LEG_NE_PAR_TEM');
        hr_utility.set_message_token('REF_TEMPLATE', l_base_template_name);
        hr_utility.set_message_token('PARENT_TEMPLATE', l_parent_template_name);
        hr_utility.raise_error;
       end if;
     end if;
     --
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_reference_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ref_template_id   PK
--   reference_type_cd lookup
--   effective_date    effective date
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
Procedure chk_reference_type_cd(
                            p_ref_template_id             in number,
                            p_reference_type_cd           in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reference_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rft_shd.api_updating
    (p_ref_template_id            => p_ref_template_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_reference_type_cd
      <> nvl(pqh_rft_shd.g_old_rec.reference_type_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_REFERENCE_TYPE',
           p_lookup_code    => p_reference_type_cd,
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
end chk_reference_type_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_rft_tct >------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks  if the parent template and base template have the
--   same transaction category id.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ref_template_id PK
--   p_parent_template_id ID of FK column
--   p_base_template_id ID of FK column
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
Procedure chk_rft_tct (p_ref_template_id       in number,
                       p_parent_template_id    in number,
                       p_base_template_id      in number,
                       p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rft_tct';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_parent_tct   pqh_templates.transaction_category_id%type;
  l_base_tct     pqh_templates.transaction_category_id%type;
  --
  cursor c1 is
  select transaction_category_id
  from pqh_templates a
  where a.template_id = p_parent_template_id;

  cursor c2 is
  select transaction_category_id
  from pqh_templates a
  where a.template_id = p_base_template_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rft_shd.api_updating
     (p_ref_template_id         => p_ref_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_parent_template_id,hr_api.g_number)
     <> nvl(pqh_rft_shd.g_old_rec.parent_template_id,hr_api.g_number)
     or not l_api_updating) and
     p_parent_template_id is not null then
    --
    --
      open c1;
      fetch c1 into l_parent_tct;
      close c1;

      open c2;
      fetch c2 into l_base_tct;
      close c2;
    --

      if l_base_tct <> l_parent_tct then
       hr_utility.set_message(8302,'PQH_RFT_TCT_MISMATCH');
       hr_utility.raise_error;
      End if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_rft_tct;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rft_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_ref_template_id
  (p_ref_template_id          => p_rec.ref_template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_base_template_id
  (p_ref_template_id          => p_rec.ref_template_id,
   p_base_template_id          => p_rec.base_template_id,
   p_reference_type_cd        => p_rec.reference_type_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_parent_template_id
  (p_ref_template_id          => p_rec.ref_template_id,
   p_parent_template_id          => p_rec.parent_template_id,
   p_reference_type_cd        => p_rec.reference_type_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_reference_type_cd
  (p_ref_template_id          => p_rec.ref_template_id,
   p_reference_type_cd        => p_rec.reference_type_cd,
      p_effective_date        => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
 chk_rft_tct
  (p_ref_template_id          => p_rec.ref_template_id,
   p_parent_template_id          => p_rec.parent_template_id,
   p_base_template_id          => p_rec.base_template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  chk_legislation_code
  (p_ref_template_id          => p_rec.ref_template_id,
   p_parent_template_id       => p_rec.parent_template_id,
   p_base_template_id         => p_rec.base_template_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rft_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_ref_template_id
  (p_ref_template_id       => p_rec.ref_template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_base_template_id
  (p_ref_template_id       => p_rec.ref_template_id,
   p_base_template_id      => p_rec.base_template_id,
   p_reference_type_cd        => p_rec.reference_type_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_parent_template_id
  (p_ref_template_id       => p_rec.ref_template_id,
   p_parent_template_id    => p_rec.parent_template_id,
   p_reference_type_cd        => p_rec.reference_type_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_reference_type_cd
  (p_ref_template_id          => p_rec.ref_template_id,
   p_reference_type_cd        => p_rec.reference_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_rft_tct
  (p_ref_template_id       => p_rec.ref_template_id,
   p_parent_template_id    => p_rec.parent_template_id,
   p_base_template_id      => p_rec.base_template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_legislation_code
  (p_ref_template_id          => p_rec.ref_template_id,
   p_parent_template_id       => p_rec.parent_template_id,
   p_base_template_id         => p_rec.base_template_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rft_shd.g_rec_type
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
end pqh_rft_bus;

/
