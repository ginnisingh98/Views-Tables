--------------------------------------------------------
--  DDL for Package Body MO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MO_UTILS" AS
/*  $Header: AFMOUTLB.pls 120.3 2005/11/17 13:27:13 sryu noship $ */



--
-- Generic_Error (Internal)
--
-- Set error message and raise exception for unexpected sql errors.
--
PROCEDURE Generic_Error
  (  routine            IN VARCHAR2
   , errcode            IN NUMBER
   , errmsg             IN VARCHAR2
  )
IS
BEGIN
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END;

--
-- Get Set_Of_Books_Name
--
FUNCTION Get_Set_Of_Books_Name
  (  p_operating_unit         IN  NUMBER
  )
RETURN VARCHAR2 IS

BEGIN


  RETURN Get_Ledger_Name(p_operating_unit);

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'MO_UTILS.Get_Set_of_Books_Name'
                  , sqlcode
                  , sqlerrm);

END Get_Set_Of_Books_Name;


--
-- Get Set_Of_Books_Info
--
PROCEDURE Get_Set_Of_Books_Info
  (  p_operating_unit         IN NUMBER
   , p_sob_id                OUT NOCOPY NUMBER
   , p_sob_name              OUT NOCOPY VARCHAR2
  )
IS

BEGIN
  Get_Ledger_Info( p_operating_unit,
                   p_sob_id,
                   p_sob_name);
EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'MO_UTILS.Get_Set_Of_Books_Info'
                  , sqlcode
                  , sqlerrm);

END Get_Set_Of_Books_Info;

--
-- Get_Ledger_Name
--
FUNCTION Get_Ledger_Name
  (  p_operating_unit         IN  NUMBER
  )
RETURN VARCHAR2
IS
  l_ledger_name               GL_LEDGERS.Name%TYPE;

BEGIN
  SELECT gl.name
    INTO l_ledger_name
    FROM hr_organization_information o1,
         hr_organization_information o2,
         gl_ledgers_public_v gl
   WHERE o1.organization_id = o2.organization_id
     AND o1.organization_id = p_operating_unit
     AND o1.org_information_context = 'CLASS'
     AND o2.org_information_context = 'Operating Unit Information'
     AND o1.org_information1 = 'OPERATING_UNIT'
     AND o1.org_information2 = 'Y'
     AND o2.org_information3 = gl.ledger_id;

  RETURN l_ledger_name;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'MO_UTILS.Get_Ledger_Name'
                  , sqlcode
                  , sqlerrm);

END Get_Ledger_Name;


--
-- Get_Ledger_Info
--
PROCEDURE Get_Ledger_Info
  (  p_operating_unit         IN NUMBER
   , p_ledger_id                OUT NOCOPY NUMBER
   , p_ledger_name              OUT NOCOPY VARCHAR2
  )
IS
  l_ledger_id                 GL_LEDGERS.Ledger_Id%TYPE;
  l_ledger_name               GL_LEDGERS.Name%TYPE;

BEGIN
  SELECT to_number(o2.org_information3),
         gl.name
    INTO l_ledger_id,
         l_ledger_name
    FROM hr_organization_information o1,
         hr_organization_information o2,
         gl_ledgers_public_v gl
   WHERE o1.organization_id = o2.organization_id
     AND o1.organization_id = p_operating_unit
     AND o1.org_information_context = 'CLASS'
     AND o2.org_information_context = 'Operating Unit Information'
     AND o1.org_information1 = 'OPERATING_UNIT'
     AND o1.org_information2 = 'Y'
     AND o2.org_information3 = gl.ledger_id;


  p_ledger_id   := l_ledger_id;
  p_ledger_name := l_ledger_name;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'MO_UTILS.Get_Ledger_Info'
                  , sqlcode
                  , sqlerrm);

END Get_Ledger_Info;

--
-- Get Multi_Org_Flag
--
FUNCTION Get_Multi_Org_Flag
RETURN VARCHAR2
IS

BEGIN

   RETURN mo_global.is_multi_org_enabled;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'MO_UTILS.Get_Multi_Org_Flag'
                  , sqlcode
                  , sqlerrm);

END Get_Multi_Org_Flag;


