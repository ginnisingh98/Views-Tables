--------------------------------------------------------
--  DDL for Package Body PQH_RHT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RHT_BUS" as
/* $Header: pqrhtrhi.pkb 115.7 2002/12/06 18:08:02 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rht_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_history_id >------|
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
--   routing_history_id PK of record being inserted or updated.
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
Procedure chk_routing_history_id(p_routing_history_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_history_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_history_id,hr_api.g_number)
     <>  pqh_rht_shd.g_old_rec.routing_history_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_routing_history_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_routing_history_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pos_structure_version_id >------|
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
--   p_routing_history_id PK
--   p_pos_structure_version_id ID of FK column
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
Procedure chk_pos_structure_version_id (p_routing_history_id          in number,
                            p_pos_structure_version_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pos_structure_version_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_pos_structure_versions a
    where  a.pos_structure_version_id = p_pos_structure_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pos_structure_version_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.pos_structure_version_id,hr_api.g_number)
     or not l_api_updating) and
     p_pos_structure_version_id is not null then
    --
    -- check if pos_structure_version_id value exists in per_pos_structure_versions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_pos_structure_versions
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK7');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pos_structure_version_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_to_member_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_to_member_id ID of FK column
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
Procedure chk_forwarded_to_member_id (p_routing_history_id          in number,
                            p_forwarded_to_member_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_to_member_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_list_members a
    where  a.routing_list_member_id = p_forwarded_to_member_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_to_member_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_to_member_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_to_member_id is not null then
    --
    -- check if forwarded_to_member_id value exists in pqh_routing_list_members table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_list_members
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK6');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_forwarded_to_member_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_by_member_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_by_member_id ID of FK column
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
Procedure chk_forwarded_by_member_id (p_routing_history_id          in number,
                            p_forwarded_by_member_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_by_member_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_list_members a
    where  a.routing_list_member_id = p_forwarded_by_member_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_by_member_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_by_member_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_by_member_id is not null then
    --
    -- check if forwarded_by_member_id value exists in pqh_routing_list_members table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_list_members
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK5');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_forwarded_by_member_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_category_id >------|
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
--   p_routing_history_id PK
--   p_transaction_category_id ID of FK column
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
Procedure chk_transaction_category_id (p_routing_history_id          in number,
                            p_transaction_category_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_category_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_transaction_categories a
    where  a.transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
     (p_routing_history_id            => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.transaction_category_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if transaction_category_id value exists in pqh_transaction_categories table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_transaction_categories
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_category_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_to_position_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_to_position_id ID of FK column
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
Procedure chk_forwarded_to_position_id (p_routing_history_id          in number,
                            p_forwarded_to_position_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_to_position_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_positions a
    where  a.position_id = p_forwarded_to_position_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_to_position_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_to_position_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_to_position_id is not null then
    --
    -- check if forwarded_to_position_id value exists in per_all_positions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_positions
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_forwarded_to_position_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_by_position_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_by_position_id ID of FK column
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
Procedure chk_forwarded_by_position_id (p_routing_history_id          in number,
                            p_forwarded_by_position_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_by_position_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_positions a
    where  a.position_id = p_forwarded_by_position_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_by_position_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_by_position_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_by_position_id is not null then
    --
    -- check if forwarded_by_position_id value exists in per_all_positions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_positions
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_forwarded_by_position_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_category_id >------|
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
--   p_routing_history_id PK
--   p_routing_category_id ID of FK column
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
Procedure chk_routing_category_id (p_routing_history_id          in number,
                            p_routing_category_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_category_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_categories a
    where  a.routing_category_id = p_routing_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
     (p_routing_history_id            => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_category_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.routing_category_id,hr_api.g_number)
     or not l_api_updating)
     and p_routing_category_id is not null then
    --
    -- check if routing_category_id value exists in pqh_routing_categories table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_categories
        -- table.
        --
        pqh_rht_shd.constraint_error('PQH_ROUTING_HISTORY_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_routing_category_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_approval_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   routing_history_id PK of record being inserted or updated.
--   approval_cd Value of lookup code.
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
Procedure chk_approval_cd(p_routing_history_id                in number,
                            p_approval_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_approval_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_approval_cd
      <> nvl(pqh_rht_shd.g_old_rec.approval_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_approval_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_APPROVAL_CD',
           p_lookup_code    => p_approval_cd,
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
end chk_approval_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_user_action_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   routing_history_id PK of record being inserted or updated.
--   user_action_cd Value of lookup code.
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
Procedure chk_user_action_cd(p_routing_history_id                in number,
                            p_user_action_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_user_action_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_user_action_cd
      <> nvl(pqh_rht_shd.g_old_rec.user_action_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_USER_ACTION_CD',
           p_lookup_code    => p_user_action_cd,
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
end chk_user_action_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_to_assignment_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_to_assignment_id ID of FK column
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
Procedure chk_forwarded_to_assignment_id (p_routing_history_id          in number,
                            p_forwarded_to_assignment_id          in number,
                            p_effective_date              in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_to_assignment_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_assignments_f a
    where  a.assignment_id = p_forwarded_to_assignment_id
      and  p_effective_date between a.effective_start_date and a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_to_assignment_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_to_assignment_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_to_assignment_id is not null then
    --
    -- check if forwarded_to_assignment_id value exists in per_all_assignments table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_assignments table
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_ASSIGNMENT');
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
End chk_forwarded_to_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_by_assignment_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_by_assignment_id ID of FK column
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
Procedure chk_forwarded_by_assignment_id (p_routing_history_id          in number,
                            p_forwarded_by_assignment_id          in number,
                            p_effective_date              in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_by_assignment_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_assignments_f a
    where  a.assignment_id = p_forwarded_by_assignment_id
      and  p_effective_date between a.effective_start_date and a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_by_assignment_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_by_assignment_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_by_assignment_id is not null then
    --
    -- check if forwarded_by_assignment_id value exists in per_all_assignments table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_assignments table
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_ASSIGNMENT');
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
End chk_forwarded_by_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_to_role_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_to_role_id ID of FK column
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
Procedure chk_forwarded_to_role_id (p_routing_history_id          in number,
                                    p_forwarded_to_role_id        in number,
                                    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_to_role_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_roles a
    where  a.role_id = p_forwarded_to_role_id
    and nvl(a.enable_flag,'X') ='Y';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_to_role_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_to_role_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_to_role_id is not null then
    --
    -- check if forwarded_to_role_id value exists in pqh_roles table
    hr_utility.set_location('checking forwarded_to_role '||p_forwarded_to_role_id||l_proc,5);
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_roles table
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_ROLE');
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
End chk_forwarded_to_role_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_by_role_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_by_role_id ID of FK column
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
Procedure chk_forwarded_by_role_id (p_routing_history_id    in number,
                                    p_forwarded_by_role_id  in number,
                                    p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_by_role_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_roles a
    where  a.role_id = p_forwarded_by_role_id
    and nvl(a.enable_flag,'X') ='Y';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_by_role_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_by_role_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_by_role_id is not null then
    --
    -- check if forwarded_by_role_id value exists in pqh_roles table
    hr_utility.set_location('checking forwarded_by_role '||p_forwarded_by_role_id||l_proc,5);
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in fnd_user table
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_ROLE');
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
End chk_forwarded_by_role_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_to_user_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_to_user_id ID of FK column
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
Procedure chk_forwarded_to_user_id (p_routing_history_id          in number,
                            p_forwarded_to_user_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_to_user_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_user a
    where  a.user_id = p_forwarded_to_user_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_to_user_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_to_user_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_to_user_id is not null then
    --
    -- check if forwarded_to_user_id value exists in fnd_user table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in fnd_user table
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_USER');
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
End chk_forwarded_to_user_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_forwarded_by_user_id >------|
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
--   p_routing_history_id PK
--   p_forwarded_by_user_id ID of FK column
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
Procedure chk_forwarded_by_user_id (p_routing_history_id          in number,
                            p_forwarded_by_user_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_forwarded_by_user_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_user a
    where  a.user_id = p_forwarded_by_user_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rht_shd.api_updating
    (p_routing_history_id                => p_routing_history_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_forwarded_by_user_id,hr_api.g_number)
     <> nvl(pqh_rht_shd.g_old_rec.forwarded_by_user_id,hr_api.g_number)
     or not l_api_updating) and
     p_forwarded_by_user_id is not null then
    --
    -- check if forwarded_by_user_id value exists in fnd_user table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in fnd_user table
        -- table.
        --
          hr_utility.set_message(8302,'PQH_INVALID_USER');
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
End chk_forwarded_by_user_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rht_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_routing_history_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pos_structure_version_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_pos_structure_version_id          => p_rec.pos_structure_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_member_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_member_id          => p_rec.forwarded_to_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_member_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_member_id          => p_rec.forwarded_by_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_position_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_position_id          => p_rec.forwarded_to_position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_position_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_position_id          => p_rec.forwarded_by_position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_category_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_routing_category_id          => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_approval_cd
  (p_routing_history_id          => p_rec.routing_history_id,
   p_approval_cd         => p_rec.approval_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_user_action_cd
  (p_routing_history_id          => p_rec.routing_history_id,
   p_user_action_cd         => p_rec.user_action_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_assignment_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_assignment_id  => p_rec.forwarded_to_assignment_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_assignment_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_assignment_id  => p_rec.forwarded_by_assignment_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_user_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_user_id     => p_rec.forwarded_by_user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_user_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_user_id     => p_rec.forwarded_to_user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_role_id
  (p_routing_history_id      => p_rec.routing_history_id,
   p_forwarded_by_role_id     => p_rec.forwarded_by_role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_role_id
  (p_routing_history_id      => p_rec.routing_history_id,
   p_forwarded_to_role_id     => p_rec.forwarded_to_role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rht_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_routing_history_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pos_structure_version_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_pos_structure_version_id          => p_rec.pos_structure_version_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_member_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_member_id          => p_rec.forwarded_to_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_member_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_member_id          => p_rec.forwarded_by_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_position_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_position_id          => p_rec.forwarded_to_position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_position_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_position_id          => p_rec.forwarded_by_position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_category_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_routing_category_id          => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_approval_cd
  (p_routing_history_id          => p_rec.routing_history_id,
   p_approval_cd         => p_rec.approval_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_user_action_cd
  (p_routing_history_id          => p_rec.routing_history_id,
   p_user_action_cd         => p_rec.user_action_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_assignment_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_assignment_id  => p_rec.forwarded_to_assignment_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_assignment_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_by_assignment_id  => p_rec.forwarded_by_assignment_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_user_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_user_id     => p_rec.forwarded_to_user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_user_id
  (p_routing_history_id      => p_rec.routing_history_id,
   p_forwarded_by_user_id     => p_rec.forwarded_by_user_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_to_role_id
  (p_routing_history_id          => p_rec.routing_history_id,
   p_forwarded_to_role_id     => p_rec.forwarded_to_role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_forwarded_by_role_id
  (p_routing_history_id      => p_rec.routing_history_id,
   p_forwarded_by_role_id     => p_rec.forwarded_by_role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rht_shd.g_rec_type
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
end pqh_rht_bus;

/
