--------------------------------------------------------
--  DDL for Package HR_FTP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FTP_RKD" AUTHID CURRENT_USER as
/* $Header: hrftprhi.pkh 120.0 2005/05/31 00:31:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_tab_page_id             in number
  ,p_object_version_number_o      in number
  ,p_form_canvas_id_o             in number
  ,p_tab_page_name_o              in varchar2
  ,p_display_order_o              in number
  ,p_visible_override_o           in number
  );
--
end hr_ftp_rkd;

 

/
