--------------------------------------------------------
--  DDL for Package Body PAY_MGB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MGB_BUS" as
/* $Header: pymgbrhi.pkb 120.0 2005/05/29 06:45:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_mgb_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the uniqueness of the combination
--   block_name and report_format which forms the true key.
--
--
-- Pre Conditions:
--   Should be called only while insert. Since these columns are non-updatable
--   it is not required to check the uniqueness while update.
--
-- In Arguments:
--   block_name
--   report_format
--
-- Post Success:
--   Processing Continues.
--
--
-- Post Failure:
--   Failure might occur if any of the parameters are null or the combination
--   already exists for a different magnetic block.
--   Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_key
  ( p_block_name      in  varchar2
   ,p_report_format   in  varchar2
  ) IS
--
cursor csr_unique_key  is
  select null
  from   pay_magnetic_blocks
  where  block_name = p_block_name
  and    report_format   = p_report_format;
--
  l_proc     varchar2(72) := g_package || 'chk_unique_key';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'BLOCK_NAME'
               ,p_argument_value =>  p_block_name
              );

        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'REPORT_FORMAT'
               ,p_argument_value =>  p_report_format
              );

        open csr_unique_key;
        fetch csr_unique_key into l_exists;

        if csr_unique_key%found then

             close csr_unique_key;

             fnd_message.set_name( 'PAY' , 'PAY_33256_INV_UKEY1' );
             fnd_message.set_token( 'COL1' , 'BLOCK_NAME');
             fnd_message.set_token( 'COL2' , 'REPORT_FORMAT');
             fnd_message.set_token( 'COL1_VAL', p_block_name);
             fnd_message.set_token( 'COL2_VAL', p_report_format);
             fnd_message.raise_error ;

        end if ;

        close csr_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_unique_key;
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
  (p_rec in pay_mgb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_mgb_shd.api_updating
      (p_magnetic_block_id                 => p_rec.magnetic_block_id
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  if nvl(p_rec.block_name, hr_api.g_varchar2) <>
     pay_mgb_shd.g_old_rec.block_name then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BLOCK_NAME'
     ,p_base_table => pay_mgb_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.report_format, hr_api.g_varchar2) <>
     pay_mgb_shd.g_old_rec.report_format then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_FORMAT'
     ,p_base_table => pay_mgb_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_mgb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
    chk_unique_key
     ( p_block_name       => p_rec.block_name
      ,p_report_format    => p_rec.report_format
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_mgb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
 chk_non_updateable_args
        ( p_rec  => p_rec );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_mgb_shd.g_rec_type) is
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
end pay_mgb_bus;

/
