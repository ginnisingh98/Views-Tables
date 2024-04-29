--------------------------------------------------------
--  DDL for Package HR_PDE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDE_RKU" AUTHID CURRENT_USER as
/* $Header: hrpderhi.pkh 120.0 2005/09/23 06:44:22 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_person_deplymt_eit_id        in number
  ,p_person_deployment_id         in number
  ,p_person_extra_info_id         in number
  ,p_object_version_number        in number
  ,p_person_deployment_id_o       in number
  ,p_person_extra_info_id_o       in number
  ,p_object_version_number_o      in number
  );
--
end hr_pde_rku;

 

/
