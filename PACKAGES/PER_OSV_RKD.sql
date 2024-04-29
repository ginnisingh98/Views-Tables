--------------------------------------------------------
--  DDL for Package PER_OSV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OSV_RKD" AUTHID CURRENT_USER as
/* $Header: peosvrhi.pkh 120.0 2005/05/31 12:38:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_org_structure_version_id     in number
  ,p_business_group_id_o          in number
  ,p_organization_structure_id_o  in number
  ,p_date_from_o                  in date
  ,p_version_number_o             in number
  ,p_copy_structure_version_id_o  in number
  ,p_date_to_o                    in date
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  ,p_topnode_pos_ctrl_enabled_f_o in varchar2
  );
--
end per_osv_rkd;

 

/
