--------------------------------------------------------
--  DDL for Package HR_WPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WPT_RKI" AUTHID CURRENT_USER as
/* $Header: hrwptrhi.pkh 120.0 2005/05/31 03:52:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_window_property_id           in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_title                        in varchar2
  );
end hr_wpt_rki;

 

/
