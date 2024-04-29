--------------------------------------------------------
--  DDL for Package Body PAY_IVL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IVL_BUS" as
/* $Header: pyivlrhi.pkb 120.0.12010000.6 2009/07/30 12:03:21 npannamp ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ivl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_input_value_id              number         default null;

cursor csr_row_count is
select count(*) from pay_input_values_f
where input_value_id = pay_ivl_shd.g_old_rec.input_value_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_input_value_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is

  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_input_values_f ivl
     where ivl.input_value_id = p_input_value_id
       and pbg.business_group_id = ivl.business_group_id;
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

    ,p_argument           => 'input_value_id'
    ,p_argument_value     => p_input_value_id
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
         => nvl(p_associated_column1,'INPUT_VALUE_ID')
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
  (p_input_value_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code

      from per_business_groups pbg
         , pay_input_values_f ivl
     where ivl.input_value_id = p_input_value_id
       and pbg.business_group_id (+) = ivl.business_group_id;
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
    ,p_argument           => 'input_value_id'
    ,p_argument_value     => p_input_value_id
    );
  --
  if ( nvl(pay_ivl_bus.g_input_value_id, hr_api.g_number)

       = p_input_value_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_ivl_bus.g_legislation_code;
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
    pay_ivl_bus.g_input_value_id              := p_input_value_id;
    pay_ivl_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_default_value_format >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_default_value_format
( p_default_value       in varchar2
 ,p_lookup_type         in varchar2
 ,p_min_value           in varchar2
 ,p_max_value           in varchar2
 ,p_uom                 in varchar2
 ,p_input_currency_code in varchar2
 ,p_warning_or_error    in varchar2
 ,p_default_val_warning out nocopy boolean
)
IS
  --
  l_proc        varchar2(72)    := g_package||'chk_default_value_format';
  l_default_value  varchar2(100) ;
  l_range_check    varchar2(10) ;
  --
BEGIN
  --
  hr_utility.set_location(' Entering:'|| l_proc, 10);
  --
  if p_default_value is not null and p_lookup_type is null then
      --
       hr_utility.set_location(l_proc, 20);
      --

    l_default_value := p_default_value ;
    --
    hr_chkfmt.checkformat
    (l_default_value,
     p_uom,
     l_default_value,
     p_min_value,
     p_max_value,
     'Y',
     l_range_check,
     p_input_currency_code
     );

    if l_range_check = 'F' then
      --
      if p_warning_or_error = 'E' then
        --
        hr_utility.set_location(l_proc,30);
        --
        fnd_message.set_name('PAY', 'HR_INPVAL_DEFAULT_INVALID');
        fnd_message.raise_error;
        --
      elsif p_warning_or_error = 'W' then
        --
        hr_utility.set_location(l_proc,40);
        --
        p_default_val_warning := TRUE ;
        --
      end if;
      --
    end if;
    --
  end if ;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);

END chk_default_value_format;
--

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
  ,p_rec             in pay_ivl_shd.g_rec_type
  ) IS
--

  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_ivl_shd.api_updating
      (p_input_value_id                   => p_rec.input_value_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

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
  (p_element_type_id               in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
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
  If ((nvl(p_element_type_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_element_types_f'
            ,p_base_key_column => 'ELEMENT_TYPE_ID'
            ,p_base_key_value  => p_element_type_id

            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','element types');
     hr_multi_message.add
       (p_associated_column1 => pay_ivl_shd.g_tab_nam || '.ELEMENT_TYPE_ID');
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
  (p_input_value_id                   in number
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
      ,p_argument       => 'input_value_id'
      ,p_argument_value => p_input_value_id
      );
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'ben_acty_base_rt_f'
       ,p_base_key_column => 'input_value_id'
       ,p_base_key_value  => p_input_value_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','acty base rt');
         hr_multi_message.add;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_link_input_values_f'
       ,p_base_key_column => 'input_value_id'

       ,p_base_key_value  => p_input_value_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','link input values');
         hr_multi_message.add;
    End If;
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
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action

      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_lookup_type >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to ensure that LOOKUP_TYPE can be entered only
--   when Unit Of Measure is 'Character' and is the one present in HR_LOOKUPS,
--   enabled and valid as of current date.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_lookup_type
( p_lookup_type varchar2
 ,p_uom varchar2
 ,p_effective_date date
) IS
cursor csr_lookup is
select 'X' from hr_lookups
where upper(lookup_type) = nvl(upper(p_lookup_type),lookup_type)
and enabled_flag = 'Y'
and p_effective_date between
nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);

l_dummy varchar2(1);

l_proc        varchar2(72)    := g_package||'chk_lookup_type';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

if p_lookup_type is not null and upper(p_uom) <> 'C' then
  fnd_message.set_name('PAY','PAY_34117_INVALID_UOM');
  fnd_message.raise_error;
else
  open csr_lookup;
    fetch csr_lookup into l_dummy;
    if csr_lookup%notfound then
      close csr_lookup;
      fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
      fnd_message.raise_error;
    end if;
    close csr_lookup;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_lookup_type;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_formula_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is used to ensure that FORMULA_ID is present in
--  FF_FORMULAS_F as of session date and must be of type
--  'ELEMENT INPUT VALIDATION'
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_formula_id
( p_business_group_id number
 ,p_legislation_code varchar2
 ,p_effective_date date
 ,p_formula_id number
) IS

cursor csr_formula is
select 'X'
from ff_formulas_f ff, ff_formula_types ft
where nvl(ff.legislation_code,nvl(p_legislation_code,'~~nvl~~'))
      = nvl(p_legislation_code,'~~nvl~~')
and nvl(ff.business_group_id, nvl(p_business_group_id,-1))=nvl(p_business_group_id,-1)
and p_effective_date between ff.effective_start_date and ff.effective_end_date
and ff.formula_type_id = ft.formula_type_id
and upper (ft.formula_type_name) = 'ELEMENT INPUT VALIDATION'
and ff.formula_id = p_formula_id;

l_dummy varchar2(1);

l_proc        varchar2(72)    := g_package||'chk_formula_id';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

if p_formula_id is not null then
  open csr_formula;
  fetch csr_formula into l_dummy;
  if csr_formula%notfound then
    close csr_formula;
    fnd_message.set_name('PAY','PAY_34116_INVALID_FORMULA');
    fnd_message.raise_error;
  end if;
  close csr_formula;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_formula_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_formula_validation >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_formula_validation
  (p_default_value           in  varchar2
  ,p_warning_or_error        in  varchar2
  ,p_effective_date          in  date
  ,p_input_value_id          in  number  default null
  ,p_formula_id              in  number  default null
  ,p_business_group_id       in  number
  ,p_default_formula_warning out nocopy boolean
  ,p_assignment_id_warning   out nocopy boolean
  ,p_formula_message         out nocopy varchar2
  ) is
  --
  l_proc              varchar2(72) := g_package||'chk_formula_val';
  l_formula_status    varchar2(10);
  l_formula_message   fnd_new_messages.message_text%type;
  l_formula_id        number;
  l_inputs            ff_exec.inputs_t;
  l_outputs           ff_exec.outputs_t;
  --
  Cursor C_formula
  is
    select formula_id
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;
  --
Begin
  hr_utility.set_location(' Entering:'||l_proc, 5);
  --
  If p_business_group_id is not null then
    --
    -- Validation is not done for startup elements
    --
    l_formula_id            := p_formula_id;
    p_assignment_id_warning := false;

    hr_utility.set_location(' Step 1:'||l_proc, 6);
    If (l_formula_id is null) then
      --
      Open C_formula;
      Fetch C_formula into l_formula_id;
      Close C_formula;
      --
    End If;
    --
    hr_utility.set_location(' Step 3:'||l_proc, 8);
    -- We need to call a formula to validate the default value.
    --For Bug No. 2879170 added if condtion.
   If  l_formula_id is not null then
    ff_exec.init_formula(l_formula_id,
                         p_effective_date,
                         l_inputs,
                         l_outputs);
    --
    -- Check the input count before attempting to
    -- set the input and context values.
    --
    hr_utility.set_location(' Step 4:'||l_proc, 9);
    If(l_inputs.count >= 1) then
       -- Set up the inputs and contexts to formula.
       For i in l_inputs.first..l_inputs.last loop
          If l_inputs(i).name = 'ASSIGNMENT_ID' then
             -- We cannot set assignment id at this level, hence
             -- raise warning and quit
             p_assignment_id_warning := True;
             exit;
          Elsif l_inputs(i).name = 'BUSINESS_GROUP_ID' then
             -- Set the business_group_id context.
             l_inputs(i).value := p_business_group_id;
          Elsif l_inputs(i).name = 'DATE_EARNED' then
             -- Set the date_earned context.
             l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
          Elsif l_inputs(i).name = 'ENTRY_VALUE' then
             -- Set the input to the entry value to be validated.
             -- Note - need to pass database format to formula.
             l_inputs(i).value := p_default_value;
          Else
             -- No context recognised.
             fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE', l_proc);
             fnd_message.set_token('STEP','10');
             fnd_message.raise_error;
          End if;
       End loop;
    End if;
    --
    -- Dont validate if the assignment context exists or if its a start up
    -- element.
    --
    If not p_assignment_id_warning then
      --
      ff_exec.run_formula(l_inputs, l_outputs);
      --
      -- Now obtain the return values. There should be
      -- exactly two outputs.
      If l_outputs.count <> 2 then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','20');
        fnd_message.raise_error;
      End if;
      --
      For i in l_outputs.first..l_outputs.last loop
        If l_outputs(i).name = 'FORMULA_MESSAGE' then
          --
          hr_utility.set_location(' Step 5:'||l_proc, 10);
          l_formula_message := l_outputs(i).value;
        Elsif l_outputs(i).name = 'FORMULA_STATUS' then
          --
          hr_utility.set_location(' Step 6:'||l_proc, 11);
          l_formula_status := upper(l_outputs(i).value);
        Else
          --
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE', l_proc);
          fnd_message.set_token('STEP','30');
          fnd_message.raise_error;
          --
        End if;
      End loop;
      --
      -- Check whether we have raised an error and act appropriately.
      --
       hr_utility.set_location(' Step 7:'||l_proc, 11);
      If l_formula_status <> 'S' and p_warning_or_error = 'E' then
        -- I.e. the formula validation failed and we need to raise an error.
        If l_formula_message is null then
          -- User not defined an error message.
          --
          fnd_message.set_name('PAY','PAY_33083_LK_INP_VAL_FORML_ERR');
          fnd_message.raise_error;
        Else
          -- User has defined message and so we can raise it.
          fnd_message.set_name('PAY','HR_ELE_ENTRY_FORMULA_HINT');
          fnd_message.set_token('FORMULA_TEXT', l_formula_message, false);
          fnd_message.raise_error;
        End if;
      Elsif l_formula_status <> 'S' and p_warning_or_error = 'W' then
        -- We have failed validation, but only want to warn.
        p_default_formula_warning := true;
        --
      End if;
      --
    End if;

    p_formula_message := l_formula_message;
    --
   End If;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_value_set_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_value_set_id (
  p_value_set_id number,
  p_uom varchar2
  ) is
  --
  l_proc varchar2(72) := g_package||'chk_value_set_id';
  l_validation_type varchar2(1);
  --
  cursor csr_value_set is
  select validation_type
  from fnd_flex_value_sets
  where flex_value_set_id = p_value_set_id;
  --
BEGIN
  --
  hr_utility.set_location(' Entering:'|| l_proc, 10);
  --
  if p_value_set_id is not null then
    -- Check uom is 'C'
    if upper(p_uom) <> 'C' then
      hr_utility.set_location(l_proc, 20);
      fnd_message.set_name('PAY','PAY_34117_INVALID_UOM');
      fnd_message.raise_error;
    else
    -- Check value set id is valid, i.e. that it exists and that the value
    -- set is table-validated, i.e. validation_type is 'F'
      open csr_value_set;
      fetch csr_value_set into l_validation_type;
      if csr_value_set%notfound or l_validation_type <> 'F' then
        close csr_value_set;
        hr_utility.set_location(l_proc, 30);
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','30');
        fnd_message.raise_error;
      end if;
      close csr_value_set;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
END chk_value_set_id;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_upd_display_sequence >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that display sequence is not updated
--  for an element's input values if there are paylink batch lines for the
--  element.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_display_sequence
(p_element_type_id number
,p_name varchar2
,p_display_sequence number) is

l_proc        varchar2(72)    := g_package||'chk_upd_display_sequence';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

if (p_name <> pay_ivl_shd.g_old_rec.name or p_display_sequence
    <> pay_ivl_shd.g_old_rec.display_sequence) then
  pay_element_types_pkg.check_for_paylink_batches
  (p_element_type_id    => p_element_type_id
  ,p_element_name   => p_name);
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_upd_display_sequence;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_upd_generate_db_items_flag >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will ensure that if generate_db_items_flag is updated
--  and the datetrack mode is not CORRECTION then it will force CORRECTION
--  mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_generate_db_items_flag
(p_datetrack_mode IN OUT NOCOPY varchar2
,p_generate_db_items_flag IN varchar2)
IS

l_proc        varchar2(72)    := g_package||'chk_upd_generate_db_items_flag';

l_count       number;

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

if (p_generate_db_items_flag <> pay_ivl_shd.g_old_rec.generate_db_items_flag)
   and p_datetrack_mode <> 'CORRECTION' then
  open csr_row_count;
  fetch csr_row_count into l_count;
  close csr_row_count;
  if l_count > 1 then
    fnd_message.set_name('PAY', 'PAY_34151_ELE_NO_DATE_UPD');
    fnd_message.raise_error;
  else
    p_datetrack_mode := 'CORRECTION';
  end if;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_upd_generate_db_items_flag;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_upd_name >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following checks if name is updated
--  1) Ensure that the mode is CORRECTION , if not then force it.
--  2) Check that the name is unique for the element type id
--  3) Name is not updated if its a 'Pay Value' or updated to become a
--     'Pay Value'
--  4) Name is not updated if contributions used for element type is Yes
--     and the name is one of these 'Coverage','EE Contr' and 'ER Contr'
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_name
(p_datetrack_mode IN OUT NOCOPY varchar2
,p_name IN varchar2
,p_effective_date in date
,p_element_type_id IN number)

IS

cursor csr_ben_contri is
select contributions_used from
ben_benefit_classifications
where benefit_classification_id in ( select distinct benefit_classification_id
                          from pay_element_types_f
                          where element_type_id = p_element_type_id
                          and p_effective_date between effective_start_date
                          and effective_end_date);

l_dummy varchar2(1);

l_proc        varchar2(72)    := g_package||'chk_upd_name';
l_name        pay_input_values_f.name%type := p_name;
l_boolean     boolean;
l_chk_name    pay_input_values_f.name%type;

l_count       number;

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);


if (p_name <> pay_ivl_shd.g_old_rec.name) then

  -- Force Correction mode
  if p_datetrack_mode <> 'CORRECTION' then
    open csr_row_count;
      fetch csr_row_count into l_count;
      close csr_row_count;
      if l_count > 1 then
        fnd_message.set_name('PAY', 'PAY_34151_ELE_NO_DATE_UPD');
        fnd_message.raise_error;
      else
        p_datetrack_mode := 'CORRECTION';
      end if;
  end if;

  -- Check if the new name is unique
  l_boolean := pay_input_values_pkg.name_not_unique
  (p_element_type_id,
   null,
   l_name,
   p_error_if_true => TRUE);


  -- Check if the name is in proper format
  hr_chkfmt.checkformat
  (l_name,
  'PAY_NAME',
   l_chk_name,
   null,
   null,
   'N',
   l_chk_name,
   null);

 -- Check that PAY VALUE name is not updated
 if upper(p_name) = 'PAY VALUE' then
   fnd_message.set_name('PAY', 'PAY_34126_NAME_PAY_VAL_UPD');
   fnd_message.raise_error;
 end if;

 -- Check for the new name
 if upper(pay_ivl_shd.g_old_rec.name) = 'PAY VALUE' then
   fnd_message.set_name('PAY', 'PAY_34126_NAME_PAY_VAL_UPD');
   fnd_message.raise_error;
 end if;

 -- Name is not updated if contributions used for element type is Yes
 -- and the name is one of these 'Coverage','EE Contr' and 'ER Contr'
 open csr_ben_contri;
 fetch csr_ben_contri into l_dummy;

 if l_dummy = 'Y' and upper(pay_ivl_shd.g_old_rec.name)
    in ('COVERAGE','EE CONTR','ER CONTR')
 then
   close csr_ben_contri;
   fnd_message.set_name('PAY', 'PAY_33078_LK_INP_VAL_NO_UPD');
   fnd_message.raise_error;
 end if;
 close csr_ben_contri;

 end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_upd_name;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_upd_uom >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that if the UOM is updated, force the datetrack
--  mode to CORRECTION, if not the same.Also check that the UOM is updated
--  only in its class and recreate db items.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_uom
(p_datetrack_mode IN OUT NOCOPY varchar2
,p_uom IN varchar2
,p_input_value_id in number
,p_effective_date in date)
IS
cursor csr_uom is
select lookup_code from
hr_lookups
where upper(substr(lookup_code,1,2))
    = upper(substr(pay_ivl_shd.g_old_rec.uom,1,2))
and lookup_type = 'UNITS'
and enabled_flag = 'Y'
and p_effective_date between
nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);

l_dummy varchar2(1);

l_count       number;

l_proc        varchar2(72)    := g_package||'chk_upd_uom';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

-- Check that the UOM if updated to a not null value is
-- within  the class as the previous UOM value
if (p_uom <> pay_ivl_shd.g_old_rec.uom and p_uom is not null) then
  if p_datetrack_mode <> 'CORRECTION' then
    open csr_row_count;
    fetch csr_row_count into l_count;
    close csr_row_count;
    if l_count > 1 then
      fnd_message.set_name('PAY', 'PAY_34151_ELE_NO_DATE_UPD');
      fnd_message.raise_error;
    else
      p_datetrack_mode := 'CORRECTION';
    end if;
  end if;
  if pay_ivl_shd.g_old_rec.uom is not null then
    for rec in csr_uom
    loop
      if substr(rec.lookup_code,1,2) <> substr(p_uom,1,2) then
        fnd_message.set_name('PAY', 'PAY_34127_UOM_UPD_CLASS');
        fnd_message.raise_error;
      end if;
    end loop;
  end if;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_upd_uom;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_upd_def_value_null >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will ensure that update fails if
--  the input value is used in a pay basis or there exists
--  element entries for this hot defaulted input value
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_def_value_null
(p_input_value_id in number
,p_effective_date in date
,p_default_value  in varchar2
,p_pay_basis_warning out nocopy boolean)
IS

cursor csr_pay_basis is
        select  1
        from    per_pay_bases
        where   input_value_id = p_input_value_id;

cursor csr_entries is
        select  1
        from    pay_element_entry_values_f
        where   input_value_id           = p_input_value_id
        and     p_effective_date between effective_start_date
        and     effective_end_date;


l_dummy varchar2(1);


l_proc        varchar2(72)    := g_package||'chk_upd_def_value_null';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

open csr_pay_basis;

-- Check for pay basis

fetch csr_pay_basis into l_dummy;
if csr_pay_basis%found then
  close csr_pay_basis;
  p_pay_basis_warning := TRUE;
end if;
close csr_pay_basis;


if p_default_value is null then
  -- Check for element entries and Hot default flag

  open csr_entries;
  fetch csr_entries into l_dummy;
  if csr_entries%found and pay_ivl_shd.g_old_rec.hot_default_flag = 'Y' then
    close csr_entries;
    fnd_message.set_name('PAY', 'PAY_34128_DEF_VAL_HOT_DEF');
    fnd_message.raise_error;
  end if;
  close csr_entries;
end if;

hr_utility.set_location(' Entering:'|| l_proc, 10);

END chk_upd_def_value_null;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_upd_mand_flag >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure ensures that the mandatory flag cannot be changed from
--  'N' to 'Y'.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_mand_flag
(p_mandatory_flag varchar2
) IS

l_proc        varchar2(72)    := g_package||'chk_upd_mand_flag';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);


  if pay_ivl_shd.g_old_rec.mandatory_flag = 'N' and p_mandatory_flag = 'Y' then
  fnd_message.set_name('PAY', 'PAY_34125_MAN_FLAG_UPD');
  fnd_message.raise_error;
  end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_upd_mand_flag;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_hot_default_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that hot default flag is not set to 'Y'
--  if mandatory flag is not 'Y'
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_hot_default_flag
(p_mandatory_flag varchar2
,p_hot_default_flag varchar2
) IS
l_proc        varchar2(72)    := g_package||'chk_hot_default_flag';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

  if p_hot_default_flag = 'Y' and p_mandatory_flag <> 'Y' then
  fnd_message.set_name('PAY','PAY_34119_HOT_DEFAULT_FLAG');
  fnd_message.raise_error;
  end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_hot_default_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_name >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--  1)  Validate NAME as a valid db item name using hr_fmt.checkformat
--  2)  NAME must be unique for a element
--  3)  The name 'Pay Value' must have a UOM of 'Money' if the element
--      classifications is of PAYMENTS type
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_name
(p_name varchar2
,p_element_type_id number
,p_uom varchar2
) IS

cursor csr_classification is
select non_payments_flag
from pay_element_classifications
where classification_id in ( select distinct classification_id
                            from pay_element_types_f
                            where element_type_id = p_element_type_id);

l_boolean boolean;
l_name pay_input_values_f.name%type := p_name;
l_dummy varchar2(100);

l_proc        varchar2(72)    := g_package||'chk_name';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

-- Check that the name is unique

l_boolean := pay_input_values_pkg.name_not_unique
(p_element_type_id,
 null,
 l_name,
 p_error_if_true => TRUE);

-- Check the name for proper format
 hr_chkfmt.checkformat
 (l_name,
 'PAY_NAME',
  l_dummy,
  null,
  null,
  'N',
  l_dummy,
  null);

-- Check that the name 'Pay Value' must have a UOM of 'Money' if the element
-- classifications is of PAYMENTS type

 open csr_classification;
 fetch csr_classification into l_dummy;
 close csr_classification;


 if upper(l_name) =  'PAY VALUE' and upper(p_uom) <> 'M' and l_dummy = 'N' then
   fnd_message.set_name('PAY', 'PAY_34122_UOM_MONEY_PAYMENTS');
   fnd_message.raise_error;
 end if;

 hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_name;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_uom >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--  1) The UOM cannot be 'Money' if no currencies have been specified for the
--     element type
--  2) Validate UOM with HR_LOOKUPS having LOOKUP_TYPE as 'UNITS'
--     and lookup_code not equal to 'M' if element_types'
--     output_currency_code is null
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_uom
(p_element_type_id in number
,p_uom in varchar2
,p_effective_date in date
) IS
cursor csr_currency is

select input_currency_code
from pay_element_types_f
where element_type_id = p_element_type_id;

cursor csr_lookup is
select 'X' from hr_lookups
where upper(lookup_code) = nvl(upper(p_uom),lookup_code)
and lookup_type = 'UNITS'
and enabled_flag = 'Y'
and p_effective_date between
nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);

l_dummy varchar2(1);

l_proc        varchar2(72)    := g_package||'chk_uom';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

for rec in csr_currency
loop
  if rec.input_currency_code is null and upper(p_uom) = 'M' then
    fnd_message.set_name('PAY', 'PAY_6626_INPVAL_NO_MONEY_UOM');
    fnd_message.raise_error;
  end if;
end loop;

open csr_lookup;

fetch csr_lookup into l_dummy;
if csr_lookup%notfound then
  fnd_message.set_name('PAY', 'PAY_6171_INPVAL_NO_LOOKUP');
  fnd_message.raise_error;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_uom;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_default_value >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--  1) DEFAULT_VALUE has to be validated against HR_LOOKUPS for lookup_type
--     equal to specified in LOOKUP_TYPE field (active as of current date),
--     if not null
--
--  2) DEFAULT_VALUE must lie between MIN_VALUE and MAX_VALUE (if LOOKUP_TYPE is
--     null) and if DEFAULT_VALUE does not lie between MIN_VALUE and MAX_VALUE
--     then depending on whether WARNING_OR_ERROR is 'E', an error must be
--     raised else just a warning must be issued
-- ----------------------------------------------------------------------------
PROCEDURE chk_default_value
( p_element_type_id     in number
 ,p_default_value       in varchar2
 ,p_lookup_type         in varchar2
 ,p_value_set_id        in number
 ,p_min_value           in varchar2
 ,p_max_value           in varchar2
 ,p_uom                 in varchar2
 ,p_warning_or_error    in varchar2
 ,p_effective_date      in date
 ,p_default_val_warning out nocopy boolean
)
IS
  --
  cursor csr_lookup is
  select 'X' from hr_lookups
  where upper(lookup_code) = nvl(upper(p_default_value),lookup_code)
  and lookup_type = p_lookup_type
  and enabled_flag = 'Y'
  and p_effective_date between
  nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);
  --
  cursor csr_currency(p_element_type_id number) is
  select input_currency_code
  from pay_element_types_f
  where element_type_id = p_element_type_id;
  --
  l_dummy varchar(1);
  l_proc        varchar2(72)    := g_package||'chk_default_value';
  l_input_currency_code varchar2(10) ;
  --
BEGIN
  --
  hr_utility.set_location(' Entering:'|| l_proc, 10);
  --
  if p_default_value is not null then
    --
    if p_lookup_type is not null then
      --
      hr_utility.set_location(l_proc, 20);
      --
      open csr_lookup;
      fetch csr_lookup into l_dummy;
      --
      if csr_lookup%notfound then
        --
        hr_utility.set_location(l_proc, 30);
        --
        close csr_lookup;
        --
        fnd_message.set_name('PAY', 'PAY_6171_INPVAL_NO_LOOKUP');
        fnd_message.raise_error;
        --
      end if;
      --
      close csr_lookup;
      --
    elsif p_value_set_id is not null then
      --
      hr_utility.set_location(l_proc,40);
      if pay_input_values_pkg.decode_vset_value (
           p_value_set_id,
           p_default_value ) is null then
        --
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','40');
        fnd_message.raise_error;
        --
      end if;
      --

      -- Bug 6164772

    elsif (p_min_value is not null or p_max_value is not null) then
      --
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      --
      open csr_currency(p_element_type_id);
      fetch csr_currency into l_input_currency_code ;
      close csr_currency;
      --
      pay_ivl_bus.chk_default_value_format
      ( p_default_value
       ,p_lookup_type
       ,p_min_value
       ,p_max_value
       ,p_uom
       ,l_input_currency_code
       ,p_warning_or_error
       ,p_default_val_warning
       );

    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
  --
END chk_default_value;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_upd_default_value >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--  1) DEFAULT_VALUE has to be validated against HR_LOOKUPS for lookup_type
--     equal to specified in LOOKUP_TYPE field (active as of current date),
--     if not null
--  2) DEFAULT_VALUE must lie between MIN_VALUE and MAX_VALUE (if LOOKUP_TYPE
--     is null) and if DEFAULT_VALUE does not lie between MIN_VALUE and
--     MAX_VALUE then depending on whether WARNING_OR_ERROR is 'E', an
--     error must be raised else just a warning must be issued
-- ----------------------------------------------------------------------------
/* Commented for bug 6164772 - Use chk_default_value in place of chk_upd_default_value
   as both do the same validations.

PROCEDURE chk_upd_default_value
( p_default_value       in varchar2
 ,p_lookup_type         in varchar2
 ,p_value_set_id        in number
 ,p_min_value           in varchar2
 ,p_max_value           in varchar2
 ,p_warning_or_error    in varchar2
 ,p_effective_date      in date
 ,p_default_val_warning out nocopy boolean
)
IS
  --
  cursor csr_lookup is
  select 'X'
  from hr_lookups
  where upper(lookup_code) = nvl(upper(p_default_value),lookup_code)
  and lookup_type = decode(p_lookup_type,
                      hr_api.g_varchar2, pay_ivl_shd.g_old_rec.lookup_type,
                      p_lookup_type)
  and enabled_flag = 'Y'
  and p_effective_date between nvl(start_date_active,hr_api.g_sot)
                       and nvl(end_date_active,hr_api.g_eot);
  --
  l_dummy varchar(1);
  l_value_set_id number;
  l_proc  varchar2(72)    := g_package||'chk_upd_default_value';
  --
BEGIN
  --
  hr_utility.set_location(' Entering:'|| l_proc, 10);
  --
  if p_lookup_type is not null or (
    pay_ivl_shd.g_old_rec.lookup_type is not null and
    p_lookup_type = hr_api.g_varchar2
    ) then
    --
    open csr_lookup;
    fetch csr_lookup into l_dummy;
    --
    if csr_lookup%notfound then
      --
      close csr_lookup;
      --
      fnd_message.set_name('PAY', 'PAY_6171_INPVAL_NO_LOOKUP');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_lookup;
    --
  elsif p_value_set_id is not null and p_default_value is not null and
    p_default_value <> hr_api.g_varchar2 and (
      p_value_set_id <> hr_api.g_number or (
        pay_ivl_shd.g_old_rec.value_set_id is not null and
        p_value_set_id = hr_api.g_number
      )
    ) then
    --
    if p_value_set_id = hr_api.g_number then
      --
      -- Value set id is not changing, use the old one
      --
      l_value_set_id := pay_ivl_shd.g_old_rec.value_set_id;
      --
    else
      --
      -- Value set id is changing, use the new one
      --
      l_value_set_id := p_value_set_id;
      --
    end if;
    --
    hr_utility.set_location(l_proc,20);
    --
    -- Validate the default value using l_value_set_id
    --
    if pay_input_values_pkg.decode_vset_value (
        l_value_set_id,
        p_default_value ) is null then
      --
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','20');
      fnd_message.raise_error;
      --
    end if;
    --
  elsif pay_ivl_shd.g_old_rec.min_value is not null
      or pay_ivl_shd.g_old_rec.max_value is not null then
    --
    if p_min_value <> pay_ivl_shd.g_old_rec.min_value OR p_max_value <> pay_ivl_shd.g_old_rec.max_value then
      --
      if (p_default_value <= p_min_value or
          p_default_value >= p_max_value) then
        --
        if p_warning_or_error = 'E' then
          --
          fnd_message.set_name('PAY', 'PAY_6303_INPUT_VALUE_OUT_RANGE');
          fnd_message.raise_error;
          --
        elsif p_warning_or_error = 'W' then
          --
          p_default_val_warning := TRUE ;
          --
        end if;
        --
      end if;
      --
    else
    --
    if (p_default_value <= pay_ivl_shd.g_old_rec.min_value or
      p_default_value >= pay_ivl_shd.g_old_rec.max_value) then
      --
      if p_warning_or_error = 'E' then
        --
        fnd_message.set_name('PAY', 'PAY_6303_INPUT_VALUE_OUT_RANGE');
        fnd_message.raise_error;
        --
      elsif p_warning_or_error = 'W' then
        --
        p_default_val_warning := TRUE ;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
END chk_upd_default_value;
*/

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_max_min_value >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check if MIN_VALUE is less than or equal to MAX_VALUE
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_max_min_value
( p_element_type_id  in number
 ,p_max_value        in varchar2
 ,p_min_value        in varchar2
 ,p_uom              in varchar2
 ,p_warning_or_error in varchar2
 ,p_lookup_type      in varchar2
 ,p_min_max_warning  out nocopy boolean
)
IS
  --
  cursor csr_currency(p_element_type_id number) is
  select input_currency_code
  from pay_element_types_f
  where element_type_id = p_element_type_id;
  --
  l_proc        varchar2(72)    := g_package||'chk_max_min_value';
  l_range_check varchar2(10);
  l_input_currency_code varchar2(10) ;
  l_max_value varchar2(255);
  --
