--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_PREFS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_PREFS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcepapi.pkh 120.0 2005/05/29 01:40:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_pref_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_pref_b
  (
   p_copy_entity_pref_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_pref_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_pref_a
  (
   p_copy_entity_pref_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_copy_entity_prefs_bk3;

 

/
