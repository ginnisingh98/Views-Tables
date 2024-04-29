--------------------------------------------------------
--  DDL for Package Body BEN_CWG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWG_BUS" as
/* $Header: becwgrhi.pkb 120.0 2005/05/28 01:29:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cwg_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cwb_wksht_grp_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cwb_wksht_grp_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_cwb_wksht_grp cwg
     where cwg.cwb_wksht_grp_id = p_cwb_wksht_grp_id
       and pbg.business_group_id = cwg.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cwb_wksht_grp_id'
    ,p_argument_value     => p_cwb_wksht_grp_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'CWB_WKSHT_GRP_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_cwb_wksht_grp_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_cwb_wksht_grp cwg
     where cwg.cwb_wksht_grp_id = p_cwb_wksht_grp_id
       and pbg.business_group_id = cwg.business_group_id;
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
    ,p_argument           => 'cwb_wksht_grp_id'
    ,p_argument_value     => p_cwb_wksht_grp_id
    );
  --
  if ( nvl(ben_cwg_bus.g_cwb_wksht_grp_id, hr_api.g_number)
       = p_cwb_wksht_grp_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_cwg_bus.g_legislation_code;
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
    ben_cwg_bus.g_cwb_wksht_grp_id            := p_cwb_wksht_grp_id;
    ben_cwg_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ben_cwg_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.cwb_wksht_grp_id is not null)  and (
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute1, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute2, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute3, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute4, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute5, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute6, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute7, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute8, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute9, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute10, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute11, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute12, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute13, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute14, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute15, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute16, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute17, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute18, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute19, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute20, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute21, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute22, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute23, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute24, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute25, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute26, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute27, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute28, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute29, hr_api.g_varchar2)  or
    nvl(ben_cwg_shd.g_old_rec.cwg_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.cwg_attribute30, hr_api.g_varchar2)
    ))
    or (p_rec.cwb_wksht_grp_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'CWG_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'CWG_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.cwg_attribute1
      ,p_attribute2_name                 => 'CWG_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.cwg_attribute2
      ,p_attribute3_name                 => 'CWG_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.cwg_attribute3
      ,p_attribute4_name                 => 'CWG_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.cwg_attribute4
      ,p_attribute5_name                 => 'CWG_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.cwg_attribute5
      ,p_attribute6_name                 => 'CWG_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.cwg_attribute6
      ,p_attribute7_name                 => 'CWG_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.cwg_attribute7
      ,p_attribute8_name                 => 'CWG_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.cwg_attribute8
      ,p_attribute9_name                 => 'CWG_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.cwg_attribute9
      ,p_attribute10_name                => 'CWG_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.cwg_attribute10
      ,p_attribute11_name                => 'CWG_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.cwg_attribute11
      ,p_attribute12_name                => 'CWG_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.cwg_attribute12
      ,p_attribute13_name                => 'CWG_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.cwg_attribute13
      ,p_attribute14_name                => 'CWG_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.cwg_attribute14
      ,p_attribute15_name                => 'CWG_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.cwg_attribute15
      ,p_attribute16_name                => 'CWG_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.cwg_attribute16
      ,p_attribute17_name                => 'CWG_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.cwg_attribute17
      ,p_attribute18_name                => 'CWG_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.cwg_attribute18
      ,p_attribute19_name                => 'CWG_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.cwg_attribute19
      ,p_attribute20_name                => 'CWG_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.cwg_attribute20
      ,p_attribute21_name                => 'CWG_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.cwg_attribute21
      ,p_attribute22_name                => 'CWG_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.cwg_attribute22
      ,p_attribute23_name                => 'CWG_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.cwg_attribute23
      ,p_attribute24_name                => 'CWG_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.cwg_attribute24
      ,p_attribute25_name                => 'CWG_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.cwg_attribute25
      ,p_attribute26_name                => 'CWG_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.cwg_attribute26
      ,p_attribute27_name                => 'CWG_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.cwg_attribute27
      ,p_attribute28_name                => 'CWG_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.cwg_attribute28
      ,p_attribute29_name                => 'CWG_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.cwg_attribute29
      ,p_attribute30_name                => 'CWG_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.cwg_attribute30
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
  (p_effective_date               in date
  ,p_rec in ben_cwg_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_cwg_shd.api_updating
      (p_cwb_wksht_grp_id                  => p_rec.cwb_wksht_grp_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(ben_cwg_shd.g_old_rec.business_group_id,hr_api.g_number) then

     hr_api.argument_changed_error
     (p_api_name      => l_proc,
      p_argument      => 'BUSINESS_GROUP_ID',
      p_base_table    => ben_cwg_shd.g_tab_nam);
  END IF;
  --
  IF nvl(p_rec.pl_id,hr_api.g_number) <>
     nvl(ben_cwg_shd.g_old_rec.pl_id,hr_api.g_number) then

     hr_api.argument_changed_error
     (p_api_name      => l_proc,
      p_argument      => 'PL_ID',
      p_base_table    => ben_cwg_shd.g_tab_nam);
  END IF;

End chk_non_updateable_args;
--

/*
Procedure chk_status_cd(p_cwb_wksht_grp_id            in number,
                          p_status_cd                   in varchar2,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_status_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cwg_shd.api_updating
         (p_cwb_wksht_grp_id           => p_cwb_wksht_grp_id,
          p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_status_cd <>
          nvl(ben_cwg_shd.g_old_rec.status_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CWG_STAT',
           p_lookup_code    => p_status_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_status_cd '||p_status_cd);
      fnd_message.set_token('TYPE','BEN_CWG_STAT');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ;
*/

