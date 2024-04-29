--------------------------------------------------------
--  DDL for Package OTA_LPT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPT_RKU" AUTHID CURRENT_USER as
/* $Header: otlptrhi.pkh 120.0 2005/05/29 07:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_learning_path_id             in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_objectives                   in varchar2
  ,p_purpose                      in varchar2
  ,p_keywords                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_objectives_o                 in varchar2
  ,p_purpose_o                    in varchar2
  ,p_keywords_o                   in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_lpt_rku;

 

/
