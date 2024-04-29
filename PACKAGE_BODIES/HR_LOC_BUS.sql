--------------------------------------------------------
--  DDL for Package Body HR_LOC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOC_BUS" AS
  /* $Header: hrlocrhi.pkb 120.7.12010000.2 2008/12/30 10:18:50 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package           VARCHAR2(33) := '  hr_loc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code  VARCHAR2(150)       DEFAULT NULL;
g_location_id       NUMBER              DEFAULT NULL;
--
--
--
-- -----------------------------------------------------------------------
-- |----------------------< return_legislation_code >--------------------|
-- -----------------------------------------------------------------------
--
FUNCTION return_legislation_code
  (p_location_id              IN hr_locations.location_id%TYPE
  ) RETURN VARCHAR2 IS
  --
  -- Declare local variables
  --
  l_legislation_code  VARCHAR2(150);
  l_proc              VARCHAR2(72)  :=  'return_legislation_code';
  l_business_group_id NUMBER(15);
  --
  -- Cursor to find business_group_id.  We need to know
  -- if this is NULL before attempting to find the
  -- legislation code.
  --
  cursor csr_bus_grp_id IS
    SELECT business_group_id
      FROM hr_locations_all
     WHERE location_id = p_location_id;
  --
  -- Cursor to find legislation code.  l_business_group_id
  -- is set using csr_bus_grp_id (above).
  --
  -- Want to use business_group_id as index in this case.
  --
  -- Previous cursor technique not helpful here because the
  -- business_group_id is allowed to be NULL.
  --
    cursor csr_leg_code IS
    SELECT legislation_code
      FROM per_business_groups
     WHERE business_group_id = l_business_group_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'location_id',
                             p_argument_value => p_location_id);
  IF nvl(g_location_id, hr_api.g_number) = p_location_id THEN
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  ELSE
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    OPEN csr_bus_grp_id;
    FETCH csr_bus_grp_id INTO l_business_group_id;
    IF csr_bus_grp_id%notfound THEN
      --
      -- The primary key is invalid therefore we must error
      --
      CLOSE csr_bus_grp_id;
      fnd_message.set_name('PER', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    END IF;
    --
    IF l_business_group_id IS NULL THEN
       --
       --  If the location's business_group is NULL, we return a NULL
       --  legislation code (This is not standard).
       --
       l_legislation_code := NULL;
    ELSE
       --
       --  Otherwise get legislation code from database
       --
       OPEN csr_leg_code;
       FETCH csr_leg_code INTO l_legislation_code;
       IF csr_leg_code%notfound THEN
          --
          -- The business_group_id is invalid therefore we must error
          --
          CLOSE csr_leg_code;
          fnd_message.set_name('PER', 'HR_51395_WEB_BUS_GRP_NOT_FND');
     fnd_message.raise_error;
       ELSE
     CLOSE csr_leg_code;
       END IF;
       hr_utility.set_location(l_proc, 30);
       --
       --
    END IF;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function
    g_location_id      := p_location_id;
    g_legislation_code := l_legislation_code;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  RETURN l_legislation_code;
END return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_ship_to_loc_id_and_flag>------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates SHIP_TO_LOCATION_ID and all YES/NO flags
--
--  Process Logic:
--
--      Only perform validation if SHIP_TO_LOCATION_ID is not NULL.
--
--      i)   Check SHIP_TO_LOCATION_ID is valid within the HR_LOCATIONS_ALL table,
--           and its SHIP_TO_SITE_FLAG is 'Y'
--
--      ii)  If SHIP_TO_LOCATION_ID references a location other LOCATION_ID,
--           ensure that the current location's SHIP_TO_SITE_FLAG is 'N'.
--
--
--  Pre-Requisites:
--    None.
--
--  In Arguments:
--    p_location_id
--    p_ship_to_location_id
--    p_ship_to_site_flag
--    p_receiving_site_flag
--    p_inactive_date            -  required to validate ship_to_location
--    p_business_group_id        -  required to validate ship_to_location
--    p_effective_date
--
--  Post Success:
--    Processing continues if attributes are valid.  Also, ship_to_site_flag
--    and receiving_site flag may have been set.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Developer/Implementation notes:
--    Duplicate validation exists on form, so any changes made here or on form
--    must be dual-maintained.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_ship_to_loc_id_and_flag
  (   p_location_id            IN     hr_locations.location_id%TYPE,
      p_ship_to_location_id    IN OUT NOCOPY hr_locations.ship_to_location_id%TYPE,
      p_ship_to_site_flag      IN     hr_locations.ship_to_site_flag%TYPE,
      p_inactive_date          IN     hr_locations.inactive_date%TYPE,
      p_business_group_id      IN     hr_locations.business_group_id%TYPE,
      p_effective_date         IN     DATE )
IS
--
   l_exists             VARCHAR2(1);
   l_proc               VARCHAR2(72)  :=  g_package||'chk_ship_to_loc_id_and_flag';
--
   cursor csr_valid_ship_to_loc IS
     --
     SELECT NULL
     FROM hr_locations_all
       WHERE location_id = p_ship_to_location_id
         AND ship_to_site_flag = 'Y'
         AND nvl(inactive_date, hr_api.g_eot) >= p_effective_date
         AND (  p_business_group_id IS NULL
                OR nvl(business_group_id, p_business_group_id)
                  = p_business_group_id );
     --
BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 10);

   --
   -- Check that the ship to location ID is linked to a
   -- valid location on HR_LOCATIONS_ALL
   --
   hr_utility.set_location(l_proc, 20);
   --
   --
   -- Only check validity of ship_to_location if inserting or data has changed
   --
   IF (p_location_id IS NULL) THEN
--
-- **************************** Inserting ************************************
--
      IF p_ship_to_location_id IS NOT NULL THEN
      --
      -- If p_ship_to_location_id IS null, it defaults to location_id
      -- once this is known (i.e. in pre_insert() )
      --
      --
           hr_utility.set_location(l_proc, 25);
           --
      IF p_ship_to_site_flag = 'Y' THEN
         --
         -- Can't be a ship-to-site if p_ship_to_location_id points to another
         -- location, which it must do if it is not NULL.
         --
         hr_utility.set_message(800, 'PER_52537_LOC_INV_SHPTO_FLG');
         hr_utility.raise_error;
      ELSE
         --
         --  Fetch data from database
            --
              OPEN csr_valid_ship_to_loc;
              FETCH csr_valid_ship_to_loc INTO l_exists;
              --
              IF csr_valid_ship_to_loc%notfound THEN
               CLOSE csr_valid_ship_to_loc;
            hr_utility.set_message(800, 'PER_52501_INV_SHIP_TO_LOC');
               hr_utility.raise_error;
            ELSE
            CLOSE csr_valid_ship_to_loc;
         END IF;
      END IF;
      --
      ELSE
    IF p_ship_to_site_flag = 'N' THEN
      --
      --
      -- Can't be a ship-to-site if p_ship_to_location_id points to another
      -- location, which it must do if it is not NULL.
           -- Must be a ship-to-site if p_ship_to_location_id is NULL
      --
         hr_utility.set_message(800, 'PER_52386_INVALID_SHIP_TO_LOC');
         hr_utility.raise_error;
    END IF;
      END IF;
        --

   ELSE
      -- Start of fix 3224396
      IF nvl (p_ship_to_location_id, hr_api.g_number) <>
         nvl (hr_loc_shd.g_old_rec.ship_to_location_id, hr_api.g_number) OR
         nvl (p_ship_to_site_flag, hr_api.g_varchar2) <>
         nvl (hr_loc_shd.g_old_rec.ship_to_site_flag, hr_api.g_varchar2) THEN
      -- End of 3224396
--
-- ************************** Updating with new data ***************************
--
    --
    -- ship_to_location_id defaults to location_id if NULL.  See business rules.
    --
    --
         hr_utility.set_location(l_proc, 30);
         --
    p_ship_to_location_id := nvl (p_ship_to_location_id, p_location_id);
    ---
         IF p_ship_to_location_id = p_location_id THEN
       --
          -- Do not get data from database if we are referencing current location_id
       --
       IF (p_ship_to_site_flag = 'N') OR (nvl(p_inactive_date, hr_api.g_eot) <
                                          p_effective_date) THEN
          hr_utility.set_message(800, 'PER_52537_LOC_INV_SHPTO_FLG');
          hr_utility.raise_error;
       END IF;
         ELSE
       --
       IF (p_ship_to_site_flag = 'Y') THEN
          hr_utility.set_message(800, 'PER_52537_LOC_INV_SHPTO_FLG');
          hr_utility.raise_error;
       END IF;
       --
       --  Fetch data from database
       --
            OPEN csr_valid_ship_to_loc;
            FETCH csr_valid_ship_to_loc INTO l_exists;
            --
            IF csr_valid_ship_to_loc%notfound THEN
             CLOSE csr_valid_ship_to_loc;
          hr_utility.set_message(800, 'PER_52501_INV_SHIP_TO_LOC');
          hr_utility.raise_error;
       ELSE
          CLOSE csr_valid_ship_to_loc;
       END IF;
    END IF;
      END IF;
   END IF;
      --
   hr_utility.set_location('Leaving:'|| l_proc, 80);
END chk_ship_to_loc_id_and_flag;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_receiving_site_flag >------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates RECEIVING_SITE_FLAG
--
--
--  Pre-Requisites:
--    Ship-to-site flag has been validated
--
--  In Arguments:

--    p_ship_to_site_flag
--    p_receiving_site_flag
--
--  Post Success:
--    Processing continues if attributes are valid.  Also, ship_to_site_flag
--    and receiving_site flag may have been set.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Developer/Implementation notes:
--    Duplicate validation exists on form, so any changes made here or on form
--    must be dual-maintained.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_receiving_site_flag
  (   p_ship_to_site_flag      IN OUT NOCOPY hr_locations.ship_to_site_flag%TYPE,
      p_receiving_site_flag    IN OUT NOCOPY hr_locations.receiving_site_flag%TYPE )
IS
--
   l_proc               VARCHAR2(72)  :=  g_package||'chk_receiving_site_flag';
--
BEGIN
   --
   --  Test validity of receiving-site flag.
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   IF p_ship_to_site_flag = 'Y' AND p_receiving_site_flag <> 'Y' THEN
      hr_utility.set_message(800, 'PER_52538_LOC_INV_REC_FLAG');
      hr_utility.raise_error;
   END IF;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 20);
END chk_receiving_site_flag;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_designated_receiver_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a designated_receiver id exists in table per_people_f.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_designated_receiver_id
--    p_location_id
--    p_business_group_id
--    p_effective_date
--
--  Post Success:
--    If a row does exist in per_all_people_f for the given designated_receiver id,
--    and this person is an active employee then processing continues.
--
--  Post Failure:
--    If a row does not exist in per_people_f for the given designated_receiver id then
--    an application error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
--
PROCEDURE chk_designated_receiver_id
  (  p_designated_receiver_id   IN      hr_locations.designated_receiver_id%TYPE,
     p_location_id              IN      hr_locations.location_id%TYPE,
     p_business_group_id        IN      hr_locations.business_group_id%TYPE,
     p_effective_date           IN      DATE
  )
IS
--
   l_exists             VARCHAR2(1);
   l_proc               VARCHAR2(72)  :=  g_package||'chk_designated_receiver_id';
--
   cursor csr_valid_pers IS
     SELECT NULL
     FROM per_all_people_f
       WHERE person_id = p_designated_receiver_id
       AND employee_number IS NOT NULL
       AND p_effective_date BETWEEN effective_start_date AND effective_end_date
       AND ( p_business_group_id IS NULL
             OR p_business_group_id = business_group_id +0);

--
BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 10);
   IF p_designated_receiver_id IS NOT NULL THEN
      --
      -- Only perform validation when DESIGNATED_RECEIVER_ID is not null
      --
      IF (p_location_id IS NULL) OR
   (p_designated_receiver_id <> nvl (hr_loc_shd.g_old_rec.designated_receiver_id,
                 hr_api.g_number) )
      THEN
    --
    -- Check that the Person ID is linked to a
    -- valid person on PER_PEOPLE_F
    --
    hr_utility.set_location(l_proc, 20);
    OPEN csr_valid_pers;
    FETCH csr_valid_pers INTO l_exists;
    IF csr_valid_pers%notfound THEN
       CLOSE csr_valid_pers;
       hr_utility.set_message(800, 'PER_52502_INV_DES_REC_LOC');
       hr_utility.raise_error;
    ELSE
       CLOSE csr_valid_pers;
    END IF;
    --
      END IF;
      --
   END IF;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 30);
   --

END chk_designated_receiver_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_inactive_date>----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that inactive_date is greater than or equal to session_date
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_inactive_date
--    p_effective_date
--    p_location_id
--
--  Post Success:
--    If inactive date is greater than or equal to session date then
--    normal processing continues
--
--  Post Failure:
--    If the inactive date is less than the session date then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
--
PROCEDURE chk_inactive_date
  (p_inactive_date          IN     hr_locations.inactive_date%TYPE,
   p_effective_date         IN     DATE,
   p_location_id            IN     hr_locations.location_id%TYPE)
IS
--
   l_proc  VARCHAR2(72) := g_package||'chk_inactive_date';
--
BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   --  If set, inactive_date must be greater or equal to session date.
   --
   IF nvl (p_inactive_date, hr_api.g_eot) < p_effective_date THEN
      hr_utility.set_message(800, 'HR_7301_INVALID_INACTIVE_DATE');
      hr_utility.raise_error;
   END IF;
   --
   hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_inactive_date;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_inventory_organization_id >----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates the INVENTORY_ORGANIZATION_ID points to a valid inventory
--    organization with the use of a select statement.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_inventory_organization_id
--    p_effective_date
--    p_location_id
--
--  Post Success:
--    If the inventory_organization_id is valid then
--    normal processing continues
--
--  Post Failure:
--    If the inventory_organization_id is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
--
PROCEDURE chk_inventory_organization_id
  ( p_inventory_organization_id IN     hr_locations.inventory_organization_id%TYPE,
    p_effective_date            IN     DATE,
    p_location_id               IN     hr_locations.location_id%TYPE,
    p_operating_unit_id         IN     NUMBER)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_inventory_organization_id';
   l_exists         VARCHAR2(1);

   dummy            NUMBER := 2;
   dummy2           NUMBER := 1;
--
--
   cur BINARY_INTEGER;
   res BINARY_INTEGER;
--
BEGIN
--
   hr_utility.set_location('Entering: id '|| l_proc, 10);
--
-- Only continue if INVENTORY_ORGANIZTION_ID is not null
-- and we are updating with new data, or inserting.
--
   IF  p_inventory_organization_id IS NOT NULL  THEN
     hr_utility.set_location('Inventory Org id '|| p_inventory_organization_id, 15);
     IF  ( p_inventory_organization_id <> nvl (hr_loc_shd.g_old_rec.inventory_organization_id, hr_api.g_number) ) OR
        ( p_location_id IS NULL) THEN
       hr_utility.set_location('If Condition satisfied, checking inventory org ', 20);
    --
    DECLARE
    INV_VIEW_DOES_NOT_EXIST EXCEPTION;
    PRAGMA EXCEPTION_INIT(INV_VIEW_DOES_NOT_EXIST, -00942);
    BEGIN
    cur := DBMS_SQL.Open_Cursor;
    --
    hr_utility.set_location(l_proc||': Before parse', 30);
    --
    DBMS_SQL.Parse (cur,
           ' SELECT NULL
              FROM INV_ORGANIZATION_NAME_V
              WHERE organization_id = :pOrgId', DBMS_SQL.Native );
    DBMS_SQL.Bind_Variable (cur, 'pOrgId',p_inventory_organization_id );
    hr_utility.set_location(l_proc||': Before Execute', 40);
    res := DBMS_SQL.Execute(cur);

    -- Make sure we have a valid inventory organization
    hr_utility.set_location(l_proc||': Before Fetch', 50);
    If (DBMS_SQL.FETCH_ROWS (cur) = 0) then
       hr_utility.set_location(l_proc||': Rasing Error', 60);
       hr_utility.set_message(800, 'PER_52503_INV_INVENT_ORG_ID');
       hr_utility.raise_error;
    End if;

    hr_utility.set_location(l_proc||': Before close cursor', 70);
    DBMS_SQL.Close_Cursor (cur);
    EXCEPTION
     When INV_VIEW_DOES_NOT_EXIST Then
       hr_utility.set_location(l_proc||': View INV_ORGANIZATION_NAME_V not found', 99);
       if DBMS_SQL.Is_Open(cur) then
          DBMS_SQL.Close_Cursor(cur);
       end if;

     When Others then
       hr_utility.set_location(l_proc||': Other Error found'||sqlerrm, 99);
       if DBMS_SQL.Is_Open(cur) then
          DBMS_SQL.Close_Cursor(cur);
       end if;
       raise;
    END;

   END IF;
  END IF;
   --
   hr_utility.set_location('Leaving:'||l_proc, 40);
--
END chk_inventory_organization_id;

/*
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_tax_name >---------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that TAX_NAME is valid within the active tax codes.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_tax_name
--    p_effective_date
--    p_location_id
--
--  Post Success:
--    If the tax_name attribute is valid then
--    normal processing continues
--
--  Post Failure:
--    If the tax_name attribute is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_tax_name
  ( p_tax_name                IN     hr_locations.tax_name%TYPE,
    p_effective_date          IN     DATE,
    p_location_id             IN     hr_locations.location_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_tax_name';
   l_exists         VARCHAR2(1);
--
   cursor csr_valid_tax_name IS
     SELECT NULL
        FROM ap_tax_codes
        WHERE nvl(inactive_date, hr_api.g_eot ) >= p_effective_date
          AND name = p_tax_name;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Only continue if tax_name is not null:
--
   IF ( p_tax_name IS NOT NULL ) THEN
   --
   -- Only continue if tax_name is not null
   --p_tax_name
      IF ( p_tax_name <> nvl (hr_loc_shd.g_old_rec.tax_name, hr_api.g_varchar2) )
   OR (p_location_id IS NULL)
      --
      --  Only validate if inserting, or updating with new value
      --
      THEN
    OPEN csr_valid_tax_name;
    FETCH csr_valid_tax_name INTO l_exists;
    --
    hr_utility.set_location(l_proc, 20);
    --
    IF csr_valid_tax_name%notfound THEN
       CLOSE csr_valid_tax_name;
       hr_utility.set_message(800, 'PER_52504_INV_TAX_NAME');
       hr_utility.raise_error;
    END IF;
    --
    CLOSE csr_valid_tax_name;
      END IF;
      --
   END IF;
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_tax_name;
--
*/
--
--  ---------------------------------------------------------------------------
--  |-----------------------------<  chk_style >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates STYLE column using select statement.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_style
--    p_location_id
--
--  Post Success:
--    If the style attribute is valid then
--    normal processing continues
--
--  Post Failure:
--    If the style attribute is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_style
  (p_style                  IN     hr_locations.style%TYPE,
   p_location_id            IN     hr_locations.location_id%TYPE )