BEGIN
  --
  hr_utility.set_location(' Entering:'|| l_proc, 10);
  --
  if(p_max_value is not null and p_min_value is not null) then
    --
    hr_utility.set_location(' Entering:'|| l_proc, 20);
    --
    open csr_currency(p_element_type_id);
    fetch csr_currency into l_input_currency_code ;
    close csr_currency;
    --
    l_max_value := p_max_value;
    hr_chkfmt.checkformat
     ( l_max_value
      ,p_uom
      ,l_max_value
      ,p_min_value
      ,null
      ,'Y'
      ,l_range_check
      ,l_input_currency_code
     );
    --
    if l_range_check = 'F' then
      --
      if p_warning_or_error = 'E' then
        --
        fnd_message.set_name('PAY', 'HR_51975_ALL_MAX_MORE_MIN');
        fnd_message.raise_error;
        --
      elsif p_warning_or_error = 'W' then
        --
        p_min_max_warning := TRUE;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
END chk_max_min_value;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_warning_or_error>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--  1) WARNING_OR_ERROR must be set in case a MIN_VALUE/MAX_VALUE/FORMULA_ID
--     is specified
--  2) Validate with HR_LOOKUPS having LOOKUP_TYPE as 'WARNING_ERROR'
--     and active as of current date
-- ----------------------------------------------------------------------------
PROCEDURE chk_warning_or_error
(p_warning_or_error in varchar2
,p_lookup_type in varchar2
,p_min_value in varchar2
,p_max_value in varchar2
,p_formula_id in varchar2
,p_effective_date in date
)
IS
  cursor csr_lookup is
  select 'X' from hr_lookups
  where upper(lookup_code) = nvl(upper(p_warning_or_error),lookup_code)
  and lookup_type = 'WARNING_ERROR'
  and enabled_flag = 'Y'
  and p_effective_date between
  nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);

  l_dummy varchar2(1);
  l_proc        varchar2(72)    := g_package||'chk_warning_or_error';
