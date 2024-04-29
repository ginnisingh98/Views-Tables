--------------------------------------------------------
--  DDL for Package HR_SP_PLACEMENT_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SP_PLACEMENT_API_BK3" AUTHID CURRENT_USER as
/* $Header: pesppapi.pkh 120.3 2006/05/04 03:44:57 snukala noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_spinal_point_placement_b>---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sp_placement_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_placement_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_spinal_point_placement_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sp_placement_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_placement_id                  in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date	   in	  date
  ,p_effective_end_date		   in	  date
  );
--
end hr_sp_placement_api_bk3;

 

/
