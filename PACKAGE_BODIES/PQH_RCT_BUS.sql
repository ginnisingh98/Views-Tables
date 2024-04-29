--------------------------------------------------------
--  DDL for Package Body PQH_RCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RCT_BUS" as
/* $Header: pqrctrhi.pkb 115.24 2004/02/19 13:29:18 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rct_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_routing_category_id >------|
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
--   routing_category_id PK of record being inserted or updated.
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
Procedure chk_routing_category_id
                          (p_routing_category_id         in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_category_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rct_shd.api_updating
    (p_routing_category_id                => p_routing_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_category_id,hr_api.g_number)
     <>  pqh_rct_shd.g_old_rec.routing_category_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_routing_category_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_routing_category_id;
--
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
--   p_routing_category_id PK
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
Procedure chk_transaction_category_id
                           (p_routing_category_id          in number,
                            p_transaction_category_id      in number,
                            p_object_version_number        in number) is
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
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id     => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating AND
        nvl(p_transaction_category_id,hr_api.g_number)
      = nvl(pqh_rct_shd.g_old_rec.transaction_category_id,hr_api.g_number)
     or not l_api_updating) then
       --
       -- check if transaction_category_id value exists in
       -- pqh_transaction_categories table
       --
       open c1;
       --
       fetch c1 into l_dummy;
       if c1%notfound then
         --
         close c1;
         --
         -- raise error as FK does not relate to PK in
         -- pqh_transaction_categories table.
         --
         pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_FK2');
         --
       end if;
       --
       close c1;
       --
       --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_transaction_category_id;
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
--   routing_category_id PK of record being inserted or updated.
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
Procedure chk_enable_flag (p_routing_category_id     in number,
                           p_enable_flag             in varchar2,
                           p_transaction_category_id in number,
                           p_effective_date          in date,
                           p_object_version_number   in number) is
  --
  l_error_code        number(10);
  l_error_range_name  pqh_attribute_ranges.range_name%type;
  l_overlap_range_name  pqh_attribute_ranges.range_name%type;
  l_error_routing_category varchar2(200);
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rct_shd.api_updating
    (p_routing_category_id         => p_routing_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_rct_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
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
  End if;
  --
  /**
  -- If we are trying to enable a previously disabled routing category then
  -- we need to make sure that the rules under this routing category do not
  -- overlap with any other rule in the same transaction category.
  --
  if l_api_updating and
     p_enable_flag = 'Y' and
     p_enable_flag <> nvl(pqh_rct_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
     then
     --
     hr_utility.set_location('Enable allow :'||l_proc,8);
     --
     l_error_code := pqh_ATTRIBUTE_RANGES_pkg.chk_enable_routing_category
                       (p_transaction_category_id => p_transaction_category_id,
                        p_routing_category_id     => p_routing_category_id,
                        p_overlap_range_name      => l_overlap_range_name,
                        p_error_routing_category  => l_error_routing_category,
                        p_error_range_name        => l_error_range_name
                       );
     --
     If l_error_code = 1 then
        --
        hr_utility.set_message(8302,'PQH_CANNOT_ENABLE_ROUTING_CAT');
        hr_utility.set_message_token('RANGE_NAME',l_overlap_range_name);
        hr_utility.set_message_token('ERR_RANGE',l_error_range_name);
        hr_utility.set_message_token('ERR_ROUTING',l_error_routing_category);
        hr_utility.raise_error;
        --
     End if;
     --
     hr_utility.set_location('Allowed:'||l_proc,9);
     --
  End if;
  --
  **/
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enable_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_default_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   routing_category_id PK of record being inserted or updated.
--   default_flag Value of lookup code.
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
Procedure chk_default_flag (p_routing_category_id     in number,
                           p_default_flag             in varchar2,
                           p_effective_date          in date,
                           p_object_version_number   in number) is
  --
  --
  l_proc         varchar2(72) := g_package||'chk_default_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rct_shd.api_updating
    (p_routing_category_id         => p_routing_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_default_flag
      <> nvl(pqh_rct_shd.g_old_rec.default_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_default_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_default_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_default_flag;
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
--   routing_category_id PK of record being inserted or updated.
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
Procedure chk_delete_flag (p_routing_category_id     in number,
                           p_delete_flag             in varchar2,
                           p_effective_date          in date,
                           p_object_version_number   in number) is
  --
  --
  l_proc         varchar2(72) := g_package||'chk_delete_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_rct_shd.api_updating
    (p_routing_category_id         => p_routing_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_delete_flag
      <> nvl(pqh_rct_shd.g_old_rec.delete_flag,hr_api.g_varchar2)
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
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_delete_flag;
--
---------------------------------------------------------------------------
--
-- Description : The foll procedure disallows any update of a transaction
-- category of a routing category .
-- Allows routing categories to be added or updated only if the transaction
-- categories attributes are frozen.
-- Allows a routing category to be disabled at any time though .
--
Procedure chk_ins_upd_routing_category
                           (p_routing_category_id          in number,
                            p_transaction_category_id      in number,
                            p_enable_flag                  in varchar2,
                            p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ins_upd_routing_category';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_freeze_status_cd pqh_transaction_categories.freeze_status_cd%type;
  --
  cursor c1 is
    select nvl(freeze_status_cd,hr_api.g_varchar2)
    from   pqh_transaction_categories a
    where  a.transaction_category_id = p_transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id     => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  -- Raise Error if trying to update the transaction category of the
  -- routing category.
  --
  if (l_api_updating AND
        nvl(p_transaction_category_id,hr_api.g_number)
     <> nvl(pqh_rct_shd.g_old_rec.transaction_category_id,hr_api.g_number)) then
       --
       -- Cannot update the transaction category id
       --
       hr_utility.set_message(8302,'PQH_NO_UPD_TRAN_CAT_OF_RCAT');
       hr_utility.raise_error;
       --
  End if;

  --
  open c1;
  --
  fetch c1 into l_freeze_status_cd;
  if c1%notfound then
  --
     close c1;
     --
     -- raise error as FK does not relate to PK in
     -- pqh_transaction_categories table.
     --
     pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_FK2');
     --
  end if;
  --
  close c1;
  --
  -- Check the freeze status cd. Do not allow any updates or inserts if
  -- transaction category is already been frozen.
  --
  If l_freeze_status_cd = 'FREEZE_CATEGORY' then
  --
     if l_api_updating  then
        --
        If nvl(pqh_rct_shd.g_old_rec.enable_flag,'Y')  = 'Y' then
        --
          hr_utility.set_message(8302,'PQH_NO_RCT_UPD_FROZEN_TCT');
          hr_utility.raise_error;
        --
        End if;
        --
      Else
        --
          hr_utility.set_message(8302,'PQH_NO_RCT_INS_FROZEN_TCT');
          hr_utility.raise_error;
        --
     End if;

  /**
  --
  -- If transaction category is in unfrozen state
  --
  Elsif l_freeze_status_cd IS NULL then
     --
     -- Raise Error,if trying to update details of a routing category other
     -- than its enable flag.
     --
     if l_api_updating  AND
        nvl(p_enable_flag,hr_api.g_varchar2)
      = nvl(pqh_rct_shd.g_old_rec.enable_flag,hr_api.g_varchar2) then
        --
          hr_utility.set_message(8302,'PQH_NO_UPDATE_ROUT_CAT');
          hr_utility.raise_error;
        --
     End if;
     --
     -- Disallow any inserts when the transaction category is in unfrozen
     -- state
     --
     If not l_api_updating then
        --
          hr_utility.set_message(8302,'PQH_NO_INSERT_ROUT_CAT');
          hr_utility.raise_error;
        --
     End if;
     --
  **/
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ins_upd_routing_category;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_list_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that  if a valid list id is entered
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_routing_category_id PK
--   p_routing_list_id ID         of FK column
--   p_position_structure_id ID   of FK column
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
Procedure chk_list_id (p_routing_category_id          in number,
                       p_routing_list_id              in number,
                       p_position_structure_id        in number,
                       p_transaction_category_id      in number,
                       p_object_version_number        in number) as
  --
  l_proc         varchar2(72) := g_package||'chk_list_id';
  l_api_updating boolean;
  l_member_cd    pqh_transaction_categories.member_cd%type;
  l_dummy        varchar2(1);
  --
  Cursor c1 is
    select a.member_cd
    from   pqh_transaction_categories a
    where  a.transaction_category_id = p_transaction_category_id;

  Cursor c2 is
    select null
    from pqh_attribute_ranges
    where routing_category_id = p_routing_category_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
    (p_routing_category_id     => p_routing_category_id,
     p_object_version_number   => p_object_version_number);

  open c1;
  Fetch c1 into l_member_cd;
  close c1;
  --
/**
  -- If the member cd is R only routing list id may be entered .
  -- Raise error if  Position structure id is not null .
  --
    if l_member_cd = 'R' then
       --
       -- Raise error if the routing list id is null
       --
       if p_routing_list_id IS NULL then
          hr_utility.set_message(8302,'PQH_ROUTING_LIST_ID_IS_NULL');
          hr_utility.raise_error;
       Else
          if (l_api_updating AND
             nvl(p_routing_list_id,hr_api.g_number)
             <> nvl(pqh_rct_shd.g_old_rec.routing_list_id,hr_api.g_number)) then
             --
             -- Disallow updates to routing list id field, if detail recs exist
             --
             open c2;
             Fetch c2 into l_dummy;
             if c2%found then
                close c2;
                hr_utility.set_message(8302,'PQH_CANNOT_UPD_LIST_ID');
                hr_utility.raise_error;
             End if;
             close c2;
             --
          End if;
       End if;
       --
       -- Raise Error if position structure id is not null
       --
       if p_position_structure_id IS NOT NULL then
          hr_utility.set_message(8302,'PQH_LIST_ID_NOT_MATCH_MEM_CD');
          hr_utility.raise_error;
       End if;
    --
    Elsif l_member_cd = 'P' then
       if p_position_structure_id IS NULL then
          hr_utility.set_message(8302,'PQH_POS_STRUCT_ID_IS_NULL');
          hr_utility.raise_error;
       Else
          if (l_api_updating AND
             nvl(p_position_structure_id,hr_api.g_number)
             <> nvl(pqh_rct_shd.g_old_rec.position_structure_id,hr_api.g_number)) then
             --
             -- Disallow updates to position_structure_id field, if detail recs exist
             --
             open c2;
             Fetch c2 into l_dummy;
             if c2%found then
                close c2;
                hr_utility.set_message(8302,'PQH_CANNOT_UPD_LIST_ID');
                hr_utility.raise_error;
             End if;
             close c2;
             --
          End if;
       End if;
       --
       -- Raise Error if routing list id is not null
       --
       if p_routing_list_id IS NOT NULL then
          hr_utility.set_message(8302,'PQH_LIST_ID_NOT_MATCH_MEM_CD');
          hr_utility.raise_error;
       End if;
    --
    Else
       if p_routing_list_id IS NOT NULL or p_position_structure_id IS NOT NULL then
          hr_utility.set_message(8302,'PQH_LIST_ID_NOT_MATCH_MEM_CD');
          hr_utility.raise_error;
       End if;
    End if;
  --
**/

 --
 if l_api_updating and nvl(p_routing_list_id,hr_api.g_number)
             <> nvl(pqh_rct_shd.g_old_rec.routing_list_id,hr_api.g_number) then
    --
    -- Disallow any updates to the routing list id if there are any
    -- child records for this routing category.
    --
    open c2;
    Fetch c2 into l_dummy;
    if c2%found then
       close c2;
       hr_utility.set_message(8302,'PQH_CANNOT_UPD_LIST_ID');
       hr_utility.raise_error;
    End if;
    close c2;
    --
 End if;
 --
 --
 -- Inserting a new routing category or updating the list id of an existing
 -- category.
 --
 if (l_api_updating and nvl(p_routing_list_id,hr_api.g_number)
             <> nvl(pqh_rct_shd.g_old_rec.routing_list_id,hr_api.g_number))
    OR NOT l_api_updating then
    --
    -- Validate if the member_cd matches the list id and a list_id that
    -- mismatches the member_cd is not supplied
    --
    if l_member_cd = 'R' then
       --
       If p_routing_list_id IS NULL then
          hr_utility.set_message(8302,'PQH_ROUTING_LIST_ID_IS_NULL');
          hr_utility.raise_error;
       End if;
       --
       if p_position_structure_id IS NOT NULL then
          hr_utility.set_message(8302,'PQH_LIST_ID_NOT_MATCH_MEM_CD');
          hr_utility.raise_error;
       End if;
       --
    Elsif l_member_cd = 'P' then
       If p_position_structure_id IS NULL then
          --
          hr_utility.set_message(8302,'PQH_POS_STRUCT_ID_IS_NULL');
          hr_utility.raise_error;
          --
       End if;
       --
       if p_routing_list_id IS NOT NULL then
          hr_utility.set_message(8302,'PQH_LIST_ID_NOT_MATCH_MEM_CD');
          hr_utility.raise_error;
       End if;
    Else
       if p_routing_list_id IS NOT NULL or
          p_position_structure_id IS NOT NULL then
          --
          hr_utility.set_message(8302,'PQH_LIST_ID_NOT_MATCH_MEM_CD');
          hr_utility.raise_error;
          --
       End if;
       --
    End if;
    --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_list_id;
--
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
--   p_routing_category_id PK
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
Procedure chk_routing_list_id (p_routing_category_id   in number,
                            p_routing_list_id          in number,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_routing_list_id';
  l_api_updating boolean;
  l_enable_flag  pqh_routing_lists.enable_flag%TYPE;
  --
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select nvl(enable_flag,'N')
    from   pqh_routing_lists a
    where  a.routing_list_id = p_routing_list_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id            => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_routing_list_id,hr_api.g_number)
     <> nvl(pqh_rct_shd.g_old_rec.routing_list_id,hr_api.g_number)
     or not l_api_updating) and
     p_routing_list_id is not null then
    --
    -- check if routing_list_id value exists in pqh_routing_lists table
    --
    open c1;
      --
      fetch c1 into l_enable_flag;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_lists
        -- table.
        --
        pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_FK1');
        --
      end if;
      --
    close c1;
    --
    -- Check if the Routing List is enabled .
    --
    if nvl(l_enable_flag,'N') = 'N' then
       --
       hr_utility.set_message(8302,'PQH_ROUTING_LIST_NOT_ENABLED');
       hr_utility.raise_error;
       --
    End if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_routing_list_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_override_role_id >------|
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
--   p_routing_category_id PK
--   p_override_role_id ID of FK column
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
Procedure chk_override_role_id (p_routing_category_id         in number,
                                  p_override_role_id          in number,
                                  p_object_version_number       in number) is
  --
  l_enable_flag       pqh_roles.enable_flag%type;
  --
  l_proc         varchar2(72) := g_package||'chk_override_role_id';
  l_api_updating boolean;
  --
  cursor c1 is
    select nvl(enable_flag,'N')
    from   pqh_roles a
    where  a.role_id = p_override_role_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id     => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_override_role_id,hr_api.g_number)
     <> nvl(pqh_rct_shd.g_old_rec.override_role_id,hr_api.g_number)
     or not l_api_updating) and
     p_override_role_id is not null then
      --
      -- check if override_role_id value exists in
      -- pqh_roles table
      --
      open c1;
      --
      fetch c1 into l_enable_flag;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_routing_list_members
        -- table.
        --
        hr_utility.set_message(8302,'PQH_INVALID_OVERRIDE_ROLE');
        hr_utility.raise_error;
        --
      end if;
      --
      close c1;
      --
      -- When adding a new routing list or updating the override member,
      -- Check if the override member is a enabled member.
      --
      if nvl(l_enable_flag,'N') <> 'Y' then
         --
         hr_utility.set_message(8302,'PQH_OVERRIDE_ROLE_NOT_ENABLED');
         hr_utility.raise_error;
         --
      End if;
  --
  end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_override_role_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_override_user_id >------|
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
--   p_routing_category_id PK
--   p_override_user_id ID of FK column
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
Procedure chk_override_user_id (p_routing_category_id         in number,
                                p_override_role_id            in number,
                                p_override_user_id            in number,
                                p_object_version_number       in number) is
  --
  l_dummy        varchar2(1);
  --
  l_proc         varchar2(72) := g_package||'chk_override_user_id';
  l_api_updating boolean;
  --
  cursor c1 is
    select null
    from   fnd_user a
    where  a.user_id = p_override_user_id;
  --
  cursor c2 is
    select null
      from pqh_role_users_v
     Where user_id = p_override_user_id
       and role_id = p_override_role_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id     => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_override_user_id,hr_api.g_number)
     <> nvl(pqh_rct_shd.g_old_rec.override_user_id,hr_api.g_number)
     or not l_api_updating) and
     p_override_user_id is not null then
      --
      -- check if override_user_id value exists in
      -- pqh_roles table
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
        hr_utility.set_message(8302,'PQH_INVALID_OVERRIDE_USER');
        hr_utility.raise_error;
        --
      end if;
      --
      close c1;
      --
  end if;
  --
  If p_override_user_id IS NOT NULL then
     --
     If p_override_role_id IS NULL then
        --
        -- Should not be able to enter user without entering override role.
        --
        hr_utility.set_message(8302,'PQH_NO_OVERRIDE_ROLE_FOR_USER');
        hr_utility.raise_error;
        --
     Else
        --
        -- Check if user belongs to the override role specified.
        --
        open c2;
        --
        fetch c2 into l_dummy;
        if c2%notfound then
           --
           close c2;
           --
           -- raise error
           --
           hr_utility.set_message(8302,'PQH_USER_NOT_IN_OVERRIDE_ROLE');
           hr_utility.raise_error;
           --
         end if;
         --
         close c2;
         --
      End if;
      --
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_override_user_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_position_structure_id >------|
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
--   p_routing_category_id PK
--   p_position_structure_id ID of FK column
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
Procedure chk_position_structure_id (p_routing_category_id          in number,
                            p_position_structure_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_structure_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_position_structures a
    where  a.position_structure_id = p_position_structure_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id            => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_structure_id,hr_api.g_number)
     <> nvl(pqh_rct_shd.g_old_rec.position_structure_id,hr_api.g_number)
     or not l_api_updating) and
     p_position_structure_id is not null then
    --
    -- check if position_structure_id value exists in per_position_structures table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_position_structures
        -- table.
        --
        pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_position_structure_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_override_position_id >------|
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
--   p_routing_category_id PK
--   p_override_position_id ID of FK column
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
Procedure chk_override_position_id (p_routing_category_id        in number,
                                    p_override_position_id       in number,
                                    p_object_version_number      in number) is
 --
 l_proc         varchar2(72) := g_package||'chk_override_position_id';
 l_api_updating boolean;
 l_dummy        varchar2(1);
 --
 cursor c1 is
   select null
   from   hr_all_positions_f a
   where  a.position_id = p_override_position_id;
 --
 /**
 Cursor csr_pos_in_pos_hier is
 select null
  from per_pos_structure_versions v, per_pos_structure_elements e
 where v.position_structure_id = p_position_structure_id
   and sysdate between v.date_from and
                   nvl(v.date_to,to_date('31-12-4712','dd-mm-RRRR'))
   and v.pos_structure_version_id = e.pos_structure_version_id
   and (e.subordinate_position_id = p_override_position_id or
        e.parent_position_id = p_override_position_id);
 --
 **/
 --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rct_shd.api_updating
     (p_routing_category_id            => p_routing_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_override_position_id,hr_api.g_number)
     <> nvl(pqh_rct_shd.g_old_rec.override_position_id,hr_api.g_number)
     or not l_api_updating) and
     p_override_position_id is not null then
      --
      -- check if override_position_id value exists in hr_all_positions_f table
      --
      open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_all_positions_f
        -- table.
        --
        pqh_rct_shd.constraint_error('PQH_ROUTING_CATEGORIES_FK4');
        --
      end if;
      --
      close c1;
      --
  end if;
  --
  /**
  -- If updating either position_strcuture or override_position
  -- or if inserting a new routing category using a position hierarchy ,
  -- Check if the override position is within the position hierarchy
  --
  if p_override_position_id is not null then
     --
     -- Check if the position belongs to the position structure
     --
     open csr_pos_in_pos_hier;
     --
     fetch csr_pos_in_pos_hier into l_dummy;
     --
     if csr_pos_in_pos_hier%notfound then
        --
        -- raise error
        --
        close csr_pos_in_pos_hier;
        hr_utility.set_message(8302,'PQH_POS_NOT_IN_POS_HIER');
        hr_utility.raise_error;
        --
     end if;
     --
     Close csr_pos_in_pos_hier;
     --
  End if;
  --
  **/
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_override_position_id;
--
--------------------------------------------------------------------------
--
-- Disallow creating routing category if there already exists a routing
-- category with null rule under it
--
Procedure chk_universal_routing_exists(p_transaction_category_id in number,
                                       p_default_flag            in varchar2)
