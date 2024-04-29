--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK6" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_org_classification >-----------------------|
-- ----------------------------------------------------------------------------
--


PROCEDURE create_org_classification_a
     (p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
--    ,p_org_information_id             OUT NUMBER
--     ,p_object_version_number          OUT NUMBER
 );

PROCEDURE create_org_classification_b
     (p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
--     ,p_org_information_id             OUT NUMBER
--     ,p_object_version_number          OUT NUMBER
 );

end hr_organization_bk6;

/