IS
--
   l_proc           VARCHAR2(72)  :=  g_package||'chk_style';
   l_exists         VARCHAR2(1);
--
   -- Bug fix 3649137.
   -- cursor modified to improve performance.

   cursor csr_valid_style IS
     SELECT NULL
        FROM fnd_descr_flex_contexts_vl vl
        WHERE vl.descriptive_flexfield_name ='Address Location'
           AND vl.enabled_flag = 'Y'
	   AND vl.application_id = 800
           AND vl.descriptive_flex_context_code = p_style;
--
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Only continue if STYLE is not null
--
   IF ( p_style IS NOT NULL ) THEN
      --
      --  Only continue if STYLE is not null
      --
      IF ( nvl(hr_loc_shd.g_old_rec.style, hr_api.g_varchar2) <> p_style)
   OR (p_location_id IS NULL ) THEN
    --
    -- Only validate if inserting, or updating with new value
    --
    OPEN csr_valid_style;
    FETCH csr_valid_style INTO l_exists;
    --
    hr_utility.set_location(l_proc, 20);
    --
    IF csr_valid_style%notfound THEN
       CLOSE csr_valid_style;
       hr_utility.set_message(800, 'PER_52505_INV_ADDRESS_STYLE');
       hr_utility.raise_error;
    END IF;
    CLOSE csr_valid_style;
      END IF;
   END IF;
