--------------------------------------------------------
--  DDL for Package PER_HIERARCHY_VERSIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HIERARCHY_VERSIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pepgvapi.pkh 120.1 2005/10/02 02:21:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hierarchy_versions_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_versions_b
  (
   p_hierarchy_version_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hierarchy_versions_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_versions_a
  (
   p_hierarchy_version_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end per_hierarchy_versions_bk3;

 

/
