--------------------------------------------------------
--  DDL for Package Body PQH_DST_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DST_BUS" as
/* $Header: pqdstrhi.pkb 115.6 2002/12/05 19:32:00 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_dst_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_budget_set_id >------|
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
--   dflt_budget_set_id PK of record being inserted or updated.
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
Procedure chk_dflt_budget_set_id(p_dflt_budget_set_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_budget_set_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_dst_shd.api_updating
    (p_dflt_budget_set_id                => p_dflt_budget_set_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_budget_set_id,hr_api.g_number)
     <>  pqh_dst_shd.g_old_rec.dflt_budget_set_id) then
    --
    -- raise error as PK has changed
    --
    pqh_dst_shd.constraint_error('PQH_DFLT_BUDGET_SETS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_dflt_budget_set_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_dst_shd.constraint_error('PQH_DFLT_BUDGET_SETS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dflt_budget_set_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_budget_set_name >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_budget_set_name (p_dflt_budget_set_id                in number,
                            p_dflt_budget_set_name               in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_set_name';
  --
l_dummy   varchar2(1) ;

 cursor csr_budget_set_name is
 select 'X'
 from pqh_dflt_budget_sets
 where dflt_budget_set_name = p_dflt_budget_set_name
   and dflt_budget_set_id <> nvl(p_dflt_budget_set_id,0);

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_budget_set_name;
   fetch csr_budget_set_name into l_dummy;
  close csr_budget_set_name;

    if nvl(l_dummy ,'Y') = 'X' then
      --
       hr_utility.set_message(8302,'PQH_DUPLICATE_BUDGET_SET_NAME');
       hr_utility.raise_error;
      --
    end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_set_name;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_dst_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dflt_budget_set_id
  (p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_set_name
  (p_dflt_budget_set_id      => p_rec.dflt_budget_set_id,
   p_dflt_budget_set_name    => p_rec.dflt_budget_set_name);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_dst_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dflt_budget_set_id
  (p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_set_name
  (p_dflt_budget_set_id      => p_rec.dflt_budget_set_id,
   p_dflt_budget_set_name    => p_rec.dflt_budget_set_name);
  --

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_dst_shd.g_rec_type) is
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
  (p_dflt_budget_set_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pqh_dflt_budget_sets b
    where b.dflt_budget_set_id      = p_dflt_budget_set_id
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
                             p_argument       => 'dflt_budget_set_id',
                             p_argument_value => p_dflt_budget_set_id);
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
end pqh_dst_bus;

/
