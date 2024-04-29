--------------------------------------------------------
--  DDL for Package Body PQH_BFS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BFS_BUS" as
/* $Header: pqbfsrhi.pkb 115.10 2003/04/02 20:01:46 srajakum ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bfs_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_fund_src_id >------|
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
--   budget_fund_src_id PK of record being inserted or updated.
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
Procedure chk_budget_fund_src_id(p_budget_fund_src_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_fund_src_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bfs_shd.api_updating
    (p_budget_fund_src_id                => p_budget_fund_src_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_fund_src_id,hr_api.g_number)
     <>  pqh_bfs_shd.g_old_rec.budget_fund_src_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bfs_shd.constraint_error('PQH_BUDGET_FUND_SRC_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_budget_fund_src_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bfs_shd.constraint_error('PQH_BUDGET_FUND_SRC_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_budget_fund_src_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_element_id >------|
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
--   p_budget_fund_src_id PK
--   p_budget_element_id ID of FK column
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
Procedure chk_budget_element_id (p_budget_fund_src_id          in number,
                            p_budget_element_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_element_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_budget_elements a
    where  a.budget_element_id = p_budget_element_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bfs_shd.api_updating
     (p_budget_fund_src_id            => p_budget_fund_src_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_element_id,hr_api.g_number)
     <> nvl(pqh_bfs_shd.g_old_rec.budget_element_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if budget_element_id value exists in pqh_budget_elements table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_budget_elements
        -- table.
        --
        pqh_bfs_shd.constraint_error('PQH_BUDGET_FUND_SRCS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_element_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_duplicate_src >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_src (p_budget_element_id             in number,
                             p_budget_fund_src_id            in number,
                             p_project_id                    in number,
                             p_award_id                      in number,
                             p_task_id                       in number,
                             p_expenditure_type              in varchar2,
                             p_organization_id               in number,
                             p_cost_allocation_keyflex_id    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_src';
  --
l_dummy   varchar2(1) ;

 cursor csr_src is
 select 'X'
 from pqh_budget_fund_srcs
 where budget_element_id            = p_budget_element_id
   and budget_fund_src_id           <> nvl(p_budget_fund_src_id,0)
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
-- |------< chk_cost_allocation_keyflex_id >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_cost_allocation_keyflex_id (p_budget_fund_src_id          in number,
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
  l_api_updating := pqh_bfs_shd.api_updating
     (p_budget_fund_src_id            => p_budget_fund_src_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cost_allocation_keyflex_id,hr_api.g_number)
     <> nvl(pqh_bfs_shd.g_old_rec.cost_allocation_keyflex_id,hr_api.g_number)
     or not l_api_updating) and p_cost_allocation_keyflex_id is not null then
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
        -- raise error as FK does not relate to PK in pqh_budget_elements
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_COST_KEYFLEX');
          hr_utility.raise_error;
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

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_bfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_fund_src_id
  (p_budget_fund_src_id          => p_rec.budget_fund_src_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_element_id
  (p_budget_fund_src_id          => p_rec.budget_fund_src_id,
   p_budget_element_id          => p_rec.budget_element_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cost_allocation_keyflex_id
  (p_budget_fund_src_id         =>  p_rec.budget_fund_src_id,
   p_cost_allocation_keyflex_id =>  p_rec.cost_allocation_keyflex_id,
   p_object_version_number      =>  p_rec.object_version_number);
  --
  chk_duplicate_src (p_budget_element_id          => p_rec.budget_element_id,
                     p_budget_fund_src_id         => p_rec.budget_fund_src_id,
                     p_project_id                 => p_rec.project_id,
                     p_award_id                   => p_rec.award_id,
                     p_task_id                    => p_rec.task_id,
                     p_expenditure_type           => p_rec.expenditure_type,
                     p_organization_id            => p_rec.organization_id,
                     p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_bfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_fund_src_id
  (p_budget_fund_src_id          => p_rec.budget_fund_src_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_element_id
  (p_budget_fund_src_id          => p_rec.budget_fund_src_id,
   p_budget_element_id          => p_rec.budget_element_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cost_allocation_keyflex_id
  (p_budget_fund_src_id         =>  p_rec.budget_fund_src_id,
   p_cost_allocation_keyflex_id =>  p_rec.cost_allocation_keyflex_id,
   p_object_version_number      =>  p_rec.object_version_number);
  --
  chk_duplicate_src (p_budget_element_id          => p_rec.budget_element_id,
                     p_budget_fund_src_id         => p_rec.budget_fund_src_id,
                     p_project_id                 => p_rec.project_id,
                     p_award_id                   => p_rec.award_id,
                     p_task_id                    => p_rec.task_id,
                     p_expenditure_type           => p_rec.expenditure_type,
                     p_organization_id            => p_rec.organization_id,
                     p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_bfs_shd.g_rec_type) is
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
end pqh_bfs_bus;

/
