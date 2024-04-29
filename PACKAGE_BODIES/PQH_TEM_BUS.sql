--------------------------------------------------------
--  DDL for Package Body PQH_TEM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TEM_BUS" as
/* $Header: pqtemrhi.pkb 120.2.12000000.2 2007/04/19 12:48:53 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tem_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_template_id >------|
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
--   template_id PK of record being inserted or updated.
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
Procedure chk_template_id(p_template_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_template_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_template_id,hr_api.g_number)
     <>  pqh_tem_shd.g_old_rec.template_id) then
    --
    -- raise error as PK has changed
    --
    pqh_tem_shd.constraint_error('PQH_TEMPLATES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_template_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_tem_shd.constraint_error('PQH_TEMPLATES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_template_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_tem_dml_allowed >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure allows any updates to the template record only if it
--   is unfrozen.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
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
Procedure chk_tem_dml_allowed(p_template_id                 in number,
                              p_freeze_status_cd            in varchar2,
                              p_object_version_number       in number) is
  --
  l_proc             varchar2(72) := g_package||'chk_tem_dml_allowed';
  l_api_updating     boolean;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number      => p_object_version_number);
  --
  /** Updating but not the freeze status cd **/
      --
  if (l_api_updating
      and nvl(p_freeze_status_cd,hr_api.g_varchar2)
       =  nvl(pqh_tem_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2)) then
      --
      if nvl(pqh_tem_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2)
         = 'FREEZE_TEMPLATE' then
         hr_utility.set_message(8302,'PQH_NO_UPD_FROZEN_TEM');
         hr_utility.raise_error;
      End if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_tem_dml_allowed;
--
-- ----------------------------------------------------------------------------
-- |------< chk_tct_upd_allowed >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks  if the transaction category for the template
--   can be updated
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_template_id PK
--   p_transaction_category_id ID of FK column
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
Procedure chk_tct_upd_allowed (p_template_id             in number,
                               p_transaction_category_id in number,
                               p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tct_upd_allowed';
  l_api_updating boolean;
  l_dummy1       varchar2(1);
  l_dummy2       varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_template_attributes a
    where  a.template_id = p_template_id;
  --
  cursor c2 is
    select null
    from   pqh_ref_templates a
    where  a.base_template_id = p_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  l_api_updating := pqh_tem_shd.api_updating
     (p_template_id            => p_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_tem_shd.g_old_rec.transaction_category_id,hr_api.g_number)) then

     open c1;
     Fetch c1 into l_dummy1;
     if c1%found then
       close c1;
       hr_utility.set_message(8302,'PQH_TEM_DETAILS_EXIST');
       hr_utility.raise_error;
     End if;
     close c1;

     open c2;
     Fetch c2 into l_dummy2;
     if c2%found then
       close c2;
       hr_utility.set_message(8302,'PQH_TEM_DETAILS_EXIST');
       hr_utility.raise_error;
     End if;
     close c2;

  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_tct_upd_allowed;

