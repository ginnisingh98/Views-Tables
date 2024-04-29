--------------------------------------------------------
--  DDL for Package PER_PGS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PGS_RKI" AUTHID CURRENT_USER as
/* $Header: pepgsrhi.pkh 120.0 2005/05/31 14:13:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_grade_spine_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_parent_spine_id              in number
  ,p_grade_id                     in number
  ,p_ceiling_step_id              in number
  ,p_starting_step                in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  );
end per_pgs_rki;

 

/
