--------------------------------------------------------
--  DDL for Package HR_TPT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TPT_RKU" AUTHID CURRENT_USER as
/* $Header: hrtptrhi.pkh 120.0 2005/05/31 03:26:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_tab_page_property_id         in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_label                        in varchar2
  ,p_source_lang_o                in varchar2
  ,p_label_o                      in varchar2
  );
--
end hr_tpt_rku;

 

/
