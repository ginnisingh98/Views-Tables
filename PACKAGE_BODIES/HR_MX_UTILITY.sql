--------------------------------------------------------
--  DDL for Package Body HR_MX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_UTILITY" AS
/* $Header: hrmxutil.pkb 120.10.12010000.1 2008/07/28 03:31:59 appldev ship $ */

g_debug BOOLEAN;

TYPE wrip_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

gt_wrip wrip_tab;

TYPE tax_subsidy_percent_tab IS TABLE OF NUMBER
                              INDEX BY BINARY_INTEGER;

gt_tax_subsidy_percent tax_subsidy_percent_tab;

    FUNCTION per_mx_full_name(
                p_first_name        IN VARCHAR2
               ,p_middle_names      IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2
  )  RETURN VARCHAR2 IS
        --
        l_full_name  VARCHAR2(240);
        --
    BEGIN
        -------------------------------------------------------------------------
        -- The Full Name format is:
        -- "<Father's Last Name> <Mother's Last Name> <First Name> <Second Name>"
        -------------------------------------------------------------------------
        SELECT SUBSTR(LTRIM(RTRIM(
                DECODE(p_last_name, NULL, '', ' ' || p_last_name)
              ||DECODE(p_per_information1, NULL,'',' ' || p_per_information1)
              ||DECODE(p_first_name,NULL, '', ' ' || p_first_name)
              ||DECODE(p_middle_names,NULL, '', ' ' || p_middle_names)
              )), 1, 240)
        INTO   l_full_name
        FROM   dual;

        RETURN(l_full_name);
        --
    END per_mx_full_name;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_GRE_from_location                               --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : This function is used to fetch the GRE for the      --
--                  given location and BG from the Mexico specific      --
--                  Generic Hierarchy Structure.                        --
--                                                                      --
--                  If the Location is part of more than 1 GRE, then    --
--                  p_is_ambiguous flag is set to TRUE.                 --
--                                                                      --
--                  If the Location is missing from the Generic         --
--                  Hierarchy version which is active on p_session_date,--
--                  then p_missing_gre is set to TRUE.                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id        NUMBER                         --
--                  p_business_group_id  NUMBER                         --
--                  p_session_date       DATE                           --
--            OUT : p_is_ambiguous       BOOLEAN                        --
--                  p_missing_gre        BOOLEAN                        --
--         RETURN : NUMBER                                              --
--                                                                      --
---------------------------------------------------------------------------

   FUNCTION get_GRE_from_location(
                p_location_id       IN NUMBER,
                p_business_group_id IN NUMBER, -- Bug 4129001
                p_session_date      IN DATE,
                p_is_ambiguous     OUT NOCOPY BOOLEAN,
                p_missing_gre      OUT NOCOPY BOOLEAN
   ) RETURN NUMBER IS

        CURSOR csr_get_GRE_from_loc IS
        select distinct(pghn_gre.entity_id)
        from per_gen_hierarchy          pgh,
             per_gen_hierarchy_versions pghv,
             per_gen_hierarchy_nodes    pghn_loc,
             per_gen_hierarchy_nodes    pghn_gre
        where pgh.type = 'MEXICO HRMS'
          and pghv.hierarchy_id = pgh.hierarchy_id
          and p_session_date BETWEEN pghv.date_from
                              AND nvl(pghv.date_to, hr_general.end_of_time)
          and pghv.status = 'A'
          and pghn_loc.hierarchy_version_id = pghv.hierarchy_version_id
          and pghn_loc.node_type = 'MX LOCATION'
          and pghn_loc.entity_id = p_location_id
          and pghn_gre.hierarchy_node_id = pghn_loc.parent_hierarchy_node_id
          and pghn_gre.hierarchy_version_id = pghv.hierarchy_version_id
          and pghn_gre.business_group_id = p_business_group_id -- Bug 4129001
          and pghn_gre.node_type = 'MX GRE';

        l_gre_id  NUMBER;
   BEGIN

        IF p_location_id IS NULL THEN
                p_is_ambiguous := FALSE;
                p_missing_gre  := FALSE;
                return(null);
        END IF;

        OPEN csr_get_GRE_from_loc;
        LOOP

            FETCH csr_get_GRE_from_loc INTO l_gre_id;

   ------------------------------------------------
   -- The first row is fetched.
   ------------------------------------------------
            IF csr_get_GRE_from_loc%ROWCOUNT = 1 THEN
                p_is_ambiguous := FALSE;
                p_missing_gre  := FALSE;

   ------------------------------------------------
   -- No rows are fetched by the cursor
   ------------------------------------------------
            ELSIF csr_get_GRE_from_loc%NOTFOUND and csr_get_GRE_from_loc%ROWCOUNT < 1 THEN
                p_missing_gre := TRUE;
                return(null);

   ------------------------------------------------
   -- More than 1 row is fetched by the cursor.
   ------------------------------------------------
            ELSE
                p_is_ambiguous := TRUE;
                return(null);

            END IF;

            EXIT WHEN csr_get_GRE_from_loc%NOTFOUND;

        END LOOP;

   ------------------------------------------------
   -- Only 1 row is fetched. This is the GRE we need
   ------------------------------------------------
        return(l_gre_id);

   END get_GRE_from_location;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_GRE_from_scl                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : This function is used to fetch the GRE from the     --
