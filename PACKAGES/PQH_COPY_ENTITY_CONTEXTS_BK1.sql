--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_CONTEXTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_CONTEXTS_BK1" AUTHID CURRENT_USER as
/* $Header: pqcecapi.pkh 120.0 2005/05/29 01:38:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_copy_entity_context_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_context_b
  (
   p_application_short_name         in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_responsibility_key             in  varchar2
  ,p_transaction_short_name         in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_copy_entity_context_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_context_a
  (
   p_context                        in  varchar2
  ,p_application_short_name         in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_responsibility_key             in  varchar2
  ,p_transaction_short_name         in  varchar2
  ,p_object_version_number          in  number
  );
--
end pqh_copy_entity_contexts_bk1;

 

/
