--------------------------------------------------------
--  DDL for Package PER_US_ORG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_ORG_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peusvald.pkh 120.0.12010000.1 2008/10/16 15:43:59 pvelugul noship $ */
PROCEDURE INSERT_US_ORG_INFO
  (p_organization_id             IN     NUMBER
  ,p_org_info_type_code          IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2
  ,p_org_information2            IN     VARCHAR2);


PROCEDURE UPDATE_US_ORG_INFO
  (P_ORG_INFORMATION_ID          IN     NUMBER
  ,p_org_info_type_code          IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2
  ,p_org_information2            IN     VARCHAR2);

END PER_US_ORG_INFO_LEG_HOOK;


/
