--------------------------------------------------------
--  DDL for Package PER_RU_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RU_ORG_INFO" AUTHID CURRENT_USER AS
/* $Header: peruorgp.pkh 120.0.12000000.1 2007/01/22 03:55:39 appldev noship $ */
 PROCEDURE CREATE_RU_ORG_INFO(
         p_organization_id      NUMBER
        ,p_org_info_type_code   VARCHAR2
        ,p_org_information1     VARCHAR2
        ,p_org_information2     VARCHAR2
        ,p_org_information3     VARCHAR2
        ,p_org_information4     VARCHAR2
        ,p_org_information5     VARCHAR2
        ,p_org_information7     VARCHAR2
        ,p_org_information8     VARCHAR2
        ,p_org_information12    VARCHAR2
         );
 PROCEDURE UPDATE_RU_ORG_INFO(
                  p_org_information_id   NUMBER
                 ,p_org_info_type_code   VARCHAR2
                 ,p_org_information1     VARCHAR2
		 ,p_org_information2     VARCHAR2
	         ,p_org_information3     VARCHAR2
	         ,p_org_information4     VARCHAR2
	         ,p_org_information5     VARCHAR2
	         ,p_org_information7     VARCHAR2
		 ,p_org_information8     VARCHAR2
		 ,p_org_information12    VARCHAR2
                          );
END PER_RU_ORG_INFO;

 

/
