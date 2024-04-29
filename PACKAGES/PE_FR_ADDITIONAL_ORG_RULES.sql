--------------------------------------------------------
--  DDL for Package PE_FR_ADDITIONAL_ORG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_FR_ADDITIONAL_ORG_RULES" AUTHID CURRENT_USER AS
/* $Header: pefrorgh.pkh 120.0 2005/05/31 08:59:46 appldev noship $ */

PROCEDURE fr_validate_org_info_ins
  (p_effective_date                 IN  DATE
  ,p_organization_id                IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_org_information6               IN  VARCHAR2
  ,p_org_information7               IN  VARCHAR2
  ,p_org_information8               IN  VARCHAR2
  ,p_org_information9               IN  VARCHAR2
  ,p_org_information10              IN  VARCHAR2
  ,p_org_information11              IN  VARCHAR2
  ,p_org_information12              IN  VARCHAR2
  ,p_org_information13              IN  VARCHAR2
  ,p_org_information14              IN  VARCHAR2
  ,p_org_information15              IN  VARCHAR2
  ,p_org_information16              IN  VARCHAR2
  ,p_org_information17              IN  VARCHAR2
  ,p_org_information18              IN  VARCHAR2
  ,p_org_information19              IN  VARCHAR2
  ,p_org_information20              IN  VARCHAR2
   );

PROCEDURE fr_validate_org_info_upd
  (p_effective_date                 IN  DATE
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_org_information6               IN  VARCHAR2
  ,p_org_information7               IN  VARCHAR2
  ,p_org_information8               IN  VARCHAR2
  ,p_org_information9               IN  VARCHAR2
  ,p_org_information10              IN  VARCHAR2
  ,p_org_information11              IN  VARCHAR2
  ,p_org_information12              IN  VARCHAR2
  ,p_org_information13              IN  VARCHAR2
  ,p_org_information14              IN  VARCHAR2
  ,p_org_information15              IN  VARCHAR2
  ,p_org_information16              IN  VARCHAR2
  ,p_org_information17              IN  VARCHAR2
  ,p_org_information18              IN  VARCHAR2
  ,p_org_information19              IN  VARCHAR2
  ,p_org_information20              IN  VARCHAR2
  ,p_org_information_id             IN  NUMBER
  ,p_object_version_number          IN  NUMBER
  );

PROCEDURE fr_validate_org_info
  (p_effective_date                 IN  DATE
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_organization_id                IN  NUMBER default null   /* ins only */
  ,p_org_information_id             IN  NUMBER default null   /* upd only */
  ,p_object_version_number          IN  NUMBER default null   /* upd only */  );

END pe_fr_additional_org_rules;

 

/
