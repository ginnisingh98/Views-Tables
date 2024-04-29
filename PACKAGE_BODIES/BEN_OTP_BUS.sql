--------------------------------------------------------
--  DDL for Package Body BEN_OTP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OTP_BUS" as
/* $Header: beotprhi.pkb 115.3 2003/09/25 00:30:57 rpgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_otp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.

--
g_legislation_code            varchar2(150)  default null;
g_optip_id                    number         default null;
--
-- ----------------------------------------------------------------------------
-- |------< chk_optip_id >------|
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
--   optip_id PK of record being inserted or updated.
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
Procedure chk_optip_id(p_optip_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_optip_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_otp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_optip_id                => p_optip_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_optip_id,hr_api.g_number)
     <>  ben_otp_shd.g_old_rec.optip_id) then
    -- raise error as PK has changed
    --
    ben_otp_shd.constraint_error('BEN_OPTIP_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_optip_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_otp_shd.constraint_error('BEN_OPTIP_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_optip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_uniq_optip >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the the records is unique with the
-- pgm_id, pl_typ_id and opt_id for the effective_date
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pgm_id
--   pl_typ_id
--   opt_id
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
Procedure chk_uniq_optip(  p_pgm_id                in number,
                           p_pl_typ_id             in number,
                           p_opt_id                in number,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_uniq_optip';
  l_dummy        varchar2(1)  := null ;
  --
  cursor c_uniq_optip is
    select null from
         ben_optip_f optip
    where optip.pgm_id = p_pgm_id
     and  optip.pl_typ_id = p_pl_typ_id
     and  optip.opt_id    = p_opt_id
     and  optip.effective_start_date > p_effective_date ;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- raise error as the record already exists
    open c_uniq_optip ;
    fetch c_uniq_optip into l_dummy ;
    --
    if c_uniq_optip%found then
    --
      hr_utility.set_location('Future record exists.Cannot insert ', 8 ) ;
      close c_uniq_optip ;
      fnd_message.set_name('PER','HR_7211_DT_UPD_ROWS_IN_FUTURE');
      fnd_message.raise_error;
    --
    end if;
    close c_uniq_optip ;
   --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_uniq_optip;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_optip_id                             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_optip_f otp
     where otp.optip_id = p_optip_id
       and pbg.business_group_id = otp.business_group_id;
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
    ,p_argument           => 'optip_id'
    ,p_argument_value     => p_optip_id
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

  (p_optip_id                             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ben_optip_f otp
     where otp.optip_id = p_optip_id
       and pbg.business_group_id = otp.business_group_id;
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
    ,p_argument           => 'optip_id'
    ,p_argument_value     => p_optip_id
    );
  --
  if ( nvl(ben_otp_bus.g_optip_id, hr_api.g_number)
       = p_optip_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_otp_bus.g_legislation_code;

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
    ben_otp_bus.g_optip_id          := p_optip_id;
    ben_otp_bus.g_legislation_code  := l_legislation_code;

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
  (p_rec in ben_otp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.optip_id is not null)  and (
    nvl(ben_otp_shd.g_old_rec.legislation_code, hr_api.g_varchar2) <>
    nvl(ben_otp_shd.g_old_rec.legislation_subgroup, hr_api.g_varchar2) <>
    nvl(ben_otp_shd.g_old_rec.otp_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.legislation_code, hr_api.g_varchar2)  or
    nvl(p_rec.legislation_subgroup, hr_api.g_varchar2)  or
    nvl(p_rec.otp_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute1, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute2, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute3, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute4, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute5, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute6, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute7, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute8, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute9, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute10, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute11, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute12, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute13, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute14, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute15, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute16, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute17, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute18, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute19, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute20, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute21, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute22, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute23, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute24, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute25, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute26, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute27, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute28, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute29, hr_api.g_varchar2)  or
    nvl(ben_otp_shd.g_old_rec.otp_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.otp_attribute30, hr_api.g_varchar2) ))
    or (p_rec.optip_idis null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'legislation_code'
      ,p_attribute_category              => 'legislation_subgroup'
      ,p_attribute_category              => 'OTP_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'OTP_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.otp_attribute1
      ,p_attribute2_name                 => 'OTP_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.otp_attribute2
      ,p_attribute3_name                 => 'OTP_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.otp_attribute3
      ,p_attribute4_name                 => 'OTP_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.otp_attribute4
      ,p_attribute5_name                 => 'OTP_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.otp_attribute5
      ,p_attribute6_name                 => 'OTP_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.otp_attribute6
      ,p_attribute7_name                 => 'OTP_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.otp_attribute7
      ,p_attribute8_name                 => 'OTP_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.otp_attribute8
      ,p_attribute9_name                 => 'OTP_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.otp_attribute9
      ,p_attribute10_name                => 'OTP_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.otp_attribute10
      ,p_attribute11_name                => 'OTP_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.otp_attribute11
      ,p_attribute12_name                => 'OTP_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.otp_attribute12
      ,p_attribute13_name                => 'OTP_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.otp_attribute13
      ,p_attribute14_name                => 'OTP_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.otp_attribute14
      ,p_attribute15_name                => 'OTP_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.otp_attribute15
      ,p_attribute16_name                => 'OTP_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.otp_attribute16
      ,p_attribute17_name                => 'OTP_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.otp_attribute17
      ,p_attribute18_name                => 'OTP_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.otp_attribute18
      ,p_attribute19_name                => 'OTP_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.otp_attribute19
      ,p_attribute20_name                => 'OTP_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.otp_attribute20
      ,p_attribute21_name                => 'OTP_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.otp_attribute21
      ,p_attribute22_name                => 'OTP_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.otp_attribute22
      ,p_attribute23_name                => 'OTP_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.otp_attribute23
      ,p_attribute24_name                => 'OTP_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.otp_attribute24
      ,p_attribute25_name                => 'OTP_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.otp_attribute25
      ,p_attribute26_name                => 'OTP_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.otp_attribute26
      ,p_attribute27_name                => 'OTP_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.otp_attribute27
      ,p_attribute28_name                => 'OTP_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.otp_attribute28
      ,p_attribute29_name                => 'OTP_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.otp_attribute29
      ,p_attribute30_name                => 'OTP_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.otp_attribute30
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
  ,p_rec             in ben_otp_shd.g_rec_type
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
  IF NOT ben_otp_shd.api_updating
      (p_optip_id                         => p_rec.optip_id
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
  (p_pgm_id                        in number default hr_api.g_number
  ,p_ptip_id                       in number default hr_api.g_number
  ,p_opt_id                        in number default hr_api.g_number
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
  If ((nvl(p_pgm_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pgm_f'
            ,p_base_key_column => 'PGM_ID'
            ,p_base_key_value  => p_pgm_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'pgm';
     raise l_integrity_error;
  End If;
  If ((nvl(p_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ptip_f'
            ,p_base_key_column => 'PTIP_ID'
            ,p_base_key_value  => p_ptip_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'ptip';
     raise l_integrity_error;
  End If;
  If ((nvl(p_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_opt_f'
            ,p_base_key_column => 'OPT_ID'
            ,p_base_key_value  => p_opt_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'opt';
     raise l_integrity_error;
  End If;
  --
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
  (p_optip_id                         in number
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
      ,p_argument       => 'optip_id'
      ,p_argument_value => p_optip_id
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
  (p_rec                   in ben_otp_shd.g_rec_type
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
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  --
  --ben_otp_bus.chk_df(p_rec);
  chk_optip_id
  (p_optip_id              => p_rec.optip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  -- Check the future rows for pgm/pl_typ/opt/effective_date combination
  --
  chk_uniq_optip
  (p_pgm_id                =>p_rec.pgm_id,
   p_pl_typ_id             =>p_rec.pl_typ_id,
   p_opt_id                =>p_rec.opt_id,
   p_effective_date        =>p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ben_otp_shd.g_rec_type
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
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_optip_id
  (p_optip_id          => p_rec.optip_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_pgm_id                         => p_rec.pgm_id
    ,p_ptip_id                        => p_rec.ptip_id
    ,p_opt_id                         => p_rec.opt_id
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
  --ben_otp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ben_otp_shd.g_rec_type
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
    ,p_optip_id                         => p_rec.optip_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_otp_bus;

/