--                  Mexico Statutory Information tab (Soft Coded Key    --
--                  Flexfield).                                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_soft_coding_keyflex_id    NUMBER                  --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------

   FUNCTION get_GRE_from_scl(p_soft_coding_keyflex_id IN NUMBER

   ) RETURN NUMBER IS

        CURSOR csr_get_GRE_from_scl IS
        SELECT segment1
          FROM hr_soft_coding_keyflex
         WHERE soft_coding_keyflex_id = p_soft_coding_keyflex_id;

        l_gre_id  NUMBER := null;
   BEGIN

        OPEN csr_get_GRE_from_scl;
        FETCH csr_get_GRE_from_scl INTO l_gre_id;
        CLOSE csr_get_GRE_from_scl;

        return(l_gre_id);

   END get_GRE_from_scl;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_bus_grp                                       --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : This procedure determines the agreement between     --
--                  specified business group and legislation.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--                  p_legislation_code      VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : Raises an error if a business group does not belong --
--                  to the legislation specified.                       --
--                                                                      --
--------------------------------------------------------------------------


PROCEDURE check_bus_grp (p_business_group_id IN NUMBER
                        ,p_legislation_code  IN VARCHAR2) AS

    CURSOR csr_bg IS
        SELECT legislation_code
        FROM per_business_groups pbg
        WHERE pbg.business_group_id = p_business_group_id;
      --
    l_legislation_code  per_business_groups.legislation_code%type;
BEGIN

   OPEN csr_bg;
--
     FETCH csr_bg
     INTO l_legislation_code;
--
     IF csr_bg%NOTFOUND THEN
        CLOSE csr_bg;
        hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
        hr_utility.raise_error;
      END IF;
      CLOSE csr_bg;
--
      IF l_legislation_code <> p_legislation_code THEN
        hr_utility.set_message(800, 'HR_7961_PER_BUS_GRP_INVALID');
        hr_utility.set_message_token('LEG_CODE', p_legislation_code);
        hr_utility.raise_error;
      END IF;
EXCEPTION
    WHEN OTHERS THEN
       IF csr_bg%ISOPEN THEN
          CLOSE csr_bg;
       END IF;
       RAISE;

END check_bus_grp;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_bg_from_person                                  --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : This function determines the business_group_id for a--
--                  given person.                                       --
-- Parameters     :                                                     --
--             IN : p_person_id          NUMBER                         --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : business_group_id    NUMBER                         --
--                                                                      --
--------------------------------------------------------------------------

FUNCTION GET_BG_FROM_PERSON (
        p_person_id per_all_people_f.person_id%type)
        RETURN per_all_people_f.business_group_id%type AS

    CURSOR csr_fetch_bg IS
    SELECT business_group_id
      FROM per_people_f
     WHERE person_id = p_person_id
       AND rownum < 2;

    l_bg_id per_all_people_f.business_group_id%type;

BEGIN
    OPEN csr_fetch_bg;
        FETCH csr_fetch_bg INTO l_bg_id;

        IF csr_fetch_bg%NOTFOUND THEN
                CLOSE csr_fetch_bg;
                hr_utility.set_message(801, 'HR_7971_PER_PER_IN_PERSON');
                hr_utility.raise_error;
        END IF;
    CLOSE csr_fetch_bg;

    RETURN (l_bg_id);
END GET_BG_FROM_PERSON;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_bg_from_assignment                              --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : This function determines the business_group_id for a--
--                  given assignment.                                   --
-- Parameters     :                                                     --
--             IN : p_assignment_id      NUMBER                         --
--            OUT : N/A                                                 --
--         RETURN : business_group_id    NUMBER                         --
--                                                                      --
--------------------------------------------------------------------------

