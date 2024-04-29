--------------------------------------------------------
--  DDL for Package Body PQH_RTM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RTM_BUS" as
/* $Header: pqrtmrhi.pkb 120.2 2006/01/05 15:29:54 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rtm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_role_template_id >------|
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
--   role_template_id PK of record being inserted or updated.
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
Procedure chk_role_template_id(p_role_template_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_template_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
    (p_role_template_id                => p_role_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_role_template_id,hr_api.g_number)
     <>  pqh_rtm_shd.g_old_rec.role_template_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rtm_shd.constraint_error('RTM_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_role_template_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rtm_shd.constraint_error('RTM_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_role_template_id;
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
--   p_role_template_id PK
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
Procedure chk_template_id (p_role_template_id          in number,
                            p_template_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_template_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_templates a
    where  a.template_id = p_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
     (p_role_template_id            => p_role_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_template_id,hr_api.g_number)
     <> nvl(pqh_rtm_shd.g_old_rec.template_id,hr_api.g_number)
     or not l_api_updating) and
     p_template_id is not null then
    --
    -- check if template_id value exists in pqh_templates table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_templates
        -- table.
        --
        pqh_rtm_shd.constraint_error('PQH_ROLE_TEMPLATES_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_template_id;
--
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
--   p_role_template_id PK
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
Procedure chk_transaction_category_id (p_role_template_id          in number,
                            p_transaction_category_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_category_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_transaction_categories a
    where  a.transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
     (p_role_template_id            => p_role_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_rtm_shd.g_old_rec.transaction_category_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if transaction_category_id value exists in pqh_transaction_categories table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_transaction_categories
        -- table.
        --
        pqh_rtm_shd.constraint_error('PQH_ROLE_TEMPLATES_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_category_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_role_id >------|
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
--   p_role_template_id PK
--   p_role_id ID of FK column
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
Procedure chk_role_id (p_role_template_id          in number,
                            p_role_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_roles a
    where  a.role_id = p_role_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
     (p_role_template_id            => p_role_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_role_id,hr_api.g_number)
     <> nvl(pqh_rtm_shd.g_old_rec.role_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if role_id value exists in pqh_roles table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_roles
        -- table.
        --
        pqh_rtm_shd.constraint_error('PQH_ROLE_TEMPLATES_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_role_id;
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
--   role_template_id PK of record being inserted or updated.
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
Procedure chk_enable_flag(p_role_template_id              in number,
			    p_role_id in number,
                            p_enable_flag                 in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  l_role_enable_flag  varchar2(10);
  --
  cursor c_role_enable_flag(p_role_id number) is
  select enable_flag
  from pqh_roles
  where role_id=p_role_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
    (p_role_template_id                => p_role_template_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_rtm_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enable_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(8302,'PQH_ENABLE_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
      if p_enable_flag = 'Y' then
        open c_role_enable_flag(p_role_id);
        fetch c_role_enable_flag into l_role_enable_flag;
        close c_role_enable_flag;
        if nvl(l_role_enable_flag,'N') = 'N' then
          hr_utility.set_message(8302,'PQH_ROLE_DIS_CANT_ENABLE_RTM');
          hr_utility.raise_error;
        end if;
      end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enable_flag;
--
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_for_pending_txns >---------------------------|
-- ---------------------------------------------------------------------------
--
--
Function chk_for_pending_txns(p_role_id 	in number,
                              p_txn_cat         out nocopy varchar2,
                              p_bg              out nocopy varchar2)
return varchar2
is
  --
  l_proc         varchar2(72) := g_package||'chk_for_pending_txns';
  l_api_updating boolean;
  l_bus_grp_name varchar2(240);
  --
  cursor c_txn_cats(p_role_id number) is
  select distinct ptc.transaction_category_id, ptc.name transaction_category,
         ptc.business_group_id
  from pqh_routing_list_members rlm, pqh_routing_categories rct,
       pqh_transaction_categories ptc
  where rlm.routing_list_id =  rct.routing_list_id
  and rlm.role_id = p_role_id
  and rct.transaction_category_id=ptc.transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    for r_txn_cat in c_txn_cats(p_role_id)
    loop
      --
      if nvl(pqh_tct_bus.chk_active_transaction_exists(r_txn_cat.transaction_category_id),'N')
            = 'Y' then
         --
         p_txn_cat :=  r_txn_cat.transaction_category;
         if (r_txn_cat.business_group_id is not null) then
           l_bus_grp_name := hr_general.DECODE_ORGANIZATION(r_txn_cat.business_group_id);
         else
           l_bus_grp_name := hr_general.decode_lookup('PQH_TCT_SCOPE', 'GLOBAL');
         end if;
         --
         p_bg := l_bus_grp_name;
         --
         return 'Y';
      end if;
      --
    end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  return 'N';
end chk_for_pending_txns;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_category_template_id >------|
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
--   p_role_template_id PK
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
Procedure chk_category_template_id (p_role_template_id          in number,
                            p_transaction_category_id          in number,
                            p_template_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_category_template_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_templates a
    where  a.transaction_category_id=p_transaction_category_id
	   and a.template_id = p_template_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
     (p_role_template_id            => p_role_template_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_rtm_shd.g_old_rec.transaction_category_id,hr_api.g_number)
     or nvl(p_template_id,hr_api.g_number)
     <> nvl(pqh_rtm_shd.g_old_rec.template_id,hr_api.g_number) )
     or not l_api_updating) and
      (p_transaction_category_id is not null
     or  p_template_id is not null) then
    --
    -- check if transaction_category_id and template_id value exists in pqh_templates table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_templates
        -- table.
        --
        pqh_rtm_shd.constraint_error('RTM_TCT_TEM_FK');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_category_template_id;
--
--
----------------------------------------------------------------------------
-- |------< chk_non_updateable_args >------|
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
--   p_rec     pqh_rtm_asd.g_rec_type
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
Procedure chk_non_updateable_args (p_rec  in pqh_rtm_shd.g_rec_type ) is
  --
  l_proc         varchar2(72) := g_package||'chk_non_updateable_args';
  l_api_updating boolean;
  l_error	 exception;
  l_argument     varchar2(30);
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rtm_shd.api_updating
     (p_role_template_id            => p_rec.role_template_id,
      p_object_version_number   => p_rec.object_version_number);
  --
  if (not l_api_updating ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message('PROCEDURE', l_proc);
    hr_utility.set_message('STEP', '10');
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);

  if nvl(p_rec.transaction_category_id,hr_api.g_number) <>
     nvl(pqh_rtm_shd.g_old_rec.transaction_category_id,hr_api.g_number) then
     l_argument := 'transaction_category_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc,30);
exception
  when l_error then
     hr_api.argument_changed_error
        (p_api_name => l_proc
        ,p_argument => l_argument
        );
  when others then
     raise;
     hr_utility.set_location(' Leaving:'||l_proc,50);
  --
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rtm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_role_template_id
  (p_role_template_id          => p_rec.role_template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_template_id
  (p_role_template_id          => p_rec.role_template_id,
   p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_role_template_id          => p_rec.role_template_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_category_template_id
  (p_role_template_id          => p_rec.role_template_id,
   p_transaction_category_id   => p_rec.transaction_category_id,
   p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_role_id
  (p_role_template_id          => p_rec.role_template_id,
   p_role_id          => p_rec.role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_role_template_id          => p_rec.role_template_id,
   p_role_id			=> p_rec.role_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rtm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  chk_role_template_id
  (p_role_template_id          => p_rec.role_template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_template_id
  (p_role_template_id          => p_rec.role_template_id,
   p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_role_template_id          => p_rec.role_template_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_category_template_id
  (p_role_template_id          => p_rec.role_template_id,
   p_transaction_category_id   => p_rec.transaction_category_id,
   p_template_id          => p_rec.template_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_role_id
  (p_role_template_id          => p_rec.role_template_id,
   p_role_id          => p_rec.role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_role_template_id          => p_rec.role_template_id,
   p_role_id			=> p_rec.role_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rtm_shd.g_rec_type
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
end pqh_rtm_bus;

/