BEGIN

  hr_utility.set_location(' Entering:'|| l_proc, 10);

if (p_min_value is not null or p_max_value is not null or p_formula_id
      is not NULL)
  --   or p_lookup_type is not null)  -- bug 8675578
     and p_warning_or_error is null then
     fnd_message.set_name('PAY','PAY_34121_WARN_ERROR_MAND');
     fnd_message.raise_error;
  elsif (p_min_value is null and p_max_value is null)
     and p_formula_id is null
     and p_lookup_type is null                     -- 6164772
     and p_warning_or_error is not null then
     fnd_message.set_name('PAY','PAY_6908_INPVAL_ERROR_VAL');
     fnd_message.raise_error;
  end if;

  open csr_lookup;
  fetch csr_lookup into l_dummy;
  if csr_lookup%notfound then
    close csr_lookup;
    fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
    fnd_message.raise_error;
  end if;
  close csr_lookup;

  hr_utility.set_location(' Leaving:'|| l_proc, 10);
END chk_warning_or_error;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_other_insert_val>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--  1) Only 15 input values can be created for each element
--  2) Insert should not be allowed if there exists
--     element entries or pay run results for this element type
--  3) Any of the following combinations can be entered at a time,
--    1) FORMULA_ID and DEFAULT_VALUE
--    2) LOOKUP_TYPE and DEFAULT_VALUE
--    3) DEFAULT_VALUE, MIN_VALUE and MAX_VALUE
--    4) VALUE_SET_ID and DEFAULT_VALUE
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_other_insert_val
  (p_element_type_id   in number
  ,p_formula_id        in number
  ,p_lookup_type       in varchar2
  ,p_value_set_id      in number
  ,p_min_value         in varchar2
  ,p_max_value         in varchar2
  ,p_start_date        in date
  ,p_end_date          in date
  ,p_pay_basis_warning out nocopy boolean
  )
