--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_FUNCTIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_FUNCTIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqcefapi.pkh 120.0 2005/05/29 01:39:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_copy_entity_function_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_function_b
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
-- ----------------------------------------------------------------------------
-- |---------------------------< update_copy_entity_function_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_function_a
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
end pqh_copy_entity_functions_bk2;

 

/
