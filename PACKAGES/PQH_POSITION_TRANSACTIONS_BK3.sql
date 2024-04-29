--------------------------------------------------------
--  DDL for Package PQH_POSITION_TRANSACTIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_POSITION_TRANSACTIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqptxapi.pkh 120.0 2005/05/29 02:22:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_position_transaction_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position_transaction_b
  (
   p_position_transaction_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_position_transaction_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position_transaction_a
  (
   p_position_transaction_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_position_transactions_bk3;

 

/