--
-- Get Default_ou
--
-- Purpose:
-- Returns a default operating unit based on the
-- MO: Default Operating Unit, MO:Security Profile and MO: Operating Unit
-- profile options.
--
PROCEDURE get_default_ou
  (  p_default_org_id  OUT NOCOPY NUMBER
   , p_default_ou_name OUT NOCOPY VARCHAR2
   , p_ou_count        OUT NOCOPY NUMBER)
IS
  l_prof_org_id     hr_operating_units.organization_id%TYPE;
  l_default_org_id  hr_operating_units.organization_id%TYPE;
  l_default_ou_name hr_operating_units.name%TYPE;
BEGIN
   p_ou_count := mo_global.get_ou_count;

   IF (get_multi_org_flag <> 'Y' OR p_ou_count = 0) THEN
      RETURN; -- org id and name out parameters will be null,
              -- ou count will be 0.
   END IF;

   --
   -- If p_ou_count is 1, the session has access to only one operating
   -- unit which will be returned as the default.
   -- If p_ou_count is greater than 1, the session has access to more than
   -- one operating units. In this case, the value of the profile option
   -- MO: Default Operating Unit will be returned as the default, provided
   -- it is included in the MO: Security Profile.
   --

   IF (p_ou_count = 1) THEN
      --
      -- Commented out the code given below, since from performance
      -- perspective, using temporary table is the best way to achieve
      -- multiple access. There is no necessity to populate a PL/SQL
      -- array and consume memory.
      --
      --DECLARE
      --   l_ou_name_tab mo_global.OUNameTab;
      --BEGIN
      --   l_ou_name_tab     := mo_global.get_ou_tab;
      --   l_default_org_id  := l_ou_name_tab.FIRST;
      --   l_default_ou_name := l_ou_name_tab(l_default_org_id);
      BEGIN
        SELECT mg.organization_id
             , mg.organization_name
          INTO l_default_org_id
             , l_default_ou_name
          FROM mo_glob_org_access_tmp mg;
      EXCEPTION
         WHEN OTHERS THEN
           l_default_org_id  := null;
           l_default_ou_name := null;
      END;
   ELSE -- p_ou_count > 1
      l_prof_org_id := fnd_profile.value('DEFAULT_ORG_ID');

      IF (mo_global.check_access(l_prof_org_id) = 'Y') THEN
         l_default_org_id  := l_prof_org_id;
         l_default_ou_name := mo_global.get_ou_name(l_default_org_id);
      ELSE
         l_default_org_id  := NULL;
         l_default_ou_name := NULL;
      END IF;
   END IF;

   p_default_org_id  := l_default_org_id;
   p_default_ou_name := l_default_ou_name;

EXCEPTION
   WHEN OTHERS THEN
     Generic_Error('MO_UTILS.Get_Default_OU'
                   , sqlcode
                   , sqlerrm);
END get_default_ou;


--
-- Get Child_table_orgs
--
FUNCTION Get_Child_Tab_Orgs
  (  p_table_name    IN VARCHAR2
   , p_where         IN VARCHAR2)
RETURN VARCHAR2
IS
  l_tb_org_id        NUMBER;
  l_tb_orgid_list    VARCHAR2(4000) DEFAULT '@';
  l_tb_orgid_cnt     PLS_INTEGER;
  l_tb_sql           VARCHAR2(4000);

  TYPE OrgCurTyp     IS REF CURSOR;
  --
  -- Cursor Variable
  --
  c_tb               OrgCurTyp;

BEGIN
  --
  -- Populate Table OUs to a local variable.
  -- Note:
  -- Bug 1133214 - Native dynamic sql does not work with bulk fetch.
  --
  l_tb_sql := ' SELECT DISTINCT org_id '
           || ' FROM '
           || p_table_name
           || ' where 1=1 '
           || p_where;
  OPEN c_tb FOR l_tb_sql;
  LOOP
    FETCH c_tb
     INTO l_tb_org_id;
     l_tb_orgid_cnt := c_tb%ROWCOUNT;
     EXIT WHEN c_tb%NOTFOUND;
     l_tb_orgid_list := l_tb_orgid_list || l_tb_org_id || '@';
  END LOOP;
  CLOSE c_tb;
  --
  -- A child transaction is found.
  --
  IF l_tb_orgid_cnt > 0 THEN
    RETURN (l_tb_orgid_list);
  ELSE
    -- No data found?
    --
    -- Trim default value '@'.
    --
    RETURN (NULL);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'MO_UTILS.Get_Child_Tab_Orgs'
                  , sqlcode
                  , sqlerrm);
