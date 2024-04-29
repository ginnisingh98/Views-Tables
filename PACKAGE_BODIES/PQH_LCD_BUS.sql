--------------------------------------------------------
--  DDL for Package Body PQH_LCD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_LCD_BUS" as
/* $Header: pqlcdrhi.pkb 115.4 2002/12/03 00:07:48 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_lcd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_level_code_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_level_code_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_de_level_codes and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_level_codes lcd
      --   , EDIT_HERE table_name(s) 333
     where lcd.level_code_id = p_level_code_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'level_code_id'
    ,p_argument_value     => p_level_code_id
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
        => nvl(p_associated_column1,'LEVEL_CODE_ID')
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
  (p_level_code_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_de_level_codes and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqh_de_level_codes lcd
      --   , EDIT_HERE table_name(s) 333
     where lcd.level_code_id = p_level_code_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'level_code_id'
    ,p_argument_value     => p_level_code_id
    );
  --
  if ( nvl(pqh_lcd_bus.g_level_code_id, hr_api.g_number)
       = p_level_code_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_lcd_bus.g_legislation_code;
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
    pqh_lcd_bus.g_level_code_id               := p_level_code_id;
    pqh_lcd_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pqh_lcd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';

--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_lcd_shd.api_updating
      (p_level_code_id                     => p_rec.level_code_id
      ,p_object_version_number             => p_rec.object_version_number
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
 IF nvl(p_rec.level_code, hr_api.g_varchar2) <>
    nvl(pqh_lcd_shd.g_old_rec.level_code, hr_api.g_varchar2) THEN
    hr_utility.set_message(8302, 'PQH_DE_NONUPD_LEVEL_CODE');
      fnd_message.raise_error;
   END IF;



End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_delete
 (p_rec  in pqh_lcd_shd.g_rec_type) is
  l_proc  varchar2(72) := g_package||'Ckh_Delete';
 Cursor Del is
select  '1' from PQH_DE_WRKPLC_VLDTN_LVLNUMS
where     LEVEL_NUMBER_ID  =  pqh_lcd_shd.g_old_rec.LEVEL_NUMBER_ID
and       LEVEL_CODE_ID     = pqh_lcd_shd.g_old_rec.LEVEL_CODE_ID;
 l_Status Varchar2(1);
Begin
Open Del;
Fetch Del into l_Status;
If Del%Found Then
   Close Del;
   hr_utility.set_message(8302, 'PQH_LVLCD_PRE_DEL');
   hr_utility.raise_error;
End If;
Close Del;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_LVLNUMS.LEVEL_CODE_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Delete;
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_LEVEL_NUMBER_ID >----------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_LEVEL_NUMBER_ID
 (p_rec  in pqh_lcd_shd.g_rec_type) is
  l_proc  varchar2(72) := g_package||'Ckh_LEVEL_NUMBER_ID';
 Cursor c_LEVEL_NUMBER_ID is
select  '1' from PQH_DE_LEVEL_NUMBERS a, PQH_DE_LEVEL_codes b
where   a.LEVEL_NUMBER_ID	  = p_rec.LEVEL_NUMBER_ID
and     a.LEVEL_NUMBER_ID         = b.LEVEL_NUMBER_ID
and     b.LEVEL_CODE              = p_rec.level_code;

 l_LEVEL_NUMBER_ID PQH_DE_LEVEL_NUMBERS.LEVEL_NUMBER_ID%TYPE;

Begin
hr_utility.set_location(l_proc, 10);
Open c_LEVEL_NUMBER_ID;
Fetch c_LEVEL_NUMBER_ID into l_LEVEL_NUMBER_ID;
If c_LEVEL_NUMBER_ID%found  Then
   hr_utility.set_message(8302, 'PQH_DE_NOEXIST_LEVEL_NUMBER_ID');
   Close c_LEVEL_NUMBER_ID;
   fnd_message.raise_error;
End If;
Close c_LEVEL_NUMBER_ID;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_LEVEL_NUMBERS.LEVEL_NUMBER_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_LEVEL_NUMBER_ID;
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_Unique_Level_Code >--------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_Unique_Level_Code
  (p_rec   in pqh_lcd_shd.g_rec_type) is
--
Cursor c_Level_Code is
Select  Level_Code
  from  PQH_DE_Level_Codes
 Where  Level_Code = p_rec.Level_Code;
  l_Level_Code PQH_DE_Level_Codes.Level_Code%TYPE;
  l_proc     varchar2(72) := g_package || 'Unique_Level_Code';
Begin
hr_utility.set_location(l_proc, 10);
Open c_Level_Code;
Fetch c_Level_Code into l_Level_Code;
If c_Level_Code%ROWCOUNT > 0 Then
   hr_utility.set_message(8302, 'PQH_DE_DUPVAL_Level_Code');
   Close c_Level_Code;
   fnd_message.raise_error;
End If;
Close c_Level_Code;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_Level_Codes.Level_Code'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Unique_Level_Code;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pqh_lcd_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
Chk_Unique_Level_Code (p_rec);
Chk_LEVEL_NUMBER_ID (p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqh_lcd_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_lcd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
Chk_delete(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_lcd_bus;

/
