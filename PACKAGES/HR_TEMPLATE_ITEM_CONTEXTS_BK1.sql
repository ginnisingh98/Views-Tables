--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_CONTEXTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_CONTEXTS_BK1" AUTHID CURRENT_USER as
/* $Header: hrticapi.pkh 120.0 2005/05/31 03:08:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< copy_template_item_context_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_item_context_b
  (p_effective_date                in     date
  ,p_language_code                 in varchar2
  ,p_template_item_context_id_frm  in number
  ,p_template_item_id              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< copy_template_item_context_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_item_context_a
  (p_effective_date                in     date
  ,p_language_code                 in varchar2
  ,p_template_item_context_id_frm  in number
  ,p_template_item_id              in number
  ,p_template_item_context_id_to   in number
  ,p_object_version_number         in number
  ,p_item_context_id               in number
  ,p_concatenated_segments         in varchar2
  );
--
end hr_template_item_contexts_bk1;

 

/
