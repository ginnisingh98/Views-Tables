--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_CONTEXTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_CONTEXTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcecapi.pkh 120.0 2005/05/29 01:38:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_context_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_context_b
  (
   p_context                        in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_context_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_context_a
  (
   p_context                        in  varchar2
  ,p_object_version_number          in  number
  );
--
end pqh_copy_entity_contexts_bk3;

 

/
