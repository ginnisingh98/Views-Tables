--------------------------------------------------------
--  DDL for Package PQH_BRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BRE_RKI" AUTHID CURRENT_USER as
/* $Header: pqbrerhi.pkh 120.0 2005/05/29 01:34:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end pqh_bre_rki;

 

/