FUNCTION GET_BG_FROM_ASSIGNMENT (
        p_assignment_id per_all_assignments_f.assignment_id%TYPE)
        RETURN per_all_assignments_f.business_group_id%TYPE AS

    CURSOR csr_fetch_bg IS
    SELECT business_group_id
      FROM per_assignments_f
     WHERE assignment_id = p_assignment_id
       AND rownum < 2;

    l_bg_id per_all_assignments_f.business_group_id%TYPE;

BEGIN
    OPEN csr_fetch_bg;
        FETCH csr_fetch_bg INTO l_bg_id;

        IF csr_fetch_bg%NOTFOUND THEN
                CLOSE csr_fetch_bg;
                hr_utility.set_message(801, 'HR_7348_PPM_ASSIGNMENT_INVALID');
                hr_utility.raise_error;
        END IF;
    CLOSE csr_fetch_bg;

    RETURN (l_bg_id);
END GET_BG_FROM_ASSIGNMENT;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_legal_employer                                  --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the legal employer based on the  --
--                  Mexico Statutory Reporting Hierarchy for given GRE  --
--                  Note: The effective date is defaulted to that of    --
--                  the session.                                        --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--             IN : p_tax_unit_id           NUMBER                      --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_legal_employer(p_business_group_id NUMBER,
                            p_tax_unit_id NUMBER) RETURN NUMBER IS
--
r_legal_employer_id    hr_organization_units.organization_id%TYPE;
lv_proc                VARCHAR2(240);
ld_effective_date      DATE;
BEGIN

   lv_proc := 'hr_mx_utility.get_legal_employer';
   r_legal_employer_id := -1;

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;

   SELECT effective_date
   INTO ld_effective_date
   FROM fnd_sessions
   WHERE session_id = USERENV('sessionid');

   IF (g_debug)
   THEN
      hr_utility.set_location(lv_proc, 10);
   END IF;

   r_legal_employer_id := get_legal_employer(p_business_group_id,
                                             p_tax_unit_id,
                                             ld_effective_date);

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_legal_employer_id;

--
END get_legal_employer;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_legal_employer                                  --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the legal employer based on the  --
--                  Mexico Statutory Reporting Hierarchy for given GRE  --
--                  as on the specifed effeective date.                 --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--             IN : p_tax_unit_id           NUMBER                      --
--             IN : p_effective_date        DATE                        --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_legal_employer(p_business_group_id NUMBER,
                            p_tax_unit_id       NUMBER,
                            p_effective_date    DATE)
RETURN NUMBER IS
--
r_legal_employer_id    hr_organization_units.organization_id%TYPE;
lv_proc                VARCHAR2(240);
BEGIN

   lv_proc := 'hr_mx_utility.get_legal_employer-2';
   r_legal_employer_id := -1;

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;

   SELECT le_node.entity_id
   INTO r_legal_employer_id
   FROM per_gen_hierarchy_nodes gre_node,
        per_gen_hierarchy_nodes le_node,
        per_gen_hierarchy_versions hier_ver,
        fnd_lookup_values lv
   WHERE gre_node.node_type =  'MX GRE'
   AND   gre_node.entity_id = p_tax_unit_id
   AND   gre_node.business_group_id = p_business_group_id
   AND   gre_node.hierarchy_version_id = le_node.hierarchy_version_id
   AND   le_node.hierarchy_node_id = gre_node.parent_hierarchy_node_id
   AND   gre_node.hierarchy_version_id = hier_ver.hierarchy_version_id
   AND   status = lv.lookup_code
   AND   lv.meaning = 'Active'
   AND   lv.LANGUAGE = 'US'
   AND   lv.lookup_type = 'PQH_GHR_HIER_VRSN_STATUS'
   AND   p_effective_date BETWEEN hier_ver.date_from
                              AND NVL(hier_ver.date_to, hr_general.end_of_time);

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_legal_employer_id;

