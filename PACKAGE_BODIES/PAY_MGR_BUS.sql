--------------------------------------------------------
--  DDL for Package Body PAY_MGR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MGR_BUS" as
/* $Header: pymgrrhi.pkb 120.2 2005/07/10 23:13:53 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_mgr_bus.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_formula_id >---------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_formula_id
  ( p_formula_id  in  number ) IS
--
cursor csr_formula_id  is
  select null
  from   ff_formulas_f
  where  formula_id = p_formula_id;
--
  l_proc     varchar2(72) := g_package || 'chk_formula_id';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if (p_formula_id <> -9999) then
        hr_api.mandatory_arg_error
                   ( p_api_name       =>  l_proc
                    ,p_argument       =>  'FORMULA_ID'
                    ,p_argument_value =>  p_formula_id
                   );

        open csr_formula_id;
        fetch csr_formula_id into l_exists;

        if csr_formula_id%notfound then

             close csr_formula_id;

             fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
             fnd_message.set_token('PARENT' , 'Formula Id' );
             fnd_message.raise_error;

        end if ;

        close csr_formula_id;
  --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_formula_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_mgr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_formula_id
     ( p_formula_id => p_rec.formula_id );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_mgr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
    chk_formula_id
     ( p_formula_id => p_rec.formula_id );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_mgr_shd.g_rec_type) is
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
end pay_mgr_bus;

/
