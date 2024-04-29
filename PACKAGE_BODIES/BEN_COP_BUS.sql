--------------------------------------------------------
--  DDL for Package Body BEN_COP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COP_BUS" as
/* $Header: becoprhi.pkb 120.5 2007/12/04 10:59:29 bachakra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cop_bus.';  -- Global package name

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_oipl_id >----------------------------------|
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
--   oipl_id               PK of record being inserted or updated.
--   effective_date        Effective Date of session
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
Procedure chk_oipl_id(p_oipl_id                     in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oipl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_oipl_id                     => p_oipl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_oipl_id,hr_api.g_number)
     <>  ben_cop_shd.g_old_rec.oipl_id) then
    --
    -- raise error as PK has changed
    --
    ben_cpo_shd.constraint_error('BEN_OIPL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_oipl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cop_shd.constraint_error('BEN_OIPL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_oipl_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_dflt_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   dflt_flag             Value of lookup code.
--   effective_date        effective date
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
Procedure chk_dflt_flag(p_oipl_id                     in number,
                        p_dflt_flag                   in varchar2,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_cop_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
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
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_mndtry_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   mndtry_flag           Value of lookup code.
--   effective_date        effective date
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
Procedure chk_mndtry_flag(p_oipl_id                     in number,
                          p_mndtry_flag                 in varchar2,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mndtry_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mndtry_flag
      <> nvl(ben_cop_shd.g_old_rec.mndtry_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mndtry_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_mndtry_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_mndtry_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mndtry_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_elig_apls_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   elig_apls_flag        Value of lookup code.
--   effective_date        effective date
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
Procedure chk_elig_apls_flag(p_oipl_id                     in number,
                             p_elig_apls_flag              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_apls_flag
      <> nvl(ben_cop_shd.g_old_rec.elig_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_elig_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_elig_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_elig_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_apls_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_trk_inelig_per_flag >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   trk_inelig_per_flag   Value of lookup code.
--   effective_date        effective date
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
Procedure chk_trk_inelig_per_flag(p_oipl_id                     in number,
                                  p_trk_inelig_per_flag         in varchar2,
                                  p_effective_date              in date,
                                  p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_trk_inelig_per_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_trk_inelig_per_flag
      <> nvl(ben_cop_shd.g_old_rec.trk_inelig_per_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_trk_inelig_per_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_trk_inelig_per_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_trk_inelig_per_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_trk_inelig_per_flag;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_drvbl_fctr_prtn_elig_flag >--------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id                   PK of record being inserted or updated.
--   drvbl_fctr_prtn_elig_flag  Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                             inserted or updated.
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
Procedure chk_drvbl_fctr_prtn_elig_flag
              (p_oipl_id                     in number,
               p_drvbl_fctr_prtn_elig_flag   in varchar2,
               p_effective_date              in date,
               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_prtn_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_prtn_elig_flag
      <> nvl(ben_cop_shd.g_old_rec.drvbl_fctr_prtn_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_prtn_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_prtn_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_drvbl_fctr_prtn_elig_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_prtn_elig_flag;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_prtn_elig_ovrid_alwd_flag >-------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id                   PK of record being inserted or updated.
--   prtn_elig_ovrid_alwd_flag Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                             inserted or updated.
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
Procedure chk_prtn_elig_ovrid_alwd_flag
            (p_oipl_id                     in number,
             p_prtn_elig_ovrid_alwd_flag   in varchar2,
             p_effective_date              in date,
             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_elig_ovrid_alwd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_elig_ovrid_alwd_flag
      <> nvl(ben_cop_shd.g_old_rec.prtn_elig_ovrid_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_elig_ovrid_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prtn_elig_ovrid_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prtn_elig_ovrid_alwd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_elig_ovrid_alwd_flag;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_drvbl_fctr_apls_rts_flag >---------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id                 PK of record being inserted or updated.
--   drvbl_fctr_apls_rts_flag Value of lookup code.
--   effective_date          effective date
--   object_version_number   Object version number of record being
--                           inserted or updated.
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
Procedure chk_drvbl_fctr_apls_rts_flag
       (p_oipl_id                  in number,
        p_drvbl_fctr_apls_rts_flag in varchar2,
        p_effective_date           in date,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_apls_rts_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_apls_rts_flag
      <> nvl(ben_cop_shd.g_old_rec.drvbl_fctr_apls_rts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_apls_rts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_apls_rts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_drvbl_fctr_apls_rts_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_apls_rts_flag;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_oipl_stat_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   oipl_stat_cd          Value of lookup code.
--   effective_date        effective date
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
Procedure chk_oipl_stat_cd(p_oipl_id                    in number,
                           p_oipl_stat_cd               in varchar2,
                           p_effective_date             in date,
                           p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oipl_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_oipl_stat_cd
      <> nvl(ben_cop_shd.g_old_rec.oipl_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_oipl_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_oipl_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_oipl_stat_cd');
      fnd_message.set_token('TYPE','BEN_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_oipl_stat_cd;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_pcp_dsgn_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   pcp_dsgn_cd          Value of lookup code.
--   effective_date        effective date
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
Procedure chk_pcp_dsgn_cd(p_oipl_id                    in number,
                           p_pcp_dsgn_cd               in varchar2,
                           p_effective_date             in date,
                           p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_dsgn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pcp_dsgn_cd
      <> nvl(ben_cop_shd.g_old_rec.pcp_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_dsgn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PCP_DSGN',
           p_lookup_code    => p_pcp_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_dsgn_cd');
      fnd_message.set_token('TYPE','BEN_PCP_DSGN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_dsgn_cd;
--
-- -------------------------------------------------------------------------------
-- |-----------------------< chk_pcp_dpnt_dsgn_cd >-------------------------------|
-- -------------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   pcp_dpnt_dsgn_cd      Value of lookup code.
--   effective_date        effective date
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
Procedure chk_pcp_dpnt_dsgn_cd(p_oipl_id                    in number,
                               p_pcp_dpnt_dsgn_cd           in varchar2,
                               p_effective_date             in date,
                               p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_dpnt_dsgn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pcp_dpnt_dsgn_cd
      <> nvl(ben_cop_shd.g_old_rec.pcp_dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_dpnt_dsgn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PCP_DSGN',
           p_lookup_code    => p_pcp_dpnt_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_dpnt_dsgn_cd');
      fnd_message.set_token('TYPE','BEN_PCP_DSGN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_dpnt_dsgn_cd;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_auto_enrt_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   auto_enrt_flag        Value of lookup code.
--   effective_date        effective date
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
Procedure chk_auto_enrt_flag(p_oipl_id                    in number,
                             p_auto_enrt_flag             in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_auto_enrt_flag
      <> nvl(ben_cop_shd.g_old_rec.auto_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_auto_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_auto_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_auto_enrt_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_auto_enrt_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_vrfy_fmly_mmbr_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   vrfy_fmly_mmbr_cd     Value of lookup code.
--   effective_date        effective date
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
Procedure chk_vrfy_fmly_mmbr_cd(p_oipl_id                    in number,
                                p_vrfy_fmly_mmbr_cd          in varchar2,
                                p_effective_date             in date,
                                p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrfy_fmly_mmbr_cd
      <> nvl(ben_cop_shd.g_old_rec.vrfy_fmly_mmbr_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_vrfy_fmly_mmbr_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FMLY_MMBR',
           p_lookup_code    => p_vrfy_fmly_mmbr_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_vrfy_fmly_mmbr_cd');
      fnd_message.set_token('TYPE','BEN_FMLY_MMBR');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_cd;
-- ---------------------------------------------------------------------
-- |------------------< chk_enrt_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   enrt_cd               Value of lookup code.
--   effective_date        effective date
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
Procedure chk_enrt_cd(p_oipl_id                    in number,
                                p_enrt_cd          in varchar2,
                                p_effective_date             in date,
                                p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_cop_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT',
           p_lookup_code    => p_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_enrt_cd');
      fnd_message.set_token('TYPE','BEN_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cd;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dflt_enrt_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   dflt_enrt_cd          Value of lookup code.
--   effective_date        effective date
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
Procedure chk_dflt_enrt_cd(p_oipl_id                    in number,
                           p_dflt_enrt_cd               in varchar2,
                           p_effective_date             in date,
                           p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_cd
      <> nvl(ben_cop_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DFLT_ENRT',
           p_lookup_code    => p_dflt_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dflt_enrt_cd');
      fnd_message.set_token('TYPE','BEN_DFLT_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_cd;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_auto_enrt_mthd_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   auto_enrt_mthd_rl     Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_auto_enrt_mthd_rl(p_oipl_id                     in number,
                                p_business_group_id           in number,
                                p_auto_enrt_mthd_rl           in number,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_mthd_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.auto_enrt_mthd_rl
      or not l_api_updating)
      and p_auto_enrt_mthd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_auto_enrt_mthd_rl,
        p_formula_type_id   => -146,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_auto_enrt_mthd_rl);
      fnd_message.set_token('TYPE_ID',-146);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_auto_enrt_mthd_rl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_dflt_enrt_det_rl >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   dflt_enrt_det_rl      Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_dflt_enrt_det_rl(p_oipl_id                     in number,
                               p_business_group_id           in number,
                               p_dflt_enrt_det_rl            in number,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_det_rl';
  l_api_updating boolean;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dflt_enrt_det_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.dflt_enrt_det_rl
      or not l_api_updating)
      and p_dflt_enrt_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_dflt_enrt_det_rl,
        p_formula_type_id   => -32,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_dflt_enrt_det_rl);
      fnd_message.set_token('TYPE_ID',-32);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_det_rl;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_mndtry_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   mndtry_rl             Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_mndtry_rl(p_oipl_id                     in number,
                        p_business_group_id           in number,
                        p_mndtry_rl                   in number,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mndtry_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mndtry_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.mndtry_rl
      or not l_api_updating)
      and p_mndtry_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_mndtry_rl,
        p_formula_type_id   => -159,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_mndtry_rl);
      fnd_message.set_token('TYPE_ID',-159);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mndtry_rl;
-- ----------------------------------------------------------------------------
-- |-------------------< chk_rqd_perd_enrt_nenrt_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   rqd_perd_enrt_nenrt_rl             Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_rqd_perd_enrt_nenrt_rl(p_oipl_id                     in number,
                        p_business_group_id           in number,
                        p_rqd_perd_enrt_nenrt_rl                   in number,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_perd_enrt_nenrt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rqd_perd_enrt_nenrt_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.rqd_perd_enrt_nenrt_rl
      or not l_api_updating)
      and p_rqd_perd_enrt_nenrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_rqd_perd_enrt_nenrt_rl,
        p_formula_type_id   => -513,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_rqd_perd_enrt_nenrt_rl);
      fnd_message.set_token('TYPE_ID',-513);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_perd_enrt_nenrt_rl;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_postelcn_edit_rl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   postelcn_edit_rl      Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_postelcn_edit_rl(p_oipl_id                     in number,
                               p_business_group_id           in number,
                               p_postelcn_edit_rl            in number,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_postelcn_edit_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_postelcn_edit_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.postelcn_edit_rl
      or not l_api_updating)
      and p_postelcn_edit_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_postelcn_edit_rl,
        p_formula_type_id   => -215,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_postelcn_edit_rl);
      fnd_message.set_token('TYPE_ID',-215);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_postelcn_edit_rl;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_vrfy_fmly_mmbr_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   vrfy_fmly_mmbr_rl     Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_vrfy_fmly_mmbr_rl(p_oipl_id                     in number,
                                p_business_group_id           in number,
                                p_vrfy_fmly_mmbr_rl           in number,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrfy_fmly_mmbr_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.vrfy_fmly_mmbr_rl
      or not l_api_updating)
      and p_vrfy_fmly_mmbr_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_vrfy_fmly_mmbr_rl,
        p_formula_type_id   => -21,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_vrfy_fmly_mmbr_rl);
      fnd_message.set_token('TYPE_ID',-21);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_rl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_enrt_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   enrt_rl     Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_enrt_rl(p_oipl_id                     in number,
                                p_business_group_id           in number,
                                p_enrt_rl           in number,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_oipl_id                     => p_oipl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_rl,hr_api.g_number)
      <> ben_cop_shd.g_old_rec.enrt_rl
      or not l_api_updating)
      and p_enrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_enrt_rl,
        p_formula_type_id   => -393,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_enrt_rl);
      fnd_message.set_token('TYPE_ID',-393);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_rl;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_cd_rl_combination >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code is RULE then the rule must be
--   defined else it should not be.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_dflt_enrt_det_rl        in varchar2
--   p_dflt_enrt_cd            in number
--
-- object_version_number      Object version number of record being
--                            inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
procedure chk_cd_rl_combination
(
   p_dflt_enrt_cd        in varchar2,
   p_dflt_enrt_det_rl    in number ) IS
   l_proc         varchar2(72) := g_package||'chk_cd_rl_combination';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_dflt_enrt_cd <> 'RL' and p_dflt_enrt_det_rl is not null)
  then
     fnd_message.set_name('BEN','BEN_91730_NO_RULE');
     fnd_message.raise_error;
  end if;
  if (p_dflt_enrt_cd = 'RL' and p_dflt_enrt_det_rl is null)
  then
     fnd_message.set_name('BEN','BEN_91731_RULE');
     fnd_message.raise_error;
  end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
END;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_auto_enrt_and_mthd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the automatic enrollment flag
--   flag is checked, the plan record for the option must have the enrollment
--   method = "Automatic".
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   auto_enrt_flag        Automatic Enrollment Flag.
--   pl_id                 pl_id.
--   effective_date        Session date of record.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_auto_enrt_and_mthd(p_oipl_id                   in number,
                                 p_auto_enrt_flag            in varchar2,
                                 p_pl_id                     in number,
                                 p_effective_date            in date,
                                 p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_and_mthd';
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f    pl
    where  pl.pl_id = p_pl_id
      and  pl.enrt_mthd_cd = 'A'
      and  p_effective_date between pl.effective_start_date
           and pl.effective_end_date
      and  pl.business_group_id + 0 = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    if p_auto_enrt_flag = 'Y' then
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise an error as the Enrollment Method Code has a value of
        -- "automatic".
        --
        fnd_message.set_name('BEN','BEN_91967_AUTO_ENRT_AND_MTHD');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    end if;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_auto_enrt_and_mthd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_auto_enrt_and_flags >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the automatic enrollment flag
--   flag is checked, the mandatory flag and default flag must not be checked.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   auto_enrt_flag        Automatic Enrollment Flag.
--   mndtry_flag           Mandatory Flag.
--   dflt_flag             Default Flag.
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
Procedure chk_auto_enrt_and_flags(p_auto_enrt_flag            in varchar2,
                                  p_mndtry_flag               in varchar2,
                                  p_dflt_flag                 in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_and_flags';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    if p_auto_enrt_flag = 'Y' and
       (p_mndtry_flag = 'Y' or p_dflt_flag = 'Y') then
       --
       -- raise an error as the Mandatory Flag or Default Flag has a value
       -- of 'Y'.
       --
       fnd_message.set_name('BEN','BEN_91969_AUTO_ENRT_AND_FLAGS');
       fnd_message.raise_error;
       --
      --
    end if;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_auto_enrt_and_flags;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_plan_pcp_before_oipl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that an oipl cannot have its pcp_dsgn_cd
--   nor its pcp_dpnt_dsgn_cd set to not null until the corresponding plan has
--   a ben_pl_pcp row attached to it.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   pl_id                 FK of record being inserted or updated.
--   pcp_dsgn_cd           pcp designation code
--   pcp_dpnt_dsgn_cd      pcp dependent designation code
--   effective_date        Session date of record.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_plan_pcp_before_oipl(p_oipl_id                in number,
                                p_pl_id                     in number,
                                p_pcp_dsgn_cd               in varchar2,
                                p_pcp_dpnt_dsgn_cd          in varchar2,
                                p_effective_date            in date,
                                p_business_group_id         in number,
                                p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plan_pcp_before_oipl';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_pcp a
    where  a.pl_id = p_pl_id
    and    a.business_group_id = p_business_group_id;
  --
Begin
  --
 hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_oipl_id                     => p_oipl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and (p_pcp_dsgn_cd is not null or p_pcp_dpnt_dsgn_cd is not null)) then
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise an error as there is no ben_pl_pcp row for the corresponding plan.
        --
        fnd_message.set_name('BEN','BEN_92592_NO_PL_PCP_ROW');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_plan_pcp_before_oipl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_plan_oipl_mutexcl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the oipl is mutually exclusive
--   for the actl_prem_id. A plan cannot exist with this actl_prem_id
--   due to the ARC relationship on ben_actl_prem_f.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id               PK of record being inserted or updated.
--   actl_prem_id          actl_prem_id.
--   effective_date        Session date of record.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_plan_oipl_mutexcl(p_oipl_id                   in number,
                                p_actl_prem_id              in number,
                                p_effective_date            in date,
                                p_business_group_id         in number,
                                p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plan_oipl_mutexcl';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.actl_prem_id = p_actl_prem_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cop_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_oipl_id                     => p_oipl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and p_actl_prem_id is not null) then
    --
    -- Check if actl_prem_id is mutually exclusive.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this actl_prem_id has been assigned to plan(s).
        --
        fnd_message.set_name('BEN','BEN_91611_PLAN_OPTION_EXCL2');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_plan_oipl_mutexcl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_opt_id >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that option id is unique for a plan
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_oipl_id PK
--   p_opt_id ID of FK column
--   p_pl_id
--   p_effective_date session date
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
Procedure chk_opt_id (p_oipl_id               in number,
                      p_pl_id                 in number,
                      p_opt_id                in number,
                      p_validation_start_date in date,
                      p_validation_end_date   in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_opt_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  CURSOR c1 IS
    SELECT NULL
    FROM   ben_oipl_f cop
    WHERE  cop.opt_id               = p_opt_id
    AND    cop.pl_id                = p_pl_id
    AND    cop.oipl_id             <> nvl(p_oipl_id, hr_api.g_number)
    AND    cop.business_group_id    = p_business_group_id
    AND    p_validation_start_date <= cop.effective_end_date
    AND    p_validation_end_date   >= cop.effective_start_date
    --
    -- Start of CAGR band aid.
    --
    AND    NOT EXISTS(SELECT 'x'
                      FROM  ben_pl_f pln
                      ,     ben_pl_typ_f ptp
                      WHERE pln.pl_id                = p_pl_id
                      AND   pln.pl_typ_id            = ptp.pl_typ_id
                      AND   pln.business_group_id    = p_business_group_id
                      AND   p_validation_start_date <= pln.effective_end_date
                      AND   p_validation_end_date   >= pln.effective_start_date
                      AND   ptp.opt_typ_cd           = 'CAGR'
                      AND   ptp.business_group_id    = p_business_group_id
                      AND   p_validation_start_date <= ptp.effective_end_date
                      AND   p_validation_end_date   >= ptp.effective_start_date);
  --
  -- End of CAGR band aid.
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cop_shd.api_updating
     (p_oipl_id                 => p_oipl_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_opt_id,hr_api.g_number)
     <> nvl(ben_cop_shd.g_old_rec.opt_id, hr_api.g_number)
     or not l_api_updating) then
    --
    --
    open c1;
      --
      fetch c1 into l_exists;
      if c1%found then
        close c1;
        --
        -- raise error as this beneficiary already exists for this enrt rslt
        --
        fnd_message.set_name('BEN','BEN_91845_DUP_OPT');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_opt_id;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_ordr_num_unq_in_plan >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that ordr_num is unique for a plan
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_oipl_id PK
--   p_ordr_num
--   p_pl_id
--   p_effective_date session date
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
Procedure chk_ordr_num_unq_in_plan
          (p_oipl_id               in number,
           p_pl_id                 in number,
           p_ordr_num              in number,
           p_validation_start_date in date,
           p_validation_end_date   in date,
           p_effective_date        in date,
           p_business_group_id     in number,
           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ordr_num_unq_in_plan';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oipl_f
    where  ordr_num = p_ordr_num
    and    pl_id = p_pl_id
    and    oipl_id <> nvl(p_oipl_id, hr_api.g_number)
    and    business_group_id + 0 = p_business_group_id
    and    p_validation_start_date <= effective_end_date
    and    p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cop_shd.api_updating
     (p_oipl_id                 => p_oipl_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ordr_num,hr_api.g_number)
     <> nvl(ben_cop_shd.g_old_rec.ordr_num, hr_api.g_number)
     or not l_api_updating) then
    --
    --
    open c1;
      --
      fetch c1 into l_exists;
      if c1%found then
        close c1;
        --
        -- raise error as this ordr_num already exists for this Plans options
        --
        fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ordr_num_unq_in_plan;
--
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
            (p_dflt_enrt_det_rl              in number default hr_api.g_number,
             p_mndtry_rl                     in number default hr_api.g_number,
             p_rqd_perd_enrt_nenrt_rl                     in number default hr_api.g_number,
             p_actl_prem_id                  in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
             p_opt_id                        in number default hr_api.g_number,
   	     p_datetrack_mode	     	     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
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
    If ((nvl(p_dflt_enrt_det_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dflt_enrt_det_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_mndtry_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_mndtry_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_rqd_perd_enrt_nenrt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_rqd_perd_enrt_nenrt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_actl_prem_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_actl_prem_f',
             p_base_key_column => 'actl_prem_id',
             p_base_key_value  => p_actl_prem_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_actl_prem_f';
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
    If ((nvl(p_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_opt_f',
             p_base_key_column => 'opt_id',
             p_base_key_value  => p_opt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_opt_f';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
            (p_oipl_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
  l_opt_id number;
  l_Dummy  number;
  --
  cursor c1 is
    select cop.opt_id
    from   ben_oipl_f cop
    where  cop.oipl_id = p_oipl_id;
  --
  cursor c_epe is
    select null
    from   ben_elig_per_elctbl_chc epe
    where  epe.oipl_id = p_oipl_id;
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
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
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
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'oipl_id',
       p_argument_value => p_oipl_id);
    --
    open c1;
      fetch c1 into l_opt_id;
    close c1;
    --
    -- commented out to fix bug 1244535
/*
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_opt_f',
           p_base_key_column => 'opt_id',
           p_base_key_value  => l_opt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_opt_f';
      Raise l_rows_exist;
    End If;
*/
    -- Bug - 1894249
    -- Added validation to ensure that the option cannot be deleted
    -- if a participant has been enrolled in the oipl .

    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtt_enrt_rslt_f',
           p_base_key_column => 'oipl_id',
           p_base_key_value  => p_oipl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtt_enrt_rslt_f';
      Raise l_rows_exist;
    End If;

    If p_datetrack_mode = 'ZAP' then
    -- Check in Ben_elig_per_elctbl_chc added rbingi, Bug 4558201
    Open c_epe;
      Fetch c_epe into l_Dummy;
      --
      If c_epe%FOUND then
        l_table_name := 'ben_elig_per_elctbl_chc';
	Close c_epe ;
	Raise l_rows_exist ;
      End if;
     Close c_epe ;
    End if;

    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_to_prte_rsn_f',
           p_base_key_column => 'oipl_id',
           p_base_key_value  => p_oipl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_to_prte_rsn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_oipl_enrt_f',
           p_base_key_column => 'oipl_id',
           p_base_key_value  => p_oipl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_oipl_enrt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtn_elig_f',
           p_base_key_column => 'oipl_id',
           p_base_key_value  => p_oipl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtn_elig_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cvg_amt_calc_mthd_f',
           p_base_key_column => 'oipl_id',
           p_base_key_value  => p_oipl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cvg_amt_calc_mthd_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_base_rt_f',
           p_base_key_column => 'oipl_id',
           p_base_key_value  => p_oipl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_rows_exist;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    Raise;
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_cop_shd.g_rec_type,
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
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_oipl_id
  (p_oipl_id                     => p_rec.oipl_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_mndtry_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_mndtry_flag                 => p_rec.mndtry_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_dflt_flag                   => p_rec.dflt_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_auto_enrt_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_auto_enrt_flag              => p_rec.auto_enrt_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_elig_apls_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_elig_apls_flag              => p_rec.elig_apls_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_trk_inelig_per_flag         => p_rec.trk_inelig_per_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_drvbl_fctr_prtn_elig_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_drvbl_fctr_prtn_elig_flag    => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_prtn_elig_ovrid_alwd_flag   => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_drvbl_fctr_apls_rts_flag     => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_oipl_stat_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_oipl_stat_cd                => p_rec.oipl_stat_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_pcp_dsgn_cd
  (p_oipl_id               => p_rec.oipl_id,
   p_pcp_dsgn_cd           => p_rec.pcp_dsgn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_pcp_dpnt_dsgn_cd
  (p_oipl_id               => p_rec.oipl_id,
   p_pcp_dpnt_dsgn_cd      => p_rec.pcp_dpnt_dsgn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
  chk_dflt_enrt_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_dflt_enrt_cd                => p_rec.dflt_enrt_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_enrt_cd                     => p_rec.enrt_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
--
  chk_dflt_enrt_det_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_dflt_enrt_det_rl            => p_rec.dflt_enrt_det_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_auto_enrt_mthd_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_auto_enrt_mthd_rl           => p_rec.auto_enrt_mthd_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_mndtry_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_mndtry_rl                   => p_rec.mndtry_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_rqd_perd_enrt_nenrt_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_rqd_perd_enrt_nenrt_rl                   => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_postelcn_edit_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_postelcn_edit_rl            => p_rec.postelcn_edit_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_vrfy_fmly_mmbr_rl           => p_rec.vrfy_fmly_mmbr_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_enrt_rl                     => p_rec.enrt_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
--
  chk_cd_rl_combination
  (p_dflt_enrt_cd       => p_rec.dflt_enrt_cd,
   p_dflt_enrt_det_rl   => p_rec.dflt_enrt_det_rl);
  --
  chk_opt_id
  (p_oipl_id               => p_rec.oipl_id,
   p_pl_id                 => p_rec.pl_id,
   p_opt_id                => p_rec.opt_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_plan_pcp_before_oipl
  (p_oipl_id                   => p_rec.oipl_id,
   p_pl_id                     => p_rec.pl_id,
   p_pcp_dsgn_cd               => p_rec.pcp_dsgn_cd,
   p_pcp_dpnt_dsgn_cd          => p_rec.pcp_dpnt_dsgn_cd,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_ordr_num_unq_in_plan
  (p_oipl_id               => p_rec.oipl_id,
   p_pl_id                 => p_rec.pl_id,
   p_ordr_num              => p_rec.ordr_num,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cop_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_oipl_id
  (p_oipl_id                     => p_rec.oipl_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_mndtry_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_mndtry_flag                 => p_rec.mndtry_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_dflt_flag                   => p_rec.dflt_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_auto_enrt_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_auto_enrt_flag              => p_rec.auto_enrt_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_elig_apls_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_elig_apls_flag              => p_rec.elig_apls_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_trk_inelig_per_flag         => p_rec.trk_inelig_per_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_drvbl_fctr_prtn_elig_flag
  (p_oipl_id                      => p_rec.oipl_id,
   p_drvbl_fctr_prtn_elig_flag    => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_prtn_elig_ovrid_alwd_flag   => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
  (p_oipl_id                     => p_rec.oipl_id,
   p_drvbl_fctr_apls_rts_flag    => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_oipl_stat_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_oipl_stat_cd                => p_rec.oipl_stat_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_pcp_dsgn_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_pcp_dsgn_cd                 => p_rec.pcp_dsgn_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_pcp_dpnt_dsgn_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_pcp_dpnt_dsgn_cd            => p_rec.pcp_dpnt_dsgn_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_dflt_enrt_cd                => p_rec.dflt_enrt_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_oipl_id                     => p_rec.oipl_id,
   p_enrt_cd                     => p_rec.enrt_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
--
  chk_dflt_enrt_det_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_dflt_enrt_det_rl            => p_rec.dflt_enrt_det_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_auto_enrt_mthd_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_auto_enrt_mthd_rl           => p_rec.auto_enrt_mthd_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_mndtry_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_mndtry_rl                   => p_rec.mndtry_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_rqd_perd_enrt_nenrt_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_rqd_perd_enrt_nenrt_rl                   => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_postelcn_edit_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_postelcn_edit_rl            => p_rec.postelcn_edit_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_vrfy_fmly_mmbr_rl           => p_rec.vrfy_fmly_mmbr_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_oipl_id                     => p_rec.oipl_id,
   p_business_group_id           => p_rec.business_group_id,
   p_enrt_rl                     => p_rec.enrt_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
--
  chk_cd_rl_combination
  (p_dflt_enrt_cd       => p_rec.dflt_enrt_cd,
   p_dflt_enrt_det_rl   => p_rec.dflt_enrt_det_rl);
  --
  chk_auto_enrt_and_mthd
  (p_oipl_id                   => p_rec.oipl_id,
   p_auto_enrt_flag            => p_rec.auto_enrt_flag,
   p_pl_id                     => p_rec.pl_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id);
  --
  chk_auto_enrt_and_flags
  (p_auto_enrt_flag            => p_rec.auto_enrt_flag,
   p_mndtry_flag               => p_rec.mndtry_flag,
   p_dflt_flag                 => p_rec.dflt_flag);
  --
  chk_auto_enrt_and_mthd
  (p_oipl_id                   => p_rec.oipl_id,
   p_auto_enrt_flag            => p_rec.auto_enrt_flag,
   p_pl_id                     => p_rec.pl_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id);
  --
  chk_auto_enrt_and_flags
  (p_auto_enrt_flag            => p_rec.auto_enrt_flag,
   p_mndtry_flag               => p_rec.mndtry_flag,
   p_dflt_flag                 => p_rec.dflt_flag);
  --
  chk_plan_pcp_before_oipl
  (p_oipl_id                   => p_rec.oipl_id,
   p_pl_id                     => p_rec.pl_id,
   p_pcp_dsgn_cd               => p_rec.pcp_dsgn_cd,
   p_pcp_dpnt_dsgn_cd          => p_rec.pcp_dpnt_dsgn_cd,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_plan_oipl_mutexcl
  (p_oipl_id                   => p_rec.oipl_id,
   p_actl_prem_id              => p_rec.actl_prem_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_opt_id
  (p_oipl_id               => p_rec.oipl_id,
   p_pl_id                 => p_rec.pl_id,
   p_opt_id                => p_rec.opt_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ordr_num_unq_in_plan
  (p_oipl_id               => p_rec.oipl_id,
   p_pl_id                 => p_rec.pl_id,
   p_ordr_num              => p_rec.ordr_num,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_dflt_enrt_det_rl              => p_rec.dflt_enrt_det_rl,
     p_mndtry_rl                     => p_rec.mndtry_rl,
     p_rqd_perd_enrt_nenrt_rl                     => p_rec.rqd_perd_enrt_nenrt_rl,
     p_actl_prem_id                  => p_rec.actl_prem_id,
     p_pl_id                         => p_rec.pl_id,
     p_opt_id                        => p_rec.opt_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_cop_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_oipl_id		        => p_rec.oipl_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_oipl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_oipl_f b
    where b.oipl_id      = p_oipl_id
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
                             p_argument       => 'oipl_id',
                             p_argument_value => p_oipl_id);
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
end ben_cop_bus;

/
