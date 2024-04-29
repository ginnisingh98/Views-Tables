--------------------------------------------------------
--  DDL for Package Body PAY_GBE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GBE_BUS" as
/* $Header: pygberhi.pkb 120.1 2005/06/30 06:59:09 tukumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_gbe_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_grossup_balances_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--Procedure set_security_group_id
--  (p_grossup_balances_id                  in number
--  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pay_grossup_bal_exclusions and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
--  cursor csr_sec_grp is
--    select pbg.security_group_id
--      from per_business_groups pbg
--         , pay_grossup_bal_exclusions gbe
      --   , EDIT_HERE table_name(s) 333
--     where gbe.grossup_balances_id = p_grossup_balances_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
--  l_security_group_id number;
--  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
--begin
  --
--  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
--  hr_api.mandatory_arg_error
--    (p_api_name           => l_proc
--    ,p_argument           => 'grossup_balances_id'
--    ,p_argument_value     => p_grossup_balances_id
--    );
  --
--  open csr_sec_grp;
--  fetch csr_sec_grp into l_security_group_id;
  --
--  if csr_sec_grp%notfound then
     --
--     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
--     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
--     fnd_message.raise_error;
     --
--  end if;
--  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
--  hr_api.set_security_group_id
--    (p_security_group_id => l_security_group_id
--    );
  --
--  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
--end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--Function return_legislation_code
--  (p_grossup_balances_id                  in     number
--  )
--  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pay_grossup_bal_exclusions and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
--  cursor csr_leg_code is
--    select pbg.legislation_code
--      from per_business_groups     pbg
--         , pay_grossup_bal_exclusions gbe
      --   , EDIT_HERE table_name(s) 333
--     where gbe.grossup_balances_id = p_grossup_balances_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
--  l_legislation_code  varchar2(150);
--  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
--Begin
  --
--  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
--  hr_api.mandatory_arg_error
--    (p_api_name           => l_proc
--    ,p_argument           => 'grossup_balances_id'
--    ,p_argument_value     => p_grossup_balances_id
--    );
  --
--  if ( nvl(pay_gbe_bus.g_grossup_balances_id, hr_api.g_number)
--       = p_grossup_balances_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
--    l_legislation_code := pay_gbe_bus.g_legislation_code;
--    hr_utility.set_location(l_proc, 20);
--  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
--    open csr_leg_code;
--    fetch csr_leg_code into l_legislation_code;
    --
--    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
--      close csr_leg_code;
--      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
--      fnd_message.raise_error;
--    end if;
--    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
--    close csr_leg_code;
--    pay_gbe_bus.g_grossup_balances_i:= p_grossup_balances_id;
--    pay_gbe_bus.g_legislation_code  := l_legislation_code;
--  end if;
--  hr_utility.set_location(' Leaving:'|| l_proc, 40);
--  return l_legislation_code;
--end return_legislation_code;
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
  (p_rec in pay_gbe_shd.g_rec_type
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
  IF NOT pay_gbe_shd.api_updating
      (p_grossup_balances_id                  => p_rec.grossup_balances_id
      ,p_object_version_number                => p_rec.object_version_number
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
  if nvl(p_rec.grossup_balances_id, hr_api.g_number) <>
     nvl(pay_gbe_shd.g_old_rec.grossup_balances_id, hr_api.g_number) then
     l_argument := 'grossup_balances_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
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
-- |---------------------------< chk_upd_dates >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that for the row being updated, the start
--   date is not later than the end date. Also checks that the dates do not overlap
--   with some existing one with the same source_type, source_id and balance_type_id.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_grossup_balances_id
--   p_start_date
--   p_end_date
--   p_source_type
--   p_source_id
--   p_balance_type_id
--   p_object_version_number
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
procedure chk_upd_dates
  (p_grossup_balances_id     in number
  ,p_start_date              in date
  ,p_end_date                in date
  ,p_source_type             in varchar2
  ,p_source_id               in number
  ,p_balance_type_id         in number
  ,p_object_version_number   in number  )
is
--
  l_exists              varchar2(1);
  l_proc                varchar2(72) := g_package||'chk_upd_dates';
  l_api_updating        boolean;
--
  Cursor C1_upd is
    Select 'Y'
    From   pay_grossup_bal_exclusions
    Where  not
           ((start_date < p_start_date
             and nvl(end_date, hr_general.END_OF_TIME) < p_start_date)
             OR
            (start_date > p_end_date
             AND NVL(end_date, hr_general.END_OF_TIME) > NVL(p_end_date, hr_general.END_OF_TIME))
           )
    And    not (grossup_balances_id = p_grossup_balances_id)
    And    source_type = p_source_type
    And    source_id   = p_source_id
    And    balance_type_id = p_balance_type_id ;
--
begin
   hr_utility.set_location('Entering:'|| l_proc, 1);
   --
   -- check that the start date is not on or more than the end date
   --
   IF nvl(p_start_date, hr_general.START_OF_TIME)
                > NVL(p_end_date, hr_general.END_OF_TIME) THEN
      --
      hr_utility.set_message
         (800
         ,'PAY_52900_GBE_DATE_ERROR'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
   l_api_updating := pay_gbe_shd.api_updating (
           p_grossup_balances_id   => p_grossup_balances_id
          ,p_object_version_number => p_object_version_number );
   --
   if (l_api_updating
       and ( nvl(p_start_date,hr_general.start_of_time)
                  <>  nvl(per_asp_shd.g_old_rec.start_date, hr_general.start_of_time)
             or nvl(p_end_date,hr_general.end_of_time)
                  <>  nvl(per_asp_shd.g_old_rec.end_date, hr_general.end_of_time))) then
     hr_utility.set_location(l_proc, 4);
     open c1_upd;
     fetch c1_upd into l_exists;
     If c1_upd%found then
        hr_utility.set_location(l_proc, 5);
        Close c1_upd;
        hr_utility.set_message
            (800
            ,'PAY_52901_GBE_OVERLAP_ERROR'
            );
        hr_utility.raise_error;
     else  Close c1_upd;
     End if;
   end if;
   --
END chk_upd_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ins_dates >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that for the row being inserted, the start
--   date is not later than the end date. Also checks that the dates do not overlap
--   with some existing one with the same source_type, source_id and balance_type_id.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_start_date
--   p_end_date
--   p_source_type
--   p_source_id
--   p_balance_type_id
--   p_object_version_number
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
procedure chk_ins_dates
  (p_start_date              in date
  ,p_end_date                in date
  ,p_source_type             in varchar2
  ,p_source_id               in number
  ,p_balance_type_id         in number
  ,p_object_version_number   in number  )
is
--
  l_exists              varchar2(1);
  l_proc                varchar2(72) := g_package||'chk_ins_dates';
--
  Cursor C1_ins is
    Select 'Y'
    From   pay_grossup_bal_exclusions
    Where  not
           ((start_date < p_start_date
             and nvl(end_date, hr_general.END_OF_TIME) < p_start_date)
             OR
            (start_date > p_end_date
             AND NVL(end_date, hr_general.END_OF_TIME) > NVL(p_end_date, hr_general.END_OF_TIME))
           )
    And    source_type = p_source_type
    And    source_id   = p_source_id
    And    balance_type_id = p_balance_type_id ;
--
begin
   hr_utility.set_location('Entering:'|| l_proc, 1);
   --
   -- check that the start date is not on or more than the end date
   --
   IF nvl(p_start_date, hr_general.START_OF_TIME)
                > NVL(p_end_date, hr_general.END_OF_TIME) THEN
      --
      hr_utility.set_message
         (800
         ,'PAY_52900_GBE_DATE_ERROR'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
   open C1_ins;
   fetch C1_ins into l_exists;
   If C1_ins%found then
     hr_utility.set_location(l_proc, 5);
     Close C1_ins;
     hr_utility.set_message
         (800
         ,'PAY_52901_GBE_OVERLAP_ERROR'
         );
     hr_utility.raise_error;
   else  Close C1_ins;
   End if;
--
END chk_ins_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that for the row being updated or inserted,
--   the source type is either 'EE' or 'ET', and source_id is not null.
--   Also, if source_type is 'EE', source_id will have to be an element_entry_id
--   which exists on pay_element_entries_f. If source_type is 'ET', source_id
--   will have to be an element_type id which exists on pay_element_types_f.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_source_type
--   p_source_id
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
procedure chk_source
 ( p_source_type in varchar2
  ,p_source_id in number)
is
--
        l_exists             number;
        l_proc               varchar2(72)  :=  g_package||'chk_source ';
        --
        cursor C_ee is
          Select distinct ee.element_entry_id
          from pay_element_entries_f ee
          where ee.element_entry_id = p_source_id ;
       --
        cursor C_et is
          Select distinct et.element_type_id
          from pay_element_types_f et
          where et.element_type_id = p_source_id ;
--
begin
--
  hr_utility.set_location('Entering:'|| p_source_type, 1);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'source_type'
    ,p_argument_value => p_source_type
   );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'source_id'
    ,p_argument_value => p_source_id
   );
--
  if (p_source_type not in ('EE', 'ET') ) then
     pay_gbe_shd.constraint_error(p_constraint_name => 'PAY_GBE_SOURCE_TYPE_CHK');
  end if;
--
  if (p_source_type = 'EE') then
    open C_ee;
     fetch C_ee into l_exists;
     if C_ee%notfound then
       hr_utility.set_location(l_proc, 3);
       close C_ee;
       hr_utility.set_message(801, 'PAY_52902_GBE_SOURCE_ERROR');
       hr_utility.raise_error;
     end if;
     close C_ee;
  elsif (p_source_type = 'ET') then
    open C_et;
     fetch C_et into l_exists;
     if C_et%notfound then
       hr_utility.set_location(l_proc, 3);
       close C_et;
       hr_utility.set_message(801, 'PAY_52902_GBE_SOURCE_ERROR');
       hr_utility.raise_error;
     end if;
     close C_et;
  end if;
--
  hr_utility.set_location(l_proc, 2);
--
end chk_source;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_bal_type_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that for the row being updated or inserted,
--   the balance type id exists in pay_balance_types.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_balance_type_id
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
Procedure chk_bal_type_id
  ( p_balance_type_id in number )
is
--
        l_exists             number;
        l_proc               varchar2(72)  :=  g_package||'chk_bal_type_id ';
        --
        -- Cursor to check a valid BALANCE_TYPE_ID being inserted.
        -- It should exist on pay_balance_types table.
        --
        cursor C1 is
          select balance_type_id
          from   pay_balance_types
          where  balance_type_id = p_balance_type_id ;
--
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'balance_type_id'
    ,p_argument_value => p_balance_type_id
    );
  --
     open C1;
     fetch C1 into l_exists;
     if C1%notfound then
       hr_utility.set_location(l_proc, 3);
       close C1;
       -- raise error as FK does not relate to PK in pay_balance_types
       pay_gbe_shd.constraint_error('PAY_GROSSUP_BAL_EXCLUSIONS_FK1');
     end if;
     close C1;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end chk_bal_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the row being inserted or updated does
--   not already exists on the database, i.e, has the same balance_type_id,
--   start_date, end_date, source_type and source_id combination.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_balance_type_id
--   p_start_date
--   p_end_date
--   p_source_type
--   p_source_id
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
    ( p_balance_type_id in number
     ,p_start_date      in date
     ,p_end_date        in date
     ,p_source_type     in varchar2
     ,p_source_id       in number) is
--
    l_exists    varchar2(1);
    l_proc      varchar2(72) := g_package||'chk_unique_key';
--
    cursor C1 is
    select 'Y'
    from  pay_grossup_bal_exclusions gbe
    where gbe.balance_type_id = p_balance_type_id
    and   gbe.start_date      = p_start_date
    and   gbe.end_date        = p_end_date
    and   gbe.source_type     = p_source_type
    and   gbe.source_id       = p_source_id ;
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
     pay_gbe_shd.constraint_error('PAY_GROSSUP_BAL_EXCLUSIONS_UK1');
   end if;
   close C1;
   --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
--
end chk_unique_key;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_gbe_shd.g_rec_type
  ) is
  --
  l_proc  varchar2(72) := g_package||'insert_validate';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_ins_dates (
              p_start_date          => p_rec.start_date
             ,p_end_date            => p_rec.end_date
             ,p_source_type         => p_rec.source_type
             ,p_source_id           => p_rec.source_id
             ,p_balance_type_id     => p_rec.balance_type_id
             ,p_object_version_number => p_rec.object_version_number );
  --
  chk_source ( p_source_type         => p_rec.source_type
              ,p_source_id           => p_rec.source_id );
  --
  chk_bal_type_id ( p_balance_type_id => p_rec.balance_type_id );
  --
  chk_unique_key  ( p_balance_type_id => p_rec.balance_type_id
                   ,p_start_date      => p_rec.start_date
                   ,p_end_date        => p_rec.end_date
                   ,p_source_type     => p_rec.source_type
                   ,p_source_id       => p_rec.source_id );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_gbe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  chk_upd_dates ( p_grossup_balances_id => p_rec.grossup_balances_id
             ,p_start_date          => p_rec.start_date
             ,p_end_date            => p_rec.end_date
             ,p_source_type         => p_rec.source_type
             ,p_source_id           => p_rec.source_id
             ,p_balance_type_id     => p_rec.balance_type_id
             ,p_object_version_number => p_rec.object_version_number);
  --
  chk_source ( p_source_type         => p_rec.source_type
              ,p_source_id           => p_rec.source_id );
  --
  chk_bal_type_id ( p_balance_type_id => p_rec.balance_type_id );
  --
  chk_unique_key  ( p_balance_type_id => p_rec.balance_type_id
                   ,p_start_date      => p_rec.start_date
                   ,p_end_date        => p_rec.end_date
                   ,p_source_type     => p_rec.source_type
                   ,p_source_id       => p_rec.source_id );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_gbe_shd.g_rec_type
  ) is
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
end pay_gbe_bus;

/
