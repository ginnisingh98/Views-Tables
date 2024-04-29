--------------------------------------------------------
--  DDL for Package PER_ES_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_ORG_INFO" AUTHID CURRENT_USER AS
/* $Header: peesorgp.pkh 120.0.12000000.1 2007/01/21 22:29:19 appldev ship $ */
PROCEDURE CREATE_ES_ORG_INFO(p_org_info_type_code   VARCHAR2
                            ,p_org_information1     VARCHAR2
			                ,p_org_information2     VARCHAR2
			                ,p_org_information3     VARCHAR2
              			    ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2
			                ,p_org_information6     VARCHAR2
	             		    ,p_org_information7     VARCHAR2
                            ,p_org_information8     VARCHAR2
                            ,p_organization_id      NUMBER
                            ,p_effective_date       DATE
                            );

PROCEDURE UPDATE_ES_ORG_INFO(p_org_info_type_code   VARCHAR2
                            ,p_org_information1     VARCHAR2
	                	    ,p_org_information2     VARCHAR2
			                ,p_org_information3     VARCHAR2
			                ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2
	            		    ,p_org_information6     VARCHAR2
      			            ,p_org_information7     VARCHAR2
                            ,p_org_information8     VARCHAR2
                            ,p_org_information_id   NUMBER
                            ,p_effective_date       DATE
                            );
END PER_ES_ORG_INFO;

 

/