--
   hr_utility.set_location(' Leaving:'|| l_proc, 30);
END chk_style;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_timezone >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates TIMEZONE_CODE column using select statement.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_timezone
--
--  Post Success:
--    If the timezone_code attribute is valid then
--    normal processing continues
--
--  Post Failure:
--    If the timezone_code attribute is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on Location form, so any changes
--    made here or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_timezone
  (p_timezone_code          IN     hr_locations.timezone_code%TYPE)
IS
--
   l_proc           VARCHAR2(72)  :=  g_package||'chk_timezone';
   l_exists         VARCHAR2(1);
--
   cursor csr_valid_timezone IS
     SELECT NULL
        FROM fnd_timezones_vl vl
        WHERE vl.timezone_code = p_timezone_code
          AND vl.enabled_flag = 'Y';
--
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Only continue if TIMEZONE_CODE is not null
--
   IF ( p_timezone_code IS NOT NULL ) THEN
      --
      --  Only continue if TIMEZONE_CODE is not null
      --
      IF ( nvl(hr_loc_shd.g_old_rec.timezone_code, hr_api.g_varchar2)
                   <> p_timezone_code) THEN
    --
    -- Only validate if inserting, or updating with new value
    --
    OPEN csr_valid_timezone;
    FETCH csr_valid_timezone INTO l_exists;
    --
    hr_utility.set_location(l_proc, 20);
    --
    IF csr_valid_timezone%notfound THEN
       CLOSE csr_valid_timezone;
       hr_utility.set_message(800, 'PER_51983_INV_TZ_CODE');
       hr_utility.raise_error;
    END IF;
    CLOSE csr_valid_timezone;
      END IF;
   END IF;
