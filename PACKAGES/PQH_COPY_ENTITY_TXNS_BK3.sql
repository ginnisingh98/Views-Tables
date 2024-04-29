--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_TXNS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_TXNS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcetapi.pkh 120.0 2005/05/29 01:41:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_COPY_ENTITY_TXN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_COPY_ENTITY_TXN_b
  (
   p_copy_entity_txn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_COPY_ENTITY_TXN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_COPY_ENTITY_TXN_a
  (
   p_copy_entity_txn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end PQH_COPY_ENTITY_TXNS_bk3;

 

/
