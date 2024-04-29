--------------------------------------------------------
--  DDL for Package Body PAY_LIV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_LIV_BUS" as
/* $Header: pylivrhi.pkb 120.1 2005/07/12 05:24:42 alogue noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_liv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_link_input_value_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_link_input_value_id                  in number
  ,p_associated_column1                   in varchar2
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , pay_link_input_values_f liv
         , pay_element_links_f pel
     where liv.link_input_value_id = p_link_input_value_id
      and  liv.element_link_id   = pel.element_link_id
      and  pbg.business_group_id = pel.business_group_id;
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
    ,p_argument           => 'link_input_value_id'
    ,p_argument_value     => p_link_input_value_id
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
         => nvl(p_associated_column1,'LINK_INPUT_VALUE_ID')
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
  (p_link_input_value_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_link_input_values_f liv
         , pay_element_links_f pel
     where liv.link_input_value_id = p_link_input_value_id
      and  liv.element_link_id   = pel.element_link_id
      and  pbg.business_group_id = pel.business_group_id;
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
    ,p_argument           => 'link_input_value_id'
    ,p_argument_value     => p_link_input_value_id
    );
  --
  if ( nvl(pay_liv_bus.g_link_input_value_id, hr_api.g_number)
       = p_link_input_value_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_liv_bus.g_legislation_code;
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
    pay_liv_bus.g_link_input_value_id         := p_link_input_value_id;
    pay_liv_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_liv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);

--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_liv_shd.api_updating
      (p_link_input_value_id              => p_rec.link_input_value_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.element_link_id, hr_api.g_number) <>
       nvl(pay_liv_shd.g_old_rec.element_link_id, hr_api.g_number)
  THEN
      l_argument := 'p_element_link_id';
      RAISE l_error;
  END IF;

  IF nvl(p_rec.input_value_id, hr_api.g_number) <>
       nvl(pay_liv_shd.g_old_rec.input_value_id, hr_api.g_number)
  THEN
      l_argument := 'p_input_value_id';
      RAISE l_error;
  END IF;
    hr_utility.set_location('Leaving:'||l_proc, 20);

  EXCEPTION
      WHEN l_error THEN
         hr_utility.set_location('Leaving:'||l_proc, 25);
         hr_api.argument_changed_error
           (p_api_name => l_proc
           ,p_argument => l_argument);
      WHEN OTHERS THEN
         hr_utility.set_location('Leaving:'||l_proc, 30);
         RAISE;

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
  (p_input_value_id                in number
  ,p_element_link_id               in number
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
  If ((nvl(p_input_value_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_input_values_f'
            ,p_base_key_column => 'INPUT_VALUE_ID'
            ,p_base_key_value  => p_input_value_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','input values');
     hr_multi_message.add
       (p_associated_column1 => pay_liv_shd.g_tab_nam || '.INPUT_VALUE_ID');
  End If;
  If ((nvl(p_element_link_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_element_links_f'
            ,p_base_key_column => 'ELEMENT_LINK_ID'
            ,p_base_key_value  => p_element_link_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','element links');
     hr_multi_message.add
       (p_associated_column1 => pay_liv_shd.g_tab_nam || '.ELEMENT_LINK_ID');
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
  (p_link_input_value_id              in number
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
      ,p_argument       => 'link_input_value_id'
      ,p_argument_value => p_link_input_value_id
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
-- check procedures
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_warning_or_error >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to validate that either warning or error is defined if minimum
-- and/or maximum of Input value is specified.
--
Procedure chk_warning_or_error
  (p_warning_or_error in varchar2
  ,p_max_value        in varchar2
  ,p_min_value        in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_warning_or_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_max_value is not null or p_min_value is not null) then
    If p_warning_or_error is null Then
      fnd_message.set_name('PAY', 'PAY_33084_LK_INP_VAL_WARN_ERR');
      fnd_message.raise_error;
    End If;
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_warning_or_error;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_min_and_max_values >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to validate the following business rules:
--
-- 1. For a link input value the minimum should be less than or equal to
--    the maximum.
-- 2. The default should be within the range of minimum and maximum.
-- 3. If Input Value is to be validated by a Formula, then maximum or minimum
--    values should not be defined for a link input value.
--
Procedure chk_min_and_max_values
  (p_input_value_id        in   number
  ,p_effective_date        in   date
  ,p_default_value         in   varchar2
  ,p_max_value             in   varchar2
  ,p_min_value             in   varchar2
  ,p_warning_or_error      in   varchar2
  ,p_default_range_warning out  nocopy boolean
  ) is
  --
  l_proc                varchar2(72) := g_package||'chk_min_and_max_values';
  l_exists              varchar2(1);
  l_min_max_failure     varchar2(1);
  l_formula_id          pay_input_values_f.formula_id%type;
  l_value               varchar2(255);
  --
  Cursor C_formula_id
  is
    select formula_id
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;
  --
  Procedure chk_format
    (p_input_value_id      in         number
    ,p_effective_date      in         date
    ,p_unformatted_value   in         varchar2
    ,p_min_value           in         varchar2
    ,p_max_value           in         varchar2
    ,p_min_max_failure     out nocopy varchar2
    ) is
  --
  l_unformatted_value   varchar2(255) := p_unformatted_value;
  l_database_value      varchar2(80);
  l_min_max_failure     varchar2(1);
  l_checkformat_error   boolean;
  l_input_currency_code pay_element_types_f.input_currency_code%type;
  l_message_text        hr_lookups.meaning%type;
  l_uom                 pay_input_values_f.uom%type;
  --
  Cursor C_currency_uom
  is
    select pet.input_currency_code, piv.uom
      from pay_element_types_f pet,
           pay_input_values_f piv
     where pet.element_type_id = piv.element_type_id
       and piv.input_value_id  = p_input_value_id
       and p_effective_date between pet.effective_start_date
       and pet.effective_end_date
       and p_effective_date between piv.effective_start_date
       and piv.effective_end_date;
  Begin
    --
    Open C_currency_uom;
    Fetch C_currency_uom into l_input_currency_code,l_uom;
    Close C_currency_uom;
    --
    begin
      hr_chkfmt.checkformat(l_unformatted_value,
                            l_uom,
                            l_database_value,
                            p_min_value,
                            p_max_value,
                            'Y',
                            l_min_max_failure,
                            l_input_currency_code);
    exception
      when hr_utility.hr_error then
        l_checkformat_error := true;
    end;

    p_min_max_failure := l_min_max_failure;

    If (l_checkformat_error) then
    --
      begin
      --
        select meaning
        into   l_message_text
        from   hr_lookups
        where  lookup_type = 'UNITS'
        and    lookup_code = l_uom;
      --
      exception
        when no_data_found then
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE', 'PAY_LIV_BUS.CHK_FORMAT');
          fnd_message.set_token('STEP', '2');
          fnd_message.raise_error;
      end;
      --
      fnd_message.set_name('PAY', 'PAY_6306_INPUT_VALUE_FORMAT');
      fnd_message.set_token('UNIT_OF_MEASURE', l_message_text);
      fnd_message.raise_error;
      --
    end if;
   --
  End chk_format;


Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_default_range_warning := False;
  --
  -- Validate min value with UOM
  --
  chk_format
    (p_input_value_id      =>  p_input_value_id
    ,p_effective_date      =>  p_effective_date
    ,p_unformatted_value   =>  p_min_value
    ,p_min_value           =>  null
    ,p_max_value           =>  null
    ,p_min_max_failure     =>  l_min_max_failure
    );
  --
  -- Validate max value with UOM
  --
  chk_format
    (p_input_value_id      =>  p_input_value_id
    ,p_effective_date      =>  p_effective_date
    ,p_unformatted_value   =>  p_max_value
    ,p_min_value           =>  null
    ,p_max_value           =>  null
    ,p_min_max_failure     =>  l_min_max_failure
    );
  --
  -- Validate default value with UOM
  --
  chk_format
    (p_input_value_id      =>  p_input_value_id
    ,p_effective_date      =>  p_effective_date
    ,p_unformatted_value   =>  p_default_value
    ,p_min_value           =>  p_min_value
    ,p_max_value           =>  p_max_value
    ,p_min_max_failure     =>  l_min_max_failure
    );

  If (p_min_value is not null and
      p_max_value is not null) then
    begin

      l_value := p_min_value;

      chk_format
        (p_input_value_id      =>  p_input_value_id
        ,p_effective_date      =>  p_effective_date
        ,p_unformatted_value   =>  l_value
        ,p_min_value           =>  p_min_value
        ,p_max_value           =>  p_max_value
        ,p_min_max_failure     =>  l_min_max_failure
        );

    exception
      When Others then
        fnd_message.set_name('PAY', 'HR_51976_ALL_MIN_LESS_MAX');
        fnd_message.raise_error;
    end;
  End If;

  hr_utility.set_location('l_min_max_failure '||l_min_max_failure,30);

  If l_min_max_failure = 'F' Then
    --
    If nvl(p_warning_or_error,pay_liv_shd.g_old_rec.warning_or_error) = 'W'
    then
      p_default_range_warning := True;
    Elsif nvl(p_warning_or_error,pay_liv_shd.g_old_rec.warning_or_error) = 'E'
    then
      fnd_message.set_name('PAY', 'HR_INPVAL_DEFAULT_INVALID');
      fnd_message.raise_error;
    End if;
    --
  End If;

  Open C_formula_id;
  Fetch C_formula_id Into l_formula_id;
  Close C_formula_id;

  If l_formula_id is not null and
     (p_min_value is not null
      or p_max_value is not null
      or p_warning_or_error is null)  Then
    --
      fnd_message.set_name('PAY', 'PAY_6905_INPVAL_FORMULA_VAL');
      fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_min_and_max_values;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_costed_flag >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to validate the following business rules:
--
-- 1. If the Element Link is not costed then the Link Input value cannot be
--    costed.
-- 2. If the Unit of Measurement of the Link Input Value is neither 'Money' nor
--    'Hours' then the Link Input value cannot be costed.
-- 3. If the Element Link is Distributed, then only the 'Pay Value' can be
--    costed.
--
Procedure chk_costed_flag
  (p_element_link_id            in number
  ,p_effective_date             in date
  ,p_input_value_id             in number
  ,p_costed_flag                in varchar2
  ) is
--
  l_proc                varchar2(72) := g_package||'chk_costed_flag';
  l_costable_type       pay_element_links_f.costable_type%type;
  l_uom                 pay_input_values_f.uom%type;
  l_name                pay_input_values_f.name%type;

  Cursor C_element_link
  is
    select costable_type
      from pay_element_links_f
     where element_link_id = p_element_link_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor C_input_values
  is
    select name, uom
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  Open C_element_link;
  Fetch C_element_link into l_costable_type;
  Close C_element_link;

  If l_costable_type = 'N' and p_costed_flag <> 'N' Then
    fnd_message.set_name('PAY', 'PAY_33080_LK_INP_VAL_NO_COST');
    fnd_message.raise_error;
  End if;

  Open C_input_values;
  Fetch C_input_values into l_name, l_uom;
  Close C_input_values;

  If (l_uom <> 'M' and l_uom not like 'H%'
     and p_costed_flag = 'Y') Then
    fnd_message.set_name('PAY', 'PAY_33081_LK_INP_VAL_UOM_COST');
    fnd_message.raise_error;
  End If;

  If l_name <> 'Pay Value' Then
    If l_costable_type = 'D' and p_costed_flag = 'Y' Then
    fnd_message.set_name('PAY', 'PAY_33082_LK_INP_VAL_DIST_COST');
    fnd_message.raise_error;
    End If;
  End if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_costed_flag;

--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_benefit_plan >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to validate the following business rule:
--
-- 1. Input Values 'Coverage','EE Contr' and 'ER Contr' for type A benefit
--    plan cannot be updated at all.
--
Procedure chk_benefit_plan
  (p_element_link_id            in number
  ,p_input_value_id             in number
  ,p_effective_date             in date
  ) is
--
  l_proc                        varchar2(72) := g_package||'chk_benefit_plan';
  l_contributions_used          pay_element_links_v.contributions_used%type;
  l_name                        pay_input_values_f.name%type;

  Cursor C_contributions_used
  is
    select contributions_used
      from pay_element_links_v
     where element_link_id = p_element_link_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor C_name
  is
    select name
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;
--
Begin
  hr_utility.set_location(' Entering:'||l_proc, 5);
--
  Open C_contributions_used;
  Fetch C_contributions_used into l_contributions_used;
  Close C_contributions_used;
  --
  Open C_name;
  Fetch C_name into l_name;
  Close C_name;
  --
  If nvl(l_contributions_used,'N') = 'Y'
     and (l_name in ('Coverage',
                     'EE Contr',
                     'ER Contr')) Then
    fnd_message.set_name('PAY', 'PAY_33078_LK_INP_VAL_NO_UPD');
    fnd_message.raise_error;
  End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_benefit_plan;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_default_value >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to validate the following business rule:
--
-- 1. If the Input Value is hot defaulted and entries exist, then the default
--    cannot be updated to NULL.
--
Procedure chk_default_value
  (p_element_link_id            in number
  ,p_input_value_id             in number
  ,p_effective_date             in date
  ,p_default_value              in varchar2
  ) is
--
  l_proc                varchar2(72) := g_package||'chk_default_value';
  l_exists              varchar2(1);
  l_hot_default_flag    pay_input_values_f.hot_default_flag%type;
  l_element_type_id     pay_input_values_f.element_type_id%type;

  Cursor c_hot_default_flag
  is
    select hot_default_flag, element_type_id
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor c_element_entry(p_element_type_id number)
  is
    select null
      from pay_element_entries_f
     where element_link_id = p_element_link_id
       and element_type_id = p_element_type_id
       and p_effective_date between effective_start_date
       and effective_end_date;
--
Begin
  hr_utility.set_location(' Entering:'||l_proc, 5);
  --
  Open c_hot_default_flag;
  Fetch c_hot_default_flag into l_hot_default_flag, l_element_type_id;
  Close c_hot_default_flag;

  If (l_hot_default_flag = 'Y'
     and pay_liv_shd.g_old_rec.default_value is not null
     and p_default_value is null) Then
    Open c_element_entry(l_element_type_id);
    Loop
      Fetch c_element_entry into l_exists;
      If c_element_entry%found Then
        fnd_message.set_name('PAY', 'PAY_33079_LK_INP_VAL_NO_UPD');
        fnd_message.raise_error;
      Else
        exit;
      End if;
    End Loop;
    Close c_element_entry;
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_default_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in  pay_liv_shd.g_rec_type
  ,p_effective_date        in  date
  ,p_datetrack_mode        in  varchar2
  ,p_validation_start_date in  date
  ,p_validation_end_date   in  date
  ) is
--
  l_proc                  varchar2(72) := g_package||'insert_validate';
  l_default_range_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_warning_or_error
    (p_warning_or_error => p_rec.warning_or_error
    ,p_max_value        => p_rec.max_value
    ,p_min_value        => p_rec.min_value
    );

  chk_min_and_max_values
    (p_input_value_id        => p_rec.input_value_id
    ,p_effective_date        => p_effective_date
    ,p_default_value         => p_rec.default_value
    ,p_max_value             => p_rec.max_value
    ,p_min_value             => p_rec.min_value
    ,p_warning_or_error      => p_rec.warning_or_error
    ,p_default_range_warning => l_default_range_warning
    );

  chk_costed_flag
    (p_element_link_id      => p_rec.element_link_id
    ,p_effective_date       => p_effective_date
    ,p_input_value_id       => p_rec.input_value_id
    ,p_costed_flag          => p_rec.costed_flag
    );

  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in         pay_liv_shd.g_rec_type
  ,p_effective_date          in         date
  ,p_datetrack_mode          in         varchar2
  ,p_validation_start_date   in         date
  ,p_validation_end_date     in         date
  ,p_default_range_warning   out nocopy boolean
  ,p_default_formula_warning out nocopy boolean
  ,p_assignment_id_warning   out nocopy boolean
  ,p_formula_message         out nocopy varchar2

  ) is
--
  l_proc                    varchar2(72) := g_package||'update_validate';
  l_business_group_id       pay_element_links_f.business_group_id%type;
  l_formula_id              number;
  --
  Cursor c_business_group_id
  is
    select business_group_id
      from pay_element_links_f
     where element_link_id = p_rec.element_link_id;
  --
  Cursor c_formula
  is
    select formula_id
      from pay_input_values_f
     where input_value_id = p_rec.input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_warning_or_error
    (p_warning_or_error => p_rec.warning_or_error
    ,p_max_value        => p_rec.max_value
    ,p_min_value        => p_rec.min_value
    );

  chk_min_and_max_values
    (p_input_value_id          => p_rec.input_value_id
    ,p_effective_date          => p_effective_date
    ,p_default_value           => p_rec.default_value
    ,p_max_value               => p_rec.max_value
    ,p_min_value               => p_rec.min_value
    ,p_warning_or_error        => p_rec.warning_or_error
    ,p_default_range_warning   => p_default_range_warning
    );

  chk_costed_flag
    (p_element_link_id      => p_rec.element_link_id
    ,p_effective_date       => p_effective_date
    ,p_input_value_id       => p_rec.input_value_id
    ,p_costed_flag          => p_rec.costed_flag
    );

  chk_benefit_plan
    (p_element_link_id      => p_rec.element_link_id
    ,p_input_value_id       => p_rec.input_value_id
    ,p_effective_date       => p_effective_date
    );

  chk_default_value
    (p_element_link_id      => p_rec.element_link_id
    ,p_input_value_id       => p_rec.input_value_id
    ,p_effective_date       => p_effective_date
    ,p_default_value        => p_rec.default_value
    );

  --
  Open c_business_group_id;
  Fetch c_business_group_id into l_business_group_id;
  Close c_business_group_id;
  --
  Open c_formula;
  Fetch c_formula into l_formula_id;
  Close c_formula;
  --
  If (p_rec.default_value is not null and l_formula_id is not null) then
    pay_ivl_bus.chk_formula_validation
      (p_default_value            => p_rec.default_value
      ,p_warning_or_error         => p_rec.warning_or_error
      ,p_effective_date           => p_effective_date
      ,p_input_value_id           => p_rec.input_value_id
      ,p_formula_id               => l_formula_id
      ,p_business_group_id        => l_business_group_id
      ,p_default_formula_warning  => p_default_formula_warning
      ,p_assignment_id_warning    => p_assignment_id_warning
      ,p_formula_message          => p_formula_message
      );
  End If;
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_input_value_id                 => p_rec.input_value_id
    ,p_element_link_id                => p_rec.element_link_id
    ,p_datetrack_mode                 => p_datetrack_mode
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
  (p_rec                    in pay_liv_shd.g_rec_type
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
    ,p_link_input_value_id              => p_rec.link_input_value_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_liv_bus;

/