--
   hr_utility.set_location(' Leaving:'|| l_proc, 30);
END chk_timezone;
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--|-------------------------< chk_del_location >-------------------------------|
--------------------------------------------------------------------------------
--
--
--  Description
--    - Checks that the following tables do not reference the hr_locations_all
--      row
--
--           per_all_assigments_f
--           pay_wc_funds
--           per_events
--           per_all_vacancies
--           hr_all_organization_units
--           hr_all_positions_f (date tracked position table)
--           pay_element_links_f
--           per_salary_survey_mappings
--           hr_location_extra_info
--           per_us_inval_locations
--
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--     p_location_id
--
--  Post Success:
--    The record is deleted from the database.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
--
PROCEDURE chk_del_location
  ( p_location_id           IN      hr_locations.location_id%TYPE ) IS
--
   l_proc               VARCHAR2(72):= g_package||'chk_del_location';
   l_exists             VARCHAR2(1);
   l_location_id     hr_locations.location_id%TYPE;
   l_location_code      hr_locations.location_code%TYPE;
--
   --
   -- Define a cursor for each table in HRMS that contains a location id column.
   --
   cursor csr_per_all_assignments_f IS
   SELECT NULL
     FROM  per_all_assignments_f
     WHERE location_id = p_location_id;
--
   cursor csr_pay_wc_funds IS
   SELECT NULL
     FROM  pay_wc_funds
     WHERE location_id = p_location_id;
