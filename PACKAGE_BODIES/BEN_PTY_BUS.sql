--------------------------------------------------------
--  DDL for Package Body BEN_PTY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTY_BUS" as
/* $Header: beptyrhi.pkb 115.7 2002/12/10 15:22:41 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pty_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pl_pcp_typ_id               number         default null;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_pcp_typ_id >------|
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
--   pl_pcp_typ_id PK of record being inserted or updated.
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
Procedure chk_pl_pcp_typ_id(p_pl_pcp_typ_id                      in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_pcp_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pty_shd.api_updating
    (p_pl_pcp_typ_id                   => p_pl_pcp_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_pcp_typ_id,hr_api.g_number)
     <>  ben_pty_shd.g_old_rec.pl_pcp_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_pty_shd.constraint_error('BEN_PL_PCP_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pl_pcp_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pty_shd.constraint_error('BEN_PL_PCP_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_pcp_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_pcp_id >------|
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
--   p_pl_pcp_typ_id PK
--   p_pl_pcp ID of FK column
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
Procedure chk_pl_pcp_id (p_pl_pcp_typ_id          in number,
                            p_pl_pcp_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_pcp_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_pcp a
    where  a.pl_pcp_id = p_pl_pcp_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
 l_api_updating := ben_pty_shd.api_updating
     (p_pl_pcp_typ_id            => p_pl_pcp_typ_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_pcp_id,hr_api.g_number)
     <> nvl(ben_pty_shd.g_old_rec.pl_pcp_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if pl_pcp_id value exists in ben_pl_pcp table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pl_pcp
        -- table.
        --
        ben_pty_shd.constraint_error('BEN_PL_PCP_TYP_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_pcp_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_pcp_typ_id PK of record being inserted or updated.
--   pcp_typ_cd Value of lookup code.
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
Procedure chk_pcp_typ_cd (p_pl_pcp_typ_id                in number,
                            p_pcp_typ_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_typ_cd ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pty_shd.api_updating
    (p_pl_pcp_typ_id                   => p_pl_pcp_typ_id,
     p_object_version_number       => p_object_version_number);
  --
 if p_pcp_typ_cd is null then
      fnd_message.set_name('BEN','BEN_92593_DATA_NULL');
      fnd_message.set_token('FIELD', 'PCP Type');
      fnd_message.raise_error;
  end if;
  if (l_api_updating
      and p_pcp_typ_cd      <>       nvl(ben_pty_shd.g_old_rec.pcp_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PCP_SPCLTY',
           p_lookup_code    => p_pcp_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_typ_cd');
      fnd_message.set_token('TYPE','BEN_PCP_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_typ_cd ;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_gndr_alwd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_pcp_typ_id PK of record being inserted or updated.
--   gndr_alwd_cd Value of lookup code.
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
Procedure chk_gndr_alwd_cd (p_pl_pcp_typ_id                in number,
                            p_gndr_alwd_cd         in varchar2,
                            p_min_age              in number,
                            p_max_age              in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_gndr_alwd_cd ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pty_shd.api_updating
    (p_pl_pcp_typ_id                   => p_pl_pcp_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_gndr_alwd_cd is null and p_min_age is null and p_max_age is null
  then
      fnd_message.set_name('BEN','BEN_92593_DATA_NULL');
      fnd_message.set_token('FIELD', 'Maximum Age or Minimum Age or Gender');
      fnd_message.raise_error;
  end if;
  if (l_api_updating
      and p_gndr_alwd_cd      <>       nvl(ben_pty_shd.g_old_rec.gndr_alwd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_gndr_alwd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'SEX',
           p_lookup_code    => p_gndr_alwd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_gndr_alwd_cd');
      fnd_message.set_token('TYPE','SEX');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_gndr_alwd_cd ;
--
--
-- ----------------------------------------------------------------------------
-- |------<  chk_pl_pcp_typ_record >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check that the ben_pl_pcp_type record could not be created
-- unless the pcp_rpstry_flag = 'Y'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_pcp_id FK of record
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

Procedure chk_pl_pcp_typ_record
          ( p_pl_pcp_id            in   varchar2) is

l_proc     varchar2(72) := g_package|| ' chk_pl_pcp_typ_record';
l_dummy    varchar(30);
--l_name     ben_acty_base_rt_f.name%type ;

--cursor to check the pcp_rpstry_flag
cursor c1 is select pcp_rpstry_flag
       from   ben_pl_pcp
       Where  pl_pcp_id = p_pl_pcp_id;

--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     --- when the rate is imputing chek the plan in imputing
     open c1;
     fetch c1 into l_dummy;
     if c1%found and l_dummy <> 'Y' then
	 fnd_message.set_name('BEN','BEN_92561_RPSTRY_FLG');
       fnd_message.raise_error;
    end if;
    close c1;

  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_pl_pcp_typ_record;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pl_pcp_typ_id                        in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_pl_pcp_typ pty
     where pty.pl_pcp_typ_id = p_pl_pcp_typ_id
       and pbg.business_group_id = pty.business_group_id;
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
    ,p_argument           => 'pl_pcp_typ_id'
    ,p_argument_value     => p_pl_pcp_typ_id
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
  (p_pl_pcp_typ_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ben_pl_pcp_typ pty
     where pty.pl_pcp_typ_id = p_pl_pcp_typ_id
       and pbg.business_group_id = pty.business_group_id;
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
    ,p_argument           => 'pl_pcp_typ_id'
    ,p_argument_value     => p_pl_pcp_typ_id
    );
  --
  if ( nvl(ben_pty_bus.g_pl_pcp_typ_id, hr_api.g_number)
       = p_pl_pcp_typ_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_pty_bus.g_legislation_code;
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
    ben_pty_bus.g_pl_pcp_typ_id     := p_pl_pcp_typ_id;
    ben_pty_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ben_pty_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pl_pcp_typ_id is not null)  and (
    nvl(ben_pty_shd.g_old_rec.pty_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute1, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute2, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute3, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute4, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute5, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute6, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute7, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute8, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute9, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute10, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute11, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute12, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute13, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute14, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute15, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute16, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute17, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute18, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute19, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute20, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute21, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute22, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute23, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute24, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute25, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute26, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute27, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute28, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute29, hr_api.g_varchar2)  or
    nvl(ben_pty_shd.g_old_rec.pty_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute30, hr_api.g_varchar2) ))
    or (p_rec.pl_pcp_typ_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'PTY_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'PTY_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pty_attribute1
      ,p_attribute2_name                 => 'PTY_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pty_attribute2
      ,p_attribute3_name                 => 'PTY_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pty_attribute3
      ,p_attribute4_name                 => 'PTY_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pty_attribute4
      ,p_attribute5_name                 => 'PTY_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pty_attribute5
      ,p_attribute6_name                 => 'PTY_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pty_attribute6
      ,p_attribute7_name                 => 'PTY_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pty_attribute7
      ,p_attribute8_name                 => 'PTY_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pty_attribute8
      ,p_attribute9_name                 => 'PTY_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pty_attribute9
      ,p_attribute10_name                => 'PTY_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pty_attribute10
      ,p_attribute11_name                => 'PTY_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pty_attribute11
      ,p_attribute12_name                => 'PTY_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pty_attribute12
      ,p_attribute13_name                => 'PTY_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pty_attribute13
      ,p_attribute14_name                => 'PTY_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pty_attribute14
      ,p_attribute15_name                => 'PTY_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pty_attribute15
      ,p_attribute16_name                => 'PTY_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pty_attribute16
      ,p_attribute17_name                => 'PTY_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pty_attribute17
      ,p_attribute18_name                => 'PTY_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pty_attribute18
      ,p_attribute19_name                => 'PTY_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pty_attribute19
      ,p_attribute20_name                => 'PTY_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pty_attribute20
      ,p_attribute21_name                => 'PTY_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.pty_attribute21
      ,p_attribute22_name                => 'PTY_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.pty_attribute22
      ,p_attribute23_name                => 'PTY_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.pty_attribute23
      ,p_attribute24_name                => 'PTY_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.pty_attribute24
      ,p_attribute25_name                => 'PTY_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.pty_attribute25
      ,p_attribute26_name                => 'PTY_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.pty_attribute26
      ,p_attribute27_name                => 'PTY_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.pty_attribute27
      ,p_attribute28_name                => 'PTY_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.pty_attribute28
      ,p_attribute29_name                => 'PTY_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.pty_attribute29
      ,p_attribute30_name                => 'PTY_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.pty_attribute30
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
  (p_rec in ben_pty_shd.g_rec_type
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
  IF NOT ben_pty_shd.api_updating
      (p_pl_pcp_typ_id                        => p_rec.pl_pcp_typ_id
      ,p_object_version_number                => p_rec.object_version_number
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ben_pty_shd.g_rec_type ,
   p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  chk_pl_pcp_typ_id(p_pl_pcp_typ_id               =>  p_rec.pl_pcp_typ_id
                 ,p_object_version_number       => p_rec.object_version_number);

  chk_pl_pcp_id(p_pl_pcp_typ_id               =>  p_rec.pl_pcp_typ_id
                 ,p_pl_pcp_id                   => p_rec.pl_pcp_id
                 ,p_object_version_number       => p_rec.object_version_number);

  chk_pcp_typ_cd (p_pl_pcp_typ_id                 => p_rec.pl_pcp_typ_id,
                p_pcp_typ_cd                    => p_rec.pcp_typ_cd,
                p_effective_date                => p_effective_date,
                p_object_version_number         => p_rec.object_version_number);


  chk_gndr_alwd_cd (p_pl_pcp_typ_id                => p_rec.pl_pcp_typ_id,
                  p_gndr_alwd_cd                 => p_rec.gndr_alwd_cd,
                  p_min_age                      => p_rec.min_age,
                  p_max_age                      => p_rec.max_age,
                  p_effective_date               => p_effective_date,
                  p_object_version_number        => p_rec.object_version_number);

  chk_pl_pcp_typ_record ( p_pl_pcp_id   => p_rec.pl_pcp_id);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  --ben_pty_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ben_pty_shd.g_rec_type
  ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_pl_pcp_typ_id(p_pl_pcp_typ_id               =>  p_rec.pl_pcp_typ_id
                 ,p_object_version_number       => p_rec.object_version_number);

  chk_pl_pcp_id(p_pl_pcp_typ_id               =>  p_rec.pl_pcp_typ_id
                 ,p_pl_pcp_id                   => p_rec.pl_pcp_id
                 ,p_object_version_number       => p_rec.object_version_number);

  chk_pcp_typ_cd (p_pl_pcp_typ_id                 => p_rec.pl_pcp_typ_id,
                p_pcp_typ_cd                    => p_rec.pcp_typ_cd,
                p_effective_date                => p_effective_date,
                p_object_version_number         => p_rec.object_version_number);


  chk_gndr_alwd_cd (p_pl_pcp_typ_id                => p_rec.pl_pcp_typ_id,
                  p_gndr_alwd_cd                 => p_rec.gndr_alwd_cd,
                  p_min_age                      => p_rec.min_age,
                  p_max_age                      => p_rec.max_age,
                  p_effective_date               => p_effective_date,
                  p_object_version_number        => p_rec.object_version_number);

  chk_pl_pcp_typ_record ( p_pl_pcp_id   => p_rec.pl_pcp_id);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  --ben_pty_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_pty_shd.g_rec_type
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
end ben_pty_bus;

/
