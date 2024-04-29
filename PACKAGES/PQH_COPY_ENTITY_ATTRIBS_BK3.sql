--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_ATTRIBS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_ATTRIBS_BK3" AUTHID CURRENT_USER as
/* $Header: pqceaapi.pkh 120.0 2005/05/29 01:37:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_attrib_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_attrib_b
  (
   p_copy_entity_attrib_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_copy_entity_attrib_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_attrib_a
  (
   p_copy_entity_attrib_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_copy_entity_attribs_bk3;

 

/
