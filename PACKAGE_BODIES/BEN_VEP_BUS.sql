--------------------------------------------------------
--  DDL for Package Body BEN_VEP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VEP_BUS" as
/* $Header: beveprhi.pkb 120.0.12010000.2 2008/08/05 15:33:44 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_vep_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vrbl_rt_elig_prfl_id                    number         default null;
--
-- ----------------------------------------------------------------------------
-- |------< chk_vrbl_rt_elig_prfl_id >------|
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
--   vrbl_rt_elig_prfl_id PK of record being inserted or updated.
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
Procedure chk_vrbl_rt_elig_prfl_id(p_vrbl_rt_elig_prfl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_elig_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vep_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_vrbl_rt_elig_prfl_id        => p_vrbl_rt_elig_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_vrbl_rt_elig_prfl_id,hr_api.g_number)
     <>  ben_vep_shd.g_old_rec.vrbl_rt_elig_prfl_id) then
    -- raise error as PK has changed
    --
    ben_vep_shd.constraint_error('BEN_VRBL_RT_ELIG_PRFL_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_vrbl_rt_elig_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_vep_shd.constraint_error('BEN_VRBL_RT_ELIG_PRFL_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_vrbl_rt_elig_prfl_id;



-- ----------------------------------------------------------------------------
-- |------< chk_mndtry_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_elig_prfl_id PK of record being inserted or updated.
--   mndtry_flag Value of lookup code.
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
Procedure chk_mndtry_flag(p_vrbl_rt_elig_prfl_id                in number,
                            p_mndtry_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  --
  l_proc         varchar2(72) := g_package||'chk_mndtry_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vep_shd.api_updating
    (p_vrbl_rt_elig_prfl_id                => p_vrbl_rt_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mndtry_flag
      <> nvl(ben_vep_shd.g_old_rec.mndtry_flag,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'MNDTRY_FLAG_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mndtry_flag;
-- ----------------------------------------------------------------------------
-- |------< chk_vrbl_rt_elig_prfl_count >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there should be only one
--   Eligibility Profile record linked to VAPRO.
--   This procedure has been created as part of bug 3548872
--   Since PDW is not supporting multiple VAPROs, we have this check.
--   As soon as PDW start supporting multiple VAPROs, this procedure needs
--  to be removed. This would be called only from Insert_Validate
--
--
-- In Parameters
--   p_vrbl_rt_prfl_id
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
Procedure chk_vrbl_rt_elig_prfl_count(
                           p_vrbl_rt_prfl_id         in number,
                           p_effective_date	         in date
                           ) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_elig_prfl_count';
  l_dummy        varchar2(1)  := null ;
  --
  cursor c_vrbl_rt_elig_prfl is
    select null from
         BEN_VRBL_RT_ELIG_PRFL_f vep
    where
     vep.vrbl_rt_prfl_id        = p_vrbl_rt_prfl_id
     and p_effective_date between effective_start_date
     						and effective_end_date;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- raise error as the record already exists
    open c_vrbl_rt_elig_prfl ;
    fetch c_vrbl_rt_elig_prfl into l_dummy ;
    --
    if c_vrbl_rt_elig_prfl%found then
    --
      hr_utility.set_location('Only one Profile is allowed ', 8 ) ;
      close c_vrbl_rt_elig_prfl ;
      fnd_message.set_name('BEN','BEN_93952_ONLY_ONE_ELPRO');
      fnd_message.raise_error;
    --
    end if;
    close c_vrbl_rt_elig_prfl ;
   --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_vrbl_rt_elig_prfl_count;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_uniq_vrbl_rt_elig_prfl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the the records is unique with the
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_id
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
Procedure chk_uniq_vrbl_rt_elig_prfl(
                           p_vrbl_rt_elig_prfl_id    in number,
                           p_eligy_prfl_id           in number,
                           p_vrbl_rt_prfl_id         in number,
                           p_effective_date          in date,
                           p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_uniq_vrbl_rt_elig_prfl';
  l_dummy        varchar2(1)  := null ;
  --
  cursor c_uniq_vrbl_rt_elig_prfl is
    select null from
         BEN_VRBL_RT_ELIG_PRFL_f vep
    where
      vep.eligy_prfl_id   = p_eligy_prfl_id
     and  vep.vrbl_rt_prfl_id        = p_vrbl_rt_prfl_id
     and  vep.effective_start_date > p_effective_date
     and  nvl(vep.vrbl_rt_elig_prfl_id,-1) <> p_vrbl_rt_elig_prfl_id ;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- raise error as the record already exists
    open c_uniq_vrbl_rt_elig_prfl ;
    fetch c_uniq_vrbl_rt_elig_prfl into l_dummy ;
    --
    if c_uniq_vrbl_rt_elig_prfl%found then
    --
      hr_utility.set_location('Future record exists.Cannot insert ', 8 ) ;
      close c_uniq_vrbl_rt_elig_prfl ;
      fnd_message.set_name('PER','HR_7211_DT_UPD_ROWS_IN_FUTURE');
      fnd_message.raise_error;
    --
    end if;
    close c_uniq_vrbl_rt_elig_prfl ;
   --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_uniq_vrbl_rt_elig_prfl;
--
--  2940151
-- ----------------------------------------------------------------------------
-- |------< chk_elig_prfl_criteria >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that a variable prfl has either an
--   elig profile or criteria attached, not both
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_id
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
Procedure chk_elig_prfl_criteria(
                           p_vrbl_rt_elig_prfl_id    in number,
                           p_eligy_prfl_id           in number,
                           p_vrbl_rt_prfl_id         in number,
                           p_effective_date          in date,
                           p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_prfl_criteria';
  l_dummy        varchar2(1)  := null ;
  --
  cursor c_vrbl_rt_flags is
    select 'X' from
         ben_vrbl_rt_prfl_f vpf
    where
      vpf.vrbl_rt_prfl_id   = p_vrbl_rt_prfl_id
     and p_effective_date between vpf.effective_start_date and vpf.effective_end_date
     and (rt_hrly_slrd_flag = 'Y' or
	rt_pstl_cd_flag = 'Y' or
	rt_lbr_mmbr_flag = 'Y' or
	rt_lgl_enty_flag = 'Y' or
	rt_benfts_grp_flag = 'Y' or
	rt_wk_loc_flag = 'Y' or
	rt_brgng_unit_flag = 'Y' or
	rt_age_flag = 'Y' or
	rt_los_flag = 'Y' or
	rt_per_typ_flag = 'Y' or
	rt_fl_tm_pt_tm_flag = 'Y' or
	rt_ee_stat_flag = 'Y' or
	rt_grd_flag = 'Y' or
	rt_pct_fl_tm_flag = 'Y' or
	rt_asnt_set_flag = 'Y' or
	rt_hrs_wkd_flag = 'Y' or
	rt_comp_lvl_flag = 'Y' or
	rt_org_unit_flag = 'Y' or
	rt_loa_rsn_flag = 'Y' or
	rt_pyrl_flag = 'Y' or
	rt_schedd_hrs_flag = 'Y' or
	rt_py_bss_flag = 'Y' or
	rt_prfl_rl_flag = 'Y' or
	rt_cmbn_age_los_flag = 'Y' or
	rt_prtt_pl_flag = 'Y' or
	rt_svc_area_flag = 'Y' or
	rt_ppl_grp_flag = 'Y' or
	rt_dsbld_flag = 'Y' or
	rt_hlth_cvg_flag = 'Y' or
	rt_poe_flag = 'Y' or
	rt_ttl_cvg_vol_flag = 'Y' or
	rt_ttl_prtt_flag = 'Y' or
	rt_gndr_flag = 'Y' or
	rt_tbco_use_flag = 'Y' or
	rt_cntng_prtn_prfl_flag = 'Y' or
	rt_cbr_quald_bnf_flag = 'Y' or
	rt_optd_mdcr_flag = 'Y' or
	rt_lvg_rsn_flag = 'Y' or
	rt_pstn_flag = 'Y' or
	rt_comptncy_flag = 'Y' or
	rt_job_flag = 'Y' or
	rt_qual_titl_flag = 'Y' or
	rt_dpnt_cvrd_pl_flag = 'Y' or
	rt_dpnt_cvrd_plip_flag = 'Y' or
	rt_dpnt_cvrd_ptip_flag = 'Y' or
	rt_dpnt_cvrd_pgm_flag = 'Y' or
	rt_enrld_oipl_flag = 'Y' or
	rt_enrld_pl_flag = 'Y' or
	rt_enrld_plip_flag = 'Y' or
	rt_enrld_ptip_flag = 'Y' or
	rt_enrld_pgm_flag = 'Y' or
	rt_prtt_anthr_pl_flag = 'Y' or
	rt_othr_ptip_flag = 'Y' or
	rt_no_othr_cvg_flag = 'Y' or
	rt_dpnt_othr_ptip_flag = 'Y' or
	rt_qua_in_gr_flag = 'Y' or
	rt_perf_rtng_flag = 'Y'
	-- or rt_elig_prfl_flag = 'Y'
	);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- raise error as the record already exists
    open c_vrbl_rt_flags ;
    fetch c_vrbl_rt_flags into l_dummy ;
    --
    if c_vrbl_rt_flags%found then
    --

      close c_vrbl_rt_flags ;
      fnd_message.set_name('BEN','BEN_93550_VAPRO_ELIG_PRFL');
      fnd_message.raise_error;
    --
    end if;
    close c_vrbl_rt_flags ;
   --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_prfl_criteria;
--

--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vrbl_rt_elig_prfl_id                             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , BEN_VRBL_RT_ELIG_PRFL_f vep
     where vep.vrbl_rt_elig_prfl_id = p_vrbl_rt_elig_prfl_id
       and pbg.business_group_id = vep.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VRBL_RT_ELIG_PRFL_ID'
    ,p_argument_value     => p_vrbl_rt_elig_prfl_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_vrbl_rt_elig_prfl_id                             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , BEN_VRBL_RT_ELIG_PRFL_f vep
     where vep.vrbl_rt_elig_prfl_id = p_vrbl_rt_elig_prfl_id
       and pbg.business_group_id = vep.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VRBL_RT_ELIG_PRFL_ID'
    ,p_argument_value     => p_vrbl_rt_elig_prfl_id
    );
  --
  if ( nvl(ben_vep_bus.g_vrbl_rt_elig_prfl_id, hr_api.g_number)
       = p_vrbl_rt_elig_prfl_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_vep_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    ben_vep_bus.g_vrbl_rt_elig_prfl_id          := p_vrbl_rt_elig_prfl_id;
    ben_vep_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
/*
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in ben_vep_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.vrbl_rt_elig_prfl_id is not null)  and (
    nvl(ben_vep_shd.g_old_rec.vep_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute1, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute2, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute3, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute4, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute5, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute6, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute7, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute8, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute9, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute10, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute11, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute12, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute13, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute14, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute15, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute16, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute17, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute18, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute19, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute20, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute21, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute22, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute23, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute24, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute25, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute26, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute27, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute28, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute29, hr_api.g_varchar2)  or
    nvl(ben_vep_shd.g_old_rec.vep_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.vep_attribute30, hr_api.g_varchar2) ))
    or (p_rec.vrbl_rt_elig_prfl_idis null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'VEP_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'VEP_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.vep_attribute1
      ,p_attribute2_name                 => 'VEP_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.vep_attribute2
      ,p_attribute3_name                 => 'VEP_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.vep_attribute3
      ,p_attribute4_name                 => 'VEP_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.vep_attribute4
      ,p_attribute5_name                 => 'VEP_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.vep_attribute5
      ,p_attribute6_name                 => 'VEP_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.vep_attribute6
      ,p_attribute7_name                 => 'VEP_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.vep_attribute7
      ,p_attribute8_name                 => 'VEP_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.vep_attribute8
      ,p_attribute9_name                 => 'VEP_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.vep_attribute9
      ,p_attribute10_name                => 'VEP_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.vep_attribute10
      ,p_attribute11_name                => 'VEP_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.vep_attribute11
      ,p_attribute12_name                => 'VEP_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.vep_attribute12
      ,p_attribute13_name                => 'VEP_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.vep_attribute13
      ,p_attribute14_name                => 'VEP_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.vep_attribute14
      ,p_attribute15_name                => 'VEP_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.vep_attribute15
      ,p_attribute16_name                => 'VEP_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.vep_attribute16
      ,p_attribute17_name                => 'VEP_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.vep_attribute17
      ,p_attribute18_name                => 'VEP_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.vep_attribute18
      ,p_attribute19_name                => 'VEP_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.vep_attribute19
      ,p_attribute20_name                => 'VEP_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.vep_attribute20
      ,p_attribute21_name                => 'VEP_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.vep_attribute21
      ,p_attribute22_name                => 'VEP_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.vep_attribute22
      ,p_attribute23_name                => 'VEP_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.vep_attribute23
      ,p_attribute24_name                => 'VEP_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.vep_attribute24
      ,p_attribute25_name                => 'VEP_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.vep_attribute25
      ,p_attribute26_name                => 'VEP_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.vep_attribute26
      ,p_attribute27_name                => 'VEP_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.vep_attribute27
      ,p_attribute28_name                => 'VEP_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.vep_attribute28
      ,p_attribute29_name                => 'VEP_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.vep_attribute29
      ,p_attribute30_name                => 'VEP_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.vep_attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
*/
--
/*
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date  in date
  ,p_rec             in ben_vep_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_vep_shd.api_updating
      (p_vrbl_rt_elig_prfl_id             => p_rec.vrbl_rt_elig_prfl_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
*/
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_ttlcov_ttlprtt_mutexcl >----------------------|
-- ----------------------------------------------------------------------------
-- Added for checks during usage of 'Eligbility Profiles' for defining
-- criteria for calculation of Variable Coverages and Variable Actual Premiums.
-- Bug : 3456400
--
--
Procedure chk_ttlcov_ttlprtt_mutexcl
  (p_vrbl_rt_prfl_id        in number
  ,p_eligy_prfl_id          in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ) is
