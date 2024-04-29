--------------------------------------------------------
--  DDL for Package HR_FTT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FTT_RKI" AUTHID CURRENT_USER as
/* $Header: hrfttrhi.pkh 120.0 2005/05/31 00:31:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_tab_page_id             in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_tab_page_name           in varchar2
  ,p_description                  in varchar2
  );
end hr_ftt_rki;

 

/
