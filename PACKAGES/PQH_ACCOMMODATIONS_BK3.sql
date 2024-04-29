--------------------------------------------------------
--  DDL for Package PQH_ACCOMMODATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ACCOMMODATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqaccapi.pkh 120.1 2005/10/02 02:25:22 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_accommodation_b>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_accommodation_b
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_accommodation_id                 in     number
  ,p_object_version_number            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_accommodation_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_accommodation_a
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_accommodation_id                 in     number
  ,p_object_version_number            in     number
  ,p_effective_start_date             in     date
  ,p_effective_end_date               in     date
  );
--
end pqh_accommodations_bk3;

 

/
