--------------------------------------------------------
--  DDL for Package Body PQH_OPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_OPL_BUS" as
/* $Header: pqoplrhi.pkb 115.4 2002/12/03 00:09:31 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_opl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_operation_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_operation_id                         in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_de_operations and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_operations opl
      --   , EDIT_HERE table_name(s) 333
     where opl.operation_id = p_operation_id;
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
    ,p_argument           => 'operation_id'
    ,p_argument_value     => p_operation_id
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
        => nvl(p_associated_column1,'OPERATION_ID')
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
  (p_operation_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_de_operations and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqh_de_operations opl
      --   , EDIT_HERE table_name(s) 333
     where opl.operation_id = p_operation_id;
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
    ,p_argument           => 'operation_id'
    ,p_argument_value     => p_operation_id
    );
  --
  if ( nvl(pqh_opl_bus.g_operation_id, hr_api.g_number)
       = p_operation_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_opl_bus.g_legislation_code;
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
    pqh_opl_bus.g_operation_id                := p_operation_id;
    pqh_opl_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_opl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';

--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_opl_shd.api_updating
      (p_operation_id                      => p_rec.operation_id
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
IF nvl(p_rec.OPERATION_NUMBER, hr_api.g_varchar2) <>
    nvl(pqh_opl_shd.g_old_rec.OPERATION_NUMBER, hr_api.g_varchar2) THEN
    hr_utility.set_message(8302, 'PQH_DE_NONUPD_OPERATION_NUMBER');
      fnd_message.raise_error;
  END IF;

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_delete >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_delete
 (p_rec  in pqh_opl_shd.g_rec_type) is
  l_proc  varchar2(72) := g_package||'Ckh_Delete';
 Cursor Del is
select  '1' from per_gen_hierarchy_nodes
where    NODE_TYPE  = 'OPR_OPTS'
and      entity_id  = p_rec.OPERATION_NUMBER;
 l_Status Varchar2(1);
Begin
Open Del;
Fetch Del into l_Status;
If Del%Found Then
   Close Del;
   hr_utility.set_message(8302, 'PQH_OPRTNS_PRE_DEL');
   hr_utility.raise_error;
End If;
Close Del;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_OPERATIONS.OPERATION_NUMBER'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Delete;

-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_Unique_Description >-------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_Unique_Description
  (p_rec   in pqh_opl_shd.g_rec_type) is
--
Cursor c_Description is
Select  Description
  from  PQH_DE_OPERATIONS
 Where  Description = p_rec.Description;
  l_Description PQH_DE_OPERATIONS.Description%TYPE;
  l_proc     varchar2(72) := g_package || 'Unique_Description';
Begin
hr_utility.set_location(l_proc, 10);
Open c_Description;
Fetch c_Description into l_Description;
If c_Description%ROWCOUNT > 0 Then
   hr_utility.set_message(8302, 'PQH_DE_DUPVAL_Description');
   Close c_Description;
   fnd_message.raise_error;
End If;
Close c_Description;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_OPERATIONS.Description'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Unique_Description;
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_Unique_OPERATION_NUMBER >--------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_Unique_OPERATION_NUMBER
  (p_rec   in pqh_opl_shd.g_rec_type) is
--
Cursor c_OPERATION_NUMBER is
Select  OPERATION_NUMBER
  from  PQH_DE_OPERATIONS
 Where  OPERATION_NUMBER = p_rec.OPERATION_NUMBER;
  l_OPERATION_NUMBER PQH_DE_OPERATIONS.OPERATION_NUMBER%TYPE;
  l_proc     varchar2(72) := g_package || 'Unique_OPERATION_NUMBER';
Begin
hr_utility.set_location(l_proc, 10);
Open c_OPERATION_NUMBER;
Fetch c_OPERATION_NUMBER into l_OPERATION_NUMBER;
If c_OPERATION_NUMBER%ROWCOUNT > 0 Then
   hr_utility.set_message(8302, 'PQH_DE_DUPVAL_OPERATIONS');
   Close c_OPERATION_NUMBER;
   fnd_message.raise_error;
End If;
Close c_OPERATION_NUMBER;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_OPERATIONS.OPERATION_NUMBER'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Unique_OPERATION_NUMBER;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_opl_shd.g_rec_type
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
     Chk_Unique_OPERATION_NUMBER (P_Rec);
     Chk_Unique_Description(P_Rec);

  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
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
  ,p_rec                          in pqh_opl_shd.g_rec_type
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
  -- Chk_Unique_OPERATION_NUMBER (P_Rec);
   Chk_Unique_Description(P_Rec);
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
    (p_effective_date              => p_effective_date
      ,p_rec                       => p_rec
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
  (p_rec                          in pqh_opl_shd.g_rec_type
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
end pqh_opl_bus;

/
