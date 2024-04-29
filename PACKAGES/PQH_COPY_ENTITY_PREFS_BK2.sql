--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_PREFS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_PREFS_BK2" AUTHID CURRENT_USER as
/* $Header: pqcepapi.pkh 120.0 2005/05/29 01:40:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_copy_entity_pref_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_pref_b
  (
   p_copy_entity_pref_id            in  number
  ,p_table_route_id                 in  number
  ,p_copy_entity_txn_id             in  number
  ,p_select_flag                    in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_copy_entity_pref_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_pref_a
  (
   p_copy_entity_pref_id            in  number
  ,p_table_route_id                 in  number
  ,p_copy_entity_txn_id             in  number
  ,p_select_flag                    in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_copy_entity_prefs_bk2;

 

/