--
  l_dummy 	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_ttlcov_ttlprtt_mutexcl';
  --
  cursor c1 is
    select null
    from ben_elig_ttl_cvg_vol_prte_f
    where eligy_prfl_id = p_eligy_prfl_id
    and exists
      (select null
      from ben_elig_ttl_prtt_prte_f
      where eligy_prfl_id in
      	(select eligy_prfl_id
	 from ben_vrbl_rt_elig_prfl_f
	 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
	 and business_group_id = p_business_group_id
	 and p_effective_date between effective_start_date and effective_end_date)
      or eligy_prfl_id = p_eligy_prfl_id);
  --
  cursor c2 is
    select null
    from ben_elig_ttl_prtt_prte_f
    where eligy_prfl_id = p_eligy_prfl_id
    and exists
      (select null
       from ben_elig_ttl_cvg_vol_prte_f
       where eligy_prfl_id in
      	(select eligy_prfl_id
	 from ben_vrbl_rt_elig_prfl_f
	 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
	 and business_group_id = p_business_group_id
	 and p_effective_date between effective_start_date and effective_end_date)
      or eligy_prfl_id = p_eligy_prfl_id);

  --
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  --
  if c1%found then
    close c1;
    fnd_message.set_name('BEN','BEN_92258_TTLPRTT_CVGVOL_EXCL1');
    fnd_message.raise_error;
  end if;
  --
  close c1;
  --
  --
  open c2;
  fetch c2 into l_dummy;
  --
  if c2%found then
    close c2;
    fnd_message.set_name('BEN','BEN_92259_TTLPRTT_CVGVOL_EXCL2');
    fnd_message.raise_error;
  end if;
  --
  close c2;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_ttlcov_ttlprtt_mutexcl;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_ttlcov_ttlprtt_mlt_cd >-----------------------|
