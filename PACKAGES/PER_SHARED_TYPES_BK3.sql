--------------------------------------------------------
--  DDL for Package PER_SHARED_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SHARED_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: peshtapi.pkh 120.0 2005/05/31 21:04:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_shared_type_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_shared_type_b
  (
   p_shared_type_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_shared_type_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_shared_type_a
  (
   p_shared_type_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end per_shared_types_bk3;

 

/
