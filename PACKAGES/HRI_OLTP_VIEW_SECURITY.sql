--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_SECURITY" AUTHID CURRENT_USER AS
/* $Header: hriovsec.pkh 115.0 2003/04/01 17:23:19 cbridge noship $ */

  FUNCTION exist_orghvrsn_for_security(p_org_structure_version_id
                   per_org_structure_versions.org_structure_version_id%type)
                   RETURN VARCHAR2;

  FUNCTION exist_orgh_for_security(p_organization_structure_id
                   per_org_structure_versions.organization_structure_id%type)
                   RETURN VARCHAR2;

END hri_oltp_view_security;

 

/