--
   cursor csr_per_events IS
   SELECT NULL
     FROM  per_events
     WHERE location_id = p_location_id;
 --
   cursor csr_per_all_vacancies IS
   SELECT NULL
     FROM  per_all_vacancies
     WHERE location_id = p_location_id;
 --
   cursor csr_hr_all_organization_units IS
   SELECT NULL
     FROM  hr_all_organization_units
     WHERE location_id = p_location_id;
--
   cursor csr_hr_all_positions_f IS
   SELECT NULL
     FROM  hr_all_positions_f
     WHERE location_id = p_location_id;
--
   cursor csr_pay_element_links_f IS
   SELECT NULL
     FROM  pay_element_links_f
     WHERE location_id = p_location_id;
 --
   cursor csr_per_salary_survey_mappings IS
   SELECT NULL
     FROM  per_salary_survey_mappings
     WHERE location_id = p_location_id;

   cursor csr_hr_location_extra_info IS
   SELECT NULL
     FROM  hr_location_extra_info
     WHERE location_id = p_location_id;
--
   cursor csr_per_us_inval_locations IS
   SELECT NULL
     FROM  per_us_inval_locations
     WHERE location_id = p_location_id;

--- Fix For Bug 7644045 Starts ---
cursor csr_legal_location_flag is
     select NULL
     from HR_LOCATIONS_ALL
     where location_id = p_location_id
     and LEGAL_ADDRESS_FLAG ='Y';
--- Fix For Bug 7644045 Ends ---

--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- get the proposal details first.
  --
  OPEN csr_per_all_assignments_f;
  FETCH csr_per_all_assignments_f INTO l_exists;
  IF csr_per_all_assignments_f%found THEN
     CLOSE csr_per_all_assignments_f;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_per_all_assignments_f;
  --
  --
  hr_utility.set_location(l_proc, 15);
  OPEN csr_pay_wc_funds;
  FETCH csr_pay_wc_funds INTO l_exists;
  IF csr_pay_wc_funds%found THEN
     CLOSE csr_pay_wc_funds ;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_pay_wc_funds ;
  --
  --
  hr_utility.set_location(l_proc, 20);
  OPEN csr_per_events;
  FETCH csr_per_events INTO l_exists;
  IF csr_per_events%found THEN
     CLOSE csr_per_events;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_per_events;
  --
  --
  hr_utility.set_location(l_proc, 25);
  OPEN csr_per_all_vacancies;
  FETCH csr_per_all_vacancies INTO l_exists;
  IF csr_per_all_vacancies%found THEN
     CLOSE csr_per_all_vacancies;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_per_all_vacancies;
  --
  --
  hr_utility.set_location(l_proc, 30);
  OPEN csr_hr_all_organization_units;
  FETCH csr_hr_all_organization_units INTO l_exists;
  IF csr_hr_all_organization_units%found THEN
     CLOSE csr_hr_all_organization_units;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_hr_all_organization_units;
  --
  -- Added by SCNair on 30-SEP-99 (position date tracked table)
  --
  hr_utility.set_location(l_proc, 35);
  OPEN csr_hr_all_positions_f;
  FETCH csr_hr_all_positions_f INTO l_exists;
  IF csr_hr_all_positions_f%found THEN
     CLOSE csr_hr_all_positions_f;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_hr_all_positions_f;
  --
  --
  hr_utility.set_location(l_proc, 40);
  OPEN csr_pay_element_links_f;
  FETCH csr_pay_element_links_f INTO l_exists;
  IF csr_pay_element_links_f%found THEN
     CLOSE csr_pay_element_links_f;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_pay_element_links_f;
  --
  --
  hr_utility.set_location(l_proc, 45);
  OPEN csr_per_salary_survey_mappings;
  FETCH csr_per_salary_survey_mappings INTO l_exists;
  IF csr_per_salary_survey_mappings%found THEN
     CLOSE csr_per_salary_survey_mappings;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_per_salary_survey_mappings;
  --
  --
  hr_utility.set_location(l_proc, 50);
  OPEN csr_hr_location_extra_info;
  FETCH csr_hr_location_extra_info INTO l_exists;
  IF csr_hr_location_extra_info%found THEN
     CLOSE csr_hr_location_extra_info;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_hr_location_extra_info;
  --
  --
  hr_utility.set_location(l_proc, 55);
  OPEN csr_per_us_inval_locations;
  FETCH csr_per_us_inval_locations INTO l_exists;
  IF csr_per_us_inval_locations%found THEN
     CLOSE csr_per_us_inval_locations;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_per_us_inval_locations;
  --
