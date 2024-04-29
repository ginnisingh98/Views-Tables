--------------------------------------------------------
--  DDL for Package HR_TCP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCP_RKD" AUTHID CURRENT_USER as
/* $Header: hrtcprhi.pkh 120.0 2005/05/31 03:00:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_item_context_page_i in number
  ,p_object_version_number_o      in number
  ,p_template_item_context_id_o   in number
  ,p_template_tab_page_id_o       in number
  );
--
end hr_tcp_rkd;

 

/
