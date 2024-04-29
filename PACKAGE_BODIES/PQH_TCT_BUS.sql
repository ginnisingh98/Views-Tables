--------------------------------------------------------
--  DDL for Package Body PQH_TCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_BUS" as
/* $Header: pqtctrhi.pkb 120.4.12000000.2 2007/04/19 12:48:04 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tct_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_transaction_category_id >------|
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
--   transaction_category_id PK of record being inserted or updated.
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
Procedure chk_transaction_category_id(p_transaction_category_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transaction_category_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id                => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_transaction_category_id,hr_api.g_number)
     <>  pqh_tct_shd.g_old_rec.transaction_category_id) then
    --
    -- raise error as PK has changed
    --
    pqh_tct_shd.constraint_error('PQH_TRANSACTION_CATEGORIES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_transaction_category_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_tct_shd.constraint_error('PQH_TRANSACTION_CATEGORIES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_transaction_category_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_consolid_table_route_id >------|
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
--   p_transaction_category_id PK
--   p_consolidated_table_route_id ID of FK column
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
Procedure chk_consolid_table_route_id (p_transaction_category_id          in number,
                            p_consolidated_table_route_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_consolid_table_route_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_table_route a
    where  a.table_route_id = p_consolidated_table_route_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tct_shd.api_updating
     (p_transaction_category_id            => p_transaction_category_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_consolidated_table_route_id,hr_api.g_number)
     <> nvl(pqh_tct_shd.g_old_rec.consolidated_table_route_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if consolidated_table_route_id value exists in pqh_table_route table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_table_route
        -- table.
        --
        pqh_tct_shd.constraint_error('PQH_TRANSACTION_CATEGORIES_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_consolid_table_route_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_master_table_route_id >------|
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
--   p_transaction_category_id PK
--   p_master_table_route_id ID of FK column
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
Procedure chk_master_table_route_id
                           (p_transaction_category_id        in number,
                            p_master_table_route_id          in number,
                            p_object_version_number          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_master_table_route_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_table_route a
    where  a.table_route_id = p_master_table_route_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tct_shd.api_updating
     (p_transaction_category_id    => p_transaction_category_id,
      p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_master_table_route_id,hr_api.g_number)
      <> nvl(pqh_tct_shd.g_old_rec.master_table_route_id,hr_api.g_number)
      or not l_api_updating)
     and p_master_table_route_id IS NOT NULL then
    --
    -- check if master_table_route_id value exists in pqh_table_route table
    --
      open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_table_route
        -- table.
        --
        pqh_tct_shd.constraint_error('PQH_TRANSACTION_CATEGORIES_FK2');
        --
        --
      end if;
      --
      close c1;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_master_table_route_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_business_group_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
--
Procedure chk_business_group_id
                           (p_transaction_category_id  in number,
                            p_business_group_id        in number,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_business_group_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_tct_shd.api_updating
     (p_transaction_category_id    => p_transaction_category_id,
      p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_business_group_id,hr_api.g_number)
      <> nvl(pqh_tct_shd.g_old_rec.business_group_id,hr_api.g_number)
      or not l_api_updating)
      and p_business_group_id is not null then
      --
      -- check if business_group_id exists in hr_all_organization_units table
      --
      open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        hr_utility.set_message(8302,'PQH_INVALID_BUSINESS_GROUP');
        hr_utility.raise_error;
        --
      End if;
      --
      Close c1;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_business_group_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_setup_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   setup_type_cd Value of lookup code.
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
Procedure chk_setup_type_cd
                           (p_transaction_category_id     in number,
                            p_setup_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_setup_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id     => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_setup_type_cd
      <> nvl(pqh_tct_shd.g_old_rec.setup_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_setup_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_TXN_CAT_SETUP_TYPE',
           p_lookup_code    => p_setup_type_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    End if;
    --
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_setup_type_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_route_validated_txn_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   route_validated_txn_flag Value of lookup code.
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
Procedure chk_route_validated_txn_flag(p_transaction_category_id                in number,
                            p_route_validated_txn_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_route_validated_txn_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id                => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_route_validated_txn_flag
      <> nvl(pqh_tct_shd.g_old_rec.route_validated_txn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_route_validated_txn_flag,
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
end chk_route_validated_txn_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_workflow_enable_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   route_validated_txn_flag Value of lookup code.
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
Procedure chk_workflow_enable_flag(p_transaction_category_id                in number,
                            p_workflow_enable_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_workflow_enable_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id     => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_workflow_enable_flag
      <> nvl(pqh_tct_shd.g_old_rec.workflow_enable_flag,hr_api.g_varchar2)
      or not l_api_updating) and
      p_workflow_enable_flag is NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_workflow_enable_flag,
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
end chk_workflow_enable_flag;
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
--   transaction_category_id PK of record being inserted or updated.
--   route_validated_txn_flag Value of lookup code.
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
Procedure chk_enable_flag(p_transaction_category_id                in number,
                            p_enable_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id     => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_tct_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      or not l_api_updating) and
      p_enable_flag is NOT NULL then
    --
    -- check if value of lookup falls within lookup type.
    --
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
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enable_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_post_style_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   post_style_cd Value of lookup code.
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
Procedure chk_post_style_cd(p_transaction_category_id                in number,
                            p_post_style_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_post_style_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id                => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_post_style_cd
      <> nvl(pqh_tct_shd.g_old_rec.post_style_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_POST_STYLE',
           p_lookup_code    => p_post_style_cd,
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
end chk_post_style_cd;
--
--
--
Procedure chk_member_cd_upd_allowed(p_transaction_category_id in number)
is
  --
  l_dummy        varchar2(1);
  l_proc         varchar2(72) := g_package||'chk_member_cd_upd_allowed';
  --
Cursor c1 is
   Select null
   from pqh_routing_categories a
   where a.transaction_category_id = p_transaction_category_id
     and nvl(a.enable_flag,'N') = 'Y';
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c1;
  --
  Fetch c1 into l_dummy;
  if c1%found then
     --
     Close c1;
     hr_utility.set_message(8302,'PQH_INVALID_MEMBER_CD_UPD');
     hr_utility.raise_error;
     --
  End if;
  Close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_member_cd_upd_allowed;
--
-- ----------------------------------------------------------------------------
-- |------< chk_member_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   member_cd Value of lookup code.
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
Procedure chk_member_cd(p_transaction_category_id     in number,
                        p_member_cd                   in varchar2,
                        p_freeze_status_cd            in varchar2,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_member_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id     => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_member_cd
      <> nvl(pqh_tct_shd.g_old_rec.member_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_MEMBER_CD',
           p_lookup_code    => p_member_cd,
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
  -- Allow member code to be updated only if there are no enabled routing
  -- categories under the transaction category.
  --
  /****
  if l_api_updating
      and p_member_cd
      <> nvl(pqh_tct_shd.g_old_rec.member_cd,hr_api.g_varchar2)  then
     --
     chk_member_cd_upd_allowed
        (p_transaction_category_id =>  p_transaction_category_id);
     --
  End if;
  ****/
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_member_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_future_action_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   future_action_cd Value of lookup code.
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
Procedure chk_future_action_cd(p_transaction_category_id                in number,
                            p_future_action_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_future_action_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id                => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_future_action_cd
      <> nvl(pqh_tct_shd.g_old_rec.future_action_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_FUTURE_ACTION',
           p_lookup_code    => p_future_action_cd,
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
end chk_future_action_cd;
--
-- ----------------------------------------------------------------------------
-- |                ------< chk_valid_routing_exists >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check  if there is at least one routing
--   category under a transaction_category .
--   If there are any list identifiers defined , then there must be at least
--   1 routing rule defined under each routing category .
--   If there are no list identfiers defined , there must be one routing
--   category with no rules . All the above checks are performed on trying to
--   freeze the transaction category.
--
--
Procedure chk_valid_routing_exists
                           (p_transaction_category_id     in number,
                            p_routing_type                in varchar2) is
  --
  -- The foll cursor checks if any list identifers have been defined
  -- for a transaction category.
  --
  Cursor csr_list_ident_defined is
   Select count(*)
     From pqh_txn_category_attributes
    Where transaction_category_id = p_transaction_category_id
      AND list_identifying_flag = 'Y';
  --
  --
  TYPE cur_type        IS REF CURSOR;
  csr_routing          cur_type;
  sql_stmt             varchar2(1000);
  --
  csr_auth1            cur_type;
  csr_auth2            cur_type;
  sql_stmt1            varchar2(1000);
  sql_stmt2            varchar2(1000);
  --
  l_no_of_list_ident          number(10) := 0;
  l_rec_count                 number(10) := 0;
  l_no_of_rules               number(10) := 0;
  --
  l_routing_category_id       pqh_routing_categories.routing_category_id%type;
  l_list_name                 varchar2(200);
  --
  l_dummy                     varchar2(1);
  --
  l_proc         varchar2(72) := g_package||'chk_valid_routing_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the number of list identifiers.
  --
  Open csr_list_ident_defined;
  --
  Fetch csr_list_ident_defined into l_no_of_list_ident;
  --
  Close csr_list_ident_defined;
  --
  --
  -- The foll cursor selects the no of enabled routing categories exist for a
  -- transaction category,and how many routing rules exists under each routing
  -- category.
  --
  sql_stmt := 'Select rct.routing_category_id, count(rng.range_name)'
           || ' from pqh_routing_categories rct,pqh_attribute_ranges rng'
           || ' Where rct.transaction_category_id = :p_transaction_category_id'
           || '   and rct.enable_flag = :p_enable_flag'
           || '   and nvl(rct.default_flag,:dummy1) <> :yes_flag1 '
           || '   and nvl(rct.delete_flag,:dummy2) <> :yes_flag2 ';
  --
  If p_routing_type = 'R' then
     sql_stmt := sql_stmt || ' and rct.routing_list_id IS NOT NULL';
  Elsif p_routing_type = 'P' then
     sql_stmt := sql_stmt || ' and rct.position_structure_id IS NOT NULL';
  Else
     sql_stmt := sql_stmt || ' and rct.routing_list_id IS NULL and rct.position_structure_id IS NULL';
  End if;
  --
  sql_stmt := sql_stmt || ' and rct.routing_category_id = rng.routing_category_id(+)'
           || ' and rng.enable_flag(+) = :p_rule_enable'
           || ' and nvl(rng.delete_flag(+),:dummy3) <> :yes_flag3'
           || ' and rng.routing_list_member_id(+) IS NULL'
           || ' and rng.position_id(+) IS NULL'
           || ' and rng.assignment_id(+) IS NULL'
     || ' group by rct.routing_category_id'
     || ' order by rct.routing_category_id';
  --
  -- Select the no of routing categories and no of rules under the routing
  -- category.
  --
  --
  Open csr_routing for sql_stmt using p_transaction_category_id,
                                      'Y','N','Y','N','Y','Y','N','Y';
  --
  l_rec_count := 0;
  --
  Loop
    --
    Fetch csr_routing into l_routing_category_id,l_no_of_rules;
    --
    If csr_routing%notfound then
       exit;
    End if;
    --
    l_rec_count := l_rec_count + 1;
    --
    -- List identfiers exist , but no rules were defined for this routing
    -- category. We need to make this check only if the routing type is
    -- routing list though ..
    --
--    If p_routing_type = 'R' and
    If l_no_of_rules = 0  and  l_no_of_list_ident > 0 then
       --
       Close csr_routing;
       --
       get_routing_category_name
                                (p_routing_category_id =>l_routing_category_id,
                                 p_routing_category_name=> l_list_name);
       --
       hr_utility.set_message(8302,'PQH_NO_RULES_IN_ROUTING_CAT');
       hr_utility.set_message_token('LIST_NAME', l_list_name);
       hr_utility.raise_error;
       --
    End if;
    --
  End loop;
  --
  Close csr_routing;
  --
  -- The transaction category must have at least one routing category though
  --
  If l_rec_count = 0 then
     hr_utility.set_message(8302,'PQH_NO_ROUTING_CAT_IN_TCT');
     hr_utility.raise_error;
  End if;
  --
  -- Position and Supervisory hierarchy must have at least one member rule
  -- with approver flag set to 'Y'.
  --
  If p_routing_type = 'P' or p_routing_type = 'S' then
     --
     sql_stmt1 :='Select rct.routing_category_id'
             ||' from pqh_routing_categories rct'
             ||' Where rct.transaction_category_id=:p_transaction_category_id'
             ||' and rct.enable_flag = :p_enable_flag'
             ||' and nvl(rct.default_flag,:dummy1) <> :p_default_flag'
             ||' and nvl(rct.delete_flag,:dummy2) <> :p_delete_flag';
     --
     sql_stmt2 := 'Select null from pqh_attribute_ranges'
                ||' Where routing_category_id = :p_routing_category_id'
                ||'   and enable_flag   = :p_enable_flag'
                ||'   and approver_flag = :p_approver_flag';
     --
     If p_routing_type = 'P' then
        --
        sql_stmt1 := sql_stmt1 || ' and rct.position_structure_id IS NOT NULL';
        sql_stmt2 := sql_stmt2 || ' and position_id IS NOT NULL';
        --
     Elsif  p_routing_type = 'S' then
        --
        sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id IS NULL and rct.position_structure_id IS NULL';
        sql_stmt2 := sql_stmt2 || ' and assignment_id IS NOT NULL';
        --
     End if;
     --
     --
     Open csr_auth1 for sql_stmt1 using p_transaction_category_id,
                                        'Y','N','Y','N','Y';
     --
     Loop
        --
        Fetch csr_auth1 into l_routing_category_id;
        --
        If csr_auth1%notfound then
           exit;
        End if;
        --
        Open csr_auth2 for sql_stmt2 using l_routing_category_id,'Y','Y';
        --
        Fetch csr_auth2 into l_dummy;
        --
        If csr_auth2%notfound then
          --
          Close csr_auth2;
          --
          get_routing_category_name
                  (p_routing_category_id =>l_routing_category_id,
                   p_routing_category_name=> l_list_name);
          --
          hr_utility.set_message(8302,'PQH_NO_MEM_RULE_IN_ROUT_CAT');
          hr_utility.set_message_token('LIST_NAME', l_list_name);
          hr_utility.raise_error;
          --
        End if;
        --
        Close csr_auth2;
        --
     End loop;
     --
     Close csr_auth1;
     --
     --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
--
Procedure get_routing_category_name(p_routing_category_id     in number,
                                p_routing_category_name  out nocopy varchar2) is
  --
  l_proc         varchar2(72) := g_package||'get_routing_list_name';
  --
  -- The foll cursor returns the name of the routing category.
  --
  Cursor csr_routing_name(p_routing_category_id in number) is
    Select decode(RCT.routing_list_id,NULL,decode(RCT.position_structure_id,NULL,hr_general.decode_lookup('PQH_SUPERVISORY_HIERARCHY','SUPERVISORY_HIERARCHY'),PPS.name),RLT.routing_list_name) list_name
      From pqh_routing_categories RCT ,
           pqh_routing_lists RLT,
           per_position_structures PPS
     WHERE RCT.routing_category_id = p_routing_category_id AND
           RCT.routing_list_id = RLT.routing_list_id(+) and
           RCT.position_structure_id = PPS.position_structure_id(+);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  Open csr_routing_name(p_routing_category_id => p_routing_category_id);
  Fetch csr_routing_name into p_routing_category_name;
  Close csr_routing_name;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
-- ----------------------------------------------------------------------------
-- |------< chk_freeze_status_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
--   freeze_status_cd Value of lookup code.
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
Procedure chk_freeze_status_cd
                           (p_transaction_category_id     in number,
                            p_freeze_status_cd            in varchar2,
                            p_routing_type                in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_freeze_status_cd';
  l_api_updating boolean;
  l_active_txn_exists_flag varchar2(1) := 'N';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id                => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_freeze_status_cd
      <> nvl(pqh_tct_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_freeze_status_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_CATEGORY_FREEZE_STATUS',
           p_lookup_code    => p_freeze_status_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
      -- Check if there exists at least one routing category under
      -- the transaction category and if each routing category has
      -- at least one rule before freezing the category.
      --
      If p_freeze_status_cd = 'FREEZE_CATEGORY' then
              --
              chk_valid_routing_exists
              (p_transaction_category_id => p_transaction_category_id,
               p_routing_type             => p_routing_type);
              --
              pqh_attribute_ranges_pkg.chk_rout_overlap_on_freeze
              (p_transaction_category_id => p_transaction_category_id);
              --
              pqh_attribute_ranges_pkg.chk_mem_overlap_on_freeze
              (p_transaction_category_id => p_transaction_category_id);
              --
      End if;
      --
    end if;
    --
  end if;
  --
  --      ADDED VALIDATIONS
  --
  /*** This check is available in PQHWSTCT. Removing from api as they are not
   applicable for the wizard.
  --
  if (l_api_updating AND
      nvl(p_freeze_status_cd,hr_api.g_varchar2)
      <> nvl(pqh_tct_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2))
      or NOT l_api_updating then
      --
      --
      --
      -- Disallow updation of freeze_status_cd to NULL if active transactions
      -- exists for the transaction category only if the attributes were
      -- previously frozen.
      --
      if  p_freeze_status_cd IS NULL then
          --
          If nvl(pqh_tct_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2) =
             'FREEZE_ATTRIBUTES' then
             --
             l_active_txn_exists_flag := chk_active_transaction_exists
             (p_transaction_category_id => p_transaction_category_id);
             --
             If l_active_txn_exists_flag = 'Y' then
             --
                hr_utility.set_message(8302, 'PQH_CATEGORY_ROUT_HIST_EXISTS');
                hr_utility.raise_error;
             --
             End if;
          End if;
          --
      Else
           --
           -- Check if there exists at least one routing category under
           -- the transaction category and if each routing category has
           -- at least one rule before freezing the category.
           --
           If p_freeze_status_cd = 'FREEZE_CATEGORY' then
              --
              chk_valid_routing_exists
              (p_transaction_category_id => p_transaction_category_id,
               p_routing_type             => p_routing_type);
              --
              pqh_attribute_ranges_pkg.chk_rout_overlap_on_freeze
              (p_transaction_category_id => p_transaction_category_id);
              --
              pqh_attribute_ranges_pkg.chk_mem_overlap_on_freeze
              (p_transaction_category_id => p_transaction_category_id);
              --
           End if;
           --
           -- If Freezing the transaction category or its attributes , check if
           -- identifer counts are satisfied .
           --
           --
           chk_identifiers_count
           (p_transaction_category_id  => p_transaction_category_id,
            p_routing_type             => p_routing_type,
            p_min_member_identifiers   => 1,
            p_max_list_identifiers     => 3,
            p_max_member_identifiers   => 5);
           --
--      End if;
      --
      --
  End if;
  ***/
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_freeze_status_cd;
--
--------------------------------------------------------------------------------
--            NEW VALIDATIONS
-------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------< chk_upd_tct_allowed >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to checks if Transaction category details
--   can be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   transaction_category_id PK of record being inserted or updated.
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
Procedure chk_upd_tct_allowed
                (p_transaction_category_id                in number,
                 p_freeze_status_cd                       in varchar2,
                 p_object_version_number                  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upd_tct_allowed';
  l_api_updating boolean;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_tct_shd.api_updating
    (p_transaction_category_id     => p_transaction_category_id,
     p_object_version_number       => p_object_version_number);
  --
  -- Raise error if Trying to update details of a frozen transaction category ,
  -- If we are trying to unfreeze the category then allow updation
  --
  if l_api_updating  AND
     (nvl(p_freeze_status_cd,hr_api.g_varchar2)
     = nvl(pqh_tct_shd.g_old_rec.freeze_status_cd,hr_api.g_varchar2)) then
     --
     -- Disallow changing details of frozen category
     --
     if pqh_tct_shd.g_old_rec.freeze_status_cd = 'FREEZE_CATEGORY' then
        --
        hr_utility.set_message(8302,'PQH_NO_UPD_FROZEN_TCT');
        hr_utility.raise_error;
        --
     End if;
     --
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_upd_tct_allowed;
--
--
-------------------------------------------------------------------------------
--   chk_identifiers_count
-------------------------------------------------------------------------------
--
-- Description :
--    This function ensures the following Business Rules
-- 1) Transaction Category must have at least p_min_member identifier
--    if the routing type is Position Hierarhcy / Supervisory Hierarchy
-- 2) Transaction Category must have a max of p_max_list_identifiers
-- 3) Transaction Category must have a max of p_max_Member_identifiers
--
--
PROCEDURE chk_identifiers_count(p_transaction_category_id  in   number,
                                p_routing_type             in   varchar2,
                                p_min_member_identifiers   in   number,
                                p_max_list_identifiers     in   number,
                                p_max_member_identifiers   in   number) is
--
Cursor tot_list_identifiers is
       Select count(*) from pqh_txn_category_attributes tca
       where tca.transaction_category_id = p_transaction_category_id
       AND   tca.list_identifying_flag = 'Y';
--
Cursor tot_member_identifiers is
       Select count(*) from pqh_txn_category_attributes tca
       where  tca.transaction_category_id = p_transaction_category_id
       AND    tca.member_identifying_flag = 'Y';
--
l_no_list_identifiers    number(5);
l_no_member_identifiers  number(5);
--
l_proc  varchar2(72) := g_package||'chk_identifiers_count';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
     --
     -- Check if there a maximum of p_max_list_identifiers
     --
     Open tot_list_identifiers;
     Fetch tot_list_identifiers into l_no_list_identifiers;
     Close tot_list_identifiers;
     --
     If l_no_list_identifiers > p_max_list_identifiers then
        hr_utility.set_message(8302, 'PQH_MAX_LIST_IDENTIFIERS');
        hr_utility.raise_error;
     end if;
     --
     -- Check if there a maximum of p_member_list_identifiers
     -- There maybe no member identifiers at all.
     --
     Open tot_member_identifiers;
     Fetch tot_member_identifiers into l_no_member_identifiers;
     Close tot_member_identifiers;
     --
     if l_no_member_identifiers > p_max_member_identifiers then
        hr_utility.set_message(8302, 'PQH_MAX_MEMBER_IDENTIFIERS');
        hr_utility.raise_error;
     end if;

     If ((p_routing_type = 'P' OR p_routing_type = 'S') AND
        l_no_member_identifiers < p_min_member_identifiers) then
        --
        hr_utility.set_message(8302, 'PQH_MIN_MEMBER_IDENTIFIERS');
        hr_utility.raise_error;
        --
     End if;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--
-- The following procedure checks if any active transaction for this
-- transaction category exists.
--
FUNCTION chk_active_transaction_exists (p_short_name in VARCHAR2,
                                        p_transaction_category_id in number)
RETURN VARCHAR2
is
--
l_dummy        varchar2(1);
l_proc         varchar2(72) := g_package||'chk_act_txn_exists';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_short_name ='BUDGET_WORKSHEET' then
     select 'Y'
     into l_dummy
     from dual
     where exists ( select null
                    from pqh_worksheets
                    where wf_transaction_category_id = p_transaction_category_id
                      and transaction_status not in ('REJECT','TERMINATE','APPLIED'));
  elsif p_short_name ='PQH_BPR' then
     select 'Y'
     into l_dummy
     from dual
     where exists ( select null from pqh_budget_pools
                    where wf_transaction_category_id = p_transaction_category_id
                      and approval_status in ('P'));
  elsif p_short_name ='POSITION_TRANSACTION' then
     select 'Y'
     into l_dummy
     from dual
     where exists ( select null from pqh_position_transactions
                    where wf_transaction_category_id = p_transaction_category_id
                      and transaction_status not in ('REJECT','TERMINATE','APPLIED'));
  end if;
  --
  hr_utility.set_location('Leaving with:'||l_dummy,20);
  hr_utility.set_location('Leaving:'||l_proc,30);
  --
  RETURN l_dummy;
  --
exception
   when others then
      return 'N';
End chk_active_transaction_exists;
----------------------------------------------------------------------------
--
-- The following procedure checks if any active transaction for this
-- transaction category exists.
--
FUNCTION chk_active_transaction_exists (p_transaction_category_id in NUMBER)
RETURN VARCHAR2
is
--
--
--
l_dummy        varchar2(1);
l_proc         varchar2(72) := g_package||'chk_active_transaction_exists';
l_short_name   pqh_transaction_categories.short_name%type;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Select short_name
  into l_short_name
  From   pqh_transaction_categories
  Where  transaction_category_id = p_transaction_category_id;
  --
  if l_short_name is not null then
     l_dummy := chk_active_transaction_exists(p_short_name => l_short_name,
                                              p_transaction_category_id => p_transaction_category_id);
  end if;
  hr_utility.set_location('Entering:'||l_proc, 5);
  return l_dummy;
End chk_active_transaction_exists;
--
--
/**
FUNCTION chk_active_transaction_exists (p_transaction_category_id in NUMBER)
RETURN VARCHAR2
is
--
type cur_type IS REF CURSOR;
c2               cur_type;
sql_stmt         varchar2(1000);
--
l_from_clause    pqh_table_route.from_clause%type;
l_where_clause   pqh_table_route.where_clause%type;
l_table_alias    pqh_table_route.table_alias%type;
--
l_new_where      pqh_table_route.where_clause%type;
--
Cursor c1 is
  Select tr.from_clause,tr.table_alias,tr.where_clause
  From   pqh_transaction_categories tct,pqh_table_route tr
  Where  tct.transaction_category_id = p_transaction_category_id
    AND  tct.consolidated_table_route_id  = tr.table_route_id;
--
l_check_flag   varchar2(1) := 'N';
l_dummy        varchar2(1);
l_proc         varchar2(72) := g_package||'chk_active_transaction_exists';
--
Begin
    --
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    Open c1;
    --
    -- Fetch the from clause for the transaction category id.
    --
    Fetch c1 into l_from_clause,l_table_alias,l_where_clause;
    --
    If c1%found then
       --
       l_check_flag := 'Y';
       --
    End if;
    --
    Close c1;
    --
    If l_check_flag = 'Y' then
       --
       -- Call replace_where_params to replace part of where clause
       --
       pqh_refresh_data.replace_where_params
       (p_where_clause_in  => l_where_clause,
        p_txn_tab_flag     => 'N',
        p_txn_id           => '',
        p_where_clause_out => l_new_where);
       --
       -- Form dynamic SQL
       --
       --
       sql_stmt:=  'Select null From '
               ||l_from_clause
               ||' Where '
               ||l_new_where;

       If l_new_where IS NOT NULL then
       --
          sql_stmt := sql_stmt || ' and';
       --
       End if;

       sql_stmt := sql_stmt ||' nvl('
               ||l_table_alias
               ||'.transaction_status ,:b) not in ('
               ||''''||'REJECT'||''''
               ||','
               ||''''||'TERMINATE'||''''
               ||','
               ||''''||'APPLIED'||''''
               ||')' ;
       --
       Begin
       --
         Open c2 for sql_stmt using hr_api.g_varchar2;
         --
         Fetch c2 into l_dummy;
         --
         If c2%found then
            Close c2;
            RETURN 'Y';
         End if;
         --
         Close c2;
         --
       Exception when others then
         Close c2;
         Return 'N';
       --
       End;
       --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  RETURN 'N';
  --
End chk_active_transaction_exists;
**/
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_tct_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_transaction_category_id
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_upd_tct_allowed
  (p_transaction_category_id      => p_rec.transaction_category_id,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_consolid_table_route_id
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_consolidated_table_route_id          => p_rec.consolidated_table_route_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_master_table_route_id
  (p_transaction_category_id    => p_rec.transaction_category_id,
   p_master_table_route_id      => p_rec.master_table_route_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_route_validated_txn_flag
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_route_validated_txn_flag         => p_rec.route_validated_txn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_workflow_enable_flag
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_workflow_enable_flag         => p_rec.workflow_enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_post_style_cd
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_post_style_cd         => p_rec.post_style_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_member_cd
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_member_cd         => p_rec.member_cd,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_future_action_cd
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_future_action_cd         => p_rec.future_action_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_freeze_status_cd
  (p_transaction_category_id  => p_rec.transaction_category_id,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_routing_type             => p_rec.member_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_setup_type_cd
  (p_transaction_category_id  => p_rec.transaction_category_id,
   p_setup_type_cd            => p_rec.setup_type_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_business_group_id
  (p_transaction_category_id    => p_rec.transaction_category_id,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec             in  pqh_tct_shd.g_rec_type
                         ,p_effective_date  in  date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_transaction_category_id
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_upd_tct_allowed
  (p_transaction_category_id      => p_rec.transaction_category_id,
   p_freeze_status_cd             => p_rec.freeze_status_cd,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_consolid_table_route_id
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_consolidated_table_route_id          => p_rec.consolidated_table_route_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_master_table_route_id
  (p_transaction_category_id    => p_rec.transaction_category_id,
   p_master_table_route_id      => p_rec.master_table_route_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_route_validated_txn_flag
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_route_validated_txn_flag         => p_rec.route_validated_txn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_workflow_enable_flag
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_workflow_enable_flag         => p_rec.workflow_enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_post_style_cd
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_post_style_cd         => p_rec.post_style_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_member_cd
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_member_cd         => p_rec.member_cd,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_future_action_cd
  (p_transaction_category_id          => p_rec.transaction_category_id,
   p_future_action_cd         => p_rec.future_action_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_freeze_status_cd
  (p_transaction_category_id  => p_rec.transaction_category_id,
   p_freeze_status_cd         => p_rec.freeze_status_cd,
   p_routing_type             => p_rec.member_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_setup_type_cd
  (p_transaction_category_id  => p_rec.transaction_category_id,
   p_setup_type_cd            => p_rec.setup_type_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_business_group_id
  (p_transaction_category_id    => p_rec.transaction_category_id,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_tct_shd.g_rec_type
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
end pqh_tct_bus;

/
