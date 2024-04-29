--------------------------------------------------------
--  DDL for Package PER_PSV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSV_RKI" AUTHID CURRENT_USER as
/* $Header: pepsvrhi.pkh 120.0 2005/05/31 15:44:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_psv_rki;

 

/
