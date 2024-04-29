--------------------------------------------------------
--  DDL for Package Body PQH_RLT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLT_BUS" as
/* $Header: pqrltrhi.pkb 115.8 2004/02/26 10:32:25 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rlt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_list_id >------|
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
--   routing_list_id PK of record being inserted or updated.
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
Procedure chk_routing_list_id(p_routing_list_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_list_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rlt_shd.api_updating
    (p_routing_list_id                => p_routing_list_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_list_id,hr_api.g_number)
     <>  pqh_rlt_shd.g_old_rec.routing_list_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rlt_shd.constraint_error('PQH_ROUTING_LISTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_routing_list_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rlt_shd.constraint_error('PQH_ROUTING_LISTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_routing_list_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_list_name >------|
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
--   routing_list_id PK of record being inserted or updated.
--   routing_list_name name of the routing list
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
Procedure chk_routing_list_name(p_routing_list_id                in number,
				p_routing_list_name		 in varchar2,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_list_name';
  l_api_updating boolean;
  l_dummy 	 varchar2(10);
  --
  cursor c1 is
  select 'x'
  from pqh_routing_lists
  where nvl(routing_list_name,hr_api.g_varchar2) = nvl(p_routing_list_name,hr_api.g_varchar2);
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rlt_shd.api_updating
    (p_routing_list_id                => p_routing_list_id,
     p_object_version_number       => p_object_version_number);
  --
  if ((l_api_updating
     and nvl(p_routing_list_name,hr_api.g_varchar2)
     <>  nvl(pqh_rlt_shd.g_old_rec.routing_list_name,hr_api.g_varchar2)) or not l_api_updating )then

      if p_routing_list_name is not null then
	--
	open c1;
	fetch c1 into l_dummy;
	if c1%found then
	  close c1;
	  hr_utility.set_message(8302,'PQH_ROUTING_LIST_NAME_EXISTS');
	  hr_utility.raise_error;
--      pqh_rlt_shd.constraint_error('PQH_ROUTING_LISTS_PK');
        end if;
        close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_routing_list_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_for_pending_txns >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   routing_list_member_id PK of record being inserted or updated.
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
Procedure chk_for_pending_txns(p_routing_list_id   in number) is
  --
  l_name         pqh_transaction_categories_vl.name%type;
  l_proc         varchar2(72) := g_package||'chk_for_pending_txns';
  l_bus_grp_name varchar2(240);
  l_bus_grp_id   pqh_transaction_categories_vl.business_group_id%type;
  l_api_updating boolean;
  --
  cursor c_txn_cats(p_routing_list_id number) is
  select distinct transaction_category_id
  from pqh_routing_list_members rlm, pqh_routing_categories rct
  where rlm.routing_list_id =  rct.routing_list_id
  and rct.routing_list_id = p_routing_list_id;
  --
  Cursor csr_txn_cat_name(p_transaction_category_id in number) is
   Select name,business_group_id
     From pqh_transaction_categories_vl
    Where transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    for r_txn_cat in c_txn_cats(p_routing_list_id)
    loop
      --
      if nvl(pqh_tct_bus.chk_active_transaction_exists(r_txn_cat.transaction_category_id),'N')
            = 'Y' then
         --
         Open csr_txn_cat_name(p_transaction_category_id => r_txn_cat.transaction_category_id);
         Fetch csr_txn_cat_name into l_name,l_bus_grp_id;
         Close csr_txn_cat_name;
         --
         hr_utility.set_message(8302,'PQH_CANT_DEL_RL_PENDING_TXNS');
         hr_utility.set_message_token('TRANSACTION_CATEGORY',l_name);
         if (l_bus_grp_id is not null) then
           l_bus_grp_name := hr_general.DECODE_ORGANIZATION(l_bus_grp_id);
         else
           l_bus_grp_name := hr_general.decode_lookup('PQH_TCT_SCOPE', 'GLOBAL');
         end if;
         --
         hr_utility.set_message_token('BUSINESS_GROUP', l_bus_grp_name);
         --
         hr_utility.raise_error;
         --
      end if;
      --
    end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_for_pending_txns;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rlt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_routing_list_id
  (p_routing_list_id          => p_rec.routing_list_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_list_name
  (p_routing_list_id          => p_rec.routing_list_id,
   p_routing_list_name        => p_rec.routing_list_name,
   p_object_version_number    => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rlt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_routing_list_id
  (p_routing_list_id          => p_rec.routing_list_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_routing_list_name
  (p_routing_list_id          => p_rec.routing_list_id,
   p_routing_list_name        => p_rec.routing_list_name,
   p_object_version_number    => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rlt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_for_pending_txns(p_rec.routing_list_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_rlt_bus;

/