IS
  cursor csr_run_results is
  select 1
  from   dual
  where  exists
       (select /*+ INDEX(PAYROLL PAY_PAYROLL_ACTIONS_PK)
                   INDEX(ASSIGN  PAY_ASSIGNMENT_ACTIONS_PK) */ 1
        from    pay_run_results RUN,
                pay_payroll_actions PAYROLL,
                pay_assignment_actions ASSIGN
        where   run.element_type_id = p_element_type_id
        and     assign.assignment_action_id = run.assignment_action_id
        and     assign.payroll_action_id = payroll.payroll_action_id
        and     payroll.effective_date between p_start_date
                                           and     p_end_date);

  cursor csr_pay_basis is
        select  1 pay
        from    per_pay_bases
        where   input_value_id in ( select input_value_id
                                    from pay_input_values_f
                                    where element_type_id = p_element_type_id);

  l_dummy varchar2(1);
  l_proc        varchar2(72)    := g_package||'chk_other_insert_val';

BEGIN

  hr_utility.set_location(' Entering:'|| l_proc, 10);
  if pay_input_values_pkg.no_of_input_values(p_element_type_id) >= 15 then
    fnd_message.set_name('PAY','HR_7124_INPVAL_MAX_ENTRIES');
    fnd_message.raise_error;
  end if;

  open csr_run_results;
  fetch csr_run_results into l_dummy;
  if csr_run_results%found
    or pay_element_types_pkg.element_entries_exist (
         p_element_type_id,
         p_error_if_true => TRUE
       ) then
    fnd_message.set_name('PAY','PAY_34123_CANNOT_CR_INP_VAL');
    fnd_message.raise_error;
  end if;
  close csr_run_results;
  if p_formula_id is not null and (
    p_lookup_type is not null or
    p_value_set_id is not null or
    p_min_value is not null or
    p_max_value is not null
    ) then
    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;
  elsif p_lookup_type is not null and (
    p_formula_id is not null or
    p_value_set_id is not null or
    p_min_value is not null or
    p_max_value is not null
    ) then
    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;
  elsif p_value_set_id is not null and (
    p_formula_id is not null or
    p_lookup_type is not null or
    p_min_value is not null or
    p_max_value is not null
    ) then
    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;
  elsif (p_min_value is not null or p_max_value is not null) and (
    p_formula_id is not null or
    p_lookup_type is not null or
    p_value_set_id is not null
    ) then
    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;
  end if;

  for rec in csr_pay_basis
  loop
  if rec.pay = '1' then
    p_pay_basis_warning := TRUE;
  end if;
  end loop;

  hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_other_insert_val;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_other_upd_val>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check only one of the following combinations can be