is
--
--
TYPE cur_type        IS REF CURSOR;
csr_univ_routing     cur_type;
sql_stmt             varchar2(1000);
--
Cursor csr_routing_type is
  Select member_cd
    From pqh_transaction_categories
   Where transaction_category_id = p_transaction_category_id;
--
--
l_routing_type                pqh_transaction_categories.member_cd%type;
--
l_prev_routing_cat            pqh_routing_categories.routing_category_id%type;
l_prev_range_name             pqh_attribute_ranges.range_name%type;
l_prev_list_name              varchar2(250);
null_rule_flag                varchar2(1);
--
l_routing_category_id         pqh_routing_categories.routing_category_id%type;
l_list_name                   varchar2(250);
l_range_name                  pqh_attribute_ranges.range_name%type;
l_attribute_id                pqh_attribute_ranges.attribute_id%type;
l_from_char                   pqh_attribute_ranges.from_char%type;
l_to_char                     pqh_attribute_ranges.to_char%type;
l_from_number                 pqh_attribute_ranges.from_number%type;
l_to_number                   pqh_attribute_ranges.to_number%type;
l_from_date                   pqh_attribute_ranges.from_date%type;
l_to_date                     pqh_attribute_ranges.to_date%type;
--
--
  l_proc         varchar2(72) := g_package||'chk_universal_routing_exists';
