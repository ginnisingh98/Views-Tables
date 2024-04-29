--------------------------------------------------------
--  DDL for Package HR_GRADE_SCALE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_SCALE_BK1" AUTHID CURRENT_USER as
/* $Header: pepgsapi.pkh 120.1.12000000.1 2007/01/22 01:19:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_grade_scale_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_grade_scale_b
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_grade_id                       in     number
  ,p_ceiling_point_id               in     number
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_grade_scale_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_grade_scale_a
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_grade_id                       in     number
  ,p_ceiling_point_id               in     number
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_grade_spine_id                 in     number
  ,p_ceiling_step_id                in     number
  ,p_object_version_number          in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  );
--
end hr_grade_scale_bk1;

 

/
