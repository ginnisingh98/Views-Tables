--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_ORG" AS
/* $Header: hriodorg.pkb 115.0 2003/01/22 14:41:18 jtitmas noship $ */

FUNCTION  indicate_in_orgh
     ( p_org_hierarchy_version_id IN hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE
     , p_top_organization_id      IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE
     , p_test_organization_id     IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE)
         RETURN NUMBER IS

  l_return_value   NUMBER;

BEGIN

  l_return_value := hri_bpl_org.indicate_in_orgh
                     (p_org_hierarchy_version_id => p_org_hierarchy_version_id,
                      p_top_organization_id => p_top_organization_id,
                      p_test_organization_id => p_test_organization_id);

  RETURN l_return_value;

END indicate_in_orgh;

END hri_oltp_disc_org;

/
