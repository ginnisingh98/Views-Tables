--------------------------------------------------------
--  DDL for Package Body PAY_ROM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ROM_BUS" as
/* $Header: pyromrhi.pkb 115.3 2002/12/09 15:04:01 divicker noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_rom_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_run_type_org_method_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_run_type_org_method_id               in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_run_type_org_methods_f rom
     where rom.run_type_org_method_id = p_run_type_org_method_id
       and pbg.business_group_id = rom.business_group_id;
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
    ,p_argument           => 'run_type_org_method_id'
    ,p_argument_value     => p_run_type_org_method_id
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
  (p_run_type_org_method_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_run_type_org_methods_f rom
     where rom.run_type_org_method_id = p_run_type_org_method_id
       and pbg.business_group_id (+) = rom.business_group_id;
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
    ,p_argument           => 'run_type_org_method_id'
    ,p_argument_value     => p_run_type_org_method_id
    );
  --
  if ( nvl(pay_rom_bus.g_run_type_org_method_id, hr_api.g_number)
       = p_run_type_org_method_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_rom_bus.g_legislation_code;
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
    pay_rom_bus.g_run_type_org_method_id := p_run_type_org_method_id;
    pay_rom_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_rom_shd.g_rec_type
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
  IF NOT pay_rom_shd.api_updating
      (p_run_type_org_method_id           => p_rec.run_type_org_method_id
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
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_rom_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if nvl(p_rec.run_type_org_method_id, hr_api.g_number) <>
     nvl(pay_rom_shd.g_old_rec.run_type_org_method_id,hr_api.g_number) then
     l_argument := 'run_type_org_method_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if nvl(p_rec.legislation_code,hr_api.g_varchar2) <>
     nvl(pay_rom_shd.g_old_rec.legislation_code,hr_api.g_varchar2) then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if nvl(p_rec.run_type_id, hr_api.g_number) <>
     nvl(pay_rom_shd.g_old_rec.run_type_id, hr_api.g_number) then
     l_argument := 'run_type_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.org_payment_method_id, hr_api.g_number) <>
     nvl(pay_rom_shd.g_old_rec.org_payment_method_id,hr_api.g_number) then
     l_argument := 'org_payment_method_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 35);
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
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_run_type_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the run_type_id enterend by carrying out
--    the following:
--      - check that the run_type_id exists
--      - check that the following rules apply:
--
--    Mode     Run Type     Available Components             Resulting method
--    ------   -----------  -------------------------------  ---------------
--    USER     USER         USER, STARTUP, GENERIC           USER
--    USER     STARTUP      USER, STARTUP, GENERIC           USER
--    USER     GENERIC      USER, STARTUP, GENERIC           USER
--    STARTUP  USER         This mode cannot access USER     Error
--                          run types
--    STARTUP  STARTUP      STARTUP, GENERIC                 STARTUP
--    STARTUP  GENERIC      STARTUP, GENERIC                 STARTUP
--    GENERIC  USER         This mode cannot access USER     Error
--                          run types
--    GENERIC  STARTUP      This mode cannot access STARTUP  Error
--                          run types
--    GENERIC  GENERIC      GENERIC                          GENERIC
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_org_method_id
--    p_run_type_id
--    p_effective_date
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the run_type_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) run_type_id does not exist
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_run_type_id
  (p_run_type_org_method_id in number
  ,p_run_type_id            in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ,p_legislation_code       in varchar2) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package||'chk_run_type_id';
l_legislation_code pay_run_type_org_methods_f.legislation_code%TYPE := Null;
--
CURSOR csr_chk_user_run_type(p_leg_code varchar2) is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_run_type_id
and    p_effective_date between effective_start_date
                        and     effective_end_date
and    ((prt.business_group_id is not null
       and prt.business_group_id = p_business_group_id)
or     (prt.legislation_code is not null
        and prt.legislation_code = p_leg_code)
or     (prt.business_group_id is null
       and prt.legislation_code is null));
--
CURSOR csr_chk_startup_run_type is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_run_type_id
and    p_effective_date between effective_start_date
                        and     effective_end_date
and    prt.business_group_id is null
and   ((p_legislation_code is not null
      and prt.legislation_code = p_legislation_code)
or    (prt.legislation_code is null));
--
CURSOR csr_chk_generic_run_type is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_run_type_id
and    p_effective_date between effective_start_date
                        and     effective_end_date
and    prt.business_group_id is null
and    prt.legislation_code is null;
--
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the run_type_id has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the run_type_id is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null because pre_insert has not been called yet.
--
  IF (((p_run_type_org_method_id is not null) and
     nvl(pay_rom_shd.g_old_rec.run_type_id, hr_api.g_number) <>
     nvl(p_run_type_id, hr_api.g_number)) or
     (p_run_type_org_method_id is null)) THEN
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Only need to open the cursor if run_type_id is not null
     --
     IF p_run_type_id is not null THEN
     --
       IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
       hr_utility.set_location(l_proc, 15);
       --
         OPEN csr_chk_generic_run_type;
         FETCH csr_chk_generic_run_type INTO l_exists;
           IF csr_chk_generic_run_type%NOTFOUND THEN
           --
             CLOSE csr_chk_generic_run_type;
             hr_utility.set_message(801, 'HR_33587_INVALID_RT_FOR_MODE');
             hr_utility.raise_error;
             --
           END IF;
         CLOSE csr_chk_generic_run_type;
       --
       ELSIF hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
         hr_utility.set_location(l_proc, 20);
         --
         OPEN  csr_chk_startup_run_type;
         FETCH csr_chk_startup_run_type INTO l_exists;
           IF csr_chk_startup_run_type%NOTFOUND THEN
           --
             CLOSE csr_chk_startup_run_type;
             hr_utility.set_message(801, 'HR_33587_INVALID_RT_FOR_MODE');
             hr_utility.raise_error;
           END IF;
         CLOSE csr_chk_startup_run_type;
       --
       ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
         hr_utility.set_location(l_proc, 25);
         --
         IF p_run_type_org_method_id is not null THEN
         l_legislation_code := pay_rom_bus.return_legislation_code(p_run_type_org_method_id);
         ELSE
         l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
         END IF;
         --
         OPEN  csr_chk_user_run_type(l_legislation_code);
         FETCH csr_chk_user_run_type INTO l_exists;
           IF csr_chk_user_run_type%NOTFOUND THEN
           --
             CLOSE csr_chk_user_run_type;
             hr_utility.set_message(801, 'HR_33589_INVALID_RUN_TYPE');
             hr_utility.raise_error;
           END IF;
         CLOSE csr_chk_user_run_type;
       --
       END IF;
     --
     END IF;
  --
  END IF;
--
hr_utility.set_location('Leaving: '||l_proc, 30);
--
end chk_run_type_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_org_payment_method_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the org_payment_method_id entered by carrying out
--    the following:
--      - check that the org_payment_method_id exists
--      - check that the following rules apply:
--
--    Mode     Org Pay. Method   Available Components           Resulting usage
--    ------   ---------------   -----------------------------  ---------------
--    USER     USER              USER, STARTUP, GENERIC         USER
--    STARTUP  USER              This mode cannot access USER   Error
--    GENERIC  USER              This mode cannot access USER   Error
--
--    NB. Only USER defined organization payment methods exist.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_org_method_id
--    p_org_payment_method_id
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If the org_payment_method_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) org_payment_method_id does not exist
--     b) Either STARTUP or GENERIC mode is used.
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_org_payment_method_id
  (p_run_type_org_method_id in number
  ,p_org_payment_method_id  in number
  ,p_effective_date         in date
  ,p_business_group_id      in number) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package||'chk_org_payment_method_id';
--
CURSOR csr_chk_org_pay_method is
select 'Y'
from   pay_org_payment_methods_f opm
where  opm.org_payment_method_id = p_org_payment_method_id
and    p_effective_date between opm.effective_start_date
                        and     opm.effective_end_date
and    opm.business_group_id = p_business_group_id;
--
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the org_payment_method_id has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the org_payment_method_id is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null because pre_insert has not been called yet.
--
  IF (((p_run_type_org_method_id is not null) and
  nvl(pay_rom_shd.g_old_rec.org_payment_method_id, hr_api.g_number) <>
  nvl(p_org_payment_method_id, hr_api.g_number)) or
  (p_run_type_org_method_id is null)) THEN
  --
    hr_utility.set_location(l_proc, 10);
    --
    -- Only need to open the cursor if org_payment_method_id is not null
    --
    IF p_org_payment_method_id is not null THEN
    --
      IF hr_startup_data_api_support.g_startup_mode in ('GENERIC','STARTUP') THEN
      hr_utility.set_location(l_proc, 15);
      --
        hr_utility.set_message(801, 'HR_33591_ROM_INV_PAYM_METHOD');
        hr_utility.raise_error;
      --
      ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
      --
        hr_utility.set_location(l_proc, 20);
        --
        OPEN  csr_chk_org_pay_method;
        FETCH csr_chk_org_pay_method INTO l_exists;
          IF csr_chk_org_pay_method%NOTFOUND THEN
          --
            CLOSE csr_chk_org_pay_method;
            hr_utility.set_message(801, 'HR_33591_ROM_INV_PAYM_METHOD');
            hr_utility.raise_error;
          END IF;
        CLOSE csr_chk_org_pay_method;
      --
      END IF;
    --
    END IF;
  --
  END IF;
--
hr_utility.set_location('Leaving: '||l_proc, 25);
--
end chk_org_payment_method_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_priority  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the priority enterend by carrying out the
--    following:
--      - check that the priority is unique for a particular run_type/
--        org_payment_method combination
--      - check that the priority is between 1 and 99
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_org_method_id
--    p_org_payment_method_id
--    p_run_type_id
--    p_priority
--    p_business_group_id
--    p_legislation_code
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    If the priority is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) it is not unique
--     b) it is not between 1 and 99
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_priority
  (p_run_type_org_method_id in number
  ,p_org_payment_method_id  in number
  ,p_run_type_id            in number
  ,p_priority               in number
  ,p_business_group_id      in number
  ,p_legislation_code       in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package||'chk_priority';
--
CURSOR csr_chk_unique_priority_bg
is
select null
from   pay_run_type_org_methods_f rom
where  rom.run_type_id           = p_run_type_id
and    rom.org_payment_method_id = p_org_payment_method_id
and    rom.priority              = p_priority
and    rom.effective_start_date <= p_validation_end_date
and    rom.effective_end_date   >= p_validation_start_date
and    rom.business_group_id     = p_business_group_id;
--
CURSOR csr_chk_unique_priority_leg
is
select null
from   pay_run_type_org_methods_f rom
where  rom.run_type_id           = p_run_type_id
and    rom.org_payment_method_id = p_org_payment_method_id
and    rom.priority              = p_priority
and    rom.effective_start_date <= p_validation_end_date
and    rom.effective_end_date   >= p_validation_start_date
and    rom.legislation_code      = p_legislation_code;
--
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
--
IF ((p_priority is not null) AND (p_priority NOT BETWEEN 1 and 99)) THEN
--
  hr_utility.set_message(801, 'HR_33582_ROM_PRIORITY_RANGE');
  hr_utility.raise_error;
  --
END IF;
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the priority has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the priority is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_run_type_org_method_id is not null) and
     nvl(pay_rom_shd.g_old_rec.priority, hr_api.g_number) <>
     nvl(p_priority, hr_api.g_number))
   or
     (p_run_type_org_method_id is null)) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Only need to open the cursors if priority is not null
     --
     if p_priority is not null then
     --
       IF p_business_group_id is null THEN
       --
         OPEN  csr_chk_unique_priority_leg;
         FETCH csr_chk_unique_priority_leg INTO l_exists;
         IF csr_chk_unique_priority_leg%FOUND THEN
         --
           CLOSE csr_chk_unique_priority_leg;
           hr_utility.set_message(801, 'HR_33584_ROM_PRIORITY_UNIQUE');
           hr_utility.raise_error;
         END IF;
         CLOSE csr_chk_unique_priority_leg;
         hr_utility.set_location(l_proc, 15);
         --
       ELSE
         OPEN  csr_chk_unique_priority_bg;
         FETCH csr_chk_unique_priority_bg INTO l_exists;
         IF csr_chk_unique_priority_bg%FOUND THEN
         --
           CLOSE csr_chk_unique_priority_bg;
           hr_utility.set_message(801, 'HR_33584_ROM_PRIORITY_UNIQUE');
           hr_utility.raise_error;
         END IF;
         CLOSE csr_chk_unique_priority_bg;
         hr_utility.set_location(l_proc, 20);
         --
       END IF;
       hr_utility.set_location(l_proc, 25);
       --
     else   -- p_priority is null
           hr_utility.set_message(801, 'HR_33583_ROM_PRIORITY_NULL');
           hr_utility.raise_error;
     end if;
     hr_utility.set_location(l_proc, 30);
END IF;
hr_utility.set_location('Leaving: '||l_proc, 35);
END chk_priority;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_amount_percent  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the amount and percent enterend by carrying out
--    the following:
--      - check amount is >0
--      - check that only one of amount and percent are null
--      - if amount is not null check it has the correct money format
--      - if percent is not null check it has the correct format with 2 decimal
--        places
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_percent
--    p_amount
--    p_org_payment_method_id
--
--  Post Success:
--    If amount and percent are valid then processing continues
--
--  Post Failure:
--    If either percent or amount are invalid then an application error will be
--    raised and processing is terminated:
--
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_percent_amount
  (p_percent               in number
  ,p_amount                in number
  ,p_org_payment_method_id in number) is
  --
l_exists         varchar2(1);
l_proc           varchar2(72) := g_package||'chk_percent_amount';
l_curcode        varchar2(15);
l_amount         number(38);
l_percentage     number(10);
--
cursor get_curcode
is
select currency_code
from pay_org_payment_methods_f
where org_payment_method_id = p_org_payment_method_id;
--
BEGIN
hr_utility.set_location('Entering: '||l_proc, 5);
--
-- if amount is not null then percent is null, and vice versa
--
IF p_amount is null THEN
  IF p_percent is null then
    hr_utility.set_message(801, 'HR_6680_PPM_AMT_PERC');
    hr_utility.raise_error;
  END IF;
  --
hr_utility.set_location('Entering: '||l_proc, 10);
--
ELSE
  IF p_percent is not null THEN
    hr_utility.set_message(801, 'HR_6221_PAYM_INVALID_PPM');
    hr_utility.raise_error;
  END IF;
END IF;
--
hr_utility.set_location(l_proc, 15);
--
-- Check formats
--
if p_amount < 0 then
  hr_utility.set_message(801, 'HR_7355_PPM_AMOUNT_NEGATIVE');
  hr_utility.raise_error;
end if;
--
if p_percent not between 0 and 100 then
  hr_utility.set_message(801, 'HR_7040_PERCENT_RANGE');
  hr_utility.raise_error;
end if;
--
hr_utility.set_location(l_proc, 20);
--
if p_amount is not null then
--
--  Check that Amount has a money format
--
  l_amount := to_char(p_amount);
  open get_curcode;
  fetch get_curcode into l_curcode;
  close get_curcode;
  --
  hr_dbchkfmt.is_db_format (p_value    => l_amount,
                            p_arg_name => 'AMOUNT',
                            p_format   => 'M',
                            p_curcode  => l_curcode);
else
--
hr_utility.set_location(l_proc, 25);
--
--  p_percent is not null so check that format is decimal with
--  2 decimal places
--
  l_percentage := to_char(p_percent);
  --
  hr_dbchkfmt.is_db_format (p_value    => l_percentage,
                            p_arg_name => 'PERCENTAGE',
                            p_format   => 'H_DECIMAL2');
end if;
--
hr_utility.set_location('Leaving: '||l_proc, 30);
END chk_percent_amount;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_bg_leg_code >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the business_group_id and legislation code entered
--    by enforcing the following:
--
--    Mode            Business Group ID      Legislation Code
--    -------------   --------------------   ------------------------------
--    USER            NOT NULL               NULL
--    STARTUP         NULL                   NOT NULL
--    GENERIC         NULL                   NULL
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the combination is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) Combination of business_group_id and legislation_code is anything other
--     than detailed above.
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_bg_leg_code
  (p_business_group_id     in number
  ,p_legislation_code      in varchar2) is
--
l_proc    varchar2(72) := g_package||'chk_bg_leg_code';
--
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
--
  IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
  --
    hr_utility.set_location(l_proc, 15);
    --
    IF ((p_business_group_id is not null)
    or (p_legislation_code is not null)) THEN
    --
      hr_utility.set_message(801, 'HR_33586_INVALID_BG_LEG_COMBI');
      hr_utility.raise_error;
    --
    END IF;
  --
  ELSIF hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
  --
    hr_utility.set_location(l_proc, 20);
    --
    IF ((p_business_group_id is not null)
    or (p_legislation_code is null)) THEN
    --
      hr_utility.set_message(801, 'HR_33586_INVALID_BG_LEG_COMBI');
      hr_utility.raise_error;
    --
    END IF;
  --
  ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
  --
    hr_utility.set_location(l_proc, 25);
    --
    IF ((p_business_group_id is null)
    or (p_legislation_code is not null)) THEN
    --
      hr_utility.set_message(801, 'HR_33586_INVALID_BG_LEG_COMBI');
      hr_utility.raise_error;
    --
    END IF;
  --
  END IF;
--
hr_utility.set_location('Leaving: '||l_proc, 30);
--
end chk_bg_leg_code;
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
  (p_org_payment_method_id         in number default hr_api.g_number
  ,p_run_type_id                   in number default hr_api.g_number
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
  If ((nvl(p_org_payment_method_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_org_payment_methods_f'
            ,p_base_key_column => 'ORG_PAYMENT_METHOD_ID'
            ,p_base_key_value  => p_org_payment_method_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'org payment methods';
     raise l_integrity_error;
  End If;
  If ((nvl(p_run_type_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_run_types_f'
            ,p_base_key_column => 'RUN_TYPE_ID'
            ,p_base_key_value  => p_run_type_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'run types';
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
  (p_run_type_org_method_id           in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
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
      ,p_argument       => 'run_type_org_method_id'
      ,p_argument_value => p_run_type_org_method_id
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
    --
    -- Call procedure to check startup_action for inserts.
    --
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    --
    -- Call procedure to check startup_action for updates and deletes.
    --
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_rom_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(True
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_run_type_id(p_run_type_org_method_id => p_rec.run_type_org_method_id
                 ,p_run_type_id            => p_rec.run_type_id
                 ,p_effective_date         => p_effective_date
                 ,p_business_group_id      => p_rec.business_group_id
                 ,p_legislation_code       => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_org_payment_method_id
                 (p_run_type_org_method_id => p_rec.run_type_org_method_id
                 ,p_org_payment_method_id  => p_rec.org_payment_method_id
                 ,p_effective_date         => p_effective_date
                 ,p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_priority(p_run_type_org_method_id => p_rec.run_type_org_method_id
              ,p_org_payment_method_id  => p_rec.org_payment_method_id
              ,p_run_type_id            => p_rec.run_type_id
              ,p_priority               => p_rec.priority
              ,p_business_group_id      => p_rec.business_group_id
              ,p_legislation_code       => p_rec.legislation_code
              ,p_validation_start_date  => p_validation_start_date
              ,p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_percent_amount(p_percent               => p_rec.percentage
                    ,p_amount                => p_rec.amount
                    ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_bg_leg_code(p_business_group_id => p_rec.business_group_id
                 ,p_legislation_code  => p_rec.legislation_code);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_rom_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_run_type_id(p_run_type_org_method_id => p_rec.run_type_org_method_id
                 ,p_run_type_id            => p_rec.run_type_id
                 ,p_effective_date         => p_effective_date
                 ,p_business_group_id      => p_rec.business_group_id
                 ,p_legislation_code       => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_org_payment_method_id
                 (p_run_type_org_method_id => p_rec.run_type_org_method_id
                 ,p_org_payment_method_id  => p_rec.org_payment_method_id
                 ,p_effective_date         => p_effective_date
                 ,p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_priority(p_run_type_org_method_id => p_rec.run_type_org_method_id
              ,p_org_payment_method_id  => p_rec.org_payment_method_id
              ,p_run_type_id            => p_rec.run_type_id
              ,p_priority               => p_rec.priority
              ,p_business_group_id      => p_rec.business_group_id
              ,p_legislation_code       => p_rec.legislation_code
              ,p_validation_start_date  => p_validation_start_date
              ,p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_percent_amount(p_percent               => p_rec.percentage
                    ,p_amount                => p_rec.amount
                    ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_bg_leg_code(p_business_group_id => p_rec.business_group_id
                 ,p_legislation_code  => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 35);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_org_payment_method_id          => p_rec.org_payment_method_id
    ,p_run_type_id                    => p_rec.run_type_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 45);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_rom_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,pay_rom_shd.g_old_rec.business_group_id
                    ,pay_rom_shd.g_old_rec.legislation_code);
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_run_type_org_method_id           => p_rec.run_type_org_method_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_rom_bus;

/