---

Procedure chk_hidden_cd(p_cwb_wksht_grp_id       in number
                          ,p_hidden_cd        in varchar2
                          ,p_effective_date          in date
                          ,p_object_version_number   in number
                         ) is
  l_proc         varchar2(72) := g_package||'chk_hidden_cd';
  l_api_updating boolean;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cwg_shd.api_updating
    (p_cwb_wksht_grp_id           => p_cwb_wksht_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_hidden_cd
          <> nvl(ben_cwg_shd.g_old_rec.hidden_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_hidden_cd is not null then
       if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WS_ACC',
           p_lookup_code    => p_hidden_cd,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'p_hidden_cd');
        fnd_message.set_token('VALUE', p_hidden_cd);
        fnd_message.set_token('TYPE','BEN_WS_ACC');
        fnd_message.raise_error;
        --
      end if;
   end if ;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_hidden_cd;
--




--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_ordr_num >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if display on enrollment check box
--   is selected and the Plan Type display code for self service is assigned
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cwb_wksht_grp_id              PK of record being inserted or updated.
--   object_version_number         Object version number of record being
--                                 inserted or updated.
--   p_business_group_id           Business group id
--   p_ordr_num                    Ordr_num
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
Procedure chk_ordr_num(p_cwb_wksht_grp_id              in number,
                       p_object_version_number         in number,
                       p_pl_id                         in number,
                       p_business_group_id             in number,
                       p_ordr_num                      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ordr_num';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor c_cwg is
  select 1
  from   ben_cwb_wksht_grp cwg
  where  cwg.cwb_wksht_grp_id <> nvl(p_cwb_wksht_grp_id,-9999)
  and    pl_id = p_pl_id
  and    cwg.ordr_num = p_ordr_num
  and    cwg.business_group_id = p_business_group_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cwg_shd.api_updating
    (p_cwb_wksht_grp_id            => p_cwb_wksht_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ordr_num
      <> nvl(ben_cwg_shd.g_old_rec.ordr_num,hr_api.g_number)
      or not l_api_updating)
      and p_ordr_num is not null then
    --
    open  c_cwg;
    fetch c_cwg into l_dummy;
    close c_cwg;

    if l_dummy = 1 then
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
    end if;
  end if;
end chk_ordr_num;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_uniq_label >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if display on enrollment check box
--   is selected and the Plan Type display code for self service is assigned
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cwb_wksht_grp_id              PK of record being inserted or updated.
--   object_version_number         Object version number of record being
--                                 inserted or updated.
--   p_business_group_id           Business group id
--   p_label                       Label
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
Procedure chk_uniq_label(p_cwb_wksht_grp_id            in number,
                       p_object_version_number         in number,
                       p_pl_id                         in number,
                       p_business_group_id             in number,
                       p_label                         in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_uniq_label';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor c_cwg is
  select 1
  from   ben_cwb_wksht_grp cwg
  where  cwg.cwb_wksht_grp_id <> nvl(p_cwb_wksht_grp_id,-9999)
  and    pl_id = p_pl_id
  and    upper(cwg.label) = upper(p_label)
  and    cwg.business_group_id = p_business_group_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cwg_shd.api_updating
    (p_cwb_wksht_grp_id            => p_cwb_wksht_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_label
      <> nvl(ben_cwg_shd.g_old_rec.label,hr_api.g_varchar2)
      or not l_api_updating)
      and p_label is not null then
    --
    open  c_cwg;
    fetch c_cwg into l_dummy;
    close c_cwg;

    if l_dummy = 1 then
      fnd_message.set_name('BEN','BEN_93316_LABEL_NOT_UNIQUE');
      fnd_message.raise_error;
    end if;
  end if;
end chk_uniq_label;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_lookup_cd >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the lookup code is valid
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cwb_wksht_grp_id              PK of record being inserted or updated.
--   object_version_number         Object version number of record being
--                                 inserted or updated.
--   p_business_group_id           Business group id
--   p_wksht_grp_cd                WorkSheet Group Code
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
Procedure chk_lookup_cd(p_cwb_wksht_grp_id            in number,
                        p_object_version_number       in number,
                        p_effective_date              in date,
                        p_wksht_grp_cd                in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_lookup_cd';
  l_api_updating boolean;
  l_dummy        number;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cwg_shd.api_updating
    (p_cwb_wksht_grp_id            => p_cwb_wksht_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wksht_grp_cd
      <> nvl(ben_cwg_shd.g_old_rec.wksht_grp_cd,hr_api.g_number)
      or not l_api_updating)
      and p_wksht_grp_cd is not null then
    --
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WKSHT_GRP',
           p_lookup_code    => p_wksht_grp_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_wksht_grp_cd');
      fnd_message.set_token('VALUE', p_wksht_grp_cd);
      fnd_message.set_token('TYPE','BEN_WKSHT_GRP');
      fnd_message.raise_error;
      --
    end if;

  end if;
end chk_lookup_cd;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_cwg_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_ordr_num(p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
               p_object_version_number => p_rec.object_version_number,
               p_pl_id                 => p_rec.pl_id,
               p_business_group_id     => p_rec.business_group_id,
               p_ordr_num              => p_rec.ordr_num);
  --
  chk_uniq_label(p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
               p_object_version_number => p_rec.object_version_number,
               p_pl_id                 => p_rec.pl_id,
               p_business_group_id     => p_rec.business_group_id,
               p_label                 => p_rec.label);
  --
  chk_lookup_cd(p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
               p_object_version_number => p_rec.object_version_number,
               p_effective_date        => p_effective_date,
               p_wksht_grp_cd          => p_rec.wksht_grp_cd);
  --
  chk_hidden_cd
  (p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
   p_hidden_cd           => p_rec.hidden_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  /*
  chk_status_cd
  (p_cwb_wksht_grp_id        => p_rec.cwb_wksht_grp_id,
   p_status_cd               => p_rec.status_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
 */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_cwg_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date    => p_effective_date
      ,p_rec              => p_rec
    );
  --
  chk_ordr_num(p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
               p_object_version_number => p_rec.object_version_number,
               p_pl_id                 => p_rec.pl_id,
               p_business_group_id     => p_rec.business_group_id,
               p_ordr_num              => p_rec.ordr_num);
  --
  chk_uniq_label(p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
               p_object_version_number => p_rec.object_version_number,
               p_pl_id                 => p_rec.pl_id,
               p_business_group_id     => p_rec.business_group_id,
               p_label                 => p_rec.label);
  --
  chk_lookup_cd(p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
               p_object_version_number => p_rec.object_version_number,
               p_effective_date        => p_effective_date,
               p_wksht_grp_cd          => p_rec.wksht_grp_cd);
  --
  chk_hidden_cd
  (p_cwb_wksht_grp_id      => p_rec.cwb_wksht_grp_id,
   p_hidden_cd           => p_rec.hidden_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  /*
   chk_status_cd
  (p_cwb_wksht_grp_id        => p_rec.cwb_wksht_grp_id,
   p_status_cd               => p_rec.status_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_cwg_bus;

/
