--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTE_RANGES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTE_RANGES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrngapi.pkh 120.1 2005/10/02 02:27:43 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ATTRIBUTE_RANGE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ATTRIBUTE_RANGE_b
  (
   p_attribute_range_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ATTRIBUTE_RANGE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ATTRIBUTE_RANGE_a
  (
   p_attribute_range_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ATTRIBUTE_RANGES_bk3;

 

/