-- ----------------------------------------------------------------------------
-- Added for checks during usage of 'Eligbility Profiles' for defining
-- criteria for calculation of Variable Coverages and Variable Actual Premiums.
-- Bug : 3456400
--
Procedure chk_ttlcov_ttlprtt_mlt_cd
  (p_vrbl_rt_prfl_id        in number
  ,p_eligy_prfl_id          in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ) is
--
  l_dummy 	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_ttlcov_ttlprtt_mlt_cd';
  l_mlt_cd      varchar2(30);
  l_vrbl_usg_cd varchar2(30);
  --
  cursor c1 is
  select mlt_cd, vrbl_usg_cd
  from ben_vrbl_rt_prfl_f
  where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
  and business_group_id = p_business_group_id
  and p_effective_date between effective_start_date and effective_end_date;
  --
  cursor c2 is
  select null
  from ben_elig_ttl_prtt_prte_f
  where eligy_prfl_id = p_eligy_prfl_id
  and business_group_id = p_business_group_id
  and p_effective_date between effective_start_date and effective_end_date;
  --
  cursor c3 is
  select null
  from ben_elig_ttl_cvg_vol_prte_f
  where eligy_prfl_id = p_eligy_prfl_id
  and business_group_id = p_business_group_id
  and p_effective_date between effective_start_date and effective_end_date;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_mlt_cd, l_vrbl_usg_cd;
  close c1;
  --
  open c2;
  fetch c2 into l_dummy;
  if c2%found then
    if l_vrbl_usg_cd = 'ACP' and l_mlt_cd <> 'TTLPRTT' then
      close c2;
      fnd_message.set_name('BEN','BEN_92263_TTLPRTT_MLTCD');
      fnd_message.raise_error;
    end if;
  end if;
  close c2;
  --
  --
  open c3;
  fetch c3 into l_dummy;
  if c3%found then
    if l_vrbl_usg_cd = 'ACP' and l_mlt_cd <> 'TTLCVG' then
      close c3;
      fnd_message.set_name('BEN','BEN_92264_TTLCVG_MLTCD');
      fnd_message.raise_error;
    end if;
  end if;
  close c3;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_ttlcov_ttlprtt_mlt_cd;
