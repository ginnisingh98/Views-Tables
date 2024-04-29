--------------------------------------------------------
--  DDL for Package HR_KI_INTEGRATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_INTEGRATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: hrintapi.pkh 120.1 2005/10/02 02:03:08 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_integration_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_integration_b
  (
   p_sso_enabled                   in     boolean
  ,p_integration_id                in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_integration_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_integration_a
  (
   p_sso_enabled                   in     boolean
  ,p_integration_id                in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_integrations_bk3;

 

/
