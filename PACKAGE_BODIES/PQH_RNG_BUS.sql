--------------------------------------------------------
--  DDL for Package Body PQH_RNG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RNG_BUS" as
/* $Header: pqrngrhi.pkb 115.18 2004/06/24 16:51:43 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rng_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_attribute_range_id >------|
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
--   attribute_range_id PK of record being inserted or updated.
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
Procedure chk_attribute_range_id(p_attribute_range_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_range_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rng_shd.api_updating
    (p_attribute_range_id                => p_attribute_range_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_attribute_range_id,hr_api.g_number)
     <>  pqh_rng_shd.g_old_rec.attribute_range_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rng_shd.constraint_error('PQH_ATTRIBUTE_RANGES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_attribute_range_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rng_shd.constraint_error('PQH_ATTRIBUTE_RANGES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_attribute_range_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_position_id >------|
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
--   p_attribute_range_id PK
--   p_position_id ID of FK column
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
Procedure chk_position_id (p_attribute_range_id          in number,
                            p_position_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_positions a
    where  a.position_id = p_position_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rng_shd.api_updating
     (p_attribute_range_id            => p_attribute_range_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.position_id,hr_api.g_number)
     or not l_api_updating) and
     p_position_id is not null then
    --
    -- check if position_id value exists in per_all_positions table
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
        pqh_rng_shd.constraint_error('PQH_ATTRIBUTE_RANGES_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_position_id;
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
--   p_attribute_range_id PK
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
Procedure chk_routing_category_id (p_attribute_range_id          in number,
                            p_routing_category_id          in number,
                            p_object_version_number in number) is
  --
  l_proc             varchar2(72) := g_package||'chk_routing_category_id';
  l_api_updating     boolean;
  l_dummy            varchar2(1);
  l_tcat             pqh_routing_categories.transaction_category_id%type;
  l_freeze_status_cd pqh_transaction_categories.freeze_status_cd%type;
  --
  cursor c1 is
--    select null
    select transaction_category_id
    from   pqh_routing_categories a
    where  a.routing_category_id = p_routing_category_id;
  --
  cursor c2 is
  select nvl(freeze_status_cd,hr_api.g_varchar2)
  from   pqh_transaction_categories a
  where  a.transaction_category_id = l_tcat;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rng_shd.api_updating
     (p_attribute_range_id            => p_attribute_range_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_category_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.routing_category_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if routing_category_id value exists in pqh_routing_categories table
    --
    open c1;
      --
--      fetch c1 into l_dummy;
      fetch c1 into l_tcat;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_categories
        -- table.
        --
        pqh_rng_shd.constraint_error('PQH_ATTRIBUTE_RANGES_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  open c2;
  Fetch c2 into l_freeze_status_cd;
  close c2;

  if l_freeze_status_cd = 'FREEZE_CATEGORY' then
     hr_utility.set_message(8302, 'PQH_INVALID_RNG_OPERATION');
     hr_utility.raise_error;
  End if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_routing_category_id;
--

-- ----------------------------------------------------------------------------
-- |------< chk_routing_list_member_id >------|
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
--   p_attribute_range_id PK
--   p_routing_list_member_id ID of FK column
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
Procedure chk_routing_list_member_id (p_attribute_range_id          in number,
                            p_routing_list_member_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_list_member_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_routing_list_members a
    where  a.routing_list_member_id = p_routing_list_member_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rng_shd.api_updating
     (p_attribute_range_id            => p_attribute_range_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_list_member_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.routing_list_member_id,hr_api.g_number)
     or not l_api_updating) and
     p_routing_list_member_id is not null then
    --
    -- check if routing_list_member_id value exists in pqh_routing_list_members table
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
        pqh_rng_shd.constraint_error('PQH_ATTRIBUTE_RANGES_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_routing_list_member_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_valid_list_member_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks  if only either the routing_list_member_id /
--   position_id/ assignment_id is entered .
--   It also makes sure that the routing_list_member_id entered belongs
--   to the routing list associated with its routing category.
--   It also makes sure that the position_id entered belongs
--   to the position_structure associated with its routing category.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_attribute_range_id PK
--   p_routing_list_member_id ID of FK column
--   p_position_id ID            of FK column
--   p_assignment_id ID          of FK column
--   p_routing_category_id ID    of FK column
--   p_object_version_number     object version number
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
Procedure chk_valid_list_member_id (p_attribute_range_id          in number,
                                    p_attribute_id      in number,
                                    p_range_name      in varchar2,
                                    p_routing_list_member_id      in number,
                                    p_position_id                 in number,
                                    p_assignment_id               in number,
                                    p_routing_category_id         in number,
                                    p_object_version_number       in number) is
  --
  l_rlist_id1                pqh_routing_categories.routing_list_id%type;
  l_rlist_id2                pqh_routing_list_members.routing_list_id%type;
  l_enable_flag              pqh_routing_list_members.enable_flag%type;
  l_position_structure_id    pqh_routing_categories.position_structure_id%type;
  --
 Cursor csr_list_id is
    select nvl(routing_list_id,hr_api.g_number),
           nvl(position_structure_id,hr_api.g_number)
    from   pqh_routing_categories a
    where  a.routing_category_id = p_routing_category_id;
  --
 Cursor csr_routing_list_member is
    Select nvl(routing_list_id,hr_api.g_number),nvl(enable_flag,'N')
    from   pqh_routing_list_members a
    where  a.routing_list_member_id = p_routing_list_member_id;
 --
 Cursor csr_pos_in_pos_hier(p_position_structure_id in number) is
 select null
  from per_pos_structure_versions v, per_pos_structure_elements e
 where v.position_structure_id = p_position_structure_id
   and sysdate between v.date_from and
                   nvl(v.date_to,to_date('31-12-4712','dd-mm-RRRR'))
   and v.pos_structure_version_id = e.pos_structure_version_id
   and (e.subordinate_position_id = p_position_id or
        e.parent_position_id = p_position_id);
 --
 Cursor csr_new_attr_in_rule is
  Select 'x'
    From pqh_attribute_ranges
   Where attribute_id = p_attribute_id
     and range_name = p_range_name
     and routing_category_id = p_routing_category_id
     and routing_list_member_id = p_routing_list_member_id;
  --
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_proc         varchar2(72) := g_package||'chk_valid_list_member_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Select the routing list / position structure associated with the
  -- routingcategory.
  --
  Open csr_list_id;
  Fetch csr_list_id into l_rlist_id1,l_position_structure_id;
  Close csr_list_id;
  --
  l_api_updating := pqh_rng_shd.api_updating
     (p_attribute_range_id      => p_attribute_range_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_list_member_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.routing_list_member_id,hr_api.g_number)
     or not l_api_updating) and
     p_routing_list_member_id is not null then
    --
    -- Get the routing list to which the member belongs
    --
    Open csr_routing_list_member;
    Fetch csr_routing_list_member into l_rlist_id2,l_enable_flag;
    Close csr_routing_list_member;
    --
    -- Raise error if the member does not belong to the same routing list
    -- as the one attached to the routing category.
    --
    If l_rlist_id1 <> l_rlist_id2 then
       hr_utility.set_message(8302,'PQH_INVALID_ROUTING_LIST_MEM');
       hr_utility.raise_error;
    End if;

    If l_enable_flag <> 'Y' then
       If not l_api_updating then

          open csr_new_attr_in_rule;
          fetch csr_new_attr_in_rule into l_dummy;
          If csr_new_attr_in_rule%found then
             hr_utility.set_message(8302,'PQH_AUTHORIZER_NOT_ENABLED');
             hr_utility.raise_error;
          End if;
          Close csr_new_attr_in_rule;
       Else
          hr_utility.set_message(8302,'PQH_AUTHORIZER_NOT_ENABLED');
          hr_utility.raise_error;
       End if;
    End if;

    If p_position_id IS NOT NULL OR p_assignment_id  IS NOT NULL then
       hr_utility.set_message(8302,'PQH_MULTIPLE_MEMBER_TYPES');
       hr_utility.raise_error;
    End if;
    --
  end if;
  --
  -- Check if this position belong to the position structure associated
  -- with its routing category.
  -- Check if only position_id is not null
  --
  if (l_api_updating
     and nvl(p_position_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.position_id,hr_api.g_number)
     or not l_api_updating) and
     p_position_id is not null then
     --
     -- Get the position structure to which the position belongs
     --
     open csr_pos_in_pos_hier(p_position_structure_id=>l_position_structure_id);
     --
     fetch csr_pos_in_pos_hier into l_dummy;
     --
     if csr_pos_in_pos_hier%notfound then
        --
        -- raise error if the position does not belong to the same position
        -- structure as the one associated with the routing category.
        --
        close csr_pos_in_pos_hier;
        hr_utility.set_message(8302,'PQH_POS_NOT_IN_POS_HIER');
        hr_utility.raise_error;
        --
     end if;
     --
     Close csr_pos_in_pos_hier;
     --
     If p_routing_list_member_id IS NOT NULL OR
        p_assignment_id IS NOT NULL then
         --
         hr_utility.set_message(8302,'PQH_MULTIPLE_MEMBER_TYPES');
         hr_utility.raise_error;
         --
     End if;
    --
  end if;
  --
  -- Check if only assignment_id is not null
  --
  if (l_api_updating
     and nvl(p_assignment_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.assignment_id,hr_api.g_number)
     or not l_api_updating) and
     p_assignment_id is not null then
    --
      If p_routing_list_member_id IS NOT NULL OR p_position_id IS NOT NULL then
         hr_utility.set_message(8302,'PQH_MULTIPLE_MEMBER_TYPES');
         hr_utility.raise_error;
      End if;
    --
  end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_valid_list_member_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_attribute_id >------|
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
--   p_attribute_range_id PK
--   p_attribute_id ID of FK column
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
Procedure chk_attribute_id (p_attribute_range_id          in number,
                            p_attribute_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_attribute_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_attributes a
    where  a.attribute_id = p_attribute_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rng_shd.api_updating
     (p_attribute_range_id            => p_attribute_range_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_attribute_id,hr_api.g_number)
     <> nvl(pqh_rng_shd.g_old_rec.attribute_id,hr_api.g_number)
     or not l_api_updating)
     and p_attribute_id is not null then
    --
    -- check if attribute_id value exists in pqh_attributes table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_attributes
        -- table.
        --
        pqh_rng_shd.constraint_error('PQH_ATTRIBUTE_RANGES_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_if_valid_identifiers >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks  if the attribute id enetered is a valid
--   list / member identifier
--   Also checks if at least 1 range values are entered.
--   Also checks if the from and to values entered match the column type
--   if the attribute id.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_attribute_range_id PK
--   p_attribute_id ID of FK column
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
Procedure chk_if_valid_identifiers
                           (
                            p_attribute_range_id    in number,
                            p_routing_category_id   in number,
                            p_attribute_id          in number,
                            p_routing_list_member_id in number,
                            p_position_id           in number,
                            p_assignment_id         in number,
                            p_from_char             in varchar2,
                            p_to_char               in varchar2,
                            p_from_number           in number,
                            p_to_number             in number,
                            p_from_date             in date,
                            p_to_date               in date,
                            p_object_version_number in number) is
  --
  l_col_type          pqh_attributes.column_type%type;
  l_attribute_name    pqh_attributes.attribute_name%type;
  l_dummy_name        pqh_attributes.attribute_name%type;
  l_list_identifier   pqh_txn_category_attributes.list_identifying_flag%type;
  l_member_identifier pqh_txn_category_attributes.member_identifying_flag%type;
  l_tcat_id           pqh_txn_category_attributes.transaction_category_id%type;
  r_tcat_id           pqh_routing_categories.transaction_category_id%type;
  l_attribute_found   boolean := FALSE;
  --
  l_proc              varchar2(72) := g_package||'chk_if_valid_identifiers';
  l_api_updating      boolean;
  l_dummy             varchar2(1);
  --
  cursor c1 is
    select transaction_category_id
    from   pqh_routing_categories a
    where  a.routing_category_id = p_routing_category_id;

  cursor c2 (p_transaction_category_id in number) is
    select att.attribute_name,nvl(att.column_type,hr_api.g_varchar2),
           tca.transaction_category_id,
           nvl(tca.list_identifying_flag,hr_api.g_varchar2),
           nvl(tca.member_identifying_flag,hr_api.g_varchar2)
    from   pqh_txn_category_attributes tca,pqh_attributes att
    where  att.attribute_id = p_attribute_id
      AND  tca.attribute_id = att.attribute_id
      AND  tca.transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rng_shd.api_updating
     (p_attribute_range_id      => p_attribute_range_id,
      p_object_version_number   => p_object_version_number);
  --
  -- Attribute id may be null in case of rules for default hiearchy.
  -- Then we do no need to perform the foll checks.
  --
  If p_attribute_id is NOT NULL then
  --
  -- Obtain the transaction category of the routing category.
  --
  Open c1;
  Fetch c1 into r_tcat_id;
  Close c1;
  --
  -- check if attribute_id also belongs to this transaction category .
  -- Else there is a transaction category mismatch.
  --
  Open c2 (p_transaction_category_id =>  r_tcat_id);
  --
  fetch c2 into l_attribute_name,l_col_type,
                   l_tcat_id,l_list_identifier,l_member_identifier;
  --
  if c2%notfound then
     --
     Close c2;
     --
     -- raise error as this attribute does not belong to the same transaction
     -- category id as the routing category.
     --
     hr_utility.set_message(8302,'PQH_RNG_TCT_MISMATCH');
     hr_utility.set_message_token('ATTRIBUTE_NAME', l_attribute_name);
     hr_utility.raise_error;
     --
  End if;
  --
  Close c2;
  --
  --
  -- Check if this attribute is a valid list / member identifier
  --
  If p_routing_list_member_id IS NULL AND
          p_position_id IS NULL AND
          p_assignment_id IS NULL then
             if l_list_identifier <> 'Y' then
                hr_utility.set_message(8302,'PQH_NOT_LIST_IDENTIFIER');
                hr_utility.raise_error;
             End if;
   Else
            if l_member_identifier <> 'Y' then
                hr_utility.set_message(8302,'PQH_NOT_MEMBER_IDENTIFIER');
                hr_utility.raise_error;
             End if;
   End if;
   --
   -- Check if valid From and To range values are entered.
   --
   If l_col_type = 'V' then
   --
     if p_from_char IS NOT NULL and p_to_char IS NOT NULL and
        p_to_char < p_from_char then
        hr_utility.set_message(8302,'PQH_INVALID_TO_RANGE');
        hr_utility.raise_error;
     End if;
     --
     if p_from_date IS NOT NULL OR p_to_date IS NOT NULL
     OR p_from_number IS NOT NULL OR p_to_number IS NOT NULL then
        hr_utility.set_message(8302,'PQH_INVALID_RANGE_VALUES');
        hr_utility.raise_error;
     End if;
  --
  Elsif l_col_type = 'N' then
  --
     if p_from_number IS NOT NULL and p_to_number IS NOT NULL and
        p_to_number < p_from_number then

        hr_utility.set_message(8302,'PQH_INVALID_TO_RANGE');
        hr_utility.raise_error;
     End if;
     --
     if p_from_date IS NOT NULL OR p_to_date IS NOT NULL
     OR p_from_char IS NOT NULL OR p_to_char IS NOT NULL then
        hr_utility.set_message(8302,'PQH_INVALID_RANGE_VALUES');
        hr_utility.raise_error;
     End if;
  --
  Elsif l_col_type = 'D' then
  --
     --
     if p_from_date IS NOT NULL and p_to_date IS NOT NULL and
        p_to_date < p_from_date then
        hr_utility.set_message(8302,'PQH_INVALID_TO_RANGE');
        hr_utility.raise_error;
     End if;
     --
     if p_from_char IS NOT NULL OR p_to_char IS NOT NULL
     OR p_from_number IS NOT NULL OR p_to_number IS NOT NULL then
        hr_utility.set_message(8302,'PQH_INVALID_RANGE_VALUES');
        hr_utility.raise_error;
     End if;
  --
  End if;
  --
  End if; -- p_attribute_id IS NOT NULL
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_if_valid_identifiers;
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
--   attribute_range_id PK of record being inserted or updated.
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
Procedure chk_approver_flag(p_attribute_range_id                in number,
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
  l_api_updating := pqh_rng_shd.api_updating
    (p_attribute_range_id                => p_attribute_range_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_approver_flag
      <> nvl(pqh_rng_shd.g_old_rec.approver_flag,hr_api.g_varchar2)
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
--
FUNCTION chk_if_member_enabled(p_routing_list_id in number,
                               p_routing_list_member_id in number)
RETURN NUMBER is
--
Cursor csr_member_enabled is
 Select nvl(enable_flag,'N')
   From pqh_routing_list_members
  Where routing_list_id = p_routing_list_id
    And routing_list_member_id = p_routing_list_member_id;
--
l_enable_flag       pqh_routing_list_members.enable_flag%type;
l_proc              varchar2(72) := g_package||'chk_if_member_enabled';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  Open csr_member_enabled;
  --
  Fetch csr_member_enabled into l_enable_flag;
  --
  Close csr_member_enabled;
  --
  If l_enable_flag <> 'Y' then
     RETURN 1;
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  RETURN 0;
  --
End;
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
--   attribute_range_id PK of record being inserted or updated.
--   enable_flag Value of lookup code.
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
Procedure chk_enable_flag(p_attribute_range_id          in number,
                          p_enable_flag                 in varchar2,
                          p_routing_list_member_id      in number,
                          p_routing_category_id         in number,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  --
 Cursor csr_list_id is
    select nvl(routing_list_id,hr_api.g_number)
    from   pqh_routing_categories a
    where  a.routing_category_id = p_routing_category_id;
 --
  l_routing_list_id  pqh_routing_categories.routing_list_id%type;
  l_error_code       number(10) := NULL;
 --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rng_shd.api_updating
    (p_attribute_range_id                => p_attribute_range_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_rng_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
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
  end if;
  --
  if l_api_updating
      and p_enable_flag
      <> nvl(pqh_rng_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      and p_enable_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_enable_flag = 'Y' and p_routing_list_member_id IS NOT NULL then
       --
       Open csr_list_id;
       Fetch csr_list_id into l_routing_list_id;
       Close csr_list_id;
       --
       l_error_code := chk_if_member_enabled
                     (p_routing_list_id => l_routing_list_id,
                      p_routing_list_member_id => p_routing_list_member_id);
       --
       If l_error_code = 1 then
          --
          hr_utility.set_message(8302,'PQH_CANNOT_ENABLE_AUTH_RULE');
          hr_utility.raise_error;
          --
       End if;
       --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enable_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_delete_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attribute_range_id PK of record being inserted or updated.
--   delete_flag Value of lookup code.
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
Procedure chk_delete_flag(p_attribute_range_id          in number,
                          p_delete_flag                 in varchar2,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rng_shd.api_updating
    (p_attribute_range_id                => p_attribute_range_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_delete_flag
      <> nvl(pqh_rng_shd.g_old_rec.delete_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_delete_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_delete_flag,
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
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_delete_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rng_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_attribute_range_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_position_id          => p_rec.position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_category_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_routing_category_id          => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_list_member_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_valid_list_member_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_attribute_id                => p_rec.attribute_id,
   p_range_name                  => p_rec.range_name,
   p_routing_list_member_id      => p_rec.routing_list_member_id,
   p_position_id                 => p_rec.position_id,
   p_assignment_id               => p_rec.assignment_id,
   p_routing_category_id         => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_approver_flag
  (p_attribute_range_id    => p_rec.attribute_range_id,
   p_approver_flag         => p_rec.approver_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_enable_flag                 => p_rec.enable_flag,
   p_routing_category_id         => p_rec.routing_category_id,
   p_routing_list_member_id      => p_rec.routing_list_member_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_delete_flag
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_delete_flag                 => p_rec.delete_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_if_valid_identifiers
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_routing_category_id         => p_rec.routing_category_id,
   p_attribute_id                => p_rec.attribute_id,
   p_routing_list_member_id      => p_rec.routing_list_member_id,
   p_position_id                 => p_rec.position_id,
   p_assignment_id               => p_rec.assignment_id,
   p_from_char                   => p_rec.from_char,
   p_to_char                     => p_rec.to_char,
   p_from_number                 => p_rec.from_number,
   p_to_number                   => p_rec.to_number,
   p_from_date                   => p_rec.from_date,
   p_to_date                     => p_rec.to_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rng_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_attribute_range_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_position_id          => p_rec.position_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_category_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_routing_category_id          => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_routing_list_member_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_routing_list_member_id          => p_rec.routing_list_member_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_valid_list_member_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_attribute_id                => p_rec.attribute_id,
   p_range_name                  => p_rec.range_name,
   p_routing_list_member_id      => p_rec.routing_list_member_id,
   p_position_id                 => p_rec.position_id,
   p_assignment_id               => p_rec.assignment_id,
   p_routing_category_id         => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_attribute_id
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_attribute_id          => p_rec.attribute_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_approver_flag
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_approver_flag         => p_rec.approver_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_enable_flag
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_enable_flag                 => p_rec.enable_flag,
   p_routing_category_id         => p_rec.routing_category_id,
   p_routing_list_member_id      => p_rec.routing_list_member_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_delete_flag
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_delete_flag                 => p_rec.delete_flag,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_if_valid_identifiers
  (p_attribute_range_id          => p_rec.attribute_range_id,
   p_routing_category_id         => p_rec.routing_category_id,
   p_attribute_id                => p_rec.attribute_id,
   p_routing_list_member_id      => p_rec.routing_list_member_id,
   p_position_id                 => p_rec.position_id,
   p_assignment_id               => p_rec.assignment_id,
   p_from_char                   => p_rec.from_char,
   p_to_char                     => p_rec.to_char,
   p_from_number                 => p_rec.from_number,
   p_to_number                   => p_rec.to_number,
   p_from_date                   => p_rec.from_date,
   p_to_date                     => p_rec.to_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rng_shd.g_rec_type
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
end pqh_rng_bus;

/
