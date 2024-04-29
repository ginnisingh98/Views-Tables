--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqattapi.pkh 120.0 2005/05/29 01:26:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ATTRIBUTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ATTRIBUTE_b
  (
   p_attribute_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ATTRIBUTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ATTRIBUTE_a
  (
   p_attribute_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ATTRIBUTES_bk3;

 

/
