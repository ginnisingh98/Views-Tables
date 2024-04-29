--------------------------------------------------------
--  DDL for Package PQH_RANK_PROCESS_APPROVAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_PROCESS_APPROVAL_BK3" AUTHID CURRENT_USER as
/* $Header: pqrapapi.pkh 120.1 2005/06/03 11:58:56 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_rank_process_approval_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rank_process_approval_b
  (p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_rank_process_approval_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rank_process_approval_a
  (p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_object_version_number         in     number
  );
--
end pqh_rank_process_approval_bk3;

 

/
