--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbreapi.pkh 120.1 2005/10/02 02:26:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_realloc_txn_dtl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_realloc_txn_dtl_b
  (
   p_txn_detail_id            in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_realloc_txn_dtl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_realloc_txn_dtl_a
  (
   p_txn_detail_id            in  number
  ,p_object_version_number          in  number
  );
--
end pqh_BDGT_POOL_REALLOCTIONS_bk3;

 

/
