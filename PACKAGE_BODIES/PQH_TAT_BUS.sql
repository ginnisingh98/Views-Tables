--------------------------------------------------------
--  DDL for Package Body PQH_TAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TAT_BUS" as
/* $Header: pqtatrhi.pkb 120.2 2005/10/12 20:19:38 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tat_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_template_attribute_id >------|
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
--   template_attribute_id PK of record being inserted or updated.
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
Procedure chk_template_attribute_id(p_template_attribute_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_template_attribute_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tat_shd.api_updating
    (p_template_attribute_id                => p_template_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_template_attribute_id,hr_api.g_number)
     <>  pqh_tat_shd.g_old_rec.template_attribute_id) then
    --
    -- raise error as PK has changed
    --
    pqh_tat_shd.constraint_error('PQH_TEMPLATE_ATTRIBUTES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_template_attribute_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_tat_shd.constraint_error('PQH_TEMPLATE_ATTRIBUTES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_template_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_template_id >------|
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
--   p_template_attribute_id PK
--   p_template_id ID of FK column
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
Procedure chk_template_id (p_template_attribute_id          in number,
                            p_template_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_template_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_freeze_status_cd pqh_templates.freeze_status_cd%type;
  --
  cursor c1 is
    select freeze_status_cd
    from   pqh_templates a
    where  a.template_id = p_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tat_shd.api_updating
     (p_template_attribute_id            => p_template_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_template_id,hr_api.g_number)
     <> nvl(pqh_tat_shd.g_old_rec.template_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if template_id value exists in pqh_templates table
    --
    open c1;
      --
--      fetch c1 into l_dummy;
      fetch c1 into l_freeze_status_cd;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_templates
        -- table.
        --
        pqh_tat_shd.constraint_error('PQH_TEMPLATE_ATTRIBUTES_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if l_freeze_status_cd = 'FREEZE_TEMPLATE' then
     hr_utility.set_message(8302,'PQH_INVALID_TAT_OPERATION');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_template_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_attribute_id >------|
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
--   p_template_attribute_id PK
--   p_attribute_id ID of FK column
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
Procedure chk_attribute_id (p_template_attribute_id in number,
                            p_template_id           in number,
                            p_attribute_id          in number,
                            p_object_version_number in number) is
  --
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_enable_flag  pqh_attributes.enable_flag%type;
  l_attribute_name pqh_attributes_vl.attribute_name%type;
  --
  cursor c1 is
    select nvl(enable_flag,'N')
    from   pqh_attributes a
    where  a.attribute_id = p_attribute_id;
  --
  Cursor c2 is
    select att.attribute_name
      from pqh_attributes_vl att,pqh_template_attributes tat
     where tat.attribute_id = p_attribute_id
       and tat.template_id = p_template_id
       and tat.attribute_id = att.attribute_id;
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tat_shd.api_updating
     (p_template_attribute_id            => p_template_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_attribute_id,hr_api.g_number)
     <> nvl(pqh_tat_shd.g_old_rec.attribute_id,hr_api.g_number)
     or not l_api_updating) then
     --
     -- check if attribute_id value exists in pqh_attributes table
     --
     open c1;
     --
     fetch c1 into l_enable_flag;
     if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_attributes
        -- table.
        --
        pqh_tat_shd.constraint_error('PQH_TEMPLATE_ATTRIBUTES_FK1');
        --
      end if;
      --
      close c1;
      --
      --
      -- When trying to insert a template attribute or when modifying the
      -- attribute id, check if the is enabled.
      -- Cannot add a attribute that is not enabled to a template.
      --
      If l_enable_flag <> 'Y' then
         hr_utility.set_message(8302,'PQH_ATTRIBUTE_NOT_ENABLED');
         hr_utility.raise_error;
      End if;
      --
      -- When trying to insert a template attribute or when modifying the
      -- the attribute id , check if that attribute is not already attached
      -- to the template.
      --
      Open c2;
      Fetch c2 into l_attribute_name;
      If c2%found then
         --
         -- Should not allow same attribute to be added twice to the template.
         --
         hr_utility.set_message(8302,'PQH_ATTR_ATTACHED_TO_TEM');
         hr_utility.set_message_token('ATTRIBUTE', l_attribute_name);
         hr_utility.raise_error;
         --
      End if;
      Close c2;
      --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_att_tct >------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks  if the template and attribute have the same
--   transaction category id.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_template_attribute_id PK
--   p_template_id ID of FK column
--   p_attribute_id ID of FK column
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
Procedure chk_att_tct (p_template_attribute_id          in number,
                       p_template_id                    in number,
                       p_attribute_id          in number,
                       p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_att_tct';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_tem_tct      pqh_templates.transaction_category_id%type;
  l_select_flag  pqh_txn_category_attributes.select_flag%type;
  --
  cursor c1 is
    select transaction_category_id
    from   pqh_templates a
    where  a.template_id = p_template_id;
  --
  cursor c2 is
    select nvl(tca.select_flag,'N')
    from   pqh_attributes att , pqh_txn_category_attributes tca
    where  att.attribute_id = p_attribute_id
      AND  att.attribute_id = tca.attribute_id
      AND  tca.transaction_category_id = l_tem_tct;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tat_shd.api_updating
     (p_template_attribute_id   => p_template_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  /**
  if (l_api_updating
     and nvl(p_attribute_id,hr_api.g_number)
     <> nvl(pqh_tat_shd.g_old_rec.attribute_id,hr_api.g_number)
     or not l_api_updating) then
     **/
    --
    --
    open c1;
    fetch c1 into l_tem_tct;
    close c1;
    --
    open c2;
    fetch c2 into l_select_flag;
    --
    If c2%notfound then
       Close c2;
       hr_utility.set_message(8302,'PQH_TEM_ATTR_TCT_MISMATCH');
       hr_utility.raise_error;
    End if;
    --
    close c2;
    --
    -- Cannot add an attribute that is not selectable , to a template
    --
    If l_select_flag <> 'Y' then
       hr_utility.set_message(8302,'PQH_ATTRIBUTE_NOT_SELECTABLE');
       hr_utility.raise_error;
    End if;
    --
  --

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_att_tct;
--
-- Verifies that the template and attribute Legislations are compatible
--
Procedure chk_legislation_code (p_template_attribute_id          in number,
                            p_template_id          in number,
                            p_attribute_id          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_legislation_code';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_template_leg_code varchar2(30);
  l_template_name varchar2(100);
  l_attribute_leg_code varchar2(30);
  l_attribute_name varchar2(100);
  --
  cursor c_template_leg_code is
   select legislation_code, template_name
   from pqh_templates_vl
   where template_id = p_template_id;
  --
  cursor c_attribute_leg_code is
   select legislation_code, attribute_name
   from pqh_attributes_vl
   where attribute_id = p_attribute_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  l_api_updating := pqh_tat_shd.api_updating
     (p_template_attribute_id            => p_template_attribute_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_attribute_id,hr_api.g_number)
     <> nvl(pqh_tat_shd.g_old_rec.attribute_id,hr_api.g_number)
     or not l_api_updating) then
     --
     open c_template_leg_code;
     fetch c_template_leg_code into l_template_leg_code, l_template_name;
     close c_template_leg_code;
     open c_attribute_leg_code;
     fetch c_attribute_leg_code into l_attribute_leg_code, l_attribute_name;
     close c_attribute_leg_code;
     --
     if l_template_leg_code is null then
       if l_attribute_leg_code is not null then
        hr_utility.set_message(8302,'PQH_NO_LEG_TEM_ATT');
        hr_utility.set_message_token('TEMPLATE', l_template_name);
        hr_utility.set_message_token('ATTRIBUTE', l_attribute_name);
        hr_utility.raise_error;
       end if;
     else
       if nvl(l_attribute_leg_code,l_template_leg_code)  <> l_template_leg_code then
        hr_utility.set_message(8302,'PQH_TEM_ATT_LEG_NE_TEM');
        hr_utility.set_message_token('TEMPLATE', l_template_name);
        hr_utility.set_message_token('ATTRIBUTE', l_attribute_name);
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
-- ----------------------------------------------------------------------------
-- |------< chk_edit_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_attribute_id PK of record being inserted or updated.
--   edit_flag Value of lookup code.
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
Procedure chk_edit_flag(p_template_attribute_id                in number,
                            p_edit_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_edit_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tat_shd.api_updating
    (p_template_attribute_id                => p_template_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_edit_flag
      <> nvl(pqh_tat_shd.g_old_rec.edit_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_edit_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_edit_flag,
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
end chk_edit_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_view_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_attribute_id PK of record being inserted or updated.
--   view_flag Value of lookup code.
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
Procedure chk_view_flag(p_template_attribute_id                in number,
                            p_view_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_view_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tat_shd.api_updating
    (p_template_attribute_id                => p_template_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_view_flag
      <> nvl(pqh_tat_shd.g_old_rec.view_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_view_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_view_flag,
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
end chk_view_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_required_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   template_attribute_id PK of record being inserted or updated.
--   required_flag Value of lookup code.
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
Procedure chk_required_flag(p_template_attribute_id                in number,
                            p_required_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_required_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tat_shd.api_updating
    (p_template_attribute_id                => p_template_attribute_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_required_flag
      <> nvl(pqh_tat_shd.g_old_rec.required_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_required_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_required_flag,
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
end chk_required_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_flags_mismatch >------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks  if there is any mismatch in the value of
--   view , edit and Required flags.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_template_attribute_id PK
--   p_view_flag       View Flag
--   p_edit_flag       Edit Flag
--   p_Required_flag   Required Flag
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
Procedure chk_flags_mismatch (p_template_attribute_id          in number,
                              p_view_flag                      in varchar2,
                              p_edit_flag                      in varchar2,
                              p_required_flag                  in varchar2,
                              p_object_version_number          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_flags_mismatch';
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if p_required_flag = 'Y' then
     if p_edit_flag = 'Y' then
        if p_view_flag = 'Y' then
           null;
        else
           hr_utility.set_message(8302,'PQH_VIEW_EDIT_MISMATCH');
           hr_utility.raise_error;
        end if;
     else
       hr_utility.set_message(8302,'PQH_EDIT_REQD_MISMATCH');
       hr_utility.raise_error;
     end if;
  end if;
  --
  if p_view_flag = 'N' then
     if p_edit_flag = 'N' then
        if p_required_flag = 'N' then
           null;
        else
           hr_utility.set_message(8302,'PQH_EDIT_REQD_MISMATCH');
           hr_utility.raise_error;
        end if;
     else
       hr_utility.set_message(8302,'PQH_VIEW_EDIT_MISMATCH');
       hr_utility.raise_error;
     end if;
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_flags_mismatch;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_tat_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_attribute_id
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_template_id
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_id
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id          => p_rec.template_id,
   p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_att_tct
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id                    => p_rec.template_id,
   p_attribute_id                   => p_rec.attribute_id,
   p_object_version_number          => p_rec.object_version_number);
  --
  chk_legislation_code
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id                    => p_rec.template_id,
   p_attribute_id                   => p_rec.attribute_id,
   p_object_version_number          => p_rec.object_version_number);
  --
  chk_edit_flag
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_edit_flag         => p_rec.edit_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_view_flag
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_view_flag         => p_rec.view_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_required_flag
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_required_flag         => p_rec.required_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_flags_mismatch
  (p_template_attribute_id => p_rec.template_attribute_id,
   p_view_flag             => p_rec.view_flag,
   p_edit_flag             => p_rec.edit_flag,
   p_required_flag         => p_rec.required_flag,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_tat_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_attribute_id
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_template_id
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_id
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id          => p_rec.template_id,
   p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_att_tct
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id                    => p_rec.template_id,
   p_attribute_id                   => p_rec.attribute_id,
   p_object_version_number          => p_rec.object_version_number);
  --
  chk_legislation_code
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_template_id                    => p_rec.template_id,
   p_attribute_id                   => p_rec.attribute_id,
   p_object_version_number          => p_rec.object_version_number);
  --
  chk_edit_flag
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_edit_flag         => p_rec.edit_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_view_flag
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_view_flag         => p_rec.view_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_required_flag
  (p_template_attribute_id          => p_rec.template_attribute_id,
   p_required_flag         => p_rec.required_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_flags_mismatch
  (p_template_attribute_id => p_rec.template_attribute_id,
   p_view_flag             => p_rec.view_flag,
   p_edit_flag             => p_rec.edit_flag,
   p_required_flag         => p_rec.required_flag,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_tat_shd.g_rec_type
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
--
Procedure fetch_attribute_name(
          p_attribute_id     in pqh_attributes.attribute_id%type,
          p_attribute_name  out nocopy pqh_attributes.attribute_name%type) is
--
 Cursor csr_attr_name is
  Select attribute_name
    From pqh_attributes
   Where attribute_id = p_attribute_id;
--
  l_proc  varchar2(72) := g_package||'fetch_attribute_name';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_attribute_name := NULL;
  --
  Open csr_attr_name;
  --
  Fetch csr_attr_name into p_attribute_name;
  --
  Close csr_attr_name;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End fetch_attribute_name;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< populate_attribute_name >----------------------------|
-- ----------------------------------------------------------------------------
Procedure populate_attribute_name(
          p_attr_table       in pqh_prvcalc.t_attid_priv,
          p_attr_name_table out nocopy pqh_prvcalc.t_attname_priv) is
--
  l_attribute_name     pqh_attributes.attribute_name%type;
  l_mode_flag          pqh_template_attributes.view_flag%type;
  l_reqd_flag          pqh_template_attributes.required_flag%type;
  --
  l_proc  varchar2(72) := g_package||'populate_attribute_name';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_attr_table.count > 0 then
    --
    For cnt in p_attr_table.FIRST .. p_attr_table.LAST loop
     --
     fetch_attribute_name(p_attribute_id   => p_attr_table(cnt).attribute_id,
                          p_attribute_name => l_attribute_name);
     --
     p_attr_name_table(cnt).form_column_name := l_attribute_name;
     p_attr_name_table(cnt).mode_flag := p_attr_table(cnt).mode_flag;
     p_attr_name_table(cnt).reqd_flag := p_attr_table(cnt).reqd_flag;
     --
    End loop;
    --
  End if;
  --
  -- Sort the table by attribute name .
  --
  For cnt in 1..p_attr_name_table.COUNT loop

     For j in 1..p_attr_name_table.COUNT-1 loop
         --
         If p_attr_name_table(j).form_column_name >
            p_attr_name_table(j+1).form_column_name then

            l_attribute_name := p_attr_name_table(j).form_column_name;
            l_mode_flag      := p_attr_name_table(j).mode_flag;
            l_reqd_flag      := p_attr_name_table(j).reqd_flag;

            p_attr_name_table(j).form_column_name := p_attr_name_table(j+1).form_column_name;
            p_attr_name_table(j).mode_flag := p_attr_name_table(j+1).mode_flag;
            p_attr_name_table(j).reqd_flag := p_attr_name_table(j+1).reqd_flag;

            p_attr_name_table(j+1).form_column_name := l_attribute_name;
            p_attr_name_table(j+1).mode_flag := l_mode_flag;
            p_attr_name_table(j+1).reqd_flag := l_reqd_flag;

         End if;

     End loop;

  End loop;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End populate_attribute_name;
--
end pqh_tat_bus;

/
