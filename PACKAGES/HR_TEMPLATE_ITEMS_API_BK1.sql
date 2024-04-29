--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEMS_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEMS_API_BK1" AUTHID CURRENT_USER as
/* $Header: hrtimapi.pkh 120.0 2005/05/31 03:12:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_template_item_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_item_b
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_template_item_id_from         in     number
  ,p_form_template_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_template_item_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_item_a
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_template_item_id_from         in     number
  ,p_form_template_id              in     number
  ,p_template_item_id_to           in     number
  ,p_object_version_number         in     number
  );
--
end hr_template_items_api_bk1;

 

/