--
--
Begin
--
--
hr_utility.set_location('Entering:'||l_proc,10);
--
-- We need to do the below validations , only if we are trying to create
-- a non-default routing category.
--
If nvl(p_default_flag,'N') <> 'Y' then
  --
  Open csr_routing_type;
  Fetch csr_routing_type into l_routing_type;
  Close csr_routing_type;
  --
  l_prev_routing_cat := NULL;
  l_prev_list_name   := NULL;
  l_prev_range_name  := hr_api.g_varchar2; -- some random value
  null_rule_flag := 'N';
  --
  If l_routing_type = 'R' then
     sql_stmt := 'select b.routing_category_id,RLT.routing_list_name list_name,';
  elsif l_routing_type = 'P' then
     sql_stmt := 'select b.routing_category_id,PPS.name list_name,';
  Else
     sql_stmt := 'select b.routing_category_id,hr_general.decode_lookup('
                ||''''||'PQH_SUPERVISORY_HIERARCHY'||''''||','
                ||''''||'SUPERVISORY_HIERARCHY'||''''||'),';
  End if;

  sql_stmt := sql_stmt ||'a.range_name, a.attribute_id, a.from_char, a.to_char, a.from_number, a.to_number, a.from_date, a.to_date from pqh_attribute_ranges a,pqh_routing_categories b, pqh_routing_lists RLT, per_position_structures PPS ';

  sql_stmt := sql_stmt ||' Where b.transaction_category_id = :p_transaction_category_id and  b.enable_flag = :p_enable_flag '
                       ||' and nvl(b.default_flag,:null_val) <> :p_default_flag and nvl(b.delete_flag,:null_val2) <> :p_delete_flag and b.routing_category_id = a.routing_category_id(+) ';


  If l_routing_type = 'R' then
     sql_stmt := sql_stmt ||' AND b.routing_list_id = RLT.routing_list_id ';
  elsif l_routing_type = 'P' then
     sql_stmt := sql_stmt ||' AND b.position_structure_id = PPS.position_structure_id ';
  Else
     sql_stmt := sql_stmt ||' AND b.routing_list_id is null AND b.position_structure_id is null ';
  End if;

  sql_stmt := sql_stmt || ' and a.routing_list_member_id(+) is null and a.position_id(+) is null and a.assignment_id(+) is null order by 1,2,3';
  --
  Open csr_univ_routing for sql_stmt using p_transaction_category_id,
                                           'Y','N','Y','N','Y';
  --
  Loop
    --
    Fetch csr_univ_routing into l_routing_category_id,l_list_name,l_range_name,
                                l_attribute_id,l_from_char,l_to_char,
                                l_from_number,l_to_number,l_from_date,l_to_date;
    --
    If csr_univ_routing%notfound then
       Exit;
    End if;
    --
    -- Check If we are in the same rule under a routing category
    --
    If l_prev_routing_cat = l_routing_category_id  AND
       l_prev_range_name = l_range_name then
    --
       If l_from_char IS NOT NULL or l_to_char IS NOT NULL or
          l_from_number IS NOT NULL or l_to_number IS NOT NULL or
          l_from_date IS NOT NULL or l_to_date IS NOT NULL then
          --
          null_rule_flag := 'N';
          --
       End if;
    --
    Else
    --
    -- If this is new rule , check if the previous was a null rule.
    -- Also check if the prev routing category had any rule at all .
    -- Depending on the case , raise a meaningful message.
    --
       If null_rule_flag = 'Y' then
          --
          Close csr_univ_routing;
          --
          If l_prev_range_name IS NULL then
          --
             hr_utility.set_message(8302,'PQH_RCT_WITH_NO_RULE_EXISTS');
             hr_utility.set_message_token('LIST_NAME',l_prev_list_name);
             hr_utility.raise_error;
          --
          Else
          --
             hr_utility.set_message(8302,'PQH_NULL_RULE_EXISTS');
             hr_utility.set_message_token('LIST_NAME',l_prev_list_name);
             hr_utility.raise_error;
          --
          End if;
          --
       End if;
       --
       -- If it was not a null rule , then re-initialise variables
       -- and proceed processing next rule .
       --
       l_prev_routing_cat := l_routing_category_id;
       l_prev_list_name   := l_list_name;
       l_prev_range_name  := l_range_name;
       null_rule_flag := 'Y';
       --
       --
       If l_from_char IS NOT NULL or l_to_char IS NOT NULL or
          l_from_number IS NOT NULL or l_to_number IS NOT NULL or
          l_from_date IS NOT NULL or l_to_date IS NOT NULL then
          --
          null_rule_flag := 'N';
          --
       End if;
       --
    End if;
    --
  End loop;
  --
  Close csr_univ_routing;
  --
  --
  -- check if the last rule was a null rule.
  --
  If null_rule_flag = 'Y' then
     --
     If l_prev_range_name IS NULL then
        --
        hr_utility.set_message(8302,'PQH_RCT_WITH_NO_RULE_EXISTS');
        hr_utility.set_message_token('LIST_NAME',l_prev_list_name);
        hr_utility.raise_error;
        --
     Else
        --
        hr_utility.set_message(8302,'PQH_NULL_RULE_EXISTS');
        hr_utility.set_message_token('LIST_NAME',l_prev_list_name);
        hr_utility.raise_error;
        --
     End if;
     --
  End if;
  --
