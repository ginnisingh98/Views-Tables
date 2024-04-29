--------------------------------------------------------
--  DDL for Package Body PQH_BCE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BCE_BUS" as
/* $Header: pqbcerhi.pkb 115.7 2004/04/28 17:17:08 rthiagar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bce_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_bdgt_cmmtmnt_elmnt_id >------|
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
--   bdgt_cmmtmnt_elmnt_id PK of record being inserted or updated.
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
Procedure chk_bdgt_cmmtmnt_elmnt_id(p_bdgt_cmmtmnt_elmnt_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bdgt_cmmtmnt_elmnt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bce_shd.api_updating
    (p_bdgt_cmmtmnt_elmnt_id                => p_bdgt_cmmtmnt_elmnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_bdgt_cmmtmnt_elmnt_id,hr_api.g_number)
     <>  pqh_bce_shd.g_old_rec.bdgt_cmmtmnt_elmnt_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bce_shd.constraint_error('PQH_BDGT_CMMTMNT_ELMNTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_bdgt_cmmtmnt_elmnt_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bce_shd.constraint_error('PQH_BDGT_CMMTMNT_ELMNTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_bdgt_cmmtmnt_elmnt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_elmnt_frequency >------|
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
--   p_bdgt_cmmtmnt_elmnt_id PK
--   p_dflt_elmnt_frequency ID of FK column
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
Procedure chk_dflt_elmnt_frequency (p_bdgt_cmmtmnt_elmnt_id          in number,
                            p_dflt_elmnt_frequency          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_elmnt_frequency';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_time_period_types a
    where  a.period_type = p_dflt_elmnt_frequency;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bce_shd.api_updating
    (p_bdgt_cmmtmnt_elmnt_id                => p_bdgt_cmmtmnt_elmnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_elmnt_frequency,hr_api.g_varchar2)
     <> nvl(pqh_bce_shd.g_old_rec.dflt_elmnt_frequency,hr_api.g_varchar2)
     or not l_api_updating) and
     p_dflt_elmnt_frequency is not null then
    --
    -- check if dflt_elmnt_frequency value exists in per_time_period_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_time_period_types
        -- table.
        --
        pqh_bce_shd.constraint_error('PQH_BDGT_CMMTMNT_ELMNTS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dflt_elmnt_frequency;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_id >------|
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
--   p_bdgt_cmmtmnt_elmnt_id PK
--   p_budget_id ID of FK column
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
Procedure chk_budget_id (p_bdgt_cmmtmnt_elmnt_id          in number,
                            p_budget_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_budgets a
    where  a.budget_id = p_budget_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bce_shd.api_updating
     (p_bdgt_cmmtmnt_elmnt_id            => p_bdgt_cmmtmnt_elmnt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_id,hr_api.g_number)
     <> nvl(pqh_bce_shd.g_old_rec.budget_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if budget_id value exists in pqh_budgets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budgets
        -- table.
        --
        pqh_bce_shd.constraint_error('PQH_BDGT_CMMTMNT_ELMNTS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_actual_commitment_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bdgt_cmmtmnt_elmnt_id PK of record being inserted or updated.
--   actual_commitment_type Value of lookup code.
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
Procedure chk_actual_commitment_type(p_bdgt_cmmtmnt_elmnt_id    in number,
                            p_actual_commitment_type            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_actual_commitment_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bce_shd.api_updating
    (p_bdgt_cmmtmnt_elmnt_id       => p_bdgt_cmmtmnt_elmnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_actual_commitment_type
      <> nvl(pqh_bce_shd.g_old_rec.actual_commitment_type,hr_api.g_varchar2)
      or not l_api_updating)
      and p_actual_commitment_type is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BDGT_CALC_TYPE',
           p_lookup_code    => p_actual_commitment_type,
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
end chk_actual_commitment_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_salary_basis_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bdgt_cmmtmnt_elmnt_id PK of record being inserted or updated.
--   salary_basis_flag Value of lookup code.
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
Procedure chk_salary_basis_flag(p_bdgt_cmmtmnt_elmnt_id                in number,
                            p_salary_basis_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_salary_basis_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bce_shd.api_updating
    (p_bdgt_cmmtmnt_elmnt_id                => p_bdgt_cmmtmnt_elmnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_salary_basis_flag
      <> nvl(pqh_bce_shd.g_old_rec.salary_basis_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_salary_basis_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_salary_basis_flag,
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
end chk_salary_basis_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_element_type_id >------|
-- ----------------------------------------------------------------------------
Procedure chk_element_type_id(p_element_type_id           in number,
                              p_bdgt_cmmtmnt_elmnt_id     in number,
                              p_budget_id                 in number,
                              p_actual_commitment_type    in varchar2,
                              p_object_version_number     in number) is
  --

  l_proc         varchar2(72) := g_package||'chk_element_type_id';
  l_api_updating boolean;
  --

cursor csr_element_ins is
select count(*)
from pqh_bdgt_cmmtmnt_elmnts
where budget_id = p_budget_id
  and element_type_id = p_element_type_id
  and (actual_commitment_type = 'BOTH' and p_actual_commitment_type in ('BOTH','COMMITMENT','ACTUAL')
  or (actual_commitment_type = 'COMMITMENT' and p_actual_commitment_type in ('BOTH','COMMITMENT'))
  or (actual_commitment_type = 'ACTUAL' and p_actual_commitment_type in ('BOTH','ACTUAL')));

cursor csr_element_upd is
select count(*)
from pqh_bdgt_cmmtmnt_elmnts
where budget_id = p_budget_id
  and element_type_id = p_element_type_id
  and bdgt_cmmtmnt_elmnt_id <> p_bdgt_cmmtmnt_elmnt_id
  and (actual_commitment_type = 'BOTH' and p_actual_commitment_type in ('BOTH','COMMITMENT','ACTUAL')
  or (actual_commitment_type = 'COMMITMENT' and p_actual_commitment_type in ('BOTH','COMMITMENT'))
  or (actual_commitment_type = 'ACTUAL' and p_actual_commitment_type in ('BOTH','ACTUAL')));

l_count   number(9) := 0;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_api_updating := pqh_bce_shd.api_updating
    (p_bdgt_cmmtmnt_elmnt_id      => p_bdgt_cmmtmnt_elmnt_id,
     p_object_version_number      => p_object_version_number);
  --

  IF p_element_type_id IS NULL THEN
          --
      -- raise error as element is null
      --
      hr_utility.set_message(8302,'PQH_BDGT_ELMNT_NULL');
      hr_utility.raise_error;
      --
  END IF;
    --
    -- check if the lement is repeated more then once
    --
  if l_api_updating then
       open csr_element_upd;
         fetch csr_element_upd into l_count;
       close csr_element_upd;

    if l_count <> 0 then
        -- raise error as element is null
        --
        hr_utility.set_message(8302,'PQH_BDGT_ELMNT_DUP');
        hr_utility.raise_error;
        --
    end if;
   --
  else
    -- new row is getting inserted
       open csr_element_ins;
         fetch csr_element_ins into l_count;
       close csr_element_ins;

    if l_count <> 0 then
        -- raise error as element is null
        --
        hr_utility.set_message(8302,'PQH_BDGT_ELMNT_DUP');
        hr_utility.raise_error;
        --
    end if;
   --

  end if; -- for api_updating

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_element_type_id ;
--
-- ----------------------------------------------------------------------------
-- |------< chk_input_values >------|
-- ----------------------------------------------------------------------------
Procedure chk_input_values(p_element_input_value_id           in number,
                           p_frequency_input_value_id           in number,
                           p_salary_basis_flag             in varchar2,
                           p_formula_id                    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_input_values';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

/* Commmented as element frequency is no longer inputted from the screen
  IF (p_element_input_value_id IS NULL AND p_frequency_input_value_id IS NOT NULL ) OR
     (p_element_input_value_id IS NOT NULL AND p_frequency_input_value_id IS NULL ) THEN
          --
      -- raise error as both are mutually inclusive
      --
      hr_utility.set_message(8302,'PQH_INPUT_VALUES_NULL');
      hr_utility.raise_error;
      --
  END IF;
*/
    --
    --
    --
   IF NVL(p_salary_basis_flag,'N') = 'N' AND
      p_element_input_value_id IS NULL   AND
      p_formula_id             IS NULL   THEN
      --
      -- atleast one of the three must be entered
      -- raise error
      --
      hr_utility.set_message(8302,'PQH_INVALID_CMMT_VALUES');
      hr_utility.raise_error;
      --
   END IF;
   -- only one basis must be entered, if more than one basis then report error
   if p_element_input_value_id is not null then
      if nvl(p_salary_basis_flag,'N') = 'Y' then
         hr_utility.set_message(8302,'PQH_MULTI_CMMT_VALUES');
         hr_utility.raise_error;
      elsif p_formula_id is not null then
         hr_utility.set_message(8302,'PQH_MULTI_CMMT_VALUES');
         hr_utility.raise_error;
      end if;
   end if;
   if p_formula_id is not null then
      if nvl(p_salary_basis_flag,'N') = 'Y' then
         hr_utility.set_message(8302,'PQH_MULTI_CMMT_VALUES');
         hr_utility.raise_error;
      elsif p_element_input_value_id is not null then
         hr_utility.set_message(8302,'PQH_MULTI_CMMT_VALUES');
         hr_utility.raise_error;
      end if;
   end if;

    --

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_input_values ;
--
-- ----------------------------------------------------------------------------
-- |------< chk_overhead_percentage >------|
-- ----------------------------------------------------------------------------
Procedure chk_overhead_percentage(p_overhead_percentage           in number ) is
  --
  l_proc         varchar2(72) := g_package||'chk_overhead_percentage';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  IF  NVL(p_overhead_percentage,0) < 0 THEN
          --
      -- raise error as overhead_percentage cannot be negative
      --
      hr_utility.set_message(8302,'PQH_INVALID_OVERHEAD_PER');
      hr_utility.raise_error;
      --
  END IF;
    --

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_overhead_percentage ;
--
-- ----------------------------------------------------------------------------
-- |------< chk_balance_type_id >------|
-- ----------------------------------------------------------------------------
Procedure chk_balance_type_id(p_balance_type_id           in number
                              ) is
  --

  l_proc         varchar2(72) := g_package||'chk_balance_type_id';
  l_api_updating boolean;
  --

