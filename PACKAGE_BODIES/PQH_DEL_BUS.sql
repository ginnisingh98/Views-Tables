--------------------------------------------------------
--  DDL for Package Body PQH_DEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DEL_BUS" as
/* $Header: pqdelrhi.pkb 115.7 2002/12/05 19:31:43 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_del_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_budget_element_id >------|
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
--   dflt_budget_element_id PK of record being inserted or updated.
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
Procedure chk_dflt_budget_element_id(p_dflt_budget_element_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_budget_element_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_del_shd.api_updating
    (p_dflt_budget_element_id                => p_dflt_budget_element_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_budget_element_id,hr_api.g_number)
     <>  pqh_del_shd.g_old_rec.dflt_budget_element_id) then
    --
    -- raise error as PK has changed
    --
    pqh_del_shd.constraint_error('PQH_DFLT_BUDGET_ELEMENTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_dflt_budget_element_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_del_shd.constraint_error('PQH_DFLT_BUDGET_ELEMENTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dflt_budget_element_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_budget_set_id >------|
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
--   p_dflt_budget_element_id PK
--   p_dflt_budget_set_id ID of FK column
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
Procedure chk_dflt_budget_set_id (p_dflt_budget_element_id          in number,
                            p_dflt_budget_set_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_budget_set_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_dflt_budget_sets a
    where  a.dflt_budget_set_id = p_dflt_budget_set_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_del_shd.api_updating
     (p_dflt_budget_element_id            => p_dflt_budget_element_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_budget_set_id,hr_api.g_number)
     <> nvl(pqh_del_shd.g_old_rec.dflt_budget_set_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if dflt_budget_set_id value exists in pqh_dflt_budget_sets table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_dflt_budget_sets
        -- table.
        --
        pqh_del_shd.constraint_error('PQH_DFLT_BUDGET_ELEMENTS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dflt_budget_set_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_duplicate_elements >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_elements (p_dflt_budget_set_id                in number,
                                  p_dflt_budget_element_id            in number,
                                  p_element_type_id               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_elements';
  --
l_dummy   varchar2(1) ;

 cursor csr_element is
 select 'X'
 from pqh_dflt_budget_elements
 where dflt_budget_set_id = p_dflt_budget_set_id
   and dflt_budget_element_id <> nvl(p_dflt_budget_element_id,0)
   and element_type_id   = p_element_type_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_element;
   fetch csr_element into l_dummy;
  close csr_element;

    if nvl(l_dummy ,'Y') = 'X' then
      --
       hr_utility.set_message(8302,'PQH_DUPLICATE_BUDGET_ELEMENTS');
       hr_utility.raise_error;
      --
    end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_duplicate_elements;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_sum >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_sum (p_dflt_budget_set_id                in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sum';
  --

l_sum       number(15,2) := 0;

 cursor csr_element is
 select SUM(NVL(dflt_dist_percentage,0))
 from pqh_dflt_budget_elements
 where dflt_budget_set_id = p_dflt_budget_set_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_element;
   fetch csr_element into l_sum;
  close csr_element;

   if l_sum > 100 then
     -- sum cannot be more then 100
     --
      hr_utility.set_message(8302,'PQH_WKS_INVALID_ELMNT_SUM');
      hr_utility.raise_error;
    --
   end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_sum;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_percentage >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_percentage (p_dflt_dist_percentage                in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_percentage';
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   if NVL(p_dflt_dist_percentage,0) < 0 then
    -- percentage cannot be less then zero
    --
      hr_utility.set_message(8302,'PQH_WKS_INVALID_ELMNT_PERCENT');
      hr_utility.raise_error;
    --
   end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_percentage;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_del_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dflt_budget_element_id
  (p_dflt_budget_element_id          => p_rec.dflt_budget_element_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_budget_set_id
  (p_dflt_budget_element_id          => p_rec.dflt_budget_element_id,
   p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_duplicate_elements
  (p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_dflt_budget_element_id      => p_rec.dflt_budget_element_id,
   p_element_type_id              =>  p_rec.element_type_id);
  --
  --
 chk_percentage
  (p_dflt_dist_percentage    => p_rec.dflt_dist_percentage );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_del_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dflt_budget_element_id
  (p_dflt_budget_element_id          => p_rec.dflt_budget_element_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_budget_set_id
  (p_dflt_budget_element_id          => p_rec.dflt_budget_element_id,
   p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_duplicate_elements
  (p_dflt_budget_set_id          => p_rec.dflt_budget_set_id,
   p_dflt_budget_element_id      => p_rec.dflt_budget_element_id,
   p_element_type_id              =>  p_rec.element_type_id);
  --
 chk_percentage
  (p_dflt_dist_percentage    => p_rec.dflt_dist_percentage );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_del_shd.g_rec_type) is
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
end pqh_del_bus;

/
