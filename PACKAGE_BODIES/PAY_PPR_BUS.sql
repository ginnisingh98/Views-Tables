--------------------------------------------------------
--  DDL for Package Body PAY_PPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPR_BUS" as
/* $Header: pypprrhi.pkb 115.3 2004/02/25 21:33 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ppr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_status_processing_rule_id   number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_status_processing_rule_id            in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and pbg.business_group_id (+) = spr.business_group_id;
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
    ,p_argument           => 'status_processing_rule_id'
    ,p_argument_value     => p_status_processing_rule_id
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
         => nvl(p_associated_column1,'STATUS_PROCESSING_RULE_ID')
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
  (p_status_processing_rule_id            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and pbg.business_group_id (+) = spr.business_group_id;
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
    ,p_argument           => 'status_processing_rule_id'
    ,p_argument_value     => p_status_processing_rule_id
    );
  --
  if ( nvl(pay_ppr_bus.g_status_processing_rule_id, hr_api.g_number)
       = p_status_processing_rule_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_ppr_bus.g_legislation_code;
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
    pay_ppr_bus.g_status_processing_rule_id   := p_status_processing_rule_id;
    pay_ppr_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_ppr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_argument varchar2(80);
  l_error exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_ppr_shd.api_updating
      (p_status_processing_rule_id        => p_rec.status_processing_rule_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Ensure that the following attributes are not updated.
  --
  If nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(pay_ppr_shd.g_old_rec.business_group_id,hr_api.g_number) then
    --
    l_argument := 'business_group_id';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  --
  If nvl(p_rec.legislation_code,hr_api.g_varchar2) <>
     nvl(pay_ppr_shd.g_old_rec.legislation_code,hr_api.g_varchar2) then
    --
    l_argument := 'legislation_code';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  If nvl(p_rec.status_processing_rule_id,hr_api.g_number) <>
     nvl(pay_ppr_shd.g_old_rec.status_processing_rule_id,hr_api.g_number) then
    --
    l_argument := 'status_processing_rule_id';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 25);
  --
  If nvl(p_rec.assignment_status_type_id,hr_api.g_number) <>
     nvl(pay_ppr_shd.g_old_rec.assignment_status_type_id,hr_api.g_number) then
    --
    l_argument := 'assignment_status_type_id';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 30);
  --
  If nvl(p_rec.element_type_id,hr_api.g_number) <>
     nvl(pay_ppr_shd.g_old_rec.element_type_id,hr_api.g_number) then
    --
    l_argument := 'element_type_id';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 35);
  --
  If nvl(p_rec.legislation_subgroup,hr_api.g_varchar2) <>
     nvl(pay_ppr_shd.g_old_rec.legislation_subgroup,hr_api.g_varchar2) then
    --
    l_argument := 'legislation_subgroup';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Leaving :'||l_proc, 40);
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
  (p_status_processing_rule_id        in number
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
      ,p_argument       => 'status_processing_rule_id'
      ,p_argument_value => p_status_processing_rule_id
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
-- |------------------------< chk_assignment_status_type_id >-----------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the assignment_status_type_id against
--   the parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_assignment_status_type_id
  (p_assignment_status_type_id   in number
  ,p_business_group_id           in number
  ,p_legislation_code            in varchar2
  ,p_element_type_id             in number
  ,p_formula_id                  in number
  )  is
--
  l_proc        varchar2(72) := g_package||'chk_assignment_status_type_id';
  l_exists      varchar2(1);

  Cursor c_chk_assign_status_type
  is
    SELECT  '1'
     FROM   per_assignment_status_types astp
     WHERE  nvl(astp.assignment_status_type_id,-1) = nvl(p_assignment_status_type_id,-1)
	 	and ((astp.legislation_code =
		nvl(p_legislation_code,hr_api.return_legislation_code(p_business_group_id)))
        or ( astp.legislation_code is null  and
             astp.business_group_id = p_business_group_id)
        or ( astp.legislation_code is null  and
             astp.business_group_id is null));
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_assignment_status_type_id is not null then

    Open c_chk_assign_status_type;
    Fetch c_chk_assign_status_type into l_exists;
    If c_chk_assign_status_type%notfound Then
      --
      Close c_chk_assign_status_type;
      pay_ppr_shd.constraint_error('PAY_STATUS_PROCESSING_RULE_FK2');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_assign_status_type;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;

--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_formula_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the formula_id against the
--   parent table
--   check  whether formula_type is of type 'ORACLE_PAYROLL' or
--   'BALANCE ADJUSTMENT'
--   If FORMULA_ID is not null and the Formula Type associated with FORMULA_ID
--   is 'Balance Adjustment', then PROCESSING_RULE must be 'B', else 'P'.
-- ----------------------------------------------------------------------------
Procedure chk_formula_id
  ( p_business_group_id		in number
 , p_legislation_code		in varchar2
 , p_status_processing_rule_id  in number
 , p_start_date			in date
 , p_end_date			in date
 , p_element_type_id		in number
 , p_assignment_status_type_id  in number
 , p_formula_id			in varchar2
 , p_processing_rule		out nocopy varchar2
 , p_formula_mismatch_warning   out nocopy boolean
 )  is
--
  l_proc varchar2(72) := g_package||'chk_formula_id';

  cursor c_assignment_status is
    SELECT  astp.user_status
     FROM   pay_ass_status_types_plus_std astp
     WHERE  nvl(astp.assignment_status_type_id,-1) = nvl(p_assignment_status_type_id,-1)
	 	and ((astp.legislation_code =
		nvl(p_legislation_code,hr_api.return_legislation_code(p_business_group_id)))
        or ( astp.legislation_code is null  and
             astp.business_group_id = p_business_group_id)
        or ( astp.legislation_code is null  and
             astp.business_group_id is null));

  Cursor c_chk_formula_id
  is
    select distinct ft.formula_type_name,
           Decode(ft.formula_type_name,'Balance Adjustment','B','P') processing_rule
      from ff_formula_types ft, ff_formulas_f ff
     where ff.formula_type_id = ft.formula_type_id
       and ff.formula_id = p_formula_id
       and ((ff.legislation_code =
         nvl(p_legislation_code,hr_api.return_legislation_code(p_business_group_id)))
        or ( ff.legislation_code is null  and
             ff.business_group_id = p_business_group_id)
        or ( ff.legislation_code is null  and
             ff.business_group_id is null));

--
  l_formula_type       ff_formula_types.formula_type_name%type;
  l_assignment_status  per_assignment_status_types.user_status%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- if assignment status is of type 'Standard' or 'Balance Adjustment'
  -- and formula is null then return 'P'
  if (p_formula_id is null) then
      -- By default 'P' according to Business Rule
      p_processing_rule := 'P';
  else
  --
  Open c_chk_formula_id;
  Fetch c_chk_formula_id into l_formula_type, p_processing_rule;
  If c_chk_formula_id%notfound Then
    --
    Close c_chk_formula_id;
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'FORMULA_ID');
    fnd_message.raise_error;
    --
   elsif NOT ((upper(l_formula_type) = 'ORACLE PAYROLL'
       or
       upper(l_formula_type)='BALANCE ADJUSTMENT')) then
    --
    Close c_chk_formula_id;
    fnd_message.set_name('PAY','PAY_33196_SPR_INVALID_FOR_TYPE');
    fnd_message.set_token('FORMULA','FORMULA_NAME');
    fnd_message.raise_error;
    --
    elsif (p_assignment_status_type_id is not null
        and NVL(UPPER(l_formula_type),'-1') <> 'ORACLE PAYROLL') then
      open c_assignment_status;
      fetch c_assignment_status into l_assignment_status;
      close c_assignment_status;

      Close c_chk_formula_id;

      fnd_message.set_name('PAY', 'PAY_33197_SPR_INVALID_ASSIGN');
      fnd_message.set_token('ASSIGNMENT_STATUS', l_assignment_status);
      fnd_message.set_token('FORMULA_TYPE', 'Oracle Payroll');
      fnd_message.raise_error;
     end if;
     Close c_chk_formula_id;



      hr_utility.set_location('Entering:'||l_proc, 10);
       --
       --
       -- check if formula is updated
       -- formula can not be updated if result rule exist with in
       -- date range specified for Status Processing Rule
       --
       if (p_formula_id <> nvl(pay_ppr_shd.g_old_rec.formula_id,p_formula_id)) and
           (pay_status_rules_pkg.result_rules_exist(p_status_processing_rule_id,
	                                       p_start_date, p_end_date)) then
          fnd_message.set_name('PAY','HR_7135_SPR_FORMULA_NO_UPDATE');
          fnd_message.raise_error;
       end if;
       --
       hr_utility.set_location('Entering:'||l_proc, 15);
       --
       -- check whether input values for the element do not match the
       -- data type of any of the inputs of the selected formula
       --

       if (p_formula_id is not null
          and pay_status_rules_pkg.no_input_values_match_formula(p_element_type_id,p_formula_id)) then
 	  --
	  -- if input type do not match then set output variable to true
	  --
          p_formula_mismatch_warning := True;
       else
          p_formula_mismatch_warning := false;
       end if;
      End If;
    --
    hr_utility.set_location('Leaving:'||l_proc, 20);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_element_type_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the element type id against the
--   parent table and to check whether the business group and legislation code
--   are consistent with those of the element type.
--
-- ----------------------------------------------------------------------------
Procedure chk_element_type_id
  (p_effective_date    in date
  ,p_element_type_id   in number
  ,p_business_group_id in number
  ,p_legislation_code  in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_element_type_id';
  l_exists varchar2(1);

  Cursor c_chk_element_type
  is
    select null
      from pay_element_types_f element, pay_element_classifications classif,
           pay_element_classifications_tl classif_tl, pay_element_types_f_tl element_tl
     where classif_tl.classification_id = classif.classification_id
       and classif_tl.language = userenv('LANG')
       and element.Element_type_id = element_tl.Element_type_id
       and element.Element_type_id = p_element_type_id
       and element_tl.language = userenv('LANG')
       and element.classification_id = classif.classification_id
       and p_effective_date between element.effective_start_date
                and element.effective_end_date
       and  nvl(element.business_group_id,nvl(p_business_group_id, 0)) = nvl(p_business_group_id,0)
       and  nvl(element.legislation_code, nvl(nvl(p_legislation_code,hr_api.return_legislation_code(p_business_group_id)), '~'))
             = nvl(nvl(p_legislation_code,hr_api.return_legislation_code(p_business_group_id)),'~');

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   --    Check mandatory element_type_id exists
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'element_type_id'
    ,p_argument_value               => p_element_type_id
    );
  --
    hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open c_chk_element_type;
  fetch c_chk_element_type into l_exists;
  if c_chk_element_type%notfound then
    close c_chk_element_type;
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'ELEMENT_TYPE_ID');
    fnd_message.raise_error;
  end if;
  close c_chk_element_type;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the legislation code against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_legislation_code
  (p_legislation_code  in varchar2)
  is
--
  l_proc        varchar2(72) := g_package||'chk_legislation_code';
  l_exists varchar2(1);

  Cursor c_chk_leg_code
  is
    select null
      from fnd_territories
     where territory_code = p_legislation_code;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_legislation_code is not null then

    Open c_chk_leg_code;
    Fetch c_chk_leg_code into l_exists;
    If c_chk_leg_code%notfound Then
      --
      Close c_chk_leg_code;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','LEGISLATION_CODE');
      fnd_message.set_token('TABLE','FND_TERRITORIES');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_leg_code;

  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_unique_rules >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to check whether the status processing rule being
--   created is a duplicate rule.
--   null assignmnet_status_type_id denote 'Standard' or 'Balance Adjustment'
--   assignment status
-- ----------------------------------------------------------------------------
Procedure chk_unique_rules
  (p_effective_date            in date
  ,p_assignment_status_type_id in number default null
  ,p_processing_rule           in varchar2
  ,p_element_type_id           in number
  ,p_status_processing_rule_id in number default null
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_unique_rules';
  l_exists varchar2(1);
  --
   cursor c_duplicate_rule
    is
      select '1'
        from pay_status_processing_rules_f
       where nvl(assignment_status_type_id,-1) = nvl(p_assignment_status_type_id,-1)
         and element_type_id = p_element_type_id
         and processing_rule = nvl(p_processing_rule,'P')
         and p_effective_date between effective_start_date
         and effective_end_date
         and status_processing_rule_id <> nvl(p_status_processing_rule_id,-1);
  --
  begin
      --
      hr_utility.set_location('Entering:'||l_proc, 1);
      --
      open c_duplicate_rule;
      fetch c_duplicate_rule into l_exists;
      if c_duplicate_rule%found then
      --
         close c_duplicate_rule;
         fnd_message.set_name('PAY', 'PAY_33195_SPR_NOT_UNIQUE');
         fnd_message.raise_error;
      --
      End If;
  --
      close c_duplicate_rule;
     hr_utility.set_location('Leaving:'||l_proc, 2);
End chk_unique_rules;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to set the effective end date of the status
--   processing rule based on the end date of Element, formula or Future
--   Status Processing Rule.
-- ----------------------------------------------------------------------------
--
Procedure set_effective_end_date
  (p_effective_date             in  date
  ,p_status_processing_rule_id  in  number
  ,p_element_type_id            in  number
  ,p_formula_id                 in  number
  ,p_assignment_status_type_id  in  number
  ,p_processing_rule            in  varchar2
  ,p_business_group_id          in  number
  ,p_legislation_code           in  varchar2
  ,p_datetrack_mode             in  varchar2 default null
  ,p_validation_start_date      in  date
  ,p_validation_end_date        in out nocopy date
  ) is
  --
  l_proc                    varchar2(72) := g_package||'set_effective_end_date';
  l_max_end_date_of_element date;

  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- find out max effective end date of the element
  l_max_end_date_of_element :=
                  pay_element_types_pkg.element_end_date (p_element_type_id);

  --
  -- set effective_end_date of status processing_rule based
  -- on end date of formula and element end date and any future
  -- Status Processing rule
  --
  p_validation_end_date := pay_status_rules_pkg.status_rule_end_date(
	    p_status_processing_rule_id    =>p_status_processing_rule_id,
	    p_element_type_id              =>p_element_type_id,
	    p_formula_id		   =>p_formula_id,
	    p_assignment_status_type_id    =>p_assignment_status_type_id,
	    p_processing_rule		   =>p_processing_rule,
	    p_session_date		   =>p_effective_date,
	    p_max_element_end_date         =>l_max_end_date_of_element,
	    p_validation_start_date	   =>p_validation_start_date,
	    p_business_group_id		   =>p_business_group_id,
	    p_legislation_code		   =>p_legislation_code
	    );

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
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
  --
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => FALSE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => FALSE
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec			in  pay_ppr_shd.g_rec_type
  ,p_effective_date		in  date
  ,p_datetrack_mode		in  varchar2
  ,p_validation_start_date	in  date
  ,p_validation_end_date	in  date
  ,p_processing_rule		out nocopy varchar2
  ,p_formula_mismatch_warning   out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
  l_processing_rule pay_status_processing_rules_f.processing_rule%type;
  l_formula_mismatch_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
   hr_utility.set_location('Before chk_startup:'||l_proc, 6);

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
       ,p_associated_column1 => pay_ppr_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --   This procedure is used to validate the business group id against the
--   parent table
--
-- ----------------------------------------------------------------------------
  IF hr_startup_data_api_support.g_startup_mode
                     IN ('STARTUP') THEN

   chk_legislation_code
       (p_legislation_code    => p_rec.legislation_code);
  End if;
--
-- ----------------------------------------------------------------------------

chk_assignment_status_type_id
  (p_assignment_status_type_id  =>p_rec.assignment_status_type_id
  ,p_business_group_id		=>p_rec.business_group_id
  ,p_legislation_code		=>p_rec.legislation_code
  ,p_element_type_id		=>p_rec.element_type_id
  ,p_formula_id			=>p_rec.formula_id
  );

--
-- ----------------------------------------------------------------------------
chk_formula_id
  (p_business_group_id		=>p_rec.business_group_id
 , p_legislation_code		=>p_rec.legislation_code
 , p_status_processing_rule_id  => p_rec.status_processing_rule_id
 , p_start_date			=>p_validation_start_date
 , p_end_date			=>p_validation_end_date
 , p_element_type_id		=>p_rec.element_type_id
 , p_assignment_status_type_id  =>p_rec.assignment_status_type_id
 , p_formula_id			=>p_rec.formula_id
  ,p_processing_rule		=>l_processing_rule
 , p_formula_mismatch_warning   => l_formula_mismatch_warning
 );

    p_processing_rule          := l_processing_rule;
    p_formula_mismatch_warning := l_formula_mismatch_warning;
--
-- ----------------------------------------------------------------------------
chk_element_type_id
  (p_effective_date		=>p_effective_date
  ,p_element_type_id		=>p_rec.element_type_id
  ,p_business_group_id		=>p_rec.business_group_id
  ,p_legislation_code		=>p_rec.legislation_code
 );
--
-- ----------------------------------------------------------------------------
chk_unique_rules
  (p_effective_date            => p_effective_date
  ,p_assignment_status_type_id => p_rec.assignment_status_type_id
  ,p_processing_rule           => l_processing_rule
  ,p_element_type_id           => p_rec.element_type_id
  ,p_status_processing_rule_id => p_rec.status_processing_rule_id
 );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_ppr_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_processing_rule          out nocopy varchar2
  ,p_formula_mismatch_warning out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
  l_formula_mismatch_warning boolean;
  l_processing_rule   varchar2(1);
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
       ,p_associated_column1 => pay_ppr_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
-- ----------------------------------------------------------------------------
chk_formula_id
  (p_business_group_id		=> p_rec.business_group_id
 , p_legislation_code		=> p_rec.legislation_code
 , p_status_processing_rule_id  => p_rec.status_processing_rule_id
 , p_start_date			=> p_validation_start_date
 , p_end_date			=> p_validation_end_date
 , p_element_type_id		=> p_rec.element_type_id
 , p_assignment_status_type_id  => p_rec.assignment_status_type_id
 , p_formula_id			=> p_rec.formula_id
 , p_processing_rule		=> l_processing_rule
 , p_formula_mismatch_warning   => l_formula_mismatch_warning
 );
--
    p_processing_rule          := l_processing_rule;
    p_formula_mismatch_warning := l_formula_mismatch_warning;
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
  (p_rec                    in pay_ppr_shd.g_rec_type
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
                    ,pay_ppr_shd.g_old_rec.business_group_id
                    ,pay_ppr_shd.g_old_rec.legislation_code
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
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_status_processing_rule_id        => p_rec.status_processing_rule_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_ppr_bus;

/
