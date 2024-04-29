--------------------------------------------------------
--  DDL for Package Body BEN_PPV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPV_BUS" as
/* $Header: beppvrhi.pkb 120.5.12010000.2 2008/08/05 15:17:18 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppv_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtl_mo_rt_prtn_val_id >------|
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
--   prtl_mo_rt_prtn_val_id PK of record being inserted or updated.
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
Procedure chk_prtl_mo_rt_prtn_val_id(p_prtl_mo_rt_prtn_val_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtl_mo_rt_prtn_val_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppv_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prtl_mo_rt_prtn_val_id                => p_prtl_mo_rt_prtn_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtl_mo_rt_prtn_val_id,hr_api.g_number)
     <>  ben_ppv_shd.g_old_rec.prtl_mo_rt_prtn_val_id) then
    --
    -- raise error as PK has changed
    --
    ben_ppv_shd.constraint_error('BEN_PRTL_MO_RT_PRTN_VAL_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtl_mo_rt_prtn_val_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ppv_shd.constraint_error('BEN_PRTL_MO_RT_PRTN_VAL_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prtl_mo_rt_prtn_val_id;
--
procedure chk_dup_prorate_by_day_row(p_effective_date in date,
                                     p_acty_base_rt_id in number,
                                     p_mode in varchar2,
                                     p_prtl_mo_rt_prtn_val_id in number default null)
  is
--
  cursor c1 is
    select null
    from ben_prtl_mo_rt_prtn_val_f ppv
    where ppv.PRORATE_BY_DAY_TO_MON_FLAG = 'Y'
    and   ppv.acty_base_rt_id = p_acty_base_rt_id
    and   p_effective_date between ppv.effective_start_date
          and ppv.effective_end_date;
  --
  cursor c2 is
     select null
     from ben_prtl_mo_rt_prtn_val_f ppv
     where ppv.PRORATE_BY_DAY_TO_MON_FLAG = 'Y'
     and   ppv.acty_base_rt_id = p_acty_base_rt_id
     and   ppv.prtl_mo_rt_prtn_val_id <> p_prtl_mo_rt_prtn_val_id
     and   p_effective_date between ppv.effective_start_date
          and ppv.effective_end_date;
  --
  l_dummy  varchar2(30);

begin
  --
  if p_mode = 'Insert' then
    open c1;
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      --
      fnd_message.set_name('BEN','BEN_94261_PPV_DUP');
      fnd_message.raise_error;
      --
    else
      --
      close c1;
      --
    end if;
  elsif p_mode = 'Update' then
    --
    open c2;
    fetch c2 into l_dummy;
    if c2%found then
      --
      close c2;
      --
      fnd_message.set_name('BEN','BEN_94261_PPV_DUP');
      fnd_message.raise_error;
      --
    else
      --
      close c2;
      --
    end if;
  end if;
  --
end;


-- ----------------------------------------------------------------------------
-- |------< chk_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtl_mo_rt_prtn_val_id PK of record being inserted or updated.
--   rndg_cd Value of lookup code.
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
Procedure chk_rndg_cd(p_prtl_mo_rt_prtn_val_id                in number,
                            p_rndg_cd               in varchar2,
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
  l_api_updating := ben_ppv_shd.api_updating
    (p_prtl_mo_rt_prtn_val_id                => p_prtl_mo_rt_prtn_val_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_ppv_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message('BEN','BEN_91041_INVALID_RNDG_CD');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtl_mo_prortn_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtl_mo_rt_prtn_val_id PK of record being inserted or updated.
--   prtl_mo_prortn_rl Value of formula rule id.
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
Procedure chk_prtl_mo_prortn_rl(p_prtl_mo_rt_prtn_val_id      in number,
                                p_business_group_id           in number,
                                p_prtl_mo_prortn_rl           in number,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtl_mo_prortn_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_prtl_mo_prortn_rl
    and    ff.formula_type_id = -528
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
  l_api_updating := ben_ppv_shd.api_updating
    (p_prtl_mo_rt_prtn_val_id      => p_prtl_mo_rt_prtn_val_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtl_mo_prortn_rl,hr_api.g_number)
      <> ben_ppv_shd.g_old_rec.prtl_mo_prortn_rl
      or not l_api_updating)
      and p_prtl_mo_prortn_rl is not null then
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
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_prtl_mo_prortn_rl);
        fnd_message.set_token('TYPE_ID',-528);
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
end chk_prtl_mo_prortn_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtl_mo_rt_prtn_val_id PK of record being inserted or updated.
--   rndg_rl Value of formula rule id.
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
Procedure chk_rndg_rl(p_prtl_mo_rt_prtn_val_id                in number,
                             p_rndg_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
    where  ff.formula_id = p_rndg_rl
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppv_shd.api_updating
    (p_prtl_mo_rt_prtn_val_id                => p_prtl_mo_rt_prtn_val_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_ppv_shd.g_old_rec.rndg_rl
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
    -- Unless Rounding Code = Rule, Rounding rule must be blank.
--  if  nvl(p_rndg_cd,hr_api.g_varchar2)  <> 'RL' and p_rndg_rl is not null then
      --
--      fnd_message.set_name('BEN', 'BEN_91043_RNDG_RL_NOT_NULL');
--      fnd_message.raise_error;
      --
--    elsif nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
      --
--      fnd_message.set_name('BEN', 'BEN_92340_RNDG_RL_NULL');
--      fnd_message.raise_error;
      --
--    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_rndg_cd_rl >-------------------------------|
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
--   rndg_cd        Value of look up value.
--   rndg_rl        value of look up Value
--                  inserted or updated.
--
-- Post Success
--   Processing continues
--
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_rndg_cd_rl(p_rndg_cd      in varchar2,
                         p_rndg_rl      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if    (p_rndg_cd <> 'RL' and p_rndg_rl is not null)
  then
                fnd_message.set_name('BEN', 'BEN_91043_RNDG_RL_NOT_NULL');
                fnd_message.raise_error;
  end if;

  if (p_rndg_cd = 'RL' and p_rndg_rl is null)
  then
                fnd_message.set_name('BEN', 'BEN_92340_RNDG_RL_NULL');
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
-- |------< chk_strt_r_stp_cvg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtl_mo_rt_prtn_val_id PK of record being inserted or updated.
--   strt_r_stp_cvg_cd Value of lookup code.
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
Procedure chk_strt_r_stp_cvg_cd(p_prtl_mo_rt_prtn_val_id                in number,
                            p_strt_r_stp_cvg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_strt_r_stp_cvg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppv_shd.api_updating
    (p_prtl_mo_rt_prtn_val_id      => p_prtl_mo_rt_prtn_val_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_strt_r_stp_cvg_cd
      <> nvl(ben_ppv_shd.g_old_rec.strt_r_stp_cvg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_strt_r_stp_cvg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STRT_R_STP_CVG',
           p_lookup_code    => p_strt_r_stp_cvg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_92183_INL_SRT_R_ST_CVG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_strt_r_stp_cvg_cd;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_prortn_rl_pct_val >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the prtl_mo_prortn_rl and pct_val
--   If Rule is not null then val must not be null.
--   If Rule is null then val must be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_prtl_mo_prortn_rl
--   pct_val
--
-- Post Success
--   Processing continues
--
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_prortn_rl_pct_val (p_prtl_mo_prortn_rl          in number,
                                 p_pct_val                    in number,
                                 p_prorate_by_day_to_mon_flag in varchar2,
				 p_prtl_mo_rt_prtn_val_id     in number,
				 p_acty_base_rt_id            in  number,
				 p_actl_prem_id               in number,
                                 p_business_group_id          in  number,
             	                 p_validation_start_date      in  date,
                                 p_validation_end_date        in  date) is
  --
  l_proc         varchar2(72) := g_package||'chk_prortn_rl_pct_val' ;
  l_dummy        varchar2(10);
  --
  -- Bug No 4418762 Added cursor to ensure no overlap of
  -- prorate on day/month basis and percent/rule defined
  --
  cursor chk_overlap is
             select 'Y'
             from   ben_prtl_mo_rt_prtn_val_f
             Where  prtl_mo_rt_prtn_val_id <> nvl(p_prtl_mo_rt_prtn_val_id,-1)
             and    (acty_base_rt_id = p_acty_base_rt_id  or
                     actl_prem_id = p_actl_prem_id)   -- Bug 4440097
	     and    prorate_by_day_to_mon_flag = 'Y'
 --Bug 6242951
      /*     and    p_validation_start_date <= effective_end_date
             and    p_validation_end_date >= effective_start_date
       */
       	     and    not ((p_validation_end_date < effective_start_date)
	            or (p_validation_start_date > effective_end_date))
 --Bug 6242951
             and    business_group_id = p_business_group_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug No 4419185
  --
  if (p_pct_val <0 or p_pct_val > 100) then
                fnd_message.set_name('BEN', 'BEN_94263_INVALID_PCT_VAL');
                fnd_message.raise_error;
  end if;
  --
  if (p_prtl_mo_prortn_rl is not null and p_pct_val is not null
      and p_prorate_by_day_to_mon_flag = 'N')
  then
                fnd_message.set_name('BEN', 'BEN_92267_PRORTN_RL_PCT_VAL1');
                fnd_message.raise_error;
  end if;
  --
  if (p_prtl_mo_prortn_rl is null and p_pct_val is null and
       p_prorate_by_day_to_mon_flag = 'N')  then
                fnd_message.set_name('BEN', 'BEN_92268_PRORTN_RL_PCT_VAL2');
                fnd_message.raise_error;
  end if;
 --
 -- Bug No 4418762
 --
 if (p_prtl_mo_prortn_rl is not null or p_pct_val is not null)  then
     open chk_overlap;
     fetch chk_overlap into l_dummy;
     if chk_overlap%FOUND then
                fnd_message.set_name('BEN', 'BEN_94262_PRORATE_FLAG_PCT_VAL');
                fnd_message.raise_error;
     end if;
     close chk_overlap;
  end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prortn_rl_pct_val ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_from_dt_to_dy >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the min value is
