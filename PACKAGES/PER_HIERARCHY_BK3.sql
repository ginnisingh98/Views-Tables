--------------------------------------------------------
--  DDL for Package PER_HIERARCHY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HIERARCHY_BK3" AUTHID CURRENT_USER as
/* $Header: pepghapi.pkh 120.1 2005/10/02 02:21:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hierarchy_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_b
  (
   p_hierarchy_id                   in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hierarchy_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_a
  (
   p_hierarchy_id                   in  number
  ,p_object_version_number          in  number
  );
--
end per_hierarchy_bk3;

 

/
