--------------------------------------------------------
--  DDL for Package PER_PSE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSE_RKU" AUTHID CURRENT_USER as
/* $Header: pepserhi.pkh 120.0.12010000.1 2008/07/28 05:26:35 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_pos_structure_element_id     in number
  ,p_business_group_id            in number
  ,p_pos_structure_version_id     in number
  ,p_subordinate_position_id      in number
  ,p_parent_position_id           in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_pos_structure_version_id_o   in number
  ,p_subordinate_position_id_o    in number
  ,p_parent_position_id_o         in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end per_pse_rku;

/