EXCEPTION
WHEN OTHERS
THEN
   hr_utility.set_message(800, 'HR_MX_INVALID_LE');
   hr_utility.raise_error;

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_legal_employer_id;
--
END get_legal_employer;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_tbl_value_local                                 --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function to return value of the specified column    --
--                  of the user table specified.                        --
-- Parameters     :                                                     --
--             IN : p_table_name          VARCHAR2                      --
--             IN : p_column_name         VARCHAR2                      --
--             IN : p_business_group_id   NUMBER                        --
--             IN : p_organization_id     NUMBER                        --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_tbl_val_local (p_table_name VARCHAR2,
                            p_column_name VARCHAR2,
                            p_business_group_id NUMBER,
                            p_organization_id NUMBER)
RETURN VARCHAR2 IS

r_tbl_val     NUMBER;
lv_row_name   pay_user_rows_f.row_low_range_or_name%TYPE;
lv_proc       VARCHAR2(240);

FUNCTION get_organization_name (p_organization_id NUMBER)
RETURN VARCHAR2 IS

lv_org_name    hr_organization_units.name%TYPE;

BEGIN

   lv_proc := 'get_organization_name';

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;

   SELECT name
   INTO lv_org_name
   FROM hr_all_organization_units
   WHERE organization_id = p_organization_id;

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN lv_org_name;

END get_organization_name;

BEGIN
   lv_proc := 'get_tbl_val_local';

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;


   lv_row_name := get_organization_name(p_organization_id);

   BEGIN

      IF (g_debug)
      THEN
         hr_utility.trace('Getting Tax Subsidy Percent for '|| lv_row_name);
      END IF;

      r_tbl_val := FND_NUMBER.canonical_to_number(hruserdt.get_table_value(
                                  p_bus_group_id => p_business_group_id,
                                  p_table_name => p_table_name,
                                  p_col_name => p_column_name,
                                  p_row_value => lv_row_name));

      /* Bug 4187012
      gt_tax_subsidy_percent(p_organization_id) := r_tbl_val;
      */

      IF (g_debug)
      THEN
         hr_utility.trace('Found Tax Subsidy Percent : '|| r_tbl_val);
      END IF;

   EXCEPTION
   WHEN OTHERS
   THEN

      IF (g_debug)
      THEN
         hr_utility.trace('Exception in '|| lv_proc);
      END IF;

      RETURN NULL;
   END;

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_tbl_val;

END get_tbl_val_local;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_wrip                                            --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the Work Risk Insurance Premium  --
--                  for the given tax unit id                           --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--             IN : p_tax_unit_id           NUMBER                      --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_wrip(p_business_group_id NUMBER, p_tax_unit_id NUMBER)
RETURN NUMBER IS

r_wrip                         NUMBER;
lv_gre_name                    hr_organization_units.name%TYPE;
lv_proc                        VARCHAR2(240);

BEGIN

   lv_proc := 'get_wrip';

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;

   IF (NOT gt_wrip.EXISTS(p_tax_unit_id))
   THEN

     r_wrip := get_tbl_val_local('Work Risk Insurance Premium',
                                 'Percentage',
                                 p_business_group_id,
                                 p_tax_unit_id);
   ELSE
     r_wrip := gt_wrip(p_tax_unit_id);
   END IF;

   IF (r_wrip IS NULL)
   THEN

      IF (g_debug)
      THEN
         hr_utility.trace('Leaving '|| lv_proc);
      END IF;

      hr_utility.set_message(800,'HR_MX_NO_WRIP');
      hr_utility.raise_error;

      RETURN r_wrip;

   /* Bug 4187012 */
   ELSE
     gt_wrip(p_tax_unit_id) := r_wrip;
   END IF;

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_wrip;

END get_wrip;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_tax_subsidy_percent                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the Tax Subsidy Percentage.      --
--                  This function first looks at tax subsidy percentage --
--                  defined
--                  Mexico Statutory Reporting Hierarchy for given GRE  --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--             IN : p_tax_unit_id           NUMBER                      --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_tax_subsidy_percent(p_business_group_id NUMBER,
                                 p_tax_unit_id NUMBER)
RETURN NUMBER IS

r_tax_subsidy_percentage       NUMBER;
lv_gre_name                    hr_organization_units.name%TYPE;
lv_le_name                     hr_organization_units.name%TYPE;
ln_legal_employer_id           hr_organization_units.organization_id%TYPE;
lv_proc                        VARCHAR2(240);