--

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
  (
  p_vrbl_rt_prfl_id               in number default hr_api.g_number
  ,p_eligy_prfl_id                 in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
Exception
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
  (p_vrbl_rt_elig_prfl_id             in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'VRBL_RT_ELIG_PRFL_ID'
      ,p_argument_value => p_vrbl_rt_elig_prfl_id
      );
    --
  --
    --
  End If;
  --
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
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ben_vep_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  --ben_vep_bus.chk_df(p_rec);

    chk_vrbl_rt_elig_prfl_id
  (p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  -- Check the future rows for eligy_prfl/effective_date combination
  --
  chk_mndtry_flag
  (p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_mndtry_flag           => p_rec.mndtry_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

chk_vrbl_rt_elig_prfl_count(
	p_vrbl_rt_prfl_id       =>p_rec.vrbl_rt_prfl_id,
	p_effective_date        => p_effective_date);

  chk_uniq_vrbl_rt_elig_prfl
  (
   p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_vrbl_rt_prfl_id       =>p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         =>p_rec.eligy_prfl_id,
   p_effective_date        =>p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  chk_elig_prfl_criteria
  (
   p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_vrbl_rt_prfl_id       =>p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         =>p_rec.eligy_prfl_id,
   p_effective_date        =>p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 -- Bug : 3456400
 chk_ttlcov_ttlprtt_mutexcl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
 chk_ttlcov_ttlprtt_mlt_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ben_vep_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_vrbl_rt_elig_prfl_id
  (p_vrbl_rt_elig_prfl_id          => p_rec.vrbl_rt_elig_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_mndtry_flag
  (p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_mndtry_flag           => p_rec.mndtry_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

   chk_uniq_vrbl_rt_elig_prfl
  (
   p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_vrbl_rt_prfl_id       =>p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         =>p_rec.eligy_prfl_id,
   p_effective_date        =>p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_elig_prfl_criteria
  (
   p_vrbl_rt_elig_prfl_id  => p_rec.vrbl_rt_elig_prfl_id,
   p_vrbl_rt_prfl_id       =>p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         =>p_rec.eligy_prfl_id,
   p_effective_date        =>p_effective_date,
   p_object_version_number => p_rec.object_version_number);

 -- Bug : 3456400
 chk_ttlcov_ttlprtt_mutexcl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
 chk_ttlcov_ttlprtt_mlt_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_eligy_prfl_id         => p_rec.eligy_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);

  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
    p_vrbl_rt_prfl_id                        => p_rec.vrbl_rt_prfl_id
    ,p_eligy_prfl_id                         => p_rec.eligy_prfl_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
/*
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
*/
  --
  --
  --ben_vep_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ben_vep_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_vrbl_rt_elig_prfl_id                         => p_rec.vrbl_rt_elig_prfl_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
end ben_vep_bus;

/
