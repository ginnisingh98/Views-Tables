--------------------------------------------------------
--  DDL for Package HR_PDC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDC_RKU" AUTHID CURRENT_USER as
/* $Header: hrpdcrhi.pkh 120.0 2005/09/23 06:44 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_person_deplymt_contact_id    in number
  ,p_person_deployment_id         in number
  ,p_contact_relationship_id      in number
  ,p_object_version_number        in number
  ,p_person_deployment_id_o       in number
  ,p_contact_relationship_id_o    in number
  ,p_object_version_number_o      in number
  );
--
end hr_pdc_rku;

 

/
