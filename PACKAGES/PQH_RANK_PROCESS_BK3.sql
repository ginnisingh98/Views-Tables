--------------------------------------------------------
--  DDL for Package PQH_RANK_PROCESS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_PROCESS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrnkapi.pkh 120.1 2005/06/03 11:58:28 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rank_process_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure delete_rank_process_b
  (p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rank_process_a >-------------------------|
-- ----------------------------------------------------------------------------
procedure delete_rank_process_a
  (p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_object_version_number         in     number
  );
--
end pqh_rank_process_bk3;

 

/
