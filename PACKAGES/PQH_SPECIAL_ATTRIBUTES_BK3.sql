--------------------------------------------------------
--  DDL for Package PQH_SPECIAL_ATTRIBUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SPECIAL_ATTRIBUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqsatapi.pkh 120.0 2005/05/29 02:40:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_special_attribute_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_special_attribute_b
  (
   p_special_attribute_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_special_attribute_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_special_attribute_a
  (
   p_special_attribute_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_special_attributes_bk3;

 

/
