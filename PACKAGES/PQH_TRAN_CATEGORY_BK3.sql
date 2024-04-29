--------------------------------------------------------
--  DDL for Package PQH_TRAN_CATEGORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRAN_CATEGORY_BK3" AUTHID CURRENT_USER as
/* $Header: pqtctapi.pkh 120.1 2005/10/02 02:28:26 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TRAN_CATEGORY_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TRAN_CATEGORY_b
  (
   p_transaction_category_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TRAN_CATEGORY_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TRAN_CATEGORY_a
  (
   p_transaction_category_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_TRAN_CATEGORY_bk3;

 

/
