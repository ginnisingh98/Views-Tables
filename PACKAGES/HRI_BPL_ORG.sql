--------------------------------------------------------
--  DDL for Package HRI_BPL_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_ORG" AUTHID CURRENT_USER AS
/* $Header: hriborg.pkh 115.1 2003/03/04 17:39:38 cbridge noship $ */

FUNCTION  indicate_in_orgh
     ( p_org_hierarchy_version_id IN hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE
     , p_top_organization_id      IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE
     , p_test_organization_id     IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE)
         RETURN NUMBER;

  -- bug 2711570
  -- returns the organization hierarchy structure id
  -- attached to the current user/responsibility security profile
  -- if none is attached, returns -1
  FUNCTION get_org_structure_id   RETURN NUMBER;

  -- bug 2711570
  -- checks if the current user/responsibility secure profile has an
  -- organization hierarchy set against it (org security profile form):
  -- a)if it does, then only return 'TRUE' for any organization
  --   hierarchy version that has the same org_structure_version_id

  -- b)if the current user/responsibility securite profile does not
  --   have an organization hierarchy set against it:
  --   always return 'TRUE' i.e. they can view all hierarchies
  FUNCTION exist_orghvrsn_for_security(p_org_structure_version_id
                   per_org_structure_versions.org_structure_version_id%type)
                   RETURN VARCHAR2;

  -- bug 2711570
  -- checks if the current user/responsibility secure profile has an
  -- organization hierarchy set against it (org security profile form):
  -- a)if it does, then only return 'TRUE' for the organization
  --   hierarchy that has the same organization_structure_id

  -- b)if the current user/responsibility securite profile does not
  --   have an organization hierarchy set against it:
  --   always return 'TRUE' i.e. they can view all hierarchies
  FUNCTION exist_orgh_for_security(p_organization_structure_id
                   per_org_structure_versions.organization_structure_id%type)
                   RETURN VARCHAR2;

END hri_bpl_org;

 

/