BEGIN

   lv_proc := 'get_tax_subsidy_percent';

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;

   ln_legal_employer_id := get_legal_employer(p_business_group_id,
                                              p_tax_unit_id);

   IF (NOT gt_tax_subsidy_percent.EXISTS(p_tax_unit_id))
   THEN

     r_tax_subsidy_percentage := get_tbl_val_local('Tax Subsidy Percentage',
                                                   'Percentage',
                                                   p_business_group_id,
                                                   p_tax_unit_id);

     IF (r_tax_subsidy_percentage is NULL)
     THEN

       IF (NOT gt_tax_subsidy_percent.EXISTS(ln_legal_employer_id))
       THEN

         r_tax_subsidy_percentage := get_tbl_val_local('Tax Subsidy Percentage',
                                                       'Percentage',
                                                       p_business_group_id,
                                                       ln_legal_employer_id);
         gt_tax_subsidy_percent(ln_legal_employer_id) :=
                                                     r_tax_subsidy_percentage;
       ELSE

         r_tax_subsidy_percentage :=
                                  gt_tax_subsidy_percent(ln_legal_employer_id);
       END IF;

     ELSE
         /* Bug 4187012 */
         gt_tax_subsidy_percent(p_tax_unit_id) := r_tax_subsidy_percentage;
     END IF;

   ELSE
     r_tax_subsidy_percentage := gt_tax_subsidy_percent(p_tax_unit_id);
   END IF;

   IF (r_tax_subsidy_percentage IS NULL)
   THEN

      IF (g_debug)
      THEN
         hr_utility.trace('Leaving '|| lv_proc);
      END IF;

      hr_utility.set_message(800,'HR_MX_NO_SUBSIDY');
      hr_utility.raise_error;

      RETURN r_tax_subsidy_percentage;

   END IF;

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_tax_subsidy_percentage;

END get_tax_subsidy_percent;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_tax_subsidy_percent                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the Tax Subsidy Percentage.      --
--                  This function first looks at tax subsidy percentage --
--                  defined for given GRE and then at the LE. The LE is --
--                  derived from get_legal_employer using the effective --
--                  date specified.                                     --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--             IN : p_tax_unit_id           NUMBER                      --
--             IN : p_effective_date        DATE                        --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_tax_subsidy_percent(p_business_group_id NUMBER,
                                 p_tax_unit_id       NUMBER,
                                 p_effective_date    DATE)
RETURN NUMBER IS

r_tax_subsidy_percentage       NUMBER;
lv_gre_name                    hr_organization_units.name%TYPE;
lv_le_name                     hr_organization_units.name%TYPE;
ln_legal_employer_id           hr_organization_units.organization_id%TYPE;
lv_proc                        VARCHAR2(240);

BEGIN

   lv_proc := 'get_tax_subsidy_percent';

   IF (g_debug)
   THEN
      hr_utility.trace('Entering '|| lv_proc);
   END IF;

   ln_legal_employer_id := get_legal_employer(p_business_group_id,
                                              p_tax_unit_id,
                                              p_effective_date);

   IF (NOT gt_tax_subsidy_percent.EXISTS(p_tax_unit_id))
   THEN

     r_tax_subsidy_percentage := get_tbl_val_local('Tax Subsidy Percentage',
                                                   'Percentage',
                                                   p_business_group_id,
                                                   p_tax_unit_id);

     IF (r_tax_subsidy_percentage is NULL)
     THEN

       IF (NOT gt_tax_subsidy_percent.EXISTS(ln_legal_employer_id))
       THEN

         r_tax_subsidy_percentage := get_tbl_val_local('Tax Subsidy Percentage',
                                                       'Percentage',
                                                       p_business_group_id,
                                                       ln_legal_employer_id);
         gt_tax_subsidy_percent(ln_legal_employer_id) :=
                                                     r_tax_subsidy_percentage;
       ELSE

         r_tax_subsidy_percentage :=
                                  gt_tax_subsidy_percent(ln_legal_employer_id);
       END IF;

     ELSE
         /* Bug 4187012 */
         gt_tax_subsidy_percent(p_tax_unit_id) := r_tax_subsidy_percentage;
     END IF;

   ELSE
     r_tax_subsidy_percentage := gt_tax_subsidy_percent(p_tax_unit_id);
   END IF;

   IF (r_tax_subsidy_percentage IS NULL)
   THEN

      IF (g_debug)
      THEN
         hr_utility.trace('Leaving '|| lv_proc);
      END IF;

      hr_utility.set_message(800,'HR_MX_NO_SUBSIDY');
      hr_utility.raise_error;

      RETURN r_tax_subsidy_percentage;

   END IF;

   IF (g_debug)
   THEN
      hr_utility.trace('Leaving '|| lv_proc);
   END IF;

   RETURN r_tax_subsidy_percentage;

