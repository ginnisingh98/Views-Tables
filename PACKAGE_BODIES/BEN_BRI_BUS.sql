--------------------------------------------------------
--  DDL for Package Body BEN_BRI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BRI_BUS" as
/* $Header: bebrirhi.pkb 120.0 2005/05/28 00:51:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bri_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_batch_rt_id >-------------------------|
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
--   batch_rt_id PK of record being inserted or updated.
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
Procedure chk_batch_rt_id(p_batch_rt_id                in number,
                          p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bri_shd.api_updating
    (p_batch_rt_id                => p_batch_rt_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_batch_rt_id,hr_api.g_number)
     <>  ben_bri_shd.g_old_rec.batch_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_batch_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_batch_rt_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_oipl_id >------------------------------|
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
--   p_batch_rt_id PK
--   p_oipl_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_oipl_id (p_batch_rt_id           in number,
                       p_oipl_id               in number,
                       p_effective_date        in date,
                       p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oipl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oipl_f a
    where  a.oipl_id = p_oipl_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_bri_shd.api_updating
     (p_batch_rt_id            => p_batch_rt_id,
      p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_oipl_id,hr_api.g_number)
     <> nvl(ben_bri_shd.g_old_rec.oipl_id,hr_api.g_number)
     or not l_api_updating) and
     p_oipl_id is not null then
    --
    -- check if oipl_id value exists in ben_oipl_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_oipl_f
        -- table.
        --
        ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_DT4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_oipl_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_pl_id >------------------------------|
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
--   p_batch_rt_id PK
--   p_pl_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_pl_id (p_batch_rt_id           in number,
                     p_pl_id                 in number,
                     p_effective_date        in date,
                     p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f a
    where  a.pl_id = p_pl_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_bri_shd.api_updating
     (p_batch_rt_id            => p_batch_rt_id,
      p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_id,hr_api.g_number)
     <> nvl(ben_bri_shd.g_old_rec.pl_id,hr_api.g_number)
     or not l_api_updating) and
     p_pl_id is not null then
    --
    -- check if pl_id value exists in ben_pl_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pl_f
        -- table.
        --
        ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_DT3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_pgm_id >----------------------------|
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
--   p_batch_rt_id PK
--   p_pgm_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_pgm_id (p_batch_rt_id           in number,
                      p_pgm_id                in number,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pgm_f a
    where  a.pgm_id = p_pgm_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_bri_shd.api_updating
     (p_batch_rt_id            => p_batch_rt_id,
      p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pgm_id,hr_api.g_number)
     <> nvl(ben_bri_shd.g_old_rec.pgm_id,hr_api.g_number)
     or not l_api_updating) and
     p_pgm_id is not null then
    --
    -- check if pgm_id value exists in ben_pgm_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pgm_f
        -- table.
        --
        ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pgm_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_person_id >-----------------------------|
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
--   p_batch_rt_id PK
--   p_person_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_person_id (p_batch_rt_id           in number,
                         p_person_id             in number,
                         p_effective_date        in date,
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_person_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_bri_shd.api_updating
     (p_batch_rt_id            => p_batch_rt_id,
      p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_bri_shd.g_old_rec.person_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people_f
        -- table.
        --
        ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_benefit_action_id >-------------------------|
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
--   p_batch_rt_id PK
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
Procedure chk_benefit_action_id (p_batch_rt_id           in number,
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
  l_api_updating := ben_bri_shd.api_updating
     (p_batch_rt_id            => p_batch_rt_id,
      p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_benefit_action_id,hr_api.g_number)
     <> nvl(ben_bri_shd.g_old_rec.benefit_action_id,hr_api.g_number)
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
        ben_bri_shd.constraint_error('BEN_BATCH_RATE_INFO_FK1');
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
-- |----------------------------< chk_acty_typ_cd >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_rt_id PK of record being inserted or updated.
--   acty_typ_cd Value of lookup code.
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
Procedure chk_acty_typ_cd(p_batch_rt_id               in number,
                          p_acty_typ_cd               in varchar2,
                          p_effective_date            in date,
                          p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bri_shd.api_updating
    (p_batch_rt_id                => p_batch_rt_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_typ_cd
      <> nvl(ben_bri_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_TYP',
           p_lookup_code    => p_acty_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_acty_typ_cd');
      fnd_message.set_token('TYPE','BEN_ACTY_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_tx_typ_cd >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_rt_id PK of record being inserted or updated.
--   tx_typ_cd Value of lookup code.
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
Procedure chk_tx_typ_cd(p_batch_rt_id             in number,
                        p_tx_typ_cd               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tx_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bri_shd.api_updating
    (p_batch_rt_id                => p_batch_rt_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_tx_typ_cd
      <> nvl(ben_bri_shd.g_old_rec.tx_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tx_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TX_TYP',
           p_lookup_code    => p_tx_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_tx_typ_cd');
      fnd_message.set_token('TYPE','BEN_TX_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tx_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dflt_flag >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_rt_id PK of record being inserted or updated.
--   dflt_flag Value of lookup code.
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
Procedure chk_dflt_flag(p_batch_rt_id             in number,
                        p_dflt_flag               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bri_shd.api_updating
    (p_batch_rt_id                => p_batch_rt_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_bri_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dflt_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_bnft_rt_typ_cd >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_rt_id PK of record being inserted or updated.
--   bnft_rt_typ_cd Value of lookup code.
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
Procedure chk_bnft_rt_typ_cd(p_batch_rt_id                in number,
                             p_bnft_rt_typ_cd             in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_rt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bri_shd.api_updating
    (p_batch_rt_id                => p_batch_rt_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_rt_typ_cd
      <> nvl(ben_bri_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNFT_RT_TYP',
           p_lookup_code    => p_bnft_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bnft_rt_typ_cd');
      fnd_message.set_token('TYPE','BEN_BNFT_RT_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bnft_rt_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bri_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_batch_rt_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oipl_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_oipl_id               => p_rec.oipl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_pl_id                 => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_pgm_id                => p_rec.pgm_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_benefit_action_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_typ_cd
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_acty_typ_cd           => p_rec.acty_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tx_typ_cd
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_tx_typ_cd             => p_rec.tx_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_dflt_flag             => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_rt_typ_cd
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_bnft_rt_typ_cd        => p_rec.bnft_rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bri_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_batch_rt_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oipl_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_oipl_id               => p_rec.oipl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_pl_id                 => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_pgm_id                => p_rec.pgm_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_benefit_action_id
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_typ_cd
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_acty_typ_cd           => p_rec.acty_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tx_typ_cd
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_tx_typ_cd             => p_rec.tx_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_dflt_flag             => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_rt_typ_cd
  (p_batch_rt_id           => p_rec.batch_rt_id,
   p_bnft_rt_typ_cd        => p_rec.bnft_rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bri_shd.g_rec_type
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
  (p_batch_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_batch_rate_info b
    where b.batch_rt_id      = p_batch_rt_id
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
                             p_argument       => 'batch_rt_id',
                             p_argument_value => p_batch_rt_id);
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
end ben_bri_bus;

/
