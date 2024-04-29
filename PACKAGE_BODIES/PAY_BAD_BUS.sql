--------------------------------------------------------
--  DDL for Package Body PAY_BAD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BAD_BUS" as
/* $Header: pybadrhi.pkb 115.3 2003/05/28 18:43:28 rthirlby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bad_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_attribute_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_attribute_id                         in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_bal_attribute_definitions bad
     where bad.attribute_id = p_attribute_id
       and pbg.business_group_id = bad.business_group_id;
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
    ,p_argument           => 'attribute_id'
    ,p_argument_value     => p_attribute_id
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
        => nvl(p_associated_column1,'ATTRIBUTE_ID')
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
  (p_attribute_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_bal_attribute_definitions bad
     where bad.attribute_id = p_attribute_id
       and pbg.business_group_id (+) = bad.business_group_id;
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
    ,p_argument           => 'attribute_id'
    ,p_argument_value     => p_attribute_id
    );
  --
  if ( nvl(pay_bad_bus.g_attribute_id, hr_api.g_number)
       = p_attribute_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_bad_bus.g_legislation_code;
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
    pay_bad_bus.g_attribute_id                := p_attribute_id;
    pay_bad_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_attribute_name >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the attribute_name is unique across
--   all modes, i.e. a user row cannot have the same attribute name as a
--   startup (legislation) row.
--   A hierachy is used to prevent duplicate attribute names. GENERIC mode takes
--   priority, if a generic row exists then error with duplicate name, but if a
--   startup or user row exists with same name then error, saying the existig
--   row must be deleted and retry insert of GENERIC.
--   IF in STARTUP mode, if generic row or startup row in same legislation
--   exists then error - duplicate row, but if user row exists then error
--   saying the existing row must be deleted and retry insert of startup row.
--   If in user mode, if generic row, or startup row with same leg as current
--   bg, or a user row in same bg exists then - error duplicate name.
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
--   Processing continues if a valid attribute_name has been entered.
--
-- Post Failure:
--   An application error is raised if a duplicate attribute_name has been
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_attribute_name
  (p_attribute_id      in number
  ,p_attribute_name    in varchar2
  ,p_business_group_id in number default null
  ,p_legislation_code  in varchar2 default null)
IS
--
  l_proc     varchar2(72) := g_package || 'chk_attribute_name';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_attribute_name varchar2(80);
  l_leg_code varchar2(80);
  l_bg_id    number;
  l_mode     varchar2(30);
  l_bg_leg   varchar2(80);
  --
  cursor csr_attribute_name is
  select bad.attribute_name
  ,      bad.legislation_code
  ,      bad.business_group_id
  from   pay_bal_attribute_definitions bad
  where  bad.attribute_name = p_attribute_name;
  --
  cursor csr_bg_leg(p_bg_id number)
  is
  select legislation_code
  from   per_business_groups
  where  nvl(business_group_id,-1) = nvl(p_bg_id,-1);
  --
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the attribute_name has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the attribute_name is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_attribute_id is not null) and
     nvl(pay_bad_shd.g_old_rec.attribute_name, hr_api.g_varchar2) <>
     nvl(p_attribute_name, hr_api.g_varchar2))
   or
    (p_attribute_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if attribute_name is not null
      --
      if p_attribute_name is not null then
      --
        l_mode := hr_startup_data_api_support.return_startup_mode;
        --
          OPEN csr_attribute_name;
          FETCH csr_attribute_name INTO l_attribute_name
                                       ,l_leg_code
                                       ,l_bg_id;
          IF csr_attribute_name%NOTFOUND THEN
          --
            hr_utility.trace('insert row');
            close csr_attribute_name;
          ELSE
            if l_mode = 'GENERIC' then
              hr_utility.set_location(l_proc, 15);
              if (l_leg_code is null and l_bg_id is null) then
                -- generic row with duplicate name already exists
                hr_utility.set_message(801, 'PAY_34231_DUP_ATT_G');
                hr_utility.raise_error;
              elsif
                 l_leg_code is not null
              or l_bg_id is not null then
                -- name exists at lower level, existing row must be deleted
                -- so new seeded row can be inserted.
                hr_utility.set_message(801,'PAY_34232_S_U_ATT_LOW_LVL_DEL');
                hr_utility.raise_error;
              end if;
            elsif l_mode = 'STARTUP' THEN
              --
              hr_utility.set_location(l_proc, 20);
              if (l_leg_code = p_legislation_code) then
                -- startup row with duplicate name already exists
                hr_utility.set_message(801,'PAY_34233_DUP_ATT_S');
                hr_utility.raise_error;
              elsif
                 l_leg_code is null then
                   if l_bg_id is not null then
                    open  csr_bg_leg(l_bg_id);
                    fetch csr_bg_leg into l_bg_leg;
                    close csr_bg_leg;
                     if p_legislation_code = l_bg_leg then
                     -- Row with duplicate name exists at lower hierarchy.
                     -- Row needs to be deleted so seeded row can be inserted.
                     hr_utility.set_message(801,'PAY_34234_U_ATT_LOW_LVL_DEL');
                     hr_utility.raise_error;
                     end if;
                   else -- l_bg_id is null then
                     -- Row with duplicate name exists at higher level,
                     -- so cannot insert this row.
                     hr_utility.set_message(801,'PAY_34235_G_ATT_HI_LVL');
                     hr_utility.raise_error;
                   end if;
              end if;
            else -- mode is 'USER'
              open  csr_bg_leg(p_business_group_id);
              fetch csr_bg_leg into l_bg_leg;
              close csr_bg_leg;
              --
              if l_bg_id = p_business_group_id then
                -- user row with duplicate name already exists
                hr_utility.set_message(801,'PAY_34236_DUP_ATT_U');
                hr_utility.raise_error;
              elsif
                 l_bg_id is null then
                   if ((l_leg_code is null)
                   or (l_leg_code is not null
                   and l_leg_code = l_bg_leg)) then
                     -- Row with duplicate name exists at higher level, so
                     -- cannot insert this row.
                     hr_utility.set_message(801,'PAY_34237_G_S_ATT_HI_LVL');
                     hr_utility.raise_error;
                   end if;
              end if;
            end if; -- what mode
            close csr_attribute_name;
          END IF;
          --
        end if;
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_attribute_name;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_user_attribute_name >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the user_attribute_name is unique
--   across all modes, i.e. a user row cannot have the same user attribute name
--   as a startup (legislation) row.
--   A hierachy is used to prevent duplicate user attribute names. GENERIC mode
--   takes priority, if a generic row exists then error with duplicate name,
--   but if a startup or user row exists with same user name then error, saying
--   the existig row must be deleted and retry insert of GENERIC.
--   IF in STARTUP mode, if generic row or startup row in same legislation
--   exists then error - duplicate row, but if user row exists then error
--   saying the existing row must be deleted and retry insert of startup row.
--   If in user mode, if generic row, or startup row with same leg as current
--   bg, or a user row in same bg exists then - error duplicate name.
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
--   Processing continues if a valid attribute_name has been entered.
--
-- Post Failure:
--   An application error is raised if a duplicate attribute_name has been
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_user_attribute_name
  (p_attribute_id        in number
  ,p_user_attribute_name in varchar2
  ,p_business_group_id   in number default null
  ,p_legislation_code    in varchar2 default null)
IS
--
  l_proc     varchar2(72) := g_package || 'chk_user_attribute_name';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_user_attribute_name varchar2(80);
  l_leg_code varchar2(80);
  l_bg_id    number;
  l_mode     varchar2(30);
  l_bg_leg   varchar2(80);
  --
  cursor csr_user_attribute_name is
  select bad.user_attribute_name
  ,      bad.legislation_code
  ,      bad.business_group_id
  from   pay_bal_attribute_definitions bad
  where  bad.user_attribute_name = p_user_attribute_name;
  --
  cursor csr_bg_leg(p_bg_id number)
  is
  select legislation_code
  from   per_business_groups
  where  nvl(business_group_id,-1) = nvl(p_bg_id,-1);
  --
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the user_attribute_name has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the user_attribute_name is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_attribute_id is not null) and
     nvl(pay_bad_shd.g_old_rec.user_attribute_name, hr_api.g_varchar2) <>
     nvl(p_user_attribute_name, hr_api.g_varchar2))
   or
   (p_attribute_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if user_attribute_name is not null
      --
      if p_user_attribute_name is not null then
      --
        l_mode := hr_startup_data_api_support.return_startup_mode;
        --
          OPEN csr_user_attribute_name;
          FETCH csr_user_attribute_name INTO l_user_attribute_name
                                       ,l_leg_code
                                       ,l_bg_id;
          IF csr_user_attribute_name%NOTFOUND THEN
          --
            hr_utility.trace('insert row');
            close csr_user_attribute_name;
          ELSE
            if l_mode = 'GENERIC' then
              hr_utility.set_location(l_proc, 15);
              if (l_leg_code is null and l_bg_id is null) then
                -- generic row with duplicate name already exists
                hr_utility.set_message(801, 'PAY_34277_DUP_USRATT_G');
                hr_utility.raise_error;
              elsif
                 l_leg_code is not null
              or l_bg_id is not null then
                -- name exists at lower level, existing row must be deleted
                -- so new seeded row can be inserted.
                hr_utility.set_message(801,'PAY_34278_S_U_USRAT_LWLVL_DEL');
                hr_utility.raise_error;
              end if;
            elsif l_mode = 'STARTUP' THEN
              --
              hr_utility.set_location(l_proc, 20);
              if (l_leg_code = p_legislation_code) then
                -- startup row with duplicate name already exists
                hr_utility.set_message(801,'PAY_34279_DUP_USRATT_S');
                hr_utility.raise_error;
              elsif
                 l_leg_code is null then
                   if l_bg_id is not null then
                    open  csr_bg_leg(l_bg_id);
                    fetch csr_bg_leg into l_bg_leg;
                    close csr_bg_leg;
                     if p_legislation_code = l_bg_leg then
                     -- Row with duplicate name exists at lower hierarchy.
                     -- Row needs to be deleted so seeded row can be inserted.
                     hr_utility.set_message(801,'PAY_34280_U_USRAT_LWLVL_DEL');
                     hr_utility.raise_error;
                     end if;
                   else -- l_bg_id is null then
                     -- Row with duplicate name exists at higher level,
                     -- so cannot insert this row.
                     hr_utility.set_message(801,'PAY_34281_G_USRATT_HI_LVL');
                     hr_utility.raise_error;
                   end if;
              end if;
            else -- mode is 'USER'
              open  csr_bg_leg(p_business_group_id);
              fetch csr_bg_leg into l_bg_leg;
              close csr_bg_leg;
              --
             if l_bg_id = p_business_group_id then
                -- user row with duplicate name already exists
                hr_utility.set_message(801,'PAY_34282_DUP_USRATT_U');
                hr_utility.raise_error;
              elsif
                 l_bg_id is null then
                   if ((l_leg_code is null)
                   or (l_leg_code is not null
                   and l_leg_code = l_bg_leg)) then
                     -- Row with duplicate name exists at higher level, so
                     -- cannot insert this row.
                     hr_utility.set_message(801,'PAY_34283_G_S_USRATT_HI_LVL');
                     hr_utility.raise_error;
                   end if;
              end if;
            end if; -- what mode
            close csr_user_attribute_name;
          END IF;
          --
        end if;
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_user_attribute_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_alterable >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a valid value is entered in the
--   alterable column, either 'Y' or 'N'. If in user mode the alterable flag
--   must be 'Y'.
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
--   Processing continues if a valid value is entered in alterable.
--
-- Post Failure:
--   An application error is raised if a value other than those returned from
--   HR_STANDARD_LOOKUPS with lookup_type = 'YES_NO'.
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_alterable
  (p_effective_date           in date
  ,p_alterable                in varchar2) IS
--
  l_proc     varchar2(72) := g_package || 'chk_alterable';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  --
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- YES_NO is a system level lookup, so only need to validate against
-- hr_standard_lookups, even though the table has a business_group_id and
-- would expect to need to validate against hr_lookups.
--
-- if user mode then alterable must be 'Y'.
--
  if hr_startup_data_api_support.g_startup_mode = 'USER' then
  --
    if p_alterable <> 'Y' then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(801, 'PAY_34238_U_ALT_FLAG_MUSTB_Y');
      hr_utility.raise_error;
    end if;
    --
  else -- startup or generic mode
    --
    IF hr_api.not_exists_in_hrstanlookups
                      (p_effective_date          => p_effective_date
                      ,p_lookup_type             => 'YES_NO'
                      ,p_lookup_code             => p_alterable
                      )
    THEN
    --
    -- the value entered for this  record is not recognised
    --
      fnd_message.set_name('PAY', 'PAY_34239_INV_ALT_FLAG');
      fnd_message.raise_error;
      --
      hr_utility.set_location(l_proc, 15);
    END IF;
  end if; -- what mode
  --
hr_utility.set_location('Leaving: '||l_proc, 20);
--
End chk_alterable;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_for_child_rows >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that no child rows exist when attempting
--   to delete a row from this table. Child row could exist in tables
--   pay_balance_attributes and pay_bal_attribute_defaults.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
--
-- Post Success:
--   If not child rows are found then the row is deleted.
--
-- Post Failure:
--   An application error is raised if any child rows are found and the delete
--   does not take place.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_for_child_rows
  (p_attribute_id      in number
  ,p_business_group_id in number default null
  ,p_legislation_code  in varchar2 default null) is
  --
  cursor csr_child_attrib(p_bal_att_id number
                          ,p_bg_id     number)
  is
  select 1
  from   pay_balance_attributes pba
  where  pba.attribute_id = p_bal_att_id
  and    pba.business_group_id = nvl(p_bg_id, pba.business_group_id);
  --
  cursor csr_child_defaults(p_bal_att_id number
                           ,p_bg_id      number)
  is
  select 1
  from   pay_bal_attribute_defaults pbd
  where  pbd.attribute_id = p_bal_att_id
  and    pbd.business_group_id = nvl(p_bg_id, pbd.business_group_id);
  --
  cursor get_bg_id
  is
  select business_group_id
  from   per_business_groups
  where  legislation_code = p_legislation_code;
  --
  l_proc     varchar2(72) := g_package || 'chk_for_child_rows';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_exists   number(1);
--
BEGIN
hr_utility.set_location('Entering: '||l_proc,5);
--
if p_business_group_id is not null then -- user run type
  open  csr_child_attrib(p_attribute_id, p_business_group_id);
  fetch csr_child_attrib into l_exists;
  if csr_child_attrib%FOUND then
    close csr_child_attrib;
    hr_utility.set_message(801,'PAY_34240_CHILD_ATTRIBUTE');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 10);
  else
    close csr_child_attrib;
  end if;
  --
  open csr_child_defaults(p_attribute_id, p_business_group_id);
  fetch csr_child_defaults into l_exists;
  if csr_child_defaults%FOUND then
    close csr_child_defaults;
    hr_utility.set_message(801,'PAY_34241_CHILD_ATT_DEFAULT');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 15);
  else
    close csr_child_defaults;
  end if;
  --
elsif p_legislation_code is not null then -- startup category
--
  for each_bg in get_bg_id loop
    open csr_child_attrib(p_attribute_id, each_bg.business_group_id);
    fetch csr_child_attrib into l_exists;
    if csr_child_attrib%FOUND then
      close csr_child_attrib;
      hr_utility.set_message(801,'PAY_34240_CHILD_ATTRIBUTE');
      hr_utility.raise_error;
      hr_utility.set_location(l_proc, 20);
    else
      close csr_child_attrib;
    end if;
    --
    -- check for existing child pay_bal_attribute_defaults
    --
    open csr_child_defaults(p_attribute_id, each_bg.business_group_id);
    fetch csr_child_defaults into l_exists;
    if csr_child_defaults%FOUND then
      close csr_child_defaults;
      hr_utility.set_message(801,'PAY_34241_CHILD_ATT_DEFAULT');
      hr_utility.raise_error;
      hr_utility.set_location(l_proc, 25);
    else
      close csr_child_defaults;
    end if;
  end loop;
--
ELSE -- generic category
  open csr_child_attrib(p_attribute_id, p_business_group_id);
  fetch csr_child_attrib into l_exists;
  if csr_child_attrib%FOUND then
    close csr_child_attrib;
    hr_utility.set_message(801,'PAY_34240_CHILD_ATTRIBUTE');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 30);
  else
    close csr_child_attrib;
  end if;
  --
  -- check for existing child pay_bal_attribute_definitions
  --
  open csr_child_defaults(p_attribute_id, p_business_group_id);
  fetch csr_child_defaults into l_exists;
  if csr_child_defaults%FOUND then
    close csr_child_defaults;
    hr_utility.set_message(801,'PAY_34241_CHILD_ATT_DEFAULT');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 35);
  else
    close csr_child_defaults;
  end if;
END IF;
hr_utility.set_location(' Leaving:'|| l_proc, 40);
--
End chk_for_child_rows;
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
  (p_effective_date               in date
  ,p_rec in pay_bad_shd.g_rec_type
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
  IF NOT pay_bad_shd.api_updating
      (p_attribute_id                      => p_rec.attribute_id
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_bad_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if p_rec.attribute_id <> pay_bad_shd.g_old_rec.attribute_id then
     l_argument := 'attribute_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if p_rec.legislation_code <> pay_bad_shd.g_old_rec.legislation_code then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if p_rec.attribute_name <> pay_bad_shd.g_old_rec.attribute_name then
     l_argument := 'attribute_name';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if p_rec.alterable <> pay_bad_shd.g_old_rec.alterable then
     l_argument := 'alterable';
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
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_non_updateable_args;
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
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_bad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
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
       ,p_associated_column1 => pay_bad_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Validate Dependent Attributes
  --
  pay_bad_bus.chk_attribute_name
             (p_attribute_id      => p_rec.attribute_id
             ,p_attribute_name    => p_rec.attribute_name
             ,p_business_group_id => p_rec.business_group_id
             ,p_legislation_code  => p_rec.legislation_code
             );
  --
  pay_bad_bus.chk_user_attribute_name
             (p_attribute_id        => p_rec.attribute_id
             ,p_user_attribute_name => p_rec.user_attribute_name
             ,p_business_group_id   => p_rec.business_group_id
             ,p_legislation_code    => p_rec.legislation_code
             );

  pay_bad_bus.chk_alterable
             (p_effective_date         => p_effective_date
             ,p_alterable              => p_rec.alterable
             );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_bad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_startup_action(false
                    ,pay_bad_shd.g_old_rec.business_group_id
                    ,pay_bad_shd.g_old_rec.legislation_code
                    );
  --
  chk_for_child_rows
             (p_attribute_id      => p_rec.attribute_id
             ,p_business_group_id => pay_bad_shd.g_old_rec.business_group_id
             ,p_legislation_code  => pay_bad_shd.g_old_rec.legislation_code
             );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- NB. need to use g_old_rec, as p_rec is not pupulated with all the columns
  -- for delete mode.
  --
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     hr_utility.set_location(l_proc, 15);
     --
     -- Validate Important Attributes
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
     hr_utility.set_location(l_proc, 20);
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End delete_validate;
--
end pay_bad_bus;

/
