--------------------------------------------------------
--  DDL for Package Body PAY_CAL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CAL_BUS" as
/* $Header: pycalrhi.pkb 120.1 2005/11/11 07:06:15 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_cal_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cost_allocation_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cost_allocation_id                   in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_cost_allocations_f cal
     where cal.cost_allocation_id = p_cost_allocation_id
       and pbg.business_group_id = cal.business_group_id;
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
    ,p_argument           => 'cost_allocation_id'
    ,p_argument_value     => p_cost_allocation_id
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
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
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
  (p_cost_allocation_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_cost_allocations_f cal
     where cal.cost_allocation_id = p_cost_allocation_id
       and pbg.business_group_id = cal.business_group_id;
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
    ,p_argument           => 'cost_allocation_id'
    ,p_argument_value     => p_cost_allocation_id
    );
  --
  if ( nvl(pay_cal_bus.g_cost_allocation_id, hr_api.g_number)
       = p_cost_allocation_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_cal_bus.g_legislation_code;
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
    pay_cal_bus.g_cost_allocation_id          := p_cost_allocation_id;
    pay_cal_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in pay_cal_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_cal_shd.api_updating
      (p_cost_allocation_id               => p_rec.cost_allocation_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- p_cost_allocation_id
  --
  if nvl(p_rec.cost_allocation_id, hr_api.g_number) <>
     nvl(pay_cal_shd.g_old_rec.cost_allocation_id, hr_api.g_number)
  then
    l_argument := 'p_rec.cost_allocation_id';
    raise l_error;
  end if;
  --
  -- p_assignment_id
  --
  if nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(pay_cal_shd.g_old_rec.assignment_id, hr_api.g_number)
  then
    l_argument := 'p_rec.assignment_id';
    raise l_error;
  end if;
  --
  -- p_business_group_id
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_cal_shd.g_old_rec.business_group_id, hr_api.g_number)
  then
    l_argument := 'p_rec.business_group_id';
    raise l_error;
  end if;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_cost_allocation_keyflex_id >-------------------|
-- ----------------------------------------------------------------------------
Procedure chk_cost_allocation_keyflex_id
  (p_cost_allocation_keyflex_id     in     number
  ,p_effective_date                 in     date
  ) is
  --
  -- Cursor to check that the flexfield combination exists.
  --
  cursor csr_combination_exists is
  select 'Y'
  from   pay_cost_allocation_keyflex ckf
  where  ckf.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
  and    p_effective_date between nvl(ckf.start_date_active,p_effective_date)
                          and     nvl(ckf.end_date_active,p_effective_date)
  and    ckf.enabled_flag = 'Y';
--
  l_proc  varchar2(72) := g_package||'chk_cost_allocation_keyflex_id';
  l_exists varchar2(1);
--
Begin
  --
  -- Check that the combination_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_cost_allocation_keyflex_id'
  ,p_argument_value => p_cost_allocation_keyflex_id
  );
  --
  -- Check that the combination exists.
  --
  open csr_combination_exists;
  fetch csr_combination_exists into l_exists;
  if csr_combination_exists%notfound then
    close csr_combination_exists;
    fnd_message.set_name('PAY', 'PAY_50982_INVALID_COST_KEYFLEX');
    fnd_message.raise_error;
  end if;
  close csr_combination_exists;
End chk_cost_allocation_keyflex_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_assignment_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_assignment_id                  in     number
  ,p_business_group_id              in     number
  ,p_effective_date                 in     date
  ) is
  --
  -- Cursor to check that the assignment exists.
  --
  cursor csr_assignment_exists is
  select 'Y'
  from   per_assignments_f paf
  where  paf.assignment_id = p_assignment_id
  and    p_effective_date between paf.effective_start_date
                          and     paf.effective_end_date
  and    paf.business_group_id = p_business_group_id;
--
  l_proc              varchar2(72) := g_package||'chk_assignment_id';
  l_exists            varchar2(1);
--
Begin
  --
  -- Check that the combination_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_assignment_id'
  ,p_argument_value => p_assignment_id
  );
  --
  -- Check that the combination exists.
  --
  open csr_assignment_exists;
  fetch csr_assignment_exists into l_exists;
  if csr_assignment_exists%notfound then
    close csr_assignment_exists;
    fnd_message.set_name('PAY', 'HR_7467_PLK_NOT_ELGBLE_ASS_ID');
    fnd_message.set_token('ASSIGNMENT_ID', p_assignment_id);
    fnd_message.raise_error;
  end if;
  close csr_assignment_exists;
End chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_proportion >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_proportion
  (p_cost_allocation_id in number
  ,p_proportion         in number) is
--
  l_proc  varchar2(72) := g_package||'chk_proportion';
--
Begin
  --
  -- Check that the proportion is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_proportion'
  ,p_argument_value => p_proportion
  );
  --
  -- Check that the proportion is between 0 and 1
  --
  if ((nvl(pay_cal_shd.g_old_rec.proportion,hr_api.g_number) <> p_proportion)
  or (p_cost_allocation_id is null)) then
  --
    if p_proportion not between 0 and 1 then
      fnd_message.set_name('PAY', 'PAY_50983_INVALID_PROPORTION');
      fnd_message.raise_error;
    end if;
  --
  end if;
  --
End chk_proportion;
--
-- -------------------------------------------------------------------------
-- |--------------------< chk_duplicate_cost_keyflex >---------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that no duplicate cost allocation keyflex id exists for the
--   same assignment on any date in the validation date range.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_cost_allocation_id
--   p_cost_allocation_keyflex_id
--   p_assignment_id
--   p_datetrack_mode
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success:
--   Processing continues if the cost allocation keyflex id is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   cost allocation keyflex id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_duplicate_cost_keyflex
  (p_cost_allocation_id          in number
  ,p_cost_allocation_keyflex_id  in number
  ,p_assignment_id               in number
  ,p_datetrack_mode              in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  )
is
  --
  -- Declare local variables
  --
  l_proc             varchar2(72) := g_package||'chk_duplicate_cost_keyflex';
  l_exists           varchar2(1);

  --
  -- Cursor to check that a retro component exists.
  --
  cursor csr_duplicate_cost_keyflex is
    select null
    from pay_cost_allocations_f
    where assignment_id = p_assignment_id
      and cost_allocation_id <> nvl(p_cost_allocation_id, hr_api.g_number)
      and cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
      and effective_start_date <= p_validation_end_date
      and effective_end_date   >= p_validation_start_date
    ;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_utility.set_location('Cost Allocation ID:'|| p_cost_allocation_id, 10);
  hr_utility.set_location('p_cost_allocation_keyflex_id:'|| p_cost_allocation_keyflex_id, 10);
  hr_utility.set_location('p_assignment_id:'|| p_assignment_id, 10);
  hr_utility.set_location('p_datetrack_mode:'|| p_datetrack_mode, 10);
  hr_utility.set_location('p_validation_start_date:'|| p_validation_start_date, 10);
  hr_utility.set_location('p_validation_end_date:'|| p_validation_end_date, 10);

  --
  -- Check p_datetrack_mode has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );

  --
  -- Perform the validity check when the datetrack mode is not
  -- ZAP or DELETE.
  --
  if p_datetrack_mode not in (hr_api.g_zap, hr_api.g_delete) then

    --
    -- Check mandatory parameters have been set
    --

    --
    -- Note: cost_allocation_id is not yet populated when inserting.
    --
    if p_datetrack_mode <> hr_api.g_insert then

      hr_api.mandatory_arg_error
        (p_api_name       => l_proc
        ,p_argument       => 'cost_allocation_id'
        ,p_argument_value => p_cost_allocation_id
        );

    end if;

    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'cost_allocation_keyflex_id'
      ,p_argument_value => p_cost_allocation_keyflex_id
      );
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'assignment_id'
      ,p_argument_value => p_assignment_id
      );
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );

    --
    -- Check if a duplicate record exists.
    --
    hr_utility.set_location(l_proc, 20);
    open csr_duplicate_cost_keyflex;
    fetch csr_duplicate_cost_keyflex into l_exists;
    if csr_duplicate_cost_keyflex%found then
      close csr_duplicate_cost_keyflex;

      fnd_message.set_name('PER','HR_6645_ASS_COST_DUPL');
      fnd_message.raise_error;

    end if;
    close csr_duplicate_cost_keyflex;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_duplicate_cost_keyflex;
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
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
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
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
  (p_cost_allocation_id               in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
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
      ,p_argument       => 'cost_allocation_id'
      ,p_argument_value => p_cost_allocation_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_cal_shd.g_rec_type
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
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_cost_allocation_keyflex_id
    (p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id
    ,p_effective_date             => p_effective_date);
  --
  chk_assignment_id
    (p_assignment_id     => p_rec.assignment_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_effective_date    => p_effective_date);
  --
  chk_proportion
    (p_cost_allocation_id => p_rec.cost_allocation_id
    ,p_proportion         => p_rec.proportion);
  --
  chk_duplicate_cost_keyflex
    (p_cost_allocation_id          => p_rec.cost_allocation_id
    ,p_cost_allocation_keyflex_id  => p_rec.cost_allocation_keyflex_id
    ,p_assignment_id               => p_rec.assignment_id
    ,p_datetrack_mode              => p_datetrack_mode
    ,p_validation_start_date       => p_validation_start_date
    ,p_validation_end_date         => p_validation_end_date
    );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_cal_shd.g_rec_type
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_cost_allocation_keyflex_id
    (p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id
    ,p_effective_date             => p_effective_date);
  --
  chk_proportion
    (p_cost_allocation_id => p_rec.cost_allocation_id
    ,p_proportion         => p_rec.proportion);
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
  chk_duplicate_cost_keyflex
    (p_cost_allocation_id          => p_rec.cost_allocation_id
    ,p_cost_allocation_keyflex_id  => p_rec.cost_allocation_keyflex_id
    ,p_assignment_id               => p_rec.assignment_id
    ,p_datetrack_mode              => p_datetrack_mode
    ,p_validation_start_date       => p_validation_start_date
    ,p_validation_end_date         => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_cal_shd.g_rec_type
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
    ,p_cost_allocation_id               => p_rec.cost_allocation_id
    );
  --
  chk_duplicate_cost_keyflex
    (p_cost_allocation_id          => p_rec.cost_allocation_id
    ,p_cost_allocation_keyflex_id  => pay_cal_shd.g_old_rec.cost_allocation_keyflex_id
    ,p_assignment_id               => pay_cal_shd.g_old_rec.assignment_id
    ,p_datetrack_mode              => p_datetrack_mode
    ,p_validation_start_date       => p_validation_start_date
    ,p_validation_end_date         => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_cal_bus;

/
