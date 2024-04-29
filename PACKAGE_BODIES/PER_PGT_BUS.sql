--------------------------------------------------------
--  DDL for Package Body PER_PGT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGT_BUS" as
/* $Header: pepgtrhi.pkb 115.2 2003/06/05 07:38:23 cxsimpso noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pgt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_hier_node_type_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_hier_node_type_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_gen_hier_node_types pgt
     where pgt.hier_node_type_id = p_hier_node_type_id
       and pbg.business_group_id = pgt.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'hier_node_type_id'
    ,p_argument_value     => p_hier_node_type_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'HIER_NODE_TYPE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_hier_node_type_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_gen_hier_node_types pgt
     where pgt.hier_node_type_id = p_hier_node_type_id
       and pbg.business_group_id (+) = pgt.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'hier_node_type_id'
    ,p_argument_value     => p_hier_node_type_id
    );
  --
  if ( nvl(per_pgt_bus.g_hier_node_type_id, hr_api.g_number)
       = p_hier_node_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pgt_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_pgt_bus.g_hier_node_type_id           := p_hier_node_type_id;
    per_pgt_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in per_pgt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pgt_shd.api_updating
      (p_hier_node_type_id                 => p_rec.hier_node_type_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (per_pgt_shd.g_old_rec.child_node_type <> nvl(p_rec.child_node_type,hr_api.g_varchar2)) THEN
     fnd_message.set_name('PER', 'HR_289899_PGT_CNTYPE_NO_UPD');
     fnd_message.raise_error;
  END IF;
  --
  IF (per_pgt_shd.g_old_rec.hierarchy_type <> nvl(p_rec.hierarchy_type,hr_api.g_varchar2)) THEN
     fnd_message.set_name('PER', 'HR_289900_PGT_HTYPE_NO_UPD');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(per_pgt_shd.g_old_rec.business_group_id,hr_api.g_number)
         <> nvl(p_rec.business_group_id,hr_api.g_number)) THEN
     fnd_message.set_name('PER', 'HR_289901_PGT_BG_NO_UPD');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_hierarchy_type >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates hierarchy_type and is called on insert only.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues hierarchy_type is valid.
--
-- Post Failure:
--   An application error is raised if hierarchy_type is not valid.
--
Procedure chk_hierarchy_type (p_effective_date in date
                             ,p_hierarchy_type in varchar2) IS
--
  l_proc  varchar2(72) := g_package||'chk_hierarchy_type';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'effective_date'
    ,p_argument_value     => p_effective_date
    );

  If p_hierarchy_type IS NOT NULL then
    If HR_API.NOT_EXISTS_IN_HRSTANLOOKUPS(p_effective_date => p_effective_date
                                         ,p_lookup_type    => 'HIERARCHY_TYPE'
                                         ,p_lookup_code    => p_hierarchy_type) then
      --
      fnd_message.set_name('PER', 'HR_289902_PGT_HTYPE_INV');
      fnd_message.raise_error;
    End If;
  Else
    fnd_message.set_name('PER', 'HR_289903_PGT_HTYPE_NULL');
    fnd_message.raise_error;
  End If;
  --
  Exception
   when app_exception.application_exception then
     -- hierarchy_type requires independent validation,
     -- catch any app exception raised above and place on stack or re-raise
     If hr_multi_message.exception_add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.HIERARCHY_TYPE') then
       raise;
     End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_hierarchy_type;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_parent_child_node_type >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the child node type and parent node_type as of the effective date
--   and within the hierarchy_type. Assumes a valid hierarchy_type. Called from
--   insert and update validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues if valid.
--
-- Post Failure:
--   An application error is raised if invalid.
--
Procedure chk_parent_child_node_type
                             (p_effective_date in date
                             ,p_hier_node_type_id in number
                             ,p_child_node_type in varchar2
                             ,p_parent_node_type in varchar2
                             ,p_hierarchy_type in varchar2) IS
  --
  -- CSR to test if node exists in hierarchy
  --
  CURSOR csr_node(l_node_type varchar2
                 ,l_hierarchy_type varchar2) IS
    SELECT 'X'
    FROM per_gen_hier_node_types
    WHERE child_node_type = l_node_type
    AND hierarchy_type = l_hierarchy_type;
  --
  --
  -- CSR to test if top node exists in hierarchy
  --
  CURSOR csr_top_node (l_hierarchy_type varchar2) IS
    SELECT 'X'
    FROM per_gen_hier_node_types
    WHERE parent_node_type is null
    AND hierarchy_type = l_hierarchy_type;
  --
  --
  l_err_flag BOOLEAN := false;
  l_err_parent_flag BOOLEAN := false;
  l_proc  varchar2(72) := g_package||'chk_parent_child_node_type';
  l_dummy varchar2(1) := null;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'effective_date'
    ,p_argument_value     => p_effective_date
    );

    -- check child node is supplied
    -- and a valid lookup code
  If p_child_node_type IS NULL then
      -- child node type requires independent validation here
      fnd_message.set_name('PER', 'HR_289904_PGT_CNODE_TYPE_NULL');
      hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.CHILD_NODE_TYPE');
  Else
    --
    -- Validate child_node_type on insert only (non-updateable) lookup code
    --
    If p_hier_node_type_id is null then
      If hr_api.not_exists_in_hrstanlookups
                              (p_effective_date => p_effective_date
                              ,p_lookup_type    => 'HIERARCHY_NODE_TYPE'
                              ,p_lookup_code    => p_child_node_type) then

        --
        l_err_flag := true;
        fnd_message.set_name('PER', 'HR_289906_PGT_CNODE_TYPE_INV');
        -- independently validated
        hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.CHILD_NODE_TYPE');
      End If;
      --
      hr_utility.set_location(l_proc, 10);
      --
      If not(l_err_flag) and
        hr_multi_message.no_exclusive_error('PER_GEN_HIER_NODE_TYPES.HIERARCHY_TYPE') then
        --
        -- only proceed with validation if err not raised already on child_node
        -- nor on hierarchy_type fields
        --
        -- check the child_node_type does not already exist in the hierarchy
        -- (thus child_node + parent_node (where set) will be unique too)
        --
        Open csr_node(p_child_node_type, p_hierarchy_type);
        Fetch csr_node into l_dummy;
        If csr_node%found then
          Close csr_node;
          l_err_flag := TRUE;
          fnd_message.set_name('PER', 'HR_289905_PGT_CNODE_NOT_UNQ');
          -- conditionally independently validated
          hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.CHILD_NODE_TYPE');
        Else
          Close csr_node;
        End if;
        --
        hr_utility.set_location(l_proc, 15);
        --
        -- check that the child_node is not the same as the parent node
        --
        If not(l_err_flag) and p_child_node_type = nvl(p_parent_node_type,-999) then
          fnd_message.set_name('PER', 'HR_289907_PGT_CNODE_IS_PNODE');
          -- conditionally independently validated
          l_err_flag := TRUE;
          hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.CHILD_NODE_TYPE');
        End If;

      End If;
    End If;
  End If;


  hr_utility.set_location(l_proc, 20);
  --
  -- tests if parent node type is set
  --
  If p_parent_node_type IS NOT NULL then
    -- validate for ins and upd
    If (p_hier_node_type_id is null
        or (p_hier_node_type_id is not null
            and nvl(per_pgt_shd.g_old_rec.parent_node_type,hr_api.g_varchar2)
            <> p_parent_node_type))
    then
      If hr_api.not_exists_in_hrstanlookups
                         (p_effective_date => p_effective_date
                         ,p_lookup_type    => 'HIERARCHY_NODE_TYPE'
                         ,p_lookup_code    => p_parent_node_type) then
        --
        l_err_parent_flag := TRUE;
        fnd_message.set_name('PER', 'HR_289908_PGT_PNODE_TYPE_INV');
        -- independently validated
        hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.PARENT_NODE_TYPE');
        --
      End If;
      --
      hr_utility.set_location(l_proc, 30);
      --
      If not(l_err_parent_flag) and
        hr_multi_message.no_exclusive_error('PER_GEN_HIER_NODE_TYPES.HIERARCHY_TYPE') then
        --
        -- only proceed with validation if err not raised already on parent_node
        -- nor on hierarchy_type fields
        --
        -- check there is a child_node_type matching the parent_node_type
        -- in the hierarchy already
        Open csr_node(p_parent_node_type, p_hierarchy_type);
        Fetch csr_node into l_dummy;
        If csr_node%notfound then
          Close csr_node;
          fnd_message.set_name('PER', 'HR_289909_PGT_PNODE_NOT_CNODE');
          hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.PARENT_NODE_TYPE');
        Else
          Close csr_node;
        End If;
        hr_utility.set_location(l_proc, 35);

        -- conditionally check that the parent_node is not being updated to the same
        -- value as the child node
        If (not(l_err_flag) and not(l_err_parent_flag)) and
            (p_hier_node_type_id is not null and
            per_pgt_shd.g_old_rec.child_node_type = p_parent_node_type)
        then
          fnd_message.set_name('PER', 'HR_289907_PGT_CNODE_IS_PNODE');
          hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.PARENT_NODE_TYPE');
        End If;
      End If;
    End If;
  Else
    hr_utility.set_location(l_proc, 40);
    If (hr_multi_message.no_exclusive_error('PER_GEN_HIER_NODE_TYPES.HIERARCHY_TYPE')
        and p_hier_node_type_id is null or (p_hier_node_type_id is not null
         and per_pgt_shd.g_old_rec.parent_node_type IS NOT NULL )) then
         -- parent node is null so if ins or upd and this isnt already top node
         -- confirm that we can set this node as the top node
         -- scope in the hierarchy
       Open csr_top_node(p_hierarchy_type);
       Fetch csr_top_node into l_dummy;
       If csr_top_node%found then
         Close csr_top_node;
         fnd_message.set_name('PER', 'HR_289910_PGT_TOP_NODE_DUP');
         hr_multi_message.add
               (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.PARENT_NODE_TYPE');
       Else
         Close csr_top_node;
       End If;
    End If;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
   --
End chk_parent_child_node_type;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_child_value_set >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates child_value_set and is called on insert and update.
--   Raises error if valueset is  being updated to a different value
--   and the scope is already used in a generic hierarchy.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues if child_value_set is valid.
--
-- Post Failure:
--   An application error is raised if child_value_set is not valid.
--
Procedure chk_child_value_set(p_hier_node_type_id in number
                            ,p_child_value_set in varchar2) IS

  CURSOR csr_vs IS
  SELECT 'X'
  FROM fnd_flex_value_sets
  WHERE flex_value_set_name = p_child_value_set;

  CURSOR csr_node_used is
  SELECT 'Y'
  FROM per_gen_hierarchy_nodes
  WHERE node_type = to_char(p_hier_node_type_id);

  --
  l_proc  varchar2(72) := g_package||'chk_child_value_set';
  l_dummy varchar2(1)  := null;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  If p_child_value_set is null then
    fnd_message.set_name('PER', 'HR_289911_PGT_CHILD_VS_NULL');
    fnd_message.raise_error;
  Else
    If p_hier_node_type_id is null or
       per_pgt_shd.g_old_rec.child_value_set <> p_child_value_set then
        -- confirm that VS exist
      Open csr_vs;
      Fetch csr_vs into l_dummy;
      If csr_vs%notfound then
        Close csr_vs;
        fnd_message.set_name('PER', 'HR_289912_PGT_CHILD_VS_INV');
        fnd_message.raise_error;
      Else
        Close csr_vs;
      End If;

      if p_hier_node_type_id is not null then
      -- check that the VS may be updated
      -- as not used in a generic hierarchy..
        Open csr_node_used;
        Fetch csr_node_used into l_dummy;
        If csr_node_used%found then
          Close csr_node_used;
          fnd_message.set_name('PER', 'HR_289192_PER_CAL_VS_IN_USE');
          fnd_message.raise_error;
        Else
          Close csr_node_used;
        End If;
      End if;

    End If;
  End If;
  --
Exception
  when app_exception.application_exception then
   If hr_multi_message.exception_add
          (p_associated_column1 => 'PER_GEN_HIER_NODE_TYPES.CHILD_VALUE_SET') then
     hr_utility.set_location('Leaving:'||l_proc, 40);
     raise;
   End If;
 --
 hr_utility.set_location('Leaving:'||l_proc, 50);
 --
End chk_child_value_set;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  -- Validate Important Attributes

  If p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id
      (p_business_group_id => p_rec.business_group_id
      ,p_associated_column1 => per_pgt_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
  End If;

  -- validate HIERARCHY_TYPE
  chk_hierarchy_type(p_effective_date, p_rec.hierarchy_type);

  -- validate CHILD_NODE_TYPE, PARENT_NODE_TYPE
  chk_parent_child_node_type
               (p_effective_date     => p_effective_date
               ,p_hier_node_type_id  => p_rec.hier_node_type_id
               ,p_child_node_type    => p_rec.child_node_type
               ,p_parent_node_type   => p_rec.parent_node_type
               ,p_hierarchy_type     => p_rec.hierarchy_type);

  -- validate CHILD_VALUE_SET
  chk_child_value_set(p_child_value_set    => p_rec.child_value_set
                     ,p_hier_node_type_id  => p_rec.hier_node_type_id);
  --
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pgt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
   If p_rec.business_group_id is not null then
     hr_api.validate_bus_grp_id
      (p_business_group_id => p_rec.business_group_id
      ,p_associated_column1 => per_pgt_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
   End If;


  -- validate CHILD_NODE_TYPE, PARENT_NODE_TYPE
  chk_parent_child_node_type
               (p_effective_date     => p_effective_date
               ,p_hier_node_type_id  => p_rec.hier_node_type_id
               ,p_child_node_type    => p_rec.child_node_type
               ,p_parent_node_type   => p_rec.parent_node_type
               ,p_hierarchy_type     => p_rec.hierarchy_type);

  -- validate CHILD_VALUE_SET
  chk_child_value_set(p_child_value_set    => p_rec.child_value_set
                     ,p_hier_node_type_id  => p_rec.hier_node_type_id);
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pgt_shd.g_rec_type
  ) is

  -- csr to see if any hierarchy nodes reference this scope
  CURSOR csr_node_used is
   select 'Y'
    from per_gen_hierarchy_nodes
    where node_type = to_char(p_rec.hier_node_type_id);

   l_proc  varchar2(72) := g_package||'delete_validate';
   l_dummy varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- To validate that delete is allowed, check that:
  -- 1) node_type is not referenced in is the lowest level (has no chilren) in its
  --    node type hierarchy (or global)
  -- 2) the node's type hierarchy is not used in a generic hierarchy already

  If 'Y' = hr_calendar_node_type_api.child_exists(p_hierarchy_type => p_rec.hierarchy_type
                                                 ,p_child_node_type => p_rec.child_node_type) then
    fnd_message.set_name('PER', 'HR_289913_PER_CAL_CHILD_EXISTS');
    fnd_message.raise_error;
  End if;

   -- bug 2982313 rework this to actually check if the scope record is being used in a generic hierarchy
   -- rather than checking if hierarchy type has been used by the open .
    --If 'Y' = hr_calendar_node_type_api.gen_hier_exists(p_hierarchy_type => p_rec.hierarchy_type) then
    -- fnd_message.set_name('PER', 'HR_289914_PER_CAL_HIER_EXISTS');
    -- fnd_message.raise_error;
    --End if;
  open csr_node_used;
  fetch csr_node_used into l_dummy;
  if csr_node_used%found then
    close csr_node_used;
    fnd_message.set_name('PER', 'HR_289914_PER_CAL_HIER_EXISTS');
    fnd_message.raise_error;
  else
    close csr_node_used;
  end if;
  -- end bug 2982313.



  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_pgt_bus;

/
