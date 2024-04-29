--------------------------------------------------------
--  DDL for Package Body PAY_PBD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBD_BUS" as
/* $Header: pypbdrhi.pkb 115.1 2002/12/11 15:12:08 exjones noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pbd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_bal_attribute_default_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_bal_attribute_default_id             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_bal_attribute_defaults pbd
     where pbd.bal_attribute_default_id = p_bal_attribute_default_id
       and pbg.business_group_id = pbd.business_group_id;
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
    ,p_argument           => 'bal_attribute_default_id'
    ,p_argument_value     => p_bal_attribute_default_id
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
        => nvl(p_associated_column1,'BAL_ATTRIBUTE_DEFAULT_ID')
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
  (p_bal_attribute_default_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_bal_attribute_defaults pbd
     where pbd.bal_attribute_default_id = p_bal_attribute_default_id
       and pbg.business_group_id (+) = pbd.business_group_id;
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
    ,p_argument           => 'bal_attribute_default_id'
    ,p_argument_value     => p_bal_attribute_default_id
    );
  --
  if ( nvl(pay_pbd_bus.g_bal_attribute_default_id, hr_api.g_number)
       = p_bal_attribute_default_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pbd_bus.g_legislation_code;
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
    pay_pbd_bus.g_bal_attribute_default_id    := p_bal_attribute_default_id;
    pay_pbd_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_attribute_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the validity of the attribute_id
--   entered. The following rules apply
--
--    Mode     Attribute_id Result
--    ------   -----------  ---------------------------------------------------
--    USER     USER         USER row in bal_attribute_defaults
--    USER     STARTUP      USER row in bal_attribute_defaults
--    USER     GENERIC      USER row in bal_attribute_defaults
--    STARTUP  USER         Error - This mode cannot access USER attributes
--    STARTUP  STARTUP      STARTUP row in bal_attribute_defaults
--    STARTUP  GENERIC      STARTUP row in bal_attribute_defaults
--    GENERIC  USER         Error - This mode cannot access USER attributes
--    GENERIC  STARTUP      Error - This mode cannot access STARTUP attributes
--    GENERIC  GENERIC      GENERIC row in bal_attribute_defaults
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
--   Processing continues if a valid attribute_id exists.
--
-- Post Failure:
--   An application error is raised if the attribute_id does not exist.
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_attribute_id
  (p_bal_attribute_default_id in number
  ,p_attribute_id             in number
  ,p_business_group_id        in number default null
  ,p_legislation_code         in varchar2 default null) IS
--
  l_proc     varchar2(72) := g_package || 'chk_attribute_id';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_attribute_id varchar2(80);
  --
  cursor csr_chk_attribute_id_u(p_leg_code varchar2
                               ,p_bg_id    number)
  is
  select 1
  from   pay_bal_attribute_definitions bad
  where  bad.attribute_id = p_attribute_id
  and    ((bad.business_group_id is not null
         and bad.business_group_id = p_bg_id)
  or     (bad.legislation_code is not null
         and bad.legislation_code = p_leg_code)
  or     (bad.business_group_id is null
         and bad.legislation_code is null));
  --
  cursor csr_chk_attribute_id_s(p_leg_code varchar2)
  is
  select 1
  from   pay_bal_attribute_definitions bad
  where  bad.attribute_id = p_attribute_id
  and    bad.business_group_id is null
  and    ((bad.legislation_code is not null
         and bad.legislation_code = p_leg_code)
  or     (bad.legislation_code is null));
  --
  cursor csr_chk_attribute_id_g
  is
  select 1
  from pay_bal_attribute_definitions bad
  where  bad.attribute_id = p_attribute_id
  and    bad.business_group_id is null
  and    bad.legislation_code is null;
  --
  l_exists number;
  l_legislation_code pay_bal_attribute_defaults.legislation_code%type;
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
IF (((p_bal_attribute_default_id is not null) and
     nvl(pay_pbd_shd.g_old_rec.attribute_id, hr_api.g_varchar2) <>
     nvl(p_attribute_id, hr_api.g_varchar2))
   or
    (p_bal_attribute_default_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if attribute_id is not null
      --
      if p_attribute_id is not null then
      --
        IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
        hr_utility.set_location(l_proc, 15);
        --
          OPEN  csr_chk_attribute_id_g;
          FETCH csr_chk_attribute_id_g into l_exists;
          IF csr_chk_attribute_id_g%NOTFOUND THEN
          --
            CLOSE csr_chk_attribute_id_g;
            hr_utility.set_message(801, 'PAY_34251_INV_ATTID_4_MODEG');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_attribute_id_g;
        --
        elsif hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
        hr_utility.set_location(l_proc, 20);
        --
          OPEN  csr_chk_attribute_id_s(p_legislation_code);
          FETCH csr_chk_attribute_id_s into l_exists;
          IF csr_chk_attribute_id_s%NOTFOUND THEN
          --
            CLOSE csr_chk_attribute_id_s;
            hr_utility.set_message(801, 'PAY_34252_INV_ATTID_4_MODES');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_attribute_id_s;
          --
        ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
        hr_utility.set_location(l_proc, 25);
        --
          if p_bal_attribute_default_id is not null then
            l_legislation_code := pay_pbd_bus.return_legislation_code
                                             (p_bal_attribute_default_id);
          else
            l_legislation_code := hr_api.return_legislation_code
                                        (p_business_group_id);
          end if;
          --
          OPEN  csr_chk_attribute_id_u(l_legislation_code
                                      ,p_business_group_id);
          FETCH csr_chk_attribute_id_u into l_exists;
          IF csr_chk_attribute_id_u%NOTFOUND THEN
          --
            CLOSE csr_chk_attribute_id_u;
            hr_utility.set_message(801, 'PAY_34253_INV_ATTID_4_MODEU');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_attribute_id_u;
          --
        END IF;
        --
      end if;
      --
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_attribute_id;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_balance_category_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the validity of the balance_category_id
--   entered. The following rules apply
--
--    Mode     Bal Category Result
--    ------   -----------  ---------------------------------------------------
--    USER     USER         USER row in bal_attribute_defaults
--    USER     STARTUP      USER row in bal_attribute_defaults
--    USER     GENERIC      USER row in bal_attribute_defaults
--    STARTUP  USER         Error - This mode cannot access USER bal categories
--    STARTUP  STARTUP      STARTUP row in bal_attribute_defaults
--    STARTUP  GENERIC      STARTUP row in bal_attribute_defaults
--    GENERIC  USER         Error - This mode cannot access USER bal categories
--    GENERIC  STARTUP      Error - This mode cannot access STARTUP bal cats
--    GENERIC  GENERIC      GENERIC row in bal_attribute_defaults
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
--   Processing continues if a valid balance_category_id exists.
--
-- Post Failure:
--   An application error is raised if the balance_category_id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_balance_category_id
  (p_bal_attribute_default_id in number
  ,p_balance_category_id      in number
  ,p_business_group_id        in number default null
  ,p_legislation_code         in varchar2 default null) IS
--
  l_proc     varchar2(72) := g_package || 'chk_balance_category_id';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_balance_category_id varchar2(80);
  --
  cursor csr_chk_bal_cat_id_u(p_leg_code varchar2
                             ,p_bg_id    number)
  is
  select 1
  from   pay_balance_categories_f pbc
  where  pbc.balance_category_id = p_balance_category_id
  and    ((pbc.business_group_id is not null
         and pbc.business_group_id = p_bg_id)
  or     (pbc.legislation_code is not null
         and pbc.legislation_code = p_leg_code)
  or     (pbc.business_group_id is null
         and pbc.legislation_code is null));
  --
  cursor csr_chk_bal_cat_id_s(p_leg_code varchar2)
  is
  select 1
  from   pay_balance_categories_f pbc
  where  pbc.balance_category_id = p_balance_category_id
  and    pbc.business_group_id is null
  and    ((pbc.legislation_code is not null
         and pbc.legislation_code = p_leg_code)
  or     (pbc.legislation_code is null));
  --
  cursor csr_chk_bal_cat_id_g
  is
  select 1
  from pay_balance_categories_f pbc
  where  pbc.balance_category_id = p_balance_category_id
  and    pbc.business_group_id is null
  and    pbc.legislation_code is null;
  --
  l_exists number;
  l_legislation_code pay_bal_attribute_defaults.legislation_code%type;
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
IF (((p_bal_attribute_default_id is not null) and
     nvl(pay_pbd_shd.g_old_rec.balance_category_id, hr_api.g_varchar2) <>
     nvl(p_balance_category_id, hr_api.g_varchar2))
   or
    (p_bal_attribute_default_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if balance_category_id is not null
      --
      if p_balance_category_id is not null then
      --
        IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
        hr_utility.set_location(l_proc, 15);
        --
          OPEN  csr_chk_bal_cat_id_g;
          FETCH csr_chk_bal_cat_id_g into l_exists;
          IF csr_chk_bal_cat_id_g%NOTFOUND THEN
            CLOSE csr_chk_bal_cat_id_g;
            hr_utility.set_message(801, 'PAY_34254_INV_CATID_4_MODEG');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_bal_cat_id_g;
          --
        elsif hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
        hr_utility.set_location(l_proc, 20);
        --
          OPEN  csr_chk_bal_cat_id_s(p_legislation_code);
          FETCH csr_chk_bal_cat_id_s into l_exists;
          IF csr_chk_bal_cat_id_s%NOTFOUND THEN
            CLOSE csr_chk_bal_cat_id_s;
            hr_utility.set_message(801, 'PAY_34255_INV_CATID_4_MODES');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_bal_cat_id_s;
          --
        ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
        hr_utility.set_location(l_proc, 25);
        --
          if p_bal_attribute_default_id is not null then
            l_legislation_code := pay_pbd_bus.return_legislation_code
                                             (p_bal_attribute_default_id);
          else
            l_legislation_code := hr_api.return_legislation_code
                                        (p_business_group_id);
          end if;
          --
          OPEN  csr_chk_bal_cat_id_u(l_legislation_code
                                    ,p_business_group_id);
          FETCH csr_chk_bal_cat_id_u into l_exists;
          IF csr_chk_bal_cat_id_u%NOTFOUND THEN
          --
            CLOSE csr_chk_bal_cat_id_u;
            hr_utility.set_message(801, 'PAY_34256_INV_CATID_4_MODEU');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_bal_cat_id_u;
          --
        END IF;
        --
      end if;
      --
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_balance_category_id;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_balance_dimension_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the validity of the balance_category_id
--   entered. The following rules apply
--
--    Mode     Bal Dim      Result
--    ------   -----------  ---------------------------------------------------
--    USER     USER         USER row in bal_attribute_defaults
--    USER     STARTUP      USER row in bal_attribute_defaults
--    USER     GENERIC      USER row in bal_attribute_defaults
--    STARTUP  USER         Error - This mode cannot access USER bal dims
--    STARTUP  STARTUP      STARTUP row in bal_attribute_defaults
--    STARTUP  GENERIC      STARTUP row in bal_attribute_defaults
--    GENERIC  USER         Error - This mode cannot access USER bal dims
--    GENERIC  STARTUP      Error - This mode cannot access STARTUP bal dims
--    GENERIC  GENERIC      GENERIC row in bal_attribute_defaults

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
--   Processing continues if a valid balance_dimension_id exists.
--
-- Post Failure:
--   An application error is raised if the balance_dimension_id does not exist.
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_balance_dimension_id
  (p_bal_attribute_default_id in number
  ,p_balance_dimension_id     in number
  ,p_business_group_id        in number default null
  ,p_legislation_code         in varchar2 default null) IS
--
  l_proc     varchar2(72) := g_package || 'chk_balance_dimension_id';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_balance_dimension_id varchar2(80);
  --
  cursor csr_chk_bal_dim_id_u(p_leg_code varchar2
                             ,p_bg_id    number)
  is
  select 1
  from   pay_balance_dimensions dim
  where  dim.balance_dimension_id = p_balance_dimension_id
  and    ((dim.business_group_id is not null
         and dim.business_group_id = p_bg_id)
  or     (dim.legislation_code is not null
         and dim.legislation_code = p_leg_code)
  or     (dim.business_group_id is null
         and dim.legislation_code is null));
  --
    cursor csr_chk_bal_dim_id_s(p_leg_code varchar2)
  is
  select 1
  from   pay_balance_dimensions dim
  where  dim.balance_dimension_id = p_balance_dimension_id
  and    dim.business_group_id is null
  and    ((dim.legislation_code is not null
         and dim.legislation_code = p_leg_code)
  or     (dim.legislation_code is null));
  --
  cursor csr_chk_bal_dim_id_g
  is
  select 1
  from   pay_balance_dimensions dim
  where  dim.balance_dimension_id = p_balance_dimension_id
  and    dim.business_group_id is null
  and    dim.legislation_code is null;
  --
  l_exists number;
  l_legislation_code pay_bal_attribute_defaults.legislation_code%type;
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
IF (((p_bal_attribute_default_id is not null) and
     nvl(pay_pbd_shd.g_old_rec.balance_dimension_id, hr_api.g_varchar2) <>
     nvl(p_balance_dimension_id, hr_api.g_varchar2))
   or
    (p_bal_attribute_default_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if balance_dimension_id is not null
      --
      if p_balance_dimension_id is not null then
      --
        IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
        hr_utility.set_location(l_proc, 15);
        --
          OPEN  csr_chk_bal_dim_id_g;
          FETCH csr_chk_bal_dim_id_g into l_exists;
          IF csr_chk_bal_dim_id_g%NOTFOUND THEN
            CLOSE csr_chk_bal_dim_id_g;
            hr_utility.set_message(801, 'PAY_34258_INV_DIMID_4_MODEG');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_bal_dim_id_g;
          --
        elsif hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
        hr_utility.set_location(l_proc, 20);
        --
          OPEN  csr_chk_bal_dim_id_s(p_legislation_code);
          FETCH csr_chk_bal_dim_id_s into l_exists;
          IF csr_chk_bal_dim_id_s%NOTFOUND THEN
            CLOSE csr_chk_bal_dim_id_s;
            hr_utility.set_message(801, 'PAY_34257_INV_DIMID_4_MODES');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_bal_dim_id_s;
          --
        ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
        hr_utility.set_location(l_proc, 25);
        --
          if p_bal_attribute_default_id is not null then
            l_legislation_code := pay_pbd_bus.return_legislation_code
                                             (p_bal_attribute_default_id);
          else
            l_legislation_code := hr_api.return_legislation_code
                                        (p_business_group_id);
          end if;
          --
          OPEN  csr_chk_bal_dim_id_u(l_legislation_code
                                    ,p_business_group_id);
          FETCH csr_chk_bal_dim_id_u into l_exists;
          IF csr_chk_bal_dim_id_u%NOTFOUND THEN
            CLOSE csr_chk_bal_dim_id_u;
            hr_utility.set_message(801, 'PAY_34259_INV_DIMID_4_MODEU');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_chk_bal_dim_id_u;
          --
        END IF;
        --
      end if;
      --
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_balance_dimension_id;
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
  (p_rec in pay_pbd_shd.g_rec_type
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
  IF NOT pay_pbd_shd.api_updating
      (p_bal_attribute_default_id          => p_rec.bal_attribute_default_id
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_pbd_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if p_rec.balance_category_id <> pay_pbd_shd.g_old_rec.balance_category_id then
     l_argument := 'balance_category_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if p_rec.legislation_code <> pay_pbd_shd.g_old_rec.legislation_code then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if p_rec.bal_attribute_default_id <>
                     pay_pbd_shd.g_old_rec.bal_attribute_default_id then
     l_argument := 'bal_attribute_default_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if p_rec.attribute_id <> pay_pbd_shd.g_old_rec.attribute_id then
     l_argument := 'attribute_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 35);
  --
  if p_rec.balance_dimension_id <> pay_pbd_shd.g_old_rec.balance_dimension_id
     then
     l_argument := 'balance_dimension_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 40);
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
  (p_rec                          in pay_pbd_shd.g_rec_type
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
       ,p_associated_column1 => pay_pbd_shd.g_tab_nam
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
  pay_pbd_bus.chk_attribute_id
             (p_bal_attribute_default_id => p_rec.bal_attribute_default_id
             ,p_attribute_id             => p_rec.attribute_id
             ,p_business_group_id        => p_rec.business_group_id
             ,p_legislation_code         => p_rec.legislation_code
             );
  --
  hr_utility.set_location(l_proc, 10);
  --
  pay_pbd_bus.chk_balance_category_id
             (p_bal_attribute_default_id => p_rec.bal_attribute_default_id
             ,p_balance_category_id      => p_rec.balance_category_id
             ,p_business_group_id        => p_rec.business_group_id
             ,p_legislation_code         => p_rec.legislation_code
             );
  hr_utility.set_location(l_proc, 15);
  --
  pay_pbd_bus.chk_balance_dimension_id
             (p_bal_attribute_default_id => p_rec.bal_attribute_default_id
             ,p_balance_dimension_id     => p_rec.balance_dimension_id
             ,p_business_group_id        => p_rec.business_group_id
             ,p_legislation_code         => p_rec.legislation_code
             );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_pbd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- NB. need to use g_old_rec, as p_rec is not pupulated with all the columns
  -- for delete mode.
  --
  chk_startup_action(false
                    ,pay_pbd_shd.g_old_rec.business_group_id
                    ,pay_pbd_shd.g_old_rec.legislation_code
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_pbd_bus;

/