--- Fix For Bug 7644045 Starts ---
  OPEN csr_legal_location_flag ;
  FETCH csr_legal_location_flag INTO l_exists;
  IF csr_legal_location_flag%found THEN
  hr_utility.set_location(l_proc, 60);
     CLOSE csr_legal_location_flag;
     hr_utility.set_message(800, 'PER_52506_CHK_DEL_LOCATION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_legal_location_flag;
--- Fix For Bug 7644045 Ends ---


  --
  -- Call pre-delete validation provided by other Apps
  --
  inv_location.inv_predel_validation  ( p_location_id => p_location_id);
  po_locations_s.po_predel_validation ( p_location_id => p_location_id);
  oe_location.oe_predel_validation    ( p_location_id => p_location_id);
  qa_location.qa_predel_validation    ( p_location_id => p_location_id);
  --
  hr_utility.set_location('Leaving: ' ||l_proc, 80);
END chk_del_location;
--
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
--   (business_group_id, person_id, location_id, primary_flag or style)
--   have been altered.
--
-- Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_non_updateable_args(p_rec IN hr_loc_shd.g_rec_type) IS
--
  l_proc     VARCHAR2(72) := g_package||'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument VARCHAR2(30);
--
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Only proceed with validation if a row exists for
-- the current record in the HR Schema
--
  IF NOT hr_loc_shd.api_updating
                (p_location_id           => p_rec.location_id,
                 p_object_version_number => p_rec.object_version_number)
  THEN
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE ', l_proc);
    hr_utility.set_message_token('STEP ', '5');
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
       nvl (hr_loc_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
END chk_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |-----------------------------<  chk_df  >--------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ---------------------------------------------------------------------------
PROCEDURE chk_df
  (p_rec IN hr_loc_shd.g_rec_type) IS
--
  l_proc    VARCHAR2(72) := g_package||'chk_df';
--
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 10);
   hr_utility.set_location('Style is: '||p_rec.style ||  ',  Address 1 is: ' || p_rec.address_line_1, 10);
  --
  -- Address location - regular DF
  -- =============================
  --
  IF nvl(hr_loc_shd.g_old_rec.style, hr_api.g_varchar2) <>
     nvl(p_rec.style, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.address_line_1, hr_api.g_varchar2) <>
     nvl(p_rec.address_line_1, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.address_line_2, hr_api.g_varchar2) <>
     nvl(p_rec.address_line_2, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.address_line_3, hr_api.g_varchar2) <>
     nvl(p_rec.address_line_3, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.country, hr_api.g_varchar2) <>
     nvl(p_rec.country, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.postal_code, hr_api.g_varchar2) <>
     nvl(p_rec.postal_code, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.region_1, hr_api.g_varchar2) <>
     nvl(p_rec.region_1, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.region_2, hr_api.g_varchar2) <>
     nvl(p_rec.region_2, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.region_3, hr_api.g_varchar2) <>
     nvl(p_rec.region_3, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.telephone_number_1, hr_api.g_varchar2) <>
     nvl(p_rec.telephone_number_1, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.telephone_number_2, hr_api.g_varchar2) <>
     nvl(p_rec.telephone_number_2, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.telephone_number_3, hr_api.g_varchar2) <>
     nvl(p_rec.telephone_number_3, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.town_or_city, hr_api.g_varchar2) <>
     nvl(p_rec.town_or_city, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information13, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information13, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information14, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information14, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information15, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information15, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information16, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information16, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information17, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information17, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information18, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information18, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information19, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information19, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.loc_information20, hr_api.g_varchar2) <>
     nvl(p_rec.loc_information20, hr_api.g_varchar2) OR
    (p_rec.location_id IS NULL)
  THEN
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Address Location'
      ,p_attribute_category => p_rec.style
      ,p_attribute1_name    => 'ADDRESS_LINE_1'
      ,p_attribute1_value   => p_rec.address_line_1
      ,p_attribute2_name    => 'ADDRESS_LINE_2'
      ,p_attribute2_value   => p_rec.address_line_2
      ,p_attribute3_name    => 'ADDRESS_LINE_3'
      ,p_attribute3_value   => p_rec.address_line_3
      ,p_attribute4_name    => 'COUNTRY'
      ,p_attribute4_value   => p_rec.country
      ,p_attribute5_name    => 'POSTAL_CODE'
      ,p_attribute5_value   => p_rec.postal_code
      ,p_attribute6_name    => 'REGION_1'
      ,p_attribute6_value   => p_rec.region_1
      ,p_attribute7_name    => 'REGION_2'
      ,p_attribute7_value   => p_rec.region_2
      ,p_attribute8_name    => 'REGION_3'
      ,p_attribute8_value   => p_rec.region_3
      ,p_attribute9_name    => 'TELEPHONE_NUMBER_1'
      ,p_attribute9_value   => p_rec.telephone_number_1
      ,p_attribute10_name   => 'TELEPHONE_NUMBER_2'
      ,p_attribute10_value  => p_rec.telephone_number_2
      ,p_attribute11_name   => 'TELEPHONE_NUMBER_3'
      ,p_attribute11_value  => p_rec.telephone_number_3
      ,p_attribute12_name   => 'TOWN_OR_CITY'
      ,p_attribute12_value  => p_rec.town_or_city
      ,p_attribute13_name   => 'LOC_INFORMATION13'
      ,p_attribute13_value  => p_rec.loc_information13
      ,p_attribute14_name   => 'LOC_INFORMATION14'
      ,p_attribute14_value  => p_rec.loc_information14
      ,p_attribute15_name   => 'LOC_INFORMATION15'
      ,p_attribute15_value  => p_rec.loc_information15
      ,p_attribute16_name   => 'LOC_INFORMATION16'
      ,p_attribute16_value  => p_rec.loc_information16
      ,p_attribute17_name   => 'LOC_INFORMATION17'
      ,p_attribute17_value  => p_rec.loc_information17
      ,p_attribute18_name   => 'LOC_INFORMATION18'
      ,p_attribute18_value  => p_rec.loc_information18
      ,p_attribute19_name   => 'LOC_INFORMATION19'
      ,p_attribute19_value  => p_rec.loc_information19
      ,p_attribute20_name   => 'LOC_INFORMATION20'
      ,p_attribute20_value  => p_rec.loc_information20
      );
  END IF;
