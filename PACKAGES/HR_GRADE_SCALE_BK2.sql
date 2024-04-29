--------------------------------------------------------
--  DDL for Package HR_GRADE_SCALE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_SCALE_BK2" AUTHID CURRENT_USER as
/* $Header: pepgsapi.pkh 120.1.12000000.1 2007/01/22 01:19:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_grade_scale_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_scale_b
  (p_effective_date                 in     date
  ,p_grade_spine_id                 in     number
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_grade_id                       in     number
  ,p_ceiling_step_id                in     number
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_grade_scale_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_scale_a
  (p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_grade_spine_id                 in     number
  ,p_object_version_number          in     number
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_grade_id                       in     number
  ,p_ceiling_step_id                in     number
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  );
--
end hr_grade_scale_bk2;

 

/
