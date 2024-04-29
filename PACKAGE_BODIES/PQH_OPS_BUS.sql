--------------------------------------------------------
--  DDL for Package Body PQH_OPS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_OPS_BUS" as
/* $Header: pqopsrhi.pkb 115.2 2002/12/03 20:41:53 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_ops_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_wrkplc_vldtn_op_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_wrkplc_vldtn_op_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_wrkplc_vldtn_ops ops
     where ops.wrkplc_vldtn_op_id = p_wrkplc_vldtn_op_id
       and pbg.business_group_id = ops.business_group_id;
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
    ,p_argument           => 'wrkplc_vldtn_op_id'
    ,p_argument_value     => p_wrkplc_vldtn_op_id
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
        => nvl(p_associated_column1,'WRKPLC_VLDTN_OP_ID')
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
  (p_wrkplc_vldtn_op_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_de_wrkplc_vldtn_ops ops
     where ops.wrkplc_vldtn_op_id = p_wrkplc_vldtn_op_id
       and pbg.business_group_id = ops.business_group_id;
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
    ,p_argument           => 'wrkplc_vldtn_op_id'
    ,p_argument_value     => p_wrkplc_vldtn_op_id
    );
  --
  if ( nvl(pqh_ops_bus.g_wrkplc_vldtn_op_id, hr_api.g_number)
       = p_wrkplc_vldtn_op_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_ops_bus.g_legislation_code;
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
    pqh_ops_bus.g_wrkplc_vldtn_op_id          := p_wrkplc_vldtn_op_id;
    pqh_ops_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_ops_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_ops_shd.api_updating
      (p_wrkplc_vldtn_op_id                => p_rec.wrkplc_vldtn_op_id
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
  If P_Rec.WRKPLC_VLDTN_VER_ID <> pqh_ops_shd.g_old_rec.wrkplc_vldtn_ver_id Then
     hr_utility.set_message(8302, 'PQH_DE_NONUPD_VALVER_ID');
     fnd_message.raise_error;
  End If;

End chk_non_updateable_args;

Procedure Chk_Ops_Req
  (p_effective_date               in date
  ,p_rec                          in pqh_ops_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'Chk_Ops';
--
  Cursor Ops is
  Select Employment_type, Remuneration_regulation
  from  Pqh_De_Wrkplc_Vldtns a, Pqh_De_Wrkplc_Vldtn_Vers b
  Where Wrkplc_Vldtn_Ver_Id = p_rec.Wrkplc_Vldtn_Ver_Id
    and a.Wrkplc_Vldtn_Id   = b.Wrkplc_Vldtn_id;

  l_Employment_type         Pqh_De_Wrkplc_Vldtns.Employment_Type%TYPE;
  l_Remuneration_Regulation Pqh_De_Wrkplc_Vldtns.Remuneration_Regulation%TYPE;
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  Open Ops;
  Fetch Ops into l_Employment_Type, l_Remuneration_regulation;
  If OPS%NOTFOUND Then
     Close Ops;
     hr_utility.set_message(8302, 'PQH_DE_OPS_VALDTN_DEFINITION');
     hr_utility.raise_error;
  Else
     If Not(l_Employment_Type = 'WC' and l_Remuneration_Regulation = 'CP') Then
        Close Ops;
        hr_utility.set_message(8302, 'PQH_DE_OPS_VALDTN_DEFINITION');
        hr_utility.raise_error;
     End If;
  End If;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_OPS.WRKPLC_VLDTN_OP_ID') then
       hr_utility.set_location(' Leaving:'||l_proc,60);
       raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_ops_Req;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_ops_shd.g_rec_type
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
    ,p_associated_column1 => pqh_ops_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
   hr_utility.set_location('Entering:'||l_proc, 10);

  Chk_Ops_Req
  (p_effective_date
  ,p_rec);

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
  ,p_rec                          in pqh_ops_shd.g_rec_type
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
    ,p_associated_column1 => pqh_ops_shd.g_tab_nam
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
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_ops_shd.g_rec_type
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
end pqh_ops_bus;

/
