--------------------------------------------------------
--  DDL for Package PQH_BUDGET_DETAILS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_DETAILS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbdtapi.pkh 120.1 2005/10/02 02:25:37 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_detail_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_detail_b
  (
   p_budget_detail_id               in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_detail_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_detail_a
  (
   p_budget_detail_id               in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_details_bk3;

 

/