-- ----------------------------------------------------------------------------
-- |------< chk_transaction_category_id >------|
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
--   p_template_id PK
--   p_transaction_category_id ID of FK column
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
Procedure chk_transaction_category_id (p_template_id          in number,
                            p_transaction_category_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_category_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_freeze_status_cd pqh_transaction_categories.freeze_status_cd%type;
  --
  cursor c1 is
    select nvl(freeze_status_cd,hr_api.g_varchar2)
    from   pqh_transaction_categories_vl a
    where  a.transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  l_api_updating := pqh_tem_shd.api_updating
     (p_template_id            => p_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_tem_shd.g_old_rec.transaction_category_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if transaction_category_id value exists in
    -- pqh_transaction_categories table
    --
    open c1;
      --
      fetch c1 into l_freeze_status_cd;
--      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_transaction_categories
        -- table.
        --
        pqh_tem_shd.constraint_error('PQH_TEMPLATES_FK');
        --
      end if;
      --
    close c1;

    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_category_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_legislation_code >------|
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
--   p_template_id PK
--   p_legislation_code Legislation code of FK column
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
Procedure chk_legislation_code (p_template_id          in number,
                            p_legislation_code          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_legislation_code';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_tat_leg_code varchar2(10);
  --
  cursor c1 is
    select  'x'
    from   fnd_territories_vl a
    where  a.territory_code = p_legislation_code;
  --
  cursor c2(p_template_id number) is
  select legislation_code
  from pqh_template_attributes tat, pqh_attributes att
  where tat.template_id = p_template_id
  and tat.attribute_id= att.attribute_id
  and att.legislation_code is not null;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  l_api_updating := pqh_tem_shd.api_updating
     (p_template_id            => p_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_legislation_code,hr_api.g_varchar2)
     <> nvl(pqh_tem_shd.g_old_rec.legislation_code,hr_api.g_varchar2)
     or not l_api_updating) then
     --
     -- check if legislation_code value exists in
     -- fnd_territories_vl table
     --
     if p_legislation_code is not null then
      open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in fnd_territories_vl
        -- table.
        --
        pqh_tem_shd.constraint_error('PQH_TEMPLATES_FK2');
        --
      end if;
      --
      close c1;
      --
     end if;
     --
     open c2(p_template_id);
     fetch c2 into l_tat_leg_code;
     if c2%found then
       close c2;
       if p_legislation_code is null then
         hr_utility.set_message(8302,'PQH_CANT_CHG_TEM_LEG_NULL');
         hr_utility.raise_error;
       end if;
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_template_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the  template name is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--   template_name
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
Procedure chk_template_name(p_template_id                 in number,
                            p_template_name               in varchar2,
                            p_transaction_category_id     in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_template_name';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_template_name,hr_api.g_varchar2)
     <>  pqh_tem_shd.g_old_rec.template_name)
      or not l_api_updating then
     --
     chk_template_name_unique
         (p_template_id                 => p_template_id,
          p_template_name               => p_template_name,
          p_transaction_category_id     => p_transaction_category_id);
     --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_template_name;
--
--
Procedure chk_template_name_unique
                           (p_template_id                 in number,
                            p_template_name               in varchar2,
                            p_transaction_category_id     in number) is
  --
  l_dummy   varchar2(1) ;
  --
  Cursor csr_tem_name is
  select null
    from pqh_templates_vl
   where template_name = p_template_name
     and transaction_category_id = p_transaction_category_id
     and template_id <> nvl(p_template_id,0);
  --
  l_proc         varchar2(72) := g_package||'chk_template_name_unique';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open csr_tem_name;
  Fetch csr_tem_name into l_dummy;
  --
  If csr_tem_name%found then
     Close csr_tem_name;
     hr_utility.set_message(8302,'PQH_DUPLICATE_TEM_NAME');
     hr_utility.raise_error;
  End if;
  --
  Close csr_tem_name;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_template_name_unique;
--

-- ----------------------------------------------------------------------------
-- |------< chk_under_review_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   under_review_flag Value of lookup code.
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
Procedure chk_under_review_flag(p_template_id             in number,
                            p_under_review_flag           in varchar2,
                            p_template_type_cd            in varchar2,
                            p_create_flag                 in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_under_review_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_under_review_flag
      <> nvl(pqh_tem_shd.g_old_rec.under_review_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_under_review_flag is not null then
         --
         -- check if value of lookup falls within lookup type.
         --
         if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_under_review_flag,
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
  If p_under_review_flag = 'Y' then
     --
     if p_template_type_cd = 'DOMAIN' then
        --
        hr_utility.set_message(8302,'PQH_NO_REVIEW_FOR_DOMAIN_TEM');
        hr_utility.raise_error;
        --
      End if;
      --
     If p_create_flag = 'Y' then
        --
        hr_utility.set_message(8302,'PQH_NO_REVIEW_FOR_CREATE_TEM');
        hr_utility.raise_error;
        --
      End if;
      --
   End if;
   --
   --
   hr_utility.set_location('Leaving:'||l_proc,10);
   --
end chk_under_review_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_if_template_applied >------|
-- ----------------------------------------------------------------------------
--
Function chk_if_template_applied(p_template_id in number)
RETURN varchar2 IS
--
l_proc         varchar2(72) := g_package||'chk_if_template_applied';
l_dummy        varchar2(1);
--
Cursor csr_tem_appl is
 Select null
   from pqh_transaction_templates
  Where template_id = p_template_id;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc,5);
   --
   Open csr_tem_appl;
   Fetch csr_tem_appl into l_dummy;
   --
   If csr_tem_appl%notfound then
      Close csr_tem_appl;
      RETURN 'N';
   End if;
   --
   Close csr_tem_appl;
   --
   RETURN 'Y';
   --
   hr_utility.set_location('Leaving:'||l_proc,10);
   --
End;
--
-- ----------------------------------------------------------------------------
-- |------< chk_create_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   create_flag Value of lookup code.
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
Procedure chk_create_flag(p_template_id               in number,
                          p_create_flag               in varchar2,
                          p_template_type_cd          in varchar2,
                          p_effective_date            in date,
                          p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_create_flag';
  l_api_updating boolean;
  l_applied_flag varchar2(10);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_create_flag
      <> nvl(pqh_tem_shd.g_old_rec.create_flag,hr_api.g_varchar2)
      or not l_api_updating) and
      p_create_flag is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_create_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
  --
  End if; /* If update or insert */
  --
  -- Check if create flag can be updated.Should not allow update if the
  -- template was used in any transaction.
  --
  if l_api_updating AND
      nvl(p_create_flag,hr_api.g_varchar2)
      <> nvl(pqh_tem_shd.g_old_rec.create_flag,hr_api.g_varchar2) then
      --
      l_applied_flag := chk_if_template_applied(p_template_id => p_template_id);
      --
      If l_applied_flag = 'Y' then
         --
         hr_utility.set_message(8302,'PQH_NO_UPD_TEM_TASK_TYPE');
         hr_utility.raise_error;
         --
      End if;
      --
  End if;
  --
  --
  If p_create_flag is not null then
      --
      -- Raise error if create flag has a value for a domain template
      --
      If p_template_type_cd = 'DOMAIN' then
         --
         hr_utility.set_message(8302,'PQH_NO_TASK_FOR_DOMAIN_TEM');
         hr_utility.raise_error;
         --
      End if;
      --
  Else
      --
      -- Raise error if create flag has no value for a task template
      --
      if p_template_type_cd = 'TASK' then
         --
         hr_utility.set_message(8302,'PQH_INVALID_TEMPLATE_TASK');
         hr_utility.raise_error;
         --
      End if;
      --
  End if; /*If p_create_flag is not null*/
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_create_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enable_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   enable_flag Value of lookup code.
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
Procedure chk_enable_flag(p_template_id                in number,
                            p_enable_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_tem_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enable_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enable_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    If p_enable_flag = 'N' then
       --
       disable_role_templates(p_template_id   =>   p_template_id);
       --
    End if;
    --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enable_flag;
--
--
Procedure disable_role_templates(p_template_id                in number) is
  --
  l_proc         varchar2(72) := g_package||'disable_role_templates';
  --
  Cursor csr_role_templates is
  Select role_template_id,object_version_number
    From pqh_role_templates
   Where template_id = p_template_id;
  --
  l_object_version_number    pqh_role_templates.object_version_number%type;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  For rec in csr_role_templates loop
      --
      l_object_version_number := rec.object_version_number;
      --
      pqh_role_templates_api.update_role_template(
        p_validate               => false
       ,p_role_template_id       => rec.role_template_id
       ,p_enable_flag            => 'N'
       ,p_object_version_number  => l_object_version_number
       ,p_effective_date         => sysdate  );
      --
  End loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End disable_role_templates;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_attribute_only_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   attribute_only_flag Value of lookup code.
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
Procedure chk_attribute_only_flag(p_template_id                in number,
                            p_attribute_only_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_only_flag';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  Cursor c1 is
    select null
    from pqh_ref_templates a
    where a.parent_template_id = p_template_id
      and a.reference_type_cd = 'REFERENCE';
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_attribute_only_flag
      <> nvl(pqh_tem_shd.g_old_rec.attribute_only_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_attribute_only_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_attribute_only_flag,
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
  -- Raise error if attribute_only_flag is updated to  Y and reference templates
  -- exist for the current template.
  --
  if (l_api_updating
      and nvl(p_attribute_only_flag,hr_api.g_varchar2)
       <> nvl(pqh_tem_shd.g_old_rec.attribute_only_flag,hr_api.g_varchar2)) then
      --
      if nvl(p_attribute_only_flag,hr_api.g_varchar2) = 'Y' then
         --
         -- Check if the attribute_only_flag is being updated to 'Y'
         open c1;
         fetch c1 into l_dummy;
         if c1%found then
            Close c1;
            hr_utility.set_message(8302,'PQH_REF_TEMPLATES_EXIST');
            hr_utility.raise_error;
         End if;
         close c1;
         -- Raise error if reference records exist in pqh_ref_templates
         --
      --
      End if;
  --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_attribute_only_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_freeze_status_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   freeze_status_cd Value of lookup code.
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
Procedure chk_freeze_status_cd(p_template_id                in number,
                            p_freeze_status_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_freeze_status_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_freeze_status_cd
      <> nvl(pqh_tem_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_freeze_status_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_TEMPLATE_FREEZE_STATUS',
           p_lookup_code    => p_freeze_status_cd,
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
end chk_freeze_status_cd;
--
-- ADDITIONAL CHKS
--
-- ----------------------------------------------------------------------------
-- |------< chk_template_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   template_type__cd Value of lookup code.
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
Procedure chk_template_type_cd(p_template_id                in number,
                            p_template_type_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_template_type_cd';
  l_api_updating boolean;
  l_applied_flag varchar2(10);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_template_type_cd
      <> nvl(pqh_tem_shd.g_old_rec.template_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_template_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_TEMPLATE_TYPE',
           p_lookup_code    => p_template_type_cd,
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
  --
  -- Check if template type can be updated.Should not allow update if the
  -- template was used in any transaction.
  --
  if l_api_updating AND
      nvl(p_template_type_cd,hr_api.g_varchar2)
      <> nvl(pqh_tem_shd.g_old_rec.template_type_cd,hr_api.g_varchar2) then
      --
      l_applied_flag := chk_if_template_applied(p_template_id => p_template_id);
      --
      If l_applied_flag = 'Y' then
         --
         hr_utility.set_message(8302,'PQH_NO_UPD_TEMPLATE_TYPE');
         hr_utility.raise_error;
         --
      End if;
      --
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_template_type_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_master_child_attributes >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if master and all its child
--   attributes have been associated with the template before freezing
--   the template.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   transaction_category FK column
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
--   Internal table handler use and Called within form.
--
Procedure chk_master_child_attributes(p_transaction_category_id  IN number,
                                      p_template_id              IN number) is
--
type master_child is record
          (master_attribute_id pqh_attributes.master_attribute_id%type,
          attribute_id         pqh_attributes.attribute_id%type,
          attribute_name       pqh_attributes.attribute_name%type,
          tat_attribute_id     pqh_template_attributes.attribute_id%type,
          view_flag            pqh_template_attributes.view_flag%type,
          edit_flag            pqh_template_attributes.edit_flag%type);
--
attr_rec master_child;
--
Cursor c1 is
    Select  nvl(att.master_attribute_id,att.attribute_id),
            tca.attribute_id,rtrim(att.attribute_name),nvl(tat.attribute_id,-1),
            nvl(tat.view_flag,'N') , nvl(tat.edit_flag,'N')
    From    pqh_txn_category_attributes tca,pqh_attributes_vl att,
            pqh_template_attributes tat
    Where   tca.transaction_category_id = p_transaction_category_id
      AND   tca.attribute_id   = att.attribute_id
      AND   att.attribute_id   = tat.attribute_id(+)
      AND   tat.template_id(+) = p_template_id
    Order by 1,2;
  --
Cursor csr_master_attr(p_attribute_id in number) is
 Select rtrim(attribute_name)
   from pqh_attributes_vl
  Where attribute_id = p_attribute_id;
  --
  --
  -- Declaring local variables.
  --
  child_attr_list     varchar2(2000) := NULL;
  view_edit_list      varchar2(2000) := NULL;
  --
  view_flag_mismatch    varchar2(1) := 'N';
  edit_flag_mismatch    varchar2(1) := 'N';
  match                 number(5)   :=  0;
  no_match              number(5)   :=  0;
  master_attached       varchar2(1) := 'Y';
  --
  master_id                  pqh_attributes.attribute_id%type := -1;
  l_master_attribute_name    pqh_attributes.attribute_name%type := NULL;
  master_view_flag           pqh_template_attributes.view_flag%type := 'N';
  master_edit_flag           pqh_template_attributes.edit_flag%type := 'N';
  --
  check_reqd_flag    varchar2(1) := 'N';
  --
  l_proc         varchar2(72) := g_package||'chk_master_child_attributes';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    Open c1;
    loop
       --
       Fetch c1 into attr_rec;
       --
       Exit when c1%notfound;
       --
       --
       -- Check if there has been a change in master_attribute_id
       --
       if master_id <> attr_rec.master_attribute_id then
          --
          -- If there has been a change in master attribute id , perform
          -- all the checks for the set of attributes under the previous
          -- master attribute.
          --
          If check_reqd_flag = 'Y' then
           --
           -- Few attributes are attached to the template and the rest are not
           --
           Open csr_master_attr(p_attribute_id => master_id);
           Fetch csr_master_attr into l_master_attribute_name;
           Close csr_master_attr;
           --
           --
           if match > 0 and no_match > 0 then
              --
              If master_attached = 'N' then
                 --
                 hr_utility.set_message(8302,'PQH_ATTACH_MASTER_ATTRIBUTE');
                 hr_utility.set_message_token('ATTRIBUTE_NAME',l_master_attribute_name);
                 hr_utility.raise_error;
                 --
              Else
                 --
                 hr_utility.set_message(8302,'PQH_MISMATCH_MASTER_CHILD_ATTR');
                 hr_utility.set_message_token('CHILD',substr(child_attr_list,1,lengthb(child_attr_list)-1));
                 hr_utility.set_message_token('MASTER',l_master_attribute_name);
                 hr_utility.raise_error;
                 --
              End if; /* If master_attached = 'N'*/
              --
           End if; /* if match > 0 and no_match > 0 */
           --
           If view_flag_mismatch = 'Y' then
             --
             hr_utility.set_message(8302,'PQH_ATTR_VIEW_FLAG_MISMATCH');
             hr_utility.set_message_token('CHILD',substr(view_edit_list,1,lengthb(view_edit_list)-1));
             hr_utility.raise_error;
             --
           end if;
           --
           If edit_flag_mismatch = 'Y' then
             --
             hr_utility.set_message(8302,'PQH_ATTR_EDIT_FLAG_MISMATCH');
             hr_utility.set_message_token('CHILD',substr(view_edit_list,1,lengthb(view_edit_list)-1));
             hr_utility.raise_error;
             --
           end if; /* edit_flag_mismatch = 'Y' */
          --
          End if; /* check_reqd_flag = 'Y'*/
          --
          -- Reset defaults.
          --
          check_reqd_flag       := 'N';
          match                 := 0;
          no_match              := 0;
          view_flag_mismatch    := 'N';
          edit_flag_mismatch    := 'N';
          master_attached       := 'Y';
          child_attr_list     := NULL;
          --
          view_edit_list := attr_rec.attribute_name||',';
          --
          -- The current record has the master for the next set of attributes
          -- and all validations should be made against the master values
          --
          master_id               := attr_rec.master_attribute_id;
          hr_utility.set_location('Master is '||to_char(master_id),101);
          master_view_flag        := attr_rec.view_flag;
          master_edit_flag        := attr_rec.edit_flag;
          --
      Else
          --
          --
          If (nvl(lengthb(attr_rec.attribute_name),0) + nvl(lengthb(view_edit_list),0))
                                                                <= 500 then
             --
             view_edit_list := view_edit_list||attr_rec.attribute_name||',';
             --
          End if;
          --
          --
          hr_utility.set_location('Child is '||to_char(attr_rec.attribute_id),102);
          if master_view_flag <> attr_rec.view_flag then
             --
             view_flag_mismatch := 'Y';
             --
          End if; /* if master_view_flag <> attr_rec.view_flag */
          --
          --
          --
          if master_edit_flag <> attr_rec.edit_flag then
             --
             edit_flag_mismatch := 'Y';
             --
             --
          End if; /*  master_edit_flag <> attr_rec.edit_flag */
          --
       End if; /* if master_id <> attr_rec.master_attribute_id */
       --
       --
       -- Check if the attribute has been added to the template
       --
       if attr_rec.attribute_id = attr_rec.tat_attribute_id then
          --
          hr_utility.set_location('Added Child is '||to_char(attr_rec.tat_attribute_id),103);
          -- attribute has been added to the template
          match := match + 1;
          --
       else
          --
          If attr_rec.attribute_id = attr_rec.master_attribute_id then
             --
             hr_utility.set_location('Not Added Master is '||to_char(attr_rec.master_attribute_id),104);
             -- master attribute has NOT been added to the template
             --
             master_attached := 'N';
             no_match := no_match + 1;
             --
          Else
             --
             -- child attribute has NOT been added to the template
             -- Save the attribute id that has not been attached.
             --
             If (nvl(lengthb(attr_rec.attribute_name),0) + nvl(lengthb(child_attr_list),0))
                                                                <= 500 then
             --
                child_attr_list:=child_attr_list||attr_rec.attribute_name||',';
             --
             hr_utility.set_location('Not Added Child is '||attr_rec.attribute_name,105);
             End if;
             --
             no_match := no_match + 1;
             --
          End if;

       end if; /* attr_rec.attribute_id = attr_rec.tat_attribute_id */
       --
       -- The master attribute id may be from a different transaction category.
       -- Ideally this should not be the case . But if such a case occurs then
       -- we should not perform the master child attributes check.
       --
       if attr_rec.attribute_id = attr_rec.master_attribute_id then
          --
          check_reqd_flag := 'Y' ;
          --
       End if; /* if attr_rec.attribute_id = attr_rec.master_attribute_id */
       --
    End loop;
    --
    -- Repeating validations for the last record
    --
    If check_reqd_flag = 'Y' then
          --
          -- Few attributes are attached to the template and the rest are not
          --
          Open csr_master_attr(p_attribute_id => master_id);
          Fetch csr_master_attr into l_master_attribute_name;
          Close csr_master_attr;
          --
          if match > 0 and no_match > 0 then
             --
             If master_attached = 'N' then
                --
                hr_utility.set_message(8302,'PQH_ATTACH_MASTER_ATTRIBUTE');
                hr_utility.set_message_token('ATTRIBUTE_NAME',l_master_attribute_name);
                hr_utility.raise_error;
                --
             Else
                --
                hr_utility.set_message(8302,'PQH_MISMATCH_MASTER_CHILD_ATTR');
                hr_utility.set_message_token('CHILD',substr(child_attr_list,1,lengthb(child_attr_list)-1));
                hr_utility.set_message_token('MASTER',l_master_attribute_name);
                hr_utility.raise_error;
                --
             End if; /* If master_attached = 'N */
          --
          End if; /* if match > 0 and no_match > 0 */
          --
          If view_flag_mismatch = 'Y' then
          --
             hr_utility.set_message(8302,'PQH_ATTR_VIEW_FLAG_MISMATCH');
             hr_utility.set_message_token('CHILD',substr(view_edit_list,1,lengthb(view_edit_list)-1));
             hr_utility.raise_error;
          --
          End if;
          --
          If edit_flag_mismatch = 'Y' then
          --
             hr_utility.set_message(8302,'PQH_ATTR_EDIT_FLAG_MISMATCH');
             hr_utility.set_message_token('CHILD',substr(view_edit_list,1,lengthb(view_edit_list)-1));
             hr_utility.raise_error;
          --
          End if;
    --
    End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_rout_hist_exist >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if Routing history exists for the template
--   This procedure in turn calls another procedure which would return an
--   error code to signify if any routing history exists or not.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use and Called within form.
--
Procedure chk_rout_hist_exist( p_template_id             IN number) is
--
--
Cursor c1(p_template_id in number) is
    Select null
      from pqh_transaction_templates tt
     Where tt.template_id = p_template_id
       AND tt.transaction_id in (Select ptx.position_transaction_id
                                From pqh_position_transactions ptx
                               Where nvl(ptx.transaction_status,'PENDING') in
                                     ('APPROVED','SUBMITTED','PENDING'));
--
  l_dummy        varchar2(1);
  l_proc         varchar2(72) := g_package||'chk_rout_hist_exist';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c1(p_template_id => p_template_id);
  --
  Fetch c1 into l_dummy;
  --
  If c1%found then
     --
     Close c1;
     hr_utility.set_message(8302,'PQH_TEMPLATE_ROUT_HIST_EXISTS');
     hr_utility.raise_error;
     --
  End if;
  --
  Close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_rout_hist_exist;
--
--
---------------------------------------------------------------------------
--
Procedure chk_attr_or_reference_exists(p_template_id      in number,
                                       p_reference_mode   in varchar2) is
  --
  Cursor csr_attr_exist is
   Select null from pqh_template_attributes
    Where template_id = p_template_id;
  --
  --
  Cursor csr_attr_with_req is
   Select null from pqh_template_attributes
    Where template_id = p_template_id
      AND (view_flag is NOT NULL OR
           edit_flag IS NOT NULL OR
           required_flag IS NOT NULL);
  --
  Cursor csr_copy_exist is
   Select null from pqh_ref_templates
    Where parent_template_id = p_template_id
      and reference_type_cd = 'COPY';
  --
  Cursor csr_ref_exist is
   Select null from pqh_ref_templates
    Where parent_template_id = p_template_id
      and reference_type_cd = 'REFERENCE';
  --
  --
  l_dummy        varchar2(1);
  l_proc         varchar2(72) := g_package||'chk_attr_or_reference_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open csr_attr_exist;
  Fetch csr_attr_exist into l_dummy;
  --
  -- No attributes for the template
  --
  If csr_attr_exist%notfound then
     --
     --  Check if any template was referenced if this is the reference mode.
     --
     If p_reference_mode <> 'Y' then
     --
     Open csr_ref_exist;
     Fetch csr_ref_exist into l_dummy;
     If csr_ref_exist%notfound then
        --
        Close csr_attr_exist;
        Close csr_ref_exist;
        --
        hr_utility.set_message(8302,'PQH_NO_TEMP_ATTR_OR_REF');
        hr_utility.raise_error;
        --
     End if;
     Close csr_ref_exist;
     --
     Else
        --
        -- If copy mode and no attributes exist for template raise error.
        --
        hr_utility.set_message(8302,'PQH_NO_TEMP_ATTR_OR_COPY');
        hr_utility.raise_error;
        --
     /**
     Open csr_copy_exist;
     Fetch csr_copy_exist into l_dummy;
     If csr_copy_exist%notfound then
        --
        Close csr_attr_exist;
        Close csr_copy_exist;
        --
        hr_utility.set_message(8302,'PQH_NO_TEMP_ATTR_OR_COPY');
        hr_utility.raise_error;
        --
     End if;
     Close csr_copy_exist;
     --
     **/
     --
     End if;
     --
  Else
   --
   -- Copy mode
   --
   If p_reference_mode = 'Y' then
     --
     -- Attributes exist , but do not have any requirements setup
     --
     Open csr_attr_with_req;
     Fetch csr_attr_with_req into l_dummy;
     If csr_attr_with_req%notfound then
        --
        Close csr_attr_exist;
        Close csr_attr_with_req;
        --
        hr_utility.set_message(8302,'PQH_NO_TEMP_ATTR_WITH_REQ');
        hr_utility.raise_error;
        --
     End if;
     Close csr_attr_with_req;
     --
   End if;
   --
  End if;
  --
  --
  Close csr_attr_exist;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_attr_or_reference_exists;
--
-- ----------------------------------------------------------------------------
-- |------< chk_invalid_freeze >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure makes validations before a freeze or unfreeze
--   is allowed.This check is needed only on updation of freeze_status_cd
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_id PK of record being inserted or updated.
--   freeze_status_cd Value of lookup code.
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
Procedure chk_invalid_freeze(p_template_id                in number,
                             p_transaction_category_id    in number,
                             p_freeze_status_cd           in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_invalid_freeze';
  l_reference_mode varchar2(10);
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tem_shd.api_updating
    (p_template_id                => p_template_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_freeze_status_cd,hr_api.g_varchar2)
       <> nvl(pqh_tem_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2)
      )  then
    --
    --
      if p_freeze_status_cd = 'FREEZE_TEMPLATE' then
        --
        -- On freeze check  if all master and child attributes are
        -- attached to the template.
        --
        l_reference_mode := NULL;
        l_reference_mode := fnd_profile.value('PQH_DISALLOW_TEMPLATE_REFERENCE');
        --
        chk_attr_or_reference_exists
                  (p_template_id    =>  p_template_id,
                   p_reference_mode =>  nvl(l_reference_mode,'Y'));
        --
        chk_master_child_attributes
                  (p_transaction_category_id => p_transaction_category_id,
                   p_template_id             => p_template_id);
        --
      elsif p_freeze_status_cd IS NULL then
        --
                 chk_rout_hist_exist(
                     p_template_id             => p_template_id);
        --
        --
      end if;
    --
    --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_invalid_freeze;
--
--
-- END ADDITIONAL CHKS
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_tem_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_id
  (p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_template_id              => p_rec.template_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_legislation_code
  (p_template_id              => p_rec.template_id,
   p_legislation_code         => p_rec.legislation_code,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_template_type_cd
  (p_template_id           => p_rec.template_id,
   p_template_type_cd      => p_rec.template_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_create_flag
  (p_template_id          => p_rec.template_id,
   p_create_flag         => p_rec.create_flag,
   p_template_type_cd      => p_rec.template_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_under_review_flag
  (p_template_id          => p_rec.template_id,
   p_create_flag         => p_rec.create_flag,
   p_under_review_flag         => p_rec.under_review_flag,
   p_template_type_cd      => p_rec.template_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_template_id          => p_rec.template_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_only_flag
  (p_template_id          => p_rec.template_id,
   p_attribute_only_flag         => p_rec.attribute_only_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_freeze_status_cd
  (p_template_id           => p_rec.template_id,
   p_freeze_status_cd      => p_rec.freeze_status_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_template_name
  (p_template_id              => p_rec.template_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_template_name            => p_rec.template_name,
   p_object_version_number    => p_rec.object_version_number);
  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_tem_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_id
  (p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tem_dml_allowed
  (p_template_id              => p_rec.template_id,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_tct_upd_allowed
  (p_template_id              => p_rec.template_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_template_id          => p_rec.template_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_legislation_code
  (p_template_id              => p_rec.template_id,
   p_legislation_code         => p_rec.legislation_code,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_template_type_cd
  (p_template_id           => p_rec.template_id,
   p_template_type_cd      => p_rec.template_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_create_flag
  (p_template_id          => p_rec.template_id,
   p_create_flag         => p_rec.create_flag,
   p_template_type_cd      => p_rec.template_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_under_review_flag
  (p_template_id          => p_rec.template_id,
   p_create_flag         => p_rec.create_flag,
   p_under_review_flag         => p_rec.under_review_flag,
   p_template_type_cd      => p_rec.template_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_template_id          => p_rec.template_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_only_flag
  (p_template_id          => p_rec.template_id,
   p_attribute_only_flag         => p_rec.attribute_only_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_freeze_status_cd
  (p_template_id          => p_rec.template_id,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_invalid_freeze
  (p_template_id              => p_rec.template_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_template_name
  (p_template_id              => p_rec.template_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_template_name            => p_rec.template_name,
   p_object_version_number    => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_tem_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_tem_bus;

/
