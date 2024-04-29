--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_ALLOCATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_ALLOCATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqvalapi.pkh 120.1 2005/10/02 02:28:38 aroussel $ */
--

  -- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_VEHICLE_ALLOCATION_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vehicle_allocation_b
  (p_validate                       in     boolean
  ,p_effective_date                 in   date
  ,p_datetrack_mode                 in   varchar2
  ,p_vehicle_allocation_id          in   number
  ,p_object_version_number          in   number
  );
  -- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_VEHICLE_ALLOCATION_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vehicle_allocation_a
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_vehicle_allocation_id          in     number
  ,p_object_version_number          in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  );

end PQP_VEHICLE_ALLOCATIONS_BK3;

 

/
