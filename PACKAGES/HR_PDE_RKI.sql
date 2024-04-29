--------------------------------------------------------
--  DDL for Package HR_PDE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDE_RKI" AUTHID CURRENT_USER as
/* $Header: hrpderhi.pkh 120.0 2005/09/23 06:44:22 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_person_deplymt_eit_id        in number
  ,p_person_deployment_id         in number
  ,p_person_extra_info_id         in number
  ,p_object_version_number        in number
  );
end hr_pde_rki;

 

/
