--------------------------------------------------------
--  DDL for Package Body PER_BIL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BIL_BUS" as
/* $Header: pebilrhi.pkb 115.10 2003/04/10 09:19:39 jheer noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bil_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_id_value >------|
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
--   id_value PK of record being inserted or updated.
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
Procedure chk_id_value(p_id_value                in number,
                       p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_id_value';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_bil_shd.api_updating
    (p_id_value                => p_id_value,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_id_value,hr_api.g_number)
     <>  per_bil_shd.g_old_rec.id_value) then
    --
    -- raise error as PK has changed
    --
    per_bil_shd.constraint_error('hr_summary_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_id_value is not null then
      --
      -- raise error as PK is not null
      --
      per_bil_shd.constraint_error('hr_summary_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_id_value;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_bil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_stmt  hr_summary_restriction_type.restriction_sql%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_id_value
  (p_id_value          => p_rec.id_value,
   p_object_version_number => p_rec.object_version_number);
  --
  if p_rec.fk_value1 is not null
  or p_rec.fk_value2 is not null
  or p_rec.fk_value3 is not null then
  --
     if not per_bil_shd.parent_found(p_rec => p_rec) then
        per_bil_shd.constraint_error('PARENT_RECORD');
     end if;
  --
  end if;
  --
  if per_bil_shd.row_exist (p_rec => p_rec) then
     per_bil_shd.constraint_error('UNIQUE_ROW');
  end if;
  --
  if p_rec.type in ('ITEM_TYPE','RESTRICTION_TYPE','KEY_TYPE') then
     --
     per_bil_shd.lookup_exists(p_code => p_rec.text_value1
                              ,p_type => 'GSP_'||p_rec.type);
     --
     if p_rec.type = 'RESTRICTION_TYPE'  then
        if p_rec.text_value4 is not null then
           l_stmt := p_rec.text_value4;
           per_bil_shd.check_restriction_sql (p_stmt              => l_stmt
                                             ,p_business_group_id => p_rec.business_group_id);
        end if;
     end if;
     --
  end if;
  --
  if p_rec.type = 'ITEM_TYPE_USAGE' and per_bil_shd.sequence_exist (p_rec => p_rec) then
     per_bil_shd.constraint_error('UNIQUE_SEQUENCE');
  end if;
  --
  if p_rec.type = 'RESTRICTION_VALUE' then
     --
     if not per_bil_shd.chk_date_valid(p_rec => p_rec) then
        fnd_message.set_name('PER','HR_51155_INVAL_DATE_FORMAT');
        fnd_message.raise_error;
     end if;
     --
     per_bil_shd.valid_value(p_rec => p_rec);
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_bil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_stmt  hr_summary_restriction_type.restriction_sql%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_id_value
  (p_id_value          => p_rec.id_value,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Check to see if any of the (user-owned) fk values or name have changed
  -- If they have then check too see if it is unique/valid
  --
  if (per_bil_shd.g_old_rec.fk_value1   <> p_rec.fk_value1 or
      per_bil_shd.g_old_rec.fk_value2   <> p_rec.fk_value2 or
      per_bil_shd.g_old_rec.text_value1 <> p_rec.text_value1) then
      if per_bil_shd.row_exist (p_rec => p_rec) then
         per_bil_shd.constraint_error('UNIQUE_ROW');
      end if;
  end if;
  --
  -- only check for unique sequence number if row being updated is not system-owned
  --
  if p_rec.type = 'ITEM_TYPE_USAGE'
     and per_bil_shd.g_old_rec.num_value1 <> p_rec.num_value1 then
         if per_bil_shd.sequence_exist (p_rec => p_rec) then
            per_bil_shd.constraint_error('UNIQUE_SEQUENCE');
         end if;
  end if;
  --
  if p_rec.type in ('ITEM_TYPE','RESTRICTION_TYPE','KEY_TYPE') then
     --
     per_bil_shd.lookup_exists(p_code => p_rec.text_value1
                              ,p_type => 'GSP_'||p_rec.type);
     --
     if p_rec.type = 'RESTRICTION_TYPE'  then
        if p_rec.text_value4 is not null then
           l_stmt := p_rec.text_value4;
           per_bil_shd.check_restriction_sql (p_stmt              => l_stmt
                                             ,p_business_group_id => p_rec.business_group_id);
        end if;
     end if;
     --
  end if;
  --
  if p_rec.type = 'RESTRICTION_VALUE' then
     if not per_bil_shd.chk_date_valid(p_rec => p_rec) then
        fnd_message.set_name('PER','HR_51155_INVAL_DATE_FORMAT');
        fnd_message.raise_error;
     end if;
  end if;
  --
  if p_rec.type = 'RESTRICTION_VALUE' then
     per_bil_shd.valid_value(p_rec => p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_bil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  l_type  hr_summary.type%type;
--
  cursor csr_check_children is
    select type
    from   hr_summary
    where  (fk_value1 = p_rec.id_value
    or      fk_value2 = p_rec.id_value
    or      fk_value3 = p_rec.id_value);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_check_children;
  fetch csr_check_children into l_type;
  if csr_check_children%found then
     close csr_check_children;
     if l_type = 'ITEM_TYPE_USAGE' then
        per_bil_shd.constraint_error('CHILD_RECORD_ITU');
     elsif l_type = 'VALID_RESTRICTION' then
        per_bil_shd.constraint_error('CHILD_RECORD_VR');
     elsif l_type = 'RESTRICTION_USAGE' then
        per_bil_shd.constraint_error('CHILD_RECORD_RTU');
     elsif l_type = 'KEY_TYPE_USAGE' then
        per_bil_shd.constraint_error('CHILD_RECORD_KTU');
     elsif l_type = 'RESTRICTION_VALUE' then
        per_bil_shd.constraint_error('CHILD_RECORD_RV');
     elsif l_type = 'ITEM_VALUE' then
        per_bil_shd.constraint_error('CHILD_RECORD_IV');
     elsif l_type = 'KEY_VALUE' then
        per_bil_shd.constraint_error('CHILD_RECORD_KV');
     elsif l_type = 'VALID_KEY_TYPE' then
        per_bil_shd.constraint_error('CHILD_RECORD_VKT');
     elsif l_type = 'PROCESS_RUN' then
        per_bil_shd.constraint_error('CHILD_RECORD_PR');
     end if;
  else
     close csr_check_children;
  end if;
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
  (p_id_value in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           hr_summary b
    where b.id_value      = p_id_value
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
                             p_argument       => 'id_value',
                             p_argument_value => p_id_value);
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
end per_bil_bus;

/
