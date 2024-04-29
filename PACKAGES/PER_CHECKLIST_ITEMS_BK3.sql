--------------------------------------------------------
--  DDL for Package PER_CHECKLIST_ITEMS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHECKLIST_ITEMS_BK3" AUTHID CURRENT_USER as
/* $Header: pechkapi.pkh 120.1 2005/10/02 02:13:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_checklist_items_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_checklist_items_b
  (
   p_checklist_item_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_checklist_items_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_checklist_items_a
  (
   p_checklist_item_id              in  number
  ,p_object_version_number          in  number
  );
--
end per_checklist_items_bk3;

 

/
