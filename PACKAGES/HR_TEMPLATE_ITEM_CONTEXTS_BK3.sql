--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_CONTEXTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_CONTEXTS_BK3" AUTHID CURRENT_USER as
/* $Header: hrticapi.pkh 120.0 2005/05/31 03:08:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------< delete_template_item_context_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item_context_b
  (p_template_item_context_id     in    number
   ,p_object_version_number       in    number
   --,p_delete_children_flag        in    varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------< delete_template_item_context_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item_context_a
  (p_template_item_context_id     in    number
   ,p_object_version_number       in    number
   --,p_delete_children_flag        in    varchar2
  );
--
end hr_template_item_contexts_bk3;

 

/
