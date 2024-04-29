--------------------------------------------------------
--  DDL for Package PQH_RANK_PROCESS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_PROCESS_BK2" AUTHID CURRENT_USER as
/* $Header: pqrnkapi.pkh 120.1 2005/06/03 11:58:28 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rank_process_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_rank_process_b
  (p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_pgm_id                        in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_process_cd                    in     varchar2
  ,p_process_date                  in     date
  ,p_benefit_action_id             in     number
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_total_score                   in     number
  ,p_request_id                    in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
  ,p_per_in_ler_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rank_process_a >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_rank_process_a
  (p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_pgm_id                        in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_process_cd                    in     varchar2
  ,p_process_date                  in     date
  ,p_benefit_action_id             in     number
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_total_score                   in     number
  ,p_request_id                    in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
  ,p_per_in_ler_id                 in     number
  );
--
end pqh_rank_process_bk2;

 

/