END get_child_tab_orgs;

--
-- get_default_org_id
--
-- Purpose:
-- Returns the ORG_ID of the default operating unit.
--
FUNCTION get_default_org_id RETURN NUMBER
IS
   l_def_org_id   hr_operating_units.organization_id%TYPE;
   l_def_org_name hr_operating_units.name%TYPE;
   l_org_count    pls_integer;
BEGIN
   get_default_ou(l_def_org_id, l_def_org_name, l_org_count);
   return l_def_org_id;

EXCEPTION
   WHEN OTHERS THEN
     generic_error('MO_UTILS.Get_Default_Org_ID', sqlcode, sqlerrm);

END get_default_org_id;

--
-- Function check_org_in_sp
--
-- Purpose
-- Returns 'Y' if an org exists in the MO: Security Profile.
-- Returns 'N' if an org does not exists in the MO: Security Profile or the
-- profile option is not set.
-- FND_GLOBAL.apps_initialize() must be called before calling this API, since
-- the profiles are read from the cache.
--
FUNCTION check_org_in_sp
  (  p_org_id      IN  NUMBER
   , p_org_class  IN  VARCHAR2)
RETURN VARCHAR2
IS
  l_security_profile_id   fnd_profile_option_values.profile_option_value%TYPE;
  l_org_exists            VARCHAR2(1) := 'N';
  l_sp_name               per_security_profiles.security_profile_name%TYPE;
  l_bg_id                 per_security_profiles.business_group_id%TYPE;
  is_view_all_org         VARCHAR2(1);

BEGIN
  --
  -- Check if input parameters are passed
  --
  IF (p_org_id IS NULL OR p_org_class IS NULL) THEN
    -- Should we raise an exception in this case or just return 'N'???????
    RETURN 'N';
  END IF;

  --
  -- Read the MO: Security Profile profile value
  --
  l_security_profile_id := fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL');

  IF l_security_profile_id IS NULL THEN
    -- Should we raise an exception in this case or just return 'N'???????
    RETURN 'N';
  ELSE

    --
    -- Check if this a view all or global view all organizations
    -- security profile. The HR table per_organization_list is not
    -- populated for view all or global view all organizations.
    --
    -- For a view all security profile within a business group,
    -- the business group id is populated per_security_profiles.
    --
    SELECT security_profile_name
         , business_group_id
         , view_all_organizations_flag
      INTO l_sp_name
         , l_bg_id
         , is_view_all_org
      FROM per_security_profiles
     WHERE security_profile_id = to_number(l_security_profile_id);

    IF (is_view_all_org = 'Y') THEN
      IF (l_bg_id IS NOT NULL) THEN
        --
        -- View all Within the Business Group Case
        --
        -- Check the classification and use appropriate views
        -- based on the classification. This is done to ensure
        -- that the org whose setup is complete is selected.
        --
        IF p_org_class = 'OPERATING_UNIT' THEN
          BEGIN
            SELECT 'Y'
              INTO l_org_exists
              FROM hr_operating_units
             WHERE business_group_id = l_bg_id
               AND organization_id = p_org_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_org_exists := 'N';
          END;
        ELSIF p_org_class = 'HR_BG' THEN
          BEGIN
            SELECT 'Y'
              INTO l_org_exists
              FROM per_business_groups
             WHERE organization_id = p_org_id
               AND business_group_id = l_bg_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_org_exists := 'N';
          END;
        END IF;


      ELSE
        --
        -- Global View all Case
        --
        -- Check the classification and use appropriate views
        -- based on the classification. This is done to ensure
        -- that the org whose setup is complete is selected.
        --
        IF p_org_class = 'OPERATING_UNIT' THEN
          BEGIN
            SELECT 'Y'
              INTO l_org_exists
              FROM hr_operating_units
             WHERE organization_id = p_org_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_org_exists := 'N';
          END;
        ELSIF p_org_class = 'HR_BG' THEN
          BEGIN
            SELECT 'Y'
              INTO l_org_exists
              FROM per_business_groups
             WHERE organization_id = p_org_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_org_exists := 'N';
          END;
        END IF;  -- for p_org_class
      END IF; -- for l_bg_id

    ELSE

      --
      -- Security Profile based on list or hierarchy Case
      --
      -- Check the classification and use appropriate views
      -- based on the classification. This is done to ensure
      -- that the org whose setup is complete is selected.
      --
      IF p_org_class = 'OPERATING_UNIT' THEN
        BEGIN
          SELECT 'Y'
            INTO l_org_exists
            FROM per_organization_list per,
                 hr_operating_units ou
           WHERE per.organization_id = ou.organization_id
             AND per.security_profile_id = l_security_profile_id
             AND ou.organization_id = p_org_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_org_exists := 'N';
         END;
      ELSIF p_org_class = 'HR_BG' THEN
        BEGIN
          SELECT 'Y'
            INTO l_org_exists
            FROM per_organization_list per,
                 per_business_groups bg
           WHERE per.organization_id = bg.organization_id
             AND per.security_profile_id = l_security_profile_id
             AND bg.organization_id = p_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_org_exists := 'N';
        END;
      END IF;  -- for p_org_class

    END IF; -- for is_view_all_org

    RETURN l_org_exists;

  END IF; -- for l_security_profile_id