cursor csr_balance is
select count(*) from pay_balance_feeds feed
where feed.balance_type_id = p_balance_type_id;

l_count   number(9) := 0;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  IF p_balance_type_id IS not NULL THEN
       open csr_balance;
         fetch csr_balance into l_count;
       close csr_balance;

    if l_count <> 0 then
        -- raise error as element is null
        --
        hr_utility.set_message(8302,'PQH_BDGT_ELMNT_DUP');
        hr_utility.set_warning;

        --
    end if;
   --

  end if; -- for api_updating

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_balance_type_id ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_bce_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_bdgt_cmmtmnt_elmnt_id
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_elmnt_frequency
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_dflt_elmnt_frequency          => p_rec.dflt_elmnt_frequency,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_id
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_actual_commitment_type
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_actual_commitment_type      => p_rec.actual_commitment_type,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_salary_basis_flag
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_salary_basis_flag         => p_rec.salary_basis_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_element_type_id
  (p_element_type_id     => p_rec.element_type_id,
   p_bdgt_cmmtmnt_elmnt_id     => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_budget_id                  => p_rec.budget_id,
   p_actual_commitment_type          =>  p_rec.actual_commitment_type,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_input_values
  (p_element_input_value_id    => p_rec.element_input_value_id,
   p_frequency_input_value_id  => p_rec.frequency_input_value_id,
   p_salary_basis_flag         => p_rec.salary_basis_flag,
   p_formula_id                => p_rec.formula_id);
  --
  chk_overhead_percentage
  (p_overhead_percentage     => p_rec.overhead_percentage );
  --
 /* chk_balance_type_id
  (p_balance_type_id        => p_rec.balance_type_id); */
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_bce_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_bdgt_cmmtmnt_elmnt_id
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_elmnt_frequency
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_dflt_elmnt_frequency          => p_rec.dflt_elmnt_frequency,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_id
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_actual_commitment_type
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_actual_commitment_type      => p_rec.actual_commitment_type,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_salary_basis_flag
  (p_bdgt_cmmtmnt_elmnt_id          => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_salary_basis_flag         => p_rec.salary_basis_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_element_type_id
  (p_element_type_id     => p_rec.element_type_id,
   p_bdgt_cmmtmnt_elmnt_id     => p_rec.bdgt_cmmtmnt_elmnt_id,
   p_budget_id                  => p_rec.budget_id,
   p_actual_commitment_type          =>  p_rec.actual_commitment_type,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_input_values
  (p_element_input_value_id    => p_rec.element_input_value_id,
   p_frequency_input_value_id  => p_rec.frequency_input_value_id,
   p_salary_basis_flag         => p_rec.salary_basis_flag,
   p_formula_id                => p_rec.formula_id);
  --
  chk_overhead_percentage
  (p_overhead_percentage     => p_rec.overhead_percentage );
  --
  /* chk_balance_type_id
  (p_balance_type_id         => p_rec.balance_type_id); */
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_bce_shd.g_rec_type
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
end pqh_bce_bus;

/
