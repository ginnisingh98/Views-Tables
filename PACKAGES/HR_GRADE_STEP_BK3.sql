--------------------------------------------------------
--  DDL for Package HR_GRADE_STEP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_STEP_BK3" AUTHID CURRENT_USER as
/* $Header: pespsapi.pkh 120.3.12000000.1 2007/01/22 04:39:16 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_grade_step_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_step_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_grade_step_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_step_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
end hr_grade_step_bk3;

 

/
