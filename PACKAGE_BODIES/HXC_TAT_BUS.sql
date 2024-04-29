--------------------------------------------------------
--  DDL for Package Body HXC_TAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TAT_BUS" as
/* $Header: hxtatrhi.pkb 120.2 2005/09/23 07:03:57 rchennur noship $ */
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
g_package  varchar2(33)	:= '  hxc_tat_bus.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
-- the following two global variables are only to be
-- used by the return_legislation_code function.

g_legislation_code            varchar2(150)  default null;
g_time_attribute_id           number         default null;

--  -------------------------------------------------------------------------
--  |----------------------< set_security_group_id >------------------------|
--  -------------------------------------------------------------------------
procedure set_security_group_id
  (p_time_attribute_id in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_time_attributes and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_time_attributes tat
      --   , EDIT_HERE table_name(s) 333
     where tat.time_attribute_id = p_time_attribute_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  ;
  --
begin
  --
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc :=  g_package||'set_security_group_id';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'time_attribute_id'
    ,p_argument_value     => p_time_attribute_id
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
  if g_debug then
  	hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end set_security_group_id;
--
--  -------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-----------------------|
--  -------------------------------------------------------------------------
--
Function return_legislation_code
  (p_time_attribute_id                    in     number
  )
  return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_time_attributes and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_time_attributes tat
      --   , EDIT_HERE table_name(s) 333
     where tat.time_attribute_id = p_time_attribute_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  ;
  --
begin
  --
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc :=  g_package||'return_legislation_code';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'time_attribute_id'
    ,p_argument_value     => p_time_attribute_id
    );
  --
  if ( nvl(hxc_tat_bus.g_time_attribute_id, hr_api.g_number)
       = p_time_attribute_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_tat_bus.g_legislation_code;
    if g_debug then
    	  hr_utility.set_location(l_proc, 20);
    end if;
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
    if g_debug then
    	  hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hxc_tat_bus.g_time_attribute_id := p_time_attribute_id;
    hxc_tat_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
  	hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
  return l_legislation_code;
end return_legislation_code;

-- --------------------------------------------------------------------------
-- |------------------------------< chk_df >--------------------------------|
-- --------------------------------------------------------------------------
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
--   if the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   if the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- --------------------------------------------------------------------------
procedure chk_df
  (p_rec in hxc_tat_shd.g_rec_type
  ) is

l_proc   varchar2(72) ;

begin

  if g_debug then
  	l_proc := g_package || 'chk_df';
  	hr_utility.set_location('Entering:'||l_proc,10);
  end if;

  if ((p_rec.time_attribute_id is not null)  and (
    nvl(hxc_tat_shd.g_old_rec.time_attribute_id, hr_api.g_varchar2) <>
    nvl(p_rec.time_attribute_id, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hxc_tat_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.time_attribute_id is null) then

    -- only execute the validation if absolutely necessary:
    -- a) during update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) during insert.
 /*
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HXC'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
      );
  */null;
  end if;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc,20);
  end if;

end chk_df;

-- --------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >----------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. if an attribute has been updated an error is generated.
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
--   processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure chk_non_updateable_args
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  ) is

l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
l_error    exception;
l_argument varchar2(30);

begin

  -- only proceed with the validation if a row exists for the current
  -- record in the HR Schema.

  if not hxc_tat_shd.api_updating
      (p_time_attribute_id     => p_rec.time_attribute_id
      ,p_object_version_number => p_rec.object_version_number
      ) then
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  end if;

  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.

exception
  when l_error then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => l_argument);
  when others then
    raise;

end chk_non_updateable_args;

-- --------------------------------------------------------------------------
-- |---------------------------< insert_validate >--------------------------|
-- --------------------------------------------------------------------------
procedure insert_validate
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  ) is

  l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call all supporting business operations

  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."

  hxc_tat_bus.chk_df(p_rec);

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end insert_validate;

-- --------------------------------------------------------------------------
-- |---------------------------< update_validate >--------------------------|
-- --------------------------------------------------------------------------
procedure update_validate
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'update_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call all supporting business operations

  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."

  chk_non_updateable_args
    (p_effective_date => p_effective_date
      ,p_rec          => p_rec
    );

  hxc_tat_bus.chk_df(p_rec);

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end update_validate;

-- --------------------------------------------------------------------------
-- |---------------------------< delete_validate >--------------------------|
-- --------------------------------------------------------------------------
procedure delete_validate
  (p_rec in hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'delete_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call all supporting business operations

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end delete_validate;

end hxc_tat_bus;

/