End if;
--
--
hr_utility.set_location('Leaving:'||l_proc,10);
--
--
End;
--
------------------------------------------------------------------------------
--
Function chk_if_routing_cat_exists
(p_transaction_category_id in pqh_transaction_categories.transaction_category_id%type,
 p_routing_type            in pqh_transaction_categories.member_cd%type)
--
RETURN BOOLEAN is
  --
  -- Declare cursors and local variables
  --
  type cur_type IS REF CURSOR;
  rct_cur          cur_type;
  sql_stmt         varchar2(1000);
  --
  l_routing_category_id    pqh_routing_categories.routing_category_id%type;
  --
  l_proc varchar2(72) := g_package||'chk_if_routing_cat_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  sql_stmt := 'Select routing_category_id from pqh_routing_categories where transaction_category_id = :t';
  --
  -- Select only the routing categories that belong to the current routing
  -- type of the transaction category.
  --
  If p_routing_type = 'R' then
     --
     sql_stmt := sql_stmt ||' and routing_list_id is not null';
     --
  Elsif p_routing_type = 'P' then
     --
     sql_stmt := sql_stmt ||' and position_structure_id is not null';
     --
  Else
     --
     sql_stmt := sql_stmt ||' and routing_list_id is null and position_structure_id is null';
     --
  End if;
  --
  Open rct_cur for sql_stmt using p_transaction_category_id;
  --
  Fetch rct_cur into l_routing_category_id;
  --
  If rct_cur%found then
     RETURN TRUE;
  End if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 70);
  --
  RETURN FALSE;
  --
