--------------------------------------------------------
--  DDL for Package PQH_BRE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BRE_RKU" AUTHID CURRENT_USER as
/* $Header: pqbrerhi.pkh 120.0 2005/05/29 01:34:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_reallocation_id              in number
  ,p_position_id                  in number
  ,p_pool_id                      in number
  ,p_reallocation_amt             in number
  ,p_reserved_amt                 in number
  ,p_object_version_number        in number
  ,p_txn_detail_id               in number
  ,p_transaction_type             in varchar2
  ,p_budget_detail_id             in number
  ,p_budget_period_id             in number
  ,p_entity_id                    in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_position_id_o                in number
  ,p_pool_id_o                    in number
  ,p_reallocation_amt_o           in number
  ,p_reserved_amt_o               in number
  ,p_object_version_number_o      in number
  ,p_txn_detail_id_o             in number
  ,p_transaction_type_o           in varchar2
  ,p_budget_detail_id_o           in number
  ,p_budget_period_id_o           in number
  ,p_entity_id_o                  in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  );
--
end pqh_bre_rku;

 

/
