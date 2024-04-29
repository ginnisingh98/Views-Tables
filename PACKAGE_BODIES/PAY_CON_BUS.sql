--------------------------------------------------------
--  DDL for Package Body PAY_CON_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CON_BUS" as
/* $Header: pyconrhi.pkb 115.3 1999/12/03 16:45:29 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_con_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_contr_history_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   contr_history_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_contr_history_id(p_contr_history_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_contr_history_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_con_shd.api_updating
    (p_contr_history_id            => p_contr_history_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_contr_history_id,hr_api.g_number)
     <>  pay_con_shd.g_old_rec.contr_history_id) then
    --
    -- raise error as PK has changed
    --
    pay_con_shd.constraint_error('PAY_US_CONTRIBUTION_HISTORY_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_contr_history_id is not null then
      --
      -- raise error as PK is not null
      --
      pay_con_shd.constraint_error('PAY_US_CONTRIBUTION_HISTORY_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_contr_history_id;
-- ----------------------------------------------------------------------------
-- |------< valid_date_return >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the From Date and the To_date
--   are in the same calender year.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_from_Date  From Date of the record being  inserted or updated.
--   p_to_Date    To Date of the record being  inserted or updated.
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
Procedure valid_date_return
  (p_from_date in date,
   p_to_date in date) is
  l_proc         varchar2(72) := g_package||' valid_date_return';
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    if (p_from_date is null) then
        hr_utility.set_message(801, 'HR_7575_ALL_MAN_DATE_FIELD');
        hr_utility.raise_error;
    end if;
    if (p_from_date > p_to_date ) then
        hr_utility.set_message(801, 'HR_7301_ADD_DATE_TO_LATER');
        hr_utility.raise_error;
    end if;
-- Compares if the date_from is 01/01/YYYY or not
    if (trunc(p_from_date) <> trunc(to_date('01/01/' || to_char(trunc(p_from_date),'YYYY'),'DD/MM/YYYY' ))) then
        hr_utility.set_message(801, 'PAY_6807_CALEND_INVALID_DATE');
        hr_utility.raise_error;
    end if;
-- Compares if the date_to is 31/12/YYYY or not
    if (trunc(p_to_date) <> trunc(to_date('31/12/' || to_char(trunc(p_to_date),'YYYY'),'DD/MM/YYYY' ))) then
        hr_utility.set_message(801, 'PAY_6807_CALEND_INVALID_DATE');
        hr_utility.raise_error;
    end if;
-- Compares if the calender year of date_From and date_to are same or not
    if (to_number(to_char(p_from_date,'YYYY')) <>
          to_number(to_char(p_to_date,'YYYY'))) then
        hr_utility.set_message(801, 'PAY_6807_CALEND_INVALID_DATE');
        hr_utility.raise_error;
    end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
end valid_date_return;
-- ----------------------------------------------------------------------------
-- |------< valid_employee_return >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if a particluar
--   person was a valid employee or not. Furing the calender year of
--   From Date given as input parameter.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_employee_id       Employee Id of the person
--   p_from_Date         From Date of the record being  inserted or updated.
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
Procedure valid_employee_return
  (p_person_id         IN NUMBER,
   p_from_date         IN DATE  ,
   p_business_group_id IN NUMBER) IS
    l_proc         VARCHAR2(72) := g_package||' valid_date_return';
    l_count NUMBER;
begin
    hr_utility.set_location('Entering:'||l_proc, 5);

-- following SQL checks if the person of type 'EMP' was valid or not during
-- a particular time or not

    select count(*)
    into   l_count
    from   per_people_f         ppf,
           per_person_types     ptype
    where  (to_number(to_char(p_from_date,'YYYY')) >=
                to_number(to_char(ppf.effective_start_date,'YYYY')) and
            to_number(to_char(p_from_date,'YYYY'))  <=
                to_number(to_char(ppf.effective_end_date,'YYYY')))
    and    ppf.person_type_id       = ptype.person_type_id
    and    ppf.person_id            = p_person_id
    and    ptype.system_person_type = 'EMP'
    and    ppf.business_group_id    = p_business_group_id;
    if (l_count = 0) then
        hr_utility.set_message(801, 'HR_7149_BOOKINGS_FLAG_CHANGE');
        hr_utility.set_message_token('EMP_OR_APL', 'employee');
        hr_utility.raise_error;
    end if;
    hr_utility.set_location('Leaving:'||l_proc, 10);
end valid_employee_return;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< valid_contr_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value  for
--   Contribution Type is valid or not.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_state_tax_rule_id   PK of record being inserted or updated.
--   sit_optional_calc_ind   Value of lookup code.
--   effective_date          effective date
--   object_version_number   Object version number of record being
--                           inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure valid_contr_type
  (p_lookup_type     in varchar2,
   p_lookup_code     in varchar2,
   p_effective_date  in date
  ) is
  --
  l_proc         varchar2(72) := g_package||'valid_contr_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--  hr_api.mandatory_arg_error
--    (p_api_name       => l_proc
--    ,p_argument       => 'contr_type'
--    ,p_argument_value => p_effective_date
--    );
    --
    -- Validate only if attribute is not 'G' (457)
    --
    if (p_lookup_code = 'G') then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => p_lookup_type,
             p_lookup_code    => p_lookup_code,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
            hr_utility.set_message(801,'HR_7209_API_LOOK_INVALID');
            hr_utility.raise_error;
      end if;
    else
        hr_utility.set_message(801,'HR_7209_API_LOOK_INVALID');
        hr_utility.raise_error;
      --
    end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end valid_contr_type;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_contr_history_id
  (p_contr_history_id          => p_rec.contr_history_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  valid_date_return(
      p_from_date          => p_rec.date_from,
      p_to_date            => p_rec.date_to);


  valid_employee_return(
      p_person_id         => p_rec.person_id        ,
      p_from_date         => p_rec.date_from        ,
      p_business_group_id => p_rec.business_group_id);

  valid_contr_type
  (p_lookup_type    =>  'US_PRE_TAX_DEDUCTIONS',
   p_lookup_code    =>  p_rec.contr_type       ,
   p_effective_date =>  p_rec.date_to         );


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_contr_history_id
  (p_contr_history_id          => p_rec.contr_history_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  valid_date_return
  (
      p_from_date          => p_rec.date_from,
      p_to_date            => p_rec.date_to
  );
  valid_employee_return
  (
      p_person_id          => p_rec.person_id       ,
      p_from_date          => p_rec.date_from       ,
      p_business_group_id  => p_rec.business_group_id
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_con_shd.g_rec_type) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_contr_history_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_us_contribution_history b
    where b.contr_history_id      = p_contr_history_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'contr_history_id',
                             p_argument_value => p_contr_history_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pay_con_bus;

/
