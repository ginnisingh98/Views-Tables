--------------------------------------------------------
--  DDL for Package Body BEN_QIG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_QIG_BUS" as
/* $Header: beqigrhi.pkb 120.2.12010000.2 2008/08/05 15:24:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_qig_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_qua_in_gr_rt_id                   number         default null;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_qua_in_gr_rt_id >----------------------------|
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
--   qua_in_gr_rt_id      PK of record being inserted or updated.
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
Procedure chk_qua_in_gr_rt_id(p_qua_in_gr_rt_id                 in number,
                        p_effective_date            in date,
                        p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qua_in_gr_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_qig_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_qua_in_gr_rt_id                   => p_qua_in_gr_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_qua_in_gr_rt_id,hr_api.g_number)
     <>  ben_qig_shd.g_old_rec.qua_in_gr_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_qig_shd.constraint_error('BEN_QUA_IN_GR_RT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_qua_in_gr_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_qig_shd.constraint_error('BEN_QUA_IN_GR_RT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_qua_in_gr_rt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_quar_in_grade_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--   Additionally this procedure will check that quar_in_grade_cd is unique
--   within the Eligibility profile.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qua_in_gr_rt_id PK
--   p_quar_in_grade_cd ID of FK column
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
Procedure chk_quar_in_grade_cd (p_qua_in_gr_rt_id             in number,
                      p_quar_in_grade_cd      in varchar2,
                      p_vrbl_rt_prfl_id       in number,
                      p_validation_start_date in date,
                      p_validation_end_date   in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_quar_in_grade_cd';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_exists       varchar2(1);
  --
   cursor c1 is select  null
                from    hr_lookups h1
                where   h1.lookup_type = 'BEN_CWB_QUAR_IN_GRD'
                and     h1.lookup_code = p_quar_in_grade_cd
                and     p_effective_date
                between nvl(h1.start_date_active, p_effective_date)
                and     nvl(h1.end_date_active, p_effective_date)
                and     h1.enabled_flag = 'Y';
  --
  cursor c3 is
         select null
         from ben_qua_in_gr_rt_f
         where quar_in_grade_cd = p_quar_in_grade_cd
           and vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
           and qua_in_gr_rt_id <> nvl(p_qua_in_gr_rt_id,hr_api.g_number)
           and business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_qig_shd.api_updating
     (p_qua_in_gr_rt_id               => p_qua_in_gr_rt_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_quar_in_grade_cd,hr_api.g_varchar2)
     <> nvl(ben_qig_shd.g_old_rec.quar_in_grade_cd,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- check if quar_in_grade_cd value exists in hr_lookups table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK
        -- table.
        --
        ben_qig_shd.constraint_error('BEN_QUA_IN_GR_RT_FK2');
        --
      end if;
      --
    close c1;
    --
    open c3;
    fetch c3 into l_exists;
    if c3%found then
      close c3;
      --
      -- raise error as this quartile in grade already exists for this profile
    --
     fnd_message.set_name('BEN', 'BEN_92992_DUPS_ROW');
     fnd_message.set_token('VAR1','Quartile in Grade criteria');
     fnd_message.set_token('VAR2','Variable Rate Profile');
     fnd_message.raise_error;
    --
    end if;
    close c3;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_quar_in_grade_cd;
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
--   qua_in_gr_rt_id PK of record being inserted or updated.
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
Procedure chk_excld_flag(p_qua_in_gr_rt_id                in number,
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
  l_api_updating := ben_qig_shd.api_updating
    (p_qua_in_gr_rt_id                   => p_qua_in_gr_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_qig_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
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
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_qua_in_gr_rt_id                            in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_qua_in_gr_rt_f qig
     where qig.qua_in_gr_rt_id = p_qua_in_gr_rt_id
       and pbg.business_group_id = qig.business_group_id;
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
    ,p_argument           => 'qua_in_gr_rt_id'
    ,p_argument_value     => p_qua_in_gr_rt_id
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
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'QUA_IN_GR_RT_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
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
  (p_qua_in_gr_rt_id                            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ben_qua_in_gr_rt_f qig
     where qig.qua_in_gr_rt_id = p_qua_in_gr_rt_id
       and pbg.business_group_id = qig.business_group_id;
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
    ,p_argument           => 'qua_in_gr_rt_id'
    ,p_argument_value     => p_qua_in_gr_rt_id
    );
  --
  if ( nvl(ben_qig_bus.g_qua_in_gr_rt_id, hr_api.g_number)
       = p_qua_in_gr_rt_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_qig_bus.g_legislation_code;
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
    ben_qig_bus.g_qua_in_gr_rt_id                   := p_qua_in_gr_rt_id;
    ben_qig_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
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
  (p_rec in ben_qig_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.qua_in_gr_rt_id is not null)  and (
    nvl(ben_qig_shd.g_old_rec.qig_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute1, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute2, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute3, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute4, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute5, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute6, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute7, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute8, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute9, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute10, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute11, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute12, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute13, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute14, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute15, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute16, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute17, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute18, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute19, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute20, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute21, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute22, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute23, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute24, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute25, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute26, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute27, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute28, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute29, hr_api.g_varchar2)  or
    nvl(ben_qig_shd.g_old_rec.qig_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.qig_attribute30, hr_api.g_varchar2) ))
    or (p_rec.qua_in_gr_rt_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'BEN_QUA_IN_GR_RT_F'
      ,p_attribute_category              => 'QIG_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'QIG_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.qig_attribute1
      ,p_attribute2_name                 => 'QIG_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.qig_attribute2
      ,p_attribute3_name                 => 'QIG_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.qig_attribute3
      ,p_attribute4_name                 => 'QIG_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.qig_attribute4
      ,p_attribute5_name                 => 'QIG_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.qig_attribute5
      ,p_attribute6_name                 => 'QIG_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.qig_attribute6
      ,p_attribute7_name                 => 'QIG_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.qig_attribute7
      ,p_attribute8_name                 => 'QIG_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.qig_attribute8
      ,p_attribute9_name                 => 'QIG_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.qig_attribute9
      ,p_attribute10_name                => 'QIG_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.qig_attribute10
      ,p_attribute11_name                => 'QIG_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.qig_attribute11
      ,p_attribute12_name                => 'QIG_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.qig_attribute12
      ,p_attribute13_name                => 'QIG_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.qig_attribute13
      ,p_attribute14_name                => 'QIG_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.qig_attribute14
      ,p_attribute15_name                => 'QIG_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.qig_attribute15
      ,p_attribute16_name                => 'QIG_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.qig_attribute16
      ,p_attribute17_name                => 'QIG_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.qig_attribute17
      ,p_attribute18_name                => 'QIG_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.qig_attribute18
      ,p_attribute19_name                => 'QIG_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.qig_attribute19
      ,p_attribute20_name                => 'QIG_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.qig_attribute20
      ,p_attribute21_name                => 'QIG_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.qig_attribute21
      ,p_attribute22_name                => 'QIG_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.qig_attribute22
      ,p_attribute23_name                => 'QIG_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.qig_attribute23
      ,p_attribute24_name                => 'QIG_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.qig_attribute24
      ,p_attribute25_name                => 'QIG_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.qig_attribute25
      ,p_attribute26_name                => 'QIG_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.qig_attribute26
      ,p_attribute27_name                => 'QIG_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.qig_attribute27
      ,p_attribute28_name                => 'QIG_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.qig_attribute28
      ,p_attribute29_name                => 'QIG_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.qig_attribute29
      ,p_attribute30_name                => 'QIG_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.qig_attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
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
  ,p_rec             in ben_qig_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_qig_shd.api_updating
      (p_qua_in_gr_rt_id                        => p_rec.qua_in_gr_rt_id
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
End chk_non_updateable_args;
--
-- added for Bug 5078478 .. add this procedure to check the duplicate seq no
-- |--------------------< chk_duplicate_ordr_num >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_qua_in_gr_rt_id
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
           ,p_qua_in_gr_rt_id  in number
           ,p_ordr_num in number
           ,p_validation_start_date in date
	   ,p_validation_end_date in date
           ,p_business_group_id in number)
is
l_proc   varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy    char(1);
   cursor c1 is select null
                  from ben_qua_in_gr_rt_f
                 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                   -- changed against bug: 5113011
		   and qua_in_gr_rt_id   <> nvl(p_qua_in_gr_rt_id  ,-1)
                   -- and quar_in_grade_cd   <> nvl(p_quar_in_grade_cd  ,-1)
                   --and p_effective_date between effective_start_date
                   --                         and effective_end_date
		   and p_validation_start_date <= effective_end_date
		   and p_validation_end_date >= effective_start_date
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
   hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_duplicate_ordr_num;



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
  (p_vrbl_rt_prfl_id               in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
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
  If ((nvl(p_vrbl_rt_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_vrbl_rt_prfl_f'
            ,p_base_key_column => 'VRBL_RT_PRFL_ID'
            ,p_base_key_value  => p_vrbl_rt_prfl_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','vrbl rt prfl');
     hr_multi_message.add
       (p_associated_column1 => ben_qig_shd.g_tab_nam || '.VRBL_RT_PRFL_ID');
  End If;
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
  (p_qua_in_gr_rt_id                  in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
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
      ,p_argument       => 'qua_in_gr_rt_id'
      ,p_argument_value => p_qua_in_gr_rt_id
      );
    --
  --
    --
  End If;
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
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ben_qig_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_qig_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --

    chk_qua_in_gr_rt_id
    (p_qua_in_gr_rt_id       => p_rec.qua_in_gr_rt_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
    --
    chk_quar_in_grade_cd
    (p_qua_in_gr_rt_id       => p_rec.qua_in_gr_rt_id,
     p_quar_in_grade_cd      => p_rec.quar_in_grade_cd,
     p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date,
     p_effective_date        => p_effective_date,
     p_business_group_id     => p_rec.business_group_id,
     p_object_version_number => p_rec.object_version_number);
    --
    chk_excld_flag
    (p_qua_in_gr_rt_id             => p_rec.qua_in_gr_rt_id,
     p_excld_flag            => p_rec.excld_flag,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
     --
     -- added for Bug 5078478 .. add this procedure to check the duplicate seq no
	chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_qua_in_gr_rt_id	  => p_rec.qua_in_gr_rt_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_validation_start_date => p_validation_start_date
	   ,p_validation_end_date => p_validation_end_date
           ,p_business_group_id   => p_rec.business_group_id);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
   -- ben_qig_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ben_qig_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_qig_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  chk_qua_in_gr_rt_id
    (p_qua_in_gr_rt_id        => p_rec.qua_in_gr_rt_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
    --
  chk_quar_in_grade_cd
    (p_qua_in_gr_rt_id       => p_rec.qua_in_gr_rt_id,
     p_quar_in_grade_cd      => p_rec.quar_in_grade_cd,
     p_vrbl_rt_prfl_id       => p_rec.vrbl_rt_prfl_id,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date,
     p_effective_date        => p_effective_date,
     p_business_group_id     => p_rec.business_group_id,
     p_object_version_number => p_rec.object_version_number);
    --
  chk_excld_flag
    (p_qua_in_gr_rt_id             => p_rec.qua_in_gr_rt_id,
     p_excld_flag            => p_rec.excld_flag,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
     --
     -- added for Bug 5078478 .. add this procedure to check the duplicate seq no
   chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_qua_in_gr_rt_id	  => p_rec.qua_in_gr_rt_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_validation_start_date => p_validation_start_date
	   ,p_validation_end_date => p_validation_end_date
           ,p_business_group_id   => p_rec.business_group_id);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_vrbl_rt_prfl_id                => p_rec.vrbl_rt_prfl_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  -- ben_qig_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ben_qig_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
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
    ,p_qua_in_gr_rt_id                        => p_rec.qua_in_gr_rt_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_qig_bus;

/