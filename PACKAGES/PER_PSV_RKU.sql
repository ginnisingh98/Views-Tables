--------------------------------------------------------
--  DDL for Package PER_PSV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSV_RKU" AUTHID CURRENT_USER as
/* $Header: pepsvrhi.pkh 120.0 2005/05/31 15:44:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_pos_structure_version_id     in number
  ,p_business_group_id            in number
  ,p_position_structure_id        in number
  ,p_date_from                    in date
  ,p_version_number               in number
  ,p_copy_structure_version_id    in number
  ,p_date_to                      in date
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
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
end per_psv_rku;

 

/
