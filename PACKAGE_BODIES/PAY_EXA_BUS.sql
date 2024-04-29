--------------------------------------------------------
--  DDL for Package Body PAY_EXA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EXA_BUS" AS
/* $Header: pyexarhi.pkb 115.13 2003/09/26 06:48:50 tvankayl ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_exa_bus.';  -- global package name
-- [start of change: 40.1, Dave Harris]
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_territory_code >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_territory_code(
   p_territory_code        in varchar2
  ,p_external_account_id   in number
  ,p_object_version_number in number
  ) is
  --
  cursor csr_chk_territory_code is
    SELECT 1
    FROM   FND_TERRITORIES_VL ft
    WHERE  ft.territory_code = p_territory_code
    ;
  --
  cursor csr_territory_code is
    SELECT territory_code
    FROM   PAY_EXTERNAL_ACCOUNTS pea
    WHERE  pea.external_account_id = p_external_account_id
    ;
  --
  l_proc     varchar2(72) := g_package||'chk_territory_code';
  -- stub - l_api_updating is redundant
  l_api_updating boolean;
  l_territory_code          pay_external_accounts.territory_code%type;
  l_dummy        number;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- true if PK exists, false if PK does not exist
  -- stub - not required
  --
  l_api_updating := pay_exa_shd.api_updating
                      (p_external_account_id   => p_external_account_id,
                       p_object_version_number => p_object_version_number);

  --
  -- should not be able to U territory_code on an existing combination,
  -- only set territory code if I'ing a fresh combination record,
  --
  open  csr_territory_code;
  fetch csr_territory_code into l_territory_code;
  close csr_territory_code;
  --
  -- new combination record,
  -- will be setting territory code onto it,
  -- therefore validate territory code,
  -- nb. territory code can be assumed to be not null as it is a mandatory
  --     parameter
  --
  if l_territory_code is null then
    hr_utility.trace('| fresh combination, validate territory_code');
    --
    hr_utility.set_location(l_proc, 10);
    --
    open csr_chk_territory_code;
    fetch csr_chk_territory_code into l_dummy;
    --
    if csr_chk_territory_code%notfound then
      close csr_chk_territory_code;
      hr_utility.set_message(801, 'HR_7727_EXA_TERR_CODE_INVALID');
      hr_utility.raise_error;
    end if;
    --
    close csr_chk_territory_code;
  --
  -- territory code exists, therefore using an existing combination record,
  -- check that territory code has not being changed
  --
  else
    hr_utility.trace('| old combination, chk territory_code is not mutating');
    if ( nvl(p_territory_code, hr_api.g_varchar2) <>
         nvl(pay_exa_shd.g_old_rec.territory_code, hr_api.g_varchar2) ) then
      hr_api.argument_changed_error(
        p_api_name => l_proc,
        p_argument => 'TERRITORY_CODE');
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
end chk_territory_code;
-- [end of change: 40.1, Dave Harris]
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
procedure insert_validate(
   p_rec               in pay_exa_shd.g_rec_type
  ,p_business_group_id in number
  ) is
  --
  l_proc  varchar2(72) := g_package||'insert_validate';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- [start of change: 40.1, Dave Harris]
  chk_territory_code(p_territory_code        => p_rec.territory_code,
                     p_external_account_id   => p_rec.external_account_id,
                     p_object_version_number => p_rec.object_version_number);
  -- [end of change: 40.1, Dave Harris]
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_validate(
   p_rec in pay_exa_shd.g_rec_type
   ) is
  --
  l_proc  varchar2(72) := g_package||'update_validate';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- [start of change: 40.1, Dave Harris]
  chk_territory_code(p_territory_code        => p_rec.territory_code,
                     p_external_account_id   => p_rec.external_account_id,
                     p_object_version_number => p_rec.object_version_number);
  --
  -- [end of change: 40.1, Dave Harris]
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end update_validate;
--
END pay_exa_bus;

/
