--------------------------------------------------------
--  DDL for Package Body PAY_ITR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ITR_BUS" as
/* $Header: pyitrrhi.pkb 115.6 2002/12/16 17:48:51 dsaxby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_itr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_iterative_rule_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_iterative_rule_id                    in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_iterative_rules_f itr
     where itr.iterative_rule_id = p_iterative_rule_id
       and pbg.business_group_id = itr.business_group_id;
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
    ,p_argument           => 'iterative_rule_id'
    ,p_argument_value     => p_iterative_rule_id
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
     fnd_message.set_name(801,'HR_7220_INVALID_PRIMARY_KEY');
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
  (p_iterative_rule_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_iterative_rules_f itr
     where itr.iterative_rule_id = p_iterative_rule_id
       and pbg.business_group_id (+) = itr.business_group_id;
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
    ,p_argument           => 'iterative_rule_id'
    ,p_argument_value     => p_iterative_rule_id
    );
  --
  if ( nvl(pay_itr_bus.g_iterative_rule_id, hr_api.g_number)
       = p_iterative_rule_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_itr_bus.g_legislation_code;
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
      fnd_message.set_name(801,'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_itr_bus.g_iterative_rule_id := p_iterative_rule_id;
    pay_itr_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_itr_shd.g_rec_type
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
  IF NOT pay_itr_shd.api_updating
      (p_iterative_rule_id                => p_rec.iterative_rule_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name(800, 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_itr_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
--
  if nvl(p_rec.iterative_rule_id, hr_api.g_number) <>
     nvl(pay_itr_shd.g_old_rec.iterative_rule_id, hr_api.g_number) then
     l_argument := 'iterative_rule_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
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
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the row being inserted or updated does
--   not already exists on the database, i.e, has the same RESULT_NAME, RULE_TYPE,
--   INPUT_VALUE_ID, ELEMENT_TYPE_ID, EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
--   combination.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_result_name
--   p_iterative_rule_type
--   p_input_value_id
--   p_element_type_id
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_unique_key
    ( p_result_name                    in varchar2
     ,p_iterative_rule_type            in varchar2
     ,p_input_value_id                 in number
     ,p_element_type_id                in number
     ,p_validation_start_date           in date
     ,p_validation_end_date             in date
    )  is
--
    l_exists    varchar2(1);
    l_proc      varchar2(72) := g_package||'chk_unique_key';
--
    cursor C1 is
    select 'Y'
    from   pay_iterative_rules_f pir
    where  pir.result_name          = p_result_name
    and    pir.element_type_id      = p_element_type_id
    and    pir.iterative_rule_type  = p_iterative_rule_type
    and    pir.input_value_id       = p_input_value_id
    and    pir.effective_start_date = p_validation_start_date
    and    pir.effective_end_date   = p_validation_end_date  ;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 1);
   --
  open C1;
   fetch C1 into l_exists;
   if C1%found then
     hr_utility.set_location(l_proc, 3);
     -- row is not unique
     close C1;
     pay_itr_shd.constraint_error('PAY_ITERATIVE_RULES_UK1');
   end if;
   close C1;
   --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
--
end chk_unique_key;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_element_type_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check that the element_type of the row being
--   inserted or updated exists on pay_element_types_f and is date effective.
--
-- Prerequisites:
--   This procedure is called from the update_validate and insert_validate.
--
-- In Parameters:
--   p_element_type_id
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_element_type_id
( p_element_type_id      in number
 ,p_validation_start_date in date
 ,p_validation_end_date   in date
)
is
  l_exists              number;
  l_proc                varchar2(72) := g_package||'chk_element_type_id';
--
  Cursor C1 is
    select distinct et.element_type_id
    from   pay_element_types_f et
    where  et.element_type_id = p_element_type_id
    and    (p_validation_start_date between et.effective_start_date
                   and et.effective_end_date
           or ( p_validation_start_date < et.effective_start_date
                and p_validation_end_date > et.effective_start_date) ) ;
--
begin
   hr_utility.set_location('Entering:'|| l_proc, 1);
   --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'element_type_id'
    ,p_argument_value => p_element_type_id
   );
--
  open C1;
  fetch C1 into l_exists;
  if C1%notfound then
    hr_utility.set_location(l_proc, 3);
    close C1;
    hr_utility.set_message(801, 'PAY_52908_ITR_ETYPE_ERROR');
    hr_utility.raise_error;
  end if;
  close C1;
--
  hr_utility.set_location(l_proc, 2);
--
end chk_element_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_result_name >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the iterative rule being inserted or
--   updated has a valid result name.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_element_type_id
--   p_result_name
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
procedure chk_result_name
 ( p_element_type_id        in number
  ,p_result_name            in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
 )
is
--
        l_exists             varchar2(80);
        l_proc               varchar2(72)  :=  g_package||'chk_result_name ';
        --
        cursor C1 is
        select distinct f.item_name
        from   pay_element_types_f e
              ,ff_fdi_usages_f f
        where e.element_type_id = p_element_type_id
        and   e.iterative_formula_id = f.formula_id
        and   f.usage in ('O', 'B')
        and   f.item_name = p_result_name
        and   (p_validation_start_date between e.effective_start_date
                   and e.effective_end_date
               or ( p_validation_start_date < e.effective_start_date
                    and p_validation_end_date > e.effective_start_date) )
        and   (p_validation_start_date between f.effective_start_date
                   and f.effective_end_date
               or ( p_validation_start_date < f.effective_start_date
                    and p_validation_end_date > f.effective_start_date) ) ;
--
begin
  hr_utility.set_location('Entering : '|| l_proc, 1);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'result_name'
    ,p_argument_value => p_result_name
    );
  --
  open C1;
  fetch C1 into l_exists;
  if C1%notfound then
    hr_utility.set_location(l_proc, 3);
    close C1;
    hr_utility.set_message(801, 'PAY_52903_ITR_RESULT_ERROR');
    hr_utility.raise_error;
  end if;
  close C1;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end chk_result_name ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_iterative_rule_cond >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used check that for the row being inserted or updated
--   the iterative_rule_type is valid. Also checks that if iterative_rule_type
--   is 'M', then severity level is not null and is in ('F', 'I', 'W').
--   If iterative_rule_type is 'A', then input value id is not null and
--   is a valid input value id (i.e. exists on the element).
--
-- Prerequisites:
--   This procedure is called from the update_validate and insert_validate.
--
-- In Parameters:
--   p_element_type_id
--   p_input_value_id
--   p_severity_level
--   p_iterative_rule_type
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_iterative_rule_cond
( p_element_type_id      in number
 ,p_input_value_id       in number
 ,p_severity_level       in varchar2
 ,p_iterative_rule_type  in varchar2
 ,p_validation_start_date in date
 ,p_validation_end_date   in date
)
is
  l_exists              number;
  l_proc                varchar2(72) := g_package||'chk_iterative_rule_cond';
--
  Cursor C1 is
    Select distinct piv.input_value_id
    from   pay_input_values_f piv
    where  piv.element_type_id = p_element_type_id
    and    piv.input_value_id  = p_input_value_id
    and    (p_validation_start_date between piv.effective_start_date
                   and piv.effective_end_date
               or ( p_validation_start_date < piv.effective_start_date
                    and p_validation_end_date > piv.effective_start_date) ) ;
--
begin
   hr_utility.set_location('Entering:'|| l_proc, 1);
   --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'iterative_rule_type'
    ,p_argument_value => p_iterative_rule_type
   );
  --
  if (p_iterative_rule_type not in ('M', 'A' , 'S')) then
     pay_itr_shd.constraint_error('PAY_ITR_RULE_TYPE_CHK');
  --
  elsif (p_iterative_rule_type = 'M') then
     --
     hr_api.mandatory_arg_error
     ( p_api_name       => l_proc
       ,p_argument       => 'severity_level'
       ,p_argument_value => p_severity_level
     );
     --
     if ( p_severity_level not in ('F', 'I', 'W')) then
        pay_itr_shd.constraint_error('PAY_ITR_SEV_LEVEL_CHK');
     end if;
     --
     if (p_input_value_id is not null) then
          fnd_message.set_name('PAY', 'PAY_52906_ITR_MESSAGE_ERRROR');
          fnd_message.raise_error;
     end if;
  --
  elsif (p_iterative_rule_type = 'A') then
     --
     hr_api.mandatory_arg_error
     ( p_api_name       => l_proc
       ,p_argument       => 'input_value_id'
       ,p_argument_value => p_input_value_id
     );
     --
     open C1;
     fetch C1 into l_exists;
     if ( C1%notfound ) then
        close C1;
        fnd_message.set_name('PAY', 'PAY_52904_ITR_INPVAL_ERROR');
        fnd_message.raise_error;
     else Close c1;
     end if;
  --
     if (p_severity_level is not null) then
          fnd_message.set_name('PAY', 'PAY_52907_ITR_ADJUST_ERROR');
          fnd_message.raise_error;
     end if;
  --
  elsif (p_iterative_rule_type = 'S') then
     if (p_input_value_id is not null or p_severity_level is not null) then
          fnd_message.set_name('PAY', 'PAY_52905_ITR_STOP_ERROR');
          fnd_message.raise_error;
     end if;
  end if;
end chk_iterative_rule_cond;
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
    fnd_message.set_name(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
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
  (p_iterative_rule_id                in number
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
      ,p_argument       => 'iterative_rule_id'
      ,p_argument_value => p_iterative_rule_id
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
    fnd_message.set_name(801, 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
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
  (p_rec                   in pay_itr_shd.g_rec_type
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
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  END IF;
  --
  chk_unique_key
    ( p_result_name                    => p_rec.result_name
     ,p_iterative_rule_type            => p_rec.iterative_rule_type
     ,p_input_value_id                 => p_rec.input_value_id
     ,p_element_type_id                => p_rec.element_type_id
     ,p_validation_start_date           => p_validation_start_date
     ,p_validation_end_date             => p_validation_end_date
    );
  --
  chk_element_type_id
    ( p_element_type_id      => p_rec.element_type_id
     ,p_validation_start_date => p_validation_start_date
     ,p_validation_end_date   => p_validation_end_date
    );
  --
  chk_result_name
    ( p_element_type_id        => p_rec.element_type_id
     ,p_result_name            => p_rec.result_name
     ,p_validation_start_date   => p_validation_start_date
     ,p_validation_end_date     => p_validation_end_date
    );
  --
  chk_iterative_rule_cond
    ( p_element_type_id      => p_rec.element_type_id
     ,p_input_value_id       => p_rec.input_value_id
     ,p_severity_level       => p_rec.severity_level
     ,p_iterative_rule_type  => p_rec.iterative_rule_type
     ,p_validation_start_date => p_validation_start_date
     ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_itr_shd.g_rec_type
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
  IF hr_startup_data_api_support.g_startup_mode

                     NOT IN ('GENERIC','STARTUP') THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  END IF;

  --
  chk_unique_key
    ( p_result_name                    => p_rec.result_name
     ,p_iterative_rule_type            => p_rec.iterative_rule_type
     ,p_input_value_id                 => p_rec.input_value_id
     ,p_element_type_id                => p_rec.element_type_id
     ,p_validation_start_date           => p_validation_start_date
     ,p_validation_end_date             => p_validation_end_date
    );
  --
  chk_element_type_id
    ( p_element_type_id      => p_rec.element_type_id
     ,p_validation_start_date => p_validation_start_date
     ,p_validation_end_date   => p_validation_end_date
    );
  --
  chk_result_name
    ( p_element_type_id        => p_rec.element_type_id
     ,p_result_name            => p_rec.result_name
     ,p_validation_start_date   => p_validation_start_date
     ,p_validation_end_date     => p_validation_end_date
    );
  --
  chk_iterative_rule_cond
    ( p_element_type_id      => p_rec.element_type_id
     ,p_input_value_id       => p_rec.input_value_id
     ,p_severity_level       => p_rec.severity_level
     ,p_iterative_rule_type  => p_rec.iterative_rule_type
     ,p_validation_start_date => p_validation_start_date
     ,p_validation_end_date   => p_validation_end_date
    );
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_itr_shd.g_rec_type
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
    ,p_iterative_rule_id                => p_rec.iterative_rule_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_itr_bus;

/
