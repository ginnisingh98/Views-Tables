--------------------------------------------------------
--  DDL for Package HR_TMT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TMT_RKI" AUTHID CURRENT_USER as
/* $Header: hrtmtrhi.pkh 120.0 2005/05/31 03:22:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_template_id             in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_template_name           in varchar2
  ,p_description                  in varchar2
  );
end hr_tmt_rki;

 

/
