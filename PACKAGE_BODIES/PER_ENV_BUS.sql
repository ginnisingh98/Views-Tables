--------------------------------------------------------
--  DDL for Package Body PER_ENV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ENV_BUS" as
/* $Header: peenvrhi.pkb 120.1 2005/08/04 03:23:12 vegopala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_env_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cal_entry_value_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cal_entry_value_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
   cursor csr_sec_grp is
     select pbg.security_group_id
     from per_business_groups_perf     pbg
         , per_calendar_entries ent
         , per_cal_entry_values env
     where env.cal_entry_value_id = p_cal_entry_value_id
     and   env.calendar_entry_id = ent.calendar_entry_id
     and   pbg.business_group_id (+) = ent.business_group_id;

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
    ,p_argument           => 'cal_entry_value_id'
    ,p_argument_value     => p_cal_entry_value_id
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
        => nvl(p_associated_column1,'CAL_ENTRY_VALUE_ID')
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
  (p_cal_entry_value_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , per_calendar_entries ent
         , per_cal_entry_values env
     where env.cal_entry_value_id = p_cal_entry_value_id
     and   env.calendar_entry_id = ent.calendar_entry_id
     and   pbg.business_group_id (+) = ent.business_group_id;
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
    ,p_argument           => 'cal_entry_value_id'
    ,p_argument_value     => p_cal_entry_value_id
    );
  --
  if ( nvl(per_env_bus.g_cal_entry_value_id, hr_api.g_number)
       = p_cal_entry_value_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_env_bus.g_legislation_code;
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
    per_env_bus.g_cal_entry_value_id          := p_cal_entry_value_id;
    per_env_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in per_env_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_env_shd.api_updating
      (p_cal_entry_value_id                => p_rec.cal_entry_value_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- check parent Entry Id is not updated
  If nvl(p_rec.calendar_entry_id, hr_api.g_number) <>
     nvl(per_env_shd.g_old_rec.calendar_entry_id ,hr_api.g_number)
  then
    hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'CALENDAR_ENTRY_ID'
          ,p_base_table => 'PER_CAL_ENTRY_VALUES'
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_calendar_entry_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates calendar_entry_id is set and exists, called on insert only.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: error raised and processing stops
--
Procedure chk_calendar_entry_id (p_calendar_entry_id in NUMBER) IS
--
  l_proc  varchar2(72) := g_package||'chk_calendar_entry_id';
  l_dummy varchar2(1);
--
--
  CURSOR CSR_ENTRY IS
  SELECT 'X'
  FROM per_calendar_entries ent
  WHERE ent.calendar_entry_id = p_calendar_entry_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_calendar_entry_id IS NULL then
    -- raise as serious error, no point doing other checks
     fnd_message.set_name('PER', 'PER_289976_CAL_ENT_NULL');
     fnd_message.raise_error;
  Else
  --
    open CSR_ENTRY;
    fetch CSR_ENTRY into l_dummy;
    if CSR_ENTRY%notfound then
      close CSR_ENTRY;
      -- raise as serious error, no point doing other checks
      fnd_message.set_name('PER', 'PER_289977_CAL_ENT_INV');
      fnd_message.raise_error;
    else
      close CSR_ENTRY;
    end if;
  End if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_calendar_entry_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_hierarchy_node_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates hierarchy_node_id, if set, exists in per_gen_hierarchy_nodes.
--   Also checks that the parent calendar entry is using the same generic hierarchy
--   to which the node belongs, and that the node id is unique in per_cal_entry_values
--   for the parent calendar_entry_id.  Insert only.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure:
--
Procedure chk_hierarchy_node_id (p_hierarchy_node_id in NUMBER
                                ,p_calendar_entry_id in NUMBER) IS
--
  l_proc  varchar2(72) := g_package||'chk_hierarchy_node_id';
  l_id    number(15)   := NULL;
  l_dummy varchar2(1)  := NULL;

  -- Get the gen hier id for the entry record,
  -- which cannot have VS id set
  CURSOR CSR_ENTRY IS
  SELECT ent.hierarchy_id
  FROM per_calendar_entries ent
  WHERE ent.calendar_entry_id = p_calendar_entry_id
  AND ent.value_set_id is NULL;

  -- Check the node exists in the hierarchy version 1
  -- as calendar hierarchies only have one version
  CURSOR CSR_GEN_HIER (l_gen_hier NUMBER) IS
  SELECT 'X'
  FROM  per_gen_hierarchy_nodes pgn
  WHERE pgn.hierarchy_node_id = p_hierarchy_node_id
  AND   pgn.hierarchy_version_id = (select pgv.hierarchy_version_id
                                    from per_gen_hierarchy_versions pgv
                                    where  pgv.hierarchy_id = l_gen_hier
                                    and  pgv.version_number = 1);

  --
  -- Check that the node is unique for the parent entry id
  -- in per_cal_entry_values;
  --
  CURSOR CSR_ENT_VAL IS
  SELECT 'X'
  FROM  per_cal_entry_values env
  WHERE env.hierarchy_node_id = p_hierarchy_node_id
  AND   env.calendar_entry_id = p_calendar_entry_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'calendar_entry_id'
    ,p_argument_value     => p_calendar_entry_id
    );
  --
  --
  IF p_hierarchy_node_id IS NOT NULL THEN
    --
    open CSR_ENTRY;
    fetch CSR_ENTRY into l_id;
    if CSR_ENTRY%notfound then
        close CSR_ENTRY;
        fnd_message.set_name('PER', 'PER_289978_CAL_ENT_NODE_INV');
        fnd_message.raise_error;
    else
      hr_utility.set_location(l_proc, 15);
      close CSR_ENTRY;
      if l_id IS NULL then
        fnd_message.set_name('PER', 'PER_289978_CAL_ENT_NODE_INV');
        fnd_message.raise_error;
      else
        hr_utility.set_location(l_proc, 25);
        open CSR_GEN_HIER(l_id);
        fetch CSR_GEN_HIER into l_dummy;
        if CSR_GEN_HIER%notfound then
          close CSR_GEN_HIER;
          -- node does not exist in the parent entry's gen heirarchy  MM
          fnd_message.set_name('PER', 'PER_289979_CAL_ENT_NODE_INV');
          fnd_message.raise_error;
        else
          close CSR_GEN_HIER;
        end if;

        hr_utility.set_location(l_proc, 35);
        open CSR_ENT_VAL;
        fetch CSR_ENT_VAL into l_dummy;
        if CSR_ENT_VAL%found then
          close CSR_ENT_VAL;
          -- node already used by an entry value for this
          -- calendar entry
          fnd_message.set_name('PER', 'PER_289980_CAL_ENT_NODE_UNQ');
          fnd_message.raise_error;
        else
          close CSR_ENT_VAL;
        end if;
      end if;
    end if;
  END IF;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_hierarchy_node_id;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_value >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates value by checking the parent calendar entry record has a
--   value_set_id (stand-alone coverage rather than generic hierarchy coverage)
--   and that a matching value exists in that value set. Insert only.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure:
--
Procedure chk_value (p_value in VARCHAR2
                    ,p_calendar_entry_id in NUMBER) IS
--
  l_proc  varchar2(72) := g_package||'chk_value';
  l_id    number(15)   := NULL;

  -- Get the VS id for the entry record,
  -- which cannot have a gen hier id set
  CURSOR CSR_ENTRY IS
  SELECT ent.VALUE_SET_ID
  FROM per_calendar_entries ent
  WHERE ent.calendar_entry_id = p_calendar_entry_id
  AND ent.hierarchy_id is NULL;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'calendar_entry_id'
    ,p_argument_value     => p_calendar_entry_id
    );
  --
  --
  IF p_value IS NOT NULL THEN
    --
    open CSR_ENTRY;
    fetch CSR_ENTRY into l_id;
    if CSR_ENTRY%notfound then
        close CSR_ENTRY;
        -- parent entry is not using valueset    -- MM
        fnd_message.set_name('PER', 'PER_289981_CAL_ENT_VS_INV');
        fnd_message.raise_error;
    else
      close CSR_ENTRY;
      -- do valudation of the VS value ....

    end if;
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_value;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_comb_fks_valid >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates that the correct combination of hierarchy_node_id,
--   and value is supplied. Runs on insert only as these params
--   are not updateable.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_comb_fks_valid(p_hierarchy_node_id IN NUMBER
                            ,p_org_structure_element_id IN NUMBER
                            ,p_value             IN VARCHAR2) IS
--
  l_proc  varchar2(72) := g_package||'chk_comb_fks_valid';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF (p_hierarchy_node_id is null and p_value is null
      and p_org_structure_element_id is null)
     OR (p_hierarchy_node_id is not null and p_value is not null)
     OR (p_org_structure_element_id is not null and p_value is not null)
     OR (p_org_structure_element_id is not null and p_hierarchy_node_id is not null) then
    -- unrecoverable error as only one must be set
    fnd_message.set_name('PER', 'PER_289982_CAL_ENV_FKS_NULL');
    fnd_message.raise_error;
  END IF;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_comb_fks_valid;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_override_name_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Validates the combination of usage_flag, override_name and override_type
-- as follows:
--   a) One or both of override name or override_type has been
--      set for a child override override value only. i.e. usage = 'O'.
--   b) Coverage name has not been set for non-override values i.e. usage <> 'O'
--   c) Coverage name, if set, is <> parent entry name.
--   d) Coverage type (lookup code) exists for the
--      lookup_type CALENDAR_ENTRY_TYPE.
--   e) Coverage type, if set, is <> parent entry type.
--   f) Coverage type should not be set for an exception i.e. usage = 'Y'
--
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_override_name_type(p_calendar_entry_id         IN NUMBER
                                ,p_cal_entry_value_id        IN NUMBER
                                ,p_usage_flag                IN VARCHAR2
                                ,p_override_name             IN VARCHAR2
                                ,p_override_type             IN VARCHAR2
                                ,p_effective_date            IN DATE) IS
--
 CURSOR csr_OVR IS
  SELECT name, type from per_calendar_entries
  WHERE calendar_entry_id = p_calendar_entry_id;
--
  l_proc  varchar2(80) := g_package||'chk_override_name_type';
  l_type  per_cal_entry_values.override_type%type;
  l_name  per_cal_entry_values.override_name%type;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 IF (p_cal_entry_value_id is NULL
       or (p_usage_flag <> per_env_shd.g_old_rec.usage_flag)
       or (nvl(p_override_name,hr_api.g_varchar2)
          <> nvl(per_env_shd.g_old_rec.override_name,hr_api.g_varchar2))
       or (nvl(p_override_type,hr_api.g_varchar2)
          <> nvl(per_env_shd.g_old_rec.override_type,hr_api.g_varchar2)) )
  THEN

    IF p_usage_flag = 'O' and p_override_name is null and p_override_type is null then
     -- override must have a name or value - convert to MM
      fnd_message.set_name('PER', 'HR_289992_CAL_OVER_NULL');
      fnd_message.raise_error;
    End if;
    --
    IF p_usage_flag <> 'O' and p_override_name is not null then
     -- non override's must not have an override name - convert to MM
      fnd_message.set_name('PER', 'HR_289993_CAL_OVERN_SET');
      fnd_message.raise_error;
    End if;
     --
    hr_utility.set_location(l_proc, 10);
    IF p_override_type is not null then
      IF p_usage_flag = 'Y' then
        -- exceptions must not have an override type - convert to MM
        fnd_message.set_name('PER', 'HR_289994_CAL_OVERT_SET');
        fnd_message.raise_error;
      ELSE
        -- check the value exists in lookups...
        if hr_api.NOT_EXISTS_IN_HR_LOOKUPS
         (p_effective_date     => p_effective_date
         ,p_lookup_type        => 'CALENDAR_ENTRY_TYPE'
         ,p_lookup_code        => p_override_type)
        then
          fnd_message.set_name('PER','HR_289995_CAL_OVERT_INV');
          fnd_message.raise_error;
         --
        end if;
      END IF;
    End if;

    hr_utility.set_location(l_proc, 20);

    IF p_override_type is not null or p_override_name is not null then
     -- validate that the override values differ from the parent...
      open CSR_OVR;
      fetch CSR_OVR into l_name, l_type;
      close CSR_OVR;
      If upper(l_name) = upper(p_override_name) then
          fnd_message.set_name('PER', 'HR_289996_CAL_OVERN_DIF');
          fnd_message.raise_error;
      End If;
      If l_type = p_override_type then
          fnd_message.set_name('PER', 'HR_289997_CAL_OVERT_DIF');
          fnd_message.raise_error;
      End If;
    End if;
 --
 END IF;
 --
 hr_utility.set_location('Leaving:'||l_proc, 30);
 --
End chk_override_name_type;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_comb_usage_parentev_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the combination of usage_flag and parent_entry_value_id values as:
--     a) usage_flag is  mandatory.
--     b) usage_flag value is one of 'N' entry value,'Y' exception,'O' override.
--     c) parent_entry_value_id is mandatory if usage_flag <> 'Y', otherwise
--        parent_entry_value_id must be null.
--     d) if parent_entry_value_id is not null, checks that parent_entry_value_id
--        corresponds to a record in per_cal_entry_values for the current
--        calendar_entry_id, and that the parent record is an existing entry value.
--        i.e. usage = 'Y'.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_comb_usage_parentev_id (p_cal_entry_value_id IN NUMBER
                                     ,p_calendar_entry_id IN NUMBER
                                     ,p_parent_entry_value_id IN NUMBER
                                     ,p_usage_flag IN VARCHAR2) IS

  -- Check the parent exists in per_cal_entry_values
  -- as calendar hierarchies only have one version
  CURSOR CSR_EV IS
  SELECT env.calendar_entry_id, env.parent_entry_value_id
  FROM  per_cal_entry_values env
  WHERE env.cal_entry_value_id = p_parent_entry_value_id;

  l_parent_entry_id       NUMBER(15);
  l_parent_entry_value_id NUMBER(15);
--
  l_proc  varchar2(80) := g_package||'chk_comb_usage_parentev_id';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    IF (p_cal_entry_value_id is NULL
       or (nvl(p_parent_entry_value_id,hr_api.g_number)
          <> nvl(per_env_shd.g_old_rec.parent_entry_value_id,hr_api.g_number))
       or (nvl(p_usage_flag,hr_api.g_varchar2)
          <> nvl(per_env_shd.g_old_rec.usage_flag,hr_api.g_varchar2)) )
    THEN


      If p_usage_flag is null or p_usage_flag not in ('Y','N','O') then
        -- usage is invalid
          fnd_message.set_name('PER', 'HR_289998_CAL_USAGE_INV');
          fnd_message.raise_error;
      End if;

      -- continue with combines validation
      If p_parent_entry_value_id is not null and p_usage_flag = 'N' THEN
        -- current record is a gen hierarchy coverage parent or a valueset coverage
        -- so parent_entry_value_id must be null.
        fnd_message.set_name('PER', 'PER_289983_CAL_VS_NO_PARENT');
        fnd_message.raise_error;
      End if;

      If p_parent_entry_value_id is null and p_usage_flag <> 'N' THEN
        -- current record is not a gen hierarchy coverage parent or
        -- a valueset coverage so parent_entry_value_id must NOT be null.
        fnd_message.set_name('PER', 'HR_289999_CAL_PARENT_NULL');
        fnd_message.raise_error;
      End if;

      hr_utility.set_location(l_proc, 10);

      If p_parent_entry_value_id is not NULL then
        -- if we get here, we can proceed with validating the parent coverage id

        open CSR_EV;
        fetch CSR_EV into l_parent_entry_id, l_parent_entry_value_id;
        If CSR_EV%notfound then
            close CSR_EV;
          -- parent EV was not found
          fnd_message.set_name('PER', 'PER_289984_CAL_PARENT_INV1');
          fnd_message.raise_error;
        Else
          close CSR_EV;

          hr_utility.set_location(l_proc, 20);
          If p_calendar_entry_id <> l_parent_entry_id then
            -- parent EV exists for a different calendar entry
            fnd_message.set_name('PER', 'PER_289985_CAL_PARENT_INV2');
            fnd_message.raise_error;
          End if;

          If l_parent_entry_value_id is not NULL then
             -- parent EV is actually EVX or EVO so this grandchild is not allowed.
            fnd_message.set_name('PER', 'PER_289156_CAL_PARENT_INV3');
            fnd_message.raise_error;
          End if;
        End if;
      End if;
      --
    End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  --
End CHK_COMB_USAGE_PARENTEV_ID;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_identifier_key >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the Identifier Key is UNIQUE.
--   Note: This should only be NOT NULL when called by SEED DB user.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_identifier_key (p_identifier_key in VARCHAR2) IS
--
 CURSOR c_unique IS
  SELECT 'Y'
  FROM PER_CAL_ENTRY_VALUES ENV
  WHERE ENV.IDENTIFIER_KEY = p_identifier_key;

  l_proc  varchar2(72) := g_package||'chk_identifier_key';
  l_value varchar2(240):= null;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF p_identifier_key IS NOT NULL THEN
    open c_unique;
    fetch c_unique into l_value;
    IF c_unique%found THEN
     close c_unique;
     -- Add to MM list as non-fatal
      fnd_message.set_name('PER','PER_449074_CAL_IDK_EXISTS');
      hr_multi_message.add
       (p_associated_column1 => 'PER_CAL_ENTRY_VALUES.identifier_key');
    ELSE
      close c_unique;
    END IF;
   --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_identifier_key;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_env_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --

  -- Validate calendar entry id on insert only
     chk_calendar_entry_id(p_rec.calendar_entry_id);

  -- Check combination of FKs is valid before
  -- individiual combinations and values are checked
     chk_comb_fks_valid(p_rec.hierarchy_node_id
                       ,p_rec.org_structure_element_id
                       ,p_rec.value);


  -- Now validate the FK, value params
     chk_hierarchy_node_id(p_rec.hierarchy_node_id
                          ,p_rec.calendar_entry_id);

     chk_value (p_rec.value
               ,p_rec.calendar_entry_id);

  -- Finally validate usage_flag and parent entry value
     chk_comb_usage_parentev_id(p_rec.cal_entry_value_id
                               ,p_rec.calendar_entry_id
                               ,p_rec.parent_entry_value_id
                               ,p_rec.usage_flag);

  -- validate override_name and override_type
     chk_override_name_type (p_rec.calendar_entry_id
                            ,p_rec.cal_entry_value_id
                            ,p_rec.usage_flag
                            ,p_rec.override_name
                            ,p_rec.override_type
                            ,p_effective_date);

  -- chk_identifier_key(p_rec.identifier_key);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_env_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );


  -- Finally validate usage_flag and parent entry value
     chk_comb_usage_parentev_id(p_rec.cal_entry_value_id
                               ,p_rec.calendar_entry_id
                               ,p_rec.parent_entry_value_id
                               ,p_rec.usage_flag);

  -- validate override_name and override_type
     chk_override_name_type (p_rec.calendar_entry_id
                            ,p_rec.cal_entry_value_id
                            ,p_rec.usage_flag
                            ,p_rec.override_name
                            ,p_rec.override_type
                            ,p_effective_date);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_env_shd.g_rec_type
  ) is
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
end per_env_bus;

/
