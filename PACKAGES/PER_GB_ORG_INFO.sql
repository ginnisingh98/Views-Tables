--------------------------------------------------------
--  DDL for Package PER_GB_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_ORG_INFO" AUTHID CURRENT_USER as
/* $Header: pegborgp.pkh 120.2.12010000.2 2008/09/11 13:18:13 emunisek ship $ */
PROCEDURE CREATE_GB_ORG_INFO(
         p_organization_id             NUMBER
        ,p_org_info_type_code          VARCHAR2
        ,p_org_information1            VARCHAR2
        ,p_org_information3            VARCHAR2 --Added for bug 7338614
        ,p_org_information10           VARCHAR2
        );
PROCEDURE UPDATE_GB_ORG_INFO(
         p_org_info_type_code     VARCHAR2
        ,p_org_information1       VARCHAR2
        ,p_org_information3       VARCHAR2 --Added for bug 7338614
        ,p_org_information10      VARCHAR2
        ,p_org_information_id     NUMBER
        );
END PER_GB_ORG_INFO;

/
