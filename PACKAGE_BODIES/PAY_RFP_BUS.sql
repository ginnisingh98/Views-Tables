--------------------------------------------------------
--  DDL for Package Body PAY_RFP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RFP_BUS" as
/* $Header: pyrfprhi.pkb 120.0 2005/05/29 08:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_rfp_bus.';  -- Global package name
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_report_format_mapping_id >---------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_report_format_mapping_id
  ( p_report_format_mapping_id  in  number ) IS
--
cursor csr_report_format_mapping_id  is
  select null
  from   pay_report_format_mappings_f
  where  report_format_mapping_id = p_report_format_mapping_id;
--
  l_proc     varchar2(72) := g_package || 'chk_report_format_mapping_id';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
                   ( p_api_name       =>  l_proc
                    ,p_argument       =>  'REPORT_FORMAT_MAPPING_ID'
                    ,p_argument_value =>  p_report_format_mapping_id
                   );

        open csr_report_format_mapping_id;
        fetch csr_report_format_mapping_id into l_exists;

        if csr_report_format_mapping_id%notfound then

             close csr_report_format_mapping_id;

             fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
             fnd_message.set_token('PARENT' , 'Report Format Mapping Id' );
             fnd_message.raise_error;

        end if ;

        close csr_report_format_mapping_id;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_report_format_mapping_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the uniqueness of the combination
--   report_format_mapping_id and parameter_name.
--   This is required since there is no primary key constraint on the table.
--
-- Pre Conditions:
--   Should be called only while insert. Since these columns are non-updatable
--   it is not required to check the uniqueness while update.
--
-- In Arguments:
--   report_format_mapping_id
--   parameter_name
--
-- Post Success:
--   Processing Continues.
--
--
-- Post Failure:
--   Failure might occur if any of the parameters are null or the combination
--   already exists.
--   Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_key
  ( p_report_format_mapping_id   in  number
   ,p_parameter_name             in  varchar2
  ) IS
--
cursor csr_unique_key  is
  select null
  from   pay_report_format_parameters
  where  report_format_mapping_id = p_report_format_mapping_id
  and    parameter_name = p_parameter_name;
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
                    ,p_argument       =>  'REPORT_FORMAT_MAPPING_ID'
                    ,p_argument_value =>  p_report_format_mapping_id
                   );

        hr_api.mandatory_arg_error
                   ( p_api_name       =>  l_proc
                    ,p_argument       =>  'PARAMETER_NAME'
                    ,p_argument_value =>  p_parameter_name
                   );

        open csr_unique_key;
        fetch csr_unique_key into l_exists;

        if csr_unique_key%found then

             close csr_unique_key;

             fnd_message.set_name( 'PAY' , 'PAY_33256_INV_UKEY1' );
             fnd_message.set_token( 'COL1' , 'REPORT_FORMAT_MAPPING_ID');
             fnd_message.set_token( 'COL2' , 'PARAMETER_NAME');
             fnd_message.set_token( 'COL1_VAL', p_report_format_mapping_id);
             fnd_message.set_token( 'COL2_VAL', p_parameter_name);
             fnd_message.raise_error ;

        end if ;

        close csr_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_unique_key;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_parameter_value >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the validity of the parameter_value.
--   The parameter_value cannot be null.
--
-- Pre Conditions:
--   None.
--
--
-- In Arguments:
--   parameter_value.
--
--
-- Post Success:
--   Processing Continues.
--
--
-- Post Failure:
--   Failure might occur if the parameter_value is null.
--   Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_parameter_value
  ( p_parameter_value   in  varchar2 ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_parameter_value';
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
                   ( p_api_name       =>  l_proc
                    ,p_argument       =>  'PARAMETER_VALUE'
                    ,p_argument_value =>  p_parameter_value
                   );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_parameter_value;
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
  (p_rec in pay_rfp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_rfp_shd.api_updating
      (p_report_format_mapping_id          => p_rec.report_format_mapping_id
      ,p_parameter_name                    => p_rec.parameter_name
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_rfp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  --
  -- Validate Dependent Attributes
  --
  chk_report_format_mapping_id
     ( p_report_format_mapping_id => p_rec.report_format_mapping_id );
  --
  chk_unique_key
     ( p_report_format_mapping_id => p_rec.report_format_mapping_id
      ,p_parameter_name           => p_rec.parameter_name
     );
  --
  chk_parameter_value
     ( p_parameter_value          => p_rec.parameter_value
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_rfp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  chk_parameter_value
     ( p_parameter_value          => p_rec.parameter_value
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_rfp_shd.g_rec_type
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
end pay_rfp_bus;

/