--
  hr_utility.set_location(l_proc, 20);
  --
  --  HR_LOCATIONS - flexible address DDF
  --  ===================================
  --
  IF nvl(hr_loc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)
  OR
     (p_rec.location_id IS NULL)
  THEN
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
--
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'HR_LOCATIONS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );
  END IF;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- JG_HR_LOCATIONS - global localizations DDF
  -- ==========================================
  --
  IF nvl(hr_loc_shd.g_old_rec.global_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute_category, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute1, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute2, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute3, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute4, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute5, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute6, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute7, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute8, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute9, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute10, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute11, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute12, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute13, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute14, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute15, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute16, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute17, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute18, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute19, hr_api.g_varchar2) OR
     nvl(hr_loc_shd.g_old_rec.global_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.global_attribute20, hr_api.g_varchar2)
  OR
     (p_rec.location_id IS NULL)
  THEN
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'JG'
      ,p_descflex_name      => 'JG_HR_LOCATIONS'
      ,p_attribute_category => p_rec.global_attribute_category
      ,p_attribute1_name    => 'GLOBAL_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.global_attribute1
      ,p_attribute2_name    => 'GLOBAL_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.global_attribute2
      ,p_attribute3_name    => 'GLOBAL_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.global_attribute3
      ,p_attribute4_name    => 'GLOBAL_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.global_attribute4
      ,p_attribute5_name    => 'GLOBAL_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.global_attribute5
      ,p_attribute6_name    => 'GLOBAL_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.global_attribute6
      ,p_attribute7_name    => 'GLOBAL_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.global_attribute7
      ,p_attribute8_name    => 'GLOBAL_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.global_attribute8
      ,p_attribute9_name    => 'GLOBAL_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.global_attribute9
      ,p_attribute10_name   => 'GLOBAL_ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.global_attribute10
      ,p_attribute11_name   => 'GLOBAL_ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.global_attribute11
      ,p_attribute12_name   => 'GLOBAL_ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.global_attribute12
      ,p_attribute13_name   => 'GLOBAL_ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.global_attribute13
      ,p_attribute14_name   => 'GLOBAL_ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.global_attribute14
      ,p_attribute15_name   => 'GLOBAL_ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.global_attribute15
      ,p_attribute16_name   => 'GLOBAL_ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.global_attribute16
      ,p_attribute17_name   => 'GLOBAL_ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.global_attribute17
      ,p_attribute18_name   => 'GLOBAL_ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.global_attribute18
      ,p_attribute19_name   => 'GLOBAL_ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.global_attribute19
      ,p_attribute20_name   => 'GLOBAL_ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.global_attribute20
      );
  END IF;
--
--
  hr_utility.set_location(' Leaving:'||l_proc, 40);
END chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (  p_rec IN OUT NOCOPY hr_loc_shd.g_rec_type,
     p_effective_date IN DATE,
     p_operating_unit_id IN NUMBER)
