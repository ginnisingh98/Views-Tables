--------------------------------------------------------
--  DDL for Package PER_OSE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OSE_RKD" AUTHID CURRENT_USER as
/* $Header: peoserhi.pkh 120.0.12000000.1 2007/01/22 00:38:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_org_structure_element_id     in number
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
end per_ose_rkd;

 

/