END get_tax_subsidy_percent;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_hire_anniversary                                --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the date of hire of a person.    --
-- Parameters     :                                                     --
--             IN : p_person_id        NUMBER                           --
--             IN : p_effective_date   DATE                             --
--            OUT : N/A                                                 --
--         RETURN : DATE                                                --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_hire_anniversary(p_person_id      NUMBER,
                              p_effective_date DATE) RETURN DATE IS
   -- Bug 4650086
   CURSOR c_get_adj_svc_date
   IS
   SELECT pps.adjusted_svc_date
   FROM   per_periods_of_service pps,
          per_all_people_f       pap
   WHERE  pap.person_id = p_person_id
   AND    pps.person_id = pap.person_id
   AND    p_effective_date BETWEEN pap.effective_start_date
                               AND pap.effective_end_date
   AND    pps.date_start = (SELECT MAX (pps1.date_start)
                            FROM   per_periods_of_service pps1
                            WHERE  pps1.person_id = pps.person_id
                            AND    pps1.date_start <= p_effective_date);
   -- ORDER BY pps.adjusted_svc_date DESC;

   -- cursor to get the start_date or original_date_of_hire
   CURSOR c_get_hire_date
   IS
   SELECT NVL(original_date_of_hire, start_date)
   FROM   per_all_people_f
   WHERE  person_id = p_person_id
   ORDER  BY 1 desc;

   ld_adj_svc_date     DATE;
   ld_seniority_from   DATE;
BEGIN
   OPEN c_get_adj_svc_date;
   FETCH c_get_adj_svc_date INTO ld_adj_svc_date ;
   CLOSE c_get_adj_svc_date;

   hr_utility.trace('ld_adj_svc_date = '|| TO_CHAR(ld_adj_svc_date));

   IF ld_adj_svc_date IS NOT NULL THEN
      ld_seniority_from := ld_adj_svc_date ;
   ELSE
      OPEN c_get_hire_date;
      FETCH c_get_hire_date INTO ld_seniority_from;
      CLOSE c_get_hire_date ;
   END IF;

   hr_utility.trace('ld_seniority_from = '|| TO_CHAR(ld_seniority_from));

   IF ld_seniority_from IS NULL THEN
      hr_utility.trace('Cannot determine the start of service!');
      hr_utility.raise_error;
   END IF;

   RETURN (ld_seniority_from);
END get_hire_anniversary;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_seniority_social_security                       --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the seniority of the person as   --
--                  on the effective date, rounded off to the next year --
-- Parameters     :                                                     --
--             IN : p_person_id        NUMBER                           --
--             IN : p_effective_date   DATE                             --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_seniority_social_security(p_person_id      NUMBER,
                                       p_effective_date DATE) RETURN NUMBER IS
--
   ln_seniority_years  NUMBER;

BEGIN
--
   -- calculate seniority years
   SELECT CEIL((p_effective_date - get_hire_anniversary (
                                                    p_person_id,
                                                    p_effective_date))/365)
   INTO ln_seniority_years
   FROM DUAL ;

   IF ln_seniority_years < 0 THEN

      ln_seniority_years := 0;

   END IF;

   hr_utility.trace('ln_seniority_years = '|| TO_CHAR(ln_seniority_years));

   RETURN ln_seniority_years;

--
END get_seniority_social_security;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_seniority                                       --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the seniority of the person as   --
--                  on the effective date.                              --
--                  The seniority for Amends should be computed as      --
--                  follows:                                            --
--                  Fractions from 0 to 6 months, Seniority = 0         --
--                  Fractions from 6.1 to 12 months, Seniority = 1      --
--                  2 years 3 months = 2 seniority years                --
--                  2 years 6 months 1 day = 3 seniority years          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id NUMBER                          --
--             IN : p_tax_unit_id       NUMBER                          --
--             IN : p_payroll_id        NUMBER                          --
--             IN : p_person_id         NUMBER                          --
--             IN : p_effective_date    DATE                            --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_seniority(p_business_group_id IN NUMBER
                      ,p_tax_unit_id       IN NUMBER
                      ,p_payroll_id        IN NUMBER
                      ,p_person_id         IN NUMBER
                      ,p_effective_date    IN DATE)
RETURN NUMBER IS
--
   ln_seniority_years  NUMBER;
   ld_hire_date        DATE;
   ln_days_in_a_year   NUMBER;

