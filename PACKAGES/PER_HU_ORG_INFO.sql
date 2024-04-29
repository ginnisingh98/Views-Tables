--------------------------------------------------------
--  DDL for Package PER_HU_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_ORG_INFO" AUTHID CURRENT_USER as
/* $Header: pehuorgp.pkh 120.0.12000000.1 2007/01/21 23:19:14 appldev ship $ */

PROCEDURE CREATE_HU_ORG_INFO(p_org_info_type_code   VARCHAR2
                            ,p_org_information3     VARCHAR2
                            ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2) ;

PROCEDURE UPDATE_HU_ORG_INFO(p_org_information_id   NUMBER
                            ,p_org_info_type_code   VARCHAR2
                            ,p_org_information3     VARCHAR2
                            ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2);

END PER_HU_ORG_INFO;

 

/
