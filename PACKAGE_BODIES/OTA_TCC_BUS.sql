--------------------------------------------------------
--  DDL for Package Body OTA_TCC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TCC_BUS" as
/* $Header: ottccrhi.pkb 120.1 2005/09/01 07:26:31 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tcc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cross_charge_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cross_charge_id                      in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ota_cross_charges tcc
     where tcc.cross_charge_id = p_cross_charge_id
       and pbg.business_group_id = tcc.business_group_id;
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
    ,p_argument           => 'cross_charge_id'
    ,p_argument_value     => p_cross_charge_id
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
  (p_cross_charge_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ota_cross_charges tcc
     where tcc.cross_charge_id = p_cross_charge_id
       and pbg.business_group_id = tcc.business_group_id;
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
    ,p_argument           => 'cross_charge_id'
    ,p_argument_value     => p_cross_charge_id
    );
  --
  if ( nvl(ota_tcc_bus.g_cross_charge_id, hr_api.g_number)
       = p_cross_charge_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_tcc_bus.g_legislation_code;
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
    ota_tcc_bus.g_cross_charge_id   := p_cross_charge_id;
    ota_tcc_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_tcc_shd.g_rec_type
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
  IF NOT ota_tcc_shd.api_updating
      (p_cross_charge_id                      => p_rec.cross_charge_id
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
-- |-----------------------< chk_overlap_cc_def>------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_overlap_cc_def
(p_cross_charge_id    in number
 ,p_start_date_active  in date
 ,p_end_date_active    in date
 ,p_gl_set_of_books_id    in number
 ,p_from_to            in varchar2
 ,p_type               in varchar2
 ,p_business_group_id  in number
) IS
 l_proc  varchar2(72) := g_package||'chk_overlap_cc_def';
  l_exists	varchar2(1);

CURSOR TCC IS
SELECT null
FROM OTA_CROSS_CHARGES
WHERE cross_charge_id <> nvl(p_cross_charge_id,0) and
      Business_group_id = p_business_group_id and
      gl_Set_of_books_id   = p_gl_set_of_books_id and
      From_to = p_from_to and
      type    = p_type  and
      (p_start_date_active  between start_date_active and nvl(end_date_active, hr_api.g_eot)      or
      nvl(p_end_date_active,hr_api.g_eot)  between start_date_active and nvl(end_date_active, hr_api.g_eot));
-- bug no 4587140
/*          ((start_date_active <= p_start_date_active and
          start_date_active <=  nvl(end_date_active,hr_api.g_date) ) or
          (start_date_active >= p_start_date_active and
          nvl(p_end_date_active,hr_api.g_eot) >= start_date_active ));

*/
 /*      ((start_date_active <= p_start_date_active and
          nvl(end_date_active,hr_api.g_date) >= nvl(p_end_date_active,hr_api.g_date)) or
          (start_date_active >= p_start_date_active and
           start_date_active <= nvl(p_end_date_active,hr_api.g_eot)) or
          (start_date_active <= p_start_date_active and
          nvl(end_date_active,hr_api.g_date) <= nvl(p_end_date_active,hr_api.g_date) and
          nvl(end_date_active,hr_api.g_date) >= p_start_date_active ))  ; */

Begin
       hr_utility.set_location(' entering:'||l_proc, 10);

if (((p_cross_charge_id is not null) and
      (nvl(ota_tcc_shd.g_old_rec.start_date_active,hr_api.g_date) <>
         nvl(p_start_date_active,hr_api.g_date) or
         nvl(ota_tcc_shd.g_old_rec.end_date_active,hr_api.g_date) <>
         nvl(p_end_date_active,hr_api.g_date)) )
   or (p_cross_charge_id is null)) then

   If ota_tcc_shd.g_old_rec.end_date_active is not null and
      nvl(p_end_date_active,hr_api.g_date) >
      ota_tcc_shd.g_old_rec.end_date_active then

      fnd_message.set_name('OTA','OTA_13348_TCC_EXT_END_DATE');
      fnd_message.raise_error;

   end if;
   OPEN TCC;
   FETCH TCC INTO l_exists;
   IF TCC%found then
      fnd_message.set_name('OTA','OTA_13330_TCC_DATE_OVERLAP');
      fnd_message.raise_error;
   END IF;
   CLOSE TCC;


end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);

  --
end  chk_overlap_cc_def;


-- ----------------------------------------------------------------------------
-- |-------------------------< chk_end_date_ext>------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_end_date_ext
(p_cross_charge_id    in number
 ,p_end_date_active    in date
) IS
 l_proc  varchar2(72) := g_package||'chk_end_date_ext';
  l_exists	varchar2(1);

Begin
       hr_utility.set_location(' entering:'||l_proc, 10);

