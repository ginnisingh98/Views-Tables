--------------------------------------------------------
--  DDL for Package HR_TCP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCP_RKU" AUTHID CURRENT_USER as
/* $Header: hrtcprhi.pkh 120.0 2005/05/31 03:00:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_template_item_context_page_i in number
  ,p_object_version_number        in number
  ,p_template_item_context_id     in number
  ,p_template_tab_page_id         in number
  ,p_object_version_number_o      in number
  ,p_template_item_context_id_o   in number
  ,p_template_tab_page_id_o       in number
  );
--
end hr_tcp_rku;

 

/
