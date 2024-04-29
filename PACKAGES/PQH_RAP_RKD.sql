--------------------------------------------------------
--  DDL for Package PQH_RAP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RAP_RKD" AUTHID CURRENT_USER as
/* $Header: pqraprhi.pkh 120.0 2005/05/29 02:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rank_process_approval_id     in number
  ,p_rank_process_id_o            in number
  ,p_approval_date_o              in date
  ,p_supervisor_id_o              in number
  ,p_system_rank_o                in number
  ,p_population_count_o           in number
  ,p_proposed_rank_o              in number
  ,p_object_version_number_o      in number
  );
--
end pqh_rap_rkd;

 

/
