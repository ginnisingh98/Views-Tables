--------------------------------------------------------
--  DDL for Package Body BEN_VPF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VPF_BUS" as
/* $Header: bevpfrhi.pkb 120.1.12010000.1 2008/07/29 13:07:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_vpf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_vrbl_rt_prfl_id >---------------------------|
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
--   vrbl_rt_prfl_id PK of record being inserted or updated.
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
Procedure chk_vrbl_rt_prfl_id(p_vrbl_rt_prfl_id             in number,
                              p_effective_date              in date,
                              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_vrbl_rt_prfl_id,hr_api.g_number)
     <>  ben_vpf_shd.g_old_rec.vrbl_rt_prfl_id) then
    --
    -- raise error as PK has changed
    --
    ben_vpf_shd.constraint_error('BEN_VRBL_RT_PRFL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_vrbl_rt_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_vpf_shd.constraint_error('BEN_VRBL_RT_PRFL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_vrbl_rt_prfl_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_vrbl_usg_cd_dependencies >---------------------------|
-- ----------------------------------------------------------------------------
-- Bug : 3476138
-- Description
--   This procedure is used to check that if VPF.VRBL_USG_CD_NAME (Usage) is updated
--   then there are no corresponding records in ben_bnft_vrbl_rt_f, ben_acty_vrbl_rt_r
--   or ben_actl_prem_vrbl_rt_f if the VAPRO was associated with Coverage, Activity Base Rates
--   or Actual Premiums respectively.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id         :PK of record being updated.
--   validation_start_date   : Validation Start Date of update
--   validation_end_date     : Validation End Date of update
--   vrbl_usg_cd           : Usage code (ACP, CVG or RT)
--   effective_date        : effective date of the update.
--   object_version_number : OVN of record being updated.
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
Procedure chk_vrbl_usg_cd_dependencies(p_vrbl_rt_prfl_id             in number,
                                        p_validation_start_date in date,
                                        p_validation_end_date in date,
                                        p_vrbl_usg_cd                   in varchar2,
					p_effective_date            in date,
	                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_usg_cd_dependencies';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_vrbl_usg_cd,hr_api.g_varchar2)
     <>  ben_vpf_shd.g_old_rec.vrbl_usg_cd) then

    if ben_vpf_shd.g_old_rec.vrbl_usg_cd = 'RT' then
    --
         If   (dt_api.rows_exist
                 (p_base_table_name => 'ben_acty_vrbl_rt_f',
                  p_base_key_column => 'vrbl_rt_prfl_id',
                  p_base_key_value  => p_vrbl_rt_prfl_id,
                  p_from_date       => p_validation_start_date,
                  p_to_date         => p_validation_end_date)) Then
        --
		  fnd_message.set_name('BEN','BEN_93902_VAPRO_CHILD_EXISTS');
	          fnd_message.set_token('RATE_TYPE','Standard Rate');
		  fnd_message.raise_error;
        --
	end if;
    --
    End If;
    --
    if ben_vpf_shd.g_old_rec.vrbl_usg_cd = 'CVG' then
    --
         If   (dt_api.rows_exist
                 (p_base_table_name => 'ben_bnft_vrbl_rt_f',
                  p_base_key_column => 'vrbl_rt_prfl_id',
                  p_base_key_value  => p_vrbl_rt_prfl_id,
                  p_from_date       => p_validation_start_date,
                  p_to_date         => p_validation_end_date)) Then
        --
		  fnd_message.set_name ('BEN','BEN_93902_VAPRO_CHILD_EXISTS');
	          fnd_message.set_token('RATE_TYPE','Coverage');
		  fnd_message.raise_error;
        --
	end if;
    --
    End If;
    --
    --
    if ben_vpf_shd.g_old_rec.vrbl_usg_cd = 'ACP' then
    --
         If   (dt_api.rows_exist
                 (p_base_table_name => 'ben_actl_prem_vrbl_rt_f',
                  p_base_key_column => 'vrbl_rt_prfl_id',
                  p_base_key_value  => p_vrbl_rt_prfl_id,
                  p_from_date       => p_validation_start_date,
                  p_to_date         => p_validation_end_date)) Then
        --
		  fnd_message.set_name('BEN','BEN_93902_VAPRO_CHILD_EXISTS');
	          fnd_message.set_token('RATE_TYPE','Actual Premium');
		  fnd_message.raise_error;
        --
	end if;
	hr_utility.set_location('Reaced here',9999);
    --
    End If;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_vrbl_usg_cd_dependencies;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_mn_mx_elcn_vals >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the value given for MN_ELCN_VAL is less than the value
--   given for MX_ELCN_VAL
--
-- Pre Conditions
--   none
--
-- In Parameters
--     p_mn_elcn_val  Minimum Election Value.
--     p_mx_elcn_val  Maximum Election Value.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
-- ----------------------------------------------------------------------------
Procedure chk_mn_mx_elcn_vals
             (p_mn_elcn_val  in number,
              p_mx_elcn_val  in number) is
begin
   if p_mn_elcn_val is not null and
      p_mx_elcn_val is not null and
      p_mx_elcn_val < p_mn_elcn_val then
         fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
         fnd_message.raise_error;
   end if;
end chk_mn_mx_elcn_vals;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_lwr_upr_lmt_vals >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the value given for lwr_lmt_val is less than the value
--   given for upr_lmt_val
--
-- Pre Conditions
--   none
--
-- In Parameters
--  lwr_lmt_val
--  upr_lmt_val
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
-- ----------------------------------------------------------------------------
Procedure chk_lwr_upr_lmt_vals
             (p_lwr_lmt_val  in number,
              p_upr_lmt_val  in number) is
begin
   if p_lwr_lmt_val is not null and
      p_upr_lmt_val is not null and
      p_upr_lmt_val < p_lwr_lmt_val then
         fnd_message.set_name('BEN','BEN_92279_LWR_LESS_NOT_EQ_UPR');
         fnd_message.raise_error;
   end if;
end chk_lwr_upr_lmt_vals;
--

-- ----------------------------------------------------------------------------
-- |------------------------< chk_lwr_upr_lmt_vals >--------------------------|
-- ----------------------------------------------------------------------------

Procedure chk_ultmt_lwr_upr_lmt
             (p_ultmt_lwr_lmt  in number,
              p_ultmt_upr_lmt  in number) is
begin
   if p_ultmt_lwr_lmt is not null and
      p_ultmt_upr_lmt is not null and
      p_ultmt_upr_lmt < p_ultmt_lwr_lmt then
         fnd_message.set_name('BEN','BEN_92279_LWR_LESS_NOT_EQ_UPR');
         fnd_message.raise_error;
   end if;
end chk_ultmt_lwr_upr_lmt;



-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the Variable Rate Profile Name is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is Vrbl_Rt_Prfl name
--     p_vrbl_rt_prfl_id is vrbl_rt_prfl_id
--     p_business_group_id
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
Procedure chk_name_unique
          ( p_vrbl_rt_prfl_id      in   varchar2
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_vrbl_rt_prfl_f
             Where  vrbl_rt_prfl_id <> nvl(p_vrbl_rt_prfl_id,-1)
             and    name = p_name
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_name_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_lwr_lmt_val_and_rl >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that lwr_lmt_val and lwr_lmt_calc_rl
--        are mutually exclusive.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id               PK of record being inserted or updated.
--   lwr_lmt_val                   Lower Limit Value.
--   lwr_lmt_calc_rl               Lower Limit Value Rule.
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
Procedure chk_lwr_lmt_val_and_rl(p_vrbl_rt_prfl_id               in number,
                                 p_lwr_lmt_val                   in number,
                                 p_lwr_lmt_calc_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lwr_lmt_val_and_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Lower Limit Value and Lower Limit Value Rule fields must be
    -- mutually exclusive.
    if (p_lwr_lmt_val is not null and p_lwr_lmt_calc_rl is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_91859_LWR_LMT_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
end chk_lwr_lmt_val_and_rl;



-- ----------------------------------------------------------------------------
-- |---------------------< chk_ultmt_lwr_lmt_and_rl >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that ultmt_lwr_lmt_val and
---   ulmt_lwr_lmt_calc_rl
--        are mutually exclusive.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id               PK of record being inserted or updated.
--   ultmt_lwr_lmt                 Lower Limit Value.
--   ultmt_lwr_lmt_calc_rl         Lower Limit Value Rule.
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
Procedure chk_ultmt_lwr_lmt_val_and_rl(p_vrbl_rt_prfl_id         in number,
                                 p_ultmt_lwr_lmt                 in number,
                                 p_ultmt_lwr_lmt_calc_rl         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ultmt_lwr_lmt_val_and_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Lower Limit Value and Lower Limit Value Rule fields must be
    -- mutually exclusive.
    if (p_ultmt_lwr_lmt is not null and p_ultmt_lwr_lmt_calc_rl is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_91859_LWR_LMT_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
end chk_ultmt_lwr_lmt_val_and_rl;


--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_upr_lmt_val_and_rl >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that upr_lmt_val and upr_lmt_calc_rl
--        are mutually exclusive.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id               PK of record being inserted or updated.
--   upr_lmt_val                   Upper Limit Value.
--   upr_lmt_calc_rl               Upper Limit Value Rule.
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
Procedure chk_upr_lmt_val_and_rl(p_vrbl_rt_prfl_id               in number,
                                 p_upr_lmt_val                   in number,
                                 p_upr_lmt_calc_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upr_lmt_val_and_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Upper Limit Value and Upper Limit Value Rule fields must be
    -- mutually exclusive.
    if (p_upr_lmt_val is not null and p_upr_lmt_calc_rl is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_91860_UPR_LMT_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
end chk_upr_lmt_val_and_rl;


--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_ultmt_upr_lmt_val_and_rl >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check that ultmt_upr_lmt and
-- ultmt_upr_lmt_calc_rl
-- are mutually exclusive.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id               PK of record being inserted or updated.
--   ultmt_upr_lmt                 Upper Limit Value.
--   ultmt_upr_lmt_calc_rl         Upper Limit Value Rule.
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
Procedure chk_ultmt_upr_lmt_val_and_rl(p_vrbl_rt_prfl_id    in number,
                                 p_ultmt_upr_lmt            in number,
                                 p_ultmt_upr_lmt_calc_rl    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ultmt_upr_lmt_val_and_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Upper Limit Value and Upper Limit Value Rule fields must be
    -- mutually exclusive.
    if (p_ultmt_upr_lmt is not null and p_ultmt_upr_lmt_calc_rl is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_91860_UPR_LMT_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
end chk_ultmt_upr_lmt_val_and_rl;


--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vrbl_rt_prfl_stat_cd >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   vrbl_rt_prfl_stat_cd Value of lookup code.
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
Procedure chk_vrbl_rt_prfl_stat_cd(p_vrbl_rt_prfl_id       in number,
                                   p_vrbl_rt_prfl_stat_cd  in varchar2,
                                   p_effective_date        in date,
                                   p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_prfl_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id                => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrbl_rt_prfl_stat_cd
      <> nvl(ben_vpf_shd.g_old_rec.vrbl_rt_prfl_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_vrbl_rt_prfl_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_vrbl_rt_prfl_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP vrbl_rt_prfl_stat_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrbl_rt_prfl_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_val_calc_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   val_calc_rl Value of formula rule id.
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
Procedure chk_val_calc_rl(p_vrbl_rt_prfl_id          in number,
                          p_val_calc_rl              in number,
                          p_business_group_id        in number,
                          p_effective_date           in date,
                          p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_val_calc_rl
    and    ff.formula_type_id in (-171, -49, -507)
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_val_calc_rl,hr_api.g_number)
      <> ben_vpf_shd.g_old_rec.val_calc_rl
      or not l_api_updating)
      and p_val_calc_rl is not null then
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
        hr_utility.set_message(801,'FORMULA_DOES_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_rndg_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   rndg_rl         Value of formula rule id.
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
Procedure chk_rndg_rl    (p_vrbl_rt_prfl_id          in number,
                          p_rndg_rl                  in number,
                          p_business_group_id        in number,
                          p_effective_date           in date,
                          p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rndg_rl
    and    ff.formula_type_id = -169
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_vpf_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
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
        hr_utility.set_message('BEN','BEN_91042_INVALID_RNDG_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_lwr_lmt_calc_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id         PK of record being inserted or updated.
--   lwr_lmt_calc_rl         Value of formula rule id.
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
Procedure chk_lwr_lmt_calc_rl  (p_vrbl_rt_prfl_id          in number,
                                p_lwr_lmt_calc_rl          in number,
                                p_business_group_id        in number,
                                p_effective_date           in date,
                                p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lwr_lmt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_lwr_lmt_calc_rl
    and    ff.formula_type_id in (-392, -511, -512)
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_lwr_lmt_calc_rl,hr_api.g_number)
      <> ben_vpf_shd.g_old_rec.lwr_lmt_calc_rl
      or not l_api_updating)
      and p_lwr_lmt_calc_rl is not null then
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
        hr_utility.set_message('BEN','BEN_91815_INVALID_LWR_LMT_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lwr_lmt_calc_rl;


-- ----------------------------------------------------------------------------
-- |---------------------< chk_ultmt_lwr_lmt_calc_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id         PK of record being inserted or updated.
--   ultmt_lwr_lmt_calc_rl   Value of formula rule id.
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
Procedure chk_ultmt_lwr_lmt_calc_rl (p_vrbl_rt_prfl_id     in number,
                                p_ultmt_lwr_lmt_calc_rl    in number,
                                p_business_group_id        in number,
                                p_effective_date           in date,
                                p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ultmt_lwr_lmt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_ultmt_lwr_lmt_calc_rl
    and    ff.formula_type_id in (-392, -511, -512)
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ultmt_lwr_lmt_calc_rl,hr_api.g_number)
      <> ben_vpf_shd.g_old_rec.ultmt_lwr_lmt_calc_rl
      or not l_api_updating)
      and p_ultmt_lwr_lmt_calc_rl is not null then
    --
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
        hr_utility.set_message('BEN','BEN_91815_INVALID_LWR_LMT_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ultmt_lwr_lmt_calc_rl;



--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_upr_lmt_calc_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id         PK of record being inserted or updated.
--   upr_lmt_calc_rl         Value of formula rule id.
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
Procedure chk_upr_lmt_calc_rl  (p_vrbl_rt_prfl_id          in number,
                                p_upr_lmt_calc_rl          in number,
                                p_business_group_id        in number,
                                p_effective_date           in date,
                                p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upr_lmt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_upr_lmt_calc_rl
    and    ff.formula_type_id in (-293, -514, -515)
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_upr_lmt_calc_rl,hr_api.g_number)
      <> ben_vpf_shd.g_old_rec.upr_lmt_calc_rl
      or not l_api_updating)
      and p_upr_lmt_calc_rl is not null then
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
        hr_utility.set_message('BEN','BEN_91823_INVALID_UPR_LMT_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_upr_lmt_calc_rl;


-- ----------------------------------------------------------------------------
-- |---------------------< chk_ultmt_upr_lmt_calc_rl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id         PK of record being inserted or updated.
--   upr_lmt_calc_rl         Value of formula rule id.
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
Procedure chk_ultmt_upr_lmt_calc_rl(p_vrbl_rt_prfl_id    in number,
                                p_ultmt_upr_lmt_calc_rl    in number,
                                p_business_group_id        in number,
                                p_effective_date           in date,
                                p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ultmt_upr_lmt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_ultmt_upr_lmt_calc_rl
    and    ff.formula_type_id in (-293, -514, -515)
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ultmt_upr_lmt_calc_rl,hr_api.g_number)
      <> ben_vpf_shd.g_old_rec.ultmt_upr_lmt_calc_rl
      or not l_api_updating)
      and p_ultmt_upr_lmt_calc_rl is not null then
    --

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
        hr_utility.set_message('BEN','BEN_91823_INVALID_UPR_LMT_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ultmt_upr_lmt_calc_rl;





--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_no_mx_elcn_val_dfnd_flag >------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   no_mx_elcn_val_dfnd_flag Value of lookup code.
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
Procedure chk_no_mx_elcn_val_dfnd_flag
   (p_vrbl_rt_prfl_id             in number,
    p_no_mx_elcn_val_dfnd_flag    in varchar2,
    p_effective_date              in date,
    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_elcn_val_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_elcn_val_dfnd_flag
      <> nvl(ben_vpf_shd.g_old_rec.no_mx_elcn_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_elcn_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: no_mx_elcn_val');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_elcn_val_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_no_mn_elcn_val_dfnd_flag >------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   no_mn_elcn_val_dfnd_flag Value of lookup code.
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
Procedure chk_no_mn_elcn_val_dfnd_flag
   (p_vrbl_rt_prfl_id             in number,
    p_no_mn_elcn_val_dfnd_flag    in varchar2,
    p_effective_date              in date,
    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_elcn_val_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_elcn_val_dfnd_flag
      <> nvl(ben_vpf_shd.g_old_rec.no_mn_elcn_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_elcn_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: no_mn_elcn_val');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_elcn_val_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_alwys_sum_all_cvg_flag >------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   alwys_sum_all_cvg_flag Value of lookup code.
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
Procedure chk_alwys_sum_all_cvg_flag
   (p_vrbl_rt_prfl_id             in number,
    p_alwys_sum_all_cvg_flag    in varchar2,
    p_effective_date              in date,
    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_alwys_sum_all_cvg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_alwys_sum_all_cvg_flag
      <> nvl(ben_vpf_shd.g_old_rec.alwys_sum_all_cvg_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alwys_sum_all_cvg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: alwys_sum_all_cvg');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alwys_sum_all_cvg_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_alwys_cnt_all_prtts_flag >------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   alwys_cnt_all_prtts_flag Value of lookup code.
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
Procedure chk_alwys_cnt_all_prtts_flag
   (p_vrbl_rt_prfl_id             in number,
    p_alwys_cnt_all_prtts_flag    in varchar2,
    p_effective_date              in date,
    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_alwys_cnt_all_prtts_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_alwys_cnt_all_prtts_flag
      <> nvl(ben_vpf_shd.g_old_rec.alwys_cnt_all_prtts_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alwys_cnt_all_prtts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: alwys_cnt_all_prt');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alwys_cnt_all_prtts_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mlt_cd >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   mlt_cd Value of lookup code.
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
Procedure chk_mlt_cd(p_vrbl_rt_prfl_id             in number,
                     p_mlt_cd                      in varchar2,
                     p_vrbl_usg_cd                 in varchar2,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mlt_cd';
  l_api_updating boolean;
  l_lookup_code  varchar2(20);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mlt_cd
      <> nvl(ben_vpf_shd.g_old_rec.mlt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_vrbl_usg_cd = 'RT' THEN
       l_lookup_code := 'BEN_MLT';
    elsif p_vrbl_usg_cd = 'CVG' THEN
       l_lookup_code := 'BEN_CVG_MLT';
    elsif p_vrbl_usg_cd = 'ACP' THEN
       l_lookup_code := 'BEN_ACTL_PREM_MLT';
    end if;
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => l_lookup_code,
           p_lookup_code    => p_mlt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_vrbl_usg_cd');
      fnd_message.set_token('TYPE', 'BEN_VRBL_USG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
    --
    -- if mlt_cd is 'TPLPC' then defer the action.
    if (p_mlt_cd = 'TPLPC') then
       fnd_message.set_name('BEN','BEN_92504_PREM_CALC_MTHD_DFRD');
       fnd_message.raise_error;
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mlt_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_vrbl_usg_cd >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id       PK of record being inserted or updated.
--   vrbl_usg_cd           Value of lookup code.
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
Procedure chk_vrbl_usg_cd(p_vrbl_rt_prfl_id             in number,
                          p_vrbl_usg_cd                 in varchar2,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_usg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrbl_usg_cd
      <> nvl(ben_vpf_shd.g_old_rec.vrbl_usg_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_VRBL_USG',
           p_lookup_code    => p_vrbl_usg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: vrbl_usg_cd');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrbl_usg_cd;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_asmt_to_use_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id       PK of record being inserted or updated.
--   asmt_to_use_cd        Value of lookup code.
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
Procedure chk_asmt_to_use_cd(p_vrbl_rt_prfl_id             in number,
                             p_asmt_to_use_cd              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_asmt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_asmt_to_use_cd
      <> nvl(ben_vpf_shd.g_old_rec.asmt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ASMT_TO_USE',
           p_lookup_code    => p_asmt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_asmt_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_ASMT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_asmt_to_use_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------<chk_rndg_cd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   rndg_cd         Value of lookup code.
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
Procedure chk_rndg_cd(p_vrbl_rt_prfl_id             in number,
                     p_rndg_cd                     in varchar2,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if p_rndg_cd is not null then
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_vpf_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: rndg_cd ');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_rndg_cd_rl >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the code/rule dependency as the
--   following:
--              If Code =  'Rule' then rule must be selected.
--              If Code <> 'Rule' thne rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rndg_cd                    Value of look up value.
--   rndg_rl                    value of look up Value
--                              inserted or updated.
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
Procedure chk_rndg_cd_rl       (p_rndg_cd          in varchar2,
                                p_rndg_rl          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check dependency of Code and Rule.
        --
        if (p_rndg_cd <> 'RL' and
            p_rndg_rl is not null) then
                fnd_message.set_name('BEN','BEN_91732_NO_RNDG_RULE');
                fnd_message.raise_error;
        end if;

        if (p_rndg_cd = 'RL' and p_rndg_rl is null) then
                fnd_message.set_name('BEN','BEN_91733_RNDG_RULE');
                fnd_message.raise_error;
        end if;

  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd_rl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_acty_ref_perd_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   acty_ref_perd_cd Value of lookup code.
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
Procedure chk_acty_ref_perd_cd(p_vrbl_rt_prfl_id             in number,
                               p_acty_ref_perd_cd            in varchar2,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_ref_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_ref_perd_cd
      <> nvl(ben_vpf_shd.g_old_rec.acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_REF_PERD',
           p_lookup_code    => p_acty_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: acty_ref_perd');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_ref_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_ref_perd_usg_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the periodicity is monthly if the usage code is actual_premium
--   Bug #3377
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_ref_perd_cd Value of lookup code.
--   p_vrbl_usg_cd
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
Procedure chk_ref_perd_usg_cd(p_acty_ref_perd_cd            in varchar2,
                                               p_vrbl_usg_cd                 in varchar2 ) is
  --
  l_proc   varchar2(72) := g_package||'chk_ref_perd_usg_cd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    if p_vrbl_usg_cd = 'ACP' then
       if p_acty_ref_perd_cd <> 'MO' then
      --
      -- raise error as does not exist as lookup
      --
         fnd_message.set_name('BEN','BEN_92439_REF_PERD_USAGE');
         fnd_message.raise_error;
      --
       end if;
    --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ref_perd_usg_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_val_othr_val >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if val field is not null then the other val must
--   be null and if any of the other val is not null then val must be null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--  p_val, p_mn_elcn_val, p_mx_elcn_val, p_incrmnt_elcn_val, p_dflt_elcn_val
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
Procedure  chk_val_othr_val(p_val in number,
                            p_mn_elcn_val in number,
                            p_mx_elcn_val in number,
                            p_incrmnt_elcn_val in number,
                            p_dflt_elcn_val in number,
                            p_mlt_cd in varchar2) is
  --
  l_proc   varchar2(72) := g_package||'chk_val_othr_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  FLFXPCL uses both p_val and p_mn_elcn_val.
  --
    if p_val is not null and p_mlt_cd <> 'FLFXPCL' then
       if p_mn_elcn_val is not null OR
          p_mx_elcn_val is not null OR
          p_incrmnt_elcn_val is not null OR
          p_dflt_elcn_val is not null then
      --
      -- raise error as does not exist as lookup
      --
         fnd_message.set_name('BEN','BEN_92440_VAL_VS_OTHERS');
         fnd_message.raise_error;
      --
       end if;
    --
    end if;
  --
   if p_mn_elcn_val          is not null OR p_mx_elcn_val      is not null OR
          p_incrmnt_elcn_val is not null OR p_dflt_elcn_val    is not null then
      if p_val is not null and p_mlt_cd <> 'FLFXPCL' then
      --
      -- raise error as does not exist as lookup
      --
         fnd_message.set_name('BEN','BEN_92440_VAL_VS_OTHERS');
         fnd_message.raise_error;
      --
      end if;
    --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val_othr_val;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vrbl_rt_trtmt_cd >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   vrbl_rt_trtmt_cd Value of lookup code.
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
Procedure chk_vrbl_rt_trtmt_cd(p_vrbl_rt_prfl_id             in number,
                               p_vrbl_rt_trtmt_cd            in varchar2,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_trtmt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrbl_rt_trtmt_cd
      <> nvl(ben_vpf_shd.g_old_rec.vrbl_rt_trtmt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TRTMT',
           p_lookup_code    => p_vrbl_rt_trtmt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: rt_trmnt');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrbl_rt_trtmt_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_tx_typ_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
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
Procedure chk_tx_typ_cd(p_vrbl_rt_prfl_id         in number,
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tx_typ_cd
      <> nvl(ben_vpf_shd.g_old_rec.tx_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
   hr_utility.set_location('lookup code is'||p_tx_typ_cd,20);
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TX_TYP',
           p_lookup_code    => p_tx_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: tx_typ');
      hr_utility.raise_error;
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
-- |--------------------------< chk_bnft_rt_typ_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
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
Procedure chk_bnft_rt_typ_cd(p_vrbl_rt_prfl_id             in number,
                             p_bnft_rt_typ_cd              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_rt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_rt_typ_cd
      <> nvl(ben_vpf_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_bnft_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: bnft_rt_typ');
      hr_utility.raise_error;
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
-- |---------------------------< chk_rt_typ_cd >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   rt_typ_cd Value of lookup code.
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
Procedure chk_rt_typ_cd(p_vrbl_rt_prfl_id         in number,
                        p_rt_typ_cd               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_typ_cd
      <> nvl(ben_vpf_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: rt_typ');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_acty_typ_cd >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
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
Procedure chk_acty_typ_cd(p_vrbl_rt_prfl_id           in number,
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
  l_api_updating := ben_vpf_shd.api_updating
    (p_vrbl_rt_prfl_id             => p_vrbl_rt_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_typ_cd
      <> nvl(ben_vpf_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_TYP',
           p_lookup_code    => p_acty_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'LOOKUP_NOT_EXIST: acty_typ');
      hr_utility.raise_error;
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
-- |-----------------------< chk_alwys_cnt_all_prtts_def >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the Always Count All
--   Participants Flag is Y then a TTL_PRTT_RT_F record must have
--   been defined.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   alwys_cnt_all_prtts_flag
--   effective_date effective date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_alwys_cnt_all_prtts_def(p_vrbl_rt_prfl_id       in number,
                                   p_alwys_cnt_all_prtts_flag  in varchar2,
                                   p_effective_date        in date,
                                   p_business_group_id    in   number) is
  --
  l_proc         varchar2(72) := g_package||'chk_alwys_cnt_all_prtts_def';
  l_dummy    char(1);
  cursor c1 is select null
             from   ben_ttl_prtt_rt_f
             Where  vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
             and    business_group_id = p_business_group_id
             and    p_effective_date between effective_start_date
             and    effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_alwys_cnt_all_prtts_flag = 'Y' then
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        close c1;
        fnd_message.set_name('BEN','BEN_92265_PRTT_CRIT_NOTDEF');
        fnd_message.raise_error;
     end if;
      --
     close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alwys_cnt_all_prtts_def;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_elig_alwys_cnt_all_prtt_df >-----------------|
-- ----------------------------------------------------------------------------
-- Added for checks during usage of 'Eligbility Profiles' for defining
-- criteria for calculation of Variable Coverages and Variable Actual Premiums.
-- Bug : 3456400
--
-- Description
--   This procedure is used to check that if the Always Count All
--   Participants Flag is Y then a BEN_ELIG_TTL_PRTT_PRTE_F record must have
--   been defined with the record (ELPRO) being attached to Variable Rate Profile
--   (VAPRO) identified by p_vrbl_rt_prfl_id.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   alwys_cnt_all_prtts_flag
--   effective_date
--   business_group_id
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_elig_alwys_cnt_all_prtt_df(p_vrbl_rt_prfl_id       in number,
                                   p_alwys_cnt_all_prtts_flag  in varchar2,
                                   p_effective_date        in date,
                                   p_business_group_id    in   number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_alwys_cnt_all_prtt_df';
  l_dummy    char(1);
  cursor c1 is select null
  	       from ben_elig_ttl_prtt_prte_f etp, ben_vrbl_rt_elig_prfl_f vep
	       where vep.eligy_prfl_id = etp.eligy_prfl_id
	       and vep.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
	       and vep.business_group_id = p_business_Group_id
	       and p_effective_date between vep.effective_start_date and vep.effective_end_date
	       and etp.business_group_id = p_business_Group_id
	       and p_effective_date between etp.effective_start_date and etp.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_alwys_cnt_all_prtts_flag = 'Y' then
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        close c1;
        fnd_message.set_name('BEN','BEN_92265_PRTT_CRIT_NOTDEF');
        fnd_message.raise_error;
     end if;
      --
     close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_alwys_cnt_all_prtt_df;


--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_alwys_sum_all_cvg_def >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the Always Sum All
--   Coverage Flag is Y then a TTL_CVG_VOL_RT_F record must have
--   been defined.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   alwys_sum_all_cvg_flag
--   effective_date effective date
--
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
Procedure chk_alwys_sum_all_cvg_def(p_vrbl_rt_prfl_id       in number,
                                   p_alwys_sum_all_cvg_flag  in varchar2,
                                   p_effective_date        in date,
                                   p_business_group_id    in   number) is
  --
  l_proc         varchar2(72) := g_package||'chk_alwys_sum_all_cvg_def';
  l_dummy    char(1);
  cursor c1 is select null
             from   ben_ttl_cvg_vol_rt_f
             Where  vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
             and    business_group_id = p_business_group_id
             and    p_effective_date between effective_start_date
             and    effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_alwys_sum_all_cvg_flag = 'Y' then
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        close c1;
        fnd_message.set_name('BEN','BEN_92266_CVG_CRIT_NOTDEF');
        fnd_message.raise_error;
     end if;
      --
     close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alwys_sum_all_cvg_def;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_elig_alwys_sum_all_cvg_def >-------------------|
-- ----------------------------------------------------------------------------
-- Added for checks during usage of 'Eligbility Profiles' for defining
-- criteria for calculation of Variable Coverages and Variable Actual Premiums.
-- Bug : 3456400
--
-- Description
--   This procedure is used to check that if the Always Sum All
--   Coverage Flag is Y then a BEN_ELIG_TTL_CVG_VOL_PRTE_F record must have
--   been defined with the record (ELPRO) attached to Variable Rate Profile
--   (VAPRO) identified by p_vrbl_rt_prfl_id.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id PK of record being inserted or updated.
--   alwys_sum_all_cvg_flag
--   effective_date
--   business_group_id
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
Procedure chk_elig_alwys_sum_all_cvg_def(p_vrbl_rt_prfl_id       in number,
                                   p_alwys_sum_all_cvg_flag  in varchar2,
                                   p_effective_date        in date,
                                   p_business_group_id    in   number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_alwys_sum_all_cvg_def';
  l_dummy    char(1);
 cursor c1 is select null
  	       from ben_elig_ttl_cvg_vol_prte_f etc, ben_vrbl_rt_elig_prfl_f vep
	       where vep.eligy_prfl_id = etc.eligy_prfl_id
	       and vep.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
	       and vep.business_group_id = p_business_Group_id
	       and p_effective_date between vep.effective_start_date and vep.effective_end_date
	       and etc.business_group_id = p_business_Group_id
	       and p_effective_date between etc.effective_start_date and etc.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_alwys_sum_all_cvg_flag = 'Y' then
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        close c1;
        fnd_message.set_name('BEN','BEN_92266_CVG_CRIT_NOTDEF');
        fnd_message.raise_error;
     end if;
      --
     close c1;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_alwys_sum_all_cvg_def;

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_usg_acty_tx_for_prem >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if vrbl_usg_cd = 'ACP' Actual Premium
--   then tx_typ_cd must be 'NOTAPPLICABLE' and if vrbl_usg_cd is not = 'ACP'
--   then acty_typ_cd is required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
-- vrbl_usg_cd
-- acty_typ_cd
-- tx_typ_cd
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
Procedure chk_usg_acty_tx_for_prem(p_vrbl_usg_cd          in varchar2,
                                   p_acty_typ_cd          in varchar2,
                                   p_tx_typ_cd            in varchar2) is
   --
  l_proc         varchar2(72) := g_package||'chk_usg_acty_tx_for_prem';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_vrbl_usg_cd = 'ACP' then
     if p_tx_typ_cd <> 'NOTAPPLICABLE' then
        fnd_message.set_name('BEN','BEN_92260_TX_TYP_MUST_NOTAPP');
        fnd_message.raise_error;
     end if;
  elsif p_acty_typ_cd is null then
     fnd_message.set_name('BEN','BEN_92261_ACTY_TYP_RQD');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_usg_acty_tx_for_prem;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_alwys_flag_one_def >--------------------------
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that only one of alwys_cnt_all_prtts_flag
--   or alwys_sum_all_cvg_flag is set to 'Y'.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alwys_cnt_all_prtts_flag
--   alwys_sum_all_cvg_flag
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
Procedure chk_alwys_flag_one_def(p_alwys_cnt_all_prtts_flag  in varchar2,
                                 p_alwys_sum_all_cvg_flag  in varchar2) is
   --
  l_proc         varchar2(72) := g_package||'chk_alwys_flag_one_def';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_alwys_cnt_all_prtts_flag = 'Y' and p_alwys_sum_all_cvg_flag = 'Y' then
  --  Only one flag can be set to Y
     fnd_message.set_name('BEN','BEN_92262_ONE_FLAG_ALWD_SET');
     fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alwys_flag_one_def;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_ttlprtt_mltcd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the mlt_cd = TTLPRTT or TTLCVG
--   that the applicable criteria must be set up on ttl_cvg_vol_rt or
--   ttl_prtt_rt.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id        PK of record being inserted or updated.
--   mlt_cd
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
Procedure  chk_ttlprtt_mtl_cd(p_vrbl_rt_prfl_id           in number,
                              p_mlt_cd                      in varchar2,
                                   p_effective_date            in date,
                                   p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ttlprtt_mtl_cd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ttl_cvg_vol_rt_f a

    where  a.business_group_id +0 = p_business_group_id
    and    a.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
  cursor c2 is
    select null
    from   ben_ttl_prtt_rt_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_mlt_cd <> 'TTLPRTT' then
    --
    --
    open c2;
      --
      fetch c2 into l_dummy;
      if c2%found then
        --
        --
        close c2;
        --
        -- raise an error as mlt_cd can't be changed when prtt criteria set up.
        --
        --
        fnd_message.set_name('BEN','BEN_92263_TTLPRTT_MLTCD');
        fnd_message.raise_error;
        --
      end if;
      --
    close c2;
    --
  end if;
  --
  if p_mlt_cd <> 'TTLCVG' then
    --
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        --
        close c1;
        --
        -- raise an error as mlt_cd can't be changed when cvg criteria set up.
        --
        --
        fnd_message.set_name('BEN','BEN_92264_TTLCVG_MLTCD');
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
End chk_ttlprtt_mtl_cd;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_elig_ttlprtt_mlt_cd >--------------------------|
-- ----------------------------------------------------------------------------
-- Added for checks during usage of 'Eligbility Profiles' for defining
-- criteria for calculation of Variable Coverages and Variable Actual Premiums.
-- Bug : 3456400
--
-- Description
--   This procedure is used to check that if the mlt_cd = TTLPRTT or TTLCVG
--   and any Eligibility Profile is defined
--   then none of the  Eligibility Profiles must be set up on ben_elig_ttl_cvg_vol_prte or
--   ben_elig_ttl_prtt_prte_f respectively.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id        PK of record being inserted or updated.
--   mlt_cd                 Calculation Method
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
Procedure  chk_elig_ttlprtt_mtl_cd(p_vrbl_rt_prfl_id           in number,
 	                         p_mlt_cd                      in varchar2,
                                   p_effective_date            in date,
                                   p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_ttlprtt_mtl_cd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is select null
  	       from ben_elig_ttl_cvg_vol_prte_f etc, ben_vrbl_rt_elig_prfl_f vep
	       where vep.eligy_prfl_id = etc.eligy_prfl_id
	       and vep.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
	       and vep.business_group_id = p_business_Group_id
	       and p_effective_date between vep.effective_start_date and vep.effective_end_date
	       and etc.business_group_id = p_business_Group_id
	       and p_effective_date between etc.effective_start_date and etc.effective_end_date;
  --
  cursor c2 is select null
  	       from ben_elig_ttl_prtt_prte_f etp, ben_vrbl_rt_elig_prfl_f vep
	       where vep.eligy_prfl_id = etp.eligy_prfl_id
	       and vep.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
	       and vep.business_group_id = p_business_Group_id
	       and p_effective_date between vep.effective_start_date and vep.effective_end_date
	       and etp.business_group_id = p_business_Group_id
	       and p_effective_date between etp.effective_start_date and etp.effective_end_date;
  --
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_mlt_cd <> 'TTLPRTT' then
    --
    open c2;
      --
      fetch c2 into l_dummy;
      if c2%found then
        --
        close c2;
        -- raise an error as mlt_cd can't be changed when prtt criteria set up.
        fnd_message.set_name('BEN','BEN_92263_TTLPRTT_MLTCD');
        fnd_message.raise_error;
        --
      end if;
      --
    close c2;
    --
  end if;
  --
  if p_mlt_cd <> 'TTLCVG' then
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        -- raise an error as mlt_cd can't be changed when cvg criteria set up.
        fnd_message.set_name('BEN','BEN_92264_TTLCVG_MLTCD');
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
End chk_elig_ttlprtt_mtl_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_profile_flags  >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   vrbl_rt_prfl_id          PK of record being inserted or updated.
--   rt_hrly_slrd_flag        Value of lookup code
--   rt_pstl_cd_flag          Value of lookup code
--   rt_lbr_mmbr_flag         Value of lookup code
--   rt_lgl_enty_flag         Value of lookup code
--   rt_benfts_grp_flag       Value of lookup code
--   rt_wk_loc_flag           Value of lookup code
--   rt_brgng_unit_flag       Value of lookup code
--   rt_age_flag              Value of lookup code
--   rt_los_flag              Value of lookup code
--   rt_per_typ_flag          Value of lookup code
--   rt_fl_tm_pt_tm_flag      Value of lookup code
--   rt_ee_stat_flag          Value of lookup code
--   rt_grd_flag              Value of lookup code
--   rt_pct_fl_tm_flag        Value of lookup code
--   rt_asnt_set_flag         Value of lookup code
--   rt_hrs_wkd_flag          Value of lookup code
--   rt_comp_lvl_flag         Value of lookup code
--   rt_org_unit_flag         Value of lookup code
--   rt_loa_rsn_flag          Value of lookup code
--   rt_pyrl_flag             Value of lookup code
--   rt_schedd_hrs_flag       Value of lookup code
--   rt_py_bss_flag           Value of lookup code
--   rt_prfl_rl_flag          Value of lookup code
--   rt_cmbn_age_los_flag     Value of lookup code
--   rt_prtt_pl_flag          Value of lookup code
--   rt_svc_area_flag         Value of lookup code
--   rt_ppl_grp_flag          Value of lookup code
--   rt_dsbld_flag            Value of lookup code
--   rt_hlth_cvg_flag         Value of lookup code
--   rt_poe_flag              Value of lookup code
--   rt_ttl_cvg_vol_flag      Value of lookup code
--   rt_ttl_prtt_flag         Value of lookup code
--   rt_gndr_flag             Value of lookup code
--   rt_tbco_use_flag         Value of lookup code
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
Procedure chk_profile_flags
   (p_vrbl_rt_prfl_id             in number,
    p_rt_hrly_slrd_flag           in varchar2,
    p_rt_pstl_cd_flag             in varchar2,
    p_rt_lbr_mmbr_flag            in varchar2,
    p_rt_lgl_enty_flag            in varchar2,
    p_rt_benfts_grp_flag          in varchar2,
    p_rt_wk_loc_flag              in varchar2,
    p_rt_brgng_unit_flag          in varchar2,
    p_rt_age_flag                 in varchar2,
    p_rt_los_flag                 in varchar2,
    p_rt_per_typ_flag             in varchar2,
    p_rt_fl_tm_pt_tm_flag         in varchar2,
    p_rt_ee_stat_flag             in varchar2,
    p_rt_grd_flag                 in varchar2,
    p_rt_pct_fl_tm_flag           in varchar2,
    p_rt_asnt_set_flag            in varchar2,
    p_rt_hrs_wkd_flag             in varchar2,
    p_rt_comp_lvl_flag            in varchar2,
    p_rt_org_unit_flag            in varchar2,
    p_rt_loa_rsn_flag             in varchar2,
    p_rt_pyrl_flag                in varchar2,
    p_rt_schedd_hrs_flag          in varchar2,
    p_rt_py_bss_flag              in varchar2,
    p_rt_prfl_rl_flag             in varchar2,
    p_rt_cmbn_age_los_flag        in varchar2,
    p_rt_prtt_pl_flag             in varchar2,
    p_rt_svc_area_flag            in varchar2,
    p_rt_ppl_grp_flag             in varchar2,
    p_rt_dsbld_flag               in varchar2,
    p_rt_hlth_cvg_flag            in varchar2,
    p_rt_poe_flag                 in varchar2,
    p_rt_ttl_cvg_vol_flag         in varchar2,
    p_rt_ttl_prtt_flag            in varchar2,
    p_rt_gndr_flag                in varchar2,
    p_rt_tbco_use_flag            in varchar2,
    p_effective_date              in date ,
    p_rt_cntng_prtn_prfl_flag	  in varchar2,
    p_rt_cbr_quald_bnf_flag  	  in varchar2,
    p_rt_optd_mdcr_flag      	  in varchar2,
    p_rt_lvg_rsn_flag        	  in varchar2,
    p_rt_pstn_flag           	  in varchar2,
    p_rt_comptncy_flag       	  in varchar2,
    p_rt_job_flag            	  in varchar2,
    p_rt_qual_titl_flag      	  in varchar2,
    p_rt_dpnt_cvrd_pl_flag   	  in varchar2,
    p_rt_dpnt_cvrd_plip_flag 	  in varchar2,
    p_rt_dpnt_cvrd_ptip_flag 	  in varchar2,
    p_rt_dpnt_cvrd_pgm_flag  	  in varchar2,
    p_rt_enrld_oipl_flag     	  in varchar2,
    p_rt_enrld_pl_flag       	  in varchar2,
    p_rt_enrld_plip_flag     	  in varchar2,
    p_rt_enrld_ptip_flag     	  in varchar2,
    p_rt_enrld_pgm_flag      	  in varchar2,
    p_rt_prtt_anthr_pl_flag  	  in varchar2,
    p_rt_othr_ptip_flag      	  in varchar2,
    p_rt_no_othr_cvg_flag    	  in varchar2,
    p_rt_dpnt_othr_ptip_flag 	  in varchar2,
    p_rt_qua_in_gr_flag    	  in varchar2,
    p_rt_perf_rtng_flag    	  in varchar2,
    p_rt_elig_prfl_flag    	  in varchar2
    ) is
  --
  l_proc         varchar2(72) := g_package||'chk_profile_flags';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_hrly_slrd_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_hrly_slrd_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_pstl_cd_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_pstl_cd_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_lbr_mmbr_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_lbr_mmbr_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_lgl_enty_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_lgl_enty_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_benfts_grp_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_benfts_grp_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_wk_loc_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_wk_loc_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_brgng_unit_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_brgng_unit_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_age_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_age_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_los_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_los_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_per_typ_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_per_typ_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_fl_tm_pt_tm_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_fl_tm_pt_tm_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_ee_stat_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_ee_stat_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_grd_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_grd_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_pct_fl_tm_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_pct_fl_tm_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_asnt_set_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_asnt_set_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_hrs_wkd_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_hrs_wkd_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_comp_lvl_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_comp_lvl_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_org_unit_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_org_unit_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_loa_rsn_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_loa_rsn_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_pyrl_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_pyrl_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_schedd_hrs_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_schedd_hrs_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_py_bss_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_py_bss_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_prfl_rl_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_prfl_rl_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_cmbn_age_los_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_cmbn_age_los_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_prtt_pl_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_prtt_pl_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_svc_area_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_svc_area_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_ppl_grp_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_ppl_grp_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_dsbld_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_dsbld_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_hlth_cvg_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_hlth_cvg_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_poe_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_poe_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_ttl_cvg_vol_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_ttl_cvg_vol_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_ttl_prtt_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_ttl_prtt_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_gndr_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_gndr_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_rt_tbco_use_flag,
        p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('FIELD',p_rt_tbco_use_flag);
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;


  if hr_api.not_exists_in_hr_lookups
         (p_lookup_type    => 'YES_NO',
          p_lookup_code    => p_rt_cntng_prtn_prfl_flag,
          p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_rt_cntng_prtn_prfl_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
  end if;

  if hr_api.not_exists_in_hr_lookups
         (p_lookup_type    => 'YES_NO',
          p_lookup_code    => p_rt_cbr_quald_bnf_flag,
          p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_rt_cbr_quald_bnf_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
  end if;

  if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_rt_optd_mdcr_flag,
            p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD',p_rt_optd_mdcr_flag);
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
        --
  end if;

  if hr_api.not_exists_in_hr_lookups
             (p_lookup_type    => 'YES_NO',
              p_lookup_code    => p_rt_lvg_rsn_flag,
              p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD',p_rt_lvg_rsn_flag);
          fnd_message.set_token('TYPE','YES_NO');
          fnd_message.raise_error;
          --
  end if;

  if hr_api.not_exists_in_hr_lookups
               (p_lookup_type    => 'YES_NO',
                p_lookup_code    => p_rt_pstn_flag,
                p_effective_date => p_effective_date) then
            --
            -- raise error as does not exist as lookup
            --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD',p_rt_pstn_flag);
            fnd_message.set_token('TYPE','YES_NO');
            fnd_message.raise_error;
            --
  end if;

  if hr_api.not_exists_in_hr_lookups
               (p_lookup_type    => 'YES_NO',
                p_lookup_code    => p_rt_comptncy_flag,
                p_effective_date => p_effective_date) then
            --
            -- raise error as does not exist as lookup
            --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD',p_rt_comptncy_flag);
            fnd_message.set_token('TYPE','YES_NO');
            fnd_message.raise_error;
            --
  end if;

  if hr_api.not_exists_in_hr_lookups
                 (p_lookup_type    => 'YES_NO',
                  p_lookup_code    => p_rt_job_flag,
                  p_effective_date => p_effective_date) then
              --
              -- raise error as does not exist as lookup
              --
              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
              fnd_message.set_token('FIELD',p_rt_job_flag);
              fnd_message.set_token('TYPE','YES_NO');
              fnd_message.raise_error;
              --
  end if;

  if hr_api.not_exists_in_hr_lookups
                   (p_lookup_type    => 'YES_NO',
                    p_lookup_code    => p_rt_qual_titl_flag,
                    p_effective_date => p_effective_date) then
                --
                -- raise error as does not exist as lookup
                --
                fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                fnd_message.set_token('FIELD',p_rt_qual_titl_flag);
                fnd_message.set_token('TYPE','YES_NO');
                fnd_message.raise_error;
                --
  end if;

  if hr_api.not_exists_in_hr_lookups
                     (p_lookup_type    => 'YES_NO',
                      p_lookup_code    => p_rt_dpnt_cvrd_pl_flag,
                      p_effective_date => p_effective_date) then
                  --
                  -- raise error as does not exist as lookup
                  --
                  fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                  fnd_message.set_token('FIELD',p_rt_dpnt_cvrd_pl_flag);
                  fnd_message.set_token('TYPE','YES_NO');
                  fnd_message.raise_error;
                  --
  end if;

  if hr_api.not_exists_in_hr_lookups
                       (p_lookup_type    => 'YES_NO',
                        p_lookup_code    => p_rt_dpnt_cvrd_plip_flag,
                        p_effective_date => p_effective_date) then
                    --
                    -- raise error as does not exist as lookup
                    --
                    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                    fnd_message.set_token('FIELD',p_rt_dpnt_cvrd_plip_flag);
                    fnd_message.set_token('TYPE','YES_NO');
                    fnd_message.raise_error;
                    --
  end if;

  if hr_api.not_exists_in_hr_lookups
                         (p_lookup_type    => 'YES_NO',
                          p_lookup_code    => p_rt_dpnt_cvrd_ptip_flag,
                          p_effective_date => p_effective_date) then
                      --
                      -- raise error as does not exist as lookup
                      --
                      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                      fnd_message.set_token('FIELD',p_rt_dpnt_cvrd_ptip_flag);
                      fnd_message.set_token('TYPE','YES_NO');
                      fnd_message.raise_error;
                      --
  end if;

  if hr_api.not_exists_in_hr_lookups
                           (p_lookup_type    => 'YES_NO',
                            p_lookup_code    => p_rt_dpnt_cvrd_pgm_flag,
                            p_effective_date => p_effective_date) then
                        --
                        -- raise error as does not exist as lookup
                        --
                        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                        fnd_message.set_token('FIELD',p_rt_dpnt_cvrd_pgm_flag);
                        fnd_message.set_token('TYPE','YES_NO');
                        fnd_message.raise_error;
                        --
  end if;

  if hr_api.not_exists_in_hr_lookups
                             (p_lookup_type    => 'YES_NO',
                              p_lookup_code    => p_rt_enrld_oipl_flag,
                              p_effective_date => p_effective_date) then
                          --
                          -- raise error as does not exist as lookup
                          --
                          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                          fnd_message.set_token('FIELD',p_rt_enrld_oipl_flag);
                          fnd_message.set_token('TYPE','YES_NO');
                          fnd_message.raise_error;
                          --
  end if;

  if hr_api.not_exists_in_hr_lookups
                             (p_lookup_type    => 'YES_NO',
                              p_lookup_code    => p_rt_enrld_pl_flag,
                              p_effective_date => p_effective_date) then
                          --
                          -- raise error as does not exist as lookup
                          --
                          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                          fnd_message.set_token('FIELD',p_rt_enrld_pl_flag);
                          fnd_message.set_token('TYPE','YES_NO');
                          fnd_message.raise_error;
                          --
  end if;

  if hr_api.not_exists_in_hr_lookups
                               (p_lookup_type    => 'YES_NO',
                                p_lookup_code    => p_rt_enrld_plip_flag,
                                p_effective_date => p_effective_date) then
                            --
                            -- raise error as does not exist as lookup
                            --
                            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                            fnd_message.set_token('FIELD',p_rt_enrld_plip_flag);
                            fnd_message.set_token('TYPE','YES_NO');
                            fnd_message.raise_error;
                            --
  end if;

  if hr_api.not_exists_in_hr_lookups
                               (p_lookup_type    => 'YES_NO',
                                p_lookup_code    => p_rt_enrld_ptip_flag,
                                p_effective_date => p_effective_date) then
                            --
                            -- raise error as does not exist as lookup
                            --
                            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                            fnd_message.set_token('FIELD',p_rt_enrld_ptip_flag);
                            fnd_message.set_token('TYPE','YES_NO');
                            fnd_message.raise_error;
                            --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                 (p_lookup_type    => 'YES_NO',
                                  p_lookup_code    => p_rt_enrld_pgm_flag,
                                  p_effective_date => p_effective_date) then
                              --
                              -- raise error as does not exist as lookup
                              --
                              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                              fnd_message.set_token('FIELD',p_rt_enrld_pgm_flag);
                              fnd_message.set_token('TYPE','YES_NO');
                              fnd_message.raise_error;
                              --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                   (p_lookup_type    => 'YES_NO',
                                    p_lookup_code    => p_rt_prtt_anthr_pl_flag,
                                    p_effective_date => p_effective_date) then
                                --
                                -- raise error as does not exist as lookup
                                --
                                fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                fnd_message.set_token('FIELD',p_rt_prtt_anthr_pl_flag);
                                fnd_message.set_token('TYPE','YES_NO');
                                fnd_message.raise_error;
                                --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                     (p_lookup_type    => 'YES_NO',
                                      p_lookup_code    => p_rt_othr_ptip_flag,
                                      p_effective_date => p_effective_date) then
                                  --
                                  -- raise error as does not exist as lookup
                                  --
                                  fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                  fnd_message.set_token('FIELD',p_rt_othr_ptip_flag);
                                  fnd_message.set_token('TYPE','YES_NO');
                                  fnd_message.raise_error;
                                  --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                     (p_lookup_type    => 'YES_NO',
                                      p_lookup_code    => p_rt_no_othr_cvg_flag,
                                      p_effective_date => p_effective_date) then
                                  --
                                  -- raise error as does not exist as lookup
                                  --
                                  fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                  fnd_message.set_token('FIELD',p_rt_no_othr_cvg_flag);
                                  fnd_message.set_token('TYPE','YES_NO');
                                  fnd_message.raise_error;
                                  --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                       (p_lookup_type    => 'YES_NO',
                                        p_lookup_code    => p_rt_dpnt_othr_ptip_flag,
                                        p_effective_date => p_effective_date) then
                                    --
                                    -- raise error as does not exist as lookup
                                    --
                                    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                    fnd_message.set_token('FIELD',p_rt_dpnt_othr_ptip_flag);
                                    fnd_message.set_token('TYPE','YES_NO');
                                    fnd_message.raise_error;
                                    --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                       (p_lookup_type    => 'YES_NO',
                                        p_lookup_code    => p_rt_qua_in_gr_flag,
                                        p_effective_date => p_effective_date) then
                                    --
                                    -- raise error as does not exist as lookup
                                    --
                                    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                    fnd_message.set_token('FIELD',p_rt_qua_in_gr_flag);
                                    fnd_message.set_token('TYPE','YES_NO');
                                    fnd_message.raise_error;
                                    --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                         (p_lookup_type    => 'YES_NO',
                                          p_lookup_code    => p_rt_perf_rtng_flag,
                                          p_effective_date => p_effective_date) then
                                      --
                                      -- raise error as does not exist as lookup
                                      --
                                      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                      fnd_message.set_token('FIELD',p_rt_perf_rtng_flag);
                                      fnd_message.set_token('TYPE','YES_NO');
                                      fnd_message.raise_error;
                                      --
  end if;

  if hr_api.not_exists_in_hr_lookups
                                         (p_lookup_type    => 'YES_NO',
                                          p_lookup_code    => p_rt_elig_prfl_flag,
                                          p_effective_date => p_effective_date) then
                                      --
                                      -- raise error as does not exist as lookup
                                      --
                                      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                                      fnd_message.set_token('FIELD',p_rt_elig_prfl_flag);
                                      fnd_message.set_token('TYPE','YES_NO');
                                      fnd_message.raise_error;
                                      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_profile_flags;
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
            (p_oipl_id                       in number default hr_api.g_number,
             p_pl_typ_opt_typ_id             in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
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
    --If ((nvl(p_pl_typ_opt_typ_id, hr_api.g_number) <> hr_api.g_number) and
      --NOT (dt_api.check_min_max_dates
      --      (p_base_table_name => 'ben_pl_typ_opt_typ_f',
      --       p_base_key_column => 'pl_typ_opt_typ_id',
      --       p_base_key_value  => p_pl_typ_opt_typ_id,
      --       p_from_date       => p_validation_start_date,
      --       p_to_date         => p_validation_end_date)))  Then
      --l_table_name := 'ben_pl_typ_opt_typ_f';
      --Raise l_integrity_error;
    --End If;
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
            (p_vrbl_rt_prfl_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
             p_name                     in varchar2,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_criteria_rows_exist EXCEPTION;
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
       p_argument       => 'vrbl_rt_prfl_id',
       p_argument_value => p_vrbl_rt_prfl_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_VRBL_RT_ELIG_PRFL_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'BEN_VRBL_RT_ELIG_PRFL_F';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_age_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_age_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_benfts_grp_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_benfts_grp_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_loa_rsn_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_loa_rsn_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_los_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_los_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_tbco_use_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_tbco_use_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pct_fl_tm_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pct_fl_tm_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_vrbl_rt_prfl_rl_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_vrbl_rt_prfl_rl_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_wk_loc_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_wk_loc_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_org_unit_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_org_unit_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_comp_lvl_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_comp_lvl_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_hrs_wkd_in_perd_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_hrs_wkd_in_perd_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_grade_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_grade_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_actl_prem_vrbl_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_actl_prem_vrbl_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_vrbl_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_vrbl_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_fl_tm_pt_tm_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_fl_tm_pt_tm_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_lgl_enty_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_lgl_enty_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_lbr_mmbr_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_lbr_mmbr_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_svc_area_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_svc_area_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_py_bss_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_py_bss_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pyrl_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pyrl_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pstl_zip_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pstl_zip_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_per_typ_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_per_typ_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_hrly_slrd_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_hrly_slrd_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_gndr_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_gndr_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cmbn_age_los_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cmbn_age_los_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_brgng_unit_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_brgng_unit_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_asnt_set_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_asnt_set_rt_f';
      Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_vrbl_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_vrbl_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ppl_grp_rt_f',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ppl_grp_rt_f';
      Raise l_criteria_rows_exist;
    End If;

    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_CBR_QUALD_BNF_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_cbr_quald_bnf_rt_f';
        Raise l_criteria_rows_exist;
    End If;

    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_CNTNG_PRTN_PRFL_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_cntng_prtn_prfl_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_COMPTNCY_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_comptncy_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_JOB_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_job_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_LVG_RSN_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_lvg_rsn_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_OPTD_MDCR_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_optd_mdcr_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_PSTN_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_pstn_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_DPNT_CVRD_OTHR_PGM_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_dpnt_cvrd_othr_pgm_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_DPNT_CVRD_OTHR_PL_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_dpnt_cvrd_othr_pl_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_DPNT_CVRD_OTHR_PTIP_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_dpnt_cvrd_othr_ptip_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_DPNT_CVRD_PLIP_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_dpnt_cvrd_othr_plip_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_DPNT_OTHR_PTIP_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_dpnt_othr_ptip_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
              (p_base_table_name => 'BEN_QUA_IN_GR_RT_F',
               p_base_key_column => 'vrbl_rt_prfl_id',
               p_base_key_value  => p_vrbl_rt_prfl_id,
               p_from_date       => p_validation_start_date,
               p_to_date         => p_validation_end_date)) Then
            l_table_name := 'ben_qua_in_gr_rt_f';
            Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
              (p_base_table_name => 'BEN_PERF_RTNG_RT_F',
               p_base_key_column => 'vrbl_rt_prfl_id',
               p_base_key_value  => p_vrbl_rt_prfl_id,
               p_from_date       => p_validation_start_date,
               p_to_date         => p_validation_end_date)) Then
            l_table_name := 'ben_perf_rtng_rt_f';
            Raise l_criteria_rows_exist;
    End If;

    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_ENRLD_ANTHR_OIPL_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_enrld_anthr_oipl_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_ENRLD_ANTHR_PGM_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_enrld_anthr_pgm_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_ENRLD_ANTHR_PLIP_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_enrld_anthr_plip_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_ENRLD_ANTHR_PL_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_enrld_anthr_pl_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_ENRLD_ANTHR_PTIP_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_enrld_anthr_ptip_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_NO_OTHR_CVG_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_no_othr_cvg_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_OTHR_PTIP_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_othr_ptip_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_PRTT_ANTHR_PL_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_prtt_anthr_pl_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'BEN_QUAL_TITL_RT_F',
           p_base_key_column => 'vrbl_rt_prfl_id',
           p_base_key_value  => p_vrbl_rt_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_qual_titl_rt_f';
        Raise l_criteria_rows_exist;
    End If;
    --
    --
    --Bug : 3476138
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_bnft_vrbl_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_bnft_vrbl_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_acty_vrbl_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_acty_vrbl_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_actl_prem_vrbl_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_actl_prem_vrbl_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_vrbl_rt_elig_prfl_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_vrbl_rt_elig_prfl_f';
        Raise l_rows_exist;
    End If;
    --
    --Bug : 3476138
    --
    --
    --Bug : 6123832
    --
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_dsbld_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_dsbld_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_ee_stat_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_ee_stat_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
     If (dt_api.rows_exist
	 (p_base_table_name => 'ben_poe_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_poe_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
    If (dt_api.rows_exist
	 (p_base_table_name => 'ben_schedd_hrs_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_schedd_hrs_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
    If (dt_api.rows_exist
	 (p_base_table_name => 'ben_ttl_cvg_vol_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_ttl_cvg_vol_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
    If (dt_api.rows_exist
	 (p_base_table_name => 'ben_ttl_prtt_rt_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_ttl_prtt_rt_f';
        Raise l_rows_exist;
    End If;
    --
    --
    If (dt_api.rows_exist
	 (p_base_table_name => 'ben_vrbl_rt_prfl_rl_f',
	  p_base_key_column => 'vrbl_rt_prfl_id',
	  p_base_key_value  => p_vrbl_rt_prfl_id,
	  p_from_date       => p_validation_start_date,
	  p_to_date         => p_validation_end_date)) Then
        l_table_name := 'ben_vrbl_rt_prfl_rl_f';
        Raise l_rows_exist;
    End If;
    --
    --Bug : 6123832
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_criteria_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.child_exists_error(p_table_name               => 'BEN_VRBL_RT_PRFL_CRITERIA',
                                   p_parent_table_name        => 'BEN_VRBL_RT_PRFL_F',
                                   p_parent_entity_name       => p_name);
    --
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.child_exists_error(p_table_name               => l_table_name,
                                   p_parent_table_name        => 'BEN_VRBL_RT_PRFL_F',
                                   p_parent_entity_name       => p_name);
    --
  When Others Then
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
-- |------< chk_mlt_cd_dependencies >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
--
--
-- In Parameters
--	 mlt_cd
--	 val
--	 mn_elcn_val
--	 mx_elcn_val
--	 incrmnt_elcn_val
--	.dflt_elcn_val
--	 rt_typ_cd
--       bnft_rt_typ_cd
--       val_calc_rl
--       vrbl_rt_prfl_id
--       effective_date
--	 object_version_number
--
--
Procedure chk_mlt_cd_dependencies(p_mlt_cd                      in varchar2,
                                  p_val                         in number,
                                  p_mn_elcn_val                 in number,
                                  p_mx_elcn_val                 in number,
                                  p_incrmnt_elcn_val            in number,
--Bug: 	4237447
				  p_dflt_elcn_val in number,
--End Bug:	4237447
                                  p_rt_typ_cd                   in varchar2,
	                          p_bnft_rt_typ_cd              in varchar2,
		                  p_val_calc_rl                 in number,
                        -- note the following is temporarily being used for
                        -- enter value at enrollment flag.  It should be renamed.
                          p_no_mn_elcn_val_dfnd_flag    in varchar2,
                              p_comp_lvl_fctr_id        in number,
				  p_vrbl_rt_prfl_id             in number,
				  p_effective_date              in date,
				  p_object_version_number       in number
                                 ) is
  --
  l_proc  varchar2(72) := g_package||'chk_mlt_cd_dependencies';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_vpf_shd.api_updating
     (p_vrbl_rt_prfl_id       => p_vrbl_rt_prfl_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_mlt_cd,hr_api.g_varchar2)
               <> nvl(ben_vpf_shd.g_old_rec.mlt_cd,hr_api.g_varchar2) or
          nvl(p_val,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.val,hr_api.g_number) or
          nvl(p_mn_elcn_val,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.mn_elcn_val,hr_api.g_number) or
          nvl(p_mx_elcn_val,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.mx_elcn_val,hr_api.g_number) or
          nvl(p_incrmnt_elcn_val,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.incrmnt_elcn_val,hr_api.g_number) or
--Bug : 	4237447
	  nvl(p_dflt_elcn_val,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.dflt_elcn_val,hr_api.g_number) or
-- End Bug:	4237447
          nvl(p_rt_typ_cd,hr_api.g_varchar2)
               <> nvl(ben_vpf_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2) or
          nvl(p_bnft_rt_typ_cd,hr_api.g_varchar2)
               <> nvl(ben_vpf_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2) or
          nvl(p_val_calc_rl,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.val_calc_rl,hr_api.g_number) or
          nvl(p_comp_lvl_fctr_id        ,hr_api.g_number)
               <> nvl(ben_vpf_shd.g_old_rec.comp_lvl_fctr_id,hr_api.g_number) or
          nvl(p_no_mn_elcn_val_dfnd_flag,hr_api.g_varchar2)
               <> nvl(ben_vpf_shd.g_old_rec.no_mn_elcn_val_dfnd_flag,hr_api.g_varchar2)
         ))
      or
         not l_api_updating then
	  --
	  if p_mlt_cd is NULL then
	  --
	      fnd_message.set_name('BEN','BEN_91535_MLT_CD_RQD');
	      fnd_message.raise_error;
	  --
	  end if;
	  --
     -- the following is just not true.  you can't have a value
     -- for enter value at enrollment.
	  if p_val is NULL then
	  --

	     if p_mlt_cd in ('FLFX','FLFXPCL','CL','AP','CVG','CLANDCVG','APANDCVG')
               and p_no_mn_elcn_val_dfnd_flag = 'N' then
	     --
	        fnd_message.set_name('BEN','BEN_91536_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --

	  if p_mn_elcn_val is NULL then
	  --
	     if (p_mlt_cd in ('FLFX','CL','CVG','CLANDCVG')
               and p_no_mn_elcn_val_dfnd_flag = 'Y')
               or p_mlt_cd = 'FLFXPCL' then
		 --
	        fnd_message.set_name('BEN','BEN_91538_MIN_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_mx_elcn_val is NULL then
	  --
	     if p_mlt_cd in ('FLFX','CL','CVG','CLANDCVG')
               and p_no_mn_elcn_val_dfnd_flag = 'Y' then
	     --
	        fnd_message.set_name('BEN','BEN_91540_MAX_VAL_REQ');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_incrmnt_elcn_val is NULL then
	  --
	     if p_mlt_cd in ('FLFX','CL','CVG','CLANDCVG')
               and p_no_mn_elcn_val_dfnd_flag = 'Y' then
		   --
	          fnd_message.set_name('BEN','BEN_91542_INCRMT_VAL_RQD');
	          fnd_message.raise_error;
	     --
	     end if;
	  end if;
-- Bug:	4237447
	 if p_dflt_elcn_val is not NULL then
	 	 if p_mlt_cd in ('FLFX','CL','CVG','CLANDCVG')  and p_no_mn_elcn_val_dfnd_flag = 'Y' and  (p_dflt_elcn_val < p_mn_elcn_val or p_dflt_elcn_val > p_mx_elcn_val) then
	        fnd_message.set_name('PAY','HR_INPVAL_DEFAULT_INVALID');
                 fnd_message.raise_error;
	     end if;
	end if;
--End Bug: 	4237447
	  if p_rt_typ_cd is NULL then
	  --
	     if p_mlt_cd in ('CL','AP','CLANDCVG','APANDCVG','FLFXPCL') then
		   --
	          fnd_message.set_name('BEN','BEN_91544_RT_TYP_CD_RQD');
	          fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_bnft_rt_typ_cd is NULL then
	  --
	     if p_mlt_cd in ('CVG','CLANDCVG','APANDCVG') then
	     --
	        fnd_message.set_name('BEN','BEN_91546_BNFTS_TYP_CD_RQD');
	        fnd_message.raise_error;
	     --
	    end if;
	   --
	  --
	  end if;
        --
	  if p_comp_lvl_fctr_id is NULL then
	  --
	     if p_mlt_cd in ('CL','CLANDCVG','FLFXPCL') then
	     --
	        fnd_message.set_name('BEN','BEN_92472_COMP_FCTR_RQD');
	        fnd_message.raise_error;
	     --
	    end if;
	   --
	  --
	  end if;
	  --
	  if p_val_calc_rl is NULL then
	  --
	     if p_mlt_cd in ('RL') then
	     --
	        fnd_message.set_name('BEN','BEN_91548_VAL_CALC_RL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_mlt_cd not in ('RL')
	     then
		 --
	        fnd_message.set_name('BEN','BEN_91549_VAL_CALC_RL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  end if;
  --
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mlt_cd_dependencies;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_vpf_shd.g_rec_type,
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
  chk_vrbl_rt_prfl_id
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_name                  => p_rec.name,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_mn_mx_elcn_vals
  (p_mn_elcn_val  => p_rec.mn_elcn_val,
   p_mx_elcn_val  => p_rec.mx_elcn_val);
  --
  chk_lwr_upr_lmt_vals
  (p_lwr_lmt_val  => p_rec.lwr_lmt_val,
   p_upr_lmt_val  => p_rec.upr_lmt_val);
  --
  chk_ultmt_lwr_upr_lmt
  (p_ultmt_lwr_lmt  => p_rec.ultmt_lwr_lmt,
   p_ultmt_upr_lmt  => p_rec.ultmt_upr_lmt);
  --
  chk_lwr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_lwr_lmt_val                   => p_rec.lwr_lmt_val,
   p_lwr_lmt_calc_rl               => p_rec.lwr_lmt_calc_rl);
   --
  chk_ultmt_lwr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_ultmt_lwr_lmt                 => p_rec.ultmt_lwr_lmt,
   p_ultmt_lwr_lmt_calc_rl         => p_rec.ultmt_lwr_lmt_calc_rl);
   --
  chk_upr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_upr_lmt_val                   => p_rec.upr_lmt_val,
   p_upr_lmt_calc_rl               => p_rec.upr_lmt_calc_rl);
   --
  chk_ultmt_upr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_ultmt_upr_lmt                 => p_rec.ultmt_upr_lmt,
   p_ultmt_upr_lmt_calc_rl         => p_rec.ultmt_upr_lmt_calc_rl);
   --

  chk_vrbl_rt_prfl_stat_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_vrbl_rt_prfl_stat_cd  => p_rec.vrbl_rt_prfl_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_val_calc_rl           => p_rec.val_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_lwr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_lwr_lmt_calc_rl       => p_rec.lwr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_upr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_upr_lmt_calc_rl       => p_rec.upr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_ultmt_lwr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_ultmt_lwr_lmt_calc_rl => p_rec.ultmt_lwr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ultmt_upr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_ultmt_upr_lmt_calc_rl => p_rec.ultmt_upr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_elcn_val_dfnd_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_no_mx_elcn_val_dfnd_flag => p_rec.no_mx_elcn_val_dfnd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_elcn_val_dfnd_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_no_mn_elcn_val_dfnd_flag => p_rec.no_mn_elcn_val_dfnd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_alwys_sum_all_cvg_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_alwys_cnt_all_prtts_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_mlt_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_mlt_cd                => p_rec.mlt_cd,
   p_vrbl_usg_cd           => p_rec.vrbl_usg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrbl_usg_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_vrbl_usg_cd           => p_rec.vrbl_usg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_asmt_to_use_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_asmt_to_use_cd        => p_rec.asmt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_rndg_cd               => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd_rl
  (p_rndg_cd               => p_rec.rndg_cd,
   p_rndg_rl               => p_rec.rndg_rl);
  --
  chk_acty_ref_perd_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_acty_ref_perd_cd      => p_rec.acty_ref_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ref_perd_usg_cd
  (p_acty_ref_perd_cd      => p_rec.acty_ref_perd_cd,
   p_vrbl_usg_cd           => p_rec.vrbl_usg_cd);
  --
  chk_val_othr_val
  (p_val                   => p_rec.val,
   p_mn_elcn_val           => p_rec.mn_elcn_val,
   p_mx_elcn_val           => p_rec.mx_elcn_val,
   p_incrmnt_elcn_val      => p_rec.incrmnt_elcn_val,
   p_dflt_elcn_val         => p_rec.dflt_elcn_val,
   p_mlt_cd                => p_rec.mlt_cd);
  --
  chk_vrbl_rt_trtmt_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_vrbl_rt_trtmt_cd      => p_rec.vrbl_rt_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tx_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_tx_typ_cd             => p_rec.tx_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_rt_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_bnft_rt_typ_cd        => p_rec.bnft_rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_rt_typ_cd             => p_rec.rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_acty_typ_cd           => p_rec.acty_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mlt_cd_dependencies
     (p_mlt_cd                 => p_rec.mlt_cd,
      p_val                    => p_rec.val,
      p_mn_elcn_val            => p_rec.mn_elcn_val,
      p_mx_elcn_val            => p_rec.mx_elcn_val,
      p_incrmnt_elcn_val       => p_rec.incrmnt_elcn_val,
--Bug : 	4237447
      p_dflt_elcn_val		=> p_rec.dflt_elcn_val,
--End Bug: 	4237447
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_no_mn_elcn_val_dfnd_flag  => p_rec.no_mn_elcn_val_dfnd_flag,
      p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
      p_vrbl_rt_prfl_id        => p_rec.vrbl_rt_prfl_id,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );
  -- Bug : 3456400
  if p_rec.rt_elig_prfl_flag = 'Y' then
  --
    chk_elig_alwys_cnt_all_prtt_df
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
        p_effective_date           => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
    chk_elig_alwys_sum_all_cvg_def
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag,
        p_effective_date            => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
  else
  --
    chk_alwys_cnt_all_prtts_def
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
        p_effective_date           => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
    --
    chk_alwys_sum_all_cvg_def
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag,
        p_effective_date            => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
  end if;
--
  chk_usg_acty_tx_for_prem
     (p_vrbl_usg_cd              => p_rec.vrbl_usg_cd,
      p_acty_typ_cd              => p_rec.acty_typ_cd,
      p_tx_typ_cd                => p_rec.tx_typ_cd);
--
  chk_alwys_flag_one_def
     (p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
      p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag);

---- Updated for bug 2529689
  IF (p_rec.vrbl_usg_cd = 'ACP' ) THEN
  -- Bug : 3456400
      if p_rec.rt_elig_prfl_flag = 'Y' then
      --
	 chk_elig_ttlprtt_mtl_cd
          (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
          p_mlt_cd                   => p_rec.mlt_cd,
          p_effective_date            => p_effective_date,
          p_business_group_id        => p_rec.business_group_id);
      --
      else
      --
         chk_ttlprtt_mtl_cd
          (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
          p_mlt_cd                   => p_rec.mlt_cd,
          p_effective_date            => p_effective_date,
          p_business_group_id        => p_rec.business_group_id);
      --
      end if;
  --
  END IF;
--

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_vpf_shd.g_rec_type,
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
  chk_vrbl_rt_prfl_id
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_name                  => p_rec.name,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_mn_mx_elcn_vals
  (p_mn_elcn_val  => p_rec.mn_elcn_val,
   p_mx_elcn_val  => p_rec.mx_elcn_val);
  --
  chk_lwr_upr_lmt_vals
  (p_lwr_lmt_val  => p_rec.lwr_lmt_val,
   p_upr_lmt_val  => p_rec.upr_lmt_val);
  --
  chk_ultmt_lwr_upr_lmt
  (p_ultmt_lwr_lmt  => p_rec.ultmt_lwr_lmt,
   p_ultmt_upr_lmt  => p_rec.ultmt_upr_lmt);
  --
  chk_lwr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_lwr_lmt_val                   => p_rec.lwr_lmt_val,
   p_lwr_lmt_calc_rl               => p_rec.lwr_lmt_calc_rl);
   --
  chk_ultmt_lwr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_ultmt_lwr_lmt                 => p_rec.ultmt_lwr_lmt,
   p_ultmt_lwr_lmt_calc_rl         => p_rec.ultmt_lwr_lmt_calc_rl);
   --
  chk_ultmt_upr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_ultmt_upr_lmt                 => p_rec.ultmt_upr_lmt,
   p_ultmt_upr_lmt_calc_rl         => p_rec.ultmt_upr_lmt_calc_rl);
   --

  chk_upr_lmt_val_and_rl
  (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
   p_upr_lmt_val                   => p_rec.upr_lmt_val,
   p_upr_lmt_calc_rl               => p_rec.upr_lmt_calc_rl);
   --
  chk_vrbl_rt_prfl_stat_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_vrbl_rt_prfl_stat_cd  => p_rec.vrbl_rt_prfl_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_val_calc_rl           => p_rec.val_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_lwr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_lwr_lmt_calc_rl       => p_rec.lwr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_upr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_upr_lmt_calc_rl       => p_rec.upr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ultmt_lwr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_ultmt_lwr_lmt_calc_rl => p_rec.ultmt_lwr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ultmt_upr_lmt_calc_rl
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_ultmt_upr_lmt_calc_rl => p_rec.ultmt_upr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_no_mx_elcn_val_dfnd_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_no_mx_elcn_val_dfnd_flag => p_rec.no_mx_elcn_val_dfnd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_no_mn_elcn_val_dfnd_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_no_mn_elcn_val_dfnd_flag => p_rec.no_mn_elcn_val_dfnd_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_alwys_sum_all_cvg_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_alwys_cnt_all_prtts_flag
  (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_mlt_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_mlt_cd                => p_rec.mlt_cd,
   p_vrbl_usg_cd           => p_rec.vrbl_usg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrbl_usg_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_vrbl_usg_cd           => p_rec.vrbl_usg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_asmt_to_use_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_asmt_to_use_cd        => p_rec.asmt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_rndg_cd               => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd_rl
  (p_rndg_cd               => p_rec.rndg_cd,
   p_rndg_rl               => p_rec.rndg_rl);
  --
  chk_acty_ref_perd_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_acty_ref_perd_cd      => p_rec.acty_ref_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ref_perd_usg_cd
  (p_acty_ref_perd_cd      => p_rec.acty_ref_perd_cd,
   p_vrbl_usg_cd           => p_rec.vrbl_usg_cd);
  --
  chk_val_othr_val
  (p_val                   => p_rec.val,
   p_mn_elcn_val           => p_rec.mn_elcn_val,
   p_mx_elcn_val           => p_rec.mx_elcn_val,
   p_incrmnt_elcn_val      => p_rec.incrmnt_elcn_val,
   p_dflt_elcn_val         => p_rec.dflt_elcn_val,
   p_mlt_cd                => p_rec.mlt_cd);
  --
  chk_vrbl_rt_trtmt_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_vrbl_rt_trtmt_cd      => p_rec.vrbl_rt_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tx_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_tx_typ_cd             => p_rec.tx_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_rt_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_bnft_rt_typ_cd        => p_rec.bnft_rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_rt_typ_cd             => p_rec.rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_typ_cd
  (p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
   p_acty_typ_cd           => p_rec.acty_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Bug : 3456400
  if p_rec.rt_elig_prfl_flag = 'Y' then
  --
    chk_elig_alwys_cnt_all_prtt_df
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
        p_effective_date           => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
    chk_elig_alwys_sum_all_cvg_def
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag,
        p_effective_date            => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
  else
  --
    chk_alwys_cnt_all_prtts_def
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
        p_effective_date           => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
    chk_alwys_sum_all_cvg_def
       (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
        p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag,
        p_effective_date            => p_effective_date,
        p_business_group_id        => p_rec.business_group_id);
  --
  end if;
--
  chk_usg_acty_tx_for_prem
     (p_vrbl_usg_cd              => p_rec.vrbl_usg_cd,
      p_acty_typ_cd              => p_rec.acty_typ_cd,
      p_tx_typ_cd                => p_rec.tx_typ_cd);
--
  chk_alwys_flag_one_def
     (p_alwys_cnt_all_prtts_flag => p_rec.alwys_cnt_all_prtts_flag,
      p_alwys_sum_all_cvg_flag   => p_rec.alwys_sum_all_cvg_flag);
--
  -- Updated for bug 2529689
  IF (p_rec.vrbl_usg_cd = 'ACP' ) THEN
      if p_rec.rt_elig_prfl_flag = 'Y' then
      --
	 chk_elig_ttlprtt_mtl_cd
          (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
          p_mlt_cd                   => p_rec.mlt_cd,
          p_effective_date            => p_effective_date,
          p_business_group_id        => p_rec.business_group_id);
      --
      else
      --
         chk_ttlprtt_mtl_cd
          (p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
          p_mlt_cd                   => p_rec.mlt_cd,
          p_effective_date            => p_effective_date,
          p_business_group_id        => p_rec.business_group_id);
      --
      end if;
  --
  END IF;
--
  chk_mlt_cd_dependencies
     (p_mlt_cd                 => p_rec.mlt_cd,
      p_val                    => p_rec.val,
      p_mn_elcn_val            => p_rec.mn_elcn_val,
      p_mx_elcn_val            => p_rec.mx_elcn_val,
      p_incrmnt_elcn_val       => p_rec.incrmnt_elcn_val,
--Bug : 	4237447
       p_dflt_elcn_val		=> p_rec.dflt_elcn_val,
--End Bug:	4237447
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_no_mn_elcn_val_dfnd_flag  => p_rec.no_mn_elcn_val_dfnd_flag,
      p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
      p_vrbl_rt_prfl_id        => p_rec.vrbl_rt_prfl_id,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );
--
--Bug : 3476138
chk_vrbl_usg_cd_dependencies
			(p_vrbl_rt_prfl_id    =>      p_rec.vrbl_rt_prfl_id,
                         p_validation_start_date    =>      p_validation_start_date,
                         p_validation_end_date     =>      p_validation_end_date,
                         p_vrbl_usg_cd     =>      p_rec.vrbl_usg_cd,
			 p_effective_date   =>    p_effective_date,
                         p_object_version_number     =>      p_rec.object_version_number  );
--Bug : 3476138
--
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_oipl_id                       => p_rec.oipl_id,
     p_pl_typ_opt_typ_id             => p_rec.pl_typ_opt_typ_id,
     p_pl_id                         => p_rec.pl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_vpf_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
   --
   CURSOR c_vpf_name
   IS
      SELECT vpf.NAME
        FROM ben_vrbl_rt_prfl_f vpf
       WHERE vpf.vrbl_rt_prfl_id = p_rec.vrbl_rt_prfl_id
         AND p_effective_date BETWEEN vpf.effective_start_date
                                  AND vpf.effective_end_date;
   --
   l_vpf_name      ben_vrbl_rt_prfl_f.name%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN c_vpf_name;
    --
    FETCH c_vpf_name INTO l_vpf_name;
    --
  CLOSE c_vpf_name;
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_name                     => l_vpf_name,
     p_vrbl_rt_prfl_id		=> p_rec.vrbl_rt_prfl_id);
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
  (p_vrbl_rt_prfl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_vrbl_rt_prfl_f b
    where b.vrbl_rt_prfl_id   = p_vrbl_rt_prfl_id
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
                             p_argument       => 'vrbl_rt_prfl_id',
                             p_argument_value => p_vrbl_rt_prfl_id);
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
end ben_vpf_bus;

/
