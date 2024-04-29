--------------------------------------------------------
--  DDL for Package HR_PROGRESSION_POINT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROGRESSION_POINT_BK3" AUTHID CURRENT_USER as
/* $Header: pepspapi.pkh 120.1 2005/10/02 02:22:39 aroussel $ */
-- ----------------------------------------------------------------------------
-- |------------------< delete_progression_point_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_progression_point_b
  (p_validate                      in     boolean
  ,p_spinal_point_id               in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------< delete_progression_point_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_progression_point_a
  (p_validate                      in     boolean
  ,p_spinal_point_id               in     number
  ,p_object_version_number         in     number
  );
end hr_progression_point_bk3;

 

/
