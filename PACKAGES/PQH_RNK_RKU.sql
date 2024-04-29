--------------------------------------------------------
--  DDL for Package PQH_RNK_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RNK_RKU" AUTHID CURRENT_USER as
/* $Header: pqrnkrhi.pkh 120.0 2005/05/29 02:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_rank_process_id              in number
  ,p_pgm_id                       in number
  ,p_pl_id                        in number
  ,p_oipl_id                      in number
  ,p_process_cd                   in varchar2
  ,p_process_date                 in date
  ,p_benefit_action_id            in number
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_total_score                  in number
  ,p_object_version_number        in number
  ,p_request_id                   in number
  ,p_business_group_id            in number
  ,p_per_in_ler_id                in number
  ,p_pgm_id_o                     in number
  ,p_pl_id_o                      in number
  ,p_oipl_id_o                    in number
  ,p_process_cd_o                 in varchar2
  ,p_process_date_o               in date
  ,p_benefit_action_id_o          in number
  ,p_person_id_o                  in number
  ,p_assignment_id_o              in number
  ,p_total_score_o                in number
  ,p_object_version_number_o      in number
  ,p_request_id_o                 in number
  ,p_business_group_id_o          in number
  ,p_per_in_ler_id_o              in number
  );
--
end pqh_rnk_rku;

 

/
