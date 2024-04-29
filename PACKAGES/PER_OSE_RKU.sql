--------------------------------------------------------
--  DDL for Package PER_OSE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OSE_RKU" AUTHID CURRENT_USER as
/* $Header: peoserhi.pkh 120.0.12000000.1 2007/01/22 00:38:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_org_structure_element_id     in number
  ,p_organization_id_parent       in number
  ,p_organization_id_child        in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_pos_control_enabled_flag     in varchar2
  ,p_business_group_id_o          in number
  ,p_organization_id_parent_o     in number
  ,p_org_structure_version_id_o   in number
  ,p_organization_id_child_o      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  ,p_pos_control_enabled_flag_o   in varchar2
  );
--
end per_ose_rku;

 

/
