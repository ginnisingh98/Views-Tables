--------------------------------------------------------
--  DDL for Package HR_PDC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDC_RKI" AUTHID CURRENT_USER as
/* $Header: hrpdcrhi.pkh 120.0 2005/09/23 06:44 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_person_deplymt_contact_id    in number
  ,p_person_deployment_id         in number
  ,p_contact_relationship_id      in number
  ,p_object_version_number        in number
  );
end hr_pdc_rki;

 

/
