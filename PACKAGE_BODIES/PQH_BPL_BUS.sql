--------------------------------------------------------
--  DDL for Package Body PQH_BPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BPL_BUS" as
/* $Header: pqbplrhi.pkb 115.9 2003/04/11 11:44:23 mvankada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_bpl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pool_id                     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pool_id                              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_budget_pools bpl
     where bpl.pool_id = p_pool_id
       and pbg.business_group_id = bpl.business_group_id;
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
    ,p_argument           => 'pool_id'
    ,p_argument_value     => p_pool_id
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
        => nvl(p_associated_column1,'POOL_ID')
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
  (p_pool_id                              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_budget_pools bpl
     where bpl.pool_id = p_pool_id
       and pbg.business_group_id (+) = bpl.business_group_id;
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
    ,p_argument           => 'pool_id'
    ,p_argument_value     => p_pool_id
    );
  --
  if ( nvl(pqh_bpl_bus.g_pool_id, hr_api.g_number)
       = p_pool_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_bpl_bus.g_legislation_code;
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
    pqh_bpl_bus.g_pool_id                     := p_pool_id;
    pqh_bpl_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_bpl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_bpl_shd.api_updating
      (p_pool_id                           => p_rec.pool_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pool_id >------|
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
--   pool_id PK of record being inserted or updated.
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
Procedure chk_pool_id(p_pool_id                in number,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pool_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bpl_shd.api_updating
    (p_pool_id                => p_pool_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pool_id,hr_api.g_number)
     <>  pqh_bpl_shd.g_old_rec.pool_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bpl_shd.constraint_error('PQH_BUDGET_POOLS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pool_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bpl_shd.constraint_error('PQH_BUDGET_POOLS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pool_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_version_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pool_id PK
--   p_budget_version_id ID of FK column
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
Procedure chk_budget_version_id
                           (p_pool_id               in number,
                            p_budget_version_id     in number,
                            p_object_version_number in number) is
--
  l_proc         varchar2(72) := g_package||'chk_budget_version_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_budgeted_entity_cd pqh_budgets.budgeted_entity_cd%type;
--
cursor c1 is
    select a.budgeted_entity_cd
    from   pqh_budgets a
    where  a.budget_id = (Select budget_id
                         From pqh_budget_versions bvr
                         where bvr.budget_version_id = p_budget_version_id);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bpl_shd.api_updating
     (p_pool_id            => p_pool_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_version_id,hr_api.g_number)
     <> nvl(pqh_bpl_shd.g_old_rec.budget_version_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if budget_version_id value exists in pqh_budgets table
    --
    open c1;
      --
      fetch c1 into l_budgeted_entity_cd;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budgets
        -- table.
        --
        pqh_bpl_shd.constraint_error('PQH_BUDGET_POOLS_FK1');
        --
      end if;
      --
    close c1;
/*kgowripe
    As per the latest reallocation functionality, reallocation can be performed for
    all budget entities (except OPEN budgets). so this check is no longer required.
    Instead we need to check that budgeted entity is not OPEN.

    --
    -- Check if the budget is budgeted for a position
    --
    If l_budgeted_entity_cd <> 'POSITION' then
      --
      -- raise error as budgeted entity is not a position
      --
      hr_utility.set_message(8302,'PQH_NOT_A_POSITION_BUDGET');
      hr_utility.raise_error;
      --
    End if;
    --
kgowripe */
    --
    -- Check if the budget is not budgeted for OPEN
    --
    If l_budgeted_entity_cd = 'OPEN' then
      --
      -- raise error as budgeted entity is OPEN
      --
      hr_utility.set_message(8302,'PQH_OPEN_BUDGET');
      hr_utility.raise_error;
      --
    End if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_version_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_unit_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pool_id PK of record being inserted or updated.
