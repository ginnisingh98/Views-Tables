--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_ATTRIBUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_ATTRIBUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqtcaapi.pkh 120.1 2005/10/02 02:28:20 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TXN_CAT_ATTRIBUTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TXN_CAT_ATTRIBUTE_b
  (
   p_txn_category_attribute_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TXN_CAT_ATTRIBUTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TXN_CAT_ATTRIBUTE_a
  (
   p_txn_category_attribute_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_TXN_CAT_ATTRIBUTES_bk3;

 

/
