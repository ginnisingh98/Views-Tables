--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_ORG" AUTHID CURRENT_USER AS
/* $Header: hriodorg.pkh 115.0 2003/01/22 14:41:08 jtitmas noship $ */

FUNCTION  indicate_in_orgh
     ( p_org_hierarchy_version_id IN hri_cs_orgh_v.ORG_HIERARCHY_VERSION_ID%TYPE
     , p_top_organization_id      IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE
     , p_test_organization_id     IN hri_cs_orgh_v.SUP_ORGANIZATION_ID%TYPE)
         RETURN NUMBER;

END hri_oltp_disc_org;

 

/
