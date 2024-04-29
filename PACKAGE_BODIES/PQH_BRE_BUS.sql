--------------------------------------------------------
--  DDL for Package Body PQH_BRE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BRE_BUS" as
/* $Header: pqbrerhi.pkb 115.6 2003/06/04 08:19:51 ggnanagu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_bre_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_reallocation_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pool_id                      in number
  ,p_transaction_type             in varchar2
  ,p_txn_detail_id               in number
  ,p_associated_column1           in varchar2
  ) is
  --
  -- Declare cursor
  --
  cursor csr_trnx_dtl_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_budget_pools bpl
     where bpl.pool_id = p_pool_id
       and pbg.business_group_id = bpl.business_group_id;

  cursor csr_trnx_amt_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_bdgt_pool_realloctions  bre
         , pqh_budget_pools bpl
     where bre.reallocation_id = p_txn_detail_id
       and bre.pool_id = bpl.pool_id
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
      ,p_argument           => 'transaction_type'
      ,p_argument_value     => p_transaction_type );
  if p_transaction_type IN ('D','R') then
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'pool_id'
      ,p_argument_value     => p_pool_id
      );
   elsif p_transaction_type IN ('DD','RD') then
    hr_api.mandatory_arg_error
    (p_api_name  => l_proc
    ,p_argument => 'txn_detail_id'
    ,p_argument_value => p_txn_detail_id);
   end if;
  --
  if p_transaction_type IN ('D','R') then
    open csr_trnx_dtl_sec_grp;
    fetch csr_trnx_dtl_sec_grp into l_security_group_id;
    --
    if csr_trnx_dtl_sec_grp%notfound then
       --
       close csr_trnx_dtl_sec_grp;
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
      close csr_trnx_dtl_sec_grp;
      --
      -- Set the security_group_id in CLIENT_INFO
      --
      hr_api.set_security_group_id
        (p_security_group_id => l_security_group_id
        );
    end if;
  elsif p_transaction_type IN ('DD','RD') then
    open csr_trnx_amt_sec_grp;
    fetch csr_trnx_amt_sec_grp into l_security_group_id;
    --
    if csr_trnx_amt_sec_grp%notfound then
       --
       close csr_trnx_amt_sec_grp;
       --
       -- The primary key is invalid therefore we must error
       --
       fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
       hr_multi_message.add
         (p_associated_column1
          => nvl(p_associated_column1,'txn_detail_id')
         );
       --
    else
      close csr_trnx_amt_sec_grp;
      --
      -- Set the security_group_id in CLIENT_INFO
      --
      hr_api.set_security_group_id
        (p_security_group_id => l_security_group_id
        );
    end if;
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
  (p_reallocation_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_bdgt_pool_realloctions bre
         , pqh_budget_pools bpl
     where bre.reallocation_id = p_reallocation_id
       and ( (bre.transaction_type in ('D','R')
              and bre.pool_id = bpl.pool_id)
            OR (bre.transaction_type in ('DD','RD')
                and bpl.pool_id = (select txn_detail_id
                                   from pqh_bdgt_pool_realloctions
                                   where reallocation_id = p_reallocation_id)) )
       and pbg.business_group_id = bpl.business_group_id;
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
    ,p_argument           => 'reallocation_id'
    ,p_argument_value     => p_reallocation_id
    );
  --
  if ( nvl(pqh_bre_bus.g_reallocation_id, hr_api.g_number)
       = p_reallocation_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_bre_bus.g_legislation_code;
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
    pqh_bre_bus.g_reallocation_id             := p_reallocation_id;
    pqh_bre_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_bre_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_bre_shd.api_updating
      (p_reallocation_id                   => p_rec.reallocation_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  --           not been updated.
  --
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_reallocation_id >------|
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
--   reallocation_id PK of record being inserted or updated.
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
Procedure chk_reallocation_id(p_reallocation_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reallocation_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bre_shd.api_updating
    (p_reallocation_id                => p_reallocation_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_reallocation_id,hr_api.g_number)
     <>  pqh_bre_shd.g_old_rec.reallocation_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bre_shd.constraint_error('PQH_BDGT_POOL_REALLOCTIONS');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_reallocation_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bre_shd.constraint_error('PQH_BDGT_POOL_REALLOCTIONS');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_reallocation_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pool_id >------|
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
--   p_reallocation_id PK
--   p_pool_id ID of FK column
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
Procedure chk_pool_id (p_reallocation_id          in number,
                            p_pool_id          in number default null,
                          p_transaction_type in varchar2,
                          p_txn_detail_id in number default null,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pool_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_budget_pools a
    where  a.pool_id = p_pool_id;
  --
  cursor c2 is
    select null
    from   pqh_bdgt_pool_realloctions a
    where  a.reallocation_id = p_txn_detail_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  IF p_transaction_type IN ('D', 'R') THEN
  IF p_pool_id IS NOT NULL THEN
  l_api_updating := pqh_bre_shd.api_updating
     (p_reallocation_id            => p_reallocation_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pool_id,hr_api.g_number)
     <> nvl(pqh_bre_shd.g_old_rec.pool_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if pool_id value exists in pqh_budget_pools table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budget_pools
        -- table.
        --
        pqh_bre_shd.constraint_error('PQH_BDGT_POOL_REALLOCTIONS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  END IF;
  --
  END IF;
  --
  IF p_transaction_type IN ('DD', 'RD') THEN
  IF p_txn_detail_id IS NOT NULL THEN
  l_api_updating := pqh_bre_shd.api_updating
     (p_reallocation_id            => p_reallocation_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_txn_detail_id,hr_api.g_number)
     <> nvl(pqh_bre_shd.g_old_rec.txn_detail_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if txn_detail_id value exists in pqh_bdgt_pool_realloctions table
    --
    open c2;
      --
      fetch c2 into l_dummy;
      if c2%notfound then
        --
        close c2;
        --
        -- raise error as FK does not relate to PK in pqh_bdgt_pool_realloctions
        -- table.
        --
        pqh_bre_shd.constraint_error('PQH_BDGT_POOL_REALLOCTIONS_FK1');
        --
      end if;
      --
    close c2;
    --
  end if;
  END IF;
  --
  END IF;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pool_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_amount >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_period_amount(p_reallocation_id IN number,
                            p_object_version_number IN number,
                            p_transaction_type IN varchar2,
                            p_reallocation_amt  IN NUMBER,
                            p_reserved_amt IN number) IS
--
  l_proc  varchar2(72) := g_package||'chk_period_amount';
  l_api_updating boolean;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pqh_bre_shd.api_updating
     (p_reallocation_id            => p_reallocation_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_reserved_amt,hr_api.g_number)
     <> nvl(pqh_bre_shd.g_old_rec.reserved_amt,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if  reserved_amt is greater than 0.
    --
    If p_reserved_amt <  0 then
       hr_utility.set_message(8302,'PQH_BGT_REALLOC_DONOR_RES_NEG');
       hr_utility.raise_error;
    End if;
    If p_reallocation_amt < 0 THEN
    	hr_utility.set_message(8302,'PQH_BGT_REALLOC_DONOR_REA_NEG');
    	hr_utility.raise_error;
    End if;

  END IF;
    --
  IF p_transaction_type = 'DD' THEN
     IF NVL(p_reallocation_amt,0) <= 0  AND NVL(p_reserved_amt,0) <= 0  THEN
        hr_utility.set_message(8302,'PQH_BGT_DNR_PRD_AMOUNT');
        hr_utility.raise_error;
     END IF;
  END IF;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_period_amount;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- pqh_bre_bus.set_security_group_id procedure
  --
  pqh_bre_bus.set_security_group_id(p_rec.pool_id,
                                    p_rec.transaction_type,
                                    p_rec.txn_detail_id);
  --
  -- Call all supporting business operations
  --
  --
  chk_reallocation_id
  (p_reallocation_id          => p_rec.reallocation_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pool_id
  (p_reallocation_id          => p_rec.reallocation_id,
   p_pool_id          => p_rec.pool_id,
   p_transaction_type => p_rec.transaction_type,
   p_txn_detail_id => p_rec.txn_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_period_amount
  (p_reallocation_id          => p_rec.reallocation_id,
   p_transaction_type         => p_rec.transaction_type,
   p_reserved_amt             => p_rec.reserved_amt,
   p_reallocation_amt         => p_rec.reallocation_amt,
   p_object_version_number    => p_rec.object_version_number);
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
  ,p_rec                          in pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_reallocation_id
  (p_reallocation_id          => p_rec.reallocation_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_pool_id
  (p_reallocation_id          => p_rec.reallocation_id,
   p_pool_id          => p_rec.pool_id,
   p_transaction_type => p_rec.transaction_type,
   p_txn_detail_id => p_rec.txn_detail_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_period_amount
  (p_reallocation_id          => p_rec.reallocation_id,
   p_transaction_type         => p_rec.transaction_type,
   p_reserved_amt             => p_rec.reserved_amt,
   p_reallocation_amt         => p_rec.reallocation_amt,
   p_object_version_number    => p_rec.object_version_number);
  --
  pqh_bre_bus.set_security_group_id(p_rec.pool_id,
                                    p_rec.transaction_type,
                                    p_rec.txn_detail_id);
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
  (p_rec                          in pqh_bre_shd.g_rec_type
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
end pqh_bre_bus;

/
