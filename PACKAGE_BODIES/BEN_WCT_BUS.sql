--------------------------------------------------------
--  DDL for Package Body BEN_WCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WCT_BUS" as
/* $Header: bewctrhi.pkb 120.0.12010000.2 2008/08/05 15:46:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_wct_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_wv_prtn_rsn_ctfn_ptip_id >------|
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
--   wv_prtn_rsn_ctfn_ptip_id PK of record being inserted or updated.
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
Procedure chk_wv_prtn_rsn_ctfn_ptip_id
             (p_wv_prtn_rsn_ctfn_ptip_id    in number,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wv_prtn_rsn_ctfn_ptip_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wct_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_wv_prtn_rsn_ctfn_ptip_id                => p_wv_prtn_rsn_ctfn_ptip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_wv_prtn_rsn_ctfn_ptip_id,hr_api.g_number)
     <>  ben_wct_shd.g_old_rec.wv_prtn_rsn_ctfn_ptip_id) then
    --
    -- raise error as PK has changed
    --
    ben_wct_shd.constraint_error('BEN_WV_PRTN_RSN_CTFN_PTIP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_wv_prtn_rsn_ctfn_ptip_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_wct_shd.constraint_error('BEN_WV_PRTN_RSN_CTFN_PTIP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_wv_prtn_rsn_ctfn_ptip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_wv_prtn_ctfn_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wv_prtn_rsn_ctfn_ptip_id PK of record being inserted or updated.
--   wv_prtn_ctfn_typ_cd Value of lookup code.
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
Procedure chk_wv_prtn_ctfn_typ_cd
             (p_wv_prtn_rsn_ctfn_ptip_id    in number,
              p_wv_prtn_ctfn_typ_cd         in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wv_prtn_ctfn_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wct_shd.api_updating
    (p_wv_prtn_rsn_ctfn_ptip_id                => p_wv_prtn_rsn_ctfn_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wv_prtn_ctfn_typ_cd
      <> nvl(ben_wct_shd.g_old_rec.wv_prtn_ctfn_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) and
      p_wv_prtn_ctfn_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WV_PRTN_CTFN_TYP',
           p_lookup_code    => p_wv_prtn_ctfn_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'WV_PRTN_CTFN_TYP_not_exist');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wv_prtn_ctfn_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pfd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wv_prtn_rsn_ctfn_ptip_id PK of record being inserted or updated.
--   pfd_flag Value of lookup code.
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
Procedure chk_pfd_flag(p_wv_prtn_rsn_ctfn_ptip_id in number,
                       p_pfd_flag                 in varchar2,
                       p_effective_date           in date,
                       p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pfd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wct_shd.api_updating
    (p_wv_prtn_rsn_ctfn_ptip_id                => p_wv_prtn_rsn_ctfn_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pfd_flag
      <> nvl(ben_wct_shd.g_old_rec.pfd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pfd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pfd_flag,
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
end chk_pfd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ctfn_rqd_when_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wv_prtn_rsn_ctfn_ptip_id PK of record being inserted or updated.
--   ctfn_rqd_when_rl Value of formula rule id.
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
Procedure chk_ctfn_rqd_when_rl
             (p_wv_prtn_rsn_ctfn_ptip_id    in number,
              p_ctfn_rqd_when_rl            in number,
              p_effective_date              in date,
              p_object_version_number       in number,
              p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ctfn_rqd_when_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_ctfn_rqd_when_rl
    and    ff.formula_type_id = -502
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
  l_api_updating := ben_wct_shd.api_updating
    (p_wv_prtn_rsn_ctfn_ptip_id                => p_wv_prtn_rsn_ctfn_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ctfn_rqd_when_rl,hr_api.g_number)
      <> ben_wct_shd.g_old_rec.ctfn_rqd_when_rl
      or not l_api_updating)
      and p_ctfn_rqd_when_rl is not null then
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
        fnd_message.set_token('ID',p_ctfn_rqd_when_rl);
        fnd_message.set_token('TYPE_ID',-502);
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
end chk_ctfn_rqd_when_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_lack_ctfn_sspnd_wvr_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wv_prtn_rsn_ctfn_ptip_id PK of record being inserted or updated.
--   lack_ctfn_sspnd_wvr_flag Value of lookup code.
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
Procedure chk_lack_ctfn_sspnd_wvr_flag
             (p_wv_prtn_rsn_ctfn_ptip_id    in number,
              p_lack_ctfn_sspnd_wvr_flag    in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lack_ctfn_sspnd_wvr_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wct_shd.api_updating
    (p_wv_prtn_rsn_ctfn_ptip_id                => p_wv_prtn_rsn_ctfn_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_lack_ctfn_sspnd_wvr_flag
      <> nvl(ben_wct_shd.g_old_rec.lack_ctfn_sspnd_wvr_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_lack_ctfn_sspnd_wvr_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_lack_ctfn_sspnd_wvr_flag,
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
end chk_lack_ctfn_sspnd_wvr_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_wv_prtn_ctfn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wv_prtn_rsn_ctfn_ptip_id PK of record being inserted or updated.
--   wv_prtn_ctfn_cd Value of lookup code.
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
Procedure chk_wv_prtn_ctfn_cd
             (p_wv_prtn_rsn_ctfn_ptip_id    in number,
              p_wv_prtn_ctfn_cd             in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wv_prtn_ctfn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wct_shd.api_updating
    (p_wv_prtn_rsn_ctfn_ptip_id                => p_wv_prtn_rsn_ctfn_ptip_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wv_prtn_ctfn_cd
      <> nvl(ben_wct_shd.g_old_rec.wv_prtn_ctfn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_wv_prtn_ctfn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WV_PRTN_CTFN_TYP',
           p_lookup_code    => p_wv_prtn_ctfn_cd,
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
end chk_wv_prtn_ctfn_cd;
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
            (p_ctfn_rqd_when_rl           in number default hr_api.g_number,
             p_wv_prtn_rsn_ptip_id           in number default hr_api.g_number,
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
    If ((nvl(p_ctfn_rqd_when_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_ctfn_rqd_when_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_wv_prtn_rsn_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_wv_prtn_rsn_ptip_f',
             p_base_key_column => 'wv_prtn_rsn_ptip_id',
             p_base_key_value  => p_wv_prtn_rsn_ptip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_wv_prtn_rsn_ptip_f';
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
            (p_wv_prtn_rsn_ctfn_ptip_id		in number,
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
       p_argument       => 'wv_prtn_rsn_ctfn_ptip_id',
       p_argument_value => p_wv_prtn_rsn_ctfn_ptip_id);
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
	(p_rec 			 in ben_wct_shd.g_rec_type,
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
  chk_wv_prtn_rsn_ctfn_ptip_id
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wv_prtn_ctfn_typ_cd
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_wv_prtn_ctfn_typ_cd         => p_rec.wv_prtn_ctfn_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pfd_flag
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_pfd_flag         => p_rec.pfd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ctfn_rqd_when_rl
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_ctfn_rqd_when_rl        => p_rec.ctfn_rqd_when_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_lack_ctfn_sspnd_wvr_flag
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_lack_ctfn_sspnd_wvr_flag         => p_rec.lack_ctfn_sspnd_wvr_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wv_prtn_ctfn_cd
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_wv_prtn_ctfn_cd         => p_rec.wv_prtn_ctfn_cd,
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
	(p_rec 			 in ben_wct_shd.g_rec_type,
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
  chk_wv_prtn_rsn_ctfn_ptip_id
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wv_prtn_ctfn_typ_cd
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_wv_prtn_ctfn_typ_cd         => p_rec.wv_prtn_ctfn_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pfd_flag
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_pfd_flag         => p_rec.pfd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ctfn_rqd_when_rl
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_ctfn_rqd_when_rl        => p_rec.ctfn_rqd_when_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_lack_ctfn_sspnd_wvr_flag
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_lack_ctfn_sspnd_wvr_flag         => p_rec.lack_ctfn_sspnd_wvr_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wv_prtn_ctfn_cd
  (p_wv_prtn_rsn_ctfn_ptip_id          => p_rec.wv_prtn_rsn_ctfn_ptip_id,
   p_wv_prtn_ctfn_cd         => p_rec.wv_prtn_ctfn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ctfn_rqd_when_rl           => p_rec.ctfn_rqd_when_rl,
             p_wv_prtn_rsn_ptip_id           => p_rec.wv_prtn_rsn_ptip_id,
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
	(p_rec 			 in ben_wct_shd.g_rec_type,
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
     p_wv_prtn_rsn_ctfn_ptip_id		=> p_rec.wv_prtn_rsn_ctfn_ptip_id);
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
  (p_wv_prtn_rsn_ctfn_ptip_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_wv_prtn_rsn_ctfn_ptip_f b
    where b.wv_prtn_rsn_ctfn_ptip_id      = p_wv_prtn_rsn_ctfn_ptip_id
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
                             p_argument       => 'wv_prtn_rsn_ctfn_ptip_id',
                             p_argument_value => p_wv_prtn_rsn_ctfn_ptip_id);
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
end ben_wct_bus;

/
