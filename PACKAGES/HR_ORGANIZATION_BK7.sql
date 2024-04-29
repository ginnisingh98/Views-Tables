--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK7" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_company_cost_center_b >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_company_cost_center_b
   ( p_effective_date                  IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_company_valueset_id            IN  NUMBER
     ,p_company                        IN  VARCHAR2
     ,p_costcenter_valueset_id         IN  NUMBER
     ,p_costcenter                     IN  VARCHAR2
    );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_company_cost_center_a >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_company_cost_center_a
   (  p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_company_valueset_id            IN  NUMBER
     ,p_company                        IN  VARCHAR2
     ,p_costcenter_valueset_id         IN  NUMBER
     ,p_costcenter                     IN  VARCHAR2
     ,p_ori_org_information_id         IN NUMBER
     ,p_ori_object_version_number      IN NUMBER
     ,p_org_information_id             IN NUMBER
     ,p_object_version_number          IN NUMBER
   );

end hr_organization_bk7;

/