--  entered at a time,
--    1) FORMULA_ID and DEFAULT_VALUE
--    2) LOOKUP_TYPE and DEFAULT_VALUE
--    3) DEFAULT_VALUE, MIN_VALUE and MAX_VALUE
--    4) VALUE_SET_ID and DEFAULT_VALUE
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_other_upd_val
(p_formula_id in number
,p_lookup_type in varchar2
,p_value_set_id in number
,p_min_value in varchar2
,p_max_value in varchar2
)
IS

BEGIN

  if pay_ivl_shd.g_old_rec.formula_id is not null and
    p_formula_id is not null and (
    p_lookup_type is not null or
    p_value_set_id is not null or
    p_min_value is not null or
    p_max_value is not null
    ) then

    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;

  elsif pay_ivl_shd.g_old_rec.lookup_type is not null and
    p_lookup_type is not null and (
    p_formula_id is not null or
    p_value_set_id is not null or
    p_min_value is not null or
    p_max_value is not null
    ) then

    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;

  elsif pay_ivl_shd.g_old_rec.value_set_id is not null and
    p_value_set_id is not null and (
    p_formula_id is not null or
    p_lookup_type is not null or
    p_min_value is not null or
    p_max_value is not null
    ) then

    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;

  elsif (pay_ivl_shd.g_old_rec.min_value is not null and
    p_min_value is not null or
    pay_ivl_shd.g_old_rec.max_value is not null and
    p_max_value is not null) and (
    p_formula_id is not null or
    p_lookup_type is not null or
    p_value_set_id is not null
    ) then

    fnd_message.set_name('PAY','PAY_6170_INPVAL_VAL_COMB');
    fnd_message.raise_error;

  end if;

