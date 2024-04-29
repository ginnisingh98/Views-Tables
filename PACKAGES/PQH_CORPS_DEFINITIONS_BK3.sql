--------------------------------------------------------
--  DDL for Package PQH_CORPS_DEFINITIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_DEFINITIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcpdapi.pkh 120.1 2005/10/02 02:26:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_corps_definition_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_corps_definition_b
  (
  p_corps_definition_id            in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_corps_definition_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_corps_definition_a
  (
  p_corps_definition_id            in  number
  ,p_object_version_number          in number
  );
--
end pqh_corps_definitions_bk3;

 

/
