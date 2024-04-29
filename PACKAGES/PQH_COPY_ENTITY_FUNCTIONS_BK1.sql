--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_FUNCTIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_FUNCTIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqcefapi.pkh 120.0 2005/05/29 01:39:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_copy_entity_function_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_function_b
  (
   p_table_route_id                 in  number
  ,p_function_type_cd               in  varchar2
  ,p_pre_copy_function_name         in  varchar2
  ,p_copy_function_name             in  varchar2
  ,p_post_copy_function_name        in  varchar2
  ,p_context                        in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_copy_entity_function_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_function_a
  (
   p_copy_entity_function_id        in  number
  ,p_table_route_id                 in  number
  ,p_function_type_cd               in  varchar2
  ,p_pre_copy_function_name         in  varchar2
  ,p_copy_function_name             in  varchar2
  ,p_post_copy_function_name        in  varchar2
  ,p_object_version_number          in  number
  ,p_context                        in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_copy_entity_functions_bk1;

 

/
