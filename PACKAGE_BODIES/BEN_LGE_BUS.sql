--------------------------------------------------------
--  DDL for Package Body BEN_LGE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LGE_BUS" as
/* $Header: belgerhi.pkb 120.0 2005/05/28 03:23:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lge_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_chg_pgm_enrt_id >------|
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
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
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
Procedure chk_ler_chg_pgm_enrt_id(p_ler_chg_pgm_enrt_id  in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_chg_pgm_enrt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_chg_pgm_enrt_id,hr_api.g_number)
     <>  ben_lge_shd.g_old_rec.ler_chg_pgm_enrt_id) then
    --
    -- raise error as PK has changed
    --
    ben_lge_shd.constraint_error('BEN_LER_CHG_PGM_ENRT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_chg_pgm_enrt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lge_shd.constraint_error('BEN_LER_CHG_PGM_ENRT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_chg_pgm_enrt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   dflt_enrt_rl Value of formula rule id.
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
Procedure chk_dflt_enrt_rl(p_ler_chg_pgm_enrt_id         in number,
                           p_dflt_enrt_rl                in number,
                           p_effective_date              in date,
                           p_business_group_id           in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dflt_enrt_rl,hr_api.g_number)
      <> ben_lge_shd.g_old_rec.dflt_enrt_rl
      or not l_api_updating)
      and p_dflt_enrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_dflt_enrt_rl,
        p_formula_type_id   => -32,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_dflt_enrt_rl);
      fnd_message.set_token('TYPE_ID',-32);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   dflt_enrt_cd Value of lookup code.
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
Procedure chk_dflt_enrt_cd(p_ler_chg_pgm_enrt_id         in number,
                           p_dflt_enrt_cd                in varchar2,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id         => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_cd
      <> nvl(ben_lge_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_crnt_enrt_prclds_chg_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   crnt_enrt_prclds_chg_flag Value of lookup code.
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
Procedure chk_crnt_enrt_prclds_chg_flag(p_ler_chg_pgm_enrt_id  in number,
                                 p_crnt_enrt_prclds_chg_flag   in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crnt_enrt_prclds_chg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crnt_enrt_prclds_chg_flag
      <> nvl(ben_lge_shd.g_old_rec.crnt_enrt_prclds_chg_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_crnt_enrt_prclds_chg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_crnt_enrt_prclds_chg_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crnt_enrt_prclds_chg_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_auto_enrt_mthd_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   auto_enrt_mthd_rl Value of formula rule id.
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
Procedure chk_auto_enrt_mthd_rl(p_ler_chg_pgm_enrt_id         in number,
                                p_auto_enrt_mthd_rl           in number,
                                p_effective_date              in date,
                                p_business_group_id           in number,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_mthd_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> ben_lge_shd.g_old_rec.auto_enrt_mthd_rl
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
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
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
Procedure chk_enrt_mthd_cd(p_ler_chg_pgm_enrt_id         in number,
                           p_enrt_mthd_cd                in varchar2,
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
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_mthd_cd
      <> nvl(ben_lge_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_MTHD',
           p_lookup_code    => p_enrt_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_enrt_mthd_cd');
      fnd_message.set_token('TYPE','BEN_ENRT_MTHD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_mthd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   enrt_cd Value of lookup code.
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
Procedure chk_enrt_cd(p_ler_chg_pgm_enrt_id         in number,
                      p_enrt_cd                     in varchar2,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_lge_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_stl_elig_cant_chg_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   stl_elig_cant_chg_flag Value of lookup code.
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
Procedure chk_stl_elig_cant_chg_flag(p_ler_chg_pgm_enrt_id   in number,
                                p_stl_elig_cant_chg_flag     in varchar2,
                                p_effective_date             in date,
                                p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_stl_elig_cant_chg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_stl_elig_cant_chg_flag
      <> nvl(ben_lge_shd.g_old_rec.stl_elig_cant_chg_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_stl_elig_cant_chg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_stl_elig_cant_chg_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_stl_elig_cant_chg_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   enrt_rl Value of formula rule id.
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
Procedure chk_enrt_rl(p_ler_chg_pgm_enrt_id         in number,
                      p_enrt_rl                     in number,
                      p_effective_date              in date,
                      p_business_group_id           in number,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id                => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_rl,hr_api.g_number)
      <> ben_lge_shd.g_old_rec.enrt_rl
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
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_code_rule_depencency >-----------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_chg_pgm_enrt_id PK of record being inserted or updated.
--   enrt_cd Value of lookup code.
--   enrt_rl
--   dflt_enrt_cd
--   dflt_enrt_rl
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
Procedure chk_code_rule_dependency(p_ler_chg_pgm_enrt_id       in number,
                                   p_enrt_cd                   in varchar2,
                                   p_enrt_rl                   in number,
                                   p_dflt_enrt_cd              in varchar2,
                                   p_dflt_enrt_rl              in number,
                                   p_effective_date            in date,
                                   p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_code_rule_dependency ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lge_shd.api_updating
    (p_ler_chg_pgm_enrt_id         => p_ler_chg_pgm_enrt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_enrt_cd,hr_api.g_varchar2)
               <> nvl(ben_lge_shd.g_old_rec.enrt_cd,hr_api.g_varchar2) or
          nvl(p_enrt_rl,hr_api.g_number)
               <> nvl(ben_lge_shd.g_old_rec.enrt_rl,hr_api.g_number))

      or not l_api_updating) then
    --
    if (p_enrt_cd = 'RL' and p_enrt_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
             fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_enrt_cd,hr_api.g_varchar2) <> 'RL' and p_enrt_rl is
       not null then
             --
             fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and
         (nvl(p_dflt_enrt_cd,hr_api.g_varchar2)
               <> nvl(ben_lge_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2) or
          nvl(p_dflt_enrt_rl,hr_api.g_number)
               <> nvl(ben_lge_shd.g_old_rec.dflt_enrt_rl,hr_api.g_number))

      or not l_api_updating) then
    --
    if (p_dflt_enrt_cd = 'RL' and p_dflt_enrt_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
             fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_dflt_enrt_cd,hr_api.g_varchar2) <> 'RL' and p_dflt_enrt_rl is
       not null then
             --
             fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_code_rule_dependency;
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
            (p_ler_id                        in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
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
    If ((nvl(p_ler_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
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
            (p_ler_chg_pgm_enrt_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
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
       p_argument       => 'ler_chg_pgm_enrt_id',
       p_argument_value => p_ler_chg_pgm_enrt_id);
    --
    --
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
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
	(p_rec 			 in ben_lge_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ler_chg_pgm_enrt_id
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_rl
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_dflt_enrt_rl        => p_rec.dflt_enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crnt_enrt_prclds_chg_flag
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_crnt_enrt_prclds_chg_flag         => p_rec.crnt_enrt_prclds_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_auto_enrt_mthd_rl
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_auto_enrt_mthd_rl        => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_mthd_cd         => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_cd         => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_elig_cant_chg_flag
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_stl_elig_cant_chg_flag         => p_rec.stl_elig_cant_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_rl        => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_code_rule_dependency
  (p_ler_chg_pgm_enrt_id         => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_cd                     => p_rec.enrt_cd,
   p_enrt_rl                     => p_rec.enrt_rl,
   p_dflt_enrt_cd                => p_rec.dflt_enrt_cd,
   p_dflt_enrt_rl                => p_rec.dflt_enrt_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_lge_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ler_chg_pgm_enrt_id
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_rl
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_dflt_enrt_rl        => p_rec.dflt_enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crnt_enrt_prclds_chg_flag
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_crnt_enrt_prclds_chg_flag         => p_rec.crnt_enrt_prclds_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_auto_enrt_mthd_rl
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_auto_enrt_mthd_rl        => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_mthd_cd         => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_cd         => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stl_elig_cant_chg_flag
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_stl_elig_cant_chg_flag         => p_rec.stl_elig_cant_chg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_rl
  (p_ler_chg_pgm_enrt_id          => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_rl        => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_code_rule_dependency
  (p_ler_chg_pgm_enrt_id         => p_rec.ler_chg_pgm_enrt_id,
   p_enrt_cd                     => p_rec.enrt_cd,
   p_enrt_rl                     => p_rec.enrt_rl,
   p_dflt_enrt_cd                => p_rec.dflt_enrt_cd,
   p_dflt_enrt_rl                => p_rec.dflt_enrt_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ler_id                        => p_rec.ler_id,
             p_pgm_id                        => p_rec.pgm_id,
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
	(p_rec 			 in ben_lge_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
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
     p_ler_chg_pgm_enrt_id		=> p_rec.ler_chg_pgm_enrt_id);
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
  (p_ler_chg_pgm_enrt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_chg_pgm_enrt_f b
    where b.ler_chg_pgm_enrt_id      = p_ler_chg_pgm_enrt_id
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
                             p_argument       => 'ler_chg_pgm_enrt_id',
                             p_argument_value => p_ler_chg_pgm_enrt_id);
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
end ben_lge_bus;

/