--   budget_unit_id Value of lookup code.
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
Procedure chk_budget_unit_id(p_pool_id                in number,
                             p_budget_version_id      in varchar2,
                            p_budget_unit_id              in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  -- Check if this is a valid shared type
  --
  Cursor c1 is
   Select null
     from per_shared_types pst
    where pst.shared_type_id = p_budget_unit_id
      AND  lookup_type = 'BUDGET_MEASUREMENT_TYPE';
  --
  -- Check if the budget unit id belongs to the budget.
  --
  Cursor c2 is
     Select null
      from pqh_budgets bgt
      Where bgt.budget_id = (Select budget_id
                               From pqh_budget_versions bvr
                              Where bvr.budget_version_id = p_budget_version_id)
     and (bgt.budget_unit1_id = p_budget_unit_id or
          bgt.budget_unit2_id = p_budget_unit_id or
          bgt.budget_unit3_id = p_budget_unit_id );
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bpl_shd.api_updating
    (p_pool_id                => p_pool_id,
     p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_unit_id
      <> nvl(pqh_bpl_shd.g_old_rec.budget_unit_id,hr_api.g_number)
      or not l_api_updating) then
    --
    -- check if value of budget_unit falls within per shared types
    --
    Open c1;
    --
    Fetch c1 into l_dummy;
    --
    If c1%notfound then
       --
       Close c1;
       hr_utility.set_message(8302,'PQH_INVALID_BUDGET_UOM');
       hr_utility.raise_error;
       --
    End if;
    --
    Close c1;
    --
    --
    Open c2;
    --
    Fetch c2 into l_dummy;
    --
    If c2%notfound then
       --
       -- Raise error if the budget unit cd does not exist for the budget
       --
       Close c2;
       hr_utility.set_message(8302,'PQH_INVALID_BUDGET_UNIT');
       hr_utility.raise_error;
       --
    End if;
    --
    Close c2;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_unit_id;
--
--   ADDITIONAL CHECKS
--
--   Check if any transactions/details exist for the folder/transaction.
--  Raise error if trying to update this folder/transaction
--
Procedure chk_upd_allowed(p_pool_id                in number,
                          p_parent_pool_id       in number,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upd_allowed';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  Cursor csr_folder_trnxs IS
  select null
  from   pqh_budget_pools
  where  parent_pool_id = p_pool_id;
  Cursor csr_trnx_dtls is
  Select null
  from   pqh_bdgt_pool_realloctions a
  Where  a.pool_id = p_pool_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bpl_shd.api_updating
    (p_pool_id                => p_pool_id,
     p_object_version_number  => p_object_version_number);
  --
  if l_api_updating then
    --
   if p_parent_pool_id IS NULL then
     Open csr_folder_trnxs;
     Fetch csr_folder_trnxs into l_dummy;
     if csr_folder_trnxs%found then
        Close csr_folder_trnxs;
        hr_utility.set_message(8302,'PQH_TRNX_EXIST_IN_FOLDER');
        hr_utility.raise_error;
     End if;
     Close csr_folder_trnxs;
   else
     Open csr_trnx_dtls;
     Fetch csr_trnx_dtls into l_dummy;
     if csr_trnx_dtls%found then
        Close csr_trnx_dtls;
        hr_utility.set_message(8302,'PQH_DTLS_EXIST_FOR_TRNX');
        hr_utility.raise_error;
     End if;
     Close csr_trnx_dtls;
   end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_upd_allowed;
--
-- Check if folder_name is unique in pqh_budget_pools_table
-- Also, Raise error if the entered folder_name is null.
--
Procedure chk_pool_name(p_pool_id                in number,
                        p_name              in varchar2,
                        p_parent_pool_id  in number,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pool_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
-- added approval_status<>'T' condition by mvanakda
  Cursor csr_folder_name is
  Select null
  from   pqh_budget_pools a
  Where  a.name = p_name
   AND   a.parent_pool_id IS NULL
    AND  (p_pool_id IS NULL or a.pool_id <> p_pool_id)
AND a.approval_status<>'T';
  Cursor csr_trnx_name is
  Select null
  from   pqh_budget_pools a
  Where  a.name = p_name
   AND   a.parent_pool_id IS NOT NULL
   AND   a.parent_pool_id =p_parent_pool_id
   AND  (p_pool_id IS NULL or a.pool_id <> p_pool_id);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bpl_shd.api_updating
    (p_pool_id                => p_pool_id,
     p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_name
      <> nvl(pqh_bpl_shd.g_old_rec.name,hr_api.g_varchar2)
      or not l_api_updating) then

      If p_name IS NULL then
        If p_parent_pool_id IS NULL Then
           hr_utility.set_message(8302,'PQH_FOLDER_NAME_IS_NULL');
        Else
           hr_utility.set_message(8302,'PQH_TRNX_NAME_IS_NULL');
        End If;
        hr_utility.raise_error;
      End if;
     --
     --
     If p_parent_pool_id IS NULL Then
       Open csr_folder_name;
       Fetch csr_folder_name into l_dummy;
       if csr_folder_name%found then
          Close csr_folder_name;
          hr_utility.set_message(8302,'PQH_FOLDER_NAME_MUST_BE_UNIQUE');
          hr_utility.raise_error;
       End if;
       Close csr_folder_name;
     ELSE
       Open csr_trnx_name;
       Fetch csr_trnx_name into l_dummy;
       if csr_trnx_name%found then
          Close csr_trnx_name;
          hr_utility.set_message(8302,'PQH_TRNX_NAME_MUST_BE_UNIQUE');
          hr_utility.raise_error;
       End if;
       Close csr_trnx_name;
     End If;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pool_name;
/* No longer required as there cane be any number of folders created from a budget
--
-- Check if there is only one pool per budget_unit_id for a budget
--
Procedure chk_budget_pool_unique
                       (p_pool_id                in number,
                        p_budget_version_id      in number,
                        p_budget_unit_id         in number,
                        p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_pool_unique';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  Cursor c1 is
  Select null
  from   pqh_budget_pools a
  Where  budget_version_id = p_budget_version_id
    AND  budget_unit_id = p_budget_unit_id
    AND  (p_pool_id IS NULL or a.pool_id <> p_pool_id);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bpl_shd.api_updating
    (p_pool_id                => p_pool_id,
     p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_budget_version_id,hr_api.g_number)
      <> nvl(pqh_bpl_shd.g_old_rec.budget_version_id,hr_api.g_number)
      or p_budget_unit_id
      <> nvl(pqh_bpl_shd.g_old_rec.budget_unit_id,hr_api.g_number) )
      or not l_api_updating) then
    --
    --
     Open c1;
     --
     Fetch c1 into l_dummy;
     --
     if c1%found then

        Close c1;
        pqh_bpl_shd.constraint_error('PQH_BUDGET_POOLS_U1');

     End if;
    --
     Close c1;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_budget_pool_unique;

*/
PROCEDURE chk_tnx_category_id(p_transaction_category_id IN Number) IS

Cursor csr_tnx_catg_id IS
  SELECT 'x'
  FROM   pqh_transaction_categories
  WHERE  transaction_category_id = p_transaction_category_id;
 l_exist Varchar2(10);
 l_proc  varchar2(72) := g_package||'chk_tnx_category_id';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN csr_tnx_catg_id;
  FETCH csr_tnx_catg_id INTO l_exist;
  IF csr_tnx_catg_id%NOTFOUND THEN
   CLOSE csr_tnx_catg_id;
   fnd_message.set_name(8302,'PQH_INVALID_TNX_CATG');
   fnd_message.raise_error;
  END IF;
  CLOSE csr_tnx_catg_id;
  hr_utility.set_location('Leaving:'||l_proc, 10);
END chk_tnx_category_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_bpl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_bpl_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
 chk_pool_id
  (p_pool_id               => p_rec.pool_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  if p_rec.parent_pool_id IS NULL then
    chk_budget_version_id
    (p_pool_id               => p_rec.pool_id,
     p_budget_version_id     => p_rec.budget_version_id,
     p_object_version_number => p_rec.object_version_number);
  --
    chk_budget_unit_id
    (p_pool_id               => p_rec.pool_id,
     p_budget_version_id     => p_rec.budget_version_id,
     p_budget_unit_id        => p_rec.budget_unit_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
   chk_tnx_category_id(p_transaction_category_id => p_rec.wf_transaction_category_id);
  --
   end if;
  --
  chk_pool_name
  (p_pool_id               => p_rec.pool_id,
   p_name                  => p_rec.name,
   p_parent_pool_id      => p_rec.parent_pool_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_bpl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_bpl_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  chk_pool_id
  (p_pool_id          => p_rec.pool_id,
   p_object_version_number => p_rec.object_version_number);
  --
/* Should allow updating folders to mark the same as approved/rejected
  chk_upd_allowed
  (p_pool_id               => p_rec.pool_id,
   p_parent_pool_id      => p_rec.parent_pool_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  if p_rec.parent_pool_id is null then
    chk_budget_version_id
    (p_pool_id          => p_rec.pool_id,
     p_budget_version_id     => p_rec.budget_version_id,
     p_object_version_number => p_rec.object_version_number);
  --
    chk_budget_unit_id
    (p_pool_id               => p_rec.pool_id,
     p_budget_version_id     => p_rec.budget_version_id,
     p_budget_unit_id        => p_rec.budget_unit_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
   chk_tnx_category_id(p_transaction_category_id => p_rec.wf_transaction_category_id);
  --
  end if;
  --
  chk_pool_name
  (p_pool_id               => p_rec.pool_id,
   p_name                  => p_rec.name,
   p_parent_pool_id      => p_rec.parent_pool_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_bpl_shd.g_rec_type
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
end pqh_bpl_bus;

/
