--------------------------------------------------------
--  DDL for Package Body PQH_FYN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FYN_BUS" as
/* $Header: pqfynrhi.pkb 115.6 2002/12/06 18:06:27 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_fyn_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_fyi_notified_id >------|
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
--   fyi_notified_id PK of record being inserted or updated.
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
Procedure chk_fyi_notified_id(p_fyi_notified_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_fyi_notified_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_fyn_shd.api_updating
    (p_fyi_notified_id                => p_fyi_notified_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_fyi_notified_id,hr_api.g_number)
     <>  pqh_fyn_shd.g_old_rec.fyi_notified_id) then
    --
    -- raise error as PK has changed
    --
    pqh_fyn_shd.constraint_error('PQH_FYI_NOTIFY_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_fyi_notified_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_fyn_shd.constraint_error('PQH_FYI_NOTIFY_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_fyi_notified_id;
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
--   p_fyi_notified_id PK
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
Procedure chk_transaction_category_id (p_fyi_notified_id          in number,
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
  l_api_updating := pqh_fyn_shd.api_updating
     (p_fyi_notified_id            => p_fyi_notified_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_fyn_shd.g_old_rec.transaction_category_id,hr_api.g_number)
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
        pqh_fyn_shd.constraint_error('PQH_FYI_NOTIFY_FK1');
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
-- |------< chk_notified_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   fyi_notified_id PK of record being inserted or updated.
--   notified_type_cd Value of lookup code.
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
Procedure chk_notified_type_cd(p_fyi_notified_id                in number,
                            p_notified_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_notified_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_fyn_shd.api_updating
    (p_fyi_notified_id                => p_fyi_notified_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_notified_type_cd
      <> nvl(pqh_fyn_shd.g_old_rec.notified_type_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
  hr_utility.set_location('Type Cd: '||p_notified_type_cd, 10);
     --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_NOTIFIED_TYPE_CD',
           p_lookup_code    => p_notified_type_cd,
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
end chk_notified_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_notification_event_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   fyi_notified_id PK of record being inserted or updated.
--   notification_event_cd Value of lookup code.
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
Procedure chk_notification_event_cd(p_fyi_notified_id                in number,
                            p_notification_event_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_notification_event_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_fyn_shd.api_updating
    (p_fyi_notified_id                => p_fyi_notified_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_notification_event_cd
      <> nvl(pqh_fyn_shd.g_old_rec.notification_event_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_NOTIFICATION_EVENT_CD',
           p_lookup_code    => p_notification_event_cd,
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
end chk_notification_event_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_notified_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   fyi_notified_id PK of record being inserted or updated.
--   notification_event_cd Value of lookup code.
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
Procedure chk_notified_name(p_fyi_notified_id                in number,
                            p_notified_name               in varchar2,
                            p_notified_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_notified_name';
  l_api_updating boolean;
  l_dummy  varchar2(1);
 --
  cursor c1 is
    select null
    from   wf_roles r
    where  r.name = p_notified_name;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_notified_type_cd = 'OTHERS' THEN

    --
    -- check if notified_name exists in wf_roles table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        hr_utility.set_message(8302,'PQH_INVALID_NOTIFIED_NAME');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --

  else

   --
   -- notified_name should be null if p_notified_type_cd <> OTHERS
   --
     if p_notified_name is not null then
        --
        -- raise error
        --
        hr_utility.set_message(8302,'PQH_INVALID_NOTIFIED_NAME');
        hr_utility.raise_error;
        --

     end if;

  end if;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_notified_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_fyn_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_fyi_notified_id
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_notified_type_cd
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_notified_type_cd         => p_rec.notified_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_notification_event_cd
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_notification_event_cd         => p_rec.notification_event_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_notified_name
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_notified_name            => p_rec.notified_name,
   p_notified_type_cd         => p_rec.notified_type_cd,
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
Procedure update_validate(p_rec in pqh_fyn_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_fyi_notified_id
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_notified_type_cd
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_notified_type_cd         => p_rec.notified_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_notification_event_cd
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_notification_event_cd         => p_rec.notification_event_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_notified_name
  (p_fyi_notified_id          => p_rec.fyi_notified_id,
   p_notified_name            => p_rec.notified_name,
   p_notified_type_cd         => p_rec.notified_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_fyn_shd.g_rec_type
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
end pqh_fyn_bus;

/
