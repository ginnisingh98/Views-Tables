--------------------------------------------------------
--  DDL for Package PER_OSE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OSE_RKI" AUTHID CURRENT_USER as
/* $Header: peoserhi.pkh 120.0.12000000.1 2007/01/22 00:38:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_org_structure_element_id     in number
  ,p_business_group_id            in number
  ,p_organization_id_parent       in number
  ,p_org_structure_version_id     in number
  ,p_organization_id_child        in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_pos_control_enabled_flag     in varchar2
  );
end per_ose_rki;

 

/