End;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_rct_shd.g_rec_type
                          ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_routing_category_id
  (p_routing_category_id         => p_rec.routing_category_id,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ins_upd_routing_category
  (p_routing_category_id          => p_rec.routing_category_id,
   p_transaction_category_id      => p_rec.transaction_category_id,
   p_enable_flag                  => p_rec.enable_flag,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_list_id
  (p_routing_category_id      => p_rec.routing_category_id,
   p_routing_list_id          => p_rec.routing_list_id,
   p_position_structure_id    => p_rec.position_structure_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  /**
  chk_universal_routing_exists
   (p_transaction_category_id          => p_rec.transaction_category_id,
    p_default_flag                     => p_rec.default_flag);
  **/
  --
  chk_enable_flag
  (p_routing_category_id          => p_rec.routing_category_id,
   p_enable_flag                  => p_rec.enable_flag,
   p_transaction_category_id      => p_rec.transaction_category_id,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_default_flag
  (p_routing_category_id          => p_rec.routing_category_id,
   p_default_flag                 => p_rec.default_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_delete_flag
  (p_routing_category_id          => p_rec.routing_category_id,
   p_delete_flag                 => p_rec.delete_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_routing_list_id
  (p_routing_category_id      => p_rec.routing_category_id,
   p_routing_list_id          => p_rec.routing_list_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_override_role_id
  (p_routing_category_id         => p_rec.routing_category_id,
   p_override_role_id          => p_rec.override_role_id,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_override_user_id
  (p_routing_category_id         => p_rec.routing_category_id,
   p_override_role_id          => p_rec.override_role_id,
   p_override_user_id          => p_rec.override_user_id,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_position_structure_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_position_structure_id          => p_rec.position_structure_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_override_position_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_override_position_id         => p_rec.override_position_id,
   p_object_version_number        => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_rct_shd.g_rec_type
                          ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_routing_category_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transaction_category_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_transaction_category_id      => p_rec.transaction_category_id,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_ins_upd_routing_category
  (p_routing_category_id          => p_rec.routing_category_id,
   p_transaction_category_id      => p_rec.transaction_category_id,
   p_enable_flag                  => p_rec.enable_flag,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_list_id
  (p_routing_category_id      => p_rec.routing_category_id,
   p_routing_list_id          => p_rec.routing_list_id,
   p_position_structure_id    => p_rec.position_structure_id,
   p_transaction_category_id  => p_rec.transaction_category_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_routing_category_id          => p_rec.routing_category_id,
   p_enable_flag                  => p_rec.enable_flag,
   p_transaction_category_id      => p_rec.transaction_category_id,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_default_flag
  (p_routing_category_id          => p_rec.routing_category_id,
   p_default_flag                 => p_rec.default_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_delete_flag
  (p_routing_category_id          => p_rec.routing_category_id,
   p_delete_flag                 => p_rec.delete_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_routing_list_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_routing_list_id          => p_rec.routing_list_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_override_role_id
  (p_routing_category_id         => p_rec.routing_category_id,
   p_override_role_id          => p_rec.override_role_id,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_override_user_id
  (p_routing_category_id         => p_rec.routing_category_id,
   p_override_role_id          => p_rec.override_role_id,
   p_override_user_id          => p_rec.override_user_id,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_position_structure_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_position_structure_id          => p_rec.position_structure_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_override_position_id
  (p_routing_category_id          => p_rec.routing_category_id,
   p_override_position_id         => p_rec.override_position_id,
   p_object_version_number        => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_rct_shd.g_rec_type
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
end pqh_rct_bus;


/
