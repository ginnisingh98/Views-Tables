--------------------------------------------------------
--  DDL for Package Body BEN_TCV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TCV_BUS" as
/* $Header: betcvrhi.pkb 120.0.12010000.2 2008/08/05 15:32:24 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_tcv_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ttl_cvg_vol_rt_id >------|
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
--   ttl_cvg_vol_rt_id PK of record being inserted or updated.
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
Procedure chk_ttl_cvg_vol_rt_id(p_ttl_cvg_vol_rt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ttl_cvg_vol_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_tcv_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ttl_cvg_vol_rt_id                => p_ttl_cvg_vol_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ttl_cvg_vol_rt_id,hr_api.g_number)
     <>  ben_tcv_shd.g_old_rec.ttl_cvg_vol_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_tcv_shd.constraint_error('BEN_TTL_CVG_VOL_RT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ttl_cvg_vol_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_tcv_shd.constraint_error('BEN_TTL_CVG_VOL_RT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ttl_cvg_vol_rt_id;
--
-- |--------------------< chk_duplicate_ordr_num >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_vrbl_rt_prfl_id
--    p_ordr_num
--    p_effective_date
--    p_business_group_id
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
procedure chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id in number
           ,p_ordr_num in number
           ,p_effective_date in date
           ,p_business_group_id in number)
is
   l_proc   varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy    char(1);
   cursor c1 is select null
                from ben_ttl_cvg_vol_rt_f
                 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                    --and asnt_set_rt_id <> nvl(p_asnt_set_rt_id,-1)
                   and p_effective_date between effective_start_date
                                            and effective_end_date
                   and business_group_id + 0 = p_business_group_id
                   and ordr_num = p_ordr_num;
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);

   --
   open c1;
   fetch c1 into l_dummy;
   --
   if c1%found then
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
   end if;
   close c1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_duplicate_ordr_num;

--
-- Added For bug 2529689
--
--
-- |--------------------< chk_ttlcov_mlt_cd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- If the Usage selected is Actual Premiums, the Calculation type should be
-- Multiple of total coverage
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_vrbl_rt_prfl_id
--    p_effective_date
--    p_business_group_id
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
procedure chk_ttlcov_mlt_cd
          (p_vrbl_rt_prfl_id in number
           ,p_effective_date in date
           ,p_business_group_id in number)
is
   l_proc   varchar2(72) := g_package||' chk_ttlcov_mlt_cd ';



   cursor c1 is select vrbl_usg_cd, mlt_cd
                  from ben_vrbl_rt_prfl_f
                 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date
                   and business_group_id  = p_business_group_id;

   l_c1 c1%ROWTYPE;
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);

   --
   open c1;
   fetch c1 into l_c1;
   --
   hr_utility.set_location('vrbl rt prfl id is :'||p_vrbl_rt_prfl_id, 69);
   hr_utility.set_location('vrbl_usg_cd is :'||l_c1.vrbl_usg_cd, 69);
   hr_utility.set_location('mlt_cd id is :'||l_c1.mlt_cd, 69);

   IF l_c1.vrbl_usg_cd = 'ACP' THEN
      IF l_c1.mlt_cd <> 'TTLCVG' THEN
        close c1;
        --
        -- raise an error as mlt_cd can only be TTLCVG .
        --
        --
        fnd_message.set_name('BEN','BEN_92264_TTLCVG_MLTCD');
        fnd_message.raise_error;
      END IF;
   END IF;

   close c1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_ttlcov_mlt_cd;

--

-- ----------------------------------------------------------------------------
-- |------< chk_cvg_vol_det_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ttl_cvg_vol_rt_id PK of record being inserted or updated.
--   cvg_vol_det_rl Value of formula rule id.
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
Procedure chk_cvg_vol_det_rl(p_ttl_cvg_vol_rt_id                in number,
                             p_cvg_vol_det_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_vol_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
    where  ff.formula_id = p_cvg_vol_det_rl
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_tcv_shd.api_updating
    (p_ttl_cvg_vol_rt_id                => p_ttl_cvg_vol_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cvg_vol_det_rl,hr_api.g_number)
      <> ben_tcv_shd.g_old_rec.cvg_vol_det_rl
      or not l_api_updating)
      and p_cvg_vol_det_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_cvg_vol_det_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_vol_det_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ttl_cvg_vol_rt_id PK of record being inserted or updated.
--   cvg_vol_det_cd Value of lookup code.
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
Procedure chk_cvg_vol_det_cd(p_ttl_cvg_vol_rt_id                in number,
                            p_cvg_vol_det_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_vol_det_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_tcv_shd.api_updating
    (p_ttl_cvg_vol_rt_id                => p_ttl_cvg_vol_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_vol_det_cd
      <> nvl(ben_tcv_shd.g_old_rec.cvg_vol_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cvg_vol_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CVG_DET_DT',
           p_lookup_code    => p_cvg_vol_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cvg_vol_det_cd');
      fnd_message.set_token('TYPE','BEN_CVG_DET_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_vol_det_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_cvg_vol_amt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ttl_cvg_vol_rt_id PK of record being inserted or updated.
--   no_mx_cvg_vol_amt_apls_flag Value of lookup code.
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
Procedure chk_no_mx_cvg_vol_amt_flag(p_ttl_cvg_vol_rt_id                in number,
                            p_no_mx_cvg_vol_amt_apls_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_cvg_vol_amt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_tcv_shd.api_updating
    (p_ttl_cvg_vol_rt_id                => p_ttl_cvg_vol_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_cvg_vol_amt_apls_flag
      <> nvl(ben_tcv_shd.g_old_rec.no_mx_cvg_vol_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_vol_amt_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mx_cvg_vol_amt_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_cvg_vol_amt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_cvg_vol_amt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ttl_cvg_vol_rt_id PK of record being inserted or updated.
--   no_mn_cvg_vol_amt_apls_flag Value of lookup code.
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
Procedure chk_no_mn_cvg_vol_amt_flag(p_ttl_cvg_vol_rt_id                in number,
                            p_no_mn_cvg_vol_amt_apls_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_cvg_vol_amt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_tcv_shd.api_updating
    (p_ttl_cvg_vol_rt_id                => p_ttl_cvg_vol_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_cvg_vol_amt_apls_flag
      <> nvl(ben_tcv_shd.g_old_rec.no_mn_cvg_vol_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_cvg_vol_amt_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mn_cvg_vol_amt_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_cvg_vol_amt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_excld_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ttl_cvg_vol_rt_id PK of record being inserted or updated.
--   excld_flag Value of lookup code.
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
Procedure chk_excld_flag(p_ttl_cvg_vol_rt_id                in number,
                            p_excld_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_excld_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_tcv_shd.api_updating
    (p_ttl_cvg_vol_rt_id                => p_ttl_cvg_vol_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_tcv_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_excld_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_excld_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_excld_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_cvg_vol_prtt_mutexcl >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the cvg_vol is mutually exclusive for
--   vrbl_rt_prfl_id. A ttl_prtt_rt cannot exist with this vrbl_rt_prfl_id due t
--   the ARC relationship on ben_vrbl_rt_prfl_f.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ttl_cvg_vol_rt_id     PK of record being inserted or updated.
--   vrbl_rt_prfl_id       vrbl_rt_prfl_id.
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
Procedure chk_cvg_vol_prtt_mutexcl(p_ttl_cvg_vol_rt_id        in number,
                                   p_vrbl_rt_prfl_id           in number,
                                   p_effective_date            in date,
                                   p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_vol_prtt_mutexcl';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
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
  if p_vrbl_rt_prfl_id is not null then
    --
    -- Check if vrbl_rt_prfl_id is mutually exclusive.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this vrbl_rt_prfl_id assigned to ttl_prtt_rt(s).
        --
        fnd_message.set_name('BEN','BEN_92258_TTLPRTT_CVGVOL_EXCL1');
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
End chk_cvg_vol_prtt_mutexcl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_flag_and_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the flag is turned on then
--   the value must be null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_FLAG value of flag item.
--   P_VAL  value of value item
--   P_MSG  message name to dispaly if validation fails
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
Procedure chk_flag_and_val(p_flag      in varchar2,
                           p_val       in number,
                           p_msg       in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_flag_and_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_flag = 'Y' and p_val is not null then
      fnd_message.set_name('BEN', p_msg);
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_flag_and_val;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mn_val_mx_val >--------------------------|
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
--   p_mn_val minimum value
--   p_mx_val maximum value
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
Procedure chk_mn_val_mx_val(p_mn_val in number,
                        p_mx_val in number) is
  --
  l_proc varchar2(72) := g_package||'chk_mn_val_mx_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check the values
  -- note: Don't want an error if either one is null
  --
  if (p_mn_val >= p_mx_val) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_91142_MIN_LESS_NOT_EQ_MAX');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_mn_val_mx_val;
----------------------------------------------------------------------------
--|-------------------------< chk_mn_mx_vol_amt >--------------------------|
----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that minimum vol amt number is always less
--   than max vol amt number and either the flag is set or the number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   poe_rt_id PK of record being inserted or updated.
--   mn_cvg_vol_amt Value of Minimum value.
--   mx_cvg_vol_amt Value of Maximum value.
--   no_mn_cvg_vol_amt_apls_flag Value of Minimum flag.
--   no_mx_cvg_vol_amt_apls_flag Value of Maximum flag.
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
Procedure chk_mn_mx_vol_amt(p_ttl_cvg_vol_rt_id           in number,
                            p_no_mn_cvg_vol_amt_apls_flag in varchar2,
                            p_mn_cvg_vol_amt              in number,
                            p_no_mx_cvg_vol_amt_apls_flag in varchar2,
                            p_mx_cvg_vol_amt              in number,
                            p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_vol_amt';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Minimum Vol Number must be < Maximum Vol Number,
  -- if both are used.
  --
  if p_mn_cvg_vol_amt is not null and p_mx_cvg_vol_amt is not null then
    --
    -- raise error if max value not greater than min value
    --
    if p_mx_cvg_vol_amt <= p_mn_cvg_vol_amt then
      --
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- If No Minimum vol flag set to "on" (Y),
  --    then minimum vol number must be blank.
  --
  if p_no_mn_cvg_vol_amt_apls_flag = 'Y' and
    p_mn_cvg_vol_amt is not null then
    --
    fnd_message.set_name('BEN','BEN_91054_MIN_VAL_NOT_NULL');
    fnd_message.raise_error;
    --
  elsif p_no_mn_cvg_vol_amt_apls_flag = 'N' and
    p_mn_cvg_vol_amt is null then
    --
    fnd_message.set_name('BEN','BEN_91055_MIN_VAL_REQUIRED');
    fnd_message.raise_error;
    --
  end if;
  --
  -- If No Maximum poe flag set to "on" (Y),
  --    then maximum poe number must be blank.
  --
  if p_no_mx_cvg_vol_amt_apls_flag = 'Y' and
    p_mx_cvg_vol_amt is not null then
    --
    fnd_message.set_name('BEN','BEN_91056_MAX_VAL_NOT_NULL');
    fnd_message.raise_error;
    --
  elsif p_no_mx_cvg_vol_amt_apls_flag = 'N' and
    p_mx_cvg_vol_amt is null then
    --
    fnd_message.set_name('BEN','BEN_91057_MAX_VAL_REQUIRED');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_vol_amt;
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
            (p_vrbl_rt_prfl_id               in number default hr_api.g_number,
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
    If ((nvl(p_vrbl_rt_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_vrbl_rt_prfl_f',
             p_base_key_column => 'vrbl_rt_prfl_id',
             p_base_key_value  => p_vrbl_rt_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_vrbl_rt_prfl_f';
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
            (p_ttl_cvg_vol_rt_id		in number,
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
       p_argument       => 'ttl_cvg_vol_rt_id',
       p_argument_value => p_ttl_cvg_vol_rt_id);
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
	(p_rec 			 in ben_tcv_shd.g_rec_type,
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
  chk_ttl_cvg_vol_rt_id
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_vol_det_rl
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_cvg_vol_det_rl        => p_rec.cvg_vol_det_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_vol_det_cd
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_cvg_vol_det_cd         => p_rec.cvg_vol_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_cvg_vol_amt_flag
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_no_mx_cvg_vol_amt_apls_flag         => p_rec.no_mx_cvg_vol_amt_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_cvg_vol_amt_flag
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_no_mn_cvg_vol_amt_apls_flag         => p_rec.no_mn_cvg_vol_amt_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_excld_flag         => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_vol_prtt_mutexcl
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id        => p_rec.business_group_id);
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mn_cvg_vol_amt_apls_flag,
   p_val    => p_rec.mn_cvg_vol_amt,
   p_msg    => 'BEN_91695_MIN_VAL_FLAG_EXCLSV');
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mx_cvg_vol_amt_apls_flag,
   p_val    => p_rec.mx_cvg_vol_amt,
   p_msg    => 'BEN_91696_MAX_VAL_FLAG_EXCLSV');
  --
  chk_mn_val_mx_val
  (p_mn_val                     => p_rec.mn_cvg_vol_amt,
   p_mx_val                     => p_rec.mx_cvg_vol_amt);
  --
  chk_mn_mx_vol_amt
  (p_ttl_cvg_vol_rt_id           => p_rec.ttl_cvg_vol_rt_id,
   p_no_mn_cvg_vol_amt_apls_flag => p_rec.no_mn_cvg_vol_amt_apls_flag,
   p_mn_cvg_vol_amt              => p_rec.mn_cvg_vol_amt,
   p_no_mx_cvg_vol_amt_apls_flag => p_rec.no_mx_cvg_vol_amt_apls_flag,
   p_mx_cvg_vol_amt              => p_rec.mx_cvg_vol_amt,
   p_object_version_number       => p_rec.object_version_number);
  --
chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_effective_date      => p_effective_date
           ,p_business_group_id   => p_rec.business_group_id);
--
   -- For bug 2529689
   -- Call procedure to check mltcd is TTLCVG
   chk_ttlcov_mlt_cd
   (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id,
    p_effective_date      => p_effective_date,
    p_business_group_id   => p_rec.business_group_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_tcv_shd.g_rec_type,
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
  chk_ttl_cvg_vol_rt_id
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_vol_det_rl
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_cvg_vol_det_rl        => p_rec.cvg_vol_det_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_vol_det_cd
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_cvg_vol_det_cd         => p_rec.cvg_vol_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_cvg_vol_amt_flag
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_no_mx_cvg_vol_amt_apls_flag         => p_rec.no_mx_cvg_vol_amt_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_cvg_vol_amt_flag
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_no_mn_cvg_vol_amt_apls_flag         => p_rec.no_mn_cvg_vol_amt_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_excld_flag         => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_vol_prtt_mutexcl
  (p_ttl_cvg_vol_rt_id          => p_rec.ttl_cvg_vol_rt_id,
   p_vrbl_rt_prfl_id          => p_rec.vrbl_rt_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id        => p_rec.business_group_id);
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mn_cvg_vol_amt_apls_flag,
   p_val    => p_rec.mn_cvg_vol_amt,
   p_msg    => 'BEN_91695_MIN_VAL_FLAG_EXCLSV');
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mx_cvg_vol_amt_apls_flag,
   p_val    => p_rec.mx_cvg_vol_amt,
   p_msg    => 'BEN_91696_MAX_VAL_FLAG_EXCLSV');
  --
  chk_mn_val_mx_val
  (p_mn_val                     => p_rec.mn_cvg_vol_amt,
   p_mx_val                     => p_rec.mx_cvg_vol_amt);
  --
  chk_mn_mx_vol_amt
  (p_ttl_cvg_vol_rt_id           => p_rec.ttl_cvg_vol_rt_id,
   p_no_mn_cvg_vol_amt_apls_flag => p_rec.no_mn_cvg_vol_amt_apls_flag,
   p_mn_cvg_vol_amt              => p_rec.mn_cvg_vol_amt,
   p_no_mx_cvg_vol_amt_apls_flag => p_rec.no_mx_cvg_vol_amt_apls_flag,
   p_mx_cvg_vol_amt              => p_rec.mx_cvg_vol_amt,
   p_object_version_number       => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_effective_date      => p_effective_date
           ,p_business_group_id   => p_rec.business_group_id);
--
-- For bug 2529689
   -- Call procedure to check mltcd is TTLCVG
   chk_ttlcov_mlt_cd
   (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id,
    p_effective_date      => p_effective_date,
    p_business_group_id   => p_rec.business_group_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_tcv_shd.g_rec_type,
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
     p_ttl_cvg_vol_rt_id		=> p_rec.ttl_cvg_vol_rt_id);
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
  (p_ttl_cvg_vol_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ttl_cvg_vol_rt_f b
    where b.ttl_cvg_vol_rt_id      = p_ttl_cvg_vol_rt_id
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
                             p_argument       => 'ttl_cvg_vol_rt_id',
                             p_argument_value => p_ttl_cvg_vol_rt_id);
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
end ben_tcv_bus;

/
