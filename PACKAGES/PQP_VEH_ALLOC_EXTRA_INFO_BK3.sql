--------------------------------------------------------
--  DDL for Package PQP_VEH_ALLOC_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEH_ALLOC_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pqvaiapi.pkh 120.0.12010000.3 2008/08/08 07:18:36 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_VEH_ALLOC_EXTRA_INFO_b >-----------------------|
-- ----------------------------------------------------------------------------
--

 procedure delete_veh_alloc_extra_info_b
  ( p_veh_alloc_extra_info_id  in     number
   ,p_vehicle_allocation_id    in     number
   ,p_object_version_number    in     number
  );



-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_VEH_ALLOC_EXTRA_INFO_a >-----------------------|
-- ----------------------------------------------------------------------------

  procedure delete_veh_alloc_extra_info_a
  (p_veh_alloc_extra_info_id   in     number
  ,p_vehicle_allocation_id    in     number
  ,p_object_version_number     in     number
  );
end  PQP_VEH_ALLOC_EXTRA_INFO_BK3;

/
