--------------------------------------------------------
--  DDL for Package Body BEN_CPP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPP_BUS" as
/* $Header: becpprhi.pkb 120.0 2005/05/28 01:16:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cpp_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_duplicate_ordr_num >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_plip_id
--    p_ordr_num
--    p_effective_date
--    p_object_version_number
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
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_ordr_num
          ( p_plip_id  in number
           ,p_pgm_id in number
           ,p_ordr_num in number
           ,p_effective_date in date
           ,p_validation_start_date  in date
           ,p_validation_end_date    in date
           ,p_business_group_id in number)
is
   l_proc   varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy    char(1);
   cursor c1 is select null
                  from ben_plip_f
                 where plip_id <> nvl(p_plip_id,-1)
                   and pgm_id = p_pgm_id
                   and business_group_id + 0 = p_business_group_id
                   and ordr_num = p_ordr_num
                   and p_validation_start_date <= effective_end_date
                   and p_validation_end_date >= effective_start_date;

--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c1;
   fetch c1 into l_dummy;
   if c1%found then
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
   end if;
   close c1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_duplicate_ordr_num;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_duplicate_pl_id_in_pgm>------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks whether one pl_Id is associated
--   to a program id once
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_id    Plan Id
--   p_pgm_id   Program Id
--   p_effective_date   effective_date
--   p_business_group_id  business_group_id
--   p_plip_id            PK of record being inserted ot updated
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
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_pl_id_in_pgm(p_pl_id            in number
                                       ,p_effective_date    in date
                                       ,p_business_group_id in number
                                       ,p_pgm_id            in number
                                       ,p_plip_id            in number
                                       ,p_validation_start_date  in date
                                       ,p_validation_end_date    in date)
is
l_proc	    varchar2(72) := g_package||' chk_duplicate_pl_id_in_pgm ';
l_dummy   char(1);

cursor c1 is select null
             from   ben_plip_f
             where  pgm_id = p_pgm_id
             and    business_group_id + 0 = p_business_group_id
             and    pl_id = p_pl_id
             and    plip_id <> nvl(p_plip_id, -1)
             and    p_validation_start_date <= effective_end_date
             and    p_validation_end_date >= effective_start_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_validation_start_date:'||p_validation_start_date, 5);
  hr_utility.set_location('p_validation_end_date:'||p_validation_end_date, 5);
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
          fnd_message.set_name('BEN','BEN_91721_DUP_PL_ID_IN_PGM');
          fnd_message.raise_error;
      end if;
      close c1;
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_duplicate_pl_id_in_pgm;
--
-- ----------------------------------------------------------------------------
-- |------< chk_plan_allowed_in_pgm >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     pl_id
--     effective_date
--     business_group_id
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
-- ----------------------------------------------------------------------------
Procedure chk_plan_allowed_in_pgm(p_pl_id  in varchar2
                                 ,p_effective_date in date
                                 ,p_business_group_id in number)
is
l_proc	    varchar2(72) := g_package||' chk_plan_allowed_in_pgm ';
l_pl_cd       varchar2(30);
cursor c1 is select pl_cd
             from   ben_pl_f
             where  pl_id = p_pl_id
             and    p_effective_date between effective_start_date
                                         and effective_end_date
             and    business_group_id = p_business_group_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   open c1;
   fetch c1 into l_pl_cd;
   close c1;
   if l_pl_cd = 'MYNTBPGM' then
       fnd_message.set_name('BEN','BEN_91787_PL_ALWD_IN_PGM');
       fnd_message.raise_error;
   end if;
   hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_plan_allowed_in_pgm;
--

-- --------------------------------chk_cd_rl_combination >-------------------------------|
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
--   p_vrfy_fmly_mmbr_cd         in varchar2,
--   p_vrfy_fmly_mmbr_rl         in number
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
procedure chk_cd_rl_combination
(
    p_vrfy_fmly_mmbr_cd     in varchar2,
    p_vrfy_fmly_mmbr_rl     in number ) IS
   l_proc         varchar2(72) := g_package||'chk_cd_rl_combination';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if    ( p_vrfy_fmly_mmbr_cd <> 'RL' and  p_vrfy_fmly_mmbr_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if ( p_vrfy_fmly_mmbr_cd = 'RL' and p_vrfy_fmly_mmbr_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
--leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cd_rl_combination;

---
-- ----------------------------------------------------------------------------
-- |------< chk_plip_id >------|
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
--   plip_id PK of record being inserted or updated.
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
Procedure chk_plip_id(p_plip_id                in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plip_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_plip_id                => p_plip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_plip_id,hr_api.g_number)
     <>  ben_cpp_shd.g_old_rec.plip_id) then
    --
    -- raise error as PK has changed
    --
    ben_cpp_shd.constraint_error('BEN_PLIP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_plip_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cpp_shd.constraint_error('BEN_PLIP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_plip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_det_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   dflt_enrt_det_rl Value of formula rule id.
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
Procedure chk_dflt_enrt_det_rl
              (p_plip_id                in number,
               p_dflt_enrt_det_rl       in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_dflt_enrt_det_rl
    and    ff.formula_type_id = -32 /*default enrollment det */
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dflt_enrt_det_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.dflt_enrt_det_rl
      or not l_api_updating)
      and p_dflt_enrt_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
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
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_det_rl;
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
--   plip_id               PK of record being inserted or updated.
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
Procedure chk_auto_enrt_mthd_rl
              (p_plip_id                in number,
               p_auto_enrt_mthd_rl      in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_auto_enrt_mthd_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_auto_enrt_mthd_rl
    and    ff.formula_type_id = -146 /*default enrollment det */
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.auto_enrt_mthd_rl
      or not l_api_updating)
      and p_auto_enrt_mthd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91953_NVLD_AUTO_ENR_MTH_RL');
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
end chk_auto_enrt_mthd_rl;
--


