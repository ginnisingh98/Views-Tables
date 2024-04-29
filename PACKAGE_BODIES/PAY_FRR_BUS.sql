--------------------------------------------------------
--  DDL for Package Body PAY_FRR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FRR_BUS" as
/* $Header: pyfrrrhi.pkb 120.0.12010000.3 2009/10/01 06:36:27 phattarg ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_frr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_formula_result_rule_id      number         default null;
--
-- This global variable would be used in the chk_ procedures
--
g_exists                      varchar2(1)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_formula_result_rule_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_formula_result_rules_f frr
     where frr.formula_result_rule_id = p_formula_result_rule_id
       and pbg.business_group_id (+) = frr.business_group_id;
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
    ,p_argument           => 'formula_result_rule_id'
    ,p_argument_value     => p_formula_result_rule_id
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
         => nvl(p_associated_column1,'FORMULA_RESULT_RULE_ID')
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
  (p_formula_result_rule_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_formula_result_rules_f frr
     where frr.formula_result_rule_id = p_formula_result_rule_id
       and pbg.business_group_id (+) = frr.business_group_id;
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
    ,p_argument           => 'formula_result_rule_id'
    ,p_argument_value     => p_formula_result_rule_id
    );
  --
  if ( nvl(pay_frr_bus.g_formula_result_rule_id, hr_api.g_number)
       = p_formula_result_rule_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_frr_bus.g_legislation_code;
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
    pay_frr_bus.g_formula_result_rule_id      := p_formula_result_rule_id;
    pay_frr_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_frr_shd.g_rec_type
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
  IF NOT pay_frr_shd.api_updating
      (p_formula_result_rule_id           => p_rec.formula_result_rule_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Ensure that the following attributes are not updated.
  --
  If nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(pay_frr_shd.g_old_rec.business_group_id,hr_api.g_number) then
    --
    l_argument := 'business_group_id';
    raise l_error;
    --
  End if;
  --
  If nvl(p_rec.legislation_code,hr_api.g_varchar2) <>
     nvl(pay_frr_shd.g_old_rec.legislation_code,hr_api.g_varchar2) then
    --
    l_argument := 'legislation_code';
    raise l_error;
    --
  End if;
  --
  If nvl(p_rec.status_processing_rule_id,hr_api.g_number) <>
     nvl(pay_frr_shd.g_old_rec.status_processing_rule_id,hr_api.g_number) then
    --
    l_argument := 'status_processing_rule_id';
    raise l_error;
    --
  End if;
  --
  If nvl(p_rec.result_name,hr_api.g_varchar2) <>
     nvl(pay_frr_shd.g_old_rec.result_name,hr_api.g_varchar2) then
    --
    l_argument := 'result_name';
    raise l_error;
    --
  End if;
  --
  If nvl(p_rec.legislation_subgroup,hr_api.g_varchar2) <>
     nvl(pay_frr_shd.g_old_rec.legislation_subgroup,hr_api.g_varchar2) then
    --
    l_argument := 'legislation_subgroup';
    raise l_error;
    --
  End if;
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
  (p_formula_result_rule_id           in number
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
      ,p_argument       => 'formula_result_rule_id'
      ,p_argument_value => p_formula_result_rule_id
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
    Fetch c_chk_leg_code into g_exists;
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

  Cursor c_chk_element_type
  is
    select null
      from pay_element_types_f pet
     where pet.element_type_id = p_element_type_id
       and p_effective_date between pet.effective_start_date
       and pet.effective_end_date
       and ((p_business_group_id is not null and
            ((pet.business_group_id = p_business_group_id)
             or
             (pet.legislation_code =
              hr_api.return_legislation_code(p_business_group_id))
            ))
           --
           or
            (p_legislation_code is not null
             and pet.legislation_code = p_legislation_code
            ));
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_chk_element_type;
  fetch c_chk_element_type into g_exists;
  if c_chk_element_type%notfound then
    close c_chk_element_type;
    fnd_message.set_name('PAY','PAY_34171_FRR_INVALID_FK');
    fnd_message.set_token('1','element type');
    fnd_message.raise_error;
  end if;
  close c_chk_element_type;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_status_processing_rule_id >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the status_processing_rule_id against
--   the parent table and to check whether the business group and legislation
--   code are consistent with those of the SPR.
--
-- ----------------------------------------------------------------------------
Procedure chk_status_processing_rule_id
  (p_effective_date            in date
  ,p_status_processing_rule_id in number
  ,p_business_group_id         in number
  ,p_legislation_code          in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_spr_id';

  Cursor c_chk_spr
  is
    select null
      from pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date
       and ((p_business_group_id is not null and
             ((spr.business_group_id = p_business_group_id)
             or
             (spr.legislation_code =
              hr_api.return_legislation_code(p_business_group_id))
             ))
           --
           or
           (p_legislation_code is not null and
             (spr.legislation_code = p_legislation_code)
           ));
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_chk_spr;
  fetch c_chk_spr into g_exists;
  if c_chk_spr%notfound then
    close c_chk_spr;
    fnd_message.set_name('PAY','PAY_34171_FRR_INVALID_FK');
    fnd_message.set_token('1','status processing rule');
    fnd_message.raise_error;
  end if;
  close c_chk_spr;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_result_name >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to check whether the result name is same as the
--   item name in formula dictionary and the item is either output or both
--   (input and output).
--
-- ----------------------------------------------------------------------------
Procedure chk_result_name
  (p_effective_date            in date
  ,p_status_processing_rule_id in number
  ,p_result_name               in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_result_name';
  --
  Cursor c_chk_result_name
  is
    select null
      from ff_fdi_usages_f fdu
          ,pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and fdu.formula_id = spr.formula_id
       and fdu.usage in ('O', 'B')
       and fdu.item_name = p_result_name
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date
       and p_effective_date between fdu.effective_start_date
       and fdu.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_chk_result_name;
  fetch c_chk_result_name into g_exists;
  if c_chk_result_name%notfound then
    fnd_message.set_name('PAY','PAY_34156_FRR_NAME_INVALID');
    IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
       close c_chk_result_name;
       fnd_message.raise_error;
    ELSE
       hr_utility.trace('PAY_34156_FRR_NAME_INVALID Warning in startup mode: formula result_name:'
                        ||p_result_name|| ' not found for spr_id:'
                        ||to_char(p_status_processing_rule_id)
                        ||' effective_date:'||to_char(p_effective_date));
       hr_utility.trace('SQLERRM:'||SQLERRM);
    END IF;
  end if;
  close c_chk_result_name;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_common_rules >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to check the dependent attributes of different
--   result rule types.
--
-- ----------------------------------------------------------------------------
Procedure chk_common_rules
  (p_element_type_id           in number     default null
  ,p_result_rule_type          in varchar2
  ,p_severity_level            in varchar2   default null
  ,p_input_value_id            in number     default null
  ) is
--
  l_proc             varchar2(72) := g_package||'chk_common_rules';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_result_rule_type <> 'M' then -- message
      --
      -- severity must be entered
      --
      If p_severity_level is not null then
        --
        fnd_message.set_name('PAY','PAY_34168_FRR_NO_SEVERITY');
        fnd_message.raise_error;
        --
      End If;
      --
      If p_result_rule_type in ('I','O','U','S') then -- others
        --
        -- element type must be entered
        --
        If p_element_type_id is null then
          --
          fnd_message.set_name('PAY','PAY_34158_FRR_ELEMENT_REQD');
          fnd_message.raise_error;
          --
        End If;
        --
        If p_result_rule_type in ('I','U') then
          --
          -- input value must be entered for indirect and update recurring
          -- rules.
          --
          If p_input_value_id is null then
            --
            fnd_message.set_name('PAY','PAY_34159_FRR_INPUT_VALUE_REQD');
            fnd_message.raise_error;
            --
          End If;
          --
        Else
          --
          -- input value must be null for other rules.
          --
          If p_input_value_id is not null then
            --
            fnd_message.set_name('PAY','PAY_34169_FRR_NO_INPUT_VALUE');
            fnd_message.raise_error;
            --
          End If;
          --
        End If;
        --
      Elsif p_result_rule_type = 'D' then
        --
        -- input value must be entered for direct rule
        --
        If p_input_value_id is null then
          --
          fnd_message.set_name('PAY','PAY_34159_FRR_INPUT_VALUE_REQD');
          fnd_message.raise_error;
          --
        End If;
        --
      End If;
      --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_result_rule_type >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the result rule type against the
--   business rules.
-- ----------------------------------------------------------------------------
Procedure chk_result_rule_type
  (p_effective_date            in date
  ,p_element_type_id           in number
  ,p_status_processing_rule_id in number
  ,p_result_name               in varchar2
  ,p_result_rule_type          in varchar2
  ,p_severity_level            in varchar2
  ,p_input_value_id            in number
  ) is
  --
  l_proc             varchar2(72) := g_package||'chk_result_rule_type';
  l_spr_element_id   pay_element_types_f.element_type_id%type;
  --
  Cursor c_element_dets(p_element_type_id number)
  is
    select pet.processing_type
          ,pet.third_party_pay_only_flag
          ,pet.processing_priority
          ,pet.multiple_entries_allowed_flag
      from pay_element_types_f pet
     where pet.element_type_id = p_element_type_id
       and p_effective_date between pet.effective_start_date
       and pet.effective_end_date;
  --
  Cursor c_spr_element
  is
    select spr.element_type_id
      from pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date;
 --
 l_element_dets     c_element_dets%rowtype;
 l_spr_element_dets c_element_dets%rowtype;
 --

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
    (p_effective_date
    ,'RESULT_RULE_TYPE'
    ,p_result_rule_type) Then
    --
    fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN','RESULT_RULE_TYPE');
    fnd_message.set_token('LOOKUP_TYPE','RESULT_RULE_TYPE');
    fnd_message.raise_error;
    --
  End If;
  --
  If p_element_type_id is not null then
    Open c_element_dets (p_element_type_id);
    Fetch c_element_dets into l_element_dets;
    Close c_element_dets;
  End If;
  --
  Open c_spr_element;
  Fetch c_spr_element into l_spr_element_id;
  Close c_spr_element;
  --
  Open c_element_dets (l_spr_element_id);
  Fetch c_element_dets into l_spr_element_dets;
  Close c_element_dets;
  --
  chk_common_rules
    (p_element_type_id
    ,p_result_rule_type
    ,p_severity_level
    ,p_input_value_id);
  --
  If p_result_rule_type in ('I','O') then -- indirect or order indirect
      --
      -- the priority of the non-recurring element providing the input
      -- value must be same as or lower (ie. same or higher number) than
      -- that of the element for which this is the formula result rule
      -- for the lifetime of the formula result rule.
      --
      If (l_spr_element_dets.processing_priority
          > l_element_dets.processing_priority) then
        --
        fnd_message.set_name('PAY','PAY_34163_FRR_PRIORITY');
        fnd_message.raise_error;
        --
      End If;
      --
      -- the element must be non-recurring and non-third party.
      --
      If (l_element_dets.processing_type <> 'N')
      or (nvl(l_element_dets.third_party_pay_only_flag,'N') <> 'N') then
        --
        fnd_message.set_name('PAY','PAY_34160_FRR_INDIRECT_RULE');
        fnd_message.raise_error;
        --
      End If;
      --
  Elsif p_result_rule_type in ('U','S') then -- update recurring or stop entry
      --
      -- the element must be recurring
      --
      If l_element_dets.processing_type <> 'R' then
        --
        fnd_message.set_name('PAY','PAY_34161_FRR_RECURRING');
        fnd_message.raise_error;
        --
      End If;
      --
      -- if the element allows multiple entries then it
      -- can only be the target of such a rule if it is also the source.
      --
      If (l_element_dets.multiple_entries_allowed_flag = 'Y'
         and l_spr_element_id <> p_element_type_id) then
        --
        fnd_message.set_name('PAY','PAY_34164_FRR_NO_MULTI_ENTRIES');
        fnd_message.raise_error;
        --
      End If;
      --
  Elsif p_result_rule_type = 'M' then -- message
      --
      -- severity must be entered
      --
      If p_severity_level is null then
        --
        fnd_message.set_name('PAY','PAY_34167_FRR_SEVERITY_REQD');
        fnd_message.raise_error;
        --
      End If;
      --
      -- no element or input value can be entered
      --
      If (p_element_type_id is not null
         or p_input_value_id is not null) then
        --
        fnd_message.set_name('PAY','PAY_34157_FRR_MSG_NO_ELEMENT');
        fnd_message.raise_error;
        --
      End If;
      --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_severity_level >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the severity level against the
--   lookup 'FORMULA_RESULT_MESSAGE_LEVEL'.
--
-- ----------------------------------------------------------------------------
Procedure chk_severity_level
  (p_effective_date  in date
  ,p_severity_level  in varchar2
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_severity_level';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If hr_api.not_exists_in_hr_lookups
      (p_effective_date
      ,'FORMULA_RESULT_MESSAGE_LEVEL'
      ,p_severity_level) Then
      --
      fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
      fnd_message.set_token('COLUMN','SEVERITY_LEVEL');
      fnd_message.set_token('LOOKUP_TYPE','FORMULA_RESULT_MESSAGE_LEVEL');
      fnd_message.raise_error;
      --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_input_value_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to check whether the UOM of the input value matches
--   the datatype of the formula result.
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id
  (p_effective_date            in date
  ,p_element_type_id           in number
  ,p_status_processing_rule_id in number
  ,p_result_name               in varchar2
  ,p_result_rule_type          in varchar2
  ,p_input_value_id            in number
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_input_value_id';
  l_uom         pay_input_values_f.uom%type;
  l_op_datatype ff_fdi_usages_f.data_type%type;
  --
  Cursor c_chk_input_value is
    select uom
      from pay_input_values_f piv
     where piv.input_value_id = p_input_value_id
       and piv.element_type_id = p_element_type_id
       and p_effective_date between piv.effective_start_date
       and piv.effective_end_date;
  --
  Cursor c_result_dtype is
    select fdu.data_type
      from ff_fdi_usages_f fdu
          ,pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and fdu.formula_id = spr.formula_id
       and fdu.usage in ('O', 'B')
       and fdu.item_name = p_result_name
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date
       and p_effective_date between fdu.effective_start_date
       and fdu.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c_result_dtype;
  Fetch c_result_dtype into l_op_datatype;
  Close c_result_dtype;
  --
  If p_input_value_id is not null then
    --
    Open c_chk_input_value;
    Fetch c_chk_input_value into l_uom;
    If c_chk_input_value%notfound then
      Close c_chk_input_value;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','INPUT_VALUE_ID');
      fnd_message.set_token('TABLE','PAY_INPUT_VALUES_F');
      fnd_message.raise_error;
    End If;
    Close c_chk_input_value;
    --
    If l_op_datatype = 'D' then -- date
      If substr(l_uom,1,1) <> 'D' then
        fnd_message.set_name('PAY','PAY_34162_FRR_INVALID_UOM');
        fnd_message.raise_error;
      End If;
    --
    Elsif l_op_datatype = 'T' then -- text
      If l_uom not in ('C','T') then
        fnd_message.set_name('PAY','PAY_34162_FRR_INVALID_UOM');
        fnd_message.raise_error;
      End If;
    --
    Elsif l_op_datatype = 'N' then -- numeric
      If (substr(l_uom,1,1) not in ('H','I','M','N')) then
        fnd_message.set_name('PAY','PAY_34162_FRR_INVALID_UOM');
        fnd_message.raise_error;
      End If;
    --
    End If;
    --
  End If;
  --
  If (p_result_rule_type = 'O' and l_op_datatype <> 'N') then
    --
    fnd_message.set_name('PAY','PAY_34170_FRR_DATATYP_MISMATCH');
    fnd_message.set_token('RULE','Order Indirect');
    fnd_message.set_token('TYPE','Numeric');
    fnd_message.raise_error;
    --
  Elsif (p_result_rule_type = 'M' and l_op_datatype <> 'T') then
    --
    fnd_message.set_name('PAY','PAY_34170_FRR_DATATYP_MISMATCH');
    fnd_message.set_token('RULE','Message');
    fnd_message.set_token('TYPE','Text');
    fnd_message.raise_error;
    --
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
--   This procedure is used to check whether the formula result rule being
--   created is a duplicate rule.
-- ----------------------------------------------------------------------------
Procedure chk_unique_rules
  (p_effective_date            in date
  ,p_status_processing_rule_id in number
  ,p_result_rule_type          in varchar2
  ,p_result_name               in varchar2
  ,p_element_type_id           in number
  ,p_input_value_id            in number
  ,p_formula_result_rule_id    in number default null
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_unique_rules';
  --
  function message_rule_not_unique
    --
    -- Returns TRUE if the tested message rule already exists
    -- Only one message rule is allowed for each SPR/result name combination
    return boolean is
    --
    v_duplicate_found       boolean := FALSE;
    --
    cursor c_duplicate_rule
    is
      select '1'
        from pay_formula_result_rules_f
       where status_processing_rule_id = p_status_processing_rule_id
         and result_rule_type          = 'M'
         and result_name               = p_result_name
         and p_effective_date between effective_start_date
         and effective_end_date
         and formula_result_rule_id <> nvl(p_formula_result_rule_id,-1);
  --
  begin
      --
      hr_utility.set_location('Entering:'||l_proc, 2);
      --
      open c_duplicate_rule;
      fetch c_duplicate_rule into g_exists;
      v_duplicate_found := c_duplicate_rule%found;
      close c_duplicate_rule;
      --
      hr_utility.set_location('Leaving:'||l_proc, 3);
      --
      return v_duplicate_found;
      --
  end message_rule_not_unique;
  --
  function recurring_rule_not_unique
    -- Returns TRUE if the tested stop-entry/update-recurring rule already
    -- exists.
    -- Only one stop-entry/update-recurring rule is allowed for each
    -- combination of result name, SPR and element type
    return boolean is
    --
    v_duplicate_found       boolean := FALSE;
    --
    cursor c_duplicate_rule
    is
      select '1'
        from pay_formula_result_rules_f
       where status_processing_rule_id = p_status_processing_rule_id
         and result_rule_type          in ('S','U')
         and result_name               = p_result_name
         and element_type_id           = p_element_type_id
         and p_effective_date between effective_start_date
         and effective_end_date
         and formula_result_rule_id <> nvl(p_formula_result_rule_id,-1);
  --
  begin
      --
      hr_utility.set_location('Entering:'||l_proc, 4);
      --
      open c_duplicate_rule;
      fetch c_duplicate_rule into g_exists;
      v_duplicate_found := c_duplicate_rule%found;
      close c_duplicate_rule;
      --
      hr_utility.set_location('Leaving:'||l_proc, 5);
      --
      return v_duplicate_found;
      --
  end recurring_rule_not_unique;
  --
  function other_rule_type_not_unique
    -- Returns TRUE if any duplicate rule/rule-type/input-value is found
    -- Only one indirect or direct is allowed for each
    -- combination of SPR, result name and input value
    return boolean is
    --
    v_duplicate_found       boolean := FALSE;
    --
    cursor c_duplicate_rule
    is
      select '1'
        from pay_formula_result_rules_f
       where status_processing_rule_id = p_status_processing_rule_id
         and result_rule_type          = p_result_rule_type
         and result_name               = p_result_name
         and input_value_id            = p_input_value_id
         and p_effective_date between effective_start_date
         and effective_end_date
         and formula_result_rule_id <> nvl(p_formula_result_rule_id,-1);
  --
  begin
      --
      hr_utility.set_location('Entering:'||l_proc, 6);
      --
      open c_duplicate_rule;
      fetch c_duplicate_rule into g_exists;
      v_duplicate_found := c_duplicate_rule%found;
      close c_duplicate_rule;
      --
      hr_utility.set_location('Leaving:'||l_proc, 7);
      --
      return v_duplicate_found;
      --
  end other_rule_type_not_unique;
  --
  -- Main procedure starts
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  If (p_result_rule_type = 'M' and message_rule_not_unique)
    or (p_result_rule_type in ('S','U') and recurring_rule_not_unique)
    or (p_result_rule_type in ('I','D') and other_rule_type_not_unique) then
    --
    fnd_message.set_name('PAY','HR_6478_FF_UNI_FRR');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to set the effective end date of the formula result
--   based on the result rule types.
-- ----------------------------------------------------------------------------
Procedure set_effective_end_date
  (p_effective_date             in  date
  ,p_result_rule_type           in  varchar2
  ,p_result_name                in  varchar2
  ,p_status_processing_rule_id  in  number
  ,p_element_type_id            in  number
  ,p_input_value_id             in  number
  ,p_datetrack_mode             in  varchar2 default null
  ,p_formula_result_rule_id     in  number   default null
  ,p_validation_end_date        in out nocopy date
  ) is
  --
  l_proc                    varchar2(72) := g_package||'set_eff_end_date';
  l_future_rule_end_date    date;
  l_max_spr_end_date        date;
  l_max_end_date_of_element date;
  l_max_end_date_of_target  date;
  l_spr_formula_id          pay_status_processing_rules_f.formula_id%type;
  l_spr_element_type_id     pay_status_processing_rules_f.element_type_id%type;
  --
  Cursor c_spr_element
  is
    select spr.formula_id,spr.element_type_id
      from pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_spr_element;
  fetch c_spr_element into l_spr_formula_id, l_spr_element_type_id;
  close c_spr_element;
  --
  -- get the maximum end date of the spr
  --
  l_max_spr_end_date := pay_status_rules_pkg.spr_end_date
                          (p_status_processing_rule_id
                          ,l_spr_formula_id);
  hr_utility.set_location('l_max_spr_end_date '||to_char(l_max_spr_end_date),6);
  --
  -- get the maximum end date of the source element type
  --
  l_max_end_date_of_element := pay_element_types_pkg.element_end_date
                                 (l_spr_element_type_id);
  hr_utility.set_location('l_max_end_date_of_element '||to_char(l_max_end_date_of_element),7);
  --
  -- get the maximum end date of the target element type
  --
  l_max_end_date_of_target := pay_element_types_pkg.element_end_date
                                (p_element_type_id);
  hr_utility.set_location('l_max_end_date_of_target '||to_char(l_max_end_date_of_target),8);
  --
  -- get the maximum end date of a similar rule if it exists in the future.
  --
  l_future_rule_end_date := pay_formula_result_rules_pkg.result_rule_end_date
                              (p_formula_result_rule_id
                              ,p_result_rule_type
                              ,p_result_name
                              ,p_status_processing_rule_id
                              ,p_element_type_id
                              ,p_input_value_id
                              ,p_effective_date
                              ,l_max_spr_end_date);
  hr_utility.set_location('l_future_rule_end_date '||to_char(l_future_rule_end_date),8);
  --
  hr_utility.set_location('before set-p_validation_end_date '||to_char(p_validation_end_date),9);
  --
  if (p_result_rule_type in ('I','U','S'))
  or (p_datetrack_mode = hr_api.g_delete_next_change) then
    p_validation_end_date := least (l_max_end_date_of_element
                                   ,l_max_spr_end_date
                                   ,l_max_end_date_of_target
                                   ,l_future_rule_end_date);
  else
    p_validation_end_date := least (l_max_end_date_of_element
                                   ,l_max_spr_end_date
                                   ,l_future_rule_end_date);
  end if;
  --
  hr_utility.set_location('after set-p_validation_end_date '||to_char(p_validation_end_date),10);
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
  (p_rec                   in pay_frr_shd.g_rec_type
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
       ,p_associated_column1 => pay_frr_shd.g_tab_nam
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
  --
  --
  If p_rec.legislation_code is not null then
    chk_legislation_code
      (p_legislation_code => p_rec.legislation_code);
  End if;
  --
  If p_rec.element_type_id is not null then
    chk_element_type_id
      (p_effective_date    => p_effective_date
      ,p_element_type_id   => p_rec.element_type_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_legislation_code  => p_rec.legislation_code
      );
  End if;
  --
  chk_status_processing_rule_id
    (p_effective_date            => p_effective_date
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_business_group_id         => p_rec.business_group_id
    ,p_legislation_code          => p_rec.legislation_code
    );
  --
  chk_result_name
    (p_effective_date            => p_effective_date
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    );
  --
  chk_result_rule_type
    (p_effective_date            => p_effective_date
    ,p_element_type_id           => p_rec.element_type_id
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    ,p_result_rule_type          => p_rec.result_rule_type
    ,p_severity_level            => p_rec.severity_level
    ,p_input_value_id            => p_rec.input_value_id
    );
  --
  If p_rec.severity_level is not null then
    chk_severity_level
      (p_effective_date => p_effective_date
      ,p_severity_level => p_rec.severity_level
      );
  End if;
  --
  chk_input_value_id
    (p_effective_date            => p_effective_date
    ,p_element_type_id           => p_rec.element_type_id
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    ,p_result_rule_type          => p_rec.result_rule_type
    ,p_input_value_id            => p_rec.input_value_id
    );
  --
  chk_unique_rules
    (p_effective_date            => p_effective_date
    ,p_element_type_id           => p_rec.element_type_id
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    ,p_result_rule_type          => p_rec.result_rule_type
    ,p_input_value_id            => p_rec.input_value_id
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_frr_shd.g_rec_type
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
       ,p_associated_column1 => pay_frr_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Validate Dependent Attributes
  --
  If p_rec.element_type_id is not null then
    chk_element_type_id
      (p_effective_date    => p_effective_date
      ,p_element_type_id   => p_rec.element_type_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_legislation_code  => p_rec.legislation_code
      );
  End if;
  --
  chk_result_rule_type
    (p_effective_date            => p_effective_date
    ,p_element_type_id           => p_rec.element_type_id
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    ,p_result_rule_type          => p_rec.result_rule_type
    ,p_severity_level            => p_rec.severity_level
    ,p_input_value_id            => p_rec.input_value_id
    );
  --
  If p_rec.severity_level is not null then
    chk_severity_level
      (p_effective_date => p_effective_date
      ,p_severity_level => p_rec.severity_level
      );
  End if;
  --
  chk_input_value_id
    (p_effective_date            => p_effective_date
    ,p_element_type_id           => p_rec.element_type_id
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    ,p_result_rule_type          => p_rec.result_rule_type
    ,p_input_value_id            => p_rec.input_value_id
    );
  --
  chk_unique_rules
    (p_effective_date            => p_effective_date
    ,p_element_type_id           => p_rec.element_type_id
    ,p_status_processing_rule_id => p_rec.status_processing_rule_id
    ,p_result_name               => p_rec.result_name
    ,p_result_rule_type          => p_rec.result_rule_type
    ,p_input_value_id            => p_rec.input_value_id
    ,p_formula_result_rule_id    => p_rec.formula_result_rule_id
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
  (p_rec                    in pay_frr_shd.g_rec_type
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
                    ,pay_frr_shd.g_old_rec.business_group_id
                    ,pay_frr_shd.g_old_rec.legislation_code
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
    ,p_formula_result_rule_id           => p_rec.formula_result_rule_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_frr_bus;

/
