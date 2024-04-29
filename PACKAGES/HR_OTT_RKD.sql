--------------------------------------------------------
--  DDL for Package HR_OTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OTT_RKD" AUTHID CURRENT_USER as
/* $Header: hrottrhi.pkh 120.0 2005/05/31 01:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_option_type_id               in number
  ,p_language                     in varchar2
  ,p_option_name_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hr_ott_rkd;

 

/
