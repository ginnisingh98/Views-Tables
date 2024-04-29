--------------------------------------------------------
--  DDL for Package HR_GRADE_SCALE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_SCALE_BK3" AUTHID CURRENT_USER as
/* $Header: pepgsapi.pkh 120.1.12000000.1 2007/01/22 01:19:51 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< delete_grade_scale_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_scale_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_grade_spine_id                in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_grade_scale_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_scale_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_grade_spine_id                in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
end hr_grade_scale_bk3;

 

/
