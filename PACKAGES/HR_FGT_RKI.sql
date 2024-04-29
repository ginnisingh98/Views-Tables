--------------------------------------------------------
--  DDL for Package HR_FGT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FGT_RKI" AUTHID CURRENT_USER as
/* $Header: hrfgtrhi.pkh 120.0 2005/05/31 00:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_data_group_id           in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_data_group_name         in varchar2
  ,p_description                  in varchar2
  );
end hr_fgt_rki;

 

/
