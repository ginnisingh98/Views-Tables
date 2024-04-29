--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_BK2" AUTHID CURRENT_USER as
/* $Header: pecwkapi.pkh 120.1.12010000.1 2008/07/28 04:28:14 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< convert_to_cwk_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure convert_to_cwk_b
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_npw_number                    in     varchar2
  ,p_projected_placement_end       in     date
  ,p_person_type_id                in     number
  ,p_datetrack_update_mode         in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< convert_to_cwk_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure convert_to_cwk_a
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_npw_number                    in     varchar2
  ,p_projected_placement_end       in     date
  ,p_person_type_id                in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_per_effective_start_date      in     date
  ,p_per_effective_end_date        in     date
  ,p_pdp_object_version_number     in       number
  ,p_assignment_id                 in     number
  ,p_asg_object_version_number     in     number
  ,p_assignment_sequence           in     number
  );
--
end hr_contingent_worker_bk2;

/
