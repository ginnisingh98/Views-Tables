--------------------------------------------------------
--  DDL for Package PQP_ANALYZED_ALIEN_DATA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ANALYZED_ALIEN_DATA_BK3" AUTHID CURRENT_USER as
/* $Header: pqaadapi.pkh 120.0 2005/05/29 01:39:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_analyzed_alien_data_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_analyzed_alien_data_b
  (
   p_analyzed_data_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_analyzed_alien_data_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_analyzed_alien_data_a
  (
   p_analyzed_data_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqp_analyzed_alien_data_bk3;

 

/