END chk_other_upd_val;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_raise_warning>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will set p_link_inp_val_warning to TRUE if name or
--  default value or lookup type or min value or max value or warning_or_error
--  is updated
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_raise_warning
(p_lookup_type in varchar2
,p_name in varchar2
,p_default_value in varchar2
,p_min in varchar2
,p_max in varchar2
,p_warning_or_error in varchar2
,p_link_inp_val_warning IN OUT NOCOPY boolean)
IS

l_proc        varchar2(72)    := g_package||'chk_raise_warning';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);


if p_lookup_type <> pay_ivl_shd.g_old_rec.lookup_type
   OR p_default_value <> pay_ivl_shd.g_old_rec.default_value OR p_min <> pay_ivl_shd.g_old_rec.min_value
   OR p_max <> pay_ivl_shd.g_old_rec.max_value OR p_warning_or_error <> pay_ivl_shd.g_old_rec.warning_or_error
   then
 p_link_inp_val_warning := TRUE;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_raise_warning;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_delete_allowed>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will do the following validations
--    a) Not allowed for all delete modes if the element has
--       benefit contributions_used flag as 'Y'
--       and name is 'Coverage' or 'EE Contr' or 'ER Contr', except when
--       the element itself is deleted.
--    b) Not allowed for date effective delete for the following scenarios
--       1. Formula result rules apply to this input value (either as
--       indirect or update recurring) after the new end date and
--       the rules are not self-referential.
--       2. An absence exists for a range of time outside of
--       the new date-effective lifetime of the input value.
--    c) Not allowed for ZAP mode for the following scenarios
--       1. Element entry values for the input value exist.
--       2. Run result values for the input value exist.
--       3. Compiled formulae use db items of the input value
--       4. Formula result rules refer to the input value, and those
--          rules are not self-referential.
--       5. Absence attendance types exist for this input value.
--       6. BackPay rules exist for this input value.
--       7. The input value is PAY_VALUE and links exist for the
--          element type with a costable type of 'Distributed'.
--       8. The input value is used by a salary basis.
--       9. The input value is used by an accrual plan.
--       10. The input value is used by a net calculation rule.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_delete_allowed
(p_datetrack_mode in varchar2
,p_input_value_id in number
,p_element_type_id in number
,p_effective_date in date
,p_start_date in date
,p_end_date in date)
IS
cursor csr_classification is

