--------------------------------------------------------
--  DDL for Package PA_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ORG" AUTHID CURRENT_USER AS
/* $Header: PAORGS.pls 115.0 99/07/16 15:09:03 porting ship $ */
  PROCEDURE pa_predel_validation (p_org_id number);
  PROCEDURE pa_os_predel_validation (p_org_structure_id   IN number);
  PROCEDURE pa_osv_predel_validation (p_org_structure_version_id IN number);
  PROCEDURE pa_ose_predel_validation (p_org_structure_element_id IN number);
  PROCEDURE pa_org_predel_validation (p_org_id number) ;
--
END pa_org;

 

/