Procedure chk_vrfy_fmly_mmbr_cd(p_plip_id                     in number,
                                p_vrfy_fmly_mmbr_cd           in varchar2,
                                p_effective_date              in date,
                                p_object_version_number       in number) is

  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrfy_fmly_mmbr_cd
      <> nvl(ben_cpp_shd.g_old_rec.vrfy_fmly_mmbr_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_vrfy_fmly_mmbr_cd is not null
  then
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
      fnd_message.set_token('FIELD', 'p_vrfy_fmly_mmbr_cd');
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

-------------------------



Procedure chk_use_csd_rsd_prccng_cd(p_plip_id                     in number,
                                p_use_csd_rsd_prccng_cd           in varchar2,
                                p_effective_date              in date,
                                p_object_version_number       in number) is

  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_csd_rsd_prccng_cd
      <> nvl(ben_cpp_shd.g_old_rec.use_csd_rsd_prccng_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_use_csd_rsd_prccng_cd is not null
  then
   -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_USE_CSD_RSD_PRCCNG',
           p_lookup_code    => p_use_csd_rsd_prccng_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_use_csd_rsd_prccng_cd');
      fnd_message.set_token('TYPE','BEN_USE_CSD_RSD_PRCCNG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_csd_rsd_prccng_cd;


--------

Procedure chk_vrfy_fmly_mmbr_rl
  (p_plip_id               in number
  ,p_vrfy_fmly_mmbr_rl     in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_effective_date  => p_effective_date,
     p_plip_id         => p_plip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrfy_fmly_mmbr_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.vrfy_fmly_mmbr_rl
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
end chk_vrfy_fmly_mmbr_rl;
--
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
--   plip_id               PK of record being inserted or updated.
--   enrt_rl               Value of formula rule id.
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
Procedure chk_enrt_rl
              (p_plip_id                in number,
               p_enrt_rl                in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_rl
    and    ff.formula_type_id = -393 /*default enrollment det */
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.enrt_rl
      or not l_api_updating)
      and p_enrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91952_INVLD_ENRT_RL');
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
end chk_enrt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_to_asn_pndg_ctfn_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id               PK of record being inserted or updated.
--   enrt_rl               Value of formula rule id.
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
Procedure chk_dflt_to_asn_pndg_ctfn_rl
              (p_plip_id                                 in number,
               p_dflt_to_asn_pndg_ctfn_rl                in number,
               p_effective_date                          in date,
               p_object_version_number                   in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_to_asn_pndg_ctfn_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_dflt_to_asn_pndg_ctfn_rl
    and    ff.formula_type_id = -454
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dflt_to_asn_pndg_ctfn_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.dflt_to_asn_pndg_ctfn_rl
      or not l_api_updating)
      and p_dflt_to_asn_pndg_ctfn_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_dflt_to_asn_pndg_ctfn_rl);
        fnd_message.set_token('TYPE_ID',-454);
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
end chk_dflt_to_asn_pndg_ctfn_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mn_cvg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id               PK of record being inserted or updated.
--   enrt_rl               Value of formula rule id.
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
Procedure chk_mn_cvg_rl
              (p_plip_id                                 in number,
               p_mn_cvg_rl                               in number,
               p_effective_date                          in date,
               p_object_version_number                   in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mn_cvg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_mn_cvg_rl
    and    ff.formula_type_id = -164
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mn_cvg_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.mn_cvg_rl
      or not l_api_updating)
      and p_mn_cvg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_mn_cvg_rl);
        fnd_message.set_token('TYPE_ID',-164);
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
end chk_mn_cvg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mx_cvg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id               PK of record being inserted or updated.
--   enrt_rl               Value of formula rule id.
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
Procedure chk_mx_cvg_rl
              (p_plip_id                                 in number,
               p_mx_cvg_rl                               in number,
               p_effective_date                          in date,
               p_object_version_number                   in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mx_cvg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_mx_cvg_rl
    and    ff.formula_type_id = -161
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_cvg_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.mx_cvg_rl
      or not l_api_updating)
      and p_mx_cvg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_mx_cvg_rl);
        fnd_message.set_token('TYPE_ID',-161);
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
end chk_mx_cvg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prort_prtl_yr_cvg_rstrn_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id               PK of record being inserted or updated.
--   enrt_rl               Value of formula rule id.
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
Procedure chk_prort_prtl_yr_cvg_rstrn_rl
              (p_plip_id                                 in number,
               p_prort_prtl_yr_cvg_rstrn_rl              in number,
               p_effective_date                          in date,
               p_object_version_number                   in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prort_prtl_yr_cvg_rstrn_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_prort_prtl_yr_cvg_rstrn_rl
    and    ff.formula_type_id = -166
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prort_prtl_yr_cvg_rstrn_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_rl
      or not l_api_updating)
      and p_prort_prtl_yr_cvg_rstrn_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_prort_prtl_yr_cvg_rstrn_rl);
        fnd_message.set_token('TYPE_ID',-166);
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
end chk_prort_prtl_yr_cvg_rstrn_rl;
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
--   plip_id PK of record being inserted or updated.
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
Procedure chk_dflt_enrt_cd(p_plip_id                in number,
                            p_dflt_enrt_cd               in varchar2,
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
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_cd
      <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91216_INV_DFLT_ENRT_MTHD');
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
-- |------< chk_dflt_to_asn_pndg_ctfn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
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
Procedure chk_dflt_to_asn_pndg_ctfn_cd(p_plip_id          in number,
                            p_dflt_to_asn_pndg_ctfn_cd    in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_to_asn_pndg_ctfn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_to_asn_pndg_ctfn_cd
      <> nvl(ben_cpp_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_to_asn_pndg_ctfn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DFLT_TO_ASN_PNDG_CTFN',
           p_lookup_code    => p_dflt_to_asn_pndg_ctfn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dflt_to_asn_pndg_ctfn_cd');
      fnd_message.set_token('TYPE', 'BEN_DFLT_TO_ASN_PNDG_CTFN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_to_asn_pndg_ctfn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_unsspnd_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
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
Procedure chk_unsspnd_enrt_cd(p_plip_id          in number,
                            p_unsspnd_enrt_cd    in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_unsspnd_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_unsspnd_enrt_cd
      <> nvl(ben_cpp_shd.g_old_rec.unsspnd_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_unsspnd_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_UNSSPND_ENRT',
           p_lookup_code    => p_unsspnd_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_unsspnd_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_UNSSPND_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_unsspnd_enrt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prort_prtl_yr_cvg_rstrn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
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
Procedure chk_prort_prtl_yr_cvg_rstrn_cd(p_plip_id          in number,
                            p_prort_prtl_yr_cvg_rstrn_cd  in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prort_prtl_yr_cvg_rstrn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prort_prtl_yr_cvg_rstrn_cd
      <> nvl(ben_cpp_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prort_prtl_yr_cvg_rstrn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRORT_PRTL_YR_CVG_RSTRN',
           p_lookup_code    => p_prort_prtl_yr_cvg_rstrn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prort_prtl_yr_cvg_rstrn_cd');
      fnd_message.set_token('TYPE', 'BEN_PRORT_PRTL_YR_CVG_RSTRN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prort_prtl_yr_cvg_rstrn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_incr_r_decr_only_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
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
Procedure chk_cvg_incr_r_decr_only_cd(p_plip_id          in number,
                            p_cvg_incr_r_decr_only_cd  in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_incr_r_decr_only_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_incr_r_decr_only_cd
      <> nvl(ben_cpp_shd.g_old_rec.cvg_incr_r_decr_only_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cvg_incr_r_decr_only_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CVG_INCR_R_DECR_ONLY',
           p_lookup_code    => p_cvg_incr_r_decr_only_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cvg_incr_r_decr_only_cd');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_incr_r_decr_only_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnft_or_option_rstrctn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
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
Procedure chk_bnft_or_option_rstrctn_cd(p_plip_id         in number,
                            p_bnft_or_option_rstrctn_cd   in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_or_option_rstrctn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_or_option_rstrctn_cd
      <> nvl(ben_cpp_shd.g_old_rec.bnft_or_option_rstrctn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_or_option_rstrctn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNFT_R_OPT_RSTRN',
           p_lookup_code    => p_bnft_or_option_rstrctn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bnft_or_option_rstrctn_cd');
      fnd_message.set_token('TYPE','BEN_BNFT_R_OPT_RSTRN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bnft_or_option_rstrctn_cd;
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
--   plip_id               PK of record being inserted or updated.
--   enrt_mthd_cd          Value of lookup code.
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
Procedure chk_enrt_mthd_cd(p_plip_id                     in number,
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
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_mthd_cd
      <> nvl(ben_cpp_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91951_INVLD_ENRT_MTHD_CD');
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
--   plip_id               PK of record being inserted or updated.
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
Procedure chk_enrt_cd(p_plip_id                     in number,
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
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_cpp_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91950_INVALID_ENRT_CD');
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
-- |------< chk_plip_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   plip_stat_cd Value of lookup code.
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
Procedure chk_plip_stat_cd(p_plip_id                in number,
                            p_plip_stat_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plip_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_plip_stat_cd
      <> nvl(ben_cpp_shd.g_old_rec.plip_stat_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_plip_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91217_INVLD_STAT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_plip_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
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
Procedure chk_dflt_flag(p_plip_id                in number,
                            p_dflt_flag               in varchar2,
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
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_cpp_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91210_INVLD_DFLT_FLAG');
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
-- |------< chk_alws_unrstrctd_enrt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id                   PK of record being inserted or updated.
--   alws_unrstrctd_enrt_flag  Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                               inserted or updated.
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
Procedure chk_alws_unrstrctd_enrt_flag(p_plip_id          in number,
                            p_alws_unrstrctd_enrt_flag    in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_alws_unrstrctd_enrt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_alws_unrstrctd_enrt_flag
      <> nvl(ben_cpp_shd.g_old_rec.alws_unrstrctd_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_alws_unrstrctd_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alws_unrstrctd_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91949_ALWS_UNRSTR_ENRT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alws_unrstrctd_enrt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_cvg_amt_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id                   PK of record being inserted or updated.
--   no_mn_cvg_amt_apls_flag   Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                               inserted or updated.
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
Procedure chk_no_mn_cvg_amt_apls_flag(p_plip_id                 in number,
                                       p_no_mn_cvg_amt_apls_flag in varchar2,
                                       p_effective_date          in date,
                                       p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_cvg_amt_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_cvg_amt_apls_flag
      <> nvl(ben_cpp_shd.g_old_rec.no_mn_cvg_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_cvg_amt_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_cvg_amt_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mn_cvg_amt_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_cvg_amt_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_cvg_incr_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id                   PK of record being inserted or updated.
--   no_mn_cvg_incr_apls_flag  Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                               inserted or updated.
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
Procedure chk_no_mn_cvg_incr_apls_flag(p_plip_id                 in number,
                                       p_no_mn_cvg_incr_apls_flag in varchar2,
                                       p_effective_date          in date,
                                       p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_cvg_incr_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_cvg_incr_apls_flag
      <> nvl(ben_cpp_shd.g_old_rec.no_mn_cvg_incr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_cvg_incr_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_cvg_incr_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mn_cvg_incr_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_cvg_incr_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_cvg_amt_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id                   PK of record being inserted or updated.
--   no_mx_cvg_amt_apls_flag   Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                               inserted or updated.
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
Procedure chk_no_mx_cvg_amt_apls_flag(p_plip_id                 in number,
                                       p_no_mx_cvg_amt_apls_flag in varchar2,
                                       p_effective_date          in date,
                                       p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_cvg_amt_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_cvg_amt_apls_flag
      <> nvl(ben_cpp_shd.g_old_rec.no_mx_cvg_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_cvg_amt_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_amt_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mx_cvg_amt_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_cvg_amt_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_cvg_incr_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id                   PK of record being inserted or updated.
--   no_mx_cvg_incr_apls_flag  Value of lookup code.
--   effective_date            effective date
--   object_version_number     Object version number of record being
--                               inserted or updated.
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
Procedure chk_no_mx_cvg_incr_apls_flag(p_plip_id                 in number,
                                       p_no_mx_cvg_incr_apls_flag in varchar2,
                                       p_effective_date          in date,
                                       p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_cvg_incr_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_cvg_incr_apls_flag
      <> nvl(ben_cpp_shd.g_old_rec.no_mx_cvg_incr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_cvg_incr_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_incr_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mx_cvg_incr_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_cvg_incr_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_all_no_amount_flags >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the combination of the
--   "no amount" flags and the "amount" values is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   no_mn_cvg_dfnd_flag
--   mn_cvg_amt
--   no_mx_cvg_dfnd_flag
--   mx_cvg_alwd_amt
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
Procedure chk_all_no_amount_flags
     (p_no_mn_cvg_amt_apls_flag           in varchar2,
      p_mn_cvg_amt                        in number,
      p_no_mx_cvg_amt_apls_flag           in varchar2,
      p_mx_cvg_alwd_amt                   in number) is
  --
  l_proc varchar2(72) := g_package||'chk_all_no_amount_flags';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if it is a valid combination
  --
  if ((p_no_mn_cvg_amt_apls_flag='Y' and p_mn_cvg_amt>0) or
      (p_no_mn_cvg_amt_apls_flag='N' and p_mn_cvg_amt=0)) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_91150_NO_MIN_CVG_APLS_FLAG');
    fnd_message.raise_error;
    --
  end if;
  --
  -- check if it is a valid combination
  --
  if ((p_no_mx_cvg_amt_apls_flag='Y' and p_mx_cvg_alwd_amt>0) or
      (p_no_mx_cvg_amt_apls_flag='N' and p_mx_cvg_alwd_amt=0)) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_91149_NO_MAX_CVG_APLS_FLAG');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_no_amount_flags;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mn_val_mn_flag_mn_rule >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the minimum value, no
--   minimum flag, or the minimum rule is entered.  More than one of the
--   above mentioned may not have be entered.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_mn_cvg_amt                value of Minimum Value
--   p_no_mn_cvg_amt_apls_flag   value of No Minimum Flag
--   p_mn_cvg_rl                 value of Minimum Rule
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
Procedure chk_mn_val_mn_flag_mn_rule(p_mn_cvg_amt             in number,
                                     p_no_mn_cvg_amt_apls_flag in varchar2,
                                     p_mn_cvg_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mn_val_mn_flag_mn_rule';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_mn_cvg_amt is not null and (p_no_mn_cvg_amt_apls_flag = 'Y' or
     p_mn_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91945_MN_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_mn_cvg_rl is not null and (p_no_mn_cvg_amt_apls_flag = 'Y' or
     p_mn_cvg_amt is not null) then
      --
      fnd_message.set_name('BEN','BEN_91945_MN_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_no_mn_cvg_amt_apls_flag = 'Y' and (p_mn_cvg_amt is not null or
     p_mn_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91945_MN_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_val_mn_flag_mn_rule;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mx_val_mx_flag_mx_rule >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the maximum value, no
--   maximum flag, or the maximum rule is entered.  More than one of the
--   above mentioned may not have be entered.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_mx_cvg_alwd_amt           value of Minimum Value
--   p_no_mx_cvg_amt_apls_flag   value of No Minimum Flag
--   p_mx_cvg_rl                 value of Minimum Rule
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
Procedure chk_mx_val_mx_flag_mx_rule(p_mx_cvg_alwd_amt         in number,
                                     p_no_mx_cvg_amt_apls_flag in varchar2,
                                     p_mx_cvg_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mx_val_mx_flag_mx_rule';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_mx_cvg_alwd_amt is not null and (p_no_mx_cvg_amt_apls_flag = 'Y' or
     p_mx_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91946_MX_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_mx_cvg_rl is not null and (p_no_mx_cvg_amt_apls_flag = 'Y' or
     p_mx_cvg_alwd_amt is not null) then
      --
      fnd_message.set_name('BEN','BEN_91946_MX_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_no_mx_cvg_amt_apls_flag = 'Y' and (p_mx_cvg_alwd_amt is not null or
     p_mx_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91946_MX_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_val_mx_flag_mx_rule;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_cd_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If Program Provides no Automatic Enrollment Flag (ben_pgm_f) = 'YES' then
--   Enrollment Method Code cannot be 'Automatic'.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--	dflt_enrt_cd
--    pgm_id
--    business_group_id
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
Procedure chk_dflt_enrt_cd_dpndcy
             (p_plip_id                in number,
              p_pgm_id                 in number,
              p_dflt_enrt_cd      in varchar2,
              p_business_group_id      in number,
              p_effective_date         in date,
              p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dflt_enrt_cd_dpndcy';
  l_api_updating boolean;
  l_value varchar2(30);
  --
  cursor c1 is select pgm_prvds_no_auto_enrt_flag
               from   ben_pgm_f pgm
               where  pgm.pgm_id = p_pgm_id
               and    pgm.business_group_id +0 = p_business_group_id
               and    p_effective_date between pgm.effective_start_date
                                           and pgm.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_dflt_enrt_cd,hr_api.g_varchar2)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- If pgm provides no auto enroll flag = 'Y' then enrt mthd code can't be 'A'.
    -- Bypass this edit if mthd is null.
    --
    if p_dflt_enrt_cd is not null then
      open c1;
      fetch c1 into l_value;
      if c1%found then
        if l_value = 'Y' and p_dflt_enrt_cd = 'A' then
          --
          close c1;
          fnd_message.set_name('BEN','BEN_91219_DFLT_ENRT_MTHD_DPNDC');
          fnd_message.raise_error;
          --
        end if;
      end if;
      close c1;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_cd_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If Program Provides no Default Enrollment Flag (ben_pgm_f) = 'YES' then
--   the following fields must be null:  Default Flag, Default Enrollment
--    Method Code, and Default Enrollment Determination Rule.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--	dflt_enrt_cd
--    dflt_enrt_det_rl
--    dflt_flag
--    pgm_id
--    business_group_id
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
Procedure chk_dflt_dpndcy(p_plip_id               in number,
                          p_pgm_id                in number,
                          p_dflt_enrt_cd          in varchar2,
                          p_dflt_enrt_det_rl      in number,
                          p_dflt_flag             in varchar2,
                          p_business_group_id     in number,
                          p_effective_date        in date,
                          p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dflt_dpndcy';
  l_api_updating boolean;
  l_value varchar2(30);
  --
  cursor c1 is select pgm_prvds_no_dflt_enrt_flag
               from   ben_pgm_f pgm
               where  pgm.pgm_id = p_pgm_id
               and    pgm.business_group_id +0 = p_business_group_id
               and    p_effective_date between pgm.effective_start_date
                                           and pgm.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

 if (l_api_updating
      and
          (nvl(p_dflt_enrt_cd,hr_api.g_varchar2)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2) or
           nvl(p_dflt_enrt_det_rl,hr_api.g_number)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_det_rl,hr_api.g_number) or
           nvl(p_dflt_flag,hr_api.g_varchar2)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
           )
      or not l_api_updating) then
    --
    -- If pgm provides no dflt enroll flag = 'Y' then dflt fields must be null
    --
      open c1;
      fetch c1 into l_value;
      if c1%found then
        --
        if l_value = 'Y' and
             (p_dflt_enrt_cd is not null or
              p_dflt_enrt_det_rl is not null or
              p_dflt_flag = 'Y' ) then  -- Bug 2717870
          --
          close c1;
          fnd_message.set_name('BEN','BEN_91224_DFLT_FLAG_DPNDCY');
          fnd_message.raise_error;
          --
        end if;
      end if;
      close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_flag_dependency >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If Default Flag = 'Y', then Default Enrollment Method Code cannot be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--	dflt_enrt_cd
--    dflt_flag
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
Procedure chk_dflt_flag_dependency(p_plip_id                in number,
                            p_dflt_enrt_cd           in varchar2,
                            p_dflt_flag                   in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag_dependency';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
          (nvl(p_dflt_enrt_cd,hr_api.g_varchar2)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2) or
           nvl(p_dflt_flag,hr_api.g_varchar2)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
          )
      or not l_api_updating) then
    --
    -- check dependency
    --
    if p_dflt_flag = 'Y' and p_dflt_enrt_cd is null then
      --
      fnd_message.set_name('BEN','BEN_91221_DFLT_FLAG_DPNDCY2');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_flag_dependency;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_mthd_dpndcy >------|
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
--   plip_id PK of record being inserted or updated.
--   dflt_enrt_cd Value of lookup code.
--   dflt_enrt_det_rl
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
Procedure chk_dflt_enrt_mthd_dpndcy(p_plip_id      in number,
                            p_dflt_enrt_cd       in varchar2,
                            p_dflt_enrt_det_rl      in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_mthd_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id         => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dflt_enrt_cd,hr_api.g_varchar2)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2) or
          nvl(p_dflt_enrt_det_rl,hr_api.g_number)
               <> nvl(ben_cpp_shd.g_old_rec.dflt_enrt_det_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_dflt_enrt_cd = 'RL' and p_dflt_enrt_det_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91222_DFLT_ENRT_MTHD_CWOR');
             fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_dflt_enrt_cd,hr_api.g_varchar2) <> 'RL' and p_dflt_enrt_det_rl is not null then
             --
             fnd_message.set_name('BEN','BEN_91223_DFLT_ENRT_MTHD_RWOC');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_mthd_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_invk_imptd_incm_per_pgm >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- Only one imputed income plan allowed in a program.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--    pgm_id
--    pl_id
--    business_group_id
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
Procedure chk_invk_imptd_incm_per_pgm(p_plip_id               in number,
                                      p_pgm_id                in number,
                                      p_pl_id                 in number,
                                      p_business_group_id     in number,
                                      p_effective_date        in date,
                                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_invk_imptd_incm_per_pgm';
  l_count        number;
  l_imptd_incm_cd varchar2(30);
  --
  cursor pl_is_imputed is select imptd_incm_calc_cd
                          from   ben_pl_f
                          where  pl_id = p_pl_id
                          and    p_effective_date between effective_start_date
                                 and effective_end_date
                          and    business_group_id +0 = p_business_group_id;
  --
  cursor count_plans is select count(distinct pl.pl_id)
                from   ben_pl_f pl,
                       ben_plip_f plip
                where  plip.pgm_id = p_pgm_id
                and    plip.pl_id = pl.pl_id
                and    pl.imptd_incm_calc_cd = 'PRTT'
                and    plip.plip_id <> nvl(p_plip_id, -1)
                and    pl.business_group_id +0 = p_business_group_id
                and    p_effective_date between pl.effective_start_date
                       and pl.effective_end_date
                and    p_effective_date between plip.effective_start_date
                       and plip.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open pl_is_imputed;
  fetch pl_is_imputed into l_imptd_incm_cd;
  close pl_is_imputed;
  --
  if l_imptd_incm_cd = 'PRTT' then
     --
     open count_plans;
     fetch count_plans into l_count;
     close count_plans;
     if nvl(l_count,0) > 0 then
        --
        --  Raise error as there is a different Plan with the Invoke
        --  Imputed Plan set to ON for this Program
            --
            fnd_message.set_name('BEN','BEN_91763_INVK_IMPTD_FLAG_PGM');
            fnd_message.raise_error;
            --
        --
      end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_invk_imptd_incm_per_pgm;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_invk_flx_crpl_per_pgm >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- INVK_FLX_CR_PL_FLAG on plan can be 'Y' for only one plan in program.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--    pgm_id
--    pl_id
--    business_group_id
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
Procedure chk_invk_flx_crpl_per_pgm(p_plip_id               in number,
                                    p_pgm_id                in number,
                                    p_pl_id                 in number,
                                    p_business_group_id     in number,
                                    p_effective_date        in date,
                                    p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_invk_flx_crpl_per_pgm';
  l_count        number;
  l_flag         varchar2(30);
  l_pgm_typ_cd   ben_pgm_f.pgm_typ_cd%type;
  --
  cursor pl_is_flex is select invk_flx_cr_pl_flag
                         from   ben_pl_f
                         where  pl_id = p_pl_id
                         and    p_effective_date between effective_start_date
                                and effective_end_date
                         and    business_group_id = p_business_group_id;
  --
  cursor c_flex_pgm is select pgm_typ_cd
        	from   ben_pgm_f
        	where  pgm_id = p_pgm_id
        	and    p_effective_date between effective_start_date and effective_end_date
                and    business_group_id = p_business_group_id;
  --
  cursor count_plans is select count(distinct pl.pl_id)
                from   ben_pl_f pl,
                       ben_plip_f plip
                where  plip.pgm_id = p_pgm_id
                and    plip.pl_id = pl.pl_id
                and    pl.invk_flx_cr_pl_flag = 'Y'
                and    plip.plip_id <> nvl(p_plip_id, -1)
                and    pl.business_group_id = p_business_group_id
                and    p_effective_date between pl.effective_start_date
                       and pl.effective_end_date
                and    p_effective_date between plip.effective_start_date
                       and plip.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_flex_pgm;
  fetch c_flex_pgm into l_pgm_typ_cd;
  close c_flex_pgm;
  --

  open pl_is_flex;
  fetch pl_is_flex into l_flag;
  close pl_is_flex;
  --
  if l_flag = 'Y' then
     --
     --
     If l_pgm_typ_cd not in ('FLEX','FPC','COBRAFLX') then
        --
        --  Raise error as Flex plans can only be included into
        --  programs that are set up as Flex Credit Programs
        --
        fnd_message.set_name('BEN','BEN_93224_FLXCR_PL_NONFLX_PGM');
        fnd_message.raise_error;
     end if;
     --
     open count_plans;
     fetch count_plans into l_count;
     close count_plans;
     if nvl(l_count,0) > 0 then
        --
        --  Raise error as there is a different Plan with the Flex
        --  Credit Plan set to ON for this Program
            --
            fnd_message.set_name('BEN','BEN_91764_INVK_FLXCR_FLAG_PGM_');
            fnd_message.raise_error;
            --
        --
      end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_invk_flx_crpl_per_pgm;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_enrt_cvg_strt_dt_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_rl Value of formula rule id.
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
Procedure chk_enrt_cvg_strt_dt_rl(p_plip_id             in number,
                              p_enrt_cvg_strt_dt_rl     in number,
                              p_effective_date          in date,
                              p_object_version_number   in number,
                              p_business_group_id       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_strt_dt_rl
    and    ff.formula_type_id = -29
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.enrt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91251_INV_ENRT_START_DT_RL');
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
end chk_enrt_cvg_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_enrt_cvg_end_dt_rl >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_rl Value of formula rule id.
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
Procedure chk_enrt_cvg_end_dt_rl(p_plip_id            in number,
                              p_enrt_cvg_end_dt_rl    in number,
                              p_effective_date        in date,
                              p_object_version_number in number,
                              p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_end_dt_rl
    and    ff.formula_type_id = -30
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.enrt_cvg_end_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91250_INV_ENRT_END_DT_RL');
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
end chk_enrt_cvg_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_strt_dt_cd(p_plip_id               in number,
                            p_enrt_cvg_strt_dt_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_strt_dt_cd
      <> nvl(ben_cpp_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_cvg_strt_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_ENRT_CVG_STRT',
               p_lookup_code    => p_enrt_cvg_strt_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91300_INV_ENRT_STRT_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_end_dt_cd(p_plip_id               in number,
                            p_enrt_cvg_end_dt_cd         in varchar2,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_end_dt_cd
      <> nvl(ben_cpp_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_cvg_end_dt_cd is not null then
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_ENRT_CVG_END',
               p_lookup_code    => p_enrt_cvg_end_dt_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91301_INV_ENRT_END_DT_CD');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   rt_strt_dt_rl Value of formula rule id.
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
Procedure chk_rt_strt_dt_rl(p_plip_id                    in number,
                             p_rt_strt_dt_rl             in number,
                             p_effective_date            in date,
                             p_object_version_number     in number,
                             p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rt_strt_dt_rl
    and    ff.formula_type_id = -66
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.rt_strt_dt_rl
      or not l_api_updating)
      and p_rt_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_rt_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-66);
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
end chk_rt_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   rt_strt_dt_cd Value of lookup code.
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
Procedure chk_rt_strt_dt_cd(p_plip_id                     in number,
                            p_rt_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_strt_dt_cd
      <> nvl(ben_cpp_shd.g_old_rec.rt_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_STRT',
           p_lookup_code    => p_rt_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_strt_dt_cd');
      fnd_message.set_token('TYPE','BEN_RT_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   rt_end_dt_rl Value of formula rule id.
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
Procedure chk_rt_end_dt_rl(p_plip_id                      in number,
                             p_rt_end_dt_rl               in number,
                             p_effective_date             in date,
                             p_object_version_number      in number,
                             p_business_group_id          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rt_end_dt_rl
    and    ff.formula_type_id = -67
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_end_dt_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.rt_end_dt_rl
      or not l_api_updating)
      and p_rt_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_rt_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-67);
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
end chk_rt_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_postelcn_edit_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   postelcn_edit_rl Value of formula rule id.
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
Procedure chk_postelcn_edit_rl(p_plip_id                    in number,
                               p_postelcn_edit_rl           in number,
                               p_effective_date             in date,
                               p_object_version_number      in number,
                               p_business_group_id          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_postelcn_edit_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_postelcn_edit_rl
    and    ff.formula_type_id = -215
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_postelcn_edit_rl,hr_api.g_number)
      <> ben_cpp_shd.g_old_rec.postelcn_edit_rl
      or not l_api_updating)
      and p_postelcn_edit_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
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
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_postelcn_edit_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   rt_end_dt_cd Value of lookup code.
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
Procedure chk_rt_end_dt_cd(p_plip_id                     in number,
                            p_rt_end_dt_cd               in varchar2,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_end_dt_cd
      <> nvl(ben_cpp_shd.g_old_rec.rt_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_END',
           p_lookup_code    => p_rt_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rt_end_dt_cd');
      fnd_message.set_token('TYPE','BEN_RT_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_drvbl_fctr_apls_rts_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   drvbl_fctr_apls_rts_flag Value of lookup code.
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
Procedure chk_drvbl_fctr_apls_rts_flag(p_plip_id                   in number,
                                       p_drvbl_fctr_apls_rts_flag  in varchar2,
                                       p_effective_date            in date,
                                       p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_apls_rts_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_apls_rts_flag
      <> nvl(ben_cpp_shd.g_old_rec.drvbl_fctr_apls_rts_flag,hr_api.g_varchar2)
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
      fnd_message.set_token('FIELD', 'p_drvbl_fctr_apls_rts_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_apls_rts_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_drvbl_fctr_prtn_elig_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   drvbl_fctr_prtn_elig_flag Value of lookup code.
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
Procedure chk_drvbl_fctr_prtn_elig_flag(p_plip_id                   in number,
                                       p_drvbl_fctr_prtn_elig_flag  in varchar2,
                                       p_effective_date            in date,
                                       p_object_version_number     in number) is  --
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_prtn_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_prtn_elig_flag
      <> nvl(ben_cpp_shd.g_old_rec.drvbl_fctr_prtn_elig_flag,hr_api.g_varchar2)
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
      fnd_message.set_token('FIELD', 'p_drvbl_fctr_prtn_elig_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_prtn_elig_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_elig_apls_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   elig_apls_flag Value of lookup code.
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
Procedure chk_elig_apls_flag(p_plip_id                   in number,
                             p_elig_apls_flag            in varchar2,
                             p_effective_date            in date,
                             p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_apls_flag
      <> nvl(ben_cpp_shd.g_old_rec.elig_apls_flag,hr_api.g_varchar2)
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
      fnd_message.set_token('FIELD', 'p_elig_apls_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_prtn_elig_ovrid_alwd_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   prtn_elig_ovrid_alwd_flag Value of lookup code.
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
Procedure chk_prtn_elig_ovrid_alwd_flag(p_plip_id                   in number,
                                        p_prtn_elig_ovrid_alwd_flag in varchar2,
                                        p_effective_date            in date,
                                        p_object_version_number     in number)
  is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_elig_ovrid_alwd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_elig_ovrid_alwd_flag
      <> nvl(ben_cpp_shd.g_old_rec.prtn_elig_ovrid_alwd_flag,hr_api.g_varchar2)
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
      fnd_message.set_token('FIELD', 'p_prtn_elig_ovrid_alwd_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_elig_ovrid_alwd_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_trk_inelig_per_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   plip_id PK of record being inserted or updated.
--   trk_inelig_per_flag Value of lookup code.
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
Procedure chk_trk_inelig_per_flag(p_plip_id                   in number,
                                  p_trk_inelig_per_flag       in varchar2,
                                  p_effective_date            in date,
                                  p_object_version_number     in number)
  is
  --
  l_proc         varchar2(72) := g_package||'chk_trk_inelig_per_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_plip_id                     => p_plip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_trk_inelig_per_flag
      <> nvl(ben_cpp_shd.g_old_rec.trk_inelig_per_flag,hr_api.g_varchar2)
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
      fnd_message.set_token('FIELD', 'p_trk_inelig_per_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_trk_inelig_per_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_interim_cd_cvg_calc_mthd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the Interim Assign Code.
--	If the Coverage Calculation is set to Flat Amount (FLFX)
-- 	and Enter Value at Enrollment is checked in the Coverages Form,
--	this procedure will not allow to set the interim assign code to
--	Next Lower
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id          PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_interim_cd_cvg_calc_mthd(
		    p_dflt_to_asn_pndg_ctfn_cd  	in varchar2,
		    p_plip_id                     	in number,
		    p_pl_id                     	in number,
                    p_effective_date            	in date,
                    p_business_group_id            	in number,
                    p_object_version_number     	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_interim_cd_cvg_calc_mthd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null from BEN_CVG_AMT_CALC_MTHD_F cvg
    where nvl(cvg.pl_id,-1) = p_pl_id
    and cvg.cvg_mlt_cd = 'FLFX'
    and cvg.entr_val_at_enrt_flag = 'Y'
    and cvg.business_group_id = p_business_group_id
    and p_effective_date between cvg.effective_start_date and cvg.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_plip_id                     => p_plip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_to_asn_pndg_ctfn_cd,hr_api.g_varchar2)
     <>  nvl(ben_cpp_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd, '***')
     or not l_api_updating)
     and p_dflt_to_asn_pndg_ctfn_cd is not null then
    --
    hr_utility.set_location(l_proc, 15);
    --
    if (instr(p_dflt_to_asn_pndg_ctfn_cd,'NL'))>0 then
      --
      hr_utility.set_location(l_proc, 25);
      --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        hr_utility.set_location(l_proc, 35);
        fnd_message.set_name('BEN', 'BEN_93113_CD_CANNOT_NEXTLOWER');
        fnd_message.raise_error;
        --
      else
        --
        close c1;
        --
      end if;
      --
    end if; -- End of instr end if
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_interim_cd_cvg_calc_mthd;

-- ----------------------------------------------------------------------------
--  BUG 3966957
--  |------< chk_plan_delete_in_pgm >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     plip_id
--     effective_date
--
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
-- ----------------------------------------------------------------------------
Procedure chk_plan_delete_in_pgm( p_plip_id in number
                                 ,p_validation_start_date in date
				 ,p_validation_end_date in date
				 ,p_effective_date in date
				 ) is

l_proc    varchar2(72) := g_package||' chk_plan_delete_in_pgm ';
l_pl_id     number;
l_pgm_id    number;

cursor c2  is select pgm_id,pl_id
              from ben_plip_f
	      where plip_id =p_plip_id
	      and p_effective_date between effective_start_date
	      and effective_end_date;



cursor c1  is select  erp.pl_id
             from
             ben_enrt_perd_for_pl_f erp
	     where
	       (
	         ( enrt_perd_id in
		      (
		       select enrt_perd_id
		       from ben_enrt_perd enp,ben_POPL_ENRT_TYP_CYCL_F pet
		       where enp.POPL_ENRT_TYP_CYCL_id = pet.POPL_ENRT_TYP_CYCL_id and
		       pet.pgm_id=l_pgm_id
		       )
                 )
		 or
                 ( lee_rsn_id in
		       (
		       select lee_rsn_id
		       from ben_lee_rsn_f len,ben_POPL_ENRT_TYP_CYCL_F pet
		       where len.POPL_ENRT_TYP_CYCL_id = pet.POPL_ENRT_TYP_CYCL_id and
		       pet.pgm_id = l_pgm_id
		       )
                 )
	       )
	       and pl_id = l_pl_id
	       and p_validation_start_date <= erp.effective_end_date
               and p_validation_end_date >= erp.effective_start_date ;




Begin
   hr_utility.set_location('Entering:'||l_proc, 5);

open c2;
fetch c2 into l_pgm_id,l_pl_id;
close c2;



   open c1;
   fetch c1 into l_pl_id;

      if c1%found then

       close c1;

       fnd_message.set_name('BEN','BEN_94109_DELETE_PL_ID');
       fnd_message.raise_error;

   end if;
   close c1;
   hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_plan_delete_in_pgm;
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
            (p_dflt_enrt_det_rl               in number ,
             p_pl_id                         in number ,
             p_pgm_id                        in number ,
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
            (p_plip_id		in number,
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
       p_argument       => 'plip_id',
       p_argument_value => p_plip_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_base_rt_f',
           p_base_key_column => 'plip_id',
           p_base_key_value  => p_plip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_f',
           p_base_key_column => 'plip_id',
           p_base_key_value  => p_plip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_f';
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
    ben_utility.child_exists_error(p_table_name => l_table_name);
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
	(p_rec 			 in ben_cpp_shd.g_rec_type,
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
  chk_plip_id
  (p_plip_id          => p_rec.plip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_det_rl
  (p_plip_id               => p_rec.plip_id,
   p_dflt_enrt_det_rl      => p_rec.dflt_enrt_det_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dflt_to_asn_pndg_ctfn_rl
  (p_plip_id                       => p_rec.plip_id,
   p_dflt_to_asn_pndg_ctfn_rl      => p_rec.dflt_to_asn_pndg_ctfn_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_mn_cvg_rl
  (p_plip_id                       => p_rec.plip_id,
   p_mn_cvg_rl                     => p_rec.mn_cvg_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_mx_cvg_rl
  (p_plip_id                       => p_rec.plip_id,
   p_mx_cvg_rl                     => p_rec.mx_cvg_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --

chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  chk_prort_prtl_yr_cvg_rstrn_rl
  (p_plip_id                       => p_rec.plip_id,
   p_prort_prtl_yr_cvg_rstrn_rl    => p_rec.prort_prtl_yr_cvg_rstrn_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
  (p_plip_id               => p_rec.plip_id,
   p_auto_enrt_mthd_rl     => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_rl
  (p_plip_id               => p_rec.plip_id,
   p_enrt_rl               => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dflt_enrt_cd
  (p_plip_id               => p_rec.plip_id,
   p_dflt_enrt_cd          => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_to_asn_pndg_ctfn_cd
  (p_plip_id                  => p_rec.plip_id,
   p_dflt_to_asn_pndg_ctfn_cd => p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  -- Bug 2562196
  /*
  chk_interim_cd_cvg_calc_mthd
  (p_plip_id                    => p_rec.plip_id,
   p_dflt_to_asn_pndg_ctfn_cd  	=> p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_pl_id                     	=> p_rec.pl_id,
   p_effective_date            	=> p_effective_date,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number 	=> p_rec.object_version_number);
  */
  --
  chk_unsspnd_enrt_cd
  (p_plip_id                  => p_rec.plip_id,
   p_unsspnd_enrt_cd          => p_rec.unsspnd_enrt_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_prort_prtl_yr_cvg_rstrn_cd
  (p_plip_id                    => p_rec.plip_id,
   p_prort_prtl_yr_cvg_rstrn_cd => p_rec.prort_prtl_yr_cvg_rstrn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cvg_incr_r_decr_only_cd
  (p_plip_id                    => p_rec.plip_id,
   p_cvg_incr_r_decr_only_cd    => p_rec.cvg_incr_r_decr_only_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_bnft_or_option_rstrctn_cd
  (p_plip_id                    => p_rec.plip_id,
   p_bnft_or_option_rstrctn_cd  => p_rec.bnft_or_option_rstrctn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_plip_id               => p_rec.plip_id,
   p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_plip_id               => p_rec.plip_id,
   p_enrt_cd               => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_plip_stat_cd
  (p_plip_id          => p_rec.plip_id,
   p_plip_stat_cd         => p_rec.plip_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_plip_id          => p_rec.plip_id,
   p_dflt_flag => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_alws_unrstrctd_enrt_flag
  (p_plip_id                  => p_rec.plip_id,
   p_alws_unrstrctd_enrt_flag => p_rec.alws_unrstrctd_enrt_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_cvg_amt_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mn_cvg_amt_apls_flag  => p_rec.no_mn_cvg_amt_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_cvg_incr_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mn_cvg_incr_apls_flag => p_rec.no_mn_cvg_incr_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mx_cvg_amt_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mx_cvg_amt_apls_flag  => p_rec.no_mx_cvg_amt_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mx_cvg_incr_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mx_cvg_incr_apls_flag => p_rec.no_mx_cvg_incr_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_mn_val_mn_flag_mn_rule
  (p_mn_cvg_amt                => p_rec.mn_cvg_amt,
   p_no_mn_cvg_amt_apls_flag   => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_rl                 => p_rec.mn_cvg_rl);
  --
  chk_mx_val_mx_flag_mx_rule
  (p_mx_cvg_alwd_amt           => p_rec.mx_cvg_alwd_amt,
   p_no_mx_cvg_amt_apls_flag   => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_rl                 => p_rec.mx_cvg_rl);
  --
  chk_all_no_amount_flags
  (p_no_mn_cvg_amt_apls_flag    => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_amt                 => p_rec.mn_cvg_amt,
   p_no_mx_cvg_amt_apls_flag    => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_alwd_amt            => p_rec.mx_cvg_alwd_amt);
  --
  chk_duplicate_ordr_num
  (p_rec.plip_id
  ,p_rec.pgm_id
  ,p_rec.ordr_num
  ,p_effective_date
  ,p_validation_start_date
  ,p_validation_end_date
  ,p_rec.business_group_id);
  --
  chk_plan_allowed_in_pgm
  (p_rec.pl_id
  ,p_effective_date
  ,p_rec.business_group_id);
  --
  chk_dflt_enrt_cd_dpndcy
  (p_plip_id    => p_rec.plip_id,
   p_pgm_id     => p_rec.pgm_id,
   p_dflt_enrt_cd   => p_rec.dflt_enrt_cd,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date    => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_dflt_dpndcy
  (p_plip_id    => p_rec.plip_id,
   p_pgm_id     => p_rec.pgm_id,
   p_dflt_enrt_cd   => p_rec.dflt_enrt_cd,
   p_dflt_enrt_det_rl        => p_rec.dflt_enrt_det_rl,
   p_dflt_flag    => p_rec.dflt_flag,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date    => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  /*
  chk_dflt_flag_dependency
  (p_plip_id    => p_rec.plip_id,
   p_dflt_enrt_cd   => p_rec.dflt_enrt_cd,
   p_dflt_flag    => p_rec.dflt_flag,
   p_effective_date    => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
 */
  --
  chk_dflt_enrt_mthd_dpndcy
  (p_plip_id    => p_rec.plip_id,
   p_dflt_enrt_cd   => p_rec.dflt_enrt_cd,
   p_dflt_enrt_det_rl        => p_rec.dflt_enrt_det_rl,
   p_effective_date    => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
   chk_duplicate_pl_id_in_pgm(p_pl_id  => p_rec.pl_id
                               ,p_effective_date => p_effective_date
                               ,p_business_group_id => p_rec.business_group_id
                               ,p_pgm_id => p_rec.pgm_id
                               ,p_validation_start_date => p_validation_start_date
                               ,p_validation_end_date   => p_validation_end_date
                               ,p_plip_id => p_rec.plip_id);
  --
 chk_vrfy_fmly_mmbr_cd(p_plip_id => p_rec.plip_id ,
                       p_vrfy_fmly_mmbr_cd => p_rec.vrfy_fmly_mmbr_cd ,
                       p_effective_date    => p_effective_date   ,
                       P_object_version_number =>p_rec.object_version_number);


 chk_use_csd_rsd_prccng_cd(p_plip_id => p_rec.plip_id ,
                       p_use_csd_rsd_prccng_cd => p_rec.use_csd_rsd_prccng_cd ,
                       p_effective_date    => p_effective_date   ,
                       P_object_version_number =>p_rec.object_version_number);

chk_vrfy_fmly_mmbr_rl
  (p_plip_id   => p_rec.plip_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

 chk_invk_imptd_incm_per_pgm
  (p_plip_id                 => p_rec.plip_id,
   p_pgm_id                  => p_rec.pgm_id,
   p_pl_id                   => p_rec.pl_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_invk_flx_crpl_per_pgm
  (p_plip_id                 => p_rec.plip_id,
   p_pgm_id                  => p_rec.pgm_id,
   p_pl_id                   => p_rec.pl_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_rl
     (p_plip_id               => p_rec.plip_id,
      p_enrt_cvg_strt_dt_rl   => p_rec.enrt_cvg_strt_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_end_dt_rl
     (p_plip_id               => p_rec.plip_id,
      p_enrt_cvg_end_dt_rl    => p_rec.enrt_cvg_end_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_strt_dt_cd
      (p_plip_id              => p_rec.plip_id,
      p_enrt_cvg_strt_dt_cd   => p_rec.enrt_cvg_strt_dt_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
      (p_plip_id              => p_rec.plip_id,
      p_enrt_cvg_end_dt_cd    => p_rec.enrt_cvg_end_dt_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_plip_id               => p_rec.plip_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_strt_dt_cd
  (p_plip_id               => p_rec.plip_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_rl
  (p_plip_id               => p_rec.plip_id,
   p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_postelcn_edit_rl
  (p_plip_id               => p_rec.plip_id,
   p_postelcn_edit_rl      => p_rec.postelcn_edit_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_end_dt_cd
  (p_plip_id               => p_rec.plip_id,
   p_rt_end_dt_cd          => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
  (p_plip_id                   => p_rec.plip_id,
   p_drvbl_fctr_apls_rts_flag  => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_drvbl_fctr_prtn_elig_flag
  (p_plip_id                   => p_rec.plip_id,
   p_drvbl_fctr_prtn_elig_flag => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_elig_apls_flag
  (p_plip_id                   => p_rec.plip_id,
   p_elig_apls_flag            => p_rec.elig_apls_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
  (p_plip_id                   => p_rec.plip_id,
   p_prtn_elig_ovrid_alwd_flag => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
  (p_plip_id                   => p_rec.plip_id,
   p_trk_inelig_per_flag       => p_rec.trk_inelig_per_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cpp_shd.g_rec_type,
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
  chk_plip_id
  (p_plip_id          => p_rec.plip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_det_rl
  (p_plip_id          => p_rec.plip_id,
   p_dflt_enrt_det_rl        => p_rec.dflt_enrt_det_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dflt_to_asn_pndg_ctfn_rl
  (p_plip_id                       => p_rec.plip_id,
   p_dflt_to_asn_pndg_ctfn_rl      => p_rec.dflt_to_asn_pndg_ctfn_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_mn_cvg_rl
  (p_plip_id                       => p_rec.plip_id,
   p_mn_cvg_rl                     => p_rec.mn_cvg_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_mx_cvg_rl
  (p_plip_id                       => p_rec.plip_id,
   p_mx_cvg_rl                     => p_rec.mx_cvg_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --
  chk_prort_prtl_yr_cvg_rstrn_rl
  (p_plip_id                       => p_rec.plip_id,
   p_prort_prtl_yr_cvg_rstrn_rl    => p_rec.prort_prtl_yr_cvg_rstrn_rl,
   p_effective_date                => p_effective_date,
   p_object_version_number         => p_rec.object_version_number,
   p_business_group_id             => p_rec.business_group_id);
  --

chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  chk_auto_enrt_mthd_rl
  (p_plip_id               => p_rec.plip_id,
   p_auto_enrt_mthd_rl     => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_rl
  (p_plip_id               => p_rec.plip_id,
   p_enrt_rl               => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dflt_enrt_cd
  (p_plip_id          => p_rec.plip_id,
   p_dflt_enrt_cd         => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

 chk_vrfy_fmly_mmbr_cd(p_plip_id => p_rec.plip_id ,
  p_vrfy_fmly_mmbr_cd => p_rec.vrfy_fmly_mmbr_cd ,
  p_effective_date    => p_effective_date   ,
  P_object_version_number =>p_rec.object_version_number);
 ------
 chk_use_csd_rsd_prccng_cd(p_plip_id => p_rec.plip_id ,
  p_use_csd_rsd_prccng_cd => p_rec.use_csd_rsd_prccng_cd ,
  p_effective_date    => p_effective_date   ,
  P_object_version_number =>p_rec.object_version_number);
-----
chk_vrfy_fmly_mmbr_rl
  (p_plip_id   => p_rec.plip_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);


  --
  chk_dflt_to_asn_pndg_ctfn_cd
  (p_plip_id                  => p_rec.plip_id,
   p_dflt_to_asn_pndg_ctfn_cd         => p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  -- Bug 2562196
  /*
  chk_interim_cd_cvg_calc_mthd
  (p_plip_id                    => p_rec.plip_id,
   p_dflt_to_asn_pndg_ctfn_cd  	=> p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_pl_id                     	=> p_rec.pl_id,
   p_effective_date            	=> p_effective_date,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number 	=> p_rec.object_version_number);
  */
  --
  chk_unsspnd_enrt_cd
  (p_plip_id                  => p_rec.plip_id,
   p_unsspnd_enrt_cd         => p_rec.unsspnd_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prort_prtl_yr_cvg_rstrn_cd
  (p_plip_id                  => p_rec.plip_id,
   p_prort_prtl_yr_cvg_rstrn_cd         => p_rec.prort_prtl_yr_cvg_rstrn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
  chk_cvg_incr_r_decr_only_cd
  (p_plip_id                    => p_rec.plip_id,
   p_cvg_incr_r_decr_only_cd    => p_rec.cvg_incr_r_decr_only_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_bnft_or_option_rstrctn_cd
  (p_plip_id                    => p_rec.plip_id,
   p_bnft_or_option_rstrctn_cd  => p_rec.bnft_or_option_rstrctn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_enrt_mthd_cd
  (p_plip_id               => p_rec.plip_id,
   p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_plip_id               => p_rec.plip_id,
   p_enrt_cd               => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_plip_stat_cd
  (p_plip_id          => p_rec.plip_id,
   p_plip_stat_cd         => p_rec.plip_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_plip_id          => p_rec.plip_id,
   p_dflt_flag => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_alws_unrstrctd_enrt_flag
  (p_plip_id                  => p_rec.plip_id,
   p_alws_unrstrctd_enrt_flag => p_rec.alws_unrstrctd_enrt_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_cvg_amt_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mn_cvg_amt_apls_flag  => p_rec.no_mn_cvg_amt_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_cvg_incr_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mn_cvg_incr_apls_flag => p_rec.no_mn_cvg_incr_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mx_cvg_amt_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mx_cvg_amt_apls_flag  => p_rec.no_mx_cvg_amt_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mx_cvg_incr_apls_flag
  (p_plip_id                  => p_rec.plip_id,
   p_no_mx_cvg_incr_apls_flag => p_rec.no_mx_cvg_incr_apls_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_mn_val_mn_flag_mn_rule
  (p_mn_cvg_amt            => p_rec.mn_cvg_amt,
   p_no_mn_cvg_amt_apls_flag   => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_rl                 => p_rec.mn_cvg_rl);
  --
  chk_mx_val_mx_flag_mx_rule
  (p_mx_cvg_alwd_amt           => p_rec.mx_cvg_alwd_amt,
   p_no_mx_cvg_amt_apls_flag   => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_rl                 => p_rec.mx_cvg_rl);
  --
  chk_all_no_amount_flags
  (p_no_mn_cvg_amt_apls_flag    => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_amt                 => p_rec.mn_cvg_amt,
   p_no_mx_cvg_amt_apls_flag    => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_alwd_amt            => p_rec.mx_cvg_alwd_amt);
  --
  --
  chk_duplicate_ordr_num
  (p_rec.plip_id
  ,p_rec.pgm_id
  ,p_rec.ordr_num
  ,p_effective_date
  ,p_validation_start_date
  ,p_validation_end_date
  ,p_rec.business_group_id);
  --
  chk_plan_allowed_in_pgm
  (p_rec.pl_id
  ,p_effective_date
  ,p_rec.business_group_id);
  --
  chk_dflt_enrt_cd_dpndcy
  (p_plip_id    => p_rec.plip_id,
   p_pgm_id     => p_rec.pgm_id,
   p_dflt_enrt_cd   => p_rec.dflt_enrt_cd,
   p_business_group_id   => p_rec.business_group_id,
   p_effective_date    => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_dflt_dpndcy
  (p_plip_id                 => p_rec.plip_id,
   p_pgm_id                  => p_rec.pgm_id,
   p_dflt_enrt_cd            => p_rec.dflt_enrt_cd,
   p_dflt_enrt_det_rl        => p_rec.dflt_enrt_det_rl,
   p_dflt_flag               => p_rec.dflt_flag,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
 /*
  chk_dflt_flag_dependency
  (p_plip_id                 => p_rec.plip_id,
   p_dflt_enrt_cd            => p_rec.dflt_enrt_cd,
   p_dflt_flag               => p_rec.dflt_flag,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
*/
  --
  chk_dflt_enrt_mthd_dpndcy
  (p_plip_id                 => p_rec.plip_id,
   p_dflt_enrt_cd            => p_rec.dflt_enrt_cd,
   p_dflt_enrt_det_rl        => p_rec.dflt_enrt_det_rl,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
   chk_duplicate_pl_id_in_pgm
   (p_pl_id             => p_rec.pl_id
   ,p_effective_date    => p_effective_date
   ,p_business_group_id => p_rec.business_group_id
   ,p_pgm_id            => p_rec.pgm_id
   ,p_validation_start_date => p_validation_start_date
   ,p_validation_end_date   => p_validation_end_date
   ,p_plip_id           => p_rec.plip_id);
  --
  chk_invk_imptd_incm_per_pgm
  (p_plip_id                 => p_rec.plip_id,
   p_pgm_id                  => p_rec.pgm_id,
   p_pl_id                   => p_rec.pl_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_invk_flx_crpl_per_pgm
  (p_plip_id                 => p_rec.plip_id,
   p_pgm_id                  => p_rec.pgm_id,
   p_pl_id                   => p_rec.pl_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_rl
     (p_plip_id               => p_rec.plip_id,
      p_enrt_cvg_strt_dt_rl   => p_rec.enrt_cvg_strt_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_end_dt_rl
     (p_plip_id               => p_rec.plip_id,
      p_enrt_cvg_end_dt_rl    => p_rec.enrt_cvg_end_dt_rl,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number,
      p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_strt_dt_cd
      (p_plip_id              => p_rec.plip_id,
      p_enrt_cvg_strt_dt_cd   => p_rec.enrt_cvg_strt_dt_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
      (p_plip_id              => p_rec.plip_id,
      p_enrt_cvg_end_dt_cd    => p_rec.enrt_cvg_end_dt_cd,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_plip_id               => p_rec.plip_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_strt_dt_cd
  (p_plip_id               => p_rec.plip_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_rl
  (p_plip_id               => p_rec.plip_id,
   p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_postelcn_edit_rl
  (p_plip_id               => p_rec.plip_id,
   p_postelcn_edit_rl      => p_rec.postelcn_edit_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_end_dt_cd
  (p_plip_id               => p_rec.plip_id,
   p_rt_end_dt_cd          => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
  (p_plip_id                   => p_rec.plip_id,
   p_drvbl_fctr_apls_rts_flag  => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_drvbl_fctr_prtn_elig_flag
  (p_plip_id                   => p_rec.plip_id,
   p_drvbl_fctr_prtn_elig_flag => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_elig_apls_flag
  (p_plip_id                   => p_rec.plip_id,
   p_elig_apls_flag            => p_rec.elig_apls_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
  (p_plip_id                   => p_rec.plip_id,
   p_prtn_elig_ovrid_alwd_flag => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
  (p_plip_id                   => p_rec.plip_id,
   p_trk_inelig_per_flag       => p_rec.trk_inelig_per_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_dflt_enrt_det_rl              => p_rec.dflt_enrt_det_rl,
     p_pl_id                         => p_rec.pl_id,
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
	(p_rec 			 in ben_cpp_shd.g_rec_type,
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
     p_plip_id		=> p_rec.plip_id);

  --bug 3966957
  chk_plan_delete_in_pgm(p_plip_id               => p_rec.plip_id,
                       p_validation_start_date   => p_validation_start_date ,
                       p_validation_end_date     => p_validation_end_date,
		       p_effective_date          => p_effective_date
	          );


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
  (p_plip_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_plip_f b
    where b.plip_id      = p_plip_id
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
                             p_argument       => 'plip_id',
                             p_argument_value => p_plip_id);
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
end ben_cpp_bus;

/
