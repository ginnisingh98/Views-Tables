--------------------------------------------------------
--  DDL for Package Body BEN_PRG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRG_BUS" as
/* $Header: beprgrhi.pkb 120.0.12010000.2 2008/08/05 15:20:31 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prg_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_pl_gd_r_svc_ctfn_id >----------------------|
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
--   pl_gd_r_svc_ctfn_id PK of record being inserted or updated.
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
Procedure chk_pl_regn_id(p_pl_regn_id             in number,
                         p_effective_date         in date,
                         p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_regn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prg_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_regn_id                  => p_pl_regn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_regn_id,hr_api.g_number)
     <>  ben_prg_shd.g_old_rec.pl_regn_id) then
    --
    -- raise error as PK has changed
    --
    ben_prg_shd.constraint_error('BEN_PL_REGN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pl_regn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_prg_shd.constraint_error('BEN_PL_REGN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_regn_id;

-- ----------------------------------------------------------------------------
-- |------------------------------< chk_parent_rec_exists >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a parent rec exists in different business group
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rptg_grp_id ID of FK column
--   p_business_group_id
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
Procedure chk_parent_rec_exists
                          (p_rptg_grp_id           in number,
                           p_business_group_id     in number,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_parent_rec_exists';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  -- This should return if there is a parent in different business group
  -- If there is no parent business group id this should not return any rows
  cursor c1 is
    select null
    from   ben_rptg_grp bnr
    where  bnr.rptg_grp_id = p_rptg_grp_id
     and   nvl(bnr.business_group_id,p_business_group_id) <> p_business_group_id ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
    -- check if rptg_grp_id value exists in ben_rptg_grp table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        fnd_message.set_name('BEN','BEN_92776_PARENT_REC_EXISTS');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_parent_rec_exists;
--

-- ----------------------------------------------------------------------------
-- |----------------------------< chk_rptg_grp_id >---------------------------|
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
--   p_pl_regn_id PK
--   p_regy_grp_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_rptg_grp_id (p_pl_regn_id            in number,
                           p_rptg_grp_id           in number,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rptg_grp_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_rptg_grp a
    where  a.rptg_grp_id = p_rptg_grp_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_prg_shd.api_updating
     (p_pl_regn_id              => p_pl_regn_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rptg_grp_id,hr_api.g_number)
     <> nvl(ben_prg_shd.g_old_rec.rptg_grp_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if pl_id value exists in ben_rept_grp table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_rptg_grp
        -- table.
        --
        ben_cpy_shd.constraint_error('BEN_PL_REGN_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_rptg_grp_id;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_hghly_compd_det_rl >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_regn_id          PK of record being inserted or updated.
--   hghly_compd_det_rl Value of formula rule id.
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
Procedure chk_hghly_compd_det_rl(p_pl_regn_id                  in number,
                                 p_business_group_id        in number,
                                 p_hghly_compd_det_rl          in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hghly_compd_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_hghly_compd_det_rl
    and    ff.formula_type_id = -31
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
  l_api_updating := ben_prg_shd.api_updating
    (p_pl_regn_id                  => p_pl_regn_id ,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_hghly_compd_det_rl ,hr_api.g_number)
      <> ben_prg_shd.g_old_rec.hghly_compd_det_rl
      or not l_api_updating)
      and p_hghly_compd_det_rl  is not null then
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
        fnd_message.set_name('BEN','BEN_91064_INVLD_HG_COMP_DET_RL');
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
end chk_hghly_compd_det_rl ;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_key_ee_det_rl >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_regn_id          PK of record being inserted or updated.
--   hghly_compd_det_rl Value of formula rule id.
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
Procedure chk_key_ee_det_rl(p_pl_regn_id                  in number,
                            p_business_group_id        in number,
                            p_key_ee_det_rl               in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_key_ee_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_key_ee_det_rl
    and    ff.formula_type_id = -39
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
  l_api_updating := ben_prg_shd.api_updating
    (p_pl_regn_id                  => p_pl_regn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_key_ee_det_rl ,hr_api.g_number)
      <> ben_prg_shd.g_old_rec.key_ee_det_rl
      or not l_api_updating)
      and p_key_ee_det_rl  is not null then
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
        fnd_message.set_name('BEN','BEN_91089_INVLD_KEY_EE_DET_RL');
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
end chk_key_ee_det_rl;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_cntr_nndscrn_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntr_nndscrn_rl PK of record being inserted or updated.
--   hghly_compd_det_rl Value of formula rule id.
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
Procedure chk_cntr_nndscrn_rl(p_pl_regn_id                  in number,
                              p_business_group_id           in number,
                              p_cntr_nndscrn_rl             in number,
                              p_effective_date              in date,
                              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cntr_nndscrn_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_cntr_nndscrn_rl
    and    ff.formula_type_id = -42
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
  l_api_updating := ben_prg_shd.api_updating
    (p_pl_regn_id                  => p_pl_regn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cntr_nndscrn_rl ,hr_api.g_number)
      <> ben_prg_shd.g_old_rec.cntr_nndscrn_rl
      or not l_api_updating)
      and p_cntr_nndscrn_rl  is not null then
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
        fnd_message.set_name('BEN','BEN_91090_INVLD_CNTR_NDSCRN_RL');
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
end chk_cntr_nndscrn_rl ;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_cvg_nndscrn_rl >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_nndscrn_rl PK of record being inserted or updated.
--   hghly_compd_det_rl Value of formula rule id.
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
Procedure chk_cvg_nndscrn_rl(p_pl_regn_id                  in number,
                             p_business_group_id           in number,
                             p_cvg_nndscrn_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_nndscrn_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_cvg_nndscrn_rl
    and    ff.formula_type_id = -41
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
  l_api_updating := ben_prg_shd.api_updating
    (p_pl_regn_id                  => p_pl_regn_id ,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cvg_nndscrn_rl ,hr_api.g_number)
      <> ben_prg_shd.g_old_rec.cvg_nndscrn_rl
      or not l_api_updating)
      and p_cvg_nndscrn_rl  is not null then
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
        fnd_message.set_name('BEN','BEN_91091_INVLD_CVG_NDSCRN_RL');
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
end chk_cvg_nndscrn_rl;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_five_pct_ownr_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   five_pct_ownr_rl PK of record being inserted or updated.
--   hghly_compd_det_rl Value of formula rule id.
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
Procedure chk_five_pct_ownr_rl(p_pl_regn_id                  in number,
                               p_business_group_id           in number,
                               p_five_pct_ownr_rl            in number,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_five_pct_ownr_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_five_pct_ownr_rl
    and    ff.formula_type_id = -154
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
  l_api_updating := ben_prg_shd.api_updating
    (p_pl_regn_id                  => p_pl_regn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_five_pct_ownr_rl ,hr_api.g_number)
      <> ben_prg_shd.g_old_rec.five_pct_ownr_rl
      or not l_api_updating)
      and p_five_pct_ownr_rl  is not null then
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
        fnd_message.set_name('BEN','BEN_91092_INVLD_5_PCT_OWNR_RL');
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
end chk_five_pct_ownr_rl;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_regy_pl_typ_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_regn_id PK of record being inserted or updated.
--   regy_pl_typ_cd Value of lookup code.
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
Procedure chk_regy_pl_typ_cd(p_pl_regn_id                  in number,
                             p_regy_pl_typ_cd              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_regy_pl_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prg_shd.api_updating
    (p_pl_regn_id                  => p_pl_regn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_regy_pl_typ_cd
      <> nvl(ben_prg_shd.g_old_rec.regy_pl_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) and  p_regy_pl_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REGY_PL_TYP',
           p_lookup_code    => p_regy_pl_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91093_INVLD_REGY_PL_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_regy_pl_typ_cd;

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
            (p_hghly_compd_det_rl            in number default hr_api.g_number,
             p_key_ee_det_rl                 in number default hr_api.g_number,
             p_cntr_nndscrn_rl               in number default hr_api.g_number,
             p_cvg_nndscrn_rl                in number default hr_api.g_number,
             p_five_pct_ownr_rl              in number default hr_api.g_number,
             p_regn_id                       in number default hr_api.g_number,
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
    If ((nvl(p_hghly_compd_det_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_hghly_compd_det_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_key_ee_det_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_key_ee_det_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_cntr_nndscrn_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_cntr_nndscrn_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_cvg_nndscrn_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_cvg_nndscrn_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_five_pct_ownr_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_five_pct_ownr_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_regn_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_regn_f',
             p_base_key_column => 'regn_id',
             p_base_key_value  => p_regn_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_regn_f';
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
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
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
            (p_pl_regn_id		in number,
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
       p_argument       => 'pl_regn_id',
       p_argument_value => p_pl_regn_id);
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
	(p_rec 			 in ben_prg_shd.g_rec_type,
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
  --CWB Changes
  if p_rec.business_group_id is not null then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_pl_regn_id
  (p_pl_regn_id             => p_rec.pl_regn_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_rptg_grp_id
  (p_pl_regn_id            => p_rec.pl_regn_id,
   p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'Regulation',
     p_argument_value => p_rec.regn_id);
  --
  chk_hghly_compd_det_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_hghly_compd_det_rl          => p_rec.hghly_compd_det_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_key_ee_det_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_key_ee_det_rl               => p_rec.key_ee_det_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_cntr_nndscrn_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_cntr_nndscrn_rl             => p_rec.cntr_nndscrn_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_cvg_nndscrn_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_cvg_nndscrn_rl              => p_rec.cvg_nndscrn_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_five_pct_ownr_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_five_pct_ownr_rl            => p_rec.five_pct_ownr_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_regy_pl_typ_cd
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_regy_pl_typ_cd              => p_rec.regy_pl_typ_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_parent_rec_exists
  (p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_prg_shd.g_rec_type,
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
  -- CWB Changes
  if p_rec.business_group_id is not null then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_pl_regn_id
  (p_pl_regn_id             => p_rec.pl_regn_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_rptg_grp_id
  (p_pl_regn_id            => p_rec.pl_regn_id,
   p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'Regulation',
     p_argument_value => p_rec.regn_id);
  --
  chk_hghly_compd_det_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_hghly_compd_det_rl          => p_rec.hghly_compd_det_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_key_ee_det_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_key_ee_det_rl               => p_rec.key_ee_det_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_cntr_nndscrn_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_cntr_nndscrn_rl             => p_rec.cntr_nndscrn_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_cvg_nndscrn_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_cvg_nndscrn_rl              => p_rec.cvg_nndscrn_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_five_pct_ownr_rl
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_business_group_id           => p_rec.business_group_id,
   p_five_pct_ownr_rl            => p_rec.five_pct_ownr_rl,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_regy_pl_typ_cd
  (p_pl_regn_id                  => p_rec.pl_regn_id,
   p_regy_pl_typ_cd              => p_rec.regy_pl_typ_cd,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  chk_parent_rec_exists
  (p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  dt_update_validate
    (p_hghly_compd_det_rl            => p_rec.hghly_compd_det_rl,
     p_key_ee_det_rl                 => p_rec.key_ee_det_rl,
     p_cntr_nndscrn_rl               => p_rec.cntr_nndscrn_rl,
     p_cvg_nndscrn_rl                => p_rec.cvg_nndscrn_rl,
     p_five_pct_ownr_rl              => p_rec.five_pct_ownr_rl,
     p_regn_id                       => p_rec.regn_id,
     p_pl_id                         => p_rec.pl_id,
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
	(p_rec 			 in ben_prg_shd.g_rec_type,
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
     p_pl_regn_id		=> p_rec.pl_regn_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_pl_regn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pl_regn_f b
    where b.pl_regn_id        = p_pl_regn_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%type; --varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
 --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'pl_regn_id',
                             p_argument_value => p_pl_regn_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
/** CWB Changes
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
*/
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_prg_bus;

/