EXCEPTION
  WHEN OTHERS THEN
    generic_error('MO_UTILS.Check_Org_In_SP', sqlcode, sqlerrm);
END check_org_in_sp;


--
-- Function check_ledger_in_sp
--
-- Purpose : use this function to determine if user has access to all Operating
--           Units for a given Ledger_ID that is passed in.
--
-- Returns 'Y' if an org exists in the MO: Security Profile.
-- Returns 'N' if an org does not exists in the MO: Security Profile or the
-- profile option is not set.
-- FND_GLOBAL.apps_initialize() must be called before calling this API, since
-- the profiles are read from the cache.

FUNCTION check_ledger_in_sp
  (  p_ledger_id      IN  NUMBER )
RETURN VARCHAR2
IS
l_has_full_ledger_access   VARCHAR2(1) := 'N';
TYPE OrgIdTab  IS TABLE OF hr_operating_units.organization_id%TYPE
  INDEX BY BINARY_INTEGER;
TYPE BGTab  IS TABLE OF hr_operating_units.business_group_id%TYPE
  INDEX BY BINARY_INTEGER;
t_org_id  OrgIdTab;
t_bg_id BGTab;

cursor ledger_cur  is
select  distinct ou.organization_id , ou.business_group_id  from hr_operating_units ou
where	  ou.set_of_books_id =p_ledger_id ;

begin
OPEN LEDGER_CUR;
	fetch ledger_cur  BULK COLLECT INTO t_org_id ,t_bg_id ;

FOR i IN t_org_id.FIRST .. t_org_id.LAST LOOP
-- check if bg and org id is same
-- if they are same then it is a business group
	if t_org_id(i) = t_bg_id(i) then
		l_has_full_ledger_access:=check_org_in_sp(t_bg_id(i),'HR_BG');
	else
		l_has_full_ledger_access:=check_org_in_sp(t_org_id(i),'OPERATING_UNIT');
	end if;
	if l_has_full_ledger_access = 'N' then
		return 'N';
	end if;
END LOOP;
-- if all organizations in the ledger(OU's and BG) are present in Security Profile
-- then return Y
return 'Y';

EXCEPTION
  WHEN OTHERS THEN
--    generic_error('MO_UTILS.Check_Ledger_In_SP', sqlcode, sqlerrm);
    return 'N';
END check_ledger_in_sp;


-- Get_Org_Name
--
FUNCTION Get_Org_Name
  (  p_org_id         IN  NUMBER
  )
RETURN VARCHAR2
IS
  l_org_name               HR_OPERATING_UNITS.Name%TYPE;

BEGIN

    SELECT hr.NAME
      INTO l_org_name
      FROM hr_operating_units hr
     WHERE hr.organization_id = p_org_id;

  RETURN l_org_name;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error('MO_UTILS.Get_Org_Name'
                  , sqlcode
                  , sqlerrm);

END Get_Org_Name;


END MO_UTILS;

/
