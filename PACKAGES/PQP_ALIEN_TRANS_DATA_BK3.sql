--------------------------------------------------------
--  DDL for Package PQP_ALIEN_TRANS_DATA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ALIEN_TRANS_DATA_BK3" AUTHID CURRENT_USER as
/* $Header: pqatdapi.pkh 120.0 2005/05/29 01:42:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_alien_trans_data_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alien_trans_data_b
  (
   p_alien_transaction_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_alien_trans_data_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alien_trans_data_a
  (
   p_alien_transaction_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqp_alien_trans_data_bk3;

 

/
