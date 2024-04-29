--------------------------------------------------------
--  DDL for Package Body PAY_PMA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PMA_BUS" as
/* $Header: pypmarhi.pkb 115.2 2002/12/11 11:12:57 ssivasu2 noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pma_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_source_id >------|
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
--   source_id PK of record being inserted or updated.
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
Procedure chk_source_id(p_source_id                in number,
                        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_source_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_pma_shd.api_updating
    (p_source_id                => p_source_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_source_id,hr_api.g_number)
     <>  pay_pma_shd.g_old_rec.source_id) then
    --
    -- raise error as PK has changed
    --
    pay_pma_shd.constraint_error('PAY_CA_PMED_ACCOUNTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_source_id is not null then
      --
      -- raise error as PK is not null
      --
      pay_pma_shd.constraint_error('PAY_CA_PMED_ACCOUNTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_source_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_organization_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table. It also checks that the Organization is a
--   valid Provincial Medical Carrier.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_source_id PK
--   p_organization_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_organization_id (p_source_id          in number,
                            p_organization_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_organization_id;
  --
  cursor c2 (p_org_id NUMBER) is
    select null
    from   hr_organization_information ogi
    where  ogi.organization_id         = p_org_id
    and    ogi.org_information1        = 'CA_PMED'
    and    ogi.org_information_context = 'CLASS'
    and    ogi.org_information2        = 'Y';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pay_pma_shd.api_updating
     (p_source_id            => p_source_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(pay_pma_shd.g_old_rec.organization_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if organization_id value exists in hr_all_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        pay_pma_shd.constraint_error('PAY_CA_PMED_ACCOUNTS_FK1');
        --
      end if;
      --
    close c1;
    --
    open c2(p_organization_id);
    fetch c2 into l_dummy;
    if c2%notfound then
      close c2;
      hr_utility.set_message(800,'PAY_74031_NOT_PMED_CARRIER');
      hr_utility.raise_error;
    end if;
    close c2;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_account_number >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Descriiption :
--    This check procedure ensures that the account number is unique within
--    organization.
--
--  Pre-conditions :
--    p_organization_id is valid
--
--  In Arguments :
--    p_source_id
--    p_object_version_number
--    p_organization_id
--    p_account_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_account_number
  (p_source_id             in pay_ca_pmed_accounts.source_id%TYPE
  ,p_object_version_number in pay_ca_pmed_accounts.object_version_number%TYPE
  ,p_organization_id       in pay_ca_pmed_accounts.organization_id%TYPE
  ,p_account_number        in pay_ca_pmed_accounts.account_number%TYPE
   )   is
--
  l_proc   varchar2(72) := g_package||'chk_account_number';
  l_api_updating boolean;
  l_dummy  NUMBER;
--
CURSOR csr_get_ac_num (p_org_id NUMBER,
                       p_ac_num VARCHAR2) IS
  SELECT 1
  FROM   pay_ca_pmed_accounts pma
  WHERE  pma.organization_id = p_org_id
  AND    pma.account_number  = p_ac_num;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  l_api_updating := pay_pma_shd.api_updating
     (p_source_id             => p_source_id,
      p_object_version_number => p_object_version_number);
  --
  if NOT l_api_updating THEN
    open csr_get_ac_num(p_organization_id,
                        p_account_number);
    fetch csr_get_ac_num INTO l_dummy;
    if csr_get_ac_num%FOUND THEN
      close csr_get_ac_num;
      hr_utility.set_message(800,'PAY_74032_AC_NO_NOT_UNIQUE');
      hr_utility.raise_error;
    end if;
    close csr_get_ac_num;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
end chk_account_number;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_enabled >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Descriiption :
--    This check procedure ensures that the ENABLED flag has a value of
--    either 'Y' or 'N'.
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_enabled
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_enabled
  (p_enabled                 in pay_ca_pmed_accounts.enabled%TYPE
   )   is
--
 l_proc   varchar2(72) := g_package||'chk_enabled';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  if (p_enabled <> 'Y' AND
      p_enabled <> 'N') THEN
    hr_utility.set_message(800,'HR_PAY_YES_NO');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_pma_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_source_id
  (p_source_id          => p_rec.source_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_source_id          => p_rec.source_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_account_number
  (p_source_id             => p_rec.source_id,
   p_object_version_number => p_rec.object_version_number,
   p_organization_id       => p_rec.organization_id,
   p_account_number        => p_rec.account_number);
  --
  chk_enabled
  (p_enabled            => p_rec.enabled);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_pma_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_source_id
  (p_source_id          => p_rec.source_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_source_id          => p_rec.source_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_account_number
  (p_source_id             => p_rec.source_id,
   p_object_version_number => p_rec.object_version_number,
   p_organization_id       => p_rec.organization_id,
   p_account_number        => p_rec.account_number);
  --
  chk_enabled
  (p_enabled            => p_rec.enabled);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_pma_shd.g_rec_type) is
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
  (p_source_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_ca_pmed_accounts b
    where b.source_id      = p_source_id
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
                             p_argument       => 'source_id',
                             p_argument_value => p_source_id);
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
end pay_pma_bus;

/
