--------------------------------------------------------
--  DDL for Package HR_KI_INTEGRATIONS_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_INTEGRATIONS_BK4" AUTHID CURRENT_USER as
/* $Header: hrintapi.pkh 120.1 2005/10/02 02:03:08 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_integration_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_integration_b
  (
   p_integration_id                in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_integration_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_integration_a
  (
   p_integration_id                in     number
  ,p_object_version_number         in     number
  ,p_ext_application_id            in     number
  );
--
end hr_ki_integrations_bk4;

 

/
