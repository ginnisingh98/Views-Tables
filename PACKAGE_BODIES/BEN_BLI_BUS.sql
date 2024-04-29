--------------------------------------------------------
--  DDL for Package Body BEN_BLI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BLI_BUS" as
/* $Header: beblirhi.pkb 115.7 2002/12/10 15:17:02 bmanyam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bli_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_batch_ler_id >------------------------|
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
--   batch_ler_id PK of record being inserted or updated.
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
Procedure chk_batch_ler_id(p_batch_ler_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_batch_ler_id,hr_api.g_number)
     <>  ben_bli_shd.g_old_rec.batch_ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_bli_shd.constraint_error('BEN_BATCH_LER_INFO_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_batch_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bli_shd.constraint_error('BEN_BATCH_LER_INFO_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_batch_ler_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_ler_id >-----------------------------|
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
--   p_batch_ler_id PK
--   p_ler_id ID of FK column
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
Procedure chk_ler_id (p_batch_ler_id          in number,
                      p_ler_id                in number,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ler_f a
    where  a.ler_id = p_ler_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_bli_shd.api_updating
     (p_batch_ler_id            => p_batch_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_id,hr_api.g_number)
     <> nvl(ben_bli_shd.g_old_rec.ler_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ler_id value exists in ben_ler_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ler_f
        -- table.
        --
        ben_bli_shd.constraint_error('BEN_BATCH_LER_INFO_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ler_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >------------------------------|
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
--   p_batch_ler_id PK
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
Procedure chk_person_id (p_batch_ler_id          in number,
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
  l_api_updating := ben_bli_shd.api_updating
     (p_batch_ler_id            => p_batch_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_bli_shd.g_old_rec.person_id,hr_api.g_number)
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
        ben_bli_shd.constraint_error('BEN_BATCH_LER_INFO_DT1');
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
-- |-------------------------< chk_benefit_action_id >------------------------|
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
--   p_batch_ler_id PK
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
Procedure chk_benefit_action_id (p_batch_ler_id          in number,
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
  l_api_updating := ben_bli_shd.api_updating
     (p_batch_ler_id            => p_batch_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_benefit_action_id,hr_api.g_number)
     <> nvl(ben_bli_shd.g_old_rec.benefit_action_id,hr_api.g_number)
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
        ben_bli_shd.constraint_error('BEN_BATCH_LER_INFO_FK1');
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
-- |---------------------------< chk_dltd_flag >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   dltd_flag Value of lookup code.
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
Procedure chk_dltd_flag(p_batch_ler_id                in number,
                        p_dltd_flag                   in varchar2,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dltd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dltd_flag
      <> nvl(ben_bli_shd.g_old_rec.dltd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dltd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dltd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dltd_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_tmprl_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   tmprl_flag Value of lookup code.
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
Procedure chk_tmprl_flag(p_batch_ler_id                in number,
                         p_tmprl_flag                  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tmprl_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tmprl_flag
      <> nvl(ben_bli_shd.g_old_rec.tmprl_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_tmprl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_tmprl_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmprl_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_crtd_flag >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   crtd_flag Value of lookup code.
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
Procedure chk_crtd_flag(p_batch_ler_id            in number,
                        p_crtd_flag               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crtd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crtd_flag
      <> nvl(ben_bli_shd.g_old_rec.crtd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_crtd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_crtd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crtd_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_clpsd_flag >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   clpsd_flag Value of lookup code.
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
Procedure chk_clpsd_flag(p_batch_ler_id            in number,
                         p_clpsd_flag              in varchar2,
                         p_effective_date          in date,
                         p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_clpsd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_clpsd_flag
      <> nvl(ben_bli_shd.g_old_rec.clpsd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_clpsd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_clpsd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_clpsd_flag;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_clsn_flag >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   clsn_flag Value of lookup code.
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
Procedure chk_clsn_flag(p_batch_ler_id            in number,
                        p_clsn_flag               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crtd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_clsn_flag
      <> nvl(ben_bli_shd.g_old_rec.clsn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_clsn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_clsn_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_clsn_flag;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_no_effect_flag >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   no_effect_flag Value of lookup code.
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
Procedure chk_no_effect_flag(p_batch_ler_id            in number,
                             p_no_effect_flag          in varchar2,
                             p_effective_date          in date,
                             p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_effect_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_effect_flag
      <> nvl(ben_bli_shd.g_old_rec.no_effect_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_effect_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_effect_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_effect_flag;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_cvrge_rt_prem_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   cvrge_rt_prem_flag Value of lookup code.
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
Procedure chk_cvrge_rt_prem_flag(p_batch_ler_id            in number,
                                 p_cvrge_rt_prem_flag      in varchar2,
                                 p_effective_date          in date,
                                 p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvrge_rt_prem_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvrge_rt_prem_flag
      <> nvl(ben_bli_shd.g_old_rec.cvrge_rt_prem_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cvrge_rt_prem_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cvrge_rt_prem_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvrge_rt_prem_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_replcd_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   replcd_flag Value of lookup code.
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
Procedure chk_replcd_flag(p_batch_ler_id              in number,
                          p_replcd_flag               in varchar2,
                          p_effective_date            in date,
                          p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_replcd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_replcd_flag
      <> nvl(ben_bli_shd.g_old_rec.replcd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_replcd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_replcd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_replcd_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_open_and_clsd_flag >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   open_and_clsd_flag Value of lookup code.
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
Procedure chk_open_and_clsd_flag(p_batch_ler_id              in number,
                                 p_open_and_clsd_flag        in varchar2,
                                 p_effective_date            in date,
                                 p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_open_and_clsd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_open_and_clsd_flag
      <> nvl(ben_bli_shd.g_old_rec.open_and_clsd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_open_and_clsd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_open_and_clsd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_open_and_clsd_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_clsd_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   clsd_flag Value of lookup code.
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
Procedure chk_clsd_flag(p_batch_ler_id              in number,
                        p_clsd_flag                 in varchar2,
                        p_effective_date            in date,
                        p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_clsd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_clsd_flag
      <> nvl(ben_bli_shd.g_old_rec.clsd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_clsd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_clsd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_clsd_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_not_crtd_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   not_crtd_flag Value of lookup code.
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
Procedure chk_not_crtd_flag(p_batch_ler_id              in number,
                            p_not_crtd_flag             in varchar2,
                            p_effective_date            in date,
                            p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_not_crtd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_not_crtd_flag
      <> nvl(ben_bli_shd.g_old_rec.not_crtd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_not_crtd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_not_crtd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_not_crtd_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_stl_actv_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_ler_id PK of record being inserted or updated.
--   stl_actv_flag Value of lookup code.
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
Procedure chk_stl_actv_flag(p_batch_ler_id              in number,
                            p_stl_actv_flag             in varchar2,
                            p_effective_date            in date,
                            p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_stl_actv_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bli_shd.api_updating
    (p_batch_ler_id                => p_batch_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_stl_actv_flag
      <> nvl(ben_bli_shd.g_old_rec.stl_actv_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_stl_actv_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_stl_actv_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_stl_actv_flag;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bli_shd.g_rec_type
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
  chk_batch_ler_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_ler_id                => p_rec.ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_benefit_action_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dltd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_dltd_flag             => p_rec.dltd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmprl_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_tmprl_flag            => p_rec.tmprl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crtd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_crtd_flag             => p_rec.crtd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_replcd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_replcd_flag           => p_rec.replcd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_open_and_clsd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_open_and_clsd_flag    => p_rec.open_and_clsd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_clsd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_clsd_flag             => p_rec.clsd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_not_crtd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_not_crtd_flag         => p_rec.not_crtd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_actv_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_stl_actv_flag         => p_rec.stl_actv_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_clpsd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_clpsd_flag            => p_rec.clpsd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_clsn_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_clsn_flag             => p_rec.clsn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_effect_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_no_effect_flag        => p_rec.no_effect_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvrge_rt_prem_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_cvrge_rt_prem_flag    => p_rec.cvrge_rt_prem_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bli_shd.g_rec_type
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
  chk_batch_ler_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_ler_id                => p_rec.ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_benefit_action_id
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dltd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_dltd_flag             => p_rec.dltd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmprl_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_tmprl_flag            => p_rec.tmprl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crtd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_crtd_flag             => p_rec.crtd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_replcd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_replcd_flag           => p_rec.replcd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_open_and_clsd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_open_and_clsd_flag    => p_rec.open_and_clsd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_clsd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_clsd_flag             => p_rec.clsd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_not_crtd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_not_crtd_flag         => p_rec.not_crtd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_actv_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_stl_actv_flag         => p_rec.stl_actv_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_clpsd_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_clpsd_flag            => p_rec.clpsd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_clsn_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_clsn_flag             => p_rec.clsn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_effect_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_no_effect_flag        => p_rec.no_effect_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvrge_rt_prem_flag
  (p_batch_ler_id          => p_rec.batch_ler_id,
   p_cvrge_rt_prem_flag    => p_rec.cvrge_rt_prem_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bli_shd.g_rec_type
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_batch_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_batch_ler_info b
    where b.batch_ler_id      = p_batch_ler_id
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
                             p_argument       => 'batch_ler_id',
                             p_argument_value => p_batch_ler_id);
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
end ben_bli_bus;

/
