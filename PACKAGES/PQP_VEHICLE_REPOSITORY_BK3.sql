--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_REPOSITORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_REPOSITORY_BK3" AUTHID CURRENT_USER as
/* $Header: pqvreapi.pkh 120.1 2005/10/02 02:28:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_vehicle_b >-------------------------|
-- ----------------------------------------------------------------------------
--

 Procedure delete_vehicle_b
  (p_validate                         in     boolean
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_vehicle_repository_id            in     number
  ,p_object_version_number            in     number
  );



-- ----------------------------------------------------------------------------
-- |-------------------------< delete_vehicle_a >-------------------------|
-- ----------------------------------------------------------------------------
--
 Procedure delete_vehicle_a
  (p_validate                         in     boolean
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_vehicle_repository_id            in     number
  ,p_object_version_number            in     number
  ,p_effective_start_date             in     date
  ,p_effective_end_date               in     date
  );

end PQP_VEHICLE_REPOSITORY_BK3;

 

/
