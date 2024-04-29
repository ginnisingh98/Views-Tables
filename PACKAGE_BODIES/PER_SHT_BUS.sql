--------------------------------------------------------
--  DDL for Package Body PER_SHT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHT_BUS" as
/* $Header: peshtrhi.pkb 120.0 2005/05/31 21:06:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sht_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_shared_type_id >------|
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
--   shared_type_id PK of record being inserted or updated.
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
Procedure chk_shared_type_id(p_shared_type_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_shared_type_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_sht_shd.api_updating
    (p_shared_type_id                => p_shared_type_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_shared_type_id,hr_api.g_number)
     <>  per_sht_shd.g_old_rec.shared_type_id) then
    --
    -- raise error as PK has changed
    --
    per_sht_shd.constraint_error('PER_SHARED_TYPES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_shared_type_id is not null then
      --
      -- raise error as PK is not null
      --
      per_sht_shd.constraint_error('PER_SHARED_TYPES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_shared_type_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_system_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   shared_type_id PK of record being inserted or updated.
--   system_type_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_system_type_cd(p_shared_type_id                in number,
                            p_lookup_type                  in varchar2,
                            p_system_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_system_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_sht_shd.api_updating
    (p_shared_type_id                => p_shared_type_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_system_type_cd
      <> nvl(per_sht_shd.g_old_rec.system_type_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => p_lookup_type,
           p_lookup_code    => p_system_type_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_system_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_duplicate_key >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the key combination is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   shared_type_id PK of record being inserted or updated.
--   system_type_cd Value of lookup code.
--   shared_type_code  developer key
--   lookup_type
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_duplicate_key(p_shared_type_id              in number,
                            p_lookup_type                 in varchar2,
                            p_system_type_cd              in varchar2,
                            p_shared_type_code            in varchar2,
                            p_business_group_id           in number,
                            p_shared_type_name            in Varchar2 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_key';
  l_shared_type_id number;
  l_lookup_code hr_lookups.lookup_code%TYPE;
  --
  -- Fix for bug 3478716. added upper for shared_type_name in the following cursor.
  --
  cursor c1 is select shared_type_id
                 from per_shared_types
                where lookup_type      = p_lookup_type
                  and system_type_cd   = p_system_type_cd
                  and shared_type_code = p_shared_type_code
                  and upper(Shared_type_name) = upper(p_shared_type_name)
                  AND ((business_group_id = p_business_group_id)
				      OR (business_group_id IS NULL)
					  OR (p_business_group_id IS NULL));
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('value of shared_type_id:'||p_shared_type_id, 5);
  hr_utility.set_location('value of shared_type_code:'||p_shared_type_code, 5);
  hr_utility.set_location('value of system_type_cd:'||p_system_type_cd, 5);
  hr_utility.set_location('value of lookup_type:'||p_lookup_type, 5);
  hr_utility.set_location('value of shared_type_name:'||p_shared_type_name, 5);
  hr_utility.set_location('value of business_group_id:'||p_business_group_id, 5);
  --
  open c1;
  fetch c1 into l_shared_type_id;
  if c1%found then
     -- key exists
     if p_shared_type_id is null
        or (p_shared_type_id is not null and p_shared_type_id <> l_shared_type_id) then
        close c1;
        select hr_general.decode_lookup(p_lookup_type,p_system_type_cd) into l_lookup_code from dual;
        -- different record is being updated inserted with same key, raise error.
        hr_utility.set_message(800,'PER_SHARE_TYPE_KEY_EXISTS');
        hr_utility.set_message_token('LOOKUP_TYPE',p_lookup_type);
        hr_utility.set_message_token('SHARED_TYPE_CODE',p_shared_type_code);
        hr_utility.set_message_token('LOOKUP_CODE',l_lookup_code);
        hr_utility.raise_error;
        --
     end if;
  end if;
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_duplicate_key;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_sht_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_shared_type_id
  (p_shared_type_id          => p_rec.shared_type_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_system_type_cd
  (p_shared_type_id          => p_rec.shared_type_id,
   p_lookup_type            => p_rec.lookup_type,
   p_system_type_cd         => p_rec.system_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_key(p_shared_type_id   => p_rec.shared_type_id,
                    p_lookup_type      => p_rec.lookup_type,
                    p_system_type_cd   => p_rec.system_type_cd,
                    p_shared_type_code => p_rec.shared_type_code,
                    p_shared_type_name => p_rec.shared_type_name,
                    p_business_group_id => p_rec.business_group_id);
  --
  -- hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_sht_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_shared_type_id
  (p_shared_type_id          => p_rec.shared_type_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_system_type_cd
  (p_shared_type_id          => p_rec.shared_type_id,
   p_lookup_type            => p_rec.lookup_type,
   p_system_type_cd         => p_rec.system_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_key(p_shared_type_id   => p_rec.shared_type_id,
                    p_lookup_type      => p_rec.lookup_type,
                    p_system_type_cd   => p_rec.system_type_cd,
                    p_shared_type_code => p_rec.shared_type_code,
                    p_shared_type_name => p_rec.shared_type_name,
                    p_business_group_id => p_rec.business_group_id);
  --
  -- hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_sht_shd.g_rec_type
                         ,p_effective_date in date) is
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
  (p_shared_type_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           per_shared_types b
    where b.shared_type_id      = p_shared_type_id
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
                             p_argument       => 'shared_type_id',
                             p_argument_value => p_shared_type_id);
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
end per_sht_bus;

/
