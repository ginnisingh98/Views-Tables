--------------------------------------------------------
--  DDL for Package PER_PSV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSV_RKD" AUTHID CURRENT_USER as
/* $Header: pepsvrhi.pkh 120.0 2005/05/31 15:44:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_pos_structure_version_id     in number
  ,p_business_group_id_o          in number
  ,p_position_structure_id_o      in number
  ,p_date_from_o                  in date
  ,p_version_number_o             in number
  ,p_copy_structure_version_id_o  in number
  ,p_date_to_o                    in date
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end per_psv_rkd;

 

/
