--------------------------------------------------------
--  DDL for Package Body GHR_EVH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_EVH_BUS" as
/* $Header: ghevhrhi.pkb 120.0.12010000.3 2009/05/27 05:37:26 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_evh_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_event_history_id >------|
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
--   event_history_id PK of record being inserted or updated.
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
Procedure chk_event_history_id(p_event_history_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_event_history_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_evh_shd.api_updating
    (p_event_history_id                => p_event_history_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_event_history_id,hr_api.g_number)
     <>  ghr_evh_shd.g_old_rec.event_history_id) then
    --
    -- raise error as PK has changed
    --
    ghr_evh_shd.constraint_error('GHR_EVENT_HISTORY_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_event_history_id is not null then
      --
      -- raise error as PK is not null
      --
      ghr_evh_shd.constraint_error('GHR_EVENT_HISTORY_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_event_history_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_event_id >------|
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
--   p_event_history_id PK
--   p_event_id ID of FK column
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
Procedure chk_event_id (p_event_history_id          in number,
                            p_event_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_event_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ghr_events a
    where  a.event_id = p_event_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ghr_evh_shd.api_updating
     (p_event_history_id            => p_event_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_event_id,hr_api.g_number)
     <> nvl(ghr_evh_shd.g_old_rec.event_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if event_id value exists in ghr_events table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ghr_events
        -- table.
        --
        ghr_evh_shd.constraint_error('GHR_EVENT_HISTORY_FK');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_event_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_evh_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_event_history_id
  (p_event_history_id          => p_rec.event_history_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_event_id
  (p_event_history_id          => p_rec.event_history_id,
   p_event_id          => p_rec.event_id,
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
Procedure update_validate(p_rec in ghr_evh_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_event_history_id
  (p_event_history_id          => p_rec.event_history_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_event_id
  (p_event_history_id          => p_rec.event_history_id,
   p_event_id          => p_rec.event_id,
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
Procedure delete_validate(p_rec in ghr_evh_shd.g_rec_type) is
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
end ghr_evh_bus;

/
