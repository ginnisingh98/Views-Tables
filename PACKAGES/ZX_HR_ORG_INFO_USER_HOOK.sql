--------------------------------------------------------
--  DDL for Package ZX_HR_ORG_INFO_USER_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_HR_ORG_INFO_USER_HOOK" AUTHID CURRENT_USER AS
/*  $Header: zxhrptpsyncs.pls 120.0 2005/09/02 01:23:25 ykonishi noship $*/

PROCEDURE create_party_tax_profile
(p_organization_id   IN NUMBER,
 p_org_classif_code  IN VARCHAR2
);


END zx_hr_org_info_user_hook;

 

/
