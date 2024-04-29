--------------------------------------------------------
--  DDL for Package PER_FR_ORG_DDF_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_ORG_DDF_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: pefroriv.pkh 120.0 2005/05/31 09:01:06 appldev noship $ */
PROCEDURE validate_fr_opm_mapping
  (p_org_information_id          IN NUMBER
  ,p_org_information_context     IN VARCHAR2
  ,p_organization_id             IN NUMBER
  ,p_org_information1            IN VARCHAR2
  ,p_org_information2            IN VARCHAR2);

PROCEDURE validate_fr_contrib_codes
  (p_org_information_id          IN NUMBER
  ,p_org_information_context     IN VARCHAR2
  ,p_organization_id             IN NUMBER
  ,p_org_information3            IN VARCHAR2
  ,p_org_information5            IN VARCHAR2);

end per_fr_org_ddf_validation;

 

/
