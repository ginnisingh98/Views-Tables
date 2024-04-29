--------------------------------------------------------
--  DDL for Package PQH_ASSIGN_ACCOMMODATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ASSIGN_ACCOMMODATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqasaapi.pkh 120.1 2005/10/02 02:25:29 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------<delete_assign_accommodation_b>---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assign_accommodation_b
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_assignment_acco_id               in     number
  ,p_object_version_number            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------<delete_assign_accommodation_a>---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assign_accommodation_a
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_assignment_acco_id               in     number
  ,p_object_version_number            in     number
  ,p_effective_start_date             in     date
  ,p_effective_end_date               in     date
  );
--
end pqh_assign_accommodations_bk3;

 

/
