--------------------------------------------------------
--  DDL for Package PQH_BUDGET_GL_FLEX_MAPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_GL_FLEX_MAPS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbgmapi.pkh 120.2 2006/06/05 19:10:33 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_gl_flex_map_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_gl_flex_map_b
  (
   p_budget_gl_flex_map_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_gl_flex_map_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_gl_flex_map_a
  (
   p_budget_gl_flex_map_id          in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_gl_flex_maps_bk3;

 

/
