--------------------------------------------------------
--  DDL for Package Body PQH_RLM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLM_BUS" as
/* $Header: pqrlmrhi.pkb 115.13 2003/08/19 15:07:31 hsajja noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rlm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_list_member_id >------|
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
--   routing_list_member_id PK of record being inserted or updated.
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
Procedure chk_routing_list_member_id(p_routing_list_member_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_list_member_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
    (p_routing_list_member_id                => p_routing_list_member_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_list_member_id,hr_api.g_number)
     <>  pqh_rlm_shd.g_old_rec.routing_list_member_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rlm_shd.constraint_error('PQH_ROUTING_LIST_MEMBERS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_routing_list_member_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rlm_shd.constraint_error('PQH_ROUTING_LIST_MEMBERS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_routing_list_member_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_list_id >------|
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
--   p_routing_list_member_id PK
--   p_routing_list_id ID of FK column
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
Procedure chk_routing_list_id (p_routing_list_member_id          in number,
                            p_routing_list_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_list_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_lists a
    where  a.routing_list_id = p_routing_list_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
     (p_routing_list_member_id            => p_routing_list_member_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_list_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.routing_list_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if routing_list_id value exists in pqh_routing_lists table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_lists
        -- table.
        --
        hr_utility.set_message(8302, 'PQH_INVALID_ROUTING_LIST');
        hr_utility.raise_error;

--        pqh_rlm_shd.constraint_error('PQH_ROUTING_LIST_MEMBERS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_routing_list_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_role_user_id >------|
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
--   p_routing_list_member_id PK
--   p_role_id ID of FK column
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
Procedure chk_role_user_id (p_routing_list_member_id          in number,
                            p_role_id          		in number,
                            p_user_id 			in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_user_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_roles a
    where  a.role_id = p_role_id;
  --
  cursor c2 is
    select null
    from pqh_role_users_v
    where user_id = nvl(p_user_id, -1)
    and role_id = p_role_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
     (p_routing_list_member_id            => p_routing_list_member_id,
      p_object_version_number   => p_object_version_number);
  --
    --
  if (l_api_updating
     and (nvl(p_role_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.role_id,hr_api.g_number)
     or nvl(p_user_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.user_id,hr_api.g_number) )
     or not l_api_updating) and
      (p_role_id is not null) then
    --
    -- check if role_id value exists in pqh_roles table and user is assigned to role
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_roles
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_ROLE');
          hr_utility.raise_error;
--        pqh_rlm_shd.constraint_error('PQH_ROUTING_LIST_MEMBERS_FK1');
        --
      end if;
      --
    close c1;
    --
    --
    -- check if user_id is assigned to role
    --
    if p_user_id is not null then
    open c2;
      --
      fetch c2 into l_dummy;
      if c2%notfound then
        --
        close c2;
        --
        -- raise error as user_id is not assigned to role
        -- table.
        --
          hr_utility.set_message(8302,'PQH_USER_NOT_OF_CUR_ROLE');
          hr_utility.raise_error;
--        pqh_rlm_shd.constraint_error('PQH_ROUTING_LIST_MEMBERS_FK1');
        --
      end if;
      --
    close c2;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_role_user_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rlist_role_user_uk1 >------|
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
--   p_role_template_id PK
--   p_template_id ID of FK column
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
Procedure chk_rlist_role_user_uk1 (p_routing_list_member_id          in number,
			    p_routing_list_id          in number,
                            p_role_id          in number,
                            p_user_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rlist_role_user_uk1';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_list_members a
    where  a.routing_list_id=p_routing_list_id
	   and a.role_id = p_role_id
	   and nvl(a.user_id,-1) = nvl(p_user_id, -1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
     (p_routing_list_member_id            => p_routing_list_member_id,
      p_object_version_number   	  => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_routing_list_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.routing_list_id,hr_api.g_number)
     or nvl(p_role_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.role_id,hr_api.g_number)
     or nvl(p_user_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.user_id,hr_api.g_number) )
     or not l_api_updating) and
      (p_role_id is not null) then
    --
    -- check if transaction_category_id and template_id value exists in pqh_templates table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error as UK failed
        -- table.
        --
          hr_utility.set_message(8302,'PQH_DUP_RLM_NOT_ALLOWED');
          hr_utility.raise_error;
--        pqh_rtm_shd.constraint_error('PQH_ROUTING_LIST_MEMBERS_UK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_rlist_role_user_uk1;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rlist_seq_uk2 >------|
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
Procedure chk_rlist_seq_uk2 (p_routing_list_member_id          in number,
			    p_routing_list_id          in number,
                            p_seq_no          		in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rlist_seq_uk2';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_list_members a
    where  a.routing_list_id=p_routing_list_id
	   and a.seq_no = p_seq_no;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
     (p_routing_list_member_id            => p_routing_list_member_id,
      p_object_version_number   	  => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_routing_list_id,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.routing_list_id,hr_api.g_number)
     or nvl(p_seq_no,hr_api.g_number)
     <> nvl(pqh_rlm_shd.g_old_rec.seq_no,hr_api.g_number))
     or not l_api_updating) and
      (p_seq_no is not null) then
    --
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error as UK failed
        -- table.
        --
          hr_utility.set_message(8302,'PQH_DUP_RLM_SEQ_NOT_ALLOWED');
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
End chk_rlist_seq_uk2;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_approver_flag >------|
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
--   approver_flag Value of lookup code.
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
Procedure chk_approver_flag(p_routing_list_member_id                in number,
                            p_approver_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_approver_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
    (p_routing_list_member_id                => p_routing_list_member_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_approver_flag
      <> nvl(pqh_rlm_shd.g_old_rec.approver_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_approver_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_approver_flag,
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
end chk_approver_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_enable_flag >------|
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
--   approver_flag Value of lookup code.
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
Procedure chk_enable_flag(p_routing_list_member_id                in number,
			    p_routing_list_id 			in number,
			    p_role_id 				in number,
			    p_user_id 				in number,
                            p_enable_flag               	in varchar2,
                            p_effective_date              	in date,
                            p_object_version_number       	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  l_routing_list_enable_flag 	varchar2(10);
  l_role_enable_flag		varchar2(10);
  l_role_user_enable_flag	varchar2(10);
  l_dummy			varchar2(10);
  --
  cursor c_routing_list_enable_flag(p_routing_list_id number) is
  select enable_flag
  from pqh_routing_lists
  where routing_list_id = p_routing_list_id;
  --
  cursor c_role_enable_flag(p_role_id number) is
  select enable_flag
  from pqh_roles
  where role_id = p_role_id;
  --
  cursor c_role_user_enable_flag(p_role_id number, p_user_id number) is
  select 'x'
  from pqh_role_users_v
  where role_id = p_role_id
  and user_id = p_user_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rlm_shd.api_updating
    (p_routing_list_member_id                => p_routing_list_member_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_rlm_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enable_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enable_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    if p_enable_flag = 'Y' then
      --
      open c_routing_list_enable_flag(p_routing_list_id);
      fetch c_routing_list_enable_flag into l_routing_list_enable_flag;
      close c_routing_list_enable_flag;
      --
      if nvl(l_routing_list_enable_flag,'N') ='N' then
        hr_utility.set_message(8302,'PQH_CANT_ENABLE_RLM_RL_DIS');
        hr_utility.raise_error;
      end if;
      --
      --
      open c_role_enable_flag(p_role_id);
      fetch c_role_enable_flag into l_role_enable_flag;
      close c_role_enable_flag;
      --
      if nvl(l_role_enable_flag,'N') = 'N' then
        hr_utility.set_message(8302,'PQH_CANT_ENABLE_RLM_RLS_DIS');
        hr_utility.raise_error;
      end if;
      --
      --
      if p_user_id is not null then
        open c_role_user_enable_flag(p_role_id, p_user_id);
        fetch c_role_user_enable_flag into l_dummy;
        --
        if c_role_user_enable_flag%notfound then
          close c_role_user_enable_flag;
          hr_utility.set_message(8302,'PQH_CANT_ENBL_RLM_RLSUSR_DIS');
          hr_utility.raise_error;
        else
          close c_role_user_enable_flag;
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enable_flag;
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
Procedure chk_for_pending_txns(p_routing_list_member_id 	in number,
				p_routing_list_id   		in number,
				p_object_version_number		in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_for_pending_txns';
  l_api_updating boolean;
  l_bus_grp_name varchar2(240);
  --
  cursor c_txn_cats(p_routing_list_id number) is
  select distinct ptc.transaction_category_id, ptc.name transaction_category_name,
  ptc.business_group_id
  from pqh_routing_list_members rlm, pqh_routing_categories rct,
       pqh_transaction_categories ptc
  where rlm.routing_list_id =  rct.routing_list_id
  and rct.routing_list_id = p_routing_list_id
  and rct.transaction_category_id = ptc.transaction_category_id;
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
         hr_utility.set_message(8302,'PQH_CANT_DEL_RLM_PNDG_TXN');
         hr_utility.set_message_token('TRANSACTION_CATEGORY', r_txn_cat.transaction_category_name);
         if (r_txn_cat.business_group_id is not null) then
           l_bus_grp_name := hr_general.DECODE_ORGANIZATION(r_txn_cat.business_group_id);
         else
           l_bus_grp_name := hr_general.decode_lookup('PQH_TCT_SCOPE', 'GLOBAL');
         end if;

         hr_utility.set_message_token('BUSINESS_GROUP', l_bus_grp_name);
         hr_utility.raise_error;
      end if;
      --
    end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_for_pending_txns;
--
function chk_txn_cat_freeze_status(p_transaction_category_id   in number) return varchar2 is
--
l_freeze_status   varchar2(30);
--
cursor c_cat_status(p_transaction_category_id number) is
select freeze_status_cd
from pqh_transaction_categories_vl
where transaction_category_id = p_transaction_category_id;
--
begin
  --
  open c_cat_status(p_transaction_category_id);
  fetch c_cat_status into l_freeze_status;
  close c_cat_status;
  return(l_freeze_status);
  --
end;
--
function chk_rlm_txn_cat_frozen(p_routing_list_member_id   in number) return varchar2 is
  --
  l_proc         varchar2(72) := g_package||'chk_rlm_txn_cat_frozen';
  l_api_updating boolean;
  --
  cursor c_txn_cats(p_routing_list_member_id number) is
select distinct rtc.transaction_category_id
from pqh_attribute_ranges arg, pqh_routing_categories rtc
where routing_list_member_id = p_routing_list_member_id
and arg.routing_category_id = rtc.routing_category_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    for r_txn_cat in c_txn_cats(p_routing_list_member_id)
    loop
      --
      return chk_txn_cat_freeze_status(r_txn_cat.transaction_category_id);
      --
    end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rlm_txn_cat_frozen;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rlm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_routing_list_member_id
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_list_id
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id          => p_rec.routing_list_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_role_user_id
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_role_id          => p_rec.role_id,
   p_user_id          => p_rec.user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_approver_flag
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_approver_flag         => p_rec.approver_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
   --
  chk_enable_flag
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id		=> p_rec.routing_list_id,
   p_role_id			=> p_rec.role_id,
   p_user_id			=> p_rec.user_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rlist_role_user_uk1
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id                 => p_rec.routing_list_id,
   p_role_id			     => p_rec.role_id,
   p_user_id			     => p_rec.user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rlist_seq_uk2
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id                 => p_rec.routing_list_id,
   p_seq_no			     => p_rec.seq_no,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rlm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_routing_list_member_id
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_list_id
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id          => p_rec.routing_list_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_role_user_id
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_role_id          => p_rec.role_id,
   p_user_id          => p_rec.user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rlist_role_user_uk1
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id                 => p_rec.routing_list_id,
   p_role_id			     => p_rec.role_id,
   p_user_id			     => p_rec.user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_approver_flag
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_approver_flag         => p_rec.approver_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id		=> p_rec.routing_list_id,
   p_role_id			=> p_rec.role_id,
   p_user_id			=> p_rec.user_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_rlist_seq_uk2
  (p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_routing_list_id                 => p_rec.routing_list_id,
   p_seq_no			     => p_rec.seq_no,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rlm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_for_pending_txns(p_routing_list_member_id  => p_rec.routing_list_member_id,
  			p_routing_list_id	 => p_rec.routing_list_id,
  		   	p_object_version_number  => p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_rlm_bus;

/
