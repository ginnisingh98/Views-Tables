--------------------------------------------------------
--  DDL for Package HR_FTP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FTP_RKI" AUTHID CURRENT_USER as
/* $Header: hrftprhi.pkh 120.0 2005/05/31 00:31:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_form_tab_page_id             in number
  ,p_object_version_number        in number
  ,p_form_canvas_id               in number
  ,p_tab_page_name                in varchar2
  ,p_display_order                in number
  ,p_visible_override             in number
  );
end hr_ftp_rki;

 

/
