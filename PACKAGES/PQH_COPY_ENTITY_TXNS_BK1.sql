--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_TXNS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_TXNS_BK1" AUTHID CURRENT_USER as
/* $Header: pqcetapi.pkh 120.0 2005/05/29 01:41:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_COPY_ENTITY_TXN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_COPY_ENTITY_TXN_b
  (
   p_transaction_category_id        in  number
  ,p_txn_category_attribute_id      in  number
  ,p_context_business_group_id      in  number
  ,p_datetrack_mode                 in  varchar2
  ,p_context                        in  varchar2
  ,p_action_date                    in  date
  ,p_src_effective_date             in  date
  ,p_number_of_copies               in  number
  ,p_display_name                   in  varchar2
  ,p_replacement_type_cd            in  varchar2
  ,p_start_with                     in  varchar2
  ,p_increment_by                   in  number
  ,p_status                         in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_COPY_ENTITY_TXN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_COPY_ENTITY_TXN_a
  (
   p_copy_entity_txn_id             in  number
  ,p_transaction_category_id        in  number
  ,p_txn_category_attribute_id      in  number
  ,p_context_business_group_id      in  number
  ,p_datetrack_mode                 in  varchar2
  ,p_context                        in  varchar2
  ,p_action_date                    in  date
  ,p_src_effective_date             in  date
  ,p_number_of_copies               in  number
  ,p_display_name                   in  varchar2
  ,p_replacement_type_cd            in  varchar2
  ,p_start_with                     in  varchar2
  ,p_increment_by                   in  number
  ,p_status                         in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end PQH_COPY_ENTITY_TXNS_bk1;

 

/