select contributions_used
from ben_benefit_classifications
where benefit_classification_id in ( select distinct benefit_classification_id
                            from pay_element_types_f
                            where element_type_id = p_element_type_id
                            and p_effective_date between effective_start_date
                            and effective_end_date);

cursor csr_name is
select 'X'
from pay_input_values_f
where input_value_id = p_input_value_id
and upper(name) in ('COVERAGE','EE CONTR','ER CONTR');

l_dummy varchar2(100);
l_name varchar2(100);

l_proc        varchar2(72)    := g_package||'chk_delete_allowed';

BEGIN

hr_utility.set_location(' Entering:'|| l_proc, 10);

 open csr_classification;
 fetch csr_classification into l_dummy;
 close csr_classification;

 open csr_name;
 fetch csr_name into l_name;

 if csr_name%found and l_dummy = 'Y' then
   close csr_name;
   fnd_message.set_name('PAY','PAY_34129_INPVAL_NAME_DEL');
   fnd_message.raise_error;
 end if;
 close csr_name;

if pay_input_values_pkg.deletion_allowed (
p_input_value_id,
p_datetrack_mode ,
p_start_date ,
p_end_date   ,
TRUE) then
null;
end if;

hr_utility.set_location(' Leaving:'|| l_proc, 10);

END chk_delete_allowed;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_ivl_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_default_val_warning   out nocopy boolean
  ,p_min_max_warning       out nocopy boolean
  ,p_pay_basis_warning     out nocopy boolean
  ,p_formula_warning       out nocopy boolean
  ,p_assignment_id_warning out nocopy boolean
  ,p_formula_message       out nocopy varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_ivl_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
   pay_ivl_bus.chk_other_insert_val
       (p_element_type_id => p_rec.element_type_id
       ,p_formula_id => p_rec.formula_id
       ,p_lookup_type => p_rec.lookup_type
       ,p_value_set_id => p_rec.value_set_id
       ,p_min_value =>  p_rec.min_value
       ,p_max_value =>  p_rec.max_value
       ,p_start_date => p_validation_start_date
       ,p_end_date   => p_validation_end_date
       ,p_pay_basis_warning => p_pay_basis_warning
       );

       pay_ivl_bus.chk_lookup_type
       (p_lookup_type => p_rec.lookup_type
       ,p_uom         => p_rec.uom
       ,p_effective_date => p_effective_date);

       pay_ivl_bus.chk_formula_id
       ( p_business_group_id => p_rec.business_group_id
        ,p_legislation_code  => p_rec.legislation_code
        ,p_effective_date    => p_effective_date
        ,p_formula_id        => p_rec.formula_id
       );

       pay_ivl_bus.chk_formula_validation
       ( p_default_value           => p_rec.default_value
        ,p_warning_or_error        => p_rec.warning_or_error
        ,p_effective_date          => p_effective_date
        ,p_formula_id              => p_rec.formula_id
        ,p_business_group_id       => p_rec.business_group_id
        ,p_default_formula_warning => p_formula_warning
        ,p_assignment_id_warning   => p_assignment_id_warning
        ,p_formula_message         => p_formula_message
       );

       pay_ivl_bus.chk_value_set_id (
         p_value_set_id => p_rec.value_set_id,
         p_uom          => p_rec.uom
       );

       pay_ivl_bus.chk_hot_default_flag
       (p_mandatory_flag => p_rec.mandatory_flag
       ,p_hot_default_flag => p_rec.hot_default_flag
       );

       pay_ivl_bus.chk_name
       (p_name => p_rec.name
       ,p_element_type_id => p_rec.element_type_id
       ,p_uom => p_rec.uom
       );

       pay_ivl_bus.chk_uom
       (p_element_type_id => p_rec.element_type_id
       ,p_uom  => p_rec.uom
       ,p_effective_date => p_effective_date     );

       -- Bug 6164772. Changed the order of call to raise proper error message
       -- when check_format() errors from within

       pay_ivl_bus.chk_max_min_value
       (p_element_type_id => p_rec.element_type_id
       ,p_max_value => p_rec.max_value
       ,p_min_value => p_rec.min_value
       ,p_uom => p_rec.uom
       ,p_warning_or_error => p_rec.warning_or_error
       ,p_lookup_type => p_rec.lookup_type
       ,p_min_max_warning => p_min_max_warning
       );

       pay_ivl_bus.chk_default_value
       ( p_element_type_id => p_rec.element_type_id
        ,p_default_value  => p_rec.default_value
        ,p_lookup_type => p_rec.lookup_type
        ,p_value_set_id => p_rec.value_set_id
        ,p_min_value => p_rec.min_value
        ,p_max_value => p_rec.max_value
        ,p_uom => p_rec.uom
        ,p_warning_or_error => p_rec.warning_or_error
        ,p_effective_date => p_effective_date
        ,p_default_val_warning => p_default_val_warning
       );

       pay_ivl_bus.chk_warning_or_error
       (p_warning_or_error => p_rec.warning_or_error
       ,p_lookup_type => p_rec.lookup_type
       ,p_min_value => p_rec.min_value
       ,p_max_value => p_rec.max_value
       ,p_formula_id => p_rec.formula_id
       ,p_effective_date => p_effective_date
       );
     END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_ivl_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in out nocopy varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_default_val_warning     out nocopy boolean
  ,p_min_max_warning         out nocopy boolean
  ,p_link_inp_val_warning    out nocopy boolean
  ,p_pay_basis_warning       out nocopy boolean
  ,p_formula_warning         out nocopy boolean
  ,p_assignment_id_warning   out nocopy boolean
  ,p_formula_message         out nocopy varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
  l_default_formula_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --

     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_ivl_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
  hr_multi_message.end_validation_set;

  END IF;
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
     pay_ivl_bus.chk_other_upd_val
       (p_formula_id => p_rec.formula_id
       ,p_lookup_type => p_rec.lookup_type
       ,p_value_set_id => p_rec.value_set_id
       ,p_min_value => p_rec.min_value
       ,p_max_value => p_rec.max_value);

       pay_ivl_bus.chk_upd_generate_db_items_flag
       (p_datetrack_mode => p_datetrack_mode
       ,p_generate_db_items_flag => p_rec.generate_db_items_flag);

       pay_ivl_bus.chk_upd_name
       (p_datetrack_mode => p_datetrack_mode
       ,p_name => p_rec.name
       ,p_effective_date => p_effective_date
       ,p_element_type_id => p_rec.element_type_id);

       pay_ivl_bus.chk_upd_uom
       (p_datetrack_mode  => p_datetrack_mode
       ,p_uom => p_rec.uom
       ,p_input_value_id => p_rec.input_value_id
       ,p_effective_date => p_effective_date);

       pay_ivl_bus.chk_upd_def_value_null
       (p_input_value_id => p_rec.input_value_id
       ,p_effective_date => p_effective_date
       ,p_default_value => p_rec.default_value
       ,p_pay_basis_warning => p_pay_basis_warning);

       pay_ivl_bus.chk_upd_mand_flag
       (p_mandatory_flag => p_rec.mandatory_flag
       );

       pay_ivl_bus.chk_hot_default_flag
       (p_mandatory_flag => p_rec.mandatory_flag
       ,p_hot_default_flag => p_rec.hot_default_flag);

       pay_ivl_bus.chk_lookup_type
       (p_lookup_type => p_rec.lookup_type
       ,p_uom         => p_rec.uom
       ,p_effective_date => p_effective_date);

       pay_ivl_bus.chk_formula_id
       ( p_business_group_id => p_rec.business_group_id
        ,p_legislation_code  => p_rec.legislation_code
        ,p_effective_date    => p_effective_date
        ,p_formula_id        => p_rec.formula_id
       );

       pay_ivl_bus.chk_formula_validation
       ( p_default_value           => p_rec.default_value
        ,p_warning_or_error        => p_rec.warning_or_error
        ,p_effective_date          => p_effective_date
        ,p_formula_id              => p_rec.formula_id
        ,p_business_group_id       => p_rec.business_group_id
        ,p_default_formula_warning => p_formula_warning
        ,p_assignment_id_warning   => p_assignment_id_warning
	,p_formula_message         => p_formula_message
       );

       pay_ivl_bus.chk_value_set_id (
         p_value_set_id => p_rec.value_set_id,
         p_uom          => p_rec.uom
       );

       pay_ivl_bus.chk_upd_display_sequence
       (p_element_type_id  => p_rec.element_type_id
       ,p_name             => p_rec.name
       ,p_display_sequence => p_rec.display_sequence );

       -- Bug 6164772

       pay_ivl_bus.chk_max_min_value
       (p_element_type_id => p_rec.element_type_id
       ,p_max_value => p_rec.max_value
       ,p_min_value => p_rec.min_value
       ,p_uom => p_rec.uom
       ,p_warning_or_error => p_rec.warning_or_error
       ,p_lookup_type => p_rec.lookup_type
       ,p_min_max_warning => p_min_max_warning
       );

       pay_ivl_bus.chk_default_value
       ( p_element_type_id => p_rec.element_type_id
        ,p_default_value  => p_rec.default_value
        ,p_lookup_type => p_rec.lookup_type
        ,p_value_set_id => p_rec.value_set_id
        ,p_min_value => p_rec.min_value
        ,p_max_value => p_rec.max_value
        ,p_uom => p_rec.uom
        ,p_warning_or_error => p_rec.warning_or_error
        ,p_effective_date => p_effective_date
        ,p_default_val_warning => p_default_val_warning
       );

       pay_ivl_bus.chk_warning_or_error
       (p_warning_or_error => p_rec.warning_or_error
       ,p_lookup_type => p_rec.lookup_type
       ,p_min_value => p_rec.min_value
       ,p_max_value => p_rec.max_value
       ,p_formula_id => p_rec.formula_id
       ,p_effective_date => p_effective_date
       );

       pay_ivl_bus.chk_raise_warning
       (p_lookup_type => p_rec.lookup_type
       ,p_name        => p_rec.name
       ,p_default_value => p_rec.default_value
       ,p_min           => p_rec.min_value
       ,p_max           => p_rec.max_value
       ,p_warning_or_error  => p_rec.warning_or_error
       ,p_link_inp_val_warning => p_link_inp_val_warning);

       /*  Bug 6164772
       if p_rec.default_value <> hr_api.g_varchar2 then
         pay_ivl_bus.chk_upd_default_value
         ( p_default_value  => p_rec.default_value
          ,p_lookup_type => p_rec.lookup_type
          ,p_value_set_id => p_rec.value_set_id
          ,p_min_value => p_rec.min_value
          ,p_max_value => p_rec.max_value
          ,p_warning_or_error => p_rec.warning_or_error
          ,p_effective_date => p_effective_date
          ,p_default_val_warning => p_default_val_warning
         );
       end if;
       */
  --
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_element_type_id                => p_rec.element_type_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  END IF;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_ivl_shd.g_rec_type
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
    --
  chk_startup_action(false
                    ,pay_ivl_shd.g_old_rec.business_group_id
                    ,pay_ivl_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;

  END IF;

   pay_ivl_bus.chk_delete_allowed
         (p_datetrack_mode => p_datetrack_mode
         ,p_input_value_id => p_rec.input_value_id
         ,p_element_type_id => p_rec.element_type_id
         ,p_effective_date => p_effective_date
         ,p_start_date => p_validation_start_date
         ,p_end_date => p_validation_end_date);


  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_input_value_id                   => p_rec.input_value_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_ivl_bus;

/
