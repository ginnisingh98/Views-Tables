--------------------------------------------------------
--  DDL for Package Body BEN_BMN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BMN_BUS" as
/* $Header: bebmnrhi.pkb 115.7 2002/12/09 12:40:49 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bmn_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_reporting_id >--------------------------|
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
--   reporting_id PK of record being inserted or updated.
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
Procedure chk_reporting_id(p_reporting_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reporting_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bmn_shd.api_updating
    (p_reporting_id                => p_reporting_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_reporting_id,hr_api.g_number)
     <>  ben_bmn_shd.g_old_rec.reporting_id) then
    --
    -- raise error as PK has changed
    --
    ben_bmn_shd.constraint_error('BEN_REPORTING_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_reporting_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bmn_shd.constraint_error('BEN_REPORTING_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_reporting_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_benefit_action_id >--------------------|
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
--   p_reporting_id PK
--   p_benefit_action_id ID of FK column
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
Procedure chk_benefit_action_id (p_reporting_id          in number,
                                 p_benefit_action_id     in number,
                                 p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_benefit_action_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_benefit_actions a
    where  a.benefit_action_id = p_benefit_action_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_bmn_shd.api_updating
     (p_reporting_id            => p_reporting_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_benefit_action_id,hr_api.g_number)
     <> nvl(ben_bmn_shd.g_old_rec.benefit_action_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if benefit_action_id value exists in ben_benefit_actions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_benefit_actions
        -- table.
        --
        ben_bmn_shd.constraint_error('BEN_REPORTING_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_benefit_action_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_rep_typ_cd >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   rep_typ_cd Value of lookup code.
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
Procedure chk_rep_typ_cd(p_reporting_id            in number,
                         p_rep_typ_cd              in varchar2,
                         p_effective_date          in date,
                         p_object_version_number   in number) is
  --
  l_proc           varchar2(72) := g_package||'chk_rep_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bmn_shd.api_updating
    (p_reporting_id                => p_reporting_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rep_typ_cd
      <> nvl(ben_bmn_shd.g_old_rec.rep_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REP_TYP',
           p_lookup_code    => p_rep_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rep_typ_cd');
      fnd_message.set_token('TYPE','BEN_REP_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rep_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bmn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  chk_reporting_id
  (p_reporting_id          => p_rec.reporting_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_benefit_action_id
  (p_reporting_id          => p_rec.reporting_id,
   p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_rep_typ_cd
  (p_reporting_id          => p_rec.reporting_id,
   p_rep_typ_cd            => p_rec.rep_typ_cd,
   p_effective_date        => p_rec.effective_date,
   p_object_version_number => p_rec.object_verison_number);
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bmn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  chk_reporting_id
  (p_reporting_id          => p_rec.reporting_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_benefit_action_id
  (p_reporting_id          => p_rec.reporting_id,
   p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_rep_typ_cd
  (p_reporting_id          => p_rec.reporting_id,
   p_rep_typ_cd            => p_rec.rep_typ_cd,
   p_effective_date        => p_rec.effective_date,
   p_object_version_number => p_rec.object_verison_number);
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bmn_shd.g_rec_type) is
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
end ben_bmn_bus;

/