IS
--
   l_proc  VARCHAR2(72) := g_package||'insert_validate';
   l_constraint_name VARCHAR2(30);
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in hrloc.bru is provided (where
  -- relevant)
  --
  -- Validate business_group_id (only if set)
  -- ==========================
  --
  -- Note:  There are no calls to lookup validation procedures in this row handler
  --        at present.  If this changes, "CLIENT_INFO" may require setting - see
  --        API strategy page 12-29 onwards.
  --
  IF p_rec.business_group_id IS NOT NULL THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);
  END IF;
  --
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate inactive_date
  -- ======================
  chk_inactive_date
    (p_inactive_date              =>    p_rec.inactive_date,
     p_effective_date             =>    p_effective_date,
     p_location_id                =>    p_rec.location_id
    );
  --
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate ship_to_loc_id_and_flags
  -- =================================
  --
  chk_ship_to_loc_id_and_flag (
    p_location_id                 =>   p_rec.location_id,
    p_ship_to_location_id         =>   p_rec.ship_to_location_id,
    p_ship_to_site_flag           =>   p_rec.ship_to_site_flag,
    p_inactive_date               =>   p_rec.inactive_date,
    p_business_group_id           =>   p_rec.business_group_id,
    p_effective_date              =>   p_effective_date );
  --
  hr_utility.set_location(l_proc, 35);
  --
  -- Validate receiving_site_flag
  -- ===============================
  chk_receiving_site_flag
    ( p_ship_to_site_flag           =>   p_rec.ship_to_site_flag,
      p_receiving_site_flag         =>   p_rec.receiving_site_flag
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate designated_receiver_id
  -- ===============================
  chk_designated_receiver_id
    (p_designated_receiver_id     =>    p_rec.designated_receiver_id,
     p_location_id                =>    p_rec.location_id,
     p_business_group_id          =>    p_rec.business_group_id,
     p_effective_date             =>    p_effective_date
    );
  hr_utility.set_location(l_proc, 45);
  --
  -- Validate inventory_organization_id
  -- ==================================
  chk_inventory_organization_id
    (p_inventory_organization_id    =>    p_rec.inventory_organization_id,
     p_effective_date               =>    p_effective_date,
     p_location_id                  =>    p_rec.location_id,
     p_operating_unit_id            =>    p_operating_unit_id
    );
  --
  hr_utility.set_location(l_proc, 50);
/*  --
  -- Validate tax_name
  -- =================
  --
  chk_tax_name
    (p_tax_name                 =>    p_rec.tax_name,
     p_effective_date           =>    p_effective_date,
     p_location_id              =>    p_rec.location_id
    );
  --
  --
  */
  hr_utility.set_location(l_proc, 58);
  --
  -- Validate style
  -- ==============
  chk_style
    (p_style                    =>    p_rec.style,
     p_location_id              =>    p_rec.location_id
    );
  --
  --
  hr_utility.set_location(l_proc, 59);
  --
  -- Validate timezone_code
  -- ======================
  chk_timezone
    (p_timezone_code            =>    p_rec.timezone_code
    );
  --
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate flexfields
  -- ===================
     chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 65);
  --
END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validate
 (  p_rec IN OUT NOCOPY hr_loc_shd.g_rec_type,
    p_effective_date IN DATE,
    p_operating_unit_id IN NUMBER)
IS
--
   l_proc  VARCHAR2(72) := g_package||'update_validate';
   l_constraint_name VARCHAR2(30);
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in hrloc.bru is provided.
  --
  -- Note:  There are no calls to lookup validation procedures in this row handler
  --        at present.  If this changes, "CLIENT_INFO" may require setting - see
  --        API strategy page 12-29 onwards.
  --
  -- Check that the columns which cannot
  -- be updated have not changed
  --
  chk_non_updateable_args(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate inactive_date
  -- ======================
  chk_inactive_date
    (p_inactive_date              =>    p_rec.inactive_date,
     p_effective_date             =>    p_effective_date,
     p_location_id                =>    p_rec.location_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate ship_to_loc_id_and_flag
  -- ======================================
  chk_ship_to_loc_id_and_flag (
    p_location_id                 =>   p_rec.location_id,
    p_ship_to_location_id         =>   p_rec.ship_to_location_id,
    p_ship_to_site_flag           =>   p_rec.ship_to_site_flag,
    p_inactive_date               =>   p_rec.inactive_date,
    p_business_group_id           =>   p_rec.business_group_id,
    p_effective_date              =>   p_effective_date );
  --
  hr_utility.set_location(l_proc, 25);
  --
  -- Validate receiving_site_flag
  -- ===============================
  chk_receiving_site_flag
    ( p_ship_to_site_flag           =>   p_rec.ship_to_site_flag,
      p_receiving_site_flag         =>   p_rec.receiving_site_flag
    );
  --
  hr_utility.set_location(l_proc, 35);
  --
  -- Validate designated_receiver_id
  -- ===============================
  chk_designated_receiver_id
    (p_designated_receiver_id     =>    p_rec.designated_receiver_id,
     p_location_id                =>    p_rec.location_id,
     p_business_group_id          =>    p_rec.business_group_id,
     p_effective_date             =>    p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 45);
  --
  -- Validate inventory_organization_id
  -- ==================================
  chk_inventory_organization_id
    (p_inventory_organization_id    =>    p_rec.inventory_organization_id,
     p_effective_date               =>    p_effective_date,
     p_location_id                  =>    p_rec.location_id,
     p_operating_unit_id            =>    p_operating_unit_id
    );
  --
  hr_utility.set_location(l_proc, 50);
  /*
  --
  -- Validate tax_name
  -- =================
  --
  chk_tax_name
    (p_tax_name                 =>    p_rec.tax_name,
     p_effective_date           =>    p_effective_date,
     p_location_id              =>    p_rec.location_id
    );
  --
  --
  */
  hr_utility.set_location(l_proc, 58);
  --
  -- Validate style
  -- ==============
  chk_style
    (p_style                    =>    p_rec.style,
     p_location_id              =>    p_rec.location_id
    );
  --
  --
  hr_utility.set_location(l_proc, 59);
  --
  --
  -- Validate timezone_code
  -- ======================
  chk_timezone
    (p_timezone_code            =>    p_rec.timezone_code
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate flexfields
  -- ===================
  chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 65);
  --
END update_validate;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec          IN    hr_loc_shd.g_rec_type
 ) IS

--
  l_proc  VARCHAR2(72) := g_package||'delete_validate';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate delete
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule chk_del_location
  --
  chk_del_location
    (p_location_id              => p_rec.location_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END delete_validate;
--
--
END hr_loc_bus;

/
