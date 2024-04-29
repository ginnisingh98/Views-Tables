--------------------------------------------------------
--  DDL for Package Body BEN_PEN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEN_BUS" as
/* $Header: bepenrhi.pkb 120.21.12010000.2 2008/08/05 15:11:10 ubhat ship $ */
--
-- ------------------------------------------------------------------------------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pen_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_enrt_rslt_id >------|
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
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_prtt_enrt_rslt_id(p_prtt_enrt_rslt_id      in number
                               ,p_effective_date         in date
                               ,p_object_version_number  in number
                               ) is
  l_proc         varchar2(72) := g_package||'chk_prtt_enrt_rslt_id';
  l_api_updating boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := ben_pen_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_object_version_number       => p_object_version_number);
  if (l_api_updating
     and nvl(p_prtt_enrt_rslt_id,hr_api.g_number)
     <>  ben_pen_shd.g_old_rec.prtt_enrt_rslt_id) then
    --
    -- raise error as PK has changed
    --
    ben_pen_shd.constraint_error('BEN_PRTT_ENRT_RSLT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtt_enrt_rslt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pen_shd.constraint_error('BEN_PRTT_ENRT_RSLT_PK');
      --
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_prtt_enrt_rslt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_ovridn_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   enrt_ovridn_flag Value of lookup code.
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
Procedure chk_enrt_ovridn_flag(p_prtt_enrt_rslt_id       in number
                              ,p_enrt_ovridn_flag        in varchar2
                              ,p_effective_date          in date
                              ,p_object_version_number   in number
                              ) is
  l_proc         varchar2(72) := g_package||'chk_enrt_ovridn_flag';
  l_api_updating boolean;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_ovridn_flag
          <> nvl(ben_pen_shd.g_old_rec.enrt_ovridn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enrt_ovridn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_enrt_ovridn_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_ovridn_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_lngr_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   no_lngr_elig_flag Value of lookup code.
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
Procedure chk_no_lngr_elig_flag(p_prtt_enrt_rslt_id       in number
                               ,p_no_lngr_elig_flag       in varchar2
                               ,p_effective_date          in date
                               ,p_object_version_number   in number
                               ) is
  l_proc         varchar2(72) := g_package||'chk_no_lngr_elig_flag';
  l_api_updating boolean;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_lngr_elig_flag
          <> nvl(ben_pen_shd.g_old_rec.no_lngr_elig_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_lngr_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_no_lngr_elig_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_lngr_elig_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_mthd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   enrt_mthd_cd Value of lookup code.
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
Procedure chk_enrt_mthd_cd(p_prtt_enrt_rslt_id                in number,
                            p_enrt_mthd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_mthd_cd
             <> nvl(ben_pen_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_RSLT_MTHD',
           p_lookup_code    => p_enrt_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_enrt_mthd_cd);
      fnd_message.set_token('TYPE','BEN_ENRT_RSLT_MTHD');
      fnd_message.raise_error;
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
end chk_enrt_mthd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_uom      >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   uom      Value of lookup code.
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
Procedure chk_uom     (p_prtt_enrt_rslt_id      in     number
                      ,p_uom                    in     varchar2
                      ,p_effective_date         in     date
                      ,p_object_version_number  in     number) is
  l_proc         varchar2(72) := g_package||'chk_uom';
  l_api_updating boolean;
  l_dummy        varchar2(1);

  cursor c1 is
      select null
        from fnd_currencies_tl
       where currency_code = p_uom     ;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_uom
      <> nvl(ben_pen_shd.g_old_rec.uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        --
        -- raise error as does not exist as lookup
        --
        close c1;
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', p_uom     );
        fnd_message.set_token('TYPE','FND_CURRENCY_TBL');
        fnd_message.raise_error;
     end if;
     close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_uom     ;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_is_cvrd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   prtt_is_cvrd_flag Value of lookup code.
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
Procedure chk_prtt_is_cvrd_flag(p_prtt_enrt_rslt_id                in number,
                            p_prtt_is_cvrd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_is_cvrd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtt_is_cvrd_flag
      <> nvl(ben_pen_shd.g_old_rec.prtt_is_cvrd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prtt_is_cvrd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_prtt_is_cvrd_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtt_is_cvrd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_sspndd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   sspndd_flag Value of lookup code.
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
Procedure chk_sspndd_flag(p_prtt_enrt_rslt_id                in number,
                            p_sspndd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sspndd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
         (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
          p_effective_date              => p_effective_date,
          p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_sspndd_flag <>
          nvl(ben_pen_shd.g_old_rec.sspndd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_sspndd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_sspndd_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_sspndd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   sspndd_flag Value of lookup code.
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
Procedure chk_comp_lvl_cd(p_prtt_enrt_rslt_id                in number,
                            p_comp_lvl_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
         (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
          p_effective_date              => p_effective_date,
          p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_lvl_cd <>
          nvl(ben_pen_shd.g_old_rec.comp_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_COMP_LVL',
           p_lookup_code    => p_comp_lvl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_comp_lvl_cd '||p_comp_lvl_cd);
      fnd_message.set_token('TYPE','BEN_COMP_LVL');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_lvl_cd;
--
-- --------------------------------------------------------------------------
-- |------------------------< chk_bnft_nnmntry_uom >-------------------------|
-- --------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   bnft_nnmntry_uom Value of lookup code.
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
Procedure chk_bnft_nnmntry_uom(p_prtt_enrt_rslt_id                in number,
                           p_bnft_nnmntry_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_nnmntry_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id                => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_nnmntry_uom
      <> nvl(ben_pen_shd.g_old_rec.bnft_nnmntry_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_nnmntry_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_NNMNTRY_UOM',
           p_lookup_code    => p_bnft_nnmntry_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_bnft_nnmntry_uom);
      fnd_message.set_token('TYPE','BEN_NNMNTRY_UOM');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bnft_nnmntry_uom;
--
-- --------------------------------------------------------------------------
-- |------< chk_bnft_typ_cd >------|
-- --------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   bnft_typ_cd Value of lookup code.
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
Procedure chk_bnft_typ_cd(p_prtt_enrt_rslt_id         in     number,
                            p_bnft_typ_cd             in     varchar2,
                            p_effective_date          in     date,
                            p_object_version_number   in     number) is

  l_proc         varchar2(72) := g_package||'chk_bnft_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_typ_cd
      <> nvl(ben_pen_shd.g_old_rec.bnft_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNFT_TYP',
           p_lookup_code    => p_bnft_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_bnft_typ_cd);
      fnd_message.set_token('TYPE','BEN_BNFT_TYP');
      fnd_message.raise_error;
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);

end chk_bnft_typ_cd;
--
-- --------------------------------------------------------------------------
-- |------< chk_prtt_enrt_rslt_stat_cd >------|
-- --------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   prtt_enrt_rslt_stat_cd Value of lookup code.
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
Procedure chk_prtt_enrt_rslt_stat_cd(p_prtt_enrt_rslt_id         in     number,
                                     p_prtt_enrt_rslt_stat_cd    in     varchar2,
                                     p_effective_date            in     date,
                                     p_object_version_number     in     number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_enrt_rslt_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtt_enrt_rslt_stat_cd
      <> nvl(ben_pen_shd.g_old_rec.prtt_enrt_rslt_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtt_enrt_rslt_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTT_ENRT_RSLT_STAT',
           p_lookup_code    => p_prtt_enrt_rslt_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_prtt_enrt_rslt_stat_cd);
      fnd_message.set_token('TYPE','BEN_PRTT_ENRT_RSLT_STAT');
      fnd_message.raise_error;
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);

end chk_prtt_enrt_rslt_stat_cd;
--
--
-- -------------------------------------------------------------------------
-- |------< chk_enrt_ovrid_rsn_cd >------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   enrt_ovrid_rsn_cd Value of lookup code.
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
Procedure chk_enrt_ovrid_rsn_cd
                   (p_prtt_enrt_rslt_id           in number
                   ,p_enrt_ovrid_rsn_cd           in varchar2
                   ,p_effective_date              in date
                   ,p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_ovrid_rsn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pen_shd.api_updating
    (p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  if (l_api_updating
      and p_enrt_ovrid_rsn_cd
      <> nvl(ben_pen_shd.g_old_rec.enrt_ovrid_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_ovrid_rsn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_OVRID_RSN',
           p_lookup_code    => p_enrt_ovrid_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_enrt_ovrid_rsn_cd);
      fnd_message.set_token('TYPE','BEN_OVRID_RSN');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
end chk_enrt_ovrid_rsn_cd;
--
-- ---------------------------------------------------------------------------
-- |------------------------< crt_ordr_warning >----------------------------|
-- ---------------------------------------------------------------------------
-- Procedure used to create warning messages for crt_ordrs.
--
-- Description
--   This procedure is used to create warning messages for persons
--   not designated as covered dependents but reqired to be covered
--   under court orders.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   effective_date effective date
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
PROCEDURE crt_ordr_warning (
   p_prtt_enrt_rslt_id   IN   NUMBER,
   p_per_in_ler_id       IN   NUMBER,
   p_person_id           IN   NUMBER,
   p_pgm_id              IN   NUMBER,
   p_pl_id               IN   NUMBER,
   p_ptip_id             IN   NUMBER,
   p_pl_typ_id           IN   NUMBER,
   p_effective_date      IN   DATE,
   p_enrt_cvg_strt_dt    IN   DATE,
   p_enrt_cvg_thru_dt    IN   DATE,
   p_business_group_id   IN   NUMBER
)
IS
   --
   l_proc              VARCHAR2 (72)    := g_package || 'crt_ordr_warning';
   l_api_updating      BOOLEAN;
   l_level             VARCHAR2 (30)    := 'PL';
   l_code              VARCHAR2 (30);
   --
   l_pgm_rec           ben_cobj_cache.g_pgm_inst_row;
   l_pl_rec            ben_cobj_cache.g_pl_inst_row;
   l_ptip_rec          ben_cobj_cache.g_ptip_inst_row;
   l_benefit_name      ben_pl_typ_f.NAME%TYPE;
   --
   l_lf_evt_ocrd_dt    DATE;
   --
   CURSOR c_lf_evt_ocrd_dt
   IS
      SELECT lf_evt_ocrd_dt
        FROM ben_per_in_ler pil
       WHERE pil.per_in_ler_id = p_per_in_ler_id;
   --
   CURSOR c_crt_ordr
   IS
      SELECT per.first_name || ' ' || per.last_name NAME, lkp.meaning,
             cvr.person_id, bpl.NAME, crt.crt_ordr_typ_cd
        FROM ben_crt_ordr crt,
             ben_crt_ordr_cvrd_per cvr,
             per_all_people_f per,
             per_contact_relationships con,
             hr_lookups lkp,
             ben_pl_f bpl
       WHERE crt.crt_ordr_typ_cd IN ('QMCSO','QDRO')
         AND crt.person_id = p_person_id
         AND crt.pl_id = p_pl_id
         AND crt.crt_ordr_id = cvr.crt_ordr_id
         AND cvr.person_id = per.person_id
         AND cvr.person_id = con.contact_person_id
         AND con.contact_type = lkp.lookup_code
         AND lkp.lookup_type = 'CONTACT'
         AND p_effective_date BETWEEN NVL (lkp.start_date_active,
                                           p_effective_date
                                          )
                                  AND NVL (lkp.end_date_active,
                                           p_effective_date
                                          )
         AND GREATEST(l_lf_evt_ocrd_dt, p_enrt_cvg_strt_dt)
                                  BETWEEN GREATEST (NVL (apls_perd_strtg_dt,
                                                         p_effective_date
                                                        ),
                                                    NVL (detd_qlfd_ordr_dt,
                                                         apls_perd_strtg_dt
                                                        )
                                                   )
                                      AND NVL (apls_perd_endg_dt,
                                               p_enrt_cvg_thru_dt
                                              )
         AND crt.business_group_id = p_business_group_id
         AND cvr.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN NVL (con.date_start, p_effective_date)
                                  AND NVL (con.date_end, p_effective_date)
         AND con.business_group_id = p_business_group_id
         AND bpl.pl_id = p_pl_id
         AND p_effective_date BETWEEN NVL (bpl.effective_start_date,
                                           p_effective_date
                                          )
                                  AND NVL (bpl.effective_end_date,
                                           p_effective_date
                                          )
      UNION
      SELECT per.first_name || ' ' || per.last_name NAME, lkp.meaning,
             cvr.person_id, bpt.NAME, crt.crt_ordr_typ_cd
        FROM ben_crt_ordr crt,
             ben_crt_ordr_cvrd_per cvr,
             per_all_people_f per,
             per_contact_relationships con,
             hr_lookups lkp,
             ben_pl_typ_f bpt
       WHERE crt.crt_ordr_typ_cd IN ('QMCSO','QDRO')
         AND crt.person_id = p_person_id
         AND crt.pl_typ_id = l_pl_rec.pl_typ_id
         AND crt.crt_ordr_id = cvr.crt_ordr_id
         AND cvr.person_id = per.person_id
         AND cvr.person_id = con.contact_person_id
         AND con.contact_type = lkp.lookup_code
         AND lkp.lookup_type = 'CONTACT'
         AND p_effective_date BETWEEN NVL (lkp.start_date_active,
                                           p_effective_date
                                          )
                                  AND NVL (lkp.end_date_active,
                                           p_effective_date
                                          )
         AND GREATEST(l_lf_evt_ocrd_dt, p_enrt_cvg_strt_dt)
                                  BETWEEN GREATEST (NVL (apls_perd_strtg_dt,
                                                         p_effective_date
                                                        ),
                                                    NVL (detd_qlfd_ordr_dt,
                                                         apls_perd_strtg_dt
                                                        )
                                                   )
                                      AND NVL (apls_perd_endg_dt,
                                               p_enrt_cvg_thru_dt
                                              )
         AND crt.business_group_id = p_business_group_id
         AND cvr.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN NVL (con.date_start, p_effective_date)
                                  AND NVL (con.date_end, p_effective_date)
         AND con.business_group_id = p_business_group_id
         AND bpt.pl_typ_id = l_pl_rec.pl_typ_id
         AND p_effective_date BETWEEN NVL (bpt.effective_start_date,
                                           p_effective_date
                                          )
                                  AND NVL (bpt.effective_end_date,
                                           p_effective_date
                                          );

   --
   l_name              VARCHAR2 (500);           -- UTF8 Change Bug 2254683
   l_contact_type      VARCHAR2 (80);  -- Bug 5706254
   l_dpnt_id           NUMBER (15);
   l_crt_ordr_typ_cd   VARCHAR2 (30);
   l_crt_ordr_meaning  VARCHAR2(80);

   --
   -- Bug 4718038 : Check PDP record for court order warning as of life event occurred date
   --
   CURSOR c_elig_dpnt
   IS
      SELECT NULL
        FROM ben_elig_cvrd_dpnt_f pdp, ben_per_in_ler pil
       WHERE pdp.dpnt_person_id = l_dpnt_id
         AND pdp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         AND p_effective_date BETWEEN pdp.effective_start_date
                                  AND pdp.effective_end_date
         AND GREATEST (pil.lf_evt_ocrd_dt, p_enrt_cvg_strt_dt) BETWEEN cvg_strt_dt
                                                                   AND cvg_thru_dt
         AND pdp.business_group_id = p_business_group_id
         AND pil.business_group_id = p_business_group_id
         AND pdp.per_in_ler_id = pil.per_in_ler_id
         AND pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

   --
   l_dummy             VARCHAR2 (1);
   l_message           fnd_new_messages.message_name%TYPE   := 'BEN_92430_CRT_ORD_WARNING';
   l_cobra_pgm         BOOLEAN                              := FALSE;
--
BEGIN
   hr_utility.set_location ('Entering:' || l_proc, 5);
   --
   hr_utility.set_location ('Checking court order at PEN level', 12);
   --
   ben_cobj_cache.get_pl_dets (p_business_group_id      => p_business_group_id,
                               p_effective_date         => p_effective_date,
                               p_pl_id                  => p_pl_id,
                               p_inst_row               => l_pl_rec
                              );

   --
   --
   IF    l_pl_rec.alws_qmcso_flag = 'Y' OR   /* Qualified Medical Child Support Order */
         l_pl_rec.alws_qdro_flag = 'Y'       /* Qualified Domestic Relations Order */
   THEN
      --
      IF p_pgm_id IS NOT NULL
      THEN
         --
         -- find the level from the program
         --
         ben_cobj_cache.get_pgm_dets
                              (p_business_group_id      => p_business_group_id,
                               p_effective_date         => p_effective_date,
                               p_pgm_id                 => p_pgm_id,
                               p_inst_row               => l_pgm_rec
                              );
         --
         l_level := l_pgm_rec.dpnt_dsgn_lvl_cd;
         --
         IF l_pgm_rec.pgm_typ_cd IN ('COBRANFLX', 'COBRAFLX')
         THEN
            --
            l_cobra_pgm := TRUE;
            --
         END IF;
         --
      ELSE
         --
         -- PLAN level
         l_level := 'PL';
         --
      END IF;
      --
      --
      -- Retrieve designation code
      --
      hr_utility.set_location ('Level = ' || l_level, 40);

      IF l_level = 'PGM'
      THEN
         --
         l_code := l_pgm_rec.dpnt_dsgn_cd;
         --
      ELSIF l_level = 'PTIP'
      THEN
         --
         ben_cobj_cache.get_ptip_dets
                              (p_business_group_id      => p_business_group_id,
                               p_effective_date         => p_effective_date,
                               p_ptip_id                => p_ptip_id,
                               p_inst_row               => l_ptip_rec
                              );
         --
         l_code := l_ptip_rec.dpnt_dsgn_cd;
         --
      ELSIF l_level = 'PL'
      THEN
         --
         l_code := l_pl_rec.dpnt_dsgn_cd;
         --
      ELSE
         --
         l_code := NULL;
         --
      END IF;
      --
      hr_utility.set_location ('dsgn code = ' || l_code, 40);
      --
      IF l_code IS NOT NULL AND
         NOT l_cobra_pgm
      THEN
         --
         /*
         hr_utility.set_location ('ACE p_prtt_enrt_rslt_id  = ' || p_prtt_enrt_rslt_id, 9999 );
         hr_utility.set_location ('ACE p_effective_date  = ' || p_effective_date, 9999 );
         hr_utility.set_location ('ACE p_business_group_id   = ' || p_business_group_id, 9999 );
         hr_utility.set_location ('ACE p_enrt_cvg_strt_dt   = ' || p_enrt_cvg_strt_dt, 9999 );
         */
         --
         OPEN c_lf_evt_ocrd_dt;
            --
            FETCH c_lf_evt_ocrd_dt into l_lf_evt_ocrd_dt;
            --
         CLOSE c_lf_evt_ocrd_dt;
         --
         OPEN c_crt_ordr;
         LOOP
            --
            FETCH c_crt_ordr INTO l_name,
                                  l_contact_type,
                                  l_dpnt_id,
                                  l_benefit_name,
                                  l_crt_ordr_typ_cd;
            --
            EXIT WHEN c_crt_ordr%NOTFOUND;
            --
            /*
            hr_utility.set_location ('ACE l_name = ' || l_name, 9999);
            hr_utility.set_location ('ACE l_dpnt_id = ' || l_dpnt_id, 9999);
            hr_utility.set_location ('ACE l_benefit_name = ' || l_benefit_name, 9999);
            hr_utility.set_location ('ACE l_lf_evt_ocrd_dt   = ' || l_lf_evt_ocrd_dt, 9999 );
            hr_utility.set_location ('ACE l_crt_ordr_typ_cd   = ' || l_crt_ordr_typ_cd, 9999 );
            */
            hr_utility.set_location('Found Court Order', 9999);
            --
            OPEN c_elig_dpnt;
               --
               FETCH c_elig_dpnt INTO l_dummy;
               --
               IF c_elig_dpnt%NOTFOUND
               THEN
                  --
                  hr_utility.set_location ('C_ELIG_DPNT Not Found', 9999);
                  --
                  l_crt_ordr_meaning := hr_general.decode_lookup
                                       (p_lookup_type                 => 'BEN_CRT_ORDR_TYP',
                                        p_lookup_code                 => l_crt_ordr_typ_cd
                                       );
                  --
                  ben_warnings.load_warning
                                          (p_application_short_name      => 'BEN',
                                           p_message_name                => l_message,
                                           p_parma                       => l_benefit_name,
                                           p_parmb                       => l_contact_type || ' , ' || l_name,
                                           p_parmc                       => l_crt_ordr_meaning,
                                           p_person_id                   => p_person_id
                                          );
                  --
               END IF;
               --
            CLOSE c_elig_dpnt;
            --
         END LOOP;
         --
         CLOSE c_crt_ordr;
         --
      END IF;
      --
   END IF;
   --
   hr_utility.set_location ('Leaving:' || l_proc, 10);
   --
END crt_ordr_warning;
--
--
-- -------------------------------------------------------------------------
-- |--------------------------< calc_mx_amt >------------------------------|
-- -------------------------------------------------------------------------
function calc_mx_amt(p_mx_cvg_rl number
                    ,p_assignment_id number
                    ,p_effective_date date
                    -- 3427367
                    ,p_business_group_id number
  		    ,p_pgm_id number
		    ,p_pl_id number
		    ,p_pl_typ_id number
		    ,p_opt_id number
		    ,p_ler_id number
		    ,p_prtt_enrt_rslt_id number --3427367
		    ,p_person_id number         -- 5331889
		   ) return number is
  l_proc       varchar2(80) := g_package||'.calc_mx_amt';
  l_outputs    ff_exec.outputs_t;
  l_return     number(15);
  l_step       integer;
  -- 3427367
  cursor c_epe is
   select elig_per_elctbl_chc_id
   from ben_elig_per_elctbl_chc
   where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
  --
  l_jurisdiction_code     varchar2(30);
  l_elig_per_elctbl_chc_id number;
  -- 3427367
begin
     hr_utility.set_location ('Entering '||l_proc,10);
     --
     -- Call formula initialise routine
     --
     -- 3427367
    open c_epe;
    fetch c_epe into l_elig_per_elctbl_chc_id;
    close c_epe;
    -- 3427367
     l_step := 20;
     l_outputs := benutils.formula
			(p_formula_id     => p_mx_cvg_rl
			-- 3427367
			,p_business_group_id => p_business_group_id
			,p_organization_id   => l_elig_per_elctbl_chc_id
			,p_pgm_id            => p_pgm_id
			,p_pl_id             => p_pl_id
			,p_pl_typ_id         => p_pl_typ_id
			,p_opt_id            => p_opt_id
			,p_ler_id			 => p_ler_id
			,p_jurisdiction_code => l_jurisdiction_code
			-- 3427367
			,p_effective_date => p_effective_date
			,p_assignment_id  => p_assignment_id
       		        ,p_param1         => 'BEN_IV_PERSON_ID'           -- Bug 5331889
                        ,p_param1_value   => to_char(p_person_id));
     --
     -- Formula will return Y or N
     --
     l_return := to_number(l_outputs(l_outputs.first).value);

     return l_return;
     hr_utility.set_location ('Leaving '||l_proc,50);
exception
     when others then
         hr_utility.set_location ('Fail in '||l_proc|| ' step in '||
                                  to_char(l_step),999);
         raise;
end;
--
-- -------------------------------------------------------------------------
-- |--------------------------< calc_mn_amt >------------------------------|
-- -------------------------------------------------------------------------
--
function calc_mn_amt(p_mn_cvg_rl number
                    ,p_assignment_id number
                    ,p_effective_date date
                    -- 3427367
                    ,p_business_group_id number
		    ,p_pgm_id number
		    ,p_pl_id number
		    ,p_pl_typ_id number
		    ,p_opt_id number
		    ,p_ler_id number
		    ,p_prtt_enrt_rslt_id number --3427367
		    ,p_person_id number         -- 5331889
                    ) return number is

  l_proc       varchar2(80) := g_package||'.calc_mn_amt';
  l_outputs    ff_exec.outputs_t;
  l_return     number(15);
  l_step       integer;
  -- 3427367
  cursor c_epe is
   select elig_per_elctbl_chc_id
   from ben_elig_per_elctbl_chc
   where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
  --
  l_jurisdiction_code     varchar2(30);
  l_elig_per_elctbl_chc_id number;
  -- 3427367
begin
	hr_utility.set_location ('Entering  '||l_proc,70);
     --
     -- Call formula initialise routine
     --
     -- 3427367
    open c_epe;
    fetch c_epe into l_elig_per_elctbl_chc_id;
    close c_epe;
    -- 3427367
     l_step := 20;
     l_outputs := benutils.formula
			(p_formula_id     => p_mn_cvg_rl
			-- 3427367
			,p_business_group_id => p_business_group_id
			,p_organization_id   => l_elig_per_elctbl_chc_id
			,p_pgm_id            => p_pgm_id
			,p_pl_id             => p_pl_id
			,p_pl_typ_id         => p_pl_typ_id
			,p_opt_id            => p_opt_id
			,p_ler_id			 => p_ler_id
			,p_jurisdiction_code => l_jurisdiction_code
			-- 3427367
			,p_effective_date => p_effective_date
			,p_assignment_id  => p_assignment_id
       		        ,p_param1         => 'BEN_IV_PERSON_ID'           -- Bug 5331889
                        ,p_param1_value   => to_char(p_person_id));
     --
     -- Formula will return Y or N
     --
     l_return := to_number(l_outputs(l_outputs.first).value);

     return l_return;
     hr_utility.set_location ('Leaving '||l_proc,70);
exception
     when others then
         hr_utility.set_location ('Fail in '||l_proc || ' step in ' ||
                                  to_char(l_step),999);
         raise;
end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<get_opts_and_cvg >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_opts_and_cvg
                (p_enrt_tbl  in     enrt_table
                ,p_enrt_cnt  in     binary_integer
                ,p_tot_amt      out nocopy number
                ,p_tot_opts     out nocopy number
                ) is
    l_tot_amt    number := 0; -- number(13) := 0;
    l_tot_opts   number := 0; -- number(8)  := 0; bug 2649163
    l_max_amt    number := 0; -- number(13) := 0;
    l_max_opts   number := 0; -- number(8)  := 0; bug 2649163
    l_tot_amt_no_interim number := 0;
    l_max_amt_no_interim number := 0;
begin
    hr_utility.set_location('Entering get_opts_and_cvg ',1234);
    hr_utility.set_location(' p_enrt_cnt '||p_enrt_cnt,1234);
    for i in 1..p_enrt_cnt loop
        l_tot_amt  := 0;
        l_tot_opts := 0;
        l_tot_amt_no_interim := 0 ;
        for j in 1..p_enrt_cnt loop
            if (p_enrt_tbl(i).enrt_cvg_strt_dt between
                    p_enrt_tbl(j).enrt_cvg_strt_dt and
                    nvl(p_enrt_tbl(j).enrt_cvg_thru_dt,hr_api.g_eot)
                ) then
                hr_utility.set_location(' j '||j,1234);
                if (p_enrt_tbl(j).calc_interm = 1) then
                    if (nvl(p_enrt_tbl(j).SSPNDD_FLAG, 'X') <> 'Y') then
                        hr_utility.set_location(' l_tot_amt before '||l_tot_amt,1234);
                        l_tot_amt := l_tot_amt+nvl(p_enrt_tbl(j).bnft_amt,0);
                        hr_utility.set_location(' l_tot_amt after '||l_tot_amt,1234);
                    end if;
                else
                  if p_enrt_tbl(j).interim_flag = 'N' then
                    hr_utility.set_location(' interim_flag before '||l_tot_amt,1234);
                    l_tot_amt := l_tot_amt + nvl(p_enrt_tbl(j).bnft_amt,0);
                    hr_utility.set_location(' interim_flag after '||l_tot_amt,1234);
                  end if;
                end if;
                if (p_enrt_tbl(j).interim_flag = 'N') then
                    l_tot_opts := l_tot_opts + 1;
                    l_tot_amt_no_interim:=l_tot_amt_no_interim+nvl(p_enrt_tbl(j).bnft_amt,0);
                end if;
            end if;
        end loop;
        hr_utility.set_location('  before l_max_amt '||l_max_amt,1234);
        l_max_amt  := greatest(l_tot_amt, l_max_amt);
        l_max_opts := greatest(l_max_opts,l_tot_opts);
        l_max_amt_no_interim :=  greatest(l_max_amt_no_interim,l_tot_amt_no_interim);
        hr_utility.set_location('  after l_max_amt '||l_max_amt,1234);
    end loop;
    hr_utility.set_location('  before p_tot_amt '||p_tot_amt,1234);
    p_tot_amt  := l_max_amt;
    p_tot_opts := l_max_opts;
    --p_tot_amt_no_interim := l_tot_amt_no_interim;
    hr_utility.set_location('  after p_tot_amt '||p_tot_amt,1234);
end get_opts_and_cvg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<get_pls_and_cvg >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_pls_and_cvg
                (p_enrt_tbl                     in    enrt_table
                ,p_enrt_cnt                     in    binary_integer
                ,p_tot_amt                        out nocopy number
                ,p_tot_pls                        out nocopy number
                ,p_dpnt_cvd_by_othr_apls_flag     out nocopy varchar2
                ,p_tot_amt_no_interim             out nocopy number
                ) is
    type l_pl_table is table of number(15) index by binary_integer;
    l_tot_amt    number := 0;  -- number(13) := 0; bug 2649163
    l_tot_pls    number := 0;  -- number(8)  := 0; bug 2649163
    l_max_amt    number := 0;  -- number(13) := 0; bug 2649163
    l_max_pls    number := 0;  -- number(8)  := 0; bug 2649163
   -- l_cnt        Binary_integer := 0;
   -- l_pl_tbl     l_pl_table;
   -- l_not_found  boolean := TRUE;
    l_tot_amt_no_interim   number := 0;
    l_max_amt_no_interim   number := 0;
begin
    --
    p_dpnt_cvd_by_othr_apls_flag := 'N';
    --
    for i in 1..p_enrt_cnt loop
               /*
                hr_utility.set_location('i INSIDE p_enrt_tbl(i).pl_id'||p_enrt_tbl(i).pl_id,111);
                hr_utility.set_location('i INSIDE p_enrt_tbl(i).pl_id'||p_enrt_tbl(i).pl_id,111);
                hr_utility.set_location('i INSIDE SSPNDD_FLAG'||p_enrt_tbl(i).SSPNDD_FLAG,111);
                hr_utility.set_location('i INSIDE Bnft I'||p_enrt_tbl(i).bnft_amt,111);
               */
        l_tot_amt := 0;
        l_tot_pls := 0;
        l_tot_amt_no_interim := 0 ;
        --l_pl_tbl.delete;
        --l_cnt := 0;
        for j in 1..p_enrt_cnt loop
                --
                hr_utility.set_location('J INSIDE p_enrt_tbl(j).pl_id'||p_enrt_tbl(j).pl_id,111);
                hr_utility.set_location('J INSIDE p_enrt_tbl(i).pl_id'||p_enrt_tbl(i).pl_id,111);
                hr_utility.set_location('J INSIDE SSPNDD_FLAG'||p_enrt_tbl(j).SSPNDD_FLAG,111);
                hr_utility.set_location('i INSIDE Bnft J '||p_enrt_tbl(j).bnft_amt,111);
                hr_utility.set_location('i INSIDE interim J'||p_enrt_tbl(j).interim_flag,111);
                --
            if (p_enrt_tbl(i).enrt_cvg_strt_dt between
                    p_enrt_tbl(j).enrt_cvg_strt_dt and
                    nvl(p_enrt_tbl(j).enrt_cvg_thru_dt,hr_api.g_eot)
               ) then
                --
                /*
                hr_utility.set_location('INSIDE p_enrt_tbl(j).pl_id'||p_enrt_tbl(j).pl_id,111);
                hr_utility.set_location('INSIDE p_enrt_tbl(i).pl_id'||p_enrt_tbl(i).pl_id,111);
                hr_utility.set_location('INSIDE SSPNDD_FLAG'||p_enrt_tbl(j).SSPNDD_FLAG,111);
                hr_utility.set_location('INSIDE calc_inter'||p_enrt_tbl(j).calc_interm,111);
                */
                --
                if (p_enrt_tbl(j).calc_interm = 1) then
                    if (nvl(p_enrt_tbl(j).SSPNDD_FLAG, 'X') <> 'Y') then
 	                l_tot_amt := l_tot_amt+nvl(p_enrt_tbl(j).bnft_amt,0);
                    end if;
                else
                  if p_enrt_tbl(j).interim_flag = 'N' then
                    l_tot_amt := l_tot_amt + nvl(p_enrt_tbl(j).bnft_amt,0);
                  end if;
                end if;
                if (p_enrt_tbl(j).interim_flag = 'N') then
                   -- Bug 1178690 comment out the pl_id check
                   -- l_not_found := TRUE;
                   -- for l in 1..l_cnt loop
                   --     if (p_enrt_tbl(j).pl_id = l_pl_tbl(l)) then
                   --         l_not_found := FALSE;
                   --         exit;
                   --     end if;
                   -- end loop;
                   -- if (l_not_found) then
                        --
                        /*
                        hr_utility.set_location('p_enrt_tbl(j).pl_id'||p_enrt_tbl(j).pl_id,111);
                        hr_utility.set_location('p_enrt_tbl(i).pl_id'||p_enrt_tbl(i).pl_id,111);
                        hr_utility.set_location('enrt_tbl(j).bnft_amt'||nvl(p_enrt_tbl(j).bnft_amt,0),111);
                        hr_utility.set_location('l_tot_amt_no_interim'||l_tot_amt_no_interim,111);
                        */
                        --
                        l_tot_pls := l_tot_pls + 1;
                        l_tot_amt_no_interim:=l_tot_amt_no_interim+nvl(p_enrt_tbl(j).bnft_amt,0);
                        if p_enrt_tbl(j).dpnt_cvd_by_othr_apls_flag = 'Y' then
                          p_dpnt_cvd_by_othr_apls_flag := 'Y';
                        end if;
                   --     l_cnt := l_cnt + 1;
                   --     l_pl_tbl(l_cnt) := p_enrt_tbl(j).pl_id;
                   -- end if;
               end if;
            end if;
        end loop;
        l_max_amt := greatest(l_tot_amt, l_max_amt);
        l_max_pls := greatest(l_max_pls,l_tot_pls);
        l_max_amt_no_interim := greatest(l_max_amt_no_interim,l_tot_amt_no_interim);  /* Bug 4309146 Removed typo */
    end loop;
    p_tot_amt := l_max_amt;
    p_tot_pls := l_max_pls;
    p_tot_amt_no_interim := l_max_amt_no_interim ;
end get_pls_and_cvg;
--
-- ----------------------------------------------------------------------------
-- |------<cache_enrt_info >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to cached all programs, plan types, plans for
--   a specified person_id..
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   person_id             Person ID
--   effective_date        effective date
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
Procedure cache_enrt_info
  (p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_person_id 	       in     number
  ,p_pgm_id            in     number
  ,p_assignment_id     in     number
  ,p_include_erl       in     varchar2
  )
is
  --
  l_dup_ptip_id_list   ben_cache.IdType;
  l_dup_pl_typ_id_list ben_cache.IdType;
  l_dup_pl_id_list     ben_cache.IdType;
  --
  l_plnrow       ben_cobj_cache.g_pl_inst_row;
  l_oiplrow      ben_cobj_cache.g_oipl_inst_row;
  --
  -- Cursor Declaration.
  --
  -- Previous enrollment means previous enrollment, so we check that the
  -- per_in_ler_id is different.
  -- BUG 3695079 fixes. This cursor never returns any rows as the current
  -- datet rack peice always has the new PIL. We need to get the DT Peice
  -- of effective_date-1 when looking along with PIL
  --
  -- p_effective_date is the lf_evt_ocrd_dt. Please keep this in mind
  -- before making further changes to this cursor.
  --
  cursor l_c_prev_pl(p_pl_id number)  is
    select nvl(sum(pen.bnft_amt),0)
      from ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler       pil
         where pen.person_id = p_person_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and pen.pl_id = p_pl_id
       and pil.person_id = p_person_id
       and nvl(pen.per_in_ler_id, pil.per_in_ler_id) <> pil.per_in_ler_id
       and pil.per_in_ler_stat_cd = 'STRTD'
       and pen.business_group_id = p_business_group_id
       and pen.enrt_cvg_strt_dt < pen.effective_end_date
       and (p_effective_date-1) between pen.enrt_cvg_strt_dt
                                    and pen.enrt_cvg_thru_dt
       and pen.effective_end_date = ( select max(pen1.effective_start_date - 1)
                                        from ben_prtt_enrt_rslt_f pen1
                                       where pen1.per_in_ler_id = pil.per_in_ler_id
                                         and pen1.prtt_enrt_rslt_stat_cd is NULL
                                         and pen1.pl_id = p_pl_id
                                         and pen1.enrt_cvg_thru_dt = hr_api.g_eot
                                         and pen1.person_id = p_person_id ) ;
  --
  --Bug 2715942 fixes
  --
  -- to get the ler_id of the STRTD per_in_ler
  --
  cursor c_ler(cv_pl_id number) is
    select pil.ler_id
      from ben_per_in_ler pil,
           ben_prtt_enrt_rslt_f pen
     where pil.person_id = p_person_id
       and pil.per_in_ler_stat_cd = 'STRTD'
       and pil.per_in_ler_id = pen.per_in_ler_id
       and pen.person_id     = p_person_id
       and pen.pl_id         = cv_pl_id
       and pen.prtt_enrt_rslt_stat_cd is null ;
  --
  cursor c_ler_rstrn(cv_pl_id number, cv_ler_id number) is
    select rstrn.pl_id,
           rstrn.mx_cvg_wcfn_amt,
           rstrn.mx_cvg_incr_alwd_amt,
           rstrn.mx_cvg_incr_wcf_alwd_amt,
           rstrn.mn_cvg_amt mn_cvg_rqd_amt,
           rstrn.mx_cvg_alwd_amt,
           rstrn.mx_cvg_rl,
           rstrn.mn_cvg_rl
    from   ben_ler_bnft_rstrn_f rstrn
    where  rstrn.ler_id = cv_ler_id
    and    rstrn.pl_id  = cv_pl_id
    and    p_effective_date
           between rstrn.effective_start_date
           and     rstrn.effective_end_date;
  --bug#3480144

  cursor other_pgm_enrolled
    (c_effective_date date
    ,c_business_group_id  number
    ,c_person_id number
    ,c_pgm_id number
    )
  is
    select pen.pgm_id,
           pen.ptip_id,
           pen.pl_typ_id,
           NVL(epe.plip_id, cpp.plip_id) plip_id,
           pen.pl_id,
           pen.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt,
           pen.prtt_enrt_rslt_id,
           pen.RPLCS_SSPNDD_RSLT_ID,
           pen.SSPNDD_FLAG,
           'N' interim_flag,
           pen.person_id,
           0 Calc_interm,
           nvl(pen.bnft_amt,0) bnft_amt,
           pen.uom,
           epe.elig_per_elctbl_chc_id,
           epe.MUST_ENRL_ANTHR_PL_ID,
           'N' dpnt_cvd_by_othr_apls_flag,
           -9999999999999999999999999999999999999 opt_id
    from ben_prtt_enrt_rslt_f pen,
         ben_elig_per_elctbl_chc epe,
         ben_plip_f cpp,
         ben_oipl_f cop,
         ben_pl_f pln
    where pen.person_id = c_person_id
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   pen.pgm_id <> c_pgm_id
    and pen.effective_end_date = hr_api.g_eot
    and pen.enrt_cvg_thru_dt   =  hr_api.g_eot
    and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id (+)
    and pen.per_in_ler_id     = epe.per_in_ler_id (+)
    and pen.comp_lvl_cd not in ('PLANFC','PLANIMP')
    and exists (select null
                 from   ben_per_in_ler pil
                 where  pil.per_in_ler_id = epe.per_in_ler_id
                   and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    and cpp.pgm_id = pen.pgm_id
    and cpp.pl_id = pen.pl_id
    and cpp.business_group_id = c_business_group_id
    and c_effective_date between cpp.effective_start_date and cpp.effective_end_date
    and pen.oipl_id           = cop.oipl_id (+)
    and c_effective_date
      between cop.effective_start_date (+) and cop.effective_end_date (+)
    and pen.pl_id = pln.pl_id
    and c_effective_date
      between pln.effective_start_date and pln.effective_end_date
    order by 1,2,3,4,5,6,7;
  --
  l_ler_rstrn         c_ler_rstrn%rowtype ;
  --
  -- Type declaration.
  --
  type interim_table is table of ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type
       index by binary_integer;
  --
  -- Local Variable declaration
  --
  l_prev_pgm_id       ben_pgm_f.pgm_id%type := -99999;
  l_prev_ptip_id  	ben_ptip_f.ptip_id%type := -99999;
  l_prev_pl_typ_id    ben_pl_typ_f.pl_typ_id%type := -99999;
  l_prev_pl_id        ben_pl_f.pl_id%type := -99999;
  l_pl_typ_rec        g_c_pl_typ%rowtype;
  l_interim_tbl       interim_table;
  l_interim_cnt       binary_integer := 0;
  i                   binary_integer;
  j                   binary_integer;
  l_interim_calc      Boolean := FALSE;
  l_proc              varchar2(72) := g_package||'cache_enrt_info';
  l_step              integer;
  l_cnt               integer := 0;
  l_frst_susp	        boolean := FALSE;
  l_enrt_tbl          enrt_table;
  l_enrt_cnt          binary_integer := 0;
  l_ler_id            number ; --Bug 2715942
  l_enrt_tbl2         enrt_table;
  --
begin
  --
  -- Store all comp. object into PL/SQL table g_enrt_tbl, and all the
  -- interim records prtt_enrt_rslt_id into l_interim_tbl PL/SQL table.
  --
  l_step := 5;
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Initialize globle variable.
  --
  l_interim_tbl.delete;
  g_enrt_tbl.delete;
  g_comp_obj_cnt := 0;
  g_pl_tbl.delete;
  g_pl_cnt := 0;
  g_pl_typ_tbl.delete;
  g_pl_typ_cnt := 0;
  g_ptip_tbl.delete;
  g_ptip_cnt 		   := 0;
  g_tot_ee_lf_ins_amt	   := 0;
  g_tot_sps_lf_ins_amt   := 0;
  g_tot_dpnt_lf_ins_amt  := 0;

  g_tot_ee_lf_ins_amt_no   := 0;
  g_tot_sps_lf_ins_amt_no  := 0;
  g_tot_dpnt_lf_ins_amt_no := 0;

  g_mx_dpnt_pct_prtt_lf  := 0;
  g_mx_sps_pct_prtt_lf   := 0;
  --
  -- Open cursor.
  --
  -- The following loop stores all of the comp objects which are enrolled
  -- in as well as comp objects which are choices but are not enrolled in
  -- (I have just added the union to the g_c1 cursor for these choices)
  -- these rows are stored in the g_enrt_tbl to be used multiple times
  -- later on to summ up certain things.  The approach is:
  -- 1) get comp objects store in g_enrt_tbl
  -- 2) initialize some special non-db fields
  -- 3) get unique pl, ptip, pl_typ records and put in cache tables
  -- 4) total/count up the numbers
  --
  open g_enrolled
    (c_effective_date    => p_effective_date
    ,c_business_group_id => p_business_group_id
    ,c_person_id         => p_person_id
    ,c_pgm_id            => nvl(p_pgm_id, -999999)
    ,c_include_erl       => p_include_erl
    );
  loop
    fetch g_enrolled into g_enrt_tbl(g_comp_obj_cnt+1);
    exit when g_enrolled%notfound;
    g_comp_obj_cnt := g_comp_obj_cnt+1;
    --
    if g_enrt_tbl(g_comp_obj_cnt).pl_id is not null then
      --
      ben_cobj_cache.get_pl_dets
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_pl_id             => g_enrt_tbl(g_comp_obj_cnt).pl_id
        ,p_inst_row	     => l_plnrow
        );
      --
      g_enrt_tbl(g_comp_obj_cnt).dpnt_cvd_by_othr_apls_flag
      := l_plnrow.dpnt_cvd_by_othr_apls_flag;
      --
    end if;
    --
    if g_enrt_tbl(g_comp_obj_cnt).oipl_id is not null then
      --
      ben_cobj_cache.get_oipl_dets
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_oipl_id           => g_enrt_tbl(g_comp_obj_cnt).oipl_id
        ,p_inst_row	     => l_oiplrow
        );
      --
      g_enrt_tbl(g_comp_obj_cnt).opt_id := l_oiplrow.opt_id;
      --
    else
      --
      g_enrt_tbl(g_comp_obj_cnt).opt_id := null;
      --
    end if;
    --
    l_cnt := l_cnt + 1;
    --
    -- If enrollment is suspended and allow interim coverage, then copy
    -- interim prtt_enrt_rslt_id into l_interim_tbl.
    --
    if (nvl(g_enrt_tbl(g_comp_obj_cnt).SSPNDD_FLAG,'X') = 'Y'
      and g_enrt_tbl(g_comp_obj_cnt).RPLCS_SSPNDD_RSLT_ID is not NULL)
    then
      --
      l_interim_cnt := l_interim_cnt + 1;
      l_interim_tbl(l_interim_cnt) :=
      g_enrt_tbl(g_comp_obj_cnt).RPLCS_SSPNDD_RSLT_ID;
      --
    end if;
    --
  end loop;
  close g_enrolled;
  --
  open g_epenotenrolled
    (c_effective_date    => p_effective_date
    ,c_business_group_id => p_business_group_id
    ,c_person_id         => p_person_id
    ,c_pgm_id            => nvl(p_pgm_id, -999999)
    );
  loop
    fetch g_epenotenrolled into g_enrt_tbl(g_comp_obj_cnt+1);
    exit when g_epenotenrolled%notfound;
    g_comp_obj_cnt := g_comp_obj_cnt+1;
    --
    if g_enrt_tbl(g_comp_obj_cnt).oipl_id is not null then
      --
      ben_cobj_cache.get_oipl_dets
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_oipl_id           => g_enrt_tbl(g_comp_obj_cnt).oipl_id
        ,p_inst_row	     => l_oiplrow
        );
      --
      g_enrt_tbl(g_comp_obj_cnt).opt_id := l_oiplrow.opt_id;
      --
    else
      --
      g_enrt_tbl(g_comp_obj_cnt).opt_id := null;
      --
    end if;
    --
    l_cnt := l_cnt + 1;
    --
    -- If enrollment is suspended and allow interim coverage, then copy
    -- interim prtt_enrt_rslt_id into l_interim_tbl.
    --
    if (nvl(g_enrt_tbl(g_comp_obj_cnt).SSPNDD_FLAG,'X') = 'Y' and
        g_enrt_tbl(g_comp_obj_cnt).RPLCS_SSPNDD_RSLT_ID is not NULL)
    then
      --
      l_interim_cnt := l_interim_cnt + 1;
      l_interim_tbl(l_interim_cnt) :=
      g_enrt_tbl(g_comp_obj_cnt).RPLCS_SSPNDD_RSLT_ID;
      --
    end if;
    --
  end loop;
  close g_epenotenrolled;
  --
  -- Check which record is interim record. If it is Interim, then set
  -- interim flag to 'Y'
  --
  l_step := 20;
  For i in 1..g_comp_obj_cnt loop
      for j in 1..l_interim_cnt loop
          if g_enrt_tbl(i).prtt_enrt_rslt_id = l_interim_tbl(j) then
              g_enrt_tbl(i).interim_flag := 'Y';
              exit;
          end if;
      end loop;
  End loop;
  --
  -- If program ID is not Null then get program information and store it in
  -- g_pgm_rec
  --
  l_step := 30;
  if (p_pgm_id is not NULL) then
      open g_c_pgm(p_effective_date,
                   p_business_group_id,
                   p_pgm_id);
      fetch g_c_pgm into g_pgm_rec;
      if (g_c_pgm%notfound) then
          close g_c_pgm;
          fnd_message.set_name('BEN','BEN_91468_PGM_MISSING');
          fnd_message.set_token('ID', to_char(p_pgm_id));
          fnd_message.raise_error;
      end if;
      close g_c_pgm;
  end if;
  --
  l_step := 40;
  --
  l_dup_ptip_id_list.delete;
  l_dup_pl_typ_id_list.delete;
  l_dup_pl_id_list.delete;
  --
  for i in 1..g_comp_obj_cnt loop
      --
      -- Get all of the unique PTIPs and cache them.
      -- If some limits are null then override with values from pl_typ.
      --
      l_interim_calc := FALSE;
      --
      if g_enrt_tbl(i).ptip_id is not null
        and not ben_cache.check_list_duplicate
                (p_list => l_dup_ptip_id_list
                ,p_id   => g_enrt_tbl(i).ptip_id
                )
      then
        --
        open g_c_ptip(p_effective_date,
                      p_business_group_id,
                      g_enrt_tbl(i).ptip_id);
        fetch g_c_ptip into g_ptip_tbl(g_ptip_cnt+1);
        if (g_c_ptip%notfound) then
            close g_c_ptip;
            fnd_message.set_name('BEN','BEN_91462_PTIP_MISSING');
            fnd_message.set_token('ID', to_char(g_enrt_tbl(i).ptip_id) );
            fnd_message.raise_error;
        else
            g_ptip_cnt := g_ptip_cnt + 1;
            --
            -- if no_mx/mn_pl_typ_ov(e)rid_flag='N' and
            -- mx/mn_enrd_alwd/rqd_ovrid_num is null then can walk up
            -- hierarchy to get value from pl_typ
            --
            if ((g_ptip_tbl(g_ptip_cnt).no_mx_pl_typ_ovrid_flag='N' and
                 g_ptip_tbl(g_ptip_cnt).mx_enrd_alwd_ovrid_num is null)
                or (g_ptip_tbl(g_ptip_cnt).no_mn_pl_typ_overid_flag='N' and
                    g_ptip_tbl(g_ptip_cnt).mn_enrd_rqd_ovrid_num is null)
               ) then
                --
                -- Note: the pl_typ_rec is not stored as it is later,
                -- Just the override columns are used and stored over
                -- the null values at the ptip level.
                --
                open g_c_pl_typ(p_effective_date,
                                p_business_group_id,
                                g_enrt_tbl(i).pl_typ_id);
              fetch g_c_pl_typ into l_pl_typ_rec;
              if (g_c_pl_typ%notfound) then
                     close g_c_pl_typ;
                     fnd_message.set_name
                         ('BEN','BEN_91469_PL_TYP_MISSING');
                     fnd_message.set_token
                         ('ID',to_char(g_enrt_tbl(i).pl_typ_id) );
                     fnd_message.raise_error;
                end if;
                close g_c_pl_typ;
                 if (g_ptip_tbl(g_ptip_cnt).no_mn_pl_typ_overid_flag='N' and
                    g_ptip_tbl(g_ptip_cnt).mn_enrd_rqd_ovrid_num is null
                   ) then
                     g_ptip_tbl(g_ptip_cnt).MN_ENRD_RQD_OVRID_NUM :=
                                            l_pl_typ_rec.mn_enrl_rqd_num;
                end if;
                 if (g_ptip_tbl(g_ptip_cnt).no_mx_pl_typ_ovrid_flag='N' and
                    g_ptip_tbl(g_ptip_cnt).mx_enrd_alwd_ovrid_num is null
                   ) then
                     g_ptip_tbl(g_ptip_cnt).MX_ENRD_ALWD_OVRID_NUM :=
                                            l_pl_typ_rec.mx_enrl_alwd_num;
                end if;
            end if;
            if (g_ptip_tbl(g_ptip_cnt).sbj_to_sps_lf_ins_mx_flag = 'Y'
                or g_ptip_tbl(g_ptip_cnt).sbj_to_dpnt_lf_ins_mx_flag = 'Y'
                or g_ptip_tbl(g_ptip_cnt).use_to_sum_ee_lf_ins_flag = 'Y'
               ) then
                g_enrt_tbl(i).calc_interm := 1;
            end if;
            l_prev_ptip_id := g_enrt_tbl(i).ptip_id;
        end if;
        close g_c_ptip;
      elsif (g_enrt_tbl(i).ptip_id is not NULL) then
          if (g_ptip_tbl(g_ptip_cnt).sbj_to_sps_lf_ins_mx_flag = 'Y'
              or g_ptip_tbl(g_ptip_cnt).sbj_to_dpnt_lf_ins_mx_flag = 'Y'
              or g_ptip_tbl(g_ptip_cnt).use_to_sum_ee_lf_ins_flag = 'Y'
              ) then
              g_enrt_tbl(i).calc_interm := 1;
          end if;
      end if;
      --
      -- Get all unique plan types not in program.
      --
      l_step := 50;
      --
      if (not ben_cache.check_list_duplicate
                (p_list => l_dup_pl_typ_id_list
                ,p_id   => g_enrt_tbl(i).pl_typ_id
                )
        and g_enrt_tbl(i).pl_typ_id is not NULL
       -- and g_enrt_tbl(i).ptip_id is NULL
        )
      then
        open g_c_pl_typ(p_effective_date,
                          p_business_group_id,
                          g_enrt_tbl(i).pl_typ_id);
        fetch g_c_pl_typ into g_pl_typ_tbl(g_pl_typ_cnt+1);
          if (g_c_pl_typ%notfound) then
              close g_c_pl_typ;
              fnd_message.set_name('BEN','BEN_91469_PL_TYP_MISSING');
              fnd_message.set_token('ID', to_char(g_enrt_tbl(i).pl_typ_id));
              fnd_message.raise_error;
        else
              g_pl_typ_cnt := g_pl_typ_cnt +1;
              l_prev_pl_typ_id := g_enrt_tbl(i).pl_typ_id;
          end if;
          close g_c_pl_typ;
      end if;
      --
      l_step := 60;
      --
      -- Get the unique plan information and cache it.
      -- If rules exist execute them and cache the results.
      --
      if not ben_cache.check_list_duplicate
                (p_list => l_dup_pl_id_list
                ,p_id   => g_enrt_tbl(i).pl_id
                )
      then
        --
        open g_c_pl(p_effective_date
                   ,p_business_group_id
                   ,g_enrt_tbl(i).pl_id
                   );
        fetch g_c_pl into g_pl_tbl(g_pl_cnt + 1);
        if (g_c_pl%notfound) then
          close g_c_pl;
          fnd_message.set_name('BEN','BEN_91460_PLAN_MISSING');
          fnd_message.set_token('ID', to_char(g_enrt_tbl(i).pl_id));
          fnd_message.raise_error;
        else
          g_pl_cnt := g_pl_cnt + 1 ;
          --
          -- Bug 2715942 code addition for ben_ler_bnft_rstrn_f
          open c_ler(g_enrt_tbl(i).pl_id);
            fetch c_ler into l_ler_id ;
          close c_ler ;
          --
          open c_ler_rstrn(g_enrt_tbl(i).pl_id,l_ler_id);
            fetch c_ler_rstrn into l_ler_rstrn ;
            if c_ler_rstrn%found then
            g_pl_tbl(g_pl_cnt).mx_cvg_wcfn_amt          := l_ler_rstrn.mx_cvg_wcfn_amt  ;
            g_pl_tbl(g_pl_cnt).mx_cvg_incr_alwd_amt     := l_ler_rstrn.mx_cvg_incr_alwd_amt ;
            g_pl_tbl(g_pl_cnt).mx_cvg_incr_wcf_alwd_amt := l_ler_rstrn.mx_cvg_incr_wcf_alwd_amt ;
            g_pl_tbl(g_pl_cnt).mn_cvg_rqd_amt           := l_ler_rstrn.mn_cvg_rqd_amt ;
            g_pl_tbl(g_pl_cnt).mx_cvg_alwd_amt          := l_ler_rstrn.mx_cvg_alwd_amt ;
            g_pl_tbl(g_pl_cnt).mx_cvg_rl                := l_ler_rstrn.mx_cvg_rl ;
            g_pl_tbl(g_pl_cnt).mn_cvg_rl                := l_ler_rstrn.mn_cvg_rl ;
            end if ;
          close c_ler_rstrn ;
          -- End 2715942
          -- g_pl_cnt := g_pl_cnt + 1;
          --
          -- If mx_cvg_rl Rule exist, then override the mx cvg amt with
          -- the result of mx_cvg_rl rule.
          --
          if (g_pl_tbl(g_pl_cnt).mx_cvg_rl is not null) then
              g_pl_tbl(g_pl_cnt).mx_cvg_alwd_amt :=
                                        calc_mx_amt
					(p_mx_cvg_rl      => g_pl_tbl(g_pl_cnt).mx_cvg_rl
					,p_assignment_id  => p_assignment_id
					,p_effective_date => p_effective_date
					-- 3427367
					,p_business_group_id => p_business_group_id
					,p_pgm_id            => g_enrt_tbl(i).pgm_id
					,p_pl_id             => g_pl_tbl(g_pl_cnt).pl_id
					,p_pl_typ_id         => g_pl_tbl(g_pl_cnt).pl_typ_id
					,p_opt_id            => g_enrt_tbl(i).opt_id
					,p_ler_id	     => l_ler_id
					,p_prtt_enrt_rslt_id => g_enrt_tbl(i).prtt_enrt_rslt_id  -- 3427367
					,p_person_id         => p_person_id                      -- Bug 5331889
					);
          end if;
          g_pl_tbl(g_pl_cnt).ptip_id := g_enrt_tbl(i).ptip_id;
          --
          -- If mn_cvg_rl Rule exist, then override the mn cvg amt with
          -- result of mn_cvg_rl rule.
          --
          if (g_pl_tbl(g_pl_cnt).mn_cvg_rl is not null) then
              g_pl_tbl(g_pl_cnt).mn_cvg_rqd_amt :=
                                                calc_mn_amt
						(p_mn_cvg_rl       => g_pl_tbl(g_pl_cnt).mn_cvg_rl
						,p_assignment_id  => p_assignment_id
						,p_effective_date => p_effective_date
						-- 3427367
						,p_business_group_id => p_business_group_id
						,p_pgm_id            => g_enrt_tbl(i).pgm_id
						,p_pl_id             => g_pl_tbl(g_pl_cnt).pl_id
						,p_pl_typ_id         => g_pl_tbl(g_pl_cnt).pl_typ_id
						,p_opt_id            => g_enrt_tbl(i).opt_id
						,p_ler_id	     => l_ler_id
						,p_prtt_enrt_rslt_id => g_enrt_tbl(i).prtt_enrt_rslt_id  --3427367
						,p_person_id         => p_person_id                      -- Bug 5331889
						);

          end if;
          l_prev_pl_id := g_enrt_tbl(i).pl_id;
          --
          if g_pl_tbl(g_pl_cnt).mx_cvg_incr_alwd_amt is not null then
            --
            -- Get prev coverage amt on plan level.  Current, the process
            -- assume there is no Interim and suspended records for
            -- previous period.
            --
            open l_c_prev_pl(l_prev_pl_id);
            fetch l_c_prev_pl into g_pl_tbl(g_pl_cnt).prev_cvg_amt;
            if (l_c_prev_pl%notfound) then
              close l_c_prev_pl;
              g_pl_tbl(g_pl_cnt).prev_cvg_amt := 0;
            end if;
            close l_c_prev_pl;
            --
          end if;
          --
        end if;
        --
        close g_c_pl;
        --
      end if;
  end loop;
  --
  l_step := 70;
  --
  -- Create a table of enrollments for each plan then call get_opts_and_cvg
  -- to compute max and min enrollments.
  -- Ignore rows where the prtt_enrt_rslt_id is null since they are not
  -- enrolled.  Just want to pick up the fact that there was 0 enrollments
  --
  for i in 1..g_pl_cnt loop
      l_enrt_cnt := 0;
      l_enrt_tbl.delete;
      --
      for j in 1..g_comp_obj_cnt loop
          if (g_enrt_tbl(j).pl_id = g_pl_tbl(i).pl_id and
              g_enrt_tbl(j).prtt_enrt_rslt_id is not null) then
              l_enrt_cnt := l_enrt_cnt + 1;
              l_enrt_tbl(l_enrt_cnt) := g_enrt_tbl(j);
          end if;
      end loop;
      If (l_enrt_cnt > 0) then
          hr_utility.set_location('Before g_pl_tbl(i).tot_cvg_amt '||g_pl_tbl(i).tot_cvg_amt,1234);
          get_opts_and_cvg
                   (p_enrt_tbl  => l_enrt_tbl
                   ,p_enrt_cnt  => l_enrt_cnt
                   ,p_tot_amt   => g_pl_tbl(i).tot_cvg_amt
                   ,p_tot_opts  => g_pl_tbl(i).tot_opt_enrld
                   );
           hr_utility.set_location('After g_pl_tbl(i).tot_cvg_amt '||g_pl_tbl(i).tot_cvg_amt,1234);
     end if;
     --
  end loop;
  --
  l_step := 80;
  --
  --
  -- Create a table of enrollments for each ptip then call get_pls_and_cvg
  -- to compute max and min enrollments.
  -- Ignore rows where the prtt_enrt_rslt_id is null since they are not
  -- enrolled.  Just want to pick up the fact that there was 0 enrollments
  --
  for i in 1..g_ptip_cnt loop
      l_enrt_cnt := 0;
      l_enrt_tbl.delete;
      for j in 1..g_comp_obj_cnt loop
          -- Bug No. 6454197 Added code to enforce limitation for enrollment at plantype
          if (g_enrt_tbl(j).ptip_id = g_ptip_tbl(i).ptip_id and
              g_enrt_tbl(j).prtt_enrt_rslt_id is not null
	      and g_enrt_tbl(j).enrt_cvg_thru_dt = hr_api.g_eot) then
              l_enrt_cnt := l_enrt_cnt + 1;
              l_enrt_tbl(l_enrt_cnt) := g_enrt_tbl(j);
          end if;
      end loop;
      If (l_enrt_cnt > 0) then
        get_pls_and_cvg
          (p_enrt_tbl => l_enrt_tbl
          ,p_enrt_cnt => l_enrt_cnt
          ,p_tot_amt  => g_ptip_tbl(i).tot_cvg_amt
          ,p_tot_pls  => g_ptip_tbl(i).tot_pl_enrld
          ,p_dpnt_cvd_by_othr_apls_flag  => g_ptip_tbl(i).dpnt_cvd_by_othr_apls_flag
          ,p_tot_amt_no_interim => g_ptip_tbl(i).tot_cvg_amt_no_interim
          );
        hr_utility.set_location('After get_pls_and_cvg 1'||g_ptip_tbl(i).tot_cvg_amt,111);
        hr_utility.set_location('After tot_cvg_no_interim'||g_ptip_tbl(i).tot_cvg_amt_no_interim,111);

     End if;
  end loop;
  --
  l_step := 90;
  --
  --
  -- Create a table of enrollments for each pl typ then call get_pls_and_cvg
  -- to compute max and min enrollments.
  -- Ignore rows where the prtt_enrt_rslt_id is null since they are not
  -- enrolled.  Just want to pick up the fact that there was 0 enrollments
  --
  -- bug#3480144
  if p_pgm_id is not null then
     open other_pgm_enrolled (c_effective_date    => p_effective_date
                             ,c_business_group_id => p_business_group_id
                             ,c_person_id         => p_person_id
                             ,c_pgm_id            => p_pgm_id
                             );
     l_enrt_cnt := 0;
     loop
       fetch other_pgm_enrolled into l_enrt_tbl2(l_enrt_cnt+1);
       if other_pgm_enrolled%notfound then
          exit;
       end if;
       l_enrt_cnt := l_enrt_cnt+1;
     end loop;
     close other_pgm_enrolled;
  end if;
  for i in 1..g_pl_typ_cnt loop
      l_enrt_cnt := 0;
      l_enrt_tbl.delete;
      for j in 1..g_comp_obj_cnt loop
          if (g_enrt_tbl(j).pl_typ_id = g_pl_typ_tbl(i).pl_typ_id
              /*and g_enrt_tbl(j).ptip_id is null */ and
              g_enrt_tbl(j).prtt_enrt_rslt_id is not null) then
              l_enrt_cnt := l_enrt_cnt + 1;
              l_enrt_tbl(l_enrt_cnt) := g_enrt_tbl(j);
          end if;
      end loop;
      -- bug#3480144
      if l_enrt_tbl2.count > 0 then
           for j in 1..l_enrt_tbl2.count loop
             if (l_enrt_tbl2(j).pl_typ_id = g_pl_typ_tbl(i).pl_typ_id
                 and l_enrt_tbl2(j).prtt_enrt_rslt_id is not null) then
              l_enrt_cnt := l_enrt_cnt + 1;
              l_enrt_tbl(l_enrt_cnt) := l_enrt_tbl2(j);
             end if;
          end loop;
      end if;
      --
      If (l_enrt_cnt > 0) then
        get_pls_and_cvg
          (p_enrt_tbl => l_enrt_tbl
          ,p_enrt_cnt => l_enrt_cnt
          ,p_tot_amt  => g_pl_typ_tbl(i).tot_cvg_amt
          ,p_tot_pls  => g_pl_typ_tbl(i).tot_pl_enrld
          ,p_dpnt_cvd_by_othr_apls_flag  => g_pl_typ_tbl(i).dpnt_cvd_by_othr_apls_flag
          ,p_tot_amt_no_interim =>  g_pl_typ_tbl(i).tot_cvg_amt_no_interim
          );
        hr_utility.set_location('AfterPLTYP get_pls_and_cvg 2'||g_pl_typ_tbl(i).tot_cvg_amt,111);
        hr_utility.set_location('After tot_cvg_no_interim'||g_pl_typ_tbl(i).tot_cvg_amt_no_interim,111);
      End if;
  end loop;
  --
  l_step := 100;
  --
  hr_utility.set_location('Leaving:'||l_proc,500);
Exception
    when others then
        hr_utility.set_location('Fail in '|| l_proc|| ' at step ' ||
                                to_char(l_step), 999);
        if g_c_pgm%isopen then
            close g_c_pgm;
        end if;
        if g_c_ptip%isopen then
            close g_c_ptip;
        end if;
        if g_c_pl_typ%isopen then
            close g_c_pl_typ;
        end if;
        if g_c_pl%isopen then
            close g_c_pl;
        end if;
        raise;
end;
--
-- ----------------------------------------------------------------------------
--                     |------<get_plan_name >------|
-- ----------------------------------------------------------------------------
--
function get_plan_name
  (p_pl_id               in     number
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  )
return varchar2
is
  --
  l_pl_rec              ben_cobj_cache.g_pl_inst_row;
/*
  l_pl_rec   ben_pl_f%rowtype;
*/
  --
begin
  --
  ben_cobj_cache.get_pl_dets
    (p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    ,p_pl_id             => p_pl_id
    ,p_inst_row	         => l_pl_rec
    );
  --
/*
  ben_comp_object.get_object(p_pl_id => p_pl_id,
                             p_rec => l_pl_rec);
*/
  return l_pl_rec.name;
  --
end;
--
-- ----------------------------------------------------------------------------
--                     |------<p_eva_rule_output >------|
-- ----------------------------------------------------------------------------
--
Procedure p_eva_rule_output(p_rule_returns ff_exec.outputs_t,
                            p_proc varchar2,
                            p_rule_id number) is
  l_successful varchar2(30);
  l_error_message varchar2(240);
begin
  --
  -- Load the rule into the required variables
  --
  if p_rule_returns.exists(1) then
     --
     for l_count in p_rule_returns.first..p_rule_returns.last loop
          --
          begin
            --
            if p_rule_returns(l_count).name = 'SUCCESSFUL' then
              --
              l_successful := p_rule_returns(l_count).value;
              --
            elsif p_rule_returns(l_count).name = 'ERROR_MESSAGE' then
              --
              l_error_message := p_rule_returns(l_count).value;
              --
            else
              --
              -- Account for cases where formula returns an unknown
              -- variable name
              --
              fnd_message.set_name('BEN', 'BEN_92310_FORMULA_RET_PARAM');
              fnd_message.set_token('PROC', p_proc);
              fnd_message.set_token('FORMULA', p_rule_id);
              fnd_message.set_token('PARAMETER', p_rule_returns(l_count).name);
              fnd_message.raise_error;
              --
            end if;
            --
            -- Code for type casting errors from formula return variables
            --
          exception
            --
            when others then
              --
              fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
              fnd_message.set_token('PROC',p_proc);
              fnd_message.set_token('FORMULA',p_rule_id);
              fnd_message.set_token('PARAMETER',p_rule_returns(l_count).name);
              fnd_message.raise_error;
            --
          end;
          --
     end loop;
     --
     if l_successful <> 'Y' then
          --
          fnd_message.set_name('BEN','BEN_92187_POST_ELCN_NOT_PASS');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          fnd_message.raise_error;
          --
     end if;
     --
  end if;
  --
end p_eva_rule_output;
--
-- ----------------------------------------------------------------------------
--                     |------<chk_post_elcn_rl >------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_post_elcn_rl
                   (p_pgm_id                 number
                   ,p_pl_id                  number
                   ,p_pl_typ_id              number
                   ,p_opt_id                 number
                   ,p_person_id              number
                   ,p_business_group_id      number
                   ,p_effective_date         date
                   ,p_pl_post_edit_rl        number
                   ,p_plip_post_edit_rl      number
                   ,p_ptip_post_edit_rl      number
                   ,p_oipl_post_edit_rl      number
                   ) is

  Cursor c_state is
  select loc.region_2, asg.assignment_id, asg.organization_id
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id(+) = asg.location_id
  and asg.person_id = p_person_id
  and asg.assignment_type <> 'C'
  and asg.primary_flag = 'Y'
  and p_effective_date between asg.effective_start_date and asg.effective_end_date
  and asg.business_group_id = p_business_group_id
  order by DECODE(asg.assignment_type,'E',1,'B',2,3); -- 5303252 Order by asg_type

  l_state c_state%rowtype;
  l_rule_returns ff_exec.outputs_t;
  l_proc    varchar2(80) := g_package || '.chk_post_elcn_rl';
  l_jurisdiction_code     varchar2(30);

  --
Begin
  --
  hr_utility.set_location('Entering - '||l_proc, 5);
  --
  --
  if p_oipl_post_edit_rl is not null or
     p_pl_post_edit_rl is not null or
     p_ptip_post_edit_rl is not null or
     p_plip_post_edit_rl is not null then
    --
    if p_person_id is not null then

      open c_state;

        fetch c_state into l_state;

      close c_state;

--      if l_state.region_2 is not null then
--        l_jurisdiction_code :=
--           pay_mag_utils.lookup_jurisdiction_code
--             (p_state => l_state.region_2);
--      end if;

    end if;
    --
  end if;

  hr_utility.set_location('l_state.assignment_id '|| l_state.assignment_id , 5);

  if p_oipl_post_edit_rl is not null then
    --
    l_rule_returns :=
      benutils.formula
        (p_formula_id        => p_oipl_post_edit_rl,
         p_assignment_id     => l_state.assignment_id,
         p_business_group_id => p_business_group_id,
         p_organization_id   => l_state.organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_opt_id            => p_opt_id,
         p_jurisdiction_code => l_jurisdiction_code,
         p_effective_date    => p_effective_date,
	 p_param1            => 'BEN_IV_PERSON_ID',        -- Bug 5331889
         p_param1_value      => to_char(p_person_id)
	 );
    --
    p_eva_rule_output(p_rule_returns => l_rule_returns,
                      p_proc         => l_proc,
                      p_rule_id      => p_oipl_post_edit_rl);
  end if;
  --
  if p_pl_post_edit_rl is not null then
    --
    l_rule_returns :=
      benutils.formula
        (p_formula_id        => p_pl_post_edit_rl,
         p_assignment_id     => l_state.assignment_id,
         p_business_group_id => p_business_group_id,
         p_organization_id   => l_state.organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_opt_id            => p_opt_id,
         p_jurisdiction_code => l_jurisdiction_code,
         p_effective_date    => p_effective_date,
	 p_param1            => 'BEN_IV_PERSON_ID',        -- Bug 5331889
         p_param1_value      => to_char(p_person_id));
    --
    p_eva_rule_output(p_rule_returns => l_rule_returns,
                      p_proc         => l_proc,
                      p_rule_id      => p_pl_post_edit_rl);
  end if;
  --
  if p_plip_post_edit_rl is not null then
    --
    l_rule_returns :=
      benutils.formula
        (p_formula_id        => p_plip_post_edit_rl,
         p_assignment_id     => l_state.assignment_id,
         p_business_group_id => p_business_group_id,
         p_organization_id   => l_state.organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_opt_id            => p_opt_id,
         p_jurisdiction_code => l_jurisdiction_code,
         p_effective_date    => p_effective_date,
	 p_param1            => 'BEN_IV_PERSON_ID',        -- Bug 5331889
         p_param1_value      => to_char(p_person_id));
    --
    p_eva_rule_output(p_rule_returns => l_rule_returns,
                      p_proc         => l_proc,
                      p_rule_id      => p_plip_post_edit_rl);
  end if;
  --
  if p_ptip_post_edit_rl is not null then
    --
    l_rule_returns :=
      benutils.formula
        (p_formula_id        => p_ptip_post_edit_rl,
         p_assignment_id     => l_state.assignment_id,
         p_business_group_id => p_business_group_id,
         p_organization_id   => l_state.organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_opt_id            => p_opt_id,
         p_jurisdiction_code => l_jurisdiction_code,
         p_effective_date    => p_effective_date,
	 p_param1            => 'BEN_IV_PERSON_ID',        -- Bug 5331889
         p_param1_value      => to_char(p_person_id));
    --
    p_eva_rule_output(p_rule_returns => l_rule_returns,
                      p_proc         => l_proc,
                      p_rule_id      => p_ptip_post_edit_rl);
  end if;
  --
  hr_utility.set_location('Leaving - '||l_proc, 10);
  --
End Chk_post_elcn_rl;
--
-- ----------------------------------------------------------------------------
--                     |------<check_mandatory_comp_object >------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_mndtry_comp_obj
                   (p_person_id             Number
                   ,p_pgm_id                Number
                   ,p_business_group_id     Number
                   ,p_effective_date        Date
                   ) is
  Cursor c1 is
      select null
        from ben_elig_per_elctbl_chc
       where business_group_id = p_business_group_id
         and nvl(pgm_id,hr_api.g_number) = nvl(p_pgm_id, hr_api.g_number)
         and MNDTRY_FLAG = 'Y'
         and pl_id in  -- bug 1207161 removed 'not'
               (Select distinct pen.pl_id
                  From ben_prtt_enrt_rslt_f pen
                 Where nvl(pen.enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
                   and p_effective_date between
                         pen.effective_start_date and pen.effective_end_date
                   and pen.effective_end_date = hr_api.g_eot
                   and pen.person_id = p_person_id
                   and nvl(pen.pgm_id,-1) = nvl(p_pgm_id,-1)
                   and pen.prtt_enrt_rslt_stat_cd is null)
         and oipl_id not in  -- bug 1207161 added this.
               (Select distinct nvl(pen.oipl_id, -1)
                  From ben_prtt_enrt_rslt_f pen
                 Where nvl(pen.enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
                   and p_effective_date between
                         pen.effective_start_date and pen.effective_end_date
                   and pen.effective_end_date = hr_api.g_eot
                   and pen.person_id = p_person_id
                   and nvl(pen.pgm_id,-1) = nvl(p_pgm_id,-1)
                   and pen.prtt_enrt_rslt_stat_cd is null)
         and per_in_ler_id in (select per_in_ler_id
                                 From ben_per_in_ler
                                Where person_id = p_person_id
                                  and per_in_ler_stat_cd = 'STRTD'
                                  and business_group_id = p_business_group_id
                              )
             ;
  l_dump    number(15);
  l_proc    varchar2(80) := g_package || '.chk_mndtry_comp_obj';
Begin
   hr_utility.set_location('Entering - '||l_proc, 5);

   -- Check that mandatory options are enrolled in.
   -- These are options that you MUST be enrolled in, IF you are
   -- enrolled in the plan at all.
   open c1;
   fetch c1 into l_dump;
   If c1%found then
       close c1;
       fnd_message.set_name('BEN', 'BEN_91962_MNDTRY_OBJ_NOT_ENRLD');
       fnd_message.raise_error;
   End if;
   close c1;
   hr_utility.set_location('Leaving - '||l_proc, 10);
End;
--
--
-- ----------------------------------------------------------------------------
--                     |------<Manage_person_type_usage >------|
-- ----------------------------------------------------------------------------
--
Procedure manage_per_type_usages
                      (p_person_id 			 number
                      ,p_business_group_id   number
                      ,p_effective_date      date
                      ) is
   -- RCHASE - rewritten for wwBug 1433274
   cursor c_pen is
   select distinct Enrt_Cvg_Strt_Dt CSD
         ,nvl(Enrt_Cvg_thru_Dt,hr_api.g_eot) CED
         ,'N' Match
     from ben_prtt_enrt_rslt_f
    where person_id = p_person_id
      and effective_end_date >= enrt_cvg_strt_dt
      and enrt_cvg_strt_dt <= nvl(Enrt_Cvg_thru_Dt,hr_api.g_eot)  --bug 5257798
      and prtt_enrt_rslt_stat_cd is null
      and sspndd_flag = 'N'
      and effective_end_date = hr_api.g_eot  -- Bug 2130842 added this clause
    order by 1 asc, 2 desc;
   --
   l_person_type_id        per_person_type_usages_f.person_type_id%type:=null;
   --
   cursor c_ptu is
   select a.person_type_usage_id
         ,a.person_type_id
         ,a.effective_start_date ESD
         ,a.effective_end_date EED
         ,a.object_version_number OVN
         ,'N' Match
    from per_person_type_usages_f a
   where a.Person_id = p_person_id
     and a.person_type_id = l_person_type_id
   order by a.effective_start_date asc, a.effective_end_date desc;
   --
   cursor c_pt is
   select person_type_id
     from per_person_types
    where system_person_type = 'PRTN'
      and business_group_id = p_business_group_id;
  --
   type pen_record is table of c_pen%rowtype index by binary_integer;
   type ptu_record is table of c_ptu%rowtype index by binary_integer;
   l_pen           pen_record;
   l_ptu           ptu_record;
   l_person_type_usage_id  per_person_type_usages_f.person_type_usage_id%type;
   l_object_version_number per_person_type_usages_f.object_version_number%type;
   l_esd per_person_type_usages_f.effective_start_date%type;
   l_eed per_person_type_usages_f.effective_end_date%type;
   l_next_ptu number:=1;
   l_next_pen number:=1;
   --
   e_no_pt exception;
   e_no_pen exception;
   l_proc varchar2(80) := g_package||'.manage_per_type_usages';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   -- Get participant person type id
   for r_pt in c_pt loop
      l_person_type_id := r_pt.person_type_id;
   end loop;
   if l_person_type_id is null then
      fnd_message.set_name('BEN','BEN_92468_PERSON_TYP_NOT_FOUND');
      fnd_message.raise_error;
   end if;
   -- Fetch enrollment results and create a distinct number or inclusive date records
   for r_pen in c_pen loop
      if l_pen.count > 0 then
         if r_pen.csd-1 >= l_pen(l_pen.count).ced then
            l_pen(l_pen.count+1) := r_pen;
         else
            if r_pen.ced > l_pen(l_pen.count).ced then
               l_pen(l_pen.count).ced := r_pen.ced;
            end if;
         end if;
      else
         l_pen(l_pen.count+1) := r_pen;
      end if;
   end loop;

   -- Fetch all participant person type usage records
   for r_ptu in c_ptu loop
      l_ptu(l_ptu.count+1) := r_ptu;
   end loop;

   hr_utility.set_location('counts prn : '||l_pen.count || ' PTU :' || l_ptu.count,90);
   if l_pen.count = 0 then
      -- if there is no enrollment result,
      -- 2899702  check for  per type usage if both 0
      --  no need to process person type usage records
      --  or delete all the person_type usage of prtn
      --  when  all  enrollment is backed out
      if  l_ptu.count > 0 then
         for j in 1..l_ptu.count loop
             hr_per_type_usage_internal.delete_person_type_usage
                (p_validate              => FALSE
                 ,p_person_type_usage_id  => l_ptu(j).person_type_usage_id
                 ,p_effective_date        => l_ptu(j).ESD
                 ,p_datetrack_mode        => hr_api.g_zap
                 ,p_object_version_number => l_ptu(j).OVN
                 ,p_effective_start_date  => l_esd
                 ,p_effective_end_date    => l_eed);
         end loop; -- zap person type usage loop
      end if ;
       hr_utility.set_location('Leaving betwen '||l_proc,90);

      return;
   end if;

   if l_ptu.count > 0 then
      -- Compare date ranges, find exact matches
      if l_pen(1).csd <> l_ptu(1).esd and l_pen(1).ced <> l_ptu(1).eed then
         null; -- first records do not match, all will be zapped and rebuilt
      else
         for i in 1..l_pen.count loop
            for j in l_next_ptu..l_ptu.count loop
               if l_pen(i).csd=l_ptu(j).esd and l_pen(i).ced=l_ptu(j).eed then
                  l_pen(i).match := 'Y';
                  l_ptu(j).match := 'Y';
                  l_next_ptu := j+1;
                  exit;
               end if;
            end loop; -- person type usage loop
            if l_pen(i).match <> 'Y' then
               exit; -- must zap remaining person type records and rebuild
            end if;
         end loop; -- enrollment loop
      end if;
      -- Remove person type usage records that did not match
      for j in 1..l_ptu.count loop
         if l_ptu(j).match = 'N' then
            hr_per_type_usage_internal.delete_person_type_usage
               (p_validate              => FALSE
               ,p_person_type_usage_id  => l_ptu(j).person_type_usage_id
               ,p_effective_date        => l_ptu(j).ESD
               ,p_datetrack_mode        => hr_api.g_zap
               ,p_object_version_number => l_ptu(j).OVN
               ,p_effective_start_date  => l_esd
               ,p_effective_end_date    => l_eed);
         end if;
      end loop; -- zap person type usage loop
      -- Create person type usage records for unmatched enrollment records
   end if;
   for i in 1..l_pen.count loop
      if l_pen(i).match = 'N' then
         hr_per_type_usage_internal.create_person_type_usage
            (p_validate              => FALSE
            ,p_person_id             => p_person_id
            ,p_person_type_id        => l_person_type_id
            ,p_person_type_usage_id  => l_person_type_usage_id
            ,p_effective_date        => l_pen(i).csd
            ,p_object_version_number => l_object_version_number
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed);
         -- if the enrollment record does not go to end of time
         -- make sure to end date the person type usage row
         if l_pen(i).ced <> hr_api.g_eot then
            hr_per_type_usage_internal.delete_person_type_usage
               (p_validate              => FALSE
               ,p_person_type_usage_id  => l_person_type_usage_id
               ,p_effective_date        => l_pen(i).ced
               ,p_datetrack_mode        => hr_api.g_delete
               ,p_object_version_number => l_object_version_number
               ,p_effective_start_date  => l_esd
               ,p_effective_end_date    => l_eed);
         end if;
      end if;
   end loop; -- create person type usage loop
   hr_utility.set_location('Leaving '||l_proc,90);
   exception
      when e_no_pt then
         hr_utility.set_location('Leaving '||l_proc||' No person type found.',100);
         raise;
      when e_no_pen then
         hr_utility.set_location('Leaving '||l_proc||' No enrollments found.',110);
         raise;
      when others then
         hr_utility.set_location('Leaving '||l_proc||' When others fired.',120);
         raise;
End;
--
-- ----------------------------------------------------------------------------
--                        << Susp_Svg_pl_opts >>                              |
-- ----------------------------------------------------------------------------
-- Description
--   This procedure will unsuspend the rest of options for a plan that has
--   Enrt_pl_opt_flag set on
--
-- ============================================================================
--
Procedure susp_svg_pl_opts
            (p_person_id          in number
            ,p_effective_date     in date
            ,p_business_group_id  in number
            ,p_pgm_id             in number
            ) is
    --
    Cursor c1 is
        select distinct b.per_in_ler_id, b.ler_id, b.pl_id
          From ben_prtt_enrt_rslt_f b
              ,ben_pl_f c
         Where b.person_id = p_person_id
           And nvl(b.pgm_id,-1) = nvl(p_pgm_id,-1)
           And p_effective_date between
                   b.effective_start_date and b.effective_end_date
           And b.business_group_id=p_business_group_id
           And b.enrt_cvg_strt_dt < nvl(b.effective_end_date,hr_api.g_eot)
           And b.oipl_id is NULL
           and b.prtt_enrt_rslt_stat_cd is null
           And b.sspndd_flag = 'Y'
           And b.pl_id = c.pl_id
           And p_effective_date between
                   c.effective_start_date and c.effective_end_date
           And c.enrt_pl_opt_flag = 'Y'
              ;
    --
    Cursor c2 (c_pl_id number) is
      Select a.prtt_enrt_rslt_id
            ,a.effective_start_date
            ,a.effective_end_date
            ,a.object_version_number
        From ben_prtt_enrt_rslt_f a
       Where a.person_id = p_person_id
         And nvl(a.pgm_id,-1) = nvl(p_pgm_id,-1)
         And a.business_group_id=p_business_group_id
         And p_effective_date between
                 a.effective_start_date and a.effective_end_date
         And a.enrt_cvg_strt_dt < nvl(a.effective_end_date, hr_api.g_eot)
         And a.oipl_id is not null
         and a.prtt_enrt_rslt_stat_cd is null
         And a.sspndd_flag = 'N'
         And a.pl_id = c_pl_id
            ;
    --
    -- Variables declaration
    --
    l_proc              varchar2(72) := g_package||'susp_svg_pl_opts';
    l_step              integer;
    l_datetrack_mode    varchar2(30);
--
Begin
  hr_utility.set_location('Entering' || l_proc,5);
  --
  -- C1 is cursor is pull out all suspended plan with in program that user
  -- specified and cursor c2 is cursor to pull out all options are not suspended
  -- within the plan.
  --
  l_step := 100;
  For l_rec1 in c1 loop
      l_step := trunc(l_step,-1)  + 10;
      For l_rec in c2(l_rec1.pl_id) Loop
          If (p_effective_date = l_rec.effective_start_date ) then
              l_datetrack_mode := hr_api.g_correction;
          Else
              l_datetrack_mode := hr_api.g_update;
          end if;
          --
          -- Noted:
          --   the following call need to changed to call suspended process after
          --   suspend process completed.
          --
          BEN_PRTT_ENRT_RESULT_API.Update_PRTT_ENRT_RESULT
              (p_validate              => FALSE
              ,p_prtt_enrt_rslt_id     => l_rec.prtt_enrt_rslt_id
              ,p_per_in_ler_id         => l_rec1.per_in_ler_id
              ,p_ler_id                => l_rec1.ler_id
              ,p_effective_start_date  => l_rec.effective_start_date
              ,p_effective_end_date    => l_rec.effective_end_date
              ,p_business_group_id     => p_business_group_id
              ,p_object_version_number => l_rec.object_version_number
              ,p_datetrack_mode        => l_datetrack_mode
              ,p_sspndd_flag           => 'Y'
              ,p_effective_date        => p_effective_date
              );
      End loop;
  End loop;
  hr_utility.set_location('Leaving' || l_proc,10);
Exception
    when others then
        hr_utility.set_location('Fail at '||l_proc||' step - '||
                                to_char(l_step),999);
        raise;
End;
--
--
-- ----------------------------------------------------------------------------
--                     |------<multi_row_edit >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to cached all programs, plan types, plans for
--   a specified person_id..
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   person_id             Person ID.
--   effective_date        effective date.
--   p_business_group_id   Business Group ID.
--   p_pgm_id              Program ID If NULL then it means Plan not in
--                         program.
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
Procedure multi_rows_edit
        	(p_person_id        	in number
                ,p_effective_date       in date
                ,p_business_group_id    in number
                ,p_pgm_id               in number
                ,p_include_erl          in varchar2
 		    ) is
  cursor c_paf is
     select assignment_id
       from per_all_assignments_f
      where person_id = p_person_id
        and assignment_type <> 'C'
        and primary_flag = 'Y'
        and p_effective_date between
              effective_start_date and effective_end_date
        and business_group_id =	p_business_group_id
        order by assignment_type desc, effective_start_date desc ; -- bug 4124110
  --
  cursor c_pl_name(cv_pl_id number) is
     select pln.name
     from ben_pl_f pln
     where pln.pl_id = cv_pl_id
       and pln.business_group_id = p_business_group_id;
  --

  --Bug 2390734 Changed the join condition to compare OPT.OPT_ID with OIPL.OPT_ID.(Intially it was being compared with itself)
  cursor c_opt_name(cv_oipl_id in number) is
     select ' : ' || opt.name
     from ben_oipl_f oipl,
          ben_opt_f  opt
     where oipl.oipl_id = cv_oipl_id
       and opt.opt_id = oipl.opt_id            --Bug 2390734
       and opt.business_group_id = p_business_group_id
       and oipl.business_group_id = p_business_group_id;
  --
  cursor c_erl (p_pl_typ_id number) is
    select 'Y'
    from ben_prtt_enrt_rslt_f pen,
         ben_enrt_bnft enb
    where pen.person_id          = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and enrt_cvg_thru_dt = hr_api.g_eot
    and pen.comp_lvl_cd <> 'PLANIMP'
    and pen.prtt_enrt_rslt_id = enb.prtt_enrt_rslt_id
    and pen.pgm_id =  p_pgm_id
    and pen.pl_typ_id = p_pl_typ_id
    and enb.cvg_mlt_cd = 'ERL'
    and pen.effective_end_date = hr_api.g_eot;
  --
  i                 binary_integer :=0;
  j                 binary_integer :=0;
  l_pl_notfnd 	    boolean :=TRUE;
  l_init_flag 	    boolean :=TRUE;
  l_prev_opt_id     ben_oipl_f.opt_id%type := 0;
  l_status          boolean;
  l_step            integer;
  l_proc            varchar2(72) := g_package||'multi_rows_edit';
  l_prev_oipl_id    number := -999999;
  l_prev_ptip_name  ben_pl_typ_f.name%type; -- UTF8 Change Bug 2254683
  l_prev_pl_id      number := -999999;
  l_prev_cvg_strt_dt date;
  l_prev_cvg_end_dt  date;
  l_assignment_id   per_assignments_f.assignment_id%type;
  l_increase        number;
  l_plan_opt_names   varchar2(3000); --UTF8 Change Bug 2254683
  l_chk_pln_cvg_lmts  boolean;
  --
  -- Bug 2162121
  --
  l_ptip_tbl_ct         number := g_ptip_tbl.count;
  l_plan_name        ben_pl_f.name%type; -- UTF8 Change Bug 2254683
  l_option_name      ben_opt_f.name%type; -- UTF8 Change Bug 2254683
  --
  l_pl_rec          ben_cobj_cache.g_pl_inst_row;
/*
  l_pl_rec          ben_pl_f%rowtype;
*/
  l_oipl_rec        ben_cobj_cache.g_oipl_inst_row;
/*
  l_oipl_rec        ben_oipl_f%rowtype;
*/
  l_plip_rec        ben_cobj_cache.g_plip_inst_row;
/*
  l_plip_rec        ben_plip_f%rowtype;
*/
  l_ptip_rec        ben_cobj_cache.g_ptip_inst_row;
/*
  l_ptip_rec        ben_ptip_f%rowtype;
*/
  l_erl             varchar2(30);

  --
begin
    hr_utility.set_location(l_proc,5);
    --
    -- suspended all suspended saving plan's options.
    --
    l_step := 5;
    susp_svg_pl_opts
                (p_person_id          => p_person_id
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                ,p_pgm_id             => p_pgm_id
                );
    --
    -- Retrieve asignment id from per_assignment_f.
    --
    l_step := 10;
    open c_paf;
    fetch c_paf into l_assignment_id;
    if (c_paf%notfound) then
       close c_paf;
       fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
       fnd_message.set_token('ID' , to_char(p_person_id));
        --Bug#  2261610
       fnd_message.set_token('PROC' , l_proc);
       fnd_message.raise_error;
    end if;
    close c_paf;
    --
           hr_utility.set_location('l_assignment_id is :-'||l_assignment_id  ,1234);
    -- Cache all comp objects belong to a specified person_id for a
    -- specified program or all program dependent on p_chk_all_pgm_flg,
    -- If Yes, then all program will be cached, otherwise, only the pgm_id
    -- is specified.
    --
    l_step := 20;
    cache_enrt_info(p_effective_date
                   ,p_business_group_id
                   ,p_person_id, p_pgm_id
                   ,l_assignment_id
                   ,p_include_erl);
    --
    -- Check enrollment limitation and coverage limitation of plan type
    -- in program.
    --
    for i in 1..g_ptip_cnt loop
        l_step := 25;
      	-- * plan type in program enrollment limitation (Max and Min).
    	if (g_ptip_tbl(i).tot_pl_enrld > g_ptip_tbl(i).MX_ENRD_ALWD_OVRID_NUM
            and g_ptip_tbl(i).MX_ENRD_ALWD_OVRID_NUM is not NULL
            and g_ptip_tbl(i).dpnt_cvd_by_othr_apls_flag = 'N') then
           --
           --bug #2162121
           --
           hr_utility.set_location('Get the plan name and option name.:-'  ,1234);
           l_ptip_tbl_ct         := nvl(g_ptip_tbl(i).tot_pl_enrld, 0); -- nvl(g_ptip_tbl.count, 0); Bug 2390734
           --                                                          -- This change is made so that the error message for 92968 displays names of only
          							       -- those compensation objects, that the person is being enrolled in.
           if l_ptip_tbl_ct > 0 then
             --
             l_plan_opt_names := null;
             --
             if  l_ptip_tbl_ct > 10 then
                l_ptip_tbl_ct := 10;
             end if;
             for i2 in 1..l_ptip_tbl_ct loop

                 if g_ptip_tbl(i).ptip_id = g_enrt_tbl(i2).ptip_id then

                    l_plan_name := null;
                    open c_pl_name(g_enrt_tbl(i2).pl_id);
                    fetch c_pl_name into l_plan_name;
                    close c_pl_name;

                    -- l_plan_opt_names := l_plan_opt_names ||l_plan_name;
                    hr_utility.set_location (l_plan_name|| 'l_plan_name :1 : ',1235);

                    if g_enrt_tbl(i2).oipl_id is not null then
                       --
                        l_option_name := null;
                        open c_opt_name(g_enrt_tbl(i2).oipl_id);
                        fetch c_opt_name into l_option_name;
                        close c_opt_name;

                        l_plan_name := l_plan_name ||l_option_name;
                        hr_utility.set_location (l_option_name|| 'l_option_name',1235);
                       --
                    end if ;

                    if l_plan_opt_names is null  then
                       l_plan_opt_names := l_plan_name;
                    else
                       l_plan_opt_names := l_plan_opt_names || ', ' ||l_plan_name;
                    end if;

                 end if;  --g_ptip_tbl(i).ptip_id = g_enrt_tbl(i2).ptip_id

                hr_utility.set_location (l_plan_opt_names|| 'l_plan_opt_names',1235);

             end loop;
           end if;   --l_ptip_tbl_ct > 0

           -- end 2162121
           fnd_message.set_name('BEN','BEN_92968_PL_ENRD_GT_MX_ALWD');
           fnd_message.set_token ('PLAN_OPTION_NAMES', l_plan_opt_names);
           fnd_message.set_token
                ('TOT_ENRD'
                ,to_char(g_ptip_tbl(i).tot_pl_enrld));
           fnd_message.set_token
                ('MX_ENRL'
                ,to_char(g_ptip_tbl(i).MX_ENRD_ALWD_OVRID_NUM));
           fnd_message.set_token('PL_TYP_NAME', g_ptip_tbl(i).name);
           fnd_message.raise_error;
       	elsif(g_ptip_tbl(i).tot_pl_enrld < g_ptip_tbl(i).MN_ENRD_RQD_OVRID_NUM
               and g_ptip_tbl(i).MN_ENRD_RQD_OVRID_NUM is not NULL) then
            l_erl := 'N';
            if p_include_erl = 'N' then
              --
              open c_erl(g_ptip_tbl(i).pl_typ_id);
              fetch c_erl into l_erl;
              close c_erl;
              --
            end if;
            if l_erl = 'N' then
              --
              l_step := 26;
              fnd_message.set_name('BEN','BEN_91588_PL_ENRD_LT_MN_RQD');
/*              fnd_message.set_token
                  ('TOT_ENRD'
                  ,to_char(g_ptip_tbl(i).tot_pl_enrld));*/ -- Bug 5664907
              fnd_message.set_token
                  ('MN_ENRL'
                  ,to_char(g_ptip_tbl(i).MN_ENRD_RQD_OVRID_NUM));
              fnd_message.set_token('PL_TYP_NAME', g_ptip_tbl(i).name);
              fnd_message.raise_error;
              --
            end if;
            --
        end if;
        --
        -- Plan type in program coverage limitation (Max and Min).
        --
        l_step := 30;
    	if (g_ptip_tbl(i).tot_cvg_amt > g_ptip_tbl(i).MX_CVG_ALWD_AMT
            and g_ptip_tbl(i).MX_CVG_ALWD_AMT is not NULL ) then
            fnd_message.set_name('BEN','BEN_92500_PL_CVG_AMT_GT_MX_ALW');
            fnd_message.set_token
                ('TOT_AMT'
                ,to_char(g_ptip_tbl(i).tot_cvg_amt));
            fnd_message.set_token
                ('MX_AMT'
                ,to_char(g_ptip_tbl(i).MX_CVG_ALWD_AMT));
            fnd_message.set_token('PL_TYP_NAME', g_ptip_tbl(i).name);
            fnd_message.raise_error;
      	end if;
        --
        -- If plan type is spouse/dependent life ins then store amount for
        -- later used.
        --
        l_step := 35;
        if (g_ptip_tbl(i).sbj_to_sps_lf_ins_mx_flag  = 'N') and
           (g_ptip_tbl(i).sbj_to_dpnt_lf_ins_mx_flag = 'N') and
           (g_ptip_tbl(i).use_to_sum_ee_lf_ins_flag  = 'Y') then
            g_tot_ee_lf_ins_amt := g_tot_ee_lf_ins_amt + g_ptip_tbl(i).tot_cvg_amt;
            g_tot_ee_lf_ins_amt_no := g_tot_ee_lf_ins_amt_no + g_ptip_tbl(i).tot_cvg_amt_no_interim;
        end if;
        hr_utility.set_location('g_tot_ee_lf_ins_amt '||g_tot_ee_lf_ins_amt,111);
        hr_utility.set_location('g_tot_ee_lf_ins_amt_no '||g_tot_ee_lf_ins_amt_no,111);
    end loop;
    --
    -- Check for spouse and dependent coverage limitations.
    --
    for i in 1..g_ptip_cnt loop
    -- Bug 4613929, Started one more Plantype loop to check for coverage for
    -- Sps or dpnt's plantype is within participant's % maximum coverage
        l_step := 38;
        if (g_ptip_tbl(i).sbj_to_sps_lf_ins_mx_flag = 'Y') then
            g_tot_sps_lf_ins_amt := g_ptip_tbl(i).tot_cvg_amt;
            g_tot_sps_lf_ins_amt_no := g_ptip_tbl(i).tot_cvg_amt_no_interim;
            if (g_pgm_rec.pgm_id = g_ptip_tbl(i).pgm_id) then
            g_mx_sps_pct_prtt_lf := g_pgm_rec.MX_SPS_PCT_PRTT_LF_AMT;
            end if;
        elsif (g_ptip_tbl(i).sbj_to_dpnt_lf_ins_mx_flag = 'Y') then
            g_tot_dpnt_lf_ins_amt := g_ptip_tbl(i).tot_cvg_amt;
            g_tot_dpnt_lf_ins_amt_no := g_ptip_tbl(i).tot_cvg_amt_no_interim;
            if (g_pgm_rec.pgm_id = g_ptip_tbl(i).pgm_id) then
            g_mx_dpnt_pct_prtt_lf := g_pgm_rec.MX_DPNT_PCT_PRTT_LF_AMT;
            end if;
        end if;
        --
        hr_utility.set_location('g_tot_sps_lf_ins_amt'||g_tot_sps_lf_ins_amt,111);
        hr_utility.set_location('g_tot_dpnt_lf_ins_amt'||g_tot_dpnt_lf_ins_amt,111);
        hr_utility.set_location('g_tot_sps_lf_ins_amt_no'||g_tot_sps_lf_ins_amt_no,111);
        hr_utility.set_location('g_tot_dpnt_lf_ins_amt_no'||g_tot_dpnt_lf_ins_amt_no,111);
        --
        l_step := 40;
        if (((g_mx_dpnt_pct_prtt_lf * g_tot_ee_lf_ins_amt)/100)
             < g_tot_dpnt_lf_ins_amt) then
            fnd_message.set_name('BEN','BEN_91590_DPNT_LF_INS_OVER_LMT');
            fnd_message.set_token('TOT_INS',to_char(g_tot_dpnt_lf_ins_amt));
            fnd_message.set_token
                ('MX_INS'
                ,to_char((g_mx_dpnt_pct_prtt_lf * g_tot_ee_lf_ins_amt)/100));
            fnd_message.raise_error;
        elsif(((g_mx_sps_pct_prtt_lf * g_tot_ee_lf_ins_amt)/100)
              <  g_tot_sps_lf_ins_amt) then
            fnd_message.set_name('BEN','BEN_91591_SP_LF_INS_OVER_LMT');
            fnd_message.set_token('TOT_INS', to_char(g_tot_sps_lf_ins_amt));
            fnd_message.set_token('MX_INS',
                to_char((g_mx_sps_pct_prtt_lf * g_tot_ee_lf_ins_amt)/100));
            fnd_message.raise_error;
        end if;
        --
        l_step := 45;
        --This Evaluates the suspended coverage also in determining the
        --limits.
        --
        if (((g_mx_dpnt_pct_prtt_lf * g_tot_ee_lf_ins_amt_no)/100)
             < g_tot_dpnt_lf_ins_amt_no) then
            fnd_message.set_name('BEN','BEN_91590_DPNT_LF_INS_OVER_LMT');
            fnd_message.set_token('TOT_INS',to_char(g_tot_dpnt_lf_ins_amt_no));
            fnd_message.set_token
                ('MX_INS'
                ,to_char((g_mx_dpnt_pct_prtt_lf * g_tot_ee_lf_ins_amt_no)/100));
            fnd_message.raise_error;
        elsif (((g_mx_sps_pct_prtt_lf * g_tot_ee_lf_ins_amt_no)/100)
              <  g_tot_sps_lf_ins_amt_no)  then
            fnd_message.set_name('BEN','BEN_91591_SP_LF_INS_OVER_LMT');
            fnd_message.set_token('TOT_INS', to_char(g_tot_sps_lf_ins_amt_no));
            fnd_message.set_token('MX_INS',
                to_char((g_mx_sps_pct_prtt_lf * g_tot_ee_lf_ins_amt_no)/100));
            fnd_message.raise_error;
        end if;
    end loop; -- Bug 4613929

    -- Check for plan type in enrollment limitation
    --
    l_step := 50;
    for i in 1..g_pl_typ_cnt loop
      --
     	-- Plan type enrollment limitation (Max and Min).
      --
      hr_utility.set_location('pl_typ_id='||to_char(g_pl_typ_tbl(i).pl_typ_id),99);
      hr_utility.set_location('val='||to_char(g_pl_typ_tbl(i).tot_pl_enrld)||
                              ' min='||to_char(g_pl_typ_tbl(i).mn_enrl_rqd_num)||
                              ' max='||to_char(g_pl_typ_tbl(i).mx_enrl_alwd_num)
                              , 101);
    	if (g_pl_typ_tbl(i).tot_pl_enrld > g_pl_typ_tbl(i).mx_enrl_alwd_num
            and g_pl_typ_tbl(i).mx_enrl_alwd_num is not NULL
            and g_pl_typ_tbl(i).dpnt_cvd_by_othr_apls_flag = 'N') then     /* and g_ptip_tbl(i).dpnt_cvd_by_othr_apls_flag = 'N') then Bug 2093956*/
            fnd_message.set_name('BEN','BEN_91587_PL_ENRD_GT_MX_ALWD');  /* Modified the above line to check for the flag from the pl_typ table instead of PTIP table*/
            fnd_message.set_token
                ('TOT_ENRD'
                ,to_char(g_pl_typ_tbl(i).tot_pl_enrld));
            fnd_message.set_token
                ('MX_ENRL'
                , to_char(g_pl_typ_tbl(i).MX_ENRL_ALWD_NUM));
            fnd_message.set_token('PL_TYP_NAME', g_pl_typ_tbl(i).name);
            fnd_message.raise_error;
       	elsif (g_pl_typ_tbl(i).tot_pl_enrld < g_pl_typ_tbl(i).mn_enrl_rqd_num
               and g_pl_typ_tbl(i).mn_enrl_rqd_num is not NULL ) then
            --
            l_erl := 'N';
            if p_include_erl = 'N' then
              --
              open c_erl(g_pl_typ_tbl(i).pl_typ_id);
              fetch c_erl into l_erl;
              close c_erl;
              --
            end if;
            if l_erl = 'N' then
              --
              fnd_message.set_name('BEN','BEN_91588_PL_ENRD_LT_MN_RQD');
/*              fnd_message.set_token
                  ('TOT_ENRD'
                  ,to_char(g_pl_typ_tbl(i).tot_pl_enrld));*/ --Bug 5664907
              fnd_message.set_token
                  ('MN_ENRL'
                  ,to_char(g_pl_typ_tbl(i).MN_ENRL_RQD_NUM));
              fnd_message.set_token('PL_TYP_NAME', g_pl_typ_tbl(i).name);
              fnd_message.raise_error;
              --
            end if;
            --
        end if;
    end loop;
    --
    -- Check min and max of options winthin plan.
    --
    l_step := 60;
    for i in 1..g_pl_cnt loop
        --
        -- BUG: 4590341
        -- Check for No. of Options Enrolled is b/w min.required and max.allowed
        --
        if (g_pl_tbl(i).interim_flag = 1 and g_pl_tbl(i).tot_opt_enrld = 0) then
            null;
        else
            if (g_pl_tbl(i).tot_opt_enrld > g_pl_tbl(i).mx_opts_alwd_num
                and g_pl_tbl(i).mx_opts_alwd_num is not NULL ) then
                fnd_message.set_name('BEN','BEN_91592_OPT_ENRD_GT_MX_ALWD');
                fnd_message.set_token('OPT_ENRD',to_char(g_pl_tbl(i).tot_opt_enrld));
                fnd_message.set_token('MX_ALWD',to_char(g_pl_tbl(i).MX_OPTS_ALWD_NUM));
                fnd_message.set_token('PL_NAME', g_pl_tbl(i).name);
                fnd_message.raise_error;
            elsif (g_pl_tbl(i).tot_opt_enrld < g_pl_tbl(i).mn_opts_rqd_num
                  and g_pl_tbl(i).mn_opts_rqd_num is not NULL) then
                fnd_message.set_name('BEN','BEN_91593_OPT_ENRD_LT_MN_RQD');
                fnd_message.set_token('OPT_ENRD', to_char(g_pl_tbl(i).tot_opt_enrld));
                fnd_message.set_token('MN_RQD',to_char(g_pl_tbl(i).MN_OPTS_RQD_NUM));
                fnd_message.set_token('PL_NAME', g_pl_tbl(i).name);
                fnd_message.raise_error;
            end if;
            /* BUG: 3949327:
                The below coverage amount limits validations need
                to be performed only when enrolled into Plan.
                So, loop thru g_enrt_tbl and to find
                if enrolled into pln then check the following
                  1. Total Coverage Amount b/w min.required and max.allowed
                  2. If Previously enrolled, then increased_amount b/w min.incr.req. and max.incr allowed
            */
            l_chk_pln_cvg_lmts := FALSE;
            --
            FOR j IN 1 .. g_comp_obj_cnt LOOP
                --
                IF (g_enrt_tbl (j).pl_id = g_pl_tbl (i).pl_id
                    AND g_enrt_tbl (j).prtt_enrt_rslt_id IS NOT NULL
                   ) THEN
                    hr_utility.set_location('l_chk_pln_cvg_lmts='|| 'TRUE' ,99);
                    l_chk_pln_cvg_lmts := TRUE;
                    EXIT;
                END IF;
            END LOOP;
            --
            hr_utility.set_location('g_pl_tbl(i).tot_cvg_amt='||g_pl_tbl(i).tot_cvg_amt,99);
            hr_utility.set_location('g_pl_tbl(i).mx_cvg_alwd_amt='||g_pl_tbl(i).mx_cvg_alwd_amt,99);
            hr_utility.set_location('g_pl_tbl(i).mx_cvg_wcfn_amt='||g_pl_tbl(i).mx_cvg_wcfn_amt,99);
            --
            IF (l_chk_pln_cvg_lmts) THEN
                -- Bug: 3949327 changes end;
                -- Check min coverage amount.
                --
                l_step := 70;
                --
                if (g_pl_tbl(i).tot_cvg_amt < g_pl_tbl(i).mn_cvg_rqd_amt
                    and g_pl_tbl(i).mn_cvg_rqd_amt is not NULL ) then
                    fnd_message.set_name('BEN','BEN_92286_PL_CVG_AMT_LT_MN_ALW');
                    fnd_message.set_token('TOT_AMT',to_char(g_pl_tbl(i).tot_cvg_amt));
                    fnd_message.set_token('MN_AMT',to_char(g_pl_tbl(i).mn_cvg_rqd_amt));
                    fnd_message.set_token('PL_NAME', g_pl_tbl(i).name);
                    fnd_message.raise_error;
                end if;
                --
                -- Check max coverage amount.
                --
                l_step := 75;
                --
                -- Coverage problem is possible if > max
                --
                if (g_pl_tbl(i).tot_cvg_amt > g_pl_tbl(i).mx_cvg_alwd_amt
                    and g_pl_tbl(i).mx_cvg_alwd_amt is not NULL ) then
                    if g_pl_tbl(i).tot_cvg_amt > g_pl_tbl(i).mx_cvg_wcfn_amt then
                      --
                      -- Over top even with certification
                      --
                      fnd_message.set_name('BEN','BEN_91589_PL_CVG_AMT_GT_MX_ALW');
                      fnd_message.set_token('TOT_AMT',to_char(g_pl_tbl(i).tot_cvg_amt));
                      fnd_message.set_token('MX_AMT',to_char(g_pl_tbl(i).MX_CVG_wcfn_AMT));
                      fnd_message.set_token('PL_NAME', g_pl_tbl(i).name);
                      fnd_message.raise_error;
                    elsif g_pl_tbl(i).mx_cvg_wcfn_amt is null then
                      --
                      -- Over top and no certification limit exists
                      --
                      fnd_message.set_name('BEN','BEN_91589_PL_CVG_AMT_GT_MX_ALW');
                      fnd_message.set_token('TOT_AMT',to_char(g_pl_tbl(i).tot_cvg_amt));
                      fnd_message.set_token('MX_AMT',to_char(g_pl_tbl(i).MX_CVG_ALWD_AMT));
                      fnd_message.set_token('PL_NAME', g_pl_tbl(i).name);
                      fnd_message.raise_error;
                    end if;
                end if;
                --
                -- Check max coverage increase amount.
                --
                l_step := 76;
                --
                -- Coverage problem is possible if increase > max
                --
                l_increase:=g_pl_tbl(i).tot_cvg_amt - g_pl_tbl(i).prev_cvg_amt;
                --
                -- Check increases only if the person was not previously enrolled.
                -- If the amount is zero, the person was not previously enrolled and
                -- is allowed to choose any coverage irrespective of the
                -- amount defined in (mx_cvg_incr_alwd_amt).
                --
                if (g_pl_tbl(i).prev_cvg_amt <> 0 and
                    l_increase > g_pl_tbl(i).mx_cvg_incr_alwd_amt
                    and g_pl_tbl(i).mx_cvg_incr_alwd_amt is not NULL ) then
                    if l_increase > g_pl_tbl(i).mx_cvg_incr_wcf_alwd_amt then
                      --
                      -- Over top even with certification
                      --
                      fnd_message.set_name('BEN','BEN_91594_CERT_INCR_GT_MX_INCR');
                      fnd_message.set_token('CERT_INCR',to_char(l_increase));
                      fnd_message.set_token('MX_INCR',to_char(g_pl_tbl(i).MX_CVG_INCR_WCF_ALWD_AMT));
                      fnd_message.raise_error;
                      --
                    elsif g_pl_tbl(i).mx_cvg_incr_wcf_alwd_amt is null then
                      --
                      -- Over top and no certification limit exists
                      --
                      fnd_message.set_name('BEN','BEN_91596_CVG_INCR_GT_MX_INCR');
                      fnd_message.set_token('CVG_INCR',to_char(l_increase));
                      fnd_message.set_token('MX_INCR',to_char(g_pl_tbl(i).MX_CVG_INCR_ALWD_AMT));
                      fnd_message.raise_error;
                    end if;
                    --
                end if;
            --
          end if; --- l_chk_pln_cvg_lmts end-if
        --
        end if;
        --
    end loop;
    --
    -- Make sure not duplicate comp object with in a program such as
    -- same plan id and option id.
    --
    l_step := 80;
    -- Bug 6741391
    ben_cobj_cache.clear_down_cache;
    -- Bug 6741391
    for i in 1..g_comp_obj_cnt loop
      --
      if g_enrt_tbl(i).prtt_enrt_rslt_id is not null and
         g_enrt_tbl(i).interim_flag = 'N'  then
        --
        -- RCHASE - Bug#1412801 - Moved post election edit rule from insert/update
        -- RCHASE                 validation calls to multi-row edit
        --
        ben_cobj_cache.get_pl_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          ,p_pl_id             => g_enrt_tbl(i).pl_id
          ,p_inst_row	       => l_pl_rec
          );
        --
/*
        ben_comp_object.get_object(p_pl_id => g_enrt_tbl(i).pl_id,
                                   p_rec => l_pl_rec);
*/
        --
        if g_enrt_tbl(i).plip_id is not null then
          --
          ben_cobj_cache.get_plip_dets
            (p_business_group_id => p_business_group_id
            ,p_effective_date    => p_effective_date
            ,p_plip_id           => g_enrt_tbl(i).plip_id
            ,p_inst_row	         => l_plip_rec
            );
          --
/*
          ben_comp_object.get_object(p_plip_id => g_enrt_tbl(i).plip_id,
                                     p_rec => l_plip_rec);
*/
        else
          l_plip_rec := null;
        end if;
        --
        if g_enrt_tbl(i).ptip_id is not null then
          --
          ben_cobj_cache.get_ptip_dets
            (p_business_group_id => p_business_group_id
            ,p_effective_date    => p_effective_date
            ,p_ptip_id           => g_enrt_tbl(i).ptip_id
            ,p_inst_row	         => l_ptip_rec
            );
          --
/*
          ben_comp_object.get_object(p_ptip_id => g_enrt_tbl(i).ptip_id,
                                     p_rec => l_ptip_rec);
*/
        else
          l_ptip_rec := null;
        end if;
        --
        if g_enrt_tbl(i).oipl_id is not null then
          --
          ben_cobj_cache.get_oipl_dets
            (p_business_group_id => p_business_group_id
            ,p_effective_date    => p_effective_date
            ,p_oipl_id           => g_enrt_tbl(i).oipl_id
            ,p_inst_row	         => l_oipl_rec
            );
          --
/*
          ben_comp_object.get_object(p_oipl_id => g_enrt_tbl(i).oipl_id,
                                     p_rec => l_oipl_rec);
*/
        else
          l_oipl_rec := null;
        end if;

        if l_pl_rec.postelcn_edit_rl is not null or
           l_oipl_rec.postelcn_edit_rl is not null or
           l_plip_rec.postelcn_edit_rl is not null or
           l_ptip_rec.postelcn_edit_rl is not null then
        chk_post_elcn_rl
          (p_pgm_id                => g_enrt_tbl(i).pgm_id,
           p_pl_id                 => g_enrt_tbl(i).pl_id,
           p_pl_typ_id             => g_enrt_tbl(i).pl_typ_id,
           p_opt_id                => g_enrt_tbl(i).opt_id,
           p_person_id             => p_person_id,
           p_effective_date        => p_effective_date,
           p_business_group_id     => p_business_group_id,
           p_pl_post_edit_rl       => l_pl_rec.postelcn_edit_rl,
           p_plip_post_edit_rl     => l_plip_rec.postelcn_edit_rl,
           p_ptip_post_edit_rl     => l_ptip_rec.postelcn_edit_rl,
           p_oipl_post_edit_rl     => l_oipl_rec.postelcn_edit_rl);
        end if;
        -- RCHASE End
        --
        -- Check whether the plan is same as the previous one.
        -- Check the oipl to be same, if they are not null.
        -- This logic of just checking with the previous record works
        -- fine as the records are stored in the order pl_id, oipl_id.
        --
        if (l_prev_pl_id = g_enrt_tbl(i).pl_id) and
           ((g_enrt_tbl(i).oipl_id is null and l_prev_oipl_id is null) or
            l_prev_oipl_id = g_enrt_tbl(i).oipl_id) then
          --
          -- Plan and oipl are same, now check whether the coverage overlap.
          -- If not, it's fine to have two results. (Possible when a person
          -- re-enrolls in a comp-object after de-enrolling from it.)
          --
          if (l_prev_cvg_strt_dt between
              g_enrt_tbl(i).enrt_cvg_strt_dt
              and nvl(g_enrt_tbl(i).enrt_cvg_thru_dt,hr_api.g_eot))
                   OR
             (g_enrt_tbl(i).enrt_cvg_strt_dt between
              l_prev_cvg_strt_dt
              and nvl(l_prev_cvg_end_dt,hr_api.g_eot)) then
            --
            fnd_message.set_name('BEN','BEN_91699_DUP_COMP_OBJ_IN_PGM');
            fnd_message.set_token
                ('PL_NAME'
                ,get_plan_name(p_pl_id             => g_enrt_tbl(i).pl_id
                              ,p_business_group_id => p_business_group_id
                              ,p_effective_date    => p_effective_date
                              )
                );
            fnd_message.raise_error;
            --
          end if;
          --
        end if;
        --
        l_prev_pl_id       := g_enrt_tbl(i).pl_id;
        l_prev_oipl_id     := g_enrt_tbl(i).oipl_id;
        l_prev_cvg_strt_dt := g_enrt_tbl(i).enrt_cvg_strt_dt;
        l_prev_cvg_end_dt  := g_enrt_tbl(i).enrt_cvg_thru_dt;
        --
        if (g_enrt_tbl(i).must_enrl_anthr_pl_id is not NULL) then
 	        l_pl_notfnd := TRUE;
 	        for j in 1..g_pl_cnt loop
                if (g_enrt_tbl(i).must_enrl_anthr_pl_id = g_pl_tbl(j).pl_id
                   ) then
 		            l_pl_notfnd := FALSE;
 		            exit;
                end if;
            end loop;
            if (l_pl_notfnd) then
                fnd_message.set_name('BEN','BEN_91597_MUST_ENRL_PLAN');
                fnd_message.set_token('PL_ID', g_enrt_tbl(i).pl_id);
                fnd_message.set_token
                    ('RQD_PL'
                    ,get_plan_name
                         (p_pl_id=> g_enrt_tbl(i).must_enrl_anthr_pl_id
                         ,p_business_group_id => p_business_group_id
                         ,p_effective_date    => p_effective_date
                         )
                    );
                fnd_message.raise_error;
 	        end if;
        end if;
      end if;
    end loop;
    --
    -- Check for coordinate coverages.  If coordinate flag set on in ptip
    -- level, then all options in each plan need to same.
    --
    l_step := 90;
    l_init_flag := true;
    for i in 1..g_ptip_cnt loop
       if (g_ptip_tbl(i).COORD_CVG_FOR_ALL_PLS_FLAG = 'Y') then
 	  for j in 1..g_comp_obj_cnt loop
             --
             if g_enrt_tbl(j).ptip_id = g_ptip_tbl(i).ptip_id and
                g_enrt_tbl(j).prtt_enrt_rslt_id is not null   and
                g_enrt_tbl(j).enrt_cvg_thru_dt = hr_api.g_eot and
                g_enrt_tbl(j).interim_flag = 'N'              and
                g_enrt_tbl(j).opt_id is not null then
                --
                if (l_init_flag) then
                  l_prev_opt_id := g_enrt_tbl(j).opt_id;
                  l_prev_ptip_name := g_ptip_tbl(i).name;
                  l_init_flag := FALSE;
                elsif (l_prev_opt_id <>  g_enrt_tbl(j).opt_id) then
                  fnd_message.set_name('BEN','BEN_91598_OPT_NOT_COORD');
                  fnd_message.set_token('PTIP_NAME1',g_ptip_tbl(i).name);
                  fnd_message.set_token('PTIP_NAME2',l_prev_ptip_name);
                  fnd_message.raise_error;
                end if;
                --
             end if;
             --
          end loop;
       end if;
    end loop;
    --
    -- Now check person_type_usage.  Make sure participant coverage period is
    -- recorded in person type usage table.
    --
    l_step := 100;
    manage_per_type_usages
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
    --
    -- Now check mandatory,  If and plan is elected, then all oipl within the
    -- plan has mandatory flag set on need to be enrolled, otherwise the routine
    -- will bomb out.
    --
    l_step := 110;
    chk_mndtry_comp_obj
        (p_person_id         => p_person_id
        ,p_pgm_id            => p_pgm_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
    hr_utility.set_location (l_proc, 10);
Exception
    when others then
        hr_utility.set_location('Fail at '||l_proc||' step - '||
                                to_char(l_step),999);
        raise;
end;
--
/*--Bug#5088571
-- ---------------------------------------------------------------------------
-- |------------------------< chk_cvg_strt_end_dt >----------------------------|
-- ---------------------------------------------------------------------------
-- Description
--   This procedure is used to check whether the Rate Start date is greater than Rate End date.
--
procedure chk_cvg_strt_end_dt(p_enrt_cvg_strt_dt            in date,
                       	      p_enrt_cvg_thru_dt            in date,
                              p_person_id                   in number
          		     ) is
--
  l_proc         varchar2(72) := g_package||'chk_cvg_strt_end_dt';
  l_person_id    number;
  l_message_name varchar2(500) := 'BEN_94592_RT_STRT_GT_END_DT';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_enrt_cvg_strt_dt > p_enrt_cvg_thru_dt then
     benutils.write(p_text=>fnd_message.get);
     ben_warnings.load_warning
           (p_application_short_name  => 'BEN'
            ,p_message_name            => l_message_name
            ,p_parma                   => 'Coverage End Date' || ' ' || fnd_date.date_to_displaydate(p_enrt_cvg_thru_dt)
	    ,p_parmb    	       => 'Coverage Start Date' ||' '|| fnd_date.date_to_displaydate(p_enrt_cvg_strt_dt)
	    ,p_person_id               =>  p_person_id
	    );
  end if;
 --
  hr_utility.set_location('Leaving:'||l_proc,10);
 --
end chk_cvg_strt_end_dt;
--
----Bug#5088571*/
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_pgm_id                    in number default hr_api.g_number,
             p_oipl_id                   in number default hr_api.g_number,
             p_per_in_ler_id             in number default hr_api.g_number,
             p_pl_id                     in number default hr_api.g_number,
             p_pl_typ_id                 in number default hr_api.g_number,
             p_prtt_enrt_rslt_id         in number default hr_api.g_number,
   	     p_datetrack_mode		 in varchar2,
             p_validation_start_date	 in date,
         p_validation_end_date	 in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_pgm_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pgm_f',
             p_base_key_column => 'pgm_id',
             p_base_key_value  => p_pgm_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pgm_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_oipl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_oipl_f',
             p_base_key_column => 'oipl_id',
             p_base_key_value  => p_oipl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_oipl_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_f',
             p_base_key_column => 'pl_id',
             p_base_key_value  => p_pl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pl_typ_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_typ_f',
             p_base_key_column => 'pl_typ_id',
             p_base_key_value  => p_pl_typ_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_typ_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_prtt_enrt_rslt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_prtt_enrt_rslt_f',
             p_base_key_column => 'prtt_enrt_rslt_id',
             p_base_key_value  => p_prtt_enrt_rslt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_prtt_enrt_rslt_f';
      Raise l_integrity_error;
    End If;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.parent_integrity_error(p_table_name => l_table_name);
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_prtt_enrt_rslt_id        in number,
             p_datetrack_mode		in varchar2,
	     p_effective_date           in date,
   	     p_validation_start_date	in date,
             p_validation_end_date	in date) Is

  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);

    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);

    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'prtt_enrt_rslt_id',
       p_argument_value => p_prtt_enrt_rslt_id);
/*
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_prvdd_ldgr_f',
           p_base_key_column => 'prtt_enrt_rslt_id',
           p_base_key_value  => p_prtt_enrt_rslt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_prvdd_ldgr_f';
      Raise l_rows_exist;
    End If;
*/
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_bnf_f',
           p_base_key_column => 'prtt_enrt_rslt_id',
           p_base_key_value  => p_prtt_enrt_rslt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_bnf_f';
      Raise l_rows_exist;
    End If;

    If p_effective_date < p_validation_start_date then
    -- Added the above condition for bug 3646239
	    If (dt_api.rows_exist
		  (p_base_table_name => 'ben_elig_cvrd_dpnt_f',
		   p_base_key_column => 'prtt_enrt_rslt_id',
		   p_base_key_value  => p_prtt_enrt_rslt_id,
		   p_from_date       => p_validation_start_date,
		   p_to_date         => p_validation_end_date)) Then
	      l_table_name := 'ben_elig_cvrd_dpnt_f';
	      Raise l_rows_exist;
	    End If;
    End If;

    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtt_enrt_actn_f',
           p_base_key_column => 'prtt_enrt_rslt_id',
           p_base_key_value  => p_prtt_enrt_rslt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtt_enrt_actn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtt_enrt_ctfn_prvdd_f',
           p_base_key_column => 'prtt_enrt_rslt_id',
           p_base_key_value  => p_prtt_enrt_rslt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtt_enrt_ctfn_prvdd_f';
      Raise l_rows_exist;
    End If;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
  ben_utility.child_exists_error(p_table_name => l_table_name);
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
    (p_rec 			 in ben_pen_shd.g_rec_type,
     p_effective_date	 in date,
     p_datetrack_mode	 in varchar2,
     p_validation_start_date in date,
     p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call context sensitive validate bgp cache routine
  --
  ben_batch_dt_api.batch_validate_bgp_id
    (p_business_group_id => p_rec.business_group_id
    );
  --
/*
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
*/
  chk_prtt_enrt_rslt_id
  (p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_ovridn_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_enrt_ovridn_flag      => p_rec.enrt_ovridn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_lngr_elig_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_no_lngr_elig_flag     => p_rec.no_lngr_elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_uom
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_uom                   => p_rec.uom     ,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_is_cvrd_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_prtt_is_cvrd_flag     => p_rec.prtt_is_cvrd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sspndd_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_sspndd_flag           => p_rec.sspndd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_cd
  (p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_comp_lvl_cd              => p_rec.comp_lvl_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);

  --
  chk_bnft_nnmntry_uom
  (p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_bnft_nnmntry_uom         => p_rec.bnft_nnmntry_uom,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_bnft_typ_cd
  (p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_bnft_typ_cd              => p_rec.bnft_typ_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_prtt_enrt_rslt_stat_cd
  (p_prtt_enrt_rslt_id          => p_rec.prtt_enrt_rslt_id,
   p_prtt_enrt_rslt_stat_cd     => p_rec.prtt_enrt_rslt_stat_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_enrt_ovrid_rsn_cd
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_enrt_ovrid_rsn_cd     => p_rec.enrt_ovrid_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  -- RCHASE - Bug#1412801 - Moved post election edit rule from insert/update
  -- RCHASE                 validation calls to multi-row edit
  --chk_post_elcn_rl
  --(p_oipl_id               => p_rec.oipl_id,
  -- p_pl_id                 => p_rec.pl_id,
  -- p_ptip_id               => p_rec.ptip_id,
  -- p_pgm_id                => p_rec.pgm_id,
  -- p_pl_typ_id             => p_rec.pl_typ_id,
  -- p_person_id             => p_rec.person_id,
  -- p_effective_date        => p_effective_date,
  -- p_business_group_id     => p_rec.business_group_id);
  --
    crt_ordr_warning
    (p_prtt_enrt_rslt_id    => p_rec.prtt_enrt_rslt_id
     ,p_per_in_ler_id       => p_rec.per_in_ler_id  /* Bug 4766655 */
     ,p_person_id           => p_rec.person_id
     ,p_pgm_id              => p_rec.pgm_id
     ,p_pl_id               => p_rec.pl_id
     ,p_ptip_id             => p_rec.ptip_id
     ,p_pl_typ_id           => p_rec.pl_typ_id
     ,p_effective_date      => p_effective_date
     ,p_enrt_cvg_strt_dt    => p_rec.enrt_cvg_strt_dt
     ,p_enrt_cvg_thru_dt    => p_rec.enrt_cvg_thru_dt
     ,p_business_group_id   => p_rec.business_group_id);
  --
/*chk_cvg_strt_end_dt
 (p_enrt_cvg_strt_dt => p_rec.enrt_cvg_strt_dt,
  p_enrt_cvg_thru_dt => p_rec.enrt_cvg_thru_dt,
  p_person_id        => p_rec.person_id);*/
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
    (p_rec 			 in     ben_pen_shd.g_rec_type,
     p_effective_date	 in     date,
     p_datetrack_mode	 in     varchar2,
     p_validation_start_date in     date,
     p_validation_end_date	 in     date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call context sensitive validate bgp cache routine
  --
  ben_batch_dt_api.batch_validate_bgp_id
    (p_business_group_id => p_rec.business_group_id
    );
  --
/*
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
*/
  chk_prtt_enrt_rslt_id
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_ovridn_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_enrt_ovridn_flag      => p_rec.enrt_ovridn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_lngr_elig_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_no_lngr_elig_flag     => p_rec.no_lngr_elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_uom
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_uom                   => p_rec.uom     ,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_is_cvrd_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_prtt_is_cvrd_flag     => p_rec.prtt_is_cvrd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sspndd_flag
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_sspndd_flag           => p_rec.sspndd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_cd
  (p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_comp_lvl_cd              => p_rec.comp_lvl_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);

  chk_bnft_nnmntry_uom
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_bnft_nnmntry_uom      => p_rec.bnft_nnmntry_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_typ_cd
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_bnft_typ_cd           => p_rec.bnft_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_enrt_rslt_stat_cd
  (p_prtt_enrt_rslt_id          => p_rec.prtt_enrt_rslt_id,
   p_prtt_enrt_rslt_stat_cd     => p_rec.prtt_enrt_rslt_stat_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_enrt_ovrid_rsn_cd
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_enrt_ovrid_rsn_cd     => p_rec.enrt_ovrid_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- RCHASE - Bug#1412801 - Moved post election edit rule from insert/update
  -- RCHASE                 validation calls to multi-row edit
  --chk_post_elcn_rl
  --(p_oipl_id               => p_rec.oipl_id,
  -- p_pl_id                 => p_rec.pl_id,
  -- p_ptip_id               => p_rec.ptip_id,
  -- p_pgm_id                => p_rec.pgm_id,
  -- p_pl_typ_id             => p_rec.pl_typ_id,
  -- p_person_id             => p_rec.person_id,
  -- p_effective_date        => p_effective_date,
  -- p_business_group_id     => p_rec.business_group_id);
--
    crt_ordr_warning
    (p_prtt_enrt_rslt_id    => p_rec.prtt_enrt_rslt_id
     ,p_per_in_ler_id       => p_rec.per_in_ler_id       /* Bug 4766655 */
     ,p_person_id           => p_rec.person_id
     ,p_pgm_id              => p_rec.pgm_id
     ,p_pl_id               => p_rec.pl_id
     ,p_ptip_id             => p_rec.ptip_id
     ,p_pl_typ_id           => p_rec.pl_typ_id
     ,p_effective_date      => p_effective_date
     ,p_enrt_cvg_strt_dt    => p_rec.enrt_cvg_strt_dt
     ,p_enrt_cvg_thru_dt    => p_rec.enrt_cvg_thru_dt
     ,p_business_group_id   => p_rec.business_group_id);
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_pgm_id                        => p_rec.pgm_id,
     p_oipl_id                       => p_rec.oipl_id,
     p_pl_id                         => p_rec.pl_id,
     p_per_in_ler_id                 => p_rec.per_in_ler_id,
     p_pl_typ_id                     => p_rec.pl_typ_id,
     p_prtt_enrt_rslt_id             => p_rec.prtt_enrt_rslt_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
/*chk_cvg_strt_end_dt
 (p_enrt_cvg_strt_dt => p_rec.enrt_cvg_strt_dt,
  p_enrt_cvg_thru_dt => p_rec.enrt_cvg_thru_dt,
  p_person_id        => p_rec.person_id);*/
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
    (p_rec 			         in     ben_pen_shd.g_rec_type,
     p_effective_date	     in     date,
     p_datetrack_mode	     in     varchar2,
     p_validation_start_date in     date,
     p_validation_end_date	 in     date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		  => p_datetrack_mode,
     p_validation_start_date      => p_validation_start_date,
     p_validation_end_date	  => p_validation_end_date,
     p_effective_date             => p_effective_date,  -- Added for bug 3646239
     p_prtt_enrt_rslt_id	  => p_rec.prtt_enrt_rslt_id);
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
  (p_prtt_enrt_rslt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtt_enrt_rslt_f b
    where b.prtt_enrt_rslt_id      = p_prtt_enrt_rslt_id
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
                             p_argument       => 'prtt_enrt_rslt_id',
                             p_argument_value => p_prtt_enrt_rslt_id);
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
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
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
end ben_pen_bus;

/
