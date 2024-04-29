--------------------------------------------------------
--  DDL for Package Body HRI_BPL_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_ORG" AS
/* $Header: hriborg.pkb 115.2 2003/04/07 14:24:00 cbridge noship $ */

/* Define type for global organization hierarchy table */
  TYPE g_varchar2_tabtype IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

/* Define table for caching last subtree of organization hierarchy */
  g_OrgInHrchy_tab         g_varchar2_tabtype;

/* Defing empty table for resetting the cache */
  g_OrgInHrchy_empty_tab   g_varchar2_tabtype;

/* Define globals for testing whether the cache is valid */
  g_Org_Hierarchy_Version_id hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE := -1;
  g_Sup_Organization_id      hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE := -1;

/* define globals for testing if a user can see certain org hrcy versions */
  g_organization_structure_id
                  per_security_profiles.organization_structure_id%TYPE;


/******************************************************************************/
/* Empties and repopulates the global cache for the values passed in          */
/******************************************************************************/
PROCEDURE reset_subtree_cache
     ( p_org_hierarchy_version_id IN hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE
     , p_sup_organization_id      IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE)
 IS

  CURSOR csr_orgs_in_subtree
    ( cp_org_hierarchy_version_id IN hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE
    , cp_sup_organization_id      IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE) IS
  -- Selects all children of the organization passed in
  SELECT sub_organization_id
  FROM hri_cs_orgh_v orh
  WHERE orh.org_hierarchy_version_id = cp_org_hierarchy_version_id
  AND orh.sup_organization_id = cp_sup_organization_id;

BEGIN
  -- Clear cache table
  g_OrgInHrchy_tab := g_OrgInHrchy_empty_tab;

  -- Open Cursor with params in explicit loop
  FOR l_OrgInHrchy_rec IN csr_orgs_in_subtree( p_Org_Hierarchy_Version_id
                                             , p_Sup_Organization_id) LOOP
    g_OrgInHrchy_tab(l_OrgInHrchy_rec.Sub_Organization_id) := 'Y';
  END LOOP;

  -- Set globals with cache information
  g_Org_Hierarchy_Version_id := p_org_hierarchy_version_id;
  g_Sup_Organization_id      := p_sup_organization_id;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_orgs_in_subtree%ISOPEN THEN
      CLOSE csr_orgs_in_subtree;
    END IF;
    -- re-raise error
    RAISE;
END reset_subtree_cache;

/******************************************************************************/
/* Returns 1 if the test organization is within the subtree of the given      */
/* organization hierarchy defined by the given top organization               */
/******************************************************************************/
FUNCTION  indicate_in_orgh
     ( p_org_hierarchy_version_id IN hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE
     , p_top_organization_id      IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE
     , p_test_organization_id     IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE)
         RETURN NUMBER IS

  l_return_value   NUMBER;

BEGIN
  -- If the cache is invalid then reset it
  IF ( p_org_hierarchy_version_id <> g_org_hierarchy_version_id OR
       p_top_organization_id      <> g_sup_organization_id) THEN
    reset_subtree_cache( p_org_hierarchy_version_id
                       , p_top_organization_id);
  END IF;

  -- Trap exception in PL/SQL block
  BEGIN
    -- If organization stored in cache then its in the hierarchy
    IF ( g_OrgInHrchy_tab(p_test_organization_id) = 'Y')
      THEN
      l_return_value := 1;
    END IF;
  EXCEPTION
    -- Otherwise an exception will be raised - either the organization is not
    -- in the hierarchy and so a NO_DATA_FOUND error occurs, or the organization
    -- id passed is null and so a null index error occurs
    WHEN OTHERS THEN
      l_return_value := 0;
  END;

  RETURN l_return_value;

