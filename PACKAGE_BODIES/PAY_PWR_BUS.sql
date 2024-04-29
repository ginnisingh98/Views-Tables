--------------------------------------------------------
--  DDL for Package Body PAY_PWR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PWR_BUS" as
/* $Header: pypwrrhi.pkb 115.2 2002/12/05 15:39:29 swinton noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pwr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_rate_id >------|
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
--   rate_id PK of record being inserted or updated.
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
Procedure chk_rate_id(p_rate_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rate_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_pwr_shd.api_updating
    (p_rate_id                => p_rate_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rate_id,hr_api.g_number)
     <>  pay_pwr_shd.g_old_rec.rate_id) then
    --
    -- raise error as PK has changed
    --
    pay_pwr_shd.constraint_error('PAY_WCI_RATES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_rate_id is not null then
      --
      -- raise error as PK is not null
      --
      pay_pwr_shd.constraint_error('PAY_WCI_RATES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rate_id;
--
-- ----------------------------------------------------------------------------
--|----------------------------<chk_rate_code>--------------------------------|
-- ----------------------------------------------------------------------------
-- Description : This function is used to validate a new Rate Code (just code in
--               the table pay_wci_rates.
-- Validation  : A rate code must be unique within an Account Number.
-- On Failure  : Raise message 'The Rate Code you have entered already exists
--               within the current Account Number. Enter a different Rate
--               Code.
-- ----------------------------------------------------------------------------
FUNCTION chk_valid_rate_code (p_rate_code         in varchar2
                             ,p_account_id        in number
                             ,p_business_group_id in number)
RETURN BOOLEAN IS
--
CURSOR get_rate_code (p_rate_code         varchar2
                     ,p_account_id        number
                     ,p_business_group_id number)
IS
SELECT code
FROM   pay_wci_rates
WHERE  code = p_rate_code
AND    account_id = p_account_id
AND    business_group_id = p_business_group_id;
--
l_proc  	varchar2(72) := g_package||'chk_rate_code';
l_exists 	varchar2(30);
v_return_value  boolean;
--
BEGIN
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
OPEN  get_rate_code (p_rate_code, p_account_id, p_business_group_id);
FETCH get_rate_code INTO l_exists;
--
  IF get_rate_code%NOTFOUND THEN
  --
    hr_utility.set_location('Returning TRUE: '||l_proc, 10);
    v_return_value := TRUE;
    --
  ELSE
  --
    hr_utility.set_location('Returning FALSE: '||l_proc, 15);
    v_return_value := FALSE;
    --
  END IF;
  --
CLOSE get_rate_code;
--
RETURN v_return_value;
--
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_valid_rate_code;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_pwr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_rate_id
  (p_rate_id          => p_rec.rate_id,
   p_object_version_number => p_rec.object_version_number);
  --
  IF NOT chk_valid_rate_code (p_rate_code         => p_rec.code
                             ,p_account_id        => p_rec.account_id
                             ,p_business_group_id => p_rec.business_group_id)
  THEN
  --
    hr_utility.set_message(801, 'PAY_74035_DUPLICATE_RATE_CODE');
    hr_utility.raise_error;
    --
  ELSE
  --
    hr_utility.trace('Valid Rate Code');
    --
  END IF;
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_pwr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_rate_id
  (p_rate_id          => p_rec.rate_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_pwr_shd.g_rec_type) is
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
  (p_rate_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_wci_rates b
    where b.rate_id      = p_rate_id
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
                             p_argument       => 'rate_id',
                             p_argument_value => p_rate_id);
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
end pay_pwr_bus;

/