--   less than the max value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_from_dy_mo_num  minimum value
--   p_to_dy_mo_num    maximum value
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
Procedure chk_from_dt_to_dy(p_from_dy_mo_num  in number,
                            p_to_dy_mo_num    in number) is
  --
  l_proc varchar2(72) := g_package||'chk_from_dt_to_dy';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check the values
  -- note: Don't want an error if either one is null
  --
  if p_from_dy_mo_num is not null and p_to_dy_mo_num is not null
     and (p_from_dy_mo_num > p_to_dy_mo_num) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_92269_MIN_LESS_NOT_EQ_MAX');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_from_dt_to_dy;
--
-- ---------------------------------------------------------------------------
-- |-------------< chk_unique_and_not_overlapping >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the combination of Start or Stop Code, From Day of Month,
--   and To Day of Month fields are unique and that the From Day
--   of Month and To Day of Month fields do not overlap
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_prtl_mo_rt_prtn_val_id is primary key
--     p_from_dy_mo_num         From Day of Month
--     p_to_dy_mo_num           To Day of Month
--     p_strt_r_stp_cvg_cd      Start or Stop Code
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
Procedure chk_unique_and_not_overlapping
          ( p_prtl_mo_rt_prtn_val_id      in  number
           ,p_acty_base_rt_id             in  number
           ,p_from_dy_mo_num              in  number
           ,p_to_dy_mo_num                in  number
           ,p_strt_r_stp_cvg_cd           in  varchar2
	   ,p_num_days_month              in  number     -- Bug No 4366086
           ,p_business_group_id           in  number
           ,p_effective_date              in  date
	   ,p_validation_start_date       in  date
           ,p_validation_end_date         in  date)
