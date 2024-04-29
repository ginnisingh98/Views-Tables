--------------------------------------------------------
--  DDL for Package Body PAY_TXR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TXR_BUS" as
/* $Header: pytxrrhi.pkb 120.0 2005/05/29 09:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_txr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_jurisdiction_code           varchar2(11)   default null;
g_tax_type                    varchar2(30)   default null;
g_tax_category                varchar2(30)   default null;
g_classification_id           number         default null;
g_taxability_rules_date_id    number         default null;
g_secondary_classification_id number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_jurisdiction_code                    in varchar2
  ,p_tax_type                             in varchar2 default null
  ,p_tax_category                         in varchar2 default null
  ,p_classification_id                    in number   default null
  ,p_taxability_rules_date_id             in number
  ,p_secondary_classification_id          in number   default null
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ,p_associated_column3                   in varchar2 default null
  ,p_associated_column4                   in varchar2 default null
  ,p_associated_column5                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pay_taxability_rules and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_taxability_rules txr
      --   , EDIT_HERE table_name(s) 333
     where txr.jurisdiction_code = p_jurisdiction_code
       and nvl(txr.tax_type, 'X') = nvl(p_tax_type, 'X')
       and nvl(txr.tax_category, 'X') = nvl(p_tax_category, 'X')
       and nvl(txr.classification_id, 0) = nvl(p_classification_id, 0)
       and nvl(txr.secondary_classification_id, 0) =
                             nvl(p_secondary_classification_id, 0)
       and txr.taxability_rules_date_id = p_taxability_rules_date_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'jurisdiction_code'
    ,p_argument_value     => p_jurisdiction_code
    );
/*
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'tax_type'
    ,p_argument_value     => p_tax_type
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'tax_category'
    ,p_argument_value     => p_tax_category
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'classification_id'
    ,p_argument_value     => p_classification_id
    );
*/
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'taxability_rules_date_id'
    ,p_argument_value     => p_taxability_rules_date_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'JURISDICTION_CODE')
      ,p_associated_column2
        => nvl(p_associated_column2,'TAX_TYPE')
      ,p_associated_column3
        => nvl(p_associated_column3,'TAX_CATEGORY')
      ,p_associated_column4
        => nvl(p_associated_column4,'CLASSIFICATION_ID')
      ,p_associated_column5
        => nvl(p_associated_column5,'TAXABILITY_RULES_DATE_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_jurisdiction_code                    in     varchar2
  ,p_tax_type                             in     varchar2 default null
  ,p_tax_category                         in     varchar2 default null
  ,p_classification_id                    in     number   default null
  ,p_taxability_rules_date_id             in     number
  ,p_secondary_classification_id          in     number   default null
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pay_taxability_rules and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , pay_taxability_rules txr
      --   , EDIT_HERE table_name(s) 333
     where txr.jurisdiction_code = p_jurisdiction_code
       and nvl(txr.tax_type, 'X') = nvl(p_tax_type, 'X')
       and nvl(txr.tax_category, 'X') = nvl(p_tax_category, 'X')
       and nvl(txr.classification_id, 0) = nvl(p_classification_id, 0)
       and nvl(txr.secondary_classification_id, 0) =
                         nvl(p_secondary_classification_id, 0)
       and txr.taxability_rules_date_id = p_taxability_rules_date_id;
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
    ,p_argument           => 'jurisdiction_code'
    ,p_argument_value     => p_jurisdiction_code
    );
/*
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'tax_type'
    ,p_argument_value     => p_tax_type
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'tax_category'
    ,p_argument_value     => p_tax_category
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'classification_id'
    ,p_argument_value     => p_classification_id
    );
*/
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'taxability_rules_date_id'
    ,p_argument_value     => p_taxability_rules_date_id
    );
  --
  if (( nvl(pay_txr_bus.g_jurisdiction_code, hr_api.g_varchar2)
       = p_jurisdiction_code)
  and ( nvl(pay_txr_bus.g_tax_type, hr_api.g_varchar2)
       = nvl(p_tax_type, hr_api.g_varchar2))
  and ( nvl(pay_txr_bus.g_tax_category, hr_api.g_varchar2)
       = nvl(p_tax_category, hr_api.g_varchar2))
  and ( nvl(pay_txr_bus.g_classification_id, hr_api.g_number)
       = nvl(p_classification_id, hr_api.g_number))
  and ( nvl(pay_txr_bus.g_secondary_classification_id, hr_api.g_number)
       = nvl(p_secondary_classification_id, hr_api.g_number))
  and ( nvl(pay_txr_bus.g_taxability_rules_date_id, hr_api.g_number)
       = p_taxability_rules_date_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_txr_bus.g_legislation_code;
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
    pay_txr_bus.g_jurisdiction_code           := p_jurisdiction_code;
    pay_txr_bus.g_tax_type                    := p_tax_type;
    pay_txr_bus.g_tax_category                := p_tax_category;
    pay_txr_bus.g_classification_id           := p_classification_id;
    pay_txr_bus.g_secondary_classification_id := p_secondary_classification_id;
    pay_txr_bus.g_taxability_rules_date_id    := p_taxability_rules_date_id;
    pay_txr_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pay_txr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_txr_shd.api_updating
      (p_jurisdiction_code                 => p_rec.jurisdiction_code
      ,p_tax_type                          => p_rec.tax_type
      ,p_tax_category                      => p_rec.tax_category
      ,p_classification_id                 => p_rec.classification_id
      ,p_taxability_rules_date_id          => p_rec.taxability_rules_date_id
      ,p_secondary_classification_id       => p_rec.secondary_classification_id
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_txr_shd.g_rec_type
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_txr_shd.g_rec_type
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
  (p_rec                          in pay_txr_shd.g_rec_type
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
end pay_txr_bus;

/
