--------------------------------------------------------
--  DDL for Package PER_ALLOCATED_CHECKLIST_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALLOCATED_CHECKLIST_BK3" AUTHID CURRENT_USER as
/* $Header: pepacapi.pkh 120.2 2005/12/13 03:15:03 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alloc_checklist_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alloc_checklist_b
  (p_allocated_checklist_id          in     number
  ,p_object_version_number           in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_alloc_checklist_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alloc_checklist_a
  (p_allocated_checklist_id          in     number
  ,p_object_version_number           in     number
  );
--
end PER_ALLOCATED_CHECKLIST_BK3;

 

/