if (((p_cross_charge_id is not null) and
         (nvl(ota_tcc_shd.g_old_rec.end_date_active,hr_api.g_date) <>
         nvl(p_end_date_active,hr_api.g_date)))
   or (p_cross_charge_id is null)) then

   If ota_tcc_shd.g_old_rec.end_date_active is not null and
      nvl(p_end_date_active,hr_api.g_date) >
      ota_tcc_shd.g_old_rec.end_date_active then

      fnd_message.set_name('OTA','OTA_13348_TCC_EXT_END_DATE');
      fnd_message.raise_error;

   end if;


end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);

  --
end  chk_end_date_ext;


-- ----------------------------------------------------------------------------
-- |------------------------------<  chk_type  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_type
  (p_cross_charge_id			in number
   ,p_type	 		       	in varchar2
   ,p_effective_date			in date) is

--
  l_proc  varchar2(72) := g_package||'chk_type';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);


  if (((p_cross_charge_id is not null) and
        nvl(ota_tcc_shd.g_old_rec.type,hr_api.g_varchar2) <>
        nvl(p_type,hr_api.g_varchar2))
     or
       (p_cross_charge_id is null)) then

       hr_utility.set_location(' entering:'||l_proc, 20);
       --
       -- if type is not null then
       -- check if the type value exists in hr_lookups
	 -- where lookup_type is 'OTA_CROSS_CHARGE_TYPE'
       --
       if p_type is not null then
          if hr_api.not_exists_in_hrstanlookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_CROSS_CHARGE_TYPE'
              ,p_lookup_code => p_type) then
              fnd_message.set_name('OTA','OTA_13334_TCC_TYPE_INVALID');
               fnd_message.raise_error;
          end if;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       end if;

   end if;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_type;


-- ----------------------------------------------------------------------------
-- |------------------------------<  chk_from_to  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_from_to
  (p_cross_charge_id			in number
   ,p_from_to	 		      in varchar2
   ,p_effective_date			in date) is

--
  l_proc  varchar2(72) := g_package||'chk_from_to';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);


  if (((p_cross_charge_id is not null) and
        nvl(ota_tcc_shd.g_old_rec.from_to,hr_api.g_varchar2) <>
        nvl(p_from_to,hr_api.g_varchar2))
     or
       (p_cross_charge_id is null)) then

       hr_utility.set_location(' entering:'||l_proc, 20);
       --
       -- if From_to is not null then
       -- check if the from_to value exists in hr_lookups
	 -- where lookup_type is 'OTA_CROSS_CHARGE_FROM_TO'
       --
       if p_from_to is not null then
          if hr_api.not_exists_in_hrstanlookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_CROSS_CHARGE_FROM_TO'
              ,p_lookup_code => p_from_to) then
              fnd_message.set_name('OTA','OTA_13341_TCC_FROM_TO_INVALID');
               fnd_message.raise_error;
          end if;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       end if;

   end if;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_from_to;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_tcc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
 chk_overlap_cc_def
 (p_cross_charge_id    =>p_rec.cross_charge_id
 ,p_start_date_active  =>p_rec.start_date_active
 ,p_end_date_active    =>p_rec.end_date_active
 ,p_gl_set_of_books_id    =>p_rec.gl_set_of_books_id
 ,p_from_to            =>p_rec.from_to
 ,p_type               =>p_rec.type
 ,p_business_group_id  =>p_rec.business_group_id);


 chk_from_to
  (p_cross_charge_id	=> p_rec.cross_charge_id
   ,p_from_to	      => p_rec.from_to
   ,p_effective_date    => p_effective_date);

 chk_type
  (p_cross_charge_id	=> p_rec.cross_charge_id
   ,p_type	      	=> p_rec.type
   ,p_effective_date    => p_effective_date);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_tcc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
      ,p_rec              => p_rec
    );

  chk_overlap_cc_def
 (p_cross_charge_id    =>p_rec.cross_charge_id
 ,p_start_date_active  =>p_rec.start_date_active
 ,p_end_date_active    =>p_rec.end_date_active
 ,p_gl_set_of_books_id    =>p_rec.gl_set_of_books_id
 ,p_from_to            =>p_rec.from_to
 ,p_type               =>p_rec.type
 ,p_business_group_id  =>p_rec.business_group_id);

 chk_end_date_ext
 (p_cross_charge_id    =>p_rec.cross_charge_id
 ,p_end_date_active    =>p_rec.end_date_active);

chk_from_to
  (p_cross_charge_id	=> p_rec.cross_charge_id
   ,p_from_to	      => p_rec.from_to
   ,p_effective_date    => p_effective_date);

 chk_type
  (p_cross_charge_id	=> p_rec.cross_charge_id
   ,p_type	      	=> p_rec.type
   ,p_effective_date    => p_effective_date);

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_tcc_shd.g_rec_type
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
end ota_tcc_bus;

/
