--------------------------------------------------------
--  DDL for Package Body OTA_THG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_THG_BUS" as
/* $Header: otthgrhi.pkb 120.0 2005/05/29 07:44:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_thg_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_gl_default_segment_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_gl_default_segment_id                in number
  ) is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- ota_hr_gl_flex_maps and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , ota_hr_gl_flex_maps thg
         , ota_cross_charges   tcc
      where tcc.cross_charge_id = thg.cross_charge_id and
        thg.gl_default_segment_id = p_gl_default_segment_id and
       pbg.business_group_id = tcc.business_group_id;
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
    ,p_argument           => 'gl_default_segment_id'
    ,p_argument_value     => p_gl_default_segment_id
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
  (p_gl_default_segment_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- ota_hr_gl_flex_maps and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
        , ota_hr_gl_flex_maps thg
        , ota_cross_charges   tcc
    where tcc. Cross_charge_id  = thg.cross_charge_id and
        thg.gl_default_segment_id = p_gl_default_segment_id and
      pbg.business_group_id = tcc.business_group_id;
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
    ,p_argument           => 'gl_default_segment_id'
    ,p_argument_value     => p_gl_default_segment_id
    );
  --
  if ( nvl(ota_thg_bus.g_gl_default_segment_id, hr_api.g_number)
       = p_gl_default_segment_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_thg_bus.g_legislation_code;
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
    ota_thg_bus.g_gl_default_segment_id := p_gl_default_segment_id;
    ota_thg_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  ,p_rec in ota_thg_shd.g_rec_type
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
  IF NOT ota_thg_shd.api_updating
      (p_gl_default_segment_id                => p_rec.gl_default_segment_id
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

-- ----------------------------------------------------------------------------
-- |----------------------<  chk_hr_data_source  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_hr_data_source
  (p_gl_default_segment_id		in number
   ,p_hr_data_source	 	      in varchar2
   ,p_effective_date			in date) is

--
  l_proc  varchar2(72) := g_package||'chk_hr_data_source';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);


  if (((p_gl_default_segment_id is not null) and
        nvl(ota_thg_shd.g_old_rec.hr_data_source,hr_api.g_varchar2) <>
        nvl(p_hr_data_source,hr_api.g_varchar2))
     or
       (p_gl_default_segment_id is null)) then

       hr_utility.set_location(' entering:'||l_proc, 20);
       --
       -- if HR_data_source is not null then
       -- check if the hr_data_source value exists in hr_lookups
	 -- where lookup_type is 'OTA_CROSS_CHARGE_TABLE'
       --
       if p_hr_data_source is not null then
          if hr_api.not_exists_in_hrstanlookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_CROSS_CHARGE_TABLE'
              ,p_lookup_code => p_hr_data_source) then
              fnd_message.set_name('OTA','OTA_13225_THG_SOURCE_INVALID');
               fnd_message.raise_error;
          end if;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       end if;

   end if;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_hr_data_source;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_thg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  --
  ota_tcc_bus.set_security_group_id(p_rec.cross_charge_id);

  chk_hr_data_source
  (p_gl_default_segment_id	 => p_rec.gl_default_segment_id
   ,p_hr_data_source	       => p_rec.hr_data_source
   ,p_effective_date		 =>p_effective_date);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_thg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
    --
  ota_tcc_bus.set_security_group_id(p_rec.cross_charge_id);

  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

   chk_hr_data_source
  (p_gl_default_segment_id	 => p_rec.gl_default_segment_id
   ,p_hr_data_source	       => p_rec.hr_data_source
   ,p_effective_date		 =>p_effective_date);

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_thg_shd.g_rec_type
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
end ota_thg_bus;

/
