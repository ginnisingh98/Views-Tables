--------------------------------------------------------
--  DDL for Package OTA_LST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LST_RKD" AUTHID CURRENT_USER as
/* $Header: otlstrhi.pkh 120.0 2005/05/29 07:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_learning_path_section_id     in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_lst_rkd;

 

/
