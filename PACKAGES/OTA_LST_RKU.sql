--------------------------------------------------------
--  DDL for Package OTA_LST_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LST_RKU" AUTHID CURRENT_USER as
/* $Header: otlstrhi.pkh 120.0 2005/05/29 07:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_learning_path_section_id     in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_lst_rku;

 

/