BEGIN
--
   ln_days_in_a_year := pay_mx_utility.get_days_in_year(
                              p_business_group_id => p_business_group_id
                             ,p_tax_unit_id       => p_tax_unit_id
                             ,p_payroll_id        => p_payroll_id);

--
   ld_hire_date      := hr_mx_utility.get_hire_anniversary(
                             p_person_id      => p_person_id
                            ,p_effective_date => p_effective_date);
--
   -- calculate seniority years

   SELECT ROUND( (p_effective_date - ld_hire_date) / ln_days_in_a_year )
   INTO ln_seniority_years
   FROM DUAL ;

   IF ln_seniority_years < 0 THEN

      ln_seniority_years := 0;

   END IF;

   hr_utility.trace('ln_seniority_years = '|| TO_CHAR(ln_seniority_years));

   RETURN ln_seniority_years;

--
END get_seniority;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_IANA_charset                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to IANA charset equivalent of              --
--                  NLS_CHARACTERSET                                    --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2 IS
    CURSOR csr_get_iana_charset IS
        SELECT tag
          FROM fnd_lookup_values
         WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
           AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
           AND language = 'US';

    lv_iana_charset fnd_lookup_values.tag%type;
BEGIN
    OPEN csr_get_iana_charset;
        FETCH csr_get_iana_charset INTO lv_iana_charset;
    CLOSE csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    RETURN (lv_iana_charset);
END get_IANA_charset;

--------------------------------------------------------------------------------
-- FUNCTION chk_entry_in_lookup
--------------------------------------------------------------------------------
FUNCTION chk_entry_in_lookup
                      (p_lookup_type    IN  hr_lookups.lookup_type%TYPE
                      ,p_entry_val      IN  hr_lookups.meaning%TYPE
                      ,p_effective_date IN  hr_lookups.start_date_active%TYPE
                      ,p_message        OUT NOCOPY VARCHAR2) RETURN VARCHAR2 AS
    --
    CURSOR c_entry_in_lookup IS
    SELECT 'Y'
    FROM   hr_lookups hll
    WHERE  hll.lookup_type  = p_lookup_type
    AND    hll.lookup_code  = p_entry_val
    AND    hll.enabled_flag = 'Y'
    AND    p_effective_date BETWEEN NVL(hll.start_date_active, p_effective_date)
                             AND     NVL(hll.end_date_active, p_effective_date);

    l_found_value_in_lookup VARCHAR2(240);
    -- There is 255 character limit on the error screen
    l_msg                   VARCHAR2(255);
    --
BEGIN
    --
    l_msg := ' ';
    l_found_value_in_lookup := 'N';

    -- Check if the value exists in the lookup
    OPEN  c_entry_in_lookup;
    FETCH c_entry_in_lookup INTO l_found_value_in_lookup;
    CLOSE c_entry_in_lookup;
    --

    IF l_found_value_in_lookup = 'N' THEN

       IF  p_lookup_type = 'PAY_MX_YES_NO' THEN
           l_msg := fnd_message.get_string('PAY','PAY_MX_INVALID_YES_NO_INPUT');
       ELSIF  p_lookup_type = 'PAY_MX_PTU_CALC_METHODS' THEN
           l_msg :=
                 fnd_message.get_string('PAY','PAY_MX_INVALID_PTU_CALC_METHOD');
       END IF;

    END IF;

    --
    -- Setup Out variables and Return statements
    p_message := l_msg;
    RETURN l_found_value_in_lookup;
    --
EXCEPTION
    WHEN OTHERS THEN
         IF  c_entry_in_lookup%ISOPEN THEN
             CLOSE c_entry_in_lookup;
         END IF;
END chk_entry_in_lookup;

