--------------------------------------------------------
--  DDL for Package Body PQH_LVL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_LVL_BUS" as
/* $Header: pqlvlrhi.pkb 115.2 2002/12/03 00:08:45 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_lvl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_wrkplc_vldtn_lvlnum_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_wrkplc_vldtn_lvlnum_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_wrkplc_vldtn_lvlnums lvl
     where lvl.wrkplc_vldtn_lvlnum_id = p_wrkplc_vldtn_lvlnum_id
       and pbg.business_group_id = lvl.business_group_id;
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
    ,p_argument           => 'wrkplc_vldtn_lvlnum_id'
    ,p_argument_value     => p_wrkplc_vldtn_lvlnum_id
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
        => nvl(p_associated_column1,'WRKPLC_VLDTN_LVLNUM_ID')
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
  (p_wrkplc_vldtn_lvlnum_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_de_wrkplc_vldtn_lvlnums lvl
     where lvl.wrkplc_vldtn_lvlnum_id = p_wrkplc_vldtn_lvlnum_id
       and pbg.business_group_id = lvl.business_group_id;
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
    ,p_argument           => 'wrkplc_vldtn_lvlnum_id'
    ,p_argument_value     => p_wrkplc_vldtn_lvlnum_id
    );
  --
  if ( nvl(pqh_lvl_bus.g_wrkplc_vldtn_lvlnum_id, hr_api.g_number)
       = p_wrkplc_vldtn_lvlnum_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_lvl_bus.g_legislation_code;
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
    pqh_lvl_bus.g_wrkplc_vldtn_lvlnum_id      := p_wrkplc_vldtn_lvlnum_id;
    pqh_lvl_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_lvl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_lvl_shd.api_updating
      (p_wrkplc_vldtn_lvlnum_id            => p_rec.wrkplc_vldtn_lvlnum_id
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
End chk_non_updateable_args;

Procedure chk_Lvl_Num
  (p_Level_Number_Id in Number)  IS
--
  l_proc     varchar2(72) := g_package || 'chk_Lvl_Num';
--
 Cursor Lvlnum is
 Select '1'
 From PQH_DE_LEVEL_NUMBERS
 Where LEVEL_NUMBER_ID = p_Level_Number_Id;
 l_Result     Varchar2(1);
Begin
 Open Lvlnum;
 Fetch Lvlnum into  l_Result;
 If Lvlnum%NOTFOUND Then
    Close Lvlnum;
    hr_utility.set_message(8302,'PQH_DE_LVLNUM_VALDTN_LVL');
    hr_utility.raise_error;
 End If;
 Close Lvlnum;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_LVLNUMS.LEVEL_NUMBER_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End chk_Lvl_Num;

Procedure chk_Lvl_Code
  (p_rec  in pqh_lvl_shd.g_rec_type)  IS
--
  l_proc     varchar2(72) := g_package || 'chk_Lvl_Code';
--
 Cursor Lvlcode is
 Select '1'
 From PQH_DE_LEVEL_CODES
 Where LEVEL_NUMBER_ID = p_Rec.Level_Number_Id and
       Level_Code_Id   = p_Rec.Level_Code_Id;

 l_Result     Varchar2(1);
Begin
 Open LvlCode;
 Fetch LvlCode into  l_Result;
 If Lvlcode%NOTFOUND Then
    Close Lvlcode;
    hr_utility.set_message(8302,'PQH_DE_LVLCOD_VALDTN_LVL');
    hr_utility.raise_error;
 End If;
 Close Lvlcode;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_LVLNUMS.LEVEL_CODE_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End chk_Lvl_Code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_lvl_shd.g_rec_type
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
    ,p_associated_column1 => pqh_lvl_shd.g_tab_nam
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
  chk_Lvl_Num(p_Rec.Level_Number_Id);

  chk_Lvl_Code(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_lvl_shd.g_rec_type
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
    ,p_associated_column1 => pqh_lvl_shd.g_tab_nam
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
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

  chk_Lvl_Num(p_Rec.Level_Number_Id);

  chk_Lvl_Code(p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_lvl_shd.g_rec_type
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
end pqh_lvl_bus;

/
