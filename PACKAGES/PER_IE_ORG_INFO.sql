--------------------------------------------------------
--  DDL for Package PER_IE_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IE_ORG_INFO" AUTHID CURRENT_USER AS
/* $Header: peieorgp.pkh 120.2 2008/02/14 13:58:24 knadhan ship $ */

PROCEDURE CREATE_IE_ORG_INFO(p_org_info_type_code  VARCHAR2
                            ,p_org_information2    VARCHAR2
				    ,p_org_information3    VARCHAR2
                            ,p_organization_id     NUMBER
                            ,p_effective_date      DATE
                            );

PROCEDURE UPDATE_IE_ORG_INFO(p_org_info_type_code  VARCHAR2
                            ,p_org_information2    VARCHAR2
				    ,p_org_information3    VARCHAR2
                            ,p_org_information_id  NUMBER
                            ,p_effective_date      DATE
                            );

PROCEDURE CREATE_IE_ASG_INFO(P_PERSON_ID       NUMBER
			    ,P_PAYROLL_ID      NUMBER
                            ,p_organization_id NUMBER
			    ,P_EFFECTIVE_DATE  DATE);

PROCEDURE UPDATE_IE_ASG_INFO(P_ASSIGNMENT_ID     NUMBER
			    ,P_PAYROLL_ID    NUMBER
			    ,p_organization_id NUMBER
			    ,P_EFFECTIVE_DATE  DATE);

END PER_IE_ORG_INFO;

/
