--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_BK6" AUTHID CURRENT_USER as
/* $Header: pqbreapi.pkh 120.1 2005/10/02 02:26:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_realloc_txn_period_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_realloc_txn_period_b
  (
   p_reallocation_period_id            in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_realloc_txn_period_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_realloc_txn_period_a
  (
   p_reallocation_period_id            in  number
  ,p_object_version_number          in  number
  );
--
end pqh_BDGT_POOL_REALLOCTIONS_bk6;

 

/
