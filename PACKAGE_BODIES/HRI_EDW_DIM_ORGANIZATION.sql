--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_ORGANIZATION" AS
/* $Header: hriedorg.pkb 120.3 2006/03/09 04:54:07 anmajumd noship $ */

PROCEDURE insert_row( p_organization_structure_id     NUMBER
                    , p_org_structure_version_id      NUMBER
                    , p_organization_id               NUMBER
                    , p_parent_organization_id        NUMBER
                    , p_organization_level            NUMBER
                    , p_org_last_updated              DATE) IS

  l_org_business_group_id      NUMBER;   -- Holds business group id for organization

BEGIN

  SELECT business_group_id INTO l_org_business_group_id
  FROM hr_all_organization_units
  WHERE organization_id = p_organization_id;
  --
  -- Fixed GSCC warning regarding explicit listing of columns in insert statements
  --
  INSERT INTO hri_primary_hrchys (
    organization_structure_id
    ,org_structure_version_id
    ,organization_id
    ,parent_organization_id
    ,organization_level
    ,business_group_id
    ,org_last_updated
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date )
  VALUES
    ( p_organization_structure_id
    , p_org_structure_version_id
    , p_organization_id
    , p_parent_organization_id
    , p_organization_level
    , l_org_business_group_id
    , NVL(p_org_last_updated,to_date('01-01-1990','DD-MM-YYYY'))
    , to_date(null)
    , to_number(null)
    , to_number(null)
    , to_number(null)
    , to_date(null));

END insert_row;

PROCEDURE populate_primary_org_hrchy_tab IS


/* The variable below holds the number of levels in the EDW Organization Hierarchy    */
/* When the number of levels in the actual hierarchy exceeds this, the base level     */
/* organization needs to point at its closest ancestor at the bottom of the hierarchy */
/* This is kept in the variable following, and can be maintained because the tree     */
/* walk is always done depth-first */
  l_number_of_levels      NUMBER := 8;
  l_bottom_level_parent   NUMBER := -1;

  l_organization_parent   NUMBER;  -- parent of the current organization

/* Cursor retrieving the organization structure, version and top organization of */
/* every primary hierarchy */
  CURSOR top_org_csr IS
  SELECT DISTINCT
   ost.organization_structure_id  organization_structure_id
  ,osv.org_structure_version_id   org_structure_version_id
  ,ele.organization_id_parent     top_organization_id
  ,MAX(ele.last_update_date)      last_updated
  FROM
   per_organization_structures ost
  ,per_org_structure_versions  osv
  ,per_org_structure_elements  ele
  WHERE
  ost.organization_structure_id = osv.organization_structure_id
  AND osv.org_structure_version_id = ele.org_structure_version_id
  AND ost.primary_structure_flag = 'Y'
  AND (osv.date_to IS NULL
      OR SYSDATE BETWEEN osv.date_from AND osv.date_to)
  AND NOT EXISTS (SELECT 1 FROM per_org_structure_elements dummy
                  WHERE dummy.org_structure_version_id = ele.org_structure_version_id
                  AND dummy.organization_id_child = ele.organization_id_parent)
  GROUP BY
   ost.organization_structure_id
  ,osv.org_structure_version_id
  ,ele.organization_id_parent;

/* Cursor which returns every organization in a given hierarchy along with its */
/* parent and level (because this is viewed from the perspective of the child  */
/* organization, the level is incremented */
/* Bug 5070725, including version id within START WITH condition */
  CURSOR walk_hierarchy_csr
    ( cp_org_structure_version_id  NUMBER
    , cp_top_organization_id       NUMBER) IS
  SELECT
   ele.organization_id_child   child_organization_id
  ,ele.organization_id_parent  parent_organization_id
  ,LEVEL+1                     child_level
  ,ele.last_update_date        last_updated
  FROM
   per_org_structure_elements ele
  WHERE
   ele.org_structure_version_id = cp_org_structure_version_id
  CONNECT BY (prior ele.organization_id_child = ele.organization_id_parent
    AND prior ele.org_structure_version_id = ele.org_structure_version_id)
  START WITH ele.organization_id_parent = cp_top_organization_id
  AND ele.org_structure_version_id = cp_org_structure_version_id;

BEGIN

/* Clear out table */
  DELETE FROM hri_primary_hrchys;

/* Loop through each primary hierarchy */
  FOR hierarchy_rec IN top_org_csr LOOP

  /* Insert row for top organization */
    insert_row( hierarchy_rec.organization_structure_id
              , hierarchy_rec.org_structure_version_id
              , hierarchy_rec.top_organization_id
              , NULL
              , 1
              , hierarchy_rec.last_updated);

  /* Loop through the rest of the organizations in the hierarchy */
    FOR organization_rec IN walk_hierarchy_csr
         ( hierarchy_rec.org_structure_version_id
         , hierarchy_rec.top_organization_id) LOOP

    /* Check to see if the level exceeds the number of levels in the dimension */
      IF (organization_rec.child_level = l_number_of_levels) THEN
      /* Store the id of the child, since it will be the parent of any higher */
      /* numbered levels */
        l_bottom_level_parent := organization_rec.child_organization_id;
        l_organization_parent := organization_rec.parent_organization_id;
      ELSIF (organization_rec.child_level > l_number_of_levels) THEN
      /* If the level is greater than number of levels in dimension, then point */
      /* directly to stored parent (guaranteed closest ancestor by depth first */
      /* tree walk) */
        l_organization_parent := l_bottom_level_parent;
      ELSE
      /* Use the direct parent of the organization */
        l_organization_parent := organization_rec.parent_organization_id;
      END IF;

  /* Insert row for current organization */
      insert_row( hierarchy_rec.organization_structure_id
                , hierarchy_rec.org_structure_version_id
                , organization_rec.child_organization_id
                , l_organization_parent
                , organization_rec.child_level
                , organization_rec.last_updated);

     END LOOP;     -- walk_hierarchy_csr

  END LOOP;     -- top_org_csr

END populate_primary_org_hrchy_tab;

END hri_edw_dim_organization;

/
