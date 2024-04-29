--------------------------------------------------------
--  DDL for Package Body PQH_CGN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CGN_BUS" as
/* $Header: pqcgnrhi.pkb 115.7 2002/11/27 04:43:27 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cgn_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_case_group_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_case_group_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_case_groups cgn
     where cgn.case_group_id     = p_case_group_id
       and pbg.business_group_id = cgn.business_group_id;
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
    ,p_argument           => 'case_group_id'
    ,p_argument_value     => p_case_group_id
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
        => nvl(p_associated_column1,'CASE_GROUP_ID')
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
  (p_case_group_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_de_case_groups cgn
     where cgn.case_group_id = p_case_group_id
       and pbg.business_group_id (+) = cgn.business_group_id;
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
    ,p_argument           => 'case_group_id'
    ,p_argument_value     => p_case_group_id
    );
  --
  if ( nvl(pqh_cgn_bus.g_case_group_id, hr_api.g_number)
       = p_case_group_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_cgn_bus.g_legislation_code;
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
    pqh_cgn_bus.g_case_group_id               := p_case_group_id;
    pqh_cgn_bus.g_legislation_code            := l_legislation_code;
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
  ,p_rec in pqh_cgn_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_cgn_shd.api_updating
      (p_case_group_id                     => p_rec.case_group_id
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



IF nvl(p_rec.CASE_GROUP_NUMBER, hr_api.g_varchar2) <>
    nvl(pqh_cgn_shd.g_old_rec.CASE_GROUP_NUMBER, hr_api.g_varchar2) THEN
      hr_utility.set_message(8302, 'PQH_DE_CSGRP_NUMBER');
      fnd_message.raise_error;
    END IF;


  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_ADVANCEMENT_TO >--------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_ADVANCEMENT_TO
  (p_rec   in pqh_cgn_shd.g_rec_type) is
--
Cursor c_case_group_NUMBER is
Select  case_group_NUMBER
  from  PQH_DE_case_groupS
 Where  case_group_NUMBER = p_rec.ADVANCEMENT_TO;

l_case_group_NUMBER PQH_DE_case_groupS.case_group_NUMBER%TYPE;
l_proc     varchar2(72) := g_package || 'Chk_case_group_NUMBER';
Begin
hr_utility.set_location(l_proc, 10);
Open c_case_group_NUMBER;
Fetch c_case_group_NUMBER into l_case_group_NUMBER;
If c_case_group_NUMBER%ROWCOUNT = 0 Then
   hr_utility.set_message(8302, 'PQH_DE_NO_EXIST_CASE_GROUP');
   Close c_case_group_NUMBER;
   fnd_message.raise_error;
End If;
Close c_case_group_NUMBER;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_case_groupS.ADVANCEMENT_TO'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_ADVANCEMENT_TO;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_delete >--------------------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_delete
 (p_rec  in pqh_cgn_shd.g_rec_type) is
  l_proc  varchar2(72) := g_package||'Ckh_Delete';
 Cursor Del is

 Select  '1'
  from per_gen_hierarchy_nodes a, pqh_de_case_groups b
where    NODE_TYPE  = 'CASE_GROUP'
and      a. entity_id    = b.CASE_GROUP_NUMBER
and      b.CASE_GROUP_id= p_rec.CASE_GROUP_id;

 l_Status Varchar2(1);
Begin
Open Del;
Fetch Del into l_Status;
If Del%Found Then
   Close Del;
   hr_utility.set_message(8302,'PQH_CASE_GROUP_PRE_DEL');
   hr_utility.raise_error;
End If;
Close Del;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_CASE_GROUPS.CASE_GROUP_NUMBER'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Delete;
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_Unique_case_group_NUMBER >------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_Unique_case_group_NUMBER
  (p_rec   in pqh_cgn_shd.g_rec_type) is
--
Cursor c_case_group_NUMBER is
Select  '1'
  from  PQH_DE_case_groupS
 Where  case_group_NUMBER = p_rec.case_group_NUMBER
   and  description       = p_rec.description;
L_status Varchar2(1);
l_proc     varchar2(1000) := g_package || 'Unique_cg_NUMBER';
Begin
hr_utility.set_location(l_proc, 10);
Open c_case_group_NUMBER;
Fetch c_case_group_NUMBER into L_status;
If c_case_group_NUMBER%found  Then
   hr_utility.set_message(8302, 'PQH_DE_CASE_GROUP_DUP');
   Close c_case_group_NUMBER;
   fnd_message.raise_error;
End If;
Close c_case_group_NUMBER;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_case_groupS.case_group_NUMBER'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Unique_case_group_NUMBER;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_cgn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  -- Validate Important Attributes

If p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_cgn_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
end if;

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  Chk_Unique_case_group_NUMBER (P_Rec);


  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
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
  ,p_rec                          in pqh_cgn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  -- Validate Important Attributes
If p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_cgn_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
end if;




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


  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_cgn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  Chk_delete(P_Rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_cgn_bus;

/
