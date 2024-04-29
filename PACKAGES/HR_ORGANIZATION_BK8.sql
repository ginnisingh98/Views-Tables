--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK8" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_org_manager_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_org_manager_b
  (p_org_information_id             IN NUMBER
  ,p_object_version_number          IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_org_manager_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_org_manager_a
  (p_org_information_id             IN  NUMBER
  ,p_object_version_number          IN  NUMBER);
--
end hr_organization_bk8;

/
