--------------------------------------------------------
--  DDL for Package PER_CHECKLISTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHECKLISTS_BK3" AUTHID CURRENT_USER as
/* $Header: pecklapi.pkh 120.1 2005/12/13 03:13:45 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_checklist_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_checklist_b
  (p_checklist_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_checklist_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_checklist_a
  (p_checklist_id                  in     number
  ,p_object_version_number         in     number
  );
--
end PER_CHECKLISTS_BK3;

 

/
