--------------------------------------------------------
--  DDL for Package Body PAY_PEU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEU_BUS" as
/* $Header: pypeurhi.pkb 120.0 2005/05/29 07:29:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_peu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_event_update_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_event_update_id                      in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_event_updates peu
     where peu.event_update_id = p_event_update_id
       and pbg.business_group_id = peu.business_group_id;
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
    ,p_argument           => 'event_update_id'
    ,p_argument_value     => p_event_update_id
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
  (p_event_update_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_event_updates peu
     where peu.event_update_id = p_event_update_id
       and pbg.business_group_id (+) = peu.business_group_id;
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
    ,p_argument           => 'event_update_id'
    ,p_argument_value     => p_event_update_id
    );
  --
  if ( nvl(pay_peu_bus.g_event_update_id, hr_api.g_number)
       = p_event_update_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_peu_bus.g_legislation_code;
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
    pay_peu_bus.g_event_update_id   := p_event_update_id;
    pay_peu_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in pay_peu_shd.g_rec_type
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
  IF NOT pay_peu_shd.api_updating
      (p_event_update_id                      => p_rec.event_update_id
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
    if (nvl(p_rec.dated_table_id, hr_api.g_number) <>
     nvl(pay_peu_shd.g_old_rec.dated_table_id, hr_api.g_number)
     ) then
     l_argument := 'dated_table_id';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.table_name, hr_api.g_varchar2) <>
     nvl(pay_peu_shd.g_old_rec.table_name, hr_api.g_varchar2)
     ) then
     l_argument := 'table_name';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_peu_shd.g_old_rec.business_group_id,hr_api.g_number)
     ) then
     l_argument := 'business_group_id';
     raise l_error;
  END IF;
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
-- |---------------------------<chk_event_type>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the event type passed actually exists
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if column not recognised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_event_type
  (p_effective_date in date
  ,p_rec                          in pay_peu_shd.g_rec_type
  ) is
  l_proc        varchar2(72) := g_package||'chk_event_type';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'event_type'
    ,p_argument_value => p_rec.event_type
    );
  --
  if hr_api.not_exists_in_hrstanlookups(p_effective_date => p_effective_date
                                       ,p_lookup_type    => 'EVENT_TYPE'
                                       ,p_lookup_code    => p_rec.event_type) then
    --
    -- The event_type for this record is not recognised
    --
    fnd_message.set_name('PAY','HR_xxxx_INVALID_EVENT_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
end chk_event_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_change_type>----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_change_type
  (p_effective_date in date
  ,p_rec in pay_peu_shd.g_rec_type
  ) IS
--
  l_proc        varchar2(72) := g_package || 'chk_change_type';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  --
--
Begin
  --
  if hr_api.not_exists_in_hrstanlookups(p_effective_date => p_effective_date
                                       ,p_lookup_type    => 'PROCESS_EVENT_TYPE'
                                       ,p_lookup_code    => p_rec.change_type) then
    --
    -- The change_type for this record is not recognised
    --
    fnd_message.set_name('PAY','HR_xxxx_INVALID_CHANGE_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
end chk_change_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_column >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the column_name is a column
--   which exist on the table referred to
--
-- Prerequisites:
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if column not recognised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_column
  (p_rec                          in pay_peu_shd.g_rec_type
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_column';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  l_dummy       number(1);
  --
  cursor csr_chk_column is
  select 1
  from   dual
  where  exists (
    select 1
    from   pay_dated_tables dt,
           fnd_tables tab,
           fnd_columns col
    where  dt.dated_table_id  = p_rec.dated_table_id
      and  dt.table_name = tab.table_name
      and  tab.table_id = col.table_id
      and  col.column_name = p_rec.column_name
    );
--
Begin
  --
 hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_rec.event_type = 'U')
  Then
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'COLUMN_NAME'
      ,p_argument_value     => p_rec.column_name
    );
    --
    Open csr_chk_column;
    Fetch csr_chk_column Into l_dummy;
    If csr_chk_column%notfound Then
      Close csr_chk_column;
      --
      -- The column does not belong to the table therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_xxxx_INVALID_COLUMN_NAME');

      fnd_message.raise_error;
    End If;
    Close csr_chk_column;
  End If;
 --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_column;
-- Bug no. 3526519. Added check procedure for duplicate check.
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_unique_rules >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to check whether the Row Level Event is unique or
--   not
-- ----------------------------------------------------------------------------
Procedure chk_unique_rules
  (p_rec                          in pay_peu_shd.g_rec_type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_unique_rules';
  l_exists      varchar2(1);
  l_event_update_id number;
  --
   cursor c_duplicate_row
    is
      select '1'
	from pay_event_updates
	where nvl(table_name,'~') = nvl(p_rec.table_name,'~')
	  and nvl(event_type,'~') = nvl(p_rec.event_type,-1)
	  and nvl(column_name,'~') = nvl(p_rec.column_name,'~')
	  and change_type = p_rec.change_type
	  and ((legislation_code =
	         nvl(p_rec.legislation_code,hr_api.return_legislation_code(p_rec.business_group_id)))
	        or ( legislation_code is null  and
	             business_group_id = p_rec.business_group_id)
	        or ( legislation_code is null  and
	             business_group_id is null));
  --
  begin
      --
      hr_utility.set_location('Entering:'||l_proc, 1);
      hr_utility.set_location('Business_group_id :'||p_rec.business_Group_id, 2);
      hr_utility.set_location('legislation_code :'||p_rec.legislation_code, 3);
      hr_utility.set_location('event_type  :'||p_rec.event_type, 4);
      hr_utility.set_location('column_name :'||p_rec.column_name, 5);
      hr_utility.set_location('change_type :'||p_rec.change_type, 6);
      hr_utility.set_location('event_type  :'||p_rec.table_name, 7);
      --
      open c_duplicate_row;
      fetch c_duplicate_row into l_exists;
      if c_duplicate_row%found then
      --
         close c_duplicate_row;
         fnd_message.set_name('PAY', 'PAY_33272_ROW_EVENT_NOT_UNIQUE');
         fnd_message.raise_error;
      --
      End If;
  --
      close c_duplicate_row;
     hr_utility.set_location('Leaving:'||l_proc, 2);
End chk_unique_rules;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_peu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Commenting out the validate bus grp operation as bus grp can
  -- take a null value.
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_change_type (p_effective_date => p_effective_date
                  ,p_rec => p_rec);
  --
  chk_event_type (p_effective_date => p_effective_date
                  ,p_rec => p_rec);
  --
  chk_column (p_rec => p_rec);
  --
  -- Bug no. 3526519. call of check procedure for duplicate check.
  chk_unique_rules(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_peu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Commenting out the validate bus grp operation as bus grp can
  -- take a null value.
  --
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  chk_change_type (p_effective_date => p_effective_date
                  ,p_rec => p_rec);
  --
  chk_event_type (p_effective_date => p_effective_date
                  ,p_rec => p_rec);
  --
  chk_column (p_rec => p_rec);
  --
  -- Bug no. 3526519. call of check procedure for duplicate check.
  chk_unique_rules(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_peu_shd.g_rec_type
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
end pay_peu_bus;

/
