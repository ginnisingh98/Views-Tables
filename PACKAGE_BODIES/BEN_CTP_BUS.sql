--------------------------------------------------------
--  DDL for Package Body BEN_CTP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTP_BUS" as
/* $Header: bectprhi.pkb 120.0 2005/05/28 01:26:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ctp_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |--------------------<chk_duplicate_ordr_num >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--     make sure ordr_to_aply_num is unique within prtn_elig_prfl
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_ptip_id
--     p_pgm_id
--     p_ordr_num
--     p_business_group_id
--     p_effective_date
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
          ( p_ptip_id in number
           ,p_pgm_id in number
           ,p_ordr_num in number
           ,p_business_group_id in number
           ,p_effective_date in date
           ,p_validation_start_date  in date
           ,p_validation_end_date    in date
            )
is
   l_proc  varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy char(1);
   cursor c1 is select null
                  from ben_ptip_f
                 where ptip_id <> nvl(p_ptip_id, -1 )
                   and pgm_id = p_pgm_id
                   and ordr_num = p_ordr_num
                   and business_group_id + 0 = p_business_group_id
                    and p_validation_start_date <= effective_end_date
                   and p_validation_end_date >= effective_start_date;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c1;
   fetch c1 into l_dummy;
   if c1%found then
       close c1;
       fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
       fnd_message.raise_error;
   end if;
   close c1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
   --
End chk_duplicate_ordr_num;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_dup_pl_typ_id_in_pgm>---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks whether one pl_typ_Id is associated
--   to a program id once
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_typ_id    Plan  Type Id
--   p_pgm_id   Program Id
--   p_effective_date   effective_date
--   p_business_group_id  business_group_id
--   p_ptip_id            PK of record being inserted ot updated
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
Procedure chk_dup_pl_typ_id_in_pgm(p_pl_typ_id            in number
                                       ,p_effective_date    in date
                                       ,p_business_group_id in number
                                       ,p_pgm_id            in number
                                       ,p_ptip_id            in number
                                       ,p_validation_start_date  in date
                                       ,p_validation_end_date    in date)
is
l_proc	    varchar2(72) := g_package||' chk_dup_pl_typ_id_in_pgm ';
l_dummy   char(1);
cursor c1 is select null
             from   ben_ptip_f
             where  pgm_id = p_pgm_id
             and    business_group_id + 0 = p_business_group_id
             and    pl_typ_id = p_pl_typ_id
             and    ptip_id <> nvl(p_ptip_id, -1)
             and    p_validation_start_date <= effective_end_date
             and    p_validation_end_date >= effective_start_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
          fnd_message.set_name('BEN','BEN_91722_DUP_PL_TYP_ID_IN_PGM');
          fnd_message.raise_error;
      end if;
      close c1;
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_dup_pl_typ_id_in_pgm;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_typ_waivable >------|
-- ----------------------------------------------------------------------------
--
-- Description
--     ensure that if WVBL_FLAG = 'Y' then all Plans in Program must be waivable
--
-- Pre Conditions
--   None.
--
-- In Parameters
--      p_wvbl_flag
--      p_pgm_id
--      p_business_group_id
--      p_effective_date
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
Procedure chk_pl_typ_waivable
          ( p_ptip_id in number,
            p_wvbl_flag in varchar2
           ,p_pgm_id in number
           ,p_business_group_id in number
           ,p_effective_date in date
           ,p_object_version_number in number)
is
   l_proc   varchar2(72) := g_package||' chk_pl_typ_waivable ';
   l_dummy   char(1);
   l_api_updating boolean;
   --
   cursor c1 is select null
                  from ben_plip_f plip, ben_pl_f pl
                  where plip.pgm_id = p_pgm_id
                    and plip.pl_id = pl.pl_id
                    and pl.wvbl_flag <> 'Y'
                    and plip.business_group_id +0 = p_business_group_id
                    and p_effective_date between plip.effective_start_date
                                             and plip.effective_end_date;
--
Begin
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wvbl_flag
      <> nvl(ben_ctp_shd.g_old_rec.wvbl_flag,hr_api.g_varchar2)
      or not l_api_updating) then

    if p_wvbl_flag = 'Y' then
       open c1;
       fetch c1 into l_dummy;
       if c1%found then
           close c1;
           fnd_message.set_name('BEN','BEN_92139_PLAN_MUST_B_WAIVABLE');
           fnd_message.raise_error;
       end if;
       close c1;
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_pl_typ_waivable;
--
-- ----------------------------------------------------------------------------
-- |------< chk_date_dpndcy >------|
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
--   ptip_id PK of record being inserted or updated.
--   dt_cd Value of lookup code.
--   dt_rl
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
Procedure chk_date_dpndcy(  p_ptip_id               in number,
                            p_dt_cd             in varchar2,
                            p_old_dt_cd         in varchar2,
                            p_dt_rl             in number,
                            p_old_dt_rl         in number,
                            p_effective_date                  in date,
                            p_object_version_number           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_date_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dt_cd,hr_api.g_varchar2)
               <> nvl(p_old_dt_cd,hr_api.g_varchar2)
          or
          nvl(p_dt_rl,hr_api.g_number)
               <> nvl(p_old_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_dt_cd = 'RL' and p_dt_rl is null) then
             --
             fnd_message.set_name('BEN','BEN_91380_DPNT_CVG_ST_DT_1');
             fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_dt_rl is not null then
             --
             fnd_message.set_name('BEN','BEN_91381_DPNT_CVG_ST_DT_2');
             fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_date_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_plan_typ_temporal >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_id
--   p_effective_date
--   p_business_group_id
--   p_pgm_id
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
/*
Procedure chk_plan_typ_temporal
          ( p_pl_typ_id in number
           ,p_effective_date in date
           ,p_business_group_id in number
           ,p_pgm_id in number)
is
   l_proc   varchar2(72) := g_package||' chk_plan_typ_temporal ';
   l_dummy   char(1);
   cursor c1 is select null
                  from  ben_pl_typ_f
                 where pl_typ_id = p_pl_typ_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date
                   and business_group_id + 0 = p_business_group_id
                   and TMPRL_FCTR_APLS_RTS_FLAG = 'Y';
   cursor c2 is select null
                  from ben_pgm_f
                 where pgm_id = p_pgm_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date
                   and business_group_id + 0 = p_business_group_id
                   and TMPRL_FCTR_APLS_RTS_FLAG = 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      open c2;
      fetch c2 into l_dummy;
      if c2%notfound then
          fnd_message.set_name('PAY','needs a message');
          fnd_message.raise_error;
      end if;
      close c2;
  end if;
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_plan_typ_temporal;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_ptip_id >------|
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_ptip_id(p_ptip_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptip_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ptip_id                => p_ptip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ptip_id,hr_api.g_number)
     <>  ben_ctp_shd.g_old_rec.ptip_id) then
    --
    -- raise error as PK has changed
    --
    ben_ctp_shd.constraint_error('BEN_PTIP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ptip_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ctp_shd.constraint_error('BEN_PTIP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ptip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_enrt_perd_tco_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   rqd_enrt_perd_tco_cd Value of lookup code.
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
Procedure chk_rqd_enrt_perd_tco_cd(p_ptip_id                in number,
                            p_rqd_enrt_perd_tco_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_enrt_perd_tco_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_enrt_perd_tco_cd
      <> nvl(ben_ctp_shd.g_old_rec.rqd_enrt_perd_tco_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rqd_enrt_perd_tco_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RQD_ENRT_PERD_TCO',
           p_lookup_code    => p_rqd_enrt_perd_tco_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91225_INV_RQD_ENRT_PERD_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_enrt_perd_tco_cd;
--
--
Procedure chk_vrfy_fmly_mmbr_cd(p_ptip_id                     in number,
                                p_vrfy_fmly_mmbr_cd           in varchar2,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrfy_fmly_mmbr_cd
      <> nvl(ben_ctp_shd.g_old_rec.vrfy_fmly_mmbr_cd,hr_api.g_varchar2)
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
--
--
--
--
--
Procedure chk_vrfy_fmly_mmbr_rl
  (p_ptip_id   in number
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ptip_id                     => p_ptip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrfy_fmly_mmbr_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.vrfy_fmly_mmbr_rl
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


--

-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_pl_typ_overid_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   no_mn_pl_typ_overid_flag Value of lookup code.
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
Procedure chk_no_mn_pl_typ_overid_flag(p_ptip_id                in number,
                            p_no_mn_pl_typ_overid_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_pl_typ_overid_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_pl_typ_overid_flag
      <> nvl(ben_ctp_shd.g_old_rec.no_mn_pl_typ_overid_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_pl_typ_overid_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_pl_typ_overid_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91226_INV_NO_MIN_PT_OR_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_pl_typ_overid_flag;
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_drvbl_fctr_apls_rts_flag(p_ptip_id                   in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_apls_rts_flag
      <> nvl(ben_ctp_shd.g_old_rec.drvbl_fctr_apls_rts_flag,hr_api.g_varchar2)
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_drvbl_fctr_prtn_elig_flag(p_ptip_id                   in number,
                                       p_drvbl_fctr_prtn_elig_flag  in varchar2,
                                       p_effective_date            in date,
                                       p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_prtn_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_prtn_elig_flag
      <> nvl(ben_ctp_shd.g_old_rec.drvbl_fctr_prtn_elig_flag,hr_api.g_varchar2)
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_elig_apls_flag(p_ptip_id                   in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_apls_flag
      <> nvl(ben_ctp_shd.g_old_rec.elig_apls_flag,hr_api.g_varchar2)
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_prtn_elig_ovrid_alwd_flag(p_ptip_id                   in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_elig_ovrid_alwd_flag
      <> nvl(ben_ctp_shd.g_old_rec.prtn_elig_ovrid_alwd_flag,hr_api.g_varchar2)
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_trk_inelig_per_flag(p_ptip_id                   in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_trk_inelig_per_flag
      <> nvl(ben_ctp_shd.g_old_rec.trk_inelig_per_flag,hr_api.g_varchar2)
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
-- |------< chk_sbj_to_sps_lf_ins_mx_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   sbj_to_sps_lf_ins_mx_flag Value of lookup code.
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
Procedure chk_sbj_to_sps_lf_ins_mx_flag(p_ptip_id                in number,
                            p_sbj_to_sps_lf_ins_mx_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sbj_to_sps_lf_ins_mx_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_sbj_to_sps_lf_ins_mx_flag
      <> nvl(ben_ctp_shd.g_old_rec.sbj_to_sps_lf_ins_mx_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_sbj_to_sps_lf_ins_mx_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_sbj_to_sps_lf_ins_mx_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_sbj_to_sps_lf_ins_mx_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_sbj_to_sps_lf_ins_mx_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_sbj_to_dpnt_lf_ins_mx_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   sbj_to_dpnt_lf_ins_mx_flag Value of lookup code.
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
Procedure chk_sbj_to_dpnt_lf_ins_mx_flag(p_ptip_id                in number,
                            p_sbj_to_dpnt_lf_ins_mx_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sbj_to_dpnt_lf_ins_mx_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_sbj_to_dpnt_lf_ins_mx_flag
      <> nvl(ben_ctp_shd.g_old_rec.sbj_to_dpnt_lf_ins_mx_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_sbj_to_dpnt_lf_ins_mx_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_sbj_to_dpnt_lf_ins_mx_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_sbj_to_dpnt_lf_ins_mx_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_sbj_to_dpnt_lf_ins_mx_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_to_sum_ee_lf_ins_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   use_to_sum_ee_lf_ins_flag Value of lookup code.
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
Procedure chk_use_to_sum_ee_lf_ins_flag(p_ptip_id                in number,
                            p_use_to_sum_ee_lf_ins_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_to_sum_ee_lf_ins_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_to_sum_ee_lf_ins_flag
      <> nvl(ben_ctp_shd.g_old_rec.use_to_sum_ee_lf_ins_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_to_sum_ee_lf_ins_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_to_sum_ee_lf_ins_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_use_to_sum_ee_lf_ins_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_to_sum_ee_lf_ins_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_drvd_fctr_dpnt_cvg_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   drvd_fctr_dpnt_cvg_flag Value of lookup code.
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
Procedure chk_drvd_fctr_dpnt_cvg_flag(p_ptip_id                in number,
                            p_drvd_fctr_dpnt_cvg_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_drvd_fctr_dpnt_cvg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvd_fctr_dpnt_cvg_flag
      <> nvl(ben_ctp_shd.g_old_rec.drvd_fctr_dpnt_cvg_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvd_fctr_dpnt_cvg_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvd_fctr_dpnt_cvg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91228_INV_DRV_FCT_DPNT_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvd_fctr_dpnt_cvg_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dob_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_dob_rqd_flag Value of lookup code.
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
Procedure chk_dpnt_dob_rqd_flag(p_ptip_id                 in number,
                            p_dpnt_dob_rqd_flag           in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dob_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dob_rqd_flag
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_dob_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_dob_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_dob_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_dob_rqd_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dob_rqd_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_legv_id_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_legv_id_rqd_flag Value of lookup code.
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
Procedure chk_dpnt_legv_id_rqd_flag(p_ptip_id             in number,
                            p_dpnt_legv_id_rqd_flag       in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_legv_id_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_legv_id_rqd_flag
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_legv_id_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_legv_id_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_legv_id_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_legv_id_rqd_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_legv_id_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_wvbl_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   wvbl_flag Value of lookup code.
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
Procedure chk_wvbl_flag(p_ptip_id                     in number,
                        p_wvbl_flag                   in varchar2,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wvbl_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wvbl_flag
      <> nvl(ben_ctp_shd.g_old_rec.wvbl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_wvbl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_wvbl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91229_INV_WVBL_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wvbl_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_dpnt_adrs_rqd_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_adrs_rqd_flag Value of lookup code.
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
Procedure chk_dpnt_adrs_rqd_flag(p_ptip_id                in number,
                            p_dpnt_adrs_rqd_flag          in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_adrs_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_adrs_rqd_flag
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_adrs_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_adrs_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_adrs_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_adrs_rqd_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_adrs_rqd_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_dpnt_cvg_no_ctfn_rqd_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_cvg_no_ctfn_rqd_flag Value of lookup code.
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
Procedure chk_dpnt_cvg_no_ctfn_rqd_flag(p_ptip_id         in number,
                            p_dpnt_cvg_no_ctfn_rqd_flag   in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_no_ctfn_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_no_ctfn_rqd_flag
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_cvg_no_ctfn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_cvg_no_ctfn_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_cvg_no_ctfn_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_cvg_no_ctfn_rqd_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_no_ctfn_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_perd_enrt_nenrt_tm_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   rqd_perd_enrt_nenrt_tm_uom Value of lookup code.
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
Procedure chk_rqd_perd_enrt_nenrt_tm_uom(p_ptip_id        in number,
                            p_rqd_perd_enrt_nenrt_tm_uom  in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_perd_enrt_nenrt_tm_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_perd_enrt_nenrt_tm_uom
      <> nvl(ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_tm_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rqd_perd_enrt_nenrt_tm_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RQD_PERD_ENRT_NENRT_TM_UOM',
           p_lookup_code    => p_rqd_perd_enrt_nenrt_tm_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91230_INV_RQD_PRD_ENRT_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_perd_enrt_nenrt_tm_uom;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prvds_cr_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   prvds_cr_flag Value of lookup code.
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
Procedure chk_prvds_cr_flag(p_ptip_id                     in number,
                            p_prvds_cr_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prvds_cr_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prvds_cr_flag
      <> nvl(ben_ctp_shd.g_old_rec.prvds_cr_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prvds_cr_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prvds_cr_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91231_INV_PRVDS_CR_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prvds_cr_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_pl_typ_ovrid_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   no_mx_pl_typ_ovrid_flag Value of lookup code.
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
Procedure chk_no_mx_pl_typ_ovrid_flag(p_ptip_id           in number,
                            p_no_mx_pl_typ_ovrid_flag     in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_pl_typ_ovrid_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_pl_typ_ovrid_flag
      <> nvl(ben_ctp_shd.g_old_rec.no_mx_pl_typ_ovrid_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_pl_typ_ovrid_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_pl_typ_ovrid_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91232_INV_NO_MAX_PT_OR_FLG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_pl_typ_ovrid_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ptip_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   ptip_stat_cd Value of lookup code.
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
Procedure chk_ptip_stat_cd(p_ptip_id                     in number,
                           p_ptip_stat_cd                in varchar2,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptip_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ptip_stat_cd
      <> nvl(ben_ctp_shd.g_old_rec.ptip_stat_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_ptip_stat_cd,
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
end chk_ptip_stat_cd;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |------< chk_crs_this_pl_typ_only_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   crs_this_pl_typ_only_flag Value of lookup code.
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
Procedure chk_crs_this_pl_typ_only_flag(p_ptip_id         in number,
                            p_crs_this_pl_typ_only_flag   in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crs_this_pl_typ_only_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crs_this_pl_typ_only_flag
      <> nvl(ben_ctp_shd.g_old_rec.crs_this_pl_typ_only_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_crs_this_pl_typ_only_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_crs_this_pl_typ_only_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91235_INV_CRS_THIS_PT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crs_this_pl_typ_only_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
--   dpnt_cvg_strt_dt_cd Value of lookup code.
--   dpnt_cvg_end_dt_cd  Value of lookup code.
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
Procedure chk_dpnt_dsgn_cd(p_ptip_id                    in number,
                           p_dpnt_dsgn_cd               in varchar2,
                           p_dpnt_cvg_strt_dt_cd        in varchar2,
                           p_dpnt_cvg_end_dt_cd         in varchar2,
                           p_effective_date             in date,
                           p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_cd
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_dsgn_cd is not null then
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_DSGN',
           p_lookup_code    => p_dpnt_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91236_INV_DPNT_DSGN_CD');
      fnd_message.raise_error;
      --
    end if;
    end if;
    --
  end if;
  --

  if ( p_dpnt_dsgn_cd is not null) and
     (p_dpnt_cvg_strt_dt_cd is null or p_dpnt_cvg_end_dt_cd is null) then

    fnd_message.set_name('BEN','BEN_92512_DPNDNT_CVRG_DT_RQD');
    fnd_message.raise_error;
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd;
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_postelcn_edit_rl
              (p_ptip_id                in number,
               p_postelcn_edit_rl       in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
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
    and    ff.formula_type_id = -215 /*default enrollment det */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_postelcn_edit_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.postelcn_edit_rl
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_rt_end_dt_rl
              (p_ptip_id                in number,
               p_rt_end_dt_rl           in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
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
    and    ff.formula_type_id = -67 /*rt_end */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_end_dt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.rt_end_dt_rl
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_rt_strt_dt_rl
              (p_ptip_id                in number,
               p_rt_strt_dt_rl          in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
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
    and    ff.formula_type_id = -66 /*rt_strt */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.rt_strt_dt_rl
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
-- |------< chk_enrt_cvg_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_enrt_cvg_end_dt_rl
              (p_ptip_id                in number,
               p_enrt_cvg_end_dt_rl     in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
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
    and    ff.formula_type_id = -30 /*enrt_cvg_end */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_rl
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
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_enrt_cvg_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-30);
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
-- |------< chk_enrt_cvg_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_enrt_cvg_strt_dt_rl
              (p_ptip_id                in number,
               p_enrt_cvg_strt_dt_rl    in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
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
    and    ff.formula_type_id = -29 /*enrt_cvg_strt */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_rl
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
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_enrt_cvg_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-29);
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_perd_enrt_nenrt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   rqd_perd_enrt_nenrt_rl Value of formula rule id.
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
Procedure chk_rqd_perd_enrt_nenrt_rl
              (p_ptip_id                in number,
               p_rqd_perd_enrt_nenrt_rl in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_perd_enrt_nenrt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rqd_perd_enrt_nenrt_rl
    and    ff.formula_type_id = -513
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rqd_perd_enrt_nenrt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_rl
      or not l_api_updating)
      and p_rqd_perd_enrt_nenrt_rl is not null then
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
        fnd_message.set_token('ID',p_rqd_perd_enrt_nenrt_rl);
        fnd_message.set_token('TYPE_ID',-513);
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
end chk_rqd_perd_enrt_nenrt_rl;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_auto_enrt_mthd_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_auto_enrt_mthd_rl
              (p_ptip_id                in number,
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
    and    ff.formula_type_id = -146
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.auto_enrt_mthd_rl
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
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_auto_enrt_mthd_rl);
        fnd_message.set_token('TYPE_ID',-146);
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
-- ----------------------------------------------------------------------------
-- |-------------------< chk_enrt_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_enrt_rl
              (p_ptip_id                in number,
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
    and    ff.formula_type_id = -393
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.enrt_rl
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
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_enrt_rl);
        fnd_message.set_token('TYPE_ID',-393);
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
-- |-------------------< chk_dflt_enrt_det_rl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
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
              (p_ptip_id                in number,
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
    and    ff.formula_type_id = -32
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dflt_enrt_det_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.dflt_enrt_det_rl
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_enrt_mthd_cd(p_ptip_id                    in number,
                            p_enrt_mthd_cd              in varchar2,
                            p_effective_date            in date,
                            p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_mthd_cd
      <> nvl(ben_ctp_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_mthd_cd is not null then
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
    end if;
    --
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_enrt_cd(p_ptip_id                   in number,
                      p_enrt_cd                   in varchar2,
                      p_effective_date            in date,
                      p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_ctp_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_enrt_cd is not null then
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
    end if;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cd;
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_dflt_enrt_cd(p_ptip_id                   in number,
                           p_dflt_enrt_cd              in varchar2,
                           p_effective_date            in date,
                           p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_enrt_cd
      <> nvl(ben_ctp_shd.g_old_rec.dflt_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dflt_enrt_cd is not null then
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
    end if;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_cvg_end_dt_rl Value of formula rule id.
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
Procedure chk_dpnt_cvg_end_dt_rl
              (p_ptip_id                in number,
               p_dpnt_cvg_end_dt_rl     in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_dpnt_cvg_end_dt_rl
    and    ff.formula_type_id = -28 /*default enrollment det */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_end_dt_rl is not null then
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
        fnd_message.set_token('ID',p_dpnt_cvg_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-28);
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
end chk_dpnt_cvg_end_dt_rl;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_cvg_strt_dt_rl Value of formula rule id.
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
Procedure chk_dpnt_cvg_strt_dt_rl
              (p_ptip_id                in number,
               p_dpnt_cvg_strt_dt_rl    in number,
               p_effective_date         in date,
               p_object_version_number  in number,
               p_business_group_id      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_dpnt_cvg_strt_dt_rl
    and    ff.formula_type_id = -27 /*default enrollment det */
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_strt_dt_rl is not null then
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
        fnd_message.set_token('ID',p_dpnt_cvg_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-27);
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
end chk_dpnt_cvg_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_strt_dt_cd Value of lookup code.
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
Procedure chk_dpnt_cvg_strt_dt_cd(p_ptip_id               in number,
                            p_dpnt_cvg_strt_dt_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_strt_dt_cd
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_cvg_strt_dt_cd is not null then
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_STRT',
           p_lookup_code    => p_dpnt_cvg_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dpnt_cvg_strt_dt_cd');
      fnd_message.set_token('TYPE','BEN_DPNT_CVG_STRT');
      fnd_message.raise_error;
      --
    end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_strt_dt_cd;
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_rt_strt_dt_cd(p_ptip_id                     in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_strt_dt_cd
      <> nvl(ben_ctp_shd.g_old_rec.rt_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_rt_strt_dt_cd is not null then
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
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_strt_dt_cd;
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
--   ptip_id PK of record being inserted or updated.
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
Procedure chk_rt_end_dt_cd(p_ptip_id                     in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_end_dt_cd
      <> nvl(ben_ctp_shd.g_old_rec.rt_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_rt_end_dt_cd is not null then
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
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   enrt_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_end_dt_cd(p_ptip_id                in number,
                            p_enrt_cvg_end_dt_cd          in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_end_dt_cd
      <> nvl(ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_enrt_cvg_end_dt_cd');
      fnd_message.set_token('TYPE','BEN_ENRT_CVG_END');
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
-- |------< chk_enrt_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   enrt_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_strt_dt_cd(p_ptip_id               in number,
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
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_strt_dt_cd
      <> nvl(ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_enrt_cvg_strt_dt_cd');
      fnd_message.set_token('TYPE','BEN_ENRT_CVG_STRT');
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_dpnt_cvg_end_dt_cd(p_ptip_id                in number,
                            p_dpnt_cvg_end_dt_cd          in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_end_dt_cd
      <> nvl(ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_dpnt_cvg_end_dt_cd is not null then
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_END',
           p_lookup_code    => p_dpnt_cvg_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dpnt_cvg_end_dt_cd');
      fnd_message.set_token('TYPE','BEN_DPNT_CVG_END');
      fnd_message.raise_error;
      --
    end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_coord_cvg_for_all_pls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   coord_cvg_for_all_pls_flag Value of lookup code.
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
Procedure chk_coord_cvg_for_all_pls_flag(p_ptip_id        in number,
                            p_coord_cvg_for_all_pls_flag  in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_coord_cvg_for_all_pls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_coord_cvg_for_all_pls_flag
      <> nvl(ben_ctp_shd.g_old_rec.coord_cvg_for_all_pls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_coord_cvg_for_all_pls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_coord_cvg_for_all_pls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91237_INV_COORD_CVG_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_coord_cvg_for_all_pls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_perd_enrt_nenrt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   When there is a value for Required Period of Enrollment Non Enrollment, there
--   must be a value for Required Period of Enrollment Non Enrollment Unit of Measure.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--	rqd_perd_enrt_nenrt_val
--    rqd_perd_enrt_nenrt_tm_uom
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
Procedure chk_rqd_perd_enrt_nenrt_dpndcy(p_ptip_id              in number,
	                      p_rqd_perd_enrt_nenrt_val         in number,
	                      p_rqd_perd_enrt_nenrt_tm_uom      in varchar2,
                              p_effective_date                  in date,
                              p_object_version_number           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_perd_enrt_nenrt_dpndcy';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_rqd_perd_enrt_nenrt_val,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_val,hr_api.g_number) or
          nvl(p_rqd_perd_enrt_nenrt_tm_uom,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_tm_uom,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- check dependency.
    --
    if (p_rqd_perd_enrt_nenrt_val is null and p_rqd_perd_enrt_nenrt_tm_uom is not null) or
       (p_rqd_perd_enrt_nenrt_val is not null and p_rqd_perd_enrt_nenrt_tm_uom is null) then
      --
      fnd_message.set_name('BEN','BEN_91238_RQD_PERD_ENRT_DPCY');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_perd_enrt_nenrt_dpndcy;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_max_num_ovrd_flg_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If No Maximum Number of Plan Type Override Flag = 'YES' then
--   Maximum Enrolled Allowed Override Number must be blank.  At least
--   one of the two are required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--	no_mx_pl_typ_ovrid_flag
--    mx_enrd_alwd_ovrid_num
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
Procedure chk_max_num_ovrd_flg_dpndcy(p_ptip_id                in number,
  				 p_mx_enrd_alwd_ovrid_num      in number,
				 p_no_mx_pl_typ_ovrid_flag     in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_max_num_ovrd_flg_dpndcy';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_mx_enrd_alwd_ovrid_num,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.mx_enrd_alwd_ovrid_num,hr_api.g_number) or
          nvl(p_no_mx_pl_typ_ovrid_flag,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.no_mx_pl_typ_ovrid_flag,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- If flag = 'Y' then num must be null.
    --
    if p_no_mx_pl_typ_ovrid_flag = 'Y' and p_mx_enrd_alwd_ovrid_num is not null then
      --
      fnd_message.set_name('BEN','BEN_91240_MX_OVRD_FLG_DPCY');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_max_num_ovrd_flg_dpndcy;
-- ----------------------------------------------------------------------------
-- |------< chk_min_num_ovrd_flg_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If No Minimum Number of Plan Type Override Flag = 'YES' then
--   Minimum Enrolled Allowed Override Number must be blank.  At least
--   One of the two are required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--	no_mn_pl_typ_overid_flag
--    mn_enrd_rqd_ovrid_num
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
Procedure chk_min_num_ovrd_flg_dpndcy(p_ptip_id                in number,
  				 p_mn_enrd_rqd_ovrid_num       in number,
				 p_no_mn_pl_typ_overid_flag    in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_min_num_ovrd_flg_dpndcy';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_mn_enrd_rqd_ovrid_num,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.mn_enrd_rqd_ovrid_num,hr_api.g_number) or
          nvl(p_no_mn_pl_typ_overid_flag,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.no_mn_pl_typ_overid_flag,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- If flag = 'Y' then num must be null.
    --
    if p_no_mn_pl_typ_overid_flag = 'Y' and p_mn_enrd_rqd_ovrid_num is not null then
      --
      fnd_message.set_name('BEN','BEN_91241_MN_OVRD_FLG_DPCY');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_min_num_ovrd_flg_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mx_enrd_alwd_ovrid_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Maximum Enrolled Allowed Override Number must be greater than BEN_PL_TYP_F
--   Maximum enrolled Allowed Number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--    mx_enrd_alwd_ovrid_num
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
Procedure chk_mx_enrd_alwd_ovrid_num(p_ptip_id                 in number,
                                 p_pl_typ_id                   in number,
  			         p_mx_enrd_alwd_ovrid_num      in number,
                                 p_effective_date              in date,
                                 p_business_group_id           in number,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mx_enrd_alwd_ovrid_num';
  l_api_updating boolean;
  l_value number;
  --
   cursor c1 is select mx_enrl_alwd_num
                  from ben_pl_typ_f pt
                  where pt.pl_typ_id = p_pl_typ_id
                    and pt.business_group_id +0 = p_business_group_id
                    and p_effective_date between pt.effective_start_date
                                             and pt.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_enrd_alwd_ovrid_num,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.mx_enrd_alwd_ovrid_num,hr_api.g_number)
      or not l_api_updating) then
    --
    -- Max enrolled allowed override number must be greater than that of plan type
    -- Bypass this edit if either is null   - Verify this.
    --
    if p_mx_enrd_alwd_ovrid_num is not null then
      open c1;
      fetch c1 into l_value;
      if c1%found then
        --
        if p_mx_enrd_alwd_ovrid_num < nvl(l_value,p_mx_enrd_alwd_ovrid_num) then
          --
          close c1;
          fnd_message.set_name('BEN','BEN_91243_INV_MX_ENRT_OVRD_NUM');
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
end chk_mx_enrd_alwd_ovrid_num;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mn_enrd_rqd_ovrid_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Minimum Enrolled Required Override Number must be greater than BEN_PL_TYP_F
--   Minimum enrolled Required Number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--    mn_enrd_rqd_ovrid_num
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
Procedure chk_mn_enrd_rqd_ovrid_num(p_ptip_id                  in number,
                                 p_pl_typ_id                   in number,
  				 p_mn_enrd_rqd_ovrid_num       in number,
                                 p_effective_date              in date,
                                 p_business_group_id           in number,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mn_enrd_rqd_ovrid_num';
  l_api_updating boolean;
  l_value number;
  --
   cursor c1 is select mn_enrl_rqd_num
                  from ben_pl_typ_f pt
                  where pt.pl_typ_id = p_pl_typ_id
                    and pt.business_group_id +0 = p_business_group_id
                    and p_effective_date between pt.effective_start_date
                                             and pt.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mn_enrd_rqd_ovrid_num,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.mn_enrd_rqd_ovrid_num,hr_api.g_number)
      or not l_api_updating) then
    --
    -- Min enrolled allowed override number must be greater than that of plan type
    -- Bypass this edit if either is null   - Verify this.
    --
    if p_mn_enrd_rqd_ovrid_num is not null then
      open c1;
      fetch c1 into l_value;
      if c1%found then
        --
        if p_mn_enrd_rqd_ovrid_num < nvl(l_value,p_mn_enrd_rqd_ovrid_num) then
          --
          close c1;
          fnd_message.set_name('BEN','BEN_91244_INV_MN_ENRT_OVRD_NUM');
          fnd_message.raise_error;
          --
        end if;
      end if;
      close c1;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_enrd_rqd_ovrid_num;
--
-- ----------------------------------------------------------------------------
-- |------< chk_min_num_ovrd_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   NOTE:  because of two prior chk procedures, this will never happen.
--   So I have commented out the calls to it!  tvh.
--
--   If minimum enrolled required override number is not null, then
--   maximum enrolled overide allowed number cannot be null OR the
--   no maximum number of plan type override flag must be 'YES'.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--	no_mx_pl_typ_ovrid_flag
--    mx_enrd_alwd_ovrid_num
--    mn_enrd_rqd_ovrid_num
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
Procedure chk_min_num_ovrd_dpndcy(p_ptip_id                    in number,
  			         p_mx_enrd_alwd_ovrid_num      in number,
  			         p_mn_enrd_rqd_ovrid_num       in number,
	         	         p_no_mx_pl_typ_ovrid_flag     in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_min_num_ovrd_dpndcy';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_mx_enrd_alwd_ovrid_num,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.mx_enrd_alwd_ovrid_num,hr_api.g_number) or
          nvl(p_no_mx_pl_typ_ovrid_flag,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.no_mx_pl_typ_ovrid_flag,hr_api.g_varchar2) or
          nvl(p_mn_enrd_rqd_ovrid_num,hr_api.g_number)
               <> nvl(ben_ctp_shd.g_old_rec.mn_enrd_rqd_ovrid_num,hr_api.g_number))
      or not l_api_updating) then
    --
    -- If min amount has value then max amount must have value or flag must be 'Y'.
    --
    if p_mn_enrd_rqd_ovrid_num is not null and p_mx_enrd_alwd_ovrid_num is null and
        p_no_mx_pl_typ_ovrid_flag <> 'Y' then
      --
      fnd_message.set_name('BEN','mn_num_dpndcy_err');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_min_num_ovrd_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation code is not 'Required' or 'Optional', then the
--   following must be null:  Cert Req Flag and Derivable Factors Apply Flag.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
--   drvd_fctr_dpnt_cvg_flag
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
Procedure chk_dpnt_dsgn_cd_dpndcy(p_ptip_id                     in number,
                                  p_dpnt_dsgn_cd                in varchar2,
  				  p_drvd_fctr_dpnt_cvg_flag     in varchar2,
                                  p_effective_date              in date,
                                  p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd_dpndcy';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dpnt_dsgn_cd,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2) or
          nvl(p_drvd_fctr_dpnt_cvg_flag,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.drvd_fctr_dpnt_cvg_flag,hr_api.g_varchar2))
      or not l_api_updating) then
    --
 if nvl(p_dpnt_dsgn_cd,'X') not in ('R','O') and
           (p_drvd_fctr_dpnt_cvg_flag = 'Y' ) then
             --
             hr_utility.set_message('BEN','BEN_91247_PT_DPNT_DSGN_RQD');
             hr_utility.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd_dpndcy;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd_detail >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level is null then the following tables must
--   contain no records for that program:  BEN_LER_CHG_DPNT_CVG_F,
--   BEN_APLD_DPNT_CVG_ELIG_PRFL_F, BEN_PGM_DPNT_CVG_CTFN_F.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
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
Procedure chk_dpnt_dsgn_cd_detail(p_ptip_id                    in number,
                                 p_dpnt_dsgn_cd                in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dpnt_dsgn_cd_detail';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is select 'x'
                  from ben_ler_chg_dpnt_cvg_f ldc
                  where ldc.ptip_id = p_ptip_id
                    and ldc.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ldc.effective_start_date
                                             and ldc.effective_end_date;
  --
  cursor c2 is select 'x'
                  from ben_apld_dpnt_cvg_elig_prfl_f ade
                  where ade.ptip_id = p_ptip_id
                    and ade.business_group_id + 0 = p_business_group_id
                    and p_effective_date between ade.effective_start_date
                                             and ade.effective_end_date;
  --
  cursor c3 is select 'x'
                  from ben_ptip_dpnt_cvg_ctfn_f pgc
                  where pgc.ptip_id = p_ptip_id
                    and pgc.business_group_id + 0 = p_business_group_id
                    and p_effective_date between pgc.effective_start_date
                                             and pgc.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                    => p_ptip_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --

 if (l_api_updating
      and nvl(p_dpnt_dsgn_cd,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    null;
    --
    -- If ldc records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
         --
         close c1;
         fnd_message.set_name('BEN','BEN_92518_DELETE_LDC');
         fnd_message.raise_error;
         --
      else
         close c1;
      end if;
          --
    end if;
    --
    -- If ade records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c2;
      fetch c2 into l_dummy;
      if c2%found then
         --
         close c2;
         fnd_message.set_name('BEN','BEN_92517_DELETE_ADE');
         fnd_message.raise_error;
         --
      else
         close c2;
      end if;
       --
    end if;
    --
    -- If pyd records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c3;
      fetch c3 into l_dummy;
      if c3%found then
         --
         close c3;
         fnd_message.set_name('BEN','BEN_92516_DELETE_PYD');
         fnd_message.raise_error;
         --
      else
         close c3;
      end if;
      --
    end if;
    --
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd_detail;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd_lvl_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation level from ben_pgm_f is not = 'Plan Type', then the
--   following must be null:  Dpnt Dsgn Cd, Cert Req Flag and Derivable Factors Apply Flag.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptip_id PK of record being inserted or updated.
--   pgm_id
--   dpnt_dsgn_cd Value of lookup code.
--   drvd_fctr_dpnt_cvg_flag
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
Procedure chk_dpnt_dsgn_cd_lvl_dpndcy(p_ptip_id                in number,
                                 p_pgm_id                      in number,
                                 p_dpnt_dsgn_cd                in varchar2,
  			         p_drvd_fctr_dpnt_cvg_flag     in varchar2,
                                 p_effective_date              in date,
                                 p_business_group_id           in number,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd_lvl_dpndcy';
  l_api_updating boolean;
  l_value varchar2(30);
  --
   cursor c1 is select pgm.dpnt_dsgn_lvl_cd
                  from ben_pgm_f pgm
                  where pgm.pgm_id = p_pgm_id
                    and pgm.business_group_id + 0 = p_business_group_id
                    and p_effective_date between pgm.effective_start_date
                                             and pgm.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ctp_shd.api_updating
    (p_ptip_id                     => p_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_dpnt_dsgn_cd,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2) or
          nvl(p_drvd_fctr_dpnt_cvg_flag,hr_api.g_varchar2)
               <> nvl(ben_ctp_shd.g_old_rec.drvd_fctr_dpnt_cvg_flag,hr_api.g_varchar2))
      or not l_api_updating) then
    --
      open c1;
      fetch c1 into l_value;
      if c1%found then
        if nvl(l_value,'X') not in ('PTIP') and
          (p_dpnt_dsgn_cd is not null or
           p_drvd_fctr_dpnt_cvg_flag = 'Y' ) then
            --
            close c1;
            if l_value is null then
              fnd_message.set_name('BEN','BEN_91248_PT_DSGN_LVL_RQD');
              fnd_message.raise_error;
            else
              fnd_message.set_name('BEN','BEN_91249_INV_DSGN_LVL_PT');
              fnd_message.raise_error;
            end if;
            --
        end if;
      end if;
      close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd_lvl_dpndcy;
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
            (p_pgm_id                        in number default hr_api.g_number,
             p_cmbn_ptip_id                  in number default hr_api.g_number,
             p_cmbn_ptip_opt_id              in number default hr_api.g_number,
             p_acrs_ptip_cvg_id              in number default hr_api.g_number,
             p_pl_typ_id                     in number default hr_api.g_number,
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
    If ((nvl(p_cmbn_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cmbn_ptip_f',
             p_base_key_column => 'cmbn_ptip_id',
             p_base_key_value  => p_cmbn_ptip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cmbn_ptip_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_cmbn_ptip_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cmbn_ptip_opt_f',
             p_base_key_column => 'cmbn_ptip_opt_id',
             p_base_key_value  => p_cmbn_ptip_opt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cmbn_ptip_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_acrs_ptip_cvg_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acrs_ptip_cvg_f',
             p_base_key_column => 'acrs_ptip_cvg_id',
             p_base_key_value  => p_acrs_ptip_cvg_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cmbn_ptip_f';
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
            (p_ptip_id		in number,
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
       p_argument       => 'ptip_id',
       p_argument_value => p_ptip_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_f',
           p_base_key_column => 'ptip_id',
           p_base_key_value  => p_ptip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_wv_prtn_rsn_ptip_f',
           p_base_key_column => 'ptip_id',
           p_base_key_value  => p_ptip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_wv_prtn_rsn_ptip_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_dpnt_cvg_f',
           p_base_key_column => 'ptip_id',
           p_base_key_value  => p_ptip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_dpnt_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_base_rt_f',
           p_base_key_column => 'ptip_id',
           p_base_key_value  => p_ptip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_apld_dpnt_cvg_elig_prfl_f',
           p_base_key_column => 'ptip_id',
           p_base_key_value  => p_ptip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_apld_dpnt_cvg_elig_prfl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ptip_dpnt_cvg_ctfn_f',
           p_base_key_column => 'ptip_id',
           p_base_key_value  => p_ptip_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ptip_dpnt_cvg_ctfn_f';
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
	(p_rec 			 in ben_ctp_shd.g_rec_type,
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
  chk_ptip_id
  (p_ptip_id          => p_rec.ptip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_enrt_perd_tco_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_rqd_enrt_perd_tco_cd         => p_rec.rqd_enrt_perd_tco_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_pl_typ_overid_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_no_mn_pl_typ_overid_flag         => p_rec.no_mn_pl_typ_overid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_drvbl_fctr_apls_rts_flag  => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_drvbl_fctr_prtn_elig_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_drvbl_fctr_prtn_elig_flag => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_elig_apls_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_elig_apls_flag            => p_rec.elig_apls_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_prtn_elig_ovrid_alwd_flag => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_trk_inelig_per_flag       => p_rec.trk_inelig_per_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_sbj_to_sps_lf_ins_mx_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_sbj_to_sps_lf_ins_mx_flag => p_rec.sbj_to_sps_lf_ins_mx_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sbj_to_dpnt_lf_ins_mx_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_sbj_to_dpnt_lf_ins_mx_flag => p_rec.sbj_to_dpnt_lf_ins_mx_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_to_sum_ee_lf_ins_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_use_to_sum_ee_lf_ins_flag  => p_rec.use_to_sum_ee_lf_ins_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvd_fctr_dpnt_cvg_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_drvd_fctr_dpnt_cvg_flag         => p_rec.drvd_fctr_dpnt_cvg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wvbl_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_wvbl_flag         => p_rec.wvbl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--

  chk_dpnt_adrs_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_adrs_rqd_flag         => p_rec.dpnt_adrs_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_no_ctfn_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_cvg_no_ctfn_rqd_flag         => p_rec.dpnt_cvg_no_ctfn_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dob_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_dob_rqd_flag         => p_rec.dpnt_dob_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_legv_id_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_legv_id_rqd_flag         => p_rec.dpnt_legv_id_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_perd_enrt_nenrt_tm_uom
  (p_ptip_id          => p_rec.ptip_id,
   p_rqd_perd_enrt_nenrt_tm_uom         => p_rec.rqd_perd_enrt_nenrt_tm_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prvds_cr_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_prvds_cr_flag         => p_rec.prvds_cr_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_pl_typ_ovrid_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_no_mx_pl_typ_ovrid_flag         => p_rec.no_mx_pl_typ_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 --
  --
  chk_vrfy_fmly_mmbr_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_vrfy_fmly_mmbr_cd     => p_rec.vrfy_fmly_mmbr_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_ptip_stat_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_ptip_stat_cd         => p_rec.ptip_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_crs_this_pl_typ_only_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_crs_this_pl_typ_only_flag         => p_rec.crs_this_pl_typ_only_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_dsgn_cd         =>  p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd  =>  p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd   =>  p_rec.dpnt_cvg_end_dt_cd,
   p_effective_date       =>  p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_dpnt_cvg_strt_dt_rl      => p_rec.dpnt_cvg_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dpnt_cvg_end_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_dpnt_cvg_end_dt_rl      => p_rec.dpnt_cvg_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_postelcn_edit_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_postelcn_edit_rl      => p_rec.postelcn_edit_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_end_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_rt_end_dt_rl      => p_rec.rt_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_strt_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_rt_strt_dt_rl      => p_rec.rt_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_end_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_cvg_end_dt_rl      => p_rec.enrt_cvg_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_cvg_strt_dt_rl      => p_rec.enrt_cvg_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rqd_perd_enrt_nenrt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_rqd_perd_enrt_nenrt_rl      => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_auto_enrt_mthd_rl     => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_rl               => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dflt_enrt_det_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_dflt_enrt_det_rl      => p_rec.dflt_enrt_det_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_mthd_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_cd               => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_dflt_enrt_cd          => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_cvg_strt_dt_cd         => p_rec.dpnt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_rt_end_dt_cd         => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_enrt_cvg_end_dt_cd         => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_enrt_cvg_strt_dt_cd         => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_cvg_end_dt_cd         => p_rec.dpnt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_coord_cvg_for_all_pls_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_coord_cvg_for_all_pls_flag         => p_rec.coord_cvg_for_all_pls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_ordr_num
  (p_ptip_id           => p_rec.ptip_id
  ,p_pgm_id            => p_rec.pgm_id
  ,p_ordr_num          => p_rec.ordr_num
  ,p_business_group_id => p_rec.business_group_id
  ,p_effective_date    => p_effective_date
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date) ;

  --
  chk_pl_typ_waivable
  (p_rec.ptip_id
  ,p_rec.wvbl_flag
  ,p_rec.pgm_id
  ,p_rec.business_group_id
  ,p_effective_date
  ,p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.dpnt_cvg_strt_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_cd,
   p_dt_rl                    => p_rec.dpnt_cvg_strt_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.rt_end_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.rt_end_dt_cd,
   p_dt_rl                    => p_rec.rt_end_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.rt_end_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.rt_strt_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.rt_strt_dt_cd,
   p_dt_rl                    => p_rec.rt_strt_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.rt_strt_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.enrt_cvg_end_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_cd,
   p_dt_rl                    => p_rec.enrt_cvg_end_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.enrt_cvg_strt_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_cd,
   p_dt_rl                    => p_rec.enrt_cvg_strt_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.dpnt_cvg_end_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_cd,
   p_dt_rl                    => p_rec.dpnt_cvg_end_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
/*chk_plan_typ_temporal
  (p_rec.pl_typ_id
  ,p_effective_date
  ,p_rec.business_group_id
  ,p_rec.pgm_id );
*/
  --
  chk_rqd_perd_enrt_nenrt_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_rqd_perd_enrt_nenrt_val  => p_rec.rqd_perd_enrt_nenrt_val,
   p_rqd_perd_enrt_nenrt_tm_uom  => p_rec.rqd_perd_enrt_nenrt_tm_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_max_num_ovrd_flg_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_mx_enrd_alwd_ovrid_num    =>  p_rec.mx_enrd_alwd_ovrid_num,
   p_no_mx_pl_typ_ovrid_flag   =>  p_rec.no_mx_pl_typ_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_min_num_ovrd_flg_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_mn_enrd_rqd_ovrid_num    =>  p_rec.mn_enrd_rqd_ovrid_num,
   p_no_mn_pl_typ_overid_flag   =>  p_rec.no_mn_pl_typ_overid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_enrd_alwd_ovrid_num
  (p_ptip_id          => p_rec.ptip_id,
   p_pl_typ_id            => p_rec.pl_typ_id,
   p_mx_enrd_alwd_ovrid_num  => p_rec.mx_enrd_alwd_ovrid_num,
   p_effective_date        => p_effective_date,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mn_enrd_rqd_ovrid_num
  (p_ptip_id          => p_rec.ptip_id,
   p_pl_typ_id            => p_rec.pl_typ_id,
   p_mn_enrd_rqd_ovrid_num  => p_rec.mn_enrd_rqd_ovrid_num,
   p_effective_date        => p_effective_date,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
-- this will never occur, prior chks prevent it!
/*  chk_min_num_ovrd_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_mx_enrd_alwd_ovrid_num  => p_rec.mx_enrd_alwd_ovrid_num,
   p_mn_enrd_rqd_ovrid_num  => p_rec.mn_enrd_rqd_ovrid_num,
   p_no_mx_pl_typ_ovrid_flag   =>  p_rec.no_mx_pl_typ_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number); */
  --
  chk_dpnt_dsgn_cd_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_dsgn_cd         => p_rec.dpnt_dsgn_cd,
   p_drvd_fctr_dpnt_cvg_flag         => p_rec.drvd_fctr_dpnt_cvg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_detail
     (p_ptip_id            => p_rec.ptip_id,
      p_dpnt_dsgn_cd       => p_rec.dpnt_dsgn_cd,
      p_business_group_id  => p_rec.business_group_id,
      p_effective_date     => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_lvl_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_pgm_id          => p_rec.pgm_id,
   p_dpnt_dsgn_cd         => p_rec.dpnt_dsgn_cd,
   p_drvd_fctr_dpnt_cvg_flag         => p_rec.drvd_fctr_dpnt_cvg_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_dup_pl_typ_id_in_pgm(p_pl_typ_id  => p_rec.pl_typ_id
                               ,p_effective_date => p_effective_date
                               ,p_business_group_id => p_rec.business_group_id
                               ,p_pgm_id => p_rec.pgm_id
                               ,p_ptip_id => p_rec.ptip_id
                               ,p_validation_start_date  => p_validation_start_date
                               ,p_validation_end_date    => p_validation_end_date) ;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ctp_shd.g_rec_type,
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
  chk_ptip_id
  (p_ptip_id          => p_rec.ptip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_enrt_perd_tco_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_rqd_enrt_perd_tco_cd         => p_rec.rqd_enrt_perd_tco_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_pl_typ_overid_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_no_mn_pl_typ_overid_flag         => p_rec.no_mn_pl_typ_overid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_rts_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_drvbl_fctr_apls_rts_flag  => p_rec.drvbl_fctr_apls_rts_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_drvbl_fctr_prtn_elig_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_drvbl_fctr_prtn_elig_flag => p_rec.drvbl_fctr_prtn_elig_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_elig_apls_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_elig_apls_flag            => p_rec.elig_apls_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_prtn_elig_ovrid_alwd_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_prtn_elig_ovrid_alwd_flag => p_rec.prtn_elig_ovrid_alwd_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_trk_inelig_per_flag
  (p_ptip_id                   => p_rec.ptip_id,
   p_trk_inelig_per_flag       => p_rec.trk_inelig_per_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_sbj_to_sps_lf_ins_mx_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_sbj_to_sps_lf_ins_mx_flag => p_rec.sbj_to_sps_lf_ins_mx_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sbj_to_dpnt_lf_ins_mx_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_sbj_to_dpnt_lf_ins_mx_flag => p_rec.sbj_to_dpnt_lf_ins_mx_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_to_sum_ee_lf_ins_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_use_to_sum_ee_lf_ins_flag  => p_rec.use_to_sum_ee_lf_ins_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvd_fctr_dpnt_cvg_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_drvd_fctr_dpnt_cvg_flag         => p_rec.drvd_fctr_dpnt_cvg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wvbl_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_wvbl_flag         => p_rec.wvbl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_dpnt_adrs_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_adrs_rqd_flag         => p_rec.dpnt_adrs_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_no_ctfn_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_cvg_no_ctfn_rqd_flag         => p_rec.dpnt_cvg_no_ctfn_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dob_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_dob_rqd_flag         => p_rec.dpnt_dob_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_legv_id_rqd_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_legv_id_rqd_flag         => p_rec.dpnt_legv_id_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_perd_enrt_nenrt_tm_uom
  (p_ptip_id          => p_rec.ptip_id,
   p_rqd_perd_enrt_nenrt_tm_uom         => p_rec.rqd_perd_enrt_nenrt_tm_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prvds_cr_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_prvds_cr_flag         => p_rec.prvds_cr_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_pl_typ_ovrid_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_no_mx_pl_typ_ovrid_flag         => p_rec.no_mx_pl_typ_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ptip_stat_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_ptip_stat_cd         => p_rec.ptip_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 --
  --
  chk_vrfy_fmly_mmbr_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_vrfy_fmly_mmbr_cd     => p_rec.vrfy_fmly_mmbr_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_crs_this_pl_typ_only_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_crs_this_pl_typ_only_flag         => p_rec.crs_this_pl_typ_only_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_dsgn_cd         => p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd  =>  p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd   =>  p_rec.dpnt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_dpnt_cvg_strt_dt_rl      => p_rec.dpnt_cvg_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_postelcn_edit_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_postelcn_edit_rl      => p_rec.postelcn_edit_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_end_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_rt_end_dt_rl      => p_rec.rt_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rt_strt_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_rt_strt_dt_rl      => p_rec.rt_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_end_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_cvg_end_dt_rl      => p_rec.enrt_cvg_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_cvg_strt_dt_rl      => p_rec.enrt_cvg_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rqd_perd_enrt_nenrt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_rqd_perd_enrt_nenrt_rl      => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_auto_enrt_mthd_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_auto_enrt_mthd_rl     => p_rec.auto_enrt_mthd_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_rl               => p_rec.enrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dflt_enrt_det_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_dflt_enrt_det_rl      => p_rec.dflt_enrt_det_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_enrt_mthd_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_mthd_cd          => p_rec.enrt_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_enrt_cd               => p_rec.enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_enrt_cd
  (p_ptip_id               => p_rec.ptip_id,
   p_dflt_enrt_cd          => p_rec.dflt_enrt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_rl
  (p_ptip_id               => p_rec.ptip_id,
   p_dpnt_cvg_end_dt_rl      => p_rec.dpnt_cvg_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dpnt_cvg_strt_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_cvg_strt_dt_cd         => p_rec.dpnt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_rt_end_dt_cd         => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_enrt_cvg_end_dt_cd         => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_enrt_cvg_strt_dt_cd         => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_end_dt_cd
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_cvg_end_dt_cd         => p_rec.dpnt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_coord_cvg_for_all_pls_flag
  (p_ptip_id          => p_rec.ptip_id,
   p_coord_cvg_for_all_pls_flag         => p_rec.coord_cvg_for_all_pls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_ordr_num
  (p_ptip_id           => p_rec.ptip_id
  ,p_pgm_id            => p_rec.pgm_id
  ,p_ordr_num          => p_rec.ordr_num
  ,p_business_group_id => p_rec.business_group_id
  ,p_effective_date    => p_effective_date
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date) ;

  --
  chk_pl_typ_waivable
  (p_rec.ptip_id
  ,p_rec.wvbl_flag
  ,p_rec.pgm_id
  ,p_rec.business_group_id
  ,p_effective_date
  ,p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.dpnt_cvg_strt_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_cd,
   p_dt_rl                    => p_rec.dpnt_cvg_strt_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.rt_end_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.rt_end_dt_cd,
   p_dt_rl                    => p_rec.rt_end_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.rt_end_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.rt_strt_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.rt_strt_dt_cd,
   p_dt_rl                    => p_rec.rt_strt_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.rt_strt_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.enrt_cvg_end_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_cd,
   p_dt_rl                    => p_rec.enrt_cvg_end_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.enrt_cvg_strt_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_cd,
   p_dt_rl                    => p_rec.enrt_cvg_strt_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_dpndcy
  (p_ptip_id                  => p_rec.ptip_id,
   p_dt_cd                    => p_rec.dpnt_cvg_end_dt_cd,
   p_old_dt_cd                => ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_cd,
   p_dt_rl                    => p_rec.dpnt_cvg_end_dt_rl,
   p_old_dt_rl                => ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_rl,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
/*chk_plan_typ_temporal
  (p_rec.pl_typ_id
  ,p_effective_date
  ,p_rec.business_group_id
  ,p_rec.pgm_id );
*/
  --
  chk_rqd_perd_enrt_nenrt_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_rqd_perd_enrt_nenrt_val  => p_rec.rqd_perd_enrt_nenrt_val,
   p_rqd_perd_enrt_nenrt_tm_uom  => p_rec.rqd_perd_enrt_nenrt_tm_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_max_num_ovrd_flg_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_mx_enrd_alwd_ovrid_num    =>  p_rec.mx_enrd_alwd_ovrid_num,
   p_no_mx_pl_typ_ovrid_flag   =>  p_rec.no_mx_pl_typ_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  chk_min_num_ovrd_flg_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_mn_enrd_rqd_ovrid_num    =>  p_rec.mn_enrd_rqd_ovrid_num,
   p_no_mn_pl_typ_overid_flag   =>  p_rec.no_mn_pl_typ_overid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_enrd_alwd_ovrid_num
  (p_ptip_id          => p_rec.ptip_id,
   p_pl_typ_id            => p_rec.pl_typ_id,
   p_mx_enrd_alwd_ovrid_num  => p_rec.mx_enrd_alwd_ovrid_num,
   p_effective_date        => p_effective_date,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mn_enrd_rqd_ovrid_num
  (p_ptip_id          => p_rec.ptip_id,
   p_pl_typ_id            => p_rec.pl_typ_id,
   p_mn_enrd_rqd_ovrid_num  => p_rec.mn_enrd_rqd_ovrid_num,
   p_effective_date        => p_effective_date,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
-- this will never occur, prior chks prevent it!
/*  chk_min_num_ovrd_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_mx_enrd_alwd_ovrid_num  => p_rec.mx_enrd_alwd_ovrid_num,
   p_mn_enrd_rqd_ovrid_num  => p_rec.mn_enrd_rqd_ovrid_num,
   p_no_mx_pl_typ_ovrid_flag   =>  p_rec.no_mx_pl_typ_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number); */
  --
  chk_dpnt_dsgn_cd_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_dpnt_dsgn_cd         => p_rec.dpnt_dsgn_cd,
   p_drvd_fctr_dpnt_cvg_flag         => p_rec.drvd_fctr_dpnt_cvg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_detail
     (p_ptip_id            => p_rec.ptip_id,
      p_dpnt_dsgn_cd       => p_rec.dpnt_dsgn_cd,
      p_business_group_id  => p_rec.business_group_id,
      p_effective_date     => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_cd_lvl_dpndcy
  (p_ptip_id          => p_rec.ptip_id,
   p_pgm_id          => p_rec.pgm_id,
   p_dpnt_dsgn_cd         => p_rec.dpnt_dsgn_cd,
   p_drvd_fctr_dpnt_cvg_flag         => p_rec.drvd_fctr_dpnt_cvg_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_dup_pl_typ_id_in_pgm(p_pl_typ_id  => p_rec.pl_typ_id
                               ,p_effective_date => p_effective_date
                               ,p_business_group_id => p_rec.business_group_id
                               ,p_pgm_id => p_rec.pgm_id
                               ,p_ptip_id => p_rec.ptip_id
                               ,p_validation_start_date  => p_validation_start_date
                               ,p_validation_end_date    => p_validation_end_date) ;

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_pgm_id                        => p_rec.pgm_id,
     p_pl_typ_id                     => p_rec.pl_typ_id,
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
	(p_rec 			 in ben_ctp_shd.g_rec_type,
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
     p_ptip_id		=> p_rec.ptip_id);
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
  (p_ptip_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ptip_f b
    where b.ptip_id      = p_ptip_id
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
                             p_argument       => 'ptip_id',
                             p_argument_value => p_ptip_id);
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

end ben_ctp_bus;

/
