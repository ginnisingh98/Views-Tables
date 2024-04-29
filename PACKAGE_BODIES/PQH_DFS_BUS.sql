--------------------------------------------------------
--  DDL for Package Body PQH_DFS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DFS_BUS" as
/* $Header: pqdfsrhi.pkb 115.11 2003/04/02 20:02:02 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_dfs_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_fund_src_id >------|
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
--   dflt_fund_src_id PK of record being inserted or updated.
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
Procedure chk_dflt_fund_src_id(p_dflt_fund_src_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_fund_src_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_dfs_shd.api_updating
    (p_dflt_fund_src_id                => p_dflt_fund_src_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_fund_src_id,hr_api.g_number)
     <>  pqh_dfs_shd.g_old_rec.dflt_fund_src_id) then
    --
    -- raise error as PK has changed
    --
    pqh_dfs_shd.constraint_error('PQH_DFLT_FUND_SRCS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_dflt_fund_src_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_dfs_shd.constraint_error('PQH_DFLT_FUND_SRCS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dflt_fund_src_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cost_allocation_keyflex_id >------|
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
--   p_dflt_fund_src_id PK
--   p_cost_allocation_keyflex_id ID of FK column
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
Procedure chk_cost_allocation_keyflex_id (p_dflt_fund_src_id          in number,
                            p_cost_allocation_keyflex_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cost_allocation_keyflex_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_cost_allocation_keyflex a
    where  a.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_dfs_shd.api_updating
    (p_dflt_fund_src_id                => p_dflt_fund_src_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cost_allocation_keyflex_id,hr_api.g_number)
     <> nvl(pqh_dfs_shd.g_old_rec.cost_allocation_keyflex_id,hr_api.g_number)
     or not l_api_updating) and
     p_cost_allocation_keyflex_id is not null then
    --
    -- check if cost_allocation_keyflex_id value exists in pay_cost_allocation_keyflex table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pay_cost_allocation_keyflex
        -- table.
        --
        pqh_dfs_shd.constraint_error('PQH_DFLT_FUND_SRCS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cost_allocation_keyflex_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_budget_element_id >------|
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
--   p_dflt_fund_src_id PK
--   p_dflt_budget_element_id ID of FK column
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
Procedure chk_dflt_budget_element_id (p_dflt_fund_src_id          in number,
                            p_dflt_budget_element_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_budget_element_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_dflt_budget_elements a
    where  a.dflt_budget_element_id = p_dflt_budget_element_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_dfs_shd.api_updating
     (p_dflt_fund_src_id            => p_dflt_fund_src_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_budget_element_id,hr_api.g_number)
     <> nvl(pqh_dfs_shd.g_old_rec.dflt_budget_element_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if dflt_budget_element_id value exists in pqh_dflt_budget_elements table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_dflt_budget_elements
        -- table.
        --
        pqh_dfs_shd.constraint_error('PQH_DFLT_FUND_SRCS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dflt_budget_element_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_duplicate_src >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_src (p_dflt_budget_element_id                in number,
                             p_dflt_fund_src_id                      in number,
                             p_project_id                            in number,
                             p_award_id                              in number,
                             p_task_id                               in number,
                             p_expenditure_type                      in varchar2,
                             p_organization_id                       in number,
                             p_cost_allocation_keyflex_id            in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_src';
  --
l_dummy   varchar2(1) ;

 cursor csr_src is
 select 'X'
 from pqh_dflt_fund_srcs
 where dflt_budget_element_id = p_dflt_budget_element_id
   and dflt_fund_src_id <> nvl(p_dflt_fund_src_id,0)
   and nvl(cost_allocation_keyflex_id,0)   = nvl(p_cost_allocation_keyflex_id,0)
   and nvl(project_id,0)                   = nvl(p_project_id,0)
   and nvl(award_id,0)                     = nvl(p_award_id,0)
   and nvl(task_id,0)                      = nvl(p_task_id,0)
   and nvl(expenditure_type,0)             = nvl(p_expenditure_type,0)
   and nvl(organization_id,0)              = nvl(p_organization_id,0)
;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_src;
   fetch csr_src into l_dummy;
  close csr_src;

    if nvl(l_dummy ,'Y') = 'X' then
      --
       hr_utility.set_message(8302,'PQH_DUPLICATE_BUDGET_SRCS');
       hr_utility.raise_error;
      --
    end if;
    if p_cost_allocation_keyflex_id is not null then
       if p_project_id is not null
          or p_award_id is not null
          or p_task_id is not null
          or p_expenditure_type is not null
          or p_organization_id is not null then
          hr_utility.set_message(8302,'PQH_BUDGET_SRC_GL_GMS');
          hr_utility.raise_error;
       end if;
    else
       if p_project_id is null
          or p_award_id is null
          or p_task_id is null
          or p_expenditure_type is null
          or p_organization_id is null then
          hr_utility.set_message(8302,'PQH_BUDGET_SRC_MANDATORY');
          hr_utility.raise_error;
       end if;
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_duplicate_src;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_sum >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_sum (p_dflt_budget_element_id                in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sum';
  --

l_sum       number(15,2) := 0;

 cursor csr_element is
 select SUM(NVL(dflt_dist_percentage,0))
 from pqh_dflt_fund_srcs
 where dflt_budget_element_id = p_dflt_budget_element_id;

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
      hr_utility.set_message(8302,'PQH_WKS_INVALID_SRCS_SUM');
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
      hr_utility.set_message(8302,'PQH_WKS_INVALID_SRC_PERCENT');
      hr_utility.raise_error;
    --
   end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_percentage;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_dfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dflt_fund_src_id
  (p_dflt_fund_src_id          => p_rec.dflt_fund_src_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cost_allocation_keyflex_id
  (p_dflt_fund_src_id          => p_rec.dflt_fund_src_id,
   p_cost_allocation_keyflex_id          => p_rec.cost_allocation_keyflex_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_budget_element_id
  (p_dflt_fund_src_id          => p_rec.dflt_fund_src_id,
   p_dflt_budget_element_id          => p_rec.dflt_budget_element_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_src
  (p_dflt_budget_element_id        => p_rec.dflt_budget_element_id,
   p_dflt_fund_src_id              => p_rec.dflt_fund_src_id,
   p_project_id                    => p_rec.project_id,
   p_award_id                      => p_rec.award_id,
   p_task_id                       => p_rec.task_id,
   p_expenditure_type              => p_rec.expenditure_type,
   p_organization_id               => p_rec.organization_id,
   p_cost_allocation_keyflex_id    => p_rec.cost_allocation_keyflex_id);
  --
  --
 chk_percentage
 (p_dflt_dist_percentage       =>  p_rec.dflt_dist_percentage );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_dfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dflt_fund_src_id
  (p_dflt_fund_src_id          => p_rec.dflt_fund_src_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cost_allocation_keyflex_id
  (p_dflt_fund_src_id          => p_rec.dflt_fund_src_id,
   p_cost_allocation_keyflex_id          => p_rec.cost_allocation_keyflex_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_budget_element_id
  (p_dflt_fund_src_id          => p_rec.dflt_fund_src_id,
   p_dflt_budget_element_id          => p_rec.dflt_budget_element_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_src
  (p_dflt_budget_element_id        => p_rec.dflt_budget_element_id,
   p_dflt_fund_src_id              => p_rec.dflt_fund_src_id,
   p_project_id                    => p_rec.project_id,
   p_award_id                      => p_rec.award_id,
   p_task_id                       => p_rec.task_id,
   p_expenditure_type              => p_rec.expenditure_type,
   p_organization_id               => p_rec.organization_id,
   p_cost_allocation_keyflex_id    => p_rec.cost_allocation_keyflex_id);
  --
  --
 chk_percentage
 (p_dflt_dist_percentage       =>  p_rec.dflt_dist_percentage );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_dfs_shd.g_rec_type) is
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
end pqh_dfs_bus;

/
