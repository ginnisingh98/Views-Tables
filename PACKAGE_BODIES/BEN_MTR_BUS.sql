--------------------------------------------------------
--  DDL for Package Body BEN_MTR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MTR_BUS" as
/* $Header: bemtrrhi.pkb 115.12 2002/12/16 17:39:10 glingapp ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_mtr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_mtchg_rt_id >------|
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
--   mtchg_rt_id PK of record being inserted or updated.
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
Procedure chk_mtchg_rt_id(p_mtchg_rt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mtchg_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_mtr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_mtchg_rt_id                => p_mtchg_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_mtchg_rt_id,hr_api.g_number)
     <>  ben_mtr_shd.g_old_rec.mtchg_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_mtr_shd.constraint_error('BEN_MTCHG_RT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_mtchg_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_mtr_shd.constraint_error('BEN_MTCHG_RT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mtchg_rt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_fctr_id >------|
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
--   p_mtchg_rt_id PK
--   p_comp_lvl_fctr_id ID of FK column
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
Procedure chk_comp_lvl_fctr_id (p_mtchg_rt_id          in number,
                            p_comp_lvl_fctr_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_fctr_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_comp_lvl_fctr a
    where  a.comp_lvl_fctr_id = p_comp_lvl_fctr_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_mtr_shd.api_updating
     (p_mtchg_rt_id            => p_mtchg_rt_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (p_comp_lvl_fctr_id is not null) and (l_api_updating
     and nvl(p_comp_lvl_fctr_id,hr_api.g_number)
     <> nvl(ben_mtr_shd.g_old_rec.comp_lvl_fctr_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if comp_lvl_fctr_id value exists in ben_comp_lvl_fctr table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_comp_lvl_fctr
        -- table.
        --
        ben_mtr_shd.constraint_error('BEN_MTCHG_RT_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_comp_lvl_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_pct_of_py_num_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   no_mx_pct_of_py_num_flag Value of lookup code.
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
Procedure chk_no_mx_pct_of_py_num_flag(p_mtchg_rt_id                in number,
                            p_no_mx_pct_of_py_num_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_pct_of_py_num_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_pct_of_py_num_flag
      <> nvl(ben_mtr_shd.g_old_rec.no_mx_pct_of_py_num_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_pct_of_py_num_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_pct_of_py_num_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_mtch_amt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   no_mx_mtch_amt_flag Value of lookup code.
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
Procedure chk_no_mx_mtch_amt_flag(p_mtchg_rt_id                in number,
                            p_no_mx_mtch_amt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_mtch_amt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_mtch_amt_flag
      <> nvl(ben_mtr_shd.g_old_rec.no_mx_mtch_amt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_mtch_amt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_mtch_amt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mtchg_rt_calc_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   mtchg_rt_calc_rl Value of formula rule id.
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
Procedure chk_mtchg_rt_calc_rl(p_mtchg_rt_id               in number,
                             p_mtchg_rt_calc_rl            in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mtchg_rt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_mtchg_rt_calc_rl
    and    ff.formula_type_id = -160
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
  l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mtchg_rt_calc_rl,hr_api.g_number)
      <> ben_mtr_shd.g_old_rec.mtchg_rt_calc_rl
      or not l_api_updating)
      and p_mtchg_rt_calc_rl is not null then
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
        fnd_message.set_token('ID',p_mtchg_rt_calc_rl);
        fnd_message.set_token('TYPE_ID',-160);
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
end chk_mtchg_rt_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_amt_of_py_num_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   no_mx_amt_of_py_num_flag Value of lookup code.
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
Procedure chk_no_mx_amt_of_py_num_flag(p_mtchg_rt_id      in number,
                            p_no_mx_amt_of_py_num_flag    in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_amt_of_py_num_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_amt_of_py_num_flag
      <> nvl(ben_mtr_shd.g_old_rec.no_mx_amt_of_py_num_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_amt_of_py_num_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_amt_of_py_num_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cntnu_mtch_aftr_mx_rl_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   cntnu_mtch_aftr_mx_rl_flag Value of lookup code.
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
Procedure chk_cntnu_mtch_aftr_mx_rl_flag(p_mtchg_rt_id    in number,
                            p_cntnu_mtch_aftr_mx_rl_flag  in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cntnu_mtch_aftr_mx_rl_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cntnu_mtch_aftr_mx_rl_flag
      <> nvl(ben_mtr_shd.g_old_rec.cntnu_mtch_aftr_mx_rl_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cntnu_mtch_aftr_mx_rl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cntnu_mtch_aftr_mx_rl_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_pct_flag_mx_pct_py >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the no_mx_pct_of_py_num_flag and
--   mx_pct_of_py_num items are mutually exclusive.
--   When the flag is set 'Y' then the value of mx_pct_of_py_num
--   must be null.  Flag 'N' value is required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   no_mx_pct_of_py_num_flag.
--   mx_pct_of_py_num.
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
Procedure chk_no_mx_pct_flag_mx_pct_py(p_mtchg_rt_id      in number,
                            p_no_mx_pct_of_py_num_flag    in varchar2,
                            p_mx_pct_of_py_num            in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_pct_flag_mx_pct_py';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
    -- If  no_mx_pct_of_py_num_flag is "on", then mx_pct_of_py_num
    -- must be null.
    If p_no_mx_pct_of_py_num_flag = 'Y' and p_mx_pct_of_py_num is not null then
       fnd_message.set_name('BEN','BEN_91717_MUT_EXLSU_MX_PCT_FLG');
       fnd_message.raise_error;
    end if;
    If p_no_mx_pct_of_py_num_flag = 'N' and p_mx_pct_of_py_num is null  then
       fnd_message.set_name('BEN','BEN_91717_MUT_EXLSU_MX_PCT_FLG');
       fnd_message.raise_error;
    end if;

    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_pct_flag_mx_pct_py;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_amt_flag_mx_amt_py >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the no_mx_amt_of_py_num_flag and
--   mx_amt_of_py_num items are mutually exclusive.
--   When the flag is set 'Y' then the value of mx_amt_of_py_num
--   must be null.  Flag 'N' value is required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mtchg_rt_id PK of record being inserted or updated.
--   no_mx_amt_of_py_num_flag.
--   mx_amt_of_py_num.
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
Procedure chk_no_mx_amt_flag_mx_amt_py(p_mtchg_rt_id      in number,
                            p_no_mx_amt_of_py_num_flag    in varchar2,
                            p_mx_amt_of_py_num            in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_amt_flag_mx_amt_py';

  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

 l_api_updating := ben_mtr_shd.api_updating
    (p_mtchg_rt_id                => p_mtchg_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
    -- If  no_mx_amt_of_py_num_flag is "on", then mx_amt_of_py_num
    -- must be null.
    If p_no_mx_amt_of_py_num_flag = 'Y' and p_mx_amt_of_py_num is not null then
       fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
       fnd_message.raise_error;
    end if;
    If p_no_mx_amt_of_py_num_flag = 'N' and p_mx_amt_of_py_num is null  then
       fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
       fnd_message.raise_error;
    end if;

    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_amt_flag_mx_amt_py;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_mx_mtch_amt_and_flag >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the matching values maximum
--   amount has a value or the matching values no maximum amount flag is
--   checked.  If the maximum amount has a value, the flag cannot be checked.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mx_mtch_amt           Matching Values maximum amount
--   no_mx_mtch_amt_flag   Matching Values no maximum amount flag
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
Procedure chk_mx_mtch_amt_and_flag
                   (p_mx_mtch_amt            in varchar2,
                    p_no_mx_mtch_amt_flag    in varchar2) is
  --
  l_proc      varchar2(72) := g_package||'chk_mx_mtch_amt_and_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (p_mx_mtch_amt is not null and p_no_mx_mtch_amt_flag = 'Y') then
        --
        -- raise error if maximum amount is not null and the No Maximum Amount
        -- flag is checked
        --
       fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
       fnd_message.raise_error;
        --
    end if;
        --
    If (p_no_mx_mtch_amt_flag = 'N' and p_mx_mtch_amt is null)  then
        --
        -- raise error if maximum amount is null and the No Maximum Amount
        -- flag is not checked
        --
       fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
       fnd_message.raise_error;
        --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mx_mtch_amt_and_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_mx_mn_mtch_amt >--------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if mx_mtch_amt and mn_mtch_val are
--   not null then mx_mtch_amt should be greater than mn_mtch_amt
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   mx_mtch_amt           Matching Values maximum amount
--   mn_mtch_amt           Matching Values manimum amount
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
Procedure chk_mx_mn_mtch_amt
                   (p_mx_mtch_amt            in varchar2,
                    p_mn_mtch_amt            in varchar2) is
  --
  l_proc      varchar2(72) := g_package||'chk_mx_mn_mtch_amt';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (p_mx_mtch_amt is not null and p_mn_mtch_amt is not null) and
       (p_mx_mtch_amt < p_mn_mtch_amt) then

       fnd_message.set_name('BEN','BEN_92506_MAX_MIN_AMT_CHK');
       fnd_message.raise_error;
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mx_mn_mtch_amt;
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
            (p_acty_base_rt_id               in number default hr_api.g_number,
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
            (p_mtchg_rt_id		in number,
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
       p_argument       => 'mtchg_rt_id',
       p_argument_value => p_mtchg_rt_id);
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
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
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
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_mtr_shd.g_rec_type,
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
  chk_mtchg_rt_id
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_fctr_id
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_pct_of_py_num_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_pct_of_py_num_flag         => p_rec.no_mx_pct_of_py_num_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_mn_mtch_amt
  (p_mx_mtch_amt           => p_rec.mx_mtch_amt,
   p_mn_mtch_amt           => p_rec.mn_mtch_amt);
  --
  chk_no_mx_mtch_amt_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_mtch_amt_flag         => p_rec.no_mx_mtch_amt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mtchg_rt_calc_rl
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_mtchg_rt_calc_rl        => p_rec.mtchg_rt_calc_rl,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_amt_of_py_num_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_amt_of_py_num_flag         => p_rec.no_mx_amt_of_py_num_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cntnu_mtch_aftr_mx_rl_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_cntnu_mtch_aftr_mx_rl_flag         => p_rec.cntnu_mtch_aftr_mx_rl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_pct_flag_mx_pct_py
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_pct_of_py_num_flag         => p_rec.no_mx_pct_of_py_num_flag,
   p_mx_pct_of_py_num      => p_rec.mx_pct_of_py_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_amt_flag_mx_amt_py
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_amt_of_py_num_flag         => p_rec.no_mx_amt_of_py_num_flag,
   p_mx_amt_of_py_num      => p_rec.mx_amt_of_py_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_mtch_amt_and_flag
  (p_mx_mtch_amt           => p_rec.mx_mtch_amt,
   p_no_mx_mtch_amt_flag   => p_rec.no_mx_mtch_amt_flag);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_mtr_shd.g_rec_type,
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
  chk_mtchg_rt_id
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_fctr_id
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_pct_of_py_num_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_pct_of_py_num_flag         => p_rec.no_mx_pct_of_py_num_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_mn_mtch_amt
  (p_mx_mtch_amt           => p_rec.mx_mtch_amt,
   p_mn_mtch_amt           => p_rec.mn_mtch_amt);
  --
  chk_no_mx_mtch_amt_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_mtch_amt_flag         => p_rec.no_mx_mtch_amt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mtchg_rt_calc_rl
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_mtchg_rt_calc_rl        => p_rec.mtchg_rt_calc_rl,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_amt_of_py_num_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_amt_of_py_num_flag         => p_rec.no_mx_amt_of_py_num_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cntnu_mtch_aftr_mx_rl_flag
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_cntnu_mtch_aftr_mx_rl_flag         => p_rec.cntnu_mtch_aftr_mx_rl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_pct_flag_mx_pct_py
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_pct_of_py_num_flag         => p_rec.no_mx_pct_of_py_num_flag,
   p_mx_pct_of_py_num      => p_rec.mx_pct_of_py_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_amt_flag_mx_amt_py
  (p_mtchg_rt_id          => p_rec.mtchg_rt_id,
   p_no_mx_amt_of_py_num_flag         => p_rec.no_mx_amt_of_py_num_flag,
   p_mx_amt_of_py_num      => p_rec.mx_amt_of_py_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_mtch_amt_and_flag
  (p_mx_mtch_amt           => p_rec.mx_mtch_amt,
   p_no_mx_mtch_amt_flag   => p_rec.no_mx_mtch_amt_flag);
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
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
	(p_rec 			 in ben_mtr_shd.g_rec_type,
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
     p_mtchg_rt_id		=> p_rec.mtchg_rt_id);
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
  (p_mtchg_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_mtchg_rt_f b
    where b.mtchg_rt_id      = p_mtchg_rt_id
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
                             p_argument       => 'mtchg_rt_id',
                             p_argument_value => p_mtchg_rt_id);
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
end ben_mtr_bus;

/
