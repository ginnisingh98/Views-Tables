--------------------------------------------------------
--  DDL for Package Body PER_ENT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ENT_BUS" as
/* $Header: peentrhi.pkb 120.2 2005/06/16 08:27:40 vegopala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ent_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_calendar_entry_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_calendar_entry_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_calendar_entries ent
     where ent.calendar_entry_id = p_calendar_entry_id
       and pbg.business_group_id = ent.business_group_id;
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
    ,p_argument           => 'calendar_entry_id'
    ,p_argument_value     => p_calendar_entry_id
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
        => nvl(p_associated_column1,'CALENDAR_ENTRY_ID')
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
  (p_calendar_entry_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_calendar_entries ent
     where ent.calendar_entry_id = p_calendar_entry_id
       and pbg.business_group_id (+) = ent.business_group_id;
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
    ,p_argument           => 'calendar_entry_id'
    ,p_argument_value     => p_calendar_entry_id
    );
  --
  if ( nvl(per_ent_bus.g_calendar_entry_id, hr_api.g_number)
       = p_calendar_entry_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ent_bus.g_legislation_code;
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
    per_ent_bus.g_calendar_entry_id           := p_calendar_entry_id;
    per_ent_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in per_ent_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ent_shd.api_updating
      (p_calendar_entry_id                 => p_rec.calendar_entry_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --

  -- check legislation code is not updated
  If nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(per_ent_shd.g_old_rec.legislation_code ,hr_api.g_varchar2)
  then
    hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'LEGISLATION_CODE'
          ,p_base_table => 'PER_CALENDAR_ENTRIES'
     );
  end if;

  -- check identifier key is not updated
  If nvl(p_rec.identifier_key, hr_api.g_varchar2) <>
     nvl(per_ent_shd.g_old_rec.identifier_key ,hr_api.g_varchar2)
  then
    hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'IDENTIFIER_KEY'
          ,p_base_table => 'PER_CALENDAR_ENTRIES'
     );
  end if;



End chk_non_updateable_args;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_name >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the name is not null.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_name (p_name in VARCHAR2) IS
--
  l_proc  varchar2(72) := g_package||'chk_name';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF p_name IS NULL THEN
   -- Add to MM list as non-fatal
    fnd_message.set_name('PER','PER_289958_CAL_NAME_NULL');
    hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.NAME');
   --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_name;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_type >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the entry type exists in HR_STANDARD_LOOKUPS.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_type (p_type in VARCHAR2
                   ,p_calendar_entry_id in NUMBER
                   ,p_effective_date in DATE) IS
--
  l_proc  varchar2(72) := g_package||'chk_type';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for type has changed
  --
  IF p_type IS NULL THEN
   -- Add to MM list
    fnd_message.set_name('PER','PER_289959_CAL_TYPE_NULL');
      hr_multi_message.add
      (p_associated_column1 => 'PER_CALENDAR_ENTRIES.TYPE');
   --
  ELSIF ((p_calendar_entry_id is null) or
       ((p_calendar_entry_id is not null) and
         (per_ent_shd.g_old_rec.type <> p_type))) then
   --
   if hr_api.NOT_EXISTS_IN_HR_LOOKUPS
     (p_effective_date     => p_effective_date
     ,p_lookup_type        => 'CALENDAR_ENTRY_TYPE'
     ,p_lookup_code        => p_type
     )
    then
     -- Add to MM list
      fnd_message.set_name('PER','PER_289960_CAL_TYPE_INV');
      hr_multi_message.add
      (p_associated_column1 => 'PER_CALENDAR_ENTRIES.TYPE');
    --
    end if;
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_type;


--  ---------------------------------------------------------------------------
--  |------------------------< chk_start_date_end_date >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that START DATE and END DATE are not null. Also check that
--    START DATE <= END DATE.
--    If start_date = end_date then check that start time <= end time.
--    Also prevent start min without start hour, and end min without end hour.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_start_date_end_date
  (p_start_date        IN DATE
  ,p_end_date          IN DATE
  ,p_start_hour        IN VARCHAR2
  ,p_start_min         IN VARCHAR2
  ,p_end_hour          IN VARCHAR2
  ,p_end_min           IN VARCHAR2
  ,p_hierarchy_id      IN NUMBER
  ,p_org_structure_version_id IN NUMBER) IS
--
 l_proc  varchar2(72) := g_package||'chk_start_date_end_date';
 l_hier_date_from date;
 l_hier_date_to date;

 --Declare the cursors

cursor csr_org_hier(p_org_structure_version_id NUMBER) is
  select date_from,date_to
 from PER_ORG_STRUCTURE_VERSIONS
where org_structure_version_id = p_org_structure_version_id;

cursor csr_geo_hier(p_hierarchy_id NUMBER) is
 select date_from, date_to
 from PER_GEN_HIERARCHY_VERSIONS
where hierarchy_id = p_hierarchy_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory incident_date is set
  --
  if p_start_date is null then
    -- Add to MM list
    fnd_message.set_name('PER','PER_289961_ENT_SDATE_NULL');
    hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.START_DATE');
  end if;

  if p_end_date is NULL then
    -- Add to MM list
    fnd_message.set_name('PER','PER_289962_ENT_EDATE_NULL');
    hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.END_DATE');
  end if;

  if ((p_end_date is NOT NULL and  p_start_date is NOT NULL) and
      (p_start_date > p_end_date)) then
    -- Add to MM list
    fnd_message.set_name('PER','PER_289963_ENT_SDATE_INV');
    hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.START_DATE');
  end if;
  --

  -- only validate time if date is OK....

  if (p_start_min is NOT NULL and p_start_hour is NULL) or
     (p_end_min is NOT NULL and p_end_hour is NULL) then
    -- Add to MM list as invalid combination passed
    fnd_message.set_name('PER','PER_289187_CAL_ENT_TIME_INV');
    hr_multi_message.add
      (p_associated_column1 => 'PER_CALENDAR_ENTRIES.START_HOUR'
      ,p_associated_column2 => 'PER_CALENDAR_ENTRIES.START_MIN'
      ,p_associated_column3 => 'PER_CALENDAR_ENTRIES.END_HOUR'
      ,p_associated_column4 => 'PER_CALENDAR_ENTRIES.END_MIN');

  else
    if (p_start_min is NOT NULL and p_end_min is NOT NULL) or
     (p_start_hour is NOT NULL and p_end_hour is NOT NULL) then

     -- do times comparison...
      if ( nvl(to_number(p_start_hour),0) = nvl(to_number(p_end_hour),23)
          and nvl(to_number(p_start_min),0) > nvl(to_number(p_end_min),55) )
       or ( nvl(to_number(p_start_hour),0) > nvl(to_number(p_end_hour),23) ) then

        fnd_message.set_name('PER','PER_289188_CAL_ENT_TIME_INV2');
        hr_multi_message.add
        (p_associated_column1 => 'PER_CALENDAR_ENTRIES.START_HOUR'
        ,p_associated_column2 => 'PER_CALENDAR_ENTRIES.START_MIN'
        ,p_associated_column3 => 'PER_CALENDAR_ENTRIES.END_HOUR'
        ,p_associated_column4 => 'PER_CALENDAR_ENTRIES.END_MIN');
      end if;

    end if;
  end if;

if p_org_structure_version_id is not null then
  open csr_org_hier(p_org_structure_version_id);
  fetch csr_org_hier into l_hier_date_from,l_hier_date_to;
end if;

if p_hierarchy_id is not null then
 open csr_geo_hier(p_hierarchy_id);
 fetch csr_geo_hier into l_hier_date_from,l_hier_date_to;
end if;

if l_hier_date_from is not null then
if l_hier_date_to is not null then
  if p_end_date < l_hier_date_from or p_start_date > l_hier_date_to then
   fnd_message.set_name('PER','CAC_SR_HIER_ENTRY_DATE_ERROR');
   fnd_message.raise_error;
  end if;
else
   if p_end_date< l_hier_date_from then
   fnd_message.set_name('PER','CAC_SR_HIER_ENTRY_DATE_ERROR');
   fnd_message.raise_error;
   end if;
end if;
end if;



  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_start_date_end_date;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_no_entry_values_exist >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description :
--
--    Validate that the entry can be deleted as no child
--    entry values exist.
--
--  Pre-conditions :
--
--
--  In Arguments :
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_no_entry_values_exist(p_calendar_entry_id in number) IS
--
 CURSOR csr_ev IS
  Select 'x'
  From per_cal_entry_values env
  Where env.calendar_entry_id = p_calendar_entry_id;
--
 l_proc  varchar2(72) := g_package||'chk_no_entry_values_exist';
 l_dummy varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_calendar_entry_id is not null then
    open csr_ev;
    fetch csr_ev into l_dummy;
    if csr_ev%found then
      close csr_ev;
      fnd_message.set_name('PER', 'PER_289964_CAL_NO_DELETE');
      fnd_message.raise_error;
    else
      close csr_ev;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
End chk_no_entry_values_exist;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_valueset_or_hierarchy >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the valueset id, or  generic hierarchy id, or
--    org structure and structure version id supplied.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_valueset_or_hierarchy (p_calendar_entry_id IN NUMBER
                                    ,p_value_set_id      IN NUMBER
                                    ,p_hierarchy_id      IN NUMBER
                                    ,p_business_group_id IN NUMBER
                                    ,p_organization_structure_id IN NUMBER
                                    ,p_org_structure_version_id IN NUMBER) IS

  -- Check if hierarchy exists in generic hierarchy table:
  --  if entry is global then hierarchy must also be global
  --  if entry not global then hierarchy must be global or in the current business group
  CURSOR CSR_HIER IS
  SELECT 'Y'
  FROM  per_gen_hierarchy gen
  WHERE gen.hierarchy_id = p_hierarchy_id
  AND gen.TYPE like 'PER_CAL%'
  AND ( (p_business_group_id is not null and
         (gen.business_group_id = p_business_group_id or gen.business_group_id is null))
       OR
        (p_business_group_id is null and gen.business_group_id is null));

  -- Check Org structure (version) exists:
  --  if entry is global then Org Structure must also be global
  --  if entry not global then Org Structure must be global or in the current business group
 CURSOR CSR_ORG_HIER IS
  SELECT 'Y'
  FROM  per_org_structure_versions osv
  WHERE OSV.ORGANIZATION_STRUCTURE_ID = p_organization_structure_id
  AND   OSV.ORG_STRUCTURE_VERSION_ID  = p_org_structure_version_id
  AND ( (p_business_group_id is not null and
         (osv.business_group_id = p_business_group_id or osv.business_group_id is null))
       OR
        (p_business_group_id is null and osv.business_group_id is null) );

  -- Check if VS exists
  CURSOR CSR_VS IS
  SELECT 'Y'
  FROM  fnd_flex_value_sets vs
  WHERE vs.FLEX_VALUE_SET_ID = p_value_set_id
  AND vs.VALIDATION_TYPE = 'F';

  -- Check if child EVs exist and return coverage type for them.
  CURSOR CSR_EV IS
  SELECT decode (ent.HIERARCHY_ID, NULL,
                                        decode (ent.VALUE_SET_ID, NULL,'O','V'),
                                       'H')

  FROM  per_calendar_entries ent
  WHERE ent.calendar_entry_id = p_calendar_entry_id
  AND exists (select 'Y' from per_cal_entry_values env
              where env.calendar_entry_id = p_calendar_entry_id);
--
  l_chk_evs     BOOLEAN := FALSE;
  l_dummy       VARCHAR2(1) := NULL;
  l_param1      VARCHAR2(30);
--
  l_proc  varchar2(72) := g_package||'chk_valueset_or_hierarchy';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  IF   (p_value_set_id is not null and p_hierarchy_id is not null)
    OR (p_value_set_id is not null and (p_organization_structure_id is not null or p_org_structure_version_id is not null))
    OR (p_hierarchy_id is not null and (p_organization_structure_id is not null or p_org_structure_version_id is not null))
  THEN
    -- raise error as only one coverage source may be chosen
    fnd_message.set_name('PER','PER_289966_CAL_ENT_TWO_SET');
    hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.HIERARCHY_ID'
       ,p_associated_column2 => 'PER_CALENDAR_ENTRIES.VALUE_SET_ID');
  ELSE
     -- only validate a specific id if > 1 are not set

     --
     -- validate the VS id exists and is a SQL VS
     --
    IF ( (p_calendar_entry_id is null and p_value_set_id is not null)
        OR (p_calendar_entry_id is not null
            AND ( (p_value_set_id is not null and per_ent_shd.g_old_rec.value_set_id is null)
                 OR (p_value_set_id is null and per_ent_shd.g_old_rec.value_set_id is not null)
                 OR (p_value_set_id is not null and p_value_set_id <> per_ent_shd.g_old_rec.value_set_id))) ) THEN

      hr_utility.set_location(l_proc, 10);

      if p_value_set_id is not NULL then
        open csr_VS;
        fetch csr_VS into l_dummy;
        if csr_VS%notfound then
          close csr_VS;
          -- raise error on MM list as VS is invalid
          -- i.e. id either was not found or is not F validation type
          fnd_message.set_name('PER','PER_289967_CAL_ENT_VS_INV');
          fnd_message.set_token('VSET',p_value_set_id);
          hr_multi_message.add
            (p_associated_column1 => 'PER_CALENDAR_ENTRIES.VALUE_SET_ID');
        else
          close csr_VS;
        end if;
      end if;

      if p_calendar_entry_id is not null then
        l_chk_evs := TRUE;
      end if;

    END IF;

    -- Validate Gen hierarchy
    IF ( (p_calendar_entry_id is null and p_hierarchy_id is not null)
        OR (p_calendar_entry_id is not null
            AND ( (p_hierarchy_id is not null and per_ent_shd.g_old_rec.hierarchy_id is null)
                 OR (p_hierarchy_id is null and per_ent_shd.g_old_rec.hierarchy_id is not null)
                 OR (p_hierarchy_id is not null and p_hierarchy_id <> per_ent_shd.g_old_rec.hierarchy_id))) )  THEN

      hr_utility.set_location(l_proc, 20);

      if p_hierarchy_id is not null then
        open csr_HIER;
        fetch csr_HIER into l_dummy;
        if csr_HIER%notfound then
          close csr_HIER;
          -- raise error as gen hierarchy is invalid
          fnd_message.set_name('PER', 'PER_289968_CAL_ENT_HIER_INV');
          hr_multi_message.add
            (p_associated_column1 => 'PER_CALENDAR_ENTRIES.HIERARCHY_ID');
        else
          close csr_HIER;
        end if;
      end if;

      if p_calendar_entry_id is not null then
        l_chk_evs := TRUE;
      end if;

    END IF;


  -- validate BOTH org structure and version are supplied, if either are
  IF (p_organization_structure_id is not null and p_org_structure_version_id is null)
    OR (p_organization_structure_id is null and p_org_structure_version_id is not null) THEN
      fnd_message.set_name('PER', 'HR_289971_CAL_OS_PARAMS');
      hr_multi_message.add
            (p_associated_column1 => 'PER_CALENDAR_ENTRIES.ORGANIZATION_STRUCTURE_ID');
      hr_multi_message.add
            (p_associated_column1 => 'PER_CALENDAR_ENTRIES.ORG_STRUCTURE_VERSION_ID');

  ELSIF (p_organization_structure_id is not null and p_org_structure_version_id is not null) THEN
  -- Validate Org Hier and Version

    IF ( (p_calendar_entry_id is null)
        OR (p_calendar_entry_id is not null
             AND (  (per_ent_shd.g_old_rec.org_structure_version_id is not null
                     and p_org_structure_version_id <> per_ent_shd.g_old_rec.org_structure_version_id)
                  OR (per_ent_shd.g_old_rec.organization_structure_id is not null
                      and p_organization_structure_id <> per_ent_shd.g_old_rec.organization_structure_id)) ) ) THEN

      hr_utility.set_location(l_proc, 30);

      open csr_ORG_HIER;
      fetch csr_ORG_HIER into l_dummy;
      if csr_ORG_HIER%notfound then
        close csr_ORG_HIER;
        -- raise error as org Hierarchy is invalid
        fnd_message.set_name('PER', 'PER_289968_CAL_ENT_HIER_INV');
        hr_multi_message.add
          (p_associated_column1 => 'PER_CALENDAR_ENTRIES.ORG_STRUCTURE_VERSION_ID');
      else
        close csr_ORG_HIER;
      end if;

      if p_calendar_entry_id is not null then
        l_chk_evs := TRUE;
      end if;

    END IF;

  ELSIF (p_organization_structure_id is null and per_ent_shd.g_old_rec.organization_structure_id is not null)
         OR (p_org_structure_version_id is null and per_ent_shd.g_old_rec.org_structure_version_id is not null) THEN
    -- updating to null
    l_chk_evs := TRUE;

  END IF;

    IF l_chk_evs THEN
      -- validate that no child EV's exist
      -- for this entry, otherwise prevent update

      hr_utility.set_location(l_proc, 30);
      open csr_EV;
      fetch csr_EV into l_dummy;  -- coverage type 'V' or 'H'  or 'O'
      if csr_EV%found then
        close csr_EV;
        -- raise error on MM list passing set id column name as

        -- Set source coverage based on param
        IF (per_ent_shd.g_old_rec.hierarchy_id is not null) THEN
          l_param1 := 'Generic Hierarchy';
        ELSIF (per_ent_shd.g_old_rec.value_set_id is not NULL)  THEN
          l_param1 := 'Valueset';
        ELSIF (per_ent_shd.g_old_rec.org_structure_version_id is not NULL) THEN
          l_param1 := 'Organization Hierarchy';
        END IF;

          -- Raise the relevant error
        if l_dummy is not null then
            -- fnd_message.set_name('PER', 'HR_289969_CAL_HEVS1_EXIST');
            -- fnd_message.set_name('PER', 'HR_289972_CAL_VEVS1_EXIST');
           fnd_message.set_name('PER', 'HR_289970_CAL_HEVS2_EXIST');
          -- fnd_message.set_token('PARAM1',l_param1 );
          if l_dummy = 'H' then -- Gen Hier evs exist
            -- updating to diff hierarchy
            hr_multi_message.add
             (p_associated_column1 => 'PER_CALENDAR_ENTRIES.HIERARCHY_ID');
          elsif l_dummy = 'V' then  -- VS evs exist
            -- updating from VS to hierarchy
              hr_multi_message.add
             (p_associated_column1 => 'PER_CALENDAR_ENTRIES.VALUE_SET_ID');
          elsif l_dummy = 'O' then  -- Org Hier evs exist
              hr_multi_message.add
             (p_associated_column1 => 'PER_CALENDAR_ENTRIES.ORG_STRUCTURE_VERSION_ID');
          end if;

        end if;
      else
        close csr_EV;
      end if;
    END IF;

  --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_valueset_or_hierarchy;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_legislation_code >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates the Legislation Code exists in fnd_territories or is NULL.
--   Note: This should only be NOT NULL when called by SEED DB user.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_legislation_code (p_legislation_code in VARCHAR2) IS
--
  l_proc  varchar2(72) := g_package||'chk_legislation_code';
  l_value varchar2(240) := 'DUMMY';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF p_legislation_code IS NOT NULL THEN
    l_value := hr_general.DECODE_TERRITORY(P_TERRITORY_CODE => p_legislation_code);

    IF l_value IS NULL then
     -- Add to MM list as non-fatal
      fnd_message.set_name('PER','PER_449075_CAL_LEG_CODE');
      hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.LEGISLATION_CODE');
    END IF;
   --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_legislation_code;
--
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
  FROM PER_CALENDAR_ENTRIES ENT
  WHERE ENT.IDENTIFIER_KEY = p_identifier_key;

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
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.identifier_key');
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
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_id_leg_comb >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Validates that both legislation_code and identidfier key are supplied
--   if either is supplied.
--
-- In Arguments:
--
-- Post Success: processing contines
--
-- Post Failure: processing halts and error is raised.
--
Procedure chk_id_leg_comb (p_legislation_code in VARCHAR2
                          ,p_identifier_key in VARCHAR2) IS
--
  l_proc  varchar2(72) := g_package||'chk_id_leg_comb';
  l_value varchar2(240) := 'DUMMY';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF (p_legislation_code IS NOT NULL AND p_identifier_key IS NULL)
     OR (p_legislation_code IS NULL AND p_identifier_key IS NOT NULL) THEN

   -- Add to MM list as non-fatal
    fnd_message.set_name('PER','PER_449076_CAL_LEG_ID_COMB');
    hr_multi_message.add
       (p_associated_column1 => 'PER_CALENDAR_ENTRIES.LEGISLATION_CODE'
       ,p_associated_column2 => 'PER_CALENDAR_ENTRIES.IDENTIFIER_KEY');
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_id_leg_comb;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_ent_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  If p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_ent_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  End If;

  -- validate entry name
  chk_name (p_name => p_rec.name);

  -- validate entry type
  chk_type (p_type              => p_rec.type
           ,p_calendar_entry_id => p_rec.calendar_entry_id
           ,p_effective_date    => p_effective_date);


  -- validate start date and end date
  chk_start_date_end_date (p_start_date => p_rec.start_date
                          ,p_end_date   => p_rec.end_date
                          ,p_start_min  => p_rec.start_min
                          ,p_start_hour => p_rec.start_hour
                          ,p_end_min   => p_rec.end_min
                          ,p_end_hour   => p_rec.end_hour
                          ,p_hierarchy_id => p_rec.hierarchy_id
                          ,p_org_structure_version_id => p_rec.org_structure_version_id);


  -- on insert only we check that the global entry is allowed
  -- by reading the HR_CROSS_BUSINESS_GROUP profile.
  If p_rec.business_group_id is null then
    If nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') <> 'Y' then
       fnd_message.set_name('PER', 'PER_289186_CAL_ENT_GLB_INV');
       hr_multi_message.add
        (p_associated_column1 => 'PER_CALENDAR_ENTRIES.BUSINESS_GROUP_ID');
    End if;
  End if;

  -- validate VS / Hierarchy id
  chk_valueset_or_hierarchy (p_calendar_entry_id => p_rec.calendar_entry_id
                            ,p_value_set_id      => p_rec.value_set_id
                            ,p_hierarchy_id      => p_rec.hierarchy_id
                            ,p_business_group_id => p_rec.business_group_id
                            ,p_organization_structure_id => p_rec.organization_structure_id
                            ,p_org_structure_version_id => p_rec.org_structure_version_id);

  -- validate Seed data params
  chk_id_leg_comb(p_legislation_code => p_rec.legislation_code,
                  p_identifier_key   => p_rec.identifier_key);
  chk_legislation_code(p_legislation_code => p_rec.legislation_code);
  chk_identifier_key(p_identifier_key => p_rec.identifier_key);


  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
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
  ,p_rec                          in per_ent_shd.g_rec_type
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
    ,p_associated_column1 => per_ent_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  End if;
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
    ,p_rec                         => p_rec
    );

  -- validate entry name
  chk_name (p_name => p_rec.name);

  -- validate entry type
  chk_type (p_type              => p_rec.type
           ,p_calendar_entry_id => p_rec.calendar_entry_id
           ,p_effective_date    => p_effective_date);

   -- validate start date and end date
  chk_start_date_end_date (p_start_date => p_rec.start_date
                          ,p_end_date   => p_rec.end_date
                          ,p_start_min  => p_rec.start_min
                          ,p_start_hour => p_rec.start_hour
                          ,p_end_min   => p_rec.end_min
                          ,p_end_hour   => p_rec.end_hour
                          ,p_hierarchy_id => p_rec.hierarchy_id
                          ,p_org_structure_version_id => p_rec.org_structure_version_id);

  If p_rec.business_group_id is null then
    If nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') <> 'Y' then
       fnd_message.set_name('PER', 'PER_289186_CAL_ENT_GLB_INV');
       hr_multi_message.add
        (p_associated_column1 => 'PER_CALENDAR_ENTRIES.BUSINESS_GROUP_ID');
    End if;
  End if;

  -- validate VS / Hierarchy id
  chk_valueset_or_hierarchy (p_calendar_entry_id => p_rec.calendar_entry_id
                            ,p_value_set_id      => p_rec.value_set_id
                            ,p_hierarchy_id      => p_rec.hierarchy_id
                            ,p_business_group_id => p_rec.business_group_id
                            ,p_organization_structure_id => p_rec.organization_structure_id
                            ,p_org_structure_version_id => p_rec.org_structure_version_id);

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ent_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- NOTE: API deletes any child entry values before this call is made.
  -- But now validate that there are no calendar entry values before we
  -- delete the entry itself.
  chk_no_entry_values_exist(p_calendar_entry_id => p_rec.calendar_entry_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_ent_bus;

/
