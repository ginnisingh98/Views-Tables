--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_SECURITY" AS
/* $Header: hriovsec.pkb 115.0 2003/04/01 17:23:33 cbridge noship $ */

  FUNCTION exist_orghvrsn_for_security(p_org_structure_version_id
                   per_org_structure_versions.org_structure_version_id%type)
                   RETURN VARCHAR2 IS

  BEGIN

       -- call business process layer function
       RETURN hri_bpl_org.exist_orghvrsn_for_security(p_org_structure_version_id);

  END exist_orghvrsn_for_security;


  FUNCTION exist_orgh_for_security(p_organization_structure_id
                   per_org_structure_versions.organization_structure_id%type)
                   RETURN VARCHAR2 IS

  BEGIN
       -- call business process layer function
       RETURN hri_bpl_org.exist_orgh_for_security(p_organization_structure_id);
  END exist_orgh_for_security;

END hri_oltp_view_security;

/
