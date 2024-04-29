--------------------------------------------------------
--  DDL for Package BEN_COPY_ENTITY_RESULTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COPY_ENTITY_RESULTS_BK3" AUTHID CURRENT_USER as
/* $Header: becpeapi.pkh 120.0 2005/05/28 01:12:11 appldev noship $  */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_results_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_results_b
  (
   p_copy_entity_result_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_results_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_results_a
  (
   p_copy_entity_result_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_copy_entity_results_bk3;

 

/