END indicate_in_orgh;


  -- returns the organization hierarchy structure id
  -- attached to the current user/responsibility security profile
  -- if none is attached, returns -1
  FUNCTION get_org_structure_id   RETURN NUMBER IS

     l_organization_structure_id
             per_security_profiles.organization_structure_id%TYPE;

  -- to get the value of the organization hierarchy structure id
  -- associated with this security profile (if any)
  CURSOR csr_get_security_profile(p_security_profile_id NUMBER) IS
  SELECT organization_structure_id
  FROM per_security_profiles
  WHERE security_profile_id = p_security_profile_id;


  BEGIN

      -- get the organization hierarchy associated with that
      -- security profile
      OPEN csr_get_security_profile(hr_security.get_security_profile);
      FETCH csr_get_security_profile INTO l_organization_structure_id;
      CLOSE csr_get_security_profile;

      RETURN(NVL(l_organization_structure_id,-1));

  END get_org_structure_id;

  -- bug  2711570
  --check if the user/responsibility secure profile has an
  --organization hierarchy set against it (org security profile form):
  --a)if it does, then only show that organization hiearchy in the list
  --  (including all of its versions, if it has more than one version)
  --b)if it does not, then show all organization hierarchy versions

  FUNCTION exist_orghvrsn_for_security(p_org_structure_version_id
                   per_org_structure_versions.org_structure_version_id%type)
                   RETURN VARCHAR2 IS

  l_check_org_vrsn NUMBER;

  CURSOR csr_check_hrchy_vrsn(p_organization_structure_id NUMBER
                             ,p_org_structure_version_id NUMBER) IS
  SELECT 1
  FROM per_org_structure_versions
  WHERE organization_structure_id = p_organization_structure_id
  AND org_structure_version_id = p_org_structure_version_id;


  BEGIN


      IF g_organization_structure_id IS NULL THEN
        -- not yet checked the user/responsibility
        -- to see if organization hierarchy set against
        -- it's security profile

        g_organization_structure_id := get_org_structure_id;

        -- if no organization hierarchy is set on the security
        -- profile then get_org_structure_id returns -1

      END IF;

      IF g_organization_structure_id = -1 THEN
          -- org hierarchy security not set for the
          -- user/responisbilty security profile
          -- therefore show all hierarchies.
          RETURN 'TRUE';
      ELSE
          -- an organization hierarchy is assigned to security profile
          -- only show version if it has same organization_structure_id
          -- and org_structure_version_id
          OPEN csr_check_hrchy_vrsn(g_organization_structure_id
                                   ,p_org_structure_version_id);
          FETCH csr_check_hrchy_vrsn INTO l_check_org_vrsn;
          IF  csr_check_hrchy_vrsn%NOTFOUND THEN
            CLOSE csr_check_hrchy_vrsn;
            RETURN 'FALSE';
          ELSE
            CLOSE csr_check_hrchy_vrsn;
            RETURN 'TRUE';
          END IF;

      END IF;

  END exist_orghvrsn_for_security;

  -- bug  2711570
  --check if the user/responsibility secure profile has an
  --organization hierarchy set against it (org security profile form):
  --a)if it does, then only show that organization hiearchy in the list
  --b)if it does not then show all organization hierarchies

  FUNCTION exist_orgh_for_security(p_organization_structure_id
                   per_org_structure_versions.organization_structure_id%type)
                   RETURN VARCHAR2 IS

  BEGIN


      IF g_organization_structure_id IS NULL THEN
        -- not yet checked the user/responsibility
        -- to see if organization hierarchy set against
        -- it's security profile

        g_organization_structure_id := get_org_structure_id;

        -- if no organization hierarchy is set on the security
        -- profile then get_org_structure_id returns -1
      END IF;

      IF g_organization_structure_id = -1 THEN
          -- org hierarchy security not set for the
          -- user/responisbilty security profile
          -- therefore show all hierarchies.
          RETURN 'TRUE';
      ELSE
          -- an organization hierarchy is assigned to security profile
          -- only show hierarchy if it has same organization_structure_id
          IF  g_organization_structure_id <> p_organization_structure_id THEN
            RETURN 'FALSE';
          ELSE
            RETURN 'TRUE';
          END IF;

      END IF;

  END exist_orgh_for_security;

END hri_bpl_org;

/
