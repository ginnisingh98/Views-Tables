--------------------------------------------------------
--  DDL for Package PQH_RAP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RAP_RKI" AUTHID CURRENT_USER as
/* $Header: pqraprhi.pkh 120.0 2005/05/29 02:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_rank_process_approval_id     in number
  ,p_rank_process_id              in number
  ,p_approval_date                in date
  ,p_supervisor_id                in number
  ,p_system_rank                  in number
  ,p_population_count             in number
  ,p_proposed_rank                in number
  ,p_object_version_number        in number
  );
end pqh_rap_rki;

 

/
