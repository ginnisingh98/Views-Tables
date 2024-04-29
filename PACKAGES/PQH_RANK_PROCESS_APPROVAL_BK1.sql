--------------------------------------------------------
--  DDL for Package PQH_RANK_PROCESS_APPROVAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_PROCESS_APPROVAL_BK1" AUTHID CURRENT_USER as
/* $Header: pqrapapi.pkh 120.1 2005/06/03 11:58:56 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_rank_process_approval_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rank_process_approval_b
  (p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_rank_process_id               in     number
  ,p_approval_date                 in     date
  ,p_supervisor_id                 in     number
  ,p_system_rank                   in     number
  ,p_population_count              in     number
  ,p_proposed_rank                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_rank_process_approval_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rank_process_approval_a
  (p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_rank_process_id               in     number
  ,p_approval_date                 in     date
  ,p_supervisor_id                 in     number
  ,p_system_rank                   in     number
  ,p_population_count              in     number
  ,p_proposed_rank                 in     number
  ,p_object_version_number         in     number
  );
--
end pqh_rank_process_approval_bk1;

 

/
