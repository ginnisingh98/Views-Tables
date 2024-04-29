--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK10" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------<create_org_class_internal_b>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_org_class_internal_b
  (  p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
     ,p_classification_enabled         IN  VARCHAR2
     ,p_org_information_id             IN  NUMBER
     ,p_object_version_number          IN  NUMBER);
--
-- ----------------------------------------------------------------------------
-- |---------------------<create_org_class_internal_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_org_class_internal_a
  ( p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
     ,p_classification_enabled         IN  VARCHAR2
     ,p_org_information_id             IN  NUMBER
     ,p_object_version_number          IN  NUMBER);
--
end hr_organization_bk10;

/