is
--
l_proc           varchar2(72) := g_package||'chk_unique_and_not_overlapping';
l_from_day       number(2);
l_to_day         number(2);
l_strt_r_stp_cd  varchar2(5);
--
cursor c1 is select from_dy_mo_num, to_dy_mo_num
             from   ben_prtl_mo_rt_prtn_val_f
             Where  prtl_mo_rt_prtn_val_id <> nvl(p_prtl_mo_rt_prtn_val_id,-1)
             and    acty_base_rt_id = p_acty_base_rt_id
             and    strt_r_stp_cvg_cd = p_strt_r_stp_cvg_cd
	     and    num_days_month = p_num_days_month           -- Bug No 4366086
        --     and    p_effective_date between effective_start_date
        --            and effective_end_date
 	     and p_validation_start_date <= effective_end_date
             and p_validation_end_date >= effective_start_date
             and    business_group_id = p_business_group_id;
--
cursor c2 is select strt_r_stp_cvg_cd
             from   ben_prtl_mo_rt_prtn_val_f
             Where  prtl_mo_rt_prtn_val_id <> nvl(p_prtl_mo_rt_prtn_val_id,-1)
             and    acty_base_rt_id = p_acty_base_rt_id
             and    num_days_month = p_num_days_month           -- Bug No 4366086
         --    and    p_effective_date between effective_start_date
         --           and effective_end_date
    	     and p_validation_start_date <= effective_end_date
             and p_validation_end_date >= effective_start_date
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 4366086 Added if condition to check that to_dy_mo_num
  -- field is not greater than num_day_month
  --
  if (p_to_dy_mo_num > p_num_days_month) then
     --
     fnd_message.set_name('BEN','BEN_94247_INVALID_TO_DATE');
     fnd_message.raise_error;
     --
  end if;
  --
  open c1;
  fetch c1 into l_from_day, l_to_day;
  if c1%found then
      close c1;
      -- Bug 4366086 : Handled complete overlap cases
      if ((p_from_dy_mo_num <= l_to_day) and (p_to_dy_mo_num >= l_from_day)) then
         --
         fnd_message.set_name('BEN','BEN_92305_MAY_NOT_OVERLAP');
         fnd_message.raise_error;
         --
      end if;
  end if;
  --
  open c2;
  fetch c2 into l_strt_r_stp_cd;
  if c2%found then
     close c2;
     if l_strt_r_stp_cd = 'STRT' or l_strt_r_stp_cd = 'STP' then
        if p_strt_r_stp_cvg_cd = 'ETHR' then
        --
        fnd_message.set_name('BEN','BEN_92306_MAY_NOT_SELECT_ETHR');
        fnd_message.raise_error;
        --
        end if;
     elsif l_strt_r_stp_cd = 'ETHR' then
        if p_strt_r_stp_cvg_cd = 'STRT' or p_strt_r_stp_cvg_cd = 'STP' then
        --
        fnd_message.set_name('BEN','BEN_92307_CANNOT_PICK_STRT_STP');
        fnd_message.raise_error;
        --
        end if;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_unique_and_not_overlapping;
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
            (p_actl_prem_id                  in number default hr_api.g_number,
             p_cvg_amt_calc_mthd_id          in number default hr_api.g_number,
             p_acty_base_rt_id               in number default hr_api.g_number,
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
    If ((nvl(p_cvg_amt_calc_mthd_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cvg_amt_calc_mthd_f',
             p_base_key_column => 'cvg_amt_calc_mthd_id',
             p_base_key_value  => p_cvg_amt_calc_mthd_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cvg_amt_calc_mthd_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_acty_base_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acty_base_rt_f',
             p_base_key_column => 'acty_base_rt_id',
             p_base_key_value  => p_acty_base_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_acty_base_rt_f';
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
    hr_utility.set_message('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
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
            (p_prtl_mo_rt_prtn_val_id		in number,
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
       p_argument       => 'prtl_mo_rt_prtn_val_id',
       p_argument_value => p_prtl_mo_rt_prtn_val_id);
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
    hr_utility.set_message('PAY', 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_ppv_shd.g_rec_type,
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
  if p_rec.PRORATE_BY_DAY_TO_MON_FLAG = 'Y' then
    --
    chk_dup_prorate_by_day_row(p_effective_date => p_effective_date,
                               p_acty_base_rt_id => p_rec.acty_base_rt_id,
                               p_mode => 'Insert');
    --
  end if;
  --
  chk_prtl_mo_rt_prtn_val_id
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtl_mo_prortn_rl
  (p_prtl_mo_rt_prtn_val_id    => p_rec.prtl_mo_rt_prtn_val_id,
   p_business_group_id         => p_rec.business_group_id,
   p_prtl_mo_prortn_rl         => p_rec.prtl_mo_prortn_rl,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd_rl
  (p_rndg_cd      => p_rec.rndg_cd,
   p_rndg_rl      => p_rec.rndg_rl);
  --
  chk_strt_r_stp_cvg_cd
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_strt_r_stp_cvg_cd         => p_rec.strt_r_stp_cvg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prortn_rl_pct_val
  (p_prtl_mo_prortn_rl     => p_rec.prtl_mo_prortn_rl,
   p_pct_val               => p_rec.pct_val,
   p_prorate_by_day_to_mon_flag  => p_rec.prorate_by_day_to_mon_flag,
   p_prtl_mo_rt_prtn_val_id  => p_rec.prtl_mo_rt_prtn_val_id, -- Bug No 4418762
   p_acty_base_rt_id         => p_rec.acty_base_rt_id,
   p_actl_prem_id            => p_rec.actl_prem_id,    -- Bug No 4440097
   p_business_group_id       => p_rec.business_group_id,
   p_validation_start_date   => p_validation_start_date,
   p_validation_end_date     => p_validation_end_date);
  --
  chk_from_dt_to_dy
  (p_from_dy_mo_num        => p_rec.from_dy_mo_num,
   p_to_dy_mo_num          => p_rec.to_dy_mo_num);
  --
  chk_unique_and_not_overlapping
  (p_prtl_mo_rt_prtn_val_id  => p_rec.prtl_mo_rt_prtn_val_id,
   p_acty_base_rt_id         => p_rec.acty_base_rt_id,
   p_from_dy_mo_num          => p_rec.from_dy_mo_num,
   p_to_dy_mo_num            => p_rec.to_dy_mo_num,
   p_strt_r_stp_cvg_cd       => p_rec.strt_r_stp_cvg_cd,
   p_num_days_month          => p_rec.num_days_month,     -- Bug No 4366086
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_validation_start_date   => p_validation_start_date,   -- Bug No 4366086
   p_validation_end_date     => p_validation_end_date);    -- Bug No 4366086
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ppv_shd.g_rec_type,
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
  if p_rec.PRORATE_BY_DAY_TO_MON_FLAG = 'Y' then
    --
    chk_dup_prorate_by_day_row(p_effective_date => p_effective_date,
                               p_acty_base_rt_id => p_rec.acty_base_rt_id,
                               p_mode => 'Update',
                               p_prtl_mo_rt_prtn_val_id => p_rec.prtl_mo_rt_prtn_val_id);
    --
  end if;
  --
  chk_prtl_mo_rt_prtn_val_id
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtl_mo_prortn_rl
  (p_prtl_mo_rt_prtn_val_id    => p_rec.prtl_mo_rt_prtn_val_id,
   p_business_group_id         => p_rec.business_group_id,
   p_prtl_mo_prortn_rl         => p_rec.prtl_mo_prortn_rl,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_strt_r_stp_cvg_cd
  (p_prtl_mo_rt_prtn_val_id          => p_rec.prtl_mo_rt_prtn_val_id,
   p_strt_r_stp_cvg_cd         => p_rec.strt_r_stp_cvg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prortn_rl_pct_val
  (p_prtl_mo_prortn_rl     => p_rec.prtl_mo_prortn_rl,
   p_pct_val               => p_rec.pct_val,
   p_prorate_by_day_to_mon_flag  => p_rec.prorate_by_day_to_mon_flag,
   p_prtl_mo_rt_prtn_val_id  => p_rec.prtl_mo_rt_prtn_val_id, -- Bug No 4418762
   p_acty_base_rt_id         => p_rec.acty_base_rt_id,
   p_actl_prem_id            => p_rec.actl_prem_id,    -- Bug No 4440097
   p_business_group_id       => p_rec.business_group_id,
   p_validation_start_date   => p_validation_start_date,
   p_validation_end_date     => p_validation_end_date);
  --
  chk_from_dt_to_dy
  (p_from_dy_mo_num        => p_rec.from_dy_mo_num,
   p_to_dy_mo_num          => p_rec.to_dy_mo_num);
  --
  chk_unique_and_not_overlapping
  (p_prtl_mo_rt_prtn_val_id  => p_rec.prtl_mo_rt_prtn_val_id,
   p_acty_base_rt_id         => p_rec.acty_base_rt_id,
   p_from_dy_mo_num          => p_rec.from_dy_mo_num,
   p_to_dy_mo_num            => p_rec.to_dy_mo_num,
   p_strt_r_stp_cvg_cd       => p_rec.strt_r_stp_cvg_cd,
   p_num_days_month          => p_rec.num_days_month,     -- Bug No 4366086
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_validation_start_date   => p_validation_start_date,  -- Bug No 4366086
   p_validation_end_date     => p_validation_end_date);   -- Bug No 4366086
  --
  chk_rndg_cd_rl
  (p_rndg_cd      => p_rec.rndg_cd,
   p_rndg_rl      => p_rec.rndg_rl);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_actl_prem_id                  => p_rec.actl_prem_id,
             p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
             p_acty_base_rt_id               => p_rec.acty_base_rt_id,
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
	(p_rec 			 in ben_ppv_shd.g_rec_type,
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
     p_prtl_mo_rt_prtn_val_id		=> p_rec.prtl_mo_rt_prtn_val_id);
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
  (p_prtl_mo_rt_prtn_val_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtl_mo_rt_prtn_val_f b
    where b.prtl_mo_rt_prtn_val_id      = p_prtl_mo_rt_prtn_val_id
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
                             p_argument       => 'prtl_mo_rt_prtn_val_id',
                             p_argument_value => p_prtl_mo_rt_prtn_val_id);
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
      hr_utility.set_message('PAY','HR_7220_INVALID_PRIMARY_KEY');
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
end ben_ppv_bus;

/
