--------------------------------------------------------
--  DDL for Package PQH_BUDGET_VERSIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_VERSIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbvrapi.pkh 120.1 2005/10/02 02:26:21 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_version_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_version_b
  (
   p_budget_version_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_version_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_version_a
  (
   p_budget_version_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_budget_versions_bk3;

 

/