--
procedure DERIVE_HR_LOC_ADDRESS
                       (p_tax_name                  in varchar2,
                        p_style                     in varchar2,
                        p_address_line_1            in varchar2,
                        p_address_line_2            in varchar2,
                        p_address_line_3            in varchar2,
                        p_town_or_city              in varchar2,
                        p_country                   in varchar2,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_loc_information13         in varchar2,
                        p_loc_information14         in varchar2,
                        p_loc_information15         in varchar2,
                        p_loc_information16         in varchar2,
                        p_loc_information17         in varchar2,
                        p_attribute_category        in varchar2,
                        p_attribute1                in varchar2,
                        p_attribute2                in varchar2,
                        p_attribute3                in varchar2,
                        p_attribute4                in varchar2,
                        p_attribute5                in varchar2,
                        p_attribute6                in varchar2,
                        p_attribute7                in varchar2,
                        p_attribute8                in varchar2,
                        p_attribute9                in varchar2,
                        p_attribute10               in varchar2,
                        p_attribute11               in varchar2,
                        p_attribute12               in varchar2,
                        p_attribute13               in varchar2,
                        p_attribute14               in varchar2,
                        p_attribute15               in varchar2,
                        p_attribute16               in varchar2,
                        p_attribute17               in varchar2,
                        p_attribute18               in varchar2,
                        p_attribute19               in varchar2,
                        p_attribute20               in varchar2,
                        p_global_attribute_category in varchar2,
                        p_global_attribute1         in varchar2,
                        p_global_attribute2         in varchar2,
                        p_global_attribute3         in varchar2,
                        p_global_attribute4         in varchar2,
                        p_global_attribute5         in varchar2,
                        p_global_attribute6         in varchar2,
                        p_global_attribute7         in varchar2,
                        p_global_attribute8         in varchar2,
                        p_global_attribute9         in varchar2,
                        p_global_attribute10        in varchar2,
                        p_global_attribute11        in varchar2,
                        p_global_attribute12        in varchar2,
                        p_global_attribute13        in varchar2,
                        p_global_attribute14        in varchar2,
                        p_global_attribute15        in varchar2,
                        p_global_attribute16        in varchar2,
                        p_global_attribute17        in varchar2,
                        p_global_attribute18        in varchar2,
                        p_global_attribute19        in varchar2,
                        p_global_attribute20        in varchar2,
                        p_loc_information18         in varchar2,
                        p_loc_information19         in varchar2,
                        p_loc_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       ) is
begin
  if (ltrim(p_town_or_city) is not null) then
    p_derived_locale := p_town_or_city || ', ';
  end if;
  if (ltrim(p_region_1) is not null) then
    p_derived_locale := p_derived_locale || p_region_1 || ', ';
  end if;
  if (ltrim(p_country) is null) then
    p_derived_locale := rtrim(p_derived_locale, ',');
  else
    p_derived_locale := p_derived_locale || p_country;
  end if;
end;
--
procedure DERIVE_PER_ADD_ADDRESS
                       (p_style                     in varchar2,
                        p_address_line1             in varchar2,
                        p_address_line2             in varchar2,
                        p_address_line3             in varchar2,
                        p_country                   in varchar2,
                        p_date_to                   in date,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_town_or_city              in varchar2,
                        p_addr_attribute_category   in varchar2,
                        p_addr_attribute1           in varchar2,
                        p_addr_attribute2           in varchar2,
                        p_addr_attribute3           in varchar2,
                        p_addr_attribute4           in varchar2,
                        p_addr_attribute5           in varchar2,
                        p_addr_attribute6           in varchar2,
                        p_addr_attribute7           in varchar2,
                        p_addr_attribute8           in varchar2,
                        p_addr_attribute9           in varchar2,
                        p_addr_attribute10          in varchar2,
                        p_addr_attribute11          in varchar2,
                        p_addr_attribute12          in varchar2,
                        p_addr_attribute13          in varchar2,
                        p_addr_attribute14          in varchar2,
                        p_addr_attribute15          in varchar2,
                        p_addr_attribute16          in varchar2,
                        p_addr_attribute17          in varchar2,
                        p_addr_attribute18          in varchar2,
                        p_addr_attribute19          in varchar2,
                        p_addr_attribute20          in varchar2,
			p_add_information13         in varchar2,
			p_add_information14         in varchar2,
			p_add_information15         in varchar2,
			p_add_information16         in varchar2,
                        p_add_information17         in varchar2,
                        p_add_information18         in varchar2,
                        p_add_information19         in varchar2,
                        p_add_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       ) is
begin
  if (ltrim(p_town_or_city) is not null) then
    p_derived_locale := p_town_or_city || ', ';
  end if;
  if (ltrim(p_region_1) is not null) then
    p_derived_locale := p_derived_locale || p_region_1 || ', ';
  end if;
  if (ltrim(p_country) is null) then
    p_derived_locale := rtrim(p_derived_locale, ',');
  else
    p_derived_locale := p_derived_locale || p_country;
  end if;
end;

--
--
BEGIN
   g_debug := hr_utility.debug_enabled;
END hr_mx_utility;

/
