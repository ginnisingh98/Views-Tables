--------------------------------------------------------
--  DDL for Package Body PAY_ISB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ISB_BUS" as
/* $Header: pyisbrhi.pkb 115.3 2002/12/16 17:48:15 dsaxby ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_isb_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_social_benefit_id           number         default null;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_absence_date >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_absence_date( p_assignment_id         number,
                            p_absence_start_date    date,
                            p_absence_end_date      date) is
    cursor c_absence_dates is
        select  social_benefit_id
        from    pay_ie_social_benefits_f isb
        where   isb.assignment_id = p_assignment_id
        and     (p_absence_start_date
                between isb.absence_start_date and isb.absence_end_date
                or  p_absence_end_date
                between isb.absence_start_date and isb.absence_end_date);
    l_social_benefit_id     integer;
begin
    open c_absence_dates;
    fetch c_absence_dates into l_social_benefit_id;
    if  c_absence_dates%found then
        close c_absence_dates;
        fnd_message.set_name('PAY','HR_IE_ABSENCE_EXISTS');
        fnd_message.raise_error;
    end if;
    if  c_absence_dates%isopen then
        close c_absence_dates;
    end if;
exception
    when others then
        raise;
end chk_absence_date;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_calculation_option >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_calculation_option(p_calculation_option   in  pay_ie_social_benefits_f.calculation_option%type) is
    cursor c_calculation_option is
        select 1
        from hr_lookups
        where lookup_type = 'IE_CALC_OPTION'
        and lookup_code = p_calculation_option
        and enabled_flag = 'Y';
    l_calculation_option_count  number;
begin
    open c_calculation_option;
    fetch c_calculation_option into l_calculation_option_count;
    if  nvl(l_calculation_option_count,0) = 0 then
        close c_calculation_option;
        fnd_message.set_name('PAY','HR_IE_NO_VALID_CALC_OPTION');
        fnd_message.raise_error;
    end if;
    if c_calculation_option%isopen then
        close c_calculation_option;
    end if;
exception
    when others then
        raise;
end chk_calculation_option;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_benefit_type >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_benefit_type(p_benefit_type   in  pay_ie_social_benefits_f.benefit_type%type) is
    cursor c_benefit_type is
        select  1
        from    hr_lookups
        where   lookup_type = 'IE_BENEFIT_TYPE'
        and     lookup_code = p_benefit_type
        and     enabled_flag = 'Y';
    l_benefit_type_count    number;
begin
        open    c_benefit_type;
        fetch   c_benefit_type  into    l_benefit_type_count;
        if p_benefit_type is not null then
            if  nvl(l_benefit_type_count,0) = 0 then
                close   c_benefit_type;
                fnd_message.set_name('PAY','HR_IE_NO_VALID_BENEFIT_TYPE');
                fnd_message.raise_error;
            end if;
        end if;
        if  c_benefit_type%isopen then
            close   c_benefit_type;
        end if;
exception
    when others then
        raise;
end chk_benefit_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_incident_id >---------------------------|
-- ----------------------------------------------------------------------------
procedure chk_incident_id(  p_incident_id   in  per_work_incidents.incident_id%type) is
    cursor c_incident_id is
        select  incident_id
        from    per_work_incidents
        where   incident_id = p_incident_id;
    l_incident_id       integer;
begin
    open    c_incident_id;
    fetch   c_incident_id into  l_incident_id;
    if p_incident_id is not null then
        if  c_incident_id%notfound then
            close c_incident_id;
            fnd_message.set_name('PAY','HR_IE_NO_VALID_INCIDENT_ID');
            fnd_message.raise_error;
        end if;
    end if;
    if  c_incident_id%isopen then
        close   c_incident_id;
    end if;
exception
    when others then
        raise;
end chk_incident_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_paye_details >---------------------------|
--  ---------------------------------------------------------------------------
procedure chk_paye_details( p_effective_date    in  date,
                            p_rec               in  pay_isb_shd.g_rec_type) is
      cursor    c_paye_details is
        select  paye_details_id
        from    pay_ie_paye_details_f ipd
        where   ipd.assignment_id = p_rec.assignment_id
        and     (ipd.tax_basis = 'IE_CUMULATIVE'
                or ipd.tax_basis = 'IE_WEEK1_MONTH1')
        and     p_effective_date between effective_start_date and effective_end_date;
      l_paye_details    integer;
begin
      open  c_paye_details;
      fetch c_paye_details into l_paye_details;
      if c_paye_details%notfound then
        close c_paye_details;
        fnd_message.set_name('PAY','HR_IE_PAYE_DETAILS_NULL');
        fnd_message.raise_error;
      end if;
      if c_paye_details%isopen then
        close c_paye_details;
      end if;
      --
exception
    when others then
        raise;
end chk_paye_details;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_valid_absence_dates >-------------------------|
--  ---------------------------------------------------------------------------
procedure chk_valid_absence_dates(  p_absence_start_date    date,
                                    p_absence_end_date      date) is
begin
    if p_absence_start_date > nvl(p_absence_end_date, p_absence_start_date+1) then
        fnd_message.set_name('PAY','HR_IE_START_END_DATES');
        fnd_message.set_token('START',TO_CHAR(p_absence_start_date),TRUE);
        fnd_message.set_token('END',TO_CHAR(p_absence_end_date),TRUE);
        fnd_message.raise_error;
    END IF;
end chk_valid_absence_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_calc_option_required >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_calc_option_required(p_rec    in  pay_isb_shd.g_rec_type) is
begin
    if  nvl(p_rec.benefit_amount,0) > 0 and p_rec.calculation_option is null then
        fnd_message.set_name('PAY','HR_IE_CALC_OPTION_REQUIRED');
        fnd_message.raise_error;
    end if;
end chk_calc_option_required;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_benefit_type_required >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_benefit_type_required(p_rec   in  pay_isb_shd.g_rec_type) is
begin
    if  nvl(p_rec.benefit_amount,0) > 0
        and (p_rec.calculation_option = 'IE_OPTION1'  or
             p_rec.calculation_option = 'IE_OPTION2'  or
             p_rec.calculation_option = 'IE_OPTION3'  or
             p_rec.calculation_option = 'IE_OPTION4')
        and p_rec.benefit_type is null then
        fnd_message.set_name('PAY','HR_IE_BENEFIT_TYPE_REQUIRED');
        fnd_message.raise_error;
    end if;
end;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_payroll_period_type >-------------------------|
-- ----------------------------------------------------------------------------
--
function get_payroll_period_type(p_assignment_id    pay_ie_social_benefits_f.assignment_id%type)
return varchar2 is
    cursor c_payroll_period_type is
        select  pay.period_type period_type
        from    per_all_assignments_f asg,
                pay_all_payrolls_f pay
        where   asg.payroll_id = pay.payroll_id
        and     asg.assignment_id = p_assignment_id;
        l_period_type            pay_all_payrolls.period_type%type;
begin
        open c_payroll_period_type;
        fetch c_payroll_period_type into l_period_type;
        close c_payroll_period_type;
        --
        return l_period_type;
exception
    when others then
        raise;
end get_payroll_period_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_social_benefit_id                    in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_ie_social_benefits_f isb
         , per_all_assignments_f paf
     where isb.social_benefit_id = p_social_benefit_id
       and pbg.business_group_id = paf.business_group_id
       and isb.assignment_id = paf.assignment_id;
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
    ,p_argument           => 'social_benefit_id'
    ,p_argument_value     => p_social_benefit_id
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
  (p_social_benefit_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_ie_social_benefits_f isb
         , per_all_assignments_f paf
     where isb.social_benefit_id = p_social_benefit_id
       and pbg.business_group_id = paf.business_group_id
       and paf.assignment_id = isb.assignment_id;
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
    ,p_argument           => 'social_benefit_id'
    ,p_argument_value     => p_social_benefit_id
    );
  --
  if ( nvl(pay_isb_bus.g_social_benefit_id, hr_api.g_number)
       = p_social_benefit_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_isb_bus.g_legislation_code;
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
    pay_isb_bus.g_social_benefit_id           := p_social_benefit_id;
    pay_isb_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_isb_shd.g_rec_type
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
  IF NOT pay_isb_shd.api_updating
      (p_social_benefit_id                => p_rec.social_benefit_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
  (p_assignment_id                 in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
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
  If ((nvl(p_assignment_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_assignments_f'
            ,p_base_key_column => 'ASSIGNMENT_ID'
            ,p_base_key_value  => p_assignment_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'all assignments';
     raise l_integrity_error;
  End If;
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
  (p_social_benefit_id                in number
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
      ,p_argument       => 'social_benefit_id'
      ,p_argument_value => p_social_benefit_id
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
  (p_rec                   in pay_isb_shd.g_rec_type
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
  --Check the Absence Start Date is earlier than Abasence End Date
  chk_valid_absence_dates(  p_absence_start_date    =>p_rec.absence_start_date,
                            p_absence_end_date      =>p_rec.absence_end_date);

  --Check whether if these absence dates already exists in the database
  --for this social_benefit_id
  chk_absence_date( p_assignment_id         =>  p_rec.assignment_id,
                    p_absence_start_date    =>  p_rec.absence_start_date,
                    p_absence_end_date      =>  p_rec.absence_end_date);
  --The Calculation Option is requred if benefit amount is positive
  chk_calc_option_required(p_rec    =>  p_rec);
  --The Benefit type is required when benefit amount is positive
  --and calculation option is in (Option 2/Option 3/Option 4)
  chk_benefit_type_required(p_rec   =>  p_rec);
  --Check for valid Calculation Option
  chk_calculation_option(p_calculation_option   =>  p_rec.calculation_option);
  --
  --Check for valid Benefit Type
  chk_benefit_type(p_benefit_type   =>  p_rec.benefit_type);
  --
  --Check for valid Incident Type for the person selected
  chk_incident_id(  p_incident_id   =>  p_rec.incident_id);
  --
  chk_paye_details( p_effective_date    =>  p_effective_date,
                    p_rec               =>  p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_isb_shd.g_rec_type
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
  --Check the Absence Start Date is earlier than Abasence End Date
    chk_valid_absence_dates(p_absence_start_date    =>p_rec.absence_start_date,
                            p_absence_end_date      =>p_rec.absence_end_date);
  --
  --Check whether if these absence dates already exists in the database
  --for this social_benefit_id
    chk_absence_date(   p_assignment_id         =>  p_rec.assignment_id,
                        p_absence_start_date    =>  p_rec.absence_start_date,
                        p_absence_end_date      =>  p_rec.absence_end_date);
  --The Calculation Option is requred if benefit amount is positive
    chk_calc_option_required(p_rec  =>  p_rec);
  --The Benefit type is required when benefit amount is positive
  --and calculation option is in (Option 2/Option 3/Option 4)
    chk_benefit_type_required(p_rec =>  p_rec);
  --Check for valid Calculation Option
    chk_calculation_option(p_calculation_option =>  p_rec.calculation_option);
  --Check for valid Benefit Type
    chk_benefit_type(p_benefit_type     =>  p_rec.benefit_type);
  --
  --Check for valid Incident Type for the person selected
    chk_incident_id(    p_incident_id   =>  p_rec.incident_id);
  --Check for paye details existance for option2/3/4
    chk_paye_details(   p_effective_date    =>  p_effective_date,
                        p_rec               =>  p_rec);
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_assignment_id                  => p_rec.assignment_id
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
  (p_rec                    in pay_isb_shd.g_rec_type
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
    ,p_social_benefit_id                => p_rec.social_benefit_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_isb_bus;

/
