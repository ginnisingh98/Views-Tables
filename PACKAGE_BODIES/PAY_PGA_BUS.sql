--------------------------------------------------------
--  DDL for Package Body PAY_PGA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PGA_BUS" as
/* $Header: pypgarhi.pkb 120.0 2005/09/29 10:53 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pga_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pay_gl_account_id           number         default null;
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
  (p_effective_date  in date
  ,p_rec             in pay_pga_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_pga_shd.api_updating
      (p_pay_gl_account_id                => p_rec.pay_gl_account_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.external_account_id, hr_api.g_number) <>
     pay_pga_shd.g_old_rec.external_account_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'EXTERNAL_ACCOUNT_ID'
     ,p_base_table => pay_pga_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.org_payment_method_id, hr_api.g_number) <>
     pay_pga_shd.g_old_rec.org_payment_method_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'ORG_PAYMENT_METHOD_ID'
     ,p_base_table => pay_pga_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_pay_gl_account_id                in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'pay_gl_account_id'
      ,p_argument_value => p_pay_gl_account_id
      );
    --
  --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_set_of_books_id >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_set_of_books_id
(p_set_of_books_id     in number
) is
--
cursor csr_set_of_books_id is
select null
from   gl_sets_of_books
where  set_of_books_id = p_set_of_books_id;
--
l_exists varchar2(1);
--
l_proc   varchar2(100) := g_package || 'chk_set_of_books_id';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_set_of_books_id is not null and p_set_of_books_id <> 0 then

    hr_utility.set_location('Entering:'|| l_proc, 20);

    open csr_set_of_books_id;
    fetch csr_set_of_books_id into l_exists;

    if csr_set_of_books_id%notfound then
      close csr_set_of_books_id;
      fnd_message.set_name('PAY', 'PAY_33456_SET_OF_BOOKS_INV');
      fnd_message.raise_error;
    end if;
    close csr_set_of_books_id;

  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
exception
  when others then
    if csr_set_of_books_id%isopen then
      close csr_set_of_books_id;
    end if;
    raise;

end chk_set_of_books_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_external_account_id >-----------------------|
-- ----------------------------------------------------------------------------
procedure chk_external_account_id
(p_external_account_id     in number
) is
--
cursor csr_external_account_id is
select null
from   pay_external_accounts
where  external_account_id = p_external_account_id;
--
l_exists varchar2(1);
--
l_proc   varchar2(100) := g_package || 'chk_external_account_id';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_external_account_id is not null then

    open csr_external_account_id;
    fetch csr_external_account_id into l_exists;

    if csr_external_account_id%notfound then
      close csr_external_account_id;
      fnd_message.set_name('PAY', 'PAY_33457_BANK_DETAILS_INV');
      fnd_message.raise_error;
    end if;

    close csr_external_account_id;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when others then
    if csr_external_account_id%isopen then
      close csr_external_account_id;
    end if;
    raise;

end chk_external_account_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_gl_account_id >-------------------------|
-- ----------------------------------------------------------------------------
procedure chk_gl_account_id
(p_gl_account_id     in number
) is
--
cursor csr_gl_account_id is
select null
from   gl_code_combinations
where  code_combination_id = p_gl_account_id;
--
l_exists varchar2(1);
--
l_proc   varchar2(100) := g_package || 'chk_gl_account_id';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_gl_account_id is not null then

    open csr_gl_account_id;
    fetch csr_gl_account_id into l_exists;

    if csr_gl_account_id%notfound then
      close csr_gl_account_id;
      fnd_message.set_name('PAY', 'PAY_33458_GL_ACT_DETAILS_INV');
      fnd_message.raise_error;
    end if;

    close csr_gl_account_id;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when others then
    if csr_gl_account_id%isopen then
      close csr_gl_account_id;
    end if;
    raise;

end chk_gl_account_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_pga_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Validate Dependent Attributes
  --
  --
  chk_set_of_books_id
  (p_set_of_books_id   => p_rec.set_of_books_id
  );
  --
  chk_external_account_id
  (p_external_account_id   => p_rec.external_account_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_cash_ac_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_cash_clearing_ac_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_control_ac_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_error_ac_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_pga_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  chk_set_of_books_id
  (p_set_of_books_id   => p_rec.set_of_books_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_cash_ac_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_cash_clearing_ac_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_control_ac_id
  );
  --
  chk_gl_account_id
  (p_gl_account_id     => p_rec.gl_error_ac_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_pga_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_pay_gl_account_id                => p_rec.pay_gl_account_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_pga_bus;

/
